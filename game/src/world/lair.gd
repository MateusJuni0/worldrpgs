class_name Lair
extends Node3D
## A Toca da Fatia 1: modulo independente, navegavel e barato de desenhar.
##
## A arquitectura ensina o percurso. Arcos altos e luz ambar marcam a rota
## principal; mudancas de eixo escondem a sala seguinte; corredores baixos e
## luz fria marcam desvios. Duas grades so abrem a partir do lado interior e
## transformam a descida longa num regresso curto ao chefe.
##
## Lei 4: cada sector agrupa copias do mesmo KayKit num MultiMesh e so mantem
## visiveis o sector da camara e os seus vizinhos. Colisoes simples continuam
## activas, mesmo quando paredes que ja nao podem ser vistas ficam ocultas.

signal shortcut_opened(shortcut_id: StringName)

const ASSET_ROOT := "res://assets/models/dungeon/"
const MODULE := 4.0
const WALL_HEIGHT := 4.0
const MAIN_ROUTE := [
	Vector3(0.0, 0.0, 8.0), Vector3(0.0, 0.0, -2.0),
	Vector3(0.0, -3.0, -14.0), Vector3(0.0, -3.0, -21.0),
	Vector3(-10.0, -3.0, -25.0), Vector3(-10.0, -5.0, -39.0),
	Vector3(6.0, -5.0, -39.0), Vector3(2.0, -6.5, -52.0),
	Vector3(-2.0, -6.5, -62.0), Vector3(-2.0, -7.8, -76.0),
	Vector3(-2.0, -7.8, -84.0),
]
const BOSS_RETURN_ROUTE := [
	Vector3(0.0, 0.0, 5.0), Vector3(8.0, 0.0, -2.0),
	Vector3(10.0, -1.0, -8.0), Vector3(10.0, -6.5, -54.0),
	Vector3(6.0, -6.5, -54.0), Vector3(-2.0, -6.5, -62.0),
	Vector3(-2.0, -7.8, -76.0),
]
const SECTOR_LINKS := {
	"landmark": ["descent", "boss_return"],
	"descent": ["landmark", "room_1"],
	"room_1": ["descent", "main_bend", "mid_loop"],
	"main_bend": ["room_1", "room_2"],
	"room_2": ["main_bend", "mid_loop", "room_3"],
	"mid_loop": ["room_1", "room_2"],
	"room_3": ["room_2", "boss_return", "arena"],
	"boss_return": ["room_3", "landmark"],
	"arena": ["room_3"],
}

var entrance_anchor := Vector3(0.0, 0.2, 8.0)
var rest_anchor := Vector3(0.0, 0.2, 5.0)
var arena_center := Vector3(-2.0, -7.8, -84.0)
var boss_door_anchor := Vector3(-2.0, -7.6, -76.0)
var landmark_sightline_anchor := Vector3(0.0, 6.0, 0.0)
var shortcut_exit_anchor := Vector3(8.0, 0.2, -2.0)

var _built := false
var _cast_shadows := false
var _sector_nodes: Dictionary = {}
var _sector_centres: Dictionary = {}
var _batches: Dictionary = {}
var _mesh_cache: Dictionary = {}
var _used_assets: Dictionary = {}
var _static_body: StaticBody3D
var _shortcut_gates: Dictionary = {}
var _shortcut_open: Dictionary = {}
var _enemy_markers: Array[Marker3D] = []
var _active_sector := ""
var _flame_mesh: SphereMesh
var _flame_material: StandardMaterial3D


func build(options: Dictionary = {}) -> void:
	if _built:
		push_warning("Lair.build() ignorado: a Toca ja foi construida")
		return
	_built = true
	_cast_shadows = bool(options.get("shadows", false))

	_static_body = StaticBody3D.new()
	_static_body.name = "LairCollision"
	_static_body.collision_layer = 1
	_static_body.collision_mask = 0
	add_child(_static_body)
	_prepare_shared_light_resources()
	_create_sectors()

	_build_landmark()
	_build_descent()
	_build_room_1()
	_build_main_bend()
	_build_room_2()
	_build_mid_loop()
	_build_room_3()
	_build_boss_return()
	_build_arena()
	_flush_all_batches()
	_build_shortcuts()
	_build_encounter_markers()
	_set_visible_sectors(["landmark", "descent", "boss_return"])
	set_process(true)


