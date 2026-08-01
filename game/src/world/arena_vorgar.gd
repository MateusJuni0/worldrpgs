class_name ArenaVorgar
extends Node3D
## Arena dedicada do Vorgar.
##
## [CODEX] A sala usa o alvo normal de 24 x 22 m do spec/61, em vez do minimo
## historico de 20 x 16 m. Razao: as marcas SEPARAR ficam a 16 m uma da outra e
## ainda conservam duas rotas de fuga com mais de 3 m entre pilar e parede.
## Alternativa descartada: conservar 20 x 16 m; passa o minimo aritmetico, mas
## deixa pouco espaco quando os dois jogadores, o chefe e um volume persistente
## ocupam a mesma metade.
##
## Este ficheiro nao decide ataques nem contagens de impactos. O agente do
## Vorgar chama set_cover_broken() e set_gate_closed() a partir dos seus dados.

signal gate_state_changed(closed: bool)
signal cover_state_changed(cover_id: StringName, broken: bool)
signal threshold_entered(player: Node3D)
signal threshold_exited(player: Node3D)

const WIDTH_M := 24.0
const DEPTH_M := 22.0
const WALL_HEIGHT_M := 4.0
const THRESHOLD_DEPTH_M := 4.0
const FLANK_CLEARANCE_M := 4.75

const DUNGEON := "res://assets/models/dungeon/"
const ASSET_FLOOR := DUNGEON + "floor_tile_large.gltf"
const ASSET_FLOOR_ROCKS := DUNGEON + "floor_tile_large_rocks.gltf"
const ASSET_WALL := DUNGEON + "wall.gltf"
const ASSET_WALL_BROKEN := DUNGEON + "wall_broken.gltf"
const ASSET_WALL_CRACKED := DUNGEON + "wall_cracked.gltf"
const ASSET_WALL_GATED := DUNGEON + "wall_gated.gltf"
const ASSET_WALL_PILLAR := DUNGEON + "wall_pillar.gltf"
const ASSET_PILLAR_DECORATED := DUNGEON + "pillar_decorated.gltf"
const ASSET_RUBBLE_LARGE := DUNGEON + "rubble_large.gltf"
const ASSET_RUBBLE_HALF := DUNGEON + "rubble_half.gltf"
const ASSET_BANNER := DUNGEON + "banner_patternC_brown.gltf"
const ASSET_TORCH := DUNGEON + "torch_mounted.gltf"
const ASSET_BROKEN_ARMS := DUNGEON + "sword_shield_broken.gltf"

const MARKER_POSITIONS := {
	&"entry": Vector3(0.0, 0.55, 7.0),
	&"partner_entry": Vector3(2.5, 0.55, 7.0),
	&"boss": Vector3(0.0, 0.55, -5.0),
	&"separate_left": Vector3(-8.0, 0.05, 1.0),
	&"separate_right": Vector3(8.0, 0.05, 1.0),
	&"join": Vector3(0.0, 0.05, 2.0),
	&"refuge_left": Vector3(-6.0, 0.05, 2.2),
	&"refuge_right": Vector3(6.0, 0.05, 2.2),
}

var _mesh_cache: Dictionary = {}
var _covers: Dictionary = {}
var _cover_collisions: Dictionary = {}
var _gate_fog: MeshInstance3D
var _gate_collision: CollisionShape3D
var _preview_camera: Camera3D


func _ready() -> void:
	_build_floor()
	_build_floor_reading()
	_build_boundaries()
	_build_entry()
	_build_covers()
	_build_dressing()
	_build_markers()
	if get_tree().current_scene == self:
		_build_preview_environment()
		_build_preview_audio()
	if "--arena-audit" in OS.get_cmdline_user_args():
		call_deferred("_run_command_line_audit")
	elif "--arena-photos" in OS.get_cmdline_user_args():
		call_deferred("_run_photo_tour")


