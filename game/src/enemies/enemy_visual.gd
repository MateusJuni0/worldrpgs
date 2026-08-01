extends Node3D
## Corpo e silhueta definidos pelos perfis de enemies.json. A silhueta é
## informação de combate: raça/papel têm de se reconhecer antes do primeiro tell.

const BODY_PATHS := {
	"orc_small": "res://assets/models/characters/quaternius-ultimate-monsters/Orc_Small.gltf",
	"orc_big": "res://assets/models/characters/quaternius-ultimate-monsters/Orc.gltf",
	"orc_skull": "res://assets/models/characters/quaternius-ultimate-monsters/Orc_Skull.gltf",
	"skeleton_mage": "res://assets/models/enemies/kaykit-skeletons/characters/Skeleton_Mage.glb",
	"skeleton_minion": "res://assets/models/enemies/kaykit-skeletons/characters/Skeleton_Minion.glb",
	"skeleton_rogue": "res://assets/models/enemies/kaykit-skeletons/characters/Skeleton_Rogue.glb",
	"skeleton_warrior": "res://assets/models/enemies/kaykit-skeletons/characters/Skeleton_Warrior.glb",
}
const KAYKIT_ANIMATION_PATHS := [
	"res://assets/models/enemies/kaykit-skeletons/animations/Rig_Medium_General.glb",
	"res://assets/models/enemies/kaykit-skeletons/animations/Rig_Medium_MovementBasic.glb",
]
const LOW_POLY_SEGMENTS := 8

static var _kaykit_library: AnimationLibrary

var _enemy_id := ""
var _body_kind := ""
var _profile: Dictionary = {}
var _variant := 0
var _casts_shadow := false
var _animation_player: AnimationPlayer
var _materials: Array[StandardMaterial3D] = []
var _base_colours: Array[Color] = []
var _profile_tint := Color.WHITE
var _current_animation := ""
var _current_tint := Color(-1.0, -1.0, -1.0, -1.0)


func setup(enemy_id: String, enemy_data: Dictionary, profile: Dictionary,
		casts_shadow: bool, variant_seed: int) -> void:
	name = "EnemyVisual"
	_enemy_id = enemy_id
	_profile = profile
	_casts_shadow = casts_shadow
	_body_kind = _resolve_body_kind(String(profile.get("body", "")), variant_seed)
	var variants := maxi(int(profile.get("variant_count", 1)), 1)
	_variant = absi(variant_seed) % variants
	var idle_colour := Color(String(enemy_data.get("color_idle", "#ffffff")))
	_profile_tint = Color.WHITE.lerp(idle_colour,
		clampf(float(profile.get("tint_strength", 0.0)), 0.0, 1.0))
	if _body_kind != "procedural":
		_build_imported_body()
	_build_silhouette(String(profile.get("silhouette", "")))
	_build_individual_marker()
	_configure_loops()
	set_tint(Color.WHITE)
	play_animation("Idle")


func set_tint(tint: Color) -> void:
	if tint.is_equal_approx(_current_tint):
		return
	_current_tint = tint
	for index: int in _materials.size():
		_materials[index].albedo_color = _base_colours[index] * _profile_tint * tint


func play_animation(semantic_name: String, speed := 1.0) -> void:
	if _animation_player == null:
		return
	var animation_name := _animation_for(semantic_name)
	if not _animation_player.has_animation(animation_name):
		animation_name = _animation_for("Idle")
	if not _animation_player.has_animation(animation_name):
		return
	if _current_animation == animation_name and _animation_player.is_playing():
		return
	_current_animation = animation_name
	_animation_player.play(animation_name, float(_profile.get("animation_blend_s", 0.0)), speed)


func _resolve_body_kind(declared: String, variant_seed: int) -> String:
	if declared != "skeleton_agile":
		return declared
	var agile := ["skeleton_warrior", "skeleton_rogue", "skeleton_minion"]
	return agile[absi(hash(_enemy_id) ^ variant_seed) % agile.size()]


func _build_imported_body() -> void:
	var path := String(BODY_PATHS.get(_body_kind, ""))
	var body_scene := load(path) as PackedScene
	if body_scene == null:
		push_error("[enemy-visual] corpo em falta: %s (%s)" % [_enemy_id, path])
		return
	var body := body_scene.instantiate()
	body.name = "Body"
	body.rotation_degrees.y = float(_profile.get("body_yaw_deg", 0.0))
	var source_height := float(_profile.get("source_height_m", 0.0))
	var target_height := float(_profile.get("target_height_m", 0.0))
	if source_height > 0.0:
		body.scale = Vector3.ONE * target_height / source_height
	add_child(body)
	_collect_materials(body)
	if _body_kind.begins_with("skeleton_"):
		_build_kaykit_animation_player(body)
	else:
		_animation_player = _find_animation_player(body)


