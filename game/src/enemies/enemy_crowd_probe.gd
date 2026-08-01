extends Node3D
## Prova de regressão do caso da captura: cinco inimigos nascem no mesmo ponto,
## perseguem o mesmo alvo e têm de conservar espaço corporal entre si.

const AttackCoordinator = preload("res://src/ai/enemy_attack_coordinator.gd")

class DummyTarget extends Node3D:
	func is_alive() -> bool:
		return true

	func take_damage(_info: DamageInfo) -> void:
		pass

	func state_name() -> String:
		return "livre"


var _enemies: Array[Enemy] = []


func _ready() -> void:
	_build_floor()
	var target := DummyTarget.new()
	target.position = Vector3.ZERO
	add_child(target)
	for index: int in 5:
		var enemy := Enemy.new()
		add_child(enemy)
		enemy.position = Vector3(0.0, 0.5, 4.0)
		enemy.setup("orc_spearman", {}, false, index + 1)
		enemy.target = target
		_enemies.append(enemy)
	_assert_spacing("nascimento")
	await _assert_attack_coordination(target)
	var presentation: Dictionary = GameData.enemies.get("_presentation", {}) as Dictionary
	await get_tree().create_timer(float(presentation.get("crowd_probe_duration_s", 0.0))).timeout
	_assert_spacing("perseguicao")
	get_tree().quit()


func _build_floor() -> void:
	var floor := StaticBody3D.new()
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(20.0, 1.0, 20.0)
	collision.shape = shape
	collision.position.y = -0.5
	floor.add_child(collision)
	add_child(floor)


func _assert_spacing(stage: String) -> void:
	var crowd: Dictionary = GameData.enemy("orc_spearman").get("crowd", {}) as Dictionary
	var clearance := float(crowd.get("spawn_clearance_m", 0.0))
	var closest := INF
	var required := 0.0
	for left: int in _enemies.size():
		for right: int in range(left + 1, _enemies.size()):
			var a := _enemies[left]
			var b := _enemies[right]
			var delta := a.global_position - b.global_position
			delta.y = 0.0
			closest = minf(closest, delta.length())
			required = a.body_radius + b.body_radius + clearance
			if delta.length() < required:
				push_error("[enemy-crowd] %s empilhou %.3f m; mínimo %.3f m" % [stage, delta.length(), required])
				get_tree().quit(1)
				return
	print("[enemy-crowd] %s: distância mínima %.3f m (contrato %.3f m)" % [stage, closest, required])


func _assert_attack_coordination(target: Node) -> void:
	var attacks: Array = GameData.enemy("orc_spearman").get("attacks", []) as Array
	var active_frames := int((attacks.front() as Dictionary).get("active", 0))
	if not AttackCoordinator.can_enter_active(target, _enemies[0], active_frames):
		push_error("[enemy-honesty] primeiro atacante não obteve janela activa")
		get_tree().quit(1)
		return
	await get_tree().physics_frame
	if AttackCoordinator.can_enter_active(target, _enemies[1], active_frames):
		push_error("[enemy-honesty] segundo atacante entrou durante a janela activa")
		get_tree().quit(1)
		return
	for _frame: int in active_frames:
		await get_tree().physics_frame
	if not AttackCoordinator.can_enter_active(target, _enemies[1], active_frames):
		push_error("[enemy-honesty] janela não foi libertada depois do contrato")
		get_tree().quit(1)
		return
	AttackCoordinator.forget_target(target)
	print("[enemy-honesty] janela activa exclusiva por %d frames" % active_frames)
