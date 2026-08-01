extends SceneTree
## Prova dedicada das artes de arma e dos movesets por família.
##
## Correr da raiz:
## godot --headless --audio-driver Dummy --path game/ \
##   --script res://src/weapons/weapon_art_selftest.gd

const WeaponArtSystem = preload("res://src/weapons/weapon_art_system.gd")

var _passed := 0
var _failed := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var weapons := _read_json("res://data/weapons.json")
	var equipment := _read_json("res://data/equipment.json")
	var system := WeaponArtSystem.new()
	var configured: bool = system.configure(weapons, equipment)
	_check(configured, "catálogo: artes e movesets formam um contrato válido")
	if not configured:
		for error: String in system.validate():
			printerr("ERRO DE CATÁLOGO: %s" % error)
		_report()
		return
	_test_catalogue_contract(system, weapons, equipment)
	_test_resource_and_commitment(system, equipment)
	_test_upgrade_options(system, weapons, equipment)
	_measure_cost(system, weapons, equipment)
	_report()


func _test_catalogue_contract(system: RefCounted, weapons: Dictionary,
		equipment: Dictionary) -> void:
	var catalogue: Dictionary = equipment.get("weapons", {}) as Dictionary
	var permitted_vectors: Array = (weapons.get("_artes", {}) as Dictionary).get(
		"vectores_fuga_permitidos", []) as Array
	var definitions: Dictionary = {}
	var main_weapon_count := 0
	for weapon_id: String in catalogue:
		var family_id := String((catalogue[weapon_id] as Dictionary).get("familia", ""))
		if family_id == "":
			continue
		main_weapon_count += 1
		var one_hand: Dictionary = system.art_for(weapon_id, {}, false)
		var two_hands: Dictionary = system.art_for(weapon_id, {}, true)
		_check(not one_hand.is_empty() and not two_hands.is_empty(),
			"%s: resolve arte nas duas empunhaduras" % weapon_id)
		_check(String(one_hand.get("definition_id", "")) \
				!= String(two_hands.get("definition_id", ""))
				and String(one_hand.get("verbo", "")) != String(two_hands.get("verbo", "")),
			"%s: uma e duas mãos oferecem verbos diferentes" % weapon_id)
		for art: Dictionary in [one_hand, two_hands]:
			definitions[String(art.get("definition_id", ""))] = true
			_check(_has_honesty_contract(art, permitted_vectors),
				"%s/%s: compromisso, seguimento, fuga, som e visual completos" % [
					weapon_id, art.get("grip", "")])
			_check(String(art.get("pergunta", "")) != ""
					and String(art.get("tradeoff", "")) != ""
					and String(art.get("verbo", "")).to_lower().find("mais dano") < 0,
				"%s/%s: Lei 2 dá opção e custo, não só dano" % [
					weapon_id, art.get("grip", "")])
		var one_moveset: Dictionary = system.moveset_for(weapon_id, {}, false)
		var two_moveset: Dictionary = system.moveset_for(weapon_id, {}, true)
		_check(String(one_moveset.get("family", "")) == family_id
				and String(two_moveset.get("family", "")) == family_id
				and String(one_moveset.get("grip", "")) != String(two_moveset.get("grip", "")),
			"%s: herda moveset da família e a empunhadura muda-o" % weapon_id)
	var exceptions: Dictionary = (weapons.get("_artes", {}) as Dictionary).get(
		"excepcoes_por_arma", {}) as Dictionary
	_check(main_weapon_count > 0 and definitions.size() < main_weapon_count * 2,
		"partilha: definições de arte são reutilizadas entre armas")
	_check(not exceptions.is_empty() and exceptions.size() < main_weapon_count,
		"partilha: poucas armas excepcionais substituem a regra da família")


