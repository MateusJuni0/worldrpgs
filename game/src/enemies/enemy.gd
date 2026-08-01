class_name Enemy
extends CharacterBody3D
## Inimigo generico, todo definido por dados (data/enemies.json).
##
## IA SIMPLES E LEGIVEL VENCE IA ESPERTA. O jogador tem de conseguir prever o que
## vem a seguir — e isso que faz a esquiva e o parry serem habilidade e nao sorte.
##
## Contrato que a spec impoe e que este ficheiro cumpre:
##  - todo o ataque telegrafa >= 0,5 s, e o telegrafo e VISIVEL (amarelo)
##  - cada ataque e 'aparavel' ou 'so esquiva', vindo dos dados
##  - postura 0-100: dano de postura = MV x 10; a zero, cambaleio 1,2 s
##  - anti-kite: 4 s sem alcancar o alvo -> comportamento de fecho
##  - perseguicao sempre abaixo dos 5,0 m/s do correr do jogador (fugir e sempre possivel)

signal died(enemy: Enemy)

const GameplayCueRenderer = preload("res://src/combat/gameplay_cue.gd")

enum State { IDLE, PATROL, CHASE, ATTACK, STAGGER, BROKEN, DEAD }

var enemy_id := "orc_spearman"
var data: Dictionary = {}
var is_boss := false

var health := 100.0
var max_health := 100.0
var defense := 0.0
var posture := 40.0
var max_posture := 40.0
var posture_mult := 1.0
var body_radius := 0.45
var hitstop_frames := 0

var target: Node3D
var home := Vector3.ZERO

var state := State.IDLE
var _state_frame := 0
var _state_time := 0.0

var _attacks: Dictionary = {}
var _rng := RandomNumberGenerator.new()
var _active_gameplay_cue: Node
var _last_attack_hit_frame := -9999
var _queue: Array = []
var _atk: Dictionary = {}
var _atk_frame := 0
var _atk_hit := false
var _gap_timer := 0.0
var _no_reach_time := 0.0
var _phase := 1

var _patrol_points: Array[Vector3] = []
var _patrol_index := 0

var _visual: CharacterVisual
var _palette: Dictionary = {}


func setup(p_enemy_id: String, palette: Dictionary, coop := false, pattern_seed := 0) -> void:
	enemy_id = p_enemy_id
	_rng.seed = pattern_seed if pattern_seed != 0 else hash(enemy_id)
	data = GameData.enemy(enemy_id)
	_palette = palette
	is_boss = bool(data.get("is_boss", false))

	max_health = float(data.get("health", 100.0))
	if is_boss and coop:
		max_health *= float(data.get("coop_health_multiplier", 1.8))
	health = max_health
	defense = float(data.get("defense", 0.0))
	max_posture = float(data.get("posture", 40.0))
	posture = max_posture
	posture_mult = float(data.get("posture_damage_taken_multiplier", 1.0))

	for a: Variant in data.get("attacks", []):
		var d := a as Dictionary
		_attacks[String(d.get("id", ""))] = d
		if d.get("followup") != null:
			var f := d.get("followup") as Dictionary
			_attacks[String(f.get("id", ""))] = f

	_build_body()
	_make_patrol_route()
	state = State.PATROL if float(data.get("patrol_speed", 0.0)) > 0.0 else State.IDLE


func _build_body() -> void:
	var height := 1.9
	if enemy_id == "orc_brute":
		height = 2.3
		body_radius = 0.62
	elif is_boss:
		height = 3.0
		body_radius = 0.85
	else:
		body_radius = 0.45

	var shape := CapsuleShape3D.new()
	shape.height = height
	shape.radius = body_radius
	var col := CollisionShape3D.new()
	col.shape = shape
	col.position = Vector3(0, height * 0.5, 0)
	add_child(col)

	# A malha e visual; a CapsuleShape3D acima continua a ser a unica colisao.
	# Os tres inimigos reutilizam o mesmo esqueleto Quaternius e distinguem-se
	# pela escala, cor de estado e silhueta exterior.
	_visual = CharacterVisual.new()
	add_child(_visual)
	_visual.setup(height)

	if is_boss:
		_dress_boss(height, body_radius)

	collision_layer = 4
	collision_mask = 1
	add_to_group("enemies")


