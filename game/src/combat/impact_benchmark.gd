extends SceneTree
## A/B da Lei 4 com cinco atacantes e seis esqueletos animados.
## Usa o Bench existente: --bench --impact=off|on --seconds=15 --warmup=4.

class BenchActor extends Node3D:
	var class_id := "warrior"
	var main_weapon := "longsword"
	var offhand_weapon := ""
	var is_two_handed := false
	var state_frame := 0
	var _atk_startup := 0
	var _atk_active := 0
	var _charge_frames := 0
	var _hitstun_frames := 0
	var body_radius := 0.0
	var camera: Node3D
	var _visual: CharacterVisual

	func is_alive() -> bool:
		return true


class ImpactBenchDriver extends Node:
	var impact_enabled := true
	var feedback: HitFeedback
	var target: BenchActor
	var attackers: Array[BenchActor] = []
	var attack: Dictionary = {}
	var cycle_frame := 0

	func _physics_process(_delta: float) -> void:
		var startup := int(attack.get("startup", 0))
		var active := int(attack.get("active", 0))
		var total := startup + active + int(attack.get("recovery", 0))
		if total <= 0:
			return
		cycle_frame = (cycle_frame + 1) % total
		for attacker: BenchActor in attackers:
			attacker.state_frame = cycle_frame
			if cycle_frame == 1:
				attacker._visual.play_animation("Sword_Attack")
			elif cycle_frame == 0:
				attacker._visual.play_animation("Idle")
		if impact_enabled and cycle_frame == startup + 1:
			for attacker: BenchActor in attackers:
				feedback.present_hit(attacker, target,
					DamageInfo.make(0.0, attacker, "light"), "metal")


func _initialize() -> void:
	_build.call_deferred()


func _build() -> void:
	await process_frame
	var impact_enabled := true
	for argument: String in OS.get_cmdline_user_args():
		if argument == "--impact=off":
			impact_enabled = false
	var stage := Node3D.new()
	stage.name = "ImpactBenchmark"
	root.add_child(stage)
	var camera := _build_environment(stage)
	var target := _make_actor(stage, "tank", Vector3.ZERO, true)
	target.camera = camera
	var game_data := root.get_node("GameData")
	var attack := (game_data.call("weapon", "longsword") as Dictionary).get(
		"light", {}) as Dictionary
	var combat := game_data.get("combat") as Dictionary
	target._hitstun_frames = ceili(float((combat.get("hitstun", {}) as Dictionary).get(
		"light", 0.0)) * float(combat.get("reference_fps", 0.0)))
	var attackers: Array[BenchActor] = []
	for index in 5:
		var angle := TAU * float(index) / 5.0
		var attacker := _make_actor(stage, "warrior",
			Vector3(sin(angle), 0.0, cos(angle)) * 1.75, false)
		attacker.look_at(target.global_position + Vector3.UP)
		attacker._atk_startup = int(attack.get("startup", 0))
		attacker._atk_active = int(attack.get("active", 0))
		attackers.append(attacker)
	var feedback := HitFeedback.install(target)
	var driver := ImpactBenchDriver.new()
	driver.impact_enabled = impact_enabled
	driver.feedback = feedback
	driver.target = target
	driver.attackers = attackers
	driver.attack = attack
	stage.add_child(driver)
	print("[impact-bench] cinco atacantes, feedback=%s" % ["on" if impact_enabled else "off"])


func _make_actor(stage: Node3D, class_id: String, at: Vector3,
		with_offhand: bool) -> BenchActor:
	var game_data := root.get_node("GameData")
	var actor := BenchActor.new()
	actor.class_id = class_id
	actor.offhand_weapon = "shield" if with_offhand else ""
	stage.add_child(actor)
	actor.global_position = at
	actor._visual = CharacterVisual.new()
	actor.add_child(actor._visual)
	var player_cfg := game_data.call("section", "player") as Dictionary
	actor._visual.setup(float(player_cfg.get("capsule_height", 0.0)),
		Color.WHITE, false, "body_male", class_id)
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
	environment.ambient_light_energy = 0.7
	var world_environment := WorldEnvironment.new()
	world_environment.environment = environment
	stage.add_child(world_environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-48.0, -34.0, 0.0)
	light.light_energy = 1.45
	stage.add_child(light)
	var floor := MeshInstance3D.new()
	var plane := PlaneMesh.new()
	plane.size = Vector2(12.0, 12.0)
	floor.mesh = plane
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color("28343b")
	floor.material_override = floor_material
	stage.add_child(floor)
	var camera := Camera3D.new()
	camera.fov = 58.0
	stage.add_child(camera)
	camera.global_position = Vector3(5.8, 4.0, 7.0)
	camera.look_at(Vector3(0.0, 0.9, 0.0))
	camera.current = true
	return camera
