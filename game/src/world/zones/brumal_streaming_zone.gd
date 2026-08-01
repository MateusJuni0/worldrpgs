extends Node3D
## Adaptador mensurável da única zona construída. A geometria continua a vir do
## Greybox e os modelos dos packs CC0 que ele já selecciona.

const GreyboxScript = preload("res://src/world/greybox.gd")

var build_time_ms := 0.0


func _ready() -> void:
	var started_usec := Time.get_ticks_usec()
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(
			"res://data/graphics.json"))
	if not parsed is Dictionary:
		push_error("Brumal de streaming sem graphics.json válido")
		return
	var graphics := parsed as Dictionary
	var preset_name := SettingsSystem.graphics_preset_name()
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--quality="):
			preset_name = argument.get_slice("=", 1)
	var presets: Dictionary = graphics.get("presets", {}) as Dictionary
	var preset: Dictionary = (presets.get(preset_name, {}) as Dictionary).duplicate(true)
	if preset.is_empty():
		push_error("Brumal de streaming sem preset '%s'" % preset_name)
		return
	preset["_name"] = preset_name
	var greybox := GreyboxScript.new()
	greybox.name = "Brumal"
	add_child(greybox)
	greybox.build(preset, graphics.get("palette", {}) as Dictionary, "brumal", "brumal")
	build_time_ms = float(Time.get_ticks_usec() - started_usec) / 1000.0
	set_meta("build_time_ms", build_time_ms)
