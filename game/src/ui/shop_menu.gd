class_name ShopMenu
extends CanvasLayer
## Loja em tempo real: escolhe-se primeiro a casa, nunca se mostra o catálogo
## inteiro, e a comparação com o equipado permanece visível durante a compra.

signal closed
signal transaction_finished(result: Dictionary)

const VendorCatalogScript = preload("res://src/npc/vendor_catalog.gd")
const VendorServiceScript = preload("res://src/npc/vendor_service.gd")
const SlotGrammar = preload("res://src/ui/shop_slots.gd")

var _catalog
var _service
var _theme: Theme
var _gameplay: Node
var _vendor_id := ""
var _mode := "buy"
var _group_id := ""
var _selected_key := ""
var _page := 0
var _visible_entries: Array[Dictionary] = []
var _groups: Array[Dictionary] = []

var _buy_mode_button: Button
var _sell_mode_button: Button
var _souls_label: Label
var _slot_list: ItemList
var _item_list: ItemList
var _page_label: Label
var _previous_page: Button
var _next_page: Button
var _detail: RichTextLabel
var _comparison: RichTextLabel
var _action_button: Button
var _message: Label


func open(theme: Theme, vendor_id: String, gameplay: Node = null) -> bool:
	_theme = theme
	_vendor_id = vendor_id
	_gameplay = gameplay
	layer = 530
	process_mode = Node.PROCESS_MODE_ALWAYS
	_catalog = VendorCatalogScript.new()
	var loaded := bool(_catalog.load_from_game_data(GameData))
	_service = VendorServiceScript.new()
	_service.setup(_catalog, GameData, SaveSystem)
	_build()
	if not loaded:
		_show_fatal("\n".join(_catalog.errors))
		return false
	_refresh_all()
	return true


func _build() -> void:
	var root := Control.new()
	root.theme = _theme
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var shade := ColorRect.new()
	shade.color = Color(0.014, 0.025, 0.030, 0.98)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(shade)

	var title := Label.new()
	title.text = "LOJA"
	title.position = Vector2(48, 24)
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color("eadbb9"))
	root.add_child(title)
	var vendor_name := String(_catalog.vendor(_vendor_id).get("display_name", _vendor_id))
	var subtitle := Label.new()
	subtitle.text = "%s  ·  TODO O CATÁLOGO, SEM DESBLOQUEIOS" % vendor_name.to_upper()
	subtitle.position = Vector2(176, 39)
	subtitle.add_theme_font_size_override("font_size", 17)
	subtitle.add_theme_color_override("font_color", Color("d4b36f"))
	root.add_child(subtitle)

	_buy_mode_button = Button.new()
	_buy_mode_button.text = "COMPRAR"
	_buy_mode_button.toggle_mode = true
	_buy_mode_button.position = Vector2(48, 92)
	_buy_mode_button.size = Vector2(188, 48)
	_buy_mode_button.pressed.connect(_set_mode.bind("buy"))
	root.add_child(_buy_mode_button)
	_sell_mode_button = Button.new()
	_sell_mode_button.text = "VENDER REPETIDOS"
	_sell_mode_button.toggle_mode = true
	_sell_mode_button.position = Vector2(244, 92)
	_sell_mode_button.size = Vector2(220, 48)
	_sell_mode_button.pressed.connect(_set_mode.bind("sell"))
	root.add_child(_sell_mode_button)

	_souls_label = Label.new()
	_souls_label.position = Vector2(1410, 38)
	_souls_label.size = Vector2(260, 44)
	_souls_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_souls_label.add_theme_font_size_override("font_size", 22)
	_souls_label.add_theme_color_override("font_color", Color("d4b36f"))
	root.add_child(_souls_label)
	var close := Button.new()
	close.text = "VOLTAR"
	close.position = Vector2(1690, 28)
	close.size = Vector2(180, 54)
	close.pressed.connect(_close)
	root.add_child(close)

	var slot_panel := Panel.new()
	slot_panel.position = Vector2(48, 160)
	slot_panel.size = Vector2(392, 770)
	root.add_child(slot_panel)
	_add_panel_title(slot_panel, "CASA DE EQUIPAMENTO")
	_slot_list = ItemList.new()
	_slot_list.position = Vector2(18, 58)
	_slot_list.size = Vector2(356, 690)
	_slot_list.select_mode = ItemList.SELECT_SINGLE
	_slot_list.item_selected.connect(_select_group)
	slot_panel.add_child(_slot_list)

	var list_panel := Panel.new()
	list_panel.position = Vector2(462, 160)
	list_panel.size = Vector2(640, 770)
	root.add_child(list_panel)
	_add_panel_title(list_panel, "ORDENADO POR PREÇO · DEPOIS NOME")
	_item_list = ItemList.new()
	_item_list.position = Vector2(18, 58)
	_item_list.size = Vector2(604, 614)
	_item_list.select_mode = ItemList.SELECT_SINGLE
	_item_list.item_selected.connect(_select_item)
	list_panel.add_child(_item_list)
	_previous_page = Button.new()
	_previous_page.text = "‹ ANTERIOR"
	_previous_page.position = Vector2(18, 690)
	_previous_page.size = Vector2(160, 54)
	_previous_page.pressed.connect(_change_page.bind(-1))
	list_panel.add_child(_previous_page)
	_page_label = Label.new()
	_page_label.position = Vector2(190, 700)
	_page_label.size = Vector2(242, 40)
	_page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_page_label.add_theme_color_override("font_color", Color("96a3a4"))
	list_panel.add_child(_page_label)
	_next_page = Button.new()
	_next_page.text = "SEGUINTE ›"
	_next_page.position = Vector2(444, 690)
	_next_page.size = Vector2(178, 54)
	_next_page.pressed.connect(_change_page.bind(1))
	list_panel.add_child(_next_page)

	var detail_panel := Panel.new()
	detail_panel.position = Vector2(1124, 160)
	detail_panel.size = Vector2(746, 770)
	root.add_child(detail_panel)
	_add_panel_title(detail_panel, "OPÇÃO E EQUIPADO · LADO A LADO")
	_detail = RichTextLabel.new()
	_detail.bbcode_enabled = true
	_detail.position = Vector2(22, 58)
	_detail.size = Vector2(702, 300)
	_detail.add_theme_font_size_override("normal_font_size", 17)
	_detail.add_theme_font_size_override("bold_font_size", 24)
	detail_panel.add_child(_detail)
	_comparison = RichTextLabel.new()
	_comparison.bbcode_enabled = true
	_comparison.position = Vector2(22, 374)
	_comparison.size = Vector2(702, 260)
	_comparison.add_theme_font_size_override("normal_font_size", 16)
	_comparison.add_theme_font_size_override("bold_font_size", 19)
	detail_panel.add_child(_comparison)
	_action_button = Button.new()
	_action_button.position = Vector2(22, 660)
	_action_button.size = Vector2(702, 66)
	_action_button.pressed.connect(_perform_transaction)
	detail_panel.add_child(_action_button)

	_message = Label.new()
	_message.position = Vector2(48, 952)
	_message.size = Vector2(1822, 72)
	_message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_message.add_theme_font_size_override("font_size", 17)
	_message.add_theme_color_override("font_color", Color("96a3a4"))
	root.add_child(_message)
	close.grab_focus()


