extends Node
## Filma um COMBATE real contra um inimigo, para se julgar o que se SENTE.
##
## Porque isto existe (02-08-2026): o Mateus disse *"tu tá a ver poucos erros, eu
## tô a ver muita coisa até para descrever… não está a comparar com o Dark
## Souls?"*. E tinha razão. A `sessao-de-jogo` verifica se as coisas **existem**;
## isto filma o que o jogador **vê**, para se poder julgar o ritmo, o aviso do
## golpe inimigo, o impacto e a reacção.
##
## Corre com:
##   godot --audio-driver Dummy --path . --rendering-method mobile scenes/filme-de-combate.tscn
## As imagens saem para captures/combate-NN.png

const GAMEPLAY := preload("res://scenes/gameplay.tscn")

const AQUECIMENTO := 90
const TOTAL := 210          ## ~3,5 s de luta a 60 fps
const INTERVALO := 7        ## 30 imagens

var _jogo: Node
var _camara: Camera3D
var _dir: String
var _tarefas: Array[int] = []


func _ready() -> void:
	_dir = ProjectSettings.globalize_path("res://captures/")
	DirAccess.make_dir_recursive_absolute(_dir)
	_jogo = GAMEPLAY.instantiate()
	add_child(_jogo)
	_correr.call_deferred()


func _correr() -> void:
	await _esperar(AQUECIMENTO)
	var jogador: Node3D = _jogo.get("player") as Node3D
	if jogador == null:
		printerr("[combate] sem jogador"); get_tree().quit(1); return

	var inimigo := _inimigo_mais_perto(jogador)
	if inimigo == null:
		printerr("[combate] sem inimigos no mundo"); get_tree().quit(1); return

	# Põe os dois cara a cara, à distância de um golpe. É daqui que se julga se o
	# inimigo avisa antes de bater — a cláusula 1 do spec/38.
	var direccao := (inimigo.global_position - jogador.global_position).normalized()
	jogador.global_position = inimigo.global_position - direccao * 2.4
	jogador.look_at(inimigo.global_position, Vector3.UP)
	await _esperar(10)

	_camara = Camera3D.new()
	_camara.fov = 60.0
	add_child(_camara)
	_camara.make_current()
	_olhar(jogador, inimigo)
	await get_tree().process_frame

	print("[combate] inimigo: %s" % inimigo.name)
	var n := 0
	for i in range(0, TOTAL, INTERVALO):
		# Ataca de forma sustentada, como um jogador faz.
		if i % 28 == 0:
			Input.action_press("attack")
		elif i % 28 == 7:
			Input.action_release("attack")
		_olhar(jogador, inimigo)
		var img := get_viewport().get_texture().get_image()
		var caminho := "%scombate-%02d.png" % [_dir, n]
		_tarefas.append(WorkerThreadPool.add_task(_guardar.bind(img, caminho)))
		print("[combate] %02d · jogador=%s pv=%.0f · inimigo=%s pv=%.0f" % [
			n, _estado(jogador), float(jogador.get("health")),
			_estado(inimigo), float(inimigo.get("health")) if "health" in inimigo else -1.0])
		n += 1
		await _esperar(INTERVALO)
		if not is_instance_valid(inimigo):
			print("[combate] o inimigo morreu ao fim de %d imagens" % n)
			break

	for t: int in _tarefas:
		WorkerThreadPool.wait_for_task_completion(t)
	print("[combate] %d imagens" % n)
	get_tree().quit(0)


func _estado(no: Node) -> String:
	if no.has_method("state_name"):
		return String(no.call("state_name"))
	if "state" in no:
		return str(no.get("state"))
	return "?"


func _inimigo_mais_perto(de: Node3D) -> Node3D:
	var melhor: Node3D = null
	var d := 1e9
	for no: Node in get_tree().get_nodes_in_group("enemies"):
		var e := no as Node3D
		if e == null:
			continue
		var dd := e.global_position.distance_to(de.global_position)
		if dd < d:
			d = dd
			melhor = e
	return melhor


## Câmara de ombro, como a do jogo — é a vista que o jogador tem de verdade.
func _olhar(jogador: Node3D, inimigo: Node3D) -> void:
	var meio := (jogador.global_position + inimigo.global_position) * 0.5 + Vector3(0, 1.2, 0)
	var atras := (jogador.global_position - inimigo.global_position).normalized()
	_camara.look_at_from_position(
		jogador.global_position + atras * 3.2 + Vector3(0.9, 2.0, 0), meio)


func _guardar(imagem: Image, caminho: String) -> void:
	var erro := imagem.save_png(caminho)
	if erro != OK:
		printerr("[combate] falhou gravar %s" % caminho)


func _esperar(frames: int) -> void:
	for _i in frames:
		await get_tree().process_frame