func _build_silhouette(kind: String) -> void:
	var height := float(_profile.get("target_height_m", 0.0))
	var accent := Color(String(_profile.get("accent_color", "#ffffff")))
	match kind:
		"polearm":
			_add_box(Vector3(height * 0.045, height * 1.18, height * 0.045),
				Vector3(height * 0.34, height * 0.62, 0.0), Vector3(0.0, 0.0, -8.0), accent)
			_add_cone(height * 0.07, height * 0.18,
				Vector3(height * 0.42, height * 1.23, 0.0), Vector3(0.0, 0.0, -8.0), accent.lightened(0.25))
		"maul":
			_add_box(Vector3(height * 0.055, height * 0.94, height * 0.055),
				Vector3(height * 0.34, height * 0.64, 0.0), Vector3.ZERO, accent)
			_add_box(Vector3(height * 0.48, height * 0.17, height * 0.20),
				Vector3(height * 0.34, height * 1.08, 0.0), Vector3.ZERO, accent.darkened(0.16))
		"cleaver":
			_add_box(Vector3(height * 0.07, height * 0.88, height * 0.07),
				Vector3(height * 0.38, height * 0.63, 0.0), Vector3.ZERO, accent)
			_add_box(Vector3(height * 0.30, height * 0.40, height * 0.10),
				Vector3(height * 0.46, height * 1.10, 0.0), Vector3(0.0, 0.0, -12.0), accent.lightened(0.22))
		"dagger":
			_add_box(Vector3(height * 0.08, height * 0.46, height * 0.055),
				Vector3(height * 0.32, height * 0.62, -height * 0.08), Vector3(20.0, 0.0, -18.0), accent)
			_add_cone(height * 0.07, height * 0.16,
				Vector3(height * 0.40, height * 0.84, -height * 0.14), Vector3(20.0, 0.0, -18.0), accent.lightened(0.30))
		"sling":
			_add_box(Vector3(height * 0.04, height * 0.64, height * 0.04),
				Vector3(height * 0.34, height * 0.72, 0.0), Vector3(0.0, 0.0, -22.0), accent)
			_add_sphere(height * 0.11, Vector3(height * 0.45, height * 0.43, 0.0), accent.darkened(0.22))
		"bell":
			_add_cone(height * 0.16, height * 0.24,
				Vector3(0.0, height * 0.73, -height * 0.22), Vector3(180.0, 0.0, 0.0), accent)
			_add_cone(height * 0.11, height * 0.28,
				Vector3(-height * 0.21, height * 1.05, 0.0), Vector3(0.0, 0.0, 58.0), accent.lightened(0.18))
			_add_cone(height * 0.11, height * 0.28,
				Vector3(height * 0.21, height * 1.05, 0.0), Vector3(0.0, 0.0, -58.0), accent.lightened(0.18))
		"weaver":
			_build_weaver(height, accent)
		"blade":
			_add_box(Vector3(height * 0.07, height * 0.68, height * 0.035),
				Vector3(height * 0.36, height * 0.70, -height * 0.08), Vector3(8.0, 0.0, -10.0), accent.lightened(0.25))
		"crossbow":
			_add_box(Vector3(height * 0.58, height * 0.06, height * 0.07),
				Vector3(0.0, height * 0.78, -height * 0.28), Vector3.ZERO, accent)
			_add_box(Vector3(height * 0.06, height * 0.34, height * 0.06),
				Vector3(0.0, height * 0.70, -height * 0.28), Vector3(62.0, 0.0, 0.0), accent.darkened(0.18))
		"zombie":
			_add_sphere(height * 0.29, Vector3(0.0, height * 0.60, -height * 0.12), accent)
			_add_box(Vector3(height * 0.07, height * 0.82, height * 0.07),
				Vector3(height * 0.38, height * 0.62, 0.0), Vector3(0.0, 0.0, 18.0), accent.darkened(0.28))
		"horns":
			_build_horns(height, accent)
		"mimic":
			_build_mimic(height, accent)
		"trident_fins":
			_build_trident_fins(height, accent)
		"wings":
			_build_wings(height, accent)
		"jagged":
			_build_jagged(height, accent)
		"tuning_fork":
			_build_tuning_fork(height, accent)
		"censer":
			_build_censer(height, accent)
		"rings":
			_build_rings(height, accent)


func _build_weaver(height: float, accent: Color) -> void:
	_add_sphere(height * 0.32, Vector3(0.0, height * 0.50, height * 0.12), accent.darkened(0.22))
	_add_sphere(height * 0.22, Vector3(0.0, height * 0.48, -height * 0.32), accent)
	for side: float in [-1.0, 1.0]:
		for row: int in 3:
			var z := (float(row) - 1.0) * height * 0.25
			_add_box(Vector3(height * 0.62, height * 0.055, height * 0.055),
				Vector3(side * height * 0.38, height * (0.52 - float(row) * 0.06), z),
				Vector3(0.0, -18.0 * (float(row) - 1.0), side * 18.0), accent)


