extends RefCounted
## Fronteira pura para seleccionar e executar artes de arma.
##
## Todos os frames, custos, curvas, limites e orçamentos vêm de weapons.json.
## O Player, input, áudio, visual e rede consomem os manifestos; este módulo não
## conhece dispositivos, nós de cena ou números de combate.

var _weapons: Dictionary = {}
var _equipment: Dictionary = {}
var _arts: Dictionary = {}
var _movesets: Dictionary = {}
var _legacy_arts: Dictionary = {}


func configure(weapons: Dictionary, equipment: Dictionary) -> bool:
	_weapons = weapons
	_equipment = equipment
	_arts = weapons.get("_artes", {}) as Dictionary
	_movesets = weapons.get("_movesets", {}) as Dictionary
	_legacy_arts = weapons.get("_weapon_arts", {}) as Dictionary
	return validate().is_empty()


func validate() -> Array[String]:
	var errors: Array[String] = []
	if _arts.is_empty():
		errors.append("weapons.json sem _artes")
	if _movesets.is_empty():
		errors.append("weapons.json sem _movesets")
	if _legacy_arts.is_empty():
		errors.append("catálogo editorial _weapon_arts inexistente")
	if not errors.is_empty():
		return errors
	var permitted_vectors: Array = _arts.get("vectores_fuga_permitidos", []) as Array
	var timing_profiles: Dictionary = _arts.get("perfis_temporais", {}) as Dictionary
	var family_contracts: Dictionary = _arts.get("familias", {}) as Dictionary
	var family_movesets: Dictionary = _movesets.get("familias", {}) as Dictionary
	var legacy_roles: Dictionary = _legacy_arts.get("roles", {}) as Dictionary
	var legacy_families: Dictionary = _legacy_arts.get("families", {}) as Dictionary
	var grips: Array = _arts.get("empunhaduras", []) as Array
	if permitted_vectors.is_empty():
		errors.append("_artes sem vectores de fuga permitidos")
	if grips.is_empty():
		errors.append("_artes sem empunhaduras")
	for family_id: String in (_equipment.get("family_movesets", {}) as Dictionary):
		var family_contract: Dictionary = family_contracts.get(family_id, {}) as Dictionary
		var family_moveset: Dictionary = family_movesets.get(family_id, {}) as Dictionary
		var legacy_family: Dictionary = legacy_families.get(family_id, {}) as Dictionary
		if family_contract.is_empty():
			errors.append("arte sem contrato para família %s" % family_id)
			continue
		if family_moveset.is_empty():
			errors.append("moveset inexistente para família %s" % family_id)
		if legacy_family.is_empty():
			errors.append("arte editorial inexistente para família %s" % family_id)
		for grip_value: Variant in grips:
			var grip := String(grip_value)
			var contract: Dictionary = family_contract.get(grip, {}) as Dictionary
			var moveset: Dictionary = family_moveset.get(grip, {}) as Dictionary
			if contract.is_empty():
				errors.append("arte %s/%s sem contrato" % [family_id, grip])
				continue
			if moveset.is_empty() or String(moveset.get("animation_set", "")) == "" \
					or String(moveset.get("posture", "")) == "":
				errors.append("moveset %s/%s incompleto" % [family_id, grip])
			var timing_id := String(contract.get("perfil_temporal", ""))
			var timing: Dictionary = timing_profiles.get(timing_id, {}) as Dictionary
			_validate_contract(errors, family_id, grip, contract, timing, permitted_vectors)
		for role_id: String in legacy_roles:
			var flavour: Dictionary = legacy_family.get(role_id, {}) as Dictionary
			if String(flavour.get("nome", "")) == "" \
					or String(flavour.get("verbo", "")) == "" \
					or String(flavour.get("compromisso", "")) == "":
				errors.append("arte editorial %s/%s incompleta" % [family_id, role_id])
	var catalogue: Dictionary = _equipment.get("weapons", {}) as Dictionary
	var exceptions: Dictionary = _arts.get("excepcoes_por_arma", {}) as Dictionary
	for weapon_id: String in exceptions:
		if not catalogue.has(weapon_id):
			errors.append("excepção de arte aponta para arma inexistente %s" % weapon_id)
		continue
		if String((catalogue[weapon_id] as Dictionary).get("familia", "")) == "":
			errors.append("excepção de arte aponta para item sem família %s" % weapon_id)
	var levels: Array = ((_weapons.get("_weapon_improvements", {}) as Dictionary).get(
		"levels", []) as Array)
	var expected_levels := int(_arts.get("upgrade_level_count", 0))
	if levels.size() != expected_levels:
		errors.append("melhoria não cobre base + seis níveis")
	var budget: Dictionary = _arts.get("orcamento_runtime", {}) as Dictionary
	for field: String in ["benchmark_iterations", "resolve_p95_usec_max",
			"catalogue_utf8_bytes_max"]:
		if float(budget.get(field, 0.0)) <= 0.0:
			errors.append("orçamento runtime sem %s" % field)
	return errors


