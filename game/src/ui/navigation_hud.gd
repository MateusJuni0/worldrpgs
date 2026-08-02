extends CanvasLayer
## Dono do minimapa e, nos blocos seguintes, do mapa grande e da persistencia.

const ExplorationMapScript = preload("res://src/world/exploration_map.gd")
const MapSurfaceScript = preload("res://src/ui/map_surface.gd")

var player: Node3D
var partner: Node3D
var world: Node3D
var zone_id := "brumal"
var minimap_enabled := true
var north_up := false

var _exploration: RefCounted
var _minimap_panel: Control
var _minimap_surface: Control
var _full_overlay: Control
var _full_surface: Control
var _full_title: Label
var _full_hint: Label
var _full_progress: Label
var _config: Dictionary = {}
var _update_clock := 0.0
var _map_open := false
var _paused_before_map := false
var _exploration_dirty := false
var _save_clock := 0.0
var _persistence_disabled := false
var _map_proof_requested := false


func _ready() -> void:
	layer = 54
	process_mode = Node.PROCESS_MODE_ALWAYS


func _exit_tree() -> void:
	_save_exploration()


func initialize(p_player: Node3D, p_partner: Node3D, p_world: Node3D,
		p_zone_id := "brumal") -> void:
	player = p_player
	partner = p_partner
	world = p_world
	zone_id = p_zone_id
	_config = ((GameData.world.get("map_reading", {}) as Dictionary).get(
		"runtime", {}) as Dictionary).duplicate(true)
	for argument: String in OS.get_cmdline_user_args():
		if argument == "--minimap=off":
			minimap_enabled = false
		elif argument == "--map-proof":
			_map_proof_requested = true
	var bounds_data: Dictionary = _config.get("zone_bounds_m", {}) as Dictionary
	var bounds := Rect2(
		Vector2(float(bounds_data.get("min_x", -110.0)), float(bounds_data.get("min_z", -110.0))),
		Vector2(float(bounds_data.get("size_x", 220.0)), float(bounds_data.get("size_z", 220.0))))
	_exploration = ExplorationMapScript.new()
	_exploration.call("configure", zone_id, bounds, float(_config.get("cell_size_m", 4.0)))
	_persistence_disabled = Bench.is_benchmarking() or "--photos" in OS.get_cmdline_user_args()
	_load_exploration_from_save()
	var terrain_changed: bool = _exploration.call("reveal", player.global_position,
		float(_config.get("reveal_radius_m", 7.0)))
	var landmarks_changed := _discover_nearby_landmarks()
	_exploration_dirty = terrain_changed or landmarks_changed
	_build_minimap(bounds)
	_build_full_map(bounds)
	set_minimap_enabled(minimap_enabled)
	if _map_proof_requested:
		_run_gameplay_map_proof.call_deferred()


func set_minimap_enabled(enabled: bool) -> void:
	minimap_enabled = enabled
	if _minimap_panel != null:
		_minimap_panel.visible = enabled and not _map_open
	if _minimap_surface != null:
		_minimap_surface.set_process(enabled and not _map_open)


func set_north_up(enabled: bool) -> void:
	north_up = enabled
	if _minimap_surface != null:
		_minimap_surface.set("north_up", north_up)
		_minimap_surface.queue_redraw()


func exploration_state() -> RefCounted:
	return _exploration


func is_full_map_open() -> bool:
	return _map_open


func show_full_map() -> void:
	if _map_open or _full_overlay == null:
		return
	_save_exploration()
	_map_open = true
	_paused_before_map = get_tree().paused
	get_tree().paused = true
	_full_overlay.visible = true
	_minimap_panel.visible = false
	_minimap_surface.set_process(false)
	_full_surface.set_process(true)
	_refresh_full_map_labels()
	_full_surface.call("rebuild_texture")
	_full_surface.queue_redraw()


