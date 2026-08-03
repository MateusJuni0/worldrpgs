extends Node
## Prova o percurso jogavel completo: o piloto usa as mesmas accoes de movimento,
## ataque, defesa e cura que o jogador, atravessa a rota publicada pelo mundo e
## luta com o guardiao. Nenhuma mudanca de `global_position` e permitida aqui.
##
## Corre com:
##   godot --audio-driver Dummy --path . --rendering-method mobile scenes/percurso.tscn
## Para nao tocar nas capturas existentes, a automacao pode definir
## `WORLDRPGS_PROOF_CAPTURE_DIR` para uma pasta temporaria.

const GAMEPLAY := preload("res://scenes/gameplay.tscn")
const PILOTO_COMBATE_SCRIPT := preload("res://src/tools/piloto_combate.gd")

const AQUECIMENTO_FRAMES := 90
const TOLERANCIA_DESTINO_M := 1.35
const TOLERANCIA_PROGRESSO_M := 0.08
const FRAMES_SEM_PROGRESSO := 180
const TEST_SLOT_MIN := 9000
const TEST_SLOT_MAX := 9999

enum ResultadoCombate { VITORIA, RESSUSCITOU, APROXIMAR, FALHA }

var _jogo: Node
var _jogador: Player
var _camara: Camera3D
var _piloto: PilotoCombate
var _dir := ""
var _tarefas: Array[int] = []
var _relatorio: Array[String] = []
var _falhas := 0
var _mortos := 0
var _mortes_observadas: Dictionary = {}
var _tipos_vistos: Dictionary = {}
var _jogador_morreu := false
var _mortes_jogador := 0
var _tentativas_maximas := 0
var _destino_actual := 0
var _destinos_totais := 0
var _alvo_actual: Enemy
var _retomar_da_fogueira := false
var _proximo_lock_frame := 0
var _lock_target_id := 0
var _test_slot := -1


func _ready() -> void:
	_test_slot = _find_unused_test_slot()
	if _test_slot < 0:
		_falhar("nao encontrou um slot temporario livre para isolar a prova")
		_fim()
		return
	SaveSystem.active_slot = _test_slot
	GameData.replace_save_state(SaveSystem.create_save("prova-percurso", "warrior"))
	_dir = OS.get_environment("WORLDRPGS_PROOF_CAPTURE_DIR")
	if _dir.is_empty():
		_dir = ProjectSettings.globalize_path("res://captures/percurso-honesto")
	_dir = _dir.trim_suffix("/").trim_suffix("\\")
	var erro := DirAccess.make_dir_recursive_absolute(_dir)
	if erro != OK:
		_falhar("nao foi possivel criar a pasta de capturas: %s" % error_string(erro))
		_fim()
		return
	get_tree().node_added.connect(_ao_no_adicionado)
	_piloto = PILOTO_COMBATE_SCRIPT.new() as PilotoCombate
	_piloto.configure(get_tree())
	_jogo = GAMEPLAY.instantiate()
	add_child(_jogo)
	_correr.call_deferred()


func _diz(texto: String) -> void:
	_relatorio.append(texto)
	print("[percurso] ", texto)


func _falhar(texto: String) -> void:
	_falhas += 1
	_diz("FALHA — " + texto)


