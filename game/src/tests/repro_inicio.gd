extends Node
## Reproducao do que o Mateus faz: escolher classe -> iniciar jogo.
## Corre com:  godot --headless --path game/ scenes/repro-inicio.tscn
##
## Existe porque o jogo fechava neste ponto e o auto-teste NAO apanhava: o
## auto-teste valida dados e contratos, nao INSTANCIA a casca nem a cena de
## jogo. Um teste que nunca abre o jogo nao prova que o jogo abre.

const GAMEPLAY := preload("res://scenes/gameplay.tscn")
const REGRA_DE_OURO_GUARD := preload("res://src/tests/regra_de_ouro_guard.gd")
const ISOLATED_GOLDEN_RULE_ARG := "--regra-de-ouro-isolada"

var _test_slot_base := 100000 + OS.get_process_id() * 100
var _test_slots: Array[int] = []


func _ready() -> void:
	# ⚠️ ESTE TESTE NAO PODE OCUPAR OS SLOTS DO JOGADOR.
	# Ja aconteceu (01-08): escreveu nos tres slots da pasta real e o Mateus
	# ficou sem conseguir comecar jogo nenhum — o ecra dizia "os tres slots
	# estao ocupados", e fazia bem, porque este fluxo nunca substitui um save.
	# Todas as arvores de trabalho partilham a MESMA pasta user:// porque tem o
	# mesmo nome de projecto. Logo: limpa o que escreveste, sempre.
	# Tenta TODAS as origens, nao so a primeira: o Mateus escolhe a dele.
	var origens := GameShell.CLASS_IDS
	for i in origens.size():
		var origem: String = origens[i]
		print("[repro] 1.%d new_game(%s)" % [i, origem])
		var slot := _test_slot_base + i
		_test_slots.append(slot)
		var ok: bool = SaveSystem.new_game("repro-" + origem, origem, slot, {
			"name": "R", "appearance": {},
		})
		if not ok:
			_falhar("new_game(%s): %s" % [origem, SaveSystem.last_error])
			return

	print("[repro] 2. a instanciar a casca (GameShell)")
	var casca := GameShell.new()
	add_child(casca)
	print("[repro] 3. casca viva")
	var golden_rule_errors := REGRA_DE_OURO_GUARD.contract_errors()
	if not golden_rule_errors.is_empty():
		_falhar("Regra de Ouro violada: %s" % " | ".join(golden_rule_errors))
		return

	# ⭐ Navegar os ecras E VOLTAR ATRAS e o que apanha o defeito do fecho: era
	# aqui que o jogo morria, porque cada troca de ecra libertava o botao que
	# ainda estava a emitir o sinal.
	print("[repro] 3b. a saltar entre ecras (menu <-> criacao <-> opcoes)")
	for volta in 3:
		casca.show_main_menu()
		casca.show_character_creation()
		casca.show_main_menu()
	print("[repro] 3c. sobreviveu a %d trocas de ecra" % 9)
	if not await _provar_catalogos_no_ecra(casca):
		return
	print("[repro] 3d. a escolher evil_mage para a prova de necromancia")
	var evil_mage_slot := _test_slot_base + origens.size()
	_test_slots.append(evil_mage_slot)
	if not SaveSystem.new_game("repro-evil-mage", "evil_mage", evil_mage_slot, {
			"name": "Mateus", "appearance": {},
		}):
		_falhar("new_game(evil_mage): %s" % SaveSystem.last_error)
		return

	print("[repro] 3e. a ABERTURA (show_opening)")
	casca.show_opening()
	await get_tree().process_frame
	var opening_story := String((GameData.ui_strings.get("opening", {}) as Dictionary)[
		"story_bbcode"])
	var opening_visible := false
	var opening_screen := casca.get("_screen") as Control
	for node: Node in opening_screen.find_children("*", "RichTextLabel", true, false):
		var label := node as RichTextLabel
		if label != null and label.is_visible_in_tree() and label.text == opening_story:
			opening_visible = true
			break
	if not opening_visible:
		_falhar("a abertura não mostrou no ecrã o texto vindo do catálogo")
		return
	print("[repro] 3f. abertura viva")

	print("[repro] 4. a instanciar a cena de jogo")
	var jogo: Node = GAMEPLAY.instantiate()
	# Permite diagnosticar esta prova sem as outras provas que partilham a cena.
	# VERIFICAR.bat continua a correr o modo completo, sem este argumento.
	if ISOLATED_GOLDEN_RULE_ARG in OS.get_cmdline_user_args():
		get_tree().root.add_child(jogo)
		get_tree().current_scene = jogo
	else:
		add_child(jogo)
	print("[repro] 5. cena de jogo instanciada")
	await _provar_necromancia_em_jogo(jogo)


