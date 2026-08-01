extends SceneTree
## Prova isolada das armas, executavel sem editar o agregador de outro agente:
## godot --headless --audio-driver Dummy --path game/ --script res://src/visual/weapon_visual_self_test.gd

class MockActor extends Node3D:
	var class_id := "warrior"
	var main_weapon := "longsword"
	var offhand_weapon := "shield"
	var is_two_handed := false


var _passed := 0
var _failed := 0
var _game_data: Node


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_game_data = load("res://src/autoload/game_data.gd").new() as Node
	_game_data.name = "GameData"
	root.add_child(_game_data)
	await process_frame
	_test_kaykit_rig_and_loadouts()
	_test_quaternius_rig_fallback()
	print("\n=== ARMA VISIVEL: %d passaram, %d falharam ===" % [_passed, _failed])
	quit(0 if _failed == 0 else 1)


func _test_kaykit_rig_and_loadouts() -> void:
	var actor := MockActor.new()
	root.add_child(actor)
	var body := CharacterVisual.new()
	actor.add_child(body)
	body.setup(float((_game_data.call("section", "player") as Dictionary).get("capsule_height", 0.0)),
		Color.WHITE, false, "body_male", actor.class_id)
	var weapons := WeaponVisual.new()
	actor.add_child(weapons)
	_check(weapons.setup(actor, body), "rig KayKit aceita WeaponVisual")
	var bones := weapons.attachment_bones()
	_check(not String(bones.get("main", "")).is_empty(), "arma principal encontra mao direita")
	_check(not String(bones.get("offhand", "")).is_empty(), "arma secundaria encontra mao esquerda")
	_check(weapons.has_visible_weapon("longsword"), "espada longa nasce visivel no kit guerreiro")
	_check(weapons.has_visible_weapon("shield"), "escudo nasce visivel na mao secundaria")
	_check(weapons.visible_mesh_count() >= 2, "espada e escudo trazem malha renderizavel")

	for weapon_id: String in WeaponVisual.WEAPON_SCENES:
		_check(ResourceLoader.exists(String(WeaponVisual.WEAPON_SCENES[weapon_id])),
			"%s resolve um modelo CC0 importavel" % weapon_id)
		weapons.sync_loadout(weapon_id, "", weapon_id in ["greataxe", "staff"])
		_check(weapons.has_visible_weapon(weapon_id), "%s fica visivel na mao" % weapon_id)
		_check(weapons.visible_mesh_count() >= 1, "%s tem pelo menos uma malha" % weapon_id)

	weapons.sync_loadout("greataxe", "shield", true)
	_check(not weapons.has_visible_weapon("shield"), "duas maos escondem a arma secundaria")
	weapons.sync_loadout("longsword", "shield", false)
	_check(weapons.has_visible_weapon("shield"), "voltar a uma mao recupera o escudo")
	_check(weapons.main_weapon_tip_position().distance_to(actor.global_position) > 0.0,
		"ponta da arma fornece origem real para o contacto")
	print("[weapon-test] KayKit: %s" % JSON.stringify(bones))
	actor.free()


func _test_quaternius_rig_fallback() -> void:
	var actor := MockActor.new()
	actor.class_id = ""
	actor.offhand_weapon = ""
	root.add_child(actor)
	var body := CharacterVisual.new()
	actor.add_child(body)
	body.setup(float((_game_data.call("section", "player") as Dictionary).get("capsule_height", 0.0)),
		Color.WHITE, false, "body_male", "")
	var weapons := WeaponVisual.new()
	actor.add_child(weapons)
	_check(weapons.setup(actor, body), "rig Quaternius aceita WeaponVisual")
	_check(weapons.has_visible_weapon("longsword"), "corpo base tambem mostra a espada")
	print("[weapon-test] Quaternius: %s" % JSON.stringify(weapons.attachment_bones()))
	actor.free()


func _check(condition: bool, label: String) -> void:
	if condition:
		_passed += 1
		print("  ok    ", label)
	else:
		_failed += 1
		printerr("  FALHA ", label)
