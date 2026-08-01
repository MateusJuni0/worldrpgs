class_name WorldChest
extends Node3D
## Arca visivel e barata. A base e a tampa sao os unicos dois meshes; o fecho
## dourado e a silhueta levantada distinguem-na sem luz dinamica nem particulas.

const LootAudioScript = preload("res://src/loot/loot_audio.gd")

signal opened_visual(chest_id: String)

var chest_id := ""
var definition: Dictionary = {}
var _rules: Dictionary = {}
var _lid_pivot: Node3D
var _opening := false
var _opened := false
var _animation_elapsed := 0.0


func configure(id: String, chest_definition: Dictionary,
		presentation_rules: Dictionary) -> void:
	chest_id = id
	definition = chest_definition
	_rules = presentation_rules
	name = "Chest_%s" % chest_id
	_apply_position(definition.get("position", []) as Array)
	_build_meshes()
	_build_collision()
	set_process(false)


func set_opened(opened: bool, immediate := true) -> void:
	_opened = opened
	_opening = opened and not immediate
	_animation_elapsed = 0.0
	if is_instance_valid(_lid_pivot):
		_lid_pivot.rotation_degrees.x = -float(_rules.get(
			"chest_open_degrees", 105.0)) if opened and immediate else 0.0
	set_process(_opening)


func open_visual() -> void:
	if _opened:
		return
	_opened = true
	_opening = true
	_animation_elapsed = 0.0
	_play_open_sound()
	set_process(true)


func is_opened() -> bool:
	return _opened


func presentation_contract() -> Dictionary:
	var meshes := find_children("*", "MeshInstance3D", true, false).size()
	var lights := find_children("*", "Light3D", true, false).size()
	return {"mesh_instances": meshes, "lights": lights,
		"art_source": "dois BoxMesh sintetizados em codigo",
		"sound_source": "madeira e fecho sintetizados em codigo"}


func _process(delta: float) -> void:
	if not _opening or not is_instance_valid(_lid_pivot):
		set_process(false)
		return
	_animation_elapsed += delta
	var duration := maxf(float(_rules.get("chest_open_seconds", 0.42)), 0.01)
	var progress := smoothstep(0.0, 1.0, clampf(_animation_elapsed / duration, 0.0, 1.0))
	_lid_pivot.rotation_degrees.x = -float(_rules.get(
		"chest_open_degrees", 105.0)) * progress
	if _animation_elapsed >= duration:
		_opening = false
		set_process(false)
		opened_visual.emit(chest_id)


func _apply_position(raw_position: Array) -> void:
	if raw_position.size() >= 3:
		position = Vector3(float(raw_position[0]), float(raw_position[1]),
			float(raw_position[2]))


func _build_meshes() -> void:
	var size := _vector3(_rules.get("chest_size_m", [1.55, 0.62, 0.92]) as Array,
		Vector3(1.55, 0.62, 0.92))
	var lid_height := float(_rules.get("chest_lid_height_m", 0.18))
	var base := MeshInstance3D.new()
	base.name = "Base"
	var base_mesh := BoxMesh.new()
	base_mesh.size = size
	base.mesh = base_mesh
	base.position.y = size.y * 0.5
	base.material_override = _material(
		Color(String(_rules.get("wood_colour", "#34271f"))), false)
	add_child(base)

	_lid_pivot = Node3D.new()
	_lid_pivot.name = "LidPivot"
	_lid_pivot.position = Vector3(0.0, size.y, -size.z * 0.5)
	add_child(_lid_pivot)
	var lid := MeshInstance3D.new()
	lid.name = "Lid"
	var lid_mesh := BoxMesh.new()
	lid_mesh.size = Vector3(size.x, lid_height, size.z)
	lid.mesh = lid_mesh
	lid.position = Vector3(0.0, lid_height * 0.5, size.z * 0.5)
	lid.material_override = _material(
		Color(String(_rules.get("metal_colour", "#9b8757"))), true)
	_lid_pivot.add_child(lid)


func _build_collision() -> void:
	var size := _vector3(_rules.get("chest_size_m", [1.55, 0.62, 0.92]) as Array,
		Vector3(1.55, 0.62, 0.92))
	var body := StaticBody3D.new()
	body.name = "ChestCollision"
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	collision.position.y = size.y * 0.5
	body.add_child(collision)
	add_child(body)


func _material(colour: Color, metallic: bool) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = colour
	material.roughness = 0.82 if not metallic else 0.48
	material.metallic = 0.0 if not metallic else 0.52
	return material


func _play_open_sound() -> void:
	var player := AudioStreamPlayer3D.new()
	player.name = "ChestOpenSound"
	player.stream = LootAudioScript.chest_stream()
	player.bus = "Impact"
	player.unit_size = 5.0
	player.max_distance = 34.0
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()


func _vector3(values: Array, fallback: Vector3) -> Vector3:
	if values.size() < 3:
		return fallback
	return Vector3(float(values[0]), float(values[1]), float(values[2]))
