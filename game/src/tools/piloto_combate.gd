class_name PilotoCombate
extends RefCounted
## Piloto unico das provas jogaveis de combate.
##
## Esta e a estrategia que nasceu na luta real do Vorgar: fixa o alvo pela accao
## remapeavel, le o telegrafo catalogado, conserva stamina defensiva, usa
## parry/esquiva/bloqueio e so ataca numa abertura real. O percurso e a arena
## partilham este mesmo fio; os detalhes espaciais SEPARAR/JUNTAR continuam a ser
## fornecidos pela arena, porque sao geometria desse encontro e nao combate geral.

var parries := 0
var dodges := 0
var blocks := 0
var consumed_frame := false
var visible_sequences: Dictionary = {}
var finished_sequences: Dictionary = {}

var _tree: SceneTree
var _arena_context: Node
var _pulsed_actions: Array[String] = []
var _oriented_target_id := 0
var _answered_attacks: Dictionary = {}
var _pending_dodge_key := ""
var _pending_dodge_direction := Vector3.ZERO
var _dodge_release_sent := false
var _active_objective := ""


func configure(tree: SceneTree, arena_context: Node = null) -> void:
	_tree = tree
	_arena_context = arena_context


func lock_on(player: Player, target: Enemy) -> bool:
	if player == null or target == null or not target.is_alive():
		return false
	if player.lock_on != null and player.lock_on.target == target:
		return true
	if player.lock_on != null and player.lock_on.target != null:
		Input.action_press("lock_on")
		await _tree.physics_frame
		Input.action_release("lock_on")
		await _tree.physics_frame
	Input.action_press("lock_on")
	await _tree.physics_frame
	Input.action_release("lock_on")
	await _tree.physics_frame
	return player.lock_on != null and player.lock_on.target == target


