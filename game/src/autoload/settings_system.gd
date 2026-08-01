extends Node
## Preferencias locais, separadas do personagem e do mundo.
## Fontes: spec/20-interface.md e spec/45-controlos-configuraveis.md.

const SETTINGS_PATH := "user://settings.json"
const AUDIO_BUSES := ["Master", "Musica", "Efeitos", "Ambiente", "Vozes"]

signal graphics_changed(preset_name: String)
signal controls_changed
signal audio_changed(bus_name: String, linear_value: float)

var data: Dictionary = {}
var last_error := ""


func _ready() -> void:
	_ensure_audio_buses()
	data = _defaults()
	_load()
	_apply_controls()
	apply_graphics()
	apply_audio()


func _defaults() -> Dictionary:
	return {
		"version": 1,
		"graphics": {
			"preset": String(_graphics_catalogue().get("default", "medio")),
			"fullscreen": true,
			"fps_limit": 60,
			"show_fps": true,
		},
		"controls": {
			"bindings": {},
			"mouse_sensitivity": 1.0,
			"invert_y": false,
			"fov": 55.0,
		},
		"audio": {
			"Master": 1.0,
			"Musica": 0.8,
			"Efeitos": 1.0,
			"Ambiente": 0.8,
			"Vozes": 1.0,
		},
	}


func _graphics_catalogue() -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(
		"res://data/graphics.json"))
	return parsed as Dictionary if typeof(parsed) == TYPE_DICTIONARY else {}


func _load() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(SETTINGS_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		last_error = "O ficheiro de configurações não é JSON válido."
		return
	data = _merge_defaults(data, parsed as Dictionary)


func save() -> bool:
	last_error = ""
	var temporary := SETTINGS_PATH + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		last_error = "Não foi possível escrever as configurações."
		return false
	file.store_string(JSON.stringify(data, "\t", true))
	file.flush()
	var write_error := file.get_error()
	file.close()
	if write_error != OK:
		last_error = error_string(write_error)
		return false
	var absolute := ProjectSettings.globalize_path(SETTINGS_PATH)
	if FileAccess.file_exists(SETTINGS_PATH):
		var remove_error := DirAccess.remove_absolute(absolute)
		if remove_error != OK:
			last_error = error_string(remove_error)
			return false
	var rename_error := DirAccess.rename_absolute(
		ProjectSettings.globalize_path(temporary), absolute)
	if rename_error != OK:
		last_error = error_string(rename_error)
		return false
	return true


func graphics_preset_name() -> String:
	return String((data.get("graphics", {}) as Dictionary).get("preset", "medio"))


func set_graphics_preset(preset_name: String) -> bool:
	var presets: Dictionary = _graphics_catalogue().get("presets", {}) as Dictionary
	if not presets.has(preset_name):
		last_error = "Preset desconhecido: %s" % preset_name
		return false
	(data.get("graphics", {}) as Dictionary)["preset"] = preset_name
	apply_graphics()
	save()
	graphics_changed.emit(preset_name)
	return true


func set_fullscreen(enabled: bool) -> void:
	(data.get("graphics", {}) as Dictionary)["fullscreen"] = enabled
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if enabled
		else DisplayServer.WINDOW_MODE_WINDOWED)
	save()


func set_fps_limit(limit: int) -> void:
	(data.get("graphics", {}) as Dictionary)["fps_limit"] = limit
	Engine.max_fps = maxi(0, limit)
	save()


func set_show_fps(enabled: bool) -> void:
	(data.get("graphics", {}) as Dictionary)["show_fps"] = enabled
	Bench.set_overlay_visible(enabled)
	save()


