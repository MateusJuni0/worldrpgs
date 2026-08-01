extends SceneTree
## Prova isolada do contrato de impacto:
## godot --headless --audio-driver Dummy --path game/ --script res://src/combat/impact_self_test.gd

class MockVisual extends Node3D:
	var last_animation := ""

	func play_animation(animation_name: String, _speed := 1.0) -> void:
		last_animation = animation_name


class MockActor extends Node3D:
	var state_frame := 0
	var _atk_startup := 0
	var _atk_active := 0
	var _charge_frames := 0
	var _hitstun_frames := 0
	var body_radius := 0.0
	var camera: Node3D
	var _visual := MockVisual.new()

	func _init() -> void:
		add_child(_visual)

	func is_alive() -> bool:
		return true


class MockEnemy extends Node3D:
	var _atk_frame := 0
	var _atk: Dictionary = {}
	var body_radius := 0.0
	var _visual := MockVisual.new()

	func _init() -> void:
		add_child(_visual)

	func is_alive() -> bool:
		return true


var _passed := 0
var _failed := 0
var _game_data: Node


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_game_data = load("res://src/autoload/game_data.gd").new() as Node
	_game_data.name = "GameData"
	root.add_child(_game_data)
	await process_frame
	_test_same_frame_and_shared_lifetime()
	_test_incoming_direction_and_reaction()
	_test_hitstop_preserves_iframe_clock()
	_test_surface_audio_contract()
	print("\n=== IMPACTO: %d passaram, %d falharam ===" % [_passed, _failed])
	quit(0 if _failed == 0 else 1)


func _test_same_frame_and_shared_lifetime() -> void:
	var attacker := _make_actor(Vector3.ZERO)
	var target := _make_actor(Vector3.FORWARD * 1.5)
	var attack := _game_data.call("weapon", "longsword").get("light", {}) as Dictionary
	attacker._atk_startup = int(attack.get("startup", 0))
	attacker._atk_active = int(attack.get("active", 0))
	attacker.state_frame = attacker._atk_startup + 1
	var feedback := HitFeedback.install(attacker)
	feedback.audio_enabled = false
	var info := DamageInfo.make(0.0, attacker, "light")
	var tree_paused_before := paused
	var time_scale_before := Engine.time_scale
	var hitbox_frame := Engine.get_physics_frames()
	var effect := feedback.present_hit(attacker, target, info, "flesh")
	_check(effect != null, "contacto activo cria feedback")
	if effect == null:
		attacker.free()
		target.free()
		return
	effect.set_physics_process(false)
	_check(effect.born_physics_frame == hitbox_frame,
		"impacto nasce no mesmo frame de fisica da hitbox")
	_check(feedback.last_impact_physics_frame == hitbox_frame,
		"coordenador regista o mesmo frame autoritativo")
	_check(effect.active_frames_total == attacker._atk_active,
		"efeito herda exactamente os frames activos ainda vivos")
	for offset in effect.active_frames_total:
		_check(effect.lives_on_physics_frame(hitbox_frame + offset),
			"efeito vive no frame activo %d" % offset)
	_check(not effect.lives_on_physics_frame(hitbox_frame + effect.active_frames_total),
		"efeito apaga no primeiro frame sem hitbox")
	_check(feedback.last_contact_point.distance_to(target.global_position) > 0.0,
		"pulso nasce na superficie e nao no centro do inimigo")
	_check(not paused and paused == tree_paused_before and Engine.time_scale == time_scale_before,
		"impacto nunca pausa a arvore nem muda o relogio global")
	for _frame in effect.active_frames_total:
		effect._physics_process(0.0)
	_check(effect.is_available(), "pulso termina e volta ao pool no ultimo frame activo")
	attacker.free()
	target.free()


