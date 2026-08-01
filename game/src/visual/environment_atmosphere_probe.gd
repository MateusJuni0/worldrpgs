extends SceneTree
## Prova visual e A/B do ceu/luz sem alterar o construtor do mundo.
##
## Uso:
##   godot --path game --rendering-method mobile \
##     --script res://src/visual/environment_atmosphere_probe.gd -- \
##     --variant=baseline --captures
##   godot --path game --rendering-method mobile \
##     --script res://src/visual/environment_atmosphere_probe.gd -- \
##     --variant=atmosphere --benchmark --warmup=8 --seconds=20

var _variant := "atmosphere"
var _captures := false
var _benchmark := false
var _warmup_seconds := 8.0
var _measure_seconds := 20.0
var _world: Node3D
var _camera: Camera3D
var _shots: Array = []
var _capture_index := 0
var _capture_wait_frames := 0
var _capture_positioned := false
var _elapsed := 0.0
var _samples: Array[float] = []


func _initialize() -> void:
	_parse_args()
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0
	var graphics := _read_json("res://data/graphics.json")
	var biomes := _read_json("res://data/biomes.json")
	var preset := ((graphics.get("presets", {}) as Dictionary).get(
		"medio", {}) as Dictionary).duplicate(true)
	var palette := graphics.get("palette", {}) as Dictionary
	var biome := biomes.get("brumal", {}) as Dictionary

	_world = Node3D.new()
	_world.name = "AtmosphereProbe"
	root.add_child(_world)
	_build_stage(_world, preset, palette)
	if _variant == "atmosphere":
		_world.add_child(EnvironmentAtmosphere.build_world_environment(
			preset, palette, biome))
		_world.add_child(EnvironmentAtmosphere.build_sun(preset, biome))
	else:
		_build_baseline_environment(_world, preset, palette, biome)

	_camera = Camera3D.new()
	_camera.fov = 65.0
	_world.add_child(_camera)
	_camera.make_current()
	_camera.look_at_from_position(
		Vector3(0.0, 3.0, 18.0), Vector3(0.0, 2.0, -24.0))
	if _captures:
		_prepare_captures()
		_capture_wait_frames = 60


func _process(delta: float) -> bool:
	if _captures:
		return _capture_tick()
	if _benchmark:
		_elapsed += delta
		if _elapsed > _warmup_seconds:
			_samples.append(delta)
		if _elapsed < _warmup_seconds + _measure_seconds:
			return false
		_print_summary(_samples)
		return true
	return true


func _finalize() -> void:
	pass


func _build_baseline_environment(
		world: Node3D, preset: Dictionary, palette: Dictionary, biome: Dictionary) -> void:
	var fog_colour := Color(String((biome.get("paleta", {}) as Dictionary).get(
		"nevoa", palette.get("fog", "#8b96a3"))))
	var environment := Environment.new()
	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = fog_colour.darkened(0.62)
	sky_material.sky_horizon_color = fog_colour.lightened(0.10)
	sky_material.ground_bottom_color = Color(String(
		palette.get("ground", "#535f3e"))).darkened(0.32)
	sky_material.ground_horizon_color = fog_colour
	sky_material.sun_angle_max = 25.0
	sky_material.sun_curve = 0.12
	var sky := Sky.new()
	sky.sky_material = sky_material
	environment.background_mode = Environment.BG_SKY
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_energy = 0.75
	environment.fog_enabled = true
	environment.fog_light_color = fog_colour
	environment.fog_light_energy = 1.0
	environment.fog_density = float(preset.get("fog_density", 0.032))
	environment.fog_aerial_perspective = 0.72
	environment.fog_sky_affect = 0.18
	EnvironmentAtmosphere.apply_graphics(environment, preset)
	var world_environment := WorldEnvironment.new()
	world_environment.name = "WorldEnvironment"
	world_environment.environment = environment
	world.add_child(world_environment)
	var sun := DirectionalLight3D.new()
	sun.name = "Sun"
	sun.rotation_degrees = Vector3(-38.0, 42.0, 0.0)
	sun.light_energy = 1.15
	sun.light_color = Color(String((biome.get("paleta", {}) as Dictionary).get(
		"luz", "#ffebcc")))
	sun.shadow_enabled = bool(preset.get("shadows", true))
	sun.directional_shadow_max_distance = float(preset.get("shadow_distance", 30.0))
	sun.directional_shadow_mode = DirectionalLight3D.SHADOW_ORTHOGONAL
	world.add_child(sun)


