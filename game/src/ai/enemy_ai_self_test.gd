extends SceneTree
## Provas deterministas da inteligencia inimiga. Corre sem cena nem renderer:
##   godot --headless --path game/ --script res://src/ai/enemy_ai_self_test.gd

const Perception = preload("res://src/ai/enemy_perception.gd")
const CombatBrain = preload("res://src/ai/enemy_combat_brain.gd")
const AttackCoordinator = preload("res://src/ai/enemy_attack_coordinator.gd")
const CrowdSteering = preload("res://src/ai/enemy_crowd_steering.gd")

var _passed := 0
var _failed := 0


func _init() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_vision_and_hearing_use_the_data_contract()
	_test_alert_and_call_are_visible_before_combat()
	_test_desist_return_heal_and_damage_reacquisition()
	_test_call_only_reaches_eligible_allies_in_range()
	_test_combat_reads_visible_commitment_not_input()
	_test_tactical_movement_approaches_orbits_and_withdraws()
	await _test_group_interval_starts_when_player_can_act()
	print("[enemy-ai-test] %d passaram; %d falharam" % [_passed, _failed])
	quit(0 if _failed == 0 else 1)


func _test_vision_and_hearing_use_the_data_contract() -> void:
	var perception := _perception_config()
	var origin := Vector3.ZERO
	var forward := Vector3.FORWARD
	var vision_range := float(perception.get("vision_range_m"))
	_check(Perception.can_see(origin, forward, forward * vision_range, true, perception),
		"percepcao: alvo no cone e no limite e visto")
	_check(not Perception.can_see(origin, forward, -forward * vision_range, true, perception),
		"percepcao: alvo atras nao e visto")
	_check(not Perception.can_see(origin, forward, forward * vision_range, false, perception),
		"percepcao: obstaculo bloqueia a visao")

	var normal_range := float(perception.get("hearing_range_m"))
	var combat_range := float(perception.get("combat_sound_range_m"))
	_check(Perception.can_hear(normal_range, false, perception),
		"percepcao: som normal no limite e ouvido")
	_check(not Perception.can_hear(combat_range, false, perception),
		"percepcao: som normal nao herda alcance de combate")
	_check(Perception.can_hear(combat_range, true, perception),
		"percepcao: som de combate usa o alcance proprio")


func _test_alert_and_call_are_visible_before_combat() -> void:
	var config := _perception_config()
	var brain := Perception.new()
	brain.reset(Vector3.ZERO)
	var context := {
		"observer_position": Vector3.ZERO,
		"observer_forward": Vector3.FORWARD,
		"target_position": Vector3.FORWARD * float(config.get("vision_range_m")),
		"has_line_of_sight": true,
	}
	var decision: Dictionary = brain.tick(0.0, context, config)
	_check(String(decision.get("state")) == "alert"
		and String(decision.get("readable_cue")) == "alert_posture"
		and float(decision.get("advance_limit_m")) == float(config.get("alert_advance_m")),
		"percepcao: detectar mostra alerta e limita o avanco")

	decision = brain.tick(float(config.get("alert_delay_s")), context, config)
	_check(String(decision.get("state")) == "calling"
		and String(decision.get("readable_cue")) == "call_shout"
		and bool(decision.get("vulnerable", false)),
		"percepcao: chamada e visivel e vulneravel")

	decision = brain.tick(float(config.get("call_delay_s")), context, config)
	_check(String(decision.get("state")) == "combat"
		and bool(decision.get("emit_call", false))
		and float(decision.get("call_radius_m")) == float(config.get("call_radius_m")),
		"percepcao: combate so comeca depois da chamada declarada")


func _test_desist_return_heal_and_damage_reacquisition() -> void:
	var config := _perception_config()
	var brain := _brain_in_combat(config)
	var away := Vector3.RIGHT * float(config.get("desist_home_distance_m"))
	var hidden := {
		"observer_position": away,
		"observer_forward": Vector3.FORWARD,
		"target_position": away + Vector3.FORWARD,
		"has_line_of_sight": false,
	}
	var decision: Dictionary = brain.tick(float(config.get("desist_after_s")), hidden, config)
	_check(String(decision.get("state")) == "returning"
		and String(decision.get("movement_action")) == "return_home"
		and String(decision.get("speed_policy")) == String(config.get("return_speed_policy")),
		"percepcao: perder o alvo inicia regresso legivel")

	var damaged := hidden.duplicate()
	damaged["damaged"] = true
	decision = brain.tick(0.0, damaged, config)
	_check(String(decision.get("state")) == "combat"
		and String(decision.get("readable_cue")) == "hurt_turn"
		and bool(decision.get("reacquired", false)),
		"percepcao: dano durante regresso readquire o alvo")

	decision = brain.tick(float(config.get("desist_after_s")), hidden, config)
	var at_home := hidden.duplicate()
	at_home["observer_position"] = Vector3.RIGHT * float(config.get("return_arrival_radius_m"))
	decision = brain.tick(0.0, at_home, config)
	_check(String(decision.get("state")) == "healing"
		and String(decision.get("readable_cue")) == "home_heal_pulse"
		and not bool(decision.get("perception_open", true)),
		"percepcao: chegada fecha percepcao durante o pulso de cura")

	decision = brain.tick(float(config.get("return_heal_pulse_s")), at_home, config)
	_check(String(decision.get("state")) == "patrol"
		and float(decision.get("heal_fraction", 0.0)) == float(config.get("return_heal_fraction"))
		and bool(decision.get("perception_open", false)),
		"percepcao: cura total acontece no fim do pulso e reabre percepcao")


