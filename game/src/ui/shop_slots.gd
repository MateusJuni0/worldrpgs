class_name ShopSlots
extends RefCounted
## Gramática única de equipamento/comércio. A loja usa-a agora; a mochila pode
## consumir as mesmas funções sem inventar categorias paralelas.


static func definitions(config: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for value: Variant in config.get("slot_groups", []):
		if typeof(value) == TYPE_DICTIONARY:
			result.append((value as Dictionary).duplicate(true))
	return result


static func definition(group_id: String, config: Dictionary) -> Dictionary:
	for group: Dictionary in definitions(config):
		if String(group.get("id", "")) == group_id:
			return group
	return {}


static func groups_for_entries(entries: Array[Dictionary], config: Dictionary) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for group: Dictionary in definitions(config):
		for entry: Dictionary in entries:
			if matches(entry, group):
				result.append(group)
				break
	return result


static func filter_entries(entries: Array[Dictionary], group_id: String,
		config: Dictionary) -> Array[Dictionary]:
	var group := definition(group_id, config)
	if group.is_empty():
		return []
	var result: Array[Dictionary] = []
	for entry: Dictionary in entries:
		if matches(entry, group):
			result.append(entry)
	return result


static func matches(entry: Dictionary, group: Dictionary) -> bool:
	var kind := String(entry.get("kind", ""))
	if kind != String(group.get("kind", "")):
		return false
	if kind != "armadura":
		return true
	var item_data: Dictionary = entry.get("data", {}) as Dictionary
	return String(item_data.get("slot", "")) == String(group.get("item_slot", ""))


static func equipped_item_keys(group_id: String, state: Dictionary, game_data: Node,
		config: Dictionary) -> Array[String]:
	var group := definition(group_id, config)
	if group.is_empty():
		return []
	var character: Dictionary = state.get("character", {}) as Dictionary
	var inventory: Dictionary = character.get("inventory", {}) as Dictionary
	var equipment: Dictionary = inventory.get("equipment", {}) as Dictionary
	var kind := String(group.get("kind", ""))
	var result: Array[String] = []
	match kind:
		"arma":
			var array_key := String(group.get("equipment_array", ""))
			var values: Array = equipment.get(array_key, []) as Array
			if values.is_empty():
				var legacy_value: Variant = equipment.get(
					String(group.get("legacy_equipment_key", "")))
				_append_key(result, kind, legacy_value)
			else:
				for value: Variant in values:
					_append_key(result, kind, value)
		"armadura":
			for value: Variant in equipment.get("armor", []):
				var item_id := _id_from_value(value)
				var armor_data: Dictionary = game_data.equipment_armor(item_id)
				if armor_data.is_empty():
					armor_data = ((game_data.armor.get("pieces", {}) as Dictionary).get(
						item_id, {}) as Dictionary)
				if String(armor_data.get("slot", "")) == String(group.get("item_slot", "")):
					_append_key(result, kind, item_id)
		"anel":
			for value: Variant in equipment.get("rings", []):
				_append_key(result, kind, value)
		"magia":
			for value: Variant in equipment.get("spell_favorites", []):
				_append_key(result, kind, value)
		"consumivel":
			for value: Variant in inventory.get("quick_slots", []):
				_append_key(result, kind, value)
	return result


static func validate(config: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var seen := {}
	var required := ["mao_direita", "mao_esquerda", "aneis",
		"consumiveis_rapidos", "feiticos"]
	for group: Dictionary in definitions(config):
		var group_id := String(group.get("id", ""))
		if group_id == "" or seen.has(group_id):
			errors.append("Casa de loja vazia ou duplicada: %s" % group_id)
		seen[group_id] = true
		if String(group.get("label", "")) == "" or String(group.get("kind", "")) == "":
			errors.append("Casa %s sem label/kind" % group_id)
	for group_id: String in required:
		if not seen.has(group_id):
			errors.append("Casa obrigatória em falta: %s" % group_id)
	return errors


static func _append_key(target: Array[String], kind: String, value: Variant) -> void:
	if value == null or String(value) == "":
		return
	var raw := String(value)
	var key := raw if raw.contains(":") else "%s:%s" % [kind, raw]
	if not target.has(key):
		target.append(key)


static func _id_from_value(value: Variant) -> String:
	var raw := String(value)
	return raw.get_slice(":", 1) if raw.contains(":") else raw
