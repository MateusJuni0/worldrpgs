extends Node
## Estado mutavel da mochila. A mochila nao tem limite: este sistema nunca
## rejeita uma recolha por peso ou espaco. A carga deriva apenas do equipamento.

signal inventory_changed

const FILTERS := ["todos", "armas", "armadura", "aneis", "magias", "consumiveis", "materiais", "favoritos"]
const MAX_SPELL_FAVORITES := 8


func normalise_state(state: Dictionary) -> bool:
	if state.is_empty():
		return false
	var changed := false
	var character: Dictionary = state.get("character", {}) as Dictionary
	var progression: Dictionary = character.get("progression", {}) as Dictionary
	var inventory: Dictionary = character.get("inventory", {}) as Dictionary
	var equipment: Dictionary = inventory.get("equipment", {}) as Dictionary
	var items: Dictionary = inventory.get("items", {}) as Dictionary
	if not inventory.has("favorite_items"):
		inventory["favorite_items"] = []
		changed = true
	var defaults: Array = (GameData.spells.get("_rules", {}) as Dictionary).get(
		"default_favorites", []) as Array
	var known: Array = progression.get("known_spells", []) as Array
	if known.is_empty():
		known = defaults.duplicate()
		progression["known_spells"] = known
		changed = true
	var spell_favorites: Array = equipment.get("spell_favorites", []) as Array
	if spell_favorites.is_empty():
		spell_favorites = defaults.duplicate()
		equipment["spell_favorites"] = spell_favorites
		changed = true
	for slot_name: String in ["main", "offhand"]:
		var value: Variant = equipment.get(slot_name)
		if value != null and String(value) != "":
			changed = _claim(items, "arma:%s" % String(value)) or changed
	for value: Variant in equipment.get("armor", []):
		changed = _claim(items, "armadura:%s" % String(value)) or changed
	for value: Variant in equipment.get("rings", []):
		changed = _claim(items, "anel:%s" % String(value)) or changed
	inventory["items"] = items
	inventory["equipment"] = equipment
	character["progression"] = progression
	character["inventory"] = inventory
	state["character"] = character
	return changed


func normalise_current(persist := true) -> bool:
	var state := GameData.save_state_snapshot()
	if not normalise_state(state):
		return true
	GameData.replace_save_state(state)
	return not persist or SaveSystem.save_current()


func entries(state := {}) -> Array[Dictionary]:
	var working: Dictionary = state if not (state as Dictionary).is_empty() \
		else GameData.save_state_snapshot()
	normalise_state(working)
	var character: Dictionary = working.get("character", {}) as Dictionary
	var inventory: Dictionary = character.get("inventory", {}) as Dictionary
	var items: Dictionary = inventory.get("items", {}) as Dictionary
	var result: Array[Dictionary] = []
	for raw_key: Variant in items.keys():
		var entry := describe_item(String(raw_key), int(items.get(raw_key, 0)), working)
		if not entry.is_empty() and int(entry.get("count", 0)) > 0:
			result.append(entry)
	var progression: Dictionary = character.get("progression", {}) as Dictionary
	for spell_value: Variant in progression.get("known_spells", []):
		var entry := describe_item("magia:%s" % String(spell_value), 1, working)
		if not entry.is_empty():
			result.append(entry)
	result.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return String(a.get("name", "")) < String(b.get("name", "")))
	return result


func describe_item(item_key: String, count := 1, state := {}) -> Dictionary:
	var parts := item_key.split(":", false, 1)
	var kind := String(parts[0]) if parts.size() == 2 else "desconhecido"
	var item_id := String(parts[1]) if parts.size() == 2 else item_key
	var data := {}
	var name := item_id.replace("_", " ").capitalize()
	match kind:
		"arma":
			data = GameData.equipment_weapon(item_id)
			if data.is_empty():
				data = GameData.weapon(item_id)
			name = String(data.get("nome", data.get("display_name", name)))
		"armadura":
			data = GameData.equipment_armor(item_id)
			if data.is_empty():
				data = (GameData.armor.get("pieces", {}) as Dictionary).get(item_id, {}) as Dictionary
			name = String(data.get("nome", name))
		"anel":
			data = GameData.ring(item_id)
			name = String(data.get("nome", name))
		"magia":
			data = GameData.spell(item_id)
			name = String(data.get("display_name", name))
		"material":
			data = GameData.material(item_id)
			name = String(data.get("display_name", name))
		"consumivel":
			data = GameData.consumable(item_id)
			name = String(data.get("display_name", name))
		_:
			return {}
	var actual_state: Dictionary = state if not (state as Dictionary).is_empty() \
		else GameData.save_state_snapshot()
	return {
		"key": item_key, "id": item_id, "kind": kind, "name": name,
		"count": count, "data": data, "equipped": is_equipped(item_key, actual_state),
		"favorite": is_favorite(item_key, actual_state),
	}


