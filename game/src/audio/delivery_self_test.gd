extends SceneTree
## Prova focal do pacote de som e icones.
## Correr com: godot --headless --audio-driver Dummy --path game \
##   --script res://src/audio/delivery_self_test.gd

const AudioFactory = preload("res://src/audio/procedural_audio.gd")
const FamilyIcons = preload("res://assets/ui/weapon_family_icons.gd")

var _passed := 0
var _failed := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_audio()
	_test_runtime_contract()
	_test_icons()
	print("[audio+icones] %d passaram, %d falharam" % [_passed, _failed])
	quit(0 if _failed == 0 else 1)


func _test_audio() -> void:
	var streams := {
		"vento": AudioFactory.make_wind(),
		"folhas": AudioFactory.make_leaves(),
		"agua": AudioFactory.make_water(),
		"corvos": AudioFactory.make_crows(),
		"fogueira": AudioFactory.make_campfire(),
	}
	for sound_name: String in streams:
		var stream := streams[sound_name] as AudioStreamWAV
		_check(stream != null and stream.mix_rate == AudioFactory.RATE,
			"%s existe a 22050 Hz" % sound_name)
		_check(stream.format == AudioStreamWAV.FORMAT_16_BITS and not stream.stereo,
			"%s e mono 16-bit" % sound_name)
		var peak := _peak(stream.data)
		_check(peak > 0.02 and peak < 0.98,
			"%s tem sinal sem clipping (pico %.3f)" % [sound_name, peak])
		if sound_name != "corvos":
			_check(stream.loop_mode == AudioStreamWAV.LOOP_FORWARD
				and stream.loop_end == stream.data.size() / 2,
				"%s declara loop completo" % sound_name)
			_check(_seam_delta(stream.data) < 0.12,
				"%s tem costura curta (delta %.3f)" % [sound_name,
					_seam_delta(stream.data)])
	_check((streams["corvos"] as AudioStreamWAV).loop_mode == AudioStreamWAV.LOOP_DISABLED,
		"corvos sao evento raro, nao relogio em loop")


func _test_runtime_contract() -> void:
	var sfx := root.get_node_or_null("Sfx")
	_check(sfx != null, "autoload Sfx existe")
	if sfx == null:
		return
	for sound_id: String in ["amb_wind", "amb_leaves", "amb_water", "amb_crows", "campfire"]:
		_check(bool(sfx.call("has_sound", sound_id)), "Sfx expoe %s" % sound_id)
	var buses := sfx.call("volume_bus_contract") as Dictionary
	for internal_name: String in buses:
		var index := AudioServer.get_bus_index(internal_name)
		_check(index >= 0 and AudioServer.get_bus_send(index) == String(buses[internal_name]),
			"%s envia para o slider %s" % [internal_name, buses[internal_name]])
	print("[audio+icones] sintese do autoload: %.1f ms" %
		float(sfx.get("synthesis_milliseconds")))


func _test_icons() -> void:
	_check(FamilyIcons.PATHS.size() == 8, "existem exactamente oito familias")
	var game_data := root.get_node_or_null("GameData")
	_check(game_data != null, "autoload GameData existe")
	var weapons := game_data.get("weapons") as Dictionary if game_data != null else {}
	var catalogue_ids: Array = []
	for family_value: Variant in (weapons.get("familias", {}) as Dictionary).keys():
		var family_id := String(family_value)
		if not family_id.begins_with("_"):
			catalogue_ids.append(family_id)
	var icon_ids: Array = FamilyIcons.PATHS.keys()
	catalogue_ids.sort()
	icon_ids.sort()
	_check(catalogue_ids == icon_ids, "os icones cobrem os oito ids do catalogo")
	var sheet := Image.create(512, 64, false, Image.FORMAT_RGBA8)
	sheet.fill(Color("182126"))
	var family_ids: Array = FamilyIcons.PATHS.keys()
	family_ids.sort()
	for index in family_ids.size():
		var family_id := String(family_ids[index])
		var path := FamilyIcons.path_for(family_id)
		var texture := load(path) as Texture2D
		_check(texture != null, "%s resolve uma textura" % family_id)
		if texture == null:
			continue
		_check(texture.get_size() == Vector2(32, 32),
			"%s importa a 32x32" % family_id)
		var icon := texture.get_image()
		_check(icon.get_pixel(0, 0).a == 0.0 and icon.get_pixel(31, 31).a == 0.0,
			"%s conserva fundo transparente" % family_id)
		sheet.blit_rect(icon, Rect2i(0, 0, 32, 32), Vector2i(index * 64 + 16, 16))
	var capture_path := "user://weapon-family-icons-32.png"
	_check(sheet.save_png(capture_path) == OK, "captura dos icones foi escrita")
	print("[audio+icones] captura: %s" % ProjectSettings.globalize_path(capture_path))


func _peak(data: PackedByteArray) -> float:
	var peak := 0
	for index in range(0, data.size(), 2):
		peak = maxi(peak, absi(data.decode_s16(index)))
	return float(peak) / 32767.0


func _seam_delta(data: PackedByteArray) -> float:
	return absf(float(data.decode_s16(0) - data.decode_s16(data.size() - 2))) / 32767.0


func _check(condition: bool, message: String) -> void:
	if condition:
		_passed += 1
	else:
		_failed += 1
		push_error("[audio+icones] FALHOU: %s" % message)
