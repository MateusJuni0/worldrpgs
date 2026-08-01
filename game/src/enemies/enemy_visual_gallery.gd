extends SceneTree
## Galeria reproduzível das famílias/papéis do bestiário. Não é uma cena de
## jogo: congela os actores e serve apenas para provar leitura à distância.

const REPRESENTATIVES := [
	"orc_spearman", "orc_brute", "vorgar", "goblin_mist_scout", "goblin_canopy_slinger", "kobold_bell_trapper",
	"weaver_canopy_snarer", "skeleton_swordsman", "skeleton_archer", "mire_zombie", "minotaur_quarry_bull", "mine_mimic",
	"tide_submerged", "cliff_windborne", "emberling_hammersmith", "penitent_cantor", "penitent_censer", "faceless_halberdier",
]
const EnemyVisualRenderer = preload("res://src/enemies/enemy_visual.gd")

var _frames := 0
var _built := false


func _process(_delta: float) -> bool:
	_frames += 1
	if not _built and _frames > 1:
		_built = true
		_build_gallery()
	elif _built and _frames > 12:
		_capture_and_quit()
	return false


func _build_gallery() -> void:
	var stage := Node3D.new()
	stage.name = "EnemyVisualGallery"
	root.add_child(stage)
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("#111923")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("#8fa6b7")
	env.ambient_light_energy = 1.25
	environment.environment = env
	stage.add_child(environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-52.0, -24.0, 0.0)
	light.light_energy = 1.45
	light.shadow_enabled = false
	stage.add_child(light)
	var ground := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(22.0, 14.0)
	ground.mesh = plane
	var ground_material := StandardMaterial3D.new()
	ground_material.albedo_color = Color("#26313a")
	ground_material.roughness = 1.0
	ground.material_override = ground_material
	stage.add_child(ground)
	var camera := Camera3D.new()
	camera.position = Vector3(0.0, 11.0, 18.5)
	camera.look_at_from_position(camera.position, Vector3(0.0, 1.25, 0.0))
	camera.current = true
	stage.add_child(camera)
	var columns := 6
	var game_data := root.get_node("GameData")
	var all_enemies: Dictionary = game_data.get("enemies") as Dictionary
	var presentation: Dictionary = all_enemies.get("_presentation", {}) as Dictionary
	var profiles: Dictionary = presentation.get("visual_profiles", {}) as Dictionary
	for index: int in REPRESENTATIVES.size():
		var id: String = REPRESENTATIVES[index]
		var column := index % columns
		var row := index / columns
		var position := Vector3((float(column) - 2.5) * 3.15, 0.0,
			(float(row) - 1.0) * 4.0)
		var enemy_data: Dictionary = game_data.call("enemy", id) as Dictionary
		var profile_key := id
		if not profiles.has(profile_key):
			profile_key = "%s:%s" % [enemy_data.get("race_id", ""), enemy_data.get("role", "")]
		var profile := (profiles.get(profile_key, {}) as Dictionary).duplicate(true)
		profile["animation_blend_s"] = float(presentation.get("animation_blend_s", 0.0))
		var visual := EnemyVisualRenderer.new()
		stage.add_child(visual)
		visual.position = position
		visual.call("setup", id, enemy_data, profile, false, index)
		var label := Label3D.new()
		label.text = String(enemy_data.get("display_name", id))
		label.font_size = 34
		label.outline_size = 8
		label.pixel_size = 0.006
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		label.no_depth_test = true
		label.position = position + Vector3.UP * 3.15
		stage.add_child(label)


func _capture_and_quit() -> void:
	_built = false
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	var error := image.save_png("res://captures/enemy-families.png")
	if error != OK:
		push_error("[enemy-gallery] falhou a captura: %s" % error_string(error))
		quit(1)
		return
	print("[enemy-gallery] captura: res://captures/enemy-families.png")
	quit()
