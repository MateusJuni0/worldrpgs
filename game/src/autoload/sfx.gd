extends Node
## Efeitos sonoros SINTETIZADOS no arranque — zero ficheiros, zero downloads.
##
## O som e parte da Lei 1 (spec/21, WP12): um ataque que se OUVE a chegar e mais
## uma pista justa; o parry que acerta merece o melhor som do jogo. Cada som e
## gerado por DSP simples (senos, serra, ruido, envelopes) a 22050 Hz mono.
## Brumal acrescenta vento, folhas, agua, corvos e fogueiras, tambem sinteticos.
## Afinacao: mexer nos numeros dos _make_* e voltar a correr.

const ProceduralAudio = preload("res://src/audio/procedural_audio.gd")
const RATE := 22050
const USER_BUSES := ["Musica", "Efeitos", "Ambiente", "Vozes"]
const INTERNAL_BUSES := {
	"GameplayInfo": "Efeitos",
	"Impact": "Efeitos",
	"UI": "Efeitos",
	"Music": "Musica",
	"Ambience": "Ambiente",
	"Voice": "Vozes",
}
const INFORMATION_SOUNDS := {
	"telegraph": true,
	"attack_parry": true,
	"attack_dodge": true,
	"attack_moving": true,
	"attack_area": true,
	"attack_hunter": true,
}
const AMBIENCE_SCAN_SECONDS := 0.5
const CROW_INTERVAL_MIN_SECONDS := 20.0
const CROW_INTERVAL_MAX_SECONDS := 60.0
const INFO_CLEARANCE_SECONDS := 1.5

var _bank: Dictionary = {}
var _pool: Array[AudioStreamPlayer3D] = []
var _flat_pool: Array[AudioStreamPlayer] = []
var _rng := RandomNumberGenerator.new()
var _ambience_players: Dictionary = {}
var _bonfire_players: Dictionary = {}
var _crow_player: AudioStreamPlayer3D
var _active_gameplay: Node3D
var _scan_elapsed := 0.0
var _crow_elapsed := 0.0
var _next_crow_seconds := 30.0
var _info_clear_at_ms := 0
var _duck_ambience_db := 0.0
var _duck_music_db := 0.0
var synthesis_milliseconds := 0.0


func _ready() -> void:
	_rng.randomize()
	_ensure_audio_buses()
	for i in 4:
		var f := AudioStreamPlayer.new()
		f.bus = "Impact"
		add_child(f)
		_flat_pool.append(f)
	for i in 12:
		var p := AudioStreamPlayer3D.new()
		p.bus = "Impact"
		p.max_distance = 42.0
		p.unit_size = 6.0
		add_child(p)
		_pool.append(p)
	var synthesis_started := Time.get_ticks_usec()
	_generate_bank()
	synthesis_milliseconds = float(Time.get_ticks_usec() - synthesis_started) / 1000.0
	print("[sfx] 17 efeitos + 5 sons de ambiente sintetizados em %.1f ms" %
		synthesis_milliseconds)
	_next_crow_seconds = _rng.randf_range(CROW_INTERVAL_MIN_SECONDS,
		CROW_INTERVAL_MAX_SECONDS)


func _process(delta: float) -> void:
	_update_ducking(delta)
	_scan_elapsed += delta
	if _scan_elapsed >= AMBIENCE_SCAN_SECONDS:
		_scan_elapsed = 0.0
		_sync_world_audio()
	if is_instance_valid(_active_gameplay):
		_crow_elapsed += delta
		if _crow_elapsed >= _next_crow_seconds:
			_try_play_crows()


