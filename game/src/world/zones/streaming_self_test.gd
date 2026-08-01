extends SceneTree
## Provas comportamentais do carregamento de zonas.
##
## Correr isoladamente:
##   godot --headless --audio-driver Dummy --path game/ \
##     --script res://src/world/zones/streaming_self_test.gd

const StreamingManagerScript = preload("res://src/world/streaming_manager.gd")
const StreamingGateScript = preload("res://src/world/streaming_gate.gd")

var _passed := 0
var _failed := 0


class MemoryProbe:
	var samples: Array[Dictionary]
	var index := 0

	func _init(values: Array[Dictionary]) -> void:
		samples = values

	func read() -> Dictionary:
		var sample: Dictionary = samples[mini(index, samples.size() - 1)]
		index += 1
		return sample


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_fojo_over_budget_is_rejected_before_loading()
	await _test_transition_loads_without_replacing_current_zone()
	await _test_crossing_keeps_escape_route_until_garganta_is_clear()
	await _test_slowest_peer_keeps_fog_closed()
	await _test_player_walks_through_a_proximity_gate()
	await _test_walking_away_unloads_unused_transition()
	await _test_measured_zone_over_budget_never_opens_fog()
	await _test_slow_publication_never_opens_fog()
	await _test_cancel_during_publication_leaves_no_orphan()
	print("\n=== STREAMING: %d passaram, %d falharam ===\n" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)


func _test_fojo_over_budget_is_rejected_before_loading() -> void:
	var manager := StreamingManagerScript.new()
	root.add_child(manager)
	var configured: bool = manager.configure(
			_fojo_world_data(), _zone_registry(300), "current_and_neighbors")
	_check(configured, "orçamento: configuração válida é aceite")
	var plan: Dictionary = manager.plan_residency("fojo", "")
	_check(not bool(plan.get("admitted", true)),
			"orçamento: Fojo e cinco vizinhas acima de 1,6 GiB são recusados")
	_check((plan.get("zone_ids", []) as Array).size() == 6,
			"orçamento: o pior conjunto de Fojo conta as seis zonas")
	manager.free()


func _test_transition_loads_without_replacing_current_zone() -> void:
	var manager := StreamingManagerScript.new()
	root.add_child(manager)
	var registry := {
		"brumal": {
			"scene_path": "res://src/world/zones/test_zone_a.tscn",
			"budget_mib": 1,
		},
		"fojo": {
			"scene_path": "res://src/world/zones/test_zone_b.tscn",
			"budget_mib": 1,
		},
	}
	_check(manager.configure(_brumal_fojo_world_data(), registry,
			"current_and_transition"), "transição: configuração é aceite")
	_check(manager.request_initial_zone("brumal"),
			"transição: zona inicial começa a carregar")
	await manager.zone_ready
	_check(manager.is_zone_loaded("brumal"),
			"transição: zona actual fica publicada")
	_check(manager.prepare_transition("fojo"),
			"transição: aproximação da garganta inicia a vizinha")
	await manager.transition_ready
	_check(manager.resident_zone_ids() == ["brumal", "fojo"],
			"transição: actual e destino coexistem quando a bruma abre")
	manager.queue_free()
	await process_frame


func _test_crossing_keeps_escape_route_until_garganta_is_clear() -> void:
	var manager := StreamingManagerScript.new()
	root.add_child(manager)
	var registry := {
		"brumal": {
			"scene_path": "res://src/world/zones/test_zone_a.tscn",
			"budget_mib": 1,
		},
		"fojo": {
			"scene_path": "res://src/world/zones/test_zone_b.tscn",
			"budget_mib": 1,
		},
	}
	manager.configure(_brumal_fojo_world_data(), registry, "current_and_transition")
	manager.request_initial_zone("brumal")
	await manager.zone_ready
	manager.prepare_transition("fojo")
	await manager.transition_ready
	if not manager.has_method("commit_transition"):
		_check(false, "fuga: atravessar conserva a zona de retirada")
		manager.queue_free()
		await process_frame
		return
	_check(manager.commit_transition("fojo"),
			"fuga: atravessar confirma a nova zona")
	_check(manager.resident_zone_ids() == ["brumal", "fojo"],
			"fuga: o lado antigo continua residente dentro da garganta")
	_check(manager.release_retreat_zone(),
			"fuga: sair da garganta autoriza a descarga anterior")
	await process_frame
	_check(manager.resident_zone_ids() == ["fojo"],
			"fuga: apenas a zona actual fica residente depois da saída")
	manager.queue_free()
	await process_frame


