class_name WorldBoundsWarning
extends Node3D
## Limite honesto de Brumal: o chao termina e a queda mata, portanto a ultima
## celula do mapa anuncia o perigo com padrao, estacas, folhas e vento.
## Toda a arte e som e sintetizada com primitivas e recursos ja carregados.

const BAND_SHADER := """
shader_type spatial;
render_mode unshaded, cull_disabled;

uniform vec4 safe_colour : source_color;
uniform vec4 danger_colour : source_color;
uniform vec2 tile_count = vec2(1.0);
uniform vec2 flow_uv = vec2(1.0, 0.0);

void fragment() {
	vec2 grid = UV * tile_count;
	float checker = mod(floor(grid.x) + floor(grid.y), 2.0);
	float fracture = step(0.82, fract(sin(dot(floor(grid * 3.0), vec2(12.9898, 78.233))) * 43758.5453));
	float current = smoothstep(0.82, 1.0, fract(dot(grid, flow_uv) - TIME * 1.6));
	float warning = max(checker * 0.70, max(fracture, current));
	ALBEDO = mix(safe_colour.rgb, danger_colour.rgb, warning);
	EMISSION = danger_colour.rgb * current * 0.35;
	ROUGHNESS = 1.0;
}
"""

var _palette: Dictionary = {}
var _band_shader: Shader
var _wind_source: AudioStreamPlayer3D
var _wind_target: Node3D
var _min_x := 0.0
var _min_z := 0.0
var _max_x := 0.0
var _max_z := 0.0
var _wind_y := 0.0


func setup(runtime: Dictionary, palette: Dictionary, traversal: Dictionary) -> void:
	_palette = palette
	_band_shader = Shader.new()
	_band_shader.code = BAND_SHADER
	var bounds: Dictionary = runtime.get("zone_bounds_m", {}) as Dictionary
	var min_x := float(bounds.get("min_x", 0.0))
	var min_z := float(bounds.get("min_z", 0.0))
	var size_x := float(bounds.get("size_x", 0.0))
	var size_z := float(bounds.get("size_z", 0.0))
	var cell := float(runtime.get("cell_size_m", 0.0))
	var step_height := float(traversal.get("automatic_step_max_m", 0.0))
	if size_x <= 0.0 or size_z <= 0.0 or cell <= 0.0:
		push_error("[WorldBoundsWarning] zone_bounds_m/cell_size_m invalidos")
		return
	_min_x = min_x
	_min_z = min_z
	_max_x = min_x + size_x
	_max_z = min_z + size_z
	_wind_y = step_height

	_build_bands(min_x, min_z, size_x, size_z, cell, step_height)
	_build_stakes(min_x, min_z, size_x, size_z, cell, step_height)
	_build_leaves(min_x, min_z, size_x, size_z, cell, step_height)
	_build_wind(min_x, min_z, size_x, size_z, cell, step_height)
	if "--bounds-player-probe" in OS.get_cmdline_user_args():
		var probe_script := load("res://src/world/bounds_player_probe.gd") as Script
		var probe := probe_script.new() as Node3D
		probe.name = "BoundsPlayerProbe"
		add_child(probe)
		probe.call("setup", _palette, bounds, cell, step_height)


func _build_bands(min_x: float, min_z: float, size_x: float, size_z: float,
		cell: float, step_height: float) -> void:
	var y := step_height * 0.15
	_add_band("OrlaOeste", Vector3(min_x + cell * 0.5, y, min_z + size_z * 0.5),
		Vector2(cell, size_z), cell, Vector2(-1.0, 0.0))
	_add_band("OrlaEste", Vector3(min_x + size_x - cell * 0.5, y, min_z + size_z * 0.5),
		Vector2(cell, size_z), cell, Vector2(1.0, 0.0))
	_add_band("OrlaNorte", Vector3(min_x + size_x * 0.5, y, min_z + cell * 0.5),
		Vector2(size_x - cell * 2.0, cell), cell, Vector2(0.0, -1.0))
	_add_band("OrlaSul", Vector3(min_x + size_x * 0.5, y, min_z + size_z - cell * 0.5),
		Vector2(size_x - cell * 2.0, cell), cell, Vector2(0.0, 1.0))


func _add_band(node_name: String, at: Vector3, size: Vector2, cell: float,
		flow: Vector2) -> void:
	var mesh := PlaneMesh.new()
	mesh.size = size
	var material := ShaderMaterial.new()
	material.shader = _band_shader
	material.set_shader_parameter("safe_colour", _colour("ground", Color("535f3e")).darkened(0.55))
	material.set_shader_parameter("danger_colour", _colour("enemy_telegraph", Color("e8c33a")))
	material.set_shader_parameter("tile_count", Vector2(maxf(size.x / cell, 1.0),
		maxf(size.y / cell, 1.0)))
	material.set_shader_parameter("flow_uv", flow)
	mesh.material = material
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.position = at
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(instance)


