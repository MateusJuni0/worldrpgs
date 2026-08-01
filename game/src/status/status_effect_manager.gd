class_name StatusEffectManager
extends Node
## Acumula estados e publica um aviso visual+sonoro antes de qualquer disparo.
##
## Os valores vêm todos de res://data/status_effects.json. O gestor não conhece
## Player nem Enemy: devolve resultados públicos para os dois consumidores.

signal feedback_requested(event: Dictionary)
signal ring_effect_requested(event: Dictionary)

const CATALOG_PATH := "res://data/status_effects.json"
const ECONOMY_PATH := "res://data/economy.json"
const EQUIPMENT_PATH := "res://data/equipment.json"

var _catalog: Dictionary = {}
var _effects: Dictionary = {}
var _meters: Dictionary = {}
var _since_buildup: Dictionary = {}
var _active: Dictionary = {}
var _target_tags: Dictionary = {}
var _consumables: Dictionary = {}
var _resistances: Dictionary = {}
var _rings: Dictionary = {}
var _ring_behaviors: Dictionary = {}
var _equipped_rings: Dictionary = {}


func configure(catalog: Dictionary = {}) -> bool:
	_catalog = catalog.duplicate(true) if not catalog.is_empty() else _load_catalog()
	_effects = _catalog.get("effects", {}) as Dictionary
	_consumables = (_load_json(ECONOMY_PATH).get("consumables", {}) as Dictionary)
	_rings = (_load_json(EQUIPMENT_PATH).get("rings", {}) as Dictionary)
	_ring_behaviors = (_catalog.get("catalogue_integrations", {}) as Dictionary).get("ring_behaviors", {}) as Dictionary
	_meters.clear()
	_since_buildup.clear()
	_active.clear()
	_target_tags.clear()
	_resistances.clear()
	_equipped_rings.clear()
	for status_value: Variant in _effects.keys():
		var status_id := String(status_value)
		_meters[status_id] = 0.0
		_since_buildup[status_id] = 0.0
	return not _effects.is_empty()


func verification_case(case_id: String) -> Dictionary:
	return (_catalog.get("_verification", {}) as Dictionary).get(case_id, {}) as Dictionary


func presentation_config() -> Dictionary:
	return (_catalog.get("presentation", {}) as Dictionary).duplicate(true)


func benchmark_config() -> Dictionary:
	return (presentation_config().get("benchmark", {}) as Dictionary).duplicate(true)


func effect_ids() -> Array:
	var ids: Array = _effects.keys()
	ids.sort()
	return ids


func integration_ids(kind: String) -> Array:
	return ((_catalog.get("catalogue_integrations", {}) as Dictionary).get(kind, []) as Array).duplicate()


func set_target_tags(tags: Array) -> void:
	_target_tags.clear()
	for tag_value: Variant in tags:
		_target_tags[String(tag_value)] = true


