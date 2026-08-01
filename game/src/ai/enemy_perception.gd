extends RefCounted
## Geometria e maquina de percepcao deterministas. O chamador fornece apenas
## factos observaveis (LOS, som, dano); todos os limiares vêm de enemies.json.

const PATROL := "patrol"
const ALERT := "alert"
const CALLING := "calling"
const COMBAT := "combat"
const RETURNING := "returning"
const HEALING := "healing"

var _state := PATROL
var _state_elapsed_s := 0.0
var _time_without_sight_s := 0.0
var _home_position := Vector3.ZERO
var _stimulus_position := Vector3.ZERO


func reset(home_position: Vector3) -> void:
	_state = PATROL
	_state_elapsed_s = 0.0
	_time_without_sight_s = 0.0
	_home_position = home_position
	_stimulus_position = home_position


func tick(delta: float, context: Dictionary, config: Dictionary) -> Dictionary:
	_state_elapsed_s += maxf(delta, 0.0)
	var emit_call := false
	var heal_fraction := 0.0
	var reacquired := false
	match _state:
		PATROL:
			if _senses_target(context, config):
				_stimulus_position = context.get("target_position", _home_position) as Vector3
				_transition(ALERT)
		ALERT:
			if _state_elapsed_s >= float(config.get("alert_delay_s", INF)):
				_transition(CALLING)
		CALLING:
			if _state_elapsed_s >= float(config.get("call_delay_s", INF)):
				_transition(COMBAT)
				emit_call = true
		COMBAT:
			if _target_visible(context, config):
				_time_without_sight_s = 0.0
			else:
				_time_without_sight_s += maxf(delta, 0.0)
			var too_far_from_home := _distance_from_home(context) >= float(
				config.get("desist_home_distance_m", INF))
			var lost_for_too_long := _time_without_sight_s >= float(
				config.get("desist_after_s", INF))
			if too_far_from_home or lost_for_too_long:
				_transition(RETURNING)
		RETURNING, HEALING:
			if bool(context.get("damaged", false)) and bool(config.get("damage_reacquires", false)):
				_time_without_sight_s = 0.0
				_transition(COMBAT)
				reacquired = true
			elif _state == RETURNING:
				var home_distance := _distance_from_home(context)
				var arrival_radius := float(config.get("return_arrival_radius_m", 0.0))
				if home_distance <= arrival_radius or is_equal_approx(home_distance, arrival_radius):
					_transition(HEALING)
			elif _state == HEALING and _state_elapsed_s >= float(
				config.get("return_heal_pulse_s", INF)):
				heal_fraction = float(config.get("return_heal_fraction", 0.0))
				_transition(PATROL)
	return _decision(config, emit_call, heal_fraction, reacquired)


func state() -> String:
	return _state


func _senses_target(context: Dictionary, config: Dictionary) -> bool:
	var seen := _target_visible(context, config)
	if seen:
		return true
	if not context.has("sound_distance_m"):
		return false
	return can_hear(float(context.get("sound_distance_m")),
		bool(context.get("sound_is_combat", false)), config)


func _target_visible(context: Dictionary, config: Dictionary) -> bool:
	if not context.has("target_position"):
		return false
	return can_see(
		context.get("observer_position", Vector3.ZERO) as Vector3,
		context.get("observer_forward", Vector3.ZERO) as Vector3,
		context.get("target_position", Vector3.ZERO) as Vector3,
		bool(context.get("has_line_of_sight", false)), config)


func _distance_from_home(context: Dictionary) -> float:
	return (context.get("observer_position", _home_position) as Vector3).distance_to(
		_home_position)


func _transition(next_state: String) -> void:
	_state = next_state
	_state_elapsed_s = 0.0


func _decision(config: Dictionary, emit_call: bool, heal_fraction: float,
		reacquired: bool) -> Dictionary:
	var cues: Dictionary = config.get("readable_cues", {}) as Dictionary
	var decision := {
		"state": _state,
		"readable_cue": String(cues.get("reacquired" if reacquired else _state, "")),
		"perception_open": _state not in [RETURNING, HEALING],
	}
	if heal_fraction > 0.0:
		decision["heal_fraction"] = heal_fraction
	if reacquired:
		decision["reacquired"] = true
	match _state:
		ALERT:
			decision["movement_action"] = "advance_to_stimulus"
			decision["stimulus_position"] = _stimulus_position
			decision["advance_limit_m"] = float(config.get("alert_advance_m", 0.0))
		CALLING:
			decision["movement_action"] = "hold"
			decision["vulnerable"] = true
		COMBAT:
			decision["movement_action"] = "engage"
			decision["emit_call"] = emit_call
			decision["call_radius_m"] = float(config.get("call_radius_m", 0.0))
		RETURNING:
			decision["movement_action"] = "return_home"
			decision["home_position"] = _home_position
			decision["speed_policy"] = String(config.get("return_speed_policy", ""))
		HEALING:
			decision["movement_action"] = "hold"
	return decision


static func can_see(observer_position: Vector3, observer_forward: Vector3,
		target_position: Vector3, has_line_of_sight: bool, config: Dictionary) -> bool:
	if not has_line_of_sight:
		return false
	var offset := target_position - observer_position
	offset.y = 0.0
	var maximum_range := float(config.get("vision_range_m", 0.0))
	if offset.length_squared() > maximum_range * maximum_range:
		return false
	if offset.is_zero_approx():
		return true
	var forward := observer_forward
	forward.y = 0.0
	if forward.is_zero_approx():
		return false
	var half_cone := float(config.get("vision_cone_deg", 0.0)) * 0.5
	return rad_to_deg(forward.normalized().angle_to(offset.normalized())) <= half_cone


static func can_hear(sound_distance_m: float, is_combat_sound: bool,
		config: Dictionary) -> bool:
	if sound_distance_m < 0.0:
		return false
	var range_field := "combat_sound_range_m" if is_combat_sound else "hearing_range_m"
	return sound_distance_m <= float(config.get(range_field, 0.0))


static func call_recipients(origin_position: Vector3, allies: Array,
		config: Dictionary) -> Array:
	var recipients: Array = []
	var call_radius := float(config.get("call_radius_m", 0.0))
	for ally_value: Variant in allies:
		var ally := ally_value as Dictionary
		if not bool(ally.get("can_receive_alert", false)):
			continue
		var distance := origin_position.distance_to(
			ally.get("position", origin_position) as Vector3)
		if distance <= call_radius or is_equal_approx(distance, call_radius):
			recipients.append(ally)
	return recipients