func _brain_in_combat(config: Dictionary) -> RefCounted:
	var brain := Perception.new()
	brain.reset(Vector3.ZERO)
	var seen := {
		"observer_position": Vector3.ZERO,
		"observer_forward": Vector3.FORWARD,
		"target_position": Vector3.FORWARD * float(config.get("vision_range_m")),
		"has_line_of_sight": true,
	}
	brain.tick(0.0, seen, config)
	brain.tick(float(config.get("alert_delay_s")), seen, config)
	brain.tick(float(config.get("call_delay_s")), seen, config)
	return brain


func _test_call_only_reaches_eligible_allies_in_range() -> void:
	var config := _perception_config()
	var radius := float(config.get("call_radius_m"))
	var allies := [
		{"id": "inside", "position": Vector3.FORWARD * radius, "can_receive_alert": true},
		{"id": "outside", "position": Vector3.FORWARD * radius * 2.0, "can_receive_alert": true},
		{"id": "busy", "position": Vector3.RIGHT * radius, "can_receive_alert": false},
	]
	var recipients := Perception.call_recipients(Vector3.ZERO, allies, config)
	_check(recipients.size() == 1 and String((recipients[0] as Dictionary).get("id")) == "inside",
		"percepcao: chamada acorda so aliados elegiveis dentro do raio")


func _test_combat_reads_visible_commitment_not_input() -> void:
	var spearman := _enemy_data("orc_spearman")
	var behavior: Dictionary = spearman.get(
		"combat_behavior", {}) as Dictionary
	var recent_neutral := {
		"distance_to_target_m": float(spearman.get("preferred_distance")),
		"has_line_of_sight": true,
		"player_visible_state": "FREE",
		"seconds_since_last_attack": 0.0,
		"attack_slot_available": true,
		"input_action": "attack",
	}
	var decision: Dictionary = CombatBrain.decide(recent_neutral, spearman, behavior)
	_check(String(decision.get("action")) == "orbit",
		"combate: input invisivel nao dispara ataque; inimigo orbita")

	var committed := recent_neutral.duplicate()
	committed["player_visible_state"] = "ataque"
	committed.erase("input_action")
	decision = CombatBrain.decide(committed, spearman, behavior)
	_check(String(decision.get("action")) == "request_attack"
		and String(decision.get("reason")) == "visible_commitment",
		"combate: animacao comprometida abre ataque oportunista")

	var drinking := recent_neutral.duplicate()
	drinking["player_visible_state"] = "a beber"
	drinking["player_state_elapsed_frames"] = int(((spearman.get("attacks", []) as Array)[3]
		as Dictionary).get("heal_punish", {}).get("reaction_latency_frames"))
	drinking.erase("input_action")
	decision = CombatBrain.decide(drinking, spearman, behavior)
	_check(String(decision.get("action")) == "request_attack"
		and String(decision.get("attack_id")) == "closing_lunge"
		and String(decision.get("reason")) == "visible_item_punish",
		"combate: ficha com castigo reage a USING_ITEM visivel apos a latencia")

	var brute := _enemy_data("orc_brute")
	drinking["distance_to_target_m"] = float(brute.get("preferred_distance"))
	decision = CombatBrain.decide(drinking, brute,
		brute.get("combat_behavior", {}) as Dictionary)
	_check(String(decision.get("action")) == "withdraw",
		"combate: sem castigo declarado, inimigo recua quando o jogador bebe")


func _test_tactical_movement_approaches_orbits_and_withdraws() -> void:
	var enemy := _enemy_data("orc_spearman")
	var target_position := Vector3.ZERO
	var actor_position := Vector3.BACK * float(enemy.get("preferred_distance"))
	var towards_target := (target_position - actor_position).normalized()
	var approach := CrowdSteering.tactical_velocity(actor_position, target_position,
		Vector3.ZERO, "approach", enemy, true)
	_check(approach.dot(towards_target) > 0.0
		and is_equal_approx(approach.length(), float(enemy.get("chase_speed"))),
		"movimento: aproximacao usa a velocidade de perseguicao dos dados")

	var clockwise := CrowdSteering.tactical_velocity(actor_position, target_position,
		Vector3.ZERO, "orbit", enemy, true)
	var counter_clockwise := CrowdSteering.tactical_velocity(actor_position, target_position,
		Vector3.ZERO, "orbit", enemy, false)
	_check(is_zero_approx(clockwise.dot(towards_target))
		and is_equal_approx(clockwise.length(), float(enemy.get("strafe_speed")))
		and clockwise.is_equal_approx(-counter_clockwise),
		"movimento: orbita e lateral, alterna lado e usa strafe_speed")

	var withdraw := CrowdSteering.tactical_velocity(actor_position, target_position,
		Vector3.ZERO, "withdraw", enemy, true)
	_check(withdraw.dot(towards_target) < 0.0,
		"movimento: recuo afasta-se do jogador em vez de parar")


