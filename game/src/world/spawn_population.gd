extends Node
## Populacao virtualizada de uma zona: todas as colocacoes existem no plano,
## mas so as mais proximas recebem corpo/animacao, dentro do tecto do catalogo.

const STREAM_TICK_SECONDS := 0.25
const STREAM_ACTIVATION_MARGIN_M := 4.0
const COMMON_PATH_OFFSET_M := 1.8
const NAMED_PATH_OFFSET_M := 3.2
const RESIDENT_ROUTE_CLEARANCE_M := 10.0
const RESIDENT_SPACING_M := 3.0
const ROUTE_EDGE_ACTIVATION_FRACTION := 0.75

var _main: Node
var _game_data: Node
var _player: Node3D
var _world: Node3D
var _lair: Node3D
var _palette: Dictionary = {}
var _zone_id := ""
var _plan: Array[Dictionary] = []
var _active: Dictionary = {}
var _stream_elapsed := 0.0
var _activation_distance_m := 0.0
var _deactivation_distance_m := 0.0
var _animated_actor_limit := 0
var _active_enemy_limit := 0


static func build_plan(zone_id: String, enemies: Dictionary,
		named_catalog: Dictionary) -> Array[Dictionary]:
	var plan: Array[Dictionary] = []
	var budgets: Dictionary = enemies.get("_zone_budgets", {}) as Dictionary
	var budget: Dictionary = budgets.get(zone_id, {}) as Dictionary
	var population: Dictionary = budget.get("population", {}) as Dictionary
	var enemy_ids: Array[String] = []
	for value: Variant in population.keys():
		enemy_ids.append(String(value))
	enemy_ids.sort()
	var remaining: Dictionary = {}
	var placed_by_enemy: Dictionary = {}
	for enemy_id: String in enemy_ids:
		var enemy: Dictionary = enemies.get(enemy_id, {}) as Dictionary
		if enemy.is_empty() or not (enemy.get("biome_ids", []) as Array).has(zone_id):
			push_error("[spawn] budget de %s contem inimigo incoerente: %s" % [
				zone_id, enemy_id])
			continue
		remaining[enemy_id] = maxi(0, int(population.get(enemy_id, 0)))
		placed_by_enemy[enemy_id] = 0

	# Cada volta materializa uma colocacao de cada ficha declarada. Assim um
	# aumento no catalogo nao cria blocos monotonos nem exige repetir IDs.
	var has_remaining := true
	while has_remaining:
		has_remaining = false
		for enemy_id: String in enemy_ids:
			var left := int(remaining.get(enemy_id, 0))
			if left <= 0:
				continue
			has_remaining = true
			var index := int(placed_by_enemy.get(enemy_id, 0))
			plan.append({
				"kind": "common",
				"zone_id": zone_id,
				"enemy_id": enemy_id,
				"world_type_id": enemy_id,
				"placement_id": "%s:common:%s:%02d" % [zone_id, enemy_id, index],
			})
			remaining[enemy_id] = left - 1
			placed_by_enemy[enemy_id] = index + 1

	var named_entries: Dictionary = named_catalog.get("encounters", {}) as Dictionary
	var named_ids: Array[String] = []
	for value: Variant in named_entries.keys():
		var named_id := String(value)
		if String((named_entries[named_id] as Dictionary).get("zone_id", "")) == zone_id:
			named_ids.append(named_id)
	named_ids.sort()
	for named_id: String in named_ids:
		var encounter: Dictionary = named_entries[named_id] as Dictionary
		var base_enemy_id := String(encounter.get("base_enemy_id", ""))
		var base_enemy: Dictionary = enemies.get(base_enemy_id, {}) as Dictionary
		if base_enemy.is_empty() or not (base_enemy.get("biome_ids", []) as Array).has(zone_id):
			push_error("[spawn] encontro %s quebra a coerencia de %s" % [named_id, zone_id])
			continue
		plan.append({
			"kind": "named",
			"zone_id": zone_id,
			"enemy_id": base_enemy_id,
			"named_encounter_id": named_id,
			"world_type_id": "named:%s" % named_id,
			"placement_id": "%s:named:%s" % [zone_id, named_id],
		})

	var guardian_ids: Array[String] = []
	for value: Variant in enemies.keys():
		var enemy_id := String(value)
		if enemy_id.begins_with("_"):
			continue
		var enemy: Dictionary = enemies.get(enemy_id, {}) as Dictionary
		if bool(enemy.get("is_boss", false)) \
				and (enemy.get("biome_ids", []) as Array).has(zone_id):
			guardian_ids.append(enemy_id)
	guardian_ids.sort()
	for guardian_id: String in guardian_ids:
		plan.append({
			"kind": "guardian",
			"zone_id": zone_id,
			"enemy_id": guardian_id,
			"world_type_id": "guardian:%s" % guardian_id,
			"placement_id": "%s:guardian:%s" % [zone_id, guardian_id],
		})
	return plan


