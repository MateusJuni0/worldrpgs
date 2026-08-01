extends RefCounted
## Escolhe uma intenção legível entre golpes. Não lê Input nem sorteia por frame:
## distância, estado visível do jogador e vagas do grupo são toda a informação.


static func decide(context: Dictionary, enemy: Dictionary,
		behavior: Dictionary) -> Dictionary:
	var visible_state := _canonical_visible_state(context, behavior)
	var item_state := String(behavior.get("visible_item_state", ""))
	if visible_state == item_state:
		var punish := _matching_item_punish(context, enemy)
		if punish.is_empty():
			return _decision("withdraw", "visible_item_without_declared_punish", behavior)
		var reaction_frames := int((punish.get("rule", {}) as Dictionary).get(
			"reaction_latency_frames", 0))
		if int(context.get("player_state_elapsed_frames", 0)) < reaction_frames:
			return _decision("wait", "visible_item_reaction", behavior)
		var result := _decision("request_attack", "visible_item_punish", behavior)
		result["attack_id"] = String((punish.get("attack", {}) as Dictionary).get("id", ""))
		return result

	var distance := float(context.get("distance_to_target_m", INF))
	var preferred_distance := float(enemy.get("preferred_distance", 0.0))
	var attack_range := float(enemy.get("attack_range", 0.0))
	var in_attack_range := distance <= attack_range
	var slot_available := bool(context.get("attack_slot_available", false))
	var commitment_states: Array = behavior.get("commitment_states", []) as Array
	if slot_available and in_attack_range and visible_state in commitment_states:
		return _decision("request_attack", "visible_commitment", behavior)

	var pattern_gap := float(enemy.get("gap_between_patterns", INF))
	var since_last_attack := float(context.get("seconds_since_last_attack", 0.0))
	if slot_available and in_attack_range and since_last_attack >= pattern_gap:
		return _decision("request_attack", "declared_initiative_gap", behavior)
	if distance > attack_range:
		return _decision("approach", "outside_attack_range", behavior)
	if distance < preferred_distance:
		return _decision("withdraw", "inside_preferred_distance", behavior)
	return _decision("orbit", "hold_preferred_distance", behavior)


static func _matching_item_punish(context: Dictionary, enemy: Dictionary) -> Dictionary:
	var behavior: Dictionary = enemy.get("combat_behavior", {}) as Dictionary
	var visible_state := _canonical_visible_state(context, behavior)
	for attack_value: Variant in enemy.get("attacks", []):
		var attack := attack_value as Dictionary
		var rule: Dictionary = attack.get("heal_punish", {}) as Dictionary
		if rule.is_empty() or String(rule.get("visible_player_state", "")) != visible_state:
			continue
		if bool(rule.get("requires_line_of_sight", false)) and not bool(
				context.get("has_line_of_sight", false)):
			continue
		return {"attack": attack, "rule": rule}
	return {}


static func _canonical_visible_state(context: Dictionary, behavior: Dictionary) -> String:
	var raw_state := String(context.get("player_visible_state", ""))
	var aliases: Dictionary = behavior.get("visible_state_aliases", {}) as Dictionary
	return String(aliases.get(raw_state, raw_state))


static func _decision(action: String, reason: String, behavior: Dictionary) -> Dictionary:
	var cues: Dictionary = behavior.get("readable_cues", {}) as Dictionary
	return {
		"action": action,
		"reason": reason,
		"readable_cue": String(cues.get(action, "")),
	}
