class_name ArmorCharacterVisual
extends CharacterVisual
## Extensão não invasiva do CharacterVisual. Os corpos KayKit partilham nomes
## de ossos e expõem cabeça/rosto/peito/capa como malhas separadas; trocamos só
## a malha do slot. Assim o peitoral muda sem substituir a silhueta da origem.

static var _donor_cache := {}

var _armor_class_id := ""
var _armor_casts_shadow := true
var _last_actor_tint := Color.WHITE
var _base_parts := {}
var _added_parts: Array[MeshInstance3D] = []
var _signatures := {}


func setup(target_height: float, tint := Color.WHITE, casts_shadow := true,
		body_id := "body_male", class_id := "") -> void:
	_armor_class_id = class_id if class_id != "" else _parent_class_id()
	_armor_casts_shadow = casts_shadow
	super.setup(target_height, tint, casts_shadow, body_id, class_id)
	_capture_base_parts()


func set_tint(tint: Color) -> void:
	_last_actor_tint = tint
	super.set_tint(tint)


func apply_armor(piece_ids: Array) -> void:
	_restore_base_parts()
	_signatures.clear()
	var recipes: Dictionary = ((GameData.armor.get("visual_rules", {}) as Dictionary).get(
		"recipes", {}) as Dictionary)
	var by_slot := {}
	for piece_value: Variant in piece_ids:
		var piece_id := String(piece_value)
		var recipe: Dictionary = recipes.get(piece_id, {}) as Dictionary
		if not recipe.is_empty():
			by_slot[String(recipe.get("slot", ""))] = {"id": piece_id, "recipe": recipe}
	for slot: String in by_slot:
		var selection: Dictionary = by_slot[slot] as Dictionary
		var recipe: Dictionary = selection.get("recipe", {}) as Dictionary
		var donor := _donor_part(String(recipe.get("donor", "")),
			String(recipe.get("part_suffix", "")))
		if donor.is_empty():
			continue
		var tint := Color(String(recipe.get("tint", "#ffffff")))
		var target := _first_base_part(slot)
		if target != null:
			_apply_donor(target, donor, tint)
		else:
			var added := _add_donor(donor, tint, slot)
			if added == null:
				continue
		_signatures[slot] = "%s:%s:%s" % [selection.get("id", ""),
			recipe.get("donor", ""), recipe.get("part_suffix", "")]


func silhouette_key() -> String:
	return _armor_class_id


func visual_signature(slot: String) -> String:
	return String(_signatures.get(slot, ""))


func visualized_slots() -> Array:
	return _signatures.keys()


func draw_surface_count() -> int:
	var total := 0
	for mesh_node: Node in find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := mesh_node as MeshInstance3D
		if mesh_instance.visible and mesh_instance.mesh != null:
			total += mesh_instance.mesh.get_surface_count()
	return total


func _capture_base_parts() -> void:
	_base_parts.clear()
	for mesh_node: Node in find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := mesh_node as MeshInstance3D
		var slot := _semantic_slot(mesh_instance.name)
		if slot == "":
			continue
		if not _base_parts.has(slot):
			_base_parts[slot] = []
		var overrides: Array[Material] = []
		if mesh_instance.mesh != null:
			for surface: int in mesh_instance.mesh.get_surface_count():
				overrides.append(mesh_instance.get_surface_override_material(surface))
		(_base_parts[slot] as Array).append({
			"node": mesh_instance,
			"mesh": mesh_instance.mesh,
			"skin": mesh_instance.skin,
			"transform": mesh_instance.transform,
			"visible": mesh_instance.visible,
			"overrides": overrides,
		})