func _provar_catalogos_no_ecra(casca: GameShell) -> bool:
	casca.show_character_creation()
	await get_tree().process_frame
	var display_name := String(GameData.class_attributes("evil_mage")["display_name"])
	var class_button: Button
	var screen := casca.get("_screen") as Control
	for node: Node in screen.find_children("*", "Button", true, false):
		var button := node as Button
		if button != null and button.text == display_name:
			class_button = button
			break
	if class_button == null:
		_falhar("evil_mage existe no catálogo, mas não apareceu na criação")
		return false
	class_button.grab_focus()
	await get_tree().process_frame
	var press := InputEventAction.new()
	press.action = "ui_accept"
	press.pressed = true
	Input.parse_input_event(press)
	await get_tree().process_frame
	var release := InputEventAction.new()
	release.action = "ui_accept"
	release.pressed = false
	Input.parse_input_event(release)
	await get_tree().process_frame
	var detail := casca.get("_detail") as RichTextLabel
	var role := (GameData.ui_strings.get("class_roles", {}) as Dictionary)[
		"evil_mage"] as Array
	if detail == null or not detail.is_visible_in_tree():
		_falhar("seleccionar evil_mage não deixou uma descrição visível")
		return false
	for role_line: Variant in role:
		if not detail.text.contains(String(role_line)):
			_falhar("o papel de evil_mage ficou vazio ou desligado do catálogo no ecrã")
			return false
	print("[repro] 3c. criação mostrou evil_mage e as três linhas do catálogo")
	return true