func hide_full_map() -> void:
	if not _map_open:
		return
	_map_open = false
	_full_overlay.visible = false
	_minimap_panel.visible = minimap_enabled
	_full_surface.set_process(false)
	_minimap_surface.set_process(minimap_enabled)
	get_tree().paused = _paused_before_map


## So e usado pelo tour fotografico: simula um percurso ja feito para a captura
## provar o nevoeiro, sem oferecer esse conhecimento numa sessao normal.
func reveal_route_for_capture() -> void:
	if _exploration == null or not is_instance_valid(world):
		return
	var segments: Array = world.get("map_path_segments")
	for segment_value: Variant in segments:
		var points := segment_value as PackedVector3Array
		for index: int in points.size() - 1:
			var from := points[index]
			var to := points[index + 1]
			var steps := maxi(1, ceili(from.distance_to(to) / 2.0))
			for step: int in steps + 1:
				var at := from.lerp(to, float(step) / float(steps))
				_exploration.call("reveal", at, float(_config.get("reveal_radius_m", 7.0)))
	for landmark: Dictionary in world.get("map_landmarks"):
		var landmark_position: Vector3 = landmark.get("position", Vector3.ZERO)
		for segment_value: Variant in segments:
			for point: Vector3 in segment_value as PackedVector3Array:
				if point.distance_to(landmark_position) <= float(landmark.get("discover_radius_m", 12.0)):
					_exploration.call("discover_landmark", String(landmark.get("id", "")))
					break
	_refresh_surfaces(true, true)


## Prova jogavel: a cena real cria mundo/jogador/HUD; este piloto carrega nas
## mesmas acoes do jogador durante 30 s e valida os pixels finais do minimapa.
## So corre com --map-proof e nunca persiste porque o corredor usa Bench.
func _run_gameplay_map_proof() -> void:
	var cartography := _config.get("cartography", {}) as Dictionary
	var proof := cartography.get("proof", {}) as Dictionary
	var route := _map_proof_route()
	if route.is_empty() or not is_instance_valid(player):
		_finish_map_proof(false, {"reason": "rota ou jogador em falta"})
		return
	var walk_seconds := float(proof.get("walk_seconds", 30.0))
	var arrival_radius := float(proof.get("arrival_radius_m", 2.0))
	var elapsed := 0.0
	var walked_distance := 0.0
	var waypoint := 0
	var previous_position := player.global_position
	var stayed_alive := true
	Input.action_press("move_forward")
	Input.action_press("dodge_sprint")
	while elapsed < walk_seconds:
		while waypoint < route.size() \
				and _planar_distance(player.global_position, route[waypoint]) <= arrival_radius:
			waypoint += 1
		if waypoint < route.size():
			var direction := route[waypoint] - player.global_position
			direction.y = 0.0
			var camera_value: Variant = player.get("camera")
			if direction.length_squared() > 0.001 and is_instance_valid(camera_value):
				camera_value.set("_yaw", atan2(-direction.x, -direction.z))
		await get_tree().physics_frame
		var current_position := player.global_position
		walked_distance += _planar_distance(previous_position, current_position)
		previous_position = current_position
		elapsed += get_physics_process_delta_time()
		if player.has_method("is_alive") and not bool(player.call("is_alive")):
			stayed_alive = false
	Input.action_release("move_forward")
	Input.action_release("dodge_sprint")
	var visible_result := await _capture_map_proof(proof, cartography)
	visible_result["walked_seconds"] = snappedf(elapsed, 0.01)
	visible_result["walked_distance_m"] = snappedf(walked_distance, 0.1)
	visible_result["stayed_alive"] = stayed_alive
	visible_result["waypoints_reached"] = waypoint
	visible_result["waypoints_total"] = route.size()
	var passed := bool(visible_result.get("capture_ok", false)) \
		and walked_distance >= float(proof.get("min_walk_distance_m", 90.0)) \
		and stayed_alive \
		and int(visible_result.get("route_pixels", 0)) >= int(proof.get("min_route_pixels", 80)) \
		and int(visible_result.get("landmark_pixels", 0)) >= int(proof.get("min_landmark_pixels", 12)) \
		and int(visible_result.get("scale_pixels", 0)) >= int(proof.get("min_scale_pixels", 30))
	_finish_map_proof(passed, visible_result)