func drive_frame(player: Player, primary_target: Enemy, allow_attack: bool = true) -> void:
	consumed_frame = false
	if not _pending_dodge_key.is_empty() and player.state == Player.State.DODGE:
		_answered_attacks[_pending_dodge_key] = true
		_pending_dodge_key = ""
		_pending_dodge_direction = Vector3.ZERO
		_dodge_release_sent = false
	release_pulses()
	Input.action_release("block")
	_clear_movement()

	var objective := _arena_objective()
	if not objective.is_empty():
		# A pergunta espacial substitui qualquer toque defensivo anterior: ficar a
		# espera de uma esquiva cancelada fazia o jogador ignorar a zona JUNTAR.
		_pending_dodge_key = ""
		_pending_dodge_direction = Vector3.ZERO
		_dodge_release_sent = false
		if objective != _active_objective:
			print("[vorgar-prova] fase espacial iniciou: %s" % objective.to_upper())
		_active_objective = objective
		if _arena_sequence_is_visible():
			visible_sequences[objective] = true
		_arena_drive_sequence(player, objective)
		_oriented_target_id = 0
		consumed_frame = true
		return
	if not _active_objective.is_empty():
		if bool(visible_sequences.get(_active_objective, false)):
			finished_sequences[_active_objective] = true
			print("[vorgar-prova] fase espacial completou: %s" \
				% _active_objective.to_upper())
		_active_objective = ""

	# O toque de esquiva precisa de um frame em que a accao esteja largada.
	# Recarregar aqui transforma o toque num sprint e deixa entrar a investida.
	if not _pending_dodge_key.is_empty():
		if not _dodge_release_sent:
			_dodge_release_sent = true
			set_movement(player, _pending_dodge_direction, false)
			consumed_frame = true
			return
		_pending_dodge_key = ""
		_pending_dodge_direction = Vector3.ZERO
		_dodge_release_sent = false

	var waiting_for_sequence := _arena_waiting_for_sequence(primary_target)
	var threat := _next_threat()
	var should_heal := _should_heal(player)
	if player.state == Player.State.USING_ITEM:
		set_movement(player, _direction_away_from_enemies(player), false)
		_oriented_target_id = 0
		consumed_frame = true
		return
	if should_heal and player.state == Player.State.FREE:
		var flask_frames := ceili(float(GameData.section("flask").get("use_seconds")) \
			* float(GameData.combat.get("reference_fps")))
		if threat.is_empty() or int(threat.get("frames_until_active")) > flask_frames:
			set_movement(player, _direction_away_from_enemies(player), false)
			pulse("use_item")
			_oriented_target_id = 0
			consumed_frame = true
			return
	if not threat.is_empty():
		var threat_enemy := threat.get("enemy") as Enemy
		var frames_until_active := int(threat.get("frames_until_active"))
		var dodge := GameData.section("dodge")
		var parry := GameData.section("parry")
		# A esquiva nasce de um toque: um tick para carregar e outro para largar.
		# A janela invulneravel so abre depois desses dois flancos de entrada.
		var input_edge_frames := maxi(1, ceili(float(Engine.physics_ticks_per_second) \
			/ float(GameData.combat.get("reference_fps"))))
		var dodge_input_lead := int(dodge.get("iframe_start_frame")) \
			+ input_edge_frames * 2
		var parry_input_lead := int(parry.get("startup_frames")) + input_edge_frames
		var attack_key := String(threat.get("key"))
		var away := player.global_position - threat_enemy.global_position
		away.y = 0.0
		var lateral := Vector3(-away.z, 0.0, away.x).normalized()
		var threat_attack := threat.get("attack") as Dictionary
		var escape := _escape_direction(player, threat_enemy, threat_attack)
		var escape_vectors := threat_attack.get("vectores_fuga", []) as Array
		var escape_needs_sprint := escape_vectors.has("afastar_se") \
			or escape_vectors.has("sair_da_area") or escape_vectors.has("rolar_para_fora")
		var attack_commitment := _player_attack_commitment_frames(player)
		if should_heal or frames_until_active <= attack_commitment:
			var lethal_now := player.health <= _largest_incoming_damage(player)
			if bool(threat.get("parryable", false)) and lethal_now:
				set_movement(player,
					(threat_enemy.global_position - player.global_position).normalized(), false)
				Input.action_press("block")
				if not bool(_answered_attacks.get(attack_key, false)):
					blocks += 1
					_answered_attacks[attack_key] = true
			elif bool(threat.get("parryable", false)) \
					and frames_until_active <= parry_input_lead \
					and not bool(_answered_attacks.get(attack_key, false)):
				set_movement(player,
					(threat_enemy.global_position - player.global_position).normalized(), false)
				pulse("parry")
				parries += 1
				_answered_attacks[attack_key] = true
			elif frames_until_active <= dodge_input_lead \
					and not bool(_answered_attacks.get(attack_key, false)):
				set_movement(player, escape, false)
				pulse("dodge_sprint")
				if _pending_dodge_key != attack_key:
					dodges += 1
				_pending_dodge_key = attack_key
				_pending_dodge_direction = escape
				_dodge_release_sent = false
			else:
				set_movement(player, escape if not escape.is_zero_approx() \
					else lateral, escape_needs_sprint)
			_oriented_target_id = 0
			consumed_frame = true
			return
	if player.state != Player.State.FREE or not player.stamina.can_act():
		_set_sprint(false)
		consumed_frame = true
		return
	if waiting_for_sequence:
		_set_sprint(false)
		_oriented_target_id = 0
		consumed_frame = true
		return
	if not allow_attack:
		return
	if not _attack_window_open(player, primary_target):
		_set_sprint(false)
		_oriented_target_id = 0
		return

	var target := _attack_target(player, primary_target)
	if target == null:
		_set_sprint(false)
		return
	var weapon := GameData.weapon(player.main_weapon)
	var light := weapon.get("light", {}) as Dictionary
	var defensive_reserve := maxf(float(GameData.section("dodge").get("stamina_cost")),
		float(GameData.section("parry").get("stamina_cost")))
	if player.stamina.current < float(light.get("stamina")) + defensive_reserve:
		var recover_away := player.global_position - primary_target.global_position
		recover_away.y = 0.0
		set_movement(player, recover_away.normalized(), false)
		_oriented_target_id = 0
		consumed_frame = true
		return
	var reach := float(weapon.get("range"))
	var to_target := target.global_position - player.global_position
	to_target.y = 0.0
	if to_target.length() > reach:
		set_movement(player, to_target.normalized(), false)
		_oriented_target_id = 0
		consumed_frame = true
		return
	if _oriented_target_id != target.get_instance_id():
		set_movement(player, to_target.normalized(), false)
		_oriented_target_id = target.get_instance_id()
		consumed_frame = true
		return
	pulse("attack")
	_oriented_target_id = 0
	consumed_frame = true


