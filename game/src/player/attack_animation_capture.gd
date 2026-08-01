extends SceneTree
## Prova visual reproduzivel dos quatro verbos minimos de uma familia.
## Guarda apenas em user://; nenhum caminho local entra no repositorio.

const REQUESTS := [
	{"label": "LEVE 1", "kind": "light", "combo": 1, "running": false},
	{"label": "LEVE 2", "kind": "light", "combo": 2, "running": false},
	{"label": "PESADO", "kind": "heavy", "combo": 0, "running": false},
	{"label": "CORRIDA", "kind": "light", "combo": 1, "running": true},
]

class CaptureActor extends Node3D:
	var main_weapon := "longsword"
	var offhand_weapon := ""
	var is_two_handed := false


func _initialize() -> void:
	_capture.call_deferred()


func _capture() -> void:
	root.get_node("Bench").call("set_overlay_visible", false)
	var stage := Node3D.new()
	root.add_child(stage)
	_build_environment(stage)
	var game_data := root.get_node("GameData")
	var weapon: Dictionary = game_data.call("weapon", "longsword") as Dictionary
	var player_height := float((game_data.call("section", "player") as Dictionary).get(
		"capsule_height", 0.0))
	var ticks_per_second := float(ProjectSettings.get_setting(
		"physics/common/physics_ticks_per_second"))
	for index: int in REQUESTS.size():
		var request := REQUESTS[index] as Dictionary
		var actor := CaptureActor.new()
		actor.position = Vector3((float(index) - 1.5) * 2.0, 0.0, 0.0)
		stage.add_child(actor)
		var visual := CharacterVisual.new()
		actor.add_child(visual)
		visual.setup(player_height, Color.WHITE, false, "body_male", "warrior")
		var attach := WeaponAttach.new()
		actor.add_child(attach)
		attach.setup(actor, visual)
		var attacks := AttackAnimationController.new()
		actor.add_child(attacks)
		attacks.setup(actor, visual)
		var attack_key := "heavy" if String(request.get("kind")) == "heavy" else "light"
		var attack: Dictionary = weapon.get(attack_key, {}) as Dictionary
		attacks.play_attack("longsword", String(request.get("kind")),
			int(request.get("combo")), bool(request.get("running")), attack)
		var animation_player := _find_animation_player(visual)
		if animation_player != null:
			var active_end := float(int(attack.get("startup", 0)) \
				+ int(attack.get("active", 0)))
			animation_player.seek(active_end / ticks_per_second, true)
			animation_player.pause()
		var label := Label3D.new()
		label.text = String(request.get("label", ""))
		label.position = Vector3(0.0, 2.35, 0.0)
		label.font_size = 48
		label.outline_size = 10
		label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		actor.add_child(label)

	for _frame: int in 3:
		await process_frame
	var path := "user://attack-animation-proof.png"
	var error := root.get_viewport().get_texture().get_image().save_png(path)
	print("[ATTACK_CAPTURE] path=%s error=%d" % [
		ProjectSettings.globalize_path(path), error])
	quit(0 if error == OK else 1)


func _build_environment(stage: Node3D) -> void:
	var world := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("11171d")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("8ba2b6")
	environment.ambient_light_energy = 0.8
	world.environment = environment
	stage.add_child(world)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-42.0, 145.0, 0.0)
	light.light_energy = 1.15
	stage.add_child(light)
	var floor_mesh := MeshInstance3D.new()
	var floor := PlaneMesh.new()
	floor.size = Vector2(16.0, 8.0)
	floor_mesh.mesh = floor
	var floor_material := StandardMaterial3D.new()
	floor_material.albedo_color = Color("28343b")
	floor_mesh.material_override = floor_material
	stage.add_child(floor_mesh)
	var camera := Camera3D.new()
	camera.position = Vector3(3.8, 2.0, -9.0)
	camera.fov = 44.0
	stage.add_child(camera)
	camera.look_at_from_position(camera.position, Vector3(0.0, 1.05, 0.0))


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child: Node in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null
