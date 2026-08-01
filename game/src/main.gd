extends Node3D
## Monta a cena. Tudo em codigo — o greybox nao tem arte, e assim nao ha ficheiros
## binarios no repositorio e cada mudanca de mundo e uma linha de diff legivel.
##
## Cenarios (--scene=):
##   perf    marco 1: zona pequena com nevoa + 3 inimigos a patrulhar (teste de desempenho)
##   combat  arena limpa: lanceiro + brutamontes, para afinar o combate
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


func _ready() -> void:
	_ensure_runtime_save()
	_graphics = _load_graphics()
	_palette = _graphics.get("palette", {})
	_preset = _pick_preset()
	_scene_kind = Bench.scene_arg

	_build_world()
	_build_player()
	_build_hud()
	_populate()
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
	var name := String(_graphics.get("default", "medio"))
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--quality="):
			name = a.split("=")[1]
	var p: Dictionary = presets.get(name, {})
	p = p.duplicate()
	p["_name"] = name
	return p


func _build_world() -> void:
	world = Greybox.new()
	world.name = "World"
	add_child(world)
	world.build(_preset, _palette, "arena" if _scene_kind == "combat" else "brumal")

	var scale := float(_preset.get("render_scale", 1.0))
	if scale < 1.0:
		get_viewport().scaling_3d_scale = scale


func _build_player() -> void:
	player = Player.new()
	player.name = "Player"
	add_child(player)
	player.setup("warrior", _palette)
	player.global_position = world.spawn_point + Vector3(0, 0.6, 0)
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
	if not Bench.is_benchmarking():
		hud.toast(GameData.ui_text("toast.start") % _preset.get("_name", "?"), 6.0)


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

	# A Toca: um em cada sala.
	var e := world.lair_entrance
	_spawn("orc_spearman", e + Vector3(0, 0.5, -10))
	_spawn("orc_brute", e + Vector3(2, 0.5, -21))

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
	hud.toast(GameData.ui_text("toast.boss_defeated"), 12.0)


# --- Teclas de sessao ---------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_pressed():
		return
	if InputMap.has_action("debug_class_next") and Input.is_action_just_pressed("debug_class_next"):
		_cycle_class()
		return
	if InputMap.has_action("quit_game") and Input.is_action_just_pressed("quit_game"):
		get_tree().quit()
	elif InputMap.has_action("toggle_mouse") and Input.is_action_just_pressed("toggle_mouse"):
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
	if not Bench.is_benchmarking() or not is_instance_valid(player):
		return
	_pilot_t += delta
	var angle := _pilot_t * 0.35
	var centre: Vector3 = world.path_points[2] if world.path_points.size() > 2 else Vector3.ZERO
	player.global_position = centre + Vector3(sin(angle) * 12.0, 0.6, cos(angle) * 12.0)
	if player.camera != null:
		player.camera.rotation.y = angle + PI


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
