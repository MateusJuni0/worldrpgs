class_name ExplorationShortcut
extends Node3D
## Atalho fisico que so pode ser aberto pelo lado interior.
##
## O modulo nao le nivel, inventario ou uma tecla concreta. O integrador mostra
## `interaction_action` com a ligacao actual de SettingsSystem e chama
## `try_interact()` quando essa accao e premida. Assim a descoberta abre o
## caminho; nenhuma chave escondida num menu o faz.

signal shortcut_opened(shortcut_id: StringName)

const LootAudioScript = preload("res://src/loot/loot_audio.gd")

const GATE_RISE_M := 4.2
const OPEN_SECONDS := 0.7

var shortcut_id: StringName = &""
var interaction_action: StringName = &"interact"

var _built := false
var _open := false
var _inside_direction := Vector3.BACK
var _interaction_radius_m := 2.6
var _gate: StaticBody3D
var _audio: AudioStreamPlayer3D


func configure(definition: Dictionary, already_open := false) -> bool:
	if _built:
		push_warning("ExplorationShortcut.configure() ignorado: atalho ja construido")
		return false
	shortcut_id = StringName(String(definition.get("id", "")))
	if shortcut_id == &"":
		push_error("ExplorationShortcut exige um id")
		return false
	interaction_action = StringName(String(definition.get("interaction_action", "interact")))
	_interaction_radius_m = maxf(float(definition.get("interaction_radius_m", 2.6)), 0.5)
	var direction_value: Variant = definition.get("inside_direction", Vector3.BACK)
	if direction_value is Vector3:
		_inside_direction = direction_value as Vector3
	_inside_direction.y = 0.0
	if _inside_direction.length_squared() < 0.001:
		_inside_direction = Vector3.BACK
	_inside_direction = _inside_direction.normalized()
	_build_gate(definition)
	_built = true
	if already_open:
		open(false)
	return true


func can_interact_from(actor_world_position: Vector3) -> bool:
	if not _built or _open:
		return false
	var offset := actor_world_position - global_position
	offset.y = 0.0
	if offset.length() > _interaction_radius_m:
		return false
	return offset.dot(_inside_direction) > 0.0


func prompt_state(actor_world_position: Vector3) -> Dictionary:
	if not _built or _open:
		return {}
	var planar_offset := actor_world_position - global_position
	planar_offset.y = 0.0
	if planar_offset.length() > _interaction_radius_m:
		return {}
	if can_interact_from(actor_world_position):
		return {
			"allowed": true,
			"action": String(interaction_action),
			"message": "abrir o atalho pelo trinco interior",
		}
	return {
		"allowed": false,
		"action": "",
		"message": "o trinco fica do outro lado",
	}


func try_interact(actor_world_position: Vector3, action_just_pressed: bool) -> bool:
	if not action_just_pressed or not can_interact_from(actor_world_position):
		return false
	return open(true)


func open(animated := true) -> bool:
	if not _built or _open:
		return false
	_open = true
	_gate.collision_layer = 0
	_gate.collision_mask = 0
	if animated and is_inside_tree():
		if is_instance_valid(_audio):
			_audio.play()
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(_gate, "position:y", GATE_RISE_M, OPEN_SECONDS)
		tween.tween_callback(_gate.hide)
	else:
		_gate.position.y = GATE_RISE_M
		_gate.hide()
	shortcut_opened.emit(shortcut_id)
	return true


func restore_open_state(open_shortcut_ids: Array) -> void:
	if shortcut_id in open_shortcut_ids:
		open(false)


func is_open() -> bool:
	return _open


func inside_test_position() -> Vector3:
	return global_position + _inside_direction * (_interaction_radius_m * 0.7)


func outside_test_position() -> Vector3:
	return global_position - _inside_direction * (_interaction_radius_m * 0.7)


func requirements() -> Dictionary:
	return {
		"action": String(interaction_action),
		"discovery": "chegar ao trinco pelo percurso interior",
		"forbidden_gates": ["nivel", "chave", "inventario", "menu"],
	}


func audit() -> Dictionary:
	return {
		"shortcut_id": String(shortcut_id),
		"built": _built,
		"open": _open,
		"mesh_instances": 2,
		"collision_shapes": 1,
		"dynamic_lights": 0,
		"audio_voices": 1,
		"interaction_action": String(interaction_action),
	}


func _exit_tree() -> void:
	# O backend de áudio pode conservar um playback até ao frame seguinte se a
	# árvore sair enquanto o trinco ainda toca. Parar explicitamente mantém
	# testes headless e mudanças de zona sem recursos órfãos.
	if is_instance_valid(_audio):
		_audio.stop()


func _build_gate(definition: Dictionary) -> void:
	_gate = StaticBody3D.new()
	_gate.name = "Gate_%s" % shortcut_id
	_gate.collision_layer = 1
	_gate.collision_mask = 0
	add_child(_gate)

	var wood_colour := _definition_colour(definition, "wood_colour", Color("30261f"))
	var metal_colour := _definition_colour(definition, "metal_colour", Color("766b57"))
	var wood_material := _material(wood_colour, 0.92)
	var metal_material := _material(metal_colour, 0.68)

	var log_mesh := CylinderMesh.new()
	log_mesh.top_radius = 0.24
	log_mesh.bottom_radius = 0.30
	log_mesh.height = 3.8
	log_mesh.radial_segments = 8
	var logs := MultiMesh.new()
	logs.transform_format = MultiMesh.TRANSFORM_3D
	logs.mesh = log_mesh
	logs.instance_count = 6
	for index: int in 6:
		logs.set_instance_transform(index, Transform3D(
			Basis(Vector3.UP, float(index % 2) * 0.15),
			Vector3(-1.75 + float(index) * 0.70, 1.9, 0.0)))
	var log_visual := MultiMeshInstance3D.new()
	log_visual.name = "BlackOakLogs"
	log_visual.multimesh = logs
	log_visual.material_override = wood_material
	log_visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_gate.add_child(log_visual)

	var hardware_mesh := BoxMesh.new()
	hardware_mesh.size = Vector3.ONE
	var hardware := MultiMesh.new()
	hardware.transform_format = MultiMesh.TRANSFORM_3D
	hardware.mesh = hardware_mesh
	hardware.instance_count = 2
	hardware.set_instance_transform(0, Transform3D(
		Basis.IDENTITY.scaled(Vector3(4.25, 0.25, 0.34)), Vector3(0.0, 1.9, 0.0)))
	hardware.set_instance_transform(1, Transform3D(
		Basis.IDENTITY.scaled(Vector3(0.38, 0.72, 0.42)), Vector3(1.52, 1.55, 0.28)))
	var hardware_visual := MultiMeshInstance3D.new()
	hardware_visual.name = "RoughIronLatch"
	hardware_visual.multimesh = hardware
	hardware_visual.material_override = metal_material
	hardware_visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_gate.add_child(hardware_visual)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(4.25, 3.8, 0.55)
	collision.shape = shape
	collision.position.y = 1.9
	_gate.add_child(collision)

	_audio = AudioStreamPlayer3D.new()
	_audio.name = "ShortcutWoodAndLatch"
	_audio.stream = LootAudioScript.chest_stream()
	_audio.max_distance = 18.0
	_audio.unit_size = 4.0
	add_child(_audio)


func _definition_colour(definition: Dictionary, key: String, fallback: Color) -> Color:
	var html := String(definition.get(key, ""))
	return Color(html) if html.is_valid_html_color() else fallback


func _material(colour: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = colour
	material.roughness = roughness
	material.metallic = 0.0
	return material