func _correr() -> void:
	await _esperar_fisica(AQUECIMENTO_FRAMES)
	_jogador = _jogo.get("player") as Player
	if _jogador == null:
		_falhar("a cena real nao criou o jogador")
		_fim()
		return
	_jogador.died.connect(_ao_jogador_morrer)
	for no: Node in get_tree().get_nodes_in_group("enemies"):
		_observar_inimigo(no)

	var mundo := _jogo.get("world") as Node3D
	var rota := _rota_publicada(mundo)
	_destinos_totais = rota.size()
	# Uma tentativa inicial e uma nova tentativa por destino publicado. O tecto e
	# da prova, nao altera qualquer numero de combate nem o jogador.
	_tentativas_maximas = maxi(1, rota.size())
	_diz("rota publicada com %d destinos" % rota.size())
	_diz("tecto da prova: %d tentativas com ressurreicao na fogueira" \
		% _tentativas_maximas)
	if rota.is_empty():
		_falhar("o mundo nao publicou uma rota continua ate a arena")
		_fim()
		return

	_camara = Camera3D.new()
	_camara.fov = 62.0
	add_child(_camara)
	_camara.make_current()

	if not await _atravessar_rota(rota, true):
		_fim()
		return

	_parar_movimento()
	var chefe: Enemy
	var vida_chefe_inicial := 0.0
	var venceu := false
	while not venceu:
		chefe = _chefe_vivo()
		if chefe == null:
			_falhar("chegou a arena a pe, mas o guardiao nao apareceu")
			await _capturar("arena-sem-chefe")
			_fim()
			return
		if vida_chefe_inicial <= 0.0:
			vida_chefe_inicial = chefe.health
			_diz("guardiao encontrado na arena: %s" % chefe.display_name())
		var resultado := await _combater(chefe)
		if resultado == ResultadoCombate.VITORIA:
			venceu = true
		elif resultado == ResultadoCombate.RESSUSCITOU:
			_diz("a regressar a pe da fogueira ate ao guardiao")
			if not await _atravessar_rota(rota, false):
				_fim()
				return
		else:
			break
	await _capturar("vorgar-derrotado" if venceu else "vorgar-falha")
	if not venceu:
		_falhar("a luta real nao derrotou o guardiao")
	elif chefe.health >= vida_chefe_inicial or chefe.is_alive():
		_falhar("a fotografia final contradiz o resultado da luta")
	else:
		_diz("guardiao derrotado por accoes de ataque; PV %.0f -> %.0f" % [
			vida_chefe_inicial, chefe.health])

	if _mortos <= 0:
		_falhar("atravessou a rota sem provar a morte de nenhum inimigo")
	_fim()


func _atravessar_rota(rota: Array[Vector3], anunciar_destinos: bool) -> bool:
	_retomar_da_fogueira = false
	var indice := 0
	while indice < rota.size():
		_destino_actual = indice + 1
		if not await _andar_ate(rota[indice]):
			await _capturar("falha-%02d" % indice)
			return false
		if _retomar_da_fogueira:
			_retomar_da_fogueira = false
			indice = 0
			_diz("retomou o percurso desde o primeiro waypoint da fogueira")
			continue
		if anunciar_destinos:
			_diz("destino %02d/%02d alcancado a pe" % [indice + 1, rota.size()])
			await _capturar("destino-%02d" % indice)
		indice += 1
	return true


func _rota_publicada(mundo: Node3D) -> Array[Vector3]:
	var rota: Array[Vector3] = []
	if mundo == null or not "path_points" in mundo:
		return rota
	for valor: Variant in mundo.get("path_points") as Array:
		if valor is Vector3:
			rota.append(valor as Vector3)
	if rota.is_empty() or not "map_path_segments" in mundo or not "arena_center" in mundo:
		return []

	var entrada := rota[rota.size() - 1]
	var arena := mundo.get("arena_center") as Vector3
	var segmento_da_toca := PackedVector3Array()
	for valor: Variant in mundo.get("map_path_segments") as Array:
		var segmento := valor as PackedVector3Array
		if segmento.size() < 2:
			continue
		if segmento[0].distance_to(entrada) <= TOLERANCIA_DESTINO_M \
				and segmento[segmento.size() - 1].distance_to(arena) <= TOLERANCIA_DESTINO_M:
			segmento_da_toca = segmento
			break
	if segmento_da_toca.is_empty():
		return []
	for indice: int in range(1, segmento_da_toca.size()):
		rota.append(segmento_da_toca[indice])
	return rota


func _andar_ate(destino: Vector3) -> bool:
	var melhor_distancia := _distancia_plana(_jogador.global_position, destino)
	var sem_progresso := 0
	var desvios_tentados := 0
	var lados := [1.0, -1.0]
	while melhor_distancia > TOLERANCIA_DESTINO_M:
		if _jogador_morreu or not _jogador.is_alive():
			if not await _esperar_ressurreicao():
				return false
			return true

		var inimigo := _inimigo_em_confronto()
		if inimigo != null:
			var nome_inimigo := inimigo.display_name()
			_parar_movimento()
			var resultado := await _combater(inimigo)
			if resultado == ResultadoCombate.FALHA:
				_falhar("nao conseguiu ultrapassar %s no caminho" % nome_inimigo)
				return false
			if resultado == ResultadoCombate.RESSUSCITOU:
				return true
			if resultado != ResultadoCombate.APROXIMAR:
				melhor_distancia = _distancia_plana(_jogador.global_position, destino)
				sem_progresso = 0
				desvios_tentados = 0
				continue
		else:
			_alvo_actual = null

		var direccao := destino - _jogador.global_position
		direccao.y = 0.0
		_aplicar_movimento(direccao.normalized(), true)
		await get_tree().physics_frame
		var distancia := _distancia_plana(_jogador.global_position, destino)
		if distancia + TOLERANCIA_PROGRESSO_M < melhor_distancia:
			melhor_distancia = distancia
			sem_progresso = 0
		else:
			sem_progresso += 1
		if sem_progresso >= FRAMES_SEM_PROGRESSO:
			if desvios_tentados < lados.size():
				_diz("colisao a %.2f m; a contornar pelo lado %d" % [
					distancia, desvios_tentados + 1])
				await _contornar(destino, float(lados[desvios_tentados]))
				desvios_tentados += 1
				melhor_distancia = _distancia_plana(_jogador.global_position, destino)
				sem_progresso = 0
				continue
			_parar_movimento()
			_falhar("colisao ou geometria bloqueou a caminhada a %.2f m do destino" % distancia)
			return false
	_parar_movimento()
	return true


