extends Node
## Filma um ataque completo, frame a frame, e grava as imagens.
##
## Porque isto existe (02-08-2026): o Mateus jogou e disse "ele nao ataca com a
## espada, ele bate com a mao e a espada fica na mao". O modo fotografia so
## apanha poses paradas, portanto eu estava a rever o jogo sem nunca ver um
## golpe. Isto e a resposta ao pedido dele: "vai tu joga".
##
## Corre com:
##   godot --audio-driver Dummy --path . --rendering-method mobile scenes/filme-de-ataque.tscn
## As imagens saem para captures/ataque-NN.png

const GAMEPLAY := preload("res://scenes/gameplay.tscn")

const FRAMES_AQUECIMENTO := 90   ## shaders, nevoeiro e modelos a assentar
const FRAMES_FILMADOS := 48      ## ~0,8 s a 60 fps: chega para um golpe inteiro
const INTERVALO := 3             ## grava um em cada 3 frames -> 16 imagens

var _jogo: Node
var _camara: Camera3D
var _dir: String


func _ready() -> void:
	# O PNG sincrono pode baixar o render para 15-20 fps. Este no tem de continuar
	# enquanto a arvore pausa entre amostras, para cada ficheiro representar um
	# frame fisico exacto do golpe e nao o tempo que o disco demorou a gravar.
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Impede que o motor recupere varios ticks entre dois PNG lentos. O filme quer
	# observar cada tick, nao simular em tempo real enquanto escreve no disco.
	Engine.max_physics_steps_per_frame = 1
	_dir = ProjectSettings.globalize_path("res://captures/")
	DirAccess.make_dir_recursive_absolute(_dir)
	_jogo = GAMEPLAY.instantiate()
	add_child(_jogo)
	_correr.call_deferred()


func _correr() -> void:
	await _esperar(FRAMES_AQUECIMENTO)

	var jogador: Player = _jogo.get("player") as Player
	if jogador == null:
		printerr("[filme] sem jogador — nao ha nada para filmar")
		get_tree().quit(1)
		return

	# Camara de ombro, perto: e daqui que se ve se a espada acompanha a mao.
	_camara = Camera3D.new()
	_camara.fov = 55.0
	add_child(_camara)
	_camara.make_current()

	print("[filme] arma na mao direita: ", _descrever_arma(jogador))

	# Bate como o jogador bate: pela accao, nao por uma chamada interna.
	Input.action_press("attack")
	while jogador.state != Player.State.ATTACK:
		await jogador.state_changed
	Input.action_release("attack")

	var n := 0
	for attack_frame in range(0, FRAMES_FILMADOS, INTERVALO):
		await _esperar_frame_de_ataque(jogador, attack_frame)
		get_tree().paused = true
		_descrever_amostra(jogador, n, attack_frame)
		_olhar(jogador)
		await get_tree().process_frame
		var img := get_viewport().get_texture().get_image()
		img.save_png("%sataque-%02d.png" % [_dir, n])
		n += 1
		get_tree().paused = false

	print("[filme] %d imagens gravadas em captures/" % n)
	get_tree().quit(0)


func _olhar(alvo: Node3D) -> void:
	var centro := alvo.global_position + Vector3(0, 1.3, 0)
	var atras := -alvo.global_transform.basis.z
	_camara.look_at_from_position(centro + atras * -2.6 + Vector3(1.1, 0.35, 0), centro)


## Diz o que esta pendurado no esqueleto — se estiver vazio, a arma nunca chegou.
func _descrever_arma(jogador: Node) -> String:
	var encontrados: Array[String] = []
	var por_ver: Array[Node] = [jogador]
	while not por_ver.is_empty():
		var no: Node = por_ver.pop_back()
		if no is BoneAttachment3D:
			var filhos: Array[String] = []
			for f in no.get_children():
				filhos.append("%s(%s)" % [f.name, f.get_class()])
			encontrados.append("%s -> [%s]" % [(no as BoneAttachment3D).bone_name,
				", ".join(filhos) if not filhos.is_empty() else "VAZIO"])
		for f in no.get_children():
			por_ver.append(f)
	return " · ".join(encontrados) if not encontrados.is_empty() \
		else "NENHUM BoneAttachment3D no jogador"


func _descrever_amostra(jogador: Player, indice: int, pedido: int) -> void:
	var visual := jogador.get("_visual") as Node
	var animacao := String(visual.call("current_animation_name")) \
		if visual != null and visual.has_method("current_animation_name") else "?"
	var total := int(jogador.get("_atk_startup")) + int(jogador.get("_charge_frames")) \
		+ int(jogador.get("_atk_active")) + int(jogador.get("_atk_recovery"))
	print("[filme] imagem %02d: pedido=%d estado=%s frame=%d/%d animacao=%s" % [
		indice, pedido, jogador.state_name(), jogador.state_frame, total, animacao])


func _esperar(frames: int) -> void:
	for _i in frames:
		await get_tree().process_frame


func _esperar_frame_de_ataque(jogador: Node, attack_frame: int) -> void:
	while int(jogador.get("state")) == Player.State.ATTACK \
			and int(jogador.get("state_frame")) < attack_frame:
		await get_tree().physics_frame
