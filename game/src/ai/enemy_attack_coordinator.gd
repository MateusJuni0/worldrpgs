extends RefCounted
## Guarda de honestidade para ataques em grupo (spec/38 §3). Se outro inimigo
## já entrou no golpe neste frame, ou o jogador ainda está no hit-stun do golpe
## anterior + intervalo declarado, o segundo ataque cancela antes da hitbox.

static var _last_active_frame: Dictionary = {}
static var _blocked_until_frame: Dictionary = {}
static var _target_actionable: Dictionary = {}
static var _attack_intents: Dictionary = {}
static var _intent_positions: Dictionary = {}


static func can_enter_active(target: Node, attacker: Node, active_frames: int) -> bool:
	if not is_instance_valid(target) or not is_instance_valid(attacker):
		return false
	var target_key := int(target.get_instance_id())
	var frame := int(Engine.get_physics_frames())
	if not bool(_target_actionable.get(target_key, true)):
		return false
	if frame <= int(_blocked_until_frame.get(target_key, -1)):
		return false
	if int(_last_active_frame.get(target_key, -1)) == frame:
		return false
	_last_active_frame[target_key] = frame
	_blocked_until_frame[target_key] = frame + maxi(active_frames, 1) - 1
	release_attack_intent(target, attacker)
	return true


## Recebe a capacidade real do jogador, não uma aproximação pelo relógio. A
## transição para `true` é o instante zero do intervalo pós-acção da spec/38.
static func update_target_actionability(target: Node, can_act: bool,
		config: Dictionary, reference_fps: float) -> void:
	if not is_instance_valid(target):
		return
	var key := int(target.get_instance_id())
	var was_actionable := bool(_target_actionable.get(key, true))
	_target_actionable[key] = can_act
	if can_act and not was_actionable:
		var gap_frames := ceili(float(config.get("post_action_gap_s", 0.0)) * reference_fps)
		var last_blocked_frame := int(Engine.get_physics_frames()) + maxi(gap_frames, 0) - 1
		_blocked_until_frame[key] = maxi(
			int(_blocked_until_frame.get(key, -1)), last_blocked_frame)


static func record_hitstun(target: Node, hitstun_frames: int,
		config: Dictionary, reference_fps: float) -> void:
	if not is_instance_valid(target):
		return
	var gap_frames := ceili(float(config.get("post_action_gap_s", 0.0)) * reference_fps)
	var can_act_frame := int(Engine.get_physics_frames()) + maxi(hitstun_frames, 0)
	var last_blocked_frame := can_act_frame + maxi(gap_frames, 0) - 1
	var key := int(target.get_instance_id())
	_blocked_until_frame[key] = maxi(
		int(_blocked_until_frame.get(key, -1)), last_blocked_frame)


static func request_attack_intent(target: Node, attacker: Node,
		target_position: Vector3, attacker_position: Vector3,
		config: Dictionary, pressure_positions: Array = []) -> bool:
	if not is_instance_valid(target) or not is_instance_valid(attacker):
		return false
	var target_key := int(target.get_instance_id())
	_prune_intents(target_key)
	var attacker_key := int(attacker.get_instance_id())
	var intents: Dictionary = _attack_intents.get(target_key, {}) as Dictionary
	var positions: Dictionary = _intent_positions.get(target_key, {}) as Dictionary
	if intents.has(attacker_key):
		positions[attacker_key] = attacker_position
		_intent_positions[target_key] = positions
		return true
	var maximum := int(config.get("maximum_attack_intents", 0))
	if maximum <= 0 or intents.size() >= maximum:
		return false
	var proposed_positions: Array = positions.values()
	proposed_positions.append(attacker_position)
	var route_positions := proposed_positions
	if not pressure_positions.is_empty():
		route_positions = pressure_positions
	if not has_escape_route(target_position, route_positions, config):
		return false
	intents[attacker_key] = weakref(attacker)
	positions[attacker_key] = attacker_position
	_attack_intents[target_key] = intents
	_intent_positions[target_key] = positions
	return true


static func release_attack_intent(target: Node, attacker: Node) -> void:
	if not is_instance_valid(target) or not is_instance_valid(attacker):
		return
	var target_key := int(target.get_instance_id())
	var attacker_key := int(attacker.get_instance_id())
	var intents: Dictionary = _attack_intents.get(target_key, {}) as Dictionary
	var positions: Dictionary = _intent_positions.get(target_key, {}) as Dictionary
	intents.erase(attacker_key)
	positions.erase(attacker_key)
	_attack_intents[target_key] = intents
	_intent_positions[target_key] = positions


static func has_escape_route(target_position: Vector3, threat_positions: Array,
		config: Dictionary) -> bool:
	var angles: Array[float] = []
	for position_value: Variant in threat_positions:
		var direction := (position_value as Vector3) - target_position
		direction.y = 0.0
		if direction.is_zero_approx():
			continue
		angles.append(fposmod(atan2(direction.z, direction.x), TAU))
	if angles.size() <= 1:
		return true
	angles.sort()
	var largest_gap := 0.0
	for index: int in angles.size():
		var next_index := (index + 1) % angles.size()
		var next_angle := angles[next_index] + (TAU if next_index == 0 else 0.0)
		largest_gap = maxf(largest_gap, next_angle - angles[index])
	return rad_to_deg(largest_gap) >= float(config.get("minimum_escape_arc_deg", INF))


static func _prune_intents(target_key: int) -> void:
	var intents: Dictionary = _attack_intents.get(target_key, {}) as Dictionary
	var positions: Dictionary = _intent_positions.get(target_key, {}) as Dictionary
	for attacker_key: Variant in intents.keys():
		var reference := intents[attacker_key] as WeakRef
		if reference.get_ref() == null:
			intents.erase(attacker_key)
			positions.erase(attacker_key)
	_attack_intents[target_key] = intents
	_intent_positions[target_key] = positions


static func forget_target(target: Node) -> void:
	if not is_instance_valid(target):
		return
	var key := int(target.get_instance_id())
	_last_active_frame.erase(key)
	_blocked_until_frame.erase(key)
	_target_actionable.erase(key)
	_attack_intents.erase(key)
	_intent_positions.erase(key)
