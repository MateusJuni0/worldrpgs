class_name ArmorVisual
extends CharacterVisual
## Armadura modular para o corpo Quaternius.
##
## [CODEX] As peças da Fatia 1 usam cascas curvas de baixo custo presas aos
## ossos UAL. Razão: nenhum modelo modular do repositório partilha o Skin
## Quaternius, e misturar o Skin KayKit foi a origem dos volumes colados ao
## corpo. Alternativa descartada: reutilizar personagens KayKit como roupa;
## mudaria corpo, proporção e esqueleto em cada troca.

const SLOT_ORDER := [
	"cabeca", "rosto", "ombros", "peito", "maos", "cintura", "pernas", "pes", "capa",
]

static var _material_cache := {}

var _armor_attachments: Array[BoneAttachment3D] = []
var _armor_piece_ids: Array[String] = []
var _signatures := {}
var _armor_casts_shadow := true


func setup(target_height: float, tint := Color.WHITE, casts_shadow := true,
		body_id := "body_male", class_id := "") -> void:
	_armor_casts_shadow = casts_shadow
	super.setup(target_height, tint, casts_shadow, body_id, class_id)
	_remove_origin_placeholders()


func apply_equipment(piece_ids: Array) -> void:
	_clear_armor()
	var selected_by_slot := {}
	for piece_value: Variant in piece_ids:
		var piece_id := String(piece_value)
		var data := _piece_data(piece_id)
		var slot := String(data.get("slot", ""))
		if not data.is_empty() and slot in SLOT_ORDER:
			selected_by_slot[slot] = piece_id
	for slot: String in SLOT_ORDER:
		var piece_id := String(selected_by_slot.get(slot, ""))
		if piece_id.is_empty():
			continue
		_build_piece(piece_id, _piece_data(piece_id))
		_armor_piece_ids.append(piece_id)


func equipped_piece_ids() -> Array[String]:
	return _armor_piece_ids.duplicate()


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


func armor_mesh_count() -> int:
	var total := 0
	for mesh_node: Node in find_children("*", "MeshInstance3D", true, false):
		if mesh_node.is_in_group("armor_visual_piece"):
			total += 1
	return total


func _remove_origin_placeholders() -> void:
	# CharacterVisual deixa uma fronteira de extensão, mas os placeholders da
	# origem incluem BoxMesh. Removemo-los só nesta subclasse; o corpo, Skin e
	# AnimationPlayer Quaternius ficam intactos.
	var attachments: Array[BoneAttachment3D] = []
	for mesh_node: Node in find_children("*", "MeshInstance3D", true, false):
		if not mesh_node.is_in_group("character_origin_outfit"):
			continue
		_meshes.erase(mesh_node as MeshInstance3D)
		var attachment := mesh_node.get_parent() as BoneAttachment3D
		if attachment != null and attachment not in attachments:
			attachments.append(attachment)
	for attachment: BoneAttachment3D in attachments:
		if is_instance_valid(attachment):
			attachment.free()
	clear_generated_origin_outfit()


func _clear_armor() -> void:
	for attachment: BoneAttachment3D in _armor_attachments:
		if not is_instance_valid(attachment):
			continue
		for descendant: Node in attachment.find_children("*", "MeshInstance3D", true, false):
			_meshes.erase(descendant as MeshInstance3D)
		attachment.free()
	_armor_attachments.clear()
	_armor_piece_ids.clear()
	_signatures.clear()


func _build_piece(piece_id: String, data: Dictionary) -> void:
	var slot := String(data.get("slot", ""))
	var material := _material_for(piece_id, data)
	match slot:
		"cabeca":
			_build_helmet(piece_id, material)
		"rosto":
			_build_face_wrap(piece_id, material)
		"ombros":
			_build_shoulders(piece_id, material)
		"peito":
			_build_cuirass(piece_id, material, "ferro" in String(data.get("material", "")).to_lower())
		"maos":
			_build_gauntlets(piece_id, material)
		"cintura":
			_build_belt(piece_id, material)
		"pernas":
			_build_greaves(piece_id, material)
		"pes":
			_build_boots(piece_id, material)
		"capa":
			_build_cape(piece_id, material)


