class_name LockOn
extends Node
## Engate de alvo e fronteira de mira livre.
##
## Todos os alcances e tempos vêm de data/combat.json. Este nó já é criado pelo
## Player, por isso é também a única costura disponível nesta árvore para montar
## os indicadores sem alterar hud.gd, game_shell.gd ou player.gd.

signal target_changed(new_target: Node3D)

const AIM_HUD_SCRIPT = preload("res://src/ui/aim_hud.gd")
const SPELL_HUD_SCRIPT = preload("res://src/ui/spell_hud.gd")

var target: Node3D = null

var _owner: Node3D
var _engage_range := 0.0
var _break_range := 0.0
var _los_grace := 0.0
var _no_los_time := 0.0
var _preview_target: Node3D = null

var _free_aim_point := Vector3.ZERO
var _free_aim_direction := Vector3.ZERO
var _free_aim_collider: Node = null
var _free_aim_valid := false
var _free_aim_spell_type := ""

var _mouse_flick_accumulator := 0.0
var _mouse_flick_direction := 0.0
var _visual_offsets: Dictionary = {}
var _aim_proxy: Node3D
var _transient_free_aim_target := false
var _benchmark_keep_lock := false


func _ready() -> void:
	_aim_proxy = Node3D.new()
	_aim_proxy.name = "FreeAimProxy"
	_aim_proxy.top_level = true
	add_child(_aim_proxy)
	call_deferred("_attach_local_huds")


func setup(p_owner: Node3D, cfg: Dictionary) -> void:
	_owner = p_owner
	_engage_range = float(cfg.get("engage_range", 0.0))
	_break_range = float(cfg.get("break_range", 0.0))
	_los_grace = float(cfg.get("los_grace", 0.0))
	if _engage_range <= 0.0 or _break_range < _engage_range or _los_grace <= 0.0:
		push_error("[lock-on] contrato incompleto em data/combat.json")


func _attach_local_huds() -> void:
	# O parceiro também tem LockOn, mas só o Player local recebe PlayerCamera.
	# Assim não aparecem duas interfaces em co-op nem nos testes unitários.
	if not is_instance_valid(_owner) or _owner.get("camera") == null:
		return
	var aim_hud: CanvasLayer = AIM_HUD_SCRIPT.new()
	aim_hud.name = "AimHud"
	add_child(aim_hud)
	aim_hud.call("setup", self)
	var spell_hud: CanvasLayer = SPELL_HUD_SCRIPT.new()
	spell_hud.name = "SpellHud"
	add_child(spell_hud)
	spell_hud.call("setup", _owner)
	call_deferred("_prepare_benchmark_fixture")


func _prepare_benchmark_fixture() -> void:
	var requested_enemies := 0
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--aim-bench-enemies="):
			requested_enemies = int(argument.split("=")[1])
		elif argument == "--aim-bench-lock":
			_benchmark_keep_lock = true
	if requested_enemies <= 0:
		return
	# Espera o piloto do benchmark colocar o jogador na zona de medição.
	await get_tree().process_frame
	await get_tree().process_frame
	var enemies: Array[Node] = _owner.get_tree().get_nodes_in_group("enemies")
	enemies.sort_custom(func(left: Node, right: Node) -> bool:
		return _owner.global_position.distance_squared_to((left as Node3D).global_position) \
			< _owner.global_position.distance_squared_to((right as Node3D).global_position))
	for index: int in enemies.size():
		if index < requested_enemies:
			continue
		var enemy := enemies[index]
		enemy.process_mode = Node.PROCESS_MODE_DISABLED
		if enemy is Node3D:
			(enemy as Node3D).visible = false
		if enemy is CollisionObject3D:
			(enemy as CollisionObject3D).collision_layer = 0
	print("[aim-bench] %d inimigos activos de %d" % [
		mini(requested_enemies, enemies.size()), enemies.size()])
	if _benchmark_keep_lock:
		await get_tree().physics_frame
		_set_target(_nearest_candidate())
		print("[aim-bench] lock-on activo: %s" % str(is_instance_valid(target)))


