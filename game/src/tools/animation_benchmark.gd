extends SceneTree
## Benchmark reproduzivel do custo de actores com esqueleto real.
##
## Mede o intervalo real entre apresentacoes. O delta do motor tambem e mostrado,
## mas nao decide o gate porque pode ser suavizado. Exemplo:
##   godot --path game --script res://src/tools/animation_benchmark.gd -- \
##     --asset=res://benchmark_assets/UAL1_Standard.glb --actors=5 --seconds=12 \
##     --window=fullscreen --vsync=on --gate

var _actors := 5
var _measure_seconds := 12.0
var _warmup_seconds := 3.0
var _elapsed := 0.0
var _wall_samples: Array[float] = []
var _engine_delta_samples: Array[float] = []
var _animation_name := ""
var _animation_players := 0
var _asset_path := "res://benchmark_assets/UAL1_Standard.glb"
var _width := 1920
var _height := 1080
var _window_mode := "fullscreen"
var _vsync := "on"
var _gate := false
var _gate_p99_ms := 16.67
var _gate_worst_ms := 20.0
var _failed := false
var _last_tick_usec := 0


func _initialize() -> void:
	_parse_arguments()
	_configure_display()
	if _failed:
		return
	var packed := load(_asset_path) as PackedScene
	if packed == null:
		_fail("nao foi possivel carregar %s" % _asset_path)
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
			_fail("actor %d nao contem AnimationPlayer" % index)
			return
		_animation_players += 1
		var candidate := _pick_animation(player)
		if candidate == "":
			_fail("actor %d nao contem animacao utilizavel" % index)
			return
		if _animation_name == "":
			_animation_name = candidate
		player.play(candidate)

	_last_tick_usec = Time.get_ticks_usec()
	print("[ANIMATION_BENCH] asset=%s actors=%d players=%d animation=%s warmup=%.1fs measure=%.1fs resolution=%dx%d window=%s vsync=%s renderer=%s gpu=%s" % [
		_asset_path, _actors, _animation_players, _animation_name, _warmup_seconds,
		_measure_seconds, _width, _height, _window_mode, _vsync,
		RenderingServer.get_current_rendering_method(),
		RenderingServer.get_video_adapter_name()])


func _process(delta: float) -> bool:
	if _failed:
		return true
	var now_usec := Time.get_ticks_usec()
	var wall_ms := float(now_usec - _last_tick_usec) / 1000.0
	_last_tick_usec = now_usec
	_elapsed += wall_ms / 1000.0
	if _elapsed > _warmup_seconds:
		_wall_samples.append(wall_ms)
		_engine_delta_samples.append(delta * 1000.0)
	if _elapsed < _warmup_seconds + _measure_seconds:
		return false
	_report()
	return not _failed


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
		elif argument.begins_with("--window="):
			_window_mode = argument.trim_prefix("--window=").to_lower()
		elif argument.begins_with("--vsync="):
			_vsync = argument.trim_prefix("--vsync=").to_lower()
		elif argument == "--gate":
			_gate = true
		elif argument.begins_with("--gate-p99-ms="):
			_gate_p99_ms = maxf(0.1, argument.trim_prefix("--gate-p99-ms=").to_float())
		elif argument.begins_with("--gate-worst-ms="):
			_gate_worst_ms = maxf(0.1, argument.trim_prefix("--gate-worst-ms=").to_float())


func _configure_display() -> void:
	if _window_mode == "fullscreen":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif _window_mode == "exclusive":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	elif _window_mode == "windowed":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(_width, _height))
	else:
		_fail("--window aceita fullscreen, exclusive ou windowed")
		return
	if _vsync == "on":
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	elif _vsync == "off":
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	elif _vsync == "adaptive":
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ADAPTIVE)
	elif _vsync == "mailbox":
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_MAILBOX)
	else:
		_fail("--vsync aceita on, off, adaptive ou mailbox")


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
	if _wall_samples.is_empty():
		_fail("nenhuma amostra recolhida")
		return
	var wall := _statistics(_wall_samples)
	var engine_delta := _statistics(_engine_delta_samples)
	print("[ANIMATION_BENCH_RESULT] actors=%d samples=%d wall_average_ms=%.3f average_fps=%.1f wall_p95_ms=%.3f wall_p99_ms=%.3f wall_worst_ms=%.3f engine_delta_p99_ms=%.3f window=%s vsync=%s" % [
		_actors, _wall_samples.size(), wall.average, 1000.0 / wall.average,
		wall.p95, wall.p99, wall.worst, engine_delta.p99, _window_mode, _vsync])
	if _gate and (wall.p99 > _gate_p99_ms or wall.worst > _gate_worst_ms):
		printerr("[ANIMATION_BENCH_GATE] FALHA p99=%.3f/%.3fms worst=%.3f/%.3fms" % [
			wall.p99, _gate_p99_ms, wall.worst, _gate_worst_ms])
		_failed = true
		quit(1)
	elif _gate:
		print("[ANIMATION_BENCH_GATE] PASSA p99=%.3f/%.3fms worst=%.3f/%.3fms" % [
			wall.p99, _gate_p99_ms, wall.worst, _gate_worst_ms])


func _statistics(source: Array[float]) -> Dictionary:
	var sorted := source.duplicate()
	sorted.sort()
	var total := 0.0
	for sample: float in sorted:
		total += sample
	var p95_index := clampi(ceili(float(sorted.size()) * 0.95) - 1, 0, sorted.size() - 1)
	var p99_index := clampi(ceili(float(sorted.size()) * 0.99) - 1, 0, sorted.size() - 1)
	return {
		"average": total / float(sorted.size()),
		"p95": sorted[p95_index],
		"p99": sorted[p99_index],
		"worst": sorted[-1],
	}


func _fail(message: String) -> void:
	_failed = true
	printerr("[ANIMATION_BENCH_ERROR] %s" % message)
	quit(2)