func _build_stakes(min_x: float, min_z: float, size_x: float, size_z: float,
		cell: float, step_height: float) -> void:
	var positions: Array[Vector3] = []
	var inset := step_height * 0.5
	_append_edge_positions(positions, min_x + inset, min_z, size_z, cell, true)
	_append_edge_positions(positions, min_x + size_x - inset, min_z, size_z, cell, true)
	_append_edge_positions(positions, min_z + inset, min_x, size_x, cell, false)
	_append_edge_positions(positions, min_z + size_z - inset, min_x, size_x, cell, false)

	var stake_height := cell * 0.30
	var stake := BoxMesh.new()
	stake.size = Vector3(step_height * 0.32, stake_height, step_height * 0.32)
	var material := StandardMaterial3D.new()
	material.albedo_color = _colour("enemy_telegraph", Color("e8c33a")).darkened(0.18)
	material.roughness = 1.0
	material.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	stake.material = material

	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = stake
	multimesh.instance_count = positions.size()
	for index in positions.size():
		var height_scale := 0.62 if index % 3 == 0 else 1.0
		var basis := Basis.IDENTITY.scaled(Vector3(1.0, height_scale, 1.0))
		var at := positions[index]
		at.y = stake_height * height_scale * 0.5
		multimesh.set_instance_transform(index, Transform3D(basis, at))
	var instance := MultiMeshInstance3D.new()
	instance.name = "EstacasQuebradas"
	instance.multimesh = multimesh
	instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(instance)


func _append_edge_positions(into: Array[Vector3], fixed: float, start: float,
		length: float, cell: float, fixed_is_x: bool) -> void:
	var count := maxi(1, ceili(length / cell))
	for index in count:
		var along := start + (float(index) + 0.5) * length / float(count)
		into.append(Vector3(fixed, 0.0, along) if fixed_is_x
			else Vector3(along, 0.0, fixed))


func _build_leaves(min_x: float, min_z: float, size_x: float, size_z: float,
		cell: float, step_height: float) -> void:
	_add_leaf_edge("FolhasOeste", Vector3(min_x + cell * 0.5, step_height, min_z + size_z * 0.5),
		Vector3(cell * 0.5, step_height, size_z * 0.5), Vector3.LEFT, size_z, cell, step_height)
	_add_leaf_edge("FolhasEste", Vector3(min_x + size_x - cell * 0.5, step_height,
		min_z + size_z * 0.5), Vector3(cell * 0.5, step_height, size_z * 0.5),
		Vector3.RIGHT, size_z, cell, step_height)
	_add_leaf_edge("FolhasNorte", Vector3(min_x + size_x * 0.5, step_height, min_z + cell * 0.5),
		Vector3(size_x * 0.5, step_height, cell * 0.5), Vector3.FORWARD, size_x, cell, step_height)
	_add_leaf_edge("FolhasSul", Vector3(min_x + size_x * 0.5, step_height,
		min_z + size_z - cell * 0.5), Vector3(size_x * 0.5, step_height, cell * 0.5),
		Vector3.BACK, size_x, cell, step_height)


func _add_leaf_edge(node_name: String, at: Vector3, extents: Vector3, outward: Vector3,
		length: float, cell: float, step_height: float) -> void:
	var leaf := QuadMesh.new()
	leaf.size = Vector2(step_height * 0.45, step_height * 0.18)
	var leaf_material := StandardMaterial3D.new()
	leaf_material.albedo_color = _colour("enemy_telegraph", Color("e8c33a"))
	leaf_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	leaf_material.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	leaf_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	leaf.material = leaf_material

	var process := ParticleProcessMaterial.new()
	process.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	process.emission_box_extents = extents
	process.direction = outward
	process.spread = 22.0
	process.initial_velocity_min = cell * 0.18
	process.initial_velocity_max = cell * 0.42
	process.gravity = outward * cell * 0.20 + Vector3.DOWN * step_height

	var particles := GPUParticles3D.new()
	particles.name = node_name
	particles.amount = maxi(1, ceili(length / cell))
	particles.lifetime = 2.4
	particles.randomness = 0.65
	particles.position = at
	particles.process_material = process
	particles.draw_pass_1 = leaf
	particles.visibility_aabb = AABB(-extents - Vector3.ONE * cell,
		extents * 2.0 + Vector3.ONE * cell * 2.0)
	add_child(particles)


func _build_wind(min_x: float, min_z: float, _size_x: float, _size_z: float,
		cell: float, step_height: float) -> void:
	var bank: Dictionary = Sfx.get("_bank") as Dictionary
	var stream := bank.get("amb_wind") as AudioStream
	if stream == null:
		return
	_wind_source = AudioStreamPlayer3D.new()
	_wind_source.name = "VentoDaOrla"
	_wind_source.stream = stream
	_wind_source.bus = "Ambience"
	_wind_source.position = Vector3(min_x, step_height, min_z)
	_wind_source.volume_db = -17.0
	_wind_source.unit_size = cell
	_wind_source.max_distance = cell * 5.0
	add_child(_wind_source)
	_wind_source.play()


func _process(_delta: float) -> void:
	if not is_instance_valid(_wind_source):
		return
	if not is_instance_valid(_wind_target):
		_wind_target = get_tree().get_first_node_in_group("player") as Node3D
	if not is_instance_valid(_wind_target):
		return
	var at := _wind_target.global_position
	var nearest := Vector3(_min_x, _wind_y, clampf(at.z, _min_z, _max_z))
	var distance := absf(at.x - _min_x)
	if absf(at.x - _max_x) < distance:
		distance = absf(at.x - _max_x)
		nearest = Vector3(_max_x, _wind_y, clampf(at.z, _min_z, _max_z))
	if absf(at.z - _min_z) < distance:
		distance = absf(at.z - _min_z)
		nearest = Vector3(clampf(at.x, _min_x, _max_x), _wind_y, _min_z)
	if absf(at.z - _max_z) < distance:
		nearest = Vector3(clampf(at.x, _min_x, _max_x), _wind_y, _max_z)
	_wind_source.global_position = nearest


func _colour(key: String, fallback: Color) -> Color:
	return Color(String(_palette.get(key, fallback.to_html())))
