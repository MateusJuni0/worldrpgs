class_name SpellCastVfx
extends Node3D
## Telegrafia presa ao foco real. O mesmo catalogo que move o corpo descreve
## carga, sustentacao, disparo e recuperacao; este no so as torna luminosas.
## Nunca declara hitbox. Se a conjuracao for interrompida, desaparece com ela.

const ANIMATION_CATALOGUE_PATH := "res://data/animations.json"

static var _phase_profiles_cache: Dictionary = {}
static var _focus_mesh_cache: SphereMesh
static var _blood_stream_mesh_cache: BoxMesh

var _bundle: Dictionary = {}
var _cast_duration_s := 0.0
var _linger_s := 0.0
var _elapsed_s := 0.0
var _committed := false
var _caster: Node3D
var _phase_profiles: Dictionary = {}
var _phase_role := "prepare"
var _reference_fps := 0.0
var _core := MeshInstance3D.new()
var _halo := MeshInstance3D.new()
var _orbit := MultiMeshInstance3D.new()
var _blood_motes := MultiMeshInstance3D.new()
var _blood_streams := MultiMeshInstance3D.new()
var _core_material: StandardMaterial3D
var _halo_material: StandardMaterial3D
var _orbit_material: StandardMaterial3D
var _blood_material: StandardMaterial3D
var _core_color := Color.WHITE
var _halo_color := Color.WHITE
var _blood_color := Color.WHITE
var _visible_orbit_instances := 0
var _visible_blood_instances := 0
var _visible_blood_stream_instances := 0


func configure(bundle: Dictionary, cast_duration_s: float,
		commit_frames: int, tip_position: Vector3) -> void:
	_bundle = bundle.duplicate()
	_phase_profiles = _cast_phase_profiles()
	_reference_fps = float(_phase_profiles.get("_reference_fps",
		Engine.physics_ticks_per_second))
	_cast_duration_s = maxf(cast_duration_s, 0.0)
	var recover_frames := _phase_frames("recover")
	_linger_s = float(maxi(maxi(commit_frames, recover_frames), 1)) / _reference_fps
	top_level = true
	name = "SpellCastVfx_%s" % String(bundle.get("spell_id", "unknown"))
	global_position = tip_position
	add_to_group("spell_cast_vfx")

	var mesh := _focus_mesh(bundle.get("render", {}) as Dictionary)
	var source_material := bundle.get("material") as StandardMaterial3D
	if mesh == null or source_material == null:
		return
	var render: Dictionary = bundle.get("render", {}) as Dictionary
	_caster = _nearest_caster(tip_position)
	_core_material = source_material.duplicate() as StandardMaterial3D
	_core_color = _core_material.albedo_color
	_core.mesh = mesh
	_core.material_override = _core_material
	_core.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_core)

	_halo_material = source_material.duplicate() as StandardMaterial3D
	_halo_color = _halo_material.albedo_color
	_halo_color.a = float(render.get("halo_alpha", 0.0))
	_halo_material.albedo_color = _halo_color
	_halo_material.emission = _halo_color
	_halo.mesh = mesh
	_halo.material_override = _halo_material
	_halo.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_halo)

	_orbit_material = _halo_material.duplicate() as StandardMaterial3D
	_orbit.material_override = _orbit_material
	_orbit.multimesh = _new_multimesh(mesh, _maximum_profile_count("orbit_instances"))
	_orbit.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_orbit)

	_blood_material = source_material.duplicate() as StandardMaterial3D
	_blood_color = _blood_material.albedo_color.darkened(float(
		render.get("core_scale", 0.0)))
	_blood_material.albedo_color = _blood_color
	_blood_material.emission = _blood_color
	_blood_motes.material_override = _blood_material
	_blood_motes.multimesh = _new_multimesh(mesh,
		_maximum_profile_count("blood_mote_count"))
	_blood_motes.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_blood_motes)

	_blood_streams.material_override = _blood_material
	_blood_streams.multimesh = _new_multimesh(_blood_stream_mesh(),
		_maximum_profile_product("blood_stream_count", "blood_stream_segments"))
	_blood_streams.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_blood_streams)

	_update_visuals()


func _process(delta: float) -> void:
	_elapsed_s += delta
	if _committed:
		_phase_role = "recover"
		_update_visuals()
		if _elapsed_s >= _linger_s:
			queue_free()
		return
	_phase_role = _pre_commit_phase()
	_update_visuals()
	if _elapsed_s > _cast_duration_s + _linger_s:
		queue_free()


func sync_tip(tip_position: Vector3) -> void:
	if not _committed:
		global_position = tip_position


func commit(tip_position: Vector3) -> void:
	global_position = tip_position
	_committed = true
	_phase_role = "recover"
	_elapsed_s = 0.0