func _build_horns(height: float, accent: Color) -> void:
	_add_cone(height * 0.13, height * 0.38,
		Vector3(-height * 0.24, height * 0.95, 0.0), Vector3(0.0, 0.0, 66.0), accent)
	_add_cone(height * 0.13, height * 0.38,
		Vector3(height * 0.24, height * 0.95, 0.0), Vector3(0.0, 0.0, -66.0), accent)
	_add_box(Vector3(height * 0.09, height * 0.82, height * 0.09),
		Vector3(height * 0.38, height * 0.56, 0.0), Vector3.ZERO, accent.darkened(0.28))


func _build_mimic(height: float, accent: Color) -> void:
	_add_box(Vector3(height * 1.12, height * 0.58, height * 0.78),
		Vector3(0.0, height * 0.31, 0.0), Vector3.ZERO, accent)
	_add_box(Vector3(height * 1.16, height * 0.20, height * 0.82),
		Vector3(0.0, height * 0.72, height * 0.05), Vector3(-18.0, 0.0, 0.0), accent.lightened(0.16))
	for tooth: int in 5:
		_add_cone(height * 0.055, height * 0.16,
			Vector3((float(tooth) - 2.0) * height * 0.20, height * 0.58, -height * 0.43),
			Vector3(90.0, 0.0, 0.0), Color("#d8d1b1"))


func _build_trident_fins(height: float, accent: Color) -> void:
	_add_box(Vector3(height * 0.045, height * 1.12, height * 0.045),
		Vector3(height * 0.34, height * 0.62, 0.0), Vector3.ZERO, accent)
	for tine: float in [-1.0, 0.0, 1.0]:
		_add_cone(height * 0.045, height * 0.20,
			Vector3(height * (0.34 + tine * 0.08), height * 1.25, 0.0), Vector3.ZERO, accent.lightened(0.25))
	_add_box(Vector3(height * 0.50, height * 0.04, height * 0.22),
		Vector3(0.0, height * 0.78, height * 0.15), Vector3(0.0, 0.0, 42.0), accent.darkened(0.08))


func _build_wings(height: float, accent: Color) -> void:
	_add_box(Vector3(height * 0.86, height * 0.055, height * 0.46),
		Vector3(-height * 0.40, height * 0.78, height * 0.12), Vector3(8.0, -12.0, -28.0), accent)
	_add_box(Vector3(height * 0.86, height * 0.055, height * 0.46),
		Vector3(height * 0.40, height * 0.78, height * 0.12), Vector3(8.0, 12.0, 28.0), accent)


func _build_jagged(height: float, accent: Color) -> void:
	for side: float in [-1.0, 1.0]:
		for level: int in 2:
			_add_cone(height * 0.10, height * (0.22 + float(level) * 0.07),
				Vector3(side * height * (0.24 + float(level) * 0.10), height * (0.70 + float(level) * 0.22), 0.0),
				Vector3(0.0, 0.0, side * -48.0), accent)


func _build_tuning_fork(height: float, accent: Color) -> void:
	_add_box(Vector3(height * 0.055, height * 0.72, height * 0.055),
		Vector3(height * 0.32, height * 0.60, 0.0), Vector3.ZERO, accent)
	for side: float in [-1.0, 1.0]:
		_add_box(Vector3(height * 0.045, height * 0.34, height * 0.045),
			Vector3(height * (0.32 + side * 0.09), height * 1.07, 0.0), Vector3.ZERO, accent.lightened(0.22))


func _build_censer(height: float, accent: Color) -> void:
	_add_box(Vector3(height * 0.035, height * 0.74, height * 0.035),
		Vector3(height * 0.32, height * 0.68, 0.0), Vector3(0.0, 0.0, -18.0), accent)
	_add_sphere(height * 0.18, Vector3(height * 0.43, height * 0.32, 0.0), accent.darkened(0.20))


func _build_rings(height: float, accent: Color) -> void:
	for ring: int in 3:
		var torus := TorusMesh.new()
		torus.inner_radius = height * (0.20 + float(ring) * 0.04)
		torus.outer_radius = torus.inner_radius + height * 0.025
		torus.rings = LOW_POLY_SEGMENTS
		torus.ring_segments = LOW_POLY_SEGMENTS
		_add_mesh(torus, Vector3(0.0, height * (0.62 + float(ring) * 0.22), 0.0),
			Vector3(90.0, 0.0, float(ring) * 18.0), accent)


