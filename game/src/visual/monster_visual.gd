class_name MonsterVisual
extends Node3D
## Apresentação dos três inimigos da Fatia 1.
##
## Altura, proporção, materiais e armadura vêm de um catálogo visual próprio.
## A cápsula e todos os números de combate continuam a pertencer ao Enemy.

const PROFILE_PATH := "res://assets/models/enemies/monster_visual_profiles.json"

static var _catalogue: Dictionary = {}

var _enemy_id := ""
var _profile: Dictionary = {}
var _body: Node3D
var _body_bounds := AABB()
var _visual_bounds := AABB()
var _animation_player: AnimationPlayer
var _materials: Array[StandardMaterial3D] = []
var _base_colours: Array[Color] = []
var _current_animation := ""
var _current_tint := Color(-1.0, -1.0, -1.0, -1.0)


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
	_build_body(casts_shadow)
	_build_overlay(casts_shadow)
	_configure_loops()
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
	if tint.is_equal_approx(_current_tint):
		return
	_current_tint = tint
	for index: int in _materials.size():
		_materials[index].albedo_color = _base_colours[index] * tint


func play_animation(semantic_name: String, speed := 1.0) -> void:
	if _animation_player == null:
		return
	var animation_name := _animation_for(semantic_name)
	if not _animation_player.has_animation(animation_name):
		animation_name = _animation_for("Idle")
	if not _animation_player.has_animation(animation_name):
		return
	if _current_animation == animation_name and _animation_player.is_playing():
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
	add_child(_body)
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
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for raw_part: Variant in _profile.get("geometry", []):
		var part := raw_part as Dictionary
		var primitive := _primitive_for(part)
		if primitive == null:
			continue
		var transform := Transform3D(Basis.from_euler(_vec3(part.get("rotation_deg", [])) * PI / 180.0),
			_vec3(part.get("position_ratio", [])) * target_height_m())
		transform.basis = transform.basis.scaled(Vector3.ONE * target_height_m())
		surface.append_from(primitive, 0, transform)
	var overlay_mesh := surface.commit()
	if overlay_mesh == null:
		_visual_bounds = _body_bounds
		return
	var overlay := MeshInstance3D.new()
	overlay.name = "ArmaduraESilhueta"
	overlay.mesh = overlay_mesh
	overlay.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON if casts_shadow \
		else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(String(_profile.get("overlay_color", "#25292a")))
	material.roughness = float(_profile.get("overlay_roughness", 0.92))
	material.metallic = float(_profile.get("overlay_metallic", 0.18))
	material.metallic_specular = float(_profile.get("overlay_specular", 0.12))
	overlay.material_override = material
	add_child(overlay)
	_materials.append(material)
	_base_colours.append(material.albedo_color)
	_visual_bounds = _body_bounds.merge(overlay.get_aabb())


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
			material.albedo_color *= body_tint
			material.roughness = float(_profile.get("body_roughness", 0.94))
			material.metallic = 0.0
			material.metallic_specular = float(_profile.get("body_specular", 0.08))
			mesh_instance.set_surface_override_material(surface_index, material)
			_materials.append(material)
			_base_colours.append(material.albedo_color)


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