func open_shortcut(shortcut_id: StringName, animated := true) -> bool:
	if not _shortcut_gates.has(shortcut_id) or bool(_shortcut_open.get(shortcut_id, false)):
		return false
	_shortcut_open[shortcut_id] = true
	var gate := _shortcut_gates[shortcut_id] as StaticBody3D
	gate.collision_layer = 0
	gate.collision_mask = 0
	if animated and is_inside_tree():
		var tween := create_tween()
		tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(gate, "position:y", gate.position.y + 3.4, 0.7)
		tween.tween_callback(gate.hide)
	else:
		gate.position.y += 3.4
		gate.hide()
	shortcut_opened.emit(shortcut_id)
	return true


func set_shortcut_open(shortcut_id: StringName, is_open: bool) -> void:
	## Ponto de integracao do save: atalhos fechados nunca sao repostos a meio
	## de uma instancia, mas um save pode materializa-los ja abertos.
	if is_open:
		open_shortcut(shortcut_id, false)


func is_shortcut_open(shortcut_id: StringName) -> bool:
	return bool(_shortcut_open.get(shortcut_id, false))


func get_enemy_markers() -> Array[Marker3D]:
	return _enemy_markers.duplicate()


func audit() -> Dictionary:
	var multimeshes := 0
	var visible_instances := 0
	for sector_node: Variant in _sector_nodes.values():
		for child: Node in (sector_node as Node).get_children():
			if child is MultiMeshInstance3D:
				multimeshes += 1
				var multimesh := (child as MultiMeshInstance3D).multimesh
				visible_instances += multimesh.instance_count if multimesh != null else 0
	return {
		"sectors": _sector_nodes.size(),
		"kaykit_assets": _used_assets.size(),
		"multimeshes": multimeshes,
		"module_instances": visible_instances,
		"collision_shapes": _static_body.get_child_count(),
		"enemy_markers": _enemy_markers.size(),
		"shortcuts": _shortcut_gates.size(),
		"main_route_length_m": snappedf(_polyline_length(MAIN_ROUTE), 0.1),
		"boss_return_length_m": snappedf(_polyline_length(BOSS_RETURN_ROUTE), 0.1),
		"boss_floor_clear_radius_m": 6.5,
		"ceiling_minimum_m": WALL_HEIGHT,
	}


func _polyline_length(points: Array) -> float:
	var result := 0.0
	for index: int in points.size() - 1:
		result += (points[index] as Vector3).distance_to(points[index + 1] as Vector3)
	return result


