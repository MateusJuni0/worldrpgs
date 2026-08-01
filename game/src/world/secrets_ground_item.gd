class_name SecretsGroundItem
extends Area3D
## Um item existe no chao antes de existir no HUD: silhueta, facho emissivo e
## sino 3D curto. O facho respeita profundidade, portanto nunca revela o item
## atraves de uma raiz ou parede; a geometria continua a ser o segredo.
##
## `already_committed` permite apresentar hoje o recibo que main/save ja
## atribuem na morte. O modo nao comprometido emite `claim_requested` e espera
## `resolve_claim()`, fronteira pronta para uma futura transaccao de recolha.

signal claim_requested(item_id: String, receipt_id: String)
signal presentation_finished(item_id: String, receipt_id: String)

const LootAudioScript = preload("res://src/loot/loot_audio.gd")

const DEFAULT_VISIBILITY_RANGE_M := 65.0
const BEAM_HEIGHT_M := 3.6
const BOB_HEIGHT_M := 0.09
const BOB_SPEED := 2.2
const TURN_SPEED := 0.65

var item_id := ""
var receipt_id := ""
var display_name := ""
var interaction_action: StringName = &"interact"

var _active := false
var _already_committed := false
var _claim_pending := false
var _interaction_radius_m := 2.6
var _visibility_range_m := DEFAULT_VISIBILITY_RANGE_M
var _elapsed := 0.0
var _silhouette_base_y := 0.75
var _silhouette: MeshInstance3D
var _beam: MeshInstance3D
var _audio: AudioStreamPlayer3D


func configure(p_item_id: String, options: Dictionary = {}) -> bool:
	if p_item_id.strip_edges() == "" or _active:
		return false
	item_id = p_item_id.strip_edges()
	receipt_id = String(options.get("receipt_id", ""))
	display_name = String(options.get("display_name", item_id))
	interaction_action = StringName(String(options.get("interaction_action", "interact")))
	_already_committed = bool(options.get("already_committed", false))
	_interaction_radius_m = maxf(float(options.get("interaction_radius_m", 2.6)), 0.5)
	_visibility_range_m = maxf(float(
		options.get("visibility_range_m", DEFAULT_VISIBILITY_RANGE_M)), 8.0)
	var colour := _option_colour(options, "colour", Color("e6cf79"))
	_build_visuals(colour)
	_build_interaction_shape()
	_build_audio()
	_active = true
	set_process(true)
	if is_inside_tree():
		_audio.play()
	return true


func try_interact(actor_world_position: Vector3, action_just_pressed: bool) -> bool:
	if not _active or _claim_pending or not action_just_pressed:
		return false
	if actor_world_position.distance_to(global_position) > _interaction_radius_m:
		return false
	if _already_committed:
		_finish_presentation()
		return true
	_claim_pending = true
	claim_requested.emit(item_id, receipt_id)
	return true


func resolve_claim(success: bool) -> void:
	if not _claim_pending:
		return
	_claim_pending = false
	if success:
		_already_committed = true
		_finish_presentation()


func prompt_state(actor_world_position: Vector3) -> Dictionary:
	if not _active or actor_world_position.distance_to(global_position) > _interaction_radius_m:
		return {}
	return {
		"allowed": not _claim_pending,
		"action": String(interaction_action) if not _claim_pending else "",
		"message": ("recolher %s" % display_name) if not _claim_pending \
			else "a guardar %s" % display_name,
	}


func is_readable_from(observer_world_position: Vector3, has_line_of_sight: bool) -> bool:
	return _active and has_line_of_sight \
		and observer_world_position.distance_to(global_position) <= _visibility_range_m


func is_active() -> bool:
	return _active


func category() -> String:
	var separator := item_id.find(":")
	return item_id.substr(0, separator) if separator > 0 else "objecto"


func audit() -> Dictionary:
	return {
		"active": _active,
		"category": category(),
		"mesh_instances": 2,
		"particle_systems": 0,
		"dynamic_lights": 0,
		"audio_voices": 1,
		"visibility_range_m": _visibility_range_m,
		"beam_height_m": BEAM_HEIGHT_M,
		"art_source": "primitivas e materiais sintetizados neste script",
		"sound_source": "PCM sintetizado em res://src/loot/loot_audio.gd",
	}