## at == null -> som "do jogador" (sem posicao). Com posicao -> 3D.
func play(sound: String, at: Variant = null, volume_db := 0.0, pitch_jitter := 0.06) -> void:
	var stream: AudioStreamWAV = _bank.get(sound)
	if stream == null:
		return
	var informative := INFORMATION_SOUNDS.has(sound)
	var pitch := 1.0 if informative else 1.0 + _rng.randf_range(-pitch_jitter, pitch_jitter)
	var bus_name := "GameplayInfo" if informative else "Impact"
	if at == null:
		for f in _flat_pool:
			if not f.playing:
				if informative:
					_protect_information(stream.get_length())
				f.stream = stream
				f.bus = bus_name
				f.volume_db = volume_db
				f.pitch_scale = pitch
				f.play()
				return
		return
	for p in _pool:
		if not p.playing:
			if informative:
				_protect_information(stream.get_length())
			p.global_position = at as Vector3
			p.stream = stream
			p.bus = bus_name
			p.volume_db = volume_db
			p.pitch_scale = pitch
			p.play()
			return


## API pequena para UI/testes: os sliders publicos controlam os pais destes
## buses, sem o menu ter de conhecer a arquitectura interna da mistura.
func volume_bus_contract() -> Dictionary:
	return INTERNAL_BUSES.duplicate()


func has_sound(sound: String) -> bool:
	return _bank.has(sound)


func active_ambience_layer_count() -> int:
	return _ambience_players.size()


func active_bonfire_source_count() -> int:
	return _bonfire_players.size()


# --- Mistura e ciclo do mundo -------------------------------------------------

func _ensure_audio_buses() -> void:
	for bus_name: String in USER_BUSES:
		_ensure_bus(bus_name, "Master")
	for bus_name: String in INTERNAL_BUSES:
		_ensure_bus(bus_name, String(INTERNAL_BUSES[bus_name]))


func _ensure_bus(bus_name: String, send_name: String) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index < 0:
		AudioServer.add_bus()
		index = AudioServer.bus_count - 1
		AudioServer.set_bus_name(index, bus_name)
	AudioServer.set_bus_send(index, send_name)


func _sync_world_audio() -> void:
	var gameplay := get_tree().root.find_child("Gameplay", true, false) as Node3D
	if gameplay != _active_gameplay:
		_stop_brumal()
		if is_instance_valid(gameplay):
			_start_brumal(gameplay)
	if is_instance_valid(_active_gameplay):
		_sync_bonfires()


func _start_brumal(gameplay: Node3D) -> void:
	_active_gameplay = gameplay
	# [CODEX] Tres vozes permanentes deixam cada material afinavel sem criar uma
	# faixa musical falsa. Alternativa descartada: achatar tudo num unico drone.
	var layers := {
		"amb_wind": -17.0,
		"amb_leaves": -21.0,
		"amb_water": -24.0,
	}
	for sound_id: String in layers:
		var player := AudioStreamPlayer.new()
		player.name = sound_id
		player.bus = "Ambience"
		player.stream = _bank[sound_id] as AudioStream
		player.volume_db = float(layers[sound_id])
		add_child(player)
		player.play()
		_ambience_players[sound_id] = player
	print("[sfx] Brumal activo: vento + folhas + agua; corvos em eventos raros")
	_crow_player = AudioStreamPlayer3D.new()
	_crow_player.name = "DistantCrows"
	_crow_player.bus = "Ambience"
	_crow_player.stream = _bank["amb_crows"] as AudioStream
	_crow_player.volume_db = -17.0
	_crow_player.unit_size = 22.0
	_crow_player.max_distance = 105.0
	add_child(_crow_player)
	_crow_elapsed = 0.0


func _stop_brumal() -> void:
	for player_value: Variant in _ambience_players.values():
		var player := player_value as AudioStreamPlayer
		if is_instance_valid(player):
			player.queue_free()
	_ambience_players.clear()
	if is_instance_valid(_crow_player):
		_crow_player.queue_free()
	_crow_player = null
	_bonfire_players.clear()
	_active_gameplay = null
	_crow_elapsed = 0.0


func _sync_bonfires() -> void:
	var live_ids: Dictionary = {}
	for child in _active_gameplay.get_children():
		var rest_point := child as Node3D
		if rest_point == null or not rest_point.name.begins_with("Rest_"):
			continue
		var instance_id := rest_point.get_instance_id()
		live_ids[instance_id] = true
		if not _bonfire_players.has(instance_id):
			_register_bonfire(rest_point)
	for instance_id: Variant in _bonfire_players.keys():
		var player := _bonfire_players[instance_id] as AudioStreamPlayer3D
		if not live_ids.has(instance_id) or not is_instance_valid(player):
			_bonfire_players.erase(instance_id)


