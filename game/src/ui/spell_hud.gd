class_name SpellHud
extends CanvasLayer
## Barra compacta dos favoritos e da mana. As marcas são desenhadas em código
## enquanto os PNG aprovados vivem fora de res://; não há asset fantasma.

class SpellSurface extends Control:
	var player: Node

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	func _draw() -> void:
		if not is_instance_valid(player):
			return
		var rules: Dictionary = GameData.spells.get("_rules", {}) as Dictionary
		var slot_count := int(rules.get("favorite_limit", 0))
		if slot_count <= 0:
			return
		var favorites: Array = player.get("favorite_spells") as Array
		var active_id := String(player.get("selected_spell"))
		var mana := int(player.get("mana"))
		var max_mana := int(player.get("max_mana"))
		# A mana fica abaixo da stamina do HUD legado, nunca por cima dela.
		var origin := Vector2(28.0, size.y - 115.0)
		var slot_size := Vector2(56.0, 62.0)
		var gap := 5.0
		var total_width := float(slot_count) * slot_size.x + float(slot_count - 1) * gap

		draw_rect(Rect2(origin - Vector2(8.0, 31.0),
			Vector2(total_width + 16.0, slot_size.y + 70.0)), Color(0.015, 0.025, 0.03, 0.78))
		_draw_mana(origin, total_width, mana, max_mana)
		for index: int in slot_count:
			var spell_id := String(favorites[index]) if index < favorites.size() else ""
			var slot_origin := origin + Vector2(float(index) * (slot_size.x + gap), 0.0)
			_draw_slot(Rect2(slot_origin, slot_size), spell_id, spell_id == active_id, mana)

		var active_spell := GameData.spell(active_id)
		var active_name := String(active_spell.get("display_name", "SEM FEITIÇO")).to_upper()
		var active_cost := int(active_spell.get("mana_cost", 0))
		var active_affordable := not active_spell.is_empty() and mana >= active_cost
		var status := "SEM FEITIÇO" if active_spell.is_empty() else (
			"DISPONÍVEL" if active_affordable else "MANA INSUFICIENTE")
		var status_colour := Color("aab2b4") if active_spell.is_empty() else (
			Color("a9d69a") if active_affordable else Color("e08b7f"))
		_draw_text(origin + Vector2(0.0, -10.0), "%s  ·  %d MANA  ·  %s" % [
			active_name, active_cost, status], 14, status_colour, total_width,
			HORIZONTAL_ALIGNMENT_LEFT)

		var hint := "%s SEGUINTE  ·  %s CONJURAR  ·  %s MEDITAR  %d/%d" % [
			SettingsSystem.binding_label("next_spell").to_upper(),
			SettingsSystem.binding_label("cast").to_upper(),
			SettingsSystem.binding_label("meditate").to_upper(),
			int(player.get("meditation_uses")), int(player.get("meditation_uses_max"))]
		_draw_text(origin + Vector2(0.0, slot_size.y + 22.0), hint, 13,
			Color("d4b36f"), total_width, HORIZONTAL_ALIGNMENT_LEFT)

	func _draw_mana(origin: Vector2, width: float, mana: int, max_mana: int) -> void:
		var bar := Rect2(origin + Vector2(0.0, -25.0), Vector2(minf(width, 300.0), 14.0))
		var fraction := clampf(float(mana) / maxf(float(max_mana), 1.0), 0.0, 1.0)
		draw_rect(bar, Color(0.025, 0.045, 0.065, 0.92))
		draw_rect(Rect2(bar.position, Vector2(bar.size.x * fraction, bar.size.y)), Color("477ca6"))
		_draw_text(bar.position + Vector2(bar.size.x + 10.0, 12.0), "%d / %d" % [mana, max_mana],
			13, Color("9ed7ee"), width - bar.size.x, HORIZONTAL_ALIGNMENT_LEFT)

		if player.has_method("state_name") and String(player.call("state_name")) == "a meditar":
			# A própria subida da mana é o progresso observável; o contorno identifica
			# a acção sem depender dos contadores privados do jogador.
			draw_rect(bar.grow(2.0), Color("d4b36f"), false, 2.0)

	func _draw_slot(rect: Rect2, spell_id: String, active: bool, mana: int) -> void:
		var spell := GameData.spell(spell_id)
		var cost := int(spell.get("mana_cost", 0))
		var affordable := not spell.is_empty() and mana >= cost
		var colour := _school_colour(String(spell.get("school", "")))
		var background := colour.darkened(0.72) if not spell.is_empty() else Color(0.04, 0.05, 0.055, 0.72)
		if not affordable and not spell.is_empty():
			background = background.darkened(0.28)
		draw_rect(rect, background)
		draw_rect(rect, Color("eadbb9") if active else Color(0.32, 0.36, 0.37, 0.9),
			false, 3.0 if active else 1.0)
		if spell.is_empty():
			return
		var display_name := String(spell.get("display_name", spell_id))
		var glyph := display_name.left(1).to_upper()
		_draw_text(rect.position + Vector2(0.0, 30.0), glyph, 23, colour,
			rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)
		_draw_text(rect.position + Vector2(0.0, rect.size.y - 7.0), str(cost), 13,
			Color("a9d69a") if affordable else Color("e08b7f"), rect.size.x,
			HORIZONTAL_ALIGNMENT_CENTER)

	func _school_colour(school_id: String) -> Color:
		var school: Dictionary = (GameData.spells.get("_schools", {}) as Dictionary).get(
			school_id, {}) as Dictionary
		match String(school.get("cor", "")):
			"azul": return Color("72b8df")
			"dourado": return Color("e0c66f")
			"laranja": return Color("dd8a4d")
			"vermelho": return Color("cf655e")
		return Color("aab2b4")

	func _draw_text(at: Vector2, text: String, font_size: int, colour: Color,
			width: float, alignment: HorizontalAlignment) -> void:
		draw_string(ThemeDB.fallback_font, at, text, alignment, width, font_size, colour)


