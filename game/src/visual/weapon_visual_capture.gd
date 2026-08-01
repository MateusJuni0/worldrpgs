extends SceneTree
## Captura local, ignorada pelo Git:
## godot --path game/ --rendering-method mobile --script res://src/visual/weapon_visual_capture.gd

class CaptureActor extends Node3D:
	var class_id := "warrior"
	var main_weapon := "longsword"
	var offhand_weapon := "shield"
	var is_two_handed := false


func _initialize() -> void:
	_capture.call_deferred()


func _capture() -> void:
	await process_frame
	var stage := Node3D.new()
	stage.name = "WeaponCapture"
	root.add_child(stage)
	_build_environment(stage)
	var actor := CaptureActor.new()
	stage.add_child(actor)
	var body := CharacterVisual.new()
	actor.add_child(body)
	var game_data := root.get_node("GameData")
	body.setup(float((game_data.call("section", "player") as Dictionary).get(
		"capsule_height", 0.0)), Color.WHITE, true, "body_male", actor.class_id)
	var weapons := WeaponVisual.new()
	actor.add_child(weapons)
	if not weapons.setup(actor, body):
		quit(1)
		return

	for _frame in 30:
		await process_frame
	var image := root.get_viewport().get_texture().get_image()
	var path := "res://captures/weapon-visual.png"
	var error := image.save_png(ProjectSettings.globalize_path(path))
	print("[weapon-capture] %s (%s)" % [path, error_string(error)])
	quit(0 if error == OK else 1)


func _build_environment(stage: Node3D) -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("11171d")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("8ba2b6")
	environment.ambient_light_energy = 0.8
	var world_environment := WorldEnvironment.new()
	world_environment.environment = environment
	stage.add_child(world_environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-42.0, -28.0, 0.0)
	light.light_energy = 1.4
	stage.add_child(light)
	var floor := MeshInstance3D.new()
	var floor_mesh := PlaneMesh.new()
	floor_mesh.size = Vector2(8.0, 8.0)
	floor.mesh = floor_mesh
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color("28343b")
	floor.material_override = floor_material
	stage.add_child(floor)
	var camera := Camera3D.new()
	camera.fov = 48.0
	stage.add_child(camera)
	camera.global_position = Vector3(3.0, 1.65, 4.2)
	camera.look_at(Vector3(0.0, 1.05, 0.0))
	camera.current = true