func toggle() -> void:
	if _transient_free_aim_target:
		return
	if is_instance_valid(target):
		_set_target(null)
	else:
		_set_target(_best_candidate(null))


## Troca para o alvo visível seguinte no lado pedido. Não re-engata se não houver.
func cycle(direction: float) -> void:
	if not is_instance_valid(target) or _transient_free_aim_target:
		return
	var next := _best_candidate(target, direction)
	if next != null:
		_set_target(next)


func tick(delta: float) -> void:
	_update_free_aim()
	if _transient_free_aim_target:
		return
	if not is_instance_valid(target):
		_preview_target = _best_candidate(null)
		if _benchmark_keep_lock:
			_set_target(_nearest_candidate())
		_tick_stick_cycle()
		return

	_preview_target = null
	if not _is_alive(target):
		_set_target(null)
		return

	var distance := _owner.global_position.distance_to(target.global_position)
	if distance > _break_range:
		_set_target(null)
		return

	if _has_line_of_sight(target):
		_no_los_time = 0.0
	else:
		_no_los_time += delta
		if _no_los_time >= _los_grace:
			_set_target(null)
			return
	_tick_stick_cycle()


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(_owner) or not _owner.has_method("state_name"):
		return
	var casting := String(_owner.call("state_name")) == "conjuracao"
	if not casting:
		_clear_transient_free_aim_target()
		return
	if is_instance_valid(target) and not _transient_free_aim_target:
		return

	# Enquanto conjura sem engate, o rato/stick orienta o corpo no plano do chão.
	# A entrega continua a ser consumida por Player; aqui só fornecemos a direcção.
	var planar := _free_aim_direction
	planar.y = 0.0
	if planar.length_squared() > 0.0:
		planar = planar.normalized()
		_owner.rotation.y = atan2(-planar.x, -planar.z)

	# No último frame, usa por um único tick a interface de alvo que Player já
	# consome. Áreas recebem o ponto livre exacto; projécteis recebem o inimigo
	# sob o retículo. A câmara nunca vê este alvo transitório.
	var state_frame := int(_owner.get("state_frame"))
	var total_frames := int(_owner.get("_cast_frames_total"))
	if not _free_aim_valid or total_frames <= 0 or state_frame < total_frames - 1:
		return
	if _free_aim_spell_type == "aoe":
		_aim_proxy.global_position = _free_aim_point
		target = _aim_proxy
		_transient_free_aim_target = true
	elif _free_aim_spell_type == "projectile":
		var enemy := _enemy_from_collider(_free_aim_collider)
		if enemy != null:
			target = enemy
			_transient_free_aim_target = true
	if _transient_free_aim_target:
		var player_camera: Variant = _owner.get("camera")
		if player_camera != null:
			player_camera.set("lock_target", null)


func _unhandled_input(event: InputEvent) -> void:
	if not is_instance_valid(target) or _transient_free_aim_target \
			or not (event is InputEventMouseMotion):
		return
	var motion := event as InputEventMouseMotion
	if is_zero_approx(motion.relative.x):
		return
	var direction := signf(motion.relative.x)
	if not is_zero_approx(_mouse_flick_direction) and direction != _mouse_flick_direction:
		_mouse_flick_accumulator = 0.0
	_mouse_flick_direction = direction
	_mouse_flick_accumulator += motion.relative.x
	var viewport_size := _owner.get_viewport().get_visible_rect().size
	var deadzone := InputMap.action_get_deadzone("look_right")
	var threshold := minf(viewport_size.x, viewport_size.y) * deadzone
	if absf(_mouse_flick_accumulator) >= threshold:
		cycle(signf(_mouse_flick_accumulator))
		_mouse_flick_accumulator = 0.0


func _tick_stick_cycle() -> void:
	if not is_instance_valid(target) or _transient_free_aim_target:
		return
	if Input.is_action_just_pressed("look_left"):
		cycle(-1.0)
	elif Input.is_action_just_pressed("look_right"):
		cycle(1.0)


