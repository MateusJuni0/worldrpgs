class_name ArmorEquipmentScreen
extends Control
## Ecrã WP11 de armadura. A ordem dos slots vem de armor.json, tal como todos
## os outros consumidores; seleccionar calcula a carga, confirmar chama a única
## fronteira de persistência existente (InventorySystem.equip).

signal equipment_confirmed(result: Dictionary)
signal closed

const ArmorSystem = preload("res://src/equipment/armor_system.gd")

var _slot_list: ItemList
var _piece_list: ItemList
var _details: RichTextLabel
var _confirm: Button
var _message: Label
var _model := {}
var _selected_slot := ""
var _selected_candidate := ""


static func build_model(state: Dictionary, class_id := "", selected_slot := "",
		candidate_id := "") -> Dictionary:
	var slots: Array = (GameData.armor.get("slots", []) as Array).duplicate()
	var groups := {}
	for slot_value: Variant in slots:
		groups[String(slot_value)] = []
	for entry: Dictionary in InventorySystem.entries(state):
		if String(entry.get("kind", "")) != "armadura":
			continue
		var item_id := String(entry.get("id", ""))
		var slot := String((entry.get("data", {}) as Dictionary).get("slot", ""))
		if groups.has(slot):
			(groups[slot] as Array).append(item_id)
	for slot_value: Variant in slots:
		(groups[String(slot_value)] as Array).sort_custom(func(a: Variant, b: Variant) -> bool:
			return String(ArmorSystem.armor_piece(String(a)).get("nome", a)) \
				< String(ArmorSystem.armor_piece(String(b)).get("nome", b)))
	var character: Dictionary = state.get("character", {}) as Dictionary
	var inventory: Dictionary = character.get("inventory", {}) as Dictionary
	var equipment: Dictionary = inventory.get("equipment", {}) as Dictionary
	var equipped_ids: Array = (equipment.get("armor", []) as Array).duplicate()
	var current_by_slot := {}
	for equipped_value: Variant in equipped_ids:
		var equipped_id := String(equipped_value)
		var equipped_slot := String(ArmorSystem.armor_piece(equipped_id).get("slot", ""))
		if equipped_slot != "":
			current_by_slot[equipped_slot] = equipped_id
	if selected_slot == "" and not slots.is_empty():
		selected_slot = String(slots[0])
	var preview := {}
	if candidate_id != "" and (groups.get(selected_slot, []) as Array).has(candidate_id):
		var progression: Dictionary = character.get("progression", {}) as Dictionary
		var attrs: Dictionary = progression.get("attributes", {}) as Dictionary
		var total_load: Dictionary = InventorySystem.load_profile(state)
		var non_armor_weight := float(total_load.get("weight", 0.0)) \
			- ArmorSystem.armor_weight(equipped_ids)
		preview = ArmorSystem.preview_equip(equipped_ids, candidate_id,
			int(attrs.get("carga", 0)), class_id, non_armor_weight)
	return {
		"slot_order": slots,
		"slot_groups": groups,
		"current_by_slot": current_by_slot,
		"selected_slot": selected_slot,
		"candidate_id": candidate_id,
		"preview": preview,
	}


func _ready() -> void:
	_build_ui()
	visible = false


func open_for_current() -> void:
	open_for_state(GameData.save_state_snapshot(), String(
		(GameData.save_state_snapshot().get("character", {}) as Dictionary).get("class_id", "")))


func open_for_state(state: Dictionary, class_id := "", selected_slot := "",
		candidate_id := "") -> void:
	if selected_slot != "":
		_selected_slot = selected_slot
	if candidate_id != "":
		_selected_candidate = candidate_id
	_model = build_model(state, class_id, _selected_slot, _selected_candidate)
	_selected_slot = String(_model.get("selected_slot", ""))
	visible = true
	_refresh_lists()
	_slot_list.grab_focus()


func close_screen() -> void:
	visible = false
	closed.emit()


func _build_ui() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	process_mode = Node.PROCESS_MODE_ALWAYS
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.01, 0.018, 0.022, 0.96)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 48)
	margin.add_theme_constant_override("margin_top", 36)
	margin.add_theme_constant_override("margin_right", 48)
	margin.add_theme_constant_override("margin_bottom", 36)
	add_child(margin)
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 20)
	margin.add_child(columns)
	_slot_list = ItemList.new()
	_slot_list.custom_minimum_size.x = 280
	_slot_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_slot_list.item_selected.connect(_on_slot_selected)
	columns.add_child(_slot_list)
	_piece_list = ItemList.new()
	_piece_list.custom_minimum_size.x = 430
	_piece_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_piece_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_piece_list.item_selected.connect(_on_piece_selected)
	columns.add_child(_piece_list)
	var comparison := VBoxContainer.new()
	comparison.custom_minimum_size.x = 510
	comparison.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	columns.add_child(comparison)
	var title := Label.new()
	title.text = _ui("title")
	title.add_theme_font_size_override("font_size", 28)
	comparison.add_child(title)
	_details = RichTextLabel.new()
	_details.bbcode_enabled = true
	_details.fit_content = false
	_details.size_flags_vertical = Control.SIZE_EXPAND_FILL
	comparison.add_child(_details)
	_message = Label.new()
	_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	comparison.add_child(_message)
	_confirm = Button.new()
	_confirm.text = _ui("confirm")
	_confirm.disabled = true
	_confirm.pressed.connect(_confirm_selection)
	comparison.add_child(_confirm)
	var close_button := Button.new()
	close_button.text = _ui("back")
	close_button.pressed.connect(close_screen)
	comparison.add_child(close_button)


