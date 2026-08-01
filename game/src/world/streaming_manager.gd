extends Node
## Carregamento de zonas sob orçamento. A interface separa planeamento de I/O:
## uma aproximação pode ser recusada antes de tocar no disco ou no frame de jogo.

signal zone_ready(zone_id: String)
signal zone_failed(zone_id: String, reason: String)
signal zone_publication_started(zone_id: String)
signal transition_ready(zone_id: String)
signal zone_entered(zone_id: String, previous_zone_id: String)
signal zone_unloaded(zone_id: String)
signal peer_readiness_changed(zone_id: String, ready_peers: int, required_peers: int)

const WORLD_POOL_MIB := 1638
const NEIGHBOR_ZONE_LIMIT_MIB := 256
const TRANSITION_ZONE_LIMIT_MIB := 512
const TRANSITION_PUBLISH_CEILING_MS := 20.0
const POLICY_CURRENT_AND_NEIGHBORS := "current_and_neighbors"
const POLICY_CURRENT_AND_TRANSITION := "current_and_transition"

var _registry: Dictionary = {}
var _adjacency: Dictionary = {}
var _policy := ""
var _requests: Dictionary = {}
var _publishing: Dictionary = {}
var _discard_when_loaded: Dictionary = {}
var _loaded_nodes: Dictionary = {}
var _memory_records: Dictionary = {}
var _memory_probe: Callable
var _current_zone_id := ""
var _transition_zone_id := ""
var _retreat_zone_id := ""
var _required_peers: Array[String] = []
var _peer_zone_readiness: Dictionary = {}
var _transition_ready_emitted := false


func configure(world_data: Dictionary, zone_registry: Dictionary,
		resident_policy: String) -> bool:
	if resident_policy not in [POLICY_CURRENT_AND_NEIGHBORS,
			POLICY_CURRENT_AND_TRANSITION]:
		return false
	if not world_data.get("connections", null) is Array or zone_registry.is_empty():
		return false
	_registry = zone_registry.duplicate(true)
	_policy = resident_policy
	_adjacency.clear()
	for connection_value: Variant in world_data.get("connections", []):
		var connection := connection_value as Dictionary
		var from_id := String(connection.get("from", ""))
		var to_id := String(connection.get("to", ""))
		if from_id == "" or to_id == "" or from_id == to_id:
			return false
		_add_neighbor(from_id, to_id)
		_add_neighbor(to_id, from_id)
	return true


func request_initial_zone(zone_id: String) -> bool:
	if _current_zone_id != "" or not _registry.has(zone_id):
		return false
	_current_zone_id = zone_id
	if _request_zone(zone_id):
		return true
	_current_zone_id = ""
	return false


func prepare_transition(zone_id: String) -> bool:
	if _current_zone_id == "" or zone_id == _current_zone_id:
		return false
	if zone_id not in (_adjacency.get(_current_zone_id, []) as Array):
		return false
	if _transition_zone_id != "" and _transition_zone_id != zone_id:
		return false
	var plan := plan_residency(_current_zone_id, zone_id)
	if not bool(plan.get("admitted", false)):
		return false
	_transition_zone_id = zone_id
	_transition_ready_emitted = false
	if is_zone_loaded(zone_id):
		_maybe_emit_transition_ready()
		return true
	if _request_zone(zone_id):
		return true
	_transition_zone_id = ""
	return false


func commit_transition(zone_id: String) -> bool:
	if zone_id != _transition_zone_id or not can_cross_transition():
		return false
	var previous_zone_id := _current_zone_id
	_current_zone_id = zone_id
	_transition_zone_id = ""
	_transition_ready_emitted = false
	_retreat_zone_id = previous_zone_id
	zone_entered.emit(zone_id, previous_zone_id)
	return true


func release_retreat_zone() -> bool:
	if _retreat_zone_id == "" or _retreat_zone_id == _current_zone_id:
		return false
	var released_zone_id := _retreat_zone_id
	_retreat_zone_id = ""
	return _unload_zone(released_zone_id)