func filtered_entries(filter_name: String, state := {}) -> Array[Dictionary]:
	var aliases := {"armas": "arma", "armadura": "armadura", "aneis": "anel",
		"magias": "magia", "consumiveis": "consumivel", "materiais": "material"}
	var result: Array[Dictionary] = []
	for entry: Dictionary in entries(state):
		if filter_name == "todos" or (filter_name == "favoritos" and bool(entry.favorite)) \
				or String(entry.kind) == String(aliases.get(filter_name, "")):
			result.append(entry)
	return result


func is_equipped(item_key: String, state: Dictionary) -> bool:
	var equipment := _equipment(state)
	var parts := item_key.split(":", false, 1)
	if parts.size() != 2:
		return false
	match String(parts[0]):
		"arma": return String(equipment.get("main", "")) == parts[1] \
			or String(equipment.get("offhand", "")) == parts[1]
		"armadura": return (equipment.get("armor", []) as Array).has(parts[1])
		"anel": return (equipment.get("rings", []) as Array).has(parts[1])
		"magia": return (equipment.get("spell_favorites", []) as Array).has(parts[1])
	return false


func is_favorite(item_key: String, state: Dictionary) -> bool:
	var character: Dictionary = state.get("character", {}) as Dictionary
	var inventory: Dictionary = character.get("inventory", {}) as Dictionary
	if item_key.begins_with("magia:"):
		return (_equipment(state).get("spell_favorites", []) as Array).has(item_key.trim_prefix("magia:"))
	return (inventory.get("favorite_items", []) as Array).has(item_key)


func equip(item_key: String) -> Dictionary:
	var before := GameData.save_state_snapshot()
	var working := before.duplicate(true)
	normalise_state(working)
	var entry := describe_item(item_key, 1, working)
	if entry.is_empty() or not String(entry.kind) in ["arma", "armadura", "anel"]:
		return {"ok": false, "message": "Este objecto não se equipa."}
	var equipment := _equipment(working)
	match String(entry.kind):
		"arma":
			if GameData.weapon(String(entry.id)).is_empty():
				return {"ok": false, "message": "A ficha existe, mas o moveset ainda não está ligado ao combate."}
			var weapon := GameData.weapon(String(entry.id))
			if String(weapon.get("slot", "main")) == "offhand" or weapon.has("familia_escudo"):
				equipment["offhand"] = entry.id
			else:
				equipment["main"] = entry.id
				if int(weapon.get("hands", 1)) >= 2:
					equipment["offhand"] = null
		"armadura":
			var armor: Array = (equipment.get("armor", []) as Array).duplicate()
			var slot := String((entry.data as Dictionary).get("slot", ""))
			for i: int in range(armor.size() - 1, -1, -1):
				if _armor_slot(String(armor[i])) == slot:
					armor.remove_at(i)
			armor.append(entry.id)
			equipment["armor"] = armor
		"anel":
			var rings: Array = (equipment.get("rings", []) as Array).duplicate()
			if not rings.has(entry.id):
				if rings.size() >= 2:
					rings.pop_front()
				rings.append(entry.id)
			equipment["rings"] = rings
	_set_equipment(working, equipment)
	return _commit(before, working, "%s equipado." % String(entry.name))


func unequip(item_key: String) -> Dictionary:
	var before := GameData.save_state_snapshot()
	var working := before.duplicate(true)
	var equipment := _equipment(working)
	var parts := item_key.split(":", false, 1)
	if parts.size() != 2:
		return {"ok": false, "message": "Objecto inválido."}
	var item_id := String(parts[1])
	match String(parts[0]):
		"arma":
			if String(equipment.get("main", "")) == item_id: equipment["main"] = null
			if String(equipment.get("offhand", "")) == item_id: equipment["offhand"] = null
		"armadura":
			var armor: Array = (equipment.get("armor", []) as Array).duplicate()
			armor.erase(item_id)
			equipment["armor"] = armor
		"anel":
			var rings: Array = (equipment.get("rings", []) as Array).duplicate()
			rings.erase(item_id)
			equipment["rings"] = rings
		_:
			return {"ok": false, "message": "Este objecto não se desequipa."}
	_set_equipment(working, equipment)
	return _commit(before, working, "Objecto desequipado.")


