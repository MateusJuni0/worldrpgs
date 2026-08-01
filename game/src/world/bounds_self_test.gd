class_name BoundsSelfTest
extends SceneTree
## Regressao isolada do limite vertical. Pode correr directamente e pode ser
## carregada pelo dono de self_test.gd sem duplicar os criterios de aceitacao.

func _init() -> void:
	var result := run_suite()
	var failures: Array = result.get("failures", []) as Array
	if not failures.is_empty():
		for failure: String in failures:
			push_error("QUEDA: %s" % failure)
		quit(1)
		return
	print("QUEDA: 3 faixas passaram; morte em %.3f s (limite %.3f s)" % [
		float(result.get("elapsed")), float(result.get("deadline"))])
	quit(0)


static func run_suite() -> Dictionary:
	var progression := JSON.parse_string(FileAccess.get_file_as_string(
		"res://data/progression.json")) as Dictionary
	var fall: Dictionary = progression.get("fall", {}) as Dictionary
	var fatal_height := float(fall.get("fatal_min_m"))
	var gravity := float(ProjectSettings.get_setting("physics/3d/default_gravity"))
	var expected_seconds := sqrt(2.0 * fatal_height / gravity)
	var physics_step := 1.0 / float(Engine.physics_ticks_per_second)
	var deadline := expected_seconds + physics_step * 4.0

	var bounds_script := load("res://src/world/bounds.gd") as Script
	var constants := bounds_script.get_script_constant_map()
	var outcomes: Dictionary = constants.get("Outcome", {}) as Dictionary
	var none_outcome := int(outcomes.get("NONE"))
	var damage_outcome := int(outcomes.get("DAMAGE"))
	var fatal_outcome := int(outcomes.get("FATAL"))
	var failures: Array[String] = []

	var tracker: RefCounted = bounds_script.new()
	tracker.call("reset", 0.0, fall)
	var no_damage_height := float(fall.get("no_damage_max_m"))
	tracker.call("sample", -no_damage_height, false)
	_check(int(tracker.call("sample", -no_damage_height, true)) == none_outcome,
		"a faixa segura causou dano", failures)

	tracker.call("reset", 0.0, fall)
	var knots: Array = fall.get("damage_knots", []) as Array
	var damage_height := float((knots[1] as Dictionary).get("height_m"))
	tracker.call("sample", -damage_height, false)
	_check(int(tracker.call("sample", -damage_height, true)) == damage_outcome,
		"a faixa intermedia nao causou dano", failures)

	tracker.call("reset", 0.0, fall)
	var elapsed := 0.0
	var outcome := none_outcome
	while outcome != fatal_outcome and elapsed <= deadline:
		elapsed += physics_step
		var height := -0.5 * gravity * elapsed * elapsed
		outcome = int(tracker.call("sample", height, false))
	_check(outcome == fatal_outcome, "a faixa mortal nao terminou a queda", failures)
	_check(elapsed <= deadline, "a morte excedeu %.3f s" % deadline, failures)

	var player_source := FileAccess.get_file_as_string("res://src/player/player.gd")
	_check(player_source.contains(
		"evaluate_fall_sample(global_position.y, is_on_floor())"),
		"a fisica do Player nao entrega amostras ao medidor", failures)
	_check(player_source.contains("GameData.fall_damage("),
		"Player nao consome a curva de dano do JSON", failures)
	_check(player_source.contains("_apply_raw_health_loss(amount)"),
		"defesa esta a reduzir dano de queda", failures)
	_check(player_source.contains("died.emit()"),
		"a queda nao tem gancho para o ciclo normal de morte", failures)
	return {"failures": failures, "elapsed": elapsed, "deadline": deadline}


static func _check(condition: bool, message: String, failures: Array[String]) -> void:
	if not condition:
		failures.append(message)