func _provar_necromancia_em_jogo(jogo: Node) -> void:
	for _frame: int in 3:
		await get_tree().physics_frame
	var jogador := jogo.get("player") as Player
	if jogador == null or jogador.class_id != "evil_mage":
		_falhar("a cena real nao arrancou com evil_mage")
		return
	var ability: Dictionary = GameData.ability("evil_mage")
	var raise_action := String(ability.get("raise_input_action", ""))
	if raise_action.is_empty() or not InputMap.has_action(raise_action) \
			or InputMap.action_get_events(raise_action).is_empty():
		_falhar("evil_mage nao declara uma accao remapeavel para Levantar")
		return
	var runtime := jogo.get("necromancy_runtime") as NecromancyRuntime
	if runtime == null:
		_falhar("a cena real nao instancia NecromancyRuntime")
		return
	var vivos := await _caminhar_ate_encontros(jogador)
	if vivos.size() < 2:
		_falhar("andar pelo caminho não materializou dois inimigos comuns")
		return
	for enemy: Enemy in vivos:
		enemy.set_physics_process(false)
	var isolated_golden_rule := ISOLATED_GOLDEN_RULE_ARG in OS.get_cmdline_user_args()
	if isolated_golden_rule:
		if not await _provar_ataque_do_catalogo(jogador, vivos[0]):
			return
	if not await _provar_voto_sangue_em_jogo(jogo, jogador, runtime, vivos[0]):
		return
	var shared_boss := jogo.get("boss") as Enemy
	var shared_boss_health := shared_boss.health if shared_boss != null else 0.0
	var corpo_futuro := vivos[0]
	var alvo_do_aliado := vivos[1]
	corpo_futuro.set_physics_process(false)
	alvo_do_aliado.set_physics_process(false)
	corpo_futuro.global_position = jogador.global_position \
		- jogador.global_transform.basis.z * 1.5
	alvo_do_aliado.global_position = jogador.global_position \
		- jogador.global_transform.basis.z * 7.0
	corpo_futuro.take_damage(DamageInfo.make(
		corpo_futuro.health + 1.0, jogador, "light"))
	await get_tree().process_frame
	if runtime.corpse_count() != 1:
		_falhar("matar um inimigo nao deixou um corpo reclamavel no mundo")
		return
	var health_before := jogador.health
	var max_health_before := jogador.max_health
	Input.action_press(raise_action)
	await get_tree().physics_frame
	await get_tree().process_frame
	Input.action_release(raise_action)
	for _frame: int in 3:
		await get_tree().physics_frame
	if runtime.summon_count() != 1:
		_falhar("carregar em %s nao levantou o corpo" % raise_action)
		return
	var aliado := runtime.summons()[0]
	if aliado.is_in_group("enemies") or not aliado.is_in_group("summons"):
		_falhar("o levantado entrou no lado hostil ou ficou sem lado aliado")
		return
	if jogador.health >= health_before or jogador.max_health >= max_health_before:
		_falhar("Levantar nao retirou PV visiveis ao jogador")
		return
	if not isolated_golden_rule and not await _observar_ataque_partilhado(
			jogo, jogador, shared_boss, shared_boss_health):
		return
	var ally_start := aliado.global_position
	var targeted_hostile := false
	var movement_observed := 0.0
	for _frame: int in 180:
		await get_tree().physics_frame
		targeted_hostile = targeted_hostile or aliado.target == alvo_do_aliado
		movement_observed = maxf(movement_observed,
			aliado.global_position.distance_to(ally_start))
		if targeted_hostile and movement_observed > 0.25:
			break
	if not targeted_hostile or movement_observed <= 0.25:
		_falhar("o aliado levantado existe, mas nao anda para lutar no mundo")
		return
	print("[repro] 6. evil_mage matou, carregou em %s e o aliado andou %.2f m" % [
		raise_action, movement_observed])

	# O caminho negativo usa outro corpo real: sem PV, o corpo fica e o HUD
	# explica a recusa em vez de fingir que a tecla nao fez nada.
	aliado.set_physics_process(false)
	var segundo_corpo := vivos[1]
	segundo_corpo.set_physics_process(false)
	segundo_corpo.global_position = jogador.global_position \
		- jogador.global_transform.basis.z * 1.5
	if segundo_corpo.is_alive():
		segundo_corpo.take_damage(DamageInfo.make(
			segundo_corpo.health + 1.0, jogador, "light"))
	await get_tree().process_frame
	var summon_count_before := runtime.summon_count()
	jogador.health = 1.0
	Input.action_press(raise_action)
	await get_tree().physics_frame
	await get_tree().process_frame
	Input.action_release(raise_action)
	await get_tree().process_frame
	var feedback: Dictionary = ability.get("raise_feedback", {}) as Dictionary
	var hud := jogo.get("hud") as Hud
	var toast := hud.get("_toast") as Label if hud != null else null
	if runtime.summon_count() != summon_count_before \
			or runtime.corpse_count() != 1 or not is_equal_approx(jogador.health, 1.0):
		_falhar("Levantar consumiu corpo ou PV sem vida suficiente")
		return
	if toast == null or toast.text != String(feedback.get(
			"insufficient_current_health", "")):
		_falhar("o ecra nao explicou a falta de PV para Levantar")
		return
	print("[repro] 7. PV insuficientes recusaram Levantar com explicacao no ecra")
	GameData.replace_save_state({})
	_limpar_slots_de_teste()
	print("=== ARRANQUE + NECROMANCIA OK ===")
	get_tree().quit(0)


