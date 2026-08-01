class_name WeaponVisual
extends Node3D
## Armas CC0 visiveis, presas ao loadout real do actor.
##
## Este no nao inventa equipamento: observa `main_weapon`, `offhand_weapon` e
## `is_two_handed` no actor. A troca de kit actualiza os modelos no mesmo frame.
## Os props sao do KayKit Character Pack: Skeletons (CC0), ja curados em
## `game/assets/models/`; nenhuma geometria ou textura vem de um jogo comercial.

const WEAPON_SCENES := {
	"longsword": "res://assets/models/enemies/kaykit-skeletons/props/Skeleton_Blade.gltf",
	"dagger": "res://assets/models/enemies/kaykit-skeletons/props/Skeleton_Blade.gltf",
	"greataxe": "res://assets/models/enemies/kaykit-skeletons/props/Skeleton_Axe.gltf",
	"staff": "res://assets/models/enemies/kaykit-skeletons/props/Skeleton_Staff.gltf",
	"shield": "res://assets/models/enemies/kaykit-skeletons/props/Skeleton_Shield_Small_A.gltf",
}

const RIGHT_HAND_CANDIDATES := [
	"handslot.r", "HandSlot.R", "hand.R", "Hand.R", "hand_r", "RightHand",
	"mixamorig:RightHand",
]
const LEFT_HAND_CANDIDATES := [
	"handslot.l", "HandSlot.L", "hand.L", "Hand.L", "hand_l", "LeftHand",
	"mixamorig:LeftHand",
]

var _actor: Node
var _character_visual: Node3D
var _skeleton: Skeleton3D
var _main_attachment: BoneAttachment3D
var _offhand_attachment: BoneAttachment3D
var _main_model: Node3D
var _offhand_model: Node3D
var _main_tip: Marker3D
var _main_weapon_id := ""
var _offhand_weapon_id := ""
var _two_handed := false


func setup(actor: Node, character_visual: Node3D) -> bool:
	name = "WeaponVisual"
	_actor = actor
	_character_visual = character_visual
	_skeleton = _find_skeleton(character_visual)
	if _skeleton == null:
		push_error("[weapon-visual] o corpo nao tem Skeleton3D")
		return false

	_main_attachment = _make_attachment("MainHandWeapon", true)
	_offhand_attachment = _make_attachment("OffhandWeapon", false)
	if _main_attachment == null or _offhand_attachment == null:
		_cleanup_attachments()
		return false

	# O ClassProp historico e um escudo decorativo exclusivo do paladino. O
	# loadout passa a ser a autoridade, por isso o substituto real o esconde.
	var decorative_prop := character_visual.find_child("ClassProp", true, false) as Node3D
	if decorative_prop != null:
		decorative_prop.visible = false

	sync_from_actor()
	return true


func _process(_delta: float) -> void:
	if is_instance_valid(_actor):
		sync_from_actor()


func sync_from_actor() -> void:
	if not is_instance_valid(_actor):
		return
	sync_loadout(
		String(_read_property(_actor, "main_weapon", "")),
		String(_read_property(_actor, "offhand_weapon", "")),
		bool(_read_property(_actor, "is_two_handed", false)))


func sync_loadout(main_weapon: String, offhand_weapon: String, two_handed: bool) -> void:
	if main_weapon != _main_weapon_id:
		_main_weapon_id = main_weapon
		_main_model = _replace_model(_main_attachment, _main_model, main_weapon, true)
		_main_tip = _make_tip_marker(_main_model)
	if offhand_weapon != _offhand_weapon_id:
		_offhand_weapon_id = offhand_weapon
		_offhand_model = _replace_model(_offhand_attachment, _offhand_model, offhand_weapon, false)
	_two_handed = two_handed
	if is_instance_valid(_offhand_model):
		_offhand_model.visible = not two_handed


func main_weapon_tip_position() -> Vector3:
	if is_instance_valid(_main_tip):
		return _main_tip.global_position
	if is_instance_valid(_main_attachment):
		return _main_attachment.global_position
	return global_position


func has_visible_weapon(weapon_id: String) -> bool:
	if weapon_id == _main_weapon_id:
		return is_instance_valid(_main_model) and _main_model.visible
	if weapon_id == _offhand_weapon_id:
		return is_instance_valid(_offhand_model) and _offhand_model.visible
	return false


func attachment_bones() -> Dictionary:
	return {
		"main": _main_attachment.bone_name if is_instance_valid(_main_attachment) else "",
		"offhand": _offhand_attachment.bone_name if is_instance_valid(_offhand_attachment) else "",
	}


func visible_mesh_count() -> int:
	var count := 0
	for root: Node3D in [_main_model, _offhand_model]:
		if not is_instance_valid(root) or not root.visible:
			continue
		count += root.find_children("*", "MeshInstance3D", true, false).size()
	return count


func _make_attachment(node_name: String, right_hand: bool) -> BoneAttachment3D:
	var bone_name := _find_hand_bone(_skeleton, right_hand)
	if bone_name.is_empty():
		push_error("[weapon-visual] rig sem mao %s: %s" % [
			"direita" if right_hand else "esquerda", _skeleton.name])
		return null
	var attachment := BoneAttachment3D.new()
	attachment.name = node_name
	attachment.bone_name = bone_name
	_skeleton.add_child(attachment)
	return attachment


