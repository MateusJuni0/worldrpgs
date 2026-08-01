extends SceneTree
## Contrato isolado dos golpes do jogador.
##
## Corre sem editar o agregador que pertence a outro agente:
## godot --headless --audio-driver Dummy --path game/ --script res://src/player/attack_family_self_test.gd

const CONTROLLER_PATH := "res://src/player/attack_animation_controller.gd"

class MockAttackActor extends Node3D:
	var state_frame := 0
	var _atk_weapon := "longsword"
	var _atk_kind := "light"
	var _combo_index := 1
	var _sprinting := false
	var _charging := false
	var _charge_frames := 0
	var _atk: Dictionary = {}

	func state_name() -> String:
		return "ataque"

var _passed := 0
var _failed := 0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var weapon_data := _read_json("res://data/weapons.json")
	var family_ids := PackedStringArray()
	for family_value: Variant in (weapon_data.get("familias", {}) as Dictionary).keys():
		var family_id := String(family_value)
		if not family_id.begins_with("_"):
			family_ids.append(family_id)
	family_ids.sort()

	var controller_script := load(CONTROLLER_PATH) as Script
	_check(controller_script != null, "controlador de animacao dos golpes existe")
	if controller_script != null:
		var controller := controller_script.new() as Node
		var declarations: Dictionary = controller.call("declared_family_animations") as Dictionary
		for family_id: String in family_ids:
			_check(declarations.has(family_id), "%s declara animacoes" % family_id)
		_test_visible_strike_window(controller, weapon_data)
		_test_generated_motion(controller, declarations)
		await _test_playback_api(controller_script, weapon_data)
		await _test_runtime_arbitration(controller_script, weapon_data)
		controller.free()

	print("\n=== GOLPES POR FAMILIA: %d passaram, %d falharam ===" % [_passed, _failed])
	quit(0 if _failed == 0 else 1)


func _test_visible_strike_window(controller: Node, weapon_data: Dictionary) -> void:
	_check(controller.has_method("visible_strike_active"),
		"efeito visivel expoe a mesma janela da hitbox")
	if not controller.has_method("visible_strike_active"):
		return
	for weapon_value: Variant in weapon_data.values():
		if not weapon_value is Dictionary:
			continue
		var weapon := weapon_value as Dictionary
		if not weapon.has("familia"):
			continue
		for attack_kind: String in ["light", "heavy"]:
			var attack: Dictionary = weapon.get(attack_kind, {}) as Dictionary
			if attack.is_empty():
				continue
			var startup := int(attack.get("startup", 0))
			var active := int(attack.get("active", 0))
			var recovery := int(attack.get("recovery", 0))
			var matches := true
			for frame: int in startup + active + recovery + 1:
				var hitbox_active := frame > startup and frame <= startup + active
				var effect_active := bool(controller.call(
					"visible_strike_active", frame, attack))
				if effect_active != hitbox_active:
					matches = false
					break
			_check(matches, "%s/%s: efeito e hitbox vivem nos mesmos frames" % [
				String(weapon.get("display_name", "arma")), attack_kind])
			if bool(attack.get("chargeable", false)):
				var charge_frames := int(attack.get("charge_max_frames", 0))
				var charged_matches := true
				for frame: int in startup + charge_frames + active + recovery + 1:
					var charged_hitbox := frame > startup + charge_frames \
						and frame <= startup + charge_frames + active
					var charged_effect := bool(controller.call(
						"visible_strike_active", frame, attack, charge_frames))
					if charged_effect != charged_hitbox:
						charged_matches = false
						break
				_check(charged_matches,
					"%s/%s carregado: aviso prolonga-se sem abrir a hitbox" % [
						String(weapon.get("display_name", "arma")), attack_kind])