func set_gate_closed(closed: bool) -> void:
	if is_instance_valid(_gate_fog):
		_gate_fog.visible = closed
	if is_instance_valid(_gate_collision):
		_gate_collision.set_deferred("disabled", not closed)
	gate_state_changed.emit(closed)


func set_cover_broken(cover_id: StringName, broken: bool) -> void:
	var cover := _covers.get(cover_id) as Node3D
	var collision := _cover_collisions.get(cover_id) as CollisionShape3D
	if cover == null or collision == null:
		push_warning("[arena] refugio desconhecido: %s" % cover_id)
		return
	var intact := cover.get_node_or_null("Intact") as Node3D
	var rubble := cover.get_node_or_null("Rubble") as Node3D
	if intact != null:
		intact.visible = not broken
	if rubble != null:
		rubble.visible = broken
	collision.set_deferred("disabled", broken)
	cover_state_changed.emit(cover_id, broken)


func marker_position(marker_id: StringName) -> Vector3:
	var marker := get_node_or_null("Markers/%s" % marker_id) as Marker3D
	return marker.global_position if marker != null else global_position


func audit_layout() -> PackedStringArray:
	var failures := PackedStringArray()
	_check(WIDTH_M >= 20.0 and DEPTH_M >= 16.0, "dimensao minima 20 x 16 m", failures)
	_check(THRESHOLD_DEPTH_M >= 4.0, "limiar com pelo menos 4 m", failures)
	_check(FLANK_CLEARANCE_M >= 3.0, "dois flancos com pelo menos 3 m", failures)
	var left: Vector3 = MARKER_POSITIONS[&"separate_left"]
	var right: Vector3 = MARKER_POSITIONS[&"separate_right"]
	var boss: Vector3 = MARKER_POSITIONS[&"boss"]
	_check(left.distance_to(right) >= 10.0,
		"SEPARAR conserva pelo menos 10 m entre alvos", failures)
	_check(left.distance_to(boss) >= 3.0 and right.distance_to(boss) >= 3.0,
		"os dois alvos ficam pelo menos 3 m do chefe", failures)
	_check(_covers.size() == 2, "existem dois refugios independentes", failures)
	_check(is_instance_valid(_gate_fog) and is_instance_valid(_gate_collision),
		"nevoeiro e fecho fisico partilham o limiar", failures)
	_check(get_node_or_null("FogThreshold/ReadyThreshold") != null,
		"andar ate ao patamar emite o pedido de entrada", failures)
	_check(get_node_or_null("Boundaries") != null,
		"o limite visivel tem colisao coincidente", failures)
	for marker_id: StringName in MARKER_POSITIONS:
		_check(get_node_or_null("Markers/%s" % marker_id) != null,
			"marcador %s existe" % marker_id, failures)
	return failures


func _build_floor() -> void:
	var floor_root := Node3D.new()
	floor_root.name = "WorkedFloor"
	add_child(floor_root)
	var clean_tiles: Array[Transform3D] = []
	var rocky_tiles: Array[Transform3D] = []
	for x_index: int in 6:
		for z_index: int in 5:
			var x := -10.0 + float(x_index) * 4.0
			var z := -8.8 + float(z_index) * 4.4
			var transform := Transform3D(
				Basis.IDENTITY.scaled(Vector3(1.0, 1.0, 1.1)), Vector3(x, 0.0, z))
			var outside_join_zone := absf(x) > 6.0 or z < -3.5 or z > 7.0
			if outside_join_zone and (x_index + z_index * 2) % 7 == 0:
				rocky_tiles.append(transform)
			else:
				clean_tiles.append(transform)
	_add_multimesh(floor_root, ASSET_FLOOR, clean_tiles, "FloorTiles")
	_add_multimesh(floor_root, ASSET_FLOOR_ROCKS, rocky_tiles, "RockyFloorTiles")
	_add_static_box(floor_root, "FloorCollision", Vector3(WIDTH_M, 0.4, DEPTH_M),
		Vector3(0.0, -0.23, 0.0))


