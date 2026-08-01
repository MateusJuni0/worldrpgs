class_name SpellWheel
extends CanvasLayer
## Roda de oito favoritos. E apenas seleccao: nao altera Engine.time_scale,
## nao pausa a SceneTree e deixa o jogador vulneravel enquanto esta aberta.

var selected_spell_id := ""
var _spell_ids: Array[String] = []
var _cards: Array[Panel] = []
var _center := Vector2(960, 540)
var _capture_mode := false


func open(theme: Theme, spell_ids: Array[String], current_spell: String, capture_mode := false) -> void:
	layer = 560
	process_mode = Node.PROCESS_MODE_ALWAYS
	_spell_ids = spell_ids.slice(0, 8)
	selected_spell_id = current_spell if _spell_ids.has(current_spell) else \
		(_spell_ids[0] if not _spell_ids.is_empty() else "")
	_capture_mode = capture_mode
	var root := Control.new()
	root.theme = theme
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var shade := ColorRect.new()
	shade.color = Color(0.0, 0.0, 0.0, 0.62)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(shade)
	var ring := Panel.new()
	ring.position = _center - Vector2(188, 188)
	ring.size = Vector2(376, 376)
	root.add_child(ring)
	var centre := Label.new()
	centre.text = "RODA DE\nFEITIÇOS"
	centre.position = _center - Vector2(90, 42)
	centre.size = Vector2(180, 84)
	centre.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	centre.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	centre.add_theme_font_size_override("font_size", 18)
	centre.add_theme_color_override("font_color", Color("eadbb9"))
	root.add_child(centre)
	for index: int in _spell_ids.size():
		var angle := -PI * 0.5 + TAU * float(index) / maxf(float(_spell_ids.size()), 1.0)
		var card := Panel.new()
		card.position = _center + Vector2(cos(angle), sin(angle)) * 295.0 - Vector2(112, 46)
		card.size = Vector2(224, 92)
		root.add_child(card)
		var label := Label.new()
		var spell := GameData.spell(_spell_ids[index])
		label.text = "%d\n%s" % [index + 1, String(spell.get("display_name", _spell_ids[index])).to_upper()]
		label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 10)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 16)
		card.add_child(label)
		_cards.append(card)
	var rule := Label.new()
	rule.text = "SOLTAR  ·  CONJURAR     |     O MUNDO NÃO ABRANDA     |     FICAS VULNERÁVEL"
	rule.position = Vector2(500, 945)
	rule.size = Vector2(920, 44)
	rule.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	rule.add_theme_color_override("font_color", Color("d4b36f"))
	root.add_child(rule)
	_update_cards()


func _process(_delta: float) -> void:
	if _capture_mode or _spell_ids.is_empty():
		return
	var vector := get_viewport().get_mouse_position() - _center
	var stick := Input.get_vector("look_left", "look_right", "look_up", "look_down")
	if stick.length() > 0.45:
		vector = stick * 200.0
	if vector.length() < 70.0:
		return
	var angle := fposmod(vector.angle() + PI * 0.5 + TAU * 0.5 / float(_spell_ids.size()), TAU)
	var index := clampi(floori(angle / TAU * float(_spell_ids.size())), 0, _spell_ids.size() - 1)
	selected_spell_id = _spell_ids[index]
	_update_cards()


func _update_cards() -> void:
	for index: int in _cards.size():
		var selected := _spell_ids[index] == selected_spell_id
		_cards[index].modulate = Color("9ed7ee") if selected else Color("768184")
