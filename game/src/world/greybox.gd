class_name Greybox
extends Node3D
## Constroi a zona navegavel e veste-a com a seleccao CC0 da Fatia 1.
##
## Tecnica de desempenho central (Lei 4): as arvores e as pedras vao num
## MultiMeshInstance3D cada — centenas de objectos, UM draw call. Numa Iris Xe
## o numero de draw calls e o que mata, nao os poligonos.
##
## A nevoa faz duas coisas ao mesmo tempo: e o tom de Brumal e e o que deixa
## cortar a distancia de visao sem se ver o corte.

const SEED := 20260731  # fixo: duas medicoes de desempenho tem de ver o mesmo mundo

const TREE_OAK: PackedScene = preload("res://assets/models/environment/brumal/tree_oak_dark.glb")
const TREE_TALL: PackedScene = preload("res://assets/models/environment/brumal/tree_tall_dark.glb")
const TREE_THIN: PackedScene = preload("res://assets/models/environment/brumal/tree_thin_dark.glb")
const ROCK_LARGE_A: PackedScene = preload("res://assets/models/environment/brumal/rock_largeA.glb")
const ROCK_LARGE_C: PackedScene = preload("res://assets/models/environment/brumal/rock_largeC.glb")
const ROCK_SMALL_A: PackedScene = preload("res://assets/models/environment/brumal/rock_smallA.glb")
const GROUND_GRASS: PackedScene = preload("res://assets/models/environment/brumal/ground_grass.glb")
const GROUND_PATH: PackedScene = preload("res://assets/models/environment/brumal/ground_pathStraight.glb")
const DETAIL_GRASS: PackedScene = preload("res://assets/models/environment/brumal/details/grass_leafs.glb")
const DETAIL_BUSH: PackedScene = preload("res://assets/models/environment/brumal/details/plant_bushSmall.glb")
const DETAIL_MUSHROOM: PackedScene = preload("res://assets/models/environment/brumal/details/mushroom_redGroup.glb")
const DETAIL_LOG: PackedScene = preload("res://assets/models/environment/brumal/details/log_large.glb")
const DETAIL_STONE: PackedScene = preload("res://assets/models/environment/brumal/details/stone_smallFlatA.glb")
const DETAIL_FLOWER: PackedScene = preload("res://assets/models/environment/brumal/details/flower_yellowB.glb")
const DUNGEON_WALL: PackedScene = preload("res://assets/models/environment/toca/wall.gltf")
const DUNGEON_WALL_BROKEN: PackedScene = preload("res://assets/models/environment/toca/wall_broken.gltf")
const DUNGEON_DOORWAY: PackedScene = preload("res://assets/models/environment/toca/wall_doorway.gltf")
const DUNGEON_FLOOR: PackedScene = preload("res://assets/models/environment/toca/floor_tile_large.gltf")
const DUNGEON_PILLAR: PackedScene = preload("res://assets/models/environment/toca/pillar.gltf")
const DUNGEON_RUBBLE: PackedScene = preload("res://assets/models/environment/toca/rubble_large.gltf")
const DUNGEON_TORCH: PackedScene = preload("res://assets/models/environment/toca/torch_mounted.gltf")

var preset: Dictionary = {}
var palette: Dictionary = {}
## A ficha do bioma (data/biomes.json ← spec/49-biomas.md). E daqui que vem a
## cor da luz, da nevoa e do acento — spec/47 §4, passo 1: a paleta da ficha
## e configuracao do motor, nao decoracao.
var biome: Dictionary = {}
var _rng := RandomNumberGenerator.new()

## Pontos de interesse que o main usa para colocar o jogador e os inimigos.
var spawn_point := Vector3.ZERO
var arena_center := Vector3.ZERO
var lair_entrance := Vector3.ZERO
var path_points: Array[Vector3] = []


func build(p_preset: Dictionary, p_palette: Dictionary, layout: String, biome_id: String = "brumal") -> void:
	preset = p_preset
	palette = p_palette
	biome = GameData.biome(biome_id)  # a arena tambem vive em Brumal
	_rng.seed = SEED
	_build_environment()
	_build_light()
	_build_vignette()
	match layout:
		"arena":
			_build_arena()
		_:
			_build_brumal()


# --- Ambiente -----------------------------------------------------------------

