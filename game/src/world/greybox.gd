class_name Greybox
extends Node3D
## Constroi a zona navegavel e veste-a com a seleccao CC0 da Fatia 1.
##
## Tecnica de desempenho central (Lei 4): as arvores e as pedras vao num
## MultiMeshInstance3D por familia, impedindo centenas de Nodes e draw calls.
## A medicao actual mostra que nem os 18-33 draws nem as camadas de chao sao o
## estrangulamento; qualquer nova fragmentacao continua a exigir A/B.
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
const LAIR_SCRIPT := preload("res://src/world/lair.gd")

var preset: Dictionary = {}
var palette: Dictionary = {}
## A ficha do bioma (data/biomes.json ← spec/49-biomas.md). E daqui que vem a
## cor da luz, da nevoa e do acento — spec/47 §4, passo 1: a paleta da ficha
## e configuracao do motor, nao decoracao.
var biome: Dictionary = {}
var _rng := RandomNumberGenerator.new()
var _ground_detail_selection := "all"
var _ground_detail_chunk_size := 0.0
var _ground_detail_shared_material: StandardMaterial3D

## Pontos de interesse que o main usa para colocar o jogador e os inimigos.
var spawn_point := Vector3.ZERO
var arena_center := Vector3.ZERO
var lair_entrance := Vector3.ZERO
var path_points: Array[Vector3] = []
var map_path_segments: Array = []
var rest_point := Vector3.ZERO
var camp_point := Vector3.ZERO
## Pontos que o mapa pode registar. A posicao existe no runtime; nome/tipo so
## aparecem depois de o jogador chegar perto, segundo a regra do spec/57.
var map_landmarks: Array[Dictionary] = []


func build(p_preset: Dictionary, p_palette: Dictionary, layout: String, biome_id: String = "brumal") -> void:
	preset = p_preset
	palette = p_palette
	biome = GameData.biome(biome_id)  # a arena tambem vive em Brumal
	_parse_ground_detail_probe_args()
	_apply_presentation_probe_args()
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

func _add_ground(size: Vector2, centre: Vector3, passage := Rect2()) -> void:
	var panels := _ground_panels(size, centre, passage)
	var mesh := BoxMesh.new()
	mesh.size = Vector3.ONE
	var ground_multimesh := MultiMesh.new()
	ground_multimesh.transform_format = MultiMesh.TRANSFORM_3D
	ground_multimesh.mesh = mesh
	ground_multimesh.instance_count = panels.size()
	for index: int in panels.size():
		var panel := panels[index]
		ground_multimesh.set_instance_transform(index, Transform3D(
			Basis.IDENTITY.scaled(Vector3(panel.size.x, mesh.size.y, panel.size.y)),
			Vector3(panel.get_center().x, centre.y - mesh.size.y * 0.5,
				panel.get_center().y)))
	var mi := MultiMeshInstance3D.new()
	mi.name = "Ground"
	mi.multimesh = ground_multimesh
	mi.material_override = _material("ground")
	# O cubo fica apenas como fundo sem fendas. A lamina Kenney por cima traz
	# um material rugoso coerente e continua a custar uma unica instancia.
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)
	var grass_mesh := _asset_mesh(GROUND_GRASS, 0.94, Color("#56604c"), false)
	if grass_mesh != null:
		var grass_multimesh := MultiMesh.new()
		grass_multimesh.transform_format = MultiMesh.TRANSFORM_3D
		grass_multimesh.mesh = grass_mesh
		grass_multimesh.instance_count = panels.size()
		for index: int in panels.size():
			var panel := panels[index]
			grass_multimesh.set_instance_transform(index, Transform3D(
				Basis.IDENTITY.scaled(Vector3(panel.size.x, 1.0, panel.size.y)),
				Vector3(panel.get_center().x, centre.y + 0.012, panel.get_center().y)))
		var grass := MultiMeshInstance3D.new()
		grass.name = "KenneyGround"
		grass.multimesh = grass_multimesh
		grass.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(grass)

	var body := StaticBody3D.new()
	body.name = "GroundCollision"
	for panel: Rect2 in panels:
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(panel.size.x, mesh.size.y, panel.size.y)
		shape.shape = box
		shape.position = Vector3(panel.get_center().x, centre.y - mesh.size.y * 0.5,
			panel.get_center().y)
		body.add_child(shape)
	add_child(body)


