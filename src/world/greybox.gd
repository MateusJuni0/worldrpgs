class_name Greybox
extends Node3D
## Constroi a zona em caixas e cilindros. Sem arte, sem texturas, sem ficheiros binarios.
##
## Tecnica de desempenho central (Lei 4): as arvores e as pedras vao num
## MultiMeshInstance3D cada — centenas de objectos, UM draw call. Numa Iris Xe
## o numero de draw calls e o que mata, nao os poligonos.
##
## A nevoa faz duas coisas ao mesmo tempo: e o tom de Brumal e e o que deixa
## cortar a distancia de visao sem se ver o corte.

const SEED := 20260731  # fixo: duas medicoes de desempenho tem de ver o mesmo mundo

var preset: Dictionary = {}
var palette: Dictionary = {}
var _rng := RandomNumberGenerator.new()

## Pontos de interesse que o main usa para colocar o jogador e os inimigos.
var spawn_point := Vector3.ZERO
var arena_center := Vector3.ZERO
var lair_entrance := Vector3.ZERO
var path_points: Array[Vector3] = []


func build(p_preset: Dictionary, p_palette: Dictionary, layout: String) -> void:
	preset = p_preset
	palette = p_palette
	_rng.seed = SEED
	_build_environment()
	_build_light()
	match layout:
		"arena":
			_build_arena()
		_:
			_build_brumal()


# --- Ambiente -----------------------------------------------------------------

func _build_environment() -> void:
	var env := Environment.new()
	var fog_colour := _colour("fog")

	env.background_mode = Environment.BG_COLOR
	env.background_color = fog_colour
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = fog_colour.lightened(0.05)
	env.ambient_light_energy = 0.55

	# Nevoa de profundidade simples. NAO volumetrica — a volumetrica e cara de mais
	# para graficos integrados e nao acrescenta nada a leitura do combate.
	env.fog_enabled = true
	env.fog_light_color = fog_colour
	env.fog_light_energy = 1.0
	env.fog_density = float(preset.get("fog_density", 0.045))
	env.fog_sky_affect = 0.0

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


func _build_light() -> void:
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-52, 38, 0)
	sun.light_energy = 0.9
	sun.light_color = Color(1.0, 0.97, 0.92)
	sun.shadow_enabled = bool(preset.get("shadows", true))
	sun.directional_shadow_max_distance = float(preset.get("shadow_distance", 30.0))
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL  # 1 cascata = o mais barato
	add_child(sun)


# --- Materiais ----------------------------------------------------------------

func _colour(key: String) -> Color:
	return Color(String(palette.get(key, "#ff00ff")))


func _material(key: String) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = _colour(key)
	m.roughness = 1.0
	m.metallic = 0.0
	m.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	return m


# --- Pecas --------------------------------------------------------------------

func _add_ground(size: Vector2, centre: Vector3) -> void:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(size.x, 1.0, size.y)
	var mi := MeshInstance3D.new()
	mi.name = "Ground"
	mi.mesh = mesh
	mi.material_override = _material("ground")
	mi.position = centre + Vector3(0, -0.5, 0)
	mi.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(mi)

	var body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = mesh.size
	shape.shape = box
	body.add_child(shape)
	body.position = mi.position
	add_child(body)