func art_for(weapon_id: String, upgrade_state: Dictionary, two_handed: bool) -> Dictionary:
	var family_id := _family_for(weapon_id)
	if family_id == "":
		return {}
	var grip := _grip(two_handed)
	var role_id := _role_for(upgrade_state, grip)
	var roles: Dictionary = _legacy_arts.get("roles", {}) as Dictionary
	var role: Dictionary = roles.get(role_id, {}) as Dictionary
	var family_flavours: Dictionary = (_legacy_arts.get("families", {}) as Dictionary).get(
		family_id, {}) as Dictionary
	var flavour: Dictionary = family_flavours.get(role_id, {}) as Dictionary
	var family_contracts: Dictionary = _arts.get("familias", {}) as Dictionary
	var contract: Dictionary = (family_contracts.get(family_id, {}) as Dictionary).get(
		grip, {}) as Dictionary
	var timing_id := String(contract.get("perfil_temporal", ""))
	var timing: Dictionary = (_arts.get("perfis_temporais", {}) as Dictionary).get(
		timing_id, {}) as Dictionary
	if role.is_empty() or flavour.is_empty() or contract.is_empty() or timing.is_empty():
		return {}
	var result := role.duplicate(true)
	result.merge(flavour, true)
	result.merge(contract, true)
	result.merge(timing, true)
	result["definition_id"] = "%s/%s" % [family_id, role_id]
	result["weapon_id"] = weapon_id
	result["family"] = family_id
	result["grip"] = grip
	result["role"] = role_id
	result["input_action"] = String(_arts.get("input_action", ""))
	result["resource"] = String(_arts.get("resource", ""))
	result["interrupt_life_restore_percent"] = int(_arts.get(
		"interrupt_life_restore_percent", 0))
	result["tradeoff"] = String(flavour.get("compromisso", ""))
	var exception: Dictionary = ((_arts.get("excepcoes_por_arma", {}) as Dictionary).get(
		weapon_id, {}) as Dictionary).get(role_id, {}) as Dictionary
	if not exception.is_empty():
		result.merge(exception, true)
	return result


func moveset_for(weapon_id: String, upgrade_state: Dictionary,
		two_handed: bool) -> Dictionary:
	var family_id := _family_for(weapon_id)
	if family_id == "":
		return {}
	var grip := _grip(two_handed)
	var family: Dictionary = (_movesets.get("familias", {}) as Dictionary).get(
		family_id, {}) as Dictionary
	var grip_data: Dictionary = family.get(grip, {}) as Dictionary
	if grip_data.is_empty():
		return {}
	var base_moves: Array = _movesets.get("movimentos_base", []) as Array
	var moves := base_moves.duplicate()
	var posture := String(grip_data.get("posture", ""))
	var unlocked: Array[String] = []
	var selected: Dictionary = upgrade_state.get("choices", {}) as Dictionary
	var levels: Array = ((_weapons.get("_weapon_improvements", {}) as Dictionary).get(
		"levels", []) as Array)
	var current_level := mini(int(upgrade_state.get("level", 0)), levels.size() - 1)
	for level: int in range(1, current_level + 1):
		var choice_id := String(selected.get(str(level), selected.get(level, "")))
		var effect := _effect_for_choice(levels[level] as Dictionary, choice_id)
		if not effect.has("postura"):
			continue
		if effect.has("replaces_level"):
			moves = base_moves.duplicate()
			unlocked.clear()
		posture = String(effect.get("postura", posture))
		var move_id := String(effect.get("moveset_unlock", ""))
		if move_id != "" and not moves.has(move_id):
			moves.append(move_id)
			unlocked.append(move_id)
	var runtime: Dictionary = ((_weapons.get("_catalogo_runtime", {}) as Dictionary).get(
		"weapons", {}) as Dictionary).get(weapon_id, {}) as Dictionary
	var signature_id := String(runtime.get("variante", ""))
	var signature: Dictionary = (_weapons.get("_weapon_signatures", {}) as Dictionary).get(
		signature_id, {}) as Dictionary
	return {
		"weapon_id": weapon_id,
		"family": family_id,
		"grip": grip,
		"moveset_id": String(grip_data.get("animation_set", "")),
		"posture": posture,
		"moves": moves,
		"unlocked_moves": unlocked,
		"signature_id": signature_id,
		"signature": signature.duplicate(true),
		"upgrade_level": current_level,
	}


