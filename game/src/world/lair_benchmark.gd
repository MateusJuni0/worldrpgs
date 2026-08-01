extends SceneTree
## Prova visual e de desempenho isolada da Toca.
##
##   godot --path game --rendering-method mobile \
##     --script res://src/world/lair_benchmark.gd -- --capture --seconds=12

const LAIR_SCRIPT = preload("res://src/world/lair.gd")

var _lair: Node3D
var _camera: Camera3D
var _warmup_seconds := 3.0
var _measure_seconds := 12.0
var _elapsed := 0.0
var _samples: Array[float] = []
var _capture := false
var _capture_index := 0
var _capture_wait_frames := 0
var _measurement_done := false
var _failed := false
var _views: Array = []


func _initialize() -> void:
	_parse_arguments()
	DisplayServer.window_set_size(Vector2i(1920, 1080))
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0

	var stage := Node3D.new()
	stage.name = "LairBenchmark"
	root.add_child(stage)
	_build_environment(stage)
	_lair = LAIR_SCRIPT.new() as Node3D
	stage.add_child(_lair)
	_lair.build({"shadows": false})

	var audit: Dictionary = _lair.audit()
	if int(audit.get("sectors", 0)) != 9 or int(audit.get("shortcuts", 0)) != 2:
		_fail("auditoria estrutural falhou: %s" % audit)
		return
	if int(audit.get("kaykit_assets", 0)) < 20 or int(audit.get("enemy_markers", 0)) != 6:
		_fail("conteudo modular incompleto: %s" % audit)
		return

	_camera = Camera3D.new()
	_camera.fov = 67.0
	_camera.near = 0.08
	stage.add_child(_camera)
	_camera.make_current()
	_views = [
		["01-entrada-distante", Vector3(0.0, 3.0, 29.0), Vector3(0.0, 3.4, 0.0)],
		["02-sala-descida", Vector3(-2.0, -1.4, -17.0), Vector3(-2.0, -1.5, -25.0)],
		["03-sala-emboscada", Vector3(-1.5, -3.4, -37.0), Vector3(8.0, -3.4, -40.0)],
		["04-atalho-interior", Vector3(10.0, -0.55, -18.0), Vector3(10.0, -3.2, -36.0)],
		["05-arena-vorgar", Vector3(-2.0, -6.25, -74.0), Vector3(-2.0, -6.4, -85.0)],
	]
	_apply_view(0)
	print("[LAIR_BENCH] audit=%s warmup=%.1fs measure=%.1fs resolution=1920x1080 renderer=%s gpu=%s" % [
		audit, _warmup_seconds, _measure_seconds,
		RenderingServer.get_current_rendering_method(), RenderingServer.get_video_adapter_name()])


func _process(delta: float) -> bool:
	if _failed:
		return true
	if not _measurement_done:
		_elapsed += delta
		var tour_index := int(_elapsed / 1.4) % _views.size()
		_apply_view(tour_index)
		if _elapsed > _warmup_seconds:
			_samples.append(delta * 1000.0)
		if _elapsed < _warmup_seconds + _measure_seconds:
			return false
		_report()
		_measurement_done = true
		if not _capture:
			return true
		_lair.open_shortcut(&"mid_loop", false)
		_lair.open_shortcut(&"boss_return", false)
		_capture_index = 0
		_capture_wait_frames = 0
		_apply_view(_capture_index)
		return false

	_capture_wait_frames += 1
	if _capture_wait_frames < 18:
		return false
	_save_capture(_capture_index)
	_capture_index += 1
	if _capture_index >= _views.size():
		print("[LAIR_CAPTURE] done=%d path=res://captures/lair/" % _views.size())
		return true
	_capture_wait_frames = 0
	_apply_view(_capture_index)
	return false


func _finalize() -> void:
	pass


func _parse_arguments() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument == "--capture":
			_capture = true
		elif argument.begins_with("--seconds="):
			_measure_seconds = maxf(1.0, argument.trim_prefix("--seconds=").to_float())
		elif argument.begins_with("--warmup="):
			_warmup_seconds = maxf(0.0, argument.trim_prefix("--warmup=").to_float())


func _build_environment(stage: Node3D) -> void:
	var world_environment := WorldEnvironment.new()
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#07090d")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#8ca0aa")
	environment.ambient_light_energy = 0.22
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment.ssao_enabled = false
	environment.ssil_enabled = false
	environment.glow_enabled = false
	environment.fog_enabled = false
	world_environment.environment = environment
	stage.add_child(world_environment)

	var moon := DirectionalLight3D.new()
	moon.rotation_degrees = Vector3(-55.0, -25.0, 0.0)
	moon.light_color = Color("#8194a8")
	moon.light_energy = 0.32
	moon.shadow_enabled = false
	stage.add_child(moon)


func _apply_view(index: int) -> void:
	if _camera == null or _views.is_empty():
		return
	var view: Array = _views[index]
	_camera.look_at_from_position(view[1] as Vector3, view[2] as Vector3)


func _save_capture(index: int) -> void:
	var directory := ProjectSettings.globalize_path("res://captures/lair/")
	DirAccess.make_dir_recursive_absolute(directory)
	var image := root.get_texture().get_image()
	var label := String((_views[index] as Array)[0])
	var error := image.save_png(directory + label + ".png")
	if error != OK:
		_fail("nao foi possivel guardar captura %s: erro %d" % [label, error])
		return
	print("[LAIR_CAPTURE] %s" % label)


func _report() -> void:
	if _samples.is_empty():
		_fail("nenhuma amostra de frame recolhida")
		return
	_samples.sort()
	var total := 0.0
	for sample: float in _samples:
		total += sample
	var average_ms := total / float(_samples.size())
	var p95 := _percentile(0.95)
	var p99 := _percentile(0.99)
	print("[LAIR_BENCH_RESULT] samples=%d average_ms=%.3f average_fps=%.1f p95_ms=%.3f p99_ms=%.3f worst_ms=%.3f draw_calls=%d objects=%d" % [
		_samples.size(), average_ms, 1000.0 / average_ms, p95, p99, _samples[-1],
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME)])


func _percentile(fraction: float) -> float:
	var index := clampi(ceili(float(_samples.size()) * fraction) - 1, 0, _samples.size() - 1)
	return _samples[index]


func _fail(message: String) -> void:
	_failed = true
	printerr("[LAIR_BENCH_ERROR] %s" % message)
	quit(2)