func _process(_delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	_update_sector_visibility(to_local(camera.global_position))


# --- Sectores e leitura -------------------------------------------------------

func _create_sectors() -> void:
	_create_sector("landmark", Vector3(0.0, 1.0, 3.0))
	_create_sector("descent", Vector3(0.0, -1.5, -9.0))
	_create_sector("room_1", Vector3(0.0, -3.0, -21.0))
	_create_sector("main_bend", Vector3(-10.0, -4.0, -33.0))
	_create_sector("room_2", Vector3(6.0, -5.0, -39.0))
	_create_sector("mid_loop", Vector3(12.0, -4.0, -30.0))
	_create_sector("room_3", Vector3(-2.0, -6.5, -62.0))
	_create_sector("boss_return", Vector3(10.0, -3.5, -30.0))
	_create_sector("arena", arena_center)


func _create_sector(sector_id: String, centre: Vector3) -> void:
	var sector := Node3D.new()
	sector.name = "Sector_%s" % sector_id
	add_child(sector)
	_sector_nodes[sector_id] = sector
	_sector_centres[sector_id] = centre
	_batches[sector_id] = {}


func _update_sector_visibility(camera_local: Vector3) -> void:
	var nearest := "landmark"
	var nearest_distance := INF
	for sector_id: Variant in _sector_centres:
		var centre: Vector3 = _sector_centres[sector_id]
		var distance := camera_local.distance_squared_to(centre)
		if distance < nearest_distance:
			nearest = String(sector_id)
			nearest_distance = distance
	if nearest_distance > 45.0 * 45.0:
		nearest = "landmark"
	if nearest == _active_sector:
		return
	_active_sector = nearest
	var visible_ids: Array = [nearest]
	visible_ids.append_array(SECTOR_LINKS.get(nearest, []))
	_set_visible_sectors(visible_ids)


func _set_visible_sectors(visible_ids: Array) -> void:
	for sector_id: Variant in _sector_nodes:
		(_sector_nodes[sector_id] as Node3D).visible = visible_ids.has(String(sector_id))


# --- Layout ------------------------------------------------------------------

func _build_landmark() -> void:
	# O arco partido e os dois pilares chegam aos 8 m: veem-se antes da fenda.
	_add_floor_grid("landmark", Vector3(0.0, 0.0, 5.0), 5, 4, false)
	for x: float in [-8.0, -4.0, 4.0, 8.0]:
		var asset := "wall_broken" if absf(x) > 4.0 else "wall_cracked"
		_place("landmark", asset, Vector3(x, 0.0, 0.0))
		_add_box_collision(Vector3(x, 2.0, 0.0), Vector3(3.9, 4.0, 0.7))
	_place("landmark", "wall_doorway", Vector3(0.0, 0.0, 0.0), Vector3.ZERO,
		Vector3(1.25, 1.55, 1.0))
	for x: float in [-4.2, 4.2]:
		_place("landmark", "pillar_decorated", Vector3(x, 0.0, 0.25), Vector3.ZERO,
			Vector3(1.35, 2.0, 1.35))
		_place("landmark", "banner_brown", Vector3(x, 5.1, 0.5), Vector3(0.0, 0.0, 0.0),
			Vector3(1.25, 1.25, 1.25))
	_add_torch("landmark", Vector3(-2.2, 2.0, 0.65), 0.0, 12.0)
	_add_torch("landmark", Vector3(2.2, 2.0, 0.65), 0.0, 12.0)
	for at: Vector3 in [Vector3(-8.0, 0.05, 2.5), Vector3(8.0, 0.05, 1.5),
			Vector3(-5.5, 0.05, -1.0), Vector3(6.0, 0.05, -1.5)]:
		_place("landmark", "rubble_large", at, Vector3(0.0, at.x * 0.11, 0.0),
			Vector3.ONE * 0.72)


func _build_descent() -> void:
	_add_corridor("descent", Vector3(0.0, 0.0, -2.0), Vector3(0.0, -3.0, -14.0), 4.0)
	# O piso inclinado e a colisao simples fazem a descida. Uma escada longa
	# sobreposta parecia correcta de fora, mas atravessava a camara a altura do
	# jogador; os mosaicos em rampa conservam a leitura sem esse volume falso.
	_add_torch("descent", Vector3(-1.7, 1.0, -5.0), PI * 0.5, 8.0)
	_add_torch("descent", Vector3(1.7, -1.0, -12.0), -PI * 0.5, 8.0)
	_add_corridor("descent", Vector3(0.0, -3.0, -14.0), Vector3(-2.0, -3.0, -15.0), 4.0)


func _build_room_1() -> void:
	# 16 x 12 m: a sala da descida, ainda iluminada pela entrada.
	_add_room("room_1", Vector3(0.0, -3.0, -21.0), 4, 3, {
		"north": [1], "west": [0], "east": [0],
	})
	_frame_route("room_1", Vector3(-8.0, -3.0, -25.0), PI * 0.5)
	# A saida directa a leste e a primeira grade: ve-se cedo, usa-se tarde.
	_place("room_1", "keyring_hanging", Vector3(7.65, -1.2, -24.8),
		Vector3(0.0, -PI * 0.5, 0.0), Vector3.ONE * 1.2)
	_place("room_1", "box_stacked", Vector3(5.4, -2.95, -17.8),
		Vector3(0.0, -0.5, 0.0), Vector3.ONE * 0.72)
	_place("room_1", "rubble_half", Vector3(-5.2, -2.95, -18.0),
		Vector3(0.0, 0.4, 0.0), Vector3.ONE * 0.65)


func _build_main_bend() -> void:
	# O cotovelo impede que a primeira sala revele a segunda e cria antecipacao.
	_add_corridor("main_bend", Vector3(-10.0, -3.0, -25.0),
		Vector3(-10.0, -5.0, -39.0), 4.0)
	_add_corridor("main_bend", Vector3(-10.0, -5.0, -39.0),
		Vector3(-4.0, -5.0, -39.0), 4.0)
	_add_torch("main_bend", Vector3(-8.2, -1.3, -35.0), -PI * 0.5, 8.0)
	_place("main_bend", "wall_half", Vector3(-10.0, -5.0, -32.0),
		Vector3(0.0, PI * 0.5, 0.0))


func _build_room_2() -> void:
	# 20 x 12 m: paredes laterais escondem a emboscada, mas a pedra rachada e
	# o escudo partido avisam que ha espaco ocupado para la dos pilares.
	_add_room("room_2", Vector3(6.0, -5.0, -39.0), 5, 3, {
		"west": [1], "east": [2], "south": [1],
	})
	for x: float in [2.0, 10.0]:
		_place("room_2", "pillar", Vector3(x, -5.0, -39.0), Vector3.ZERO,
			Vector3(0.85, 1.0, 0.85))
	_place("room_2", "sword_shield_broken", Vector3(5.2, -4.92, -35.5),
		Vector3(0.0, -0.8, 0.0), Vector3.ONE * 0.9)
	_place("room_2", "barrel_large_decorated", Vector3(12.8, -4.95, -42.4),
		Vector3(0.0, 0.35, 0.0), Vector3.ONE * 0.8)
	_frame_route("room_2", Vector3(2.0, -5.0, -45.0), 0.0)
	_add_torch("room_2", Vector3(0.4, -3.0, -43.8), PI, 9.0)
	_add_torch("room_2", Vector3(3.6, -3.0, -43.8), PI, 9.0)


func _build_mid_loop() -> void:
	_add_corridor("mid_loop", Vector3(10.0, -3.0, -25.0),
		Vector3(16.0, -5.0, -35.0), 4.0)
	_place("mid_loop", "floor_tile_small_broken_A", Vector3(13.4, -4.0, -30.5),
		Vector3(0.0, -0.55, 0.0), Vector3.ONE * 0.8)
	_add_torch("mid_loop", Vector3(14.3, -2.4, -32.4), -0.55, 7.0)


func _build_room_3() -> void:
	# 12 x 20 m: sala de guarda. A escala alonga-se na direccao do arco do
	# chefe; a simetria e os pendões substituem qualquer seta ou tutorial.
	_add_room("room_3", Vector3(-2.0, -6.5, -62.0), 3, 5, {
		"north": [2], "south": [1], "east": [4],
	})
	for z: float in [-67.5, -60.0, -54.5]:
		_add_torch("room_3", Vector3(-7.7, -4.5, z), PI * 0.5, 8.0)
		_add_torch("room_3", Vector3(3.7, -4.5, z), -PI * 0.5, 8.0)
	for x: float in [-4.8, 0.8]:
		_place("room_3", "banner_patternC_brown", Vector3(x, -3.0, -71.65),
			Vector3(0.0, PI, 0.0), Vector3.ONE * 1.1)
	_frame_route("room_3", Vector3(-2.0, -6.5, -72.0), 0.0)
	_place("room_3", "crates_stacked", Vector3(-5.0, -6.45, -55.0),
		Vector3(0.0, 0.6, 0.0), Vector3.ONE * 0.65)


func _build_boss_return() -> void:
	# Passagem de servico: da sala de guarda regressa directamente a entrada.
	_add_corridor("boss_return", Vector3(6.0, -6.5, -54.0),
		Vector3(10.0, -6.5, -54.0), 4.0)
	_add_corridor("boss_return", Vector3(10.0, -6.5, -54.0),
		Vector3(10.0, -1.0, -8.0), 4.0)
	_add_corridor("boss_return", Vector3(10.0, -1.0, -8.0),
		Vector3(8.0, 0.0, -2.0), 4.0)
	for z: float in [-48.0, -32.0, -16.0]:
		_add_torch("boss_return", Vector3(8.25, lerpf(-5.8, -1.3,
			inverse_lerp(-48.0, -16.0, z)), z), PI * 0.5, 7.0)
	_place("boss_return", "rubble_half", Vector3(11.3, -4.0, -34.0),
		Vector3(0.0, PI * 0.5, 0.0), Vector3.ONE * 0.58)


func _build_arena() -> void:
	# 20 x 16 m exactos. Aderecos ficam para la do raio de 6,5 m: o combate
	# conserva silhuetas limpas e nao perde justiça por colisao decorativa.
	_add_room("arena", arena_center, 5, 4, {"north": [2]}, 1.5)
	for x: float in [-9.2, 5.2]:
		for z: float in [-89.5, -78.5]:
			_place("arena", "pillar_decorated", Vector3(x, -7.8, z), Vector3.ZERO,
				Vector3(1.05, 1.5, 1.05))
	for x: float in [-6.0, 2.0]:
		_place("arena", "banner_brown", Vector3(x, -3.6, -91.7),
			Vector3(0.0, PI, 0.0), Vector3(1.2, 1.35, 1.2))
	for at: Vector3 in [
		Vector3(-9.6, -5.2, -89.0), Vector3(5.6, -5.2, -89.0),
		Vector3(-9.6, -5.2, -79.0), Vector3(5.6, -5.2, -79.0),
		Vector3(-7.0, -5.2, -91.5), Vector3(3.0, -5.2, -91.5),
	]:
		_add_torch("arena", at, 0.0, 10.0)
	for at: Vector3 in [Vector3(-10.2, -7.72, -86.0), Vector3(6.1, -7.72, -82.0),
			Vector3(-7.8, -7.72, -77.7), Vector3(4.8, -7.72, -90.4)]:
		_place("arena", "rubble_large", at, Vector3(0.0, at.z * 0.09, 0.0),
			Vector3.ONE * 0.62)
	_place("arena", "wall_gated", Vector3(-2.0, -7.8, -92.0), Vector3(0.0, PI, 0.0),
		Vector3(1.25, 1.5, 1.0))


# --- Modulos estruturais -----------------------------------------------------

func _add_room(sector_id: String, centre: Vector3, modules_x: int, modules_z: int,
		openings: Dictionary, wall_scale_y := 1.0) -> void:
	_add_floor_grid(sector_id, centre, modules_x, modules_z, true, wall_scale_y)
	var width := float(modules_x) * MODULE
	var depth := float(modules_z) * MODULE
	for index: int in modules_x:
		var x := centre.x + (float(index) - float(modules_x - 1) * 0.5) * MODULE
		_add_wall_module(sector_id, Vector3(x, centre.y, centre.z + depth * 0.5), 0.0,
			_is_open(openings, "north", index), index, wall_scale_y)
		_add_wall_module(sector_id, Vector3(x, centre.y, centre.z - depth * 0.5), PI,
			_is_open(openings, "south", index), index + 1, wall_scale_y)
	for index: int in modules_z:
		var z := centre.z + (float(index) - float(modules_z - 1) * 0.5) * MODULE
		_add_wall_module(sector_id, Vector3(centre.x - width * 0.5, centre.y, z), PI * 0.5,
			_is_open(openings, "west", index), index + 2, wall_scale_y)
		_add_wall_module(sector_id, Vector3(centre.x + width * 0.5, centre.y, z), -PI * 0.5,
			_is_open(openings, "east", index), index + 3, wall_scale_y)


func _add_floor_grid(sector_id: String, centre: Vector3, modules_x: int, modules_z: int,
		with_ceiling: bool, ceiling_scale_y := 1.0) -> void:
	for zi: int in modules_z:
		for xi: int in modules_x:
			var at := centre + Vector3(
				(float(xi) - float(modules_x - 1) * 0.5) * MODULE,
				0.0,
				(float(zi) - float(modules_z - 1) * 0.5) * MODULE)
			var floor_asset := "floor_tile_large"
			if (xi + zi) % 7 == 0:
				floor_asset = "floor_tile_large_rocks"
			elif (xi * 3 + zi) % 11 == 0:
				floor_asset = "floor_dirt_large_rocky"
			_place(sector_id, floor_asset, at)
			if with_ceiling:
				_place(sector_id, "ceiling_tile",
					at + Vector3.UP * WALL_HEIGHT * ceiling_scale_y,
					Vector3(PI, 0.0, 0.0), Vector3(1.0, ceiling_scale_y, 1.0))
	_add_box_collision(centre + Vector3.DOWN * 0.18,
		Vector3(float(modules_x) * MODULE, 0.35, float(modules_z) * MODULE))


func _add_wall_module(sector_id: String, at: Vector3, yaw: float, is_open: bool,
		variant: int, scale_y: float) -> void:
	if is_open:
		_place(sector_id, "wall_doorway", at, Vector3(0.0, yaw, 0.0),
			Vector3(1.0, scale_y, 1.0))
		return
	var asset := "wall"
	if variant % 9 == 0:
		asset = "wall_cracked"
	elif variant % 7 == 0:
		asset = "wall_broken"
	elif variant % 5 == 0:
		asset = "wall_pillar"
	_place(sector_id, asset, at, Vector3(0.0, yaw, 0.0), Vector3(1.0, scale_y, 1.0))
	_add_box_collision(at + Vector3.UP * WALL_HEIGHT * scale_y * 0.5,
		Vector3(MODULE, WALL_HEIGHT * scale_y, 0.55), yaw)


func _add_corridor(sector_id: String, start: Vector3, finish: Vector3, width: float) -> void:
	var delta := finish - start
	var horizontal := Vector2(delta.x, delta.z).length()
	if horizontal < 0.1:
		return
	var direction := Vector3(delta.x, 0.0, delta.z).normalized()
	var side := Vector3(-direction.z, 0.0, direction.x)
	var yaw := atan2(direction.x, direction.z)
	var pitch := atan2(-delta.y, horizontal)
	var count := maxi(1, ceili(horizontal / MODULE))
	for index: int in count:
		var t := (float(index) + 0.5) / float(count)
		var at := start.lerp(finish, t)
		_place(sector_id, "floor_tile_large", at,
			Vector3(pitch, yaw, 0.0), Vector3(width / MODULE, 1.0, 1.0))
		_place(sector_id, "ceiling_tile", at + Vector3.UP * WALL_HEIGHT,
			Vector3(PI + pitch, yaw, 0.0), Vector3(width / MODULE, 1.0, 1.0))
		for side_sign: float in [-1.0, 1.0]:
			var wall_at := at + side * width * 0.5 * side_sign
			var asset := "wall" if (index + int(side_sign)) % 4 != 0 else "wall_cracked"
			_place(sector_id, asset, wall_at, Vector3(0.0, yaw - PI * 0.5, 0.0))
			_add_box_collision(wall_at + Vector3.UP * 2.0,
				Vector3(MODULE, WALL_HEIGHT, 0.55), yaw - PI * 0.5)
	var midpoint := start.lerp(finish, 0.5)
	_add_box_collision(midpoint + Vector3.DOWN * 0.18,
		Vector3(width, 0.35, horizontal), yaw, pitch)


func _frame_route(sector_id: String, at: Vector3, yaw: float) -> void:
	_add_torch(sector_id, at + Basis(Vector3.UP, yaw) * Vector3(-1.55, 2.0, 0.25), yaw, 8.0)
	_add_torch(sector_id, at + Basis(Vector3.UP, yaw) * Vector3(1.55, 2.0, 0.25), yaw, 8.0)


func _is_open(openings: Dictionary, side: String, index: int) -> bool:
	return (openings.get(side, []) as Array).has(index)


# --- Atalhos e encontros -----------------------------------------------------

func _build_shortcuts() -> void:
	var mid_direction := Vector3(6.0, -2.0, -10.0)
	var mid_yaw := atan2(mid_direction.x, mid_direction.z)
	_add_shortcut_gate(&"mid_loop", Vector3(10.8, -3.3, -26.4), mid_yaw,
		Vector3(14.3, -4.5, -32.5), Vector3(4.0, 3.0, 4.0))
	var return_direction := Vector3(-2.0, 1.0, 6.0)
	var return_yaw := atan2(return_direction.x, return_direction.z)
	_add_shortcut_gate(&"boss_return", Vector3(8.45, -0.2, -3.35), return_yaw,
		Vector3(9.6, -0.8, -7.8), Vector3(4.0, 3.0, 4.0))


func _add_shortcut_gate(shortcut_id: StringName, at: Vector3, yaw: float,
		inside_trigger: Vector3, trigger_size: Vector3) -> void:
	var gate := StaticBody3D.new()
	gate.name = "ShortcutGate_%s" % shortcut_id
	gate.position = at
	gate.rotation.y = yaw
	gate.collision_layer = 1
	gate.collision_mask = 0
	add_child(gate)
	var visual := _make_mesh_instance("barrier")
	visual.name = "KayKitBarrier"
	visual.scale = Vector3(1.25, 1.4, 1.25)
	gate.add_child(visual)
	var gate_shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(4.0, 2.8, 0.45)
	gate_shape.shape = box
	gate_shape.position.y = 1.4
	gate.add_child(gate_shape)

	var trigger := Area3D.new()
	trigger.name = "InsideTrigger_%s" % shortcut_id
	trigger.position = inside_trigger
	trigger.collision_layer = 0
	trigger.collision_mask = 1
	var trigger_shape := CollisionShape3D.new()
	var trigger_box := BoxShape3D.new()
	trigger_box.size = trigger_size
	trigger_shape.shape = trigger_box
	trigger.add_child(trigger_shape)
	trigger.body_entered.connect(_on_shortcut_trigger_body_entered.bind(shortcut_id))
	add_child(trigger)
	_shortcut_gates[shortcut_id] = gate
	_shortcut_open[shortcut_id] = false


func _on_shortcut_trigger_body_entered(body: Node3D, shortcut_id: StringName) -> void:
	if body is CharacterBody3D:
		open_shortcut(shortcut_id)


func _build_encounter_markers() -> void:
	_add_enemy_marker("room_1_front", Vector3(0.0, -2.8, -21.0), "lanceiro_frontal")
	_add_enemy_marker("room_2_left_ambush", Vector3(1.5, -4.8, -40.8), "lanceiro_emboscada")
	_add_enemy_marker("room_2_right_ambush", Vector3(10.5, -4.8, -37.2), "lanceiro_emboscada")
	_add_enemy_marker("room_3_guard", Vector3(-2.0, -6.3, -62.0), "brutamontes_guarda")
	_add_enemy_marker("room_3_flank_left", Vector3(-5.0, -6.3, -57.0), "lanceiro_flanco")
	_add_enemy_marker("room_3_flank_right", Vector3(1.0, -6.3, -57.0), "lanceiro_flanco")
	var boss := Marker3D.new()
	boss.name = "Boss_Vorgar"
	boss.position = arena_center + Vector3(0.0, 0.2, -2.0)
	boss.add_to_group("lair_boss_spawn")
	add_child(boss)


func _add_enemy_marker(marker_name: String, at: Vector3, architecture_role: String) -> void:
	var marker := Marker3D.new()
	marker.name = marker_name
	marker.position = at
	marker.set_meta("architecture_role", architecture_role)
	marker.add_to_group("lair_enemy_spawn")
	add_child(marker)
	_enemy_markers.append(marker)


# --- Render e colisao --------------------------------------------------------

func _place(sector_id: String, asset_id: String, at: Vector3,
		rotation := Vector3.ZERO, scale := Vector3.ONE) -> void:
	var sector_batches := _batches[sector_id] as Dictionary
	var transforms: Array = sector_batches.get(asset_id, [])
	transforms.append(Transform3D(Basis.from_euler(rotation).scaled(scale), at))
	sector_batches[asset_id] = transforms
	_batches[sector_id] = sector_batches
	_used_assets[asset_id] = true


func _flush_all_batches() -> void:
	for sector_id: Variant in _batches:
		var sector_batches := _batches[sector_id] as Dictionary
		for asset_id: Variant in sector_batches:
			var transforms := sector_batches[asset_id] as Array
			if transforms.is_empty():
				continue
			var mesh := _mesh_for(String(asset_id))
			if mesh == null:
				continue
			var multimesh := MultiMesh.new()
			multimesh.transform_format = MultiMesh.TRANSFORM_3D
			multimesh.mesh = mesh
			multimesh.instance_count = transforms.size()
			for index: int in transforms.size():
				multimesh.set_instance_transform(index, transforms[index] as Transform3D)
			var instance := MultiMeshInstance3D.new()
			instance.name = "KayKit_%s" % String(asset_id)
			instance.multimesh = multimesh
			instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON \
				if _cast_shadows else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
			instance.visibility_range_end = 72.0
			instance.visibility_range_end_margin = 8.0
			(_sector_nodes[sector_id] as Node3D).add_child(instance)


func _mesh_for(asset_id: String) -> Mesh:
	if _mesh_cache.has(asset_id):
		return _mesh_cache[asset_id] as Mesh
	var packed := load(ASSET_ROOT + asset_id + ".gltf") as PackedScene
	if packed == null:
		push_error("KayKit em falta: %s" % asset_id)
		return null
	var source := packed.instantiate()
	var mesh_instance := _find_mesh_instance(source)
	if mesh_instance == null:
		push_error("KayKit sem MeshInstance3D: %s" % asset_id)
		source.free()
		return null
	var mesh := mesh_instance.mesh
	_mesh_cache[asset_id] = mesh
	source.free()
	return mesh


func _make_mesh_instance(asset_id: String) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.mesh = _mesh_for(asset_id)
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON \
		if _cast_shadows else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_used_assets[asset_id] = true
	return instance


func _find_mesh_instance(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node as MeshInstance3D
	for child: Node in node.get_children():
		var found := _find_mesh_instance(child)
		if found != null:
			return found
	return null


func _add_box_collision(at: Vector3, size: Vector3, yaw := 0.0, pitch := 0.0) -> void:
	var shape_node := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	shape_node.shape = shape
	shape_node.position = at
	shape_node.rotation = Vector3(pitch, yaw, 0.0)
	_static_body.add_child(shape_node)


func _prepare_shared_light_resources() -> void:
	_flame_mesh = SphereMesh.new()
	_flame_mesh.radius = 0.11
	_flame_mesh.height = 0.28
	_flame_mesh.radial_segments = 8
	_flame_mesh.rings = 4
	_flame_material = StandardMaterial3D.new()
	_flame_material.albedo_color = Color("#ffc05c")
	_flame_material.emission_enabled = true
	_flame_material.emission = Color("#ff9b3d")
	_flame_material.emission_energy_multiplier = 3.2


func _add_torch(sector_id: String, at: Vector3, yaw: float, light_range: float) -> void:
	_place(sector_id, "torch_mounted", at - Vector3.UP * 2.0, Vector3(0.0, yaw, 0.0),
		Vector3.ONE * 1.15)
	var holder := Node3D.new()
	holder.name = "WarmRouteLight"
	holder.position = at
	var flame := MeshInstance3D.new()
	flame.name = "Flame"
	flame.mesh = _flame_mesh
	flame.material_override = _flame_material
	holder.add_child(flame)
	var light := OmniLight3D.new()
	light.name = "AmberGuide"
	light.light_color = Color("#ffad58")
	light.light_energy = 1.7
	light.omni_range = light_range
	light.shadow_enabled = false
	light.distance_fade_enabled = true
	light.distance_fade_begin = maxf(12.0, light_range * 1.6)
	light.distance_fade_length = 10.0
	holder.add_child(light)
	(_sector_nodes[sector_id] as Node3D).add_child(holder)