func _build_cuirass(piece_id: String, material: Material, heavy: bool) -> void:
	var root := Node3D.new()
	root.name = "Armor_%s" % piece_id
	var shell := _mesh_instance("CurvedCuirass", _torso_shell_mesh(material, heavy))
	root.add_child(shell)
	var trim := _accent_material("polished_iron" if heavy else "dark_leather")
	var collar := _cylinder("RaisedCollar", 0.205 if heavy else 0.19,
		0.19 if heavy else 0.175, 0.065, trim)
	collar.scale.z = 0.74
	collar.position.y = 0.275
	root.add_child(collar)
	if heavy:
		var breast_plate := _mesh_instance("OverlappingBreastPlate", _breast_plate_mesh(trim))
		breast_plate.position = Vector3(0.0, 0.04, 0.15)
		root.add_child(breast_plate)
		for rivet_position: Vector3 in [
			Vector3(-0.205, 0.15, 0.17), Vector3(0.205, 0.15, 0.17),
			Vector3(-0.175, -0.15, 0.155), Vector3(0.175, -0.15, 0.155),
		]:
			var rivet := _sphere("ForgedRivet", Vector3.ONE * 0.018, trim)
			rivet.position = rivet_position
			root.add_child(rivet)
	else:
		for strap_config: Array in [[-0.13, -0.28], [0.13, 0.28]]:
			var strap := _capsule("ShoulderStrap", 0.022, 0.38, trim)
			strap.position = Vector3(float(strap_config[0]), 0.08, 0.17)
			strap.rotation.z = float(strap_config[1])
			root.add_child(strap)
		var seam := _capsule("StitchedCentreSeam", 0.012, 0.40, trim)
		seam.position = Vector3(0.0, -0.035, 0.19)
		root.add_child(seam)
	_attach(root, "spine_02", Vector3(0.0, 1.25, 0.01))
	_signatures["peito"] = "%s:layered_curved_%s" % [piece_id, "plate" if heavy else "leather"]


func _build_helmet(piece_id: String, material: Material) -> void:
	var root := Node3D.new()
	root.name = "Armor_%s" % piece_id
	var dome := _sphere("HammeredDome", Vector3(0.185, 0.17, 0.205), material)
	dome.position.y = 0.105
	root.add_child(dome)
	var skirt := _cylinder("HelmetSkirt", 0.185, 0.205, 0.235, material)
	skirt.position.y = -0.035
	root.add_child(skirt)
	var dark := _accent_material("iron_visor")
	var visor := _cylinder("TVisorBand", 0.19, 0.192, 0.045, dark)
	visor.scale.z = 1.06
	visor.position = Vector3(0.0, 0.005, -0.01)
	root.add_child(visor)
	var nasal := _capsule("TVisorNasal", 0.018, 0.13, dark)
	nasal.position = Vector3(0.0, -0.045, 0.205)
	root.add_child(nasal)
	_attach(root, "Head", Vector3(0.0, 1.68, 0.0))
	_signatures["cabeca"] = "%s:hammered_t_visor" % piece_id


func _build_face_wrap(piece_id: String, material: Material) -> void:
	var root := Node3D.new()
	root.name = "Armor_%s" % piece_id
	var wrap := _cylinder("CurvedFaceWrap", 0.153, 0.145, 0.13, material)
	wrap.scale.z = 0.86
	root.add_child(wrap)
	_attach(root, "Head", Vector3(0.0, 1.625, 0.01))
	_signatures["rosto"] = "%s:cloth_face_wrap" % piece_id


func _build_shoulders(piece_id: String, material: Material) -> void:
	var sides := [["upperarm_l", -0.08], ["upperarm_r", 0.08]]
	for side: Array in sides:
		var root := Node3D.new()
		root.name = "Armor_%s_%s" % [piece_id, String(side[0])]
		var pauldron := _sphere("LayeredPauldron", Vector3(0.18, 0.105, 0.205), material)
		pauldron.rotation.z = float(side[1])
		root.add_child(pauldron)
		var fur := _cylinder("FurEdge", 0.18, 0.19, 0.045, _accent_material("fur"))
		fur.rotation.z = PI * 0.5
		fur.scale.y = 0.72
		fur.position.y = -0.07
		root.add_child(fur)
		_attach_local(root, String(side[0]), Transform3D(Basis.IDENTITY, Vector3(0.0, 0.035, 0.0)))
	_signatures["ombros"] = "%s:paired_domelike_pauldrons" % piece_id


