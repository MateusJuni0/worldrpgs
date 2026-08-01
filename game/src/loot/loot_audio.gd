class_name LootAudio
extends RefCounted
## Dois sinais sintetizados uma vez: madeira/ferro ao abrir e sino ascendente
## ao recolher. Nao acrescenta binarios nem depende de assets externos.

const SAMPLE_RATE := 22050
static var _pickup_stream: AudioStreamWAV
static var _chest_stream: AudioStreamWAV


static func pickup_stream() -> AudioStreamWAV:
	if _pickup_stream == null:
		_pickup_stream = _make_pickup()
	return _pickup_stream


static func chest_stream() -> AudioStreamWAV:
	if _chest_stream == null:
		_chest_stream = _make_chest()
	return _chest_stream


static func _make_pickup() -> AudioStreamWAV:
	var duration := 0.42
	var samples := PackedFloat32Array()
	samples.resize(roundi(duration * SAMPLE_RATE))
	for index: int in samples.size():
		var time := float(index) / SAMPLE_RATE
		var value := sin(TAU * 740.0 * time) * exp(-time * 9.0) * 0.34
		if time >= 0.10:
			var second := time - 0.10
			value += sin(TAU * 1110.0 * second) * exp(-second * 10.0) * 0.28
		if time >= 0.20:
			var third := time - 0.20
			value += sin(TAU * 1480.0 * third) * exp(-third * 12.0) * 0.20
		samples[index] = value
	return _stream(samples)


static func _make_chest() -> AudioStreamWAV:
	var duration := 0.55
	var samples := PackedFloat32Array()
	samples.resize(roundi(duration * SAMPLE_RATE))
	for index: int in samples.size():
		var time := float(index) / SAMPLE_RATE
		var wood := sin(TAU * (92.0 + time * 34.0) * time) * exp(-time * 5.5) * 0.28
		var grain := sin(float(index) * 12.9898) * exp(-time * 18.0) * 0.12
		var latch := 0.0
		if time >= 0.30:
			var metal_time := time - 0.30
			latch = sin(TAU * 1860.0 * metal_time) * exp(-metal_time * 24.0) * 0.22
		samples[index] = wood + grain + latch
	return _stream(samples)


static func _stream(samples: PackedFloat32Array) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	bytes.resize(samples.size() * 2)
	for index: int in samples.size():
		bytes.encode_s16(index * 2,
			int(clampf(samples[index], -1.0, 1.0) * 32767.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.data = bytes
	return stream