func _test_resource_and_commitment(system: RefCounted, equipment: Dictionary) -> void:
	var weapon_id := _first_main_weapon(equipment)
	var art: Dictionary = system.art_for(weapon_id, {}, false)
	var cost := int(art.get("mana_cost", 0))
	var resources := {"mana": cost, "stamina": cost}
	var refused: Dictionary = system.begin(
		weapon_id, {}, false, {"mana": cost - 1, "stamina": cost}, "LIVRE")
	var started: Dictionary = system.begin(weapon_id, {}, false, resources, "LIVRE")
	_check(not bool(refused.get("ok", true))
			and int((refused.get("resources", {}) as Dictionary).get("mana", -1)) == cost - 1,
		"recurso: mana insuficiente recusa antes de entrar e não cobra")
	_check(bool(started.get("ok", false))
			and int((started.get("resources", {}) as Dictionary).get("mana", -1)) == 0
			and int((started.get("resources", {}) as Dictionary).get("stamina", -1)) == cost,
		"recurso: arte cobra mana e conserva stamina")
	var busy: Dictionary = system.begin(weapon_id, {}, false, resources, "ATTACK")
	_check(not bool(busy.get("ok", true)),
		"estado: arte só começa em LIVRE e não cancela outra acção")
	var session: Dictionary = started.get("session", {}) as Dictionary
	var cancel_result: Dictionary = system.request_cancel(session)
	_check(not bool(cancel_result.get("cancelled", true))
			and String((cancel_result.get("session", {}) as Dictionary).get("phase", "")) == "startup",
		"compromisso: não há cancelamento voluntário no arranque")
	var interrupted: Dictionary = system.try_interrupt(session, true)
	_check(bool(interrupted.get("interrupted", false))
			and int((interrupted.get("resources", {}) as Dictionary).get("mana", -1)) == 0,
		"compromisso: postura partida antes do compromisso interrompe sem devolver mana")
	var at_commit: Dictionary = system.advance(
		session, int(art.get("momento_compromisso_frame", 0)))
	var late_interrupt: Dictionary = system.try_interrupt(at_commit, true)
	_check(not bool(late_interrupt.get("interrupted", true))
			and bool((late_interrupt.get("session", {}) as Dictionary).get("effect_committed", false))
			and int((late_interrupt.get("session", {}) as Dictionary).get("effect_emissions", 0)) == 1,
		"compromisso: no frame declarado o efeito resolve uma vez e já não é retirado")
	var late_cancel: Dictionary = system.request_cancel(
		late_interrupt.get("session", {}) as Dictionary)
	_check(not bool(late_cancel.get("cancelled", true)),
		"compromisso: também não há cancelamento voluntário depois do compromisso")


func _test_upgrade_options(system: RefCounted, weapons: Dictionary,
		equipment: Dictionary) -> void:
	var weapon_id := _first_main_weapon(equipment)
	var levels: Array = ((weapons.get("_weapon_improvements", {}) as Dictionary).get(
		"levels", []) as Array)
	var one_hand_choice := _choice_for_slot(levels, "one_hand")
	var choices := {"1": _first_choice_id(levels, 1), "2": one_hand_choice}
	var art_state := {"level": 2, "choices": choices}
	var base_one: Dictionary = system.art_for(weapon_id, {}, false)
	var base_two: Dictionary = system.art_for(weapon_id, {}, true)
	var upgraded_one: Dictionary = system.art_for(weapon_id, art_state, false)
	var unchanged_two: Dictionary = system.art_for(weapon_id, art_state, true)
	_check(String(upgraded_one.get("definition_id", "")) \
			!= String(base_one.get("definition_id", ""))
			and String(unchanged_two.get("definition_id", "")) \
			== String(base_two.get("definition_id", "")),
		"melhoria +2: troca uma arte sem apagar a outra empunhadura")
	var master_choices: Dictionary = {}
	for level: int in range(1, levels.size()):
		master_choices[str(level)] = _first_choice_id(levels, level)
	var master_state := {"level": levels.size() - 1, "choices": master_choices}
	var master_one: Dictionary = system.art_for(weapon_id, master_state, false)
	var master_two: Dictionary = system.art_for(weapon_id, master_state, true)
	_check(String(master_one.get("definition_id", "")) \
			== String(master_two.get("definition_id", "")),
		"melhoria +6: arte mestra ocupa as duas empunhaduras")
	var posture_state := {"level": 1, "choices": {"1": _first_choice_id(levels, 1)}}
	var base_moveset: Dictionary = system.moveset_for(weapon_id, {}, false)
	var posture_moveset: Dictionary = system.moveset_for(weapon_id, posture_state, false)
	_check(String(base_moveset.get("posture", "")) \
			!= String(posture_moveset.get("posture", ""))
			and (posture_moveset.get("moves", []) as Array).size() \
				> (base_moveset.get("moves", []) as Array).size(),
		"melhoria +1: postura abre um movimento em vez de aumentar dano")