func apply_buildup(status_id: String, amount: float, source_id: String = "") -> Dictionary:
	var effect := _effects.get(status_id, {}) as Dictionary
	if effect.is_empty() or amount <= 0.0:
		return {"accepted": false, "triggered": false, "meter": meter_value(status_id)}
	if is_active(status_id) and not bool(effect.get("buildup_while_active", false)):
		return {
			"accepted": false,
			"reason": "already_active",
			"triggered": false,
			"meter": meter_value(status_id),
		}
	if _is_immune(effect):
		var immunity_feedback := effect.get("feedback", {}) as Dictionary
		feedback_requested.emit({
			"status_id": status_id,
			"phase": "immune",
			"source_id": source_id,
			"meter": meter_value(status_id),
			"maximum": float((effect.get("meter", {}) as Dictionary).get("maximum", 0.0)),
			"fraction": 0.0,
			"visual": (immunity_feedback.get("immunity_visual", {}) as Dictionary).duplicate(true),
			"sound": (immunity_feedback.get("immunity_sound", {}) as Dictionary).duplicate(true),
			"ring_presentations": _ring_presentations("immune", status_id),
		})
		return {
			"accepted": false,
			"immune": true,
			"triggered": false,
			"meter": meter_value(status_id),
		}
	var meter_config := effect.get("meter", {}) as Dictionary
	var maximum := float(meter_config.get("maximum", 0.0))
	if maximum <= 0.0:
		return {"accepted": false, "triggered": false, "meter": meter_value(status_id)}
	var current := minf(maximum, meter_value(status_id) + amount * resistance_multiplier(status_id))
	_meters[status_id] = current
	_since_buildup[status_id] = 0.0
	var triggered := current >= maximum
	var feedback := effect.get("feedback", {}) as Dictionary
	feedback_requested.emit({
		"status_id": status_id,
		"phase": "buildup",
		"source_id": source_id,
		"meter": current,
		"maximum": maximum,
		"fraction": current / maximum,
		"visual": (feedback.get("visual", {}) as Dictionary).duplicate(true),
		"sound": (feedback.get("sound", {}) as Dictionary).duplicate(true),
		"ring_presentations": _ring_presentations("buildup", status_id),
	})
	if not triggered:
		return {"accepted": true, "triggered": false, "meter": current}
	var trigger := effect.get("trigger", {}) as Dictionary
	var reset_value := float(trigger.get("reset_meter_to", 0.0))
	var consequences := (trigger.get("consequences", {}) as Dictionary).duplicate(true)
	_meters[status_id] = reset_value
	if String(trigger.get("mode", "")) == "duration":
		_active[status_id] = {
			"elapsed_s": 0.0,
			"next_tick_s": float(trigger.get("tick_interval_s", 0.0)),
		}
	feedback_requested.emit({
		"status_id": status_id,
		"phase": "trigger",
		"source_id": source_id,
		"meter": reset_value,
		"maximum": maximum,
		"fraction": reset_value / maximum,
		"visual": (feedback.get("trigger_visual", {}) as Dictionary).duplicate(true),
		"sound": (feedback.get("trigger_sound", {}) as Dictionary).duplicate(true),
	})
	return {
		"accepted": true,
		"triggered": true,
		"meter": reset_value,
		"consequences": consequences,
		"active": _active.has(status_id),
	}


func tick(delta: float) -> Array:
	var outcomes: Array = []
	if delta <= 0.0:
		return outcomes
	_tick_meters(delta)
	_tick_active_effects(delta, outcomes)
	_tick_resistances(delta)
	return outcomes


func is_active(status_id: String) -> bool:
	return _active.has(status_id)


func use_consumable(item_id: String) -> Dictionary:
	var item := _consumables.get(item_id, {}) as Dictionary
	var item_effect := item.get("effect", {}) as Dictionary
	if item.is_empty() or item_effect.is_empty():
		return {"used": false}
	var cleared: Array[String] = []
	for status_value: Variant in item_effect.get("clear_status_meters", []):
		var status_id := String(status_value)
		if not _effects.has(status_id):
			continue
		_clear_status(status_id)
		cleared.append(status_id)
		_emit_consumable_feedback(status_id, item_id, item)
	var duration := float(item_effect.get("duration_seconds", 0.0))
	var resistance_applied := false
	for key_value: Variant in item_effect.keys():
		var key := String(key_value)
		if not key.ends_with("_buildup_multiplier"):
			continue
		var status_id := key.trim_suffix("_buildup_multiplier")
		if not _effects.has(status_id):
			continue
		_resistances[status_id] = {
			"multiplier": float(item_effect[key]),
			"remaining_s": duration,
		}
		resistance_applied = true
	_request_ring_effects("consumable_used", {"consumable_id": item_id})
	return {
		"used": not cleared.is_empty() or resistance_applied,
		"cleared": cleared,
		"resistance_duration_s": duration,
	}


func resistance_multiplier(status_id: String) -> float:
	return float((_resistances.get(status_id, {}) as Dictionary).get("multiplier", 1.0))


func equip_rings(ring_ids: Array) -> Array[String]:
	_equipped_rings.clear()
	var equipped: Array[String] = []
	for ring_value: Variant in ring_ids:
		var ring_id := String(ring_value)
		if not _rings.has(ring_id) or not _ring_behaviors.has(ring_id):
			continue
		_equipped_rings[ring_id] = true
		equipped.append(ring_id)
	return equipped


func finish_dodge(surface_tag: String) -> Array[String]:
	var cleared: Array[String] = []
	for ring_value: Variant in _equipped_rings.keys():
		var ring_id := String(ring_value)
		var behavior := _ring_behaviors.get(ring_id, {}) as Dictionary
		if String(behavior.get("event", "")) != "dodge_finished":
			continue
		if not (behavior.get("surface_tags", []) as Array).has(surface_tag):
			continue
		var status_id := String(behavior.get("clear_status", ""))
		if not is_active(status_id) and meter_value(status_id) <= 0.0:
			continue
		_clear_status(status_id)
		cleared.append(status_id)
		_emit_ring_feedback(status_id, ring_id, behavior)
	return cleared


