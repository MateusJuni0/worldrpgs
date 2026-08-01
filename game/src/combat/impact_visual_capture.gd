extends SceneTree
## Captura local do frame autoritativo de impacto; `game/captures/` e ignorado.

class CaptureActor extends Node3D:
	var class_id := "warrior"
	var main_weapon := "longsword"
	var offhand_weapon := "shield"
	var is_two_handed := false
	var _visual: CharacterVisual
	var _hitstun_frames := 0
	var body_radius := 0.0
	var camera: Node3D

	func is_alive() -> bool:
		return true


func _initialize() -> void:
	_capture.call_deferred()


func _capture() -> void:
	await process_frame
	var stage := Node3D.new()
	stage.name = "ImpactCapture"
	root.add_child(stage)
	var camera := _build_environment(stage)
	var target := _make_actor(stage, "tank", Vector3.ZERO)
	var attacker := _make_actor(stage, "warrior", Vector3(1.35, 0.0, 0.55))
	attacker.look_at(target.global_position + Vector3.UP)
	target.camera = camera

	for _frame in 30:
		await process_frame
	var game_data := root.get_node("GameData")
	var attack := (game_data.call("weapon", "longsword") as Dictionary).get(
		"light", {}) as Dictionary
	var combat := game_data.get("combat") as Dictionary
	target._hitstun_frames = ceili(float((combat.get("hitstun", {}) as Dictionary).get(
		"light", 0.0)) * float(combat.get("reference_fps", 0.0)))
	var feedback := HitFeedback.install(target)
	feedback.audio_enabled = false
	feedback.present_hit(attacker, target, DamageInfo.make(0.0, attacker, "light"),
		"metal", int(attack.get("active", 0)))
	await process_frame
	var image := root.get_viewport().get_texture().get_image()
	var path := "res://captures/impact-autoritative-frame.png"
	var error := image.save_png(ProjectSettings.globalize_path(path))
	print("[impact-capture] %s (%s)" % [path, error_string(error)])
	quit(0 if error == OK else 1)


func _make_actor(stage: Node3D, class_id: String, at: Vector3) -> CaptureActor:
	var game_data := root.get_node("GameData")
	var actor := CaptureActor.new()
	actor.class_id = class_id
	stage.add_child(actor)
	actor.global_position = at
	actor._visual = CharacterVisual.new()
	actor.add_child(actor._visual)
	var player_cfg := game_data.call("section", "player") as Dictionary
	actor._visual.setup(float(player_cfg.get("capsule_height", 0.0)),
		Color.WHITE, true, "body_male", class_id)
	var capsule := CapsuleShape3D.new()
	capsule.height = float(player_cfg.get("capsule_height", 0.0))
	capsule.radius = float(player_cfg.get("capsule_radius", 0.0))
	actor.body_radius = capsule.radius
	var collision := CollisionShape3D.new()
	collision.shape = capsule
	collision.position.y = capsule.height * 0.5
	actor.add_child(collision)
	var weapons := WeaponVisual.new()
	actor.add_child(weapons)
	weapons.setup(actor, actor._visual)
	return actor


func _build_environment(stage: Node3D) -> Camera3D:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("11171d")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("8ba2b6")
	environment.ambient_light_energy = 0.75
	var world_environment := WorldEnvironment.new()
	world_environment.environment = environment
	stage.add_child(world_environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-48.0, -34.0, 0.0)
	light.light_energy = 1.5
	stage.add_child(light)
	var floor := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(8.0, 8.0)
	floor.mesh = plane
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color("28343b")
	floor.material_override = floor_material
	stage.add_child(floor)
	var camera := Camera3D.new()
	camera.fov = 50.0
	stage.add_child(camera)
	camera.global_position = Vector3(3.4, 2.0, 4.5)
	camera.look_at(Vector3(0.3, 1.0, 0.0))
	camera.current = true
	return camera
