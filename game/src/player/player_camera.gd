class_name PlayerCamera
extends Node3D
## Camara em terceira pessoa.
##
## FRONTEIRA COM A SPEC: o enquadramento, a rotacao e o game feel da camara sao do
## WP1B (spec/25-controlo.md, do lado do Mateus), que ainda nao existe. Isto e o
## minimo funcional para o combate se jogar e medir — nao e a camara final.

const MIN_PITCH := -60.0
const MAX_PITCH := 32.0

## Numeros de spec/25-controlo.md (WP1B), carregados de data/combat.json -> camera.
@export var sensitivity := 0.0022
@export var follow_height := 1.6
@export var distance := 4.0
@export var distance_locked_on := 4.8
@export var gamepad_look_radians_per_second := 2.5

var target: Node3D
var lock_target: Node3D

var _yaw := 0.0
var _pitch := -0.22
var _arm: SpringArm3D
var _camera: Camera3D


func _ready() -> void:
	top_level = true

	var cfg := GameData.section("camera")
	follow_height = cfg.get("pivot_height", 1.6)
	distance = cfg.get("distance", 4.0)
	distance_locked_on = cfg.get("distance_locked_on", 4.8)
	gamepad_look_radians_per_second = cfg.get("gamepad_look_radians_per_second", 2.5)

	_arm = SpringArm3D.new()
	_arm.spring_length = distance
	_arm.margin = float(cfg.get("collision_radius", 0.25))
	# So colide com o cenario (camada 1), nunca com o jogador nem com inimigos.
	_arm.collision_mask = 1
	add_child(_arm)

	_camera = Camera3D.new()
	_camera.current = true
	# 55 graus: FOV alto deforma a percepcao de distancia da esquiva.
	_camera.fov = float(cfg.get("fov", 55.0))
	_camera.near = 0.08
	_arm.add_child(_camera)


func set_view_distance(d: float) -> void:
	_camera.far = d


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var mm := event as InputEventMouseMotion
		_yaw -= mm.relative.x * sensitivity
		_pitch = clampf(_pitch - mm.relative.y * sensitivity,
			deg_to_rad(MIN_PITCH), deg_to_rad(MAX_PITCH))


func _physics_process(delta: float) -> void:
	if target == null:
		return
	if not is_instance_valid(lock_target):
		var gamepad_look := Input.get_vector("look_left", "look_right", "look_up", "look_down")
		if gamepad_look.length_squared() > 0.01:
			_yaw -= gamepad_look.x * gamepad_look_radians_per_second * delta
			_pitch = clampf(_pitch - gamepad_look.y * gamepad_look_radians_per_second * delta,
				deg_to_rad(MIN_PITCH), deg_to_rad(MAX_PITCH))

	var focus := target.global_position + Vector3.UP * follow_height
	global_position = global_position.lerp(focus, clampf(delta * 18.0, 0.0, 1.0))

	# Em combate com alvo engatado a camara recua, para o inimigo caber inteiro.
	var wanted_arm := distance_locked_on if is_instance_valid(lock_target) else distance
	_arm.spring_length = lerpf(_arm.spring_length, wanted_arm, clampf(delta * 5.0, 0.0, 1.0))

	if is_instance_valid(lock_target):
		# Com alvo engatado a camara olha para o meio entre os dois — o duelo fica legivel.
		var mid := (target.global_position + lock_target.global_position) * 0.5 + Vector3.UP * 1.1
		var to_mid := mid - global_position
		if to_mid.length_squared() > 0.01:
			var wanted_yaw := atan2(-to_mid.x, -to_mid.z)
			_yaw = lerp_angle(_yaw, wanted_yaw, clampf(delta * 9.0, 0.0, 1.0))
			var flat := Vector2(to_mid.x, to_mid.z).length()
			var wanted_pitch := clampf(atan2(to_mid.y - 0.6, flat),
				deg_to_rad(MIN_PITCH), deg_to_rad(MAX_PITCH))
			_pitch = lerp_angle(_pitch, wanted_pitch, clampf(delta * 7.0, 0.0, 1.0))

	rotation = Vector3(_pitch, _yaw, 0.0)


## Base para movimento relativo a camara (plano do chao).
func forward_flat() -> Vector3:
	var f := -global_transform.basis.z
	f.y = 0.0
	return f.normalized()


func right_flat() -> Vector3:
	var r := global_transform.basis.x
	r.y = 0.0
	return r.normalized()


func get_camera() -> Camera3D:
	return _camera