func expected_light_hits(player: Player, enemy: Enemy) -> int:
	var weapon := GameData.weapon(player.main_weapon)
	var light := weapon.get("light", {}) as Dictionary
	var damage := GameData.compute_damage(float(light.get("mv")), player.main_weapon,
		player.attrs, enemy.defense)
	return ceili(enemy.health / maxf(damage, 1.0))


func frame_budget(player: Player, enemy: Enemy, expected_hits: int) -> int:
	var longest_enemy_cycle := 0
	var all_enemy_cycles := 0
	var attack_count := 0
	for attack_value: Variant in enemy.data.get("attacks", []):
		var attack := attack_value as Dictionary
		var cycle := int(attack.get("startup")) + int(attack.get("active")) \
			+ int(attack.get("recovery"))
		longest_enemy_cycle = maxi(longest_enemy_cycle, cycle)
		all_enemy_cycles += cycle
		attack_count += 1
	for sequence: Dictionary in _arena_additional_cycles():
		longest_enemy_cycle = maxi(longest_enemy_cycle, int(sequence.get("startup")) \
			+ int(sequence.get("active")) + int(sequence.get("recovery")))
	var weapon := GameData.weapon(player.main_weapon)
	var light := weapon.get("light", {}) as Dictionary
	var player_cycle := int(light.get("startup")) + int(light.get("active")) \
		+ int(light.get("recovery"))
	var longest_gap_frames := ceili(float(enemy.data.get("gap_between_patterns", 0.0)) \
		* float(GameData.combat.get("reference_fps")))
	for phase_value: Variant in (enemy.data.get("phases", {}) as Dictionary).values():
		var phase := phase_value as Dictionary
		longest_gap_frames = maxi(longest_gap_frames, ceili(
			float(phase.get("gap_between_patterns")) \
			* float(GameData.combat.get("reference_fps"))))
	var phase_count := maxi(1, (enemy.data.get("phases", {}) as Dictionary).size())
	if not enemy.is_boss:
		# Cada carta curta pode deslocar o alvo antes da abertura seguinte. A margem
		# vem da variedade e da soma dos ciclos que o proprio catalogo declara.
		return maxi(1, expected_hits) * (maxi(1, attack_count) + 1) * maxi(1,
			all_enemy_cycles + player_cycle + longest_gap_frames)
	return maxi(1, expected_hits) * maxi(1,
		longest_enemy_cycle + player_cycle + longest_gap_frames) * phase_count


func reset_attempt() -> void:
	release_all_inputs()
	_answered_attacks.clear()
	_pending_dodge_key = ""
	_pending_dodge_direction = Vector3.ZERO
	_dodge_release_sent = false
	_oriented_target_id = 0


