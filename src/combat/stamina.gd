class_name Stamina
extends RefCounted
## Stamina do jogador — spec/01-combate.md, seccao Stamina.
##
## Regras que a spec fixa e que aqui sao lei:
##  - regeneracao 40/s, so 0,8 s DEPOIS do ultimo gasto
##  - a bloquear regenera a 10/s (25% da normal)
##  - a zero: sem accoes ofensivas/defensivas ate recuperar 15 (histerese)
##  - andar e correr sao sempre possiveis, mesmo exausto; sprint nao
##
## Teste da Lei 1: a exaustao pune a ganancia, nao executa ninguem — 0,8 s + 15 de
## histerese devolvem a esquiva em ~1,2 s.

var maximum := 100.0
var current := 100.0
var locked_out := false

var _regen_rate := 40.0
var _regen_delay := 0.8
var _block_regen := 10.0
var _hysteresis := 15.0
var _since_spend := 999.0


func configure(cfg: Dictionary, max_value: float) -> void:
	maximum = max_value
	current = max_value
	_regen_rate = cfg.get("regen_per_second", 40.0)
	_regen_delay = cfg.get("regen_delay", 0.8)
	_block_regen = cfg.get("regen_while_blocking", 10.0)
	_hysteresis = cfg.get("hysteresis", 15.0)
	locked_out = false
	_since_spend = 999.0


## Ha stamina para agir? A spec so tranca a ZERO, nao por custo — gastar
## um golpe caro com pouca stamina e permitido, e deixa o jogador exposto.
func can_act() -> bool:
	return not locked_out and current > 0.0


func spend(amount: float) -> void:
	current = maxf(0.0, current - amount)
	_since_spend = 0.0
	if current <= 0.0:
		locked_out = true


func tick(delta: float, blocking: bool) -> void:
	_since_spend += delta
	if blocking:
		current = minf(maximum, current + _block_regen * delta)
	elif _since_spend >= _regen_delay:
		current = minf(maximum, current + _regen_rate * delta)

	if locked_out and current >= _hysteresis:
		locked_out = false


func refill() -> void:
	current = maximum
	locked_out = false
	_since_spend = 999.0


func fraction() -> float:
	return current / maxf(maximum, 0.001)