func apply_graphics() -> void:
	var graphics: Dictionary = data.get("graphics", {}) as Dictionary
	if not Bench.is_benchmarking():
		Engine.max_fps = maxi(0, int(graphics.get("fps_limit", 60)))
	var presets: Dictionary = _graphics_catalogue().get("presets", {}) as Dictionary
	var preset: Dictionary = presets.get(graphics_preset_name(), {}) as Dictionary
	if not preset.is_empty() and get_viewport() != null:
		get_viewport().scaling_3d_scale = float(preset.get("render_scale", 1.0))
	if not Bench.is_benchmarking():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if bool(
			graphics.get("fullscreen", true)) else DisplayServer.WINDOW_MODE_WINDOWED)
		Bench.set_overlay_visible(bool(graphics.get("show_fps", true)))


func set_audio(bus_name: String, linear_value: float) -> void:
	if bus_name not in AUDIO_BUSES:
		return
	var value := clampf(linear_value, 0.0, 1.0)
	(data.get("audio", {}) as Dictionary)[bus_name] = value
	_apply_audio_bus(bus_name, value)
	save()
	audio_changed.emit(bus_name, value)


func apply_audio() -> void:
	var audio: Dictionary = data.get("audio", {}) as Dictionary
	for bus_name: String in AUDIO_BUSES:
		_apply_audio_bus(bus_name, float(audio.get(bus_name, 1.0)))


func _apply_audio_bus(bus_name: String, value: float) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index < 0:
		return
	AudioServer.set_bus_mute(index, value <= 0.0001)
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(value, 0.0001)))


func _ensure_audio_buses() -> void:
	for bus_name: String in AUDIO_BUSES:
		if AudioServer.get_bus_index(bus_name) >= 0:
			continue
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)


func binding_label(action_name: String, include_all := false) -> String:
	var labels: Array[String] = []
	for event: InputEvent in InputMap.action_get_events(action_name):
		var label := event.as_text().replace(" (Physical)", "")
		if event is InputEventJoypadMotion or event is InputEventJoypadButton:
			label = label.replace("Joypad", "Comando")
		labels.append(label)
		if not include_all:
			break
	return " / ".join(labels) if not labels.is_empty() else "Sem ligação"


func find_conflict(event: InputEvent, except_action := "") -> String:
	for action: StringName in InputMap.get_actions():
		var action_name := String(action)
		if action_name == except_action or action_name.begins_with("ui_"):
			continue
		for existing: InputEvent in InputMap.action_get_events(action):
			if events_match(existing, event):
				return action_name
	return ""


func remap_action(action_name: String, event: InputEvent, add_secondary := false,
		remove_conflict := true) -> void:
	var conflict := find_conflict(event, action_name)
	if remove_conflict and conflict != "":
		_remove_matching_event(conflict, event)
	var existing := InputMap.action_get_events(action_name)
	if not add_secondary:
		var removed := false
		for old_event: InputEvent in existing:
			if _same_device_family(old_event, event):
				InputMap.action_erase_event(action_name, old_event)
				removed = true
				break
		if not removed and not existing.is_empty():
			InputMap.action_erase_event(action_name, existing[0] as InputEvent)
	if not _action_has_event(action_name, event):
		InputMap.action_add_event(action_name, event)
	_store_current_bindings()
	save()
	controls_changed.emit()


func reset_controls() -> void:
	GameData.reset_input_map_to_defaults()
	(data.get("controls", {}) as Dictionary)["bindings"] = {}
	save()
	controls_changed.emit()


func set_mouse_sensitivity(value: float) -> void:
	(data.get("controls", {}) as Dictionary)["mouse_sensitivity"] = clampf(value, 0.25, 2.0)
	save()
	controls_changed.emit()


func set_invert_y(enabled: bool) -> void:
	(data.get("controls", {}) as Dictionary)["invert_y"] = enabled
	save()
	controls_changed.emit()


func set_fov(value: float) -> void:
	(data.get("controls", {}) as Dictionary)["fov"] = clampf(value, 45.0, 75.0)
	save()
	controls_changed.emit()


func control_value(key: String, fallback: Variant) -> Variant:
	return (data.get("controls", {}) as Dictionary).get(key, fallback)