## Silhueta de chefe: chifres, ombreiras e o machadao. Material proprio e escuro
## que NAO muda com o estado — o corpo continua a ser o semaforo, a silhueta e
## so identidade. Um chefe tem de se reconhecer em contraluz (regra souls).
func _dress_boss(height: float, radius: float) -> void:
	var dark := StandardMaterial3D.new()
	dark.albedo_color = Color(0.16, 0.14, 0.13)
	dark.roughness = 1.0
	dark.specular_mode = BaseMaterial3D.SPECULAR_DISABLED

	for side in [-1.0, 1.0]:
		var horn := MeshInstance3D.new()
		var hm := BoxMesh.new()
		hm.size = Vector3(0.16, 0.75, 0.16)
		horn.mesh = hm
		horn.position = Vector3(0.34 * side, height + 0.28, 0)
		horn.rotation_degrees = Vector3(0, 0, -24.0 * side)
		horn.material_override = dark
		add_child(horn)

		var pauldron := MeshInstance3D.new()
		var pm := BoxMesh.new()
		pm.size = Vector3(0.55, 0.28, 0.72)
		pauldron.mesh = pm
		pauldron.position = Vector3((radius + 0.18) * side, height * 0.78, 0)
		pauldron.material_override = dark
		add_child(pauldron)

	var haft := MeshInstance3D.new()
	var haft_m := BoxMesh.new()
	haft_m.size = Vector3(0.12, 2.1, 0.12)
	haft.mesh = haft_m
	haft.position = Vector3(radius + 0.45, height * 0.55, 0.1)
	haft.rotation_degrees = Vector3(0, 0, 12)
	haft.material_override = dark
	add_child(haft)

	var head_blade := MeshInstance3D.new()
	var blade_m := BoxMesh.new()
	blade_m.size = Vector3(0.55, 0.6, 0.14)
	head_blade.mesh = blade_m
	head_blade.position = Vector3(radius + 0.68, height * 0.55 + 0.95, 0.1)
	head_blade.material_override = dark
	add_child(head_blade)


func _make_patrol_route() -> void:
	home = global_position
	var speed := float(data.get("patrol_speed", 0.0))
	if speed <= 0.0:
		return
	for i in 3:
		var a := TAU * float(i) / 3.0
		_patrol_points.append(home + Vector3(sin(a), 0, cos(a)) * 6.0)


# --- Ciclo --------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	# Paragem de impacto (spec/25-controlo.md): congela este corpo, nao o mundo.
	if hitstop_frames > 0:
		hitstop_frames -= 1
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return

	_state_frame += 1
	_state_time += delta

	if state != State.DEAD:
		_tick_boss_phase()
		_tick_anti_kite(delta)

	match state:
		State.IDLE:   _tick_idle(delta)
		State.PATROL: _tick_patrol(delta)
		State.CHASE:  _tick_chase(delta)
		State.ATTACK: _tick_attack(delta)
		State.STAGGER, State.BROKEN: _tick_downed(delta)
		State.DEAD:
			velocity.x = 0.0
			velocity.z = 0.0

	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity", 20.0) * delta
	else:
		velocity.y = minf(velocity.y, 0.0)
	move_and_slide()
	_refresh_colour()
	_refresh_animation()


func _change_state(next: int) -> void:
	state = next
	_state_frame = 0
	_state_time = 0.0


func _target_valid() -> bool:
	return is_instance_valid(target) and (not target.has_method("is_alive") or target.call("is_alive"))


func _distance_to_target() -> float:
	if not _target_valid():
		return 9999.0
	var d := target.global_position - global_position
	d.y = 0.0
	return d.length()


func _tick_idle(delta: float) -> void:
	_brake(delta)
	if _target_valid() and _distance_to_target() <= float(data.get("aggro_range", 16.0)):
		_change_state(State.CHASE)


