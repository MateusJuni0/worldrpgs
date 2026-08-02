extends Greybox
## Adaptador fino do mundo jogavel. O Greybox continua a construir Brumal, mas
## entrega a atmosfera e a Toca aos modulos finais que ja existiam.

var _lair_script: Script
var _integrated_lair: Lair
var _lair_origin := Vector3.ZERO
var _lair_route_prepared := false


func configure_integrations(lair_script: Script) -> void:
	_lair_script = lair_script


func integrated_lair() -> Lair:
	return _integrated_lair


func _scatter_forest() -> void:
	_prepare_lair_route()
	super._scatter_forest()


func _prepare_lair_route() -> void:
	if _lair_route_prepared or _lair_script == null:
		return
	_lair_route_prepared = true
	_integrated_lair = _lair_script.new() as Lair
	if _integrated_lair == null:
		return
	_integrated_lair.name = "Lair"
	_lair_origin = lair_entrance - _integrated_lair.entrance_anchor
	_integrated_lair.position = _lair_origin
	arena_center = _lair_origin + _integrated_lair.arena_center
	map_path_segments.append(_translated_route(Lair.MAIN_ROUTE))
	map_path_segments.append(_translated_route(Lair.BOSS_RETURN_ROUTE))
	for landmark: Dictionary in map_landmarks:
		match String(landmark.get("id", "")):
			"descanso_toca":
				landmark["position"] = _lair_origin + _integrated_lair.rest_anchor
			"arena_vorgar":
				landmark["position"] = arena_center


func _translated_route(route: Array) -> PackedVector3Array:
	var translated := PackedVector3Array()
	for point: Vector3 in route:
		translated.append(_lair_origin + point)
	return translated


func _build_lair() -> void:
	_prepare_lair_route()
	if _integrated_lair == null:
		super._build_lair()
		return
	add_child(_integrated_lair)
	_integrated_lair.build({"shadows": bool(preset.get("shadows", true))})
