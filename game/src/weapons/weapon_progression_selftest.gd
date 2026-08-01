extends SceneTree
## Auto-teste dedicado do módulo de armas e melhorias.
##
## Correr da raiz do repositório:
## godot --headless --audio-driver Dummy --path game/ --script res://src/weapons/weapon_progression_selftest.gd

const WeaponProgression = preload("res://src/weapons/weapon_progression.gd")
const UpgradeMenu = preload("res://src/ui/upgrade_menu.gd")

var _passed := 0
var _failed := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var weapons := _read_json("res://data/weapons.json")
	var equipment := _read_json("res://data/equipment.json")
	var progression := WeaponProgression.new()
	var configured: bool = progression.configure(weapons, equipment)
	if not configured:
		printerr("ERROS DE CATÁLOGO: %s" % str(progression.validate()))
	_check(configured, "catálogo: dados de armas e equipamento são aceites")
	var catalogue: Dictionary = equipment.get("weapons", {}) as Dictionary
	_check(catalogue.size() == 120, "catálogo: a prova cobre as 120 armas")
	for weapon_id: String in catalogue:
		var profile: Dictionary = progression.profile(weapon_id)
		_check(not profile.is_empty(), "%s: tem perfil runtime" % weapon_id)
		_check(float(profile.get("peso", 0.0)) > 0.0,
			"%s: declara peso numérico positivo" % weapon_id)
		_check(bool(profile.get("qualquer_classe_equipa", false)),
			"%s: qualquer classe pode equipar" % weapon_id)
	_check(progression.has_method("equipped_weight"),
		"carga: o módulo expõe o peso combinado do equipamento")
	if progression.has_method("equipped_weight"):
		_check(is_equal_approx(float(progression.call(
			"equipped_weight", ["longsword", "shield"])), 6.5),
			"carga: espada longa + escudo contam 6,5 kg de jogo")
	_check(progression.has_method("moveset"),
		"moveset: o módulo expõe o verbo próprio de cada arma")
	if progression.has_method("moveset"):
		var signatures_by_family: Dictionary = {}
		for weapon_id: String in catalogue:
			var family_id := String((catalogue[weapon_id] as Dictionary).get("familia", "escudo"))
			if family_id == "escudo":
				continue
			var moveset: Dictionary = progression.call("moveset", weapon_id) as Dictionary
			_check(String(moveset.get("verbo", "")) != ""
				and String(moveset.get("compromisso", "")) != "",
				"%s: assinatura muda verbo e declara compromisso" % weapon_id)
			var signature := String(moveset.get("id", ""))
			var seen: Dictionary = signatures_by_family.get(family_id, {}) as Dictionary
			_check(not seen.has(signature),
				"%s: não repete a assinatura dentro da família %s" % [weapon_id, family_id])
			seen[signature] = true
			signatures_by_family[family_id] = seen
	_check(progression.has_method("new_upgrade_state")
		and progression.has_method("upgrade_choices")
		and progression.has_method("choose_upgrade"),
		"melhoria: o módulo expõe o voto reversível do altar")
	if progression.has_method("new_upgrade_state") \
			and progression.has_method("upgrade_choices") \
			and progression.has_method("choose_upgrade"):
		var upgrade_state: Dictionary = progression.call("new_upgrade_state") as Dictionary
		var base_damage := float(progression.profile("longsword", upgrade_state).get(
			"base_damage", 0.0))
		var expected_axes := ["postura", "arte_nova", "troca_escala",
			"conversao_elemental", "postura", "arte_nova"]
		for expected_axis: String in expected_axes:
			var choices: Array = progression.call(
				"upgrade_choices", "longsword", upgrade_state) as Array
			_check(not choices.is_empty()
				and String((choices[0] as Dictionary).get("axis", "")) == expected_axis,
				"melhoria +%d: abre %s" % [int(upgrade_state.get("level", 0)) + 1, expected_axis])
			if choices.is_empty():
				break
			var applied: Dictionary = progression.call(
				"choose_upgrade", "longsword", upgrade_state,
				String((choices[0] as Dictionary).get("id", ""))) as Dictionary
			_check(bool(applied.get("ok", false)),
				"melhoria +%d: escolha do altar é aplicável" % (int(upgrade_state.get("level", 0)) + 1))
			upgrade_state = applied.get("state", upgrade_state) as Dictionary
			_check(is_equal_approx(float(progression.profile(
				"longsword", upgrade_state).get("base_damage", 0.0)), base_damage),
				"melhoria +%d: nunca aumenta dano base" % int(upgrade_state.get("level", -1)))
		_check(int(upgrade_state.get("level", -1)) == 6,
			"melhoria: base + seis níveis chegam a +6")
		_check(progression.has_method("revert_upgrade"),
			"melhoria: o voto pode ser revertido no altar")
		if progression.has_method("revert_upgrade"):
			var reverted: Dictionary = progression.call(
				"revert_upgrade", upgrade_state, 2) as Dictionary
			_check(int(reverted.get("level", -1)) == 2
				and (reverted.get("choices", {}) as Dictionary).size() == 2,
				"melhoria: reverter para +2 remove apenas escolhas posteriores")
	_check(progression.has_method("weapon_art")
		and progression.has_method("perform_art"),
		"arte: o módulo expõe escolha por empunhadura e pagamento de mana")
	if progression.has_method("weapon_art") and progression.has_method("perform_art"):
		for family_id: String in (equipment.get("family_movesets", {}) as Dictionary):
			var sample_id := ""
			for weapon_id: String in catalogue:
				if String((catalogue[weapon_id] as Dictionary).get("familia", "")) == family_id:
					sample_id = weapon_id
					break
			var one_hand: Dictionary = progression.call(
				"weapon_art", sample_id, {}, false) as Dictionary
			var two_hands: Dictionary = progression.call(
				"weapon_art", sample_id, {}, true) as Dictionary
			_check(String(one_hand.get("nome", "")) != String(two_hands.get("nome", ""))
				and String(one_hand.get("verbo", "")) != String(two_hands.get("verbo", "")),
				"arte/%s: uma e duas mãos são verbos diferentes" % family_id)
			for art: Dictionary in [one_hand, two_hands]:
				_check(int(art.get("mana_cost", 0)) > 0
					and String(art.get("compromisso", "")) != ""
					and String(art.get("input_action", "")) == "weapon_art",
					"arte/%s: custo, compromisso e acção estão declarados" % family_id)
		var selected_art: Dictionary = progression.call(
			"weapon_art", "longsword", {}, false) as Dictionary
		var cost := int(selected_art.get("mana_cost", 0))
		var refused: Dictionary = progression.call(
			"perform_art", "longsword", {}, false, cost - 1) as Dictionary
		var paid: Dictionary = progression.call(
			"perform_art", "longsword", {}, false, cost) as Dictionary
		_check(not bool(refused.get("ok", true)) and int(refused.get("mana_after", -1)) == cost - 1,
			"arte: mana insuficiente não executa nem cobra")
		_check(bool(paid.get("ok", false)) and int(paid.get("mana_after", -1)) == 0,
			"arte: mana suficiente paga exactamente o custo declarado")
		var art_state: Dictionary = progression.call("new_upgrade_state") as Dictionary
		var posture_choices: Array = progression.call(
			"upgrade_choices", "longsword", art_state) as Array
		art_state = (progression.call(
			"choose_upgrade", "longsword", art_state,
			String((posture_choices[0] as Dictionary).get("id", ""))) as Dictionary).get(
				"state", art_state) as Dictionary
		var art_choices: Array = progression.call(
			"upgrade_choices", "longsword", art_state) as Array
		var one_hand_choice := ""
		for choice: Dictionary in art_choices:
			if String(choice.get("id", "")) == "trocar_arte_1mao":
				one_hand_choice = "trocar_arte_1mao"
				break
		var upgraded_one_result: Dictionary = progression.call(
			"choose_upgrade", "longsword", art_state, one_hand_choice) as Dictionary
		art_state = upgraded_one_result.get("state", art_state) as Dictionary
		var upgraded_one: Dictionary = progression.call(
			"weapon_art", "longsword", art_state, false) as Dictionary
		var unchanged_two: Dictionary = progression.call(
			"weapon_art", "longsword", art_state, true) as Dictionary
		_check(one_hand_choice != "" and String(upgraded_one.get("nome", "")) \
				!= String(selected_art.get("nome", "")),
			"arte +2: o voto de uma mão troca mesmo o verbo dessa empunhadura")
		var base_two: Dictionary = progression.call(
			"weapon_art", "longsword", {}, true) as Dictionary
		_check(String(unchanged_two.get("nome", "")) == String(base_two.get("nome", "")),
			"arte +2: trocar uma mão preserva a arte de duas mãos")
		while int(art_state.get("level", 0)) < 6:
			var next_choices: Array = progression.call(
				"upgrade_choices", "longsword", art_state) as Array
			if next_choices.is_empty():
				break
			art_state = (progression.call(
				"choose_upgrade", "longsword", art_state,
				String((next_choices[0] as Dictionary).get("id", ""))) as Dictionary).get(
					"state", art_state) as Dictionary
		var master_one: Dictionary = progression.call(
			"weapon_art", "longsword", art_state, false) as Dictionary
		var master_two: Dictionary = progression.call(
			"weapon_art", "longsword", art_state, true) as Dictionary
		_check(int(art_state.get("level", 0)) == 6
			and String(master_one.get("nome", "")) == String(master_two.get("nome", "")),
			"arte +6: a técnica mestra ocupa as duas artes como compromisso")
		var reverse_choices: Dictionary = {}
		for level: int in range(6, 0, -1):
			reverse_choices[str(level)] = (art_state.get("choices", {}) as Dictionary).get(
				str(level), "")
		var reverse_state := {"level": 6, "choices": reverse_choices}
		var reverse_profile: Dictionary = progression.profile("longsword", reverse_state)
		var reverse_art: Dictionary = progression.call(
			"weapon_art", "longsword", reverse_state, false) as Dictionary
		_check(String(reverse_profile.get("postura", "")) == "estreita"
			and String(reverse_art.get("nome", "")) == String(master_one.get("nome", "")),
			"melhoria: níveis superiores prevalecem mesmo se o save reordenar as chaves")
	var menu := UpgradeMenu.new()
	root.add_child(menu)
	var menu_setup_ok := menu.setup(weapons, equipment, "longsword", {})
	_check(menu_setup_ok,
		"altar: abre a arma equipada através de interact")
	var menu_choices: Array = menu.visible_choices()
	_check(menu_choices.size() == 2,
		"altar: +1 mostra as duas posturas e não um botão de dano")
	if not menu_choices.is_empty():
		var choice_id := String((menu_choices[0] as Dictionary).get("id", ""))
		var material: Dictionary = (menu_choices[0] as Dictionary).get("material", {}) as Dictionary
		var material_id := String(material.get("item_id", ""))
		var blocked: Dictionary = menu.select_choice(choice_id, {})
		var applied: Dictionary = menu.select_choice(choice_id, {material_id: 1})
		_check(not bool(blocked.get("ok", true)),
			"altar: não promete melhoria sem o material declarado")
		_check(bool(applied.get("ok", false)) and int(menu.upgrade_state().get("level", -1)) == 1,
			"altar: a escolha consome a fronteira e abre a postura")
		_check(menu.revert_to(0) and int(menu.upgrade_state().get("level", -1)) == 0,
			"altar: o voto é reversível no mesmo ecrã")
	menu.queue_free()
	_measure_ui_cost(weapons, equipment)
	_measure_module_cost(progression, catalogue)
	_report()