func _apply_controls() -> void:
	var bindings: Dictionary = ((data.get("controls", {}) as Dictionary).get(
		"bindings", {}) as Dictionary)
	for action_name: String in bindings:
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
		InputMap.action_erase_events(action_name)
		for encoded: Variant in bindings[action_name]:
			var event := decode_event(encoded as Dictionary)
			if event != null:
				InputMap.action_add_event(action_name, event)


func _store_current_bindings() -> void:
	var bindings := {}
	for action_name: String in (GameData.controls.get("actions", {}) as Dictionary).keys():
		var encoded_events: Array[Dictionary] = []
		for event: InputEvent in InputMap.action_get_events(action_name):
			var encoded := encode_event(event)
			if not encoded.is_empty():
				encoded_events.append(encoded)
		bindings[action_name] = encoded_events
	(data.get("controls", {}) as Dictionary)["bindings"] = bindings


func _remove_matching_event(action_name: String, target: InputEvent) -> void:
	for event: InputEvent in InputMap.action_get_events(action_name):
		if events_match(event, target):
			InputMap.action_erase_event(action_name, event)


func _action_has_event(action_name: String, target: InputEvent) -> bool:
	for event: InputEvent in InputMap.action_get_events(action_name):
		if events_match(event, target):
			return true
	return false


func _same_device_family(a: InputEvent, b: InputEvent) -> bool:
	var a_gamepad := a is InputEventJoypadButton or a is InputEventJoypadMotion
	var b_gamepad := b is InputEventJoypadButton or b is InputEventJoypadMotion
	return a_gamepad == b_gamepad


static func events_match(a: InputEvent, b: InputEvent) -> bool:
	return encode_event(a) == encode_event(b)


static func encode_event(event: InputEvent) -> Dictionary:
	if event is InputEventKey:
		var key := event as InputEventKey
		return {"type": "key", "physical_keycode": int(key.physical_keycode),
			"shift": key.shift_pressed, "ctrl": key.ctrl_pressed, "alt": key.alt_pressed}
	if event is InputEventMouseButton:
		return {"type": "mouse", "button": int((event as InputEventMouseButton).button_index)}
	if event is InputEventJoypadButton:
		return {"type": "joypad_button", "button": int((event as InputEventJoypadButton).button_index)}
	if event is InputEventJoypadMotion:
		var motion := event as InputEventJoypadMotion
		return {"type": "joypad_motion", "axis": int(motion.axis), "value": motion.axis_value}
	return {}


static func decode_event(encoded: Dictionary) -> InputEvent:
	match String(encoded.get("type", "")):
		"key":
			var key := InputEventKey.new()
			key.physical_keycode = int(encoded.get("physical_keycode", 0)) as Key
			key.shift_pressed = bool(encoded.get("shift", false))
			key.ctrl_pressed = bool(encoded.get("ctrl", false))
			key.alt_pressed = bool(encoded.get("alt", false))
			return key
		"mouse":
			var mouse := InputEventMouseButton.new()
			mouse.button_index = int(encoded.get("button", 1)) as MouseButton
			return mouse
		"joypad_button":
			var button := InputEventJoypadButton.new()
			button.button_index = int(encoded.get("button", 0)) as JoyButton
			return button
		"joypad_motion":
			var motion := InputEventJoypadMotion.new()
			motion.axis = int(encoded.get("axis", 0)) as JoyAxis
			motion.axis_value = float(encoded.get("value", 1.0))
			return motion
	return null


func _merge_defaults(defaults: Dictionary, loaded: Dictionary) -> Dictionary:
	var merged := defaults.duplicate(true)
	for key: Variant in loaded:
		if typeof(loaded[key]) == TYPE_DICTIONARY and typeof(merged.get(key)) == TYPE_DICTIONARY:
			merged[key] = _merge_defaults(merged[key] as Dictionary, loaded[key] as Dictionary)
		else:
			merged[key] = loaded[key]
	return merged