func _build_floor_reading() -> void:
	var reading := Node3D.new()
	reading.name = "CombatReading"
	add_child(reading)
	var flank_material := _material(Color("#4b3432"), 0.97)
	var flank_marks: Array[Transform3D] = []
	for x: float in [-8.0, 8.0]:
		for z: float in [-4.4, -1.1, 2.2, 5.5]:
			flank_marks.append(Transform3D(Basis.IDENTITY, Vector3(x, 0.065, z)))
	_add_box_multimesh(reading, Vector3(3.0, 0.035, 2.45), flank_marks,
		flank_material, "BrokenFlankInlays")
	var join_material := _material(Color("#82765d"), 0.96)
	var join_ring := MeshInstance3D.new()
	join_ring.name = "JoinRing"
	var torus := TorusMesh.new()
	torus.inner_radius = 3.65
	torus.outer_radius = 3.92
	torus.rings = 32
	torus.ring_segments = 8
	join_ring.mesh = torus
	join_ring.material_override = join_material
	join_ring.position = Vector3(0.0, 0.055, 2.0)
	join_ring.scale = Vector3(1.0, 0.16, 1.0)
	join_ring.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	reading.add_child(join_ring)
	var threshold_material := _material(Color("#5d4e3d"), 0.96)
	_add_visual_box(reading, "Threshold", Vector3(4.0, 0.045, THRESHOLD_DEPTH_M),
		Vector3(0.0, 0.08, 8.75), threshold_material)


