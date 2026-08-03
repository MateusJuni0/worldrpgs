class_name VendorCatalog
extends RefCounted
## Compila os seis catálogos existentes numa loja completa. O estado do jogador
## nunca participa: preço, e não descoberta, é a única ordem de aquisição.

const DATA_PATH := "res://data/vendors.json"

var config: Dictionary = {}
var entries: Array[Dictionary] = []
var errors: Array[String] = []
var _by_key: Dictionary = {}


func load_from_game_data(game_data: Node) -> bool:
	entries.clear()
	errors.clear()
	_by_key.clear()
	config = _read_config()
	if config.is_empty():
		return false
	var equipment: Dictionary = game_data.get("equipment") as Dictionary
	var economy: Dictionary = game_data.get("economy") as Dictionary
	var spells: Dictionary = game_data.get("spells") as Dictionary
	_append_dictionary("arma", equipment.get("weapons", {}) as Dictionary)
	_append_dictionary("armadura", equipment.get("armor", {}) as Dictionary)
	_append_dictionary("anel", equipment.get("rings", {}) as Dictionary)
	_append_spell_order(spells)
	_append_dictionary("consumivel", economy.get("consumables", {}) as Dictionary)
	_append_dictionary("material", economy.get("materials", {}) as Dictionary)
	_validate()
	return errors.is_empty()


func entry(item_key: String) -> Dictionary:
	return (_by_key.get(item_key, {}) as Dictionary).duplicate(true)


func all_entries() -> Array[Dictionary]:
	return entries.duplicate(true)


func entries_for_vendor(vendor_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value: Dictionary in entries:
		if String(value.get("vendor_id", "")) == vendor_id:
			result.append(value.duplicate(true))
	return result


func vendor(vendor_id: String) -> Dictionary:
	return ((config.get("vendors", {}) as Dictionary).get(vendor_id, {}) as Dictionary).duplicate(true)


func counts() -> Dictionary:
	var result := {}
	for value: Dictionary in entries:
		var kind := String(value.get("kind", ""))
		result[kind] = int(result.get(kind, 0)) + 1
	return result


func buy_price(item_key: String) -> int:
	return int((_by_key.get(item_key, {}) as Dictionary).get("price", 0))


func sell_price(item_key: String) -> int:
	var value: Dictionary = _by_key.get(item_key, {}) as Dictionary
	if value.is_empty():
		return 0
	if String(value.get("kind", "")) == "material" \
			and bool((config.get("pricing", {}) as Dictionary).get(
				"materials_sell_at_trade_value", false)):
		return int((value.get("data", {}) as Dictionary).get("trade_value", 0))
	var ratio := float((config.get("pricing", {}) as Dictionary).get("sellback_ratio", 0.0))
	return maxi(1, floori(float(value.get("price", 0)) * ratio))


func _read_config() -> Dictionary:
	if not FileAccess.file_exists(DATA_PATH):
		errors.append("Ficheiro de vendedores em falta: %s" % DATA_PATH)
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(DATA_PATH))
	if typeof(parsed) != TYPE_DICTIONARY:
		errors.append("vendors.json não contém um objecto JSON")
		return {}
	return parsed as Dictionary


func _append_dictionary(kind: String, catalogue: Dictionary) -> void:
	var item_index := 0
	for id_value: Variant in catalogue.keys():
		var item_id := String(id_value)
		_append_entry(kind, item_id, catalogue.get(item_id, {}) as Dictionary, item_index)
		item_index += 1


func _append_spell_order(spells: Dictionary) -> void:
	var item_index := 0
	for id_value: Variant in spells.get("order", []):
		var item_id := String(id_value)
		_append_entry("magia", item_id, spells.get(item_id, {}) as Dictionary, item_index)
		item_index += 1


func _append_entry(kind: String, item_id: String, item_data: Dictionary,
		item_index: int) -> void:
	var vendor_id := String((config.get("vendor_by_kind", {}) as Dictionary).get(kind, ""))
	var unique_kinds: Array = (config.get("catalogue_contract", {}) as Dictionary).get(
		"unique_kinds", []) as Array
	var item_key := "%s:%s" % [kind, item_id]
	var value := {
		"key": item_key,
		"id": item_id,
		"kind": kind,
		"name": _display_name(kind, item_id, item_data),
		"vendor_id": vendor_id,
		"price": _price_for(kind, item_id, item_data, item_index),
		"unique": unique_kinds.has(kind),
		"data": item_data.duplicate(true),
		"asset_path": String(item_data.get("asset_path", item_data.get("icon_path", ""))),
	}
	entries.append(value)
	_by_key[item_key] = value


