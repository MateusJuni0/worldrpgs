extends Node3D
## Monta a cena. Tudo em codigo — o greybox nao tem arte, e assim nao ha ficheiros
## binarios no repositorio e cada mudanca de mundo e uma linha de diff legivel.
##
## Cenarios (--scene=):
##   perf    marco 1: zona pequena com nevoa + 3 inimigos a patrulhar (teste de desempenho)
##   combat  arena limpa: lanceiro + brutamontes, para afinar o combate
##   vorgar  arena final real: 2 jogadores + chefe + 2 orcs, para medir o pior caso
##   zone    a fatia: Brumal -> Toca -> Vorgar   (defeito)

const NAVIGATION_HUD_SCRIPT = preload("res://src/ui/navigation_hud.gd")

var world: Greybox
var player: Player
var partner: Player
var hud: Hud
var boss: Enemy
var navigation: CanvasLayer

var _preset: Dictionary = {}
var _palette: Dictionary = {}
var _graphics: Dictionary = {}
var _scene_kind := "zone"
var _respawn_point := Vector3.ZERO
var _respawning := false
var _rest_points: Dictionary = {}
var _nearest_rest_id := ""
var _learning_points: Dictionary = {}
var _learning_elapsed := 0.0
var _wake_layer: CanvasLayer

const REST_SPAWN_OFFSET := Vector3(1.8, 0.6, 0.8)


func _ready() -> void:
	_ensure_runtime_save()
	InventorySystem.normalise_current()
	_graphics = _load_graphics()
	_palette = _graphics.get("palette", {})
	_preset = _pick_preset()
	_scene_kind = Bench.scene_arg

	_build_world()
	_build_rest_points()
	_build_player()
	_build_hud()
	_populate()
	SettingsSystem.graphics_changed.connect(_apply_graphics_live)
	_build_navigation()

	if "--photos" in OS.get_cmdline_user_args():
		var tour: Node = load("res://src/tools/photo_tour.gd").new()
		add_child(tour)
		tour.run(self)
		return

	if not Bench.is_benchmarking():
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		_run_benchmark_pilot()


func _load_graphics() -> Dictionary:
	var text := FileAccess.get_file_as_string("res://data/graphics.json")
	var parsed: Variant = JSON.parse_string(text)
	return parsed as Dictionary if typeof(parsed) == TYPE_DICTIONARY else {}


func _pick_preset() -> Dictionary:
	var presets: Dictionary = _graphics.get("presets", {})
	var name := SettingsSystem.graphics_preset_name()
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--quality="):
			name = a.split("=")[1]
	var p: Dictionary = presets.get(name, {})
	p = p.duplicate()
	p["_name"] = name
	return p


func _apply_graphics_live(preset_name: String) -> void:
	var presets: Dictionary = _graphics.get("presets", {}) as Dictionary
	var next: Dictionary = (presets.get(preset_name, {}) as Dictionary).duplicate(true)
	if next.is_empty():
		return
	next["_name"] = preset_name
	_preset = next
	get_viewport().scaling_3d_scale = float(next.get("render_scale", 1.0))
	if is_instance_valid(player) and player.camera != null:
		player.camera.set_view_distance(float(next.get("view_distance", 70.0)))
	var world_environment := world.get_node_or_null("WorldEnvironment") as WorldEnvironment
	if world_environment != null and world_environment.environment != null:
		var environment := world_environment.environment
		environment.fog_density = float(next.get("fog_density", 0.032))
		environment.adjustment_brightness = float(next.get("grade_brightness", 0.95))
		environment.adjustment_contrast = float(next.get("grade_contrast", 1.14))
		environment.adjustment_saturation = float(next.get("grade_saturation", 0.82))
	var sun := world.get_node_or_null("Sun") as DirectionalLight3D
	if sun != null:
		sun.shadow_enabled = bool(next.get("shadows", false))
		sun.directional_shadow_max_distance = float(next.get("shadow_distance", 30.0))
	var vignette := world.get_node_or_null("ScreenGrade/Vignette") as ColorRect
	if vignette != null and vignette.material is ShaderMaterial:
		(vignette.material as ShaderMaterial).set_shader_parameter(
			"strength", float(next.get("vignette_strength", 0.12)))
	if is_instance_valid(hud):
		hud.toast("Gráficos: %s · efeito aplicado" % preset_name, 2.0)


