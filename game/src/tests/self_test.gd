extends Node
## Auto-teste: verifica que o COMPORTAMENTO bate certo com a spec, nao so os dados.
##
## O GameData ja valida os dados no arranque. Isto e outra coisa: pega na maquina
## de estados e conta os frames um a um, para provar que a janela de i-frames abre
## mesmo no frame 5 e fecha mesmo no 23 — e nao "por volta de".
##
## Correr:  godot --path . --headless res://scenes/selftest.tscn
## Sai com codigo 1 se alguma verificacao falhar.

var _passed := 0
var _failed := 0

const GameplayCueRenderer = preload("res://src/combat/gameplay_cue.gd")


func _ready() -> void:
	print("\n=== AUTO-TESTE CONTRA A SPEC ===\n")
	_test_dodge_iframes()
	_test_parry_window()
	_test_task4_combat_closures()
	_test_progression_closures()
	_test_named_encounters()
	_test_economy_and_loot_transaction()
	_test_integration_closures()
	_test_weapon_frames()
	_test_stamina()
	_test_damage_worked_example()
	_test_time_to_kill()
	_test_enemy_contract()
	_test_bestiary_catalogue()
	_test_bestiary_runtime()
	_test_movement_speeds()
	_test_spell_catalogue()
	_test_feel()
	_test_biomes()
	_test_races()
	_test_families_and_kits()
	_test_equipment_catalogue()
	_test_world_catalogue()
	_test_save_round_trip()
	_test_atomic_save()
	_test_corrupt_save_recovery()
	_test_save_migration()
	_report()


# --- spec/59-saves.md · persistencia -----------------------------------------

# --- spec/71-72: nomeados, economia e compra atomica de espolio --------------

func _test_named_encounters() -> void:
	var encounters: Dictionary = GameData.named_catalog.get("encounters", {}) as Dictionary
	_check(encounters.size() == 36, "nomeados: 36 fichas fechadas")
	var by_zone: Dictionary = {}
	for named_id: String in encounters.keys():
		var encounter: Dictionary = GameData.named_encounter(named_id)
		var zone_id := String(encounter.get("zone_id", ""))
		by_zone[zone_id] = int(by_zone.get(zone_id, 0)) + 1
		_check(not GameData.enemy(String(encounter.get("base_enemy_id", ""))).is_empty(),
			"nomeado %s reutiliza ficha comum" % named_id)
		var extra: Dictionary = encounter.get("extra_attack", {}) as Dictionary
		_check(int(extra.get("startup", 0)) >= 30 and int(extra.get("active", 0)) > 0
			and int(extra.get("recovery", 0)) > 0,
			"nomeado %s tem um ataque extra mensuravel" % named_id)
		_check(String(encounter.get("guaranteed_loot", "")).contains(":"),
			"nomeado %s declara espolio garantido" % named_id)
	for zone_id: String in (GameData.world.get("zones", {}) as Dictionary).keys():
		_check(int(by_zone.get(zone_id, 0)) == 3, "%s: exactamente 3 nomeados" % zone_id)


func _test_economy_and_loot_transaction() -> void:
	var materials: Dictionary = GameData.economy.get("materials", {}) as Dictionary
	var consumables: Dictionary = GameData.economy.get("consumables", {}) as Dictionary
	_check(materials.size() == 40, "economia: os 40 materiais prometidos existem")
	_check(consumables.size() == 15,
		"economia: 15 consumiveis canonicos depois de corrigir Brasa e duplicado acentuado")
	_check(GameData.consumable("véu_sombra") == GameData.consumable("veu_sombra"),
		"economia: grafia antiga de veu_sombra migra para o ID canonico")
	_check(GameData.consumable("brasa_portatil").is_empty(),
		"economia: Brasa unica nao volta como consumivel de baralho")
	_check(GameData.level_cost(20) == 2601 and GameData.level_cost(40) == 9505
		and GameData.level_cost(70) == 28351 and GameData.level_cost(100) == 60265,
		"economia: curva cubica publica os quatro marcos exactos")
	_check(GameData.resolve_loot_card("orc_spearman", "bias:classe", "warrior")
		== "material:couro_javali", "bias: carta marcial resolve por zona")
	_check(GameData.resolve_loot_card("orc_spearman", "bias:classe", "sorcerer")
		== "material:limalha_ferro", "bias: carta arcana resolve por zona")

	var state := SaveSystem.create_save("loot-transaction", "warrior")
	var seed_value := 7204
	var order := GameData.loot_draw_order("orc_spearman", seed_value)
	var first := GameData.reward_enemy_defeat(
		state, "orc_spearman", "defeat-000", seed_value, "warrior")
	_check(String(first.get("status", "")) == "awarded"
		and String(first.get("raw_card", "")) == String(order[0]),
		"espolio: derrota compra a proxima carta da ordem reproduzivel")
	var world_state: Dictionary = state.get("world", {}) as Dictionary
	var character: Dictionary = state.get("character", {}) as Dictionary
	var held_after_first := int((character.get("progression", {}) as Dictionary).get("souls_held", 0))
	var repeated := GameData.reward_enemy_defeat(
		state, "orc_spearman", "defeat-000", seed_value, "warrior")
	_check(String(repeated.get("status", "")) == "already_committed"
		and int((character.get("progression", {}) as Dictionary).get("souls_held", 0)) == held_after_first,
		"espolio: repetir event_id nao paga almas nem carta duas vezes")
	_check((world_state.get("reward_receipts", []) as Array).size() == 1
		and int(((world_state.get("loot_decks", {}) as Dictionary).get(
			"orc_spearman", {}) as Dictionary).get("next_index", 0)) == 1,
		"espolio: recibo e indice avancam juntos")
	for draw_index: int in range(1, 10):
		GameData.reward_enemy_defeat(state, "orc_spearman", "defeat-%03d" % draw_index,
			seed_value, "warrior")
	var exhausted := GameData.reward_enemy_defeat(
		state, "orc_spearman", "defeat-010", seed_value, "warrior")
	_check(String(exhausted.get("status", "")) == "exhausted"
		and ((state.get("world", {}) as Dictionary).get("reward_receipts", []) as Array).size() == 10,
		"espolio: dez cartas fecham a torneira sem uma 11.a recompensa")

	var slot := 97
	var path := SaveSystem.slot_path(slot)
	_remove_save_artifacts(path)
	GameData.replace_save_state(SaveSystem.create_save("loot-atomic", "sorcerer"))
	var committed := SaveSystem.commit_enemy_defeat(
		"goblin_mist_scout", "atomic-001", 72, "sorcerer", slot)
	var persisted := SaveSystem.load_from_path(path, false)
	var persisted_world: Dictionary = persisted.get("world", {}) as Dictionary
	_check(String(committed.get("status", "")) == "awarded"
		and (persisted_world.get("reward_receipts", []) as Array).size() == 1,
		"espolio atomico: recibo publicado na mesma geracao do save")
	_check(int(((persisted_world.get("loot_decks", {}) as Dictionary).get(
		"goblin_mist_scout", {}) as Dictionary).get("next_index", 0)) == 1,
		"espolio atomico: indice persistido com o recibo")
	_remove_save_artifacts(path)


# --- spec/73: fronteiras assumidas passam a contratos executáveis -----------

func _test_integration_closures() -> void:
	var spell_rule: Dictionary = (GameData.enemies.get("_rules", {}) as Dictionary).get(
		"enemy_spellcasting", {}) as Dictionary
	_check((spell_rule.get("shares_with_player", []) as Array).has("interrupcao")
		and (spell_rule.get("does_not_share", []) as Array).has("mana_do_jogador"),
		"integração: magia inimiga partilha honestidade, não mana do jogador")

	var traversal: Dictionary = GameData.world.get("_traversal_rules", {}) as Dictionary
	_check(not bool(traversal.get("free_swimming", true))
		and not bool(traversal.get("free_climbing", true))
		and not bool(traversal.get("free_traversal_jump", true)),
		"integração: mundo não exige nadar, escalar ou salto livre")
	_check(is_equal_approx(float(traversal.get("automatic_step_max_m", 0.0)), 0.45)
		and String(traversal.get("weapon_move_a_saltar", "")).contains("não é verbo"),
		"integração: passo de 0,45 m e golpe a saltar não criam travessia")
	var subboss: Dictionary = GameData.world.get("_subboss_rules", {}) as Dictionary
	_check(String(subboss.get("on_flee", "")).contains("descanso")
		and String(subboss.get("on_defeat", "")).contains("ciclo"),
		"integração: fugir e vencer um subchefe persistem de forma diferente")

	_check(GameData.ui_text("hud.help").begins_with("COMANDOS")
		and GameData.ui_text("toast.death") == "Morreste. A voltar...",
		"integração: HUD e mensagens vivem no catálogo português")
	_check(GameData.ui_text("id.inexistente", "fallback") == "fallback",
		"integração: lookup de texto tem fallback explícito")
	var remote_heal := GameData.spell("elo_curador")
	var heal_effect: Dictionary = remote_heal.get("effect", {}) as Dictionary
	var heal_network: Dictionary = remote_heal.get("network_contract", {}) as Dictionary
	_check(is_equal_approx(float(heal_effect.get("heal_target_max_health_fraction", 0.0)), 0.30)
		and not bool(heal_effect.get("can_resurrect", true)),
		"integração: Elo Curador cura 30% e nunca ressuscita")
	_check(String(heal_network.get("channel", "")) == "reliable_ordered_gameplay"
		and String(heal_network.get("deduplication", "")).contains("cast_id"),
		"integração: cura remota é fiável, ordenada e idempotente")

	var actions: Dictionary = GameData.controls.get("actions", {}) as Dictionary
	for action_value: Variant in GameData.controls.get("gamepad_required", []):
		var action_id := String(action_value)
		var declared_gamepad := false
		for binding_value: Variant in actions.get(action_id, []):
			declared_gamepad = declared_gamepad or String((binding_value as Dictionary).get(
				"type", "")).begins_with("joypad_")
		var built_gamepad := false
		for event: InputEvent in InputMap.action_get_events(action_id):
			built_gamepad = built_gamepad or event is InputEventJoypadButton \
				or event is InputEventJoypadMotion
		_check(declared_gamepad and built_gamepad,
			"comando: acção nuclear '%s' declara e constrói ligação" % action_id)


# --- spec/59-saves.md: persistencia ------------------------------------------

