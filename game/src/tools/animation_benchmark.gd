extends SceneTree
## Benchmark reproduzivel da Lei 4.
##
## O modo historico `isolated` mede varias copias do mesmo esqueleto. O modo
## `hot-gameplay` arranca a cena principal, conserva o mundo/HUD/IA reais,
## completa o encontro ate ao tecto descoberto nos catalogos e conduz o jogador
## pelas accoes declaradas em graphics.json. Assim a prova mede o fio que chega
## ao ecra, nao apenas uma classe isolada.
##
## Exemplos:
##   godot --path game --rendering-method mobile --script \
##     res://src/tools/animation_benchmark.gd -- --mode=isolated --actors=5
##   godot --path game --rendering-method mobile --script \
##     res://src/tools/animation_benchmark.gd -- --mode=hot-gameplay \
##     --vsync=off --engine-cap=0 --gate

const MODE_ISOLATED := "isolated"
const MODE_HOT_GAMEPLAY := "hot-gameplay"
const GRAPHICS_PATH := "res://data/graphics.json"
const MAIN_SCENE_PATH := "res://scenes/gameplay.tscn"

var _mode := MODE_ISOLATED
var _actors := 5
var _measure_seconds := 12.0
var _warmup_seconds := 3.0
var _measure_overridden := false
var _warmup_overridden := false
var _elapsed := 0.0
var _samples: Array[float] = []
var _animation_name := ""
var _animation_players := 0
var _asset_path := "res://assets/models/animations/quaternius/UAL1_Standard.glb"
var _width := 1920
var _height := 1080
var _vsync_on := false
var _engine_cap := 0
var _window_mode := "fullscreen"
var _render_scale_override := -1.0
var _gate := false
var _out_path := ""
var _capture_path := ""
var _failed := false
var _started := false
var _sampling_announced := false
var _sampling_started := false

var _graphics: Dictionary = {}
var _presentation: Dictionary = {}
var _hot_config: Dictionary = {}
var _game: Node
var _hot_player: Node3D
var _hot_camera_rig: Node3D
var _hot_camera: Camera3D
var _expected_players := 0
var _expected_enemies := 0
var _visible_players := 0
var _visible_enemies := 0
var _minimum_player_displacement_m := 0.0
var _start_player_position := Vector3.ZERO
var _maximum_player_displacement_m := 0.0
var _continuous_actions: Array[String] = []
var _pulse_actions: Array[String] = []
var _pulse_interval_seconds := 0.0
var _pulse_hold_seconds := 0.0
var _pulse_elapsed := 0.0
var _pulse_remaining := 0.0
var _pulse_index := 0
var _active_pulse := ""
var _capture_saved := false


func _initialize() -> void:
	_parse_arguments()
	if not _load_configuration():
		return
	call_deferred("_start_after_autoloads")


func _start_after_autoloads() -> void:
	# SceneTree._initialize corre antes do _ready dos autoloads. Esperar aqui e
	# voltar a aplicar a apresentacao impede SettingsSystem de repor cap=60
	# depois de o benchmark ter pedido VSync off — era a causa da falsa medicao.
	await process_frame
	_apply_presentation()
	if _mode == MODE_HOT_GAMEPLAY:
		if not _test_user_dir_is_isolated():
			return
		await _setup_hot_gameplay()
	else:
		_setup_isolated_animation()
	if _failed:
		return
	await process_frame
	_apply_presentation()
	_started = true


func _process(delta: float) -> bool:
	if _failed:
		return true
	if not _started:
		return false
	if _mode == MODE_HOT_GAMEPLAY:
		_drive_hot_player(delta)
		if is_instance_valid(_hot_player):
			_maximum_player_displacement_m = maxf(_maximum_player_displacement_m,
				_start_player_position.distance_to(_hot_player.global_position))
	_elapsed += delta
	if _elapsed > _warmup_seconds:
		if not _sampling_announced:
			_sampling_announced = true
			if _mode == MODE_HOT_GAMEPLAY:
				_started = false
				call_deferred("_prepare_hot_sampling")
				return false
			_begin_sampling()
		if not _sampling_started:
			return false
		_samples.append(delta * 1000.0)
	if _elapsed < _warmup_seconds + _measure_seconds:
		return false
	_report()
	return true