func _build_world() -> void:
	world = Greybox.new()
	world.name = "World"
	add_child(world)
	world.build(_preset, _palette, "arena" if _scene_kind == "combat" else "brumal")

	var scale := float(_preset.get("render_scale", 1.0))
	if scale < 1.0:
		get_viewport().scaling_3d_scale = scale


func _build_player() -> void:
	var identity: Dictionary = ((GameData.save_state.get("character", {}) as Dictionary).get(
		"identity", {}) as Dictionary)
	var class_id := String(identity.get("class_id", "warrior"))
	var appearance: Dictionary = identity.get("appearance", {}) as Dictionary
	player = Player.new()
	player.name = "Player"
	add_child(player)
	player.setup(class_id, _palette, String(appearance.get("body_id", "body_male")))
	refresh_inventory_state()
	var checkpoint: Dictionary = ((GameData.save_state.get("character", {}) as Dictionary).get(
		"checkpoint", {}) as Dictionary)
	var rest_id := String(checkpoint.get("rest_point_id", "brumal_clareira"))
	# O id guarda a fogueira; o corpo renasce ao lado dela, nunca dentro da chama.
	player.global_position = (_rest_points.get(rest_id, world.spawn_point) as Vector3) \
		+ REST_SPAWN_OFFSET
	_respawn_point = player.global_position

	var cam := PlayerCamera.new()
	cam.name = "PlayerCamera"
	add_child(cam)
	cam.target = player
	cam.set_view_distance(float(_preset.get("view_distance", 70.0)))
	player.camera = cam

	player.died.connect(_on_player_died)


func _build_hud() -> void:
	hud = Hud.new()
	hud.name = "Hud"
	add_child(hud)
	hud.player = player
	SaveSystem.save_completed.connect(_on_save_completed)
	if not Bench.is_benchmarking():
		hud.toast(GameData.ui_text("toast.start") % [
			SettingsSystem.binding_label("toggle_help"), _preset.get("_name", "?")], 6.0)


func _build_navigation() -> void:
	if _scene_kind == "combat":
		return
	navigation = NAVIGATION_HUD_SCRIPT.new()
	navigation.name = "Orientacao"
	add_child(navigation)
	navigation.call("initialize", player, partner, world, "brumal")


# --- Povoamento ---------------------------------------------------------------

func _spawn(enemy_id: String, at: Vector3) -> Enemy:
	var e := Enemy.new()
	add_child(e)
	e.global_position = at
	e.setup(enemy_id, _palette)
	e.target = player
	e.home = at
	e.died.connect(_on_enemy_died)
	return e


func _populate() -> void:
	match _scene_kind:
		"perf":
			# Marco 1: tres inimigos a patrulhar dentro da zona com nevoa.
			var p := world.path_points
			_spawn("orc_spearman", p[1] + Vector3(4, 0.5, 0))
			_spawn("orc_spearman", p[2] + Vector3(-5, 0.5, 2))
			_spawn("orc_brute", p[3] + Vector3(3, 0.5, -3))
		"lei4":
			# O criterio 5 da fatia, a letra: "2 jogadores + 3 inimigos no ecra",
			# na resolucao nativa. O pior caso de render que a spec exige.
			var c := world.path_points[2]
			_spawn("orc_spearman", c + Vector3(6, 0.5, 2))
			_spawn("orc_spearman", c + Vector3(-4, 0.5, 6))
			_spawn("orc_brute", c + Vector3(2, 0.5, -6))
			partner = Player.new()
			partner.name = "Parceiro"
			add_child(partner)
			partner.setup("sorcerer", _palette)
			partner.global_position = c + Vector3(2.5, 0.6, 1.0)
		"combat":
			_spawn("orc_spearman", Vector3(4, 0.5, -6))
			_spawn("orc_brute", Vector3(-5, 0.5, -8))
		"vorgar":
			# Prova repetível dentro da arena final, não numa arena cinzenta que
			# omite as paredes, tochas e os detritos que o jogador vê.
			var c := world.arena_center
			player.global_position = c + Vector3(0.0, 0.6, 8.0)
			_respawn_point = player.global_position
			boss = _spawn("vorgar", c)
			hud.boss = boss
			_spawn("orc_spearman", c + Vector3(6.0, 0.5, 1.5))
			_spawn("orc_brute", c + Vector3(-6.0, 0.5, -2.0))
			var partner := Player.new()
			partner.name = "Parceiro"
			add_child(partner)
			partner.setup("sorcerer", _palette)
			partner.global_position = c + Vector3(2.5, 0.6, 6.5)
		_:
			_populate_zone()


