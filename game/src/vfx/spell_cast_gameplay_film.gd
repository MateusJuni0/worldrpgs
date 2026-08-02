extends Node
## Prova visual do fio completo: cena real, Player real, mundo real e a accao
## remapeavel `cast`. Com --capture-cast-film grava cada frame do lancamento em
## res://captures/filme-magia/.

const GAMEPLAY_SCENE := preload("res://scenes/gameplay.tscn")
const CAPTURE_ARG := "--capture-cast-film"
const CAPTURE_DIR_ENV := "WORLDRPGS_PROOF_CAPTURE_DIR"
const TEST_PROFILE_ID := "filme-magia-custo-visivel"
const TEST_SLOT_MIN := 13000
const TEST_SLOT_MAX := 13999
const CAPTURE_INTERVAL_FRAMES := 1
const PIXEL_ANALYSIS_INTERVAL_FRAMES := 2
const WALK_INPUT_FRAMES := 6
const POST_RECOVERY_FRAMES := 8
const TIP_SAMPLE_RADIUS_PX := 86.0
const BODY_SAMPLE_RADIUS_PX := 118.0
const FLIGHT_SAMPLE_RADIUS_PX := 34.0
const PIXEL_SAMPLE_STEP := 4
const MIN_TIP_RED_DELTA_PIXELS := 100
const MIN_BODY_RED_DELTA_PIXELS := 50
const MIN_FLIGHT_RED_DELTA_PIXELS := 40

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
	if DisplayServer.get_name().to_lower() == "headless":
		printerr("[filme-magia] FALHOU: a prova por pixels exige o renderer Mobile real")
		get_tree().quit(1)
		return
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
	for _frame: int in WALK_INPUT_FRAMES:
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
	await RenderingServer.frame_post_draw
	var baseline_image := get_viewport().get_texture().get_image()

	var expected_clips := _casting_phase_clips()
	var seen_clips: Dictionary = {}
	var rendered_phase_frames: Dictionary = {}
	var best_pre_release_tip_red_delta := 0
	var best_pre_release_body_red_delta := 0
	var best_flight_red_delta := 0
	var cast_tip_screen := Vector2.ZERO
	var has_cast_tip_screen := false
	var health_before := player.health
	Input.action_press("cast")
	await get_tree().physics_frame
	Input.action_release("cast")
	await get_tree().physics_frame
	if player.state != Player.State.CASTING:
		_fail("carregar na accao cast nao iniciou a conjuracao")

	var recover_frames := int((_phase_profile("recover")).get("phase_frames", 0))
	var film_frames := int(float(spell.get("cast_time", 0.0)) * float(
		Engine.physics_ticks_per_second)) + recover_frames + POST_RECOVERY_FRAMES
	for film_frame: int in film_frames:
		await get_tree().physics_frame
		var visual := player.get("_visual") as CharacterVisual
		var current_clip := visual.current_animation_name() if visual != null else ""
		for role: String in expected_clips:
			if current_clip == String(expected_clips[role]):
				seen_clips[role] = true
		var flash := _latest_group_node("spell_cast_vfx")
		var delivery := _latest_group_node("spell_deliveries")
		var flash_phase := String(flash.call("cast_phase")) \
			if is_instance_valid(flash) else "voo"
		if is_instance_valid(flash):
			cast_tip_screen = _camera.unproject_position(
				flash.call("tip_position") as Vector3)
			has_cast_tip_screen = true
		var should_capture := CAPTURE_ARG in OS.get_cmdline_user_args() \
			and film_frame % CAPTURE_INTERVAL_FRAMES == 0
		var should_analyse := film_frame % PIXEL_ANALYSIS_INTERVAL_FRAMES == 0
		if should_capture or should_analyse:
			var frame_image: Image
			if should_capture:
				frame_image = await _capture(player, film_frame, current_clip, flash_phase)
			else:
				await RenderingServer.frame_post_draw
				frame_image = get_viewport().get_texture().get_image()
			if frame_image != null and not frame_image.is_empty():
				for role: String in expected_clips:
					if current_clip == String(expected_clips[role]):
						rendered_phase_frames[role] = true
				if should_analyse:
					var body_screen := _camera.unproject_position(
						player.global_position + Vector3.UP * 1.15)
					if flash_phase in ["prepare", "hold"] \
							and not is_instance_valid(delivery):
						best_pre_release_body_red_delta = maxi(
							best_pre_release_body_red_delta,
							_red_circle_score(frame_image, body_screen, BODY_SAMPLE_RADIUS_PX)
							- _red_circle_score(baseline_image, body_screen,
								BODY_SAMPLE_RADIUS_PX))
					if has_cast_tip_screen:
						if flash_phase in ["prepare", "hold"] \
								and not is_instance_valid(delivery):
							best_pre_release_tip_red_delta = maxi(
								best_pre_release_tip_red_delta,
								_red_circle_score(frame_image, cast_tip_screen,
									TIP_SAMPLE_RADIUS_PX)
								- _red_circle_score(baseline_image, cast_tip_screen,
									TIP_SAMPLE_RADIUS_PX))
						if is_instance_valid(delivery):
							var enemy_screen := _camera.unproject_position(
								enemy.global_position + Vector3.UP * 1.0)
							var flight_start := cast_tip_screen.lerp(enemy_screen, 0.2)
							var flight_end := cast_tip_screen.lerp(enemy_screen, 0.8)
							best_flight_red_delta = maxi(best_flight_red_delta,
								_red_capsule_score(frame_image, flight_start, flight_end,
									FLIGHT_SAMPLE_RADIUS_PX)
								- _red_capsule_score(baseline_image, flight_start, flight_end,
									FLIGHT_SAMPLE_RADIUS_PX))

	for role: String in expected_clips:
		if not seen_clips.has(role):
			_fail("o filme nao mostrou a fase %s (%s)" % [role, expected_clips[role]])
		elif not rendered_phase_frames.has(role):
			_fail("a fase %s existiu internamente mas nao chegou a um frame renderizado" % role)
	if best_pre_release_tip_red_delta < MIN_TIP_RED_DELTA_PIXELS:
		_fail("os pixels do instrumento nao acenderam antes do disparo (%d < %d)" % [
			best_pre_release_tip_red_delta, MIN_TIP_RED_DELTA_PIXELS])
	if best_pre_release_body_red_delta < MIN_BODY_RED_DELTA_PIXELS:
		_fail("os pixels vermelhos nao mostraram o preco antes do disparo (%d < %d)" % [
			best_pre_release_body_red_delta, MIN_BODY_RED_DELTA_PIXELS])
	if best_flight_red_delta < MIN_FLIGHT_RED_DELTA_PIXELS:
		_fail("nenhum disparo vermelho ficou visivel entre instrumento e alvo (%d < %d)" % [
			best_flight_red_delta, MIN_FLIGHT_RED_DELTA_PIXELS])

	print("[filme-magia] fases vistas: %s" % JSON.stringify(seen_clips))
	print("[filme-magia] pixels vermelhos novos: instrumento=%d; corpo=%d; voo=%d" % [
		best_pre_release_tip_red_delta, best_pre_release_body_red_delta,
		best_flight_red_delta])
	if player.health >= health_before:
		print("[filme-magia] LACUNA: o sinal corporal apareceu, mas esta ficha nao descontou PV")
	else:
		print("[filme-magia] PV visiveis: %.1f -> %.1f" % [health_before, player.health])
	await _finish()


