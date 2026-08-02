class_name MonsterVisual
extends Node3D
## Apresentação dos três inimigos da Fatia 1.
##
## Altura, proporção, materiais e armadura vêm de um catálogo visual próprio.
## A cápsula e todos os números de combate continuam a pertencer ao Enemy.

const PROFILE_PATH := "res://assets/models/enemies/monster_visual_profiles.json"
const ENEMY_HUD_RENDERER = preload("res://src/ui/enemy_hud.gd")

const PHASE_NONE := 0
const PHASE_PREPARATION := 1
const PHASE_STRIKE := 2
const PHASE_RECOVERY := 3

static var _catalogue: Dictionary = {}

var _enemy_id := ""
var _profile: Dictionary = {}
var _pose_root: Node3D
var _body: Node3D
var _body_bounds := AABB()
var _visual_bounds := AABB()
var _animation_player: AnimationPlayer
var _weapon_pivot: Node3D
var _materials: Array[StandardMaterial3D] = []
var _base_colours: Array[Color] = []
var _base_emission: Array[float] = []
var _current_animation := ""
var _current_tint := Color(-1.0, -1.0, -1.0, -1.0)
var _attack_phase := PHASE_NONE
var _attack_progress := 0.0
var _hit_flash := 0.0
var _is_dead := false


## Aceita a assinatura histórica (id, altura, tinta, sombra) e a assinatura do
## renderer corrente (id, dados, perfil, sombra, semente). Em ambos os casos a
## escala visual vem exclusivamente do JSON desta classe.
func setup(enemy_id: String, target_or_enemy_data: Variant = 0.0,
		tint_or_runtime_profile: Variant = Color.WHITE, casts_shadow := false,
		_variant_seed := 0) -> void:
	name = "MonsterVisual"
	_enemy_id = enemy_id
	_profile = profile_for(enemy_id)
	if _profile.is_empty():
		push_error("[MonsterVisual] família sem perfil: %s" % enemy_id)
		return

	var initial_tint := Color.WHITE
	if tint_or_runtime_profile is Color:
		initial_tint = tint_or_runtime_profile as Color
	_validate_height_hint(target_or_enemy_data, tint_or_runtime_profile)
	_pose_root = Node3D.new()
	_pose_root.name = "PoseRoot"
	add_child(_pose_root)
	_build_body(casts_shadow)
	_build_overlay(casts_shadow)
	_build_facing_markers()
	_configure_loops()
	_connect_enemy_signals()
	_install_enemy_hud()
	set_tint(initial_tint)
	play_animation("Idle")


static func profile_for(enemy_id: String) -> Dictionary:
	_ensure_catalogue()
	var families: Dictionary = _catalogue.get("families", {}) as Dictionary
	return (families.get(enemy_id, {}) as Dictionary).duplicate(true)


static func family_ids() -> Array[String]:
	_ensure_catalogue()
	var ids: Array[String] = []
	var families: Dictionary = _catalogue.get("families", {}) as Dictionary
	for enemy_id: String in families.keys():
		ids.append(enemy_id)
	ids.sort()
	return ids


static func audit_rules() -> Dictionary:
	_ensure_catalogue()
	return (_catalogue.get("audit", {}) as Dictionary).duplicate(true)


func target_height_m() -> float:
	return float(_profile.get("target_height_m", 0.0))


func body_bounds() -> AABB:
	return _body_bounds


func visual_bounds() -> AABB:
	return _visual_bounds


func silhouette_signature() -> String:
	return String(_profile.get("silhouette_signature", ""))


func set_tint(tint: Color) -> void:
	_current_tint = tint
	_apply_material_tint()


func play_animation(semantic_name: String, speed := 1.0) -> void:
	if _animation_player == null:
		return
	var animation_name := _animation_for(semantic_name)
	if not _animation_player.has_animation(animation_name):
		animation_name = _animation_for("Idle")
	if not _animation_player.has_animation(animation_name):
		return
	if _current_animation == animation_name:
		# A morte toca uma vez e fica na pose final. Reinicia-la todos os frames era
		# a origem do cadaver que continuava a mexer-se.
		if semantic_name == "Death01" or _animation_player.is_playing():
			return
	_current_animation = animation_name
	_animation_player.play(animation_name,
		float(_catalogue.get("animation_blend_s", 0.0)), speed)