func _contornar(destino: Vector3, lado: float) -> void:
	var frente := destino - _jogador.global_position
	frente.y = 0.0
	var lateral := Vector3(-frente.z, 0.0, frente.x).normalized() * lado
	for _frame: int in maxi(1, int(FRAMES_SEM_PROGRESSO / 3)):
		if _jogador_morreu or not _jogador.is_alive():
			break
		_aplicar_movimento(lateral, false)
		await get_tree().physics_frame
	_parar_movimento()


func _combater(alvo: Enemy) -> int:
	if alvo == null or not alvo.is_alive():
		return ResultadoCombate.VITORIA
	_observar_inimigo(alvo)
	var identidade := alvo.get_instance_id()
	var nome_alvo := alvo.display_name()
	_alvo_actual = alvo
	var vida_inicial := alvo.health
	var vida_anterior := alvo.health
	var acertos := 0
	var golpes_esperados := _piloto.expected_light_hits(_jogador, alvo)
	var frame_limite := Engine.get_physics_frames() \
		+ _piloto.frame_budget(_jogador, alvo, golpes_esperados)
	if _lock_target_id != identidade:
		_lock_target_id = identidade
		_proximo_lock_frame = 0
	while Engine.get_physics_frames() < _proximo_lock_frame:
		_piloto.drive_frame(_jogador, alvo, false)
		if not _piloto.consumed_frame:
			return ResultadoCombate.APROXIMAR
		await get_tree().physics_frame
		if _jogador_morreu or not _jogador.is_alive():
			var ressuscitou := await _esperar_ressurreicao()
			_alvo_actual = null
			return ResultadoCombate.RESSUSCITOU if ressuscitou else ResultadoCombate.FALHA
	var fixou := await _piloto.lock_on(_jogador, alvo)
	if _jogador_morreu or not _jogador.is_alive():
		var ressuscitou := await _esperar_ressurreicao()
		_alvo_actual = null
		return ResultadoCombate.RESSUSCITOU if ressuscitou else ResultadoCombate.FALHA
	if not fixou:
		_proximo_lock_frame = Engine.get_physics_frames() \
			+ maxi(1, int(GameData.combat.get("reference_fps")))
		return ResultadoCombate.APROXIMAR
	_contar_tipo(alvo)
	_proximo_lock_frame = 0
	_diz("lock-on real fixou %s" % nome_alvo)

	while is_instance_valid(alvo) and alvo.is_alive() \
			and Engine.get_physics_frames() < frame_limite:
		if _jogador_morreu or not _jogador.is_alive():
			_piloto.release_all_inputs()
			var ressuscitou := await _esperar_ressurreicao()
			_alvo_actual = null
			return ResultadoCombate.RESSUSCITOU if ressuscitou else ResultadoCombate.FALHA
		_piloto.drive_frame(_jogador, alvo)
		await get_tree().physics_frame
		if is_instance_valid(alvo) and alvo.health < vida_anterior:
			acertos += 1
			vida_anterior = alvo.health

	_piloto.release_all_inputs()
	_alvo_actual = null
	if not is_instance_valid(alvo):
		if _mortes_observadas.has(identidade):
			_diz("%s morreu e o streaming retirou o cadaver depois do sinal" % nome_alvo)
			return ResultadoCombate.VITORIA
		_diz("combate falhou: %s desapareceu sem emitir died" % nome_alvo)
		return ResultadoCombate.FALHA
	if alvo.is_alive():
		_diz("combate falhou: %s conservou %.0f/%.0f PV (%d acertos; orcamento catalogado)" % [
			nome_alvo, alvo.health, vida_inicial, acertos])
		return ResultadoCombate.FALHA
	_diz("%s morreu: %.0f -> %.0f PV, %d acertos por entrada" % [
		nome_alvo, vida_inicial, alvo.health, acertos])
	return ResultadoCombate.VITORIA


