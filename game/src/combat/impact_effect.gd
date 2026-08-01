class_name ImpactEffect
extends Node3D
## Um pulso no contacto, sem particulas persistentes nem relogio em segundos.
##
## Nasce no frame autoritativo do dano e e removido quando acabam os frames
## activos restantes. A reaccao do corpo pode continuar a contar um golpe que ja
## aconteceu; esta forma brilhante, que pode parecer perigosa, nunca continua.

static var _mesh: SphereMesh
static var _materials: Dictionary = {}

var born_physics_frame := -1
var active_frames_total := 0
var active_frames_left := 0
var surface := "flesh"
var _pulse: MeshInstance3D


func prepare() -> void:
	if _pulse == null:
		_pulse = MeshInstance3D.new()
		_pulse.name = "ContactPulse"
		_pulse.mesh = _shared_mesh()
		_pulse.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(_pulse)
	visible = false
	set_physics_process(false)


func setup(event: ImpactEvent) -> bool:
	prepare()
	name = "Impact_%s" % event.surface
	born_physics_frame = event.physics_frame
	active_frames_total = event.active_frames_remaining
	active_frames_left = event.active_frames_remaining
	surface = event.surface
	global_position = event.contact_point
	if active_frames_left <= 0:
		push_error("[impacto] feedback pedido fora dos frames activos")
		_release()
		return false

	_pulse.material_override = _material_for(surface)
	_pulse.scale = Vector3.ONE
	visible = true
	set_physics_process(true)
	return true


func _physics_process(_delta: float) -> void:
	if active_frames_left <= 0:
		return
	active_frames_left -= 1
	if is_instance_valid(_pulse):
		var fraction := float(active_frames_left) / float(maxi(active_frames_total, 1))
		_pulse.scale = Vector3.ONE * maxf(fraction, 0.001)
	if active_frames_left == 0:
		_release()


func lives_on_physics_frame(frame: int) -> bool:
	return frame >= born_physics_frame \
		and frame < born_physics_frame + active_frames_total


func is_available() -> bool:
	return active_frames_left <= 0 and not visible


func _release() -> void:
	active_frames_left = 0
	visible = false
	set_physics_process(false)


static func _shared_mesh() -> SphereMesh:
	if _mesh == null:
		_mesh = SphereMesh.new()
		# particulas por impacto na GPU integrada.
		# Uma unica draw call e silhueta legivel, sem emissor de particulas por
		# impacto na GPU integrada.
		# particulas por impacto na GPU integrada.
		_mesh.radial_segments = 4
		_mesh.rings = 2
		_mesh.radius = 0.18
		_mesh.height = 0.36
	return _mesh


static func _material_for(kind: String) -> StandardMaterial3D:
	if _materials.has(kind):
		return _materials[kind] as StandardMaterial3D
	var colours := {
		"flesh": Color("7f1624"),
		"metal": Color("fff1b8"),
		"wood": Color("b9793f"),
		"stone": Color("c4d0d4"),
	}
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = colours.get(kind, colours["flesh"])
	material.emission_enabled = true
	material.emission = material.albedo_color
	material.emission_energy_multiplier = 1.35
	_materials[kind] = material
	return material