func _build_gauntlets(piece_id: String, material: Material) -> void:
	for bone_name: String in ["forearm_l", "forearm_r"]:
		var root := Node3D.new()
		root.name = "Armor_%s_%s" % [piece_id, bone_name]
		root.add_child(_cylinder("TaperedVambrace", 0.075, 0.105, 0.30, material))
		_attach_local(root, bone_name, Transform3D(Basis.IDENTITY, Vector3(0.0, 0.14, 0.0)))
	_signatures["maos"] = "%s:paired_tapered_vambraces" % piece_id


func _build_belt(piece_id: String, material: Material) -> void:
	var root := Node3D.new()
	root.name = "Armor_%s" % piece_id
	var belt := _cylinder("CurvedBelt", 0.255, 0.255, 0.085, material)
	belt.scale.z = 0.68
	root.add_child(belt)
	for x: float in [-0.18, -0.06, 0.07, 0.19]:
		var pouch := _sphere("RoundedPouch", Vector3(0.075, 0.09, 0.045), material)
		pouch.position = Vector3(x, -0.065, 0.155)
		root.add_child(pouch)
	_attach(root, "pelvis", Vector3(0.0, 0.98, 0.0))
	_signatures["cintura"] = "%s:curved_belt_four_pouches" % piece_id


func _build_greaves(piece_id: String, material: Material) -> void:
	for bone_name: String in ["calf_l", "calf_r"]:
		var root := Node3D.new()
		root.name = "Armor_%s_%s" % [piece_id, bone_name]
		root.add_child(_cylinder("TaperedGreave", 0.078, 0.11, 0.37, material))
		_attach_local(root, bone_name, Transform3D(Basis.IDENTITY, Vector3(0.0, 0.22, 0.0)))
	_signatures["pernas"] = "%s:paired_tapered_greaves" % piece_id


func _build_boots(piece_id: String, material: Material) -> void:
	for side: Array in [["calf_l", "foot_l"], ["calf_r", "foot_r"]]:
		var calf_root := Node3D.new()
		calf_root.name = "Armor_%s_%s" % [piece_id, String(side[0])]
		calf_root.add_child(_cylinder("CurvedBootLeg", 0.082, 0.105, 0.31, material))
		_attach_local(calf_root, String(side[0]),
			Transform3D(Basis.IDENTITY, Vector3(0.0, 0.33, 0.0)))
		var foot_root := Node3D.new()
		foot_root.name = "Armor_%s_%s" % [piece_id, String(side[1])]
		var toe := _sphere("RoundedBootToe", Vector3(0.075, 0.13, 0.055), material)
		foot_root.add_child(toe)
		_attach_local(foot_root, String(side[1]),
			Transform3D(Basis.IDENTITY, Vector3(0.0, 0.075, 0.0)))
	_signatures["pes"] = "%s:paired_tapered_boots" % piece_id


func _build_cape(piece_id: String, material: Material) -> void:
	var root := Node3D.new()
	root.name = "Armor_%s" % piece_id
	root.add_child(_mesh_instance("CurvedDrape", _armor_cape_mesh(material)))
	_attach(root, "spine_03", Vector3(0.0, 1.32, -0.17))
	_signatures["capa"] = "%s:curved_drape" % piece_id


func _attach(piece: Node3D, bone_name: String, model_position: Vector3) -> void:
	_attach_transform(piece, bone_name, Transform3D(Basis.IDENTITY, model_position))


func _attach_local(piece: Node3D, bone_name: String, local_transform: Transform3D) -> void:
	var bone_index := _skeleton.find_bone(StringName(bone_name))
	if bone_index < 0:
		piece.free()
		push_warning("[armor-visual] osso ausente: %s" % bone_name)
		return
	var skeleton_to_body := Transform3D.IDENTITY
	var cursor := _skeleton as Node3D
	while cursor != _body:
		skeleton_to_body = cursor.transform * skeleton_to_body
		cursor = cursor.get_parent() as Node3D
		if cursor == null:
			piece.free()
			push_warning("[armor-visual] esqueleto fora do corpo")
			return
	var model_transform := skeleton_to_body * _skeleton.get_bone_global_pose(bone_index) * local_transform
	_attach_transform(piece, bone_name, model_transform)


