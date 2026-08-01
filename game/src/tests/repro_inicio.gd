extends Node
## Reproducao do que o Mateus faz: escolher classe -> iniciar jogo.
## Corre com:  godot --headless --path game/ scenes/repro-inicio.tscn
##
## Existe porque o jogo fechava neste ponto e o auto-teste NAO apanhava: o
## auto-teste valida dados e contratos, nao INSTANCIA a casca nem a cena de
## jogo. Um teste que nunca abre o jogo nao prova que o jogo abre.

const GAMEPLAY := preload("res://scenes/gameplay.tscn")


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
		var slot: int = i - (i / 3) * 3
		var ok: bool = SaveSystem.new_game("repro-" + origem, origem, slot, {
			"name": "R", "appearance": {},
		})
		if not ok:
			printerr("[repro] FALHOU em new_game(%s): %s" % [origem, SaveSystem.last_error])
			get_tree().quit(1)
			return

	print("[repro] 2. a instanciar a casca (GameShell)")
	var casca := GameShell.new()
	add_child(casca)
	print("[repro] 3. casca viva")

	# ⭐ Navegar os ecras E VOLTAR ATRAS e o que apanha o defeito do fecho: era
	# aqui que o jogo morria, porque cada troca de ecra libertava o botao que
	# ainda estava a emitir o sinal.
	print("[repro] 3b. a saltar entre ecras (menu <-> criacao <-> opcoes)")
	for volta in 3:
		casca.show_main_menu()
		casca.show_character_creation()
		casca.show_main_menu()
	print("[repro] 3c. sobreviveu a %d trocas de ecra" % 9)
	print("[repro] 3d. a escolher evil_mage para a prova de necromancia")
	if not SaveSystem.new_game("repro-evil-mage", "evil_mage", 0, {
			"name": "Mateus", "appearance": {},
		}):
		_falhar("new_game(evil_mage): %s" % SaveSystem.last_error)
		return

	print("[repro] 3e. a ABERTURA (show_opening)")
	casca.show_opening()
	print("[repro] 3f. abertura viva")

	print("[repro] 4. a instanciar a cena de jogo")
	var jogo: Node = GAMEPLAY.instantiate()
	add_child(jogo)
	print("[repro] 5. cena de jogo instanciada")
	await _provar_necromancia_em_jogo(jogo)


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
	var vivos: Array[Enemy] = []
	for node: Node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy != null and enemy.is_alive() and not enemy.is_boss:
			vivos.append(enemy)
	if vivos.size() < 3:
		_falhar("a reproducao precisa de tres inimigos comuns vivos")
		return
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
	var distance_before := aliado.global_position.distance_to(
		alvo_do_aliado.global_position)
	for _frame: int in 45:
		await get_tree().physics_frame
	var distance_after := aliado.global_position.distance_to(
		alvo_do_aliado.global_position)
	if distance_after >= distance_before:
		_falhar("o aliado levantado existe, mas nao anda para lutar no mundo")
		return
	print("[repro] 6. evil_mage matou, carregou em %s e o aliado andou %.2f m" % [
		raise_action, distance_before - distance_after])

	# O caminho negativo usa outro corpo real: sem PV, o corpo fica e o HUD
	# explica a recusa em vez de fingir que a tecla nao fez nada.
	aliado.set_physics_process(false)
	var segundo_corpo := vivos[2]
	segundo_corpo.set_physics_process(false)
	segundo_corpo.global_position = jogador.global_position \
		- jogador.global_transform.basis.z * 1.5
	segundo_corpo.take_damage(DamageInfo.make(
		segundo_corpo.health + 1.0, jogador, "light"))
	await get_tree().process_frame
	var summon_count_before := runtime.summon_count()
	jogador.health = 1.0
	Input.action_press(raise_action)
	await get_tree().physics_frame
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
	_limpar_slots_de_teste()
	print("=== ARRANQUE + NECROMANCIA OK ===")
	get_tree().quit(0)


func _falhar(message: String) -> void:
	printerr("[repro] FALHOU: %s" % message)
	_limpar_slots_de_teste()
	get_tree().quit(1)


## Apaga os saves que este teste criou. Sem isto, o jogador fica sem slots.
func _limpar_slots_de_teste() -> void:
	var apagados := 0
	for slot in 3:
		for caminho: String in [SaveSystem.slot_path(slot), SaveSystem.slot_path(slot) + ".bak"]:
			if FileAccess.file_exists(caminho):
				DirAccess.remove_absolute(ProjectSettings.globalize_path(caminho))
				apagados += 1
	print("[repro] 7. slots de teste apagados: %d" % apagados)