func _populate_zone() -> void:
	var p := world.path_points
	# spec/27, primeiros cinco minutos: vazio -> um de costas -> dois de frente
	# -> brutamontes no arco -> descanso e bivaque ao longe.
	var lone := _spawn("orc_spearman", p[1] + Vector3.UP * 0.5)
	_face_enemy_towards(lone, p[2])
	var approach := (p[2] - p[1]).normalized()
	var right := Vector3(approach.z, 0.0, -approach.x)
	var spear_left := _spawn("orc_spearman", p[2] - right * 2.6 + Vector3.UP * 0.5)
	var spear_right := _spawn("orc_spearman", p[2] + right * 2.6 + Vector3.UP * 0.5)
	_face_enemy_towards(spear_left, p[1])
	_face_enemy_towards(spear_right, p[1])
	var brute := _spawn("orc_brute", p[3] + Vector3.UP * 0.5)
	_face_enemy_towards(brute, p[2])

	for camp_offset: Vector3 in [Vector3(-3.2, 0.5, 1.5),
			Vector3(3.0, 0.5, 1.2), Vector3(0.5, 0.5, -3.0)]:
		var camper := _spawn("orc_spearman", world.camp_point + camp_offset)
		_face_enemy_towards(camper, world.rest_point)

	# Os pontos de aprendizagem sao as ancoras que o tutorial usa para ensinar no
	# sitio certo. Vem do HEAD; apontam agora para a disposicao do spec/27.
	_learning_points = {
		"attack": p[1],
		"dodge": p[2],
		"parry": p[3],
		"flask": p[4],
	}

	# A Toca: um em cada sala.
	var e := world.lair_entrance
	_spawn("orc_spearman", e + Vector3(0, 0.5, -10))
	_spawn("orc_brute", e + Vector3(2, 0.5, -21))

	var defeated: Array = ((GameData.save_state.get("world", {}) as Dictionary).get(
		"bosses_defeated", []) as Array)
	if not "vorgar" in defeated:
		boss = _spawn("vorgar", world.arena_center)
		hud.boss = boss
		boss.died.connect(_on_boss_died)


func _face_enemy_towards(enemy: Enemy, point: Vector3) -> void:
	var direction := point - enemy.global_position
	direction.y = 0.0
	if direction.length_squared() > 0.001:
		enemy.rotation.y = atan2(-direction.x, -direction.z)


# --- Morte e recomeco ---------------------------------------------------------

func _ensure_runtime_save() -> void:
	if not GameData.save_state.is_empty():
		return
	var path := SaveSystem.slot_path(0)
	if not FileAccess.file_exists(path):
		SaveSystem.new_game("local-prototype", "warrior", 0)
		return
	var loaded := SaveSystem.load_slot(0)
	if loaded.is_empty():
		SaveSystem.new_game("local-prototype", "warrior", 0)


func _on_enemy_died(defeated: Enemy) -> void:
	if defeated.is_boss:
		return
	var snapshot := GameData.save_state_snapshot()
	var world_state: Dictionary = snapshot.get("world", {}) as Dictionary
	var deck_state: Dictionary = ((world_state.get("loot_decks", {}) as Dictionary).get(
		defeated.enemy_id, {}) as Dictionary)
	var next_index := int(deck_state.get("next_index", 0))
	var event_id := "enemy:%s:%d" % [defeated.enemy_id, next_index]
	var character: Dictionary = snapshot.get("character", {}) as Dictionary
	var identity: Dictionary = character.get("identity", {}) as Dictionary
	var class_id := String(identity.get("class_id", "warrior"))
	var seed_value := hash(String(world_state.get("owner_profile_id", "local-prototype")))
	var receipt := SaveSystem.commit_enemy_defeat(
		defeated.enemy_id, event_id, seed_value, class_id)
	match String(receipt.get("status", "")):
		"awarded":
			var card := String(receipt.get("resolved_card", ""))
			hud.toast(GameData.ui_text("toast.reward") % [int(receipt.get("souls_awarded", 0)), card], 3.0)
		"exhausted":
			hud.toast(GameData.ui_text("toast.loot_exhausted"), 2.5)
		"save_failed":
			hud.toast(GameData.ui_text("toast.reward_save_failed"), 3.0)