func cancel_transition() -> bool:
	if _transition_zone_id == "":
		return false
	var cancelled_zone_id := _transition_zone_id
	_transition_zone_id = ""
	_transition_ready_emitted = false
	for peer_id: String in _peer_zone_readiness.keys():
		(_peer_zone_readiness[peer_id] as Dictionary).erase(cancelled_zone_id)
	if is_zone_loaded(cancelled_zone_id):
		return _unload_zone(cancelled_zone_id)
	if _requests.has(cancelled_zone_id):
		_discard_when_loaded[cancelled_zone_id] = true
		return true
	if _publishing.has(cancelled_zone_id):
		_discard_when_loaded[cancelled_zone_id] = true
		return true
	return true


func current_zone_id() -> String:
	return _current_zone_id


func set_required_peers(peer_ids: Array) -> bool:
	var clean: Array[String] = []
	for peer_value: Variant in peer_ids:
		var peer_id := String(peer_value)
		if peer_id == "" or peer_id in clean:
			return false
		clean.append(peer_id)
	_required_peers = clean
	_peer_zone_readiness.clear()
	_transition_ready_emitted = false
	_maybe_emit_transition_ready()
	return true


func set_memory_probe(probe: Callable) -> bool:
	if not probe.is_valid():
		return false
	_memory_probe = probe
	return true


func memory_report() -> Dictionary:
	return _memory_records.duplicate(true)


func set_peer_zone_ready(peer_id: String, zone_id: String, ready: bool) -> bool:
	if peer_id not in _required_peers or zone_id == "":
		return false
	if not _peer_zone_readiness.has(peer_id):
		_peer_zone_readiness[peer_id] = {}
	(_peer_zone_readiness[peer_id] as Dictionary)[zone_id] = ready
	peer_readiness_changed.emit(zone_id, _ready_peer_count(zone_id), _required_peers.size())
	_maybe_emit_transition_ready()
	return true


func can_cross_transition() -> bool:
	if _transition_zone_id == "" or not is_zone_loaded(_transition_zone_id):
		return false
	return _ready_peer_count(_transition_zone_id) == _required_peers.size()


func is_zone_loaded(zone_id: String) -> bool:
	return _loaded_nodes.has(zone_id) and is_instance_valid(_loaded_nodes[zone_id])


func resident_zone_ids() -> Array[String]:
	var result: Array[String] = []
	for zone_id: String in _loaded_nodes.keys():
		if is_zone_loaded(zone_id):
			result.append(zone_id)
	result.sort()
	return result


func plan_residency(current_zone_id: String, transition_zone_id: String) -> Dictionary:
	var zone_ids: Array[String] = [current_zone_id]
	if _policy == POLICY_CURRENT_AND_NEIGHBORS:
		var neighbours: Array = (_adjacency.get(current_zone_id, []) as Array).duplicate()
		neighbours.sort()
		for neighbour: String in neighbours:
			if neighbour not in zone_ids:
				zone_ids.append(neighbour)
	elif transition_zone_id != "" and transition_zone_id not in zone_ids:
		zone_ids.append(transition_zone_id)

	var per_zone_limit := NEIGHBOR_ZONE_LIMIT_MIB \
			if _policy == POLICY_CURRENT_AND_NEIGHBORS else TRANSITION_ZONE_LIMIT_MIB
	var declared_mib := 0
	var violations: Array[String] = []
	for zone_id: String in zone_ids:
		var entry: Dictionary = _registry.get(zone_id, {}) as Dictionary
		var budget_mib := int(entry.get("budget_mib", 0))
		declared_mib += budget_mib
		if entry.is_empty():
			violations.append("zona_sem_registo:%s" % zone_id)
		elif budget_mib <= 0:
			violations.append("zona_sem_orcamento:%s" % zone_id)
		elif budget_mib > per_zone_limit:
			violations.append("zona_acima_do_limite:%s" % zone_id)
	if declared_mib > WORLD_POOL_MIB:
		violations.append("conjunto_acima_do_orcamento")

	return {
		"admitted": violations.is_empty(),
		"zone_ids": zone_ids,
		"declared_mib": declared_mib,
		"pool_mib": WORLD_POOL_MIB,
		"per_zone_limit_mib": per_zone_limit,
		"violations": violations,
	}