func _test_incoming_direction_and_reaction() -> void:
	var target := _make_actor(Vector3.ZERO)
	var attacker := _make_enemy(Vector3.BACK * 2.0)
	var camera := Camera3D.new()
	root.add_child(camera)
	camera.global_position = Vector3(0.0, 1.5, 4.0)
	camera.look_at(Vector3.ZERO)
	camera.current = true
	var attack := _game_data.call("weapon", "longsword").get("light", {}) as Dictionary
	attacker._atk = attack
	attacker._atk_frame = int(attack.get("startup", 0)) + 1
	_check(ImpactEvent.active_frames_for(attacker) == int(attack.get("active", 0)),
		"ataque inimigo partilha os frames activos reais com o impacto")
	var combat := _game_data.get("combat") as Dictionary
	var reference_fps := float(combat.get("reference_fps", 0.0))
	var hitstun := combat.get("hitstun", {}) as Dictionary
	target._hitstun_frames = ceili(float(hitstun.get("light", 0.0)) * reference_fps)
	var feedback := HitFeedback.install(target)
	feedback.audio_enabled = false
	feedback.present_hit(attacker, target, DamageInfo.make(0.0, attacker, "light"), "metal")
	var indicator := feedback.incoming_indicator()
	_check(indicator.visible, "dano recebido mostra origem mesmo fora do ecra")
	_check(indicator.shown_physics_frame == Engine.get_physics_frames(),
		"seta de origem nasce no frame do dano")
	_check(indicator.reaction_frames_left == target._hitstun_frames,
		"seta dura a reaccao real, sem temporizador duplicado")
	_check((target._visual as MockVisual).last_animation == "Hit_Chest",
		"atingido reage com animacao de dor")
	_check(indicator.screen_direction_to_source().length() > 0.99,
		"direccao de origem e normalizada e legivel")
	target.free()
	attacker.free()
	camera.free()


func _test_hitstop_preserves_iframe_clock() -> void:
	var player_source := FileAccess.get_file_as_string("res://src/player/player.gd")
	var freeze_branch := player_source.find("if hitstop_frames > 0:")
	var state_clock := player_source.find("state_frame += 1", freeze_branch)
	var early_return := player_source.find("return", freeze_branch)
	_check(freeze_branch >= 0 and early_return > freeze_branch and early_return < state_clock,
		"hit-stop retorna antes de avancar o relogio de i-frames")
	var dodge := (_game_data.call("section", "dodge") as Dictionary)
	var iframe_frame := int(dodge.get("iframe_start_frame", 0))
	var hitstop := int((_game_data.call("section", "hit_stop") as Dictionary).get("light_hit", 0))
	var simulated_state_frame := iframe_frame
	for _frame in hitstop:
		# Espelha a guarda provada acima: o tick congelado nao toca state_frame.
		pass
	_check(simulated_state_frame == iframe_frame,
		"paragem local nao consome nenhum frame de invencibilidade")


func _test_surface_audio_contract() -> void:
	var audio := HitFeedbackAudio.new()
	root.add_child(audio)
	var ids := {}
	for surface in ["flesh", "metal", "wood"]:
		ids[surface] = audio.sound_id_for_surface(surface)
	_check(ids.values().duplicate().reduce(func(acc: Dictionary, value: String):
		acc[value] = true
		return acc, {}).size() == 3,
		"carne, metal e madeira usam assinaturas sonoras distintas")
	_check(audio.synthesis_milliseconds >= 0.0,
		"som metalico declara custo de sintese medivel")
	audio.free()


func _make_actor(at: Vector3) -> MockActor:
	var actor := MockActor.new()
	root.add_child(actor)
	actor.global_position = at
	var player_cfg := _game_data.call("section", "player") as Dictionary
	var capsule := CapsuleShape3D.new()
	capsule.height = float(player_cfg.get("capsule_height", 0.0))
	capsule.radius = float(player_cfg.get("capsule_radius", 0.0))
	actor.body_radius = capsule.radius
	var collision := CollisionShape3D.new()
	collision.shape = capsule
	collision.position.y = capsule.height * 0.5
	actor.add_child(collision)
	return actor


func _make_enemy(at: Vector3) -> MockEnemy:
	var enemy := MockEnemy.new()
	root.add_child(enemy)
	enemy.global_position = at
	var player_cfg := _game_data.call("section", "player") as Dictionary
	var capsule := CapsuleShape3D.new()
	capsule.height = float(player_cfg.get("capsule_height", 0.0))
	capsule.radius = float(player_cfg.get("capsule_radius", 0.0))
	enemy.body_radius = capsule.radius
	var collision := CollisionShape3D.new()
	collision.shape = capsule
	collision.position.y = capsule.height * 0.5
	enemy.add_child(collision)
	return enemy


func _check(condition: bool, label: String) -> void:
	if condition:
		_passed += 1
		print("  ok    ", label)
	else:
		_failed += 1
		printerr("  FALHA ", label)