static func distinct_world_type_count(plan: Array[Dictionary]) -> int:
	var types: Dictionary = {}
	for placement: Dictionary in plan:
		var type_id := String(placement.get("world_type_id", ""))
		if not type_id.is_empty():
			types[type_id] = true
	return types.size()


static func catalog_contract_errors(enemies: Dictionary, named_catalog: Dictionary,
		plan: Array[Dictionary], actor_limit: int,
		active_enemy_limit: int) -> PackedStringArray:
	var errors := PackedStringArray()
	var budget: Dictionary = ((enemies.get("_zone_budgets", {}) as Dictionary).get(
		"brumal", {}) as Dictionary)
	var expected: Dictionary = budget.get("population", {}) as Dictionary
	var actual: Dictionary = {}
	var named_count := 0
	var guardian_count := 0
	var world_types: Dictionary = {}
	for placement: Dictionary in plan:
		var enemy_id := String(placement.get("enemy_id", ""))
		var enemy: Dictionary = enemies.get(enemy_id, {}) as Dictionary
		if not (enemy.get("biome_ids", []) as Array).has("brumal"):
			errors.append("%s nao pertence a Brumal" % enemy_id)
		var world_type_id := String(placement.get("world_type_id", ""))
		if not world_type_id.is_empty():
			world_types[world_type_id] = true
		match String(placement.get("kind", "")):
			"common":
				actual[enemy_id] = int(actual.get(enemy_id, 0)) + 1
			"named":
				named_count += 1
				var encounter: Dictionary = ((named_catalog.get(
					"encounters", {}) as Dictionary).get(String(placement.get(
						"named_encounter_id", "")), {}) as Dictionary)
				if String(encounter.get("guaranteed_loot", "")).is_empty():
					errors.append("%s nao tem espolio garantido" % world_type_id)
			"guardian":
				guardian_count += 1
	for enemy_id: String in expected:
		if int(actual.get(enemy_id, 0)) != int(expected.get(enemy_id, 0)):
			errors.append("%s tem %d/%d colocacoes" % [enemy_id,
				int(actual.get(enemy_id, 0)), int(expected.get(enemy_id, 0))])
	if actual.size() != expected.size():
		errors.append("o plano acrescentou tipos comuns fora do budget")
	if named_count != 3:
		errors.append("Brumal tem %d/3 encontros nomeados" % named_count)
	if guardian_count != 1:
		errors.append("Brumal tem %d/1 guardiao" % guardian_count)
	if world_types.size() < 6:
		errors.append("Brumal tem %d/6 tipos distintos no mundo" % world_types.size())
	if actor_limit != 8:
		errors.append("o tecto e %d/8 actores animados" % actor_limit)
	if active_enemy_limit != 5:
		errors.append("Brumal permite %d/5 inimigos animados" % active_enemy_limit)
	return errors


static func select_for_activation(placements: Array[Dictionary],
		observer_position: Vector3, reserved_actors: int, actor_limit: int,
		active_enemy_limit: int, activation_distance_m: float) -> Array[String]:
	var capacity := mini(maxi(0, actor_limit - reserved_actors),
		maxi(0, active_enemy_limit))
	var ranked: Array[Dictionary] = []
	for placement: Dictionary in placements:
		var position: Vector3 = placement.get("position", Vector3.ZERO) as Vector3
		var distance := observer_position.distance_to(position)
		if distance <= activation_distance_m:
			ranked.append({
				"placement_id": String(placement.get("placement_id", "")),
				"distance": distance,
			})
	ranked.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		if is_equal_approx(float(a.distance), float(b.distance)):
			return String(a.placement_id) < String(b.placement_id)
		return float(a.distance) < float(b.distance))
	var selected: Array[String] = []
	for index: int in range(mini(capacity, ranked.size())):
		selected.append(String(ranked[index].placement_id))
	return selected