func _read_json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _check(condition: bool, label: String) -> void:
	if condition:
		_passed += 1
	else:
		_failed += 1
		printerr("FALHOU: %s" % label)


func _measure_module_cost(progression: RefCounted, catalogue: Dictionary) -> void:
	for _warmup: int in range(5):
		for weapon_id: String in catalogue:
			progression.call("profile", weapon_id)
			progression.call("moveset", weapon_id)
	var samples: Array[float] = []
	var calls_per_sample := 0
	for _sample: int in range(5):
		var calls := 0
		var started_usec := Time.get_ticks_usec()
		for _iteration: int in range(20):
			for weapon_id: String in catalogue:
				progression.call("profile", weapon_id)
				progression.call("moveset", weapon_id)
				calls += 2
		var elapsed_usec := Time.get_ticks_usec() - started_usec
		calls_per_sample = calls
		samples.append(float(elapsed_usec) / float(calls))
	samples.sort()
	print("=== CUSTO ARMAS: %d chamadas/amostra · %.2f us mediana (%.2f–%.2f) ===" % [
		calls_per_sample,
		samples[2],
		samples.front(),
		samples.back(),
	])


func _measure_ui_cost(weapons: Dictionary, equipment: Dictionary) -> void:
	var samples: Array[float] = []
	for iteration: int in range(9):
		var started_usec := Time.get_ticks_usec()
		var probe := UpgradeMenu.new()
		var configured := probe.setup(weapons, equipment, "longsword", {})
		var elapsed_ms := float(Time.get_ticks_usec() - started_usec) / 1000.0
		probe.free()
		if configured and iteration >= 2:
			samples.append(elapsed_ms)
	samples.sort()
	print("=== CUSTO ALTAR: %.3f ms mediana para construir/configurar (%.3f–%.3f) ===" % [
		samples[3],
		samples.front(),
		samples.back(),
	])


func _report() -> void:
	print("=== ARMAS: %d passaram, %d falharam ===" % [_passed, _failed])
	quit(0 if _failed == 0 else 1)