func _attach_transform(piece: Node3D, bone_name: String, model_transform: Transform3D) -> void:
	var attachment := attach_equipment_to_bone(piece, StringName(bone_name),
		model_transform, false, _armor_casts_shadow)
	if attachment == null:
		piece.free()
		push_warning("[armor-visual] osso ausente: %s" % bone_name)
		return
	_armor_attachments.append(attachment)


static func _mesh_instance(node_name: String, mesh: Mesh) -> MeshInstance3D:
	var instance := MeshInstance3D.new()
	instance.name = node_name
	instance.mesh = mesh
	instance.add_to_group("armor_visual_piece")
	return instance


static func _cylinder(node_name: String, top_radius: float, bottom_radius: float,
		height: float, material: Material) -> MeshInstance3D:
	var mesh := CylinderMesh.new()
	mesh.top_radius = top_radius
	mesh.bottom_radius = bottom_radius
	mesh.height = height
	mesh.radial_segments = 12
	mesh.rings = 2
	mesh.material = material
	return _mesh_instance(node_name, mesh)


static func _sphere(node_name: String, dimensions: Vector3,
		material: Material) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = 0.5
	mesh.height = 1.0
	mesh.radial_segments = 12
	mesh.rings = 6
	mesh.material = material
	var instance := _mesh_instance(node_name, mesh)
	instance.scale = dimensions * 2.0
	return instance


static func _capsule(node_name: String, radius: float, height: float,
		material: Material) -> MeshInstance3D:
	var mesh := CapsuleMesh.new()
	mesh.radius = radius
	mesh.height = height
	mesh.radial_segments = 12
	mesh.rings = 4
	mesh.material = material
	return _mesh_instance(node_name, mesh)


static func _torso_shell_mesh(material: Material, heavy: bool) -> ArrayMesh:
	var width_scale := 1.08 if heavy else 1.0
	var depth_scale := 1.08 if heavy else 1.0
	var rings := [
		{"y": -0.27, "x": 0.205 * width_scale, "z": 0.13 * depth_scale},
		{"y": -0.09, "x": 0.245 * width_scale, "z": 0.155 * depth_scale},
		{"y": 0.11, "x": 0.27 * width_scale, "z": 0.17 * depth_scale},
		{"y": 0.23, "x": 0.245 * width_scale, "z": 0.155 * depth_scale},
		{"y": 0.29, "x": 0.19 * width_scale, "z": 0.13 * depth_scale},
	]
	return _elliptical_shell(rings, 16, material)


static func _breast_plate_mesh(material: Material) -> ArrayMesh:
	var rings := [
		{"y": -0.16, "x": 0.205, "z": 0.035},
		{"y": 0.0, "x": 0.245, "z": 0.055},
		{"y": 0.17, "x": 0.19, "z": 0.035},
	]
	return _elliptical_arc(rings, 10, material)


static func _elliptical_shell(rings: Array, segments: int, material: Material) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	for ring_index: int in rings.size() - 1:
		var lower: Dictionary = rings[ring_index]
		var upper: Dictionary = rings[ring_index + 1]
		for step: int in segments:
			var angle_a := TAU * float(step) / float(segments)
			var angle_b := TAU * float(step + 1) / float(segments)
			var a := _ellipse_point(lower, angle_a)
			var b := _ellipse_point(lower, angle_b)
			var c := _ellipse_point(upper, angle_a)
			var d := _ellipse_point(upper, angle_b)
			# A frente do boneco é -Z. Esta ordem mantém as normais para fora;
			# normais invertidas tornavam ferro e couro em silhuetas quase pretas.
			_add_triangle(surface, a, c, b)
			_add_triangle(surface, c, d, b)
	surface.set_material(material)
	return surface.commit()


static func _elliptical_arc(rings: Array, segments: int, material: Material) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	# No espaço do modelo Quaternius, +Z é a frente apresentada ao jogador.
	var start := deg_to_rad(25.0)
	var finish := deg_to_rad(155.0)
	for ring_index: int in rings.size() - 1:
		var lower: Dictionary = rings[ring_index]
		var upper: Dictionary = rings[ring_index + 1]
		for step: int in segments:
			var angle_a := lerpf(start, finish, float(step) / float(segments))
			var angle_b := lerpf(start, finish, float(step + 1) / float(segments))
			var a := _ellipse_point(lower, angle_a)
			var b := _ellipse_point(lower, angle_b)
			var c := _ellipse_point(upper, angle_a)
			var d := _ellipse_point(upper, angle_b)
			_add_triangle(surface, a, c, b)
			_add_triangle(surface, c, d, b)
	surface.set_material(material)
	return surface.commit()