func begin(weapon_id: String, upgrade_state: Dictionary, two_handed: bool,
		resources: Dictionary, actor_state: String) -> Dictionary:
	var unchanged := resources.duplicate(true)
	var art := art_for(weapon_id, upgrade_state, two_handed)
	if art.is_empty():
		return {"ok": false, "reason": "unknown_weapon_art", "resources": unchanged}
	if actor_state != String(_arts.get("free_state", "")):
		return {"ok": false, "reason": "actor_busy", "resources": unchanged, "art": art}
	var resource_key := String(_arts.get("resource", ""))
	var cost := int(art.get("mana_cost", 0))
	var available := int(unchanged.get(resource_key, 0))
	if cost <= 0 or available < cost:
		return {"ok": false, "reason": "insufficient_resource",
			"resources": unchanged, "art": art}
	var paid := unchanged.duplicate(true)
	paid[resource_key] = available - cost
	var session := {
		"active": true,
		"locked": true,
		"frame": 0,
		"phase": "startup",
		"effect_committed": false,
		"effect_emissions": 0,
		"effect_emitted_this_step": false,
		"interrupted": false,
		"art": art,
		"resources": paid.duplicate(true),
	}
	return {"ok": true, "resources": paid, "art": art, "session": session}


func advance(session: Dictionary, delta_frames: int) -> Dictionary:
	var updated := session.duplicate(true)
	updated["effect_emitted_this_step"] = false
	if not bool(updated.get("active", false)):
		return updated
	var art: Dictionary = updated.get("art", {}) as Dictionary
	var frame := maxi(0, int(updated.get("frame", 0)) + maxi(0, delta_frames))
	updated["frame"] = frame
	var commitment := int(art.get("momento_compromisso_frame", 0))
	var active_start := int(art.get("active_start_frame", 0))
	var active_end := int(art.get("active_end_frame", 0))
	var recovery_end := int(art.get("recovery_end_frame", 0))
	if frame >= commitment and not bool(updated.get("effect_committed", false)):
		updated["effect_committed"] = true
		updated["effect_emissions"] = int(updated.get("effect_emissions", 0)) + 1
		updated["effect_emitted_this_step"] = true
	if frame < commitment:
		updated["phase"] = "startup"
	elif frame <= active_end and frame >= active_start:
		updated["phase"] = "active"
	elif frame < recovery_end:
		updated["phase"] = "recovery"
	else:
		updated["phase"] = "completed"
		updated["active"] = false
		updated["locked"] = false
	return updated


func request_cancel(session: Dictionary) -> Dictionary:
	return {"cancelled": false, "session": session.duplicate(true)}


func try_interrupt(session: Dictionary, posture_broken: bool) -> Dictionary:
	var updated := session.duplicate(true)
	var interrupted := false
	if posture_broken and bool(updated.get("active", false)) \
			and not bool(updated.get("effect_committed", false)):
		interrupted = true
		updated["interrupted"] = true
		updated["active"] = false
		updated["locked"] = false
		updated["phase"] = "interrupted"
	return {
		"interrupted": interrupted,
		"effect_preserved": bool(updated.get("effect_committed", false)),
		"resources": (updated.get("resources", {}) as Dictionary).duplicate(true),
		"session": updated,
	}


