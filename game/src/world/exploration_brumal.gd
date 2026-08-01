class_name ExplorationBrumal
extends Node3D
## Gramática espacial da Fatia 1: a rota separa-se, cobra escolhas diferentes,
## volta a reunir-se e abre um regresso à Orla pelo lado interior.
##
## Este módulo é deliberadamente independente de Greybox. O dono desse ficheiro
## pode consumir `route_segments()`, `landmarks()` e `shortcut_opened` sem copiar
## coordenadas. Enquanto essa ligação não existir, o benchmark monta o módulo
## sobre a zona actual e mede o custo como limite superior.

signal shortcut_opened(shortcut_id: StringName)

const ShortcutScript = preload("res://src/world/exploration_shortcut.gd")

const ENTRY_ROUTE := [
	Vector3(0.0, 0.0, 95.0),
	Vector3(-43.0, 0.0, 91.0), Vector3(-88.0, 0.0, 94.0),
	Vector3(-94.0, 0.0, 80.0), Vector3(-50.0, 0.0, 78.0),
	Vector3(3.0, 0.0, 84.0), Vector3(45.0, 0.0, 79.0), Vector3(84.0, 0.0, 82.0),
	Vector3(92.0, 0.0, 66.0), Vector3(48.0, 0.0, 63.0),
	Vector3(0.0, 0.0, 69.0), Vector3(-47.0, 0.0, 64.0), Vector3(-86.0, 0.0, 66.0),
	Vector3(-93.0, 0.0, 50.0), Vector3(-48.0, 0.0, 47.0),
	Vector3(2.0, 0.0, 53.0), Vector3(46.0, 0.0, 48.0), Vector3(85.0, 0.0, 51.0),
	Vector3(93.0, 0.0, 34.0), Vector3(46.0, 0.0, 33.0),
	Vector3(0.0, 0.0, 39.0), Vector3(-46.0, 0.0, 34.0), Vector3(-85.0, 0.0, 36.0),
	Vector3(-92.0, 0.0, 18.0), Vector3(-46.0, 0.0, 17.0),
	Vector3(2.0, 0.0, 23.0), Vector3(48.0, 0.0, 18.0), Vector3(86.0, 0.0, 20.0),
	Vector3(92.0, 0.0, 3.0), Vector3(46.0, 0.0, 2.0),
	Vector3(0.0, 0.0, 7.0), Vector3(-43.0, 0.0, 2.0), Vector3(-75.0, 0.0, 0.0),
]
const REST_BRANCH := [
	Vector3(-75.0, 0.0, 0.0),
	Vector3(-29.0, 0.0, -4.0), Vector3(17.0, 0.0, 2.0),
	Vector3(59.0, 0.0, -2.0), Vector3(88.0, 0.0, 0.0),
	Vector3(94.0, 0.0, -15.0), Vector3(48.0, 0.0, -18.0),
	Vector3(5.0, 0.0, -12.0), Vector3(-36.0, 0.0, -17.0), Vector3(-67.0, 0.0, -14.0),
	Vector3(-75.0, 0.0, -30.0), Vector3(-31.0, 0.0, -32.0),
	Vector3(15.0, 0.0, -26.0), Vector3(56.0, 0.0, -31.0), Vector3(88.0, 0.0, -28.0),
	Vector3(94.0, 0.0, -44.0), Vector3(52.0, 0.0, -47.0),
	Vector3(10.0, 0.0, -40.0), Vector3(-34.0, 0.0, -46.0), Vector3(-67.0, 0.0, -42.0),
	Vector3(-75.0, 0.0, -58.0), Vector3(-29.0, 0.0, -61.0),
	Vector3(15.0, 0.0, -54.0), Vector3(56.0, 0.0, -60.0), Vector3(88.0, 0.0, -56.0),
	Vector3(94.0, 0.0, -72.0), Vector3(53.0, 0.0, -75.0),
	Vector3(10.0, 0.0, -68.0), Vector3(-33.0, 0.0, -74.0), Vector3(-67.0, 0.0, -70.0),
	Vector3(-67.0, 0.0, -84.0),
]
const RISK_BRANCH := [
	Vector3(-75.0, 0.0, 0.0),
	Vector3(-95.0, 0.0, -8.0), Vector3(-98.0, 0.0, -30.0),
	Vector3(-92.0, 0.0, -52.0), Vector3(-98.0, 0.0, -70.0),
	Vector3(-67.0, 0.0, -84.0),
]
const LAIR_ROUTE := [
	Vector3(-67.0, 0.0, -84.0),
	Vector3(-43.0, 0.0, -97.0),
	Vector3(-19.0, 0.0, -70.0),
]
const SHORTCUT_ROUTE := [
	Vector3(-20.0, 0.0, -70.0),
	Vector3(-49.0, 0.0, -47.0),
	Vector3(-58.0, 0.0, 8.0),
	Vector3(-43.0, 0.0, 55.0),
	Vector3(-12.0, 0.0, 83.0),
	Vector3(-7.0, 0.0, 87.0),
]