func _finalize() -> void:
	_release_all_actions()


func _load_configuration() -> bool:
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(GRAPHICS_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		_fail("graphics.json nao e um objecto JSON valido")
		return false
	_graphics = parsed as Dictionary
	_presentation = _graphics.get("presentation", {}) as Dictionary
	_hot_config = _presentation.get("hot_gameplay", {}) as Dictionary
	if _mode == MODE_HOT_GAMEPLAY:
		if _hot_config.is_empty():
			_fail("graphics.json nao declara presentation.hot_gameplay")
			return false
		if not _warmup_overridden:
			_warmup_seconds = float(_hot_config.get("warmup_seconds", _warmup_seconds))
		if not _measure_overridden:
			_measure_seconds = float(_hot_config.get("measure_seconds", _measure_seconds))
		_expected_players = int(_hot_config.get("expected_players", 0))
		_expected_enemies = int(_hot_config.get("expected_enemies", 0))
		_minimum_player_displacement_m = float(
			_hot_config.get("minimum_player_displacement_m", 0.0))
		_continuous_actions = _string_array(_hot_config.get("continuous_actions", []))
		_pulse_actions = _string_array(_hot_config.get("pulse_actions", []))
		_pulse_interval_seconds = float(_hot_config.get("pulse_interval_seconds", 0.0))
		_pulse_hold_seconds = float(_hot_config.get("pulse_hold_seconds", 0.0))
		if _expected_players <= 0 or _expected_enemies <= 0:
			_fail("hot_gameplay precisa de expected_players e expected_enemies positivos")
			return false
	return true


func _apply_presentation() -> void:
	DisplayServer.window_set_size(Vector2i(_width, _height))
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN
		if _window_mode == "fullscreen" else DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED
		if _vsync_on else DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = maxi(0, _engine_cap)
	if _render_scale_override > 0.0:
		root.get_viewport().scaling_3d_scale = _render_scale_override


func _setup_isolated_animation() -> void:
	var packed := load(_asset_path) as PackedScene
	if packed == null:
		_fail("nao foi possivel carregar %s" % _asset_path)
		return

	var stage := Node3D.new()
	stage.name = "AnimationBenchmark"
	root.add_child(stage)
	var camera := Camera3D.new()
	camera.position = Vector3(0.0, 2.2, 9.0)
	camera.look_at_from_position(camera.position, Vector3(0.0, 1.0, 0.0))
	stage.add_child(camera)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-48.0, -28.0, 0.0)
	light.shadow_enabled = true
	stage.add_child(light)

	for index: int in _actors:
		var actor := packed.instantiate()
		actor.position = Vector3((float(index) - float(_actors - 1) * 0.5) * 1.35,
			0.0, -absf(float(index) - float(_actors - 1) * 0.5) * 0.25)
		stage.add_child(actor)
		var player := _find_animation_player(actor)
		if player == null:
			_fail("actor %d nao contem AnimationPlayer" % index)
			return
		_animation_players += 1
		var candidate := _pick_animation(player)
		if candidate == "":
			_fail("actor %d nao contem animacao utilizavel" % index)
			return
		if _animation_name == "":
			_animation_name = candidate
		player.play(candidate)

	print("[ANIMATION_BENCH] mode=%s asset=%s actors=%d players=%d animation=%s warmup=%.1fs measure=%.1fs resolution=%dx%d vsync=%s cap=%d renderer=%s gpu=%s" % [
		_mode, _asset_path, _actors, _animation_players, _animation_name,
		_warmup_seconds, _measure_seconds, _width, _height,
		"on" if _vsync_on else "off", _engine_cap,
		RenderingServer.get_current_rendering_method(),
		RenderingServer.get_video_adapter_name()])