func cancel() -> void:
	queue_free()


func is_visible_flash() -> bool:
	return is_instrument_lit()


func is_instrument_lit() -> bool:
	return visible and _core.visible and _halo.visible \
		and _core.scale.length_squared() > 0.0


func is_body_price_visible() -> bool:
	return visible and (_visible_blood_instances > 0 \
		or _visible_blood_stream_instances > 0)


func cast_phase() -> String:
	return _phase_role


func visible_instance_count() -> int:
	var fixed := int(_core.visible) + int(_halo.visible)
	return fixed + _visible_orbit_instances + _visible_blood_instances \
		+ _visible_blood_stream_instances


func tip_position() -> Vector3:
	return global_position


func _pre_commit_phase() -> String:
	var elapsed_frames := _elapsed_s * _reference_fps
	var prepare_frames := float(_phase_frames("prepare"))
	var release_frames := float(_phase_frames("release"))
	var total_frames := _cast_duration_s * _reference_fps
	if elapsed_frames <= prepare_frames:
		return "prepare"
	if elapsed_frames > maxf(prepare_frames, total_frames - release_frames):
		return "release"
	return "hold"


func _phase_progress() -> float:
	if _phase_role == "recover":
		return clampf(_elapsed_s / maxf(_linger_s, 1.0 / _reference_fps), 0.0, 1.0)
	var elapsed_frames := _elapsed_s * _reference_fps
	var prepare_frames := float(_phase_frames("prepare"))
	var release_frames := float(_phase_frames("release"))
	var total_frames := _cast_duration_s * _reference_fps
	if _phase_role == "prepare":
		return clampf(elapsed_frames / maxf(prepare_frames, 1.0), 0.0, 1.0)
	if _phase_role == "release":
		var release_start := maxf(prepare_frames, total_frames - release_frames)
		return clampf((elapsed_frames - release_start) / maxf(release_frames, 1.0),
			0.0, 1.0)
	var hold_vfx := _vfx_profile("hold")
	var loop_frames := maxf(float(hold_vfx.get("loop_frames", 1.0)), 1.0)
	return fposmod(elapsed_frames - prepare_frames, loop_frames) / loop_frames


func _update_visuals() -> void:
	if _core.mesh == null:
		return
	var render: Dictionary = _bundle.get("render", {}) as Dictionary
	var progress := smoothstep(0.0, 1.0, _phase_progress())
	var previous := _previous_vfx_profile(_phase_role)
	var target := _vfx_profile(_phase_role)
	var pulse_cycles := _interpolated(previous, target, "pulse_cycles", progress)
	var pulse := sin(progress * TAU * pulse_cycles)
	var core_factor := _interpolated(previous, target, "core_factor", progress)
	var halo_factor := _interpolated(previous, target, "halo_factor", progress)
	var pulse_weight := float(target.get("orbit_scale_factor", 0.0))
	core_factor += pulse * pulse_weight
	halo_factor -= pulse * pulse_weight
	var core_scale := float(render.get("core_scale", 0.0)) * maxf(core_factor, 0.0)
	var halo_scale := float(render.get("halo_scale", 0.0)) * maxf(halo_factor, 0.0)
	_core.scale = Vector3.ONE * core_scale
	_halo.scale = Vector3.ONE * halo_scale
	var opacity := clampf(_interpolated(previous, target, "opacity", progress), 0.0, 1.0)
	_core.visible = opacity > 0.0
	_halo.visible = opacity > 0.0
	_set_material_opacity(_core_material, _core_color, opacity)
	_set_material_opacity(_halo_material, _halo_color, opacity)
	_set_material_opacity(_orbit_material, _halo_color, opacity)
	_update_orbit(previous, target, progress)
	_update_blood_price(previous, target, progress)


func _update_orbit(previous: Dictionary, target: Dictionary, progress: float) -> void:
	var count := roundi(_interpolated(previous, target, "orbit_instances", progress))
	count = clampi(count, 0, _orbit.multimesh.instance_count)
	var radius := _interpolated(previous, target, "orbit_radius_m", progress)
	var scale_factor := _interpolated(previous, target, "orbit_scale_factor", progress)
	var turns := _interpolated(previous, target, "orbit_turns", progress)
	var base_scale := float((_bundle.get("render", {}) as Dictionary).get(
		"core_scale", 0.0)) * scale_factor
	for index: int in count:
		var fraction := float(index) / float(maxi(count, 1))
		var angle := TAU * (fraction + progress * turns)
		var position := Vector3(cos(angle) * radius,
			sin(angle * 2.0) * radius * scale_factor, sin(angle) * radius)
		var basis := Basis(Vector3.UP, -angle).scaled(Vector3.ONE * base_scale)
		_orbit.multimesh.set_instance_transform(index, Transform3D(basis, position))
	_orbit.multimesh.visible_instance_count = count
	_visible_orbit_instances = count
	_orbit.visible = count > 0