func tracking_degrees_per_second(session: Dictionary) -> float:
	if bool(session.get("effect_committed", false)):
		return 0.0
	var art: Dictionary = session.get("art", {}) as Dictionary
	var frame := int(session.get("frame", 0))
	for segment_value: Variant in art.get("curva_seguimento", []):
		var segment: Dictionary = segment_value as Dictionary
		if frame <= int(segment.get("ate_frame", -1)):
			return float(segment.get("graus_por_segundo", 0.0))
	return 0.0


func _validate_contract(errors: Array[String], family_id: String, grip: String,
		contract: Dictionary, timing: Dictionary, permitted_vectors: Array) -> void:
	if timing.is_empty():
		errors.append("arte %s/%s aponta para perfil temporal inexistente" % [family_id, grip])
		return
	var commitment := int(timing.get("momento_compromisso_frame", -1))
	var active_start := int(timing.get("active_start_frame", -1))
	var active_end := int(timing.get("active_end_frame", -1))
	var recovery_end := int(timing.get("recovery_end_frame", -1))
	var curve: Array = timing.get("curva_seguimento", []) as Array
	if commitment <= 0 or active_start < commitment or active_end < active_start \
			or recovery_end < active_end or curve.is_empty():
		errors.append("arte %s/%s tem fases impossíveis" % [family_id, grip])
	else:
		var last_curve: Dictionary = curve[-1] as Dictionary
		if int(last_curve.get("ate_frame", -1)) != commitment \
				or float(last_curve.get("graus_por_segundo", -1.0)) != 0.0:
			errors.append("arte %s/%s segue depois do compromisso" % [family_id, grip])
	if not permitted_vectors.has(String(contract.get("vector_fuga", ""))):
		errors.append("arte %s/%s sem vector de fuga válido" % [family_id, grip])
	if String(contract.get("pergunta", "")) == "":
		errors.append("arte %s/%s sem pergunta da Lei 2" % [family_id, grip])
	var sound: Dictionary = contract.get("som_anuncio", {}) as Dictionary
	for field: String in ["cue_id", "descricao", "perfil", "alcance_m", "inicio_frame"]:
		if not sound.has(field) or str(sound.get(field, "")) == "":
			errors.append("arte %s/%s sem som.%s" % [family_id, grip, field])
	var visual: Dictionary = contract.get("sinal_visual_equivalente", {}) as Dictionary
	for field: String in ["ancora", "forma", "inicio", "compromisso", "fim", "fora_ecra"]:
		if String(visual.get(field, "")) == "":
			errors.append("arte %s/%s sem visual.%s" % [family_id, grip, field])


func _family_for(weapon_id: String) -> String:
	var weapon: Dictionary = (_equipment.get("weapons", {}) as Dictionary).get(
		weapon_id, {}) as Dictionary
	return String(weapon.get("familia", ""))


func _grip(two_handed: bool) -> String:
	return String(_arts.get("two_handed_grip", "")) if two_handed \
		else String(_arts.get("one_handed_grip", ""))


func _role_for(upgrade_state: Dictionary, grip: String) -> String:
	var role_id := String((_arts.get("base_roles", {}) as Dictionary).get(grip, ""))
	var selected: Dictionary = upgrade_state.get("choices", {}) as Dictionary
	var levels: Array = ((_weapons.get("_weapon_improvements", {}) as Dictionary).get(
		"levels", []) as Array)
	var current_level := mini(int(upgrade_state.get("level", 0)), levels.size() - 1)
	for level: int in range(1, current_level + 1):
		var choice_id := String(selected.get(str(level), selected.get(level, "")))
		var effect := _effect_for_choice(levels[level] as Dictionary, choice_id)
		var art_key := String(effect.get("art_key", ""))
		var art_slot := String(effect.get("art_slot", ""))
		if art_key == "":
			continue
		if art_slot == "both" or art_slot == grip:
			role_id = art_key
	return role_id


func _effect_for_choice(level_data: Dictionary, choice_id: String) -> Dictionary:
	if choice_id == "":
		return {}
	for option_value: Variant in level_data.get("options", []):
		var option: Dictionary = option_value as Dictionary
		if String(option.get("id", "")) == choice_id:
			return (option.get("effect", {}) as Dictionary).duplicate(true)
	return {}