func clear_on_rest() -> Array:
	var rest := (_catalog.get("global_exits", {}) as Dictionary).get("rest", {}) as Dictionary
	if not bool(rest.get("clear_all", false)):
		return []
	var feedback := rest.get("feedback", {}) as Dictionary
	var cleared := effect_ids()
	for status_index: int in cleared.size():
		var status_id := String(cleared[status_index])
		_clear_status(status_id)
		var effect := _effects.get(status_id, {}) as Dictionary
		feedback_requested.emit({
			"status_id": status_id,
			"phase": "cured",
			"source_id": "rest",
			"meter": 0.0,
			"maximum": float((effect.get("meter", {}) as Dictionary).get("maximum", 0.0)),
			"fraction": 0.0,
			"visual": (feedback.get("visual", {}) as Dictionary).duplicate(true),
			"sound": (feedback.get("sound", {}) as Dictionary).duplicate(true) if status_index == 0 else {},
		})
	_resistances.clear()
	return cleared


func _tick_meters(delta: float) -> void:
	for status_value: Variant in _effects.keys():
		var status_id := String(status_value)
		var current := meter_value(status_id)
		if current <= 0.0:
			continue
		var meter_config := (_effects[status_id] as Dictionary).get("meter", {}) as Dictionary
		var delay := float(meter_config.get("decay_delay_s", 0.0))
		var rate := float(meter_config.get("decay_per_s", 0.0))
		var previous_time := float(_since_buildup.get(status_id, 0.0))
		var current_time := previous_time + delta
		_since_buildup[status_id] = current_time
		var effective_delta := maxf(current_time - delay, 0.0) - maxf(previous_time - delay, 0.0)
		if effective_delta <= 0.0 or rate <= 0.0:
			continue
		var maximum := float(meter_config.get("maximum", 0.0))
		var next_value := maxf(0.0, current - rate * effective_delta)
		_meters[status_id] = next_value
		var feedback := (_effects[status_id] as Dictionary).get("feedback", {}) as Dictionary
		feedback_requested.emit({
			"status_id": status_id,
			"phase": "decay",
			"source_id": "",
			"meter": next_value,
			"maximum": maximum,
			"fraction": next_value / maximum if maximum > 0.0 else 0.0,
			"visual": (feedback.get("visual", {}) as Dictionary).duplicate(true),
			"sound": {},
		})


func _tick_active_effects(delta: float, outcomes: Array) -> void:
	for status_value: Variant in _active.keys():
		var status_id := String(status_value)
		var effect := _effects.get(status_id, {}) as Dictionary
		var trigger := effect.get("trigger", {}) as Dictionary
		var active := _active[status_id] as Dictionary
		var duration := float(trigger.get("duration_s", 0.0))
		var interval := float(trigger.get("tick_interval_s", 0.0))
		if duration <= 0.0 or interval <= 0.0:
			_active.erase(status_id)
			continue
		var end_time := minf(duration, float(active.get("elapsed_s", 0.0)) + delta)
		var next_tick := float(active.get("next_tick_s", interval))
		while next_tick <= end_time:
			var consequences := _resolved_tick_consequences(trigger)
			outcomes.append({
				"status_id": status_id,
				"phase": "tick",
				"consequences": consequences,
			})
			_emit_active_feedback(status_id, "tick", duration - next_tick)
			next_tick += interval
		active["elapsed_s"] = end_time
		active["next_tick_s"] = next_tick
		if end_time >= duration:
			_active.erase(status_id)
			_emit_active_feedback(status_id, "expired", 0.0)
		else:
			_active[status_id] = active


func _resolved_tick_consequences(trigger: Dictionary) -> Dictionary:
	var consequences := (trigger.get("tick_consequences", {}) as Dictionary).duplicate(true)
	var conditional := consequences.get("if_target_has_tag", {}) as Dictionary
	consequences.erase("if_target_has_tag")
	if conditional.is_empty() or not _target_tags.has(String(conditional.get("tag", ""))):
		return consequences
	for key_value: Variant in conditional.keys():
		var key := String(key_value)
		if key != "tag":
			consequences[key] = conditional[key]
	return consequences


func _tick_resistances(delta: float) -> void:
	for status_value: Variant in _resistances.keys():
		var status_id := String(status_value)
		var resistance := _resistances[status_id] as Dictionary
		var remaining := maxf(0.0, float(resistance.get("remaining_s", 0.0)) - delta)
		if remaining <= 0.0:
			_resistances.erase(status_id)
		else:
			resistance["remaining_s"] = remaining
			_resistances[status_id] = resistance


