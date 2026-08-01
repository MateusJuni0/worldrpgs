class_name WorldBounds
extends RefCounted
## Mede a distancia vertical desde o ponto mais alto de uma queda.
## Os limiares pertencem a progression.json; este controlador so transforma
## amostras da fisica num resultado unico e consumivel.

enum Outcome { NONE, DAMAGE, FATAL }

var last_drop_m := 0.0

var _fall: Dictionary = {}
var _anchor_y := 0.0
var _peak_y := 0.0
var _airborne := false
var _resolved := false


func reset(height_m: float, fall_config: Dictionary) -> void:
	_fall = fall_config
	_anchor_y = height_m
	_peak_y = height_m
	_airborne = false
	_resolved = false
	last_drop_m = 0.0


func sample(height_m: float, grounded: bool) -> Outcome:
	if _resolved:
		return Outcome.NONE

	if grounded:
		if not _airborne:
			_anchor_y = height_m
			_peak_y = height_m
			return Outcome.NONE
		last_drop_m = maxf(_peak_y - height_m, 0.0)
		_airborne = false
		_anchor_y = height_m
		_peak_y = height_m
		if _is_fatal(last_drop_m):
			_resolved = true
			return Outcome.FATAL
		if last_drop_m > float(_fall.get("no_damage_max_m", 0.0)):
			return Outcome.DAMAGE
		return Outcome.NONE

	if not _airborne:
		_airborne = true
		_peak_y = maxf(_anchor_y, height_m)
	else:
		_peak_y = maxf(_peak_y, height_m)
	last_drop_m = maxf(_peak_y - height_m, 0.0)
	if _is_fatal(last_drop_m):
		_resolved = true
		return Outcome.FATAL
	return Outcome.NONE


func _is_fatal(drop_m: float) -> bool:
	# Configuracao ausente falha de modo seguro: nunca deixa o jogador cair para
	# sempre por um catalogo incompleto.
	return drop_m >= float(_fall.get("fatal_min_m", 0.0))