func _provar_voto_sangue_em_jogo(jogo: Node, jogador: Player,
		runtime: NecromancyRuntime, alvo: Enemy) -> bool:
	var hud := jogo.get("hud") as Hud
	var health_text := hud.get("_info") as Label if hud != null else null
	var enemy_hud := get_tree().current_scene.get_node_or_null("EnemyHud") as EnemyHud
	var enemy_panel := enemy_hud.get("_target_group") as Control \
		if enemy_hud != null else null
	var enemy_bar := enemy_hud.get("_health_fill") as ColorRect \
		if enemy_hud != null else null
	var enemy_name := enemy_hud.get("_target_name") as Label \
		if enemy_hud != null else null
	if alvo == null or health_text == null or enemy_panel == null \
			or enemy_bar == null or enemy_name == null:
		_falhar("a prova do Voto nao encontrou o mesmo inimigo e as barras visiveis")
		return false
	if not InputMap.has_action("cast") or InputMap.action_get_events("cast").is_empty():
		_falhar("o jogador nao tem uma tecla remapeavel para usar o Voto")
		return false

	var original_position := alvo.global_position
	var original_health := alvo.health
	var original_physics := alvo.is_physics_processing()
	var original_favorites := jogador.favorite_spells.duplicate()
	var original_selected := jogador.selected_spell
	var original_main_weapon := jogador.main_weapon
	var original_offhand_weapon := jogador.offhand_weapon
	var original_two_handed := jogador.is_two_handed
	var mage_loadout := (GameData.weapons.get("loadouts", {}) as Dictionary).get(
		"evil_mage", {}) as Dictionary
	jogador.main_weapon = Player.equipment_weapon_id(mage_loadout.get("main"))
	jogador.offhand_weapon = Player.equipment_weapon_id(mage_loadout.get("offhand"))
	jogador.is_two_handed = bool(jogador.call("_loadout_uses_two_hands",
		jogador.main_weapon, jogador.offhand_weapon))
	alvo.set_physics_process(false)
	var weapon := GameData.weapon(jogador.main_weapon)
	alvo.global_position = jogador.global_position \
		- jogador.global_transform.basis.z * float(weapon.get("range")) * 0.5
	alvo.health = alvo.max_health
	await get_tree().process_frame
	var full_bar_width := float(EnemyHud.BAR_WIDTH)
	var damage_without := await _golpear_como_jogador(jogador, alvo)
	await _esperar_barra_do_inimigo(enemy_bar, full_bar_width, false)
	var bar_loss_without := full_bar_width - enemy_bar.size.x
	print("[repro] Voto baseline: arma=%s dano=%.1f barra=%.1f->%.1f visivel=%s estado=%s" % [
		jogador.main_weapon, damage_without, full_bar_width, enemy_bar.size.x,
		str(enemy_panel.visible), jogador.state_name()])
	if damage_without <= 0.0 or bar_loss_without <= 0.0 \
			or not enemy_panel.visible or not enemy_name.text.contains(alvo.display_name().to_upper()):
		_falhar("sem Voto, carregar no ataque nao tirou PV na barra do inimigo")
		return false

	for _frame: int in 240:
		if jogador.state == Player.State.FREE:
			break
		await get_tree().physics_frame
	alvo.health = alvo.max_health
	await _esperar_barra_do_inimigo(enemy_bar, full_bar_width, true)
	var max_health_without := jogador.max_health
	var oath := GameData.spell("voto_sangue")
	var layers := (oath.get("effect", {}) as Dictionary).get("layers", []) as Array
	if layers.is_empty():
		_falhar("o catalogo nao declarou as camadas do Voto")
		return false
	# Fixture explícita: a origem promete o Voto, mas o save ainda entrega os
	# mesmos três favoritos globais a todas as origens. Essa lacuna de acesso
	# está em LACUNAS.md; daqui para a frente conjuração e golpes usam Input real.
	if not jogador.favorite_spells.has("voto_sangue"):
		jogador.favorite_spells.append("voto_sangue")
	if not jogador.select_spell("voto_sangue"):
		_falhar("o jogador nao conseguiu seleccionar o Voto equipado")
		return false
	var final_layer := layers.back() as Dictionary
	for layer_value: Variant in layers:
		var layer := layer_value as Dictionary
		var layer_expected_max := max_health_without * (1.0 - float(
			layer.get("health_cost_fraction_total", 0.0)))
		Input.action_press("cast")
		await get_tree().physics_frame
		Input.action_release("cast")
		for _frame: int in 240:
			await get_tree().physics_frame
			if jogador.state == Player.State.FREE \
					and is_equal_approx(jogador.max_health, layer_expected_max):
				break
		if not is_equal_approx(jogador.max_health, layer_expected_max):
			_falhar("carregar em cast nao aplicou todas as camadas do Voto")
			return false
	await get_tree().process_frame
	var expected_max := max_health_without * (1.0 - float(
		final_layer.get("health_cost_fraction_total", 0.0)))
	var visible_health := "%d/%d PV" % [int(jogador.health), int(jogador.max_health)]
	print("[repro] Voto custo: PV max %.1f->%.1f esperado=%.1f HUD=%s" % [
		max_health_without, jogador.max_health, expected_max, health_text.text])
	if not is_equal_approx(jogador.max_health, expected_max) \
			or not health_text.text.contains(visible_health):
		_falhar("carregar em cast cobrou o Voto, mas a perda de PV maximos nao apareceu no HUD")
		return false

	var damage_with := await _golpear_como_jogador(jogador, alvo)
	await _esperar_barra_do_inimigo(enemy_bar, full_bar_width, false)
	var bar_loss_with := full_bar_width - enemy_bar.size.x
	var expected_multiplier := 1.0 + float(final_layer.get(
		"damage_bonus_fraction_total", 0.0))
	print("[repro] Voto beneficio: dano %.1f->%.1f esperado=%.1f barra=%.1f->%.1f" % [
		damage_without, damage_with, damage_without * expected_multiplier,
		bar_loss_without, bar_loss_with])
	if not is_equal_approx(damage_with, damage_without * expected_multiplier) \
			or bar_loss_with <= bar_loss_without:
		_falhar("o Voto cobrou PV maximos, mas o mesmo golpe nao tirou mais PV visiveis")
		return false

	print("[repro] 5b. Voto por tecla: PV max %.1f->%.1f; mesmo golpe %.1f->%.1f" % [
		max_health_without, jogador.max_health, damage_without, damage_with])
	for _frame: int in 240:
		if jogador.state == Player.State.FREE and jogador.hitstop_frames <= 0:
			break
		await get_tree().physics_frame
	runtime.rest()
	jogador.health = jogador.max_health
	jogador.favorite_spells.assign(original_favorites)
	jogador.selected_spell = original_selected
	jogador.main_weapon = original_main_weapon
	jogador.offhand_weapon = original_offhand_weapon
	jogador.is_two_handed = original_two_handed
	alvo.health = original_health
	alvo.global_position = original_position
	alvo.set_physics_process(original_physics)
	await get_tree().process_frame
	return true