func _build_body(casts_shadow: bool) -> void:
	var scene_path := String(_profile.get("scene_path", ""))
	var body_scene := load(scene_path) as PackedScene
	if body_scene == null:
		push_error("[MonsterVisual] modelo em falta: %s (%s)" % [_enemy_id, scene_path])
		return
	_body = body_scene.instantiate() as Node3D
	if _body == null:
		push_error("[MonsterVisual] raiz 3D inválida: %s" % scene_path)
		return
	_body.name = "Body"
	_pose_root.add_child(_body)
	_hide_declared_meshes(_body)
	var source_bounds := _descendant_mesh_bounds(_body)
	if source_bounds.size.y <= 0.0:
		push_error("[MonsterVisual] modelo sem volume: %s" % _enemy_id)
		return

	var measured_height := source_bounds.size.y
	var expected_height := float(_profile.get("source_height_m", 0.0))
	var source_tolerance := float(_profile.get("source_height_tolerance_m", 0.0))
	if absf(measured_height - expected_height) > source_tolerance:
		push_error("[MonsterVisual] fonte %s mede %.6f m; JSON declara %.6f m" % [
			_enemy_id, measured_height, expected_height])

	var target_height := target_height_m()
	var scale_factor := target_height / measured_height
	_body.rotation_degrees.y = float(_profile.get("body_yaw_deg", 0.0))
	_body.scale = Vector3(
		scale_factor * float(_profile.get("width_scale", 1.0)),
		scale_factor,
		scale_factor * float(_profile.get("depth_scale", 1.0)))
	# O pivot é derivado dos pés reais do mesh. Assim, trocar ou reimportar o
	# modelo não volta a enterrar o corpo nem exige um offset adivinhado.
	_body.position.y = -source_bounds.position.y * scale_factor
	_body_bounds = _body.transform * source_bounds
	_collect_body_materials(_body, casts_shadow)
	_animation_player = _find_animation_player(_body)


func _build_overlay(casts_shadow: bool) -> void:
	var geometry: Array = _profile.get("geometry", []) as Array
	var weapon_start := _weapon_start_index(geometry.size())
	_build_overlay_group(geometry, 0, weapon_start, "ArmaduraESilhueta", false,
		casts_shadow)
	_build_overlay_group(geometry, weapon_start, geometry.size(), "ArmaLegivel", true,
		casts_shadow)
	if _visual_bounds.size == Vector3.ZERO:
		_visual_bounds = _body_bounds


func _build_overlay_group(parts: Array, from_index: int, to_index: int,
		group_name: String, is_weapon: bool, casts_shadow: bool) -> void:
	if from_index >= to_index:
		return
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for part_index: int in range(from_index, to_index):
		var part := parts[part_index] as Dictionary
		var primitive := _primitive_for(part)
		if primitive == null:
			continue
		var transform := Transform3D(Basis.from_euler(_vec3(part.get("rotation_deg", [])) * PI / 180.0),
			_vec3(part.get("position_ratio", [])) * target_height_m())
		transform.basis = transform.basis.scaled(Vector3.ONE * target_height_m())
		surface.append_from(primitive, 0, transform)
	var overlay_mesh := surface.commit()
	if overlay_mesh == null:
		return
	var overlay := MeshInstance3D.new()
	overlay.name = group_name
	overlay.mesh = overlay_mesh
	overlay.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if casts_shadow \
		else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material := StandardMaterial3D.new()
	var base_colour := Color(String(_profile.get("overlay_color", "#25292a")))
	if is_weapon:
		# Metal/haste nao podem fundir-se com a armadura. A cor quente tambem faz a
		# arma legivel em contraluz sem precisar de uma luz por inimigo.
		base_colour = base_colour.lerp(Color("b89a66"), 0.58)
	else:
		base_colour = base_colour.lerp(Color("72807d"), 0.34)
	base_colour = _lift_colour(base_colour, 0.43 if is_weapon else 0.36)
	material.albedo_color = base_colour
	material.roughness = float(_profile.get("overlay_roughness", 0.92))
	material.metallic = maxf(float(_profile.get("overlay_metallic", 0.18)),
		0.42 if is_weapon else 0.18)
	material.metallic_specular = float(_profile.get("overlay_specular", 0.12))
	overlay.material_override = material
	_register_material(material, base_colour, 0.26 if is_weapon else 0.18)
	if is_weapon:
		var bounds := overlay.get_aabb()
		var pivot_position := Vector3(bounds.get_center().x,
			bounds.position.y + bounds.size.y * 0.35, bounds.get_center().z)
		_weapon_pivot = Node3D.new()
		_weapon_pivot.name = "WeaponPosePivot"
		_weapon_pivot.position = pivot_position
		_pose_root.add_child(_weapon_pivot)
		overlay.position = -pivot_position
		_weapon_pivot.add_child(overlay)
	else:
		_pose_root.add_child(overlay)
	_visual_bounds = _body_bounds.merge(overlay.get_aabb()) \
		if _visual_bounds.size == Vector3.ZERO else _visual_bounds.merge(overlay.get_aabb())