func initialize(main_node: Node, player_node: Node3D, world_node: Node3D,
		lair_node: Node3D, palette: Dictionary, zone_id := "brumal") -> void:
	_main = main_node
	_player = player_node
	_world = world_node
	_lair = lair_node
	_palette = palette
	_zone_id = zone_id
	_game_data = get_node_or_null("/root/GameData")
	if _game_data == null:
		push_error("[spawn] GameData indisponivel")
		return
	var enemies: Dictionary = _game_data.get("enemies") as Dictionary
	var named_catalog: Dictionary = _game_data.get("named_catalog") as Dictionary
	_plan = build_plan(zone_id, enemies, named_catalog)
	var budget: Dictionary = ((enemies.get("_zone_budgets", {}) as Dictionary).get(
		zone_id, {}) as Dictionary)
	var defaults: Dictionary = enemies.get("_enemy_defaults", {}) as Dictionary
	# O corpo entra um instante antes de a IA o poder perceber e fica ate ao
	# limite de perseguicao. Assim nao aparece ja a atacar no bordo do streaming.
	_activation_distance_m = float(defaults.get("aggro_range", 16.0)) \
		+ STREAM_ACTIVATION_MARGIN_M
	_deactivation_distance_m = maxf(_activation_distance_m,
		float(defaults.get("leash_range", 34.0)))
	_animated_actor_limit = int(budget.get("animated_actor_limit", 0))
	_active_enemy_limit = int(budget.get("active_enemy_limit", 0))
	_assign_brumal_positions()
	_append_lair_placements()
	set_meta("planned_population", _plan.size())
	set_meta("distinct_world_types", distinct_world_type_count(_plan))
	set_meta("animated_actor_limit", _animated_actor_limit)
	set_meta("active_enemy_limit", _active_enemy_limit)
	var contract_errors := catalog_contract_errors(enemies, named_catalog, _plan,
		_animated_actor_limit, _active_enemy_limit)
	set_meta("population_contract_errors", contract_errors)
	for error: String in contract_errors:
		push_error("[spawn] %s" % error)
	add_to_group("spawn_population")
	_refresh_active_set()
	set_process(true)


func plan_snapshot() -> Array[Dictionary]:
	return _plan.duplicate(true)


func active_animated_actor_count() -> int:
	return _animated_actor_count()


func active_enemy_count() -> int:
	return _active_enemy_count()


func _process(delta: float) -> void:
	_stream_elapsed += delta
	if _stream_elapsed < STREAM_TICK_SECONDS:
		return
	_stream_elapsed = 0.0
	_refresh_active_set()