func _replace_model(attachment: BoneAttachment3D, previous: Node3D,
		weapon_id: String, is_main: bool) -> Node3D:
	if is_instance_valid(previous):
		previous.free()
	if attachment == null or weapon_id.is_empty():
		return null
	var scene_path := String(WEAPON_SCENES.get(weapon_id, ""))
	if scene_path.is_empty():
		push_warning("[weapon-visual] arma executavel sem modelo: %s" % weapon_id)
		return null
	var packed := load(scene_path) as PackedScene
	if packed == null:
		push_error("[weapon-visual] modelo nao importavel: %s" % scene_path)
		return null
	var model := packed.instantiate() as Node3D
	if model == null:
		push_error("[weapon-visual] raiz 3D invalida: %s" % scene_path)
		return null
	model.name = "Main_%s" % weapon_id if is_main else "Offhand_%s" % weapon_id
	attachment.add_child(model)
	model.scale = Vector3.ONE * _scale_for_weapon(weapon_id)
	_disable_prop_shadows(model)
	return model


func _scale_for_weapon(weapon_id: String) -> float:
	# O pack traz uma unica lamina. A adaga conserva o mesmo asset/coerencia mas
	# usa a proporcao entre os alcances ja declarados no catalogo, nunca um
	# comprimento de combate duplicado neste script.
	if weapon_id != "dagger":
		return 1.0
	var game_data := get_node_or_null("/root/GameData")
	if game_data == null or not game_data.has_method("weapon"):
		return 1.0
	var dagger_range := float((game_data.call("weapon", "dagger") as Dictionary).get("range", 0.0))
	var sword_range := float((game_data.call("weapon", "longsword") as Dictionary).get("range", 0.0))
	return dagger_range / sword_range if dagger_range > 0.0 and sword_range > 0.0 else 1.0


func _make_tip_marker(model: Node3D) -> Marker3D:
	if not is_instance_valid(model):
		return null
	var marker := Marker3D.new()
	marker.name = "WeaponTip"
	model.add_child(marker)
	var farthest := Vector3.ZERO
	var farthest_squared := 0.0
	for descendant: Node in model.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := descendant as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		var box := mesh_instance.mesh.get_aabb()
		var to_model := model.global_transform.affine_inverse() * mesh_instance.global_transform
		for corner in _aabb_corners(box):
			var point := to_model * corner
			if point.length_squared() > farthest_squared:
				farthest = point
				farthest_squared = point.length_squared()
	marker.position = farthest
	return marker


static func _aabb_corners(box: AABB) -> Array[Vector3]:
	var corners: Array[Vector3] = []
	for x in [box.position.x, box.end.x]:
		for y in [box.position.y, box.end.y]:
			for z in [box.position.z, box.end.z]:
				corners.append(Vector3(x, y, z))
	return corners


static func _disable_prop_shadows(root: Node3D) -> void:
	# Duas armas pequenas nao justificam outro passe de sombras na Iris Xe. A
	# leitura vem da silhueta e do material original do pack.
	for descendant: Node in root.find_children("*", "MeshInstance3D", true, false):
		(descendant as MeshInstance3D).cast_shadow = \
			GeometryInstance3D.SHADOW_CASTING_SETTING_OFF


static func _find_hand_bone(skeleton: Skeleton3D, right_hand: bool) -> String:
	var candidates := RIGHT_HAND_CANDIDATES if right_hand else LEFT_HAND_CANDIDATES
	for candidate: String in candidates:
		if skeleton.find_bone(candidate) >= 0:
			return candidate
	var wanted_side := "right" if right_hand else "left"
	var wanted_letter := "r" if right_hand else "l"
	for bone_index in skeleton.get_bone_count():
		var bone_name := skeleton.get_bone_name(bone_index)
		var normal := String(bone_name).to_lower().replace(".", "").replace("_", "").replace(":", "")
		if "handslot" in normal and (wanted_side in normal or normal.ends_with(wanted_letter)):
			return bone_name
	for bone_index in skeleton.get_bone_count():
		var bone_name := skeleton.get_bone_name(bone_index)
		var normal := String(bone_name).to_lower().replace(".", "").replace("_", "").replace(":", "")
		if "hand" in normal and (wanted_side in normal or normal.ends_with(wanted_letter)):
			return bone_name
	return ""


static func _find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node as Skeleton3D
	for child: Node in node.get_children():
		var found := _find_skeleton(child)
		if found != null:
			return found
	return null


static func _read_property(object: Object, property_name: StringName,
		fallback: Variant) -> Variant:
	for property: Dictionary in object.get_property_list():
		if StringName(property.get("name", "")) == property_name:
			return object.get(property_name)
	return fallback


func _cleanup_attachments() -> void:
	for attachment: BoneAttachment3D in [_main_attachment, _offhand_attachment]:
		if is_instance_valid(attachment):
			attachment.queue_free()
	_main_attachment = null
	_offhand_attachment = null


func _exit_tree() -> void:
	_cleanup_attachments()