func _setup_hot_gameplay() -> void:
	var bench := root.get_node_or_null("Bench")
	if bench == null:
		_fail("autoload Bench nao existe")
		return
	bench.set("scene_arg", String(_hot_config.get("scene", "lei4")))
	var packed := load(MAIN_SCENE_PATH) as PackedScene
	if packed == null:
		_fail("nao foi possivel carregar a cena principal")
		return
	_game = packed.instantiate()
	root.add_child(_game)
	# Uma cena carregada manualmente por --script nao recebe current_scene por
	# defeito. Os apresentadores reais (EnemyHud, cues) procuram esse dono; sem
	# isto ficariam em deferred infinito e a prova deixaria de ser a do jogo.
	current_scene = _game
	for _frame: int in range(int(_hot_config.get("settle_frames", 4))):
		await process_frame
	if not is_instance_valid(_game):
		_fail("a cena principal terminou durante a preparacao")
		return
	_hot_player = _game.get("player") as Node3D
	if not is_instance_valid(_hot_player):
		_fail("a cena principal nao criou o jogador")
		return
	_hot_camera_rig = _hot_player.get("camera") as Node3D
	if not is_instance_valid(_hot_camera_rig) or not _hot_camera_rig.has_method("get_camera"):
		_fail("o jogador real nao recebeu camara")
		return
	_hot_camera = _hot_camera_rig.call("get_camera") as Camera3D
	if not is_instance_valid(_hot_camera):
		_fail("o rig do jogador nao apresentou Camera3D")
		return

	var enemies := _live_group("enemies")
	if enemies.is_empty():
		_fail("a cena de prova nao criou inimigos")
		return
	var spawn_index := 0
	while enemies.size() < _expected_enemies:
		var template := enemies[spawn_index % enemies.size()]
		var enemy_id := String(template.get("enemy_id"))
		var spawned := _game.call("_spawn", enemy_id, _hot_player.global_position) as Node
		if spawned == null:
			_fail("nao foi possivel completar o encontro a partir de %s" % enemy_id)
			return
		spawn_index += 1
		enemies = _live_group("enemies")

	_position_hot_encounter()
	for _frame: int in range(int(_hot_config.get("presentation_settle_frames", 4))):
		await process_frame
	var players := _live_group("player")
	enemies = _live_group("enemies")
	_visible_players = _visible_actor_count(players)
	_visible_enemies = _visible_actor_count(enemies)
	if players.size() != _expected_players or enemies.size() != _expected_enemies:
		_fail("caso quente materializou %d/%d jogadores e %d/%d inimigos" % [
			players.size(), _expected_players, enemies.size(), _expected_enemies])
		return
	_start_player_position = _hot_player.global_position
	_press_continuous_actions()
	print("[ANIMATION_BENCH] mode=%s scene=%s players=%d enemies=%d visible_players=%d visible_enemies=%d warmup=%.1fs measure=%.1fs resolution=%dx%d vsync=%s cap=%d renderer=%s gpu=%s" % [
		_mode, String(_hot_config.get("scene", "")), players.size(), enemies.size(),
		_visible_players, _visible_enemies, _warmup_seconds, _measure_seconds,
		_width, _height, "on" if _vsync_on else "off", _engine_cap,
		RenderingServer.get_current_rendering_method(),
		RenderingServer.get_video_adapter_name()])


func _position_hot_encounter() -> void:
	var forward := -_hot_camera_rig.global_transform.basis.z
	forward.y = 0.0
	if forward.length_squared() < 0.001:
		forward = Vector3.FORWARD
	forward = forward.normalized()
	var right := _hot_camera_rig.global_transform.basis.x
	right.y = 0.0
	right = right.normalized()
	var origin := _hot_player.global_position
	var players := _live_group("player")
	for player: Node in players:
		if player == _hot_player:
			continue
		(player as Node3D).global_position = origin \
			+ forward * float(_hot_config.get("partner_forward_m", 0.0)) \
			+ right * float(_hot_config.get("partner_right_m", 0.0))
		break

	var enemies := _live_group("enemies")
	var columns := maxi(1, int(_hot_config.get("formation_columns", 1)))
	var distance_m := float(_hot_config.get("formation_distance_m", 0.0))
	var spacing_m := float(_hot_config.get("formation_spacing_m", 0.0))
	var row_spacing_m := float(_hot_config.get("formation_row_spacing_m", 0.0))
	for index: int in enemies.size():
		var row := index / columns
		var column := index % columns
		var row_count := mini(columns, enemies.size() - row * columns)
		var lateral := (float(column) - float(row_count - 1) * 0.5) * spacing_m
		var enemy := enemies[index] as Node3D
		enemy.global_position = origin + forward * (distance_m + float(row) * row_spacing_m) \
			+ right * lateral
		enemy.set("home", enemy.global_position)
		enemy.set("target", _hot_player)