func _ground_panels(size: Vector2, centre: Vector3, passage: Rect2) -> Array[Rect2]:
	var full := Rect2(Vector2(centre.x, centre.z) - size * 0.5, size)
	if passage.size.x <= 0.0 or passage.size.y <= 0.0 or not full.intersects(passage):
		return [full]
	var cut := full.intersection(passage)
	var panels: Array[Rect2] = []
	if cut.position.y > full.position.y:
		panels.append(Rect2(full.position,
			Vector2(full.size.x, cut.position.y - full.position.y)))
	if cut.end.y < full.end.y:
		panels.append(Rect2(Vector2(full.position.x, cut.end.y),
			Vector2(full.size.x, full.end.y - cut.end.y)))
	if cut.position.x > full.position.x:
		panels.append(Rect2(Vector2(full.position.x, cut.position.y),
			Vector2(cut.position.x - full.position.x, cut.size.y)))
	if cut.end.x < full.end.x:
		panels.append(Rect2(Vector2(cut.end.x, cut.position.y),
			Vector2(full.end.x - cut.end.x, cut.size.y)))
	return panels


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


func _add_oriented_block(node_name: String, centre: Vector3, size: Vector3,
		colour_key: String, yaw: float, shadows := true, visible := true) -> void:
	var transform := Transform3D(Basis(Vector3.UP, yaw), centre)
	var mesh := BoxMesh.new()
	mesh.size = size
	var visual := MeshInstance3D.new()
	visual.name = node_name
	visual.mesh = mesh
	visual.material_override = _material(colour_key)
	visual.transform = transform
	visual.visible = visible
	if not shadows:
		visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(visual)
	var body := StaticBody3D.new()
	body.name = "%sCollision" % node_name
	var collision := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	collision.shape = box
	body.add_child(collision)
	body.transform = transform
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


## Controlos apenas de diagnóstico para medições A/B do mundo. Sem argumento,
## o jogo conserva as seis famílias e um único MultiMesh por família.
func _parse_ground_detail_probe_args() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--ground-details="):
			_ground_detail_selection = argument.trim_prefix("--ground-details=").to_lower()
		elif argument.begins_with("--ground-detail-chunk="):
			_ground_detail_chunk_size = maxf(
				0.0, argument.trim_prefix("--ground-detail-chunk=").to_float())


## O benchmark autoload aplica primeiro o modo pedido por --vsync. Esta sonda
## corre depois para comparar FIFO com um limitador sem depender de outro dono.
## O comportamento normal nao muda sem o argumento explicito.
func _apply_presentation_probe_args() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument == "--presentation-probe=cap60":
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
			Engine.max_fps = 60
		elif argument == "--presentation-probe=fifo-cap60":
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
			Engine.max_fps = 60
		elif argument == "--presentation-probe=fifo-cap120":
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
			Engine.max_fps = 120
		elif argument == "--presentation-probe=exclusive-fifo":
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
			Engine.max_fps = 0


func _ground_detail_enabled(family_id: String) -> bool:
	if _ground_detail_selection == "all":
		return true
	if _ground_detail_selection == "none":
		return false
	return family_id in _ground_detail_selection.split(",", false)


func _ground_probe_uses_shared_material() -> bool:
	return "--ground-detail-material=shared" in OS.get_cmdline_user_args()


func _shared_ground_detail_material() -> StandardMaterial3D:
	if _ground_detail_shared_material == null:
		_ground_detail_shared_material = StandardMaterial3D.new()
		_ground_detail_shared_material.albedo_color = Color("#7d8971")
		_ground_detail_shared_material.roughness = 0.94
		_ground_detail_shared_material.metallic = 0.0
		_ground_detail_shared_material.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	return _ground_detail_shared_material


func _apply_shared_ground_detail_material(mesh: Mesh) -> void:
	var material := _shared_ground_detail_material()
	for surface: int in mesh.get_surface_count():
		mesh.surface_set_material(surface, material)


