class_name ArenaVorgar
extends Node3D
## Controlador data-driven da pergunta espacial de Vorgar e da janela de
## ressurreicao. Todos os tempos, raios, cores e limites vivem na ficha
## `vorgar.vorgar_encounter` ou em `progression.coop_resurrection`.

signal sequence_started(objective: String)
signal sequence_committed(objective: String)
signal sequence_finished(objective: String)
signal revive_channel_started(reviver: Node3D, downed: Node3D)
signal revive_channel_cancelled(reason: String)
signal player_revived(player: Node3D)
signal revive_window_expired(player: Node3D)

var _boss: Node3D
var _config: Dictionary = {}
var _resurrection_contract: Dictionary = {}
var _local_player: Node3D
var _players: Array[Node3D] = []

var _active_sequence: Dictionary = {}
var _sequence_frame := 0
var _sequence_visuals: Array[Node3D] = []
var _sequence_markers: Dictionary = {}
var _sequence_hits: Dictionary = {}
var _safe_zone_local := Vector3.ZERO
var _solo_origin_global := Vector3.ZERO
var _sequence_committed := false

var _downed_elapsed: Dictionary = {}
var _downed_expired: Dictionary = {}
var _revive_markers: Dictionary = {}
var _revive_intents: Dictionary = {}
var _reviver: Node3D
var _revived: Node3D
var _revive_progress := 0.0
var _reviver_last_health := 0.0
var _resurrection_used := false


func setup(p_boss: Node3D, p_config: Dictionary, p_local_player: Node3D = null) -> void:
	_boss = p_boss
	_config = p_config
	_local_player = p_local_player
	_resurrection_contract = GameData.progression.get("coop_resurrection", {}) as Dictionary
	_sync_players()
	_build_static_guides()


func set_local_player(player: Node3D) -> void:
	_local_player = player


## Fronteira para a futura camada de rede: cada peer publica o estado da sua
## interaccao; o controlador autoritativo nunca tenta adivinhar input remoto.
func set_revive_intent(player: Node3D, pressed: bool) -> void:
	if is_instance_valid(player):
		_revive_intents[player.get_instance_id()] = pressed


func begin_sequence(sequence: Dictionary) -> void:
	end_sequence()
	_active_sequence = sequence.duplicate(true)
	_sequence_frame = 0
	_sequence_committed = false
	_sequence_hits.clear()
	_sync_players()

	var objective := String(sequence.get("objectivo_coop", ""))
	match objective:
		"separar":
			_build_separate_markers()
		"juntar":
			_build_join_markers()
		_:
			push_error("Vorgar: objectivo co-op desconhecido '%s'" % objective)
			return

	var sound := sequence.get("som_anuncio", {}) as Dictionary
	Sfx.play(String(sound.get("profile", "")), _boss.global_position)
	sequence_started.emit(objective)


## Chamado pelo BossVorgar no mesmo frame de fisica que governa compromisso e
## hitbox. Assim o marcador nunca sobrevive ao efeito nem desaparece antes dele.
func tick_sequence(frame: int) -> void:
	if _active_sequence.is_empty():
		return
	_sequence_frame = frame
	_sync_players()
	var commitment := int(_active_sequence.get("momento_compromisso_frame"))
	if not _sequence_committed and frame >= commitment:
		_sequence_committed = true
		sequence_committed.emit(String(_active_sequence.get("objectivo_coop", "")))

	var startup := int(_active_sequence.get("startup"))
	var active := int(_active_sequence.get("active"))
	var objective := String(_active_sequence.get("objectivo_coop", ""))
	if objective == "separar":
		_update_separate_markers(frame)
	if frame > startup + active:
		_set_sequence_visuals_visible(false)
		return
	_set_sequence_visuals_visible(true)
	if frame <= startup:
		return

	var active_frame := frame - startup
	match objective:
		"separar":
			_resolve_separate(active_frame)
		"juntar":
			_resolve_join(active_frame)


func end_sequence() -> void:
	if not _active_sequence.is_empty():
		sequence_finished.emit(String(_active_sequence.get("objectivo_coop", "")))
	for visual: Node3D in _sequence_visuals:
		if is_instance_valid(visual):
			visual.queue_free()
	_sequence_visuals.clear()
	_sequence_markers.clear()
	_sequence_hits.clear()
	_active_sequence = {}
	_sequence_frame = 0
	_sequence_committed = false


