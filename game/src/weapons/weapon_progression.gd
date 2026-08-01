extends RefCounted
## Fronteira data-driven das 120 armas, dos movesets e das melhorias.
##
## O módulo é puro: recebe os catálogos, devolve perfis/resultados e não conhece
## Player, save ou UI. Assim esses clientes podem integrá-lo sem duplicar regras.

var _weapons: Dictionary = {}
var _equipment: Dictionary = {}


func configure(weapons: Dictionary, equipment: Dictionary) -> bool:
	_weapons = weapons
	_equipment = equipment
	return validate().is_empty()


func validate() -> Array[String]:
	var errors: Array[String] = []
	var catalogue: Dictionary = _equipment.get("weapons", {}) as Dictionary
	var runtime: Dictionary = ((_weapons.get("_catalogo_runtime", {}) as Dictionary).get(
		"weapons", {}) as Dictionary)
	if catalogue.size() != runtime.size():
		errors.append("catalogo runtime não cobre as 120 armas")
	for weapon_id: String in catalogue:
		var runtime_entry: Dictionary = runtime.get(weapon_id, {}) as Dictionary
		if runtime_entry.is_empty():
			errors.append("%s sem perfil runtime" % weapon_id)
		elif float(runtime_entry.get("peso", 0.0)) <= 0.0:
			errors.append("%s sem peso numérico positivo" % weapon_id)
	for weapon_id: String in runtime:
		if not catalogue.has(weapon_id):
			errors.append("%s existe no runtime mas não no catálogo" % weapon_id)
	var signatures: Dictionary = _weapons.get("_weapon_signatures", {}) as Dictionary
	for weapon_id: String in catalogue:
		var family_id := String((catalogue[weapon_id] as Dictionary).get("familia", ""))
		if family_id == "":
			continue
		var variant_id := String((runtime.get(weapon_id, {}) as Dictionary).get("variante", ""))
		if not signatures.has(variant_id):
			errors.append("%s aponta para assinatura inexistente" % weapon_id)
	var improvement_levels: Array = (_weapons.get("_weapon_improvements", {}) as Dictionary).get(
		"levels", []) as Array
	if improvement_levels.size() != 7:
		errors.append("melhoria não declara base + seis níveis")
	for level: int in range(improvement_levels.size()):
		var level_data: Dictionary = improvement_levels[level] as Dictionary
		if int(level_data.get("level", -1)) != level \
				or bool(level_data.get("increases_base_damage", true)):
			errors.append("melhoria +%d está fora de ordem ou compra dano" % level)
		for option_value: Variant in level_data.get("options", []):
			if bool((option_value as Dictionary).get("increases_base_damage", true)):
				errors.append("opção de melhoria +%d compra dano" % level)
	var art_catalogue: Dictionary = _weapons.get("_weapon_arts", {}) as Dictionary
	var art_families: Dictionary = art_catalogue.get("families", {}) as Dictionary
	var art_roles: Dictionary = art_catalogue.get("roles", {}) as Dictionary
	for family_id: String in (_equipment.get("family_movesets", {}) as Dictionary):
		var family_arts: Dictionary = art_families.get(family_id, {}) as Dictionary
		for role_id: String in art_roles:
			var art: Dictionary = family_arts.get(role_id, {}) as Dictionary
			if String(art.get("nome", "")) == "" or String(art.get("verbo", "")) == "" \
					or String(art.get("compromisso", "")) == "":
				errors.append("arte %s/%s incompleta" % [family_id, role_id])
	return errors


func profile(weapon_id: String, _upgrade_state := {}) -> Dictionary:
	var catalogue: Dictionary = _equipment.get("weapons", {}) as Dictionary
	var editorial: Dictionary = catalogue.get(weapon_id, {}) as Dictionary
	var runtime: Dictionary = ((_weapons.get("_catalogo_runtime", {}) as Dictionary).get(
		"weapons", {}) as Dictionary).get(weapon_id, {}) as Dictionary
	if editorial.is_empty() or runtime.is_empty():
		return {}
	var result := {}
	var prototype: Dictionary = _weapons.get(weapon_id, {}) as Dictionary
	if not prototype.is_empty():
		result = prototype.duplicate(true)
	result.merge(editorial, true)
	result.merge(runtime, true)
	result["id"] = weapon_id
	result["qualquer_classe_equipa"] = true
	_apply_upgrade_effects(result, _upgrade_state)
	return result


func equipped_weight(weapon_ids: Array) -> float:
	var total := 0.0
	for weapon_id: Variant in weapon_ids:
		total += float(profile(String(weapon_id)).get("peso", 0.0))
	return total


func moveset(weapon_id: String, _upgrade_state := {}) -> Dictionary:
	var weapon_profile := profile(weapon_id, _upgrade_state)
	if weapon_profile.is_empty():
		return {}
	var variant_id := String(weapon_profile.get("variante", ""))
	var signature: Dictionary = (_weapons.get("_weapon_signatures", {}) as Dictionary).get(
		variant_id, {}) as Dictionary
	if signature.is_empty():
		return {}
	var result := signature.duplicate(true)
	result["id"] = variant_id
	result["familia"] = String(weapon_profile.get("familia", ""))
	if weapon_profile.has("postura"):
		result["postura"] = weapon_profile.get("postura")
		result["moveset_unlock"] = weapon_profile.get("moveset_unlock")
	return result


func new_upgrade_state() -> Dictionary:
	return {"level": 0, "choices": {}}


