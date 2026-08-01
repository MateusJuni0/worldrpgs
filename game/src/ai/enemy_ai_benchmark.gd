extends Node3D
## Stress reproduzível: oito inimigos renderizados e toda a decisão nova
## avaliada em cada frame. Os parâmetros vivem em enemies.json.
##
## godot --path game/ --rendering-method mobile \
##   res://src/ai/enemy_ai_benchmark.tscn -- --vsync=off

const EnemyScript = preload("res://src/enemies/enemy.gd")
const Perception = preload("res://src/ai/enemy_perception.gd")
const CombatBrain = preload("res://src/ai/enemy_combat_brain.gd")
const CrowdSteering = preload("res://src/ai/enemy_crowd_steering.gd")
const AttackCoordinator = preload("res://src/ai/enemy_attack_coordinator.gd")

class DummyTarget extends Node3D:
	func is_alive() -> bool:
		return true

	func state_name() -> String:
		return "ataque"

	func take_damage(_info: Variant) -> void:
		pass

var _config: Dictionary = {}
var _enemy_data: Dictionary = {}
var _actors: Array[CharacterBody3D] = []
var _brains: Array[RefCounted] = []
var _target: DummyTarget
var _vsync_on := false
var _elapsed_s := 0.0
var _samples_ms: Array[float] = []


func _ready() -> void:
	var catalogue := _catalogue()
	_config = catalogue.get("_ai_benchmark", {}) as Dictionary
	var defaults: Dictionary = catalogue.get("_enemy_defaults", {}) as Dictionary
	_enemy_data = defaults.duplicate(true)
	_enemy_data.merge(catalogue.get(String(_config.get("enemy_id", "")), {}) as Dictionary, true)
	_parse_arguments()
	DisplayServer.window_set_size(Vector2i(
		int(_config.get("viewport_width_px", 0)),
		int(_config.get("viewport_height_px", 0))))
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if _vsync_on else DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	_build_fixture()
	if _actors.size() != int(_config.get("active_enemies", 0)):
		push_error("[ENEMY_AI_BENCH] fixture incompleta: %d/%d" % [
			_actors.size(), int(_config.get("active_enemies", 0))])
		get_tree().quit(2)


func _process(delta: float) -> void:
	_tick_ai(delta)
	_elapsed_s += delta
	if _elapsed_s > float(_config.get("warmup_seconds", INF)):
		_samples_ms.append(delta * 1000.0)
	if _elapsed_s < float(_config.get("warmup_seconds", 0.0)) + float(
			_config.get("sample_seconds", INF)):
		return
	_report()
	get_tree().quit(0)


func _build_fixture() -> void:
	var stage := Node3D.new()
	stage.name = "EnemyAiBenchmark"
	add_child(stage)
	_add_floor(stage)
	_add_camera_and_light(stage)

	_target = DummyTarget.new()
	_target.position.y = float(_config.get("spawn_height_m", 0.0))
	stage.add_child(_target)
	var actor_count := int(_config.get("active_enemies", 0))
	var radius := float(_enemy_data.get("attack_range", 0.0))
	for index: int in actor_count:
		var enemy := EnemyScript.new() as CharacterBody3D
		stage.add_child(enemy)
		var angle := TAU * float(index) / float(actor_count)
		enemy.position = Vector3(sin(angle) * radius,
			float(_config.get("spawn_height_m", 0.0)), cos(angle) * radius)
		enemy.call("setup", String(_config.get("enemy_id", "")), {}, false, index + 1)
		enemy.set("target", _target)
		_actors.append(enemy)
		var brain := Perception.new()
		brain.reset(enemy.global_position)
		_brains.append(brain)
	print("[ENEMY_AI_BENCH] enemies=%d resolution=%dx%d renderer=%s gpu=%s vsync=%s" % [
		_actors.size(), int(_config.get("viewport_width_px", 0)),
		int(_config.get("viewport_height_px", 0)),
		RenderingServer.get_current_rendering_method(), RenderingServer.get_video_adapter_name(),
		"on" if _vsync_on else "off"])