static func _ellipse_point(ring: Dictionary, angle: float) -> Vector3:
	return Vector3(cos(angle) * float(ring["x"]), float(ring["y"]),
		sin(angle) * float(ring["z"]))


static func _armor_cape_mesh(material: Material) -> ArrayMesh:
	var surface := SurfaceTool.new()
	surface.begin(Mesh.PRIMITIVE_TRIANGLES)
	var columns := 8
	var rows := 6
	for row: int in rows:
		var y0 := -0.92 * float(row) / float(rows)
		var y1 := -0.92 * float(row + 1) / float(rows)
		var width0 := lerpf(0.31, 0.43, float(row) / float(rows))
		var width1 := lerpf(0.31, 0.43, float(row + 1) / float(rows))
		for column: int in columns:
			var u0 := lerpf(-1.0, 1.0, float(column) / float(columns))
			var u1 := lerpf(-1.0, 1.0, float(column + 1) / float(columns))
			var a := Vector3(u0 * width0, y0, 0.025 + 0.035 * u0 * u0)
			var b := Vector3(u1 * width0, y0, 0.025 + 0.035 * u1 * u1)
			var c := Vector3(u0 * width1, y1, 0.035 + 0.05 * u0 * u0)
			var d := Vector3(u1 * width1, y1, 0.035 + 0.05 * u1 * u1)
			_add_triangle(surface, a, b, c)
			_add_triangle(surface, c, b, d)
	surface.set_material(material)
	return surface.commit()


static func _add_triangle(surface: SurfaceTool, a: Vector3, b: Vector3, c: Vector3) -> void:
	var normal := (b - a).cross(c - a).normalized()
	for vertex: Vector3 in [a, b, c]:
		surface.set_normal(normal)
		surface.add_vertex(vertex)


static func _piece_data(piece_id: String) -> Dictionary:
	var data := GameData.equipment_armor(piece_id)
	if data.is_empty():
		data = (GameData.armor.get("pieces", {}) as Dictionary).get(piece_id, {}) as Dictionary
	return data


static func _material_for(piece_id: String, data: Dictionary) -> StandardMaterial3D:
	var material_text := String(data.get("material", "")).to_lower()
	var profile := "leather"
	if "ferro" in material_text:
		profile = "polished_iron" if "polido" in material_text else "rough_iron"
	elif "pano" in material_text:
		profile = "dark_cloth"
	elif "la" in material_text or "lã" in material_text:
		profile = "light_cloth" if "clara" in piece_id else "waxed_wool"
	elif "pelo" in material_text:
		profile = "fur_leather"
	return _source_material(profile)


static func _accent_material(profile: String) -> StandardMaterial3D:
	return _source_material(profile)


static func _source_material(profile: String) -> StandardMaterial3D:
	if _material_cache.has(profile):
		return _material_cache[profile] as StandardMaterial3D
	var colors := {
		"leather": Color("4a3022"), "fur_leather": Color("5a4936"),
		"dark_leather": Color("281a13"),
		"rough_iron": Color("65686a"), "polished_iron": Color("aab1b2"),
		"dark_cloth": Color("24282a"), "waxed_wool": Color("30383b"),
		"light_cloth": Color("aaa48f"), "iron_visor": Color("16191a"),
		"fur": Color("625b50"),
	}
	var material := StandardMaterial3D.new()
	material.albedo_color = colors.get(profile, Color("4a3022")) as Color
	material.roughness = 0.28 if profile == "polished_iron" else 0.66 \
		if profile == "rough_iron" else 0.9
	# Sem um cubemap de reflexão, metal a 0.9 lia-se como carvão no renderer
	# Mobile. Estes valores conservam o brilho sem apagar a geometria.
	material.metallic = 0.45 if profile == "polished_iron" else 0.20 \
		if profile == "rough_iron" else 0.0
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_material_cache[profile] = material
	return material
