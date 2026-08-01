class_name WeaponAttach
extends Node3D
## Equipamento visivel preso ao esqueleto real do personagem.
##
## O actor continua a ser a autoridade sobre o loadout. Este componente apenas
## traduz os IDs/familias declarados nos JSON para props CC0 ja importados e
## troca a instancia no proprio frame em que o loadout muda.

const MODEL_SCENES := {
	"blade": "res://assets/models/enemies/kaykit-skeletons/props/Skeleton_Blade.gltf",
	"axe": "res://assets/models/enemies/kaykit-skeletons/props/Skeleton_Axe.gltf",
	"staff": "res://assets/models/enemies/kaykit-skeletons/props/Skeleton_Staff.gltf",
	"crossbow": "res://assets/models/enemies/kaykit-skeletons/props/Skeleton_Crossbow.gltf",
	"shield": "res://assets/models/enemies/kaykit-skeletons/props/Skeleton_Shield_Small_A.gltf",
}

const FAMILY_MODELS := {
	"espada_recta": "blade",
	"adaga": "blade",
	"pesada_corte": "axe",
	"katana": "blade",
	"haste": "staff",
	"cajado": "staff",
	"besta": "crossbow",
}

const EXACT_MODELS := {
	"shield": "shield",
	"longsword": "blade",
	"dagger": "blade",
	"greataxe": "axe",
	"staff": "staff",
}

# Conversao visual entre os props do pack Skeletons e o corpo Adventurers. Foi
# calibrada na captura 1080p: a escala nativa fazia o escudo cobrir o tronco e
# a lamina ultrapassar a altura do personagem. Nao altera alcance nem hitbox.
const PACK_TO_CHARACTER_SCALE := 0.6

const RIGHT_HAND_CANDIDATES := [
	"handslot.r", "HandSlot.R", "hand.R", "Hand.R", "hand_r", "RightHand",
	"mixamorig:RightHand",
]
const LEFT_HAND_CANDIDATES := [
	"handslot.l", "HandSlot.L", "hand.L", "Hand.L", "hand_l", "LeftHand",
	"mixamorig:LeftHand",
]

var _actor: Node
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
	name = "WeaponAttach"
	_actor = actor
	_skeleton = character_visual.call("get_equipment_skeleton") as Skeleton3D \
		if character_visual.has_method("get_equipment_skeleton") else _find_skeleton(character_visual)
	if _skeleton == null:
		push_error("[weapon-attach] o corpo nao tem Skeleton3D")
		return false

	_main_attachment = _make_attachment("MainHandWeapon", true)
	_offhand_attachment = _make_attachment("OffhandWeapon", false)
	if _main_attachment == null or _offhand_attachment == null:
		_cleanup_attachments()
		return false

	# O prop de classe antigo nao representa o loadout. Esconde-lo impede um
	# escudo fantasma quando o jogador muda de equipamento.
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


func model_source_for(weapon_id: String) -> String:
	var model_key := String(EXACT_MODELS.get(weapon_id, ""))
	if model_key.is_empty():
		model_key = String(FAMILY_MODELS.get(_family_for(weapon_id), ""))
	return String(MODEL_SCENES.get(model_key, ""))


func has_visible_weapon(weapon_id: String, main_hand := true) -> bool:
	if main_hand:
		return weapon_id == _main_weapon_id \
			and is_instance_valid(_main_model) and _main_model.visible
	return weapon_id == _offhand_weapon_id \
		and is_instance_valid(_offhand_model) and _offhand_model.visible


func attachment_bones() -> Dictionary:
	return {
		"main": _main_attachment.bone_name if is_instance_valid(_main_attachment) else "",
		"offhand": _offhand_attachment.bone_name if is_instance_valid(_offhand_attachment) else "",
	}


func visible_mesh_count() -> int:
	var count := 0
	for model: Node3D in [_main_model, _offhand_model]:
		if not is_instance_valid(model) or not model.visible:
			continue
		count += model.find_children("*", "MeshInstance3D", true, false).size()
	return count


func main_model_instance_id() -> int:
	return _main_model.get_instance_id() if is_instance_valid(_main_model) else 0


func main_weapon_tip_position() -> Vector3:
	if is_instance_valid(_main_tip):
		return _main_tip.global_position
	if is_instance_valid(_main_attachment):
		return _main_attachment.global_position
	return global_position


func _make_attachment(node_name: String, right_hand: bool) -> BoneAttachment3D:
	var bone_name := _find_hand_bone(_skeleton, right_hand)
	if bone_name.is_empty():
		push_error("[weapon-attach] rig sem mao %s: %s" % [
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
	var scene_path := model_source_for(weapon_id)
	if scene_path.is_empty():
		push_warning("[weapon-attach] arma sem prop importado: %s" % weapon_id)
		return null
	var packed := load(scene_path) as PackedScene
	if packed == null:
		push_error("[weapon-attach] modelo nao importavel: %s" % scene_path)
		return null
	var model := packed.instantiate() as Node3D
	if model == null:
		push_error("[weapon-attach] raiz 3D invalida: %s" % scene_path)
		return null
	model.name = ("Main_%s" if is_main else "Offhand_%s") % weapon_id
	attachment.add_child(model)
	model.scale = Vector3.ONE * PACK_TO_CHARACTER_SCALE * _scale_for_weapon(weapon_id)
	_disable_prop_shadows(model)
	return model


func _family_for(weapon_id: String) -> String:
	var game_data := get_node_or_null("/root/GameData")
	if game_data == null:
		return ""
	var weapon: Dictionary = game_data.call("weapon", weapon_id) as Dictionary \
		if game_data.has_method("weapon") else {}
	if weapon.is_empty() and game_data.has_method("equipment_weapon"):
		weapon = game_data.call("equipment_weapon", weapon_id) as Dictionary
	return String(weapon.get("familia", ""))


func _scale_for_weapon(weapon_id: String) -> float:
	# A unica lamina CC0 serve tambem a adaga. A proporcao visual vem dos
	# alcances do catalogo, sem duplicar qualquer numero de combate em GDScript.
	if _family_for(weapon_id) != "adaga":
		return 1.0
	var game_data := get_node_or_null("/root/GameData")
	if game_data == null or not game_data.has_method("weapon"):
		return 1.0
	var dagger_range := float((game_data.call("weapon", weapon_id) as Dictionary).get("range", 0.0))
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


static func _disable_prop_shadows(model: Node3D) -> void:
	# Evita um passe de sombra adicional por arma na GPU alvo. A leitura da
	# silhueta conserva-se com o material original e a sombra do corpo.
	for descendant: Node in model.find_children("*", "MeshInstance3D", true, false):
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
