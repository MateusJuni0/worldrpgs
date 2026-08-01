extends SceneTree
## Mede o custo visual incremental das três barras a 1080p.
## Correr sem --headless para usar a Iris Xe:
## godot --audio-driver Dummy --path game --windowed --rendering-method mobile \
##   --script res://src/status/status_effect_benchmark.gd

const StatusEffectManager = preload("res://src/status/status_effect_manager.gd")
const StatusEffectPresenter = preload("res://src/status/status_effect_presenter.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var manager := StatusEffectManager.new()
	if not manager.configure():
		push_error("[estados-bench] catálogo inválido")
		quit(1)
		return
	var benchmark := manager.benchmark_config()
	root.size = Vector2i(
		int(benchmark.get("viewport_width_px", 0)),
		int(benchmark.get("viewport_height_px", 0))
	)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	await _warmup(int(benchmark.get("warmup_frames", 0)))
	var baseline := await _measure_frames(benchmark)

	var presenter := StatusEffectPresenter.new()
	root.add_child(presenter)
	var presentation := manager.presentation_config()
	presentation["playback_enabled"] = false
	presenter.configure(presentation)
	presenter.bind(manager)
	for status_value: Variant in manager.effect_ids():
		manager.apply_buildup(
			String(status_value),
			float(benchmark.get("meter_fill", 0.0)),
			"benchmark"
		)
	await _warmup(int(benchmark.get("warmup_frames", 0)))
	var with_status := await _measure_frames(benchmark)
	var update_microseconds := _measure_updates(manager, benchmark)

	print("[estados-bench] GPU: %s" % RenderingServer.get_video_adapter_name())
	print("[estados-bench] baseline %.1f fps · p95 %.3f ms" % [
		float(baseline.get("fps", 0.0)), float(baseline.get("p95_ms", 0.0))])
	print("[estados-bench] 3 barras %.1f fps · p95 %.3f ms · diferença %.3f ms" % [
		float(with_status.get("fps", 0.0)), float(with_status.get("p95_ms", 0.0)),
		float(with_status.get("average_ms", 0.0)) - float(baseline.get("average_ms", 0.0))])
	print("[estados-bench] atualização+barra+PCM em cache %.2f µs/evento · alvo %.0f fps" % [
		update_microseconds, float(benchmark.get("target_fps", 0.0))])
	presenter.free()
	manager.free()
	quit()


func _warmup(frame_count: int) -> void:
	for _frame: int in frame_count:
		await process_frame


func _measure_frames(benchmark: Dictionary) -> Dictionary:
	var frame_count := int(benchmark.get("measured_frames", 0))
	var frame_times_ms: Array[float] = []
	var start_microseconds := Time.get_ticks_usec()
	for _frame: int in frame_count:
		var frame_start := Time.get_ticks_usec()
		await process_frame
		frame_times_ms.append(float(Time.get_ticks_usec() - frame_start) / 1000.0)
	var elapsed_seconds := float(Time.get_ticks_usec() - start_microseconds) / 1000000.0
	frame_times_ms.sort()
	var percentile := float(benchmark.get("percentile", 0.0))
	var percentile_index := clampi(
		int(floor(float(frame_times_ms.size() - 1) * percentile)),
		0,
		frame_times_ms.size() - 1
	)
	return {
		"fps": float(frame_count) / elapsed_seconds,
		"average_ms": elapsed_seconds * 1000.0 / float(frame_count),
		"p95_ms": frame_times_ms[percentile_index],
	}


func _measure_updates(manager: Node, benchmark: Dictionary) -> float:
	var iterations := int(benchmark.get("update_iterations", 0))
	var status_id := String(benchmark.get("update_status_id", ""))
	var start_microseconds := Time.get_ticks_usec()
	for _iteration: int in iterations:
		manager.apply_buildup(
			status_id,
			float(benchmark.get("update_amount", 0.0)),
			"benchmark"
		)
	return float(Time.get_ticks_usec() - start_microseconds) / float(iterations)
