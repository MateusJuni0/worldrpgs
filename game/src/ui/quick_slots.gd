class_name QuickSlots
extends CanvasLayer
## Caixa compacta de acesso rapido: as quatro categorias ficam legiveis ao mesmo
## tempo e nunca pausam o jogo. As accoes sao IDs de controls.json; a UI pede os
## labels actuais ao SettingsSystem, portanto remapear nao deixa texto obsoleto.

const REFRESH_SECONDS := 0.10


class QuickSlotsSurface extends Control:
	var slots: Array[Dictionary] = []


	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


	func _draw() -> void:
		if slots.is_empty():
			return
		var origin := Vector2(24.0, maxf(130.0, size.y - 590.0))
		var cell_size := Vector2(78.0, 78.0)
		var positions := {
			"spell": origin + Vector2(82.0, 0.0),
			"left_hand": origin + Vector2(0.0, 82.0),
			"right_hand": origin + Vector2(164.0, 82.0),
			"item": origin + Vector2(82.0, 164.0),
		}
		draw_rect(Rect2(origin - Vector2(8.0, 26.0), Vector2(258.0, 276.0)),
			Color(0.012, 0.019, 0.022, 0.72))
		_draw_text(origin + Vector2(0.0, -8.0), "ACESSO RAPIDO", 13,
			Color("d4b36f"), 242.0, HORIZONTAL_ALIGNMENT_CENTER)
		for slot: Dictionary in slots:
			var slot_name := String(slot.get("slot", ""))
			if not positions.has(slot_name):
				continue
			_draw_slot(Rect2(positions[slot_name] as Vector2, cell_size), slot)


	func _draw_slot(rect: Rect2, slot: Dictionary) -> void:
		var slot_name := String(slot.get("slot", ""))
		var kind := String(slot.get("kind", ""))
		var tint := _kind_colour(kind)
		draw_rect(rect, Color(0.035, 0.045, 0.047, 0.94))
		draw_rect(rect, tint.darkened(0.12), false, 2.0)
		var icon_rect := Rect2(rect.position + Vector2(14.0, 15.0), Vector2(50.0, 43.0))
		if kind == "arma" and _draw_weapon_icon(icon_rect, slot, tint):
			pass
		elif String(slot.get("key", "")) == "consumivel:frasco_bruma":
			_draw_flask(icon_rect, tint)
		elif kind == "magia":
			_draw_spell(icon_rect, String(slot.get("name", "?")), tint)
		else:
			_draw_state(icon_rect, tint)
		var category: String = String({
			"spell": "FEITICO", "left_hand": "MAO E",
			"right_hand": "MAO D", "item": "ITEM",
		}.get(slot_name, slot_name))
		_draw_text(rect.position + Vector2(3.0, 11.0), String(category), 10,
			Color("aab2b4"), rect.size.x - 6.0, HORIZONTAL_ALIGNMENT_CENTER)
		if bool(slot.get("show_count", false)):
			_draw_text(rect.position + Vector2(3.0, rect.size.y - 8.0),
				str(int(slot.get("count", 0))), 16, Color("f0e4c8"),
				rect.size.x - 8.0, HORIZONTAL_ALIGNMENT_RIGHT)
		var hint := _binding_hint(slot)
		var hint_size := _fitted_font_size(hint, rect.size.x - 4.0, 10)
		_draw_text(rect.position + Vector2(2.0, rect.size.y + 15.0), hint, hint_size,
			Color("d4b36f"), rect.size.x - 4.0, HORIZONTAL_ALIGNMENT_CENTER)


	func _draw_weapon_icon(rect: Rect2, slot: Dictionary, tint: Color) -> bool:
		var data: Dictionary = slot.get("data", {}) as Dictionary
		if String(data.get("familia_escudo", "")) != "":
			_draw_shield(rect, tint)
			return true
		var family_id := String(data.get("familia", ""))
		if family_id == "":
			return false
		_draw_family_weapon(rect, family_id, tint)
		return true


	func _draw_family_weapon(rect: Rect2, family_id: String, tint: Color) -> void:
		var centre := rect.get_center()
		match family_id:
			"arco":
				draw_arc(centre + Vector2(-3.0, 0.0), 18.0, -1.15, 1.15,
					16, tint, 3.0)
				draw_line(centre + Vector2(4.0, -16.0),
					centre + Vector2(4.0, 16.0), tint.lightened(0.2), 2.0)
			"besta":
				draw_line(centre + Vector2(-19.0, -9.0),
					centre + Vector2(19.0, -9.0), tint, 4.0)
				draw_line(centre + Vector2(0.0, -16.0),
					centre + Vector2(0.0, 19.0), tint.lightened(0.2), 4.0)
				_draw_arrow_head(centre + Vector2(0.0, -17.0), tint)
			"cajado":
				draw_line(centre + Vector2(-11.0, 19.0),
					centre + Vector2(9.0, -15.0), tint, 5.0)
				draw_circle(centre + Vector2(11.0, -18.0), 7.0,
					tint.lightened(0.2))
			"haste":
				draw_line(centre + Vector2(-14.0, 19.0),
					centre + Vector2(12.0, -15.0), tint, 4.0)
				_draw_arrow_head(centre + Vector2(14.0, -18.0), tint)
			"pesada_corte":
				draw_line(centre + Vector2(-13.0, 18.0),
					centre + Vector2(8.0, -10.0), tint.darkened(0.28), 6.0)
				draw_colored_polygon(PackedVector2Array([
					centre + Vector2(2.0, -17.0), centre + Vector2(19.0, -8.0),
					centre + Vector2(10.0, 5.0), centre + Vector2(-1.0, -4.0),
				]), tint)
			_:
				var blade_width := 4.0 if family_id == "adaga" else 6.0
				var blade_start := centre + Vector2(-7.0, 8.0) \
					if family_id == "adaga" else centre + Vector2(-12.0, 13.0)
				draw_line(blade_start, centre + Vector2(14.0, -16.0),
					tint.lightened(0.24), blade_width)
				draw_line(centre + Vector2(-13.0, 4.0),
					centre + Vector2(0.0, 17.0), tint, 4.0)
				draw_circle(centre + Vector2(-11.0, 16.0), 3.0, tint.darkened(0.2))


	func _draw_arrow_head(tip: Vector2, tint: Color) -> void:
		draw_colored_polygon(PackedVector2Array([
			tip + Vector2(0.0, -5.0), tip + Vector2(6.0, 7.0),
			tip + Vector2(-6.0, 7.0),
		]), tint)


	func _draw_shield(rect: Rect2, tint: Color) -> void:
		var centre := rect.get_center()
		var points := PackedVector2Array([
			centre + Vector2(-18.0, -17.0), centre + Vector2(18.0, -17.0),
			centre + Vector2(15.0, 9.0), centre + Vector2(0.0, 21.0),
			centre + Vector2(-15.0, 9.0),
		])
		draw_colored_polygon(points, tint.darkened(0.5))
		var outline := points.duplicate()
		outline.append(points[0])
		draw_polyline(outline, tint, 2.0)
		draw_line(centre + Vector2(0.0, -15.0), centre + Vector2(0.0, 15.0),
			tint.lightened(0.22), 2.0)


	func _draw_flask(rect: Rect2, tint: Color) -> void:
		var neck := Rect2(rect.position + Vector2(19.0, 2.0), Vector2(12.0, 13.0))
		var body := Rect2(rect.position + Vector2(11.0, 14.0), Vector2(28.0, 27.0))
		draw_rect(neck, tint.darkened(0.35))
		draw_rect(body, tint.darkened(0.58))
		draw_rect(body, tint, false, 2.0)
		draw_circle(body.position + Vector2(14.0, 21.0), 8.0, Color("76c6cf"))


	func _draw_spell(rect: Rect2, display_name: String, tint: Color) -> void:
		var centre := rect.get_center()
		draw_circle(centre, 18.0, tint.darkened(0.58))
		draw_circle(centre, 18.0, tint, false, 2.0)
		_draw_text(rect.position + Vector2(0.0, 31.0), display_name.left(1).to_upper(),
			22, Color("f2ead7"), rect.size.x, HORIZONTAL_ALIGNMENT_CENTER)


	func _draw_state(rect: Rect2, tint: Color) -> void:
		draw_line(rect.position + Vector2(10.0, 32.0),
			rect.position + Vector2(40.0, 10.0), tint, 4.0)
		draw_line(rect.position + Vector2(10.0, 10.0),
			rect.position + Vector2(40.0, 32.0), tint, 4.0)


	func _binding_hint(slot: Dictionary) -> String:
		var action := String(slot.get("cycle_action", ""))
		if action != "":
			return SettingsSystem.binding_label(action).to_upper()
		if String(slot.get("slot", "")) == "item" \
				and InputMap.has_action("use_item"):
			return SettingsSystem.binding_label("use_item").to_upper()
		return "SEM DIRECCAO"


	func _kind_colour(kind: String) -> Color:
		match kind:
			"arma": return Color("c7aa72")
			"magia": return Color("78b9df")
			"consumivel": return Color("78bea5")
		return Color("879194")


	func _fitted_font_size(value: String, width: float, preferred: int) -> int:
		var measured := ThemeDB.fallback_font.get_string_size(value,
			HORIZONTAL_ALIGNMENT_LEFT, -1.0, preferred).x
		if measured <= width:
			return preferred
		return maxi(6, floori(float(preferred) * width / maxf(measured, 1.0)))


	func _draw_text(at: Vector2, value: String, font_size: int, colour: Color,
			width: float, alignment: HorizontalAlignment) -> void:
		draw_string(ThemeDB.fallback_font, at, value, alignment, width,
			font_size, colour)