func _on_player_died() -> void:
	if _respawning:
		return
	_respawning = true
	if not SaveSystem.commit_death("brumal", player.global_position):
		hud.toast("A morte não foi gravada: %s" % SaveSystem.last_error, 4.0)
	hud.toast(GameData.ui_text("toast.death"), 1.5)
	await get_tree().create_timer(
		float(GameData.section("death").get("respawn_fade_seconds", 1.2))).timeout
	_respawn()


## Vida, stamina e mana restauradas; o chefe faz reset TOTAL.
## O alvo da spec e nova tentativa em menos de 30 s — aqui e ~1,2 s.
func _respawn() -> void:
	player.respawn_at(_respawn_point)
	player.flask_refill()
	for node in get_children():
		var e := node as Enemy
		if e != null:
			e.full_reset()
	_respawning = false
	hud.toast(GameData.ui_text("toast.respawn"), 2.0)


func _on_boss_died(_e: Enemy) -> void:
	var cycle := int((GameData.save_state.get("world", {}) as Dictionary).get("cycle", 0))
	if not SaveSystem.commit_boss_defeat("vorgar", "boss:vorgar:%d" % cycle):
		hud.toast("Vorgar caiu, mas o progresso não foi gravado.", 4.0)
		return
	hud.toast(GameData.ui_text("toast.boss_defeated"), 12.0)


func _on_save_completed(_path: String) -> void:
	if is_instance_valid(hud):
		hud.indicate_save()


# --- Pontos de descanso ------------------------------------------------------

func _build_rest_points() -> void:
	_rest_points = {
		"brumal_clareira": world.spawn_point,
		"toca_entrada": world.lair_entrance + Vector3(0, 0.0, 7.0),
	}
	for rest_id: String in _rest_points:
		_build_bonfire(rest_id, _rest_points[rest_id])


func _build_bonfire(rest_id: String, at: Vector3) -> void:
	var root := Node3D.new()
	root.name = "Rest_%s" % rest_id
	root.position = at
	add_child(root)
	for index: int in range(8):
		var stone := MeshInstance3D.new()
		var mesh := SphereMesh.new()
		mesh.radius = 0.22
		mesh.height = 0.34
		stone.mesh = mesh
		var angle := TAU * float(index) / 8.0
		stone.position = Vector3(sin(angle) * 0.7, 0.18, cos(angle) * 0.7)
		root.add_child(stone)
	var ember := MeshInstance3D.new()
	var ember_mesh := CylinderMesh.new()
	ember_mesh.top_radius = 0.16
	ember_mesh.bottom_radius = 0.42
	ember_mesh.height = 0.75
	ember.mesh = ember_mesh
	ember.position.y = 0.4
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("d57635")
	material.emission_enabled = true
	material.emission = Color("d65a24")
	material.emission_energy_multiplier = 2.5
	ember.material_override = material
	root.add_child(ember)
	var light := OmniLight3D.new()
	light.position.y = 1.1
	light.light_color = Color("ff9a55")
	light.light_energy = 1.8
	light.omni_range = 7.0
	light.shadow_enabled = false
	root.add_child(light)


func _tick_rest_points() -> void:
	if not is_instance_valid(player) or player.state == Player.State.DEAD:
		return
	var nearest := ""
	var nearest_distance := 9999.0
	for rest_id: String in _rest_points:
		var distance := player.global_position.distance_to(_rest_points[rest_id])
		if distance < nearest_distance:
			nearest = rest_id
			nearest_distance = distance
	_nearest_rest_id = nearest if nearest_distance <= 2.5 else ""
	if _nearest_rest_id == "":
		hud.set_prompt("")
		return
	hud.set_prompt("%s — descansar" % _binding_label("interact"))
	if Input.is_action_just_pressed("interact"):
		_rest_at(_nearest_rest_id)


func _rest_at(rest_id: String) -> void:
	if not SaveSystem.commit_checkpoint("brumal", rest_id):
		hud.toast("Não foi possível guardar este descanso.", 3.0)
		return
	_respawn_point = (_rest_points[rest_id] as Vector3) + REST_SPAWN_OFFSET
	player.health = player.max_health
	player.stamina.current = player.stamina.maximum
	player.mana = player.max_mana
	player.flask_refill()
	for node: Node in get_children():
		var enemy := node as Enemy
		if enemy != null and not enemy.is_boss:
			enemy.full_reset()
	hud.toast("Descansaste. Este é agora o teu ponto de regresso.", 3.0)


