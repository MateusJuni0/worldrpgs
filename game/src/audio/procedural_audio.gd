class_name ProceduralAudio
extends RefCounted
## Sons de ambiente gerados em memoria: sem ficheiros, caminhos ou dependencias.
##
## Os loops usam ruido ciclico interpolado. O ultimo ponto liga ao primeiro como
## mais uma amostra do mesmo ruido, em vez de esconder a costura com silencio.

const RATE := 22050


static func make_wind() -> AudioStreamWAV:
	const DURATION := 8.0
	var rng := _seeded_rng(0x4252554d)
	var body := _controls(rng, 64)
	var air := _controls(rng, 1024)
	var samples := _buffer(DURATION)
	for index in samples.size():
		var time := float(index) / RATE
		var cycle := time / DURATION
		var breath := 0.62 + sin(TAU * cycle * 3.0) * 0.18 \
			+ sin(TAU * cycle * 7.0 + 1.3) * 0.09
		var low := _cyclic_noise(body, cycle * body.size())
		var hiss := _cyclic_noise(air, cycle * air.size())
		samples[index] = (low * 0.16 + hiss * 0.30) * breath * 0.34
	return _stream(samples, true)


static func make_leaves() -> AudioStreamWAV:
	const DURATION := 8.0
	var rng := _seeded_rng(0x464f4c48)
	var grain := _controls(rng, 3072)
	var samples := _buffer(DURATION)
	var gusts := PackedFloat32Array([0.85, 2.45, 4.70, 6.35])
	for index in samples.size():
		var time := float(index) / RATE
		var cycle := time / DURATION
		var envelope := 0.035
		for centre in gusts:
			envelope += _soft_pulse(time, centre, 0.48) * 0.30
		var position := cycle * grain.size()
		var dry := _cyclic_noise(grain, position)
		var edge := dry - _cyclic_noise(grain, position - 1.35)
		samples[index] = (dry * 0.10 + edge * 0.72) * envelope
	return _stream(samples, true)


static func make_water() -> AudioStreamWAV:
	const DURATION := 8.0
	var rng := _seeded_rng(0x41475541)
	var texture := _controls(rng, 4096)
	var flow := _controls(rng, 96)
	var samples := _buffer(DURATION)
	for index in samples.size():
		var time := float(index) / RATE
		var cycle := time / DURATION
		var wet := _cyclic_noise(texture, cycle * texture.size())
		var movement := 0.58 + _cyclic_noise(flow, cycle * flow.size()) * 0.22
		var ripple := sin(TAU * 137.0 * time + sin(TAU * 5.0 * time) * 0.8) * 0.08
		ripple += sin(TAU * 311.0 * time + 0.7) * 0.035
		samples[index] = (wet * 0.20 + ripple) * movement * 0.30
	return _stream(samples, true)


static func make_crows() -> AudioStreamWAV:
	const DURATION := 2.15
	var rng := _seeded_rng(0x434f5256)
	var roughness := _controls(rng, 256)
	var samples := _buffer(DURATION)
	var calls := PackedFloat32Array([0.18, 0.93, 1.48])
	for index in samples.size():
		var time := float(index) / RATE
		var value := 0.0
		for call_index in calls.size():
			var local := time - calls[call_index]
			var length := 0.38 if call_index < 2 else 0.29
			if local < 0.0 or local >= length:
				continue
			var progress := local / length
			var envelope := sin(PI * progress) * exp(-progress * 0.65)
			var frequency := lerpf(510.0, 315.0, progress) \
				+ sin(TAU * 23.0 * local) * 24.0
			var rasp := _cyclic_noise(roughness, time * 83.0) * 0.16
			value += (sin(TAU * frequency * local) * 0.58 \
				+ sin(TAU * frequency * 0.51 * local) * 0.24 + rasp) * envelope
		samples[index] = value * 0.30
	return _stream(samples)


static func make_campfire() -> AudioStreamWAV:
	const DURATION := 6.0
	var rng := _seeded_rng(0x42524153)
	var flame := _controls(rng, 768)
	var sparks := _controls(rng, 4096)
	var centres := PackedFloat32Array()
	var strengths := PackedFloat32Array()
	for _index in 18:
		centres.append(rng.randf_range(0.18, DURATION - 0.18))
		strengths.append(rng.randf_range(0.35, 0.85))
	var samples := _buffer(DURATION)
	for index in samples.size():
		var time := float(index) / RATE
		var cycle := time / DURATION
		var base := _cyclic_noise(flame, cycle * flame.size()) * 0.18
		var sharp := _cyclic_noise(sparks, cycle * sparks.size())
		var crackle := 0.0
		for spark_index in centres.size():
			var distance := absf(time - centres[spark_index])
			if distance < 0.045:
				crackle += sharp * exp(-distance * 105.0) * strengths[spark_index]
		var breathing := 0.72 + sin(TAU * cycle * 5.0 + 0.4) * 0.13
		samples[index] = (base * breathing + crackle * 0.44) * 0.42
	return _stream(samples, true)


static func _stream(samples: PackedFloat32Array, loop := false) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	bytes.resize(samples.size() * 2)
	for index in samples.size():
		bytes.encode_s16(index * 2,
			int(clampf(samples[index], -1.0, 1.0) * 32767.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = RATE
	stream.data = bytes
	if loop:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = samples.size()
	return stream


static func _buffer(seconds: float) -> PackedFloat32Array:
	var samples := PackedFloat32Array()
	samples.resize(int(seconds * RATE))
	return samples


static func _seeded_rng(seed_value: int) -> RandomNumberGenerator:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return rng


static func _controls(rng: RandomNumberGenerator, count: int) -> PackedFloat32Array:
	var values := PackedFloat32Array()
	values.resize(count)
	for index in count:
		values[index] = rng.randf_range(-1.0, 1.0)
	return values


static func _cyclic_noise(values: PackedFloat32Array, position: float) -> float:
	var wrapped := fposmod(position, float(values.size()))
	var left := int(floorf(wrapped))
	var fraction := wrapped - float(left)
	var smooth := fraction * fraction * (3.0 - 2.0 * fraction)
	return lerpf(values[left], values[(left + 1) % values.size()], smooth)


static func _soft_pulse(time: float, centre: float, half_width: float) -> float:
	var distance := absf(time - centre)
	if distance >= half_width:
		return 0.0
	var amount := 1.0 - distance / half_width
	return amount * amount * (3.0 - 2.0 * amount)