func _golpear_como_jogador(jogador: Player, alvo: Enemy) -> float:
	for _frame: int in 240:
		if jogador.state == Player.State.FREE and jogador.hitstop_frames <= 0:
			break
		await get_tree().physics_frame
	var health_before := alvo.health
	Input.action_release("attack")
	Input.action_release("heavy_mod")
	await get_tree().physics_frame
	await get_tree().process_frame
	Input.action_press("heavy_mod")
	Input.action_press("attack")
	await get_tree().physics_frame
	await get_tree().process_frame
	Input.action_release("attack")
	Input.action_release("heavy_mod")
	var heavy := (GameData.weapon(jogador.main_weapon).get("heavy", {}) as Dictionary)
	var frames_to_watch := int(heavy.get("startup", 0)) \
		+ int(heavy.get("active", 0)) + int(heavy.get("recovery", 0))
	for _frame: int in frames_to_watch:
		await get_tree().physics_frame
		if alvo.health < health_before:
			break
	return health_before - alvo.health


func _esperar_barra_do_inimigo(bar: ColorRect, full_width: float,
		expect_full: bool) -> void:
	for _frame: int in 30:
		await get_tree().process_frame
		var is_full := is_equal_approx(bar.size.x, full_width)
		if is_full == expect_full:
			return
		await get_tree().physics_frame


func _caminhar_ate_encontros(jogador: Player) -> Array[Enemy]:
	var vivos: Array[Enemy] = []
	var start_position := jogador.global_position
	var maximum_seen := 0
	Input.action_press("move_forward")
	Input.action_press("dodge_sprint")
	for _frame: int in 900:
		await get_tree().physics_frame
		vivos.clear()
		for node: Node in get_tree().get_nodes_in_group("enemies"):
			var enemy := node as Enemy
			if enemy != null and enemy.is_alive() and not enemy.is_boss:
				vivos.append(enemy)
		maximum_seen = maxi(maximum_seen, vivos.size())
		if vivos.size() >= 2:
			break
	Input.action_release("move_forward")
	Input.action_release("dodge_sprint")
	await get_tree().physics_frame
	if vivos.size() >= 2:
		print("[repro] 5a. movimento real encontrou %d inimigos no caminho" % vivos.size())
	elif not jogador.input_enabled:
		print("[repro] 5a. outra prova deixou o input do jogador desligado")
	else:
		print("[repro] 5a. caminho %.1f m; máximo de %d inimigos; de %s para %s" % [
			start_position.distance_to(jogador.global_position), maximum_seen,
			str(start_position), str(jogador.global_position)])
	return vivos