func set_movement(player: Player, world_direction: Vector3, sprint: bool) -> void:
	_clear_movement()
	_set_sprint(sprint)
	if world_direction.is_zero_approx() or player.camera == null:
		return
	var direction := world_direction.normalized()
	var right := player.camera.right_flat()
	var forward := player.camera.forward_flat()
	var axis_x := clampf(direction.dot(right), -1.0, 1.0)
	var axis_y := clampf(-direction.dot(forward), -1.0, 1.0)
	if axis_x < 0.0:
		Input.action_press("move_left", -axis_x)
	elif axis_x > 0.0:
		Input.action_press("move_right", axis_x)
	if axis_y < 0.0:
		Input.action_press("move_forward", -axis_y)
	elif axis_y > 0.0:
		Input.action_press("move_back", axis_y)


func pulse(action: String) -> void:
	Input.action_press(action)
	if not _pulsed_actions.has(action):
		_pulsed_actions.append(action)


func release_pulses() -> void:
	for action: String in _pulsed_actions:
		Input.action_release(action)
	_pulsed_actions.clear()


func release_all_inputs() -> void:
	release_pulses()
	for action_value: Variant in (GameData.controls.get("actions", {}) as Dictionary).keys():
		var action := String(action_value)
		if InputMap.has_action(action):
			Input.action_release(action)


func _player_attack_commitment_frames(player: Player) -> int:
	var weapon := GameData.weapon(player.main_weapon)
	var light := weapon.get("light", {}) as Dictionary
	var rules := GameData.section("attack_rules")
	return int(light.get("startup")) + int(light.get("active")) + ceili(
		float(light.get("recovery")) * float(rules.get("cancel_threshold_fraction_of_recovery")))


func _attack_window_open(player: Player, enemy: Enemy) -> bool:
	if enemy.state == Enemy.State.BROKEN:
		return true
	# Um inimigo comum regressa a CHASE durante o intervalo catalogado entre
	# padroes. Essa e a abertura visivel que o jogador usa para responder. Vorgar
	# conserva a regra mais estrita de atacar apenas na recuperacao longa.
	if not enemy.is_boss and enemy.state != Enemy.State.ATTACK:
		return true
	if enemy.state != Enemy.State.ATTACK:
		return false
	var attack := enemy.get("_atk") as Dictionary
	if attack.is_empty() or not String(attack.get("objectivo_coop", "")).is_empty():
		return false
	var attack_frame := int(enemy.get("_atk_frame"))
	var active_end := int(attack.get("startup")) + int(attack.get("active"))
	var remaining_recovery := active_end + int(attack.get("recovery")) - attack_frame
	var light := GameData.weapon(player.main_weapon).get("light", {}) as Dictionary
	var frames_until_player_hit := int(light.get("startup")) + int(light.get("active"))
	return attack_frame > active_end and remaining_recovery >= frames_until_player_hit


func _direction_away_from_enemies(player: Player) -> Vector3:
	var away := Vector3.ZERO
	for node: Node in _tree.get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null or not enemy.is_alive():
			continue
		var delta := player.global_position - enemy.global_position
		delta.y = 0.0
		if not delta.is_zero_approx():
			away += delta.normalized()
	return away.normalized()


func _escape_direction(player: Player, enemy: Enemy, attack: Dictionary) -> Vector3:
	var vectors := attack.get("vectores_fuga", []) as Array
	var away := player.global_position - enemy.global_position
	away.y = 0.0
	if vectors.has("afastar_se") or vectors.has("sair_da_area") \
			or vectors.has("rolar_para_fora"):
		var best_goal := player.global_position + away.normalized()
		var best_distance := best_goal.distance_to(enemy.global_position)
		for candidate: Vector3 in _arena_escape_goals():
			var distance := candidate.distance_to(enemy.global_position)
			if distance > best_distance:
				best_goal = candidate
				best_distance = distance
		var toward_goal := best_goal - player.global_position
		toward_goal.y = 0.0
		return toward_goal.normalized()
	if vectors.has("rolar_para_dentro") or vectors.has("aproximar_se"):
		return -away.normalized()
	return Vector3(-away.z, 0.0, away.x).normalized()


