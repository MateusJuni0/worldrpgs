extends Control
## Renderizador 2D barato do mapa revelado. A textura base so muda quando o
## jogador descobre uma celula; posicao e direccao sao dois poligonos leves.

enum Mode { MINIMAP, FULL }

var mode := Mode.MINIMAP
var exploration: RefCounted
var player: Node3D
var partner: Node3D
var map_bounds := Rect2()
var path_segments: Array = []
var landmarks: Array[Dictionary] = []
var config: Dictionary = {}
var north_up := false

var _map_texture: ImageTexture
var _map_image: Image
var _cartography: Dictionary = {}
var _revealed_path_lines: Array[PackedVector3Array] = []
var _raster_scale := 1
var _redraw_clock := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	# A grelha guarda descoberta; nao e a linguagem visual. Filtragem linear
	# impede cada celula de 1,5 m de virar um quadrado gigante no HUD.
	texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	set_process(true)


func set_context(p_exploration: RefCounted, p_player: Node3D, p_partner: Node3D,
		p_bounds: Rect2, p_paths: Array, p_landmarks: Array[Dictionary],
		p_config: Dictionary) -> void:
	exploration = p_exploration
	player = p_player
	partner = p_partner
	map_bounds = p_bounds
	path_segments = p_paths
	landmarks = p_landmarks
	config = p_config
	_cartography = config.get("cartography", {}) as Dictionary
	_raster_scale = maxi(1, int(_cartography.get("raster_scale", 2)))
	rebuild_texture()
	queue_redraw()


func set_mode(p_mode: Mode) -> void:
	mode = p_mode
	queue_redraw()


func rebuild_texture() -> void:
	if exploration == null or int(exploration.get("width")) <= 0:
		return
	var width: int = exploration.get("width")
	var height: int = exploration.get("height")
	_map_image = Image.create(width * _raster_scale, height * _raster_scale,
		false, Image.FORMAT_RGBA8)
	_map_image.fill(Color.TRANSPARENT)
	for cell_y: int in height:
		for cell_x: int in width:
			if not exploration.call("is_cell_revealed", cell_x, cell_y):
				continue
			_paint_cell(Vector2i(cell_x, cell_y))
	_rebuild_revealed_paths()
	_paint_revealed_routes()
	if _map_texture == null:
		_map_texture = ImageTexture.create_from_image(_map_image)
	else:
		_map_texture.update(_map_image)


func update_revealed_cells(cells: Array[Vector2i]) -> void:
	if _map_image == null or _map_texture == null:
		rebuild_texture()
		return
	for cell: Vector2i in cells:
		_paint_cell(cell)
	_rebuild_revealed_paths()
	_paint_revealed_routes()
	_map_texture.update(_map_image)


func _paint_cell(cell: Vector2i) -> void:
	var colour := _cell_colour(cell)
	var start := cell * _raster_scale
	for pixel_y: int in range(start.y, start.y + _raster_scale):
		for pixel_x: int in range(start.x, start.x + _raster_scale):
			_map_image.set_pixel(pixel_x, pixel_y, colour)


func _cell_colour(cell: Vector2i) -> Color:
	var colour := _colour("explored_ground_color", Color("#777a72"))
	var variation := 0.94 + float((cell.x * 17 + cell.y * 31) % 7) * 0.01
	return Color(colour.r * variation, colour.g * variation,
		colour.b * variation, 0.88)


func _process(delta: float) -> void:
	_redraw_clock += delta
	var redraw_interval := 1.0 / maxf(float(_cartography.get("redraw_hz", 15.0)), 1.0)
	if _redraw_clock >= redraw_interval:
		_redraw_clock = 0.0
		queue_redraw()


func _draw() -> void:
	if not is_instance_valid(player) or exploration == null or _map_texture == null:
		return
	if mode == Mode.MINIMAP:
		_draw_minimap()
	else:
		_draw_full_map()