func _test_save_round_trip() -> void:
	var path := "user://worldrpgs-self-test/round-trip.json"
	_remove_save_artifacts(path)
	var state := SaveSystem.create_save("self-test", "warrior")
	var character: Dictionary = state.get("character", {}) as Dictionary
	var progression: Dictionary = character.get("progression", {}) as Dictionary
	progression["level"] = 7
	progression["souls_held"] = 4321
	var inventory: Dictionary = character.get("inventory", {}) as Dictionary
	inventory["items"] = {"longsword": 1, "frasco_bruma": 3}

	_check(SaveSystem.save_to_path(path, state), "save: round-trip grava")
	var loaded := SaveSystem.load_from_path(path)
	var expected: Variant = JSON.parse_string(JSON.stringify(state, "", true))
	_check(loaded == expected,
		"save: round-trip preserva todo o estado")
	_check(GameData.save_state_snapshot() == loaded,
		"save: estado carregado fica ligado ao GameData")
	var bytes := FileAccess.get_file_as_bytes(path).size()
	_check(bytes < 64 * 1024, "save: fixture da fatia 1 ocupa %d B (< 64 KiB)" % bytes)
	_remove_save_artifacts(path)


func _test_atomic_save() -> void:
	var path := "user://worldrpgs-self-test/atomic.json"
	_remove_save_artifacts(path)
	var first := SaveSystem.create_save("first", "warrior")
	_check(SaveSystem.save_to_path(path, first), "save atomico: primeira geracao confirmada")

	# Simula energia cortada enquanto so o temporario estava a ser escrito.
	var interrupted := FileAccess.open(path + ".tmp", FileAccess.WRITE)
	interrupted.store_string("{\"format_version\":")
	interrupted.flush()
	interrupted.close()
	var after_interruption := SaveSystem.load_from_path(path, false)
	_check(String((after_interruption.get("character", {}) as Dictionary).get("profile_id", "")) == "first",
		"save atomico: temporario incompleto nao substitui o confirmado")

	var second := SaveSystem.create_save("second", "sorcerer")
	_check(SaveSystem.save_to_path(path, second), "save atomico: segunda geracao confirmada")
	var current := SaveSystem.load_from_path(path, false)
	_check(String((current.get("character", {}) as Dictionary).get("profile_id", "")) == "second",
		"save atomico: rename publica a geracao nova")
	_check(FileAccess.file_exists(path + ".bak"),
		"save atomico: geracao anterior fica no backup")
	if FileAccess.file_exists(path + ".bak"):
		var backup := SaveSystem.load_from_path(path + ".bak", false)
		_check(String((backup.get("character", {}) as Dictionary).get("profile_id", "")) == "first",
			"save atomico: backup conserva a geracao anterior inteira")
	_check(not FileAccess.file_exists(path + ".tmp"),
		"save atomico: temporario desaparece depois do commit")
	_remove_save_artifacts(path)


func _test_corrupt_save_recovery() -> void:
	var path := "user://worldrpgs-self-test/corrupt.json"
	_remove_save_artifacts(path)
	var first := SaveSystem.create_save("recover-me", "warrior")
	var second := SaveSystem.create_save("broken-newer", "sorcerer")
	SaveSystem.save_to_path(path, first)
	SaveSystem.save_to_path(path, second)

	var tampered: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(path)) as Dictionary
	(tampered.get("character", {}) as Dictionary)["profile_id"] = "alterado-sem-checksum"
	var broken := FileAccess.open(path, FileAccess.WRITE)
	broken.store_string(JSON.stringify(tampered, "\t", true))
	broken.flush()
	broken.close()
	var recovered := SaveSystem.load_from_path(path)
	var recovery_was_reported := SaveSystem.last_load_recovered
	_check(String((recovered.get("character", {}) as Dictionary).get("profile_id", "")) == "recover-me",
		"save corrompido: recupera a ultima geracao integra")
	_check(recovery_was_reported, "save corrompido: recuperacao fica sinalizada")
	_check(FileAccess.file_exists(path + ".corrupt"),
		"save corrompido: ficheiro partido fica preservado")
	var restored := SaveSystem.load_from_path(path, false)
	_check(String((restored.get("character", {}) as Dictionary).get("profile_id", "")) == "recover-me",
		"save corrompido: backup recuperado volta a ser o activo")
	_remove_save_artifacts(path)


func _test_save_migration() -> void:
	var path := "user://worldrpgs-self-test/migration.json"
	_remove_save_artifacts(path)
	var legacy := {
		"player": {
			"profile_id": "legacy",
			"identity": {"class_id": "tank"},
			"progression": {"level": 9, "souls_held": 77},
		},
		"world": {"owner_profile_id": "legacy", "bosses_defeated": ["vorgar"]},
	}
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(legacy, "\t", true))
	file.close()

	var migrated := SaveSystem.load_from_path(path, false)
	_check(SaveSystem.last_load_migrated, "save: versao antiga passa pela migracao")
	_check(int(migrated.get("format_version", 0)) == SaveSystem.CURRENT_FORMAT_VERSION,
		"save: migracao sobe para a versao actual")
	var character: Dictionary = migrated.get("character", {}) as Dictionary
	_check(int((character.get("progression", {}) as Dictionary).get("level", 0)) == 9,
		"save: migracao preserva progresso antigo")
	_check(typeof(character.get("inventory")) == TYPE_DICTIONARY
		and typeof((migrated.get("world", {}) as Dictionary).get("map")) == TYPE_DICTIONARY,
		"save: migracao acrescenta campos novos com defaults")
	_remove_save_artifacts(path)


# --- spec/51-familias.md (volta 3) · familias, escudos, armadura e kits -------

func _test_families_and_kits() -> void:
	var fams: Dictionary = GameData.weapons.get("familias", {}) as Dictionary
	var ids: Array[String] = []
	for f: String in fams.keys():
		if not f.begins_with("_"):
			ids.append(f)
	_check(ids.size() == 8, "8 familias de arma (spec/51 §2)")

	# A regra do 41 §2 — toda a familia diz onde e MA.
	for id in ids:
		_check(String((fams[id] as Dictionary).get("onde_ma", "")).length() > 20,
			"familia '%s' diz onde e ma" % id)

	# Contra-ataque so existe em perfuracao; haste e estocada da katana sobem.
	var base_counter := float(((fams["espada_recta"] as Dictionary).get("contra_perfurante", {}) as Dictionary).get("multiplicador", 0.0))
	var katana_counter := float(((fams["katana"] as Dictionary).get("contra_perfurante", {}) as Dictionary).get("multiplicador", 0.0))
	var polearm_counter := float(((fams["haste"] as Dictionary).get("contra_perfurante", {}) as Dictionary).get("multiplicador", 0.0))
	_check(absf(base_counter - 1.30) < 0.001 and absf(polearm_counter - 1.40) < 0.001
		and absf(katana_counter - 1.45) < 0.001,
		"contra-perfurante: base x1,30, haste x1,40, katana/estocada x1,45")
	_check(((fams["pesada_corte"] as Dictionary).get("contra_perfurante", {}) as Dictionary).get("golpes", []).is_empty(),
		"corte pesado nao recebe contra-ataque universal")
	# A besta e a Lei 3 em objecto: nao escala com nada.
	_check(String((fams["besta"] as Dictionary).get("escala", "")) == "nenhuma",
		"besta: zero escala (Lei 3)")
	# Adaga vs pesada: a ordem de interrupcao do 41 §4 tem de valer.
	_check(int((fams["adaga"] as Dictionary).get("interrupcao", 99))
		< int((fams["pesada_corte"] as Dictionary).get("interrupcao", 0)),
		"adaga interrompe menos que a pesada de corte")

	# Escudos: nenhum passa o tecto de 85, e o grande nao apara.
	var shields: Dictionary = GameData.weapons.get("familias_escudo", {}) as Dictionary
	_check(int(shields.get("estabilidade_maxima", 0)) == 85, "tecto de estabilidade = 85")
	_check(int(shields.get("defesa_fisica_maxima_pct", 0)) == 100
		and int((shields["escudo_medio"] as Dictionary).get("defesa_fisica_pct", 0)) == 100,
		"escudo seleccionado pode bloquear 100% fisico; piso corporal nao se mistura")
	_check((shields["escudo_grande"] as Dictionary).get("parry_delta_frames") == null,
		"escudo grande nao apara")

	# Os 6 kits: todas as classes servidas, com pecas, e so o tanque em medio.
	var loads: Dictionary = GameData.weapons.get("loadouts", {}) as Dictionary
	for class_id: String in ["warrior", "sorcerer", "tank", "assassin", "berserker", "paladin"]:
		var kit: Dictionary = loads.get(class_id, {}) as Dictionary
		_check(not kit.is_empty(), "kit inicial de '%s' existe" % class_id)
		_check((kit.get("pecas", []) as Array).size() >= 1, "kit '%s' traz pecas" % class_id)
	_check(String((loads["tank"] as Dictionary).get("carga", "")) == "medio",
		"so o tanque arranca em carga media")

	# Instrucao do Rico (31-07): o assassino comeca com DUAS adagas.
	var assassin: Dictionary = loads.get("assassin", {}) as Dictionary
	_check(String(assassin.get("main", "")) == "dagger"
		and String(assassin.get("offhand", "")) == "dagger",
		"assassino arranca com duas adagas (instrucao do Rico)")
	# E continua a poder aparar — a adaga esta na lista do WP1.
	var parry_list: Array = GameData.section("parry").get("weapons_that_parry", [])
	_check(parry_list.has("dagger"), "com duas adagas o assassino ainda apara")

	# Armadura: as 9 casas existem, e o peso nao mexe nos i-frames (Lei 1).
	_check((GameData.armor.get("slots", []) as Array).size() == 9, "9 slots de armadura")
	var carga: Dictionary = GameData.armor.get("carga", {}) as Dictionary
	_check(float((carga["pesado"] as Dictionary).get("regen_stamina_mult", 1.0)) < 1.0,
		"carga pesada custa regeneracao de stamina")
	_check(absf(float((carga["medio"] as Dictionary).get("regen_stamina_mult", 0.0)) - 1.0) < 0.001,
		"carga media conserva 40/s de regeneracao")
	_check(absf(float((carga["pesado"] as Dictionary).get("regen_stamina_mult", 0.0)) - 0.775) < 0.001,
		"carga pesada regenera 31/s")
	var overloaded: Dictionary = carga.get("sobrecarregado", {}) as Dictionary
	_check(not bool(overloaded.get("pode_esquivar", true))
		and not bool(overloaded.get("pode_correr", true))
		and not bool(overloaded.get("pode_sprintar", true)),
		"sobrecarga >100%: sem esquiva, corrida ou sprint")
	_check(int((carga["leve"] as Dictionary).get("recuperacao_esquiva_frames", -1)) == 0,
		"carga leve nao penaliza a recuperacao da esquiva")