func _add_panel_title(panel: Control, text: String) -> void:
	var label := Label.new()
	label.text = text
	label.position = Vector2(20, 18)
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color("d4b36f"))
	panel.add_child(label)


func _set_mode(mode: String) -> void:
	_mode = mode
	_group_id = ""
	_selected_key = ""
	_page = 0
	_message.text = ""
	_refresh_all()


func _refresh_all() -> void:
	_buy_mode_button.button_pressed = _mode == "buy"
	_sell_mode_button.button_pressed = _mode == "sell"
	var state := GameData.save_state_snapshot()
	var entries: Array[Dictionary]
	if _mode == "buy":
		entries = _catalog.entries_for_vendor(_vendor_id)
	else:
		entries = _sale_entries(state)
	_groups = SlotGrammar.groups_for_entries(entries, _catalog.config)
	if _groups.is_empty():
		_group_id = ""
	elif not _group_exists(_group_id):
		_group_id = String(_groups[0].get("id", ""))
	_slot_list.clear()
	for group: Dictionary in _groups:
		_slot_list.add_item(String(group.get("label", "")))
		_slot_list.set_item_metadata(_slot_list.item_count - 1, String(group.get("id", "")))
		if String(group.get("id", "")) == _group_id:
			_slot_list.select(_slot_list.item_count - 1)
	_update_souls(state)
	_refresh_items(entries)