## Parede/bloco solido, com colisao. A base do greybox.
func _add_block(centre: Vector3, size: Vector3, colour_key: String, shadows := true) -> void:
	var mesh := BoxMesh.new()
	mesh.size = size
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	mi.material_override = _material(colour_key)
	mi.position = centre
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
func _add_multimesh(mesh: Mesh, transforms: Array[Transform3D], colour_key: String, shadows: bool) -> void:
	if transforms.is_empty():
		return
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = mesh
	mm.instance_count = transforms.size()
	for i in transforms.size():
		mm.set_instance_transform(i, transforms[i])

	var mmi := MultiMeshInstance3D.new()
	mmi.multimesh = mm
	mmi.material_override = _material(colour_key)
	mmi.cast_shadow = (GeometryInstance3D.SHADOW_CASTING_SETTING_ON if shadows
		else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF)
	add_child(mmi)


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

	_scatter_forest()
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
	var trunk_mesh := CylinderMesh.new()
	trunk_mesh.top_radius = 0.22
	trunk_mesh.bottom_radius = 0.32
	trunk_mesh.height = 4.2
	trunk_mesh.radial_segments = 6   # baixo poligonal de proposito
	trunk_mesh.rings = 1

	var canopy_mesh := CylinderMesh.new()
	canopy_mesh.top_radius = 0.0
	canopy_mesh.bottom_radius = 2.1
	canopy_mesh.height = 5.0
	canopy_mesh.radial_segments = 7
	canopy_mesh.rings = 1

	var rock_mesh := BoxMesh.new()
	rock_mesh.size = Vector3(1.4, 1.0, 1.2)

	var trunks: Array[Transform3D] = []
	var canopies: Array[Transform3D] = []
	var rocks: Array[Transform3D] = []
	var trunk_bodies := StaticBody3D.new()
	trunk_bodies.name = "TreeCollision"

	var wanted: int = int(preset.get("tree_count", 200))
	var tries := 0
	while trunks.size() < wanted and tries < wanted * 12:
		tries += 1
		var p := Vector3(_rng.randf_range(-105, 105), 0, _rng.randf_range(-105, 105))
		# O caminho tem de ficar livre — a floresta e fechada, o caminho nao.
		if _distance_to_path(p) < 4.5:
			continue
		if p.distance_to(arena_center) < 18.0:
			continue
		var scale := _rng.randf_range(0.8, 1.35)
		var yaw := _rng.randf_range(0, TAU)

		var t := Transform3D(Basis(Vector3.UP, yaw).scaled(Vector3(scale, scale, scale)),
			p + Vector3(0, 2.1 * scale, 0))
		trunks.append(t)
		canopies.append(Transform3D(Basis(Vector3.UP, yaw).scaled(Vector3(scale, scale, scale)),
			p + Vector3(0, (4.2 + 2.0) * scale, 0)))

		var col := CollisionShape3D.new()
		var cyl := CylinderShape3D.new()
		cyl.radius = 0.32 * scale
		cyl.height = 4.2 * scale
		col.shape = cyl
		col.position = p + Vector3(0, 2.1 * scale, 0)
		trunk_bodies.add_child(col)

	var rocks_wanted: int = int(preset.get("rock_count", 60))
	for i in rocks_wanted:
		var p := Vector3(_rng.randf_range(-100, 100), 0, _rng.randf_range(-100, 100))
		if _distance_to_path(p) < 3.0:
			continue
		var s := _rng.randf_range(0.6, 1.8)
		rocks.append(Transform3D(
			Basis(Vector3.UP, _rng.randf_range(0, TAU)).scaled(Vector3(s, s * 0.7, s)),
			p + Vector3(0, s * 0.35, 0)))

	add_child(trunk_bodies)
	# As copas nao lancam sombra: e a maior poupanca da cena e quase nao se nota com nevoa.
	_add_multimesh(trunk_mesh, trunks, "trunk", bool(preset.get("shadows", true)))
	_add_multimesh(canopy_mesh, canopies, "canopy", false)
	_add_multimesh(rock_mesh, rocks, "rock", false)


## A Toca: entrada escondida + 3 salas + arena, tudo em blocos.
func _build_lair() -> void:
	var e := lair_entrance

	# A arvore morta que marca a fenda — o unico ponto de referencia.
	_add_block(e + Vector3(2.4, 3.0, 1.2), Vector3(0.5, 6.0, 0.5), "trunk")

	# Fenda na rocha: duas paredes com uma abertura no meio.
	_add_block(e + Vector3(-4.5, 2.0, 0), Vector3(6, 4, 1.5), "rock")
	_add_block(e + Vector3(4.5, 2.0, 0), Vector3(6, 4, 1.5), "rock")

	# Corredor + 3 salas, a descer para a arena.
	var z := e.z - 6.0
	for room in 3:
		var w := 9.0 + float(room) * 2.0
		_add_block(Vector3(-w * 0.5, 2.0, z - 5.0), Vector3(1.5, 4, 12), "rock")
		_add_block(Vector3(w * 0.5, 2.0, z - 5.0), Vector3(1.5, 4, 12), "rock")
		z -= 11.0

	# Arena do Vorgar: circular em blocos.
	var c := arena_center
	var radius := 15.0
	for i in 20:
		var a := TAU * float(i) / 20.0
		_add_block(c + Vector3(sin(a) * radius, 2.5, cos(a) * radius),
			Vector3(5.5, 5, 2.0).rotated(Vector3.UP, -a).abs(), "rock")