func reset_attempt() -> void:
	end_sequence()
	_cancel_revive_channel("reset_tentativa", false)
	_resurrection_used = false
	_downed_elapsed.clear()
	_downed_expired.clear()
	_revive_intents.clear()
	for marker_value: Variant in _revive_markers.values():
		var marker_data := marker_value as Dictionary
		var root := marker_data.get("root") as Node3D
		if is_instance_valid(root):
			root.queue_free()
	_revive_markers.clear()


func join_safe_center_global() -> Vector3:
	return to_global(_safe_zone_local)


func resurrection_used() -> bool:
	return _resurrection_used


func resurrection_progress_seconds() -> float:
	return _revive_progress


func sequence_visuals_visible() -> bool:
	for visual: Node3D in _sequence_visuals:
		if is_instance_valid(visual) and visual.visible:
			return true
	return false


func join_reach_budget() -> Dictionary:
	var width := float(_config.get("usable_width_m"))
	var depth := float(_config.get("usable_depth_m"))
	var clearance := float(_active_or_named_sequence("juntar").get(
		"safe_zone_min_boss_distance_m"))
	var half_diagonal := Vector2(width, depth).length() * 0.5
	var sequence := _active_or_named_sequence("juntar")
	var available_seconds := GameData.frames_to_seconds(float(sequence.get("startup")))
	var run_speed := float(GameData.section("movement").get("run_speed"))
	return {
		"required_max_m": half_diagonal + clearance,
		"available_m": available_seconds * run_speed,
		"warning_seconds": available_seconds,
	}


func visual_cost_snapshot() -> Dictionary:
	var counts := _count_visual_descendants(self)
	return {
		"meshes": counts.x,
		"labels": counts.y,
		"mesh_budget": int(_config.get("max_visual_meshes")),
		"label_budget": int(_config.get("max_visual_labels")),
	}


func _physics_process(delta: float) -> void:
	if _config.is_empty():
		return
	_sync_players()
	_tick_resurrection(delta)


func _sync_players() -> void:
	_players.clear()
	if not is_inside_tree():
		return
	for node: Node in get_tree().get_nodes_in_group("player"):
		var player := node as Node3D
		if player != null:
			_players.append(player)
	if _local_player == null and not _players.is_empty():
		_local_player = _players.front()


func _build_static_guides() -> void:
	for existing in get_children():
		if existing is Node3D and bool(existing.get_meta("vorgar_static_guide", false)):
			existing.queue_free()
	var colors := _config.get("colors", {}) as Dictionary
	var labels := _config.get("labels", {}) as Dictionary
	for value: Variant in _config.get("flank_offsets_m", []):
		var marker := _make_disc(
			float(_config.get("flank_marker_radius_m")),
			Color(String(colors.get("flank"))),
			float(_config.get("guide_alpha")),
			String(labels.get("flank")))
		marker.position = _vector_from_array(value as Array)
		marker.set_meta("vorgar_static_guide", true)
		add_child(marker)
	for value: Variant in _config.get("refuge_offsets_m", []):
		var marker := _make_disc(
			float(_config.get("refuge_marker_radius_m")),
			Color(String(colors.get("refuge"))),
			float(_config.get("guide_alpha")),
			String(labels.get("refuge")))
		marker.position = _vector_from_array(value as Array)
		marker.set_meta("vorgar_static_guide", true)
		add_child(marker)


func _build_separate_markers() -> void:
	var colors := _config.get("colors", {}) as Dictionary
	var labels := _config.get("labels", {}) as Dictionary
	var alive := _alive_players()
	for player: Node3D in alive:
		var marker := _make_disc(
			float(_active_sequence.get("marker_radius_m")),
			Color(String(colors.get("danger"))),
			float(_config.get("danger_alpha")),
			String(labels.get("separate")))
		add_child(marker)
		marker.global_position = player.global_position
		_sequence_visuals.append(marker)
		_sequence_markers[player.get_instance_id()] = marker
	if alive.size() == 1:
		_solo_origin_global = alive.front().global_position


func _update_separate_markers(frame: int) -> void:
	var alive := _alive_players()
	var solo := alive.size() == 1
	var freeze_frame := int(_active_sequence.get("solo_marker_freeze_frame"))
	for player: Node3D in alive:
		var marker := _sequence_markers.get(player.get_instance_id()) as Node3D
		if not is_instance_valid(marker):
			continue
		if not solo or frame <= freeze_frame:
			marker.global_position = player.global_position
			if solo:
				_solo_origin_global = player.global_position


