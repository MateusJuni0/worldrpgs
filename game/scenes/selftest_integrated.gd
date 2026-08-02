extends "res://src/tests/self_test.gd"
## Guarda de integração: antes dos contratos puros, arranca a cena jogável e
## observa a apresentação que chega ao ecrã. O estado fica só em memória e é
## limpo antes de libertar o jogo, para nunca tocar nos saves do Mateus/Rico.

const GAMEPLAY := preload("res://scenes/gameplay.tscn")


func _ready() -> void:
	await _test_player_equipment_visual_in_real_game()
	super._ready()


func _test_player_equipment_visual_in_real_game() -> void:
	var previous_state := GameData.save_state_snapshot()
	var previous_slot := SaveSystem.active_slot
	var previous_scene := Bench.scene_arg
	var state := SaveSystem.create_save("selftest-integrador", "warrior", {
		"name": "Prova visual",
		"appearance": (GameData.appearance.get("default", {}) as Dictionary).duplicate(true),
	})
	InventorySystem.normalise_state(state)
	GameData.replace_save_state(state)
	Bench.scene_arg = "zone"

	var gameplay: Node = GAMEPLAY.instantiate()
	add_child(gameplay)
	for _frame: int in 4:
		await get_tree().physics_frame

	var actor := gameplay.get("player") as Player
	var armor := actor.get("_visual") as ArmorVisual if actor != null else null
	var weapon := actor.get_node_or_null("WeaponAttach") as WeaponAttach \
			if actor != null else null
	_check(armor != null and armor.equipped_piece_ids().has("couro_peitoral") \
			and armor.armor_mesh_count() > 0,
		"jogo real: Guerreiro aparece com peitoral vestido")
	_check(weapon != null and weapon.has_visible_weapon("longsword") \
			and weapon.visible_mesh_count() > 0,
		"jogo real: Guerreiro aparece com espada na mao")

	# main.gd grava ao sair se existir estado. Esvaziar antes de remover o nó é
	# o que torna esta prova incapaz de ocupar ou alterar um slot real.
	GameData.replace_save_state({})
	remove_child(gameplay)
	gameplay.queue_free()
	await get_tree().process_frame
	GameData.replace_save_state(previous_state)
	SaveSystem.active_slot = previous_slot
	Bench.scene_arg = previous_scene