# --- spec/68 · catálogo WP5 completo -----------------------------------------

func _test_equipment_catalogue() -> void:
	var equipment_value: Variant = GameData.get("equipment")
	_check(typeof(equipment_value) == TYPE_DICTIONARY,
		"WP5: equipment.json e carregado pelo GameData")
	var equipment: Dictionary = equipment_value as Dictionary if typeof(equipment_value) == TYPE_DICTIONARY else {}
	var catalogue_weapons: Dictionary = equipment.get("weapons", {}) as Dictionary
	var catalogue_armor: Dictionary = equipment.get("armor", {}) as Dictionary
	var rings: Dictionary = equipment.get("rings", {}) as Dictionary
	_check(catalogue_weapons.size() == 120, "WP5: catalogo fecha 120 armas")
	_check(catalogue_armor.size() == 68, "WP5: catalogo fecha 68 pecas (11 iniciais + 57 de inimigos)")
	_check(rings.size() == 70, "WP5: catalogo fecha 70 aneis")

	# Tudo o que um dia gera imagem tem matéria, silhueta e prioridade declaradas.
	for group_value: Variant in [catalogue_weapons, catalogue_armor, rings]:
		var group := group_value as Dictionary
		for item_id: String in group.keys():
			var item := group[item_id] as Dictionary
			_check(String(item.get("descricao_visual", "")).length() >= 40,
				"WP5/%s: descricao visual geravel" % item_id)
			_check(typeof(item.get("fatia_1")) == TYPE_BOOL,
				"WP5/%s: Fatia 1? booleana" % item_id)

	var first_slice_armor: Array[String] = []
	for item_id: String in catalogue_armor.keys():
		if bool((catalogue_armor[item_id] as Dictionary).get("fatia_1", false)):
			first_slice_armor.append(item_id)
	_check(first_slice_armor.size() == 11, "WP5: so as 11 armaduras iniciais geram primeiro")
	var first_slice_rings := rings.values().filter(func(r: Dictionary) -> bool: return bool(r.get("fatia_1", false)))
	_check(first_slice_rings.is_empty(), "WP5: nenhum anel cresce a Fatia 1")

	# As oito famílias resolvem os onze golpes; sete deixam de ser apenas uma regra global.
	var movesets: Dictionary = equipment.get("family_movesets", {}) as Dictionary
	var eleven := ["leve", "pesado", "cadeia", "leve_para_pesado", "em_corrida", "a_rolar",
		"a_saltar", "de_cima", "empurrao", "arte_1mao", "arte_2maos"]
	var seven := ["leve_para_pesado", "em_corrida", "a_rolar", "a_saltar", "de_cima", "empurrao", "arte_1mao"]
	_check(movesets.size() == 8, "WP5: oito movesets de familia")
	for family_id: String in movesets.keys():
		var moveset := movesets[family_id] as Dictionary
		for strike: String in eleven:
			_check(moveset.has(strike) and not (moveset[strike] as Dictionary).is_empty(),
				"WP5/%s: golpe '%s' declarado" % [family_id, strike])
		for strike: String in seven:
			_check(String((moveset[strike] as Dictionary).get("pergunta", "")) != "",
				"WP5/%s/%s: golpe muda uma decisao" % [family_id, strike])

	# Melhorar abre verbos; nunca compra +10% de força.
	var upgrade: Dictionary = equipment.get("weapon_improvement", {}) as Dictionary
	var levels: Array = upgrade.get("levels", []) as Array
	_check(levels.size() == 7, "WP5: melhoria declara base + seis niveis")
	var allowed_axes := ["base", "postura", "arte_nova", "troca_escala", "conversao_elemental"]
	for level: int in range(levels.size()):
		var row := levels[level] as Dictionary
		_check(int(row.get("level", -1)) == level, "WP5: melhoria nivel %d em ordem" % level)
		_check(String(row.get("axis", "")) in allowed_axes, "WP5: melhoria nivel %d abre eixo permitido" % level)
		_check(not bool(row.get("increases_base_damage", true)), "WP5: melhoria nivel %d nao sobe forca" % level)

	# Estados são legíveis, simétricos e têm saída; nunca acontecem sem barra.
	var statuses: Dictionary = equipment.get("status_effects", {}) as Dictionary
	var status_ids: Array = statuses.keys()
	status_ids.sort()
	_check(status_ids == ["queimadura", "sangramento", "veneno"],
		"WP5: veneno, sangramento e queimadura fechados")
	for status_id: String in statuses.keys():
		var status := statuses[status_id] as Dictionary
		for field: String in ["meter_max", "decay", "trigger", "effect", "escape", "applies_to",
				"sound_cue", "visual_cue", "descricao_visual", "fatia_1"]:
			_check(str(status.get(field, "")) != "", "WP5/%s: estado declara '%s'" % [status_id, field])
		_check(String(status.get("applies_to", "")) == "jogador_e_inimigo",
			"WP5/%s: mesmas regras dos dois lados" % status_id)

	# A proposta do Assassino responde às três palavras sem IA nova, percentagem de
	# velocidade nem exclusividade de classe; a aprovação continua pendente.
	var assassin: Dictionary = equipment.get("assassin_proposal", {}) as Dictionary
	_check(String(assassin.get("approval", "")).contains("Mateus pendente"),
		"Assassino: proposta nao finge a decisao do dono")
	_check(bool(assassin.get("no_new_ai", false)), "Assassino: furtividade sem IA nova cara")
	_check(bool(assassin.get("speed_is_new_branch", false)), "Assassino: velocidade e ramo, nao +X%")
	_check(bool(assassin.get("class_affinity_not_lock", false)), "Assassino: afinidade nunca fecha outras origens")
	_check(String(((GameData.weapons.get("loadouts", {}) as Dictionary).get("assassin", {}) as Dictionary).get("offhand", "")) == "dagger",
		"Assassino: segunda adaga mecanicamente declarada")

	# Os 70 anéis são descobertas únicas e condicionais, não mais uma barra de atalhos.
	var axes: Dictionary = {}
	var effects: Dictionary = {}
	for ring_id: String in rings.keys():
		var ring := rings[ring_id] as Dictionary
		for field: String in ["nome", "eixo", "efeito", "numeros", "afinidade", "soma_com_outro",
				"onde_se_encontra", "descricao_visual", "fatia_1"]:
			_check(ring.has(field) and str(ring.get(field, "")) != "", "anel/%s: declara '%s'" % [ring_id, field])
		_check(not ring.has("input_action"), "anel/%s: passivo/condicional, sem tecla" % ring_id)
		_check(float((ring.get("numeros", {}) as Dictionary).get("max_percent", 0.0)) <= 10.0,
			"anel/%s: nenhum numero passa 10%%" % ring_id)
		axes[String(ring.get("eixo", ""))] = true
		var effect_key := String(ring.get("efeito", ""))
		_check(not effects.has(effect_key), "anel/%s: efeito nao se repete" % ring_id)
		effects[effect_key] = true
	_check(axes.size() == 8, "WP5: os oito eixos dos aneis aparecem")

	# O baralho do WP6 não promete equipamento fantasma.
	for enemy_id: String in GameData.enemies.keys():
		if enemy_id.begins_with("_") or bool(GameData.enemy(enemy_id).get("is_boss", false)):
			continue
		for card_value: Variant in GameData.enemy(enemy_id).get("loot_cards", []):
			var card := String(card_value)
			var split := card.split(":", false, 1)
			if split.size() != 2:
				continue
			match split[0]:
				"arma": _check(catalogue_weapons.has(split[1]), "espólio arma '%s' resolve" % split[1])
				"armadura": _check(catalogue_armor.has(split[1]), "espólio armadura '%s' resolve" % split[1])
				"anel": _check(rings.has(split[1]), "espólio anel '%s' resolve" % split[1])


# --- spec/69 · catálogo WP8 completo -----------------------------------------

