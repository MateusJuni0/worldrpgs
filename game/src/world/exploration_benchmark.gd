extends SceneTree
## Sonda A/B no mundo completo: primeiro o Brumal actual, depois a gramática
## ramificada, o portão e quatro drops simultâneos.
##
##   godot --path game --rendering-method mobile \
##     --script res://src/world/exploration_benchmark.gd -- --capture

const ExplorationScript = preload("res://src/world/exploration_brumal.gd")
const GroundItemScript = preload("res://src/world/secrets_ground_item.gd")

var _capture := false


func _initialize() -> void:
	for argument: String in OS.get_cmdline_user_args():
		_capture = _capture or argument == "--capture"
	call_deferred("_run")


func _run() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_size(Vector2i(1920, 1080))
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	if DisplayServer.get_name() == "headless" or RenderingServer.get_video_adapter_name() == "":
		printerr("[EXPLORATION_BENCH_ERROR] renderer real obrigatório; não usar --headless")
		quit(2)
		return

	var scene := load("res://scenes/gameplay.tscn") as PackedScene
	if scene == null:
		printerr("[EXPLORATION_BENCH_ERROR] gameplay.tscn não carregou")
		quit(2)
		return
	var gameplay := scene.instantiate()
	root.add_child(gameplay)
	await _frames(180)
	var baseline := await _measure(420)

	var world := gameplay.get("world") as Node3D
	if world == null:
		printerr("[EXPLORATION_BENCH_ERROR] gameplay não expôs world")
		quit(2)
		return
	var options := _runtime_options()
	var exploration = ExplorationScript.new()
	world.add_child(exploration)
	if not exploration.build(options):
		printerr("[EXPLORATION_BENCH_ERROR] ExplorationBrumal não construiu")
		quit(2)
		return
	var anchors: Dictionary = exploration.secret_anchors()
	var drops: Array[Node3D] = []
	var drop_definitions := [
		["arma:dagger", anchors.get("hidden_item", Vector3.ZERO)],
		["material:limalha_ferro", Vector3(31.0, 0.55, -18.0)],
		["consumivel:resina_bruma", Vector3(-28.0, 0.55, -40.0)],
		["armadura:ferro_elmo", Vector3(-18.0, 0.55, -67.0)],
	]
	for definition: Array in drop_definitions:
		var drop = GroundItemScript.new()
		drop.position = definition[1] as Vector3
		world.add_child(drop)
		drop.configure(String(definition[0]), {
			"already_committed": true,
			"interaction_radius_m": options.get("interaction_radius_m", 2.6),
			"colour": options.get("pickup_colour", "#e6cf79"),
		})
		drops.append(drop)

	await _frames(120)
	var with_exploration := await _measure(420)
	with_exploration["structural_audit"] = exploration.audit()
	with_exploration["ground_items"] = drops.size()
	with_exploration["node_delta"] = int(with_exploration.get("node_count", 0)) \
		- int(baseline.get("node_count", 0))
	with_exploration["static_memory_delta_mib"] = float(
		with_exploration.get("static_memory_mib", 0.0)) \
		- float(baseline.get("static_memory_mib", 0.0))

	_set_rendered(exploration, drops, false)
	await _frames(90)
	var warmed_off := await _measure(420)
	_set_rendered(exploration, drops, true)
	await _frames(90)
	var warmed_on := await _measure(420)
	with_exploration["warmed_render_off"] = warmed_off
	with_exploration["warmed_render_on"] = warmed_on
	with_exploration["warmed_draw_delta"] = float(warmed_on.get("average_draw_calls", 0.0)) \
		- float(warmed_off.get("average_draw_calls", 0.0))

	var captures: Array[String] = []
	if _capture:
		captures = await _capture_views(gameplay, exploration)
	print("[EXPLORATION_BENCH] adapter=%s display=%s renderer=%s resolution=1920x1080 baseline=%s with_exploration=%s captures=%s" % [
		RenderingServer.get_video_adapter_name(),
		DisplayServer.get_name(),
		RenderingServer.get_current_rendering_method(),
		JSON.stringify(baseline), JSON.stringify(with_exploration), JSON.stringify(captures)])
	gameplay.queue_free()
	await _frames(3)
	quit()