func _draw_minimap() -> void:
	var panel_rect := Rect2(Vector2.ZERO, size)
	draw_rect(panel_rect, _colour("background_color", Color("#080c0e")), true)
	var centre := size * 0.5
	var range_m := float(config.get("minimap_range_m", 40.0))
	var padding := float(_cartography.get("map_padding_px", 22.0))
	var pixels_per_m := maxf(1.0, (minf(size.x, size.y) * 0.5 - padding) /
		maxf(range_m, 1.0))
	var forward := _forward_2d()
	var heading := atan2(forward.x, -forward.y)
	var map_rotation := 0.0 if north_up else -heading

	draw_set_transform(centre, map_rotation, Vector2.ONE)
	var player_2d := Vector2(player.global_position.x, player.global_position.z)
	var texture_top_left := (map_bounds.position - player_2d) * pixels_per_m
	draw_texture_rect(_map_texture,
		Rect2(texture_top_left, map_bounds.size * pixels_per_m), false)
	_draw_partner_relative(player_2d, pixels_per_m, range_m)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	_draw_distance_ring(centre, pixels_per_m)
	_draw_minimap_landmarks(centre, player_2d, pixels_per_m, range_m, map_rotation)
	_draw_compass_ring(centre, map_rotation)
	var arrow_heading := heading if north_up else 0.0
	_draw_player_arrow(centre, arrow_heading, 1.0)
	_draw_scale_bar(pixels_per_m)
	draw_rect(panel_rect, _colour("frame_color", Color("#b7a47a")), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(10, 21),
		String(config.get("zone_label", "BRUMAL")), HORIZONTAL_ALIGNMENT_LEFT,
		-1.0, 14, _colour("text_color", Color("#f0ead9")))


func _draw_distance_ring(centre: Vector2, pixels_per_m: float) -> void:
	var distance_m := float(_cartography.get("distance_ring_m", 20.0))
	var radius := distance_m * pixels_per_m
	if radius > 0.0:
		draw_arc(centre, radius, 0.0, TAU, 64,
			_colour("grid_color", Color("#d9d0b81f")), 1.0, true)


func _draw_scale_bar(pixels_per_m: float) -> void:
	var distance_m := float(_cartography.get("scale_bar_m", 10.0))
	var length_px := distance_m * pixels_per_m
	var start := Vector2(15.0, size.y - 19.0)
	var finish := start + Vector2(length_px, 0.0)
	var colour := _colour("text_color", Color("#f0ead9"))
	draw_line(start, finish, colour, 2.0, true)
	draw_line(start + Vector2(0, -4), start + Vector2(0, 4), colour, 2.0, true)
	draw_line(finish + Vector2(0, -4), finish + Vector2(0, 4), colour, 2.0, true)
	draw_string(ThemeDB.fallback_font, start + Vector2(0, -7), "%d m" % int(distance_m),
		HORIZONTAL_ALIGNMENT_LEFT, length_px, 12, colour)


func _draw_compass_ring(centre: Vector2, map_rotation: float) -> void:
	var radius := minf(size.x, size.y) * 0.5 - 18.0
	var cardinals := [
		["N", Vector2(0, -1)], ["E", Vector2(1, 0)],
		["S", Vector2(0, 1)], ["O", Vector2(-1, 0)],
	]
	for cardinal: Array in cardinals:
		var direction: Vector2 = cardinal[1]
		var point := centre + direction.rotated(map_rotation) * radius
		var colour := Color("#f1c56f") if cardinal[0] == "N" else Color(0.82, 0.80, 0.72, 0.78)
		draw_circle(point, 10.0 if cardinal[0] == "N" else 8.0,
			Color(0.025, 0.035, 0.04, 0.86))
		draw_string(ThemeDB.fallback_font, point + Vector2(-10, 5), String(cardinal[0]),
			HORIZONTAL_ALIGNMENT_CENTER, 20.0, 13, colour)