func _test_generated_motion(controller: Node, declarations: Dictionary) -> void:
	_check(controller.has_method("build_attack_animation"),
		"controlador sintetiza curvas de ossos, nao apenas velocidades")
	if not controller.has_method("build_attack_animation"):
		return
	var equipment := _read_json("res://data/equipment.json")
	var movesets: Dictionary = equipment.get("family_movesets", {}) as Dictionary
	var packed := load("res://assets/models/animations/quaternius/UAL1_Standard.glb") as PackedScene
	_check(packed != null, "biblioteca UAL CC0 e importavel")
	if packed == null:
		return
	var source_root := packed.instantiate()
	var source_player := _find_animation_player(source_root)
	_check(source_player != null, "biblioteca UAL expoe AnimationPlayer")
	if source_player == null:
		source_root.free()
		return
	for family_id: String in declarations:
		var family: Dictionary = declarations[family_id] as Dictionary
		_check(String((family.get("em_corrida", {}) as Dictionary).get("source_clip", "")) \
			!= String((family.get("leve_1", {}) as Dictionary).get("source_clip", "")),
			"%s/corrida traz locomocao, nao e o leve acelerado" % family_id)
		var signatures := {}
		for action_id: String in ["leve_1", "leve_2", "pesado", "em_corrida"]:
			_check(family.has(action_id), "%s/%s: declarada" % [family_id, action_id])
			if not family.has(action_id):
				continue
			var profile: Dictionary = family[action_id] as Dictionary
			var source_clip := String(profile.get("source_clip", ""))
			_check(source_player.has_animation(source_clip),
				"%s/%s: clip-base '%s' existe na UAL" % [family_id, action_id, source_clip])
			if not source_player.has_animation(source_clip):
				continue
			var moveset: Dictionary = movesets.get(family_id, {}) as Dictionary
			var attack_key := "pesado" if action_id == "pesado" else "leve"
			var attack: Dictionary = moveset.get(attack_key, {}) as Dictionary
			var generated := controller.call("build_attack_animation",
				source_player.get_animation(source_clip), family_id, action_id, attack) as Animation
			_check(generated != null, "%s/%s: gera Animation" % [family_id, action_id])
			if generated != null:
				_check(_has_exact_attack_window_keys(generated, attack),
					"%s/%s: arco ofensivo usa os limites dos dados" % [family_id, action_id])
				signatures[_rotation_signature(generated)] = true
		_check(signatures.size() == 4,
			"%s: leve 1, leve 2, pesado e corrida movem ossos de quatro formas" % family_id)
	source_root.free()


func _test_playback_api(controller_script: Script, weapon_data: Dictionary) -> void:
	var controller := controller_script.new() as Node
	_check(controller.has_method("setup") and controller.has_method("play_attack"),
		"Player recebe uma API pequena para ligar os golpes")
	if not controller.has_method("setup") or not controller.has_method("play_attack"):
		controller.free()
		return
	var actor := Node3D.new()
	root.add_child(actor)
	var visual := CharacterVisual.new()
	actor.add_child(visual)
	var combat := _read_json("res://data/combat.json")
	visual.setup(float((combat.get("player", {}) as Dictionary).get("capsule_height", 0.0)),
		Color.WHITE, false, "body_male", "warrior")
	actor.add_child(controller)
	_check(bool(controller.call("setup", actor, visual)),
		"controlador liga-se ao AnimationPlayer Quaternius")
	var weapon: Dictionary = weapon_data.get("longsword", {}) as Dictionary
	var played := PackedStringArray()
	for request: Dictionary in [
			{"kind": "light", "combo": 1, "running": false},
			{"kind": "light", "combo": 2, "running": false},
			{"kind": "heavy", "combo": 0, "running": false},
			{"kind": "light", "combo": 1, "running": true}]:
		var attack_key := "heavy" if String(request["kind"]) == "heavy" else "light"
		var played_name := String(controller.call("play_attack", "longsword",
			String(request["kind"]), int(request["combo"]), bool(request["running"]),
			weapon.get(attack_key, {}) as Dictionary))
		_check(not played_name.is_empty(), "playback aceita %s" % str(request))
		played.append(played_name)
	_check(_unique_strings(played) == played.size(),
		"leve 1, leve 2, pesado e corrida tocam recursos diferentes")
	var charged_attack: Dictionary = (weapon_data.get("greataxe", {}) as Dictionary).get(
		"heavy", {}) as Dictionary
	controller.call("play_attack", "greataxe", "heavy", 0, false, charged_attack)
	var animation_player := _find_animation_player(visual)
	var charge_start := int(charged_attack.get("startup", 0))
	controller.call("_sync_charge_hold", charge_start, charged_attack, true)
	_check(animation_player != null and not animation_player.is_playing(),
		"pesado carregado congela a animacao no fim do aviso")
	if animation_player != null:
		var ticks_per_second := float(ProjectSettings.get_setting(
			"physics/common/physics_ticks_per_second"))
		_check(is_equal_approx(animation_player.current_animation_position,
			float(charge_start) / ticks_per_second),
			"pose carregada fica exactamente no limite de startup")
	controller.call("_sync_charge_hold", charge_start, charged_attack, false)
	_check(animation_player != null and animation_player.is_playing(),
		"largar o pesado retoma o arco ofensivo")
	await process_frame
	actor.free()