func _build_boundaries() -> void:
	var boundaries := Node3D.new()
	boundaries.name = "Boundaries"
	add_child(boundaries)
	var stone := _material(Color("#292d31"), 0.98)
	_add_visual_box(boundaries, "NorthLeftFoundation", Vector3(10.5, WALL_HEIGHT_M, 1.0),
		Vector3(-7.25, WALL_HEIGHT_M * 0.5, -11.5), stone)
	_add_visual_box(boundaries, "NorthRightFoundation", Vector3(10.5, WALL_HEIGHT_M, 1.0),
		Vector3(7.25, WALL_HEIGHT_M * 0.5, -11.5), stone)
	_add_visual_box(boundaries, "WestFoundation", Vector3(1.0, WALL_HEIGHT_M, DEPTH_M),
		Vector3(-12.5, WALL_HEIGHT_M * 0.5, 0.0), stone)
	_add_visual_box(boundaries, "EastFoundation", Vector3(1.0, WALL_HEIGHT_M, DEPTH_M),
		Vector3(12.5, WALL_HEIGHT_M * 0.5, 0.0), stone)
	_add_visual_box(boundaries, "SouthLeftFoundation", Vector3(10.5, WALL_HEIGHT_M, 1.0),
		Vector3(-7.25, WALL_HEIGHT_M * 0.5, 11.5), stone)
	_add_visual_box(boundaries, "SouthRightFoundation", Vector3(10.5, WALL_HEIGHT_M, 1.0),
		Vector3(7.25, WALL_HEIGHT_M * 0.5, 11.5), stone)
	_add_static_box(boundaries, "NorthLeftCollision", Vector3(10.5, WALL_HEIGHT_M, 1.0),
		Vector3(-7.25, WALL_HEIGHT_M * 0.5, -11.5))
	_add_static_box(boundaries, "NorthRightCollision", Vector3(10.5, WALL_HEIGHT_M, 1.0),
		Vector3(7.25, WALL_HEIGHT_M * 0.5, -11.5))
	_add_static_box(boundaries, "WestCollision", Vector3(1.0, WALL_HEIGHT_M, DEPTH_M),
		Vector3(-12.5, WALL_HEIGHT_M * 0.5, 0.0))
	_add_static_box(boundaries, "EastCollision", Vector3(1.0, WALL_HEIGHT_M, DEPTH_M),
		Vector3(12.5, WALL_HEIGHT_M * 0.5, 0.0))
	_add_static_box(boundaries, "SouthLeftCollision", Vector3(10.5, WALL_HEIGHT_M, 1.0),
		Vector3(-7.25, WALL_HEIGHT_M * 0.5, 11.5))
	_add_static_box(boundaries, "SouthRightCollision", Vector3(10.5, WALL_HEIGHT_M, 1.0),
		Vector3(7.25, WALL_HEIGHT_M * 0.5, 11.5))

	var wall_transforms: Array[Transform3D] = []
	var cracked_transforms: Array[Transform3D] = []
	for x: float in [-10.0, -6.0, -3.0, 3.0, 6.0, 10.0]:
		var path := cracked_transforms if x in [-6.0, 6.0] else wall_transforms
		path.append(Transform3D(Basis(Vector3.UP, PI), Vector3(x, 0.0, -11.0)))
	for x: float in [-10.0, -6.0, 6.0, 10.0]:
		wall_transforms.append(Transform3D(Basis.IDENTITY, Vector3(x, 0.0, 11.0)))
	for z: float in [-9.0, -5.0, -1.0, 3.0, 7.0]:
		wall_transforms.append(Transform3D(Basis(Vector3.UP, PI * 0.5), Vector3(-12.0, 0.0, z)))
		wall_transforms.append(Transform3D(Basis(Vector3.UP, -PI * 0.5), Vector3(12.0, 0.0, z)))
	_add_multimesh(boundaries, ASSET_WALL, wall_transforms, "KayKitWalls")
	_add_multimesh(boundaries, ASSET_WALL_CRACKED, cracked_transforms, "CrackedNorthWalls")
	var broken_transforms: Array[Transform3D] = [
		Transform3D(Basis(Vector3.UP, PI * 0.5), Vector3(-12.0, 0.0, -7.0)),
		Transform3D(Basis(Vector3.UP, -PI * 0.5), Vector3(12.0, 0.0, 5.0)),
	]
	_add_multimesh(boundaries, ASSET_WALL_BROKEN, broken_transforms, "BrokenWalls")
	_add_asset_instance(boundaries, ASSET_WALL_GATED,
		Transform3D(Basis(Vector3.UP, PI), Vector3(0.0, 0.0, -11.08)), "NorthExitGate")
	var buttresses: Array[Transform3D] = []
	for at: Vector3 in [
		Vector3(-12.0, 0.0, -11.0), Vector3(12.0, 0.0, -11.0),
		Vector3(-12.0, 0.0, 11.0), Vector3(12.0, 0.0, 11.0),
		Vector3(-2.35, 0.0, 11.0), Vector3(2.35, 0.0, 11.0),
	]:
		buttresses.append(Transform3D(Basis.IDENTITY, at))
	_add_multimesh(boundaries, ASSET_WALL_PILLAR, buttresses, "WallButtresses")


func _build_entry() -> void:
	var entry := Node3D.new()
	entry.name = "FogThreshold"
	add_child(entry)
	var lintel_material := _material(Color("#292d31"), 0.98)
	_add_visual_box(entry, "StoneLintel", Vector3(5.0, 0.8, 1.1),
		Vector3(0.0, 3.6, 11.5), lintel_material)
	_gate_fog = MeshInstance3D.new()
	_gate_fog.name = "Fog"
	var fog_quad := QuadMesh.new()
	fog_quad.size = Vector2(3.9, 3.7)
	_gate_fog.mesh = fog_quad
	_gate_fog.position = Vector3(0.0, 1.85, 11.58)
	_gate_fog.material_override = _fog_material()
	_gate_fog.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	entry.add_child(_gate_fog)
	var gate_body := StaticBody3D.new()
	gate_body.name = "ClosedGate"
	entry.add_child(gate_body)
	_gate_collision = CollisionShape3D.new()
	var gate_shape := BoxShape3D.new()
	gate_shape.size = Vector3(4.0, 3.8, 0.35)
	_gate_collision.shape = gate_shape
	_gate_collision.position = Vector3(0.0, 1.9, 11.15)
	gate_body.add_child(_gate_collision)
	var threshold := Area3D.new()
	threshold.name = "ReadyThreshold"
	threshold.position = Vector3(0.0, 1.5, 9.2)
	threshold.collision_layer = 0
	threshold.collision_mask = 1
	entry.add_child(threshold)
	var threshold_collision := CollisionShape3D.new()
	var threshold_shape := BoxShape3D.new()
	threshold_shape.size = Vector3(5.0, 3.0, 3.0)
	threshold_collision.shape = threshold_shape
	threshold.add_child(threshold_collision)
	threshold.body_entered.connect(_on_threshold_body_entered)
	threshold.body_exited.connect(_on_threshold_body_exited)


