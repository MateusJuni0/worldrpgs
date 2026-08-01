class_name NetInterpolator
extends RefCounted
## Guarda instantaneos com relogio e devolve a pose de um corpo remoto
## 100 ms no passado. Fonte: spec/19-rede.md.
##
## PORQUE 100 ms NO PASSADO:
## os instantaneos chegam a 20 Hz, ou seja de 50 em 50 ms, e a linha nao os
## entrega com regua. Desenhar o ultimo que chegou faz o corpo saltar; extrapolar
## para o presente faz o corpo passar a parede e voltar atras quando o instantaneo
## seguinte desmente a previsao. Atrasar 100 ms garante que ha SEMPRE dois
## instantaneos a envolver o instante pedido — e dois instantaneos que envolvem
## interpolam-se sem inventar nada.
##
## O preco e honesto e esta escrito: ve-se o parceiro 100 ms atras. Num jogo em
## que ninguem pode ferir ninguem (spec/19: sem fogo amigo), isso nao muda
## nenhuma decisao de combate — o que interessa e que o corpo se leia, e um
## corpo suave le-se; um corpo aos saltos nao.

## Quantos instantaneos guardar. A 20 Hz, 12 sao 600 ms de historico — chega
## para os 100 ms de atraso mais uma folga generosa de jitter.
const HISTORY := 12

var _samples: Array[Dictionary] = []
## Diferenca entre o relogio do anfitriao e o nosso. Nao se sincronizam relogios
## a serio: guarda-se o desvio da PRIMEIRA amostra e usa-se o mesmo sempre, o
## que basta para interpolar (interessa a diferenca entre amostras, nao a hora).
var _clock_offset := 0.0
var _has_offset := false


## Um instantaneo novo chegou. `host_time` e o relogio do anfitriao,
## `local_time` o nosso no momento em que chegou.
func push(host_time: float, local_time: float, body: Dictionary) -> void:
	if not _has_offset:
		_clock_offset = local_time - host_time
		_has_offset = true
	var sample := body.duplicate()
	sample["t"] = host_time + _clock_offset  # ja no nosso relogio
	# Chegou fora de ordem? Deita-se fora. Com o canal nao-fiavel ordenado isto
	# quase nao acontece, mas "quase" e o que estraga um corpo a meio de um chefe.
	if not _samples.is_empty() and float(sample["t"]) <= float(_samples[-1]["t"]):
		return
	_samples.append(sample)
	while _samples.size() > HISTORY:
		_samples.pop_front()


## A pose a desenhar agora. Devolve {} se ainda nao ha historico que chegue.
func sample_at(local_time: float) -> Dictionary:
	if _samples.is_empty():
		return {}
	var target := local_time - NetProtocol.INTERPOLATION_DELAY

	# Antes do historico: ainda nao chegou nada tao antigo. Mostra o mais antigo
	# que ha, parado. E o arranque da ligacao, e dura menos de 100 ms.
	if target <= float(_samples[0]["t"]):
		return _pose(_samples[0])

	# Depois do historico: a linha engasgou e nao chega instantaneo novo.
	# NAO se extrapola — congela-se no ultimo conhecido. Um corpo parado le-se
	# como "a ligacao esta ma"; um corpo a deslizar sozinho le-se como um bug,
	# e pior, mente sobre onde o parceiro esta.
	if target >= float(_samples[-1]["t"]):
		return _pose(_samples[-1])

	for i in range(_samples.size() - 1):
		var a := _samples[i]
		var b := _samples[i + 1]
		var ta := float(a["t"])
		var tb := float(b["t"])
		if target >= ta and target <= tb:
			var span := tb - ta
			var w := 0.0 if span <= 0.0 else (target - ta) / span
			return _blend(a, b, w)
	return _pose(_samples[-1])


func _pose(s: Dictionary) -> Dictionary:
	return {
		"position": s.get("position", Vector3.ZERO),
		"yaw": s.get("yaw", 0.0),
		"state": s.get("state", 0),
		"frame": s.get("frame", 0),
		"health_fraction": s.get("health_fraction", 1.0),
		"flags": s.get("flags", 0),
	}


func _blend(a: Dictionary, b: Dictionary, w: float) -> Dictionary:
	return {
		"position": (a.get("position", Vector3.ZERO) as Vector3).lerp(
			b.get("position", Vector3.ZERO) as Vector3, w),
		# O yaw interpola-se pelo caminho curto: sem isto, passar de 179 para
		# -179 graus faz o corpo rodar 358 graus ao contrario, a vista de todos.
		"yaw": _lerp_angle(float(a.get("yaw", 0.0)), float(b.get("yaw", 0.0)), w),
		# Estado e frame NAO se interpolam: sao discretos. Vale o do instantaneo
		# mais recente dos dois, senao o corpo entrava em estados que nunca teve.
		"state": b.get("state", 0),
		"frame": b.get("frame", 0),
		"health_fraction": lerpf(
			float(a.get("health_fraction", 1.0)), float(b.get("health_fraction", 1.0)), w),
		"flags": b.get("flags", 0),
	}


static func _lerp_angle(a: float, b: float, w: float) -> float:
	var d := fposmod(b - a, TAU)
	if d > PI:
		d -= TAU
	return a + d * w


## Quantos instantaneos estao em memoria. So para diagnostico e testes.
func sample_count() -> int:
	return _samples.size()


func reset() -> void:
	_samples.clear()
	_has_offset = false
	_clock_offset = 0.0