func _test_runtime_arbitration(controller_script: Script, weapon_data: Dictionary) -> void:
	var actor := MockAttackActor.new()
	root.add_child(actor)
	var visual := CharacterVisual.new()
	actor.add_child(visual)
	var combat := _read_json("res://data/combat.json")
	visual.setup(float((combat.get("player", {}) as Dictionary).get("capsule_height", 0.0)),
		Color.WHITE, false, "body_male", "warrior")
	var controller := controller_script.new() as Node
	actor.add_child(controller)
	controller.call("setup", actor, visual)
	actor._atk = (weapon_data.get("longsword", {}) as Dictionary).get("light", {}) as Dictionary
	controller.call("_process", 0.0)
	var animation_player := _find_animation_player(visual)
	var first_playback: String = animation_player.assigned_animation \
		if animation_player != null else ""
	_check(first_playback.begins_with("weapon_attacks/"),
		"estado ATTACK escolhe o recurso da familia")

	actor.state_frame = int(actor._atk.get("startup", 0)) + 1
	visual.play_animation("Sword_Attack")
	controller.call("_process", 0.0)
	_check(animation_player != null and animation_player.assigned_animation == first_playback,
		"controlador vence o Sword_Attack generico do Player sem reiniciar o golpe")
	if animation_player != null:
		var ticks_per_second := float(ProjectSettings.get_setting(
			"physics/common/physics_ticks_per_second"))
		_check(is_equal_approx(animation_player.current_animation_position,
			float(actor.state_frame) / ticks_per_second),
			"pose visual segue o state_frame autoritativo")

	actor.state_frame = 0
	actor._sprinting = true
	controller.call("_process", 0.0)
	var running_playback: String = animation_player.assigned_animation \
		if animation_player != null else ""
	actor.state_frame = 1
	actor._sprinting = false
	visual.play_animation("Sword_Attack")
	controller.call("_process", 0.0)
	_check(animation_player != null and animation_player.assigned_animation == running_playback \
		and "em_corrida" in running_playback,
		"corrida fica presa ao inicio do golpe mesmo depois de largar Space")
	await process_frame
	actor.free()


func _has_exact_attack_window_keys(animation: Animation, attack: Dictionary) -> bool:
	var ticks_per_second := float(ProjectSettings.get_setting(
		"physics/common/physics_ticks_per_second"))
	var startup_s := float(int(attack.get("startup", 0))) / ticks_per_second
	var active_end_s := float(int(attack.get("startup", 0)) \
		+ int(attack.get("active", 0))) / ticks_per_second
	for track: int in animation.get_track_count():
		if animation.track_get_type(track) != Animation.TYPE_ROTATION_3D:
			continue
		if not String(animation.track_get_path(track)).ends_with(":upperarm_r"):
			continue
		var has_startup := false
		var has_active_end := false
		for key: int in animation.track_get_key_count(track):
			var time := animation.track_get_key_time(track, key)
			has_startup = has_startup or is_equal_approx(time, startup_s)
			has_active_end = has_active_end or is_equal_approx(time, active_end_s)
		return has_startup and has_active_end
	return false


func _unique_strings(values: PackedStringArray) -> int:
	var unique := {}
	for value: String in values:
		unique[value] = true
	return unique.size()


func _rotation_signature(animation: Animation) -> String:
	var values := PackedStringArray()
	for track: int in animation.get_track_count():
		if animation.track_get_type(track) != Animation.TYPE_ROTATION_3D:
			continue
		var path := String(animation.track_get_path(track))
		if not ("spine_03" in path or "upperarm_" in path or "lowerarm_" in path):
			continue
		values.append(path)
		for key: int in animation.track_get_key_count(track):
			values.append(str(animation.track_get_key_value(track, key)))
	return "|".join(values)


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child: Node in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null


func _read_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	return parsed as Dictionary if parsed is Dictionary else {}


func _check(condition: bool, label: String) -> void:
	if condition:
		_passed += 1
		print("  ok    ", label)
	else:
		_failed += 1
		printerr("  FALHA ", label)