func upgrade_choices(weapon_id: String, state: Dictionary) -> Array[Dictionary]:
	if profile(weapon_id).is_empty():
		return []
	var next_level := int(state.get("level", 0)) + 1
	var levels: Array = (_weapons.get("_weapon_improvements", {}) as Dictionary).get(
		"levels", []) as Array
	if next_level >= levels.size():
		return []
	var level_data: Dictionary = levels[next_level] as Dictionary
	var result: Array[Dictionary] = []
	for option_value: Variant in level_data.get("options", []):
		var option := (option_value as Dictionary).duplicate(true)
		option["level"] = next_level
		option["axis"] = String(level_data.get("axis", ""))
		option["material"] = _material_for_tier(String(level_data.get("material_tier", "")))
		result.append(option)
	return result


func choose_upgrade(weapon_id: String, state: Dictionary, choice_id: String) -> Dictionary:
	var choices := upgrade_choices(weapon_id, state)
	for option: Dictionary in choices:
		if String(option.get("id", "")) != choice_id:
			continue
		var updated := state.duplicate(true)
		var level := int(option.get("level", 0))
		var selected: Dictionary = updated.get("choices", {}) as Dictionary
		selected[str(level)] = choice_id
		updated["choices"] = selected
		updated["level"] = level
		return {"ok": true, "state": updated, "choice": option}
	return {"ok": false, "state": state.duplicate(true), "message": "Escolha indisponível."}


func revert_upgrade(state: Dictionary, target_level: int) -> Dictionary:
	var updated := state.duplicate(true)
	var current_level := int(updated.get("level", 0))
	var retained_level := clampi(target_level, 0, current_level)
	var selected: Dictionary = updated.get("choices", {}) as Dictionary
	for level_key: Variant in selected.keys():
		if int(String(level_key)) > retained_level:
			selected.erase(level_key)
	updated["choices"] = selected
	updated["level"] = retained_level
	return updated


func weapon_art(weapon_id: String, state: Dictionary, two_handed: bool) -> Dictionary:
	var weapon_profile := profile(weapon_id, state)
	var family_id := String(weapon_profile.get("familia", ""))
	if family_id == "":
		return {}
	var role_id := "base_two_hands" if two_handed else "base_one_hand"
	var override: Dictionary = weapon_profile.get("art_override", {}) as Dictionary
	var override_key := String(override.get("art_key", ""))
	var override_slot := String(override.get("art_slot", ""))
	if override_key.begins_with("master_"):
		role_id = override_key
	elif override_slot == "one_hand" and not two_handed:
		role_id = override_key
	elif override_slot == "two_hands" and two_handed:
		role_id = override_key
	var art_catalogue: Dictionary = _weapons.get("_weapon_arts", {}) as Dictionary
	var role: Dictionary = (art_catalogue.get("roles", {}) as Dictionary).get(
		role_id, {}) as Dictionary
	var family_art: Dictionary = ((art_catalogue.get("families", {}) as Dictionary).get(
		family_id, {}) as Dictionary).get(role_id, {}) as Dictionary
	if role.is_empty() or family_art.is_empty():
		return {}
	var result := role.duplicate(true)
	result.merge(family_art, true)
	result["id"] = "%s/%s" % [family_id, role_id]
	result["family"] = family_id
	result["input_action"] = String(art_catalogue.get("input_action", ""))
	result["interrupt_life_restore_percent"] = int(art_catalogue.get(
		"interrupt_life_restore_percent", 0))
	result["presentation"] = (art_catalogue.get("presentation", {}) as Dictionary).duplicate(true)
	return result


func perform_art(weapon_id: String, state: Dictionary, two_handed: bool,
		current_mana: int) -> Dictionary:
	var art := weapon_art(weapon_id, state, two_handed)
	var cost := int(art.get("mana_cost", 0))
	if art.is_empty() or cost <= 0 or current_mana < cost:
		return {"ok": false, "mana_after": current_mana, "art": art}
	return {
		"ok": true,
		"mana_after": current_mana - cost,
		"art": art,
		"attack_manifest": art.duplicate(true),
	}


func _apply_upgrade_effects(result: Dictionary, state: Dictionary) -> void:
	var selected: Dictionary = state.get("choices", {}) as Dictionary
	var levels: Array = (_weapons.get("_weapon_improvements", {}) as Dictionary).get(
		"levels", []) as Array
	for level: int in range(1, levels.size()):
		var choice_id := String(selected.get(str(level), selected.get(level, "")))
		if choice_id == "":
			continue
		for option_value: Variant in (levels[level] as Dictionary).get("options", []):
			var option: Dictionary = option_value as Dictionary
			if String(option.get("id", "")) != choice_id:
				continue
			var effect: Dictionary = option.get("effect", {}) as Dictionary
			if effect.has("postura"):
				result["postura"] = effect.get("postura")
				result["moveset_unlock"] = effect.get("moveset_unlock")
			if effect.has("scaling_attribute"):
				result["scaling_attribute"] = effect.get("scaling_attribute")
				result["escala"] = effect.get("scaling_attribute")
			if effect.has("damage_type"):
				result["damage_conversion"] = {
					"type": effect.get("damage_type"),
					"fraction": float((_weapons.get("_weapon_improvements", {}) as Dictionary).get(
						"elemental_conversion_fraction", 0.0)),
					"preserves_base_total": true,
				}
			if effect.has("art_key"):
				result["art_override"] = effect.duplicate(true)


func _material_for_tier(tier: String) -> Dictionary:
	return ((_weapons.get("_weapon_improvements", {}) as Dictionary).get(
		"materials", {}) as Dictionary).get(tier, {}) as Dictionary
