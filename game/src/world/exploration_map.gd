extends RefCounted
## Estado compacto da exploracao de uma zona.
##
## Uma celula e um bit. Brumal, com 220 x 220 m e celulas de 4 m, ocupa
## 55 x 55 = 3025 bits (379 bytes) antes de base64. O mapa nunca precisa de
## renderizar o mundo 3D outra vez para saber por onde o jogador passou.

const FORMAT := "bitset-base64-v1"

var zone_id := ""
var bounds := Rect2()
var cell_size_m := 4.0
var width := 0
var height := 0
var discovered_landmarks: Dictionary = {}
var last_revealed_cells: Array[Vector2i] = []

var _bits := PackedByteArray()
var _revealed_count := 0


func configure(p_zone_id: String, p_bounds: Rect2, p_cell_size_m: float) -> void:
	zone_id = p_zone_id
	bounds = p_bounds
	cell_size_m = maxf(p_cell_size_m, 0.25)
	width = maxi(1, ceili(bounds.size.x / cell_size_m))
	height = maxi(1, ceili(bounds.size.y / cell_size_m))
	_bits = PackedByteArray()
	_bits.resize(ceili(float(width * height) / 8.0))
	_bits.fill(0)
	_revealed_count = 0
	discovered_landmarks.clear()


func reveal(world_position: Vector3, radius_m: float) -> bool:
	last_revealed_cells.clear()
	if width <= 0 or height <= 0:
		return false
	var centre := world_to_cell(world_position)
	var cell_radius := ceili(maxf(radius_m, 0.0) / cell_size_m)
	var changed := false
	for cell_y: int in range(maxi(0, centre.y - cell_radius), mini(height, centre.y + cell_radius + 1)):
		for cell_x: int in range(maxi(0, centre.x - cell_radius), mini(width, centre.x + cell_radius + 1)):
			var cell_world := cell_center_world(Vector2i(cell_x, cell_y))
			var planar_distance := Vector2(
				cell_world.x - world_position.x, cell_world.z - world_position.z).length()
			if planar_distance <= radius_m and _set_revealed(cell_x, cell_y):
				changed = true
	return changed


func discover_landmark(landmark_id: String) -> bool:
	if landmark_id == "" or discovered_landmarks.has(landmark_id):
		return false
	discovered_landmarks[landmark_id] = true
	return true


func is_landmark_discovered(landmark_id: String) -> bool:
	return bool(discovered_landmarks.get(landmark_id, false))


func is_cell_revealed(cell_x: int, cell_y: int) -> bool:
	if cell_x < 0 or cell_x >= width or cell_y < 0 or cell_y >= height:
		return false
	var bit_index := cell_y * width + cell_x
	return (_bits[bit_index >> 3] & (1 << (bit_index & 7))) != 0


func is_world_revealed(world_position: Vector3) -> bool:
	var cell := world_to_cell(world_position)
	return is_cell_revealed(cell.x, cell.y)


func world_to_cell(world_position: Vector3) -> Vector2i:
	return Vector2i(
		floori((world_position.x - bounds.position.x) / cell_size_m),
		floori((world_position.z - bounds.position.y) / cell_size_m))


func cell_center_world(cell: Vector2i) -> Vector3:
	return Vector3(
		bounds.position.x + (float(cell.x) + 0.5) * cell_size_m,
		0.0,
		bounds.position.y + (float(cell.y) + 0.5) * cell_size_m)


func revealed_count() -> int:
	return _revealed_count


func revealed_fraction() -> float:
	return float(_revealed_count) / float(maxi(1, width * height))


func to_save_block() -> Dictionary:
	var landmark_ids: Array[String] = []
	for landmark_id: String in discovered_landmarks.keys():
		landmark_ids.append(landmark_id)
	landmark_ids.sort()
	return {
		"format": FORMAT,
		"zone_id": zone_id,
		"width": width,
		"height": height,
		"tiers": 1,
		"cell_size_m": cell_size_m,
		"origin_x": bounds.position.x,
		"origin_z": bounds.position.y,
		"data": Marshalls.raw_to_base64(_bits),
		"landmarks": landmark_ids,
	}


func load_save_block(block: Dictionary) -> bool:
	if String(block.get("format", "")) != FORMAT \
			or String(block.get("zone_id", "")) != zone_id \
			or int(block.get("width", 0)) != width \
			or int(block.get("height", 0)) != height \
			or not is_equal_approx(float(block.get("cell_size_m", 0.0)), cell_size_m):
		return false
	var decoded := Marshalls.base64_to_raw(String(block.get("data", "")))
	if decoded.size() != _bits.size():
		return false
	_bits = decoded
	_revealed_count = 0
	for cell_y: int in height:
		for cell_x: int in width:
			if is_cell_revealed(cell_x, cell_y):
				_revealed_count += 1
	discovered_landmarks.clear()
	for landmark_value: Variant in block.get("landmarks", []):
		var landmark_id := String(landmark_value)
		if landmark_id != "":
			discovered_landmarks[landmark_id] = true
	return true


func _set_revealed(cell_x: int, cell_y: int) -> bool:
	if is_cell_revealed(cell_x, cell_y):
		return false
	var bit_index := cell_y * width + cell_x
	var byte_index := bit_index >> 3
	_bits[byte_index] = _bits[byte_index] | (1 << (bit_index & 7))
	_revealed_count += 1
	last_revealed_cells.append(Vector2i(cell_x, cell_y))
	return true