func _build_environment() -> void:
	var env := Environment.new()
	# A cor da nevoa vem da FICHA DO BIOMA (spec/49 §2, cor 2); o palette de
	# estados fica como rede de seguranca se a ficha faltar.
	var fog_colour := _biome_colour("nevoa", _colour("fog"))

	# Ceu em gradiente (ProceduralSky e quase gratis): horizonte claro a fundir
	# com a nevoa, zenite escuro — profundidade sem custar um shader proprio.
	# Zenite e chao DERIVAM da nevoa e do chao — nada de cor chapada em codigo.
	var sky_mat := ProceduralSkyMaterial.new()
	sky_mat.sky_top_color = fog_colour.darkened(0.62)
	sky_mat.sky_horizon_color = fog_colour.lightened(0.10)
	sky_mat.ground_bottom_color = _colour("ground").darkened(0.32)
	sky_mat.ground_horizon_color = fog_colour
	sky_mat.sun_angle_max = 25.0
	sky_mat.sun_curve = 0.12
	var sky := Sky.new()
	sky.sky_material = sky_mat
	env.background_mode = Environment.BG_SKY
	env.sky = sky
	env.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	env.ambient_light_energy = 0.75

	# Nevoa de profundidade simples. NAO volumetrica — a volumetrica e cara de mais
	# para graficos integrados e nao acrescenta nada a leitura do combate.
	# aerial_perspective funde a distancia com o CEU em vez de com uma cor
	# chapada — e o que separa "nevoa de jogo antigo" de atmosfera.
	env.fog_enabled = true
	env.fog_light_color = fog_colour
	env.fog_light_energy = 1.0
	env.fog_density = float(preset.get("fog_density", 0.045))
	env.fog_aerial_perspective = 0.72
	env.fog_sky_affect = 0.18

	# Gradacao barata do Environment: comprime a gama lavada da nevoa sem
	# acrescentar um passe 3D. Os valores pertencem ao preset para a Lei 4
	# poder reduzi-los sem bifurcar o mundo.
	env.adjustment_enabled = true
	env.adjustment_brightness = float(preset.get("grade_brightness", 0.95))
	env.adjustment_contrast = float(preset.get("grade_contrast", 1.14))
	env.adjustment_saturation = float(preset.get("grade_saturation", 0.82))

	# Tudo o que e caro fica desligado, explicitamente.
	env.ssao_enabled = false
	env.ssil_enabled = false
	env.sdfgi_enabled = false
	env.glow_enabled = false
	env.volumetric_fog_enabled = false

	var world_env := WorldEnvironment.new()
	world_env.name = "WorldEnvironment"
	world_env.environment = env
	add_child(world_env)


## Vinheta subtil num CanvasLayer abaixo do HUD. E um unico quad sem textura;
## escurece apenas os extremos e conserva o centro onde se le o combate.
func _build_vignette() -> void:
	var strength := float(preset.get("vignette_strength", 0.12))
	if strength <= 0.0:
		return
	var layer := CanvasLayer.new()
	layer.name = "ScreenGrade"
	layer.layer = 10
	var rect := ColorRect.new()
	rect.name = "Vignette"
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var shader := Shader.new()
	shader.code = """
shader_type canvas_item;
render_mode unshaded;
uniform float strength : hint_range(0.0, 0.3) = 0.12;
void fragment() {
	vec2 p = UV * 2.0 - 1.0;
	p.x *= 0.72;
	float edge = smoothstep(0.34, 1.08, dot(p, p));
	COLOR = vec4(0.015, 0.018, 0.022, edge * strength);
}
"""
	var material := ShaderMaterial.new()
	material.shader = shader
	material.set_shader_parameter("strength", strength)
	rect.material = material
	layer.add_child(rect)
	add_child(layer)


func _build_light() -> void:
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	# Sol baixo e quente (fim de tarde) contra nevoa fria — o contraste de
	# temperatura e o truque de atmosfera mais barato que existe.
	sun.rotation_degrees = Vector3(-38, 42, 0)
	sun.light_energy = 1.15
	sun.light_color = _biome_colour("luz", Color(1.0, 0.92, 0.80))  # cor 1 da ficha (spec/49 §2)
	sun.shadow_enabled = bool(preset.get("shadows", true))
	sun.directional_shadow_max_distance = float(preset.get("shadow_distance", 30.0))
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL  # 1 cascata = o mais barato
	add_child(sun)