func _tick_ai(delta: float) -> void:
	var perception_config: Dictionary = _enemy_data.get("perception", {}) as Dictionary
	var behavior: Dictionary = _enemy_data.get("combat_behavior", {}) as Dictionary
	var coordination: Dictionary = _enemy_data.get("attack_coordination", {}) as Dictionary
	var reference_fps := _reference_fps()
	var threat_positions: Array = []
	for actor: CharacterBody3D in _actors:
		threat_positions.append(actor.global_position)
	AttackCoordinator.update_target_actionability(_target, true, coordination, reference_fps)
	for index: int in _actors.size():
		var actor := _actors[index]
		var to_target := _target.global_position - actor.global_position
		var perception_decision: Dictionary = _brains[index].tick(delta, {
			"observer_position": actor.global_position,
			"observer_forward": to_target.normalized(),
			"target_position": _target.global_position,
			"has_line_of_sight": true,
		}, perception_config)
		if String(perception_decision.get("state", "")) != "combat":
			continue
		var has_intent := AttackCoordinator.request_attack_intent(_target, actor,
			_target.global_position, actor.global_position, coordination, threat_positions)
		var combat_decision := CombatBrain.decide({
			"distance_to_target_m": to_target.length(),
			"has_line_of_sight": true,
			"player_visible_state": _target.state_name(),
			"seconds_since_last_attack": float(_enemy_data.get("gap_between_patterns", 0.0)),
			"attack_slot_available": has_intent,
		}, _enemy_data, behavior)
		CrowdSteering.tactical_velocity(actor.global_position, _target.global_position,
			actor.velocity, String(combat_decision.get("action", "")), _enemy_data,
			index % 2 == 0)
	AttackCoordinator.has_escape_route(_target.global_position, threat_positions, coordination)


func _add_floor(stage: Node3D) -> void:
	var body := StaticBody3D.new()
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	var camera_position := _vector_from_array(_config.get("camera_position", []) as Array)
	shape.size = Vector3(camera_position.z * 2.0, 1.0, camera_position.z * 2.0)
	collision.shape = shape
	collision.position.y = -shape.size.y * 0.5
	body.add_child(collision)
	stage.add_child(body)
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = shape.size
	mesh.mesh = box
	mesh.position = collision.position
	stage.add_child(mesh)


func _add_camera_and_light(stage: Node3D) -> void:
	var camera := Camera3D.new()
	camera.position = _vector_from_array(_config.get("camera_position", []) as Array)
	stage.add_child(camera)
	camera.look_at_from_position(camera.position, Vector3.UP)
	camera.current = true
	var light := DirectionalLight3D.new()
	light.rotation = Vector3(-PI * 0.25, -PI * 0.25, 0.0)
	light.shadow_enabled = true
	stage.add_child(light)


func _report() -> void:
	if _samples_ms.is_empty():
		push_error("[ENEMY_AI_BENCH] nenhuma amostra")
		return
	_samples_ms.sort()
	var total_ms := 0.0
	for sample: float in _samples_ms:
		total_ms += sample
	var average_ms := total_ms / float(_samples_ms.size())
	var p95_index := clampi(ceili(float(_samples_ms.size()) * 0.95) - 1,
		0, _samples_ms.size() - 1)
	var p99_index := clampi(ceili(float(_samples_ms.size()) * 0.99) - 1,
		0, _samples_ms.size() - 1)
	var result := {
		"active_enemies": _actors.size(),
		"adapter": RenderingServer.get_video_adapter_name(),
		"renderer": RenderingServer.get_current_rendering_method(),
		"resolution": "%dx%d" % [int(_config.get("viewport_width_px", 0)),
			int(_config.get("viewport_height_px", 0))],
		"vsync": "on" if _vsync_on else "off",
		"samples": _samples_ms.size(),
		"average_fps": snappedf(1000.0 / average_ms, 0.1),
		"average_ms": snappedf(average_ms, 0.001),
		"p95_ms": snappedf(_samples_ms[p95_index], 0.001),
		"p99_ms": snappedf(_samples_ms[p99_index], 0.001),
		"worst_ms": snappedf(_samples_ms[-1], 0.001),
		"draw_calls": int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
		"video_mem_mb": snappedf(Performance.get_monitor(
			Performance.RENDER_VIDEO_MEM_USED) / 1048576.0, 0.1),
	}
	print("ENEMY_AI_BENCH_RESULT " + JSON.stringify(result))


func _catalogue() -> Dictionary:
	var parsed: Variant = JSON.parse_string(
		FileAccess.get_file_as_string("res://data/enemies.json"))
	return parsed as Dictionary if typeof(parsed) == TYPE_DICTIONARY else {}


func _reference_fps() -> float:
	var parsed: Variant = JSON.parse_string(
		FileAccess.get_file_as_string("res://data/combat.json"))
	return float((parsed as Dictionary).get("reference_fps", 0.0)) if (
		typeof(parsed) == TYPE_DICTIONARY) else 0.0


func _vector_from_array(values: Array) -> Vector3:
	if values.size() != 3:
		return Vector3.ZERO
	return Vector3(float(values[0]), float(values[1]), float(values[2]))


func _parse_arguments() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--vsync="):
			_vsync_on = argument.trim_prefix("--vsync=") == "on"