func _esperar_ressurreicao() -> bool:
	_parar_movimento()
	var proxima_tentativa := _mortes_jogador + 1
	if proxima_tentativa > _tentativas_maximas:
		_falhar("ultrapassou o tecto de %d tentativas depois de %d mortes" % [
			_tentativas_maximas, _mortes_jogador])
		return false
	var reference_fps := float(GameData.combat.get("reference_fps"))
	var fade_seconds := float(GameData.section("death").get("respawn_fade_seconds"))
	var wait_frames := ceili(fade_seconds * reference_fps) + maxi(1, ceili(reference_fps))
	var deadline := Engine.get_physics_frames() + wait_frames
	while not _jogador.is_alive() and Engine.get_physics_frames() < deadline:
		await get_tree().physics_frame
	if not _jogador.is_alive():
		_falhar("a morte nao regressou a fogueira dentro da janela declarada nos dados")
		return false
	_jogador_morreu = false
	_retomar_da_fogueira = true
	_proximo_lock_frame = 0
	_lock_target_id = 0
	_piloto.reset_attempt()
	_diz("ressuscitou na fogueira; tentativa %d/%d" % [
		proxima_tentativa, _tentativas_maximas])
	return true


func _inimigo_em_confronto() -> Enemy:
	var melhor: Enemy
	var melhor_distancia := INF
	var defaults: Dictionary = GameData.enemies.get("_enemy_defaults", {}) as Dictionary
	var alcance_de_alerta := float(defaults.get("aggro_range", 0.0))
	for no: Node in get_tree().get_nodes_in_group("enemies"):
		var inimigo := no as Enemy
		if inimigo == null or not inimigo.is_alive() or inimigo.is_boss:
			continue
		var distancia := _distancia_plana(inimigo.global_position, _jogador.global_position)
		if distancia <= alcance_de_alerta and distancia < melhor_distancia:
			melhor = inimigo
			melhor_distancia = distancia
	return melhor


func _chefe_vivo() -> Enemy:
	for no: Node in get_tree().get_nodes_in_group("enemies"):
		var inimigo := no as Enemy
		if inimigo != null and inimigo.is_boss and inimigo.is_alive():
			return inimigo
	return null


func _ao_no_adicionado(no: Node) -> void:
	# O sinal `died` ja existe quando o Enemy entra na arvore. Ligar aqui evita
	# guardar uma referencia diferida a um no que o streaming possa libertar.
	_observar_inimigo(no)


func _observar_inimigo(no: Node) -> void:
	var inimigo := no as Enemy
	if inimigo == null or not inimigo.has_signal("died"):
		return
	var callback := Callable(self, "_ao_inimigo_morrer")
	if not inimigo.died.is_connected(callback):
		inimigo.died.connect(callback)


func _ao_inimigo_morrer(inimigo: Enemy) -> void:
	var identidade := inimigo.get_instance_id()
	if _mortes_observadas.has(identidade):
		return
	_mortes_observadas[identidade] = true
	_mortos += 1


func _ao_jogador_morrer() -> void:
	_jogador_morreu = true
	_mortes_jogador += 1
	_parar_movimento()
	var nome_alvo := "sem inimigo fixado"
	var vida_alvo := 0.0
	var vida_alvo_maxima := 0.0
	if is_instance_valid(_alvo_actual):
		nome_alvo = _alvo_actual.display_name()
		vida_alvo = _alvo_actual.health
		vida_alvo_maxima = _alvo_actual.max_health
	_diz(("morte %d no destino %02d/%02d contra %s; " \
		+ "jogador %.0f/%.0f PV; inimigo %.0f/%.0f PV") % [
		_mortes_jogador, _destino_actual, _destinos_totais, nome_alvo,
		_jogador.health, _jogador.max_health, vida_alvo, vida_alvo_maxima])


func _contar_tipo(inimigo: Enemy) -> void:
	var chave := inimigo.enemy_id
	_tipos_vistos[chave] = int(_tipos_vistos.get(chave, 0)) + 1