func _build_covers() -> void:
	var covers_root := Node3D.new()
	covers_root.name = "TemporaryRefuges"
	add_child(covers_root)
	for side: int in [-1, 1]:
		var cover_id := &"left" if side < 0 else &"right"
		var cover := Node3D.new()
		cover.name = String(cover_id).capitalize()
		cover.position = Vector3(float(side) * 6.0, 0.0, -0.35)
		covers_root.add_child(cover)
		var intact := Node3D.new()
		intact.name = "Intact"
		cover.add_child(intact)
		_add_asset_instance(intact, ASSET_PILLAR_DECORATED,
			Transform3D(Basis.IDENTITY.scaled(Vector3(1.15, 1.35, 1.15)), Vector3.ZERO),
			"KayKitPillar")
		var rubble := Node3D.new()
		rubble.name = "Rubble"
		rubble.visible = false
		cover.add_child(rubble)
		_add_asset_instance(rubble, ASSET_RUBBLE_LARGE,
			Transform3D(Basis.IDENTITY.scaled(Vector3.ONE * 0.58), Vector3.ZERO),
			"KayKitRubble")
		var body := StaticBody3D.new()
		body.name = "Collision"
		cover.add_child(body)
		var collision := CollisionShape3D.new()
		var shape := CylinderShape3D.new()
		shape.radius = 1.28
		shape.height = 4.9
		collision.shape = shape
		collision.position.y = 2.45
		body.add_child(collision)
		_covers[cover_id] = cover
		_cover_collisions[cover_id] = collision


func _build_dressing() -> void:
	var dressing := Node3D.new()
	dressing.name = "SiegeScars"
	add_child(dressing)
	var banners: Array[Transform3D] = []
	for x: float in [-7.0, 7.0]:
		banners.append(Transform3D(Basis(Vector3.UP, PI), Vector3(x, 0.55, -10.45)))
	_add_multimesh(dressing, ASSET_BANNER, banners, "GateBanners")
	var torches: Array[Transform3D] = []
	for at: Vector3 in [
		Vector3(-9.0, 2.35, -10.45), Vector3(9.0, 2.35, -10.45),
		Vector3(-11.45, 2.35, 5.0), Vector3(11.45, 2.35, 5.0),
		Vector3(-2.2, 2.35, 10.45), Vector3(2.2, 2.35, 10.45),
	]:
		var yaw := 0.0
		if absf(at.x) > 10.0:
			yaw = -PI * 0.5 if at.x < 0.0 else PI * 0.5
		elif at.z < 0.0:
			yaw = PI
		torches.append(Transform3D(Basis(Vector3.UP, yaw), at))
	_add_multimesh(dressing, ASSET_TORCH, torches, "WallTorches")
	var rubble: Array[Transform3D] = [
		Transform3D(Basis(Vector3.UP, 0.25), Vector3(-10.7, 0.02, -8.5)),
		Transform3D(Basis(Vector3.UP, -0.55), Vector3(10.6, 0.02, -7.3)),
		Transform3D(Basis(Vector3.UP, 1.15), Vector3(-10.8, 0.02, 8.2)),
		Transform3D(Basis(Vector3.UP, -0.9), Vector3(10.8, 0.02, 8.5)),
	]
	_add_multimesh(dressing, ASSET_RUBBLE_HALF, rubble, "EdgeRubble")
	var arms: Array[Transform3D] = [
		Transform3D(Basis(Vector3.UP, -0.35), Vector3(-9.5, 0.08, -9.6)),
		Transform3D(Basis(Vector3.UP, 0.65), Vector3(9.2, 0.08, -9.8)),
	]
	_add_multimesh(dressing, ASSET_BROKEN_ARMS, arms, "BrokenArms")
	_add_guiding_lights(dressing)