func _build_join_markers() -> void:
	_safe_zone_local = to_local(_choose_join_safe_center())
	var colors := _config.get("colors", {}) as Dictionary
	var labels := _config.get("labels", {}) as Dictionary
	var danger := _make_rectangle(
		Vector2(float(_config.get("usable_width_m")), float(_config.get("usable_depth_m"))),
		Color(String(colors.get("danger"))),
		float(_config.get("danger_alpha")),
		String(labels.get("join")))
	danger.position = Vector3.ZERO
	add_child(danger)
	_sequence_visuals.append(danger)
	var safe := _make_disc(
		float(_active_sequence.get("safe_zone_radius_m")),
		Color(String(colors.get("safe"))),
		float(_config.get("safe_alpha")),
		String(labels.get("join")))
	safe.position = _safe_zone_local
	add_child(safe)
	_sequence_visuals.append(safe)


func _choose_join_safe_center() -> Vector3:
	var alive := _alive_players()
	var desired := _boss.global_position
	if alive.size() == 1:
		var nearest_distance := INF
		for value: Variant in _config.get("flank_offsets_m", []):
			var candidate := to_global(_vector_from_array(value as Array))
			var distance: float = alive.front().global_position.distance_to(candidate)
			if distance < nearest_distance:
				nearest_distance = distance
				desired = candidate
	elif not alive.is_empty():
		desired = Vector3.ZERO
		for player: Node3D in alive:
			desired += player.global_position
		desired /= float(alive.size())

	var boss_forward := -_boss.global_transform.basis.z.normalized()
	var from_boss := desired - _boss.global_position
	from_boss.y = 0.0
	var clearance := float(_active_sequence.get("safe_zone_min_boss_distance_m"))
	if from_boss.length() < clearance or boss_forward.dot(from_boss.normalized()) < 0.0:
		from_boss = boss_forward * clearance
	desired = _boss.global_position + from_boss

	var local := to_local(desired)
	var radius := float(_active_sequence.get("safe_zone_radius_m"))
	var half_width := float(_config.get("usable_width_m")) * 0.5 - radius
	var half_depth := float(_config.get("usable_depth_m")) * 0.5 - radius
	local.x = clampf(local.x, -half_width, half_width)
	local.z = clampf(local.z, -half_depth, half_depth)
	local.y = 0.0
	return to_global(local)


func _resolve_separate(active_frame: int) -> void:
	if not _damage_tick_due(active_frame):
		return
	var alive := _alive_players()
	if alive.size() == 1:
		var player: Node3D = alive.front()
		if player.global_position.distance_to(_solo_origin_global) <= float(
			_active_sequence.get("marker_radius_m")):
			_apply_sequence_damage(player)
		return
	var minimum := float(_active_sequence.get("minimum_player_separation_m"))
	for player: Node3D in alive:
		for other: Node3D in alive:
			if player == other:
				continue
			if player.global_position.distance_to(other.global_position) < minimum:
				_apply_sequence_damage(player)
				break


func _resolve_join(active_frame: int) -> void:
	if not _damage_tick_due(active_frame):
		return
	var radius := float(_active_sequence.get("safe_zone_radius_m"))
	var safe_global := join_safe_center_global()
	for player: Node3D in _alive_players():
		if player.global_position.distance_to(safe_global) > radius:
			_apply_sequence_damage(player)


func _damage_tick_due(active_frame: int) -> bool:
	var interval := int(_active_sequence.get("damage_interval_frames"))
	return active_frame == 1 or (active_frame - 1) % interval == 0


func _apply_sequence_damage(player: Node3D) -> void:
	if not is_instance_valid(player) or not player.has_method("take_damage"):
		return
	var interval := int(_active_sequence.get("damage_interval_frames"))
	var last_frame := int(_sequence_hits.get(player.get_instance_id(), -interval))
	if _sequence_frame - last_frame < interval:
		return
	var boss_data := _boss.get("data") as Dictionary
	var damage := boss_data.get("damage", {}) as Dictionary
	var weight := String(_active_sequence.get("weight"))
	var info := DamageInfo.make(float(damage.get(weight)), _boss, weight)
	info.is_aoe = true
	info.parryable = false
	info.attack_id = String(_active_sequence.get("id"))
	player.call("take_damage", info)
	_sequence_hits[player.get_instance_id()] = _sequence_frame


func _tick_resurrection(delta: float) -> void:
	_refresh_downed_players(delta)
	if _resurrection_used:
		_cancel_revive_channel("utilizacao_consumida", false)
		return
	var downed := _first_revivable_player()
	if downed == null:
		_cancel_revive_channel("sem_corpo_valido", false)
		return
	var reviver := _find_reviver_for(downed)
	if reviver == null:
		_cancel_revive_channel("interaccao_ou_distancia", true)
		return
	if _reviver != reviver or _revived != downed:
		_start_revive_channel(reviver, downed)
		return
	var current_health := float(reviver.get("health"))
	if bool(_resurrection_contract.get("damage_interrupts")) \
			and current_health < _reviver_last_health:
		_cancel_revive_channel("dano", true)
		return
	_reviver_last_health = current_health
	_revive_progress += delta
	_refresh_revive_marker(downed)
	if _revive_progress >= float((_config.get("resurrection", {}) as Dictionary).get(
		"channel_seconds")):
		_complete_revive()