func _attack_target(player: Player, primary_target: Enemy) -> Enemy:
	if not primary_target.is_boss:
		return primary_target
	var closest_common: Enemy
	var closest_distance := INF
	for node: Node in _tree.get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null or enemy == primary_target or enemy.is_boss or not enemy.is_alive():
			continue
		var distance := player.global_position.distance_to(enemy.global_position)
		if distance < closest_distance:
			closest_common = enemy
			closest_distance = distance
	return closest_common if closest_common != null else primary_target


func _next_threat() -> Dictionary:
	var chosen: Dictionary = {}
	var fewest_frames := INF
	for node: Node in _tree.get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null or not enemy.is_alive() or enemy.telegraphing_parryable() < 0:
			continue
		var attack := enemy.get("_atk") as Dictionary
		if attack.is_empty():
			continue
		var attack_frame := int(enemy.get("_atk_frame"))
		var frames_until_active := int(attack.get("startup")) - attack_frame
		if frames_until_active >= fewest_frames:
			continue
		fewest_frames = frames_until_active
		var attack_start_frame := Engine.get_physics_frames() - attack_frame
		chosen = {
			"enemy": enemy,
			"attack": attack,
			"frames_until_active": frames_until_active,
			"parryable": enemy.telegraphing_parryable() == 1,
			"key": "%d:%s:%d" % [enemy.get_instance_id(),
				String(attack.get("id")), attack_start_frame],
		}
	return chosen


func _should_heal(player: Player) -> bool:
	if player.flask_uses <= 0 or player.health >= player.max_health:
		return false
	var largest_incoming := _largest_incoming_damage(player)
	return largest_incoming > 0.0 and player.health <= player.max_health - largest_incoming


func _largest_incoming_damage(player: Player) -> float:
	var largest_incoming := 0.0
	for node: Node in _tree.get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy == null or not enemy.is_alive():
			continue
		for attack_value: Variant in enemy.data.get("attacks", []):
			var attack := attack_value as Dictionary
			largest_incoming = maxf(largest_incoming,
				GameData.apply_defense(float(attack.get("damage")), player.defense))
	return largest_incoming


func _clear_movement() -> void:
	for action: String in ["move_left", "move_right", "move_forward", "move_back"]:
		Input.action_release(action)


func _set_sprint(sprint: bool) -> void:
	if sprint:
		if not Input.is_action_pressed("dodge_sprint"):
			Input.action_press("dodge_sprint")
	else:
		Input.action_release("dodge_sprint")


func _arena_objective() -> String:
	if is_instance_valid(_arena_context) \
			and _arena_context.has_method("piloto_objectivo_activo"):
		return String(_arena_context.call("piloto_objectivo_activo"))
	return ""


func _arena_sequence_is_visible() -> bool:
	return is_instance_valid(_arena_context) \
		and _arena_context.has_method("piloto_sequencia_visivel") \
		and bool(_arena_context.call("piloto_sequencia_visivel"))


func _arena_drive_sequence(player: Player, objective: String) -> void:
	if is_instance_valid(_arena_context) \
			and _arena_context.has_method("piloto_conduzir_sequencia"):
		_arena_context.call("piloto_conduzir_sequencia", player, objective)


func _arena_waiting_for_sequence(enemy: Enemy) -> bool:
	return is_instance_valid(_arena_context) \
		and _arena_context.has_method("piloto_espera_sequencia") \
		and bool(_arena_context.call("piloto_espera_sequencia", enemy))


func _arena_escape_goals() -> Array[Vector3]:
	if is_instance_valid(_arena_context) \
			and _arena_context.has_method("piloto_destinos_de_fuga"):
		return _arena_context.call("piloto_destinos_de_fuga") as Array[Vector3]
	return []


func _arena_additional_cycles() -> Array[Dictionary]:
	if is_instance_valid(_arena_context) \
			and _arena_context.has_method("piloto_ciclos_adicionais"):
		return _arena_context.call("piloto_ciclos_adicionais") as Array[Dictionary]
	return []
