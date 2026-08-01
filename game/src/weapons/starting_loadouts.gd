class_name StartingLoadouts
extends RefCounted
## Contrato dos kits iniciais. Mantem a escolha de origem separada do catalogo
## inteiro: a origem escolhe o arranque, nunca autoriza ou bloqueia uma arma.

const ACTIVE_ORIGIN_IDS: Array[String] = [
	"warrior", "sorcerer", "tank", "assassin", "berserker", "paladin",
]
const KATANA_ID := "katana_brumal_sabre_de_vigilia"
const PENDING_EVIL_MAGE_ID := "_pending_mago_do_mal"


static func contract_errors(weapons_catalog: Dictionary,
		equipment_catalog: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var loadouts := weapons_catalog.get("loadouts", {}) as Dictionary
	var active_loadout_ids: Array[String] = []
	for raw_id: Variant in loadouts.keys():
		var loadout_id := String(raw_id)
		if not loadout_id.begins_with("_"):
			active_loadout_ids.append(loadout_id)
	active_loadout_ids.sort()
	var expected_ids := ACTIVE_ORIGIN_IDS.duplicate()
	expected_ids.sort()
	if active_loadout_ids != expected_ids:
		errors.append("os kits activos devem corresponder exactamente as seis origens correntes")

	var main_owners := {}
	var combat_signature_owners := {}
	for origin_id: String in ACTIVE_ORIGIN_IDS:
		var loadout := loadouts.get(origin_id, {}) as Dictionary
		if loadout.is_empty():
			errors.append("%s nao tem kit inicial" % origin_id)
			continue
		var main_id := String(loadout.get("main", ""))
		if main_id.is_empty():
			errors.append("%s nao tem arma principal" % origin_id)
			continue
		if main_owners.has(main_id):
			errors.append("%s e %s repetem a arma inicial %s" % [
				String(main_owners[main_id]), origin_id, main_id,
			])
		else:
			main_owners[main_id] = origin_id

		var weapon := weapons_catalog.get(main_id, {}) as Dictionary
		if weapon.is_empty():
			errors.append("%s aponta para a arma inexistente %s" % [origin_id, main_id])
			continue
		for forbidden_field: String in ["allowed_classes", "blocked_classes", "class_lock"]:
			if weapon.has(forbidden_field):
				errors.append("%s bloqueia origens pelo campo %s (Lei 3)" % [
					main_id, forbidden_field,
				])
		_validate_weapon_contract(main_id, weapon, weapons_catalog, errors)
		var signature := _combat_signature(weapon, weapons_catalog)
		if combat_signature_owners.has(signature):
			errors.append("%s e %s batem com a mesma assinatura de combate" % [
				String(combat_signature_owners[signature]), origin_id,
			])
		else:
			combat_signature_owners[signature] = origin_id

	var katana := weapons_catalog.get(KATANA_ID, {}) as Dictionary
	if katana.is_empty():
		errors.append("a katana do catalogo nao existe no runtime")
	else:
		_validate_weapon_contract(KATANA_ID, katana, weapons_catalog, errors)
		if String(katana.get("familia", "")) != "katana":
			errors.append("a katana aponta para a familia errada")
		_validate_katana_against_catalogue(katana, equipment_catalog, errors)
		var longsword := weapons_catalog.get("longsword", {}) as Dictionary
		if _combat_signature(katana, weapons_catalog) == _combat_signature(
				longsword, weapons_catalog):
			errors.append("katana e espada longa batem da mesma maneira")

	var pending := loadouts.get(PENDING_EVIL_MAGE_ID, {}) as Dictionary
	if pending.is_empty():
		errors.append("falta o lugar reservado para a setima origem Mago do Mal")
	elif String(pending.get("status", "")) != "blocked_missing_relicario_catalogue":
		errors.append("o lugar do Mago do Mal nao declara o bloqueio de catalogo")
	elif pending.has("main") or pending.has("offhand"):
		errors.append("o kit do Mago do Mal foi inventado antes de o catalogo o cobrir")

	return errors


static func _validate_katana_against_catalogue(katana: Dictionary,
		equipment_catalog: Dictionary, errors: Array[String]) -> void:
	# Numeros de combate ficam exclusivamente nos JSON. O teste cruza as duas
	# fontes executaveis em vez de copiar frames/alcance para GDScript.
	var movesets := equipment_catalog.get("family_movesets", {}) as Dictionary
	var source_moveset := movesets.get("katana", {}) as Dictionary
	var source_light := source_moveset.get("leve", {}) as Dictionary
	var runtime_light := katana.get("light", {}) as Dictionary
	for field: String in ["startup", "active", "recovery", "mv"]:
		if runtime_light.get(field) != source_light.get(field):
			errors.append("a katana diverge do catalogo no campo light/%s" % field)
	var catalogue_weapons := equipment_catalog.get("weapons", {}) as Dictionary
	var source_weapon := catalogue_weapons.get(KATANA_ID, {}) as Dictionary
	if not is_equal_approx(float(katana.get("range", 0.0)),
			float(source_weapon.get("alcance_m", -1.0))):
		errors.append("a katana diverge do alcance do catalogo")


static func _validate_weapon_contract(weapon_id: String, weapon: Dictionary,
		weapons_catalog: Dictionary, errors: Array[String]) -> void:
	var family_id := String(weapon.get("familia", ""))
	var families := weapons_catalog.get("familias", {}) as Dictionary
	if family_id.is_empty() or not families.has(family_id):
		errors.append("%s nao resolve uma familia de arma" % weapon_id)
	for attack_id: String in ["light", "heavy"]:
		var attack := weapon.get(attack_id, {}) as Dictionary
		for field: String in ["startup", "active", "recovery", "stamina", "mv"]:
			if not attack.has(field):
				errors.append("%s/%s nao declara %s em JSON" % [
					weapon_id, attack_id, field,
				])
	if float(weapon.get("range", 0.0)) <= 0.0:
		errors.append("%s nao declara alcance em JSON" % weapon_id)
	var presentation := weapon.get("presentation", {}) as Dictionary
	if String(presentation.get("visual_description", "")).length() < 20:
		errors.append("%s nao declara descricao visual suficiente" % weapon_id)
	if not presentation.has("model_asset"):
		errors.append("%s nao declara honestamente a proveniencia do modelo" % weapon_id)
	if String(presentation.get("sound_source", "")).is_empty():
		errors.append("%s nao declara a proveniencia do som" % weapon_id)
	var combat_stance := weapon.get("combat_stance", {}) as Dictionary
	for field: String in ["id", "guard", "attack_plane", "spatial_weakness"]:
		if String(combat_stance.get(field, "")).is_empty():
			errors.append("%s nao declara postura propria/%s em JSON" % [
				weapon_id, field,
			])
	if _resolved_art_names(weapon, weapons_catalog).is_empty():
		errors.append("%s nao declara arte de uma e duas maos" % weapon_id)


static func _combat_signature(weapon: Dictionary, weapons_catalog: Dictionary) -> String:
	var light := weapon.get("light", {}) as Dictionary
	var heavy := weapon.get("heavy", {}) as Dictionary
	return JSON.stringify([
		String(weapon.get("familia", "")), int(weapon.get("hands", 0)),
		float(weapon.get("range", 0.0)),
		int(light.get("startup", -1)), int(light.get("active", -1)),
		int(light.get("recovery", -1)), float(light.get("mv", -1.0)),
		int(heavy.get("startup", -1)), int(heavy.get("active", -1)),
		int(heavy.get("recovery", -1)), float(heavy.get("mv", -1.0)),
		weapon.get("combat_stance", {}),
		_resolved_art_names(weapon, weapons_catalog),
	])


static func _resolved_art_names(weapon: Dictionary, weapons_catalog: Dictionary) -> Array[String]:
	var arts := weapon.get("weapon_art", {}) as Dictionary
	if arts.is_empty():
		var family := ((weapons_catalog.get("familias", {}) as Dictionary).get(
				String(weapon.get("familia", "")), {}) as Dictionary)
		arts = {
			"one_hand": family.get("arte_1mao", ""),
			"two_hands": family.get("arte_2maos", ""),
		}
	var names: Array[String] = []
	for key: String in ["one_hand", "two_hands"]:
		var value: Variant = arts.get(key, "")
		var art_name := String((value as Dictionary).get("name", "")) \
				if value is Dictionary else String(value)
		if not art_name.is_empty():
			names.append(art_name)
	return names if names.size() == 2 else []
