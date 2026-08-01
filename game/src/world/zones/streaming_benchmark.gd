extends SceneTree
## Benchmark repetível do carregamento real disponível (Brumal + cópia com
## assets partilhados). Mede processo, renderer e o frame que publica a cena.
##
## Correr a 1080p com o renderer Mobile:
##   godot --path game/ --rendering-method mobile \
##     --script res://src/world/zones/streaming_benchmark.gd -- \
##     --out=res://src/world/zones/medicao-streaming-local.json

const StreamingManagerScript = preload("res://src/world/streaming_manager.gd")

var _manager: Node
var _frame_samples_ms: Array[float] = []
var _last_frame_usec := 0
var _out_path := "user://streaming-benchmark.json"


func _initialize() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--out="):
			_out_path = argument.get_slice("=", 1)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1920, 1080))
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	_build_camera()
	_manager = StreamingManagerScript.new()
	root.add_child(_manager)
	_last_frame_usec = Time.get_ticks_usec()
	call_deferred("_run")


func _process(_delta: float) -> bool:
	var now_usec := Time.get_ticks_usec()
	if _last_frame_usec > 0:
		_frame_samples_ms.append(float(now_usec - _last_frame_usec) / 1000.0)
	_last_frame_usec = now_usec
	return false


func _run() -> void:
	var world_data := {
		"streaming": {"max_world_working_set_gb": 2.5},
		"connections": [{"from": "brumal", "to": "brumal_partilhada"}],
	}
	var registry := {
		"brumal": {
			"scene_path": "res://src/world/zones/brumal_streaming_zone.tscn",
			"budget_mib": 512,
			"origin": Vector3.ZERO,
		},
		"brumal_partilhada": {
			"scene_path": "res://src/world/zones/brumal_streaming_zone.tscn",
			"budget_mib": 512,
			"origin": Vector3(260.0, 0.0, 0.0),
		},
	}
	if not _manager.configure(world_data, registry, "current_and_transition"):
		_fail("configuração recusada")
		return
	await _wait_frames(120)
	var baseline := _memory_snapshot()
	_reset_frame_clock()
	var initial_start := _frame_samples_ms.size()
	if not _manager.request_initial_zone("brumal"):
		_fail("Brumal não iniciou")
		return
	await _manager.zone_ready
	await _wait_frames(120)
	var initial_end := _frame_samples_ms.size()
	var one_zone := _memory_snapshot()
	_reset_frame_clock()
	var transition_start := _frame_samples_ms.size()
	var transition_outcome := {"ready": false, "failed": false, "reason": ""}
	_manager.transition_ready.connect(func(zone_id: String) -> void:
		if zone_id == "brumal_partilhada":
			transition_outcome["ready"] = true)
	_manager.zone_failed.connect(func(zone_id: String, reason: String) -> void:
		if zone_id == "brumal_partilhada":
			transition_outcome["failed"] = true
			transition_outcome["reason"] = reason)
	if not _manager.prepare_transition("brumal_partilhada"):
		_fail("transição não iniciou")
		return
	while not bool(transition_outcome.get("ready", false)) \
			and not bool(transition_outcome.get("failed", false)):
		await process_frame
	var transition_end := _frame_samples_ms.size()
	# Quando o gate reprova, a candidata já está marcada para queue_free mas ainda
	# existe neste callback; esta é a fotografia do pico que interessa diagnosticar.
	var candidate_peak := _memory_snapshot()
	_reset_frame_clock()
	if bool(transition_outcome.get("ready", false)):
		_manager.commit_transition("brumal_partilhada")
		_manager.release_retreat_zone()
	await _wait_frames(120)
	var after_unload := _memory_snapshot()
	var physical_bytes := int(OS.get_memory_info().get("physical", -1))
	var result := {
		"date": Time.get_datetime_string_from_system(false, true),
		"engine": Engine.get_version_info().get("string", ""),
		"renderer": RenderingServer.get_current_rendering_method(),
		"adapter": RenderingServer.get_video_adapter_name(),
		"resolution": "1920x1080",
		"physical_memory_gib": snappedf(float(physical_bytes) / 1073741824.0, 0.01),
		"target_8_gib": physical_bytes > 0 and physical_bytes <= 9 * 1073741824,
		"policy": "current_and_transition",
		"case": "duas Brumal; geometria duplicada e assets partilhados; não representa Fojo final",
		"baseline": baseline,
		"one_zone": one_zone,
		"candidate_peak": candidate_peak,
		"after_unload": after_unload,
		"initial_frames": _summarise_frames(initial_start, initial_end),
		"transition_frames": _summarise_frames(transition_start, transition_end),
		"manager_memory_records": _manager.memory_report(),
		"transition_admitted": bool(transition_outcome.get("ready", false)),
		"transition_failure": String(transition_outcome.get("reason", "")),
		"gates": {
			"p99_ms": 16.67,
			"worst_ms": 20.0,
			"working_set_mib": 2560,
			"per_zone_mib": 512,
		},
		"honest_limit": "esta máquina tem 16 GiB; repetir no i5-1334U/8 GiB do Rico antes de fechar a pergunta 50",
	}
	var file := FileAccess.open(_out_path, FileAccess.WRITE)
	if file == null:
		_fail("não foi possível escrever o resultado")
		return
	file.store_string(JSON.stringify(result, "  "))
	file.close()
	print("STREAMING_BENCH_RESULT ", JSON.stringify(result))
	_manager.queue_free()
	await _wait_frames(2)
	quit(0)