func _exit_tree() -> void:
	if is_instance_valid(_audio):
		_audio.stop()


func _process(delta: float) -> void:
	if not _active or not is_instance_valid(_silhouette):
		return
	_elapsed += delta
	_silhouette.position.y = _silhouette_base_y + sin(_elapsed * BOB_SPEED) * BOB_HEIGHT_M
	_silhouette.rotation.y += delta * TURN_SPEED


func _finish_presentation() -> void:
	_active = false
	set_process(false)
	if is_instance_valid(_audio):
		_audio.stop()
	hide()
	monitoring = false
	presentation_finished.emit(item_id, receipt_id)


func _build_visuals(colour: Color) -> void:
	_silhouette = MeshInstance3D.new()
	_silhouette.name = "ReadableSilhouette_%s" % category()
	_silhouette.mesh = _silhouette_mesh()
	_silhouette.material_override = _emissive_material(colour, 2.4, false)
	_silhouette.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_silhouette.visibility_range_end = _visibility_range_m
	_silhouette.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED
	_silhouette_base_y = _silhouette_height() * 0.5 + 0.28
	_silhouette.position.y = _silhouette_base_y
	_silhouette.rotation_degrees.z = 28.0 if category() == "arma" else 0.0
	add_child(_silhouette)

	var beam_mesh := QuadMesh.new()
	beam_mesh.size = Vector2(0.95, BEAM_HEIGHT_M)
	_beam = MeshInstance3D.new()
	_beam.name = "OccludedLootBeam"
	_beam.mesh = beam_mesh
	_beam.position.y = BEAM_HEIGHT_M * 0.5
	_beam.material_override = _emissive_material(Color(colour, 0.68), 2.1, true)
	_beam.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_beam.visibility_range_end = _visibility_range_m
	_beam.visibility_range_fade_mode = GeometryInstance3D.VISIBILITY_RANGE_FADE_DISABLED
	add_child(_beam)


func _silhouette_mesh() -> PrimitiveMesh:
	match category():
		"arma":
			var weapon := BoxMesh.new()
			weapon.size = Vector3(0.16, 1.55, 0.16)
			return weapon
		"armadura":
			var armour := CapsuleMesh.new()
			armour.radius = 0.42
			armour.height = 1.05
			armour.radial_segments = 8
			armour.rings = 4
			return armour
		"consumivel":
			var flask := CylinderMesh.new()
			flask.top_radius = 0.18
			flask.bottom_radius = 0.34
			flask.height = 0.74
			flask.radial_segments = 8
			return flask
		_:
			var material_drop := SphereMesh.new()
			material_drop.radius = 0.34
			material_drop.height = 0.68
			material_drop.radial_segments = 8
			material_drop.rings = 4
			return material_drop


func _silhouette_height() -> float:
	match category():
		"arma":
			return 1.55
		"armadura":
			return 1.05
		"consumivel":
			return 0.74
		_:
			return 0.68


func _build_interaction_shape() -> void:
	collision_layer = 0
	collision_mask = 0
	monitorable = false
	var collision := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = _interaction_radius_m
	collision.shape = sphere
	collision.position.y = 0.7
	add_child(collision)


func _build_audio() -> void:
	_audio = AudioStreamPlayer3D.new()
	_audio.name = "DropChime"
	_audio.stream = LootAudioScript.pickup_stream()
	_audio.max_distance = 24.0
	_audio.unit_size = 5.0
	add_child(_audio)


func _emissive_material(colour: Color, energy: float, transparent: bool) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = colour
	material.emission_enabled = true
	material.emission = Color(colour.r, colour.g, colour.b)
	material.emission_energy_multiplier = energy
	material.roughness = 0.6
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if transparent:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	return material


func _option_colour(options: Dictionary, key: String, fallback: Color) -> Color:
	var html := String(options.get(key, ""))
	return Color(html) if html.is_valid_html_color() else fallback