func _build_markers() -> void:
	var markers := Node3D.new()
	markers.name = "Markers"
	add_child(markers)
	for marker_id: StringName in MARKER_POSITIONS:
		var marker := Marker3D.new()
		marker.name = String(marker_id)
		marker.position = MARKER_POSITIONS[marker_id]
		markers.add_child(marker)


func _build_preview_environment() -> void:
	var world_environment := WorldEnvironment.new()
	world_environment.name = "PreviewEnvironment"
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#0c1116")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#74818c")
	environment.ambient_light_energy = 0.48
	environment.reflected_light_source = Environment.REFLECTION_SOURCE_DISABLED
	environment.fog_enabled = true
	environment.fog_light_color = Color("#46515a")
	environment.fog_light_energy = 0.38
	environment.fog_density = 0.012
	environment.fog_height = -1.0
	environment.fog_height_density = 0.12
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world_environment.environment = environment
	add_child(world_environment)
	var sun := DirectionalLight3D.new()
	sun.name = "Moonlight"
	sun.rotation_degrees = Vector3(-52.0, -28.0, 0.0)
	sun.light_color = Color("#c5d2db")
	sun.light_energy = 0.72
	sun.shadow_enabled = false
	add_child(sun)
	_preview_camera = Camera3D.new()
	_preview_camera.name = "PreviewCamera"
	_preview_camera.position = Vector3(0.0, 5.2, 9.0)
	_preview_camera.fov = 58.0
	_preview_camera.far = 60.0
	_preview_camera.look_at_from_position(_preview_camera.position, Vector3(0.0, 1.0, -2.0))
	add_child(_preview_camera)
	_preview_camera.current = true


func _build_preview_audio() -> void:
	var ambience := AudioStreamPlayer.new()
	ambience.name = "SynthesisedStoneWind"
	ambience.stream = _synthesise_wind()
	ambience.volume_db = -27.0
	add_child(ambience)
	ambience.play()


func _add_guiding_lights(parent: Node3D) -> void:
	for at: Vector3 in [Vector3(-6.0, 3.0, -9.7), Vector3(6.0, 3.0, -9.7),
			Vector3(0.0, 3.0, 10.0)]:
		var light := OmniLight3D.new()
		light.name = "AmberGuide"
		light.position = at
		light.light_color = Color("#d98b49")
		light.light_energy = 1.35
		light.omni_range = 7.0
		light.shadow_enabled = false
		parent.add_child(light)


func _add_multimesh(parent: Node3D, path: String, transforms: Array[Transform3D],
		label: String) -> void:
	if transforms.is_empty():
		return
	var mesh := _mesh_for(path)
	if mesh == null:
		push_error("[arena] malha em falta: %s" % path)
		return
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = mesh
	multimesh.instance_count = transforms.size()
	for index: int in transforms.size():
		multimesh.set_instance_transform(index, transforms[index])
	var instance := MultiMeshInstance3D.new()
	instance.name = label
	instance.multimesh = multimesh
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(instance)


func _add_box_multimesh(parent: Node3D, size: Vector3, transforms: Array[Transform3D],
		material: Material, label: String) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = material
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = mesh
	multimesh.instance_count = transforms.size()
	for index: int in transforms.size():
		multimesh.set_instance_transform(index, transforms[index])
	var instance := MultiMeshInstance3D.new()
	instance.name = label
	instance.multimesh = multimesh
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(instance)