func _test_world_catalogue() -> void:
	var world_value: Variant = GameData.get("world")
	_check(typeof(world_value) == TYPE_DICTIONARY,
		"WP8: world.json e carregado pelo GameData")
	var world: Dictionary = world_value as Dictionary if typeof(world_value) == TYPE_DICTIONARY else {}
	var reading: Dictionary = world.get("map_reading", {}) as Dictionary
	_check(bool(reading.get("decided_before_layout", false)),
		"WP8: leitura do mapa fica decidida antes do tracado")
	_check(String(reading.get("projection", "")) == "inclinada_40_graus",
		"WP8: vista inclinada torna a verticalidade legivel")
	_check(String(reading.get("reveal_rule", "")) == "apenas_terreno_percorrido",
		"WP8: mapa regista descoberta, nao guia")
	_check(String(reading.get("scope_decision", "")).contains("donos"),
		"WP8: catalogo nao decide mapa por zona vs mundo inteiro")

	var zones: Dictionary = world.get("zones", {}) as Dictionary
	var doors: Dictionary = world.get("history_doors", {}) as Dictionary
	var connections: Array = world.get("connections", []) as Array
	_check(zones.size() == 12, "WP8: as 12 fichas de bioma recebem tracado")
	_check(doors.size() >= 24 and doors.size() <= 36,
		"WP8: 24-36 portas de historia")
	_check(doors.size() == 30, "WP8: alvo fechado em 30 portas, 2-3 por bioma")
	_check(connections.size() >= 16, "WP8: rede tem aneis em vez de uma linha")

	var first_slice_zones := 0
	var door_counts: Dictionary = {}
	for biome_id: String in GameData.biome_ids():
		var zone: Dictionary = zones.get(biome_id, {}) as Dictionary
		_check(not zone.is_empty(), "WP8/%s: bioma tem ficha de mundo" % biome_id)
		if zone.is_empty():
			continue
		for field: String in ["nome", "biome_id", "traversal", "encounter_curve", "rest_points",
				"landmarks", "horizontal_loop", "vertical_loop", "shortcut", "dungeon",
				"connections", "descricao_visual", "concept_art", "fatia_1"]:
			_check(zone.has(field) and str(zone.get(field, "")) != "",
				"WP8/%s: declara '%s'" % [biome_id, field])
		var minutes := int((zone.get("traversal", {}) as Dictionary).get("clean_minutes", 0))
		_check(minutes >= 8 and minutes <= 12,
			"WP8/%s: travessia limpa fica em 8-12 min" % biome_id)
		var curve: Dictionary = zone.get("encounter_curve", {}) as Dictionary
		_check(int(curve.get("common", 0)) >= 12 and int(curve.get("common", 0)) <= 20,
			"WP8/%s: 12-20 encontros comuns" % biome_id)
		_check(int(curve.get("elites", 0)) >= 3 and int(curve.get("elites", 0)) <= 5,
			"WP8/%s: 3-5 elites" % biome_id)
		_check(int(curve.get("named", 0)) >= 2 and int(curve.get("named", 0)) <= 3,
			"WP8/%s: 2-3 nomeados" % biome_id)
		_check((zone.get("rest_points", []) as Array).size() >= 2 and
			(zone.get("rest_points", []) as Array).size() <= 3,
			"WP8/%s: 2-3 descansos" % biome_id)
		for loop_key: String in ["horizontal_loop", "vertical_loop", "shortcut"]:
			var loop: Dictionary = zone.get(loop_key, {}) as Dictionary
			_check(String(loop.get("opens_from", "")) == "interior",
				"WP8/%s/%s: abre-se do lado de dentro" % [biome_id, loop_key])
			_check(String(loop.get("descricao_visual", "")).length() >= 40,
				"WP8/%s/%s: descricao visual geravel" % [biome_id, loop_key])
			_check(typeof(loop.get("fatia_1")) == TYPE_BOOL,
				"WP8/%s/%s: Fatia 1? booleana" % [biome_id, loop_key])
		var vertical: Dictionary = zone.get("vertical_loop", {}) as Dictionary
		_check(int(vertical.get("height_gain_m", 0)) >= 4,
			"WP8/%s: circulo vertical muda pelo menos 4 m" % biome_id)
		_check(String(vertical.get("return_method", "")) != "",
			"WP8/%s: circulo vertical declara como regressa" % biome_id)
		_check((zone.get("connections", []) as Array).size() >= 2,
			"WP8/%s: pelo menos duas direccoes" % biome_id)
		_check(FileAccess.file_exists(String(zone.get("concept_art", ""))),
			"WP8/%s: conceito visual arquivado" % biome_id)
		if bool(zone.get("fatia_1", false)):
			first_slice_zones += 1
	_check(first_slice_zones == 1 and bool((zones.get("brumal", {}) as Dictionary).get("fatia_1", false)),
		"WP8: so Brumal pertence a Fatia 1")

	for door_id: String in doors.keys():
		var door := doors[door_id] as Dictionary
		for field: String in ["nome", "biome_id", "form", "what_exists_now", "reason_is_legible",
				"future_slot", "witness", "descricao_visual", "fatia_1"]:
			_check(door.has(field) and str(door.get(field, "")) != "",
				"WP8/porta/%s: declara '%s'" % [door_id, field])
		var door_biome := String(door.get("biome_id", ""))
		_check(zones.has(door_biome), "WP8/porta/%s: bioma existe" % door_id)
		door_counts[door_biome] = int(door_counts.get(door_biome, 0)) + 1
		_check(not bool(door.get("fatia_1", true)),
			"WP8/porta/%s: historia continua fora da Fatia 1" % door_id)
	for biome_id: String in zones.keys():
		_check(int(door_counts.get(biome_id, 0)) >= 2 and int(door_counts.get(biome_id, 0)) <= 3,
			"WP8/%s: 2-3 portas de historia" % biome_id)

	# A rede é simétrica, conectada e nenhuma garganta carrega um terceiro bioma.
	var adjacency: Dictionary = {}
	for biome_id: String in zones.keys():
		adjacency[biome_id] = []
	for connection_value: Variant in connections:
		var connection := connection_value as Dictionary
		var from_id := String(connection.get("from", ""))
		var to_id := String(connection.get("to", ""))
		_check(zones.has(from_id) and zones.has(to_id) and from_id != to_id,
			"WP8/ligacao: extremos validos %s -> %s" % [from_id, to_id])
		if zones.has(from_id) and zones.has(to_id):
			(adjacency[from_id] as Array).append(to_id)
			(adjacency[to_id] as Array).append(from_id)
		_check((connection.get("loads", []) as Array).size() == 2,
			"WP8/%s-%s: garganta carrega so os dois vizinhos" % [from_id, to_id])
		_check(String(connection.get("descricao_visual", "")).length() >= 40,
			"WP8/%s-%s: transicao tem descricao visual" % [from_id, to_id])
		_check(typeof(connection.get("fatia_1")) == TYPE_BOOL,
			"WP8/%s-%s: Fatia 1? booleana" % [from_id, to_id])
	var reached: Dictionary = {"brumal": true}
	var frontier: Array[String] = ["brumal"]
	while not frontier.is_empty():
		var current: String = String(frontier.pop_front())
		for neighbour_value: Variant in adjacency.get(current, []):
			var neighbour := String(neighbour_value)
			if not reached.has(neighbour):
				reached[neighbour] = true
				frontier.append(neighbour)
	_check(reached.size() == 12, "WP8: os 12 biomas formam uma rede ligada")


# --- spec/50-racas.md (volta 2) · as 12 fichas de raca ------------------------

func _test_races() -> void:
	var ids := GameData.race_ids()

	# 12 racas verdadeiras + o mimico como praga (spec/50 §0).
	var true_races: Array[String] = []
	for id in ids:
		if String(GameData.race(id).get("tipo", "")) == "raca":
			true_races.append(id)
	_check(true_races.size() == 12, "12 racas verdadeiras (10-15 [DECIDIDO])")
	_check(String(GameData.race("mimicos").get("tipo", "")) == "praga",
		"o mimico e praga, nao raca")

	# So os orcs estao na fatia 1 (spec/10: lanceiro, brutamontes, Vorgar).
	var slice: Array[String] = []
	for id in ids:
		if bool(GameData.race(id).get("fatia_1", false)):
			slice.append(id)
	_check(slice.size() == 1 and slice[0] == "orcs", "fatia 1 = so orcs")

	# Cada bioma tem >= 3 papeis de combate diferentes entre as racas que aloja
	# + o mimico/chefe — aqui exigimos >= 2 so das racas residentes (o 3.o vem
	# do chefe ancora, WP7). Spec/38 §6 via spec/50 §13.
	for biome_id in GameData.biome_ids():
		var housed: Dictionary = GameData.biome(biome_id).get("racas", {}) as Dictionary
		var listed: Array = [String(housed.get("dominante", ""))]
		listed.append_array(housed.get("secundarias", []) as Array)
		var roles := {}
		for race_id: Variant in listed:
			var r := GameData.race(String(race_id))
			roles[String(r.get("papel", ""))] = true
			if r.has("papel_secundario"):
				roles[String(r.get("papel_secundario", ""))] = true
		_check(roles.size() >= 2, "%s: >= 2 papeis entre residentes (tem %d)" % [biome_id, roles.size()])

	# As 6 novas sao exactamente as semeadas na volta 1 (spec/49 §4).
	for new_race: String in ["teceloes", "ventaneiras", "borralheiros",
			"submersos", "penitentes", "sem_rosto"]:
		_check(not GameData.race(new_race).is_empty(), "raca nova '%s' existe" % new_race)

	# Nenhuma raca sem segredo — a linha 8 e a que faz reler (spec/46 §5).
	for id in ids:
		_check(String(GameData.race(id).get("segredo", "")) != "",
			"'%s' tem a linha 'ninguem sabe'" % id)


# --- spec/49-biomas.md (volta 1) · as 12 fichas de bioma ----------------------

func _test_biomes() -> void:
	var ids := GameData.biome_ids()
	_check(ids.size() == 12, "12 biomas em biomes.json (spec/49 §1)")

	# Exactamente UM bioma na fatia 1, e e Brumal.
	var slice: Array[String] = []
	for id in ids:
		if bool(GameData.biome(id).get("fatia_1", false)):
			slice.append(id)
	_check(slice.size() == 1 and slice[0] == "brumal", "fatia 1 = so Brumal")

	# As ordens sao 1..12, sem repeticao — a fila de construcao e inequivoca.
	var orders: Array[int] = []
	for id in ids:
		orders.append(int(GameData.biome(id).get("ordem", 0)))
	orders.sort()
	var orders_ok := orders.size() == 12
	for i in range(orders.size()):
		if orders[i] != i + 1:
			orders_ok = false
	_check(orders_ok, "ordens 1..12 unicas")

	# Nenhum elemento eficaz e orfao: existe como elemento de outro bioma
	# ou como escola de magia (luz/sombra) — spec/49 §4.
	var elements: Array[String] = []
	for id in ids:
		elements.append(String(GameData.biome(id).get("elemento", "")))
	for id in ids:
		var eff := String(GameData.biome(id).get("eficaz_contra_nativos", ""))
		_check(eff in elements or eff in ["luz", "sombra"],
			"'%s' (eficaz em %s) existe no mapa ou e escola" % [eff, id])

	# 12 colheitas distintas — cada bioma da um material proprio (spec/46 §2).
	var crops := {}
	for id in ids:
		crops[String(GameData.biome(id).get("colheita", ""))] = true
	_check(crops.size() == 12, "12 colheitas distintas")

	# A alavanca do 46 §7 com o travao proposto: nenhuma raca dominante ou
	# secundaria aparece em mais de 3 biomas.
	var race_count := {}
	for id in ids:
		var r: Dictionary = GameData.biome(id).get("racas", {}) as Dictionary
		var all_races: Array = [String(r.get("dominante", ""))]
		all_races.append_array(r.get("secundarias", []) as Array)
		for race: Variant in all_races:
			race_count[race] = int(race_count.get(race, 0)) + 1
	for race: Variant in race_count.keys():
		_check(int(race_count[race]) <= 3, "raca '%s' em <= 3 biomas" % race)

	# A ficha de Brumal FORMALIZA o que o prototipo ja mostra: a nevoa da ficha
	# e a mesma do palette de estados que as medicoes de PERF.md viram no ecra.
	var brumal_fog := String((GameData.biome("brumal").get("paleta", {}) as Dictionary).get("nevoa", ""))
	var state_fog := _graphics_fog()
	_check(brumal_fog == state_fog, "nevoa de Brumal = a do prototipo medido (%s)" % state_fog)


func _graphics_fog() -> String:
	var graphics: Variant = JSON.parse_string(
		FileAccess.get_file_as_string("res://data/graphics.json"))
	return String(((graphics as Dictionary).get("palette", {}) as Dictionary).get("fog", ""))


# --- spec/13-magia.md (WP4) · o catalogo --------------------------------------