func _map_proof_route() -> Array[Vector3]:
	var result: Array[Vector3] = []
	if not is_instance_valid(world):
		return result
	var segments: Array = world.get("map_path_segments")
	if segments.is_empty():
		return result
	var spine := segments[0] as PackedVector3Array
	if spine.is_empty():
		return result
	var nearest_rest := Vector3.ZERO
	var nearest_rest_distance := INF
	for landmark: Dictionary in world.get("map_landmarks"):
		if String(landmark.get("type", "")) != "rest":
			continue
		var at: Vector3 = landmark.get("position", Vector3.ZERO)
		var distance := _planar_distance(player.global_position, at)
		if distance < nearest_rest_distance:
			nearest_rest = at
			nearest_rest_distance = distance
	var branch_index := -1
	if nearest_rest_distance < INF:
		var branch_distance := INF
		for index: int in spine.size():
			var distance := _planar_distance(spine[index], nearest_rest)
			if distance < branch_distance:
				branch_distance = distance
				branch_index = index
	for index: int in spine.size():
		result.append(spine[index])
		if index == branch_index:
			result.append(nearest_rest)
			result.append(spine[index])
	return result


func _capture_map_proof(proof: Dictionary, cartography: Dictionary) -> Dictionary:
	_minimap_surface.queue_redraw()
	await RenderingServer.frame_post_draw
	var frame := get_viewport().get_texture().get_image()
	var global_rect := _minimap_panel.get_global_rect()
	var requested := Rect2i(Vector2i(floori(global_rect.position.x),
		floori(global_rect.position.y)), Vector2i(ceili(global_rect.size.x),
		ceili(global_rect.size.y)))
	var available := Rect2i(Vector2i.ZERO, frame.get_size())
	var crop_rect := requested.intersection(available)
	if crop_rect.size.x <= 0 or crop_rect.size.y <= 0:
		return {"capture_ok": false, "reason": "rectangulo do minimapa vazio"}
	var minimap := frame.get_region(crop_rect)
	var capture_path := String(proof.get("capture_file",
		"res://captures/minimapa-30s.png"))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://captures"))
	var capture_error := minimap.save_png(capture_path)
	var tolerance := float(proof.get("color_tolerance", 0.16))
	var route_colour := Color.from_string(String(cartography.get("route_color", "#e3b868")),
		Color("#e3b868"))
	var landmark_styles := cartography.get("landmark_styles", {}) as Dictionary
	var rest_style := landmark_styles.get("rest", {}) as Dictionary
	var rest_colour := Color.from_string(String(rest_style.get("color", "#ffb44f")),
		Color("#ffb44f"))
	var text_colour := Color.from_string(String(cartography.get("text_color", "#f0ead9")),
		Color("#f0ead9"))
	var scale_region := Rect2i(0, maxi(0, minimap.get_height() - 42),
		mini(120, minimap.get_width()), mini(42, minimap.get_height()))
	return {
		"capture_ok": capture_error == OK,
		"capture": capture_path,
		"route_pixels": _count_colour_pixels(minimap, route_colour, tolerance),
		"landmark_pixels": _count_colour_pixels(minimap, rest_colour, tolerance),
		"scale_pixels": _count_colour_pixels(minimap, text_colour, tolerance, scale_region),
	}


func _count_colour_pixels(image: Image, target: Color, tolerance: float,
		region := Rect2i()) -> int:
	var sample := region
	if sample.size.x <= 0 or sample.size.y <= 0:
		sample = Rect2i(Vector2i.ZERO, image.get_size())
	var count := 0
	for y: int in range(sample.position.y, sample.end.y):
		for x: int in range(sample.position.x, sample.end.x):
			var pixel := image.get_pixel(x, y)
			if absf(pixel.r - target.r) <= tolerance \
					and absf(pixel.g - target.g) <= tolerance \
					and absf(pixel.b - target.b) <= tolerance:
				count += 1
	return count