func _build_stage(world: Node3D, preset: Dictionary, palette: Dictionary) -> void:
	var ground := MeshInstance3D.new()
	var ground_mesh := PlaneMesh.new()
	ground_mesh.size = Vector2(210.0, 210.0)
	ground_mesh.material = _material(Color(String(palette.get("ground", "#535f3e"))))
	ground.mesh = ground_mesh
	world.add_child(ground)

	var path := MeshInstance3D.new()
	var path_mesh := BoxMesh.new()
	path_mesh.size = Vector3(4.0, 0.04, 150.0)
	path_mesh.material = _material(Color("674638"))
	path.mesh = path_mesh
	path.position = Vector3(0.0, 0.01, -25.0)
	world.add_child(path)

	var rng := RandomNumberGenerator.new()
	rng.seed = 424242
	var transforms: Array[Transform3D] = []
	for index: int in int(preset.get("tree_count", 850)):
		var x := rng.randf_range(-100.0, 100.0)
		var z := rng.randf_range(-100.0, 100.0)
		if absf(x) < 4.5:
			x += 9.0 * signf(x if x != 0.0 else 1.0)
		var height := rng.randf_range(0.78, 1.45)
		transforms.append(Transform3D(Basis.IDENTITY.scaled(
			Vector3(rng.randf_range(0.75, 1.25), height, rng.randf_range(0.75, 1.25))),
			Vector3(x, 0.0, z)))
	_add_tree_layer(world, transforms, false)
	_add_tree_layer(world, transforms, true)


func _add_tree_layer(
		world: Node3D, transforms: Array[Transform3D], canopy: bool) -> void:
	var mesh: PrimitiveMesh
	if canopy:
		var canopy_mesh := CylinderMesh.new()
		canopy_mesh.top_radius = 0.7
		canopy_mesh.bottom_radius = 2.2
		canopy_mesh.height = 4.6
		canopy_mesh.radial_segments = 7
		canopy_mesh.material = _material(Color("283b33"))
		mesh = canopy_mesh
	else:
		var trunk_mesh := BoxMesh.new()
		trunk_mesh.size = Vector3(0.48, 4.6, 0.48)
		trunk_mesh.material = _material(Color("3d3027"))
		mesh = trunk_mesh
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = mesh
	multimesh.instance_count = transforms.size()
	for index: int in transforms.size():
		var transform := transforms[index]
		transform.origin.y = 5.6 if canopy else 2.3
		multimesh.set_instance_transform(index, transform)
	var instance := MultiMeshInstance3D.new()
	instance.multimesh = multimesh
	world.add_child(instance)


func _material(colour: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = colour
	material.roughness = 0.88
	return material


func _prepare_captures() -> void:
	_shots = [
		["spawn", Vector3(0.0, 3.0, 18.0), Vector3(0.0, 2.0, -24.0)],
		["caminho", Vector3(3.0, 2.0, 3.0), Vector3(0.0, 2.0, -38.0)],
		["alto", Vector3(0.0, 18.0, 22.0), Vector3(0.0, 0.0, -25.0)],
	]


func _capture_tick() -> bool:
	if _capture_wait_frames > 0:
		_capture_wait_frames -= 1
		return false
	if _capture_index >= _shots.size():
		return true
	var shot: Array = _shots[_capture_index]
	if not _capture_positioned:
		_camera.look_at_from_position(shot[1], shot[2])
		_capture_positioned = true
		_capture_wait_frames = 12
		return false
	var directory := ProjectSettings.globalize_path("res://captures/atmosphere-probe/")
	DirAccess.make_dir_recursive_absolute(directory)
	var image := root.get_viewport().get_texture().get_image()
	var path := directory + "%s-%s.png" % [_variant, String(shot[0])]
	image.save_png(path)
	print("[atmosphere_probe] capture ", path)
	_capture_index += 1
	_capture_positioned = false
	return false


func _print_summary(samples: Array[float]) -> void:
	samples.sort()
	var total := 0.0
	for sample: float in samples:
		total += sample
	var count := samples.size()
	var p95 := samples[clampi(ceili(float(count) * 0.95) - 1, 0, count - 1)]
	var p99 := samples[clampi(ceili(float(count) * 0.99) - 1, 0, count - 1)]
	var result := {
		"variant": _variant,
		"adapter": RenderingServer.get_video_adapter_name(),
		"resolution": "%dx%d" % [
			root.get_viewport().get_visible_rect().size.x,
			root.get_viewport().get_visible_rect().size.y,
		],
		"samples": count,
		"avg_fps": snappedf(float(count) / total, 0.1),
		"avg_frame_ms": snappedf(total / float(count) * 1000.0, 0.01),
		"p95_frame_ms": snappedf(p95 * 1000.0, 0.001),
		"p99_frame_ms": snappedf(p99 * 1000.0, 0.001),
		"draw_calls": int(Performance.get_monitor(
			Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
		"video_mem_mb": snappedf(Performance.get_monitor(
			Performance.RENDER_VIDEO_MEM_USED) / 1048576.0, 0.1),
	}
	print("ATMOSPHERE_BENCH_RESULT_JSON " + JSON.stringify(result))


func _parse_args() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--variant="):
			_variant = argument.trim_prefix("--variant=")
		elif argument == "--captures":
			_captures = true
		elif argument == "--benchmark":
			_benchmark = true
		elif argument.begins_with("--warmup="):
			_warmup_seconds = maxf(1.0, argument.trim_prefix("--warmup=").to_float())
		elif argument.begins_with("--seconds="):
			_measure_seconds = maxf(1.0, argument.trim_prefix("--seconds=").to_float())


func _read_json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary
