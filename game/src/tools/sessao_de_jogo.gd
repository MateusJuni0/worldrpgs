extends Node
## Joga uma sessão inteira e diz, passo a passo, o que funciona e o que não.
##
## Porque isto existe (02-08-2026): o Mateus disse *"joga tu e testa"*. Os testes
## que temos verificam contratos; o modo fotografia apanha poses paradas; o filme
## apanha um golpe. Faltava alguém sentar-se e **jogar**.
##
## Não é um teste que passa ou falha — é um RELATÓRIO. Cada passo diz OK ou FALHA
## com a razão, e no fim imprime a lista para o Codex arrumar um a um.
##
## Corre com:
##   godot --audio-driver Dummy --path . --rendering-method mobile scenes/sessao-de-jogo.tscn

const GAMEPLAY := preload("res://scenes/gameplay.tscn")

var _jogo: Node
var _jogador: Node3D
var _relatorio: Array[String] = []
var _falhas := 0


func _ready() -> void:
	_jogo = GAMEPLAY.instantiate()
	add_child(_jogo)
	_jogar.call_deferred()


func _diz(passo: String, ok: bool, detalhe := "") -> void:
	if not ok:
		_falhas += 1
	var marca := "  ok  " if ok else "FALHA "
	var linha := "%s %s%s" % [marca, passo, ("  — " + detalhe) if detalhe != "" else ""]
	_relatorio.append(linha)
	print("[sessao] ", linha)


func _jogar() -> void:
	await _esperar(120)

	_jogador = _jogo.get("player") as Node3D
	if _jogador == null:
		_diz("o jogo arranca com um jogador", false, "player é nulo")
		return _fim()
	_diz("o jogo arranca com um jogador", true,
		"origem %s" % String(_jogador.get("class_id")))

	await _passo_rede()
	await _passo_equipamento()
	await _passo_atacar()
	await _passo_inimigos()
	await _passo_item_rapido()
	await _passo_fogueira()
	await _passo_mundo()
	_fim()


## A entrada de rede nunca pode parecer clicável enquanto o rato está preso.
## A tecla indicada no HUD tem de abrir o menu real, não apenas libertar o rato.
func _passo_rede() -> void:
	var menu := _jogo.get("net_menu") as NetMenu
	var interface := _jogo.get("hud") as Hud
	var botao := interface.get_node_or_null("JogarADois") as Button \
		if interface != null else null
	var alcancavel := botao != null and botao.visible \
		and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE
	_diz("o botão Jogar a dois está alcançável", alcancavel,
		"rato livre e botão visível" if alcancavel else (
			"o rato está capturado enquanto o botão continua visível" if botao != null \
			and botao.visible else "a entrada de rede não apareceu"))
	if menu == null or botao == null:
		return

	botao.pressed.emit()
	await _esperar(2)
	var hospedar := menu.get("_host_button") as Button
	var entrar := menu.get("_join_button") as Button
	var menu_real := menu.visible and hospedar != null and hospedar.visible \
		and entrar != null and entrar.visible
	_diz("o botão abre o menu de rede real", menu_real,
		"Hospedar e Entrar visíveis" if menu_real \
		else "Hospedar e Entrar não ficaram disponíveis")
	_jogo.call("_toggle_network_menu")
	await _esperar(2)

	await _accionar("toggle_mouse")
	var tecla_abriu := menu.visible and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE
	_diz("a tecla de rede abre o menu e liberta o rato", tecla_abriu,
		"menu aberto e rato livre" if tecla_abriu \
		else "a tecla apenas libertou o rato sem abrir Jogar a dois")
	if menu.visible:
		_jogo.call("_toggle_network_menu")
		await _esperar(2)


## O que se leva na mão, e se bate certo com o que a interface diz.
func _passo_equipamento() -> void:
	var principal := String(_jogador.get("main_weapon"))
	var secundaria := String(_jogador.get("offhand_weapon"))
	_diz("arranca com arma na mão principal", principal != "", "main=%s" % principal)
	_diz("arranca com alguma coisa na secundária", secundaria != "", "offhand=%s" % secundaria)

	var pendurados: Array[String] = []
	var por_ver: Array[Node] = [_jogador]
	while not por_ver.is_empty():
		var no: Node = por_ver.pop_back()
		if no is BoneAttachment3D and no.get_child_count() > 0:
			pendurados.append((no as BoneAttachment3D).bone_name)
		for f in no.get_children():
			por_ver.append(f)
	_diz("há geometria pendurada no esqueleto", not pendurados.is_empty(),
		"ossos com coisa: %s" % ", ".join(pendurados))

	var visual := _jogador.get("_visual") as Node
	var estado := GameData.save_state_snapshot()
	var inventario: Dictionary = (estado.get("character", {}) as Dictionary).get(
		"inventory", {}) as Dictionary
	var esperada: Array = (inventario.get("equipment", {}) as Dictionary).get(
		"armor", []) as Array
	var visivel: Array = visual.call("equipped_piece_ids") as Array \
		if visual != null and visual.has_method("equipped_piece_ids") else []
	var faltam: Array[String] = []
	for peca: Variant in esperada:
		if not String(peca) in visivel:
			faltam.append(String(peca))
	_diz("a armadura equipada aparece no boneco",
		not esperada.is_empty() and faltam.is_empty(),
		"peças sem geometria: %s" % ", ".join(faltam) if not faltam.is_empty() \
		else "%d peça(s) equipadas e visíveis" % esperada.size())

	# ⚠️ Uma arma abaixo do requisito corta o dano: o jogador começa castigado.
	var aviso := String(_jogador.get("requirement_warning")) if "requirement_warning" in _jogador else ""
	_diz("a arma inicial cumpre o requisito da origem", aviso == "",
		aviso if aviso != "" else "sem penalização")


## Carregar em atacar tem de mudar a pose. Se não muda, não há combate.
func _passo_atacar() -> void:
	var visual: Node = _jogador.get("_visual") as Node
	var erros_catalogo := CharacterVisual.animation_catalogue_errors()
	var fronteira_catalogada := visual != null \
		and visual.has_method("play_state_animation") \
		and FileAccess.file_exists("res://data/animations.json") \
		and erros_catalogo.is_empty()
	_diz("os estados visuais obedecem ao catálogo de animações",
		fronteira_catalogada,
		"" if fronteira_catalogada \
		else "falta catálogo/API ou há erros: %s" % ", ".join(erros_catalogo))

	var antes := _pose()
	Input.action_press("attack")
	await _esperar(2)
	Input.action_release("attack")
	await _esperar(8)
	var meio := _pose()
	var animacao_do_golpe := _animacao_tocada()
	await _esperar(20)
	_diz("atacar muda a pose do boneco", antes != meio,
		"o esqueleto não se mexeu entre o repouso e o meio do golpe" if antes == meio else "")
	_diz("atacar com espada toca um golpe de espada, nunca um Punch",
		animacao_do_golpe.contains("Sword_Attack") and not animacao_do_golpe.contains("Punch"),
		"animação=%s" % animacao_do_golpe)

	var estado := String(_jogador.call("state_name")) \
		if _jogador.has_method("state_name") else "?"
	_diz("atacar entra em estado de ataque", estado != "?", "estado=%s" % estado)