func _add_ground_detail_multimesh(mesh: Mesh, transforms: Array, node_name: String) -> void:
	if _ground_detail_chunk_size <= 0.0:
		_add_asset_multimesh(mesh, transforms, false, node_name)
		return
	var chunks: Dictionary = {}
	for transform: Transform3D in transforms:
		var chunk := Vector2i(
			floori(transform.origin.x / _ground_detail_chunk_size),
			floori(transform.origin.z / _ground_detail_chunk_size))
		if not chunks.has(chunk):
			chunks[chunk] = []
		(chunks[chunk] as Array).append(transform)
	for chunk: Vector2i in chunks:
		_add_asset_multimesh(mesh, chunks[chunk] as Array, false,
			"%s_%d_%d" % [node_name, chunk.x, chunk.y])


func _build_path_visual() -> void:
	_build_path_underlay()
	var path_mesh := _asset_mesh(GROUND_PATH, 0.90, Color("#76644f"), false)
	if path_mesh == null:
		return
	var tiles: Array[Transform3D] = []
	var tile_size := 3.5
	for segment_value: Variant in map_path_segments:
		var segment := segment_value as PackedVector3Array
		for index: int in segment.size() - 1:
			var start := segment[index]
			var finish := segment[index + 1]
			var delta := finish - start
			var yaw := atan2(delta.x, delta.z)
			var count := maxi(1, ceili(delta.length() / tile_size))
			for tile: int in count:
				var t := (float(tile) + 0.5) / float(count)
				var basis := Basis(Vector3.UP, yaw).scaled(Vector3.ONE * tile_size)
				tiles.append(Transform3D(basis,
					start.lerp(finish, t) + Vector3(0, 0.035, 0)))
	_add_asset_multimesh(path_mesh, tiles, false, "KenneyPath")


## Uma unica faixa de terra larga por baixo dos mosaicos Kenney. Continua a ser
## um draw call, mas deixa de parecer dois carris finos no meio de 950 arvores.
func _build_path_underlay() -> void:
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var indices := PackedInt32Array()
	var width_m := float((GameData.world.get("orientation_runtime", {}) as Dictionary).get(
		"path_width_m", 6.0))
	for segment_value: Variant in map_path_segments:
		var segment := segment_value as PackedVector3Array
		for index: int in segment.size() - 1:
			var start := segment[index]
			var finish := segment[index + 1]
			var forward := (finish - start).normalized()
			var right := Vector3(forward.z, 0.0, -forward.x) * width_m * 0.5
			var base := vertices.size()
			vertices.append(start - right + Vector3.UP * 0.020)
			vertices.append(start + right + Vector3.UP * 0.020)
			vertices.append(finish + right + Vector3.UP * 0.020)
			vertices.append(finish - right + Vector3.UP * 0.020)
			for _normal: int in 4:
				normals.append(Vector3.UP)
			indices.append_array(PackedInt32Array([
				base, base + 1, base + 2, base, base + 2, base + 3]))
	if vertices.is_empty():
		return
	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_INDEX] = indices
	var mesh := ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	var material := _material("trunk")
	material.albedo_color = _colour("trunk").lightened(0.18)
	material.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	var visual := MeshInstance3D.new()
	visual.name = "CaminhoLargo"
	visual.mesh = mesh
	visual.material_override = material
	visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(visual)


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
	# A coluna vertebral do Brumal. Os dois desvios na clareira prometem
	# descanso e perigo sem seta nem marcador de missão.
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
	rest_point = path_points[4] + Vector3(17, 0, -1)
	camp_point = path_points[4] + Vector3(5, 0, -19)
	var lair_route: Array = LAIR_SCRIPT.MAIN_ROUTE
	var lair_origin_xz := Vector2(lair_entrance.x, lair_entrance.z) \
		- Vector2((lair_route[0] as Vector3).x, (lair_route[0] as Vector3).z)
	var descent_start := lair_origin_xz \
		+ Vector2((lair_route[1] as Vector3).x, (lair_route[1] as Vector3).z)
	var descent_finish := lair_origin_xz \
		+ Vector2((lair_route[2] as Vector3).x, (lair_route[2] as Vector3).z)
	var passage_margin := float(LAIR_SCRIPT.MODULE) * 0.5
	var passage_min := Vector2(minf(descent_start.x, descent_finish.x),
		minf(descent_start.y, descent_finish.y)) - Vector2.ONE * passage_margin
	var passage_max := Vector2(maxf(descent_start.x, descent_finish.x),
		maxf(descent_start.y, descent_finish.y)) + Vector2.ONE * passage_margin
	_add_ground(Vector2(220, 220), Vector3.ZERO,
		Rect2(passage_min, passage_max - passage_min))
	map_path_segments = [
		PackedVector3Array(path_points),
		PackedVector3Array([path_points[4], rest_point]),
		PackedVector3Array([path_points[4], camp_point]),
	]
	map_landmarks = [
		{
			"id": "descanso_1_brumal", "name": "Descanso de Brumal", "type": "rest",
			"position": rest_point, "discover_radius_m": 14.0,
		},
		{
			"id": "bivaque_brumal", "name": "Bivaque de Brumal", "type": "place",
			"position": camp_point, "discover_radius_m": 12.0,
		},
		{
			"id": "entrada_toca", "name": "A Toca", "type": "lair",
			"position": lair_entrance, "discover_radius_m": 18.0,
		},
		{
			"id": "descanso_toca", "name": "Descanso da Toca", "type": "rest",
			"position": lair_entrance + Vector3(0, 0, -18), "discover_radius_m": 12.0,
		},
		{
			"id": "arena_vorgar", "name": "Arena de Vorgar", "type": "arena",
			"position": arena_center, "discover_radius_m": 22.0,
		},
	]

	_build_path_visual()
	_build_world_guides()
	_scatter_forest()
	_scatter_ground_details()
	_build_lair()
	_build_arena_crown()