var _surface: SpellSurface
var _has_visible_snapshot := false
var _last_favorites: Array = []
var _last_selected_spell := ""
var _last_mana := 0
var _last_max_mana := 0
var _last_meditation_uses := 0
var _last_meditation_uses_max := 0
var _last_player_state := ""


func setup(player: Node) -> void:
	layer = 53
	_surface = SpellSurface.new()
	_surface.player = player
	add_child(_surface)
	if not SettingsSystem.controls_changed.is_connected(_on_controls_changed):
		SettingsSystem.controls_changed.connect(_on_controls_changed)


func _process(_delta: float) -> void:
	if not is_instance_valid(_surface) or not is_instance_valid(_surface.player):
		return
	var player := _surface.player
	var favorites: Array = (player.get("favorite_spells") as Array).duplicate()
	var selected_spell := String(player.get("selected_spell"))
	var mana := int(player.get("mana"))
	var max_mana := int(player.get("max_mana"))
	var meditation_uses := int(player.get("meditation_uses"))
	var meditation_uses_max := int(player.get("meditation_uses_max"))
	var player_state := String(player.call("state_name")) \
		if player.has_method("state_name") else ""
	if _has_visible_snapshot and favorites == _last_favorites \
			and selected_spell == _last_selected_spell and mana == _last_mana \
			and max_mana == _last_max_mana \
			and meditation_uses == _last_meditation_uses \
			and meditation_uses_max == _last_meditation_uses_max \
			and player_state == _last_player_state:
		return
	_has_visible_snapshot = true
	_last_favorites = favorites
	_last_selected_spell = selected_spell
	_last_mana = mana
	_last_max_mana = max_mana
	_last_meditation_uses = meditation_uses
	_last_meditation_uses_max = meditation_uses_max
	_last_player_state = player_state
	_surface.queue_redraw()


func _on_controls_changed() -> void:
	if is_instance_valid(_surface):
		_surface.queue_redraw()