func _draw_full_map() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), _colour("background_color", Color("#080c0e")), true)
	var projection_degrees := float(config.get("projection_degrees", 40.0))
	var tilt := maxf(0.55, sin(deg_to_rad(projection_degrees)))
	var usable := size - Vector2(150, 150)
	var pixels_per_m := minf(
		usable.x / maxf(map_bounds.size.x, 1.0),
		usable.y / maxf(map_bounds.size.y * tilt, 1.0))
	var drawn_size := Vector2(map_bounds.size.x * pixels_per_m,
		map_bounds.size.y * pixels_per_m * tilt)
	var origin := (size - drawn_size) * 0.5 + Vector2(0, 24)
	draw_texture_rect(_map_texture, Rect2(origin, drawn_size), false)

	var occupied_icons: Array[Vector2] = []
	var display_markers: Array[Dictionary] = []
	for landmark: Dictionary in landmarks:
		if not exploration.call("is_landmark_discovered", String(landmark.get("id", ""))):
			continue
		var world_position: Vector3 = landmark.get("position", Vector3.ZERO)
		var anchor := origin + Vector2(
			(world_position.x - map_bounds.position.x) * pixels_per_m,
			(world_position.z - map_bounds.position.y) * pixels_per_m * tilt)
		var point := _declutter_icon_point(anchor, occupied_icons)
		if not point.is_equal_approx(anchor):
			draw_line(anchor, point, _colour("frame_color", Color("#b7a47a")),
				1.0, true)
		_draw_landmark_icon(point, landmark)
		occupied_icons.append(point)
		display_markers.append({"point": point, "landmark": landmark})
	var occupied_labels: Array[Rect2] = []
	var icon_radius := float(_cartography.get("landmark_icon_size_px", 10.0)) + 3.0
	for icon_point: Vector2 in occupied_icons:
		occupied_labels.append(Rect2(icon_point - Vector2.ONE * icon_radius,
			Vector2.ONE * icon_radius * 2.0))
	for marker: Dictionary in display_markers:
		var landmark: Dictionary = marker.get("landmark", {}) as Dictionary
		var marker_point: Vector2 = marker.get("point", Vector2.ZERO)
		_draw_landmark_label(marker_point,
			String(landmark.get("name", "")), occupied_labels, 16)

	var player_point := origin + Vector2(
		(player.global_position.x - map_bounds.position.x) * pixels_per_m,
		(player.global_position.z - map_bounds.position.y) * pixels_per_m * tilt)
	var forward := _forward_2d()
	_draw_player_arrow(player_point, atan2(forward.x, -forward.y), 1.15)
	if is_instance_valid(partner):
		var partner_point := origin + Vector2(
			(partner.global_position.x - map_bounds.position.x) * pixels_per_m,
			(partner.global_position.z - map_bounds.position.y) * pixels_per_m * tilt)
		draw_circle(partner_point, 8.0, Color("#79c6e8"))
		draw_circle(partner_point, 8.0, Color.WHITE, false, 2.0)


func _draw_minimap_landmarks(centre: Vector2, player_2d: Vector2, pixels_per_m: float,
		range_m: float, map_rotation: float) -> void:
	var occupied_labels: Array[Rect2] = []
	for landmark: Dictionary in landmarks:
		if not exploration.call("is_landmark_discovered", String(landmark.get("id", ""))):
			continue
		var position_3d: Vector3 = landmark.get("position", Vector3.ZERO)
		var delta := Vector2(position_3d.x, position_3d.z) - player_2d
		if delta.length() > range_m:
			continue
		var point := centre + (delta * pixels_per_m).rotated(map_rotation)
		_draw_landmark_icon(point, landmark)
		if delta.length() <= float(_cartography.get("landmark_label_range_m", 24.0)):
			var style := _landmark_style(landmark)
			_draw_landmark_label(point, String(style.get("short_label", "")),
				occupied_labels, 12)


func _draw_partner_relative(player_2d: Vector2, pixels_per_m: float, range_m: float) -> void:
	if not is_instance_valid(partner):
		return
	var delta := Vector2(partner.global_position.x, partner.global_position.z) - player_2d
	if delta.length() > range_m:
		return
	draw_circle(delta * pixels_per_m, 6.0, Color("#79c6e8"))
	draw_circle(delta * pixels_per_m, 6.0, Color.WHITE, false, 1.5)


