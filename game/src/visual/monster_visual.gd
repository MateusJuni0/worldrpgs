class_name MonsterVisual
extends Node3D
## Criaturas CC0 da Fatia 1. Cada papel usa uma silhueta do Ultimate Monsters;
## a colisao e os tempos de combate continuam a pertencer ao Enemy.

const SMALL_ORC: PackedScene = preload(
	"res://assets/models/characters/quaternius-ultimate-monsters/Orc_Small.gltf")
const BIG_ORC: PackedScene = preload(
	"res://assets/models/characters/quaternius-ultimate-monsters/Orc.gltf")
const SKULL_ORC: PackedScene = preload(
	"res://assets/models/characters/quaternius-ultimate-monsters/Orc_Skull.gltf")

const SOURCE_HEIGHTS := {
	"orc_spearman": 2.347329,
	"orc_brute": 3.208673,
	"vorgar": 3.267947,
}

var _enemy_id := ""
var _animation_player: AnimationPlayer
var _materials: Array[StandardMaterial3D] = []
var _base_colours: Array[Color] = []
var _current_animation := ""
var _current_tint := Color(-1.0, -1.0, -1.0, -1.0)


func setup(enemy_id: String, target_height: float, tint := Color.WHITE,
	casts_shadow := false) -> void:
	name = "MonsterVisual"
	_enemy_id = enemy_id
	var body_scene := SMALL_ORC
	if enemy_id == "orc_brute":
		body_scene = BIG_ORC
	elif enemy_id == "vorgar":
		body_scene = SKULL_ORC

	var body := body_scene.instantiate()
	body.name = "Body"
	# Os glTF antigos do pack olham para +Z; o combate usa -Z como frente.
	body.rotation.y = PI
	add_child(body)
	scale = Vector3.ONE * (target_height / float(SOURCE_HEIGHTS.get(enemy_id, 3.2)))
	_collect_materials(body, casts_shadow)
	_animation_player = _find_animation_player(body)
	_configure_loops()
	set_tint(tint)
	play_animation("Idle")


func set_tint(tint: Color) -> void:
	if tint.is_equal_approx(_current_tint):
		return
	_current_tint = tint
	for index: int in _materials.size():
		_materials[index].albedo_color = _base_colours[index] * tint


func play_animation(semantic_name: String, speed := 1.0) -> void:
	if _animation_player == null:
		return
	var animation_name := _animation_for(semantic_name)
	if not _animation_player.has_animation(animation_name):
		animation_name = "Idle"
	if _current_animation == animation_name and _animation_player.is_playing():
		return
	_current_animation = animation_name
	_animation_player.play(animation_name, 0.12, speed)


func _animation_for(semantic_name: String) -> String:
	if _enemy_id == "orc_spearman":
		return {
			"Death01": "Death",
			"Sword_Attack": "Bite_Front",
			"Hit_Chest": "HitRecieve",
			"Jog_Fwd": "Walk",
			"Walk": "Walk",
			"Idle": "Idle",
		}.get(semantic_name, "Idle")
	return {
		"Death01": "Death",
		"Sword_Attack": "Weapon",
		"Hit_Chest": "HitReact",
		"Jog_Fwd": "Run",
		"Walk": "Walk",
		"Idle": "Idle",
	}.get(semantic_name, "Idle")


func _collect_materials(node: Node, casts_shadow: bool) -> void:
	for descendant: Node in node.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := descendant as MeshInstance3D
		if not casts_shadow:
			mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for surface: int in mesh_instance.mesh.get_surface_count():
			var source := mesh_instance.mesh.surface_get_material(surface) as StandardMaterial3D
			if source == null:
				continue
			var material := source.duplicate() as StandardMaterial3D
			mesh_instance.set_surface_override_material(surface, material)
			_materials.append(material)
			_base_colours.append(material.albedo_color)


func _configure_loops() -> void:
	if _animation_player == null:
		return
	for looping: String in ["Idle", "Walk", "Run"]:
		if _animation_player.has_animation(looping):
			_animation_player.get_animation(looping).loop_mode = Animation.LOOP_LINEAR


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child: Node in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null