func _update_blood_price(previous: Dictionary, target: Dictionary,
		progress: float) -> void:
	var is_red_school := String(_bundle.get("school", "")) == "mal"
	var visibility := clampf(_interpolated(previous, target,
		"blood_visibility", progress), 0.0, 1.0) if is_red_school else 0.0
	var count := roundi(_interpolated(previous, target, "blood_mote_count", progress))
	count = clampi(count, 0, _blood_motes.multimesh.instance_count)
	var drop := _interpolated(previous, target, "blood_body_drop_m", progress)
	var spread := _interpolated(previous, target, "blood_body_spread_m", progress)
	var flow_cycles := _interpolated(previous, target, "blood_flow_cycles", progress)
	var mote_factor := _interpolated(previous, target,
		"blood_mote_scale_factor", progress)
	var base_scale := float((_bundle.get("render", {}) as Dictionary).get(
		"core_scale", 0.0)) * mote_factor
	var body_height := _interpolated(previous, target, "blood_body_height_m", progress)
	var body_anchor := Vector3.DOWN * drop
	if is_instance_valid(_caster):
		body_anchor = to_local(_caster.global_position + Vector3.UP * body_height)
	for index: int in count:
		var fraction := float(index) / float(maxi(count, 1))
		var travel := fposmod(fraction + progress * flow_cycles, 1.0)
		var angle := TAU * fraction
		var scatter := Vector3(cos(angle), sin(angle * 2.0), sin(angle)) \
			* spread * (1.0 - travel)
		var position := body_anchor.lerp(Vector3.ZERO, travel) + scatter
		_blood_motes.multimesh.set_instance_transform(index, Transform3D(
			Basis.IDENTITY.scaled(Vector3.ONE * base_scale), position))
	_blood_motes.multimesh.visible_instance_count = count
	_visible_blood_instances = count if visibility > 0.0 else 0
	_blood_motes.visible = _visible_blood_instances > 0
	_update_blood_streams(previous, target, progress, visibility, body_anchor)
	_set_material_opacity(_blood_material, _blood_color, visibility)


func _update_blood_streams(previous: Dictionary, target: Dictionary,
		progress: float, visibility: float, body_anchor: Vector3) -> void:
	var stream_count := roundi(_interpolated(previous, target,
		"blood_stream_count", progress))
	var segments := roundi(_interpolated(previous, target,
		"blood_stream_segments", progress))
	stream_count = maxi(stream_count, 0)
	segments = maxi(segments, 0)
	var total := mini(stream_count * segments, _blood_streams.multimesh.instance_count)
	var width := float((_bundle.get("render", {}) as Dictionary).get(
		"core_scale", 0.0)) * _interpolated(previous, target,
		"blood_stream_width_factor", progress)
	var curve := _interpolated(previous, target, "blood_stream_curve_m", progress)
	var flow_cycles := _interpolated(previous, target, "blood_flow_cycles", progress)
	var axis := -body_anchor.normalized()
	var reference := axis.cross(Vector3.UP).normalized()
	if reference.is_zero_approx():
		reference = axis.cross(Vector3.RIGHT).normalized()
	var written := 0
	for stream_index: int in stream_count:
		var angle := TAU * (float(stream_index) / float(maxi(stream_count, 1)) \
			+ progress * flow_cycles)
		var side := reference.rotated(axis, angle)
		for segment_index: int in segments:
			if written >= total:
				break
			var from_t := float(segment_index) / float(maxi(segments, 1))
			var to_t := float(segment_index + 1) / float(maxi(segments, 1))
			var from := _blood_stream_point(body_anchor, side, curve, from_t)
			var to := _blood_stream_point(body_anchor, side, curve, to_t)
			_blood_streams.multimesh.set_instance_transform(written,
				_line_transform(from, to, width))
			written += 1
	_blood_streams.multimesh.visible_instance_count = total
	_visible_blood_stream_instances = total if visibility > 0.0 and width > 0.0 else 0
	_blood_streams.visible = _visible_blood_stream_instances > 0


func _blood_stream_point(body_anchor: Vector3, side: Vector3,
		curve: float, amount: float) -> Vector3:
	return body_anchor.lerp(Vector3.ZERO, amount) \
		+ side * sin(amount * PI) * curve