func _binding_label(action_name: String) -> String:
	return SettingsSystem.binding_label(action_name)


func set_local_input_enabled(enabled: bool) -> void:
	if is_instance_valid(player):
		player.input_enabled = enabled


func begin_wake_sequence(capture_mode := false) -> void:
	if not is_instance_valid(player) or is_instance_valid(_wake_layer):
		return
	player.set_waking_up(true)
	if is_instance_valid(hud):
		hud.visible = false
	_wake_layer = CanvasLayer.new()
	_wake_layer.layer = 280
	_wake_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_wake_layer)
	var root := Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_wake_layer.add_child(root)
	var veil := ColorRect.new()
	veil.name = "Veil"
	veil.color = Color(0.0, 0.0, 0.0, 0.48 if capture_mode else 0.88)
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	veil.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(veil)
	var title := Label.new()
	title.text = "CLAREIRA DE BRUMAL"
	title.position = Vector2(0, 420)
	title.size = Vector2(1920, 76)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 38)
	title.add_theme_color_override("font_color", Color("eadbb9"))
	root.add_child(title)
	var rule := ColorRect.new()
	rule.color = Color("9a743d")
	rule.position = Vector2(900, 505)
	rule.size = Vector2(120, 2)
	root.add_child(rule)
	var context := Label.new()
	context.text = "A fogueira ainda arde.  Levanta-te."
	context.position = Vector2(0, 540)
	context.size = Vector2(1920, 52)
	context.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	context.add_theme_font_size_override("font_size", 19)
	context.add_theme_color_override("font_color", Color("aab4b3"))
	root.add_child(context)
	if capture_mode:
		return
	await get_tree().create_timer(0.7).timeout
	var tween := create_tween().set_parallel(true)
	tween.tween_property(veil, "color:a", 0.0, 2.2)
	tween.tween_property(title, "modulate:a", 0.0, 1.4).set_delay(0.8)
	tween.tween_property(rule, "modulate:a", 0.0, 1.4).set_delay(0.8)
	tween.tween_property(context, "modulate:a", 0.0, 1.4).set_delay(0.8)
	await tween.finished
	_end_wake_sequence()


func wake_sequence_active() -> bool:
	return is_instance_valid(_wake_layer)


func _end_wake_sequence() -> void:
	if is_instance_valid(_wake_layer):
		_wake_layer.free()
	_wake_layer = null
	if is_instance_valid(player):
		player.set_waking_up(false)
	if is_instance_valid(hud):
		hud.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func refresh_inventory_state() -> void:
	if not is_instance_valid(player):
		return
	var state := GameData.save_state_snapshot()
	var character: Dictionary = state.get("character", {}) as Dictionary
	var inventory: Dictionary = character.get("inventory", {}) as Dictionary
	player.apply_inventory_state(inventory.get("equipment", {}) as Dictionary,
		InventorySystem.load_profile(state))


func can_change_spell_favorites() -> bool:
	return not _combat_is_active()


func spell_favorites() -> Array[String]:
	return player.favorite_spells.duplicate() if is_instance_valid(player) else []


func selected_spell_id() -> String:
	return player.selected_spell if is_instance_valid(player) else ""


func cycle_spell() -> void:
	if is_instance_valid(player):
		player.cycle_spell()


func select_and_cast_spell(spell_id: String) -> bool:
	return is_instance_valid(player) and player.select_spell(spell_id) \
		and player.cast_selected_spell()


# --- Aprendizagem contextual -------------------------------------------------

func _tick_learning(delta: float) -> void:
	if _scene_kind != "zone" or not SettingsSystem.context_tips_enabled() \
			or not is_instance_valid(player) or not player.input_enabled \
			or not is_instance_valid(hud) or hud.has_context_tip():
		return
	_learning_elapsed += delta
	if _combat_is_active():
		return
	if _learning_elapsed >= 1.2 and not SettingsSystem.tip_seen("movement"):
		_show_learning_tip("movement")
		return
	for tip_id: String in ["attack", "dodge", "parry"]:
		if SettingsSystem.tip_seen(tip_id) or not _learning_points.has(tip_id):
			continue
		if player.global_position.distance_to(_learning_points[tip_id] as Vector3) <= 23.0:
			_show_learning_tip(tip_id)
			return
	if not SettingsSystem.tip_seen("flask") and player.health < player.max_health \
			and player.global_position.distance_to(
				_rest_points.get("toca_entrada", Vector3(9999, 9999, 9999)) as Vector3) <= 18.0:
		_show_learning_tip("flask")