func _clear_transient_free_aim_target() -> void:
	if not _transient_free_aim_target:
		return
	target = null
	_transient_free_aim_target = false
	var player_camera: Variant = _owner.get("camera")
	if player_camera != null:
		player_camera.set("lock_target", null)


func _set_target(next_target: Node3D) -> void:
	if target == next_target and not _transient_free_aim_target:
		return
	target = next_target
	_transient_free_aim_target = false
	_no_los_time = 0.0
	_mouse_flick_accumulator = 0.0
	target_changed.emit(next_target)


func _is_alive(node: Node) -> bool:
	if node.has_method("is_alive"):
		return bool(node.call("is_alive"))
	return true


func _best_candidate(exclude: Node3D, direction := 0.0) -> Node3D:
	if not is_instance_valid(_owner) or _engage_range <= 0.0:
		return null
	var camera := _owner.get_viewport().get_camera_3d()
	if camera == null:
		return null
	var best: Node3D = null
	var best_centredness := -INF
	var best_distance := INF

	for node: Node in _owner.get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Node3D
		if enemy == null or enemy == exclude or not enemy.visible \
				or enemy.process_mode == Node.PROCESS_MODE_DISABLED or not _is_alive(enemy):
			continue
		var to_enemy := enemy.global_position - _owner.global_position
		var distance := to_enemy.length()
		if distance > _engage_range or not _has_line_of_sight(enemy):
			continue
		var screen_direction := (_body_center(enemy) - camera.global_position).normalized()
		var centredness := screen_direction.dot(-camera.global_transform.basis.z)
		if centredness <= 0.0:
			continue
		if not is_zero_approx(direction):
			var side := camera.global_transform.basis.x.dot(to_enemy.normalized())
			if signf(side) != signf(direction):
				continue
		if centredness > best_centredness \
				or (is_equal_approx(centredness, best_centredness) and distance < best_distance):
			best = enemy
			best_centredness = centredness
			best_distance = distance
	return best


func _nearest_candidate() -> Node3D:
	var nearest: Node3D = null
	var nearest_distance := INF
	for node: Node in _owner.get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Node3D
		if enemy == null or not enemy.visible \
				or enemy.process_mode == Node.PROCESS_MODE_DISABLED or not _is_alive(enemy):
			continue
		var distance := _owner.global_position.distance_to(enemy.global_position)
		if distance <= _engage_range and distance < nearest_distance and _has_line_of_sight(enemy):
			nearest = enemy
			nearest_distance = distance
	return nearest


func _has_line_of_sight(candidate: Node3D) -> bool:
	if not is_instance_valid(_owner) or not is_inside_tree():
		return false
	var query := PhysicsRayQueryParameters3D.create(_body_center(_owner), _body_center(candidate))
	query.collision_mask = _scenario_collision_mask()
	if _owner is CollisionObject3D:
		query.exclude = [(_owner as CollisionObject3D).get_rid()]
	return _owner.get_world_3d().direct_space_state.intersect_ray(query).is_empty()


func _update_free_aim() -> void:
	_free_aim_valid = false
	_free_aim_collider = null
	_free_aim_spell_type = ""
	if not is_instance_valid(_owner):
		return
	var camera := _owner.get_viewport().get_camera_3d()
	if camera == null:
		return
	var selected_spell := String(_owner.get("selected_spell"))
	var spell := GameData.spell(selected_spell)
	_free_aim_spell_type = String(spell.get("type", ""))
	if _free_aim_spell_type not in ["projectile", "aoe"]:
		return
	var max_range := float(spell.get("max_range", spell.get("range_m", 0.0)))
	if max_range <= 0.0:
		return

	var viewport_center := _owner.get_viewport().get_visible_rect().size * 0.5
	var camera_origin := camera.project_ray_origin(viewport_center)
	var camera_direction := camera.project_ray_normal(viewport_center).normalized()
	var cast_origin := _body_center(_owner)
	var sphere_end := _ray_sphere_endpoint(camera_origin, camera_direction, cast_origin, max_range)
	var camera_hit := _raycast(camera_origin, sphere_end)

	if _free_aim_spell_type == "aoe":
		_free_aim_point = Vector3(camera_hit.get("position", sphere_end))
		_free_aim_collider = camera_hit.get("collider") as Node
		_free_aim_direction = (_free_aim_point - cast_origin).normalized()
		_free_aim_valid = true
		return

	var aimed_enemy := _enemy_from_collider(camera_hit.get("collider") as Node)
	if aimed_enemy != null:
		_free_aim_point = _body_center(aimed_enemy)
		_free_aim_direction = (_free_aim_point - cast_origin).normalized()
		_free_aim_collider = aimed_enemy
		_free_aim_valid = true
		return

	var planar := camera_direction
	planar.y = 0.0
	if planar.length_squared() <= 0.0:
		return
	planar = planar.normalized()
	var projectile_end := cast_origin + planar * max_range
	var projectile_hit := _raycast(cast_origin, projectile_end)
	_free_aim_point = Vector3(projectile_hit.get("position", projectile_end))
	_free_aim_direction = planar
	_free_aim_collider = projectile_hit.get("collider") as Node
	_free_aim_valid = true