func _mesh_for(path: String) -> Mesh:
	if _mesh_cache.has(path):
		return _mesh_cache[path] as Mesh
	var packed := load(path) as PackedScene
	if packed == null:
		return null
	var temporary := packed.instantiate()
	var mesh_instance := _first_mesh_instance(temporary)
	var mesh := mesh_instance.mesh if mesh_instance != null else null
	temporary.free()
	_mesh_cache[path] = mesh
	return mesh


func _first_mesh_instance(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node as MeshInstance3D
	for child: Node in node.get_children():
		var found := _first_mesh_instance(child)
		if found != null:
			return found
	return null


func _add_asset_instance(parent: Node3D, path: String, transform: Transform3D,
		label: String) -> Node3D:
	var packed := load(path) as PackedScene
	if packed == null:
		push_error("[arena] cena em falta: %s" % path)
		return null
	var instance := packed.instantiate() as Node3D
	instance.name = label
	instance.transform = transform
	_set_shadow_recursive(instance, false)
	parent.add_child(instance)
	return instance


func _set_shadow_recursive(node: Node, enabled: bool) -> void:
	if node is GeometryInstance3D:
		(node as GeometryInstance3D).cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON \
			if enabled else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for child: Node in node.get_children():
		_set_shadow_recursive(child, enabled)


func _add_static_box(parent: Node3D, label: String, size: Vector3, at: Vector3) -> void:
	var body := StaticBody3D.new()
	body.name = label
	body.position = at
	parent.add_child(body)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)


func _add_visual_box(parent: Node3D, label: String, size: Vector3, at: Vector3,
		material: Material) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = label
	var mesh := BoxMesh.new()
	mesh.size = size
	instance.mesh = mesh
	instance.position = at
	instance.material_override = material
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(instance)
	return instance