func _combat_is_active() -> bool:
	for node: Node in get_tree().get_nodes_in_group("enemies"):
		var enemy := node as Enemy
		if enemy != null and enemy.state in [Enemy.State.CHASE, Enemy.State.ATTACK]:
			return true
	return false


func _show_learning_tip(tip_id: String) -> void:
	var message := GameShell.tutorial_tip_text(tip_id)
	if message == "":
		return
	SettingsSystem.mark_tip_seen(tip_id)
	hud.context_tip(message, 4.0)


# --- Teclas de sessao ---------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_pressed():
		return
	if InputMap.has_action("debug_class_next") and Input.is_action_just_pressed("debug_class_next"):
		_cycle_class()
		return
	if InputMap.has_action("toggle_mouse") and Input.is_action_just_pressed("toggle_mouse"):
		Input.mouse_mode = (Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
			else Input.MOUSE_MODE_CAPTURED)
	elif InputMap.has_action("reset_arena") and Input.is_action_just_pressed("reset_arena"):
		_respawn()
		hud.toast(GameData.ui_text("toast.arena_reset"), 2.0)


# --- Piloto automatico para a medicao -----------------------------------------

## Em modo benchmark ninguem carrega em teclas. Isto poe a camara a rodar devagar
## para o custo de render ser realista (a nevoa e as arvores entram e saem de vista)
## em vez de se medir uma cena parada, que mentiria para melhor.
func _run_benchmark_pilot() -> void:
	set_process(true)


var _pilot_t := 0.0

func _process(delta: float) -> void:
	if not Bench.is_benchmarking():
		_tick_rest_points()
		_tick_learning(delta)
		return
	# Os benchmarks de UI medem o ecrã no contexto em que ele aparece. O piloto
	# 3D colocaria artificialmente o jogador no meio dos inimigos durante menus.
	if Bench.scene_arg.begins_with("ui-"):
		return
	if not is_instance_valid(player):
		return
	_pilot_t += delta
	var angle := _pilot_t * 0.35
	var centre: Vector3 = world.path_points[2] if world.path_points.size() > 2 else Vector3.ZERO
	player.global_position = centre + Vector3(sin(angle) * 12.0, 0.6, cos(angle) * 12.0)
	if player.camera != null:
		player.camera.rotation.y = angle + PI


func _exit_tree() -> void:
	if SaveSystem.save_completed.is_connected(_on_save_completed):
		SaveSystem.save_completed.disconnect(_on_save_completed)
	if SettingsSystem.graphics_changed.is_connected(_apply_graphics_live):
		SettingsSystem.graphics_changed.disconnect(_apply_graphics_live)
	if not GameData.save_state.is_empty():
		SaveSystem.save_current()


# --- Troca de classe (F6, ferramenta de teste) ---------------------------------
# Para o Rico sentir as 6 classes sem menu (o menu de escolha vem com o WP11).

const CLASSES: Array[String] = ["warrior", "tank", "berserker", "sorcerer", "assassin", "paladin"]
var _class_index := 0


func _cycle_class() -> void:
	_class_index = (_class_index + 1) % CLASSES.size()
	var class_id := CLASSES[_class_index]
	var pos := player.global_position
	var cam := player.camera
	player.died.disconnect(_on_player_died)
	player.queue_free()

	player = Player.new()
	player.name = "Player"
	add_child(player)
	player.setup(class_id, _palette)
	player.global_position = pos
	player.camera = cam
	cam.target = player
	player.died.connect(_on_player_died)
	hud.player = player
	if is_instance_valid(navigation):
		navigation.set("player", player)
		var surface: Control = navigation.get("_minimap_surface")
		if surface != null:
			surface.set("player", player)
	for node in get_children():
		var e := node as Enemy
		if e != null:
			e.target = player
	var display: String = GameData.class_attributes(class_id).get("display_name", class_id)
	hud.toast(GameData.ui_text("toast.class_changed") % display, 2.5)