func _test_spell_catalogue() -> void:
	_check(GameData.has_method("max_mana_for"),
		"a magia usa uma reserva publica de mana, nao cargas revogadas")
	var sorcerer_attrs := GameData.class_attributes("sorcerer")
	_check(sorcerer_attrs.has("inteligencia") and sorcerer_attrs.has("fe"),
		"as quatro escolas recebem Inteligencia e Fe separadas")
	_check(GameData.max_mana_for(sorcerer_attrs) == 116,
		"Feiticeiro com Inteligencia 14 arranca com 116 de mana")
	var schools: Dictionary = GameData.spells.get("_schools", {}) as Dictionary
	_check(schools.keys().size() == 4,
		"o catalogo tem as quatro escolas de spec/42")
	_check(String((schools.get("mal", {}) as Dictionary).get("scaling", "")) == "menor_int_fe",
		"a escola vermelha escala com o MENOR de Inteligencia e Fe")
	var split_caster := {"inteligencia": 30, "fe": 12}
	_check(GameData.casting_attribute_for("mal", split_caster) == 12.0,
		"Int 30 / Fe 12 da 12 de escala vermelha")
	_check(GameData.casting_attribute_for("piromancia", split_caster) == 21.0,
		"a piromancia usa a media de Inteligencia e Fe")
	# magia, mana, tempo, dano base, alcance
	var table := [
		["dardo", 12, 0.8, 45, 18.0],
		["ruina", 35, 1.6, 70, 12.0],
		["egide", 25, 0.5, 0,  0.0],
	]
	for row: Array in table:
		var s := GameData.spell(String(row[0]))
		_check(int(s.get("mana_cost")) == int(row[1]), "%s custa %d mana" % [row[0], row[1]])
		_check(absf(float(s.get("cast_time")) - float(row[2])) < 0.001,
			"%s conjura em %.1f s" % [row[0], row[2]])
		if int(row[3]) > 0:
			_check(int(s.get("base_damage")) == int(row[3]), "%s: dano base %d" % [row[0], row[3]])
		if float(row[4]) > 0.0:
			_check(absf(float(s.get("max_range")) - float(row[4])) < 0.001,
				"%s: alcance %.0f m" % [row[0], row[4]])

	var egide := GameData.spell("egide")
	_check(int(egide.get("absorb")) == 120, "Egide absorve 120")
	_check(absf(float(egide.get("duration")) - 2.5) < 0.001, "Egide dura 2,5 s")
	_check(bool(egide.get("hyper_armor_while_active")), "Egide da hiper-armadura enquanto dura")
	_check(bool(GameData.spell("ruina").get("movement_locked")), "Ruina conjura-se parado")
	_check(absf(float(GameData.spell("ruina").get("telegraph_seconds")) - 0.5) < 0.001,
		"Ruina marca o chao 0,5 s antes")
	_check(bool(GameData.spells.get("_rules", {}).get("requires_declared_instrument", false)),
		"conjurar exige o instrumento declarado pela escola")

	var pool := GameData.max_mana_for(sorcerer_attrs)
	_check(pool == 116, "reserva do Feiticeiro: 116 mana")
	_check(2 * int(GameData.spell("ruina").get("mana_cost"))
		+ int(GameData.spell("dardo").get("mana_cost")) <= pool,
		"2 Ruinas + 1 Dardo cabem na reserva")

	var forms: Array = GameData.spells.get("_delivery_forms", []) as Array
	_check(forms.size() == 12, "as 12 formas de entrega estao declaradas")
	var escape_vectors: Array = GameData.spells.get("_escape_vectors", []) as Array
	_check(escape_vectors.size() == 9, "os 9 vectores de fuga do spec/38 estao fechados")
	var used_forms := {}
	var slice_spells: Array[String] = []
	var required_fields := ["display_name", "school", "question", "formula", "mana_cost",
		"cast_time", "delivery_form", "invalid_where", "escape_vector", "escape_method",
		"contact_type", "descricao_visual", "sound_cue", "visual_cue", "fatia_1"]
	for spell_id: Variant in GameData.spells.get("order", []):
		var spell := GameData.spell(String(spell_id))
		for field: String in required_fields:
			_check(spell.has(field) and str(spell.get(field, "")).length() > 0,
				"%s traz o campo obrigatorio %s" % [spell_id, field])
		_check(String(spell.get("school", "")) in schools.keys(),
			"%s pertence a uma das quatro escolas" % spell_id)
		_check(typeof(spell.get("fatia_1")) == TYPE_BOOL,
			"%s declara Fatia 1? como booleano" % spell_id)
		var form := String(spell.get("delivery_form", ""))
		_check(form in forms, "%s usa uma das 12 formas" % spell_id)
		used_forms[form] = true
		var contact := String(spell.get("contact_type", ""))
		_check(contact in ["instantaneo", "volume_movel", "volume_persistente", "nenhum"],
			"%s declara tipo de contacto valido" % spell_id)
		if contact != "nenhum":
			_check(String(spell.get("escape_vector", "")) in escape_vectors,
				"%s usa um dos 9 vectores de fuga" % spell_id)
		var upgrades: Array = spell.get("upgrades", []) as Array
		_check(upgrades.size() == 6, "%s tem tabela de melhoria 0..5" % spell_id)
		if upgrades.size() == 6:
			for upgrade_level: int in range(6):
				_check(int((upgrades[upgrade_level] as Dictionary).get("level", -1)) == upgrade_level,
					"%s tem o nivel %d na posicao certa" % [spell_id, upgrade_level])
			for upgrade_level: int in [1, 3, 5]:
				var axis := String((upgrades[upgrade_level] as Dictionary).get("axis", ""))
				_check(axis in ["area", "lancamentos"],
					"%s nivel %d abre area ou lancamentos" % [spell_id, upgrade_level])
		if bool(spell.get("fatia_1", false)):
			slice_spells.append(String(spell_id))
			var icon_file := ProjectSettings.globalize_path(
				"res://../%s" % String(spell.get("icon_path", "")))
			_check(String(spell.get("icon_id", "")).begins_with("ico_magia_")
				and FileAccess.file_exists(icon_file),
				"%s liga o icone aprovado da Fatia 1" % spell_id)
	for form: Variant in forms:
		_check(used_forms.has(String(form)), "forma '%s' tem pelo menos um feitico" % form)
	_check(slice_spells == ["dardo", "ruina", "egide"],
		"Fatia 1 mantem Dardo, Ruina e Egide")
	var spell_rules: Dictionary = GameData.spells.get("_rules", {}) as Dictionary
	var meditation: Dictionary = spell_rules.get("meditation", {}) as Dictionary
	_check(int(meditation.get("seconds", 0)) == 40,
		"meditar demora os 40 s decididos")
	_check(int(meditation.get("uses_per_rest", 0)) == 2
		and bool(meditation.get("use_consumed_on_start", false)),
		"meditacao tem duas tentativas finitas por descanso")
	_check(float(meditation.get("mana_restored_fraction", 0.0)) == 1.0
		and bool(meditation.get("partial_mana_kept", false)),
		"meditacao completa repoe tudo e interrupcao conserva o parcial")
	_check(spell_rules.get("favorites_change_when", []) == ["fora_de_combate", "descanso"],
		"os oito favoritos nao mudam durante combate")
	var default_favorites: Array = spell_rules.get("default_favorites", []) as Array
	_check(default_favorites == ["dardo", "ruina", "egide"]
		and default_favorites.size() <= int(spell_rules.get("favorite_limit", 0)),
		"a Fatia 1 prepara so os tres favoritos e respeita o limite de oito")
	_check(String(((GameData.weapons.get("golpes_universais", {}) as Dictionary)
		.get("arte_da_arma", {}) as Dictionary).get("custo", "")) == "mana",
		"artes de arma gastam mana, nunca energia revogada")

	var meditator := Player.new()
	meditator.max_mana = 100
	meditator.mana = 10
	meditator.meditation_uses = 2
	meditator._meditation_frames_total = 2400
	meditator._start_meditation()
	_check(meditator.state == Player.State.MEDITATING and meditator.meditation_uses == 1,
		"meditacao gasta a tentativa ao sentar")
	meditator.state_frame = 1200
	meditator._tick_meditating(1.0 / 60.0)
	_check(meditator.mana == 55,
		"meditacao repoe linearmente e pode conservar progresso parcial")
	meditator.state_frame = 2400
	meditator._tick_meditating(1.0 / 60.0)
	_check(meditator.mana == 100 and meditator.state == Player.State.FREE,
		"meditacao completa repoe 100% aos 40 s")
	meditator.queue_free()

	var spell_wheel := Player.new()
	spell_wheel.favorite_spells.assign(default_favorites)
	spell_wheel.selected_spell = "dardo"
	spell_wheel._cycle_spell()
	spell_wheel._cycle_spell()
	spell_wheel._cycle_spell()
	_check(spell_wheel.selected_spell == "dardo",
		"F percorre favoritos e nunca o catalogo inteiro")
	spell_wheel.queue_free()


# --- spec/25-controlo.md (WP1B) · buffer e impacto ----------------------------

func _test_feel() -> void:
	var b := GameData.section("input_buffer")
	_check(int(b.get("life_ms")) == 400, "buffer: entrada morre aos 400 ms")
	_check(int(b.get("parry_life_ms")) == 80, "buffer: parry guarda-se so 80 ms")
	_check(int(b.get("capacity")) == 1, "buffer: capacidade 1")
	_check(bool(b.get("dodge_has_priority")), "buffer: esquiva tem prioridade sobre ataque")

	var hs := GameData.section("hit_stop")
	_check(int(hs.get("light_hit")) == 3, "hit-stop: golpe leve 3 f")
	_check(int(hs.get("heavy_hit")) == 6, "hit-stop: golpe pesado 6 f")
	_check(int(hs.get("parry_success")) == 10, "hit-stop: parry 10 f (o momento-assinatura)")
	_check(int(hs.get("blocked")) == 4, "hit-stop: bloqueado 4 f")
	_check(int(hs.get("killing_blow")) == 8, "hit-stop: golpe final 8 f")

	var c := GameData.section("camera")
	_check(absf(float(c.get("fov")) - 55.0) < 0.001, "camara: FOV 55 graus")
	_check(absf(float(c.get("distance")) - 4.0) < 0.001, "camara: 4,0 m")
	_check(absf(float(c.get("distance_locked_on")) - 4.8) < 0.001, "camara: 4,8 m com lock-on")
	_check(absf(float(c.get("pivot_height")) - 1.6) < 0.001, "camara: pivo aos ombros (1,6 m)")
	_check(not bool(c.get("mouse_acceleration")), "camara: SEM aceleracao de rato")

	# A esquiva no buffer nunca e substituida por um ataque.
	var p := _make_player()
	p._buffer("dodge")
	p._buffer("light")
	_check(p._peek_buffer() == "dodge", "esquiva no buffer nao e substituida por ataque")
	p._buffer("dodge")
	_check(p._peek_buffer() == "dodge", "esquiva substitui esquiva")
	p.free()


# --- spec/01-combate.md · Esquiva ---------------------------------------------

