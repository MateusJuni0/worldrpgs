class_name ImpactEvent
extends RefCounted
## Fotografia imutavel de um contacto autoritativo.
##
## O evento e criado pela mesma chamada que aplica dano. O tempo visual vem dos
## frames activos que ainda restam na hitbox real; nao existe um segundo relogio
## aproximado para o efeito.

var attacker: Node3D
var target: Node3D
var damage_info: DamageInfo
var surface := "flesh"
var contact_point := Vector3.ZERO
var source_position := Vector3.ZERO
var active_frames_remaining := 0
var reaction_frames := 0
var physics_frame := 0

static var _combat_data: Dictionary = {}


static func capture(p_attacker: Node3D, p_target: Node3D, p_damage_info: DamageInfo,
		p_surface := "flesh", active_frames_override := -1) -> ImpactEvent:
	var event := ImpactEvent.new()
	event.attacker = p_attacker
	event.target = p_target
	event.damage_info = p_damage_info
	event.surface = _normalise_surface(p_surface)
	event.physics_frame = Engine.get_physics_frames()
	event.source_position = _source_position(p_attacker)
	event.contact_point = _contact_point(p_attacker, p_target, event.source_position)
	event.active_frames_remaining = active_frames_override if active_frames_override >= 0 \
		else active_frames_for(p_attacker)
	event.reaction_frames = _reaction_frames(p_target, p_damage_info,
		event.active_frames_remaining)
	return event


static func active_frames_for(actor: Node) -> int:
	if not is_instance_valid(actor):
		return 0
	# Player: estado medido desde o inicio do ataque.
	if _has_property(actor, "state_frame") and _has_property(actor, "_atk_startup") \
			and _has_property(actor, "_atk_active"):
		var frame := int(actor.get("state_frame"))
		var startup := int(actor.get("_atk_startup"))
		var charge := int(actor.get("_charge_frames")) if _has_property(actor, "_charge_frames") else 0
		var active := int(actor.get("_atk_active"))
		return maxi(startup + charge + active - frame + 1, 0)
	# Enemy: relogio proprio da ficha de ataque.
	if _has_property(actor, "_atk_frame") and _has_property(actor, "_atk"):
		var attack := actor.get("_atk") as Dictionary
		var frame := int(actor.get("_atk_frame"))
		var finish := int(attack.get("startup", 0)) + int(attack.get("active", 0))
		return maxi(finish - frame + 1, 0)
	return 0


static func _reaction_frames(p_target: Node, info: DamageInfo,
		active_frames: int) -> int:
	if is_instance_valid(p_target) and _has_property(p_target, "_hitstun_frames"):
		var current_hitstun := int(p_target.get("_hitstun_frames"))
		if current_hitstun > 0:
			return current_hitstun
	if info != null:
		var combat := _combat_catalogue()
		var reference_fps := float(combat.get("reference_fps", 0.0))
		var seconds := info.hitstun_seconds(combat.get("hitstun", {}) as Dictionary)
		if reference_fps > 0.0 and seconds > 0.0:
			return ceili(seconds * reference_fps)
	return active_frames


static func _source_position(p_attacker: Node3D) -> Vector3:
	if not is_instance_valid(p_attacker):
		return Vector3.ZERO
	var weapon_visual := p_attacker.find_child("WeaponVisual", true, false)
	if weapon_visual != null and weapon_visual.has_method("main_weapon_tip_position"):
		return weapon_visual.call("main_weapon_tip_position") as Vector3
	var collision := _find_collision(p_attacker)
	return collision.global_position if collision != null else p_attacker.global_position


static func _contact_point(p_attacker: Node3D, p_target: Node3D,
		source: Vector3) -> Vector3:
	if not is_instance_valid(p_target):
		return source
	var collision := _find_collision(p_target)
	var centre := collision.global_position if collision != null else p_target.global_position
	var radius := 0.0
	var half_height := 0.0
	if collision != null and collision.shape is CapsuleShape3D:
		var capsule := collision.shape as CapsuleShape3D
		radius = capsule.radius
		half_height = capsule.height * 0.5
	elif _has_property(p_target, "body_radius"):
		radius = float(p_target.get("body_radius"))
	var towards_source := source - centre
	var horizontal := Vector3(towards_source.x, 0.0, towards_source.z)
	if horizontal.length_squared() > 0.0:
		centre += horizontal.normalized() * radius
	if half_height > 0.0:
		centre.y = clampf(source.y, collision.global_position.y - half_height,
			collision.global_position.y + half_height)
	return centre


static func _find_collision(node: Node) -> CollisionShape3D:
	if node is CollisionShape3D:
		return node as CollisionShape3D
	for child: Node in node.get_children():
		var found := _find_collision(child)
		if found != null:
			return found
	return null


static func _normalise_surface(value: String) -> String:
	var normal := value.to_lower()
	return normal if normal in ["flesh", "metal", "wood", "stone"] else "flesh"


static func _combat_catalogue() -> Dictionary:
	if not _combat_data.is_empty():
		return _combat_data
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(
		"res://data/combat.json"))
	if parsed is Dictionary:
		_combat_data = parsed as Dictionary
	return _combat_data


static func _has_property(object: Object, property_name: StringName) -> bool:
	for property: Dictionary in object.get_property_list():
		if StringName(property.get("name", "")) == property_name:
			return true
	return false
