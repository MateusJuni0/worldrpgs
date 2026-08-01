class_name NetLinkQuality
extends RefCounted
## Mede a linha e decide quando o jogo avisa. Fonte: spec/19-rede.md —
## "latencia alvo < 80 ms; acima de 150 ms sustentados, aviso discreto no ecra
## — o jogo nao esconde a linha ma, porque esconder faria a injustica parecer
## do jogo".
##
## ESSA FRASE E O DOCUMENTO TODO. Num souls-like o jogador culpa-se a si proprio
## quando morre, e e isso que o faz melhorar. Se a morte foi da linha e o jogo
## nao o disser, o jogador aprende a licao errada — conclui que a esquiva nao
## funciona, e a Lei 1 morre por causa de um router.

enum Quality { BOA, ACEITAVEL, MA, PERDIDA }

## Media movel exponencial: reage a mudancas reais sem saltar com um pico solto.
const SMOOTHING := 0.25

var rtt_ms := 0.0
var jitter_ms := 0.0
var packet_loss := 0.0

var _has_sample := false
var _above_warn_since := -1.0
var _last_packet_time := 0.0
var _sent := 0
var _received := 0


## Um pong voltou. `rtt` em milissegundos.
func add_sample(rtt: float, now: float) -> void:
	_received += 1
	_last_packet_time = now
	if not _has_sample:
		rtt_ms = rtt
		_has_sample = true
	else:
		var previous := rtt_ms
		rtt_ms = lerpf(rtt_ms, rtt, SMOOTHING)
		# Jitter e a variacao, nao o valor. Uma linha de 120 ms estavel joga-se
		# melhor do que uma de 60 ms que salta para 200 — porque a estavel
		# aprende-se e a instavel nao.
		jitter_ms = lerpf(jitter_ms, absf(rtt - previous), SMOOTHING)

	if rtt_ms > NetProtocol.LATENCY_WARN_MS:
		if _above_warn_since < 0.0:
			_above_warn_since = now
	else:
		_above_warn_since = -1.0


func mark_sent() -> void:
	_sent += 1
	if _sent > 0:
		packet_loss = 1.0 - (float(_received) / float(_sent))


## O aviso so aparece depois de a linha estar ma de forma SUSTENTADA.
## Sem isto, um soluco de 200 ms punha um aviso a piscar no ecra a meio de um
## chefe — e um aviso que pisca e ruido, nao informacao.
func should_warn(now: float) -> bool:
	if _above_warn_since < 0.0:
		return false
	return (now - _above_warn_since) >= NetProtocol.LATENCY_WARN_SUSTAIN_S


func quality(now: float) -> Quality:
	if not _has_sample:
		return Quality.BOA
	var silence := now - _last_packet_time
	if silence >= NetProtocol.STALL_GIVE_UP_S:
		return Quality.PERDIDA
	if should_warn(now) or silence >= NetProtocol.STALL_PAUSE_S:
		return Quality.MA
	if rtt_ms > NetProtocol.LATENCY_TARGET_MS:
		return Quality.ACEITAVEL
	return Quality.BOA


## O que se mostra ao jogador. Em portugues, e sem codigo de erro nenhum:
## quem esta a jogar precisa de saber o que fazer, nao de um numero para
## copiar para o Google.
func describe(now: float) -> String:
	match quality(now):
		Quality.PERDIDA:
			return "Ligação perdida"
		Quality.MA:
			return "Ligação instável (%d ms)" % int(rtt_ms)
		Quality.ACEITAVEL:
			return "%d ms" % int(rtt_ms)
		_:
			return "%d ms" % int(rtt_ms)


func reset() -> void:
	rtt_ms = 0.0
	jitter_ms = 0.0
	packet_loss = 0.0
	_has_sample = false
	_above_warn_since = -1.0
	_sent = 0
	_received = 0