func _register_bonfire(rest_point: Node3D) -> void:
	var player := AudioStreamPlayer3D.new()
	player.name = "CampfireAudio"
	player.bus = "Ambience"
	player.stream = _bank["campfire"] as AudioStream
	player.position = Vector3(0.0, 0.65, 0.0)
	player.volume_db = -7.0
	# [CODEX] A fogueira chega aos ouvidos antes de a pequena chama vencer a
	# bruma. Alternativa descartada: copiar os 7 m da luz, que soaria tarde.
	player.unit_size = 12.0
	player.max_distance = 46.0
	rest_point.add_child(player)
	player.play()
	_bonfire_players[rest_point.get_instance_id()] = player
	print("[sfx] fogueira 3D ligada: %s" % rest_point.name)


func _try_play_crows() -> void:
	if Time.get_ticks_msec() < _info_clear_at_ms or not is_instance_valid(_crow_player):
		_crow_elapsed = maxf(_crow_elapsed - 1.0, 0.0)
		return
	var listener := get_tree().get_first_node_in_group("player") as Node3D
	if listener == null:
		return
	var angle := _rng.randf_range(0.0, TAU)
	var distance := _rng.randf_range(48.0, 72.0)
	_crow_player.global_position = listener.global_position \
		+ Vector3(cos(angle) * distance, _rng.randf_range(12.0, 22.0),
			sin(angle) * distance)
	_crow_player.pitch_scale = _rng.randf_range(0.94, 1.04)
	_crow_player.play()
	_crow_elapsed = 0.0
	_next_crow_seconds = _rng.randf_range(CROW_INTERVAL_MIN_SECONDS,
		CROW_INTERVAL_MAX_SECONDS)


func _protect_information(duration_seconds: float) -> void:
	if is_instance_valid(_crow_player) and _crow_player.playing:
		_crow_player.stop()
	var clear_at := Time.get_ticks_msec() + roundi(
		(duration_seconds + INFO_CLEARANCE_SECONDS) * 1000.0)
	_info_clear_at_ms = maxi(_info_clear_at_ms, clear_at)


func _update_ducking(delta: float) -> void:
	var protecting := Time.get_ticks_msec() < _info_clear_at_ms
	var target_ambience := -6.0 if protecting else 0.0
	var target_music := -8.0 if protecting else 0.0
	var attack_seconds := 0.02
	var release_seconds := 0.25
	var previous_ambience := _duck_ambience_db
	var previous_music := _duck_music_db
	_duck_ambience_db = move_toward(_duck_ambience_db, target_ambience,
		6.0 * delta / (attack_seconds if protecting else release_seconds))
	_duck_music_db = move_toward(_duck_music_db, target_music,
		8.0 * delta / (attack_seconds if protecting else release_seconds))
	if not is_equal_approx(previous_ambience, _duck_ambience_db):
		_set_bus_db("Ambience", _duck_ambience_db)
	if not is_equal_approx(previous_music, _duck_music_db):
		_set_bus_db("Music", _duck_music_db)


func _set_bus_db(bus_name: String, volume_db: float) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index >= 0:
		AudioServer.set_bus_volume_db(index, volume_db)


# --- Geracao -------------------------------------------------------------------

