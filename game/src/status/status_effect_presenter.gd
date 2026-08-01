class_name StatusEffectPresenter
extends Control
## Barra visível e som sintetizado para cada evento do StatusEffectManager.
## Não usa assets externos: cor, geometria e áudio vêm do catálogo JSON.

var visual_announcement_count := 0
var sound_announcement_count := 0

var _config: Dictionary = {}
var _container: VBoxContainer
var _audio_player: AudioStreamPlayer
var _rows: Dictionary = {}
var _bars: Dictionary = {}
var _sound_cache: Dictionary = {}
var _last_sound: AudioStreamWAV


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_nodes()


func _exit_tree() -> void:
	if _audio_player != null:
		_audio_player.stop()
		_audio_player.stream = null
	_sound_cache.clear()
	_last_sound = null


func configure(config: Dictionary) -> void:
	_config = config.duplicate(true)
	_build_nodes()
	_container.add_theme_constant_override("separation", int(_config.get("panel_gap_px", 0)))


func bind(manager: Node) -> void:
	if not manager.feedback_requested.is_connected(_on_feedback_requested):
		manager.feedback_requested.connect(_on_feedback_requested)


func visible_status_ids() -> Array[String]:
	var ids: Array[String] = []
	for status_value: Variant in _rows.keys():
		var status_id := String(status_value)
		if (_rows[status_id] as Control).visible:
			ids.append(status_id)
	ids.sort()
	return ids


func last_sound_stream() -> AudioStreamWAV:
	return _last_sound


func _on_feedback_requested(event: Dictionary) -> void:
	var status_id := String(event.get("status_id", ""))
	var visual := event.get("visual", {}) as Dictionary
	var sound := event.get("sound", {}) as Dictionary
	if status_id != "" and not visual.is_empty():
		_present_visual(status_id, event, visual)
	if not sound.is_empty():
		_present_sound(sound)


func _present_visual(status_id: String, event: Dictionary, visual: Dictionary) -> void:
	_ensure_row(status_id)
	var row := _rows[status_id] as Control
	var bar := _bars[status_id] as ProgressBar
	bar.max_value = maxf(float(event.get("maximum", 0.0)), 0.0)
	bar.value = clampf(float(event.get("meter", 0.0)), 0.0, bar.max_value)
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(String(visual.get("color", "#ffffff")))
	fill.corner_radius_top_left = int(_config.get("background_corner_radius_px", 0))
	fill.corner_radius_top_right = fill.corner_radius_top_left
	fill.corner_radius_bottom_left = fill.corner_radius_top_left
	fill.corner_radius_bottom_right = fill.corner_radius_top_left
	bar.add_theme_stylebox_override("fill", fill)
	var phase := String(event.get("phase", ""))
	row.visible = phase not in ["cured", "expired"] and (bar.value > 0.0 or phase in ["trigger", "tick"])
	visual_announcement_count += 1


func _present_sound(sound: Dictionary) -> void:
	var profile := String(sound.get("profile", ""))
	if profile != "" and _sound_cache.has(profile):
		_last_sound = _sound_cache[profile] as AudioStreamWAV
	else:
		_last_sound = _synthesise(sound)
		if profile != "" and _last_sound != null:
			_sound_cache[profile] = _last_sound
	if _last_sound == null:
		return
	if bool(_config.get("playback_enabled", true)):
		_audio_player.stream = _last_sound
		_audio_player.play()
	sound_announcement_count += 1


func _ensure_row(status_id: String) -> void:
	if _rows.has(status_id):
		return
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", int(_config.get("row_gap_px", 0)))
	var label := Label.new()
	label.text = status_id.capitalize()
	label.custom_minimum_size.x = float(_config.get("label_width_px", 0.0))
	row.add_child(label)
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.custom_minimum_size = Vector2(
		float(_config.get("minimum_bar_width_px", 0.0)),
		float(_config.get("bar_height_px", 0.0))
	)
	var background := StyleBoxFlat.new()
	background.bg_color = Color(String(_config.get("background_color", "#000000")))
	bar.add_theme_stylebox_override("background", background)
	row.add_child(bar)
	_container.add_child(row)
	_rows[status_id] = row
	_bars[status_id] = bar


func _build_nodes() -> void:
	if _container == null:
		_container = VBoxContainer.new()
		add_child(_container)
	if _audio_player == null:
		_audio_player = AudioStreamPlayer.new()
		add_child(_audio_player)


func _synthesise(sound: Dictionary) -> AudioStreamWAV:
	var fallback := _config.get("fallback_sound", {}) as Dictionary
	var mix_rate := int(_config.get("audio_mix_rate_hz", 0))
	var duration := float(sound.get("duration_s", fallback.get("duration_s", 0.0)))
	var frequency := float(sound.get("frequency_hz", fallback.get("frequency_hz", 0.0)))
	if mix_rate <= 0 or duration <= 0.0 or frequency <= 0.0:
		return null
	var sample_count := maxi(int(round(duration * float(mix_rate))), 1)
	var pcm := PackedByteArray()
	pcm.resize(sample_count * 2)
	var amplitude := db_to_linear(float(sound.get("volume_db", fallback.get("volume_db", 0.0))))
	var wave := String(sound.get("wave", fallback.get("wave", "sine")))
	var noise := RandomNumberGenerator.new()
	noise.seed = String(sound.get("profile", "status")).hash()
	for sample_index: int in sample_count:
		var time_s := float(sample_index) / float(mix_rate)
		var phase := TAU * frequency * time_s
		var sample := sin(phase)
		if wave == "triangle":
			sample = asin(sin(phase)) * 2.0 / PI
		elif wave == "noise":
			sample = noise.randf_range(-1.0, 1.0)
		var envelope := sin(PI * float(sample_index) / float(maxi(sample_count - 1, 1)))
		var encoded := int(round(clampf(sample * amplitude * envelope, -1.0, 1.0) * 32767.0))
		pcm.encode_s16(sample_index * 2, encoded)
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = mix_rate
	stream.stereo = false
	stream.data = pcm
	return stream