func _runtime_options() -> Dictionary:
	var world_data := _load_json("res://data/world.json")
	var economy := _load_json("res://data/economy.json")
	var orientation: Dictionary = world_data.get("orientation_runtime", {}) as Dictionary
	var presentation: Dictionary = economy.get("loot_presentation", {}) as Dictionary
	return {
		"path_width_m": float(orientation.get("path_width_m", 6.0)),
		"interaction_radius_m": float(presentation.get("interaction_radius_m", 2.6)),
		"pickup_colour": String(presentation.get("pickup_colour", "#e6cf79")),
		"wood_colour": String(presentation.get("wood_colour", "#30261f")),
		"metal_colour": String(presentation.get("metal_colour", "#766b57")),
	}


func _load_json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


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
		"worst_ms": milliseconds[-1],
		"average_draw_calls": draw_sum / float(frame_count),
		"node_count": int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)),
		"static_memory_mib": Performance.get_monitor(Performance.MEMORY_STATIC) / 1048576.0,
	}


func _capture_views(gameplay: Node, exploration: Node3D) -> Array[String]:
	var camera := Camera3D.new()
	camera.fov = 67.0
	camera.near = 0.08
	gameplay.add_child(camera)
	camera.current = true
	var anchors: Dictionary = exploration.secret_anchors()
	var hidden_item: Vector3 = anchors.get("hidden_item", Vector3.ZERO) as Vector3
	var hidden_from: Vector3 = anchors.get("hidden_from", Vector3.ZERO) as Vector3
	var revealed_from: Vector3 = anchors.get("revealed_from", Vector3.ZERO) as Vector3
	var views := [
		["01-ramificacao", hidden_from + Vector3(0.0, 2.0, 15.0),
			hidden_from + Vector3(0.0, -0.4, -12.0)],
		["02-achado-oculto", hidden_from + Vector3.UP * 0.8, hidden_item + Vector3.UP * 0.8],
		["03-achado-revelado", revealed_from + Vector3.UP * 0.8,
			hidden_item + Vector3.UP * 0.8],
		["04-achado-silhueta", hidden_item + Vector3(5.0, 1.3, 8.0),
			hidden_item + Vector3.UP * 0.8],
		["05-atalho-fora-fechado", Vector3(1.0, 2.4, 96.0), Vector3(-7.0, 1.8, 87.0)],
	]
	var paths: Array[String] = []
	for view: Array in views:
		camera.look_at_from_position(view[1] as Vector3, view[2] as Vector3)
		await _frames(16)
		paths.append(_save_capture(String(view[0])))
	exploration.shortcut().open(false)
	camera.look_at_from_position(Vector3(-16.0, 2.4, 87.0), Vector3(-7.0, 1.8, 87.0))
	await _frames(16)
	paths.append(_save_capture("06-atalho-aberto-por-dentro"))
	return paths


func _set_rendered(exploration: Node3D, drops: Array[Node3D], rendered: bool) -> void:
	exploration.visible = rendered
	for drop: Node3D in drops:
		drop.visible = rendered
		drop.set_process(rendered)


func _save_capture(label: String) -> String:
	var directory := ProjectSettings.globalize_path("res://captures/exploration/")
	DirAccess.make_dir_recursive_absolute(directory)
	var path := directory + label + ".png"
	var texture := root.get_texture()
	if texture == null:
		return "ERRO:%s:sem_textura" % label
	var image := texture.get_image()
	if image == null:
		return "ERRO:%s:sem_imagem" % label
	var error := image.save_png(path)
	if error != OK:
		return "ERRO:%s:%d" % [label, error]
	return path


func _frames(count: int) -> void:
	for _frame: int in count:
		await process_frame


func _percentile(sorted: Array[float], fraction: float) -> float:
	var index := clampi(roundi((sorted.size() - 1) * fraction), 0, sorted.size() - 1)
	return sorted[index]