## Os inimigos existem, atacam, e morrem sem ficar a mexer-se.
func _passo_inimigos() -> void:
	var inimigos := get_tree().get_nodes_in_group("enemies")
	_diz("há inimigos no mundo", not inimigos.is_empty(), "%d encontrados" % inimigos.size())
	if inimigos.is_empty():
		return

	var alvo: Node3D = inimigos[0] as Node3D
	if alvo == null:
		return
	await _provar_telegrafo(alvo)

	# Mata-o à força e vê o que acontece ao corpo — a queixa foi "morrem e
	# ficam-se a mexer, pretos".
	if alvo.has_method("take_damage"):
		var morte := DamageInfo.make(float(alvo.get("health")), _jogador, "heavy")
		alvo.call("take_damage", morte)
	await _esperar(60)

	var vivo := is_instance_valid(alvo)
	var pos_a := alvo.global_position if vivo else Vector3.ZERO
	await _esperar(60)
	var mexeu := vivo and alvo.global_position.distance_to(pos_a) > 0.05
	var morreu := vivo and alvo.has_method("is_alive") and not bool(alvo.call("is_alive"))
	_diz("o dano real mata o inimigo", morreu,
		"estado DEAD confirmado" if morreu else "a prova não chegou ao estado DEAD")
	_diz("o inimigo morto pára a IA e fica quieto", morreu and not mexeu \
		and not alvo.is_physics_processing(),
		"continuou a deslocar-se depois de morrer" if mexeu else "")

	var visual := alvo.get("_visual") as Node
	var animacao := String(visual.get("_current_animation")) if visual != null else ""
	var tinta: Variant = visual.get("_current_tint") if visual != null else null
	_diz("o cadáver toca Death01 uma vez", animacao.to_lower().contains("death"),
		"animação actual=%s" % animacao)
	var tinta_inteira := typeof(tinta) == TYPE_COLOR \
		and (tinta as Color).is_equal_approx(Color.WHITE)
	_diz("o cadáver não fica preto", tinta_inteira,
		"material conserva a cor" if tinta_inteira else "a morte escureceu o material")
	var placement_id := String(alvo.get_meta("placement_id", ""))
	_diz("o cadáver tem identidade para o descanso", placement_id != "",
		placement_id if placement_id != "" \
		else "sem placement_id a fogueira recusa depois de uma morte real")


## O aviso tem de existir durante o startup e antes de a vida descer.
func _provar_telegrafo(alvo: Node3D) -> void:
	var ficha: Dictionary = alvo.get("data") as Dictionary
	var ataques: Array = ficha.get("attacks", []) as Array
	if ataques.is_empty() or not alvo.has_method("_begin_attack"):
		_diz("o inimigo telegrafa antes de bater", false, "não há ataque executável")
		return
	var ataque := ataques[0] as Dictionary
	var posicao_jogador := _jogador.global_position
	var vida_original := float(_jogador.get("health"))
	_jogador.set("health", _jogador.get("max_health"))
	_jogador.global_position = alvo.global_position + Vector3(0.0, 0.1, -1.5)
	alvo.set("target", _jogador)
	alvo.look_at(_jogador.global_position, Vector3.UP)
	alvo.call("_begin_attack", ataque)
	await _esperar(2)
	var vida_antes := float(_jogador.get("health"))
	var anunciou := int(alvo.call("telegraphing_parryable")) >= 0 \
		and is_instance_valid(alvo.get("_active_gameplay_cue"))
	var nao_bateu_cedo := is_equal_approx(float(_jogador.get("health")), vida_antes)
	var startup := int(ataque.get("startup", 30))
	var activos := int(ataque.get("active", 6))
	await _esperar(startup + activos + 2)
	var bateu := float(_jogador.get("health")) < vida_antes
	_diz("o inimigo telegrafa o ataque antes de bater",
		anunciou and nao_bateu_cedo and bateu,
		"aviso=%s, dano antes=%s, dano depois=%s" % [
			anunciou, not nao_bateu_cedo, bateu])
	_jogador.global_position = posicao_jogador
	_jogador.set("health", vida_original)


## As ranhuras rápidas têm de ter coisas e a tecla tem de as usar.
func _passo_item_rapido() -> void:
	var frascos_antes := int(_jogador.get("flask_uses")) if "flask_uses" in _jogador else -1
	_diz("o jogador tem frascos", frascos_antes > 0, "frascos=%d" % frascos_antes)
	if frascos_antes <= 0:
		return
	# Perde vida primeiro, senão curar não se nota.
	if "health" in _jogador:
		_jogador.set("health", float(_jogador.get("max_health")) * 0.4)
	var vida_antes := float(_jogador.get("health"))
	Input.action_press("use_item")
	await _esperar(2)
	Input.action_release("use_item")
	await _esperar(90)
	var vida_depois := float(_jogador.get("health"))
	var frascos_depois := int(_jogador.get("flask_uses"))
	_diz("usar o item rápido gasta um frasco", frascos_depois < frascos_antes,
		"frascos %d -> %d" % [frascos_antes, frascos_depois])
	_diz("usar o item rápido cura", vida_depois > vida_antes,
		"vida %.0f -> %.0f" % [vida_antes, vida_depois])