func _prepare_hot_sampling() -> void:
	# O piloto aquece a cena a jogar e pode afastar-se do parceiro estatico.
	# Reenquadrar o encontro uma vez, antes da janela util, equivale a iniciar a
	# vaga quente; durante a medicao so entram accoes reais e nenhuma posicao e
	# corrigida por fora.
	_position_hot_encounter()
	for _frame: int in range(int(_hot_config.get("presentation_settle_frames", 4))):
		await process_frame
	_visible_players = _visible_actor_count(_live_group("player"))
	_visible_enemies = _visible_actor_count(_live_group("enemies"))
	_capture_saved = _save_capture()
	_start_player_position = _hot_player.global_position
	_maximum_player_displacement_m = 0.0
	_begin_sampling()
	_started = true


func _begin_sampling() -> void:
	_sampling_started = true
	print("[ANIMATION_BENCH] aquecimento concluido; a medir %.1f s" %
		_measure_seconds)


func _drive_hot_player(delta: float) -> void:
	if _pulse_actions.is_empty() or _pulse_interval_seconds <= 0.0:
		return
	if _active_pulse != "":
		_pulse_remaining -= delta
		if _pulse_remaining <= 0.0:
			Input.action_release(_active_pulse)
			_active_pulse = ""
	_pulse_elapsed += delta
	if _active_pulse != "" or _pulse_elapsed < _pulse_interval_seconds:
		return
	_pulse_elapsed = 0.0
	_active_pulse = _pulse_actions[_pulse_index % _pulse_actions.size()]
	_pulse_index += 1
	Input.action_press(_active_pulse)
	_pulse_remaining = _pulse_hold_seconds


func _press_continuous_actions() -> void:
	for action: String in _continuous_actions:
		if not InputMap.has_action(action):
			_fail("a accao de conducao %s nao existe no mapa real" % action)
			return
		Input.action_press(action)
	for action: String in _pulse_actions:
		if not InputMap.has_action(action):
			_fail("a accao de pulso %s nao existe no mapa real" % action)
			return


func _release_all_actions() -> void:
	for action: String in _continuous_actions:
		Input.action_release(action)
	for action: String in _pulse_actions:
		Input.action_release(action)


func _test_user_dir_is_isolated() -> bool:
	var expected_root := OS.get_environment("WORLDRPGS_TEST_USER_ROOT")
	var actual_root := ProjectSettings.globalize_path("user://")
	var normalized_expected := expected_root.replace("\\", "/").trim_suffix("/")
	var normalized_actual := actual_root.replace("\\", "/")
	if normalized_expected.is_empty() \
			or not normalized_actual.begins_with(normalized_expected + "/"):
		_fail("hot-gameplay recusa tocar no user:// real; isole APPDATA e WORLDRPGS_TEST_USER_ROOT")
		return false
	return true


func _live_group(group_name: String) -> Array[Node]:
	var result: Array[Node] = []
	for candidate: Node in get_nodes_in_group(group_name):
		if not is_instance_valid(candidate) or candidate.is_queued_for_deletion():
			continue
		if group_name == "enemies" and candidate.has_method("is_alive") \
				and not bool(candidate.call("is_alive")):
			continue
		result.append(candidate)
	return result