func _refresh_downed_players(delta: float) -> void:
	var window := float(_resurrection_contract.get("window_seconds"))
	for player: Node3D in _players:
		var id := player.get_instance_id()
		if _is_alive(player):
			if _downed_elapsed.has(id):
				_remove_revive_marker(id)
				_downed_elapsed.erase(id)
				_downed_expired.erase(id)
			continue
		if not _downed_elapsed.has(id):
			_downed_elapsed[id] = 0.0
			_downed_expired[id] = false
			_build_revive_marker(player)
		else:
			_downed_elapsed[id] = float(_downed_elapsed[id]) + delta
		if not bool(_downed_expired[id]) and float(_downed_elapsed[id]) >= window:
			_downed_expired[id] = true
			_remove_revive_marker(id)
			revive_window_expired.emit(player)
		elif not bool(_downed_expired[id]):
			_refresh_revive_marker(player)


func _first_revivable_player() -> Node3D:
	for player: Node3D in _players:
		var id := player.get_instance_id()
		if not _is_alive(player) and _downed_elapsed.has(id) and not bool(_downed_expired[id]):
			return player
	return null


func _find_reviver_for(downed: Node3D) -> Node3D:
	var radius := float(_config.get("revive_radius_m"))
	var closest: Node3D
	var closest_distance := INF
	for player: Node3D in _players:
		if player == downed or not _is_alive(player) or not _revive_intent_for(player):
			continue
		var distance := player.global_position.distance_to(downed.global_position)
		if distance <= radius and distance < closest_distance:
			closest = player
			closest_distance = distance
	return closest


func _revive_intent_for(player: Node3D) -> bool:
	var id := player.get_instance_id()
	if _revive_intents.has(id):
		return bool(_revive_intents[id])
	var action := String((_config.get("resurrection", {}) as Dictionary).get("input_action"))
	return player == _local_player and Input.is_action_pressed(action)


func _start_revive_channel(reviver: Node3D, downed: Node3D) -> void:
	_reviver = reviver
	_revived = downed
	_revive_progress = 0.0
	_reviver_last_health = float(reviver.get("health"))
	var resurrection := _config.get("resurrection", {}) as Dictionary
	if bool(resurrection.get("boss_targets_reviver")) and _boss.has_method("taunt"):
		_boss.call("taunt", reviver, float(resurrection.get("channel_seconds")))
	var sounds := resurrection.get("sound_profiles", {}) as Dictionary
	Sfx.play(String(sounds.get("begin")), downed.global_position)
	revive_channel_started.emit(reviver, downed)


func _cancel_revive_channel(reason: String, announce: bool) -> void:
	if _reviver == null and _revived == null:
		return
	if announce and is_instance_valid(_revived):
		var sounds := ((_config.get("resurrection", {}) as Dictionary).get(
			"sound_profiles", {}) as Dictionary)
		Sfx.play(String(sounds.get("cancel")), _revived.global_position)
	_reviver = null
	_revived = null
	_revive_progress = 0.0
	_reviver_last_health = 0.0
	revive_channel_cancelled.emit(reason)


func _complete_revive() -> void:
	if not is_instance_valid(_revived) or not _revived.has_method("respawn_at"):
		_cancel_revive_channel("interface_de_jogador_em_falta", true)
		return
	var player := _revived
	var mana_before: Variant = player.get("mana")
	var meditation_before: Variant = player.get("meditation_uses")
	var stamina: Object = player.get("stamina") as Object
	var stamina_before: Variant = stamina.get("current") if stamina != null else null
	player.call("respawn_at", player.global_position)
	player.set("health", float(player.get("max_health")) * float(
		_resurrection_contract.get("revived_health_fraction")))
	if mana_before != null:
		player.set("mana", mana_before)
	if meditation_before != null:
		player.set("meditation_uses", meditation_before)
	if stamina != null and stamina_before != null:
		stamina.set("current", stamina_before)
	_resurrection_used = true
	var id := player.get_instance_id()
	_downed_elapsed.erase(id)
	_downed_expired.erase(id)
	_remove_revive_marker(id)
	var sounds := ((_config.get("resurrection", {}) as Dictionary).get(
		"sound_profiles", {}) as Dictionary)
	Sfx.play(String(sounds.get("success")), player.global_position)
	_reviver = null
	_revived = null
	_revive_progress = 0.0
	_reviver_last_health = 0.0
	player_revived.emit(player)