func _draw_landmark_icon(point: Vector2, landmark: Dictionary) -> void:
	var style := _landmark_style(landmark)
	var icon := String(style.get("icon", "diamond"))
	var colour := Color.from_string(String(style.get("color", "#d7c49a")),
		Color("#d7c49a"))
	var radius := float(_cartography.get("landmark_icon_size_px", 10.0))
	var ink := Color("#17110d")
	draw_circle(point, radius + 3.0, Color(0.02, 0.025, 0.025, 0.92))
	match icon:
		"flame":
			var flame := PackedVector2Array([
				point + Vector2(0, -radius),
				point + Vector2(radius * 0.72, -radius * 0.05),
				point + Vector2(radius * 0.48, radius * 0.78),
				point + Vector2(0, radius),
				point + Vector2(-radius * 0.62, radius * 0.55),
				point + Vector2(-radius * 0.7, -radius * 0.12),
				point + Vector2(-radius * 0.18, -radius * 0.48),
			])
			draw_colored_polygon(flame, colour)
			draw_polyline(_closed(flame), ink, 1.5, true)
			draw_circle(point + Vector2(0, radius * 0.36), radius * 0.28,
				Color("#fff0b3"))
		"gate":
			var gate := PackedVector2Array([
				point + Vector2(-radius * 0.78, radius),
				point + Vector2(-radius * 0.78, -radius * 0.25),
				point + Vector2(-radius * 0.48, -radius * 0.78),
				point + Vector2(0, -radius),
				point + Vector2(radius * 0.48, -radius * 0.78),
				point + Vector2(radius * 0.78, -radius * 0.25),
				point + Vector2(radius * 0.78, radius),
			])
			draw_polyline(gate, ink, 5.0, true)
			draw_polyline(gate, colour, 2.5, true)
			draw_line(point + Vector2(-radius, radius),
				point + Vector2(radius, radius), colour, 2.5, true)
		"crown":
			var crown := PackedVector2Array([
				point + Vector2(-radius, -radius * 0.48),
				point + Vector2(-radius * 0.48, radius * 0.05),
				point + Vector2(0, -radius),
				point + Vector2(radius * 0.48, radius * 0.05),
				point + Vector2(radius, -radius * 0.48),
				point + Vector2(radius * 0.76, radius * 0.78),
				point + Vector2(-radius * 0.76, radius * 0.78),
			])
			draw_colored_polygon(crown, colour)
			draw_polyline(_closed(crown), ink, 1.5, true)
			draw_line(point + Vector2(-radius * 0.72, radius * 0.42),
				point + Vector2(radius * 0.72, radius * 0.42), ink, 1.5, true)
		"tent":
			var tent := PackedVector2Array([
				point + Vector2(0, -radius),
				point + Vector2(radius, radius * 0.82),
				point + Vector2(-radius, radius * 0.82),
			])
			draw_colored_polygon(tent, colour)
			draw_polyline(_closed(tent), ink, 1.5, true)
			draw_line(point + Vector2(0, -radius * 0.72),
				point + Vector2(0, radius * 0.78), ink, 1.5, true)
		_:
			var diamond := PackedVector2Array([
				point + Vector2(0, -radius), point + Vector2(radius, 0),
				point + Vector2(0, radius), point + Vector2(-radius, 0)])
			draw_colored_polygon(diamond, colour)
			draw_polyline(_closed(diamond), ink, 1.5, true)


func _draw_landmark_label(point: Vector2, text: String, occupied: Array[Rect2],
		font_size: int) -> void:
	if text.is_empty():
		return
	var text_size := ThemeDB.fallback_font.get_string_size(text,
		HORIZONTAL_ALIGNMENT_LEFT, -1.0, font_size)
	var origin := point + Vector2(18.0, 5.0)
	var rect := Rect2(origin + Vector2(-3.0, -text_size.y + 1.0),
		text_size + Vector2(6.0, 4.0))
	var tries := 0
	while _intersects_any(rect, occupied) and tries < 6:
		origin.y += text_size.y + 4.0
		rect.position.y += text_size.y + 4.0
		tries += 1
	draw_rect(rect, Color(0.02, 0.025, 0.025, 0.82), true)
	draw_string(ThemeDB.fallback_font, origin, text, HORIZONTAL_ALIGNMENT_LEFT,
		-1.0, font_size, _colour("text_color", Color("#f0ead9")))
	occupied.append(rect)


func _intersects_any(rect: Rect2, occupied: Array[Rect2]) -> bool:
	for other: Rect2 in occupied:
		if rect.intersects(other):
			return true
	return false


func _declutter_icon_point(anchor: Vector2, occupied: Array[Vector2]) -> Vector2:
	var radius := float(_cartography.get("landmark_icon_size_px", 10.0))
	var step := radius * 2.8
	var candidates: Array[Vector2] = [
		anchor,
		anchor + Vector2(step, 0),
		anchor + Vector2(-step, 0),
		anchor + Vector2(step, step),
		anchor + Vector2(-step, step),
	]
	for candidate: Vector2 in candidates:
		var free := true
		for used: Vector2 in occupied:
			if candidate.distance_to(used) < step:
				free = false
				break
		if free:
			return candidate
	return candidates[candidates.size() - 1]


func _landmark_style(landmark: Dictionary) -> Dictionary:
	var styles := _cartography.get("landmark_styles", {}) as Dictionary
	return styles.get(String(landmark.get("type", "place")), {}) as Dictionary


func _closed(points: PackedVector2Array) -> PackedVector2Array:
	var result := points.duplicate()
	if not result.is_empty():
		result.append(result[0])
	return result


