extends Node
## Efeitos sonoros SINTETIZADOS no arranque — zero ficheiros, zero downloads.
##
## O som e parte da Lei 1 (spec/21, WP12): um ataque que se OUVE a chegar e mais
## uma pista justa; o parry que acerta merece o melhor som do jogo. Cada som e
## gerado por DSP simples (senos, serra, ruido, envelopes) a 22050 Hz mono.
## Afinacao: mexer nos numeros dos _make_* e voltar a correr.

const RATE := 22050

var _bank: Dictionary = {}
var _pool: Array[AudioStreamPlayer3D] = []
var _flat_pool: Array[AudioStreamPlayer] = []
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	for i in 4:
		var f := AudioStreamPlayer.new()
		f.bus = "Master"
		add_child(f)
		_flat_pool.append(f)
	for i in 12:
		var p := AudioStreamPlayer3D.new()
		p.max_distance = 42.0
		p.unit_size = 6.0
		add_child(p)
		_pool.append(p)
	_generate_bank()


## at == null -> som "do jogador" (sem posicao). Com posicao -> 3D.
func play(sound: String, at: Variant = null, volume_db := 0.0, pitch_jitter := 0.06) -> void:
	var stream: AudioStreamWAV = _bank.get(sound)
	if stream == null:
		return
	var pitch := 1.0 + _rng.randf_range(-pitch_jitter, pitch_jitter)
	if at == null:
		for f in _flat_pool:
			if not f.playing:
				f.stream = stream
				f.volume_db = volume_db
				f.pitch_scale = pitch
				f.play()
				return
		return
	for p in _pool:
		if not p.playing:
			p.global_position = at as Vector3
			p.stream = stream
			p.volume_db = volume_db
			p.pitch_scale = pitch
			p.play()
			return


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
	print("[sfx] %d sons sintetizados" % _bank.size())


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