func _build_revive_marker(player: Node3D) -> void:
	var colors := _config.get("colors", {}) as Dictionary
	var labels := _config.get("labels", {}) as Dictionary
	var root := _make_disc(
		float(_config.get("revive_radius_m")),
		Color(String(colors.get("revive"))),
		float(_config.get("guide_alpha")),
		String(labels.get("revive")))
	add_child(root)
	root.global_position = player.global_position
	var label := _first_label(root)
	_revive_markers[player.get_instance_id()] = {"root": root, "label": label}


func _refresh_revive_marker(player: Node3D) -> void:
	var marker_data := _revive_markers.get(player.get_instance_id(), {}) as Dictionary
	if marker_data.is_empty():
		return
	var root := marker_data.get("root") as Node3D
	var label := marker_data.get("label") as Label3D
	if is_instance_valid(root):
		root.global_position = player.global_position
	if is_instance_valid(label):
		var action := String((_config.get("resurrection", {}) as Dictionary).get("input_action"))
		var channel := float((_config.get("resurrection", {}) as Dictionary).get("channel_seconds"))
		label.text = "%s · %s %.1f/%.1f s" % [
			SettingsSystem.binding_label(action),
			String((_config.get("labels", {}) as Dictionary).get("revive")),
			_revive_progress,
			channel,
		]


func _remove_revive_marker(id: int) -> void:
	var marker_data := _revive_markers.get(id, {}) as Dictionary
	var root := marker_data.get("root") as Node3D
	if is_instance_valid(root):
		root.queue_free()
	_revive_markers.erase(id)


func _make_disc(radius: float, colour: Color, alpha: float, text: String) -> Node3D:
	var root := Node3D.new()
	var mesh_instance := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = float(_config.get("marker_height_m"))
	mesh.radial_segments = int(_config.get("marker_radial_segments"))
	mesh_instance.mesh = mesh
	mesh_instance.position.y = float(_config.get("marker_y_offset_m"))
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_instance.material_override = _marker_material(colour, alpha)
	root.add_child(mesh_instance)
	root.add_child(_make_label(text, colour))
	return root


func _make_rectangle(size: Vector2, colour: Color, alpha: float, text: String) -> Node3D:
	var root := Node3D.new()
	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(size.x, float(_config.get("marker_height_m")), size.y)
	mesh_instance.mesh = mesh
	mesh_instance.position.y = float(_config.get("marker_y_offset_m"))
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_instance.material_override = _marker_material(colour, alpha)
	root.add_child(mesh_instance)
	root.add_child(_make_label(text, colour))
	return root


func _make_label(text: String, colour: Color) -> Label3D:
	var label := Label3D.new()
	label.text = text
	label.font_size = int(_config.get("label_font_size"))
	label.modulate = colour
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	label.position.y = float(_config.get("label_height_m"))
	return label


func _marker_material(colour: Color, alpha: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	colour.a = alpha
	material.albedo_color = colour
	material.emission_enabled = true
	material.emission = Color(colour, 1.0)
	material.emission_energy_multiplier = float(_config.get("emission_energy"))
	return material


func _set_sequence_visuals_visible(visible_now: bool) -> void:
	for visual: Node3D in _sequence_visuals:
		if is_instance_valid(visual):
			visual.visible = visible_now


func _alive_players() -> Array[Node3D]:
	var alive: Array[Node3D] = []
	for player: Node3D in _players:
		if _is_alive(player):
			alive.append(player)
	return alive


func _is_alive(player: Node3D) -> bool:
	return is_instance_valid(player) and player.has_method("is_alive") and bool(player.call("is_alive"))


func _active_or_named_sequence(id: String) -> Dictionary:
	if String(_active_sequence.get("id", "")) == id:
		return _active_sequence
	return (((_config.get("coop_sequences", {}) as Dictionary).get(id, {})) as Dictionary)


func _vector_from_array(value: Array) -> Vector3:
	return Vector3(float(value[0]), float(value[1]), float(value[2]))


func _first_label(root: Node3D) -> Label3D:
	for child: Node in root.get_children():
		var label := child as Label3D
		if label != null:
			return label
	return null


func _count_visual_descendants(root: Node) -> Vector2i:
	var count := Vector2i.ZERO
	for child: Node in root.get_children():
		if child is MeshInstance3D:
			count.x += 1
		elif child is Label3D:
			count.y += 1
		count += _count_visual_descendants(child)
	return count