func _test_dodge_iframes() -> void:
	var p := _make_player()
	var cfg := GameData.section("dodge")
	var total := int(cfg.get("duration_frames", 36))
	var want_start := int(cfg.get("iframe_start_frame", 5))
	var want_end := int(cfg.get("iframe_end_frame", 23))

	p.state = Player.State.DODGE
	var first := -1
	var last := -1
	for f in range(0, total + 1):
		p.state_frame = f
		if p.has_iframes():
			if first < 0:
				first = f
			last = f

	_check(first == want_start, "esquiva: i-frames comecam no frame %d (spec: %d)" % [first, want_start])
	_check(last == want_end, "esquiva: i-frames acabam no frame %d (spec: %d)" % [last, want_end])
	_check(absf(GameData.frames_to_seconds(float(last - first + 1)) - 0.3167) < 0.02,
		"esquiva: %.0f ms de invencibilidade (spec: 317 ms)"
		% (GameData.frames_to_seconds(float(last - first + 1)) * 1000.0))

	# A recuperacao dos 0,400 aos 0,600 s tem de ser vulneravel.
	p.state_frame = 30
	_check(not p.has_iframes(), "esquiva: frame 30 (0,50 s) ja e vulneravel")
	p.free()


# --- spec/01-combate.md · Parry -----------------------------------------------

func _test_parry_window() -> void:
	var p := _make_player()
	var cfg := GameData.section("parry")
	var startup := int(cfg.get("startup_frames", 8))
	var active := int(cfg.get("active_frames", 8))

	p.state = Player.State.PARRY
	var first := -1
	var last := -1
	for f in range(0, 60):
		p.state_frame = f
		if p.parry_window_open():
			if first < 0:
				first = f
			last = f

	_check(first == startup, "parry: janela abre no frame %d (spec: %d)" % [first, startup])
	_check(last - first + 1 == active, "parry: janela dura %d frames (spec: %d)" % [last - first + 1, active])
	_check(absf(GameData.frames_to_seconds(float(active)) - 0.1333) < 0.005,
		"parry: janela de %.0f ms (spec: 133 ms)" % (GameData.frames_to_seconds(float(active)) * 1000.0))

	var total := startup + active + int(cfg.get("whiff_recovery_frames", 40))
	_check(startup == 8, "parry: 8 frames de arranque obrigam a antecipar")
	_check(total == 56, "parry falhado: %d frames no total (8+8+40)" % total)
	_check(absf(GameData.frames_to_seconds(40.0) - 0.667) < 0.005, "parry falhado: 0,667 s exposto")
	p.free()


# --- spec/70 · fecho dos sistemas de combate ---------------------------------

func _test_task4_combat_closures() -> void:
	var grip := GameData.section("grip")
	_check(int(grip.get("switch_frames", 0)) == 12 and bool(grip.get("interruptible", false)),
		"empunhadura: transicao de 12 frames e interrompivel")
	var events := InputMap.action_get_events("toggle_grip")
	var has_key := false
	var has_pad := false
	for event: InputEvent in events:
		has_key = has_key or event is InputEventKey
		has_pad = has_pad or event is InputEventJoypadButton
	_check(has_key and has_pad, "empunhadura: T e Y/triangulo entram no mapa remapeavel")

	var p := _make_player()
	_check(not p.is_two_handed and p.grip_uses_offhand(),
		"empunhadura: espada + escudo arranca a uma mao")
	p._start_grip_switch()
	_check(p.state == Player.State.GRIP_SWITCH, "empunhadura: estado proprio inicia em LIVRE")
	p.state_frame = 11
	p._tick_grip_switch(1.0 / 60.0)
	_check(not p.is_two_handed, "empunhadura: ainda nao troca no frame 11")
	p.state_frame = 12
	p._tick_grip_switch(1.0 / 60.0)
	_check(p.is_two_handed and not p.grip_uses_offhand() and p.state == Player.State.FREE,
		"empunhadura: troca no frame 12 e recolhe a mao secundaria")
	p._start_grip_switch()
	var interrupt := DamageInfo.make(40.0, null, "light")
	interrupt.source_position = p.global_position + Vector3(0.0, 0.0, -1.0)
	p.take_damage(interrupt)
	_check(p.state == Player.State.HITSTUN, "empunhadura: dano interrompe a transicao")
	p.free()

	var pierced := _make_player()
	pierced.state = Player.State.BLOCK
	var pierce_info := DamageInfo.make(100.0, null, "light")
	pierce_info.source_position = pierced.global_position + Vector3(0.0, 0.0, -1.0)
	pierce_info.shield_pierce_fraction = 0.40
	var health_before := pierced.health
	pierced.take_damage(pierce_info)
	_check(absf((health_before - pierced.health) - 24.0) < 0.01,
		"ATRAVESSA_ESCUDO: 40% passa pelo escudo e depois encontra DEF")
	pierced.free()

	var crushed := _make_player()
	crushed.state = Player.State.BLOCK
	var crush_info := DamageInfo.make(100.0, null, "light")
	crush_info.source_position = crushed.global_position + Vector3(0.0, 0.0, -1.0)
	crush_info.guard_stamina_multiplier = 2.5
	var stamina_before := crushed.stamina.current
	crushed.take_damage(crush_info)
	_check(absf((stamina_before - crushed.stamina.current) - 37.5) < 0.01,
		"ESMAGA_GUARDA: custo normal de bloqueio x2,5")
	crushed.free()

	var grammar_contract := {
		"sea_orc_hookbearer": ["hook_pull", "ATRAVESSA_ESCUDO"],
		"orc_brute": ["slam", "ESMAGA_GUARDA"],
		"vorgar": ["overhead_crush", "DUAS_LARGADAS"],
		"orc_spearman": ["double_thrust", "RAMO_COMBO"],
		"skeleton_swordsman": ["bone_rattle", "FALSA_RECUPERACAO"],
		"ancient_skeleton": ["black_cut", "FINGE_MORTE"],
		"minotaur_quarry_bull": ["stone_stomp", "CORPO_DURO"],
	}
	for enemy_id: String in grammar_contract.keys():
		var expected: Array = grammar_contract[enemy_id]
		var attack := _catalogue_attack(enemy_id, String(expected[0]))
		_check((attack.get("gramatica", []) as Array).has(String(expected[1])),
			"gramatica: %s/%s liga %s" % [enemy_id, expected[0], expected[1]])
	var heal_attack := _catalogue_attack("orc_spearman", "closing_lunge")
	var heal_rule: Dictionary = heal_attack.get("heal_punish", {}) as Dictionary
	_check((heal_attack.get("gramatica", []) as Array).has("CASTIGO_CURA")
		and int(heal_rule.get("reaction_latency_frames", 0)) >= 9
		and bool(heal_rule.get("requires_line_of_sight", false))
		and not bool(heal_rule.get("reads_input", true)),
		"gramatica: castigo de cura le animacao visivel, LOS e >=9 f; nunca o input")
	var releases := _catalogue_attack("vorgar", "overhead_crush")
	var release_frames: Array = releases.get("release_variants_frames", []) as Array
	_check(release_frames.size() == 2 and int(release_frames[0]) == 56 and int(release_frames[1]) == 72
		and not (releases.get("late_release_signal", {}) as Dictionary).is_empty(),
		"duas largadas: mesmo aviso, f56/f72 e segundo sinal antes dos activos")
	var breath: Dictionary = GameData.spell("folego_roubado")
	_check(int(breath.get("base_damage", -1)) == 0 and int(breath.get("posture_damage_base", 0)) > 0
		and absf(float(breath.get("stamina_return_fraction_of_effect", 0.0)) - 0.50) < 0.001,
		"Folego Roubado usa postura/guarda e nao stamina inimiga fantasma")


func _test_progression_closures() -> void:
	_check(GameData.fall_damage(5.0, 420.0) == 0.0, "queda: zero dano ate 5 m")
	_check(GameData.fall_is_fatal(20.0) and is_inf(GameData.fall_damage(20.0, 2000.0)),
		"queda: 20 m mata sempre, independentemente da vida")
	var low_health_damage := GameData.fall_damage(12.0, 420.0)
	var high_health_damage := GameData.fall_damage(12.0, 1000.0)
	_check(low_health_damage / 420.0 > high_health_damage / 1000.0,
		"queda nao fatal: Vida continua a fazer diferenca como os donos decidiram")
	_check(GameData.fall_damage(12.0, 420.0, 1.0) > low_health_damage,
		"queda nao fatal: carga aumenta o dano sem mexer no limiar fatal")
	_check(GameData.cycle_multipliers(1) == Vector2.ONE
		and GameData.cycle_multipliers(2).is_equal_approx(Vector2(1.30, 1.15))
		and GameData.cycle_multipliers(7).is_equal_approx(Vector2(1.55, 1.30)),
		"ciclos: NG+ separa PV/dano e soma +5%/+3% ate +7")
	var resurrection: Dictionary = GameData.progression.get("coop_resurrection", {}) as Dictionary
	_check(int(resurrection.get("shared_uses_per_attempt_or_rest", 0)) == 1
		and absf(float(resurrection.get("revived_health_fraction", 0.0)) - 0.50) < 0.001,
		"co-op: uma ressurreicao partilhada por tentativa, a 50% de vida")
	var ember: Dictionary = GameData.progression.get("ember", {}) as Dictionary
	_check(not bool(ember.get("purchasable", true))
		and int(ember.get("already_rewarded_clear_souls", -1)) == 0
		and not bool(ember.get("resets_loot_deck", true)),
		"Brasa: desafio local sem loja, almas repetidas ou reset do baralho")


# --- spec/01-combate.md · tabela das armas ------------------------------------