const SHORTCUT_ID := &"brumal_portao_da_arvore"
const SHORTCUT_GATE_POSITION := Vector3(-7.0, 0.0, 87.0)
const SHORTCUT_INSIDE_DIRECTION := Vector3(-1.0, 0.0, 0.0)
const HIDDEN_ITEM_POSITION := Vector3(-96.0, 0.55, -41.0)
const HIDDEN_ITEM_REVEAL_POSITION := Vector3(-98.0, 1.4, -30.0)
const SPLIT_VIEW_POSITION := Vector3(-75.0, 1.4, 0.0)

const LANDMARK_DEFINITIONS := [
	{
		"id": "arco_partido",
		"name": "Arco Partido",
		"type": "landmark",
		"position": Vector3(-93.0, 0.0, 50.0),
		"discover_radius_m": 14.0,
	},
	{
		"id": "farol_dos_corvos",
		"name": "Farol dos Corvos",
		"type": "landmark",
		"position": Vector3(88.0, 0.0, -28.0),
		"discover_radius_m": 16.0,
	},
	{
		"id": "arvore_morta",
		"name": "Árvore Morta",
		"type": "landmark",
		"position": Vector3(-19.0, 0.0, -70.0),
		"discover_radius_m": 18.0,
	},
]

const OCCLUDER_SPECS := [
	{"position": Vector3(-85.5, 2.6, -20.5), "size": Vector3(10.0, 5.2, 4.0), "yaw": 0.42},
	{"position": Vector3(-90.0, 3.2, -23.0), "size": Vector3(4.0, 6.4, 5.0), "yaw": -0.28},
	{"position": Vector3(-82.0, 1.7, -17.0), "size": Vector3(5.0, 3.4, 3.0), "yaw": 0.76},
]

var _built := false
var _path_width_m := 6.0
var _shortcut: ExplorationShortcut
var _occluder_body: StaticBody3D


func build(options: Dictionary = {}) -> bool:
	if _built:
		push_warning("ExplorationBrumal.build() ignorado: modulo ja construido")
		return false
	_path_width_m = maxf(float(options.get("path_width_m", 6.0)), 2.0)
	_build_path_ribbons(_option_colour(options, "path_colour", Color("685844")))
	_build_occluders(_option_colour(options, "root_colour", Color("29241f")))
	_build_landmark_silhouettes(_option_colour(options, "landmark_colour", Color("35352f")))
	_build_shortcut(options)
	_built = true
	return true


func route_segments() -> Array[PackedVector3Array]:
	return [
		PackedVector3Array(ENTRY_ROUTE),
		PackedVector3Array(REST_BRANCH),
		PackedVector3Array(RISK_BRANCH),
		PackedVector3Array(LAIR_ROUTE),
		PackedVector3Array(SHORTCUT_ROUTE),
	]


func branch_contracts() -> Array[Dictionary]:
	return [
		{
			"id": "caminho_do_descanso",
			"points": PackedVector3Array(REST_BRANCH),
			"cost": "oito minutos limpos, várias dobras e exposição no Farol dos Corvos",
			"reward": "descanso visível, Baú do Bivaque e Baú da Raiz",
			"reward_ids": ["descanso_1_brumal", "brumal_bivaque", "brumal_raiz_da_toca"],
			"pressure_slots": ["farol_frente"],
		},
		{
			"id": "leito_da_bruma",
			"points": PackedVector3Array(RISK_BRANCH),
			"cost": "salto de alto risco, sem descanso e com duas aproximações ocultas",
			"reward": "achado no chão atrás das raízes",
			"reward_ids": ["achado_atras_das_raizes"],
			"pressure_slots": ["raiz_emboscada", "leito_guarda"],
		},
	]


func tutorial_path_points() -> Array[Vector3]:
	## Compatibilidade para main.gd: preserva cinco batidas espaçadas sem obrigar
	## o integrador a tratar todos os vértices da curva como encontro.
	return [
		ENTRY_ROUTE[0], ENTRY_ROUTE[2], ENTRY_ROUTE[7], ENTRY_ROUTE[12],
		ENTRY_ROUTE[17], ENTRY_ROUTE[22], ENTRY_ROUTE[27], ENTRY_ROUTE[-1],
	]