func _planar_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()


func _finish_map_proof(passed: bool, result: Dictionary) -> void:
	print("[MAP_PROOF] %s %s" % ["PASS" if passed else "FAIL", JSON.stringify(result)])
	get_tree().quit(0 if passed else 1)


func _build_minimap(bounds: Rect2) -> void:
	var cartography := _config.get("cartography", {}) as Dictionary
	var minimap_size := float(cartography.get("minimap_size_px", 304.0))
	var screen_margin := float(cartography.get("screen_margin_px", 30.0))
	_minimap_panel = Control.new()
	_minimap_panel.name = "Minimapa"
	_minimap_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_minimap_panel.offset_left = -(screen_margin + minimap_size)
	_minimap_panel.offset_top = screen_margin
	_minimap_panel.offset_right = -screen_margin
	_minimap_panel.offset_bottom = screen_margin + minimap_size
	_minimap_panel.clip_contents = true
	_minimap_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_minimap_panel)

	_minimap_surface = MapSurfaceScript.new()
	_minimap_surface.name = "Superficie"
	_minimap_surface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_minimap_surface.offset_left = 5.0
	_minimap_surface.offset_top = 5.0
	_minimap_surface.offset_right = -5.0
	_minimap_surface.offset_bottom = -5.0
	_minimap_panel.add_child(_minimap_surface)
	_minimap_surface.call("set_context", _exploration, player, partner, bounds,
		world.get("map_path_segments"), world.get("map_landmarks"), _config)
	_minimap_surface.set("north_up", north_up)


func _build_full_map(bounds: Rect2) -> void:
	_full_overlay = Control.new()
	_full_overlay.name = "MapaGrande"
	_full_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_full_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_full_overlay.visible = false
	add_child(_full_overlay)

	_full_surface = MapSurfaceScript.new()
	_full_surface.name = "Superficie"
	_full_surface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_full_surface.call("set_mode", 1)
	_full_overlay.add_child(_full_surface)
	_full_surface.call("set_context", _exploration, player, partner, bounds,
		world.get("map_path_segments"), world.get("map_landmarks"), _config)
	_full_surface.set_process(false)

	_full_title = _map_label(28, HORIZONTAL_ALIGNMENT_CENTER)
	_full_title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_full_title.offset_top = 34.0
	_full_title.offset_bottom = 78.0
	_full_overlay.add_child(_full_title)

	_full_progress = _map_label(17, HORIZONTAL_ALIGNMENT_RIGHT)
	_full_progress.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_full_progress.offset_left = -300.0
	_full_progress.offset_top = 34.0
	_full_progress.offset_right = -34.0
	_full_progress.offset_bottom = 70.0
	_full_overlay.add_child(_full_progress)

	_full_hint = _map_label(17, HORIZONTAL_ALIGNMENT_CENTER)
	_full_hint.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_full_hint.offset_top = -58.0
	_full_hint.offset_bottom = -24.0
	_full_overlay.add_child(_full_hint)


func _map_label(font_size: int, alignment: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.horizontal_alignment = alignment
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(0.94, 0.91, 0.83))
	label.add_theme_color_override("font_outline_color", Color(0.02, 0.02, 0.02, 0.95))
	label.add_theme_constant_override("outline_size", 4)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _refresh_full_map_labels() -> void:
	var zone_name := String(GameData.world_zone(zone_id).get("nome", zone_id)).to_upper()
	_full_title.text = GameData.ui_text("map.title", "MAPA DE %s") % zone_name
	_full_hint.text = GameData.ui_text("map.close_hint", "%s — fechar mapa") % \
		_action_label("open_map")
	_full_progress.text = GameData.ui_text("map.explored", "Percorrido: %.1f%%") % \
		(float(_exploration.call("revealed_fraction")) * 100.0)