func _visible_actor_count(actors: Array[Node]) -> int:
	var count := 0
	for actor: Node in actors:
		var actor_3d := actor as Node3D
		if actor_3d == null or not _hot_camera.is_position_in_frustum(
				actor_3d.global_position + Vector3.UP):
			continue
		if _has_visible_geometry(actor):
			count += 1
	return count


func _has_visible_geometry(node: Node) -> bool:
	if node is GeometryInstance3D and (node as GeometryInstance3D).is_visible_in_tree():
		return true
	for child: Node in node.get_children():
		if _has_visible_geometry(child):
			return true
	return false


func _save_capture() -> bool:
	if _capture_path.is_empty():
		return false
	var image := root.get_viewport().get_texture().get_image()
	var error := image.save_png(_capture_path)
	if error != OK:
		_fail("nao foi possivel guardar a captura: %s" % error_string(error))
		return false
	return true


func _parse_arguments() -> void:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with("--mode="):
			_mode = argument.trim_prefix("--mode=")
		elif argument.begins_with("--asset="):
			_asset_path = argument.trim_prefix("--asset=")
		elif argument.begins_with("--actors="):
			_actors = maxi(1, argument.trim_prefix("--actors=").to_int())
		elif argument.begins_with("--seconds="):
			_measure_seconds = maxf(1.0, argument.trim_prefix("--seconds=").to_float())
			_measure_overridden = true
		elif argument.begins_with("--warmup="):
			_warmup_seconds = maxf(0.0, argument.trim_prefix("--warmup=").to_float())
			_warmup_overridden = true
		elif argument.begins_with("--width="):
			_width = maxi(320, argument.trim_prefix("--width=").to_int())
		elif argument.begins_with("--height="):
			_height = maxi(240, argument.trim_prefix("--height=").to_int())
		elif argument.begins_with("--vsync="):
			_vsync_on = argument.trim_prefix("--vsync=") == "on"
		elif argument.begins_with("--engine-cap="):
			_engine_cap = maxi(0, argument.trim_prefix("--engine-cap=").to_int())
		elif argument.begins_with("--window="):
			_window_mode = argument.trim_prefix("--window=")
		elif argument.begins_with("--render-scale="):
			_render_scale_override = clampf(
				argument.trim_prefix("--render-scale=").to_float(), 0.25, 2.0)
		elif argument.begins_with("--out="):
			_out_path = argument.trim_prefix("--out=")
		elif argument.begins_with("--capture="):
			_capture_path = argument.trim_prefix("--capture=")
		elif argument == "--gate":
			_gate = true
	if _mode not in [MODE_ISOLATED, MODE_HOT_GAMEPLAY]:
		_fail("modo desconhecido: %s" % _mode)


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child: Node in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null


func _pick_animation(player: AnimationPlayer) -> String:
	var fallback := ""
	for animation: StringName in player.get_animation_list():
		var candidate := String(animation)
		if candidate == "RESET":
			continue
		if fallback == "":
			fallback = candidate
		var lower := candidate.to_lower()
		if "run" in lower or "walk" in lower or "idle" in lower:
			return candidate
	return fallback