## Descansar: a queixa foi "Não foi possível descansar agora".
func _passo_fogueira() -> void:
	var descanso: Vector3 = _jogo.get("_respawn_point") if "_respawn_point" in _jogo else Vector3.ZERO
	_jogador.global_position = descanso
	await _esperar(20)
	if "health" in _jogador:
		_jogador.set("health", float(_jogador.get("max_health")) * 0.3)
	var vida_antes := float(_jogador.get("health"))
	Input.action_press("interact")
	await _esperar(2)
	Input.action_release("interact")
	await _esperar(150)
	var vida_depois := float(_jogador.get("health"))
	var descansou := vida_depois > vida_antes
	_diz("descansar na fogueira cura", descansou,
		"vida %.0f -> %.0f" % [vida_antes, vida_depois] if descansou \
		else "vida %.0f -> %.0f; o descanso foi recusado" % [vida_antes, vida_depois])


## O mundo tem as coisas que o jogo promete.
func _passo_mundo() -> void:
	var gestor: Node = null
	var por_ver: Array[Node] = [_jogo]
	while not por_ver.is_empty():
		var no: Node = por_ver.pop_back()
		if no is WorldPickupManager:
			gestor = no
			break
		for f in no.get_children():
			por_ver.append(f)
	_diz("o gestor de espólio existe na cena", gestor != null,
		"WorldPickupManager montado" if gestor != null \
		else "WorldPickupManager não foi encontrado — nada de baús nem de coisas no chão")
	if gestor != null:
		var baus := int(gestor.call("chest_count")) \
			if gestor.has_method("chest_count") else 0
		_diz("o gestor monta os três baús de Brumal", baus == 3, "%d baús" % baus)
	var fps := Engine.get_frames_per_second()
	_diz("corre a 60 fps", fps >= 55.0, "%.0f fps" % fps)


func _fim() -> void:
	print("\n══════════ SESSÃO DE JOGO ══════════")
	for l in _relatorio:
		print(l)
	print("════════════════════════════════════")
	print("%d passo(s) com falha, de %d" % [_falhas, _relatorio.size()])
	get_tree().quit(0)


func _pose() -> String:
	var esq: Skeleton3D = _achar_esqueleto(_jogador)
	if esq == null:
		return "sem-esqueleto"
	var soma := ""
	for i in mini(esq.get_bone_count(), 12):
		soma += str(esq.get_bone_pose_rotation(i)).substr(0, 18)
	return soma


func _achar_esqueleto(no: Node) -> Skeleton3D:
	if no is Skeleton3D:
		return no as Skeleton3D
	for f in no.get_children():
		var r := _achar_esqueleto(f)
		if r != null:
			return r
	return null


func _animacao_tocada() -> String:
	var candidatas: Array[String] = []
	var por_ver: Array[Node] = [_jogador]
	while not por_ver.is_empty():
		var no: Node = por_ver.pop_back()
		if no is AnimationPlayer:
			var atribuida := String((no as AnimationPlayer).assigned_animation)
			if not atribuida.is_empty():
				candidatas.append(atribuida)
		for filha: Node in no.get_children():
			por_ver.append(filha)
	for animacao: String in candidatas:
		if animacao.contains("weapon_attacks/"):
			return animacao
	return candidatas[0] if not candidatas.is_empty() else "nenhuma"


func _esperar(frames: int) -> void:
	for _i in frames:
		await get_tree().process_frame


func _accionar(action: String) -> void:
	var pressed := InputEventAction.new()
	pressed.action = action
	pressed.pressed = true
	Input.parse_input_event(pressed)
	await _esperar(2)
	var released := InputEventAction.new()
	released.action = action
	released.pressed = false
	Input.parse_input_event(released)
	await _esperar(2)