func _aplicar_movimento(direccao_mundo: Vector3, sprint: bool) -> void:
	_parar_movimento()
	if direccao_mundo.is_zero_approx() or _jogador.camera == null:
		return
	var direita := _jogador.camera.right_flat()
	var frente := _jogador.camera.forward_flat()
	var eixo_x := clampf(direccao_mundo.dot(direita), -1.0, 1.0)
	var eixo_y := clampf(-direccao_mundo.dot(frente), -1.0, 1.0)
	if eixo_x < 0.0:
		Input.action_press("move_left", -eixo_x)
	elif eixo_x > 0.0:
		Input.action_press("move_right", eixo_x)
	if eixo_y < 0.0:
		Input.action_press("move_forward", -eixo_y)
	elif eixo_y > 0.0:
		Input.action_press("move_back", eixo_y)
	if sprint:
		Input.action_press("dodge_sprint")


func _parar_movimento() -> void:
	if _piloto != null:
		_piloto.release_all_inputs()
		return
	for accao: String in ["move_left", "move_right", "move_forward", "move_back",
			"dodge_sprint", "attack", "block", "parry", "use_item", "lock_on"]:
		Input.action_release(accao)


func _capturar(nome: String) -> void:
	if DisplayServer.get_name() == "headless":
		_diz("captura %s adiada para a execucao com renderer" % nome)
		return
	_olhar()
	await get_tree().process_frame
	var imagem := get_viewport().get_texture().get_image()
	if imagem == null or imagem.is_empty():
		_diz("captura %s indisponivel no renderer headless" % nome)
		return
	var caminho := _dir.path_join("percurso-%s.png" % nome)
	_tarefas.append(WorkerThreadPool.add_task(_guardar.bind(imagem, caminho)))


func _olhar() -> void:
	if _camara == null or _jogador == null:
		return
	var centro := _jogador.global_position + Vector3(0, 1.3, 0)
	var frente := -_jogador.global_transform.basis.z
	_camara.look_at_from_position(centro - frente * 4.0 + Vector3(0, 1.4, 0), centro)


func _fim() -> void:
	_parar_movimento()
	for tarefa: int in _tarefas:
		WorkerThreadPool.wait_for_task_completion(tarefa)
	print("\n========== PERCURSO HONESTO ==========")
	for linha: String in _relatorio:
		print("  ", linha)
	print("  inimigos mortos por sinal: %d" % _mortos)
	print("  tipos enfrentados: %d -> %s" % [_tipos_vistos.size(), str(_tipos_vistos)])
	print("  mortes do piloto: %d" % _mortes_jogador)
	if _piloto != null:
		print("  piloto: parries=%d; esquivas=%d; bloqueios=%d" % [
			_piloto.parries, _piloto.dodges, _piloto.blocks])
	print("======================================")
	# Main guarda ao sair. Esvaziar primeiro impede que esse ultimo callback volte
	# a criar o slot de prova depois da limpeza abaixo.
	GameData.replace_save_state({})
	_cleanup_test_slot()
	get_tree().quit(1 if _falhas > 0 else 0)


func _guardar(imagem: Image, caminho: String) -> void:
	var erro := imagem.save_png(caminho)
	if erro != OK:
		printerr("[percurso] falhou gravar %s: %s" % [caminho, error_string(erro)])


func _esperar_fisica(frames: int) -> void:
	for _frame: int in frames:
		await get_tree().physics_frame


func _distancia_plana(a: Vector3, b: Vector3) -> float:
	var delta := b - a
	delta.y = 0.0
	return delta.length()


func _find_unused_test_slot() -> int:
	for candidate: int in range(TEST_SLOT_MIN, TEST_SLOT_MAX + 1):
		var path := SaveSystem.slot_path(candidate)
		if not FileAccess.file_exists(path) \
				and not FileAccess.file_exists(path + ".bak") \
				and not FileAccess.file_exists(path + ".tmp"):
			return candidate
	return -1


func _cleanup_test_slot() -> void:
	if _test_slot < 0:
		return
	var path := SaveSystem.slot_path(_test_slot)
	for suffix: String in ["", ".tmp", ".bak", ".corrupt"]:
		var candidate := path + suffix
		if FileAccess.file_exists(candidate):
			DirAccess.remove_absolute(ProjectSettings.globalize_path(candidate))
