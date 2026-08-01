extends SceneTree
## Benchmark reproduzível do custo de actores com esqueleto real.
##
## Exemplo (a pasta benchmark_assets pode ser uma junction temporária para um
## pack em art/):
##   godot --path game --script res://src/tools/animation_benchmark.gd -- \
##     --asset=res://benchmark_assets/UAL1_Standard.glb --actors=5 --seconds=12

var _actors := 5
var _measure_seconds := 12.0
var _warmup_seconds := 3.0
var _elapsed := 0.0
var _samples: Array[float] = []
var _animation_name := ""
var _animation_players := 0
var _asset_path := "res://benchmark_assets/UAL1_Standard.glb"
var _width := 1920
var _height := 1080
var _vsync_on := false
var _failed := false


func _initialize() -> void:
	_parse_arguments()
	DisplayServer.window_set_size(Vector2i(_width, _height))
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if _vsync_on else DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	var packed := load(_asset_path) as PackedScene
	if packed == null:
		_fail("não foi possível carregar %s" % _asset_path)
		return

	var stage := Node3D.new()
	stage.name = "AnimationBenchmark"
	root.add_child(stage)
	var camera := Camera3D.new()
	camera.position = Vector3(0.0, 2.2, 9.0)
	camera.look_at_from_position(camera.position, Vector3(0.0, 1.0, 0.0))
	stage.add_child(camera)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-48.0, -28.0, 0.0)
	light.shadow_enabled = true
	stage.add_child(light)

	for index: int in _actors:
		var actor := packed.instantiate()
		actor.position = Vector3((float(index) - float(_actors - 1) * 0.5) * 1.35,
			0.0, -absf(float(index) - float(_actors - 1) * 0.5) * 0.25)
		stage.add_child(actor)
		var player := _find_animation_player(actor)
		if player == null:
			_fail("actor %d não contém AnimationPlayer" % index)
			return
		_animation_players += 1
		var candidate := _pick_animation(player)
		if candidate == "":
			_fail("actor %d não contém animação utilizável" % index)
			return
		if _animation_name == "":
			_animation_name = candidate
		player.play(candidate)

	print("[ANIMATION_BENCH] asset=%s actors=%d players=%d animation=%s warmup=%.1fs measure=%.1fs resolution=%dx%d vsync=%s renderer=%s gpu=%s" % [
		_asset_path, _actors, _animation_players, _animation_name, _warmup_seconds,
		_measure_seconds, _width, _height, "on" if _vsync_on else "off",
		RenderingServer.get_current_rendering_method(),
		RenderingServer.get_video_adapter_name()])


func _process(delta: float) -> bool:
	if _failed:
		return true
	_elapsed += delta
	if _elapsed > _warmup_seconds:
		_samples.append(delta * 1000.0)
	if _elapsed < _warmup_seconds + _measure_seconds:
		return false
	_report()
	return true


func _finalize() -> void:
	pass


func _parse_arguments() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--asset="):
			_asset_path = argument.trim_prefix("--asset=")
		elif argument.begins_with("--actors="):
			_actors = maxi(1, argument.trim_prefix("--actors=").to_int())
		elif argument.begins_with("--seconds="):
			_measure_seconds = maxf(1.0, argument.trim_prefix("--seconds=").to_float())
		elif argument.begins_with("--warmup="):
			_warmup_seconds = maxf(0.0, argument.trim_prefix("--warmup=").to_float())
		elif argument.begins_with("--width="):
			_width = maxi(320, argument.trim_prefix("--width=").to_int())
		elif argument.begins_with("--height="):
			_height = maxi(240, argument.trim_prefix("--height=").to_int())
		elif argument.begins_with("--vsync="):
			_vsync_on = argument.trim_prefix("--vsync=") == "on"


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child: Node in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null


func _pick_animation(player: AnimationPlayer) -> String:
	var fallback := ""
	for animation: StringName in player.get_animation_list():
		var candidate := String(animation)
		if candidate == "RESET":
			continue
		if fallback == "":
			fallback = candidate
		var lower := candidate.to_lower()
		if "run" in lower or "walk" in lower or "idle" in lower:
			return candidate
	return fallback


func _report() -> void:
	if _samples.is_empty():
		_fail("nenhuma amostra recolhida")
		return
	_samples.sort()
	var total := 0.0
	for sample: float in _samples:
		total += sample
	var average_ms := total / float(_samples.size())
	var p95_index := clampi(ceili(float(_samples.size()) * 0.95) - 1, 0, _samples.size() - 1)
	var p99_index := clampi(ceili(float(_samples.size()) * 0.99) - 1, 0, _samples.size() - 1)
	print("[ANIMATION_BENCH_RESULT] actors=%d samples=%d average_ms=%.3f average_fps=%.1f p95_ms=%.3f p99_ms=%.3f worst_ms=%.3f" % [
		_actors, _samples.size(), average_ms, 1000.0 / average_ms,
		_samples[p95_index], _samples[p99_index], _samples[-1]])


func _fail(message: String) -> void:
	_failed = true
	printerr("[ANIMATION_BENCH_ERROR] %s" % message)
	quit(2)
