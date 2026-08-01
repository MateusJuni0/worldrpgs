class_name Bonfire
extends Node
## Controlador sem geometria: a fogueira visivel continua a ser construida pelo
## mundo; este no concentra a unica transaccao de descanso, nivel e Brasa.

signal rest_completed(result: Dictionary)
signal operation_failed(result: Dictionary)
signal level_purchased(result: Dictionary)
signal ember_kindled(result: Dictionary)

const ProgressionRuntime = preload("res://src/progression/progression_runtime.gd")
const ProgressionAudio = preload("res://src/progression/progression_audio.gd")

var zone_id := ""
var rest_point_id := ""
var _audio: AudioStreamPlayer


func configure(p_zone_id: String, p_rest_point_id: String) -> void:
	zone_id = p_zone_id
	rest_point_id = p_rest_point_id


func input_action() -> String:
	var config := _progression_config("bonfire")
	return String(config.get("input_action", ""))


func process_input(player: Node, enemies: Array) -> Dictionary:
	var action := input_action()
	if action.is_empty() or not Input.is_action_just_pressed(action):
		return {"status": "idle"}
	return rest(player, enemies)


func rest(player: Node, enemies: Array) -> Dictionary:
	if zone_id.is_empty() or rest_point_id.is_empty() or player == null:
		return _fail({"status": "invalid_bonfire"})
	var dead_placements: Array[String] = []
	for enemy_value: Variant in enemies:
		var enemy := enemy_value as Node
		if enemy == null or _is_boss(enemy) or _is_alive(enemy):
			continue
		var placement_id := String(enemy.get_meta("placement_id", ""))
		if placement_id.is_empty():
			return _fail({"status": "missing_placement_id"})
		dead_placements.append(placement_id)
	var result := ProgressionRuntime.commit_rest(
		zone_id, rest_point_id, dead_placements)
	if String(result.get("status", "")) != "rested":
		return _fail(result)
	apply_rest_effects(player, enemies, result)
	_play_audio("rest_audio")
	rest_completed.emit(result)
	return result


func apply_rest_effects(player: Node, enemies: Array, result: Dictionary) -> void:
	if player == null or String(result.get("status", "")) != "rested":
		return
	_restore_player(player)
	_prepare_audio("rest_audio")
	var respawned: Array = result.get("respawned", []) as Array
	for enemy_value: Variant in enemies:
		var enemy := enemy_value as Node
		if enemy == null or _is_boss(enemy) or not enemy.has_method("full_reset"):
			continue
		var placement_id := String(enemy.get_meta("placement_id", ""))
		if not placement_id.begins_with("%s:" % zone_id):
			continue
		if _is_alive(enemy) or placement_id in respawned:
			enemy.call("full_reset")


func level_up(attribute_id: String) -> Dictionary:
	var result := ProgressionRuntime.commit_level_up(attribute_id)
	if String(result.get("status", "")) == "purchased":
		level_purchased.emit(result)
	else:
		operation_failed.emit(result)
	return result


func kindle_ember(enemies: Array, zone_boss_ids: Array) -> Dictionary:
	var placement_ids: Array[String] = []
	for enemy_value: Variant in enemies:
		var enemy := enemy_value as Node
		if enemy == null:
			continue
		var placement_id := String(enemy.get_meta("placement_id", ""))
		if not placement_id.is_empty() and placement_id.begins_with("%s:" % zone_id):
			placement_ids.append(placement_id)
	var result := ProgressionRuntime.commit_ember(zone_id, placement_ids, zone_boss_ids)
	if String(result.get("status", "")) != "kindled":
		return _fail(result)
	for enemy_value: Variant in enemies:
		var enemy := enemy_value as Node
		if enemy != null and enemy.has_method("full_reset"):
			var enemy_id := String(enemy.get("enemy_id"))
			if not _is_boss(enemy) or enemy_id in zone_boss_ids:
				enemy.call("full_reset")
	_play_audio("ember_audio")
	ember_kindled.emit(result)
	return result


func _restore_player(player: Node) -> void:
	player.set("health", player.get("max_health"))
	var stamina: Variant = player.get("stamina")
	if stamina != null and stamina.has_method("refill"):
		stamina.call("refill")
	player.set("mana", player.get("max_mana"))
	if player.has_method("flask_refill"):
		player.call("flask_refill")


func _is_alive(enemy: Node) -> bool:
	return bool(enemy.call("is_alive")) if enemy.has_method("is_alive") else true


func _is_boss(enemy: Node) -> bool:
	return bool(enemy.get("is_boss"))


func _fail(result: Dictionary) -> Dictionary:
	operation_failed.emit(result)
	return result


func _play_audio(config_key: String) -> void:
	_prepare_audio(config_key)
	if _audio != null:
		_audio.play()


func _prepare_audio(config_key: String) -> void:
	var config := _progression_config("bonfire").get(config_key, {}) as Dictionary
	if config.is_empty():
		return
	if _audio == null:
		_audio = AudioStreamPlayer.new()
		_audio.name = "BonfireAudio"
		_audio.bus = "Efeitos"
		add_child(_audio)
	_audio.stream = ProgressionAudio.make_chirp(config)
	_audio.volume_db = float(config.get("volume_db", 0.0))


func _progression_config(section_name: String) -> Dictionary:
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null:
		return {}
	var game_data := tree.root.get_node_or_null("GameData")
	if game_data == null:
		return {}
	var progression_data: Dictionary = game_data.get("progression") as Dictionary
	return progression_data.get(section_name, {}) as Dictionary