func _restore_base_parts() -> void:
	for added: MeshInstance3D in _added_parts:
		if is_instance_valid(added):
			added.free()
	_added_parts.clear()
	for slot: String in _base_parts:
		for snapshot_value: Variant in _base_parts[slot]:
			var snapshot: Dictionary = snapshot_value as Dictionary
			var mesh_instance := snapshot.get("node") as MeshInstance3D
			if not is_instance_valid(mesh_instance):
				continue
			mesh_instance.mesh = snapshot.get("mesh") as Mesh
			mesh_instance.skin = snapshot.get("skin") as Skin
			mesh_instance.transform = snapshot.get("transform") as Transform3D
			mesh_instance.visible = bool(snapshot.get("visible", true))
			_clear_overrides(mesh_instance)
			var overrides: Array = snapshot.get("overrides", []) as Array
			for surface: int in mini(overrides.size(), mesh_instance.mesh.get_surface_count()):
				mesh_instance.set_surface_override_material(surface, overrides[surface] as Material)


func _first_base_part(slot: String) -> MeshInstance3D:
	var snapshots: Array = _base_parts.get(slot, []) as Array
	if snapshots.is_empty():
		return null
	return (snapshots[0] as Dictionary).get("node") as MeshInstance3D


func _apply_donor(target: MeshInstance3D, donor: Dictionary, tint: Color) -> void:
	target.mesh = donor.get("mesh") as Mesh
	target.skin = donor.get("skin") as Skin
	target.transform = donor.get("transform") as Transform3D
	target.visible = true
	_apply_materials(target, tint)


func _add_donor(donor: Dictionary, tint: Color, slot: String) -> MeshInstance3D:
	var skeleton := _find_skeleton(self)
	if skeleton == null:
		return null
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "Armor_%s" % slot
	mesh_instance.mesh = donor.get("mesh") as Mesh
	mesh_instance.skin = donor.get("skin") as Skin
	mesh_instance.transform = donor.get("transform") as Transform3D
	mesh_instance.skeleton = NodePath("..")
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_ON \
		if _armor_casts_shadow else GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	skeleton.add_child(mesh_instance)
	_added_parts.append(mesh_instance)
	_meshes.append(mesh_instance)
	_apply_materials(mesh_instance, tint)
	return mesh_instance


func _apply_materials(mesh_instance: MeshInstance3D, tint: Color) -> void:
	_clear_overrides(mesh_instance)
	if mesh_instance.mesh == null:
		return
	for surface: int in mesh_instance.mesh.get_surface_count():
		var source := mesh_instance.mesh.surface_get_material(surface) as StandardMaterial3D
		if source != null:
			mesh_instance.set_surface_override_material(surface, _shared_material_for(source))
	mesh_instance.set_instance_shader_parameter("actor_tint", _last_actor_tint)
	mesh_instance.set_instance_shader_parameter("class_tint", tint)


static func _clear_overrides(mesh_instance: MeshInstance3D) -> void:
	if mesh_instance.mesh == null:
		return
	for surface: int in mesh_instance.mesh.get_surface_count():
		mesh_instance.set_surface_override_material(surface, null)


static func _semantic_slot(mesh_name: String) -> String:
	if mesh_name.ends_with("_Helmet") or mesh_name.ends_with("_Hat") \
			or mesh_name.ends_with("_BearHat"):
		return "cabeca"
	if mesh_name.ends_with("_HelmetVisor") or mesh_name.ends_with("_Mask"):
		return "rosto"
	if mesh_name.ends_with("_Body"):
		return "peito"
	if mesh_name.ends_with("_Cape"):
		return "capa"
	return ""


static func _donor_part(scene_path: String, suffix: String) -> Dictionary:
	var key := "%s|%s" % [scene_path, suffix]
	if _donor_cache.has(key):
		return _donor_cache[key] as Dictionary
	var packed := load(scene_path) as PackedScene
	if packed == null:
		return {}
	var root := packed.instantiate()
	var found := {}
	for mesh_node: Node in root.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := mesh_node as MeshInstance3D
		if mesh_instance.name.ends_with(suffix):
			found = {
				"mesh": mesh_instance.mesh,
				"skin": mesh_instance.skin,
				"transform": mesh_instance.transform,
			}
			break
	root.free()
	if not found.is_empty():
		_donor_cache[key] = found
	return found