func _refresh_items(source_entries: Array[Dictionary]) -> void:
	_visible_entries = SlotGrammar.filter_entries(source_entries, _group_id, _catalog.config)
	_visible_entries.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		var price_a := _display_price(a)
		var price_b := _display_price(b)
		if price_a != price_b:
			return price_a < price_b
		return String(a.get("name", "")).naturalnocasecmp_to(
			String(b.get("name", ""))) < 0)
	var page_size := maxi(1, int((_catalog.config.get("presentation", {}) as Dictionary).get(
		"page_size", 24)))
	var page_count := maxi(1, ceili(float(_visible_entries.size()) / float(page_size)))
	_page = clampi(_page, 0, page_count - 1)
	var start := _page * page_size
	var finish := mini(start + page_size, _visible_entries.size())
	_item_list.clear()
	for index: int in range(start, finish):
		var value := _visible_entries[index]
		var owned: int = _service.owned_count(String(value.get("key", "")))
		var owned_label := "  ·  tens %d" % owned if owned > 0 else ""
		_item_list.add_item("%s  ·  %d almas%s" % [
			String(value.get("name", "")), _display_price(value), owned_label])
		_item_list.set_item_metadata(_item_list.item_count - 1,
			String(value.get("key", "")))
	_page_label.text = "PÁGINA %d / %d  ·  %d OPÇÕES" % [
		_page + 1, page_count, _visible_entries.size()]
	_previous_page.disabled = _page == 0
	_next_page.disabled = _page >= page_count - 1
	_select_visible_key()
	_show_detail()


