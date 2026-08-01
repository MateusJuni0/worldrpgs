class_name NetProtocol
extends RefCounted
## O formato do fio: o que viaja entre as duas casas, e quantos bytes custa.
##
## Fonte: spec/19-rede.md — instantaneos a 20 Hz, interpolacao de 100 ms,
## eventos fiaveis e imediatos, e o tecto de 30 kbps por sentido com
## 2 jogadores + <= 5 inimigos.
##
## PORQUE E QUE ISTO E UM FICHEIRO PROPRIO:
## o orcamento de largura de banda ganha-se ou perde-se na serializacao, e um
## numero que ninguem consegue medir nao e um orcamento — e uma esperanca.
## Aqui o formato esta declarado, e o net_selftest.gd conta os bytes de verdade.

## Versao do protocolo. Duas maquinas com versoes diferentes NAO se ligam:
## e melhor recusar a ligacao do que dessincronizar em silencio a meio de um chefe.
const VERSION := 1

## spec/19: "instantaneos do anfitriao a 20 Hz".
const SNAPSHOT_HZ := 20.0
const SNAPSHOT_INTERVAL := 1.0 / SNAPSHOT_HZ

## spec/19: "interpolacao de 100 ms nos ecras". O corpo remoto desenha-se
## sempre 100 ms no passado, para haver sempre dois instantaneos a envolver
## o instante pedido — e nunca extrapolar, que e o que faz os corpos tremer.
const INTERPOLATION_DELAY := 0.100

## spec/19: "alvo de largura de banda < 30 kbps por sentido".
const BANDWIDTH_BUDGET_BPS := 30000

## spec/19: "latencia alvo entre casas < 80 ms; acima de 150 ms sustentados,
## aviso discreto no ecra".
const LATENCY_TARGET_MS := 80
const LATENCY_WARN_MS := 150
## "Sustentados" tem de ser um numero, senao o aviso pisca com cada soluco.
const LATENCY_WARN_SUSTAIN_S := 3.0

## spec/19: "aceita-se o relatorio se chegar <= 150 ms depois do frame activo".
const PARRY_REPORT_TOLERANCE_MS := 150

## spec/19: "pausa de sincronizacao ate 10 s; acima disso, trata-se como desligar".
const STALL_PAUSE_S := 5.0
const STALL_GIVE_UP_S := 10.0

## spec/19: "2 jogadores exactamente".
const MAX_PLAYERS := 2

## O tecto de cena do WP12, que e tambem o tecto de rede.
const MAX_REPLICATED_ENEMIES := 5


# --- Canais ------------------------------------------------------------------
# A escolha do canal E a decisao de desenho. Um instantaneo perdido nao se
# repete (ja vem outro a caminho); um golpe perdido e a Lei 1 quebrada.

enum Channel {
	SNAPSHOT = 1,  ## nao fiavel, ordenado — perder um nao faz mal
	EVENT = 2,     ## FIAVEL — golpes, parries, mortes, aggro
	PING = 3,      ## nao fiavel — mede a linha
}


# --- Tipos de evento ---------------------------------------------------------
# Estes viajam no canal fiavel. Sao poucos de proposito: cada um custa
# garantia de entrega, e garantia de entrega custa latencia quando ha perda.

enum Event {
	HIT_LANDED = 1,      ## acertei num inimigo (convidado -> anfitriao)
	DAMAGE_TAKEN = 2,    ## levei X (o proprio decide, spec/19 "com o meu relogio")
	PARRY = 3,           ## aparei o ataque N
	DODGE_WINDOW = 4,    ## estive invencivel de A a B (o relatorio de i-frames)
	DEATH = 5,
	REVIVE = 6,
	AGGRO = 7,           ## um inimigo mudou de alvo
	BOSS_PHASE = 8,
	ENEMY_DIED = 9,
	FLASK = 10,
	SPELL_CAST = 11,
}