func _refresh_lists() -> void:
	_slot_list.clear()
	var order: Array = _model.get("slot_order", []) as Array
	var current_by_slot: Dictionary = _model.get("current_by_slot", {}) as Dictionary
	for slot_value: Variant in order:
		var slot := String(slot_value)
		var current_id := String(current_by_slot.get(slot, ""))
		var current_name := "—" if current_id == "" else String(
			ArmorSystem.armor_piece(current_id).get("nome", current_id))
		_slot_list.add_item("%s  ·  %s" % [_slot_label(slot), current_name])
		_slot_list.set_item_metadata(_slot_list.item_count - 1, slot)
		if slot == _selected_slot:
			_slot_list.select(_slot_list.item_count - 1)
	_refresh_pieces()


func _refresh_pieces() -> void:
	_piece_list.clear()
	var groups: Dictionary = _model.get("slot_groups", {}) as Dictionary
	for piece_value: Variant in groups.get(_selected_slot, []):
		var piece_id := String(piece_value)
		var piece := ArmorSystem.armor_piece(piece_id)
		_piece_list.add_item("%s  ·  %.1f" % [String(piece.get("nome", piece_id)),
			float(piece.get("peso", 0.0))])
		_piece_list.set_item_metadata(_piece_list.item_count - 1, piece_id)
		if piece_id == _selected_candidate:
			_piece_list.select(_piece_list.item_count - 1)
	_refresh_comparison()


func _refresh_comparison() -> void:
	var preview: Dictionary = _model.get("preview", {}) as Dictionary
	_confirm.disabled = preview.is_empty() or not bool(preview.get("can_equip", false))
	if preview.is_empty():
		_details.text = _ui("empty_comparison")
		return
	var candidate := ArmorSystem.armor_piece(String(preview.get("candidate_id", "")))
	var current := ArmorSystem.armor_piece(String(preview.get("replaced_id", "")))
	var before: Dictionary = preview.get("before", {}) as Dictionary
	var after: Dictionary = preview.get("after", {}) as Dictionary
	var scale := float((GameData.armor.get("resistance_rules", {}) as Dictionary).get(
		"percent_scale", 1.0))
	_details.text = _ui("comparison_template") % [
		String(candidate.get("nome", "—")), String(current.get("nome", "—")),
		float(before.get("weight", 0.0)), float(before.get("capacity", 0.0)),
		roundi(float(before.get("fraction", 0.0)) * scale), String(before.get("class", "")),
		float(after.get("weight", 0.0)), float(after.get("capacity", 0.0)),
		roundi(float(after.get("fraction", 0.0)) * scale), String(after.get("class", "")),
		float(before.get("dodge_distance", 0.0)), int(before.get("dodge_duration_frames", 0)),
		float(after.get("dodge_distance", 0.0)), int(after.get("dodge_duration_frames", 0)),
		int(before.get("iframe_start_frame", -1)), int(before.get("iframe_end_frame", -1)),
		int(after.get("iframe_start_frame", -1)), int(after.get("iframe_end_frame", -1)),
		_resistance_text(candidate.get("resistencias", {}) as Dictionary)]


func _on_slot_selected(index: int) -> void:
	_selected_slot = String(_slot_list.get_item_metadata(index))
	_selected_candidate = ""
	_model = build_model(GameData.save_state_snapshot(), _current_class_id(), _selected_slot)
	_refresh_pieces()


func _on_piece_selected(index: int) -> void:
	_selected_candidate = String(_piece_list.get_item_metadata(index))
	_model = build_model(GameData.save_state_snapshot(), _current_class_id(),
		_selected_slot, _selected_candidate)
	_refresh_comparison()


func _confirm_selection() -> void:
	if _selected_candidate == "":
		return
	var result := InventorySystem.equip("armadura:%s" % _selected_candidate)
	_message.text = String(result.get("message", ""))
	equipment_confirmed.emit(result)
	if bool(result.get("ok", false)):
		_model = build_model(GameData.save_state_snapshot(), _current_class_id(),
			_selected_slot, _selected_candidate)
		_refresh_lists()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("inventory_menu"):
		close_screen()
		get_viewport().set_input_as_handled()


func _current_class_id() -> String:
	return String((GameData.save_state_snapshot().get("character", {}) as Dictionary).get(
		"class_id", ""))


static func _slot_label(slot: String) -> String:
	var labels: Dictionary = ((GameData.armor.get("ui", {}) as Dictionary).get(
		"slot_labels", {}) as Dictionary)
	return String(labels.get(slot, slot.to_upper()))


static func _resistance_text(resistances: Dictionary) -> String:
	if resistances.is_empty():
		return _ui("no_resistance")
	var lines: Array[String] = []
	for damage_type: String in resistances:
		lines.append("%s: %.1f%%" % [damage_type.replace("_", " ").capitalize(),
			float(resistances[damage_type])])
	return "\n".join(lines)


static func _ui(id: String) -> String:
	return String((GameData.armor.get("ui", {}) as Dictionary).get(id, id))
