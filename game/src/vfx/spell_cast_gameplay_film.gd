extends Node
## Prova visual do fio completo: cena real, Player real, mundo real e a accao
## remapeavel `cast`. Com --capture-cast-film grava o lancamento amostrado de
## dois em dois frames em res://captures/filme-magia/.

const GAMEPLAY_SCENE := preload("res://scenes/gameplay.tscn")
const CAPTURE_ARG := "--capture-cast-film"
const TEST_PROFILE_ID := "filme-magia-custo-visivel"
const TEST_SLOT_MIN := 13000
const TEST_SLOT_MAX := 13999
const SAMPLE_INTERVAL_FRAMES := 2

var _previous_state: Dictionary = {}
var _previous_scene_arg := ""
var _previous_slot := -1
var _test_slot := -1
var _gameplay: Node3D
var _camera: Camera3D
var _failures: Array[String] = []
var _capture_index := 0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Engine.max_physics_steps_per_frame = 1
	call_deferred("_run")


func _run() -> void:
	_previous_state = GameData.save_state_snapshot()
	_previous_scene_arg = Bench.scene_arg
	_previous_slot = SaveSystem.active_slot
	_test_slot = _find_unused_test_slot()
	if _test_slot < 0:
		_fail("nao encontrou slot temporario livre")
		await _finish()
		return
	SaveSystem.active_slot = _test_slot
	var test_state := SaveSystem.create_save(TEST_PROFILE_ID, "evil_mage")
	var character: Dictionary = test_state.get("character", {}) as Dictionary
	var inventory: Dictionary = character.get("inventory", {}) as Dictionary
	var equipment: Dictionary = inventory.get("equipment", {}) as Dictionary
	if equipment.get("offhand") == null:
		equipment["offhand"] = ""
	GameData.replace_save_state(test_state)
	Bench.scene_arg = "combat"

	_gameplay = GAMEPLAY_SCENE.instantiate()
	add_child(_gameplay)
	var benchmark := _benchmark_profile()
	DisplayServer.window_set_size(Vector2i(int(benchmark.get("width", 1920)),
		int(benchmark.get("height", 1080))))
	for _frame: int in int(benchmark.get("capture_frame", 90)):
		await get_tree().physics_frame

	var player := _gameplay.get("player") as Player
	if not is_instance_valid(player):
		_fail("a cena real nao criou o jogador")
		await _finish()
		return
	var spell_id := _first_red_spell(player)
	if not spell_id.is_empty() and not player.favorite_spells.has(spell_id):
		player.favorite_spells.append(spell_id)
	if spell_id.is_empty() or not player.select_spell(spell_id):
		_fail("o Mago do Mal real nao trouxe magia vermelha seleccionavel")
		await _finish()
		return
	var spell := GameData.spell(spell_id)
	var enemy := _first_live_enemy()
	if not is_instance_valid(enemy):
		_fail("o mundo real nao criou inimigo para receber o disparo")
		await _finish()
		return
	for node: Node in get_tree().get_nodes_in_group("enemies"):
		if node is Enemy:
			(node as Enemy).set_physics_process(false)

	# Primeiro faz o que o jogador faria ao chegar: anda e so depois carrega C.
	Input.action_press("move_forward")
	for _frame: int in SAMPLE_INTERVAL_FRAMES * 3:
		await get_tree().physics_frame
	Input.action_release("move_forward")
	await get_tree().physics_frame

	var forward := -player.global_transform.basis.z.normalized()
	enemy.global_position = player.global_position + forward * minf(float(
		spell.get("range_m", spell.get("max_range", 0.0))) * 0.35, 5.0)
	player.lock_on.target = enemy
	_camera = Camera3D.new()
	_camera.fov = 52.0
	add_child(_camera)
	_camera.make_current()
	_look_at_cast(player)
	await get_tree().process_frame

	var expected_clips := _casting_phase_clips()
	var seen_clips: Dictionary = {}
	var saw_pre_release_light := false
	var saw_body_price := false
	var saw_delivery := false
	var health_before := player.health
	Input.action_press("cast")
	await get_tree().physics_frame
	Input.action_release("cast")
	await get_tree().physics_frame
	if player.state != Player.State.CASTING:
		_fail("carregar na accao cast nao iniciou a conjuracao")

	var recover_frames := int((_phase_profile("recover")).get("phase_frames", 0))
	var film_frames := int(float(spell.get("cast_time", 0.0)) * float(
		Engine.physics_ticks_per_second)) + recover_frames + SAMPLE_INTERVAL_FRAMES * 4
	for film_frame: int in film_frames:
		await get_tree().physics_frame
		var visual := player.get("_visual") as CharacterVisual
		var current_clip := visual.current_animation_name() if visual != null else ""
		for role: String in expected_clips:
			if current_clip == String(expected_clips[role]):
				seen_clips[role] = true
		var flash := _latest_group_node("spell_cast_vfx")
		var delivery := _latest_group_node("spell_deliveries")
		if is_instance_valid(flash):
			var flash_phase := String(flash.call("cast_phase"))
			if flash_phase in ["prepare", "hold"] and not is_instance_valid(delivery):
				saw_pre_release_light = saw_pre_release_light \
					or bool(flash.call("is_instrument_lit"))
			saw_body_price = saw_body_price \
				or bool(flash.call("is_body_price_visible"))
		if is_instance_valid(delivery):
			var delivery_vfx := delivery.get_node_or_null(
				NodePath("SpellVfx_%s" % spell_id))
			if delivery_vfx != null and delivery_vfx.has_method("rendered_instance_count"):
				saw_delivery = saw_delivery \
					or int(delivery_vfx.call("rendered_instance_count")) > 0
		if CAPTURE_ARG in OS.get_cmdline_user_args() \
				and film_frame % SAMPLE_INTERVAL_FRAMES == 0:
			await _capture(player, film_frame, current_clip,
				String(flash.call("cast_phase")) if is_instance_valid(flash) else "voo")

	for role: String in expected_clips:
		if not seen_clips.has(role):
			_fail("o filme nao mostrou a fase %s (%s)" % [role, expected_clips[role]])
	if not saw_pre_release_light:
		_fail("o instrumento nao acendeu antes de existir disparo")
	if not saw_body_price:
		_fail("a escola vermelha nao mostrou o preco a sair do corpo")
	if not saw_delivery:
		_fail("a magia nao saiu do instrumento para o mundo")

	print("[filme-magia] fases vistas: %s" % JSON.stringify(seen_clips))
	print("[filme-magia] instrumento antes do disparo=%s; corpo vermelho=%s; voo=%s" % [
		str(saw_pre_release_light), str(saw_body_price), str(saw_delivery)])
	if player.health >= health_before:
		print("[filme-magia] LACUNA: o sinal corporal apareceu, mas esta ficha nao descontou PV")
	else:
		print("[filme-magia] PV visiveis: %.1f -> %.1f" % [health_before, player.health])
	await _finish()