func _test_slowest_peer_keeps_fog_closed() -> void:
	var manager := StreamingManagerScript.new()
	root.add_child(manager)
	var registry := {
		"brumal": {
			"scene_path": "res://src/world/zones/test_zone_a.tscn",
			"budget_mib": 1,
		},
		"fojo": {
			"scene_path": "res://src/world/zones/test_zone_b.tscn",
			"budget_mib": 1,
		},
	}
	manager.configure(_brumal_fojo_world_data(), registry, "current_and_transition")
	if not manager.has_method("set_required_peers"):
		_check(false, "co-op: a máquina mais lenta conserva a bruma")
		manager.queue_free()
		await process_frame
		return
	manager.set_required_peers(["rico"])
	manager.request_initial_zone("brumal")
	await manager.zone_ready
	manager.prepare_transition("fojo")
	await manager.zone_ready
	_check(not manager.can_cross_transition(),
			"co-op: carregar localmente não abre a bruma")
	manager.set_peer_zone_ready("rico", "fojo", true)
	_check(manager.can_cross_transition(),
			"co-op: a bruma abre quando a máquina mais lenta confirma")
	manager.queue_free()
	await process_frame


func _test_player_walks_through_a_proximity_gate() -> void:
	var manager := StreamingManagerScript.new()
	root.add_child(manager)
	var registry := {
		"brumal": {
			"scene_path": "res://src/world/zones/test_zone_a.tscn",
			"budget_mib": 1,
		},
		"fojo": {
			"scene_path": "res://src/world/zones/test_zone_b.tscn",
			"budget_mib": 1,
		},
	}
	manager.configure(_brumal_fojo_world_data(), registry, "current_and_transition")
	manager.request_initial_zone("brumal")
	await manager.zone_ready
	var gate := StreamingGateScript.new()
	root.add_child(gate)
	_check(gate.configure(manager, "brumal", "fojo", Vector3(5.0, 4.0, 2.0)),
			"proximidade: garganta válida é construída")
	_check(gate.player_approached(),
			"proximidade: caminhar para a garganta inicia o destino")
	await manager.transition_ready
	_check(gate.is_open(), "proximidade: a bruma levanta sem ecrã de carregamento")
	_check(gate.player_crossed(), "proximidade: atravessar confirma a nova zona")
	_check(gate.player_cleared(), "proximidade: afastar-se liberta o lado antigo")
	await process_frame
	_check(manager.resident_zone_ids() == ["fojo"],
			"proximidade: a garganta deixa apenas o destino residente")
	gate.queue_free()
	manager.queue_free()
	await process_frame


func _test_walking_away_unloads_unused_transition() -> void:
	var manager := StreamingManagerScript.new()
	root.add_child(manager)
	var registry := {
		"brumal": {
			"scene_path": "res://src/world/zones/test_zone_a.tscn",
			"budget_mib": 1,
		},
		"fojo": {
			"scene_path": "res://src/world/zones/test_zone_b.tscn",
			"budget_mib": 1,
		},
	}
	manager.configure(_brumal_fojo_world_data(), registry, "current_and_transition")
	manager.request_initial_zone("brumal")
	await manager.zone_ready
	var gate := StreamingGateScript.new()
	root.add_child(gate)
	gate.configure(manager, "brumal", "fojo", Vector3(5.0, 4.0, 2.0))
	gate.player_approached()
	await manager.transition_ready
	if not gate.has_method("player_withdrew"):
		_check(false, "proximidade: recuar descarrega a transição não usada")
		gate.queue_free()
		manager.queue_free()
		await process_frame
		return
	_check(gate.player_withdrew(),
			"proximidade: sair pelo lado de origem cancela a transição")
	await process_frame
	_check(manager.resident_zone_ids() == ["brumal"],
			"proximidade: a vizinha não usada deixa de ser residente")
	gate.queue_free()
	manager.queue_free()
	await process_frame