func _weapon_start_index(part_count: int) -> int:
	match _enemy_id:
		"orc_spearman": return mini(9, part_count)
		"orc_brute", "vorgar": return mini(8, part_count)
	return part_count


func _primitive_for(part: Dictionary) -> PrimitiveMesh:
	var kind := String(part.get("kind", ""))
	if kind == "box":
		var box := BoxMesh.new()
		box.size = _vec3(part.get("size_ratio", []))
		return box
	if kind == "cylinder" or kind == "cone":
		var cylinder := CylinderMesh.new()
		cylinder.height = float(part.get("height_ratio", 0.0))
		cylinder.bottom_radius = float(part.get("bottom_radius_ratio", 0.0))
		cylinder.top_radius = 0.0 if kind == "cone" else float(
			part.get("top_radius_ratio", cylinder.bottom_radius))
		cylinder.radial_segments = int(_catalogue.get("overlay_radial_segments", 8))
		return cylinder
	return null


func _collect_body_materials(node: Node, casts_shadow: bool) -> void:
	var body_tint := Color(String(_profile.get("body_tint", "#ffffff")))
	for descendant: Node in node.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := descendant as MeshInstance3D
		if not casts_shadow:
			mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for surface_index: int in mesh_instance.mesh.get_surface_count():
			var source := mesh_instance.mesh.surface_get_material(surface_index) as StandardMaterial3D
			if source == null:
				continue
			var material := source.duplicate() as StandardMaterial3D
			var base_colour := _lift_colour(material.albedo_color * body_tint, 0.38)
			material.albedo_color = base_colour
			material.roughness = float(_profile.get("body_roughness", 0.94))
			material.metallic = 0.0
			material.metallic_specular = float(_profile.get("body_specular", 0.08))
			# A textura continua a dar pele/couro/metal. Uma emissao baixa usa a mesma
			# textura como preenchimento e impede que o corpo desapareca em contraluz.
			material.emission_texture = material.albedo_texture
			mesh_instance.set_surface_override_material(surface_index, material)
			_register_material(material, base_colour, 0.16)


func _build_facing_markers() -> void:
	if _pose_root == null or _body_bounds.size.y <= 0.0:
		return
	var height := _body_bounds.size.y
	var front_z := _body_bounds.position.z - _body_bounds.size.z * 0.52
	var face_y := _body_bounds.position.y + height * 0.73
	var material := StandardMaterial3D.new()
	var amber := Color("f0b85e")
	material.albedo_color = amber
	material.roughness = 0.48
	material.emission_enabled = true
	material.emission = amber
	material.emission_energy_multiplier = 1.15
	for side: float in [-1.0, 1.0]:
		var eye_mesh := SphereMesh.new()
		eye_mesh.radius = height * 0.018
		eye_mesh.height = height * 0.036
		eye_mesh.radial_segments = 8
		eye_mesh.rings = 4
		var eye := MeshInstance3D.new()
		eye.name = "OlhoFrente"
		eye.mesh = eye_mesh
		eye.position = Vector3(side * height * 0.055, face_y, front_z)
		eye.material_override = material
		eye.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_pose_root.add_child(eye)
	_register_material(material, amber, 1.15)


func _register_material(material: StandardMaterial3D, base_colour: Color,
		emission_energy: float) -> void:
	material.emission_enabled = true
	material.emission = base_colour
	material.emission_energy_multiplier = emission_energy
	_materials.append(material)
	_base_colours.append(base_colour)
	_base_emission.append(emission_energy)


func _apply_material_tint() -> void:
	if _current_tint.a < 0.0:
		return
	for index: int in _materials.size():
		var colour := _base_colours[index] * _current_tint
		if _is_dead:
			# Morto = frio e dessaturado, nao preto. O corpo precisa de continuar a
			# parecer um cadaver e nao uma falha de material.
			colour = colour.lerp(Color("777a76"), 0.48)
		colour = _lift_colour(colour, 0.22 if _is_dead else 0.30)
		if _hit_flash > 0.0:
			colour = colour.lerp(Color("fff1cf"), _hit_flash)
		_materials[index].albedo_color = colour
		_materials[index].emission = colour
		_materials[index].emission_energy_multiplier = _base_emission[index] \
			+ _hit_flash * 0.95


