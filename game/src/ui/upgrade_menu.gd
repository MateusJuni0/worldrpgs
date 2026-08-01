extends Control
## Ecrã do altar de armas. O altar abre este Control através da acção
## `interact`; navegação/aceitação usam as acções UI do Godot.

signal upgrade_selected(weapon_id: String, state: Dictionary, material_cost: Dictionary)
signal upgrade_reverted(weapon_id: String, state: Dictionary)

const WeaponProgression = preload("res://src/weapons/weapon_progression.gd")

var _progression: RefCounted
var _weapon_id := ""
var _state: Dictionary = {}
var _material_counts: Dictionary = {}
var _choices: Array[Dictionary] = []

var _title: Label
var _summary: Label
var _message: Label
var _choice_list: VBoxContainer


func _ready() -> void:
	_build_ui()


func setup(weapons: Dictionary, equipment: Dictionary, weapon_id: String,
		state := {}, material_counts := {}) -> bool:
	if _title == null:
		_build_ui()
	_progression = WeaponProgression.new()
	if not _progression.call("configure", weapons, equipment):
		_show_message("O catálogo de armas está incoerente.")
		return false
	_weapon_id = weapon_id
	_state = (state as Dictionary).duplicate(true) if not (state as Dictionary).is_empty() \
		else _progression.call("new_upgrade_state") as Dictionary
	_material_counts = (material_counts as Dictionary).duplicate(true)
	if (_progression.call("profile", _weapon_id, _state) as Dictionary).is_empty():
		_show_message("A arma equipada não tem perfil de melhoria.")
		return false
	_refresh()
	show()
	return true


func visible_choices() -> Array[Dictionary]:
	return _choices.duplicate(true)


func upgrade_state() -> Dictionary:
	return _state.duplicate(true)


func set_material_counts(material_counts: Dictionary) -> void:
	_material_counts = material_counts.duplicate(true)
	_refresh()


func select_choice(choice_id: String, material_counts := {}) -> Dictionary:
	if _progression == null:
		return {"ok": false, "message": "O altar ainda não foi configurado."}
	var available: Dictionary = material_counts as Dictionary
	if available.is_empty():
		available = _material_counts
	var selected: Dictionary = {}
	for choice: Dictionary in _choices:
		if String(choice.get("id", "")) == choice_id:
			selected = choice
			break
	if selected.is_empty():
		return {"ok": false, "message": "Esta escolha já não está disponível."}
	var material: Dictionary = selected.get("material", {}) as Dictionary
	var material_id := String(material.get("item_id", ""))
	if material_id == "" or int(available.get(material_id, 0)) <= 0:
		var missing := "Falta %s." % String(material.get("display_name", "material"))
		_show_message(missing)
		return {"ok": false, "message": missing, "material": material}
	var result: Dictionary = _progression.call(
		"choose_upgrade", _weapon_id, _state, choice_id) as Dictionary
	if not bool(result.get("ok", false)):
		_show_message(String(result.get("message", "Escolha indisponível.")))
		return result
	_state = (result.get("state", _state) as Dictionary).duplicate(true)
	result["material_to_consume"] = {"item_id": material_id, "count": 1}
	upgrade_selected.emit(_weapon_id, _state.duplicate(true), result.material_to_consume)
	_show_message("Voto aplicado. A arma aprendeu uma opção; o dano base não mudou.")
	_refresh(false)
	return result


func revert_to(target_level: int) -> bool:
	if _progression == null:
		return false
	var before := int(_state.get("level", 0))
	_state = _progression.call("revert_upgrade", _state, target_level) as Dictionary
	if int(_state.get("level", 0)) == before:
		return false
	upgrade_reverted.emit(_weapon_id, _state.duplicate(true))
	_show_message("Voto revertido. Materiais não são prometidos como reembolso.")
	_refresh(false)
	return true


func _build_ui() -> void:
	if _title != null:
		return
	custom_minimum_size = Vector2(520.0, 420.0)
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(margin)
	var column := VBoxContainer.new()
	margin.add_child(column)
	_title = Label.new()
	_title.add_theme_font_size_override("font_size", 24)
	column.add_child(_title)
	_summary = Label.new()
	_summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_summary)
	column.add_child(HSeparator.new())
	_choice_list = VBoxContainer.new()
	_choice_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	column.add_child(_choice_list)
	_message = Label.new()
	_message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	column.add_child(_message)
	var close_hint := Label.new()
	close_hint.text = "Interactuar no altar abre o ecrã · aceitar escolhe · cancelar fecha"
	column.add_child(close_hint)


func _refresh(clear_message := true) -> void:
	if _progression == null:
		return
	var profile: Dictionary = _progression.call("profile", _weapon_id, _state) as Dictionary
	_title.text = "%s · +%d" % [String(profile.get("nome",
		profile.get("display_name", _weapon_id))), int(_state.get("level", 0))]
	_summary.text = "Peso %.2f · qualquer classe equipa · votos dão postura, moveset e artes; nunca dano base." \
		% float(profile.get("peso", 0.0))
	_choices = _progression.call("upgrade_choices", _weapon_id, _state) as Array[Dictionary]
	for child: Node in _choice_list.get_children():
		_choice_list.remove_child(child)
		child.queue_free()
	for choice: Dictionary in _choices:
		var material: Dictionary = choice.get("material", {}) as Dictionary
		var material_id := String(material.get("item_id", ""))
		var button := Button.new()
		button.text = "%s — %s\nCompromisso: %s" % [
			String(choice.get("label", choice.get("id", ""))),
			String(material.get("display_name", "material")),
			String(choice.get("tradeoff", "")),
		]
		button.disabled = int(_material_counts.get(material_id, 0)) <= 0
		button.pressed.connect(_on_choice_pressed.bind(String(choice.get("id", ""))))
		_choice_list.add_child(button)
	if _choices.is_empty():
		var complete := Label.new()
		complete.text = "+6 concluído. Reverte um voto para escolher outro caminho."
		_choice_list.add_child(complete)
	if clear_message:
		_show_message("")


func _on_choice_pressed(choice_id: String) -> void:
	select_choice(choice_id, _material_counts)


func _show_message(text: String) -> void:
	if _message != null:
		_message.text = text