func toggle_favorite(item_key: String, can_change_spells := true) -> Dictionary:
	var before := GameData.save_state_snapshot()
	var working := before.duplicate(true)
	normalise_state(working)
	var character: Dictionary = working.get("character", {}) as Dictionary
	var inventory: Dictionary = character.get("inventory", {}) as Dictionary
	if item_key.begins_with("magia:"):
		if not can_change_spells:
			return {"ok": false, "message": "Os 8 favoritos de magia só mudam fora de combate ou ao descansar."}
		var spell_id := item_key.trim_prefix("magia:")
		var equipment := inventory.get("equipment", {}) as Dictionary
		var favorites: Array = (equipment.get("spell_favorites", []) as Array).duplicate()
		if favorites.has(spell_id):
			favorites.erase(spell_id)
		elif favorites.size() >= MAX_SPELL_FAVORITES:
			return {"ok": false, "message": "A roda já tem 8 feitiços."}
		else:
			favorites.append(spell_id)
		equipment["spell_favorites"] = favorites
		inventory["equipment"] = equipment
	else:
		var favorites: Array = (inventory.get("favorite_items", []) as Array).duplicate()
		if favorites.has(item_key): favorites.erase(item_key)
		else: favorites.append(item_key)
		inventory["favorite_items"] = favorites
	character["inventory"] = inventory
	working["character"] = character
	return _commit(before, working, "Favorito actualizado.")


func load_profile(state := {}) -> Dictionary:
	var working: Dictionary = state if not (state as Dictionary).is_empty() \
		else GameData.save_state_snapshot()
	var equipment := _equipment(working)
	var weight := 0.0
	for armor_value: Variant in equipment.get("armor", []):
		weight += float(_armor_data(String(armor_value)).get("peso", 0.0))
	for weapon_slot: String in ["main", "offhand"]:
		var weapon_id := String(equipment.get(weapon_slot, ""))
		var weapon := GameData.weapon(weapon_id)
		var shield_family := String(weapon.get("familia_escudo", ""))
		if shield_family != "":
			weight += float(((GameData.weapons.get("familias_escudo", {}) as Dictionary).get(
				shield_family, {}) as Dictionary).get("peso", 0.0))
	var character: Dictionary = working.get("character", {}) as Dictionary
	var progression: Dictionary = character.get("progression", {}) as Dictionary
	var attrs: Dictionary = progression.get("attributes", {}) as Dictionary
	var capacity := GameData.load_capacity_for(int(attrs.get("carga", 8)))
	var fraction := weight / maxf(capacity, 0.001)
	var load_class := "sobrecarregado"
	var rules: Dictionary = GameData.armor.get("carga", {}) as Dictionary
	for candidate: String in ["leve", "medio", "pesado"]:
		if fraction <= float((rules.get(candidate, {}) as Dictionary).get("max_fraccao", 1.0)):
			load_class = candidate
			break
	var rule: Dictionary = rules.get(load_class, {}) as Dictionary
	return {"weight": weight, "capacity": capacity, "fraction": fraction,
		"class": load_class, "recovery_frames": int(rule.get("recuperacao_esquiva_frames", 0)),
		"regen_multiplier": float(rule.get("regen_stamina_mult", 1.0)),
		"can_dodge": bool(rule.get("pode_esquivar", true)),
		"can_run": bool(rule.get("pode_correr", true)),
		"can_sprint": bool(rule.get("pode_sprintar", true)),
		"max_speed": float(rule.get("velocidade_maxima_m_s", 999.0))}


func _claim(items: Dictionary, key: String) -> bool:
	if int(items.get(key, 0)) > 0:
		return false
	items[key] = 1
	return true


func _equipment(state: Dictionary) -> Dictionary:
	var character: Dictionary = state.get("character", {}) as Dictionary
	var inventory: Dictionary = character.get("inventory", {}) as Dictionary
	return (inventory.get("equipment", {}) as Dictionary).duplicate(true)


func _set_equipment(state: Dictionary, equipment: Dictionary) -> void:
	var character: Dictionary = state.get("character", {}) as Dictionary
	var inventory: Dictionary = character.get("inventory", {}) as Dictionary
	inventory["equipment"] = equipment
	character["inventory"] = inventory
	state["character"] = character


func _armor_data(item_id: String) -> Dictionary:
	var data := GameData.equipment_armor(item_id)
	if data.is_empty():
		data = (GameData.armor.get("pieces", {}) as Dictionary).get(item_id, {}) as Dictionary
	return data


func _armor_slot(item_id: String) -> String:
	return String(_armor_data(item_id).get("slot", ""))


func _commit(before: Dictionary, working: Dictionary, message: String) -> Dictionary:
	GameData.replace_save_state(working)
	if not SaveSystem.save_current():
		GameData.replace_save_state(before)
		return {"ok": false, "message": "Não foi possível guardar a alteração."}
	inventory_changed.emit()
	return {"ok": true, "message": message, "load": load_profile(working)}