func _capture(player: Player, film_frame: int, clip: String, phase: String) -> Image:
	_look_at_cast(player)
	get_tree().paused = true
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var directory := OS.get_environment(CAPTURE_DIR_ENV)
	if directory.is_empty():
		directory = ProjectSettings.globalize_path("res://captures/filme-magia")
	DirAccess.make_dir_recursive_absolute(directory)
	var path := directory.path_join("magia-%02d.png" % _capture_index)
	var frame_image := get_viewport().get_texture().get_image()
	var error := frame_image.save_png(path)
	print("[filme-magia] %02d frame=%d fase=%s clip=%s captura=%s" % [
		_capture_index, film_frame, phase, clip, "OK" if error == OK else error_string(error)])
	_capture_index += 1
	get_tree().paused = false
	return frame_image


func _red_circle_score(image: Image, centre: Vector2, radius: float) -> int:
	var min_x := clampi(floori(centre.x - radius), 0, image.get_width() - 1)
	var max_x := clampi(ceili(centre.x + radius), 0, image.get_width() - 1)
	var min_y := clampi(floori(centre.y - radius), 0, image.get_height() - 1)
	var max_y := clampi(ceili(centre.y + radius), 0, image.get_height() - 1)
	var radius_squared := radius * radius
	var score := 0
	for y: int in range(min_y, max_y + 1, PIXEL_SAMPLE_STEP):
		for x: int in range(min_x, max_x + 1, PIXEL_SAMPLE_STEP):
			if Vector2(float(x), float(y)).distance_squared_to(centre) > radius_squared:
				continue
			if _is_red_energy(image.get_pixel(x, y)):
				score += 1
	return score


func _red_capsule_score(image: Image, from: Vector2, to: Vector2,
		radius: float) -> int:
	var min_x := clampi(floori(minf(from.x, to.x) - radius), 0,
		image.get_width() - 1)
	var max_x := clampi(ceili(maxf(from.x, to.x) + radius), 0,
		image.get_width() - 1)
	var min_y := clampi(floori(minf(from.y, to.y) - radius), 0,
		image.get_height() - 1)
	var max_y := clampi(ceili(maxf(from.y, to.y) + radius), 0,
		image.get_height() - 1)
	var radius_squared := radius * radius
	var score := 0
	for y: int in range(min_y, max_y + 1, PIXEL_SAMPLE_STEP):
		for x: int in range(min_x, max_x + 1, PIXEL_SAMPLE_STEP):
			var point := Vector2(float(x), float(y))
			if _distance_squared_to_segment(point, from, to) > radius_squared:
				continue
			if _is_red_energy(image.get_pixel(x, y)):
				score += 1
	return score


func _distance_squared_to_segment(point: Vector2, from: Vector2, to: Vector2) -> float:
	var segment := to - from
	var length_squared := segment.length_squared()
	if length_squared <= 0.0:
		return point.distance_squared_to(from)
	var amount := clampf((point - from).dot(segment) / length_squared, 0.0, 1.0)
	return point.distance_squared_to(from + segment * amount)


func _is_red_energy(color: Color) -> bool:
	return color.r >= 0.18 and color.r - maxf(color.g, color.b) >= 0.07


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