func _memory_snapshot() -> Dictionary:
	var process_memory := _windows_process_memory()
	return {
		"working_set_mib": snappedf(float(process_memory.get("working_set_bytes", -1))
				/ 1048576.0, 0.1),
		"peak_working_set_mib": snappedf(float(process_memory.get("peak_working_set_bytes", -1))
				/ 1048576.0, 0.1),
		"static_memory_mib": snappedf(float(OS.get_static_memory_usage()) / 1048576.0, 0.1),
		"video_memory_mib": snappedf(float(Performance.get_monitor(
				Performance.RENDER_VIDEO_MEM_USED)) / 1048576.0, 0.1),
		"nodes": int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)),
		"resources": int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)),
	}


func _windows_process_memory() -> Dictionary:
	if OS.get_name() != "Windows":
		return {"working_set_bytes": -1, "peak_working_set_bytes": -1}
	var output: Array = []
	var command := "$p=Get-Process -Id %d; Write-Output $p.WorkingSet64; Write-Output $p.PeakWorkingSet64" \
			% OS.get_process_id()
	var exit_code := OS.execute("powershell", ["-NoProfile", "-NonInteractive", "-Command",
			command], output, true)
	if exit_code != 0 or output.is_empty():
		return {"working_set_bytes": -1, "peak_working_set_bytes": -1}
	var parts := String(output[0]).strip_edges().split("\n", false)
	if parts.size() != 2:
		return {"working_set_bytes": -1, "peak_working_set_bytes": -1}
	return {
		"working_set_bytes": int(parts[0]),
		"peak_working_set_bytes": int(parts[1]),
	}


func _summarise_frames(from_index: int, to_index: int) -> Dictionary:
	var samples: Array[float] = []
	for index: int in range(from_index, mini(to_index, _frame_samples_ms.size())):
		samples.append(_frame_samples_ms[index])
	if samples.is_empty():
		return {"error": "sem amostras"}
	samples.sort()
	var total := 0.0
	for sample: float in samples:
		total += sample
	var p99_index := clampi(ceili(float(samples.size()) * 0.99) - 1, 0,
			samples.size() - 1)
	return {
		"frames": samples.size(),
		"average_ms": snappedf(total / float(samples.size()), 0.001),
		"p99_ms": snappedf(samples[p99_index], 0.001),
		"worst_ms": snappedf(samples[-1], 0.001),
		"frames_over_16_67_ms": samples.filter(func(value: float) -> bool:
			return value > 16.67).size(),
		"frames_over_20_ms": samples.filter(func(value: float) -> bool:
			return value > 20.0).size(),
	}


func _wait_frames(count: int) -> void:
	for _index: int in count:
		await process_frame


func _build_camera() -> void:
	var camera := Camera3D.new()
	camera.look_at_from_position(Vector3(0.0, 35.0, 55.0), Vector3(0.0, 0.0, -20.0))
	root.add_child(camera)
	camera.current = true


func _reset_frame_clock() -> void:
	_last_frame_usec = Time.get_ticks_usec()


func _fail(reason: String) -> void:
	printerr("STREAMING_BENCH_FAILED ", reason)
	quit(1)