func _add_neighbor(zone_id: String, neighbour_id: String) -> void:
	if not _adjacency.has(zone_id):
		_adjacency[zone_id] = []
	var neighbours: Array = _adjacency[zone_id] as Array
	if neighbour_id not in neighbours:
		neighbours.append(neighbour_id)


func _request_zone(zone_id: String) -> bool:
	if is_zone_loaded(zone_id) or _requests.has(zone_id) or _publishing.has(zone_id):
		return true
	var entry: Dictionary = _registry.get(zone_id, {}) as Dictionary
	var scene_path := String(entry.get("scene_path", ""))
	if scene_path == "" or not ResourceLoader.exists(scene_path, "PackedScene"):
		zone_failed.emit(zone_id, "cena_inexistente")
		return false
	var error := ResourceLoader.load_threaded_request(scene_path, "PackedScene", false,
			ResourceLoader.CACHE_MODE_IGNORE)
	if error != OK:
		zone_failed.emit(zone_id, "pedido_falhou:%d" % error)
		return false
	_requests[zone_id] = {
		"scene_path": scene_path,
		"memory_before": _read_memory(),
	}
	return true


func _process(_delta: float) -> void:
	for zone_id: String in _requests.keys().duplicate():
		var request: Dictionary = _requests[zone_id] as Dictionary
		var scene_path := String(request.get("scene_path", ""))
		var status := ResourceLoader.load_threaded_get_status(scene_path)
		match status:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				continue
			ResourceLoader.THREAD_LOAD_LOADED:
				if bool(_discard_when_loaded.get(zone_id, false)):
					ResourceLoader.load_threaded_get(scene_path)
					_requests.erase(zone_id)
					_discard_when_loaded.erase(zone_id)
				else:
					_publish_loaded_zone(zone_id, request)
			_:
				_requests.erase(zone_id)
				_discard_when_loaded.erase(zone_id)
				zone_failed.emit(zone_id, "carregamento_falhou:%d" % status)
				if _transition_zone_id == zone_id:
					_transition_zone_id = ""


