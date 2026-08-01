extends Control
## Renderizador 2D barato do mapa revelado. A textura base so muda quando o
## jogador descobre uma celula; posicao e direccao sao dois poligonos leves.

enum Mode { MINIMAP, FULL }

var mode := Mode.MINIMAP
var exploration: RefCounted
var player: Node3D
var partner: Node3D
var map_bounds := Rect2()
var path_points: Array[Vector3] = []
var landmarks: Array[Dictionary] = []
var config: Dictionary = {}
var north_up := false

var _map_texture: ImageTexture
var _map_image: Image
var _redraw_clock := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	set_process(true)


func set_context(p_exploration: RefCounted, p_player: Node3D, p_partner: Node3D,
		p_bounds: Rect2, p_paths: Array[Vector3], p_landmarks: Array[Dictionary],
		p_config: Dictionary) -> void:
	exploration = p_exploration
	player = p_player
	partner = p_partner
	map_bounds = p_bounds
	path_points = p_paths
	landmarks = p_landmarks
	config = p_config
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
	_map_image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	_map_image.fill(Color.TRANSPARENT)
	for cell_y: int in height:
		for cell_x: int in width:
			if not exploration.call("is_cell_revealed", cell_x, cell_y):
				continue
			_map_image.set_pixel(cell_x, cell_y, _cell_colour(Vector2i(cell_x, cell_y)))
	if _map_texture == null:
		_map_texture = ImageTexture.create_from_image(_map_image)
	else:
		_map_texture.update(_map_image)


func update_revealed_cells(cells: Array[Vector2i]) -> void:
	if _map_image == null or _map_texture == null:
		rebuild_texture()
		return
	for cell: Vector2i in cells:
		_map_image.set_pixel(cell.x, cell.y, _cell_colour(cell))
	_map_texture.update(_map_image)


func _cell_colour(cell: Vector2i) -> Color:
	var world_position: Vector3 = exploration.call("cell_center_world", cell)
	var cell_size: float = exploration.get("cell_size_m")
	var colour := Color("#c89a58") if _distance_to_path(world_position) <= cell_size * 1.2 \
		else Color("#8b877b")
	var variation := 0.92 + float((cell.x * 17 + cell.y * 31) % 9) * 0.012
	return Color(colour.r * variation, colour.g * variation,
		colour.b * variation, 0.94)


func _process(delta: float) -> void:
	_redraw_clock += delta
	if _redraw_clock >= 0.05:
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
	draw_rect(panel_rect, Color(0.025, 0.035, 0.04, 0.90), true)
	var centre := size * 0.5
	var range_m := float(config.get("minimap_range_m", 40.0))
	var pixels_per_m := minf(size.x, size.y) * sqrt(2.0) / maxf(range_m * 2.0, 1.0)
	var forward := _forward_2d()
	var heading := atan2(forward.x, -forward.y)
	var map_rotation := 0.0 if north_up else -heading

	draw_set_transform(centre, map_rotation, Vector2.ONE)
	var player_2d := Vector2(player.global_position.x, player.global_position.z)
	var texture_top_left := (map_bounds.position - player_2d) * pixels_per_m
	draw_texture_rect(_map_texture,
		Rect2(texture_top_left, map_bounds.size * pixels_per_m), false)
	_draw_landmarks_relative(player_2d, pixels_per_m, range_m)
	_draw_partner_relative(player_2d, pixels_per_m, range_m)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	var arrow_heading := heading if north_up else 0.0
	_draw_player_arrow(centre, arrow_heading, 1.0)
	draw_rect(panel_rect, Color(0.64, 0.57, 0.43, 0.88), false, 2.0)
	draw_string(ThemeDB.fallback_font, Vector2(10, 21),
		String(config.get("zone_label", "BRUMAL")), HORIZONTAL_ALIGNMENT_LEFT,
		-1.0, 14, Color(0.93, 0.88, 0.74))


func _draw_full_map() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.035, 0.039, 0.043, 0.98), true)
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

	for landmark: Dictionary in landmarks:
		if not exploration.call("is_landmark_discovered", String(landmark.get("id", ""))):
			continue
		var world_position: Vector3 = landmark.get("position", Vector3.ZERO)
		var point := origin + Vector2(
			(world_position.x - map_bounds.position.x) * pixels_per_m,
			(world_position.z - map_bounds.position.y) * pixels_per_m * tilt)
		_draw_landmark(point, landmark, true)

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


func _draw_landmarks_relative(player_2d: Vector2, pixels_per_m: float, range_m: float) -> void:
	for landmark: Dictionary in landmarks:
		if not exploration.call("is_landmark_discovered", String(landmark.get("id", ""))):
			continue
		var position_3d: Vector3 = landmark.get("position", Vector3.ZERO)
		var delta := Vector2(position_3d.x, position_3d.z) - player_2d
		if delta.length() > range_m:
			continue
		_draw_landmark(delta * pixels_per_m, landmark, false)


func _draw_partner_relative(player_2d: Vector2, pixels_per_m: float, range_m: float) -> void:
	if not is_instance_valid(partner):
		return
	var delta := Vector2(partner.global_position.x, partner.global_position.z) - player_2d
	if delta.length() > range_m:
		return
	draw_circle(delta * pixels_per_m, 6.0, Color("#79c6e8"))
	draw_circle(delta * pixels_per_m, 6.0, Color.WHITE, false, 1.5)


func _draw_landmark(point: Vector2, landmark: Dictionary, with_label: bool) -> void:
	var landmark_type := String(landmark.get("type", "place"))
	var colour := Color("#d7c49a")
	match landmark_type:
		"rest": colour = Color("#f1a84b")
		"lair": colour = Color("#b9a1d8")
		"arena": colour = Color("#d87864")
	var diamond := PackedVector2Array([
		point + Vector2(0, -7), point + Vector2(7, 0),
		point + Vector2(0, 7), point + Vector2(-7, 0)])
	draw_colored_polygon(diamond, colour)
	draw_polyline(PackedVector2Array([diamond[0], diamond[1], diamond[2], diamond[3], diamond[0]]),
		Color(0.08, 0.06, 0.04), 1.5)
	if with_label:
		draw_string(ThemeDB.fallback_font, point + Vector2(11, 5),
			String(landmark.get("name", "")), HORIZONTAL_ALIGNMENT_LEFT,
			-1.0, 16, Color(0.94, 0.91, 0.83))


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


func _distance_to_path(world_position: Vector3) -> float:
	var best := INF
	for index: int in path_points.size() - 1:
		var a := path_points[index]
		var b := path_points[index + 1]
		var ab := b - a
		var t := clampf((world_position - a).dot(ab) /
			maxf(ab.length_squared(), 0.001), 0.0, 1.0)
		best = minf(best, world_position.distance_to(a + ab * t))
	return best
