class_name DamageInfo
extends RefCounted
## O que viaja de quem bate para quem leva.
##
## `weight` decide o hit-stun: leve 0,4 s, pesado 0,7 s (spec/01-combate.md).
## `parryable` e a marca que o WP6 obriga a existir em TODO o ataque inimigo.

var amount := 0.0
var attacker: Node3D = null
var source_position := Vector3.ZERO

var weight := "light"        # "light" | "heavy"
var parryable := false
var is_magic := false
var is_aoe := false

# Excepcoes de bloqueio declaradas na ficha do ataque (spec/70 §4).
# `shield_pierce_fraction` remove essa fraccao da absorcao fisica do escudo;
# `guard_stamina_multiplier` torna um golpe um esmagador de guarda dedicado.
var shield_pierce_fraction := 0.0
var guard_stamina_multiplier := 1.0

var posture_damage := 0.0
var attack_id := ""


static func make(p_amount: float, p_attacker: Node3D, p_weight: String) -> DamageInfo:
	var d := DamageInfo.new()
	d.amount = p_amount
	d.attacker = p_attacker
	d.weight = p_weight
	if p_attacker != null:
		d.source_position = p_attacker.global_position
	return d


func hitstun_seconds(cfg: Dictionary) -> float:
	return cfg.get(weight, 0.4)