func _build_individual_marker() -> void:
	if int(_profile.get("variant_count", 1)) <= 1 or _body_kind == "procedural":
		return
	var height := float(_profile.get("target_height_m", 0.0))
	var accent := Color(String(_profile.get("accent_color", "#ffffff"))).darkened(0.16)
	var side := -1.0 if _variant % 2 == 0 else 1.0
	if _variant == 0:
		_add_box(Vector3(height * 0.22, height * 0.10, height * 0.28),
			Vector3(side * height * 0.23, height * 0.82, 0.0), Vector3(0.0, 0.0, side * 18.0), accent)
	elif _variant == 1:
		_add_cone(height * 0.08, height * 0.26,
			Vector3(side * height * 0.20, height * 1.02, height * 0.05), Vector3(0.0, 0.0, side * 34.0), accent)
	else:
		_add_box(Vector3(height * 0.24, height * 0.34, height * 0.035),
			Vector3(side * height * 0.25, height * 0.74, height * 0.15), Vector3(0.0, 0.0, side * 12.0), accent)


func _add_box(size: Vector3, position: Vector3, rotation_degrees: Vector3,
		colour: Color) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	_add_mesh(mesh, position, rotation_degrees, colour)


func _add_sphere(radius: float, position: Vector3, colour: Color) -> void:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = LOW_POLY_SEGMENTS
	mesh.rings = LOW_POLY_SEGMENTS / 2
	_add_mesh(mesh, position, Vector3.ZERO, colour)


func _add_cone(radius: float, height: float, position: Vector3,
		rotation_degrees: Vector3, colour: Color) -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = 0.0
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = LOW_POLY_SEGMENTS
	_add_mesh(mesh, position, rotation_degrees, colour)


func _add_mesh(mesh: PrimitiveMesh, position: Vector3, rotation_degrees: Vector3,
		colour: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = colour
	material.roughness = 0.82
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.position = position
	instance.rotation_degrees = rotation_degrees
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if _casts_shadow \
		else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	instance.material_override = material
	add_child(instance)
	_materials.append(material)
	_base_colours.append(colour)


func _collect_materials(node: Node) -> void:
	for descendant: Node in node.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := descendant as MeshInstance3D
		if not _casts_shadow:
			mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for surface: int in mesh_instance.mesh.get_surface_count():
			var source := mesh_instance.mesh.surface_get_material(surface) as StandardMaterial3D
			if source == null:
				continue
			var material := source.duplicate() as StandardMaterial3D
			mesh_instance.set_surface_override_material(surface, material)
			_materials.append(material)
			_base_colours.append(material.albedo_color)


func _build_kaykit_animation_player(body: Node) -> void:
	_ensure_kaykit_library()
	_animation_player = AnimationPlayer.new()
	_animation_player.name = "AnimationPlayer"
	_animation_player.root_node = NodePath("../Body")
	add_child(_animation_player)
	if _kaykit_library != null:
		_animation_player.add_animation_library("", _kaykit_library)


static func _ensure_kaykit_library() -> void:
	if _kaykit_library != null:
		return
	_kaykit_library = AnimationLibrary.new()
	for path: String in KAYKIT_ANIMATION_PATHS:
		var scene := load(path) as PackedScene
		if scene == null:
			continue
		var root := scene.instantiate()
		var player := _find_animation_player(root)
		if player != null:
			for animation_name: StringName in player.get_animation_list():
				if not _kaykit_library.has_animation(animation_name):
					_kaykit_library.add_animation(animation_name, player.get_animation(animation_name))
		root.free()


func _configure_loops() -> void:
	if _animation_player == null:
		return
	for looping: String in ["Idle", "Walk", "Run", "Idle_A", "Idle_B", "Walking_A", "Walking_B", "Walking_C", "Running_A", "Running_B"]:
		if _animation_player.has_animation(looping):
			_animation_player.get_animation(looping).loop_mode = Animation.LOOP_LINEAR


func _animation_for(semantic_name: String) -> String:
	if _body_kind.begins_with("skeleton_"):
		return {
			"Death01": "Death_A",
			"Sword_Attack": "Throw",
			"Hit_Chest": "Hit_A",
			"Jog_Fwd": "Running_A",
			"Walk": "Walking_A",
			"Idle": "Idle_A",
		}.get(semantic_name, "Idle_A")
	if _body_kind == "orc_small":
		return {
			"Death01": "Death", "Sword_Attack": "Bite_Front", "Hit_Chest": "HitRecieve",
			"Jog_Fwd": "Walk", "Walk": "Walk", "Idle": "Idle",
		}.get(semantic_name, "Idle")
	return {
		"Death01": "Death", "Sword_Attack": "Weapon", "Hit_Chest": "HitReact",
		"Jog_Fwd": "Run", "Walk": "Walk", "Idle": "Idle",
	}.get(semantic_name, "Idle")


static func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child: Node in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null
