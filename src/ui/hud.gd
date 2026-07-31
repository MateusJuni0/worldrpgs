class_name Hud
extends CanvasLayer
## HUD minimo — spec/08-ui.md exige, no minimo: vida, STAMINA, cargas de magia
## e barra de vida do chefe.
##
## A stamina e obrigatoria e nao e decoracao: a esquiva e o parry dependem dela e
## o jogador tem de a ler em tempo real. Por isso e a barra mais gorda e a que
## pisca quando tranca.

const BAR_W := 340.0
const BAR_H := 18.0

var player: Player
var boss: Enemy

var _health: ColorRect
var _health_bg: ColorRect
var _stamina: ColorRect
var _stamina_bg: ColorRect
var _info: Label
var _boss_bg: ColorRect
var _boss_bar: ColorRect
var _boss_label: Label
var _help: Label
var _toast: Label
var _toast_time := 0.0


func _ready() -> void:
	layer = 50
	_build_bars()
	_build_labels()


func _bar(colour: Color, pos: Vector2, size: Vector2) -> ColorRect:
	var r := ColorRect.new()
	r.color = colour
	r.position = pos
	r.size = size
	add_child(r)
	return r


func _build_bars() -> void:
	var x := 28.0
	var y := 880.0
	_health_bg = _bar(Color(0.08, 0.05, 0.05, 0.85), Vector2(x - 2, y - 2), Vector2(BAR_W + 4, BAR_H + 4))
	_health = _bar(Color(0.72, 0.22, 0.22), Vector2(x, y), Vector2(BAR_W, BAR_H))

	var y2 := y + BAR_H + 8.0
	_stamina_bg = _bar(Color(0.05, 0.07, 0.05, 0.85), Vector2(x - 2, y2 - 2), Vector2(BAR_W + 4, BAR_H + 8))
	_stamina = _bar(Color(0.45, 0.78, 0.35), Vector2(x, y2), Vector2(BAR_W, BAR_H + 4))

	var bw := 780.0
	_boss_bg = _bar(Color(0.06, 0.04, 0.04, 0.9), Vector2(570, 960), Vector2(bw + 4, 20))
	_boss_bar = _bar(Color(0.78, 0.28, 0.24), Vector2(572, 962), Vector2(bw, 16))
	_boss_bg.visible = false
	_boss_bar.visible = false


func _styled_label(pos: Vector2, size := 16) -> Label:
	var l := Label.new()
	l.position = pos
	l.add_theme_color_override("font_color", Color(0.94, 0.94, 0.9))
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	l.add_theme_constant_override("outline_size", 5)
	l.add_theme_font_size_override("font_size", size)
	add_child(l)
	return l


func _build_labels() -> void:
	_info = _styled_label(Vector2(28, 828))
	_boss_label = _styled_label(Vector2(572, 934), 20)
	_boss_label.visible = false

	_toast = _styled_label(Vector2(28, 792), 20)
	_toast.add_theme_color_override("font_color", Color(1.0, 0.88, 0.5))

	_help = _styled_label(Vector2(1180, 120))
	_help.visible = false
	_help.text = """COMANDOS  (spec/01-combate.md)
WASD          mover        (correr 5,0 m/s)
Ctrl          andar 3,0    Space segurar: sprint 7,0
Space toque   esquiva      0,60 s · i-frames 0,08-0,38
Rato          camara
LMB           ataque leve
Shift+LMB     ataque pesado (segurar: carrega o machadao)
RMB segurar   bloqueio     (LMB com escudo = bash)
Q             parry        janela 8 f
Tab           lock-on      18 m engate / 25 m quebra
C             conjurar     F: magia seguinte
[ ]           trocar de arma (Lei 3)
F1 fps · F2 esta ajuda · F3 rato · F5 reiniciar · Esc sair"""


func _process(delta: float) -> void:
	if InputMap.has_action("toggle_help") and Input.is_action_just_pressed("toggle_help"):
		_help.visible = not _help.visible

	if _toast_time > 0.0:
		_toast_time -= delta
		if _toast_time <= 0.0:
			_toast.text = ""

	if not is_instance_valid(player):
		return

	_health.size.x = BAR_W * clampf(player.health / maxf(player.max_health, 1.0), 0.0, 1.0)
	_stamina.size.x = BAR_W * clampf(player.stamina.fraction(), 0.0, 1.0)
	# A stamina fica vermelha quando tranca — o jogador tem de perceber PORQUE nao esquivou.
	_stamina.color = Color(0.85, 0.35, 0.3) if player.stamina.locked_out else Color(0.45, 0.78, 0.35)

	var spell_name: String = GameData.spell(player.selected_spell).get("display_name", "?")
	_info.text = "%d/%d PV   %d/%d STA   cargas %d/%d   frasco %d/%d   magia: %s   %s   [%s]" % [
		int(player.health), int(player.max_health),
		int(player.stamina.current), int(player.stamina.maximum),
		player.charges, player.max_charges,
		player.flask_uses, player.flask_max,
		spell_name, player.loadout_label(), player.state_name()]

	_update_boss()


func _update_boss() -> void:
	var show := is_instance_valid(boss) and boss.is_alive() and is_instance_valid(player) \
		and player.global_position.distance_to(boss.global_position) < 30.0
	_boss_bg.visible = show
	_boss_bar.visible = show
	_boss_label.visible = show
	if show:
		_boss_bar.size.x = 780.0 * clampf(boss.health / maxf(boss.max_health, 1.0), 0.0, 1.0)
		_boss_label.text = "%s   —   fase %d" % [boss.display_name(), 2 if boss.health / boss.max_health <= 0.5 else 1]


func toast(message: String, seconds := 2.5) -> void:
	_toast.text = message
	_toast_time = seconds