func _test_weapon_frames() -> void:
	# arma, leve(a/a/r), pesado(a/a/r), MV leve, MV pesado, custo leve, alcance
	var table := [
		["dagger",    [12, 4, 14], [20, 5, 20], 0.55, 0.85, 12, 1.4],
		["longsword", [16, 6, 18], [28, 8, 26], 1.0,  1.6,  18, 2.0],
		["greataxe",  [24, 8, 26], [38, 10, 34], 1.5, 2.4,  28, 2.3],
		["staff",     [18, 5, 20], [30, 7, 28], 0.7,  1.1,  15, 1.8],
	]
	for row: Array in table:
		var id: String = row[0]
		var w := GameData.weapon(id)
		var light: Dictionary = w.get("light", {})
		var heavy: Dictionary = w.get("heavy", {})
		var lf: Array = row[1]
		var hf: Array = row[2]
		_check(int(light.get("startup")) == lf[0] and int(light.get("active")) == lf[1]
			and int(light.get("recovery")) == lf[2], "%s leve: %d/%d/%d" % [id, lf[0], lf[1], lf[2]])
		_check(int(heavy.get("startup")) == hf[0] and int(heavy.get("active")) == hf[1]
			and int(heavy.get("recovery")) == hf[2], "%s pesado: %d/%d/%d" % [id, hf[0], hf[1], hf[2]])
		_check(absf(float(light.get("mv")) - float(row[3])) < 0.001, "%s MV leve %.2f" % [id, row[3]])
		_check(absf(float(heavy.get("mv")) - float(row[4])) < 0.001, "%s MV pesado %.2f" % [id, row[4]])
		_check(int(light.get("stamina")) == int(row[5]), "%s custo do leve %d" % [id, row[5]])
		_check(absf(float(w.get("range")) - float(row[6])) < 0.001, "%s alcance %.1f m" % [id, row[6]])

	var bash: Dictionary = GameData.weapon("shield").get("bash", {})
	_check(int(bash.get("startup")) == 14 and int(bash.get("active")) == 4
		and int(bash.get("recovery")) == 16, "escudo bash: 14/4/16")
	_check(absf(float(bash.get("mv")) - 0.4) < 0.001, "escudo bash MV 0,4")
	_check(absf(float(bash.get("posture_multiplier")) - 2.0) < 0.001, "escudo bash: postura x2")

	var ga_heavy: Dictionary = GameData.weapon("greataxe").get("heavy", {})
	_check(int(ga_heavy.get("charge_max_frames")) == 20, "machadao: carrega ate +20 f")
	_check(absf(float(ga_heavy.get("charge_max_mv")) - 3.0) < 0.001, "machadao carregado: MV 3,0")


# --- spec/01-combate.md · Stamina ---------------------------------------------

func _test_stamina() -> void:
	var s := Stamina.new()
	s.configure(GameData.section("stamina"), 100.0)

	_check(s.maximum == 100.0, "stamina base 100")
	s.spend(25.0)
	_check(absf(s.current - 75.0) < 0.001, "esquiva custa 25")

	# Nao regenera antes de 0,8 s.
	s.tick(0.5, false)
	_check(absf(s.current - 75.0) < 0.001, "sem regeneracao antes de 0,8 s")
	# Depois de 0,8 s, 40/s.
	s.tick(0.4, false)
	s.tick(0.1, false)
	_check(s.current > 75.0, "regenera depois de 0,8 s")

	# Histerese: a zero tranca ate recuperar 15.
	s.refill()
	s.spend(100.0)
	_check(s.locked_out and not s.can_act(), "a zero: tranca as accoes")
	s.tick(1.0, false)   # 0,8 s de espera + 0,2 s x 40/s = 8
	_check(s.locked_out, "ainda trancada com menos de 15")
	s.tick(0.2, false)
	_check(s.can_act(), "destranca ao chegar aos 15 (%.1f)" % s.current)

	# A bloquear regenera a 10/s, nao a 40/s.
	var b := Stamina.new()
	b.configure(GameData.section("stamina"), 100.0)
	b.spend(50.0)
	b.tick(1.0, true)
	_check(absf(b.current - 60.0) < 0.5, "a bloquear regenera 10/s (deu %.1f)" % b.current)


# --- spec/11-formulas.md · o exemplo resolvido --------------------------------

func _test_damage_worked_example() -> void:
	var warrior := GameData.class_attributes("warrior")
	# O exemplo resolvido do WP2 usa o atributo 10 como referencia.
	_check(GameData.max_health_for(10) == 420.0, "formula de PV: Vida 10 -> 420")
	_check(GameData.max_stamina_for(10) == 100.0, "formula de STA: Stamina 10 -> 100")
	_check(GameData.defense_for(10) == 20.0, "formula de DEF: Con 10 -> 20")
	_check(GameData.max_health_for(20) == 640.0 and GameData.max_health_for(50) == 1000.0,
		"Vida usa breakpoints proprios 20/50")
	_check(GameData.max_stamina_for(20) == 120.0 and GameData.max_stamina_for(40) == 140.0,
		"Stamina usa breakpoints proprios 20/40")
	_check(GameData.defense_for(25) == 50.0 and GameData.defense_for(50) == 75.0,
		"Constituicao usa breakpoints proprios 25/50")
	_check(GameData.load_capacity_for(8) == 50.0 and GameData.load_capacity_for(30) == 72.0
		and GameData.load_capacity_for(70) == 87.0,
		"Carga usa breakpoints 30/50/70 e preserva 50 no arranque")

	# As fichas do WP3 (spec/12-classes.md), a letra.
	var sheets := {
		"warrior":   [11, 11, 10, 8,  8, 12, 10],
		"sorcerer":  [10, 10, 9,  14, 8, 9,  10],
		"tank":      [12, 10, 13, 8,  8, 11, 8],
		"assassin":  [10, 12, 9,  8,  8, 9,  14],
		"berserker": [11, 12, 9,  8,  8, 14, 8],
		"paladin":   [11, 10, 10, 8, 11, 11, 9],
	}
	var order := ["vida", "stamina", "constituicao", "inteligencia", "fe", "forca", "destreza"]
	for class_id: String in sheets.keys():
		var c := GameData.class_attributes(class_id)
		var want: Array = sheets[class_id]
		var ok := true
		for i in order.size():
			if int(c.get(order[i], -1)) != int(want[i]):
				ok = false
		_check(ok, "ficha do WP3: %s" % class_id)

	_check(GameData.max_mana_for(GameData.class_attributes("sorcerer")) == 116,
		"Feiticeiro (Int 14) arranca com 116 mana")
	_check(GameData.meets_requirements("greataxe", GameData.class_attributes("berserker")),
		"Berserker cumpre o machadao (For 14)")
	_check(not GameData.meets_requirements("greataxe", warrior),
		"Guerreiro NAO cumpre o machadao (For 12) — pode pegar, paga x0,6")

	var scale := GameData.attribute_scale(12.0, "medio")
	_check(absf(scale - 1.036) < 0.001, "escala For 12 / peso medio = 1,036 (deu %.4f)" % scale)
	var gain_40_60 := GameData.attribute_scale(60.0, "forte") - GameData.attribute_scale(40.0, "forte")
	var gain_20_40 := GameData.attribute_scale(40.0, "forte") - GameData.attribute_scale(20.0, "forte")
	_check(gain_40_60 < gain_20_40 and GameData.attribute_scale(70.0, "forte") - GameData.attribute_scale(60.0, "forte") < gain_40_60,
		"dano satura em bandas diferentes aos 40/60")

	var dmg := GameData.compute_damage(1.0, "longsword", warrior, 4.0)
	_check(absf(dmg - 37.4) < 0.6, "leve de espada no lanceiro = ~37 (deu %.1f)" % dmg)

	# Lei 3: abaixo do requisito continua a funcionar, so custa em numeros.
	var weak := {"forca": 8, "destreza": 8, "inteligencia": 8, "fe": 8,
		"vida": 8, "stamina": 8, "constituicao": 8}
	var weak_dmg := GameData.compute_damage(1.0, "greataxe", weak, 0.0)
	_check(weak_dmg > 0.0, "Lei 3: machadao abaixo do requisito ainda da dano (%.1f)" % weak_dmg)
	_check(absf(weak_dmg - 52.0 * 0.6) < 0.1, "abaixo do requisito: dano x0,6")

	# A DEF nunca corta mais de 40%.
	var capped := GameData.apply_defense(100.0, 90.0)
	_check(absf(capped - 60.0) < 0.001, "DEF corta no maximo 40%% (deu %.1f)" % capped)


# --- spec/01-combate.md · golpes para matar -----------------------------------

func _test_time_to_kill() -> void:
	var warrior := GameData.class_attributes("warrior")
	var cases := [["orc_spearman", 3, 5], ["orc_brute", 6, 9], ["vorgar", 45, 70]]
	for c: Array in cases:
		var e := GameData.enemy(c[0])
		var per := GameData.compute_damage(1.0, "longsword", warrior, float(e.get("defense", 0)))
		var hits := int(ceil(float(e.get("health")) / per))
		_check(hits >= int(c[1]) and hits <= int(c[2]),
			"%s morre em %d leves de espada (spec: %d-%d)" % [c[0], hits, c[1], c[2]])

	# E ao contrario: quantos golpes aguenta o jogador. O WP2 escreve estes numeros
	# sobre a ficha de REFERENCIA (Vida 10 -> 420 PV, Con 10 -> DEF 20), nao sobre
	# uma classe concreta — nenhuma das seis do WP3 tem exactamente esse par.
	var hp := GameData.max_health_for(10)
	var def := GameData.defense_for(10)
	_check(int(ceil(hp / GameData.apply_defense(130.0, def))) == 4,
		"brutamontes mata a ficha de referencia em 4 golpes")
	_check(int(ceil(hp / GameData.apply_defense(55.0, def))) == 12,
		"lanceiro mata a ficha de referencia em 12 golpes")

	# E o que isso da nas fichas reais do WP3, so para ficar registado.
	var w_hp := GameData.max_health_for(int(warrior.get("vida")))
	var w_def := GameData.defense_for(int(warrior.get("constituicao")))
	var w_brute := int(ceil(w_hp / GameData.apply_defense(130.0, w_def)))
	_check(w_brute >= 4 and w_brute <= 5,
		"Guerreiro do WP3 (%d PV) aguenta %d golpes do brutamontes" % [int(w_hp), w_brute])


# --- contrato que o WP1 impoe ao WP6 ------------------------------------------

func _test_enemy_contract() -> void:
	for id: String in ["orc_spearman", "orc_brute", "vorgar"]:
		var e := GameData.enemy(id)
		for a: Variant in e.get("attacks", []):
			var atk := a as Dictionary
			var startup := int(atk.get("startup", 0))
			_check(startup >= 30, "%s/%s telegrafa %d f = %.2f s (minimo 30 f)"
				% [id, atk.get("id"), startup, GameData.frames_to_seconds(float(startup))])
		_check(float(e.get("chase_speed", 99.0)) < 5.0,
			"%s persegue a %.1f m/s (< 5,0 do correr)" % [id, e.get("chase_speed")])

	var brute := GameData.enemy("orc_brute")
	var all_parryable := true
	for a: Variant in brute.get("attacks", []):
		if not bool((a as Dictionary).get("parryable", false)):
			all_parryable = false
	_check(all_parryable, "brutamontes: TODOS os golpes aparaveis (e o professor de parry)")

	# A fase 2 do Vorgar muda padroes, nao numeros.
	var v := GameData.enemy("vorgar")
	var phases: Dictionary = v.get("phases", {})
	var p1: Array = (phases.get("1", {}) as Dictionary).get("patterns", [])
	var p2: Array = (phases.get("2", {}) as Dictionary).get("patterns", [])
	_check(p1 != p2, "Vorgar: a fase 2 tem padroes diferentes")
	var longest_1 := 0
	var longest_2 := 0
	for pat: Variant in p1:
		longest_1 = maxi(longest_1, (pat as Array).size())
	for pat: Variant in p2:
		longest_2 = maxi(longest_2, (pat as Array).size())
	_check(longest_2 > longest_1, "Vorgar: cadeias mais longas na fase 2 (%d vs %d)" % [longest_2, longest_1])