func _capture(player: Player, film_frame: int, clip: String, phase: String) -> void:
	_look_at_cast(player)
	get_tree().paused = true
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var directory := ProjectSettings.globalize_path("res://captures/filme-magia/")
	DirAccess.make_dir_recursive_absolute(directory)
	var path := "%smagia-%02d.png" % [directory, _capture_index]
	var error := get_viewport().get_texture().get_image().save_png(path)
	print("[filme-magia] %02d frame=%d fase=%s clip=%s captura=%s" % [
		_capture_index, film_frame, phase, clip, "OK" if error == OK else error_string(error)])
	_capture_index += 1
	get_tree().paused = false


func _look_at_cast(player: Player) -> void:
	var centre := player.global_position + Vector3.UP * 1.25
	var forward := -player.global_transform.basis.z
	var right := player.global_transform.basis.x
	_camera.look_at_from_position(centre - forward * 2.7 + right * 1.15 \
		+ Vector3.UP * 0.3, centre + forward * 0.35)


func _casting_phase_clips() -> Dictionary:
	var result := {}
	var states: Dictionary = ((_animation_catalogue().get("player", {}) as Dictionary).get(
		"states", {}) as Dictionary)
	for state_key: String in states:
		var profile := states.get(state_key, {}) as Dictionary
		var role := String(profile.get("cast_phase", ""))
		if not role.is_empty():
			result[role] = String(profile.get("clip", ""))
	return result