func _tick_patrol(delta: float) -> void:
	if _target_valid() and _distance_to_target() <= float(data.get("aggro_range", 16.0)):
		_change_state(State.CHASE)
		return
	if _patrol_points.is_empty():
		_brake(delta)
		return
	var goal := _patrol_points[_patrol_index]
	if global_position.distance_to(goal) < 1.2:
		_patrol_index = (_patrol_index + 1) % _patrol_points.size()
	_walk_towards(goal, float(data.get("patrol_speed", 1.5)))


func _tick_chase(delta: float) -> void:
	if not _target_valid():
		_change_state(State.PATROL if not _patrol_points.is_empty() else State.IDLE)
		return

	var dist := _distance_to_target()
	if dist > float(data.get("leash_range", 30.0)):
		_change_state(State.PATROL if not _patrol_points.is_empty() else State.IDLE)
		return

	_face_target(delta)
	_gap_timer -= delta

	var preferred := float(data.get("preferred_distance", 2.3))
	if dist > preferred:
		_walk_towards(target.global_position, float(data.get("chase_speed", 3.0)))
	else:
		_brake(delta)

	if _gap_timer <= 0.0 and dist <= float(data.get("attack_range", 2.6)) + 0.4:
		_begin_pattern()


func _tick_downed(delta: float) -> void:
	_brake(delta)
	var seconds := 1.2
	if state == State.BROKEN:
		seconds = float(GameData.section("parry").get("broken_posture_duration", 2.0))
	else:
		seconds = float(GameData.section("poise").get("stagger_duration", 1.2))
	if _state_time >= seconds:
		posture = max_posture      # a postura volta ao maximo (spec)
		_change_state(State.CHASE)


func _brake(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, delta * 18.0)
	velocity.z = move_toward(velocity.z, 0.0, delta * 18.0)


func _walk_towards(point: Vector3, speed: float) -> void:
	var dir := point - global_position
	dir.y = 0.0
	if dir.length() < 0.1:
		return
	dir = dir.normalized()
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	rotation.y = lerp_angle(rotation.y, atan2(-dir.x, -dir.z), 0.12)


func _face_target(delta: float, max_degrees_per_second := 180.0) -> void:
	if not _target_valid():
		return
	var d := target.global_position - global_position
	d.y = 0.0
	if d.length_squared() > 0.01:
		var desired := atan2(-d.x, -d.z)
		var max_step := deg_to_rad(max_degrees_per_second) * delta
		rotation.y += clampf(angle_difference(rotation.y, desired), -max_step, max_step)


# --- Anti-kite ----------------------------------------------------------------

func _tick_anti_kite(delta: float) -> void:
	if state != State.CHASE and state != State.ATTACK:
		_no_reach_time = 0.0
		return
	if _distance_to_target() <= float(data.get("attack_range", 2.6)) + 0.5:
		_no_reach_time = 0.0
	else:
		_no_reach_time += delta


func _anti_kite_ready() -> bool:
	var limit: float = GameData.section("anti_kite").get("seconds_without_reaching", 4.0)
	return _no_reach_time >= limit


# --- Ataques ------------------------------------------------------------------

func _current_phase_data() -> Dictionary:
	if not is_boss:
		return data
	var phases: Dictionary = data.get("phases", {})
	return phases.get(str(_phase), data) as Dictionary


func _tick_boss_phase() -> void:
	if not is_boss or _phase >= 2:
		return
	var threshold := float(data.get("phase_2_at_health_fraction", 0.5))
	if health / maxf(max_health, 1.0) <= threshold:
		_phase = 2
		_queue.clear()   # a fase 2 muda PADROES, nao numeros


func _begin_pattern() -> void:
	# Anti-kite tem prioridade: 4 s sem alcancar o alvo -> golpe de fecho.
	if _anti_kite_ready():
		for id: String in _attacks.keys():
			if bool(_attacks[id].get("anti_kite_only", false)):
				_queue = [id]
				_no_reach_time = 0.0
				_start_next_attack()
				return

	var phase := _current_phase_data()
	var patterns: Array = phase.get("patterns", [])
	if patterns.is_empty():
		return
	var chosen: Array = patterns[_rng.randi_range(0, patterns.size() - 1)]
	_queue = []
	for id: Variant in chosen:
		# Um golpe so-anti-kite nunca entra num padrao normal.
		if not bool(_attacks.get(String(id), {}).get("anti_kite_only", false)):
			_queue.append(String(id))
	_start_next_attack()