func _generate_bank() -> void:
	_bank["swing_light"] = _make_swing(0.13, 900.0, 250.0, 0.45)
	_bank["swing_heavy"] = _make_swing(0.22, 520.0, 120.0, 0.62)
	_bank["hit_flesh"] = _make_hit(110.0, 52.0, 0.13, 0.5)
	_bank["hit_block"] = _make_block()
	_bank["parry"] = _make_parry()
	_bank["dodge"] = _make_swing(0.11, 400.0, 180.0, 0.22)
	_bank["step"] = _make_step()
	_bank["flask"] = _make_flask()
	_bank["telegraph"] = _make_telegraph()
	_bank["attack_parry"] = _make_attack_tell(0.25, 520.0, 1040.0, 0.16)
	_bank["attack_dodge"] = _make_attack_tell(0.28, 310.0, 760.0, 0.24)
	_bank["attack_moving"] = _make_attack_tell(0.32, 180.0, 440.0, 0.38)
	_bank["attack_area"] = _make_attack_tell(0.38, 120.0, 260.0, 0.52)
	_bank["attack_hunter"] = _make_attack_tell(0.40, 680.0, 420.0, 0.20)
	_bank["posture_break"] = _make_break()
	_bank["enemy_death"] = _make_death()
	_bank["fury"] = _make_fury()
	_bank["amb_wind"] = ProceduralAudio.make_wind()
	_bank["amb_leaves"] = ProceduralAudio.make_leaves()
	_bank["amb_water"] = ProceduralAudio.make_water()
	_bank["amb_crows"] = ProceduralAudio.make_crows()
	_bank["campfire"] = ProceduralAudio.make_campfire()


func _stream(samples: PackedFloat32Array) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	bytes.resize(samples.size() * 2)
	for i in samples.size():
		bytes.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 32767.0))
	var s := AudioStreamWAV.new()
	s.format = AudioStreamWAV.FORMAT_16_BITS
	s.mix_rate = RATE
	s.data = bytes
	return s


func _buf(seconds: float) -> PackedFloat32Array:
	var b := PackedFloat32Array()
	b.resize(int(seconds * RATE))
	return b


## Whoosh: ruido com corpo em varrimento de frequencia e envelope rapido.
func _make_swing(dur: float, f_hi: float, f_lo: float, amp: float) -> AudioStreamWAV:
	var b := _buf(dur)
	var phase := 0.0
	var lp := 0.0
	for i in b.size():
		var t := float(i) / RATE
		var k := t / dur
		var f := lerpf(f_hi, f_lo, k)
		phase += TAU * f / RATE
		var noise := _rng.randf_range(-1.0, 1.0)
		lp += (noise - lp) * 0.18   # passa-baixo de um polo: tira o silvo
		var env := sin(PI * minf(k * 1.25, 1.0))
		b[i] = (lp * 0.8 + sin(phase) * 0.25) * env * amp
	return _stream(b)


## Impacto em carne: seno grave a cair + estalo de ruido no inicio.
func _make_hit(f_hi: float, f_lo: float, dur: float, amp: float) -> AudioStreamWAV:
	var b := _buf(dur)
	var phase := 0.0
	for i in b.size():
		var t := float(i) / RATE
		var k := t / dur
		phase += TAU * lerpf(f_hi, f_lo, k) / RATE
		var body := sin(phase)
		var click := _rng.randf_range(-1.0, 1.0) * exp(-t * 90.0) * 0.55
		b[i] = (body * exp(-t * 16.0) + click) * amp
	return _stream(b)


## Madeira/escudo: batida media curta, dois parciais.
func _make_block() -> AudioStreamWAV:
	var b := _buf(0.14)
	for i in b.size():
		var t := float(i) / RATE
		var v := sin(TAU * 210.0 * t) * 0.6 + sin(TAU * 335.0 * t) * 0.35
		v += _rng.randf_range(-1.0, 1.0) * exp(-t * 120.0) * 0.4
		b[i] = v * exp(-t * 26.0) * 0.55
	return _stream(b)


## O momento-assinatura: sino metalico brilhante, tres parciais desafinados.
func _make_parry() -> AudioStreamWAV:
	var b := _buf(0.38)
	for i in b.size():
		var t := float(i) / RATE
		var v := sin(TAU * 2350.0 * t) * 0.45
		v += sin(TAU * 3580.0 * t) * 0.30
		v += sin(TAU * 5170.0 * t) * 0.18
		v += _rng.randf_range(-1.0, 1.0) * exp(-t * 160.0) * 0.5   # transiente
		b[i] = v * exp(-t * 10.0) * 0.62
	return _stream(b)