func _measure_cost(system: RefCounted, weapons: Dictionary, equipment: Dictionary) -> void:
	var budget: Dictionary = (weapons.get("_artes", {}) as Dictionary).get(
		"orcamento_runtime", {}) as Dictionary
	var iterations := int(budget.get("benchmark_iterations", 0))
	var catalogue: Dictionary = equipment.get("weapons", {}) as Dictionary
	var weapon_ids: Array[String] = []
	for weapon_id: String in catalogue:
		if String((catalogue[weapon_id] as Dictionary).get("familia", "")) != "":
			weapon_ids.append(weapon_id)
	var samples: Array[float] = []
	for _warmup: int in range(iterations):
		for weapon_id: String in weapon_ids:
			system.art_for(weapon_id, {}, false)
	for _sample: int in range(iterations):
		var started_usec := Time.get_ticks_usec()
		for weapon_id: String in weapon_ids:
			system.art_for(weapon_id, {}, false)
			system.art_for(weapon_id, {}, true)
			system.moveset_for(weapon_id, {}, false)
		var elapsed_usec := Time.get_ticks_usec() - started_usec
		samples.append(float(elapsed_usec) / float(weapon_ids.size() * 3))
	samples.sort()
	var p95_index := clampi(ceili(float(samples.size()) * 0.95) - 1, 0, samples.size() - 1)
	var p95_usec := samples[p95_index]
	var catalogue_bytes := JSON.stringify({
		"artes": weapons.get("_artes", {}),
		"movesets": weapons.get("_movesets", {}),
	}).to_utf8_buffer().size()
	_check(iterations > 0 and p95_usec <= float(budget.get("resolve_p95_usec_max", 0)),
		"Lei 4: resolução p95 cabe no orçamento JSON")
	_check(catalogue_bytes <= int(budget.get("catalogue_utf8_bytes_max", 0)),
		"Lei 4: catálogo serializado cabe no orçamento JSON")
	print("=== CUSTO ARTES: %d armas · %.3f us p95/resolução · %d B catálogo · GPU=%s ===" % [
		weapon_ids.size(), p95_usec, catalogue_bytes,
		RenderingServer.get_video_adapter_name()])


func _has_honesty_contract(art: Dictionary, permitted_vectors: Array) -> bool:
	var commitment := int(art.get("momento_compromisso_frame", -1))
	var active_start := int(art.get("active_start_frame", -1))
	var active_end := int(art.get("active_end_frame", -1))
	var recovery_end := int(art.get("recovery_end_frame", -1))
	var curve: Array = art.get("curva_seguimento", []) as Array
	var sound: Dictionary = art.get("som_anuncio", {}) as Dictionary
	var visual: Dictionary = art.get("sinal_visual_equivalente", {}) as Dictionary
	if commitment <= 0 or active_start < commitment or active_end < active_start \
			or recovery_end < active_end or curve.is_empty():
		return false
	var last_curve: Dictionary = curve[-1] as Dictionary
	if int(last_curve.get("ate_frame", -1)) != commitment \
			or float(last_curve.get("graus_por_segundo", -1.0)) != 0.0:
		return false
	if not permitted_vectors.has(String(art.get("vector_fuga", ""))):
		return false
	for field: String in ["cue_id", "descricao", "perfil", "alcance_m", "inicio_frame"]:
		if not sound.has(field) or str(sound.get(field, "")) == "":
			return false
	for field: String in ["ancora", "forma", "inicio", "compromisso", "fim", "fora_ecra"]:
		if String(visual.get(field, "")) == "":
			return false
	return true


func _first_main_weapon(equipment: Dictionary) -> String:
	for weapon_id: String in (equipment.get("weapons", {}) as Dictionary):
		if String(((equipment.get("weapons", {}) as Dictionary)[weapon_id] as Dictionary).get(
				"familia", "")) != "":
			return weapon_id
	return ""


func _first_choice_id(levels: Array, level: int) -> String:
	var options: Array = (levels[level] as Dictionary).get("options", []) as Array
	return String((options[0] as Dictionary).get("id", "")) if not options.is_empty() else ""


func _choice_for_slot(levels: Array, slot: String) -> String:
	for level_value: Variant in levels:
		for option_value: Variant in (level_value as Dictionary).get("options", []):
			var option: Dictionary = option_value as Dictionary
			if String((option.get("effect", {}) as Dictionary).get("art_slot", "")) == slot:
				return String(option.get("id", ""))
	return ""


func _read_json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _check(condition: bool, label: String) -> void:
	if condition:
		_passed += 1
	else:
		_failed += 1
		printerr("FALHOU: %s" % label)


func _report() -> void:
	print("=== ARTES DE ARMA: %d passaram, %d falharam ===" % [_passed, _failed])
	quit(0 if _failed == 0 else 1)