func _distance_to_path(p: Vector3) -> float:
	var best := 9999.0
	for segment_value: Variant in map_path_segments:
		var segment := segment_value as PackedVector3Array
		for i: int in segment.size() - 1:
			best = minf(best, _distance_to_segment(p, segment[i], segment[i + 1]))
	return best


func _distance_to_segment(p: Vector3, a: Vector3, b: Vector3) -> float:
	var ab := b - a
	var t := clampf((p - a).dot(ab) / maxf(ab.length_squared(), 0.001), 0.0, 1.0)
	return p.distance_to(a + ab * t)


func _build_world_guides() -> void:
	_build_stone_arch(path_points[3], path_points[4] - path_points[3])
	_build_rest_clearing()
	_build_bivouac()
	_build_cairns()


func _build_stone_arch(at: Vector3, travel: Vector3) -> void:
	var direction := travel.normalized()
	var right := Vector3(direction.z, 0.0, -direction.x)
	var yaw := atan2(direction.x, direction.z)
	_add_oriented_block("ArcoPedraEsquerda", at - right * 3.25 + Vector3.UP * 2.5,
		Vector3(1.45, 5.0, 1.65), "rock", yaw, true, false)
	_add_oriented_block("ArcoPedraDireita", at + right * 3.25 + Vector3.UP * 2.5,
		Vector3(1.45, 5.0, 1.65), "rock", yaw, true, false)
	_add_oriented_block("ArcoPedraLintel", at + Vector3.UP * 5.35,
		Vector3(8.0, 1.35, 1.65), "rock", yaw, true, false)
	var doorway := _asset_mesh(DUNGEON_DOORWAY, 0.78, Color("#777b78"))
	_add_asset_multimesh(doorway, [Transform3D(
		Basis(Vector3.UP, yaw).scaled(Vector3(1.75, 1.45, 1.30)), at)],
		bool(preset.get("shadows", true)), "ArcoPedraVestido")


func _build_rest_clearing() -> void:
	var stone := BoxMesh.new()
	stone.size = Vector3(0.85, 0.34, 0.62)
	var ring: Array[Transform3D] = []
	for index: int in 10:
		var angle := TAU * float(index) / 10.0
		ring.append(Transform3D(Basis(Vector3.UP, -angle),
			rest_point + Vector3(sin(angle) * 1.25, 0.20, cos(angle) * 1.25)))
	_add_multimesh(stone, ring, "rock", false, 0.08)

	var log_mesh := BoxMesh.new()
	log_mesh.size = Vector3(3.6, 0.32, 0.42)
	var logs: Array[Transform3D] = [
		Transform3D(Basis(Vector3.UP, 0.65), rest_point + Vector3(0, 0.42, 0)),
		Transform3D(Basis(Vector3.UP, -0.65), rest_point + Vector3(0, 0.45, 0)),
	]
	_add_multimesh(log_mesh, logs, "trunk", false, 0.05)
	_add_guiding_flame(rest_point, 0.95, 17.0, 3.4, 0.64)
	_add_smoke_column("FumoDescanso", rest_point, 13.0, 0.85, 0.14)