# --- Instantaneo de corpo ----------------------------------------------------
# 19 bytes por corpo. A conta NAO vive nesta prosa — vive no net_selftest.gd,
# que serializa um corpo de verdade e conta os bytes. (E ainda bem: esta tabela
# dizia 18 porque me esqueci do id, e foi o teste que apanhou.)
#
#   id do corpo      1 x uint8      1 B
#   posicao          3 x float32   12 B
#   orientacao Y     1 x float16    2 B  (so o yaw: ninguem se inclina neste jogo)
#   estado           1 x uint8      1 B  (Player.State cabe folgado)
#   frame do estado  1 x uint8      1 B  (satura a 255; e so para animacao)
#   vida em 8 bits   1 x uint8      1 B  (fraccao 0-255; a vida exacta e do dono)
#   bandeiras        1 x uint8      1 B  (invencivel, a bloquear, ...)
#                                  ----
#                                   19 B

const BODY_BYTES := 19

enum BodyFlag {
	INVULNERABLE = 1,
	BLOCKING = 2,
	HYPER_ARMOR = 4,
	LOCKED_ON = 8,
	DEAD = 16,
}


## Escreve um corpo no buffer. Devolve o numero de bytes escritos.
static func write_body(buf: StreamPeerBuffer, id: int, pos: Vector3,
		yaw: float, state: int, frame: int, health_fraction: float, flags: int) -> void:
	buf.put_u8(id)
	buf.put_float(pos.x)
	buf.put_float(pos.y)
	buf.put_float(pos.z)
	buf.put_half(yaw)
	buf.put_u8(clampi(state, 0, 255))
	buf.put_u8(clampi(frame, 0, 255))
	buf.put_u8(clampi(int(round(health_fraction * 255.0)), 0, 255))
	buf.put_u8(clampi(flags, 0, 255))


static func read_body(buf: StreamPeerBuffer) -> Dictionary:
	var id := buf.get_u8()
	var pos := Vector3(buf.get_float(), buf.get_float(), buf.get_float())
	var yaw := buf.get_half()
	var state := buf.get_u8()
	var frame := buf.get_u8()
	var health := float(buf.get_u8()) / 255.0
	var flags := buf.get_u8()
	return {
		"id": id, "position": pos, "yaw": yaw, "state": state,
		"frame": frame, "health_fraction": health, "flags": flags,
	}


## Quantos bytes por segundo custa um instantaneo com N corpos.
## O +1 do id ja esta no BODY_BYTES; o cabecalho leva o relogio do anfitriao.
const SNAPSHOT_HEADER_BYTES := 5  # 1 (contagem) + 4 (tempo do anfitriao, float32)

static func snapshot_bytes(body_count: int) -> int:
	return SNAPSHOT_HEADER_BYTES + body_count * BODY_BYTES


static func snapshot_bits_per_second(body_count: int) -> int:
	return int(snapshot_bytes(body_count) * SNAPSHOT_HZ * 8.0)


## O pior caso previsto pela spec: 2 jogadores + 5 inimigos.
static func worst_case_bits_per_second() -> int:
	return snapshot_bits_per_second(MAX_PLAYERS + MAX_REPLICATED_ENEMIES)


# --- A regra do parry a distancia --------------------------------------------

## spec/19: "aceita-se o relatorio [de parry] se chegar <= 150 ms depois do
## frame activo do ataque".
##
## ⭐ E QUANDO CHEGA TARDE, NAO SE ACUSA NINGUEM. Assume-se linha ma e o golpe
## conta como acertado. Entre dois amigos nao ha batoteiros por definicao de
## projecto (spec/19) — o unico suspeito e sempre o router, e tratar o parceiro
## como suspeito seria desenhar para um problema que este jogo nao tem.
##
## Vive no protocolo e nao na sessao porque e uma REGRA DO FIO: descreve o que
## e aceitavel receber, e tem de ser testavel sem haver sessao nenhuma aberta.
## ⚠️ A folga de 0,5 ms nao e generosidade — e virgula flutuante. Subtrair dois
## instantes e multiplicar por 1000 nao da 150,0 exactos, da 150,0000000000002;
## sem a folga, um parry EXACTAMENTE no limite era recusado por um erro de
## arredondamento. Meio milissegundo nao muda o desenho e fecha o buraco.
## (Tambem isto foi o teste que apanhou, nao a releitura.)
const _FLOAT_SLACK_MS := 0.5

static func parry_report_is_timely(reported_at: float, active_frame_at: float) -> bool:
	var delay_ms := (reported_at - active_frame_at) * 1000.0
	return delay_ms >= -_FLOAT_SLACK_MS \
		and delay_ms <= PARRY_REPORT_TOLERANCE_MS + _FLOAT_SLACK_MS
