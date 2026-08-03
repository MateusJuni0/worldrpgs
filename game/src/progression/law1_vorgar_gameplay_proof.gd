extends SceneTree
## Prova jogavel da Lei 1. Este invólucro arranca gameplay.tscn, confirma que o
## personagem que entra na arena ainda e o piloto de nivel 1 declarado nos dados
## e deixa ArenaVorgar conduzir a luta pelas accoes Input reais. A prova so sai
## verde depois de o HUD mostrar Vorgar a 0 PV / DERROTADO e o toast de vitoria.

const GAMEPLAY_SCENE_PATH := "res://scenes/gameplay.tscn"
const CANONICAL_PILOT_LEVEL := 1
const REGRESSION_LEVEL_PREFIX := "--lei-1-regression-level="


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _user_root_is_isolated():
		_fail("user:// nao esta isolado; a prova nao arrancou nem tocou nos saves")
		return
	var game_data := root.get_node_or_null("GameData")
	var bench := root.get_node_or_null("Bench")
	if game_data == null or bench == null:
		_fail("os autoloads GameData e Bench nao arrancaram")
		return
	var abilities: Dictionary = game_data.get("abilities") as Dictionary
	var proof: Dictionary = (abilities.get(
		"_law_1_vorgar_proof", {}) as Dictionary).duplicate(true)
	if proof.is_empty():
		_fail("abilities.json nao declara o contrato _law_1_vorgar_proof")
		return
	var required_level := int(proof.get("required_pilot_level", -1))
	var required_scene := String(proof.get("scene_arg", ""))
	if required_level < 0 or required_scene.is_empty():
		_fail("o contrato da Lei 1 nao declara nivel e cena do piloto")
		return
	if required_level != CANONICAL_PILOT_LEVEL:
		_fail("o contrato tentou promover o piloto para nivel %d; tem de ficar no nivel 1" \
			% required_level)
		return
	if String(bench.get("scene_arg")) != required_scene:
		_fail("a prova pediu a cena '%s', mas o jogo recebeu '%s'" % [
			required_scene, String(bench.get("scene_arg"))])
		return

	var gameplay_scene := load(GAMEPLAY_SCENE_PATH) as PackedScene
	if gameplay_scene == null:
		_fail("gameplay.tscn nao carregou")
		return
	var game := gameplay_scene.instantiate()
	root.add_child(game)
	current_scene = game
	var player := game.get("player") as Node
	var hud := game.get("hud") as Node
	if player == null or hud == null:
		_fail("gameplay.tscn nao publicou o jogador e o HUD reais")
		return
	_inject_regression_level(game_data)

	var save_state: Dictionary = game_data.get("save_state") as Dictionary
	var character: Dictionary = (save_state.get(
		"character", {}) as Dictionary)
	var progression: Dictionary = (character.get("progression", {}) as Dictionary)
	var saved_attributes: Dictionary = (progression.get("attributes", {}) as Dictionary)
	var actual_level := int(progression.get("level", -1))
	if actual_level != required_level:
		_fail("o piloto de Vorgar entrou no nivel %d; a Lei 1 exige nivel %d" % [
			actual_level, required_level])
		return
	var player_attributes: Dictionary = player.get("attrs") as Dictionary
	var attribute_data: Dictionary = game_data.get("attributes") as Dictionary
	var mismatches: PackedStringArray = []
	for attribute_value: Variant in attribute_data.get("attribute_ids", []) as Array:
		var attribute_id := String(attribute_value)
		if int(player_attributes.get(attribute_id, -1)) \
				!= int(saved_attributes.get(attribute_id, -2)):
			mismatches.append(attribute_id)
	if saved_attributes.is_empty() or not mismatches.is_empty():
		_fail("os atributos usados pelo jogador divergem do save nivel %d: %s" % [
			actual_level, ", ".join(mismatches)])
		return
	var expected_health := float(game_data.call(
		"max_health_for", int(saved_attributes.get("vida", 0))))
	var player_max_health := float(player.get("max_health"))
	var player_health := float(player.get("health"))
	if not is_equal_approx(player_max_health, expected_health) \
			or not is_equal_approx(player_health, player_max_health):
		_fail("o piloto nivel %d nao entrou com os PV iniciais derivados dos dados" \
			% actual_level)
		return

	_publish_visible_level_badge(game, actual_level)
	print("[lei-1] PILOTO CONFIRMADO: nivel %d, %.0f/%.0f PV, atributos do save" % [
		actual_level, player_health, player_max_health])
	print("[lei-1] a prova so termina quando o resultado visivel de Vorgar ficar DERROTADO")
	# ArenaVorgar foi criada pelo jogo real com --scene=vorgar e conduz daqui em
	# diante lock-on, movimento, esquiva, parry, bloqueio, cura e ataque via Input.
	# Ela propria termina o processo com 1 se o jogador morrer ou o HUD nao mostrar
	# a derrota; nao existe um segundo quit(0) neste invólucro que possa mascarar.


func _inject_regression_level(game_data: Node) -> void:
	# Controlo negativo: a cena real ja publicou Player/HUD, mas adulterar o
	# nivel tem de tornar o processo vermelho antes da vitoria.
	for argument: String in OS.get_cmdline_user_args():
		if not argument.begins_with(REGRESSION_LEVEL_PREFIX):
			continue
		var injected_level := int(argument.trim_prefix(REGRESSION_LEVEL_PREFIX))
		var state := (game_data.call("save_state_snapshot") as Dictionary).duplicate(true)
		var character: Dictionary = state.get("character", {}) as Dictionary
		var progression: Dictionary = character.get("progression", {}) as Dictionary
		progression["level"] = injected_level
		character["progression"] = progression
		state["character"] = character
		game_data.call("replace_save_state", state)
		print("[lei-1] CONTROLO NEGATIVO: nivel adulterado para %d" % injected_level)
		return


func _publish_visible_level_badge(game: Node, level: int) -> void:
	var layer := CanvasLayer.new()
	layer.name = "Law1ProofOverlay"
	layer.layer = 90
	game.add_child(layer)
	var badge := Label.new()
	badge.name = "PilotLevel"
	badge.text = "LEI 1 · PILOTO NÍVEL %d" % level
	badge.position = Vector2(20.0, 20.0)
	badge.add_theme_color_override("font_color", Color("f0d58a"))
	badge.add_theme_color_override("font_outline_color", Color("17130d"))
	badge.add_theme_constant_override("outline_size", 4)
	badge.add_theme_font_size_override("font_size", 20)
	layer.add_child(badge)


func _user_root_is_isolated() -> bool:
	var expected_root := OS.get_environment("WORLDRPGS_TEST_USER_ROOT")
	var actual_root := ProjectSettings.globalize_path("user://")
	var normalized_expected := expected_root.replace("\\", "/").trim_suffix("/")
	var normalized_actual := actual_root.replace("\\", "/")
	return not normalized_expected.is_empty() \
		and normalized_actual.begins_with(normalized_expected + "/")


func _fail(reason: String) -> void:
	printerr("[lei-1] FALHA: %s" % reason)
	quit(1)