func _publish_loaded_zone(zone_id: String, request: Dictionary) -> void:
	var scene_path := String(request.get("scene_path", ""))
	var publish_started_usec := Time.get_ticks_usec()
	var resource := ResourceLoader.load_threaded_get(scene_path)
	_requests.erase(zone_id)
	if not resource is PackedScene:
		zone_failed.emit(zone_id, "recurso_nao_e_cena")
		return
	_publishing[zone_id] = true
	zone_publication_started.emit(zone_id)
	if bool(_discard_when_loaded.get(zone_id, false)):
		_finish_discarded_publication(zone_id)
		return
	var instance := (resource as PackedScene).instantiate()
	instance.name = "Zone_%s" % zone_id
	instance.set_meta("zone_id", zone_id)
	var entry: Dictionary = _registry.get(zone_id, {}) as Dictionary
	if instance is Node3D and entry.get("origin", null) is Vector3:
		(instance as Node3D).position = entry.get("origin", Vector3.ZERO) as Vector3
	add_child(instance)
	var publish_ms := float(Time.get_ticks_usec() - publish_started_usec) / 1000.0
	# Texturas e buffers só aparecem no monitor do renderer depois de este receber
	# pelo menos um frame. A bruma continua fechada durante estas duas voltas.
	await get_tree().process_frame
	await get_tree().process_frame
	if bool(_discard_when_loaded.get(zone_id, false)):
		instance.queue_free()
		_finish_discarded_publication(zone_id)
		return
	var before: Dictionary = request.get("memory_before", {}) as Dictionary
	var after := _read_memory()
	var static_delta_bytes := maxi(0, int(after.get("static_bytes", 0))
			- int(before.get("static_bytes", 0)))
	var video_delta_bytes := maxi(0, int(after.get("video_bytes", 0))
			- int(before.get("video_bytes", 0)))
	var charged_bytes := static_delta_bytes + video_delta_bytes
	var charged_mib := ceili(float(charged_bytes) / 1048576.0)
	var declared_mib := int(entry.get("budget_mib", 0))
	var policy_limit_mib := NEIGHBOR_ZONE_LIMIT_MIB \
			if _policy == POLICY_CURRENT_AND_NEIGHBORS else TRANSITION_ZONE_LIMIT_MIB
	var resident_charge_mib := charged_mib
	for resident_zone_id: String in _loaded_nodes.keys():
		resident_charge_mib += int((_memory_records.get(resident_zone_id, {}) as Dictionary).get(
				"charged_mib", 0))
	var memory_gate_passed := charged_mib <= declared_mib and charged_mib <= policy_limit_mib \
			and resident_charge_mib <= WORLD_POOL_MIB
	var frame_gate_required := _transition_zone_id == zone_id
	var frame_gate_passed := not frame_gate_required or publish_ms <= TRANSITION_PUBLISH_CEILING_MS
	var record := {
		"static_delta_bytes": static_delta_bytes,
		"video_delta_bytes": video_delta_bytes,
		"charged_mib": charged_mib,
		"declared_mib": declared_mib,
		"policy_limit_mib": policy_limit_mib,
		"publish_ms": snappedf(publish_ms, 0.001),
		"reported_build_ms": snappedf(float(instance.get_meta("build_time_ms", 0.0)), 0.001),
		"memory_gate_passed": memory_gate_passed,
		"frame_gate_required": frame_gate_required,
		"frame_gate_passed": frame_gate_passed,
		"admitted": memory_gate_passed and frame_gate_passed,
	}
	_memory_records[zone_id] = record
	_publishing.erase(zone_id)
	_discard_when_loaded.erase(zone_id)
	if not bool(record.get("admitted", false)):
		instance.queue_free()
		if _transition_zone_id == zone_id:
			_transition_zone_id = ""
			_transition_ready_emitted = false
		if _current_zone_id == zone_id:
			_current_zone_id = ""
		var reason := "publicacao_bloqueou_frame" if not frame_gate_passed \
				else "memoria_real_acima_do_orcamento"
		zone_failed.emit(zone_id, reason)
		return
	_loaded_nodes[zone_id] = instance
	zone_ready.emit(zone_id)
	if _transition_zone_id == zone_id:
		_maybe_emit_transition_ready()


func _finish_discarded_publication(zone_id: String) -> void:
	_publishing.erase(zone_id)
	_discard_when_loaded.erase(zone_id)


func _unload_zone(zone_id: String) -> bool:
	if not is_zone_loaded(zone_id) or zone_id == _current_zone_id:
		return false
	var instance := _loaded_nodes[zone_id] as Node
	_loaded_nodes.erase(zone_id)
	_memory_records.erase(zone_id)
	instance.queue_free()
	zone_unloaded.emit(zone_id)
	return true


func _ready_peer_count(zone_id: String) -> int:
	var count := 0
	for peer_id: String in _required_peers:
		var readiness: Dictionary = _peer_zone_readiness.get(peer_id, {}) as Dictionary
		if bool(readiness.get(zone_id, false)):
			count += 1
	return count


func _maybe_emit_transition_ready() -> void:
	if _transition_ready_emitted or not can_cross_transition():
		return
	_transition_ready_emitted = true
	transition_ready.emit(_transition_zone_id)


func _read_memory() -> Dictionary:
	if _memory_probe.is_valid():
		var measured: Variant = _memory_probe.call()
		if measured is Dictionary:
			return measured as Dictionary
	return {
		"static_bytes": OS.get_static_memory_usage(),
		"video_bytes": int(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED)),
	}