func encounter_markers() -> Array[Dictionary]:
	return [
		{
			"id": "farol_frente", "branch_id": "caminho_do_descanso",
			"position": Vector3(70.0, 0.5, -29.0), "role": "guarda_frontal",
		},
		{
			"id": "raiz_emboscada", "branch_id": "leito_da_bruma",
			"position": Vector3(-96.0, 0.5, -27.0), "role": "emboscada_lateral",
		},
		{
			"id": "leito_guarda", "branch_id": "leito_da_bruma",
			"position": Vector3(-95.0, 0.5, -62.0), "role": "guarda_do_achado",
		},
	]


func landmarks() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for definition: Dictionary in LANDMARK_DEFINITIONS:
		result.append(definition.duplicate(true))
	return result


func secret_anchors() -> Dictionary:
	return {
		"hidden_item": HIDDEN_ITEM_POSITION,
		"hidden_from": SPLIT_VIEW_POSITION,
		"revealed_from": HIDDEN_ITEM_REVEAL_POSITION,
	}


func shortcut() -> ExplorationShortcut:
	return _shortcut


func restore_shortcuts(open_shortcut_ids: Array) -> void:
	if is_instance_valid(_shortcut):
		_shortcut.restore_open_state(open_shortcut_ids)


func audit() -> Dictionary:
	var rest_length := _polyline_length(ENTRY_ROUTE) + _polyline_length(REST_BRANCH) \
		+ _polyline_length(LAIR_ROUTE)
	var risk_length := _polyline_length(ENTRY_ROUTE) + _polyline_length(RISK_BRANCH) \
		+ _polyline_length(LAIR_ROUTE)
	var shortcut_length := _polyline_length(SHORTCUT_ROUTE) \
		+ SHORTCUT_GATE_POSITION.distance_to(ENTRY_ROUTE[0])
	return {
		"built": _built,
		"branch_count": 2,
		"branches_rejoin": REST_BRANCH[-1] == RISK_BRANCH[-1],
		"rest_route_length_m": snappedf(rest_length, 0.1),
		"risk_route_length_m": snappedf(risk_length, 0.1),
		"shortcut_return_length_m": snappedf(shortcut_length, 0.1),
		"shortcut_count": 1,
		"encounter_marker_count": encounter_markers().size(),
		"landmark_count": LANDMARK_DEFINITIONS.size(),
		"occluder_count": OCCLUDER_SPECS.size(),
		"mesh_instances": 5,
		"dynamic_lights": 0,
		"audio_voices": 1,
		"path_width_m": _path_width_m,
	}


func distance_to_routes(point: Vector3) -> float:
	var best := INF
	for route: PackedVector3Array in route_segments():
		for index: int in route.size() - 1:
			best = minf(best, _distance_to_segment(point, route[index], route[index + 1]))
	return best


func _build_path_ribbons(colour: Color) -> void:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var indices := PackedInt32Array()
	for route: PackedVector3Array in route_segments():
		for index: int in route.size() - 1:
			var start := route[index]
			var finish := route[index + 1]
			var forward := finish - start
			forward.y = 0.0
			if forward.length_squared() < 0.001:
				continue
			forward = forward.normalized()
			var right := Vector3(forward.z, 0.0, -forward.x) * _path_width_m * 0.5
			var base := vertices.size()
			vertices.append(start - right + Vector3.UP * 0.055)
			vertices.append(start + right + Vector3.UP * 0.055)
			vertices.append(finish + right + Vector3.UP * 0.055)
			vertices.append(finish - right + Vector3.UP * 0.055)
			for _normal: int in 4:
				normals.append(Vector3.UP)
			indices.append_array(PackedInt32Array([
				base, base + 1, base + 2, base, base + 2, base + 3]))
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var visual := MeshInstance3D.new()
	visual.name = "BrumalBranchingPaths"
	visual.mesh = mesh
	visual.material_override = _material(colour, 0.92)
	visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(visual)


func _build_occluders(colour: Color) -> void:
	var mesh := BoxMesh.new()
	mesh.size = Vector3.ONE
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = mesh
	multimesh.instance_count = OCCLUDER_SPECS.size()
	for index: int in OCCLUDER_SPECS.size():
		var spec: Dictionary = OCCLUDER_SPECS[index]
		var position: Vector3 = spec.get("position", Vector3.ZERO) as Vector3
		var size: Vector3 = spec.get("size", Vector3.ONE) as Vector3
		var yaw := float(spec.get("yaw", 0.0))
		multimesh.set_instance_transform(index, Transform3D(
			Basis(Vector3.UP, yaw).scaled(size), position))
	var visual := MultiMeshInstance3D.new()
	visual.name = "RootSightlineOccluders"
	visual.multimesh = multimesh
	visual.material_override = _material(colour, 0.96)
	visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(visual)

	_occluder_body = StaticBody3D.new()
	_occluder_body.name = "ExplorationOccluders"
	_occluder_body.collision_layer = 1
	_occluder_body.collision_mask = 0
	add_child(_occluder_body)
	for spec: Dictionary in OCCLUDER_SPECS:
		var position: Vector3 = spec.get("position", Vector3.ZERO) as Vector3
		var size: Vector3 = spec.get("size", Vector3.ONE) as Vector3
		var yaw := float(spec.get("yaw", 0.0))
		var collision := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = size
		collision.shape = box
		collision.position = position
		collision.rotation.y = yaw
		_occluder_body.add_child(collision)