func _action_label(action_name: String) -> String:
	for event: InputEvent in InputMap.action_get_events(action_name):
		if event is InputEventKey:
			var key := event as InputEventKey
			var code := key.physical_keycode if key.physical_keycode != KEY_NONE else key.keycode
			return OS.get_keycode_string(code)
		return event.as_text()
	return action_name


func _unhandled_input(event: InputEvent) -> void:
	if InputMap.has_action("open_map") and event.is_action_pressed("open_map"):
		if _map_open:
			hide_full_map()
		else:
			show_full_map()
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if _exploration == null or not is_instance_valid(player):
		return
	if _exploration_dirty and not _persistence_disabled:
		_save_clock += delta
		if _save_clock >= float(_config.get("save_debounce_s", 4.0)):
			_save_exploration()
	if _map_open:
		return
	_update_clock += delta
	var interval := 1.0 / maxf(float(_config.get("update_hz", 10.0)), 1.0)
	if _update_clock < interval:
		return
	_update_clock = 0.0
	var terrain_changed: bool = _exploration.call("reveal", player.global_position,
		float(_config.get("reveal_radius_m", 7.0)))
	var changed := _discover_nearby_landmarks() or terrain_changed
	if changed:
		_exploration_dirty = true
		_refresh_surfaces(terrain_changed)


func _refresh_surfaces(terrain_changed: bool, full_rebuild := false) -> void:
	for surface: Control in [_minimap_surface, _full_surface]:
		if surface == null:
			continue
		# O mapa grande recompõe a textura ao abrir; actualizar a cópia invisível
		# a cada passo duplicava largura de banda sem produzir um pixel no ecrã.
		if surface == _full_surface and not _map_open and not full_rebuild:
			continue
		if full_rebuild:
			surface.call("rebuild_texture")
		elif terrain_changed:
			surface.call("update_revealed_cells",
				_exploration.get("last_revealed_cells"))
		surface.queue_redraw()


func _discover_nearby_landmarks() -> bool:
	if not is_instance_valid(world) or not is_instance_valid(player):
		return false
	var changed := false
	for landmark: Dictionary in world.get("map_landmarks"):
		var at: Vector3 = landmark.get("position", Vector3.ZERO)
		if player.global_position.distance_to(at) <= float(landmark.get("discover_radius_m", 12.0)):
			changed = _exploration.call("discover_landmark",
				String(landmark.get("id", ""))) or changed
	return changed


func _load_exploration_from_save() -> void:
	var snapshot := GameData.save_state_snapshot()
	var world_state: Dictionary = snapshot.get("world", {}) as Dictionary
	var map_state: Dictionary = world_state.get("map", {}) as Dictionary
	var zones: Dictionary = map_state.get("exploration", {}) as Dictionary
	var block: Dictionary = zones.get(zone_id, {}) as Dictionary
	if not block.is_empty():
		_exploration.call("load_save_block", block)


## Publica o bitset dentro do save atómico existente. O estado em memória volta
## ao snapshot anterior se a escrita falhar, tal como as recompensas de combate.
func _save_exploration() -> bool:
	if not _exploration_dirty or _persistence_disabled:
		return true
	var before := GameData.save_state_snapshot()
	if before.is_empty():
		return false
	var working := before.duplicate(true)
	var world_state: Dictionary = working.get("world", {}) as Dictionary
	var map_state: Dictionary = world_state.get("map", {}) as Dictionary
	var zones: Dictionary = map_state.get("exploration", {}) as Dictionary
	zones[zone_id] = _exploration.call("to_save_block")
	map_state["exploration"] = zones
	world_state["map"] = map_state
	working["world"] = world_state
	GameData.replace_save_state(working)
	if not SaveSystem.save_current():
		GameData.replace_save_state(before)
		_save_clock = 0.0
		return false
	_exploration_dirty = false
	_save_clock = 0.0
	return true