func _test_group_interval_starts_when_player_can_act() -> void:
	var coordination: Dictionary = _enemy_data("orc_spearman").get(
		"attack_coordination", {}) as Dictionary
	var reference_fps := _reference_fps()
	var gap_frames := ceili(float(coordination.get("post_action_gap_s")) * reference_fps)
	var target := Node.new()
	var other_target := Node.new()
	var attackers: Array[Node] = []
	get_root().add_child(target)
	get_root().add_child(other_target)
	var maximum_intents := int(coordination.get("maximum_attack_intents"))
	for index: int in maximum_intents + 1:
		var attacker := Node.new()
		get_root().add_child(attacker)
		attackers.append(attacker)

	AttackCoordinator.forget_target(target)
	AttackCoordinator.update_target_actionability(target, false, coordination, reference_fps)
	_check(not AttackCoordinator.can_enter_active(target, attackers[0], gap_frames),
		"grupo: nenhum golpe activo enquanto o jogador nao pode agir")
	await physics_frame
	AttackCoordinator.update_target_actionability(target, true, coordination, reference_fps)
	_check(not AttackCoordinator.can_enter_active(target, attackers[0], gap_frames),
		"grupo: intervalo nao comeca antes de o jogador poder agir")
	for _frame: int in maxi(gap_frames - 1, 0):
		await physics_frame
	_check(not AttackCoordinator.can_enter_active(target, attackers[0], gap_frames),
		"grupo: segundo atacante espera os 0,20 s completos")
	await physics_frame
	_check(AttackCoordinator.can_enter_active(target, attackers[0], gap_frames),
		"grupo: janela abre exactamente depois do intervalo pos-accao")
	_check(not AttackCoordinator.can_enter_active(target, attackers[1], gap_frames),
		"grupo: dois inimigos nao entram activos no mesmo frame")
	_check(AttackCoordinator.can_enter_active(other_target, attackers[1], gap_frames),
		"grupo: coordenacao e independente por jogador alvo")

	AttackCoordinator.forget_target(target)
	var target_position := Vector3.ZERO
	var reserved := 0
	for index: int in attackers.size():
		var angle := TAU * float(index) / float(attackers.size())
		var attacker_position := Vector3.FORWARD.rotated(Vector3.UP, angle)
		if AttackCoordinator.request_attack_intent(target, attackers[index], target_position,
				attacker_position, coordination):
			reserved += 1
	_check(reserved == maximum_intents,
		"grupo: nem todos atacam; so as vagas declaradas sao reservadas")

	var open_threats := [Vector3.FORWARD, Vector3.FORWARD.rotated(Vector3.UP, TAU / 3.0),
		Vector3.FORWARD.rotated(Vector3.UP, TAU * 2.0 / 3.0)]
	var closed_threats := [Vector3.FORWARD, Vector3.RIGHT, Vector3.BACK, Vector3.LEFT]
	_check(AttackCoordinator.has_escape_route(target_position, open_threats, coordination),
		"grupo: pressao com abertura conserva rota de fuga")
	_check(not AttackCoordinator.has_escape_route(target_position, closed_threats, coordination),
		"grupo: cerco sem abertura e rejeitado")
	AttackCoordinator.forget_target(target)
	_check(not AttackCoordinator.request_attack_intent(target, attackers[0], target_position,
		Vector3.FORWARD, coordination, closed_threats),
		"grupo: reserva considera todos os corpos que pressionam a fuga")

	AttackCoordinator.forget_target(target)
	AttackCoordinator.forget_target(other_target)
	target.free()
	other_target.free()
	for attacker: Node in attackers:
		attacker.free()


func _reference_fps() -> float:
	var parsed: Variant = JSON.parse_string(
		FileAccess.get_file_as_string("res://data/combat.json"))
	return float((parsed as Dictionary).get("reference_fps")) if (
		typeof(parsed) == TYPE_DICTIONARY) else 0.0


func _perception_config() -> Dictionary:
	var parsed: Variant = _enemies_data()
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("[enemy-ai-test] enemies.json invalido")
		return {}
	return (((parsed as Dictionary).get("_enemy_defaults", {}) as Dictionary)
		.get("perception", {}) as Dictionary)


func _enemy_data(enemy_id: String) -> Dictionary:
	var catalogue := _enemies_data()
	var result: Dictionary = (catalogue.get("_enemy_defaults", {}) as Dictionary).duplicate(true)
	result.merge(catalogue.get(enemy_id, {}) as Dictionary, true)
	return result


func _enemies_data() -> Dictionary:
	var parsed: Variant = JSON.parse_string(
		FileAccess.get_file_as_string("res://data/enemies.json"))
	return parsed as Dictionary if typeof(parsed) == TYPE_DICTIONARY else {}


func _check(condition: bool, label: String) -> void:
	if condition:
		_passed += 1
		print("  OK  " + label)
	else:
		_failed += 1
		push_error("  FALHA  " + label)
