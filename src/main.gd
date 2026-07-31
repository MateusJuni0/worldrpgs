extends Node3D
## Monta a cena. Tudo em codigo — o greybox nao tem arte, e assim nao ha ficheiros
## binarios no repositorio e cada mudanca de mundo e uma linha de diff legivel.
##
## Cenarios (--scene=):
##   perf    marco 1: zona pequena com nevoa + 3 inimigos a patrulhar (teste de desempenho)
##   combat  arena limpa: lanceiro + brutamontes, para afinar o combate
##   zone    a fatia: Brumal -> Toca -> Vorgar   (defeito)

var world: Greybox
var player: Player
var hud: Hud
var boss: Enemy

var _preset: Dictionary = {}
var _palette: Dictionary = {}
var _graphics: Dictionary = {}
var _scene_kind := "zone"
var _respawn_point := Vector3.ZERO
var _respawning := false


func _ready() -> void:
	_graphics = _load_graphics()
	_palette = _graphics.get("palette", {})
	_preset = _pick_preset()
	_scene_kind = Bench.scene_arg

	_build_world()
	_build_player()
	_build_hud()
	_populate()

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
		hud.toast("F2 mostra os comandos · qualidade: %s" % _preset.get("_name", "?"), 6.0)


# --- Povoamento ---------------------------------------------------------------

func _spawn(enemy_id: String, at: Vector3) -> Enemy:
	var e := Enemy.new()
	add_child(e)
	e.global_position = at
	e.setup(enemy_id, _palette)
	e.target = player
	e.home = at
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
			var partner := Player.new()
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
	# Brumal: orcs ao longo do caminho. O lanceiro ensina a esquiva primeiro;
	# o brutamontes aparece depois, quando ja ha esquiva para o ler.
	_spawn("orc_spearman", p[1] + Vector3(5, 0.5, -2))
	_spawn("orc_spearman", p[2] + Vector3(-6, 0.5, 3))
	_spawn("orc_brute", p[2] + Vector3(4, 0.5, -6))
	_spawn("orc_spearman", p[3] + Vector3(6, 0.5, 1))
	_spawn("orc_brute", p[4] + Vector3(-5, 0.5, -2))
	_spawn("orc_spearman", p[5] + Vector3(4, 0.5, 4))

	# A Toca: um em cada sala.
	var e := world.lair_entrance
	_spawn("orc_spearman", e + Vector3(0, 0.5, -10))
	_spawn("orc_brute", e + Vector3(2, 0.5, -21))

	boss = _spawn("vorgar", world.arena_center)
	hud.boss = boss
	boss.died.connect(_on_boss_died)


# --- Morte e recomeco ---------------------------------------------------------

func _on_player_died() -> void:
	if _respawning:
		return
	_respawning = true
	hud.toast("Morreste. A voltar...", 1.5)
	await get_tree().create_timer(
		float(GameData.section("death").get("respawn_fade_seconds", 1.2))).timeout
	_respawn()


## Nao se perde nada. Vida, stamina e cargas restauradas; o chefe faz reset TOTAL.
## O alvo da spec e nova tentativa em menos de 30 s — aqui e ~1,2 s.
func _respawn() -> void:
	player.respawn_at(_respawn_point)
	player.flask_refill()
	for node in get_children():
		var e := node as Enemy
		if e != null:
			e.full_reset()
	_respawning = false
	hud.toast("Nada se perdeu.", 2.0)


func _on_boss_died(_e: Enemy) -> void:
	hud.toast("Vorgar caiu. A fatia 1 esta zerada.", 12.0)


# --- Teclas de sessao ---------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_pressed():
		return
	if InputMap.has_action("quit_game") and Input.is_action_just_pressed("quit_game"):
		get_tree().quit()
	elif InputMap.has_action("toggle_mouse") and Input.is_action_just_pressed("toggle_mouse"):
		Input.mouse_mode = (Input.MOUSE_MODE_VISIBLE if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
			else Input.MOUSE_MODE_CAPTURED)
	elif InputMap.has_action("reset_arena") and Input.is_action_just_pressed("reset_arena"):
		_respawn()
		hud.toast("Arena reiniciada.", 2.0)


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
