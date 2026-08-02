extends Node
## Joga o jogo de ponta a ponta: anda o caminho, mata o que aparece, e tenta
## chegar ao chefe. Captura pelo caminho e diz o que encontrou.
##
## Porque isto existe (02-08-2026), nas palavras do Mateus: *"é pra tu ir lá e
## matando os inimigos mesmo como se fosse um jogador, pra ir vendo os erros que
## tem nos gráficos, na geometria, nos ataques dos inimigos, nos próprios
## inimigos, nas magias que usas"*.
##
## ⚠️ A `sessao-de-jogo` verifica passos isolados. O `filme-de-combate` filma uma
## luta. Isto **atravessa o jogo** — é a única coisa que responde a *"tem como ir
## até ao chefe?"*.
##
## Corre com:
##   godot --audio-driver Dummy --path . --rendering-method mobile scenes/percurso.tscn

const GAMEPLAY := preload("res://scenes/gameplay.tscn")

const AQUECIMENTO := 90
const PASSOS := 40           ## etapas ao longo do caminho
const FRAMES_POR_PASSO := 40 ## ~0,66 s a andar/lutar em cada etapa
const ALCANCE_ATAQUE := 2.6

var _jogo: Node
var _jogador: Node3D
var _camara: Camera3D
var _dir: String
var _tarefas: Array[int] = []
var _relatorio: Array[String] = []
var _mortos := 0
var _tipos_vistos := {}


func _ready() -> void:
	_dir = ProjectSettings.globalize_path("res://captures/")
	DirAccess.make_dir_recursive_absolute(_dir)
	_jogo = GAMEPLAY.instantiate()
	add_child(_jogo)
	_correr.call_deferred()


func _diz(t: String) -> void:
	_relatorio.append(t)
	print("[percurso] ", t)


func _correr() -> void:
	await _esperar(AQUECIMENTO)
	_jogador = _jogo.get("player") as Node3D
	if _jogador == null:
		printerr("[percurso] sem jogador"); get_tree().quit(1); return

	var mundo: Node = _jogo.get("world")
	var pontos: Array = []
	if mundo != null and "path_points" in mundo:
		pontos = mundo.get("path_points") as Array
	_diz("caminho com %d pontos" % pontos.size())
	if pontos.is_empty():
		_diz("SEM CAMINHO — não há por onde avançar")
		return _fim()

	_camara = Camera3D.new()
	_camara.fov = 62.0
	add_child(_camara)
	_camara.make_current()

	# ⭐ O jogador é imortal aqui: o objectivo é ATRAVESSAR e ver, não sobreviver.
	# Morrer a meio esconde o resto do mundo, que é justamente o que se quer ver.
	if "invulnerable" in _jogador:
		_jogador.set("invulnerable", true)

	var n := 0
	for passo in PASSOS:
		var indice := mini(passo * pontos.size() / PASSOS, pontos.size() - 1)
		var alvo := pontos[indice] as Vector3
		_jogador.global_position = Vector3(alvo.x, _jogador.global_position.y, alvo.z)
		await _esperar(6)

		var inimigo := _mais_perto()
		if inimigo != null:
			var d := inimigo.global_position.distance_to(_jogador.global_position)
			_contar(inimigo)
			if d < 14.0:
				# Encosta-se e bate até morrer ou até esgotar a paciência.
				var direccao := (inimigo.global_position - _jogador.global_position).normalized()
				_jogador.global_position = inimigo.global_position - direccao * ALCANCE_ATAQUE
				_jogador.look_at(inimigo.global_position, Vector3.UP)
				for _t in 6:
					Input.action_press("attack")
					await _esperar(4)
					Input.action_release("attack")
					await _esperar(10)
					if not is_instance_valid(inimigo):
						_mortos += 1
						break

		_olhar()
		var img := get_viewport().get_texture().get_image()
		_tarefas.append(WorkerThreadPool.add_task(
			_guardar.bind(img, "%spercurso-%02d.png" % [_dir, n])))
		n += 1
		await _esperar(FRAMES_POR_PASSO)

	# Chegou-se ao fim do caminho — o chefe devia estar aqui.
	var arena := Vector3.ZERO
	if "arena_center" in mundo:
		arena = mundo.get("arena_center") as Vector3
	_jogador.global_position = Vector3(arena.x, _jogador.global_position.y, arena.z + 6.0)
	await _esperar(60)
	var chefe := _procurar_chefe()
	_diz("chefe na arena: %s" % ("SIM — " + chefe.name if chefe != null else "NÃO ENCONTRADO"))
	_olhar()
	var img_fim := get_viewport().get_texture().get_image()
	_tarefas.append(WorkerThreadPool.add_task(
		_guardar.bind(img_fim, "%spercurso-chefe.png" % _dir)))

	for t: int in _tarefas:
		WorkerThreadPool.wait_for_task_completion(t)
	_fim()


func _contar(no: Node3D) -> void:
	var chave := String(no.name)
	if "enemy_id" in no:
		chave = String(no.get("enemy_id"))
	_tipos_vistos[chave] = int(_tipos_vistos.get(chave, 0)) + 1


func _mais_perto() -> Node3D:
	var melhor: Node3D = null
	var d := 1e9
	for no: Node in get_tree().get_nodes_in_group("enemies"):
		var e := no as Node3D
		if e == null or not is_instance_valid(e):
			continue
		var dd := e.global_position.distance_to(_jogador.global_position)
		if dd < d:
			d = dd
			melhor = e
	return melhor


func _procurar_chefe() -> Node:
	for no: Node in get_tree().get_nodes_in_group("enemies"):
		var id := ""
		if "enemy_id" in no:
			id = String(no.get("enemy_id"))
		if id.contains("vorgar") or no.get_class().contains("Boss") \
				or String(no.name).to_lower().contains("boss"):
			return no
	return null


func _olhar() -> void:
	var centro := _jogador.global_position + Vector3(0, 1.3, 0)
	var atras := -_jogador.global_transform.basis.z
	_camara.look_at_from_position(centro + atras * -4.0 + Vector3(0, 1.4, 0), centro)


func _fim() -> void:
	print("\n══════════ PERCURSO ══════════")
	for l in _relatorio:
		print("  ", l)
	print("  inimigos mortos: %d" % _mortos)
	print("  tipos encontrados: %d -> %s" % [_tipos_vistos.size(), str(_tipos_vistos)])
	print("══════════════════════════════")
	get_tree().quit(0)


func _guardar(imagem: Image, caminho: String) -> void:
	imagem.save_png(caminho)


func _esperar(frames: int) -> void:
	for _i in frames:
		await get_tree().process_frame