func _build_bivouac() -> void:
	var shelter_mesh := BoxMesh.new()
	shelter_mesh.size = Vector3(3.8, 0.24, 2.8)
	var shelters: Array[Transform3D] = [
		Transform3D(Basis(Vector3.FORWARD, -0.55).rotated(Vector3.UP, 0.35),
			camp_point + Vector3(3.0, 1.25, 1.0)),
		Transform3D(Basis(Vector3.FORWARD, 0.55).rotated(Vector3.UP, -0.35),
			camp_point + Vector3(-3.0, 1.25, 1.0)),
	]
	_add_multimesh(shelter_mesh, shelters, "trunk", false, 0.06)
	_add_guiding_flame(camp_point, 0.70, 11.0, 2.2, 0.28, false)
	_add_smoke_column("FumoBivaque", camp_point, 8.0, 0.55, 0.10)


func _build_cairns() -> void:
	var stone := BoxMesh.new()
	stone.size = Vector3(0.72, 0.42, 0.64)
	var transforms: Array[Transform3D] = []
	for point_index: int in [1, 2, 4, 5]:
		var point := path_points[point_index]
		var forward := (path_points[point_index + 1] - path_points[point_index - 1]).normalized()
		var right := Vector3(forward.z, 0.0, -forward.x)
		var base := point + right * 3.7
		for level: int in 3:
			var scale := 1.0 - float(level) * 0.18
			transforms.append(Transform3D(
				Basis(Vector3.UP, float(level) * 0.7).scaled(Vector3.ONE * scale),
				base + Vector3.UP * (0.22 + float(level) * 0.36)))
	_add_multimesh(stone, transforms, "rock", false, 0.10)


func _build_arena_crown() -> void:
	var base := arena_center + Vector3(0, 0, -14.0)
	var crown_mesh := BoxMesh.new()
	crown_mesh.size = Vector3.ONE
	var stones: Array[Transform3D] = [
		Transform3D(Basis.IDENTITY.scaled(Vector3(1.4, 14.0, 1.4)),
			base + Vector3(-3.0, 7.0, 0)),
		Transform3D(Basis.IDENTITY.scaled(Vector3(1.4, 14.0, 1.4)),
			base + Vector3(3.0, 7.0, 0)),
		Transform3D(Basis.IDENTITY.scaled(Vector3(7.4, 1.4, 1.4)),
			base + Vector3(0, 13.3, 0)),
	]
	_add_multimesh(crown_mesh, stones, "rock", bool(preset.get("shadows", true)), 0.04)
	_add_guiding_flame(base, 15.0, 20.0, 3.2, 0.36, false)