var _inventory: Node
var _surface: QuickSlotsSurface
var _player: Node
var _refresh_elapsed := REFRESH_SECONDS


func setup(inventory: Node) -> void:
	_inventory = inventory
	layer = 52
	process_physics_priority = 100
	_surface = QuickSlotsSurface.new()
	add_child(_surface)
	if not _inventory.is_connected("inventory_changed", _on_inventory_changed):
		_inventory.connect("inventory_changed", _on_inventory_changed)


func _physics_process(_delta: float) -> void:
	_resolve_player()
	visible = is_instance_valid(_player) and bool(_player.get("input_enabled")) \
		and not get_tree().paused
	if not visible:
		return
	for slot_name: String in ["right_hand", "left_hand", "item"]:
		var action := String(_inventory.call("quick_slot_action", slot_name))
		if action != "" and Input.is_action_just_pressed(action):
			var result: Dictionary = _inventory.call(
				"cycle_quick_slot", slot_name, 1) as Dictionary
			if bool(result.get("ok", false)):
				_sync_player_from_inventory()
				_refresh()


func _process(delta: float) -> void:
	if not visible:
		return
	_refresh_elapsed += delta
	if _refresh_elapsed >= REFRESH_SECONDS:
		_refresh()


func _resolve_player() -> void:
	if is_instance_valid(_player):
		return
	var scene := get_tree().current_scene
	if scene == null:
		return
	var candidate := scene.find_child("Player", true, false)
	if candidate != null and candidate.has_method("apply_inventory_state"):
		_player = candidate
		_refresh_elapsed = REFRESH_SECONDS


func _sync_player_from_inventory() -> void:
	if not is_instance_valid(_player):
		return
	var state := GameData.save_state_snapshot()
	var character: Dictionary = state.get("character", {}) as Dictionary
	var inventory: Dictionary = character.get("inventory", {}) as Dictionary
	_player.call("apply_inventory_state", inventory.get("equipment", {}) as Dictionary,
		_inventory.call("load_profile", state) as Dictionary)


func _refresh() -> void:
	_refresh_elapsed = 0.0
	if not is_instance_valid(_surface) or not is_instance_valid(_player):
		return
	_surface.slots = _inventory.call(
		"quick_slot_snapshot", {}, _player) as Array[Dictionary]
	_surface.queue_redraw()


func _on_inventory_changed() -> void:
	_refresh_elapsed = REFRESH_SECONDS