func _build_landmark_silhouettes(colour: Color) -> void:
	var transforms: Array[Transform3D] = []
	var arch := LANDMARK_DEFINITIONS[0]["position"] as Vector3
	transforms.append(Transform3D(Basis.IDENTITY.scaled(Vector3(1.2, 8.0, 1.2)),
		arch + Vector3(-3.4, 4.0, 0.0)))
	transforms.append(Transform3D(Basis.IDENTITY.scaled(Vector3(1.2, 4.8, 1.2)),
		arch + Vector3(3.4, 2.4, 0.0)))
	transforms.append(Transform3D(Basis(Vector3.FORWARD, -0.18).scaled(
		Vector3(7.8, 1.1, 1.3)), arch + Vector3(-0.4, 7.2, 0.0)))

	var tower := LANDMARK_DEFINITIONS[1]["position"] as Vector3
	transforms.append(Transform3D(Basis.IDENTITY.scaled(Vector3(5.5, 11.5, 5.5)),
		tower + Vector3.UP * 5.75))
	transforms.append(Transform3D(Basis.IDENTITY.scaled(Vector3(7.2, 0.7, 7.2)),
		tower + Vector3.UP * 11.5))

	var dead_tree := LANDMARK_DEFINITIONS[2]["position"] as Vector3
	transforms.append(Transform3D(Basis.IDENTITY.scaled(Vector3(3.8, 24.0, 3.8)),
		dead_tree + Vector3.UP * 12.0))
	transforms.append(Transform3D(Basis(Vector3.FORWARD, 0.62).scaled(
		Vector3(13.0, 1.5, 1.5)), dead_tree + Vector3(-4.5, 19.0, 0.0)))
	transforms.append(Transform3D(Basis(Vector3.BACK, 0.78).scaled(
		Vector3(10.0, 1.3, 1.3)), dead_tree + Vector3(4.0, 15.5, 0.0)))

	var mesh := BoxMesh.new()
	mesh.size = Vector3.ONE
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = mesh
	multimesh.instance_count = transforms.size()
	for index: int in transforms.size():
		multimesh.set_instance_transform(index, transforms[index])
	var visual := MultiMeshInstance3D.new()
	visual.name = "ReachableLandmarkSilhouettes"
	visual.multimesh = multimesh
	visual.material_override = _material(colour, 0.88)
	visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(visual)


func _build_shortcut(options: Dictionary) -> void:
	_shortcut = ShortcutScript.new() as ExplorationShortcut
	_shortcut.name = "PortaoDaArvore"
	_shortcut.position = SHORTCUT_GATE_POSITION
	add_child(_shortcut)
	_shortcut.configure({
		"id": String(SHORTCUT_ID),
		"interaction_action": "interact",
		"interaction_radius_m": float(options.get("interaction_radius_m", 2.6)),
		"inside_direction": SHORTCUT_INSIDE_DIRECTION,
		"wood_colour": String(options.get("wood_colour", "#30261f")),
		"metal_colour": String(options.get("metal_colour", "#766b57")),
	})
	_shortcut.shortcut_opened.connect(_on_shortcut_opened)


func _on_shortcut_opened(opened_id: StringName) -> void:
	shortcut_opened.emit(opened_id)


func _polyline_length(points: Array) -> float:
	var result := 0.0
	for index: int in points.size() - 1:
		result += (points[index] as Vector3).distance_to(points[index + 1] as Vector3)
	return result


func _distance_to_segment(point: Vector3, start: Vector3, finish: Vector3) -> float:
	var delta := finish - start
	var fraction := clampf((point - start).dot(delta) / maxf(delta.length_squared(), 0.001), 0.0, 1.0)
	return point.distance_to(start + delta * fraction)


func _material(colour: Color, roughness: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = colour
	material.roughness = roughness
	material.metallic = 0.0
	return material


func _option_colour(options: Dictionary, key: String, fallback: Color) -> Color:
	var html := String(options.get(key, ""))
	return Color(html) if html.is_valid_html_color() else fallback