func _material(colour: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = colour
	material.roughness = roughness
	return material


func _fog_material() -> ShaderMaterial:
	var shader := Shader.new()
	shader.code = """
shader_type spatial;
render_mode unshaded, cull_disabled, depth_prepass_alpha;

void fragment() {
	float edge = smoothstep(0.0, 0.13, UV.x) * smoothstep(0.0, 0.13, 1.0 - UV.x);
	ALBEDO = vec3(0.66, 0.75, 0.77);
	EMISSION = vec3(0.16, 0.20, 0.21);
	ALPHA = (0.78 + UV.y * 0.06) * edge;
}

void vertex() {
	VERTEX.x += sin(UV.y * 6.0 + TIME * 0.45) * 0.03;
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	return material


func _synthesise_wind() -> AudioStreamWAV:
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 22050
	stream.stereo = false
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = 44100
	var data := PackedByteArray()
	data.resize(stream.loop_end * 2)
	for sample_index: int in stream.loop_end:
		var t := float(sample_index) / float(stream.mix_rate)
		var slow := sin(TAU * 0.19 * t) * 0.45 + sin(TAU * 0.31 * t + 1.2) * 0.25
		var grain := sin(TAU * 43.0 * t + sin(TAU * 0.7 * t) * 2.0) * 0.08
		data.encode_s16(sample_index * 2, int(clampf(slow + grain, -1.0, 1.0) * 2800.0))
	stream.data = data
	return stream


func _check(condition: bool, message: String, failures: PackedStringArray) -> void:
	if condition:
		print("  ok    arena: ", message)
	else:
		failures.append(message)
		printerr("  FALHA arena: ", message)


func _on_threshold_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		threshold_entered.emit(body)


func _on_threshold_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		threshold_exited.emit(body)


func _run_command_line_audit() -> void:
	var failures := audit_layout()
	var events := [false, false]
	threshold_entered.connect(func(_player: Node3D) -> void: events[0] = true,
		CONNECT_ONE_SHOT)
	threshold_exited.connect(func(_player: Node3D) -> void: events[1] = true,
		CONNECT_ONE_SHOT)
	var probe := CharacterBody3D.new()
	probe.name = "ThresholdAuditPlayer"
	probe.add_to_group("player")
	probe.collision_layer = 1
	probe.collision_mask = 0
	var probe_collision := CollisionShape3D.new()
	var probe_shape := CapsuleShape3D.new()
	probe_shape.radius = 0.35
	probe_shape.height = 1.8
	probe_collision.shape = probe_shape
	probe.add_child(probe_collision)
	add_child(probe)
	probe.position = Vector3(0.0, 1.0, 9.2)
	await get_tree().physics_frame
	await get_tree().physics_frame
	_check(bool(events[0]), "patamar detecta um jogador que entra", failures)
	probe.position = Vector3(0.0, 1.0, 5.0)
	await get_tree().physics_frame
	await get_tree().physics_frame
	_check(bool(events[1]), "patamar detecta um jogador que sai", failures)
	probe.queue_free()
	set_gate_closed(false)
	await get_tree().physics_frame
	_check(not _gate_fog.visible and _gate_collision.disabled,
		"abrir retira nevoeiro e colisao juntos", failures)
	set_gate_closed(true)
	await get_tree().physics_frame
	_check(_gate_fog.visible and not _gate_collision.disabled,
		"fechar repoe nevoeiro e colisao juntos", failures)
	set_cover_broken(&"left", true)
	await get_tree().physics_frame
	var left_cover := _covers[&"left"] as Node3D
	var right_cover := _covers[&"right"] as Node3D
	_check(not left_cover.get_node("Intact").visible
		and left_cover.get_node("Rubble").visible
		and (_cover_collisions[&"left"] as CollisionShape3D).disabled
		and right_cover.get_node("Intact").visible,
		"um refugio parte sem alterar o outro", failures)
	set_cover_broken(&"left", false)
	await get_tree().physics_frame
	_check(left_cover.get_node("Intact").visible
		and not left_cover.get_node("Rubble").visible
		and not (_cover_collisions[&"left"] as CollisionShape3D).disabled,
		"refugio restaura os dois estados pre-feitos", failures)
	print("=== ARENA: %d passaram, %d falharam ===" % [
		MARKER_POSITIONS.size() + 15 - failures.size(), failures.size()])
	get_tree().quit(0 if failures.is_empty() else 1)


func _run_photo_tour() -> void:
	if _preview_camera == null:
		printerr("[arena-photo] a cena precisa de ser executada directamente")
		get_tree().quit(1)
		return
	var shots: Array[Array] = [
		["01-entrada-nevoeiro", Vector3(0.0, 2.0, 16.5), Vector3(0.0, 1.4, 4.0)],
		["02-arena-geral", Vector3(0.0, 8.2, 15.5), Vector3(0.0, 1.0, -1.5)],
		["03-leitura-chao", Vector3(0.0, 5.0, 10.0), Vector3(0.0, 0.0, 1.0)],
		["04-separar", Vector3(0.0, 3.0, 8.5), Vector3(0.0, 1.0, -0.3)],
		["05-refugio-esquerdo", Vector3(-10.0, 2.2, 6.0), Vector3(-5.0, 1.2, -1.0)],
		["06-limite-norte", Vector3(8.5, 2.0, -5.0), Vector3(0.0, 1.2, -10.5)],
	]
	var output_dir := "user://arena-vorgar-captures"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_dir))
	for shot: Array in shots:
		_preview_camera.look_at_from_position(shot[1] as Vector3, shot[2] as Vector3)
		for frame: int in 18:
			await get_tree().process_frame
		var image := get_viewport().get_texture().get_image()
		var path := "%s/%s.png" % [output_dir, shot[0]]
		var error := image.save_png(path)
		if error != OK:
			printerr("[arena-photo] falhou: %s (%s)" % [path, error])
		else:
			print("[arena-photo] ", path)
	print("[arena-photo] done=%d" % shots.size())
	get_tree().quit(0)