# --- spec/67-catalogo-do-bestiario.md · WP6 completo -------------------------

func _test_bestiary_catalogue() -> void:
	const CONTACT_TYPES: Array[String] = ["instantaneo", "volume_movel", "volume_persistente"]
	const ESCAPE_VECTORS: Array[String] = ["sair_da_linha", "rolar_para_dentro",
		"rolar_para_fora", "afastar_se", "aproximar_se", "quebrar_a_visao",
		"sair_da_area", "aparar", "bloquear_e_aguentar"]
	const VISUAL_CUE_FIELDS: Array[String] = ["ancora", "forma", "inicio",
		"compromisso", "fim", "fora_ecra"]

	var common_ids: Array[String] = []
	var represented_races := {}
	var attack_count := 0
	var slice_ids: Array[String] = []
	for id: String in GameData.enemies.keys():
		if id.begins_with("_"):
			continue
		var e: Dictionary = GameData.enemy(id)
		for field: String in ["display_name", "race_id", "biome_ids", "role", "mass_kg",
				"souls", "descricao_visual", "fatia_1", "attacks"]:
			_check(e.has(field), "%s: ficha de inimigo tem '%s'" % [id, field])
		if bool(e.get("is_boss", false)):
			continue
		common_ids.append(id)
		represented_races[String(e.get("race_id", ""))] = true
		if bool(e.get("fatia_1", false)):
			slice_ids.append(id)
		_check(float(e.get("mass_kg", 0.0)) > 0.0, "%s: massa positiva para empurrao" % id)
		_check(int(e.get("souls", 0)) > 0, "%s: almas por derrota declaradas" % id)
		_check(String(e.get("descricao_visual", "")).length() >= 45,
			"%s: descricao visual especifica" % id)
		var deck: Dictionary = e.get("loot_deck", {}) as Dictionary
		var cards: Array = deck.get("cards", []) as Array
		_check(cards.size() == 10, "%s: baralho tem exactamente 10 cartas" % id)
		_check(bool(deck.get("without_replacement", false)),
			"%s: baralho compra sem reposicao" % id)
		var mandatory: Array = deck.get("mandatory_indices", []) as Array
		_check(not mandatory.is_empty(), "%s: baralho garante o equipamento visivel" % id)
		for card_index: Variant in mandatory:
			_check(int(card_index) >= 0 and int(card_index) < cards.size(),
				"%s: indice obrigatorio %s pertence ao baralho" % [id, card_index])

		var attacks: Array = e.get("attacks", []) as Array
		_check(attacks.size() >= 3 and attacks.size() <= 5,
			"%s: inimigo comum tem 3-5 ataques" % id)
		var questions := {}
		for attack_value: Variant in attacks:
			var attack: Dictionary = attack_value as Dictionary
			attack_count += 1
			var attack_label := "%s/%s" % [id, attack.get("id", "?")]
			for field: String in ["display_name", "fase_1", "fase_2", "fase_3", "fases_4_5",
					"startup", "active", "recovery", "aviso_total_frames", "parryable",
					"vectores_fuga", "som_anuncio", "sinal_visual_equivalente", "alcance_arco",
					"janela_castigo_frames", "tipo_contacto", "momento_compromisso_frame",
					"curva_seguimento", "pergunta"]:
				_check(attack.has(field), "%s: ataque tem '%s'" % [attack_label, field])
			_check(int(attack.get("aviso_total_frames", 0)) == int(attack.get("startup", -1)),
				"%s: aviso total coincide com fases 1+2" % attack_label)
			_check(CONTACT_TYPES.has(String(attack.get("tipo_contacto", ""))),
				"%s: tipo de contacto valido" % attack_label)
			var vectors: Array = attack.get("vectores_fuga", []) as Array
			_check(vectors.size() >= 1 and vectors.size() <= 2,
				"%s: declara um ou dois vectores de fuga" % attack_label)
			for vector: Variant in vectors:
				_check(ESCAPE_VECTORS.has(String(vector)),
					"%s: vector '%s' pertence aos nove" % [attack_label, vector])
			var sound: Dictionary = attack.get("som_anuncio", {}) as Dictionary
			_check(String(sound.get("cue_id", "")) != "" and String(sound.get("descricao", "")).length() >= 12,
				"%s: som proprio e descritivo" % attack_label)
			var visual: Dictionary = attack.get("sinal_visual_equivalente", {}) as Dictionary
			for visual_field: String in VISUAL_CUE_FIELDS:
				_check(String(visual.get(visual_field, "")) != "",
					"%s: sinal visual declara '%s'" % [attack_label, visual_field])
			var tracking: Dictionary = attack.get("curva_seguimento", {}) as Dictionary
			_check(float(tracking.get("fase_3_deg_s", -1.0)) == 0.0,
				"%s: seguimento para no golpe" % attack_label)
			questions[String(attack.get("pergunta", ""))] = true
		_check(questions.size() >= 3, "%s: os ataques fazem tres perguntas diferentes" % id)

	_check(common_ids.size() == 33, "bestiario: 33 tipos comuns dentro da conta 30-36")
	_check(attack_count >= 99, "bestiario: pelo menos 99 fichas completas de ataque")
	_check(slice_ids == ["orc_spearman", "orc_brute"],
		"fatia 1 do bestiario comum = lanceiro + brutamontes")
	for race_id: String in ["orcs", "goblins", "kobolds", "esqueletos", "zumbis",
			"minotauros", "teceloes", "ventaneiras", "borralheiros", "submersos",
			"penitentes", "sem_rosto"]:
		_check(represented_races.has(race_id), "bestiario representa a raca '%s'" % race_id)

	var zones: Dictionary = GameData.enemies.get("_zone_budgets", {}) as Dictionary
	_check(zones.size() == 12, "bestiario: total de almas nas 12 zonas")
	for biome_id: String in GameData.biome_ids():
		var zone: Dictionary = zones.get(biome_id, {}) as Dictionary
		var population: Dictionary = zone.get("population", {}) as Dictionary
		var computed_first_clear := 0
		for enemy_id: String in population.keys():
			_check(common_ids.has(enemy_id), "%s: populacao referencia '%s' valido" % [biome_id, enemy_id])
			computed_first_clear += int(population[enemy_id]) * int(GameData.enemy(enemy_id).get("souls", 0))
		_check(computed_first_clear == int(zone.get("souls_first_clear", -1)),
			"%s: total da primeira limpeza = %d almas" % [biome_id, computed_first_clear])
		_check(computed_first_clear * 10 == int(zone.get("souls_ten_rewarded_clears", -1)),
			"%s: orcamento fechado das dez limpezas" % biome_id)


func _test_bestiary_runtime() -> void:
	var first := GameData.loot_draw_order("orc_spearman", 42)
	var repeated := GameData.loot_draw_order("orc_spearman", 42)
	var other_seed := GameData.loot_draw_order("orc_spearman", 43)
	_check(first == repeated, "baralho: a mesma semente repete exactamente a ordem")
	_check(first != other_seed, "baralho: outra semente pode mudar a ordem")
	_check(first.size() == 10 and first.duplicate().size() == 10,
		"baralho: ordenar nao perde nenhuma das dez cartas")

	var profiles := {}
	for enemy_id: String in GameData.enemies.keys():
		if enemy_id.begins_with("_"):
			continue
		for attack_value: Variant in GameData.enemy(enemy_id).get("attacks", []):
			var attack := attack_value as Dictionary
			profiles[String((attack.get("som_anuncio", {}) as Dictionary).get("profile", ""))] = true
	_check(profiles.size() == 5, "GameplayCue: cinco familias sonoras apresentam os ataques")

	# O ensaio headless não abre um viewport 3D; prova aqui que o renderer comum
	# é construível. A ancoragem e o relógio são exercitados na arena visual.
	var cue: Node = GameplayCueRenderer.new()
	_check(cue != null, "GameplayCue: renderer comum e construivel em headless")
	cue.free()


# --- spec/01-combate.md · Movimento -------------------------------------------

func _test_movement_speeds() -> void:
	var m := GameData.section("movement")
	_check(float(m.get("walk_speed")) == 3.0, "andar 3,0 m/s")
	_check(float(m.get("run_speed")) == 5.0, "correr 5,0 m/s")
	_check(float(m.get("sprint_speed")) == 7.0, "sprint 7,0 m/s")
	_check(float(m.get("strafe_speed")) == 4.0, "strafe 4,0 m/s")
	_check(float(m.get("sprint_stamina_per_second")) == 8.0, "sprint custa 8 stamina/s")
	_check(absf(float(m.get("cast_move_multiplier")) - 0.40) < 0.001, "conjurar trava o movimento a 40%")

	var l := GameData.section("lock_on")
	_check(float(l.get("engage_range")) == 18.0, "lock-on engata a 18 m")
	_check(float(l.get("break_range")) == 25.0, "lock-on quebra a 25 m")
	_check(bool(l.get("auto_reacquire")) == false, "lock-on NAO re-engata sozinho")


# --- utilidades ---------------------------------------------------------------

func _make_player() -> Player:
	var p := Player.new()
	p.setup("warrior", {})
	add_child(p)
	return p


func _catalogue_attack(enemy_id: String, attack_id: String) -> Dictionary:
	for attack_value: Variant in GameData.enemy(enemy_id).get("attacks", []):
		var attack := attack_value as Dictionary
		if String(attack.get("id", "")) == attack_id:
			return attack
	return {}


func _remove_save_artifacts(path: String) -> void:
	for suffix: String in ["", ".tmp", ".bak", ".corrupt"]:
		var absolute := ProjectSettings.globalize_path(path + suffix)
		if FileAccess.file_exists(path + suffix):
			DirAccess.remove_absolute(absolute)


func _check(condition: bool, description: String) -> void:
	if condition:
		_passed += 1
		print("  ok    %s" % description)
	else:
		_failed += 1
		printerr("  FALHA %s" % description)


func _report() -> void:
	print("\n=== %d passaram, %d falharam ===\n" % [_passed, _failed])
	get_tree().quit(1 if _failed > 0 else 0)