static func _lift_colour(colour: Color, minimum_value: float) -> Color:
	var current := maxf(colour.r, maxf(colour.g, colour.b))
	if current >= minimum_value:
		return colour
	var amount := (minimum_value - current) / maxf(1.0 - current, 0.001)
	var lifted := colour.lerp(Color(1.0, 1.0, 1.0, colour.a), amount)
	lifted.a = colour.a
	return lifted


func _hide_declared_meshes(node: Node) -> void:
	var hidden_names: Array = _profile.get("hide_mesh_names", []) as Array
	for descendant: Node in node.find_children("*", "MeshInstance3D", true, false):
		if hidden_names.has(descendant.name):
			(descendant as MeshInstance3D).visible = false


func _validate_height_hint(target_or_enemy_data: Variant,
		runtime_profile_or_tint: Variant) -> void:
	var hinted_height := 0.0
	if target_or_enemy_data is float or target_or_enemy_data is int:
		hinted_height = float(target_or_enemy_data)
	elif runtime_profile_or_tint is Dictionary:
		hinted_height = float((runtime_profile_or_tint as Dictionary).get("target_height_m", 0.0))
	if hinted_height <= 0.0:
		return
	var tolerance := float(audit_rules().get("height_hint_tolerance_m", 0.0))
	if absf(hinted_height - target_height_m()) > tolerance:
		push_warning("[MonsterVisual] %s: colisão %.3f m, arte %.3f m" % [
		_enemy_id, hinted_height, target_height_m()])


func _connect_enemy_signals() -> void:
	var enemy := get_parent()
	if enemy == null:
		return
	if enemy.has_signal("attack_phase_changed"):
		enemy.connect("attack_phase_changed", _on_attack_phase_changed)
	if enemy.has_signal("health_changed"):
		enemy.connect("health_changed", _on_health_changed)
	if enemy.has_signal("state_changed"):
		enemy.connect("state_changed", _on_state_changed)
	if enemy.has_method("is_alive"):
		_is_dead = not bool(enemy.call("is_alive"))


func _install_enemy_hud() -> void:
	var enemy := get_parent()
	if enemy == null or not enemy.has_signal("health_changed"):
		return
	var scene := get_tree().current_scene
	if scene == null:
		call_deferred("_install_enemy_hud")
		return
	var hud := scene.get_node_or_null("EnemyHud")
	if hud == null:
		hud = ENEMY_HUD_RENDERER.new()
		hud.name = "EnemyHud"
		scene.add_child(hud)
	if hud.has_method("register_enemy"):
		hud.call("register_enemy", get_parent())


func _on_attack_phase_changed(phase: int, progress: float, _parryable: bool,
		_attack_id: String) -> void:
	_attack_phase = phase
	_attack_progress = progress


func _on_health_changed(_current: float, _maximum: float, delta: float,
		_source: Node3D) -> void:
	if delta < 0.0:
		_hit_flash = 1.0
		_apply_material_tint()


func _on_state_changed(_current: int, _previous: int) -> void:
	var enemy := get_parent()
	var was_dead := _is_dead
	_is_dead = enemy != null and enemy.has_method("is_alive") \
		and not bool(enemy.call("is_alive"))
	if was_dead and not _is_dead:
		_pose_root.rotation = Vector3.ZERO
		_pose_root.position = Vector3.ZERO
		if _weapon_pivot != null:
			_weapon_pivot.rotation = Vector3.ZERO
	_apply_material_tint()


func _process(delta: float) -> void:
	if _pose_root == null:
		return
	if _hit_flash > 0.0:
		_hit_flash = move_toward(_hit_flash, 0.0, delta * 8.0)
		_apply_material_tint()
	_update_combat_pose(delta)