func _phase_profile(role: String) -> Dictionary:
	var states: Dictionary = ((_animation_catalogue().get("player", {}) as Dictionary).get(
		"states", {}) as Dictionary)
	for state_key: String in states:
		var profile := states.get(state_key, {}) as Dictionary
		if String(profile.get("cast_phase", "")) == role:
			return profile
	return {}


func _animation_catalogue() -> Dictionary:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(
		"res://data/animations.json"))
	return parsed as Dictionary if parsed is Dictionary else {}


func _benchmark_profile() -> Dictionary:
	return ((GameData.spells.get("_vfx", {}) as Dictionary).get(
		"benchmark", {}) as Dictionary)


func _first_red_spell(player: Player) -> String:
	for spell_id: String in player.favorite_spells:
		if String(GameData.spell(spell_id).get("school", "")) == "mal":
			return spell_id
	var origin: Dictionary = GameData.class_attributes(player.class_id)
	for spell_value: Variant in origin.get("starting_spells", []):
		var spell_id := String(spell_value)
		if String(GameData.spell(spell_id).get("school", "")) == "mal":
			return spell_id
	return ""


func _first_live_enemy() -> Enemy:
	for node: Node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy != null and enemy.is_alive() and not enemy.is_boss:
			return enemy
	return null


func _latest_group_node(group_name: StringName) -> Node3D:
	var nodes := get_tree().get_nodes_in_group(group_name)
	for index: int in range(nodes.size() - 1, -1, -1):
		var node := nodes[index] as Node3D
		if is_instance_valid(node) and not node.is_queued_for_deletion():
			return node
	return null


func _fail(message: String) -> void:
	_failures.append(message)
	printerr("[filme-magia] FALHOU: %s" % message)


func _finish() -> void:
	Input.action_release("move_forward")
	Input.action_release("cast")
	get_tree().paused = false
	if is_instance_valid(_gameplay):
		_gameplay.queue_free()
	await get_tree().process_frame
	await get_tree().process_frame
	_cleanup_test_slot()
	GameData.replace_save_state(_previous_state)
	SaveSystem.active_slot = _previous_slot
	Bench.scene_arg = _previous_scene_arg
	if _failures.is_empty():
		print("=== FILME MAGIA: QUATRO FASES VISIVEIS ===")
	else:
		printerr("=== FILME MAGIA: %d FALHAS ===" % _failures.size())
	get_tree().quit(0 if _failures.is_empty() else 1)


func _find_unused_test_slot() -> int:
	for candidate: int in range(TEST_SLOT_MIN, TEST_SLOT_MAX + 1):
		var path := SaveSystem.slot_path(candidate)
		if not FileAccess.file_exists(path) and not FileAccess.file_exists(path + ".bak") \
				and not FileAccess.file_exists(path + ".tmp"):
			return candidate
	return -1


func _cleanup_test_slot() -> void:
	if _test_slot < TEST_SLOT_MIN or _test_slot > TEST_SLOT_MAX:
		return
	var path := SaveSystem.slot_path(_test_slot)
	for suffix: String in ["", ".tmp", ".bak", ".corrupt"]:
		var candidate := path + suffix
		if not FileAccess.file_exists(candidate):
			continue
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(candidate))
		if parsed is Dictionary:
			var character: Dictionary = (parsed as Dictionary).get(
				"character", {}) as Dictionary
			if String(character.get("profile_id", "")) != TEST_PROFILE_ID:
				push_error("[filme-magia] recusa limpar slot temporario de outro perfil")
				continue
		DirAccess.remove_absolute(ProjectSettings.globalize_path(candidate))
