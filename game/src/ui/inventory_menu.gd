class_name InventoryMenu
extends CanvasLayer
## Mochila em tempo real. E um leitor/editor do SaveSystem: cada alteracao
## confirmada e atomica e o mundo nunca e pausado por este ecrã.

signal closed
signal equipment_changed

var _gameplay: Node
var _theme: Theme
var _filter := "todos"
var _selected_key := ""
var _list: ItemList
var _detail: RichTextLabel
var _load: RichTextLabel
var _equipped: RichTextLabel
var _action_button: Button
var _favorite_button: Button
var _message: Label
var _filter_buttons: Dictionary = {}


func open(theme: Theme, gameplay: Node) -> void:
	_theme = theme
	_gameplay = gameplay
	layer = 520
	process_mode = Node.PROCESS_MODE_ALWAYS
	InventorySystem.normalise_current()
	_build()
	_refresh()


func _build() -> void:
	var root := Control.new()
	root.theme = _theme
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var shade := ColorRect.new()
	shade.color = Color(0.018, 0.031, 0.036, 0.97)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(shade)
	var title := Label.new()
	title.text = "MOCHILA"
	title.position = Vector2(48, 28)
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color("eadbb9"))
	root.add_child(title)
	var rule := Label.new()
	rule.text = "SEM LIMITE  ·  SÓ O EQUIPADO PESA  ·  O MUNDO CONTINUA"
	rule.position = Vector2(310, 42)
	rule.add_theme_font_size_override("font_size", 16)
	rule.add_theme_color_override("font_color", Color("d4b36f"))
	root.add_child(rule)
	var close := Button.new()
	close.text = "VOLTAR"
	close.position = Vector2(1660, 30)
	close.size = Vector2(210, 54)
	close.pressed.connect(_close)
	root.add_child(close)

	var filters := HBoxContainer.new()
	filters.position = Vector2(48, 96)
	filters.size = Vector2(1822, 48)
	filters.add_theme_constant_override("separation", 6)
	root.add_child(filters)
	var labels := {"todos": "TUDO", "armas": "ARMAS", "armadura": "ARMADURA",
		"aneis": "ANÉIS", "magias": "MAGIAS", "consumiveis": "CONSUMÍVEIS",
		"materiais": "MATERIAIS", "favoritos": "★ FAVORITOS"}
	for filter_name: String in InventorySystem.FILTERS:
		var button := Button.new()
		button.text = String(labels.get(filter_name, filter_name.to_upper()))
		button.toggle_mode = true
		button.custom_minimum_size = Vector2(211, 46)
		button.pressed.connect(_set_filter.bind(filter_name))
		filters.add_child(button)
		_filter_buttons[filter_name] = button

	var list_panel := Panel.new()
	list_panel.position = Vector2(48, 166)
	list_panel.size = Vector2(710, 790)
	root.add_child(list_panel)
	var list_title := Label.new()
	list_title.text = "OBJECTOS"
	list_title.position = Vector2(24, 20)
	list_title.add_theme_color_override("font_color", Color("d4b36f"))
	list_panel.add_child(list_title)
	_list = ItemList.new()
	_list.position = Vector2(20, 62)
	_list.size = Vector2(670, 706)
	_list.select_mode = ItemList.SELECT_SINGLE
	_list.item_selected.connect(_select_item)
	list_panel.add_child(_list)

	var detail_panel := Panel.new()
	detail_panel.position = Vector2(780, 166)
	detail_panel.size = Vector2(650, 790)
	root.add_child(detail_panel)
	var detail_title := Label.new()
	detail_title.text = "DETALHE"
	detail_title.position = Vector2(26, 20)
	detail_title.add_theme_color_override("font_color", Color("d4b36f"))
	detail_panel.add_child(detail_title)
	_detail = RichTextLabel.new()
	_detail.bbcode_enabled = true
	_detail.position = Vector2(26, 62)
	_detail.size = Vector2(598, 520)
	_detail.add_theme_font_size_override("normal_font_size", 18)
	_detail.add_theme_font_size_override("bold_font_size", 24)
	detail_panel.add_child(_detail)
	var actions := HBoxContainer.new()
	actions.position = Vector2(26, 610)
	actions.size = Vector2(598, 58)
	actions.add_theme_constant_override("separation", 10)
	detail_panel.add_child(actions)
	_action_button = Button.new()
	_action_button.text = "EQUIPAR"
	_action_button.custom_minimum_size = Vector2(284, 56)
	_action_button.pressed.connect(_equipment_action)
	actions.add_child(_action_button)
	_favorite_button = Button.new()
	_favorite_button.text = "★ FAVORITO"
	_favorite_button.custom_minimum_size = Vector2(284, 56)
	_favorite_button.pressed.connect(_favorite_action)
	actions.add_child(_favorite_button)
	_message = Label.new()
	_message.position = Vector2(26, 690)
	_message.size = Vector2(598, 70)
	_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message.add_theme_color_override("font_color", Color("96a3a4"))
	detail_panel.add_child(_message)

	var status_panel := Panel.new()
	status_panel.position = Vector2(1452, 166)
	status_panel.size = Vector2(418, 790)
	root.add_child(status_panel)
	var equipment_title := Label.new()
	equipment_title.text = "EQUIPADO"
	equipment_title.position = Vector2(24, 20)
	equipment_title.add_theme_color_override("font_color", Color("d4b36f"))
	status_panel.add_child(equipment_title)
	_equipped = RichTextLabel.new()
	_equipped.bbcode_enabled = true
	_equipped.position = Vector2(24, 60)
	_equipped.size = Vector2(370, 440)
	_equipped.add_theme_font_size_override("normal_font_size", 17)
	status_panel.add_child(_equipped)
	_load = RichTextLabel.new()
	_load.bbcode_enabled = true
	_load.position = Vector2(24, 530)
	_load.size = Vector2(370, 220)
	_load.add_theme_font_size_override("normal_font_size", 17)
	_load.add_theme_font_size_override("bold_font_size", 25)
	status_panel.add_child(_load)
	var footer := Label.new()
	footer.text = "%s  FECHAR  ·  Alterações guardadas imediatamente  ·  Não existe armazém" % \
		SettingsSystem.binding_label("inventory_menu").to_upper()
	footer.position = Vector2(48, 988)
	footer.size = Vector2(1822, 42)
	footer.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	footer.add_theme_color_override("font_color", Color("7f8e90"))
	root.add_child(footer)
	close.grab_focus()


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("inventory_menu") or Input.is_action_just_pressed("pause_menu"):
		get_viewport().set_input_as_handled()
		_close()


