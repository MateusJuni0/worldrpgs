extends SceneTree
## Sonda A/B da Lei 4: mesma zona e processo, primeiro sem baus e depois com
## os tres baus de Brumal. A captura vai para user:// e nunca para o repositorio.

const ChestManagerScript = preload("res://src/world/chest_manager.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_size(Vector2i(1920, 1080))
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	var scene := load("res://scenes/gameplay.tscn") as PackedScene
	var gameplay := scene.instantiate()
	root.add_child(gameplay)
	await _frames(180)
	var baseline := await _measure(420)

	var manager = ChestManagerScript.new()
	gameplay.add_child(manager)
	var configured: bool = manager.setup(gameplay.get("world") as Node3D,
		gameplay.get("player") as Node3D, gameplay.get("hud") as Node,
		"brumal")
	await _frames(120)
	var with_chests := await _measure(420)
	with_chests["configured"] = configured
	with_chests["chests"] = manager.chest_count()
	var capture_path := await _capture_chest(gameplay)
	print("[loot-render] adapter=%s resolution=1920x1080 baseline=%s with_chests=%s capture=%s" % [
		RenderingServer.get_video_adapter_name(), JSON.stringify(baseline),
		JSON.stringify(with_chests), capture_path])
	gameplay.queue_free()
	await _frames(3)
	quit()


func _measure(frame_count: int) -> Dictionary:
	var milliseconds: Array[float] = []
	var draw_sum := 0.0
	var started := Time.get_ticks_usec()
	for _frame: int in frame_count:
		var frame_started := Time.get_ticks_usec()
		await process_frame
		milliseconds.append(float(Time.get_ticks_usec() - frame_started) / 1000.0)
		draw_sum += RenderingServer.get_rendering_info(
			RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)
	var total_seconds := float(Time.get_ticks_usec() - started) / 1000000.0
	milliseconds.sort()
	return {
		"frames": frame_count,
		"average_fps": float(frame_count) / maxf(total_seconds, 0.001),
		"p95_ms": _percentile(milliseconds, 0.95),
		"p99_ms": _percentile(milliseconds, 0.99),
		"worst_ms": milliseconds[milliseconds.size() - 1],
		"average_draw_calls": draw_sum / float(frame_count),
		"node_count": int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)),
		"static_memory_mib": Performance.get_monitor(Performance.MEMORY_STATIC) \
			/ 1048576.0,
	}


func _capture_chest(gameplay: Node) -> String:
	var camera := Camera3D.new()
	gameplay.add_child(camera)
	var target := Vector3(-15.0, 0.75, 16.0)
	camera.global_position = target + Vector3(3.2, 2.1, 4.4)
	camera.look_at(target + Vector3.UP * 0.25)
	camera.current = true
	await _frames(6)
	var image := root.get_viewport().get_texture().get_image()
	var path := "user://loot-render-probe.png"
	image.save_png(path)
	return ProjectSettings.globalize_path(path)


func _frames(count: int) -> void:
	for _frame: int in count:
		await process_frame


func _percentile(sorted: Array[float], fraction: float) -> float:
	var index := clampi(roundi((sorted.size() - 1) * fraction), 0, sorted.size() - 1)
	return sorted[index]