func _refresh_active_set() -> void:
	if not is_instance_valid(_player):
		return
	_prune_invalid_actors()
	var external_enemies := _external_enemy_count()
	var reserved := _reserved_actor_count() + external_enemies
	var eligible: Array[Dictionary] = []
	var engaged: Array[Dictionary] = []
	for placement: Dictionary in _plan:
		var placement_id := String(placement.get("placement_id", ""))
		var actor := _active.get(placement_id) as Node
		if is_instance_valid(actor) and not _is_actor_dead(actor):
			placement["defeated"] = false
		if bool(placement.get("defeated", false)):
			continue
		var distance := _player.global_position.distance_to(
			placement.get("position", Vector3.ZERO) as Vector3)
		if distance <= _activation_distance_m \
				or (is_instance_valid(actor) and distance <= _deactivation_distance_m):
			eligible.append(placement)
			if is_instance_valid(actor) and _actor_is_engaged(actor):
				engaged.append(placement)

	# Um corpo que ja respondeu ao jogador nao pode desaparecer so porque outra
	# colocacao ficou momentaneamente mais perto. Reserva primeiro esses lugares;
	# proximidade continua a preencher apenas a capacidade que sobra.
	var desired := select_for_activation(engaged, _player.global_position,
		reserved, _animated_actor_limit,
		maxi(0, _active_enemy_limit - external_enemies),
		_deactivation_distance_m)
	var remaining: Array[Dictionary] = []
	for placement: Dictionary in eligible:
		var placement_id := String(placement.get("placement_id", ""))
		if desired.has(placement_id):
			continue
		# Durante um confronto conservam-se os corpos que o jogador ja podia ver,
		# mas uma colocacao nova espera pela resolucao da batida actual.
		if not desired.is_empty() and not _active.has(placement_id):
			continue
		remaining.append(placement)
	var nearby := select_for_activation(remaining, _player.global_position,
		reserved + desired.size(), _animated_actor_limit,
		maxi(0, _active_enemy_limit - external_enemies - desired.size()),
		_deactivation_distance_m)
	desired.append_array(nearby)

	for placement_id_value: Variant in _active.keys().duplicate():
		var placement_id := String(placement_id_value)
		var actor := _active.get(placement_id) as Node
		if not is_instance_valid(actor):
			_active.erase(placement_id)
			continue
		if _is_actor_dead(actor):
			continue
		if not desired.has(placement_id):
			_deactivate_actor(placement_id, actor)

	var free_slots := mini(
		maxi(0, _animated_actor_limit - _animated_actor_count()),
		maxi(0, _active_enemy_limit - _active_enemy_count()))
	for placement_id: String in desired:
		if free_slots <= 0:
			break
		if _active.has(placement_id) and is_instance_valid(_active[placement_id]):
			continue
		var placement := _placement_by_id(placement_id)
		if placement.is_empty():
			continue
		_spawn_placement(placement)
		free_slots -= 1
	if _animated_actor_count() > _animated_actor_limit:
		push_error("[spawn] tecto de %d actores animados excedido" % _animated_actor_limit)


func _spawn_placement(placement: Dictionary) -> void:
	var kind := String(placement.get("kind", ""))
	var named_script: Script = load("res://src/world/spawn_named_enemy.gd") if kind == "named" else null
	var actor: Node = named_script.new() as Node if named_script != null else null
	var spawned := _main.call("_spawn", String(placement.get("enemy_id", "")),
		placement.get("position", Vector3.ZERO) as Vector3, actor) as Node
	if spawned == null:
		return
	var placement_id := String(placement.get("placement_id", ""))
	spawned.set_meta("placement_id", placement_id)
	spawned.set_meta("zone_id", _zone_id)
	spawned.set_meta("world_type_id", String(placement.get("world_type_id", "")))
	if kind == "named":
		if not bool(spawned.call("configure_named",
				String(placement.get("named_encounter_id", "")))):
			spawned.queue_free()
			return
		spawned.connect("guaranteed_loot_awarded", _on_named_loot_awarded)
	elif kind == "guardian":
		_main.call("_register_boss", spawned)
	spawned.connect("died", _on_actor_died.bind(placement_id))
	_active[placement_id] = spawned


func _deactivate_actor(placement_id: String, actor: Node) -> void:
	_active.erase(placement_id)
	if String(actor.get_meta("world_type_id", "")).begins_with("guardian:"):
		if _main.get("boss") == actor:
			_main.set("boss", null)
		var hud: Node = _main.get("hud") as Node
		if is_instance_valid(hud):
			hud.set("boss", null)
	actor.queue_free()


func _on_actor_died(_defeated: Node, placement_id: String) -> void:
	var placement := _placement_by_id(placement_id)
	if not placement.is_empty():
		placement["defeated"] = true


func _on_named_loot_awarded(encounter_id: String, result: Dictionary) -> void:
	var hud: Node = _main.get("hud") as Node
	if is_instance_valid(hud) and hud.has_method("toast"):
		var message := String(result.get("message", ""))
		if message.is_empty():
			message = "O espolio de %s nao foi guardado." % encounter_id
		hud.call("toast", message, 3.0)


func _prune_invalid_actors() -> void:
	for placement_id_value: Variant in _active.keys().duplicate():
		var placement_id := String(placement_id_value)
		if not is_instance_valid(_active.get(placement_id)):
			_active.erase(placement_id)


func _is_actor_dead(actor: Node) -> bool:
	return actor.has_method("is_alive") and not bool(actor.call("is_alive"))