func _sale_entries(state: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	var character: Dictionary = state.get("character", {}) as Dictionary
	var inventory: Dictionary = character.get("inventory", {}) as Dictionary
	var items: Dictionary = inventory.get("items", {}) as Dictionary
	for key_value: Variant in items.keys():
		var value: Dictionary = _catalog.entry(String(key_value))
		if not value.is_empty() and String(value.get("vendor_id", "")) == _vendor_id \
				and int(items.get(key_value, 0)) > 0:
			value["owned_count"] = int(items.get(key_value, 0))
			result.append(value)
	return result


func _select_group(index: int) -> void:
	_group_id = String(_slot_list.get_item_metadata(index))
	_selected_key = ""
	_page = 0
	_refresh_all()


func _select_item(index: int) -> void:
	_selected_key = String(_item_list.get_item_metadata(index))
	_show_detail()


func _change_page(delta: int) -> void:
	_page += delta
	_selected_key = ""
	_refresh_all()


func _select_visible_key() -> void:
	if _item_list.item_count == 0:
		_selected_key = ""
		return
	var wanted := 0
	for index: int in _item_list.item_count:
		if String(_item_list.get_item_metadata(index)) == _selected_key:
			wanted = index
			break
	_item_list.select(wanted)
	_selected_key = String(_item_list.get_item_metadata(wanted))


func _show_detail() -> void:
	var value: Dictionary = _catalog.entry(_selected_key)
	if value.is_empty():
		_detail.text = "[color=#7f8e90]Esta casa não tem objectos neste modo.[/color]"
		_comparison.text = ""
		_action_button.disabled = true
		_action_button.text = "SEM OPÇÕES"
		return
	var data: Dictionary = value.get("data", {}) as Dictionary
	var facts: Array[String] = _facts_for(value)
	var description := String(data.get("descricao_visual", data.get("visual", "Sem descrição visual.")))
	_detail.text = "[b]%s[/b]\n[color=#d4b36f]%d ALMAS · %s[/color]\n\n%s\n\n[color=#96a3a4]%s[/color]" % [
		String(value.get("name", "")), _display_price(value),
		String(value.get("kind", "")).to_upper(), "\n".join(facts), description]
	var state := GameData.save_state_snapshot()
	var equipped_keys: Array[String] = SlotGrammar.equipped_item_keys(
		_group_id, state, GameData, _catalog.config)
	var comparison_lines: Array[String] = ["[b]EQUIPADO NESTA CASA[/b]"]
	if equipped_keys.is_empty():
		comparison_lines.append("[color=#7f8e90]— casa vazia —[/color]")
	else:
		var position := 1
		for item_key: String in equipped_keys:
			var equipped: Dictionary = _catalog.entry(item_key)
			comparison_lines.append("%d. %s" % [position,
				_comparison_summary(equipped, item_key)])
			position += 1
	comparison_lines.append("\n[color=#96a3a4]A comparação descreve escolhas; não declara uma opção ‘melhor’.[/color]")
	_comparison.text = "\n".join(comparison_lines)
	var owned: int = _service.owned_count(_selected_key, state)
	if _mode == "buy":
		var price := int(value.get("price", 0))
		var progression: Dictionary = (state.get("character", {}) as Dictionary).get(
			"progression", {}) as Dictionary
		var souls := int(progression.get("souls_held", 0))
		var already_owned := bool(value.get("unique", false)) and owned > 0
		var insufficient_souls := souls < price
		_action_button.disabled = already_owned or insufficient_souls
		if already_owned:
			_action_button.text = "JÁ POSSUÍDO"
		elif insufficient_souls:
			_action_button.text = "FALTAM %d ALMAS" % (price - souls)
		else:
			_action_button.text = "COMPRAR 1  ·  %d ALMAS" % price
	else:
		_action_button.disabled = false
		_action_button.text = "VENDER 1  ·  %d ALMAS" % _catalog.sell_price(_selected_key)


func _facts_for(value: Dictionary) -> Array[String]:
	var data: Dictionary = value.get("data", {}) as Dictionary
	var facts: Array[String] = []
	match String(value.get("kind", "")):
		"arma":
			facts.append("Família: %s · mãos: %d · alcance: %.1f m" % [
				str(data.get("familia", "—")).replace("_", " "),
				int(data.get("maos", 0)), float(data.get("alcance_m", 0.0))])
			facts.append("Pergunta de combate: %s" % str(data.get("pergunta", "—")))
			if GameData.weapon(String(value.get("id", ""))).is_empty():
				facts.append("[color=#db8d7c]Ficha futura: o moveset ainda não executa no protótipo.[/color]")
		"armadura":
			facts.append("Casa: %s · peso: %.1f" % [
				str(data.get("slot", "—")).replace("_", " "), float(data.get("peso", 0.0))])
			facts.append("Opção: %s" % str(data.get("habilidade", "—")))
			if data.has("implemented") and not bool(data.get("implemented", false)):
				facts.append("[color=#db8d7c]Ficha futura: efeito ainda não executa no protótipo.[/color]")
		"anel":
			facts.append("Eixo: %s" % str(data.get("eixo", "—")).replace("_", " "))
			facts.append("Efeito: %s" % str(data.get("efeito", "—")))
		"magia":
			facts.append("Escola: %s · mana: %d" % [str(data.get("school", "—")),
				int(data.get("mana_cost", 0))])
			facts.append("Verbo: %s" % str(data.get("verb", "—")))
			if str(data.get("type", "")) == "catalog_only":
				facts.append("[color=#db8d7c]Ficha futura: ainda não executa no protótipo.[/color]")
		"consumivel":
			facts.append("Uso: %.1f s · pilha: %d" % [float(data.get("use_seconds", 0.0)),
				int(data.get("max_stack", 0))])
		"material":
			facts.append("Refinação: %d · valor de troca: %d almas" % [
				int(data.get("refinement", 0)), int(data.get("trade_value", 0))])
	return facts


func _comparison_summary(value: Dictionary, fallback_key: String) -> String:
	if value.is_empty():
		return fallback_key
	var facts := _facts_for(value)
	var first_fact := facts[0] if not facts.is_empty() else ""
	return "[b]%s[/b] — %s" % [String(value.get("name", fallback_key)), first_fact]


func _perform_transaction() -> void:
	if _selected_key == "":
		return
	var result: Dictionary = _service.purchase(_selected_key) if _mode == "buy" \
		else _service.sell(_selected_key)
	_message.text = String(result.get("message", ""))
	_message.add_theme_color_override("font_color",
		Color("9fc59f") if bool(result.get("ok", false)) else Color("db8d7c"))
	if bool(result.get("ok", false)):
		if is_instance_valid(_gameplay) and _gameplay.has_method("refresh_inventory_state"):
			_gameplay.call("refresh_inventory_state")
		transaction_finished.emit(result)
	_refresh_all()


func _display_price(value: Dictionary) -> int:
	return int(value.get("price", 0)) if _mode == "buy" \
		else _catalog.sell_price(String(value.get("key", "")))


func _update_souls(state: Dictionary) -> void:
	var character: Dictionary = state.get("character", {}) as Dictionary
	var progression: Dictionary = character.get("progression", {}) as Dictionary
	_souls_label.text = "%d ALMAS" % int(progression.get("souls_held", 0))


func _group_exists(group_id: String) -> bool:
	for group: Dictionary in _groups:
		if String(group.get("id", "")) == group_id:
			return true
	return false


func _show_fatal(message: String) -> void:
	_detail.text = "[color=#db8d7c][b]A loja recusou abrir[/b]\n%s[/color]" % message
	_action_button.disabled = true
	_action_button.text = "DADOS INVÁLIDOS"


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel") \
			or Input.is_action_just_pressed("inventory_menu") \
			or Input.is_action_just_pressed("pause_menu"):
		_close()
		get_viewport().set_input_as_handled()


func _close() -> void:
	closed.emit()
	queue_free()