func _line_transform(from: Vector3, to: Vector3, width: float) -> Transform3D:
	var direction := to - from
	var length := direction.length()
	if length <= 0.0:
		return Transform3D(Basis.IDENTITY, from)
	var up := Vector3.UP
	if absf(direction.normalized().dot(up)) > 0.95:
		up = Vector3.RIGHT
	var basis := Basis.looking_at(direction.normalized(), up) \
		* Basis.from_scale(Vector3(width, width, length))
	return Transform3D(basis, from.lerp(to, 0.5))


func _previous_vfx_profile(role: String) -> Dictionary:
	match role:
		"hold":
			return _vfx_profile("prepare")
		"release":
			return _vfx_profile("hold")
		"recover":
			return _vfx_profile("release")
		_:
			return {}


func _vfx_profile(role: String) -> Dictionary:
	return ((_phase_profiles.get(role, {}) as Dictionary).get("vfx", {}) \
		as Dictionary)


func _phase_frames(role: String) -> int:
	return int((_phase_profiles.get(role, {}) as Dictionary).get("phase_frames", 0))


func _maximum_profile_count(field: String) -> int:
	var maximum := 0
	for role: String in _phase_profiles:
		if role.begins_with("_"):
			continue
		maximum = maxi(maximum, int(_vfx_profile(role).get(field, 0)))
	return maximum


func _maximum_profile_product(first_field: String, second_field: String) -> int:
	var maximum := 0
	for role: String in _phase_profiles:
		if role.begins_with("_"):
			continue
		var profile := _vfx_profile(role)
		maximum = maxi(maximum, int(profile.get(first_field, 0)) \
			* int(profile.get(second_field, 0)))
	return maximum


func _interpolated(previous: Dictionary, target: Dictionary,
		field: String, progress: float) -> float:
	var target_value := float(target.get(field, previous.get(field, 0.0)))
	var previous_value := float(previous.get(field, 0.0))
	return lerpf(previous_value, target_value, progress)


func _set_material_opacity(material: StandardMaterial3D,
		base_color: Color, opacity: float) -> void:
	if material == null:
		return
	var color := base_color
	color.a = base_color.a * opacity
	material.albedo_color = color
	material.emission = color


func _new_multimesh(mesh: Mesh, capacity: int) -> MultiMesh:
	var multimesh := MultiMesh.new()
	multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh.mesh = mesh
	multimesh.instance_count = maxi(capacity, 0)
	multimesh.visible_instance_count = 0
	return multimesh


func _nearest_caster(tip_position: Vector3) -> Node3D:
	var nearest: Node3D
	var nearest_distance := INF
	for node: Node in get_tree().get_nodes_in_group("player"):
		var candidate := node as Node3D
		if candidate == null:
			continue
		var distance := candidate.global_position.distance_squared_to(tip_position)
		if distance < nearest_distance:
			nearest = candidate
			nearest_distance = distance
	return nearest


static func _focus_mesh(render: Dictionary) -> SphereMesh:
	if _focus_mesh_cache != null:
		return _focus_mesh_cache
	var diameter := float(render.get("base_diameter_m", 0.0))
	var mesh := SphereMesh.new()
	mesh.radius = diameter * 0.5
	mesh.height = diameter
	mesh.radial_segments = int(render.get("radial_segments", 0))
	mesh.rings = int(render.get("rings", 0))
	_focus_mesh_cache = mesh
	return _focus_mesh_cache


static func _blood_stream_mesh() -> BoxMesh:
	if _blood_stream_mesh_cache != null:
		return _blood_stream_mesh_cache
	_blood_stream_mesh_cache = BoxMesh.new()
	_blood_stream_mesh_cache.size = Vector3.ONE
	return _blood_stream_mesh_cache


static func _cast_phase_profiles() -> Dictionary:
	if not _phase_profiles_cache.is_empty():
		return _phase_profiles_cache.duplicate(true)
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(
		ANIMATION_CATALOGUE_PATH))
	if not parsed is Dictionary:
		return {}
	var catalogue := parsed as Dictionary
	var states: Dictionary = ((catalogue.get("player", {}) as Dictionary).get(
		"states", {}) as Dictionary)
	var profiles := {"_reference_fps": float(catalogue.get(
		"reference_fps", Engine.physics_ticks_per_second))}
	for state_key: String in states:
		var state := states.get(state_key, {}) as Dictionary
		var role := String(state.get("cast_phase", ""))
		if role.is_empty():
			continue
		var profile := state.duplicate(true)
		profile["state_key"] = state_key
		profiles[role] = profile
	_phase_profiles_cache = profiles
	return profiles.duplicate(true)


static func phase_vfx_profile(role: String) -> Dictionary:
	return ((_cast_phase_profiles().get(role, {}) as Dictionary).get(
		"vfx", {}) as Dictionary).duplicate(true)
