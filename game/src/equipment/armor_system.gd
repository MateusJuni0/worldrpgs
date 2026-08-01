class_name ArmorSystem
extends RefCounted
## Contrato publico da armadura: transforma dados do catalogo num perfil que
## movimento, dano, UI e visual podem consumir. Nenhum valor de combate vive aqui.


static func load_profile_for_weight(weight: float, capacity: float) -> Dictionary:
	var armor_data: Dictionary = GameData.armor
	var dodge_data: Dictionary = GameData.section("dodge")
	var rules: Dictionary = armor_data.get("carga", {}) as Dictionary
	var fraction := weight / capacity if capacity > 0.0 else INF
	var load_class := "sobrecarregado"
	for candidate: String in ["leve", "medio", "pesado"]:
		var candidate_rule: Dictionary = rules.get(candidate, {}) as Dictionary
		if fraction <= float(candidate_rule.get("max_fraccao", 0.0)):
			load_class = candidate
			break
	var rule: Dictionary = rules.get(load_class, {}) as Dictionary
	var can_dodge := bool(rule.get("pode_esquivar", true))
	var distance_multiplier := float(rule.get("distancia_esquiva_mult", 1.0))
	var duration_multiplier := float(rule.get("duracao_esquiva_mult", 1.0))
	var base_distance := float(dodge_data.get("distance", 0.0))
	var base_duration := int(dodge_data.get("duration_frames", 0))
	return {
		"weight": weight,
		"capacity": capacity,
		"fraction": fraction,
		"class": load_class,
		"recovery_frames": int(rule.get("recuperacao_esquiva_frames", 0)),
		"regen_multiplier": float(rule.get("regen_stamina_mult", 1.0)),
		"can_dodge": can_dodge,
		"can_run": bool(rule.get("pode_correr", true)),
		"can_sprint": bool(rule.get("pode_sprintar", true)),
		"max_speed": float(rule.get("velocidade_maxima_m_s", INF)),
		"dodge_distance": base_distance * distance_multiplier if can_dodge else 0.0,
		"dodge_duration_frames": roundi(float(base_duration) * duration_multiplier) if can_dodge else 0,
		"dodge_stamina_cost": float(dodge_data.get("stamina_cost", 0.0)) * float(
			rule.get("custo_stamina_esquiva_mult", 1.0)) if can_dodge else 0.0,
		"iframe_start_frame": int(dodge_data.get("iframe_start_frame", 0)) if can_dodge else -1,
		"iframe_end_frame": int(dodge_data.get("iframe_end_frame", 0)) if can_dodge else -1,
	}


static func preview_equip(current_ids: Array, candidate_id: String, carga_attr: int,
		class_id := "", base_non_armor_weight := 0.0) -> Dictionary:
	var candidate := armor_piece(candidate_id)
	if candidate.is_empty():
		return {"can_equip": false, "error": "unknown_piece"}
	var slot := String(candidate.get("slot", ""))
	if not (GameData.armor.get("slots", []) as Array).has(slot):
		return {"can_equip": false, "error": "unknown_slot"}
	var equipped_ids := current_ids.duplicate()
	var replaced_id := ""
	for index: int in range(equipped_ids.size() - 1, -1, -1):
		var equipped_id := String(equipped_ids[index])
		if String(armor_piece(equipped_id).get("slot", "")) == slot:
			replaced_id = equipped_id
			equipped_ids.remove_at(index)
	equipped_ids.append(candidate_id)
	var capacity := GameData.load_capacity_for(carga_attr)
	var before_weight := float(base_non_armor_weight) + armor_weight(current_ids)
	var after_weight := float(base_non_armor_weight) + armor_weight(equipped_ids)
	return {
		"can_equip": true,
		"class_id": class_id,
		"slot": slot,
		"candidate_id": candidate_id,
		"replaced_id": replaced_id,
		"equipped_ids": equipped_ids,
		"before": load_profile_for_weight(before_weight, capacity),
		"after": load_profile_for_weight(after_weight, capacity),
		"weight_delta": after_weight - before_weight,
	}


static func armor_weight(piece_ids: Array) -> float:
	var total := 0.0
	for piece_value: Variant in piece_ids:
		total += float(armor_piece(String(piece_value)).get("peso", 0.0))
	return total


static func armor_piece(piece_id: String) -> Dictionary:
	var catalogue: Dictionary = GameData.equipment.get("armor", {}) as Dictionary
	var piece: Dictionary = catalogue.get(piece_id, {}) as Dictionary
	if piece.is_empty():
		piece = (GameData.armor.get("pieces", {}) as Dictionary).get(piece_id, {}) as Dictionary
	return piece


static func resistance_profile(piece_ids: Array) -> Dictionary:
	var by_slot := {}
	for piece_value: Variant in piece_ids:
		var piece_id := String(piece_value)
		var piece := armor_piece(piece_id)
		var slot := String(piece.get("slot", ""))
		if slot != "":
			by_slot[slot] = piece_id
	var values_by_type := {}
	for piece_id: String in by_slot.values():
		var piece_resistances: Dictionary = armor_piece(piece_id).get("resistencias", {}) as Dictionary
		for raw_type: String in piece_resistances:
			var damage_type := raw_type
			var biome: Dictionary = GameData.biomes.get(raw_type, {}) as Dictionary
			if not biome.is_empty():
				damage_type = String(biome.get("elemento", raw_type))
			if not values_by_type.has(damage_type):
				values_by_type[damage_type] = []
			(values_by_type[damage_type] as Array).append(float(piece_resistances[raw_type]))
	var result := {}
	for damage_type: String in values_by_type:
		result[damage_type] = combine_resistance_values(values_by_type[damage_type] as Array)
	return result


static func combine_resistance_values(values: Array) -> float:
	var rules: Dictionary = GameData.armor.get("resistance_rules", {}) as Dictionary
	var scale := float(rules.get("percent_scale", 0.0))
	var piece_cap := float(rules.get("max_per_piece_percent", 0.0))
	if scale <= 0.0 or piece_cap < 0.0:
		return 0.0
	var combined := 0.0
	for raw_value: Variant in values:
		var contribution := clampf(float(raw_value), 0.0, piece_cap)
		combined = combined + contribution - combined * contribution / scale
	return combined


static func damage_fraction_after_resistance(resistance_percent: float) -> float:
	var rules: Dictionary = GameData.armor.get("resistance_rules", {}) as Dictionary
	var scale := float(rules.get("percent_scale", 0.0))
	var minimum_fraction := float(rules.get("minimum_damage_fraction", 0.0))
	if scale <= 0.0:
		return 1.0
	return maxf(minimum_fraction, 1.0 - clampf(resistance_percent, 0.0, scale) / scale)


static func damage_after_armor(raw_damage: float, damage_type: String,
		piece_ids: Array) -> float:
	var profile := resistance_profile(piece_ids)
	var resistance := float(profile.get(damage_type, 0.0))
	return raw_damage * damage_fraction_after_resistance(resistance)
