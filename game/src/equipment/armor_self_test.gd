extends Node
## Teste de entrega da armadura. Corre separado do auto-teste canónico porque
## este agente não é dono de game/src/tests/self_test.gd.

const ArmorSystem = preload("res://src/equipment/armor_system.gd")
const ArmorEquipmentScreen = preload("res://src/equipment/armor_equipment_screen.gd")
const ArmorCharacterVisual = preload("res://src/visual/armor_character_visual.gd")

var _passed := 0
var _failed := 0


func _ready() -> void:
	_run()


func _run() -> void:
	var load_data: Dictionary = GameData.armor.get("carga", {}) as Dictionary
	var capacity := float(load_data.get("limite_base_carga_8", 0.0))
	var medium_max := float((load_data.get("medio", {}) as Dictionary).get("max_fraccao", 0.0))
	var heavy_max := float((load_data.get("pesado", {}) as Dictionary).get("max_fraccao", 0.0))
	var profile := ArmorSystem.load_profile_for_weight(
		capacity * (medium_max + heavy_max) / 2.0, capacity)
	_check(String(profile.get("class", "")) == "pesado"
		and float(profile.get("dodge_distance", 99.0)) < float(GameData.section("dodge").get("distance", 0.0))
		and int(profile.get("dodge_duration_frames", 0)) > int(GameData.section("dodge").get("duration_frames", 0))
		and int(profile.get("iframe_start_frame", -1)) == int(GameData.section("dodge").get("iframe_start_frame", -2))
		and int(profile.get("iframe_end_frame", -1)) == int(GameData.section("dodge").get("iframe_end_frame", -2)),
		"carga pesada abranda e encurta o rolamento sem tocar nos i-frames")
	var tank_attributes: Dictionary = GameData.class_attributes("tank")
	var preview := ArmorSystem.preview_equip(
		["ferro_elmo", "ferro_peitoral"], "couro_peitoral",
		int(tank_attributes.get("carga", 0)), "sorcerer")
	_check(bool(preview.get("can_equip", false))
		and String(preview.get("slot", "")) == "peito"
		and String(preview.get("replaced_id", "")) == "ferro_peitoral"
		and not (preview.get("equipped_ids", []) as Array).has("ferro_peitoral")
		and (preview.get("equipped_ids", []) as Array).has("couro_peitoral")
		and String((preview.get("before", {}) as Dictionary).get("class", "")) == "medio"
		and String((preview.get("after", {}) as Dictionary).get("class", "")) == "leve",
		"pre-visualizacao troca apenas o mesmo slot e nunca bloqueia a classe")
	var resistance_rules: Dictionary = GameData.armor.get("resistance_rules", {}) as Dictionary
	var scale := float(resistance_rules.get("percent_scale", 0.0))
	var piece_cap := float(resistance_rules.get("max_per_piece_percent", 0.0))
	var couro_corte := float(ArmorSystem.armor_piece("couro_peitoral").get("resistencias", {}).get("corte", 0.0))
	var ombro_corte := float(ArmorSystem.armor_piece("couro_ombreiras").get("resistencias", {}).get("corte", 0.0))
	var expected_multiplicative := couro_corte + ombro_corte - couro_corte * ombro_corte / scale
	var typed_profile := ArmorSystem.resistance_profile(
		["couro_peitoral", "couro_ombreiras", "bracadeiras_orc_bruma"])
	var capped := ArmorSystem.combine_resistance_values([piece_cap * 2.0])
	var floor_fraction := ArmorSystem.damage_fraction_after_resistance(
		ArmorSystem.combine_resistance_values([piece_cap, piece_cap, piece_cap, piece_cap, piece_cap]))
	var damage_after_armor := ArmorSystem.damage_after_armor(
		scale, "corte", ["couro_peitoral", "couro_ombreiras"])
	_check(is_equal_approx(float(typed_profile.get("corte", 0.0)), expected_multiplicative)
		and float(typed_profile.get("bruma", 0.0)) > 0.0
		and is_equal_approx(capped, piece_cap)
		and is_equal_approx(damage_after_armor,
			scale * ArmorSystem.damage_fraction_after_resistance(expected_multiplicative))
		and floor_fraction >= float(resistance_rules.get("minimum_damage_fraction", 0.0)),
		"resistencias sao por tipo, multiplicativas, limitadas por peca e conservam o piso")
	var screen_state := SaveSystem.create_save("armor-screen", "tank")
	screen_state.character.inventory.items["armadura:couro_peitoral"] = 1
	var equipped_before: Array = screen_state.character.inventory.equipment.armor.duplicate()
	var screen_model := ArmorEquipmentScreen.build_model(
		screen_state, "sorcerer", "peito", "couro_peitoral")
	var slot_order: Array = screen_model.get("slot_order", []) as Array
	var slot_groups: Dictionary = screen_model.get("slot_groups", {}) as Dictionary
	_check(slot_order == (GameData.armor.get("slots", []) as Array)
		and slot_groups.size() == slot_order.size()
		and (slot_groups.get("peito", []) as Array).has("couro_peitoral")
		and String((screen_model.get("preview", {}) as Dictionary).get("candidate_id", "")) == "couro_peitoral"
		and screen_state.character.inventory.equipment.armor == equipped_before,
		"ecra usa a gramatica unica de slots e mostra a carga antes de confirmar")
	var visual := ArmorCharacterVisual.new()
	add_child(visual)
	visual.setup(1.8, Color.WHITE, false, "body_male", "warrior")
	var silhouette_before := visual.silhouette_key()
	visual.apply_armor(["couro_peitoral"])
	var leather_signature := visual.visual_signature("peito")
	visual.apply_armor(["ferro_peitoral"])
	var iron_signature := visual.visual_signature("peito")
	_check(leather_signature != "" and iron_signature != ""
		and leather_signature != iron_signature
		and visual.silhouette_key() == silhouette_before
		and (visual.visualized_slots() as Array).has("peito"),
		"trocar de peitoral muda a malha sem apagar a silhueta da classe")
	visual.free()
	_report()


func _check(condition: bool, label: String) -> void:
	if condition:
		_passed += 1
		print("  ok    %s" % label)
	else:
		_failed += 1
		push_error("  FALHA %s" % label)


func _report() -> void:
	print("\n=== ARMADURA: %d passaram, %d falharam ===" % [_passed, _failed])
	get_tree().quit(1 if _failed > 0 else 0)