func _report() -> void:
	_release_all_actions()
	if _samples.is_empty():
		_fail("nenhuma amostra recolhida")
		return
	_samples.sort()
	var total := 0.0
	for sample: float in _samples:
		total += sample
	var count := _samples.size()
	var average_ms := total / float(count)
	var p95 := _samples[_percentile_index(count, 0.95)]
	var p99 := _samples[_percentile_index(count, 0.99)]
	var worst := _samples[-1]
	var one_percent_count := maxi(1, floori(float(count) * 0.01))
	var slow_total := 0.0
	for index: int in range(count - one_percent_count, count):
		slow_total += _samples[index]
	var one_percent_low := 1000.0 * float(one_percent_count) / slow_total
	var frame_budget_ms := float(_presentation.get("frame_budget_ms", 0.0))
	var worst_ceiling_ms := float(_presentation.get("worst_frame_ceiling_ms", 0.0))
	var over_budget := 0
	var over_worst_ceiling := 0
	for sample: float in _samples:
		if sample > frame_budget_ms:
			over_budget += 1
		if sample > worst_ceiling_ms:
			over_worst_ceiling += 1
	var result := {
		"mode": _mode,
		"rendering_method": RenderingServer.get_current_rendering_method(),
		"rendering_driver": RenderingServer.get_current_rendering_driver_name(),
		"adapter": RenderingServer.get_video_adapter_name(),
		"resolution": "%dx%d" % [_width, _height],
		"render_scale": snappedf(root.get_viewport().scaling_3d_scale, 0.001),
		"vsync": "on" if _vsync_on else "off",
		"engine_cap": _engine_cap,
		"warmup_seconds": snappedf(_warmup_seconds, 0.1),
		"measure_seconds": snappedf(_measure_seconds, 0.1),
		"samples": count,
		"average_ms": snappedf(average_ms, 0.001),
		"average_fps": snappedf(1000.0 / average_ms, 0.1),
		"one_percent_low_fps": snappedf(one_percent_low, 0.1),
		"p95_ms": snappedf(p95, 0.001),
		"p99_ms": snappedf(p99, 0.001),
		"worst_ms": snappedf(worst, 0.001),
		"frames_over_budget": over_budget,
		"frames_over_worst_ceiling": over_worst_ceiling,
		"draw_calls": int(Performance.get_monitor(
			Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
		"primitives": int(Performance.get_monitor(
			Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)),
		"video_mem_mib": snappedf(Performance.get_monitor(
			Performance.RENDER_VIDEO_MEM_USED) / 1048576.0, 0.1),
		"p99_pass": p99 <= frame_budget_ms,
		"worst_pass": worst <= worst_ceiling_ms,
	}
	if _mode == MODE_ISOLATED:
		result["actors"] = _actors
		result["animation_players"] = _animation_players
		result["animation"] = _animation_name
	else:
		var players := _live_group("player")
		var enemies := _live_group("enemies")
		result["players"] = players.size()
		result["enemies"] = enemies.size()
		result["expected_players"] = _expected_players
		result["expected_enemies"] = _expected_enemies
		result["visible_players_at_start"] = _visible_players
		result["visible_enemies_at_start"] = _visible_enemies
		result["player_max_displacement_m"] = snappedf(
			_maximum_player_displacement_m, 0.001)
		result["capture_saved"] = _capture_saved
		result["composition_pass"] = players.size() == _expected_players \
			and enemies.size() == _expected_enemies
		result["visible_composition_pass"] = _visible_players == _expected_players \
			and _visible_enemies == _expected_enemies
		result["input_result_pass"] = (
			_maximum_player_displacement_m >= _minimum_player_displacement_m)

	print("BENCH_RESULT_JSON " + JSON.stringify(result))
	if not _out_path.is_empty():
		var file := FileAccess.open(_out_path, FileAccess.WRITE)
		if file == null:
			_fail("nao foi possivel escrever %s" % _out_path)
			return
		file.store_string(JSON.stringify(result, "  "))
		file.close()
	if _gate and not _result_passes_gate(result):
		printerr("[ANIMATION_BENCH_GATE] FALHOU")
		quit(1)
		return
	print("[ANIMATION_BENCH_GATE] PASSOU" if _gate else "[ANIMATION_BENCH] concluido")


func _result_passes_gate(result: Dictionary) -> bool:
	if not bool(result.get("p99_pass", false)) or not bool(result.get("worst_pass", false)):
		return false
	if _mode == MODE_HOT_GAMEPLAY:
		return bool(result.get("composition_pass", false)) \
			and bool(result.get("visible_composition_pass", false)) \
			and bool(result.get("input_result_pass", false))
	return true


func _percentile_index(count: int, percentile: float) -> int:
	return clampi(ceili(float(count) * percentile) - 1, 0, count - 1)


func _string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	for item: Variant in value as Array:
		result.append(String(item))
	return result


func _fail(message: String) -> void:
	if _failed:
		return
	_failed = true
	_release_all_actions()
	printerr("[ANIMATION_BENCH_ERROR] %s" % message)
	quit(2)
