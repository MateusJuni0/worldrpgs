extends Node3D
## Assinatura 3D sintetizada por ataque. Família = timbre reconhecível à
## distância; ID do golpe = pequena diferença estável de altura/cadência.
## Assim primeira pessoa recebe direcção e identidade sem ficheiros de áudio.

static var _stream_cache: Dictionary = {}

var _enemy_id := ""
var _race_id := ""
var _profile: Dictionary = {}
var _sample_rate := 0
var _player: AudioStreamPlayer3D


func setup(enemy_id: String, race_id: String, presentation: Dictionary) -> void:
	_enemy_id = enemy_id
	_race_id = race_id
	_sample_rate = int(presentation.get("audio_sample_rate_hz", 0))
	var profiles: Dictionary = presentation.get("audio_profiles", {}) as Dictionary
	_profile = profiles.get(race_id, {}) as Dictionary
	_player = AudioStreamPlayer3D.new()
	_player.name = "AttackTell3D"
	_player.bus = "Efeitos"
	_player.unit_size = float(_profile.get("unit_size_m", 1.0))
	add_child(_player)
	if _sample_rate <= 0 or _profile.is_empty():
		push_error("[enemy-audio] perfil em falta para %s/%s" % [enemy_id, race_id])


func announce(attack: Dictionary) -> void:
	if _player == null or _sample_rate <= 0 or _profile.is_empty():
		return
	var sound: Dictionary = attack.get("som_anuncio", {}) as Dictionary
	_player.max_distance = float(sound.get("alcance_informativo_m", 0.0))
	var attack_id := String(attack.get("id", ""))
	var cache_key := "%s:%s" % [_enemy_id, attack_id]
	var stream := _stream_cache.get(cache_key) as AudioStreamWAV
	if stream == null:
		stream = _synthesise(attack_id, attack)
		_stream_cache[cache_key] = stream
	_player.stream = stream
	_player.volume_db = float(_profile.get("gain_db", 0.0))
	_player.pitch_scale = 1.0
	_player.play()


func cancel() -> void:
	if _player != null:
		_player.stop()


static func cached_signature_count() -> int:
	return _stream_cache.size()


func _synthesise(attack_id: String, attack: Dictionary) -> AudioStreamWAV:
	var duration := float(_profile.get("duration_s", 0.0))
	var sample_count := maxi(int(duration * float(_sample_rate)), 1)
	var samples := PackedFloat32Array()
	samples.resize(sample_count)
	var signature_steps := maxi(int(_profile.get("signature_steps", 1)), 1)
	var signature := absi(hash(attack_id)) % signature_steps
	var signature_offset := float(signature) * float(_profile.get("signature_step_hz", 0.0))
	var start_hz := float(_profile.get("base_hz", 0.0)) + signature_offset
	var end_hz := float(_profile.get("end_hz", 0.0)) + signature_offset
	var noise_mix := clampf(float(_profile.get("noise_mix", 0.0)), 0.0, 1.0)
	var harmonic_mix := clampf(float(_profile.get("harmonic_mix", 0.0)), 0.0, 1.0)
	var roughness_hz := float(_profile.get("roughness_hz", 0.0))
	var pulse_hz := float(_profile.get("pulse_hz", 0.0))
	var pulse_count := maxi((attack.get("commitment_offsets", []) as Array).size(), 1)
	var contact := String(attack.get("tipo_contacto", ""))
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(cache_identity(attack_id))
	var phase := 0.0
	for index: int in sample_count:
		var time := float(index) / float(_sample_rate)
		var progress := time / duration
		var curve := progress * progress if contact == "volume_movel" else progress
		var frequency := lerpf(start_hz, end_hz, curve)
		phase += TAU * frequency / float(_sample_rate)
		var tonal := sin(phase)
		tonal += sin(phase * 2.0 + sin(TAU * roughness_hz * time)) * harmonic_mix
		var texture := rng.randf_range(-1.0, 1.0)
		var envelope := sin(PI * progress)
		if contact == "volume_persistente":
			envelope *= absf(sin(TAU * pulse_hz * time))
		elif pulse_count > 1:
			envelope *= absf(sin(PI * float(pulse_count) * progress))
		samples[index] = (tonal * (1.0 - noise_mix) + texture * noise_mix) * envelope
	return _to_stream(samples)


func cache_identity(attack_id: String) -> String:
	return "%s:%s:%s" % [_race_id, _enemy_id, attack_id]


func _to_stream(samples: PackedFloat32Array) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	bytes.resize(samples.size() * 2)
	for index: int in samples.size():
		bytes.encode_s16(index * 2, int(clampf(samples[index], -1.0, 1.0) * 32767.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = _sample_rate
	stream.data = bytes
	return stream