# --- Materiais ----------------------------------------------------------------

func _colour(key: String) -> Color:
	return Color(String(palette.get(key, "#ff00ff")))


## Cor da paleta do bioma (luz / nevoa / acento — spec/49 §2), com recurso.
func _biome_colour(key: String, fallback: Color) -> Color:
	var pal: Dictionary = biome.get("paleta", {}) as Dictionary
	var c := String(pal.get(key, ""))
	return Color(c) if c.is_valid_html_color() else fallback


func _material(key: String) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = _colour(key)
	var roughness_by_surface := {
		"ground": 0.94,
		"trunk": 0.86,
		"canopy": 0.90,
		"rock": 0.72,
	}
	m.roughness = float(roughness_by_surface.get(key, 0.82))
	m.metallic = 0.0
	return m


## Extrai uma malha do modulo importado e duplica apenas os materiais. Assim
## cada familia tem uma rugosidade fisica propria sem alterar o pack CC0 nem
## criar um material por instancia.
func _asset_mesh(scene: PackedScene, roughness: float, tint := Color.WHITE,
	specular_enabled := true) -> Mesh:
	var root_node := scene.instantiate()
	var source := _find_mesh_instance(root_node)
	if source == null:
		root_node.free()
		return null
	var mesh := source.mesh.duplicate() as Mesh
	for surface: int in mesh.get_surface_count():
		var source_material := mesh.surface_get_material(surface)
		var material: Material
		if source_material != null:
			material = source_material.duplicate() as Material
		else:
			material = StandardMaterial3D.new()
		if material is StandardMaterial3D:
			var standard := material as StandardMaterial3D
			standard.roughness = roughness
			standard.metallic = 0.0
			standard.albedo_color *= tint
			if not specular_enabled:
				standard.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
		mesh.surface_set_material(surface, material)
	root_node.free()
	return mesh


func _find_mesh_instance(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node as MeshInstance3D
	for child: Node in node.get_children():
		var found := _find_mesh_instance(child)
		if found != null:
			return found
	return null


# --- Pecas --------------------------------------------------------------------

func _add_ground(size: Vector2, centre: Vector3) -> void:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(size.x, 1.0, size.y)
	var mi := MeshInstance3D.new()
	mi.name = "Ground"
	mi.mesh = mesh
	mi.material_override = _material("ground")
	mi.position = centre + Vector3(0, -0.5, 0)
	# O cubo fica apenas como fundo sem fendas. A lamina Kenney por cima traz
	# um material rugoso coerente e continua a custar uma unica instancia.
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	var grass_mesh := _asset_mesh(GROUND_GRASS, 0.94, Color("#56604c"), false)
	if grass_mesh != null:
		var grass := MeshInstance3D.new()
		grass.name = "KenneyGround"
		grass.mesh = grass_mesh
		grass.scale = Vector3(size.x, 1.0, size.y)
		grass.position = centre + Vector3(0, 0.012, 0)
		grass.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(grass)

	var body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = mesh.size
	shape.shape = box
	body.add_child(shape)
	body.position = mi.position
	add_child(body)


## Parede/bloco solido, com colisao. A base do greybox.
func _add_block(centre: Vector3, size: Vector3, colour_key: String, shadows := true, visible := true) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = _material(colour_key)
	mi.position = centre
	mi.visible = visible
	if not shadows:
		mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)

	var body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	body.add_child(shape)
	body.position = centre
	add_child(body)