func _clear_status(status_id: String) -> void:
	_meters[status_id] = 0.0
	_since_buildup[status_id] = 0.0
	_active.erase(status_id)


func _emit_consumable_feedback(status_id: String, item_id: String, item: Dictionary) -> void:
	var effect := _effects.get(status_id, {}) as Dictionary
	var feedback := effect.get("feedback", {}) as Dictionary
	feedback_requested.emit({
		"status_id": status_id,
		"phase": "cured",
		"source_id": item_id,
		"meter": 0.0,
		"maximum": float((effect.get("meter", {}) as Dictionary).get("maximum", 0.0)),
		"fraction": 0.0,
		"visual": {
			"description": String(item.get("visual", "")),
			"clears_pattern": String((feedback.get("visual", {}) as Dictionary).get("pattern", "")),
		},
		"sound": {
			"profile": "consumable_%s" % item_id,
			"description": String(item.get("sound", "")),
		},
	})


func _emit_ring_feedback(status_id: String, ring_id: String, behavior: Dictionary) -> void:
	var feedback := behavior.get("feedback", {}) as Dictionary
	var effect := _effects.get(status_id, {}) as Dictionary
	feedback_requested.emit({
		"status_id": status_id,
		"phase": "cured",
		"source_id": ring_id,
		"meter": 0.0,
		"maximum": float((effect.get("meter", {}) as Dictionary).get("maximum", 0.0)),
		"fraction": 0.0,
		"visual": (feedback.get("visual", {}) as Dictionary).duplicate(true),
		"sound": (feedback.get("sound", {}) as Dictionary).duplicate(true),
	})


func _ring_presentations(event_name: String, status_id: String) -> Array[String]:
	var presentations: Array[String] = []
	for ring_value: Variant in _equipped_rings.keys():
		var behavior := _ring_behaviors.get(String(ring_value), {}) as Dictionary
		if String(behavior.get("event", "")) != event_name:
			continue
		if String(behavior.get("status_id", "")) != status_id:
			continue
		var presentation := String(behavior.get("presentation", ""))
		if presentation != "":
			presentations.append(presentation)
	return presentations


func _request_ring_effects(event_name: String, context: Dictionary) -> void:
	for ring_value: Variant in _equipped_rings.keys():
		var ring_id := String(ring_value)
		var behavior := _ring_behaviors.get(ring_id, {}) as Dictionary
		if String(behavior.get("event", "")) != event_name:
			continue
		var required_consumable := String(behavior.get("consumable_id", ""))
		if required_consumable != "" and required_consumable != String(context.get("consumable_id", "")):
			continue
		var action := String(behavior.get("external_action", ""))
		if action != "":
			ring_effect_requested.emit({
				"ring_id": ring_id,
				"action": action,
				"context": context.duplicate(true),
			})


func _emit_active_feedback(status_id: String, phase: String, remaining_s: float) -> void:
	var effect := _effects.get(status_id, {}) as Dictionary
	var feedback := effect.get("feedback", {}) as Dictionary
	var visual_key := "expire_visual" if phase == "expired" else "tick_visual"
	var sound_key := "expire_sound" if phase == "expired" else "tick_sound"
	feedback_requested.emit({
		"status_id": status_id,
		"phase": phase,
		"source_id": "",
		"meter": meter_value(status_id),
		"maximum": float((effect.get("meter", {}) as Dictionary).get("maximum", 0.0)),
		"fraction": 0.0,
		"active_remaining_s": maxf(remaining_s, 0.0),
		"visual": (feedback.get(visual_key, feedback.get("trigger_visual", {})) as Dictionary).duplicate(true),
		"sound": (feedback.get(sound_key, feedback.get("trigger_sound", {})) as Dictionary).duplicate(true),
	})


func meter_value(status_id: String) -> float:
	return float(_meters.get(status_id, 0.0))


func _is_immune(effect: Dictionary) -> bool:
	for tag_value: Variant in effect.get("immunity_tags", []):
		if _target_tags.has(String(tag_value)):
			return true
	return false


func _load_catalog() -> Dictionary:
	return _load_json(CATALOG_PATH)


func _load_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("Catálogo em falta: %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("Catálogo inválido: %s" % path)
		return {}
	return parsed as Dictionary