func _display_name(kind: String, item_id: String, item_data: Dictionary) -> String:
	if kind in ["arma", "armadura", "anel"]:
		return String(item_data.get("nome", item_id.replace("_", " ").capitalize()))
	return String(item_data.get("display_name", item_id.replace("_", " ").capitalize()))


func _price_for(kind: String, item_id: String, item_data: Dictionary, item_index: int) -> int:
	var pricing: Dictionary = config.get("pricing", {}) as Dictionary
	var rule: Dictionary = (pricing.get("by_kind", {}) as Dictionary).get(kind, {}) as Dictionary
	var price := 0
	match String(rule.get("mode", "")):
		"zone":
			var rank := _zone_rank(item_data)
			if rank < 0:
				var band_size := maxi(1, int(rule.get("fallback_band_size", 1)))
				rank = floori(float(item_index) / float(band_size))
			price = int(rule.get("base", 0)) + rank * int(rule.get(
				"zone_step", rule.get("fallback_step", 0)))
		"mana_band":
			var mana_cost := int(item_data.get("mana_cost", 0))
			for band_value: Variant in rule.get("bands", []):
				var band: Dictionary = band_value as Dictionary
				if mana_cost <= int(band.get("max_mana", 0)):
					price = int(band.get("price", 0))
					break
		"explicit":
			price = int((rule.get("prices", {}) as Dictionary).get(item_id, 0))
		"trade_value_multiplier":
			price = int(item_data.get("trade_value", 0)) * int(rule.get("multiplier", 0))
	return _round_price(price, int(pricing.get("round_to", 1)))


func _zone_rank(item_data: Dictionary) -> int:
	var pricing: Dictionary = config.get("pricing", {}) as Dictionary
	var zone_order: Array = pricing.get("zone_order", []) as Array
	var origin := String(item_data.get("origem", ""))
	var direct_index := zone_order.find(origin)
	if direct_index >= 0:
		return direct_index
	var searchable := " ".join([
		String(item_data.get("onde_se_encontra", "")),
		String(item_data.get("material", "")),
		String(item_data.get("descricao_visual", "")),
	]).to_lower()
	var markers: Dictionary = pricing.get("zone_markers", {}) as Dictionary
	for index: int in range(zone_order.size()):
		var zone_id := String(zone_order[index])
		for marker_value: Variant in markers.get(zone_id, []):
			if searchable.contains(String(marker_value).to_lower()):
				return index
	return -1


func _round_price(value: int, step: int) -> int:
	if value <= 0 or step <= 1:
		return value
	return maxi(step, roundi(float(value) / float(step)) * step)


func _validate() -> void:
	var decision: Dictionary = config.get("_decision", {}) as Dictionary
	if bool(decision.get("discovery_gate", true)) or bool(decision.get("class_gate", true)):
		errors.append("A decisão exige catálogo total sem gate de descoberta/classe")
	var expected: Dictionary = (config.get("catalogue_contract", {}) as Dictionary).get(
		"expected_counts", {}) as Dictionary
	var actual := counts()
	for kind_value: Variant in expected.keys():
		var kind := String(kind_value)
		if int(actual.get(kind, 0)) != int(expected.get(kind, -1)):
			errors.append("Catálogo %s: %d, esperado %d" % [
				kind, int(actual.get(kind, 0)), int(expected.get(kind, -1))])
	if entries.size() != int((config.get("catalogue_contract", {}) as Dictionary).get(
		"expected_total", -1)):
		errors.append("Total comercial %d não bate no contrato" % entries.size())
	var vendors: Dictionary = config.get("vendors", {}) as Dictionary
	for value: Dictionary in entries:
		if int(value.get("price", 0)) <= 0:
			errors.append("%s sem preço positivo" % String(value.get("key", "")))
		if not vendors.has(String(value.get("vendor_id", ""))):
			errors.append("%s sem vendedor válido" % String(value.get("key", "")))
	for message: String in errors:
		push_error("[VendorCatalog] %s" % message)
