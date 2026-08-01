class_name LootFeedback
extends Node3D
## Confirma a recolha por tres canais: forma dourada, texto com a comparacao e
## sino sintetizado. Vive poucos segundos e nao usa particulas nem luzes.

const LootAudioScript = preload("res://src/loot/loot_audio.gd")

var _rules: Dictionary = {}
var _elapsed := 0.0
var _start_y := 0.0
var _visual: MeshInstance3D
var _label: Label3D
var _audio: AudioStreamPlayer3D


func configure(interest: Dictionary, rules: Dictionary) -> void:
	_rules = rules
	_start_y = position.y
	_build_visual(interest)
	_build_audio()
	set_process(true)


func presentation_contract() -> Dictionary:
	return {
		"visible": is_instance_valid(_visual) and is_instance_valid(_label),
		"audible": is_instance_valid(_audio) and _audio.stream != null,
		"mesh_instances": 1 if is_instance_valid(_visual) else 0,
		"labels": 1 if is_instance_valid(_label) else 0,
		"audio_voices": 1 if is_instance_valid(_audio) else 0,
		"art_source": "forma e glifo sintetizados em codigo",
		"sound_source": "sino sintetizado em codigo",
	}


func _process(delta: float) -> void:
	_elapsed += delta
	var duration := maxf(float(_rules.get("feedback_seconds", 3.0)), 0.01)
	var progress := clampf(_elapsed / duration, 0.0, 1.0)
	position.y = _start_y + float(_rules.get("feedback_rise_m", 1.1)) * progress
	if is_instance_valid(_label):
		_label.modulate.a = 1.0 - smoothstep(0.72, 1.0, progress)
	if _elapsed >= duration:
		queue_free()


func _build_visual(interest: Dictionary) -> void:
	_visual = MeshInstance3D.new()
	_visual.name = "LootGlyph"
	var mesh := SphereMesh.new()
	var size := float(_rules.get("feedback_mesh_size_m", 0.18))
	mesh.radius = size
	mesh.height = size * 2.0
	mesh.radial_segments = 4
	mesh.rings = 2
	_visual.mesh = mesh
	_visual.rotation_degrees = Vector3(0.0, 45.0, 0.0)
	_visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material := StandardMaterial3D.new()
	var colour := Color(String(_rules.get("pickup_colour", "#e6cf79")))
	material.albedo_color = colour
	material.emission_enabled = true
	material.emission = colour * 0.55
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_visual.material_override = material
	add_child(_visual)

	_label = Label3D.new()
	_label.name = "LootReason"
	_label.position = Vector3(0.0, size * 2.4, 0.0)
	_label.text = "%s\n%s" % [String(interest.get("name", "Item")),
		String(interest.get("reason", "Nova opcao."))]
	_label.font_size = 30
	_label.outline_size = 8
	_label.modulate = colour
	_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_label.no_depth_test = true
	add_child(_label)


func _build_audio() -> void:
	_audio = AudioStreamPlayer3D.new()
	_audio.name = "LootSound"
	_audio.stream = LootAudioScript.pickup_stream()
	_audio.bus = "UI"
	_audio.unit_size = 5.0
	_audio.max_distance = 34.0
	add_child(_audio)
	_audio.play()