func _start_next_attack() -> void:
	if _queue.is_empty():
		var phase := _current_phase_data()
		_gap_timer = float(phase.get("gap_between_patterns", 1.2))
		_change_state(State.CHASE)
		return
	var id: String = _queue.pop_front()
	_atk = _attacks.get(id, {})
	if _atk.is_empty():
		_start_next_attack()
		return
	_atk_frame = 0
	_atk_hit = false
	_last_attack_hit_frame = -9999
	if is_instance_valid(_active_gameplay_cue):
		_active_gameplay_cue.cancel()
	_active_gameplay_cue = GameplayCueRenderer.new()
	_active_gameplay_cue.call("configure", self, _atk)
	add_child(_active_gameplay_cue)
	_change_state(State.ATTACK)


func _tick_attack(delta: float) -> void:
	_atk_frame += 1
	var startup := int(_atk.get("startup", 30))
	var active := int(_atk.get("active", 6))
	var recovery := int(_atk.get("recovery", 24))

	if _atk_frame <= startup:
		# Abertura pode seguir a 180 graus/s; o sinal só afina a 30. No primeiro
		# frame activo a rotação é zero (spec/38), não uma direcção universal.
		_brake(delta)
		var phase_1 := int(_atk.get("phase_1_frames", startup - 12))
		_face_target(delta, 180.0 if _atk_frame <= phase_1 else 30.0)
		return

	if _atk_frame <= startup + active:
		var lunge := float(_atk.get("lunge_distance", 0.0))
		if lunge > 0.0:
			var f := -global_transform.basis.z
			velocity.x = f.x * (lunge / (float(active) / 60.0)) * 0.5
			velocity.z = f.z * (lunge / (float(active) / 60.0)) * 0.5
		else:
			_brake(delta)
		var persistent := String(_atk.get("tipo_contacto", "")) == "volume_persistente"
		var interval := maxi(int(_atk.get("damage_interval_frames", 30)), 1)
		if not _atk_hit or (persistent and _atk_frame - _last_attack_hit_frame >= interval):
			_try_hit()
		return

	_brake(delta)
	if _atk_frame >= startup + active + recovery:
		var follow: Variant = _atk.get("followup", null)
		if follow != null:
			_atk = follow as Dictionary
			_atk_frame = 0
			_atk_hit = false
			return
		_start_next_attack()


func _try_hit() -> void:
	if not _target_valid():
		return
	var weight := String(_atk.get("weight", "light"))
	var raw: float = float((data.get("damage", {}) as Dictionary).get(weight, 0.0))
	if raw <= 0.0:
		return

	var hit := false
	if bool(_atk.get("is_aoe", false)):
		hit = _distance_to_target() <= float(_atk.get("radius", 4.0))
	else:
		var to := target.global_position - global_position
		to.y = 0.0
		var reach := float(_atk.get("range", 2.5)) + body_radius
		if to.length() <= reach:
			var facing := -global_transform.basis.z
			hit = facing.angle_to(to.normalized()) <= deg_to_rad(float(_atk.get("arc_degrees", 60)) * 0.5)

	if not hit:
		return
	_atk_hit = true
	_last_attack_hit_frame = _atk_frame

	var info := DamageInfo.make(raw, self, weight)
	info.parryable = bool(_atk.get("parryable", false))
	info.is_aoe = bool(_atk.get("is_aoe", false))
	info.shield_pierce_fraction = clampf(float(_atk.get("shield_pierce_fraction", 0.0)), 0.0, 1.0)
	info.guard_stamina_multiplier = maxf(float(_atk.get("guard_stamina_multiplier", 1.0)), 1.0)
	info.attack_id = String(_atk.get("id", ""))
	if target.has_method("take_damage"):
		target.call("take_damage", info)