func _test_measured_zone_over_budget_never_opens_fog() -> void:
	var manager := StreamingManagerScript.new()
	root.add_child(manager)
	if not manager.has_method("set_memory_probe"):
		_check(false, "memória: zona medida acima do limite não abre a bruma")
		manager.queue_free()
		await process_frame
		return
	var mib := 1024 * 1024
	var probe := MemoryProbe.new([
		{"static_bytes": 100 * mib, "video_bytes": 50 * mib},
		{"static_bytes": 100 * mib, "video_bytes": 50 * mib},
		{"static_bytes": 100 * mib, "video_bytes": 50 * mib},
		{"static_bytes": 500 * mib, "video_bytes": 250 * mib},
	])
	manager.set_memory_probe(probe.read)
	var registry := {
		"brumal": {
			"scene_path": "res://src/world/zones/test_zone_a.tscn",
			"budget_mib": 1,
		},
		"fojo": {
			"scene_path": "res://src/world/zones/test_zone_b.tscn",
			"budget_mib": 512,
		},
	}
	manager.configure(_brumal_fojo_world_data(), registry, "current_and_transition")
	manager.request_initial_zone("brumal")
	await manager.zone_ready
	manager.prepare_transition("fojo")
	await manager.zone_failed
	_check(not manager.is_zone_loaded("fojo"),
			"memória: candidata de 600 MiB é retirada")
	_check(not manager.can_cross_transition(),
			"memória: a zona actual continua atrás de bruma fechada")
	manager.queue_free()
	await process_frame


func _test_slow_publication_never_opens_fog() -> void:
	var manager := StreamingManagerScript.new()
	root.add_child(manager)
	var registry := {
		"brumal": {
			"scene_path": "res://src/world/zones/test_zone_a.tscn",
			"budget_mib": 1,
		},
		"fojo": {
			"scene_path": "res://src/world/zones/slow_test_zone.tscn",
			"budget_mib": 512,
		},
	}
	manager.configure(_brumal_fojo_world_data(), registry, "current_and_transition")
	manager.request_initial_zone("brumal")
	await manager.zone_ready
	var outcome := {"failed": false}
	manager.zone_failed.connect(func(zone_id: String, reason: String) -> void:
		if zone_id == "fojo" and reason == "publicacao_bloqueou_frame":
			outcome["failed"] = true)
	manager.prepare_transition("fojo")
	for _frame: int in 60:
		if bool(outcome.get("failed", false)):
			break
		await process_frame
	_check(bool(outcome.get("failed", false)),
			"frame: publicação acima de 20 ms é recusada")
	_check(not manager.can_cross_transition(),
			"frame: a bruma não abre depois de um soluço de publicação")
	manager.queue_free()
	await process_frame


func _test_cancel_during_publication_leaves_no_orphan() -> void:
	var manager := StreamingManagerScript.new()
	root.add_child(manager)
	if not manager.has_signal("zone_publication_started"):
		_check(false, "cancelamento: publicação cancelada não deixa zona órfã")
		manager.queue_free()
		await process_frame
		return
	var registry := {
		"brumal": {
			"scene_path": "res://src/world/zones/test_zone_a.tscn",
			"budget_mib": 1,
		},
		"fojo": {
			"scene_path": "res://src/world/zones/test_zone_b.tscn",
			"budget_mib": 1,
		},
	}
	manager.configure(_brumal_fojo_world_data(), registry, "current_and_transition")
	manager.request_initial_zone("brumal")
	await manager.zone_ready
	manager.prepare_transition("fojo")
	await manager.zone_publication_started
	_check(manager.cancel_transition(),
			"cancelamento: afastar-se durante publicação é aceite")
	for _frame: int in 4:
		await process_frame
	_check(manager.resident_zone_ids() == ["brumal"],
			"cancelamento: publicação tardia não deixa zona órfã")
	manager.queue_free()
	await process_frame


func _fojo_world_data() -> Dictionary:
	return {
		"streaming": {"max_world_working_set_gb": 2.5},
		"connections": [
			{"from": "brumal", "to": "fojo"},
			{"from": "selva_funda", "to": "fojo"},
			{"from": "campas_cinzentas", "to": "fojo"},
			{"from": "fojo", "to": "fulgor"},
			{"from": "fojo", "to": "fornalha"},
		],
	}


func _brumal_fojo_world_data() -> Dictionary:
	return {
		"streaming": {"max_world_working_set_gb": 2.5},
		"connections": [{"from": "brumal", "to": "fojo"}],
	}


func _zone_registry(budget_mib: int) -> Dictionary:
	var registry := {}
	for zone_id: String in [
			"fojo", "brumal", "selva_funda", "campas_cinzentas", "fulgor", "fornalha"]:
		registry[zone_id] = {
			"scene_path": "res://src/world/zones/test_zone.tscn",
			"budget_mib": budget_mib,
		}
	return registry


func _check(condition: bool, description: String) -> void:
	if condition:
		_passed += 1
		print("  ok    %s" % description)
	else:
		_failed += 1
		printerr("  FALHA %s" % description)
