class_name NetHud
extends CanvasLayer
## O aviso de linha má, e mais nada.
##
## Fonte: spec/19-rede.md — "acima de 150 ms sustentados, aviso discreto no ecrã
## — o jogo não esconde a linha má, porque esconder faria a injustiça parecer
## do jogo".
##
## ⚠️ PORQUE E QUE ISTO E UM CanvasLayer PROPRIO E NAO UMA LINHA NO hud.gd:
## o `src/ui/hud.gd` tem outro dono a trabalhar nele neste momento
## (ver prompts/PARA-O-OPUS-DO-RICO.md §3). Mexer-lhe era pisar trabalho alheio.
## Isto fica auto-contido e some quando a rede esta desligada; quando o dono do
## HUD quiser absorve-lo, sao dez linhas — e esta escrito no LACUNAS.md.

const MARGIN := 12
const FONT_SIZE := 13

var _label: Label
var _session: Node


func _ready() -> void:
	layer = 90  # por baixo dos menus, por cima do jogo
	_label = Label.new()
	_label.add_theme_font_size_override("font_size", FONT_SIZE)
	# Contorno preto: o aviso tem de se ler contra a neve da Cimeira E contra
	# o escuro da Raiz. Uma cor so falha sempre num dos dois.
	_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	_label.add_theme_constant_override("outline_size", 4)
	_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_label.grow_horizontal = Control.GROW_DIRECTION_BEGIN
	_label.position = Vector2(-MARGIN, MARGIN)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_label.visible = false
	add_child(_label)

	# Ligacao tardia: se o autoload nao existir (testes headless), isto nao
	# rebenta — fica invisivel, que e o comportamento certo.
	_session = get_node_or_null("/root/NetSession")
	if _session != null:
		_session.link_warning.connect(_on_link_warning)
		_session.session_ended.connect(_on_session_ended)


func _on_link_warning(message: String) -> void:
	if message.is_empty():
		_label.visible = false
		return
	_label.text = message
	# Ambar, nao vermelho. O vermelho neste jogo quer dizer "o inimigo esta a
	# atacar" (data/graphics.json) — usa-lo para a rede ensinava a ler mal o
	# ecra, e ler o ecra e o jogo todo.
	_label.add_theme_color_override("font_color", Color(0.91, 0.76, 0.23))
	_label.visible = true


func _on_session_ended(reason: String) -> void:
	if reason.is_empty():
		_label.visible = false
		return
	_label.text = reason
	_label.add_theme_color_override("font_color", Color(0.88, 0.88, 0.88))
	_label.visible = true
	# A mensagem de fim fica cinco segundos e sai. Um aviso permanente sobre
	# uma sessao que ja acabou vira mobiliario, e mobiliario nao se le.
	var timer := get_tree().create_timer(5.0)
	timer.timeout.connect(func() -> void:
		if is_instance_valid(_label):
			_label.visible = false)