func _actor_is_engaged(actor: Node) -> bool:
	if not actor.has_method("state_name"):
		return false
	return String(actor.call("state_name")) not in ["livre", "patrulha", "morto"]


func _reserved_actor_count() -> int:
	var instances: Dictionary = {}
	for group_name: String in ["player", "summons"]:
		for node: Node in get_tree().get_nodes_in_group(group_name):
			if is_instance_valid(node) and not node.is_queued_for_deletion():
				instances[node.get_instance_id()] = true
	return instances.size()


func _external_enemy_count() -> int:
	var managed: Dictionary = {}
	for actor_value: Variant in _active.values():
		if is_instance_valid(actor_value):
			managed[(actor_value as Node).get_instance_id()] = true
	var count := 0
	for node: Node in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(node) and not node.is_queued_for_deletion() \
				and not _is_actor_dead(node) \
				and not managed.has(node.get_instance_id()):
			count += 1
	return count


func _animated_actor_count() -> int:
	var instances: Dictionary = {}
	for group_name: String in ["player", "summons"]:
		for node: Node in get_tree().get_nodes_in_group(group_name):
			if is_instance_valid(node) and not node.is_queued_for_deletion():
				instances[node.get_instance_id()] = true
	for node: Node in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(node) and not node.is_queued_for_deletion() \
				and not _is_actor_dead(node):
			instances[node.get_instance_id()] = true
	return instances.size()


func _active_enemy_count() -> int:
	var count := 0
	for node: Node in get_tree().get_nodes_in_group("enemies"):
		if is_instance_valid(node) and not node.is_queued_for_deletion() \
				and not _is_actor_dead(node):
			count += 1
	return count


func _placement_by_id(placement_id: String) -> Dictionary:
	for placement: Dictionary in _plan:
		if String(placement.get("placement_id", "")) == placement_id:
			return placement
	return {}


func _assign_brumal_positions() -> void:
	var path_value: Variant = _world.get("path_points")
	var path: Array = path_value as Array if path_value is Array else []
	if path.size() < 7:
		push_error("[spawn] Brumal nao forneceu as sete ancoras do caminho")
		return
	var route_common_placements: Array[Dictionary] = []
	var resident_placements: Array[Dictionary] = []
	var named_placements: Array[Dictionary] = []
	var represented_common_types: Dictionary = {}
	for placement: Dictionary in _plan:
		match String(placement.get("kind", "")):
			"common":
				var enemy_id := String(placement.get("enemy_id", ""))
				if represented_common_types.has(enemy_id):
					resident_placements.append(placement)
				else:
					represented_common_types[enemy_id] = true
					route_common_placements.append(placement)
			"named":
				named_placements.append(placement)
			"guardian":
				placement["position"] = _guardian_position()

	var route_placements: Array[Dictionary] = []
	for index: int in maxi(route_common_placements.size(), named_placements.size()):
		if index < route_common_placements.size():
			route_placements.append(route_common_placements[index])
		if index < named_placements.size():
			route_placements.append(named_placements[index])
	_assign_route_positions(route_placements, path)
	_assign_resident_positions(resident_placements, path, [
		_world.get("rest_point") as Vector3,
		_world.get("camp_point") as Vector3,
	])


func _assign_route_positions(placements: Array[Dictionary], path: Array) -> void:
	var route_length := _route_length(path)
	var edge_distance := minf(_activation_distance_m * ROUTE_EDGE_ACTIVATION_FRACTION,
		route_length * 0.25)
	var edge_fraction := edge_distance / maxf(route_length, 0.001)
	for index: int in placements.size():
		# As extremidades ficam livres para o nascimento do jogador e a transicao
		# da Toca. A primeira batida entra no raio de streaming publicado e as
		# restantes repartem o percurso sem duplicar uma distancia de percepcao.
		var progress := float(index) / float(maxi(1, placements.size() - 1))
		var fraction := lerpf(edge_fraction, 1.0 - edge_fraction, progress)
		var route_sample := _sample_route(path, fraction)
		var position: Vector3 = route_sample.get("position", Vector3.ZERO) as Vector3
		var tangent: Vector3 = route_sample.get("tangent", Vector3.FORWARD) as Vector3
		var side := -1.0 if index % 2 == 0 else 1.0
		var right := Vector3(tangent.z, 0.0, -tangent.x).normalized()
		var lateral_offset_m := NAMED_PATH_OFFSET_M \
			if String(placements[index].get("kind", "")) == "named" \
			else COMMON_PATH_OFFSET_M
		placements[index]["position"] = position + right * lateral_offset_m * side \
			+ Vector3.UP * 0.5


