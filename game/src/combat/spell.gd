class_name Spell
extends Node3D
## As tres magias da fatia — tres VERBOS diferentes, nao tres escaloes de dano (Lei 2).
##
##   Dardo  projectil  0,8 s
##   Ruina  area       1,6 s
##   Egide  barreira   0,5 s  (tratada no proprio jogador: absorve antes da vida)
##
## A escola declara a escala: Inteligencia, Fe, media das duas ou o MENOR.

var _data: Dictionary = {}
var _caster: Node3D
var _attrs: Dictionary = {}
var _velocity := Vector3.ZERO
var _life := 0.0
var _max_life := 3.0
var _kind := "projectile"
var _hit: Array = []
var _mesh: MeshInstance3D


static func _damage_for(data: Dictionary, attrs: Dictionary, target_defense: float) -> float:
	var attr := GameData.casting_attribute_for(String(data.get("school", "feiticaria")), attrs)
	var scale := GameData.attribute_scale(attr, String(data.get("scale_weight", "forte")))
	var raw := float(data.get("mv", 1.0)) * float(data.get("base_damage", 0)) * scale
	return GameData.apply_defense(raw, target_defense)


static func make_projectile(data: Dictionary, caster: Node3D, origin: Vector3,
		dir: Vector3, attrs: Dictionary) -> Spell:
	var s := Spell.new()
	s._kind = "projectile"
	s._data = data
	s._caster = caster
	s._attrs = attrs
	s._velocity = dir.normalized() * float(data.get("speed", 22.0))
	s._max_life = float(data.get("max_range", 30.0)) / maxf(float(data.get("speed", 22.0)), 1.0)
	s.position = origin
	s._build_visual(0.22, Color(0.55, 0.8, 1.0))
	return s


static func make_aoe(data: Dictionary, caster: Node3D, centre: Vector3, attrs: Dictionary) -> Spell:
	var s := Spell.new()
	s._kind = "aoe"
	s._data = data
	s._caster = caster
	s._attrs = attrs
	s._max_life = float(data.get("telegraph_seconds", 0.6))
	s.position = centre
	s._build_visual(float(data.get("radius", 4.0)), Color(0.85, 0.4, 1.0, 0.5))
	return s


func _build_visual(radius: float, colour: Color) -> void:
	_mesh = MeshInstance3D.new()
	var m := SphereMesh.new()
	m.radius = radius
	m.height = radius * 2.0
	m.radial_segments = 8
	m.rings = 4
	_mesh.mesh = m
	var mat := StandardMaterial3D.new()
	mat.albedo_color = colour
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if colour.a < 1.0:
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_mesh.mesh.surface_get_material(0)
	_mesh.material_override = mat
	_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(_mesh)


func _physics_process(delta: float) -> void:
	_life += delta
	match _kind:
		"projectile":
			position += _velocity * delta
			_check_projectile_hit()
			if _life >= _max_life:
				queue_free()
		"aoe":
			# Telegrafa primeiro, so depois e que magoa — dá tempo de sair de cima.
			if _life >= _max_life:
				_detonate()
				queue_free()


func _check_projectile_hit() -> void:
	for node in get_tree().get_nodes_in_group("enemies"):
		var e := node as Node3D
		if e == null or _hit.has(e):
			continue
		if e.has_method("is_alive") and not e.call("is_alive"):
			continue
		var radius: float = e.get("body_radius") if e.get("body_radius") != null else 0.5
		if global_position.distance_to(e.global_position + Vector3.UP) <= radius + 0.4:
			_hit.append(e)
			_apply_to(e)
			queue_free()
			return


func _detonate() -> void:
	var radius := float(_data.get("radius", 4.0))
	for node in get_tree().get_nodes_in_group("enemies"):
		var e := node as Node3D
		if e == null:
			continue
		if e.has_method("is_alive") and not e.call("is_alive"):
			continue
		if global_position.distance_to(e.global_position) <= radius:
			_apply_to(e)


func _apply_to(e: Node3D) -> void:
	if not e.has_method("take_damage"):
		return
	var target_def: float = e.get("defense") if e.get("defense") != null else 0.0
	var info := DamageInfo.make(_damage_for(_data, _attrs, target_def), _caster,
		String(_data.get("weight", "light")))
	info.is_magic = true
	info.is_aoe = (_kind == "aoe")
	info.posture_damage = GameData.posture_damage_from_mv(float(_data.get("mv", 1.0)))
	e.call("take_damage", info)