func _set_filter(filter_name: String) -> void:
	_filter = filter_name
	_selected_key = ""
	_refresh()


func _refresh() -> void:
	for filter_name: String in _filter_buttons:
		(_filter_buttons[filter_name] as Button).button_pressed = filter_name == _filter
	_list.clear()
	var rows := InventorySystem.filtered_entries(_filter)
	for entry: Dictionary in rows:
		var markers := "%s%s" % ["◆ " if bool(entry.equipped) else "", "★ " if bool(entry.favorite) else ""]
		var count_label := "  ×%d" % int(entry.count) if int(entry.count) > 1 else ""
		_list.add_item("%s%s%s" % [markers, String(entry.name), count_label])
		_list.set_item_metadata(_list.item_count - 1, String(entry.key))
	if _list.item_count > 0:
		var wanted := 0
		for index: int in _list.item_count:
			if String(_list.get_item_metadata(index)) == _selected_key:
				wanted = index
				break
		_list.select(wanted)
		_selected_key = String(_list.get_item_metadata(wanted))
	_show_detail()
	_show_equipped()


func _select_item(index: int) -> void:
	_selected_key = String(_list.get_item_metadata(index))
	_show_detail()


func _show_detail() -> void:
	var entry := InventorySystem.describe_item(_selected_key)
	if entry.is_empty():
		_detail.text = "[color=#7f8e90]Esta categoria está vazia.[/color]"
		_action_button.disabled = true
		_favorite_button.disabled = true
		return
	var data: Dictionary = entry.data
	var kind := _text_value(entry.get("kind"), "")
	var facts: Array[String] = []
	match kind:
		"arma":
			var family := _text_value(_catalog_field(data, "familia", "familia_escudo"), "—")
			facts.append("Família: %s" % family.replace("_", " "))
			facts.append("Mãos: %s" % _whole_number_text(
				_catalog_field(data, "maos", "hands"), "—"))
			facts.append("Alcance: %s m" % _decimal_number_text(
				_catalog_field(data, "alcance_m", "range"), "—"))
		"armadura":
			facts.append("Casa: %s" % _text_value(data.get("slot"), "—").replace("_", " "))
			facts.append("Peso declarado: %.1f" % float(data.get("peso", 0.0)))
		"anel": facts.append("Efeito: %s" % _text_value(data.get("efeito"), "—"))
		"magia":
			facts.append("Escola: %s" % _text_value(data.get("school"), "—"))
			facts.append("Mana: %d  ·  Conjuração: %.1f s" % [int(data.get("mana_cost", 0)), float(data.get("cast_time", 0.0))])
		"material": facts.append("Refinação: %s" % _text_value(data.get("refinement"), "—"))
		"consumivel": facts.append("Uso: %.1f s" % float(data.get("use_seconds", 0.0)))
	var description := _text_value(_catalog_field(data, "descricao_visual", "visual"), "")
	if description == "":
		description = _text_value(data.get("verb"), "Sem descrição.")
	_detail.text = "[b]%s[/b]\n[color=#96a3a4]%s[/color]\n\n%s\n\n%s" % [
		_text_value(entry.get("name"), _selected_key), kind.to_upper(),
		"\n".join(facts), description]
	_action_button.visible = kind in ["arma", "armadura", "anel"]
	_action_button.disabled = not _action_button.visible
	_action_button.text = "DESEQUIPAR" if bool(entry.equipped) else "EQUIPAR"
	_favorite_button.disabled = false
	_favorite_button.text = "★ RETIRAR FAVORITO" if bool(entry.favorite) else "☆ MARCAR FAVORITO"


