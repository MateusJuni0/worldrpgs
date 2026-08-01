class_name HitFeedbackAudio
extends Node
## Superficie audivel sem ficheiros novos.
##
## Carne e madeira reutilizam o banco sintetizado existente. Metal recebe um
## transiente proprio para nao roubar o sino reservado ao parry. A arte sonora e,
## portanto, sintetizada em codigo e nao vem de uma biblioteca sem proveniencia.

const SAMPLE_RATE := 22050
const METAL_VOICE_COUNT := 5

var _metal_stream: AudioStreamWAV
var _metal_players: Array[AudioStreamPlayer3D] = []
var synthesis_milliseconds := 0.0


func _ready() -> void:
	var started := Time.get_ticks_usec()
	_metal_stream = _make_metal_stream()
	synthesis_milliseconds = float(Time.get_ticks_usec() - started) / 1000.0
	for index in METAL_VOICE_COUNT:
		var player := AudioStreamPlayer3D.new()
		player.name = "MetalImpact%d" % index
		player.bus = "Impact"
		player.stream = _metal_stream
		add_child(player)
		_metal_players.append(player)


func play_surface(surface: String, at: Vector3) -> void:
	match surface:
		"metal":
			_play_metal(at)
		"wood", "stone":
			_play_existing("hit_block", at)
		_:
			_play_existing("hit_flesh", at)


func sound_id_for_surface(surface: String) -> String:
	match surface:
		"metal": return "impact_metal_sintetizado"
		"wood": return "hit_block_madeira_sintetizado"
		"stone": return "hit_block_pedra_sintetizado"
		_: return "hit_flesh_sintetizado"


func _play_metal(at: Vector3) -> void:
	for player: AudioStreamPlayer3D in _metal_players:
		if not player.playing:
			player.global_position = at
			player.pitch_scale = 1.0
			player.play()
			return


func _play_existing(sound_id: String, at: Vector3) -> void:
	var sfx := get_node_or_null("/root/Sfx")
	if sfx != null and sfx.has_method("play"):
		sfx.call("play", sound_id, at)


static func _make_metal_stream() -> AudioStreamWAV:
	var duration := 0.16
	var samples := PackedFloat32Array()
	samples.resize(int(duration * SAMPLE_RATE))
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("worldrpgs-impact-metal")
	for index in samples.size():
		var time := float(index) / float(SAMPLE_RATE)
		var ring := sin(TAU * 1460.0 * time) * 0.46
		ring += sin(TAU * 2317.0 * time) * 0.29
		var strike := rng.randf_range(-1.0, 1.0) * exp(-time * 145.0) * 0.48
		samples[index] = (ring * exp(-time * 24.0) + strike) * 0.55
	var bytes := PackedByteArray()
	bytes.resize(samples.size() * 2)
	for index in samples.size():
		bytes.encode_s16(index * 2, int(clampf(samples[index], -1.0, 1.0) * 32767.0))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.data = bytes
	return stream