func _provar_ataque_do_catalogo(jogador: Player, alvo: Enemy) -> bool:
	var weapon := GameData.weapon(jogador.main_weapon)
	var heavy := weapon["heavy"] as Dictionary
	alvo.set_physics_process(false)
	alvo.global_position = jogador.global_position \
		- jogador.global_transform.basis.z * float(weapon["range"]) * 0.5
	var health_before := alvo.health
	for _frame: int in 180:
		if jogador.state == Player.State.FREE:
			break
		await get_tree().physics_frame
	if jogador.state != Player.State.FREE:
		_falhar("o jogador não recuperou controlo para executar o ataque")
		return false
	Input.action_release("attack")
	Input.action_release("heavy_mod")
	await get_tree().physics_frame
	Input.action_press("heavy_mod")
	Input.action_press("attack")
	await get_tree().physics_frame
	await get_tree().process_frame
	Input.action_release("attack")
	Input.action_release("heavy_mod")
	var saw_catalogue_animation := false
	var visual := jogador.get("_visual") as CharacterVisual
	var frames_to_watch := int(heavy["startup"]) + int(heavy["active"]) \
		+ int(heavy["recovery"])
	for _frame: int in frames_to_watch:
		await get_tree().process_frame
		if visual != null and visual.is_visible_in_tree() \
				and visual.current_animation_name().begins_with("weapon_attacks/"):
			saw_catalogue_animation = true
		await get_tree().physics_frame
	if not saw_catalogue_animation:
		_falhar("carregar em ataque pesado não mostrou a animação da família do catálogo")
		return false
	if alvo.health >= health_before:
		_falhar("a animação apareceu, mas o golpe real não acertou no inimigo visível")
		return false
	for _frame: int in int(heavy["recovery"]):
		if jogador.state == Player.State.FREE:
			break
		await get_tree().physics_frame
	if jogador.state != Player.State.FREE:
		_falhar("o golpe acertou, mas não devolveu controlo depois da recuperação catalogada")
		return false
	print("[repro] 5b. tecla de ataque mostrou %s e acertou no inimigo" % String(
		weapon["familia"]))
	return true


func _observar_ataque_partilhado(jogo: Node, jogador: Player, boss: Enemy,
		health_before: float) -> bool:
	var hud := jogo.get("hud") as Hud
	var boss_bar := hud.get("_boss_bar") as ColorRect if hud != null else null
	if boss == null or boss_bar == null:
		_falhar("a prova partilhada não encontrou chefe e barra visível")
		return false
	var saw_catalogue_animation := false
	var saw_visible_damage := false
	var visual := jogador.get("_visual") as CharacterVisual
	for _frame: int in 900:
		await get_tree().process_frame
		if visual != null and visual.is_visible_in_tree() \
				and visual.current_animation_name().begins_with("weapon_attacks/"):
			saw_catalogue_animation = true
		if boss.health < health_before and (boss_bar.visible or not boss.is_alive()):
			saw_visible_damage = true
		if saw_catalogue_animation and saw_visible_damage:
			break
		await get_tree().physics_frame
	if not saw_catalogue_animation or not saw_visible_damage:
		_falhar("a tecla de ataque da prova partilhada não mostrou animação catalogada " \
			+ "e dano na barra do chefe")
		return false
	print("[repro] 5b. ataque partilhado mostrou animação catalogada e reduziu o chefe")
	return true


func _falhar(message: String) -> void:
	printerr("[repro] FALHOU: %s" % message)
	GameData.replace_save_state({})
	_limpar_slots_de_teste()
	get_tree().quit(1)


## Apaga os saves que este teste criou. Sem isto, o jogador fica sem slots.
func _limpar_slots_de_teste() -> void:
	var apagados := 0
	for slot: int in _test_slots:
		for caminho: String in [SaveSystem.slot_path(slot), SaveSystem.slot_path(slot) + ".bak"]:
			if FileAccess.file_exists(caminho):
				DirAccess.remove_absolute(ProjectSettings.globalize_path(caminho))
				apagados += 1
	_test_slots.clear()
	print("[repro] 7. slots de teste apagados: %d" % apagados)