## Muitas copias da mesma malha num so draw call.
func _add_multimesh(mesh: Mesh, transforms: Array[Transform3D], colour_key: String, shadows: bool, variation := 0.0) -> void:
	if transforms.is_empty():
		return
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.use_colors = variation > 0.0
	mm.instance_count = transforms.size()
	for i in transforms.size():
		mm.set_instance_transform(i, transforms[i])
		if variation > 0.0:
			# Tinta por instancia (gratis no MultiMesh): quebra o "carimbo" de
			# 200 arvores iguais sem acrescentar um unico poligono.
			var v := 1.0 + _rng.randf_range(-variation, variation)
			mm.set_instance_color(i, Color(
				v * (1.0 + _rng.randf_range(-0.05, 0.05)),
				v,
				v * (1.0 + _rng.randf_range(-0.04, 0.04))))

	var mat := _material(colour_key)
	if variation > 0.0:
		mat.vertex_color_use_as_albedo = true

	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.material_override = mat
	mmi.cast_shadow = (GeometryInstance3D.SHADOW_CASTING_SETTING_ON if shadows
		else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	add_child(mmi)


## MultiMesh que conserva os materiais importados; usado para Kenney/KayKit.
func _add_asset_multimesh(mesh: Mesh, transforms: Array, shadows: bool, node_name: String) -> void:
	if mesh == null or transforms.is_empty():
		return
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = transforms.size()
	for index: int in transforms.size():
		mm.set_instance_transform(index, transforms[index])
	var instances := MultiMeshInstance3D.new()
	instances.name = node_name
	instances.multimesh = mm
	instances.cast_shadow = (GeometryInstance3D.SHADOW_CASTING_SETTING_ON if shadows
		else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	add_child(instances)


func _build_path_visual() -> void:
	var path_mesh := _asset_mesh(GROUND_PATH, 0.90, Color("#76644f"), false)
	if path_mesh == null:
		return
	var tiles: Array[Transform3D] = []
	var tile_size := 3.5
	for index: int in path_points.size() - 1:
		var start := path_points[index]
		var finish := path_points[index + 1]
		var delta := finish - start
		var yaw := atan2(delta.x, delta.z)
		var count := maxi(1, ceili(delta.length() / tile_size))
		for tile: int in count:
			var t := (float(tile) + 0.5) / float(count)
			var basis := Basis(Vector3.UP, yaw).scaled(Vector3.ONE * tile_size)
			tiles.append(Transform3D(basis, start.lerp(finish, t) + Vector3(0, 0.025, 0)))
	_add_asset_multimesh(path_mesh, tiles, false, "KenneyPath")


# --- Layouts ------------------------------------------------------------------

## Arena limpa, para afinar combate sem o mundo a atrapalhar.
func _build_arena() -> void:
	_add_ground(Vector2(60, 60), Vector3.ZERO)
	spawn_point = Vector3(0, 0.1, 8)
	arena_center = Vector3.ZERO
	var wall := 30.0
	for i in 4:
		var a := float(i) * PI * 0.5
		_add_block(Vector3(sin(a) * wall, 1.5, cos(a) * wall), Vector3(62, 3, 2).rotated(Vector3.UP, a).abs(), "rock")


## Brumal: floresta fechada de bruma, com um caminho que leva a boca da Toca.
func _build_brumal() -> void:
	_add_ground(Vector2(220, 220), Vector3.ZERO)

	# O caminho — uma curva simples com ~700 m andados de ponta a ponta.
	path_points = [
		Vector3(0, 0, 95),
		Vector3(-14, 0, 68),
		Vector3(8, 0, 40),
		Vector3(-6, 0, 12),
		Vector3(16, 0, -16),
		Vector3(-4, 0, -44),
		Vector3(-20, 0, -70),
	]
	spawn_point = path_points[0] + Vector3(0, 0.1, 0)
	lair_entrance = path_points[path_points.size() - 1]
	arena_center = lair_entrance + Vector3(0, 0, -26)

	_build_path_visual()
	_scatter_forest()
	_scatter_ground_details()
	_build_lair()


func _distance_to_path(p: Vector3) -> float:
	var best := 9999.0
	for i in path_points.size() - 1:
		best = minf(best, _distance_to_segment(p, path_points[i], path_points[i + 1]))
	return best


func _distance_to_segment(p: Vector3, a: Vector3, b: Vector3) -> float:
	var ab := b - a
	var t := clampf((p - a).dot(ab) / maxf(ab.length_squared(), 0.001), 0.0, 1.0)
	return p.distance_to(a + ab * t)


func _scatter_forest() -> void:
	var tree_meshes: Array[Mesh] = [
		_asset_mesh(TREE_OAK, 0.88, Color("#52614a"), false),
		_asset_mesh(TREE_TALL, 0.88, Color("#52614a"), false),
		_asset_mesh(TREE_THIN, 0.88, Color("#52614a"), false),
	]
	var rock_meshes: Array[Mesh] = [
		_asset_mesh(ROCK_LARGE_A, 0.70, Color("#6a6f70")),
		_asset_mesh(ROCK_LARGE_C, 0.70, Color("#6a6f70")),
		_asset_mesh(ROCK_SMALL_A, 0.74, Color("#727777")),
	]
	var trees: Array[Array] = [[], [], []]
	var rocks: Array[Array] = [[], [], []]
	var trunk_bodies := StaticBody3D.new()
	trunk_bodies.name = "TreeCollision"

	var wanted: int = int(preset.get("tree_count", 200))
	var tries := 0
	var tree_count := 0
	while tree_count < wanted and tries < wanted * 12:
		tries += 1
		var p := Vector3(_rng.randf_range(-105, 105), 0, _rng.randf_range(-105, 105))
		# O caminho tem de ficar livre — a floresta e fechada, o caminho nao.
		if _distance_to_path(p) < 4.5:
			continue
		if p.distance_to(arena_center) < 18.0:
			continue
		var scale := _rng.randf_range(0.8, 1.35)
		var yaw := _rng.randf_range(0, TAU)
		var family := tree_count % tree_meshes.size()
		var visual_scale := scale * 4.2
		trees[family].append(Transform3D(
			Basis(Vector3.UP, yaw).scaled(Vector3.ONE * visual_scale), p))
		tree_count += 1

		# A colisao conserva exactamente a largura e posicao do greybox anterior;
		# a malha importada e apenas a pele da arvore.
		var col := CollisionShape3D.new()
		var cyl := CylinderShape3D.new()
		cyl.radius = 0.32 * scale
		cyl.height = 4.2 * scale
		col.shape = cyl
		col.position = p + Vector3(0, 2.1 * scale, 0)
		trunk_bodies.add_child(col)

	var rocks_wanted: int = int(preset.get("rock_count", 60))
	var rock_count := 0
	for _i in rocks_wanted:
		var p := Vector3(_rng.randf_range(-100, 100), 0, _rng.randf_range(-100, 100))
		if _distance_to_path(p) < 3.0:
			continue
		var s := _rng.randf_range(0.6, 1.8)
		var family := rock_count % rock_meshes.size()
		var visual_scale := s * 1.8
		rocks[family].append(Transform3D(
			Basis(Vector3.UP, _rng.randf_range(0, TAU)).scaled(
				Vector3(visual_scale, visual_scale * 0.82, visual_scale)),
			p + Vector3(0, 0.025, 0)))
		rock_count += 1

	add_child(trunk_bodies)
	for family: int in tree_meshes.size():
		_add_asset_multimesh(tree_meshes[family], trees[family], false,
			"KenneyTrees%d" % family)
	for family: int in rock_meshes.size():
		_add_asset_multimesh(rock_meshes[family], rocks[family], false,
			"KenneyRocks%d" % family)


## Seis familias de detalhe, cada uma num MultiMesh. Assim centenas de folhas,
## seixos e cogumelos acrescentam seis draw calls, nao centenas de Nodes. As
## malhas sao minimas (só estas seis vieram do pack de 785 modelos) e sem sombra.
func _scatter_ground_details() -> void:
	var families := [
		{
			"name": "GroundLeafGrass", "scene": DETAIL_GRASS,
			"count": int(preset.get("grass_detail_count", 520)),
			"path_clearance": 1.85, "scale_min": 0.72, "scale_max": 1.45,
			"path_bias": 0.78, "roughness": 0.96, "tint": Color("#7d8971"),
		},
		{
			"name": "GroundBushes", "scene": DETAIL_BUSH,
			"count": int(preset.get("bush_detail_count", 120)),
			"path_clearance": 2.35, "scale_min": 0.72, "scale_max": 1.35,
			"path_bias": 0.72, "roughness": 0.94, "tint": Color("#748064"),
		},
		{
			"name": "GroundMushrooms", "scene": DETAIL_MUSHROOM,
			"count": int(preset.get("mushroom_count", 54)),
			"path_clearance": 1.65, "scale_min": 0.70, "scale_max": 1.15,
			"path_bias": 0.82, "roughness": 0.90, "tint": Color.WHITE,
		},
		{
			"name": "FallenLogs", "scene": DETAIL_LOG,
			"count": int(preset.get("fallen_log_count", 14)),
			"path_clearance": 3.1, "scale_min": 0.80, "scale_max": 1.35,
			"path_bias": 0.54, "roughness": 0.92, "tint": Color("#8c7b6a"),
		},
		{
			"name": "GroundPebbles", "scene": DETAIL_STONE,
			"count": int(preset.get("pebble_count", 210)),
			"path_clearance": 1.45, "scale_min": 0.65, "scale_max": 1.50,
			"path_bias": 0.62, "roughness": 0.86, "tint": Color("#8a8c86"),
		},
		{
			"name": "GroundFlowers", "scene": DETAIL_FLOWER,
			"count": int(preset.get("flower_count", 70)),
			"path_clearance": 1.75, "scale_min": 0.72, "scale_max": 1.22,
			"path_bias": 0.78, "roughness": 0.92, "tint": Color("#d0c29d"),
		},
	]
	for family: Dictionary in families:
		var transforms := _scatter_detail_transforms(
			int(family["count"]), float(family["path_clearance"]),
			float(family["scale_min"]), float(family["scale_max"]),
			float(family["path_bias"]))
		var mesh := _asset_mesh(family["scene"] as PackedScene,
			float(family["roughness"]), family["tint"] as Color, false)
		_add_asset_multimesh(mesh, transforms, false, String(family["name"]))


func _scatter_detail_transforms(count: int, path_clearance: float,
	scale_min: float, scale_max: float, path_bias: float) -> Array[Transform3D]:
	var result: Array[Transform3D] = []
	var tries := 0
	while result.size() < count and tries < count * 12:
		tries += 1
		var p: Vector3
		if _rng.randf() < path_bias:
			var segment := _rng.randi_range(0, path_points.size() - 2)
			var start := path_points[segment]
			var finish := path_points[segment + 1]
			var forward := (finish - start).normalized()
			var side := Vector3(-forward.z, 0.0, forward.x)
			var centre := start.lerp(finish, _rng.randf())
			var signed_offset := _rng.randf_range(path_clearance + 0.25, 13.0)
			if _rng.randf() < 0.5:
				signed_offset *= -1.0
			p = centre + side * signed_offset + forward * _rng.randf_range(-2.5, 2.5)
			p.y = 0.025
		else:
			p = Vector3(_rng.randf_range(-103, 103), 0.025,
				_rng.randf_range(-103, 103))
		if _distance_to_path(p) < path_clearance:
			continue
		# O centro da arena tem de conservar a silhueta de combate. Os seus
		# detritos são colocados de propósito em _build_lair, junto às paredes.
		if p.distance_to(arena_center) < 18.0:
			continue
		var s := _rng.randf_range(scale_min, scale_max)
		result.append(Transform3D(
			Basis(Vector3.UP, _rng.randf_range(0.0, TAU)).scaled(
				Vector3(s, _rng.randf_range(scale_min, scale_max), s)), p))
	return result


## A Toca: a geometria de colisao continua simples e invisivel; os modulos
## KayKit fazem a leitura visual da entrada, salas e arena.
func _build_lair() -> void:
	var e := lair_entrance
	var dungeon_tint := Color("#aaa69c")
	var wall_mesh := _asset_mesh(DUNGEON_WALL, 0.74, dungeon_tint)
	var broken_mesh := _asset_mesh(DUNGEON_WALL_BROKEN, 0.78, dungeon_tint)
	var doorway_mesh := _asset_mesh(DUNGEON_DOORWAY, 0.76, dungeon_tint)
	var floor_mesh := _asset_mesh(DUNGEON_FLOOR, 0.88, dungeon_tint)
	var pillar_mesh := _asset_mesh(DUNGEON_PILLAR, 0.70, dungeon_tint)
	var rubble_mesh := _asset_mesh(DUNGEON_RUBBLE, 0.82, dungeon_tint)
	var walls: Array[Transform3D] = []
	var broken_walls: Array[Transform3D] = []
	var doorways: Array[Transform3D] = []
	var floors: Array[Transform3D] = []
	var pillars: Array[Transform3D] = []
	var rubble: Array[Transform3D] = []
	var arena_pebbles: Array[Transform3D] = []
	var arena_beams: Array[Transform3D] = []

	# A arvore morta que marca a fenda — o unico ponto de referencia.
	_add_block(e + Vector3(2.4, 3.0, 1.2), Vector3(0.5, 6.0, 0.5), "trunk", true, false)
	_add_asset_multimesh(_asset_mesh(TREE_THIN, 0.92, Color("#5a5045")), [Transform3D(
		Basis(Vector3.UP, -0.45).scaled(Vector3.ONE * 4.5),
		e + Vector3(2.4, 0.0, 1.2))], false, "DeadTreeLandmark")

	# Fenda na rocha: duas paredes com uma abertura no meio.
	_add_block(e + Vector3(-4.5, 2.0, 0), Vector3(6, 4, 1.5), "rock", true, false)
	_add_block(e + Vector3(4.5, 2.0, 0), Vector3(6, 4, 1.5), "rock", true, false)
	broken_walls.append(Transform3D(Basis.IDENTITY.scaled(Vector3(1.5, 1.0, 1.5)),
		e + Vector3(-4.5, 0, 0)))
	walls.append(Transform3D(Basis.IDENTITY.scaled(Vector3(1.5, 1.0, 1.5)),
		e + Vector3(4.5, 0, 0)))
	doorways.append(Transform3D(Basis.IDENTITY.scaled(Vector3(1.0, 1.0, 1.5)), e))

	# Corredor + 3 salas, a descer para a arena.
	var z := e.z - 6.0
	for room in 3:
		var w := 9.0 + float(room) * 2.0
		var left := Vector3(-w * 0.5, 0.0, z - 5.0)
		var right := Vector3(w * 0.5, 0.0, z - 5.0)
		_add_block(left + Vector3.UP * 2.0, Vector3(1.5, 4, 12), "rock", true, false)
		_add_block(right + Vector3.UP * 2.0, Vector3(1.5, 4, 12), "rock", true, false)
		var side_basis := Basis(Vector3.UP, PI * 0.5).scaled(Vector3(3.0, 1.0, 1.5))
		walls.append(Transform3D(side_basis, left))
		walls.append(Transform3D(side_basis, right))
		z -= 11.0

	# Arena do Vorgar: circular em blocos.
	var c := arena_center
	var radius := 15.0
	for i in 20:
		var a := TAU * float(i) / 20.0
		var at := c + Vector3(sin(a) * radius, 0.0, cos(a) * radius)
		_add_block(at + Vector3.UP * 2.5,
			Vector3(5.5, 5, 2.0).rotated(Vector3.UP, -a).abs(), "rock", true, false)
		walls.append(Transform3D(
			Basis(Vector3.UP, a).scaled(Vector3(1.375, 1.25, 2.0)), at))

	# Pedra sob os pes: uma grelha pequena, instanciada num unico MultiMesh.
	for zi in 8:
		for xi in 3:
			floors.append(Transform3D(Basis.IDENTITY,
				e + Vector3((float(xi) - 1.0) * 4.0, 0.08, -2.0 - float(zi) * 4.0)))
	for x in range(-12, 13, 4):
		for zz in range(-12, 13, 4):
			if Vector2(float(x), float(zz)).length() <= 13.0:
				floors.append(Transform3D(Basis.IDENTITY, c + Vector3(x, 0.08, zz)))
	for a in [0.25 * PI, 0.75 * PI, 1.25 * PI, 1.75 * PI]:
		pillars.append(Transform3D(Basis(Vector3.UP, a).scaled(Vector3(0.9, 1.25, 0.9)),
			c + Vector3(sin(a) * 11.0, 0.0, cos(a) * 11.0)))
	for at in [
		e + Vector3(-2.8, 0.02, -7.0),
		e + Vector3(3.1, 0.02, -17.0),
		c + Vector3(-6.0, 0.02, 5.0),
		c + Vector3(7.0, 0.02, -4.0),
	]:
		rubble.append(Transform3D(
			Basis(Vector3.UP, _rng.randf_range(0, TAU)).scaled(Vector3.ONE * 0.34), at))
	# A área de luta fica livre num raio de 8 m. A desordem conta a história nas
	# margens: pedra caída das paredes e traves partidas, sempre em MultiMesh.
	for index in 18:
		var angle := TAU * float(index) / 18.0 + _rng.randf_range(-0.12, 0.12)
		var radius_at := _rng.randf_range(10.0, 13.2)
		var at := c + Vector3(sin(angle) * radius_at, 0.025, cos(angle) * radius_at)
		var rubble_scale := _rng.randf_range(0.18, 0.40)
		rubble.append(Transform3D(
			Basis(Vector3.UP, _rng.randf_range(0.0, TAU)).scaled(
				Vector3.ONE * rubble_scale), at))
	for index in 72:
		var angle := _rng.randf_range(0.0, TAU)
		var radius_at := sqrt(_rng.randf_range(8.0 * 8.0, 13.5 * 13.5))
		var s := _rng.randf_range(0.45, 1.15)
		arena_pebbles.append(Transform3D(
			Basis(Vector3.UP, _rng.randf_range(0.0, TAU)).scaled(
				Vector3(s, _rng.randf_range(0.55, 0.90), s)),
			c + Vector3(sin(angle) * radius_at, 0.11, cos(angle) * radius_at)))
	for index in 7:
		var angle := TAU * float(index) / 7.0 + _rng.randf_range(-0.20, 0.20)
		var s := _rng.randf_range(0.72, 1.12)
		arena_beams.append(Transform3D(
			Basis(Vector3.UP, angle + PI * 0.5).scaled(Vector3.ONE * s),
			c + Vector3(sin(angle) * _rng.randf_range(10.4, 12.6), 0.10,
				cos(angle) * _rng.randf_range(10.4, 12.6))))

	_add_asset_multimesh(wall_mesh, walls, bool(preset.get("shadows", true)), "KayKitWalls")
	_add_asset_multimesh(broken_mesh, broken_walls, bool(preset.get("shadows", true)), "KayKitBrokenWalls")
	_add_asset_multimesh(doorway_mesh, doorways, bool(preset.get("shadows", true)), "KayKitDoorways")
	_add_asset_multimesh(floor_mesh, floors, false, "KayKitFloors")
	_add_asset_multimesh(pillar_mesh, pillars, bool(preset.get("shadows", true)), "KayKitPillars")
	_add_asset_multimesh(rubble_mesh, rubble, false, "KayKitRubble")
	_add_asset_multimesh(_asset_mesh(DETAIL_STONE, 0.88, Color("#898982"), false),
		arena_pebbles, false, "ArenaPebbles")
	_add_asset_multimesh(_asset_mesh(DETAIL_LOG, 0.94, Color("#746456"), false),
		arena_beams, false, "ArenaBrokenBeams")

	# Tochas: 4 na arena + 1 na fenda de entrada. Luz quente pontual contra a
	# nevoa fria — mood de souls por 5 luzes omni sem sombra (barato em Iris Xe).
	# A da entrada tambem GUIA: luz chama o jogador, nao setas.
	var torch_spots: Array[Vector3] = [
		c + Vector3(9, 0, 9), c + Vector3(-9, 0, 9),
		c + Vector3(9, 0, -9), c + Vector3(-9, 0, -9),
		e + Vector3(-1.2, 0, 0.8),
	]
	var torch_visuals: Array[Transform3D] = []
	for spot in torch_spots:
		var yaw := atan2((c - spot).x, (c - spot).z)
		torch_visuals.append(Transform3D(
			Basis(Vector3.UP, yaw).scaled(Vector3.ONE * 1.25),
			spot + Vector3(0, 2.15, 0)))
		_add_torch(spot)
	_add_asset_multimesh(_asset_mesh(DUNGEON_TORCH, 0.58), torch_visuals, false,
		"KayKitTorches")


func _add_torch(at: Vector3) -> void:
	var flame := MeshInstance3D.new()
	var fm := BoxMesh.new()
	fm.size = Vector3(0.22, 0.30, 0.22)
	flame.mesh = fm
	# A chama e a luz da tocha sao o ACENTO do bioma (spec/49 §2, cor 3) —
	# em Brumal, o ambar das tochas e a assinatura da zona.
	var accent := _biome_colour("acento", Color(1.0, 0.66, 0.30))
	var fmat := StandardMaterial3D.new()
	fmat.emission_enabled = true
	fmat.emission = accent
	fmat.emission_energy_multiplier = 2.6
	fmat.albedo_color = accent.lightened(0.20)
	flame.material_override = fmat
	flame.position = at + Vector3(0, 2.52, 0)
	add_child(flame)

	var light := OmniLight3D.new()
	light.light_color = accent
	light.light_energy = 2.4
	light.omni_range = 11.0
	light.shadow_enabled = false  # sombras de omni sao caras; a luz chega
	light.position = at + Vector3(0, 2.48, 0)
	add_child(light)