func _assign_resident_positions(placements: Array[Dictionary], path: Array,
		anchors: Array) -> void:
	if anchors.is_empty():
		return
	for index: int in placements.size():
		var anchor := anchors[index % anchors.size()] as Vector3
		var nearest := _nearest_route_sample(path, anchor)
		var route_position: Vector3 = nearest.get("position", anchor) as Vector3
		var tangent: Vector3 = nearest.get("tangent", Vector3.FORWARD) as Vector3
		var away := anchor - route_position
		away.y = 0.0
		if away.is_zero_approx():
			away = Vector3(tangent.z, 0.0, -tangent.x)
		away = away.normalized()
		var row := index / anchors.size()
		var fan_step := float((row % 3) - 1)
		var depth_step := float(row / 3)
		placements[index]["position"] = anchor \
			+ away * (RESIDENT_ROUTE_CLEARANCE_M + depth_step * RESIDENT_SPACING_M) \
			+ tangent * fan_step * RESIDENT_SPACING_M + Vector3.UP * 0.5


func _sample_route(path: Array, fraction: float) -> Dictionary:
	var segment_lengths: Array[float] = []
	var total_length := 0.0
	for index: int in path.size() - 1:
		var length := (path[index] as Vector3).distance_to(path[index + 1] as Vector3)
		segment_lengths.append(length)
		total_length += length
	var remaining := total_length * clampf(fraction, 0.0, 1.0)
	for index: int in segment_lengths.size():
		var start := path[index] as Vector3
		var finish := path[index + 1] as Vector3
		var length := segment_lengths[index]
		if remaining <= length or index == segment_lengths.size() - 1:
			var tangent := (finish - start).normalized()
			return {
				"position": start.lerp(finish, remaining / maxf(length, 0.001)),
				"tangent": tangent,
			}
		remaining -= length
	return {"position": path[-1] as Vector3, "tangent": Vector3.FORWARD}


func _route_length(path: Array) -> float:
	var total := 0.0
	for index: int in path.size() - 1:
		total += (path[index] as Vector3).distance_to(path[index + 1] as Vector3)
	return total


func _nearest_route_sample(path: Array, point: Vector3) -> Dictionary:
	var best_distance := INF
	var best := {"position": path[0] as Vector3, "tangent": Vector3.FORWARD}
	for index: int in path.size() - 1:
		var start := path[index] as Vector3
		var finish := path[index + 1] as Vector3
		var delta := finish - start
		var fraction := clampf((point - start).dot(delta) \
			/ maxf(delta.length_squared(), 0.001), 0.0, 1.0)
		var position := start + delta * fraction
		var distance := point.distance_squared_to(position)
		if distance < best_distance:
			best_distance = distance
			best = {"position": position, "tangent": delta.normalized()}
	return best


func _append_lair_placements() -> void:
	if not is_instance_valid(_lair) or not _lair.has_method("get_enemy_markers"):
		return
	# A arquitectura e o catalogo sao as duas autoridades: cada marcador fornece
	# a posicao/papel e Main resolve o ID sem duplicar uma lista de conteudo aqui.
	var markers: Array = _lair.call("get_enemy_markers") as Array
	for marker_value: Variant in markers:
		var marker := marker_value as Marker3D
		if marker == null:
			continue
		var enemy_id := String(_main.call("_enemy_id_for_lair_marker", marker))
		if enemy_id.is_empty():
			continue
		_plan.append({
			"kind": "lair",
			"zone_id": _zone_id,
			"enemy_id": enemy_id,
			"world_type_id": enemy_id,
			"placement_id": "%s:lair:%s" % [_zone_id, String(marker.name)],
			"position": marker.global_position,
		})


func _guardian_position() -> Vector3:
	if is_instance_valid(_lair):
		var marker := _lair.get_node_or_null("Boss_Vorgar") as Marker3D
		if marker != null:
			return marker.global_position
	return _world.get("arena_center") as Vector3