## Passo: toque de ruido surdo, curtissimo.
func _make_step() -> AudioStreamWAV:
	var b := _buf(0.055)
	var lp := 0.0
	for i in b.size():
		var t := float(i) / RATE
		lp += (_rng.randf_range(-1.0, 1.0) - lp) * 0.30
		b[i] = lp * exp(-t * 70.0) * 0.34
	return _stream(b)


## Gole: dois blips graves a descer.
func _make_flask() -> AudioStreamWAV:
	var b := _buf(0.30)
	for i in b.size():
		var t := float(i) / RATE
		var seg := 0.0 if t < 0.14 else 1.0
		var t0 := t - seg * 0.15
		var f := (300.0 - seg * 70.0) - t0 * 350.0
		b[i] = sin(TAU * maxf(f, 60.0) * t0) * exp(-t0 * 22.0) * 0.42
	return _stream(b)


## Aviso de ataque inimigo: subida suave — "um chefe le-se de ouvido" (spec/21).
func _make_telegraph() -> AudioStreamWAV:
	var b := _buf(0.26)
	var phase := 0.0
	for i in b.size():
		var t := float(i) / RATE
		var k := t / 0.26
		phase += TAU * lerpf(380.0, 860.0, k * k) / RATE
		b[i] = sin(phase) * sin(PI * k) * 0.20
	return _stream(b)


## Cinco famílias semânticas, independentes do nome do ficheiro: aparar é
## brilhante, esquivar médio, volume móvel sobe do grave, área pulsa grave e o
## perseguidor desce de altura. A descrição concreta continua na ficha.
func _make_attack_tell(dur: float, f_start: float, f_end: float, noise_amount: float) -> AudioStreamWAV:
	var b := _buf(dur)
	var phase := 0.0
	var lp := 0.0
	for i in b.size():
		var t := float(i) / RATE
		var k := t / dur
		phase += TAU * lerpf(f_start, f_end, k * k) / RATE
		lp += (_rng.randf_range(-1.0, 1.0) - lp) * 0.12
		var env := sin(PI * k)
		b[i] = (sin(phase) * (1.0 - noise_amount) + lp * noise_amount) * env * 0.24
	return _stream(b)


## Postura partida: estalo seco + serra grave curta.
func _make_break() -> AudioStreamWAV:
	var b := _buf(0.28)
	for i in b.size():
		var t := float(i) / RATE
		var saw := 2.0 * fposmod(95.0 * t, 1.0) - 1.0
		var crack := _rng.randf_range(-1.0, 1.0) * exp(-t * 70.0) * 0.7
		b[i] = (saw * exp(-t * 14.0) * 0.4 + crack) * 0.6
	return _stream(b)


## Morte de inimigo: serra a cair uma oitava, com ar.
func _make_death() -> AudioStreamWAV:
	var b := _buf(0.42)
	var phase := 0.0
	for i in b.size():
		var t := float(i) / RATE
		var k := t / 0.42
		phase += TAU * lerpf(150.0, 58.0, k) / RATE
		var saw := 2.0 * fposmod(phase / TAU, 1.0) - 1.0
		var breath := _rng.randf_range(-1.0, 1.0) * 0.18
		b[i] = (saw * 0.4 + breath) * exp(-t * 7.0) * 0.5
	return _stream(b)


## Furia: rugido grave — serra + ruido, meio segundo.
func _make_fury() -> AudioStreamWAV:
	var b := _buf(0.5)
	var phase := 0.0
	for i in b.size():
		var t := float(i) / RATE
		phase += TAU * (72.0 + sin(t * 30.0) * 9.0) / RATE
		var saw := 2.0 * fposmod(phase / TAU, 1.0) - 1.0
		var noise := _rng.randf_range(-1.0, 1.0) * 0.35
		b[i] = (saw * 0.5 + noise) * sin(PI * minf(t / 0.5 * 1.15, 1.0)) * 0.5
	return _stream(b)