func _catalog_field(data: Dictionary, primary: String, fallback: String) -> Variant:
	if data.has(primary):
		return data[primary]
	if data.has(fallback):
		return data[fallback]
	return null


func _text_value(value: Variant, fallback: String) -> String:
	return value if typeof(value) == TYPE_STRING else fallback


func _whole_number_text(value: Variant, fallback: String) -> String:
	if typeof(value) not in [TYPE_INT, TYPE_FLOAT]:
		return fallback
	return "%d" % int(value)


func _decimal_number_text(value: Variant, fallback: String) -> String:
	if typeof(value) not in [TYPE_INT, TYPE_FLOAT]:
		return fallback
	return "%.1f" % float(value)


func _show_equipped() -> void:
	var state := GameData.save_state_snapshot()
	var character: Dictionary = state.get("character", {}) as Dictionary
	var inventory: Dictionary = character.get("inventory", {}) as Dictionary
	var equipment: Dictionary = inventory.get("equipment", {}) as Dictionary
	var lines: Array[String] = []
	for row: Array in [["Mão principal", "arma", equipment.get("main")],
		["Mão secundária", "arma", equipment.get("offhand")]]:
		lines.append("[color=#96a3a4]%s[/color]\n%s" % [row[0], _name_for(String(row[1]), row[2])])
	lines.append("[color=#96a3a4]Armadura · 9 casas possíveis[/color]")
	var armor: Array = equipment.get("armor", []) as Array
	lines.append("—" if armor.is_empty() else ", ".join(armor.map(func(v: Variant) -> String: return _name_for("armadura", v))))
	lines.append("[color=#96a3a4]Anéis · 2 casas iniciais[/color]")
	var rings: Array = equipment.get("rings", []) as Array
	lines.append("—" if rings.is_empty() else ", ".join(rings.map(func(v: Variant) -> String: return _name_for("anel", v))))
	lines.append("[color=#96a3a4]Roda de feitiços · %d/8[/color]" % (equipment.get("spell_favorites", []) as Array).size())
	lines.append(", ".join((equipment.get("spell_favorites", []) as Array).map(func(v: Variant) -> String: return _name_for("magia", v))))
	_equipped.text = "\n\n".join(lines)
	var load := InventorySystem.load_profile(state)
	var colour := "#db8d7c" if String(load["class"]) == "sobrecarregado" else "#d4b36f"
	_load.text = "[color=%s][b]%s[/b][/color]\n%.1f / %.1f  ·  %d%%\n\nA mochila não pesa. Este total conta apenas pesos numéricos declarados no catálogo." % [
		colour, String(load["class"]).to_upper(), float(load["weight"]),
		float(load["capacity"]), roundi(float(load["fraction"]) * 100.0)]


func _name_for(kind: String, value: Variant) -> String:
	if value == null or String(value) == "":
		return "—"
	return String(InventorySystem.describe_item("%s:%s" % [kind, String(value)]).get("name", value))


func _equipment_action() -> void:
	var entry := InventorySystem.describe_item(_selected_key)
	var result := InventorySystem.unequip(_selected_key) if bool(entry.get("equipped", false)) \
		else InventorySystem.equip(_selected_key)
	_message.text = String(result.get("message", ""))
	if bool(result.get("ok", false)):
		if is_instance_valid(_gameplay) and _gameplay.has_method("refresh_inventory_state"):
			_gameplay.call("refresh_inventory_state")
		equipment_changed.emit()
	_refresh()


func _favorite_action() -> void:
	var can_change := true
	if _selected_key.begins_with("magia:") and is_instance_valid(_gameplay) \
			and _gameplay.has_method("can_change_spell_favorites"):
		can_change = bool(_gameplay.call("can_change_spell_favorites"))
	var result := InventorySystem.toggle_favorite(_selected_key, can_change)
	_message.text = String(result.get("message", ""))
	if bool(result.get("ok", false)):
		if is_instance_valid(_gameplay) and _gameplay.has_method("refresh_inventory_state"):
			_gameplay.call("refresh_inventory_state")
		_refresh()


func _close() -> void:
	closed.emit()