func _add_smoke_column(node_name: String, at: Vector3, height: float,
		radius: float, alpha: float) -> void:
	var mesh := SphereMesh.new()
	mesh.radius = 1.0
	mesh.height = 2.0
	mesh.radial_segments = 8
	mesh.rings = 4
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color.WHITE
	material.vertex_color_use_as_albedo = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.material = material
	var puff_count := maxi(3, roundi(height / 2.2))
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.use_colors = true
	multimesh.mesh = mesh
	multimesh.instance_count = puff_count
	for index: int in puff_count:
		var progress := float(index) / float(maxi(puff_count - 1, 1))
		var puff_radius := radius * (0.45 + progress * 0.65)
		var offset := Vector3(sin(float(index) * 1.7), 0, cos(float(index) * 1.3)) \
			* radius * 0.22
		multimesh.set_instance_transform(index, Transform3D(
			Basis(Vector3.UP, float(index) * 0.8).scaled(
				Vector3(puff_radius, puff_radius * 0.65, puff_radius)),
			at + offset + Vector3.UP * (1.5 + progress * height * 0.82)))
		multimesh.set_instance_color(index,
			Color(0.25, 0.28, 0.27, alpha * (1.0 - progress * 0.55)))
	var smoke := MultiMeshInstance3D.new()
	smoke.name = node_name
	smoke.multimesh = multimesh
	smoke.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(smoke)


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
		if p.distance_to(rest_point) < 11.0 or p.distance_to(camp_point) < 8.0 \
				or p.distance_to(path_points[3]) < 5.0:
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
		if p.distance_to(rest_point) < 4.0 or p.distance_to(camp_point) < 3.5:
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
			"id": "grass", "name": "GroundLeafGrass", "scene": DETAIL_GRASS,
			"count": int(preset.get("grass_detail_count", 520)),
			"path_clearance": 1.85, "scale_min": 0.72, "scale_max": 1.45,
			"path_bias": 0.78, "roughness": 0.96, "tint": Color("#7d8971"),
		},
		{
			"id": "bush", "name": "GroundBushes", "scene": DETAIL_BUSH,
			"count": int(preset.get("bush_detail_count", 120)),
			"path_clearance": 2.35, "scale_min": 0.72, "scale_max": 1.35,
			"path_bias": 0.72, "roughness": 0.94, "tint": Color("#748064"),
		},
		{
			"id": "mushroom", "name": "GroundMushrooms", "scene": DETAIL_MUSHROOM,
			"count": int(preset.get("mushroom_count", 54)),
			"path_clearance": 1.65, "scale_min": 0.70, "scale_max": 1.15,
			"path_bias": 0.82, "roughness": 0.90, "tint": Color.WHITE,
		},
		{
			"id": "log", "name": "FallenLogs", "scene": DETAIL_LOG,
			"count": int(preset.get("fallen_log_count", 14)),
			"path_clearance": 3.1, "scale_min": 0.80, "scale_max": 1.35,
			"path_bias": 0.54, "roughness": 0.92, "tint": Color("#8c7b6a"),
		},
		{
			"id": "pebble", "name": "GroundPebbles", "scene": DETAIL_STONE,
			"count": int(preset.get("pebble_count", 210)),
			"path_clearance": 1.45, "scale_min": 0.65, "scale_max": 1.50,
			"path_bias": 0.62, "roughness": 0.86, "tint": Color("#8a8c86"),
		},
		{
			"id": "flower", "name": "GroundFlowers", "scene": DETAIL_FLOWER,
			"count": int(preset.get("flower_count", 70)),
			"path_clearance": 1.75, "scale_min": 0.72, "scale_max": 1.22,
			"path_bias": 0.78, "roughness": 0.92, "tint": Color("#d0c29d"),
		},
	]
	for family: Dictionary in families:
		if not _ground_detail_enabled(String(family["id"])):
			continue
		var transforms := _scatter_detail_transforms(
			int(family["count"]), float(family["path_clearance"]),
			float(family["scale_min"]), float(family["scale_max"]),
			float(family["path_bias"]))
		var mesh := _asset_mesh(family["scene"] as PackedScene,
			float(family["roughness"]), family["tint"] as Color, false)
		if _ground_probe_uses_shared_material():
			_apply_shared_ground_detail_material(mesh)
		_add_ground_detail_multimesh(mesh, transforms, String(family["name"]))


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
	_add_block(e + Vector3(2.4, 5.0, 1.2), Vector3(0.65, 10.0, 0.65), "trunk", true, false)
	_add_asset_multimesh(_asset_mesh(TREE_THIN, 0.92, Color("#5a5045")), [Transform3D(
		Basis(Vector3.UP, -0.45).scaled(Vector3.ONE * 6.0),
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
	_add_guiding_flame(at, 2.52, 11.0, 2.4, 0.22)


func _add_guiding_flame(at: Vector3, height: float, light_range: float,
		energy: float, size: float, with_light := true) -> void:
	var flame := MeshInstance3D.new()
	var fm := SphereMesh.new()
	fm.radius = size * 0.5
	fm.height = size * 1.5
	fm.radial_segments = 8
	fm.rings = 4
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
	flame.position = at + Vector3.UP * height
	add_child(flame)
	if not with_light:
		return

	var light := OmniLight3D.new()
	light.light_color = accent
	light.light_energy = energy
	light.omni_range = light_range
	light.shadow_enabled = false  # sombras de omni sao caras; a luz chega
	light.position = at + Vector3.UP * maxf(height - 0.04, 0.1)
	add_child(light)