func _draw_player_arrow(point: Vector2, heading: float, scale_factor: float) -> void:
	var base := PackedVector2Array([
		Vector2(0, -12), Vector2(8, 8), Vector2(0, 4), Vector2(-8, 8)])
	var arrow := PackedVector2Array()
	for vertex: Vector2 in base:
		arrow.append(point + (vertex * scale_factor).rotated(heading))
	draw_colored_polygon(arrow, Color("#f5eee0"))
	draw_polyline(PackedVector2Array([arrow[0], arrow[1], arrow[2], arrow[3], arrow[0]]),
		Color("#3c2820"), 2.0)


func _forward_2d() -> Vector2:
	var forward_3d := -player.global_transform.basis.z
	var camera_value: Variant = player.get("camera")
	if camera_value != null and is_instance_valid(camera_value) \
			and camera_value.has_method("forward_flat"):
		forward_3d = camera_value.call("forward_flat")
	var forward := Vector2(forward_3d.x, forward_3d.z)
	return forward.normalized() if forward.length_squared() > 0.001 else Vector2(0, -1)


func _paint_revealed_routes() -> void:
	if _map_image == null or exploration == null:
		return
	var cell_size := float(exploration.get("cell_size_m"))
	var outline_radius := maxf(1.0,
		float(_cartography.get("route_outline_width_m", 2.5)) * 0.5 /
		cell_size * float(_raster_scale))
	var line_radius := maxf(0.65,
		float(_cartography.get("route_line_width_m", 1.5)) * 0.5 /
		cell_size * float(_raster_scale))
	var outline_colour := _colour("route_outline_color", Color("#35291c"))
	var route_colour := _colour("route_color", Color("#e3b868"))
	for world_line: PackedVector3Array in _revealed_path_lines:
		for world_point: Vector3 in world_line:
			_paint_disc(_world_to_raster(world_point), outline_radius, outline_colour)
	for world_line: PackedVector3Array in _revealed_path_lines:
		for world_point: Vector3 in world_line:
			_paint_disc(_world_to_raster(world_point), line_radius, route_colour)


func _world_to_raster(world_point: Vector3) -> Vector2:
	var cell_size := float(exploration.get("cell_size_m"))
	return Vector2(
		(world_point.x - map_bounds.position.x) / cell_size * float(_raster_scale),
		(world_point.z - map_bounds.position.y) / cell_size * float(_raster_scale))


func _paint_disc(centre: Vector2, radius: float, colour: Color) -> void:
	var min_x := maxi(0, floori(centre.x - radius))
	var max_x := mini(_map_image.get_width() - 1, ceili(centre.x + radius))
	var min_y := maxi(0, floori(centre.y - radius))
	var max_y := mini(_map_image.get_height() - 1, ceili(centre.y + radius))
	var radius_squared := radius * radius
	for pixel_y: int in range(min_y, max_y + 1):
		for pixel_x: int in range(min_x, max_x + 1):
			var offset := Vector2(float(pixel_x) + 0.5, float(pixel_y) + 0.5) - centre
			if offset.length_squared() <= radius_squared:
				_map_image.set_pixel(pixel_x, pixel_y, colour)


## Converte a topologia de autoria em linhas apenas onde o bitset diz que o
## jogador ja esteve. Assim a forma e continua sem transformar o mapa em GPS.
func _rebuild_revealed_paths() -> void:
	_revealed_path_lines.clear()
	if exploration == null:
		return
	var sample_step := maxf(float(exploration.get("cell_size_m")) * 0.5, 0.25)
	for segment_value: Variant in path_segments:
		var segment := segment_value as PackedVector3Array
		var visible_line := PackedVector3Array()
		for index: int in segment.size() - 1:
			var from := segment[index]
			var to := segment[index + 1]
			var steps := maxi(1, ceili(from.distance_to(to) / sample_step))
			for step: int in steps + 1:
				if index > 0 and step == 0:
					continue
				var point := from.lerp(to, float(step) / float(steps))
				if exploration.call("is_world_revealed", point):
					visible_line.append(point)
				elif visible_line.size() >= 2:
					_revealed_path_lines.append(visible_line)
					visible_line = PackedVector3Array()
				else:
					visible_line = PackedVector3Array()
		if visible_line.size() >= 2:
			_revealed_path_lines.append(visible_line)


func _colour(key: String, fallback: Color) -> Color:
	return Color.from_string(String(_cartography.get(key, fallback.to_html())), fallback)
