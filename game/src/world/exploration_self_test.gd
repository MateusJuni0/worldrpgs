extends SceneTree
## Prova isolada dos módulos que esta árvore pode escrever.
##
##   godot --headless --audio-driver Dummy --path game \
##     --script res://src/world/exploration_self_test.gd

const ExplorationScript = preload("res://src/world/exploration_brumal.gd")
const GroundItemScript = preload("res://src/world/secrets_ground_item.gd")
const LootAudioScript = preload("res://src/loot/loot_audio.gd")

var _passed := 0
var _failed := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var stage := Node3D.new()
	stage.name = "ExplorationSelfTest"
	root.add_child(stage)

	var exploration = ExplorationScript.new()
	stage.add_child(exploration)
	_check(exploration.build(), "Brumal: módulo constrói uma vez")

	var audit: Dictionary = exploration.audit()
	_check(int(audit.get("branch_count", 0)) == 2
		and bool(audit.get("branches_rejoin", false)),
		"Brumal: dois caminhos separam-se e voltam a juntar")
	_check(float(audit.get("rest_route_length_m", 0.0))
		> float(audit.get("risk_route_length_m", 0.0)) + 12.0,
		"Brumal: caminho com descanso custa distância; leito arriscado é mais curto")
	_check(int(audit.get("shortcut_count", 0)) == 1
		and float(audit.get("shortcut_return_length_m", 0.0)) > 0.0,
		"Brumal: regresso à Orla é uma rota física, não teletransporte")
	var combat := _load_json("res://data/combat.json")
	var world_data := _load_json("res://data/world.json")
	var run_speed := float((combat.get("movement", {}) as Dictionary).get("run_speed", 0.0))
	var traversal: Dictionary = (((world_data.get("zones", {}) as Dictionary).get(
		"brumal", {}) as Dictionary).get("traversal", {}) as Dictionary)
	var clean_target_seconds := float(traversal.get("clean_minutes", 0.0)) * 60.0
	var shortcut_target_seconds := float(traversal.get("target_after_shortcut_seconds", 0.0))
	_check(run_speed > 0.0 and absf(
		float(audit.get("rest_route_length_m", 0.0)) / run_speed - clean_target_seconds) <= 1.0,
		"medição: rota com descanso cumpre os oito minutos de world.json")
	_check(run_speed > 0.0 and absf(
		float(audit.get("shortcut_return_length_m", 0.0)) / run_speed
		- shortcut_target_seconds) <= 1.0,
		"medição: Portão da Árvore reduz a repetição aos quarenta segundos declarados")
	_check(int(audit.get("mesh_instances", 99)) == 5
		and int(audit.get("dynamic_lights", 99)) == 0,
		"Lei 4: módulo inteiro declara cinco draws e zero luzes dinâmicas")

	var branches: Array[Dictionary] = exploration.branch_contracts()
	_check(branches.size() == 2
		and (branches[0].get("points", PackedVector3Array()) as PackedVector3Array)[0]
			== (branches[1].get("points", PackedVector3Array()) as PackedVector3Array)[0]
		and (branches[0].get("points", PackedVector3Array()) as PackedVector3Array)[-1]
			== (branches[1].get("points", PackedVector3Array()) as PackedVector3Array)[-1],
		"escolha: as duas alternativas têm a mesma separação e reunião")
	_check(String(branches[0].get("cost", "")) != String(branches[1].get("cost", ""))
		and branches[0].get("reward_ids", []) != branches[1].get("reward_ids", []),
		"escolha: custo e recompensa mudam de verdade")

	var every_landmark_is_reachable := true
	for landmark: Dictionary in exploration.landmarks():
		every_landmark_is_reachable = every_landmark_is_reachable \
			and exploration.distance_to_routes(landmark.get("position", Vector3.ZERO) as Vector3) <= 16.0
	_check(exploration.landmarks().size() == 3 and every_landmark_is_reachable,
		"marcos: as três silhuetas vistas ao longe ficam junto de uma rota alcançável")

	var shortcut: ExplorationShortcut = exploration.shortcut()
	_check(shortcut != null and not shortcut.is_open(),
		"atalho: Portão da Árvore começa fechado")
	_check(not shortcut.try_interact(shortcut.outside_test_position(), true)
		and not bool(shortcut.prompt_state(shortcut.outside_test_position()).get("allowed", true)),
		"atalho: o lado da Orla vê a tranca mas não a abre")
	_check(not shortcut.try_interact(shortcut.inside_test_position(), false)
		and shortcut.try_interact(shortcut.inside_test_position(), true)
		and shortcut.is_open(),
		"atalho: chegar por dentro e premir a ação configurada abre")
	(shortcut.get_node("ShortcutWoodAndLatch") as AudioStreamPlayer3D).stop()
	var requirements: Dictionary = shortcut.requirements()
	_check(String(requirements.get("action", "")) == "interact"
		and (requirements.get("forbidden_gates", []) as Array).has("nivel")
		and (requirements.get("forbidden_gates", []) as Array).has("chave"),
		"Lei 1: contrato proíbe nível, chave, inventário e menu")

	var restored = ExplorationScript.new()
	stage.add_child(restored)
	restored.position.x = 260.0
	_check(restored.build(), "save: segunda instância de prova constrói")
	restored.restore_shortcuts([String(shortcut.shortcut_id)])
	_check(restored.shortcut().is_open(), "save: ID persistido materializa atalho aberto")

	await physics_frame
	await physics_frame
	var anchors: Dictionary = exploration.secret_anchors()
	var hidden_from: Vector3 = anchors.get("hidden_from", Vector3.ZERO) as Vector3
	var hidden_item: Vector3 = anchors.get("hidden_item", Vector3.ZERO) as Vector3
	var revealed_from: Vector3 = anchors.get("revealed_from", Vector3.ZERO) as Vector3
	var hidden_hit := _ray(stage, hidden_from, hidden_item)
	var revealed_hit := _ray(stage, revealed_from, hidden_item)
	_check(not hidden_hit.is_empty()
		and String((hidden_hit.get("collider") as Node).name) == "ExplorationOccluders",
		"segredo: a raiz bloqueia fisicamente o item a partir da separação")
	_check(revealed_hit.is_empty(),
		"segredo: contornar a raiz revela o mesmo item sem flag invisível")

	var item = GroundItemScript.new()
	item.position = hidden_item
	stage.add_child(item)
	_check(item.configure("arma:dagger", {
		"display_name": "Adaga de ferro rude",
		"receipt_id": "self-test-drop",
		"already_committed": false,
	}), "drop: item físico aceita ficha")
	var item_audit: Dictionary = item.audit()
	_check(int(item_audit.get("mesh_instances", 0)) == 2
		and int(item_audit.get("dynamic_lights", 1)) == 0
		and int(item_audit.get("particle_systems", 1)) == 0
		and int(item_audit.get("audio_voices", 0)) == 1,
		"drop: silhueta + brilho + sino custam dois draws, zero luzes e zero partículas")
	_check(item.is_readable_from(item.global_position + Vector3(0.0, 1.5, 40.0), true)
		and not item.is_readable_from(item.global_position + Vector3(0.0, 1.5, 40.0), false),
		"drop: lê-se ao longe apenas com linha de visão")

	var requests: Array[String] = []
	item.claim_requested.connect(func(requested_item: String, _receipt: String) -> void:
		requests.append(requested_item))
	_check(not item.try_interact(item.global_position, false)
		and item.try_interact(item.global_position, true)
		and requests == ["arma:dagger"] and item.is_active(),
		"drop: interact pede transação e não apaga antes da confirmação")
	item.resolve_claim(false)
	_check(item.is_active() and item.try_interact(item.global_position, true),
		"drop: falha de save conserva o item e permite tentar outra vez")
	item.resolve_claim(true)
	_check(not item.is_active(), "drop: confirmação concluída remove a apresentação")

	var receipt_item = GroundItemScript.new()
	receipt_item.position = hidden_item + Vector3(3.0, 0.0, 0.0)
	stage.add_child(receipt_item)
	_check(receipt_item.configure("material:limalha_ferro", {"already_committed": true})
		and receipt_item.try_interact(receipt_item.global_position, true)
		and not receipt_item.is_active(),
		"drop actual: recibo já atómico continua visível no chão até interact")

	stage.queue_free()
	await process_frame
	# LootAudio guarda os dois WAV sintetizados em cache estática durante uma
	# sessão normal. Esta SceneTree termina logo depois da prova, por isso liberta
	# explicitamente a cache para o auditor headless não confundir retenção com
	# uma fuga dos nós de exploração.
	LootAudioScript._pickup_stream = null
	LootAudioScript._chest_stream = null
	await process_frame
	await process_frame
	print("\n=== %d passaram, %d falharam (exploração isolada) ===" % [_passed, _failed])
	call_deferred("_finish", 0 if _failed == 0 else 1)


func _finish(exit_code: int) -> void:
	quit(exit_code)


func _ray(stage: Node3D, from: Vector3, to: Vector3) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1
	query.collide_with_areas = false
	return stage.get_world_3d().direct_space_state.intersect_ray(query)


func _load_json(path: String) -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed as Dictionary if parsed is Dictionary else {}


func _check(condition: bool, label: String) -> void:
	if condition:
		_passed += 1
		print("  ok    %s" % label)
	else:
		_failed += 1
		printerr("  FALHA %s" % label)