func _update_combat_pose(delta: float) -> void:
	var body_rotation := Vector3.ZERO
	var body_position := Vector3.ZERO
	var weapon_rotation := Vector3.ZERO
	var height := maxf(target_height_m(), 1.0)
	if _is_dead:
		body_rotation.z = deg_to_rad(82.0)
		body_rotation.x = deg_to_rad(-8.0)
		weapon_rotation.z = deg_to_rad(105.0)
	else:
		match _attack_phase:
			PHASE_PREPARATION:
				var ease := smoothstep(0.0, 1.0, _attack_progress)
				body_rotation.x = deg_to_rad(11.0 * ease)
				body_position.z = height * 0.075 * ease
				weapon_rotation = _weapon_pose_preparation() * ease
			PHASE_STRIKE:
				body_rotation.x = deg_to_rad(lerpf(11.0, -17.0, _attack_progress))
				body_position.z = height * lerpf(0.075, -0.10, _attack_progress)
				weapon_rotation = _lerp_rotation(_weapon_pose_preparation(),
					_weapon_pose_strike(), _attack_progress)
			PHASE_RECOVERY:
				body_rotation.x = deg_to_rad(lerpf(-17.0, 0.0, _attack_progress))
				body_position.z = height * lerpf(-0.10, 0.0, _attack_progress)
				weapon_rotation = _lerp_rotation(_weapon_pose_strike(), Vector3.ZERO,
					_attack_progress)
	if _hit_flash > 0.0 and not _is_dead:
		body_rotation.z += deg_to_rad(9.0 * _hit_flash)
		body_position.z += height * 0.10 * _hit_flash
	var blend := clampf(delta * (12.0 if _is_dead else 38.0), 0.0, 1.0)
	_pose_root.rotation = _lerp_rotation(_pose_root.rotation, body_rotation, blend)
	_pose_root.position = _pose_root.position.lerp(body_position, blend)
	if _weapon_pivot != null:
		_weapon_pivot.rotation = _lerp_rotation(_weapon_pivot.rotation,
			weapon_rotation, blend)


func _weapon_pose_preparation() -> Vector3:
	if _enemy_id == "orc_spearman":
		return Vector3(deg_to_rad(54.0), 0.0, deg_to_rad(-18.0))
	return Vector3(deg_to_rad(-24.0), 0.0, deg_to_rad(-102.0))


func _weapon_pose_strike() -> Vector3:
	if _enemy_id == "orc_spearman":
		return Vector3(deg_to_rad(-88.0), 0.0, deg_to_rad(5.0))
	return Vector3(deg_to_rad(-58.0), 0.0, deg_to_rad(62.0))


static func _lerp_rotation(from: Vector3, to: Vector3, weight: float) -> Vector3:
	return Vector3(lerp_angle(from.x, to.x, weight), lerp_angle(from.y, to.y, weight),
		lerp_angle(from.z, to.z, weight))


func _configure_loops() -> void:
	if _animation_player == null:
		return
	for looping: String in ["Idle", "Walk", "Run"]:
		if _animation_player.has_animation(looping):
			_animation_player.get_animation(looping).loop_mode = Animation.LOOP_LINEAR


func _animation_for(semantic_name: String) -> String:
	var animations: Dictionary = _profile.get("animations", {}) as Dictionary
	return String(animations.get(semantic_name, animations.get("Idle", "Idle")))


static func _ensure_catalogue() -> void:
	if not _catalogue.is_empty():
		return
	var text := FileAccess.get_file_as_string(PROFILE_PATH)
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("[MonsterVisual] JSON inválido: %s" % PROFILE_PATH)
		return
	_catalogue = parsed as Dictionary


static func _descendant_mesh_bounds(root_node: Node) -> AABB:
	var merged := AABB()
	var has_bounds := false
	for child: Node in root_node.get_children():
		var result := _bounds_below(child, Transform3D.IDENTITY)
		if not bool(result.get("valid", false)):
			continue
		var child_bounds: AABB = result.get("bounds", AABB()) as AABB
		merged = merged.merge(child_bounds) if has_bounds else child_bounds
		has_bounds = true
	return merged


static func _bounds_below(node: Node, parent_transform: Transform3D) -> Dictionary:
	var transform := parent_transform
	if node is Node3D:
		transform *= (node as Node3D).transform
	var merged := AABB()
	var has_bounds := false
	if node is MeshInstance3D and (node as MeshInstance3D).visible:
		merged = transform * (node as MeshInstance3D).get_aabb()
		has_bounds = true
	for child: Node in node.get_children():
		var result := _bounds_below(child, transform)
		if not bool(result.get("valid", false)):
			continue
		var child_bounds: AABB = result.get("bounds", AABB()) as AABB
		merged = merged.merge(child_bounds) if has_bounds else child_bounds
		has_bounds = true
	return {"valid": has_bounds, "bounds": merged}


static func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child: Node in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null


static func _vec3(value: Variant) -> Vector3:
	var raw := value as Array
	if raw.size() != 3:
		return Vector3.ZERO
	return Vector3(float(raw[0]), float(raw[1]), float(raw[2]))