# --- Levar dano ---------------------------------------------------------------

func take_damage(info: DamageInfo) -> void:
	if state == State.DEAD:
		return

	health = maxf(0.0, health - info.amount)
	if health <= 0.0:
		_change_state(State.DEAD)
		collision_layer = 0
		remove_from_group("enemies")
		Sfx.play("enemy_death", global_position)
		died.emit(self)
		return

	# Postura: so cai quando o inimigo esta a agir ou de pe; o cambaleio devolve o turno.
	posture = maxf(0.0, posture - info.posture_damage * posture_mult)
	if posture <= 0.0 and state != State.BROKEN:
		Sfx.play("posture_break", global_position, -2.0)
		_change_state(State.STAGGER)


## O parry acertou: postura quebrada 2,0 s, exposto ao riposte.
func on_parried() -> void:
	if state == State.DEAD:
		return
	posture = 0.0
	_change_state(State.BROKEN)


func is_posture_broken() -> bool:
	return state == State.BROKEN or state == State.STAGGER


func is_alive() -> bool:
	return state != State.DEAD


func full_reset() -> void:
	health = max_health
	posture = max_posture
	_phase = 1
	_queue.clear()
	_atk = {}
	_gap_timer = 0.0
	_no_reach_time = 0.0
	global_position = home
	velocity = Vector3.ZERO
	collision_layer = 4
	if not is_in_group("enemies"):
		add_to_group("enemies")
	_change_state(State.PATROL if not _patrol_points.is_empty() else State.IDLE)


# --- Leitura visual -----------------------------------------------------------

func _refresh_colour() -> void:
	if _visual == null:
		return
	var key: String = "enemy_idle_default"
	var custom := String(data.get("color_idle", ""))
	var colour := Color(custom) if custom != "" else Color(String(_palette.get(key, "#8fa07a")))

	match state:
		State.DEAD:
			colour = colour.darkened(0.7)
		State.BROKEN:
			colour = Color(String(_palette.get("enemy_broken_posture", "#ffffff")))
		State.STAGGER:
			colour = Color(String(_palette.get("enemy_stagger", "#f2f2f2")))
		State.ATTACK:
			var startup := int(_atk.get("startup", 30))
			if _atk_frame <= startup:
				# Amarelo a crescer: quanto mais perto do golpe, mais forte o aviso.
				var t := clampf(float(_atk_frame) / float(maxi(startup, 1)), 0.0, 1.0)
				colour = colour.lerp(Color(String(_palette.get("enemy_telegraph", "#e8c33a"))), 0.35 + 0.65 * t)
			elif _atk_frame <= startup + int(_atk.get("active", 6)):
				colour = Color(String(_palette.get("enemy_attacking", "#d64545")))
	_visual.set_tint(colour)


func _refresh_animation() -> void:
	if _visual == null:
		return
	match state:
		State.DEAD:
			_visual.play_animation("Death01")
		State.ATTACK:
			_visual.play_animation("Sword_Attack")
		State.STAGGER, State.BROKEN:
			_visual.play_animation("Hit_Chest")
		State.CHASE:
			_visual.play_animation("Jog_Fwd")
		State.PATROL:
			_visual.play_animation("Walk")
		_:
			_visual.play_animation("Idle")


## Para o HUD: o golpe em preparacao da-se para aparar?
func telegraphing_parryable() -> int:
	if state != State.ATTACK or _atk_frame > int(_atk.get("startup", 30)):
		return -1
	return 1 if bool(_atk.get("parryable", false)) else 0


func display_name() -> String:
	return String(data.get("display_name", enemy_id))


## Provocacao do Tanque (WP3): atencao forcada no provocador. A solo acorda
## quem patrulha; em co-op sera a fixacao de alvo. Simples e legivel.
func taunt(by: Node3D, _seconds: float) -> void:
	if state == State.DEAD:
		return
	target = by
	if state == State.IDLE or state == State.PATROL:
		state = State.CHASE