func _ray_sphere_endpoint(ray_origin: Vector3, ray_direction: Vector3,
		centre: Vector3, radius: float) -> Vector3:
	var offset := ray_origin - centre
	var projected := offset.dot(ray_direction)
	var discriminant := projected * projected - (offset.length_squared() - radius * radius)
	if discriminant >= 0.0:
		var distance := -projected + sqrt(discriminant)
		if distance >= 0.0:
			return ray_origin + ray_direction * distance
	return centre + ray_direction * radius


func _raycast(from: Vector3, to: Vector3) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = _aim_collision_mask()
	if _owner is CollisionObject3D:
		query.exclude = [(_owner as CollisionObject3D).get_rid()]
	return _owner.get_world_3d().direct_space_state.intersect_ray(query)


func _scenario_collision_mask() -> int:
	return int((_owner as CollisionObject3D).collision_mask) \
		if _owner is CollisionObject3D else 0


func _aim_collision_mask() -> int:
	var mask := _scenario_collision_mask()
	for node: Node in _owner.get_tree().get_nodes_in_group("enemies"):
		if node is CollisionObject3D:
			mask |= int((node as CollisionObject3D).collision_layer)
	return mask


func _enemy_from_collider(collider: Node) -> Node3D:
	var current := collider
	while current != null:
		if current is Node3D and current.is_in_group("enemies") and _is_alive(current):
			return current as Node3D
		current = current.get_parent()
	return null


func _offsets_for(node: Node3D) -> Vector2:
	var key := int(node.get_instance_id())
	if _visual_offsets.has(key):
		return _visual_offsets[key] as Vector2
	var centre_y := 0.0
	var top_y := 0.0
	for child: Node in node.find_children("*", "CollisionShape3D", true, false):
		var collision := child as CollisionShape3D
		if collision == null or collision.shape == null:
			continue
		var local_centre := node.to_local(collision.global_position).y
		centre_y = local_centre
		top_y = local_centre
		if collision.shape is CapsuleShape3D:
			top_y += (collision.shape as CapsuleShape3D).height * 0.5
		elif collision.shape is BoxShape3D:
			top_y += (collision.shape as BoxShape3D).size.y * 0.5
		break
	var offsets := Vector2(centre_y, top_y)
	_visual_offsets[key] = offsets
	return offsets


func _body_center(node: Node3D) -> Vector3:
	return node.global_position + Vector3.UP * _offsets_for(node).x


func target_visual_point(node: Node3D) -> Vector3:
	return node.global_position + Vector3.UP * _offsets_for(node).y


func display_target() -> Node3D:
	return null if _transient_free_aim_target else target


func preview_target() -> Node3D:
	return _preview_target


func free_aim_visible() -> bool:
	return _free_aim_valid and not is_instance_valid(display_target())


func free_aim_point() -> Vector3:
	return _free_aim_point


func free_aim_hits_enemy() -> bool:
	return _enemy_from_collider(_free_aim_collider) != null
