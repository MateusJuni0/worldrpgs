class_name VendorService
extends RefCounted
## Transacções de loja sobre a mesma progression.souls_held usada pelo nível.
## As funções *_in_state são puras para poderem ser provadas sem escrever saves.

signal transaction_completed(result: Dictionary)

var catalog: VendorCatalog
var _game_data: Node
var _save_system: Node


func setup(source_catalog: VendorCatalog, game_data: Node, save_system: Node) -> void:
	catalog = source_catalog
	_game_data = game_data
	_save_system = save_system


func purchase(item_key: String, quantity := 1) -> Dictionary:
	var before: Dictionary = _game_data.call("save_state_snapshot") as Dictionary
	var result := purchase_in_state(before, item_key, quantity)
	return _commit(before, result)


func sell(item_key: String, quantity := 1) -> Dictionary:
	var before: Dictionary = _game_data.call("save_state_snapshot") as Dictionary
	var result := sell_in_state(before, item_key, quantity)
	return _commit(before, result)


func purchase_in_state(state: Dictionary, item_key: String, quantity := 1) -> Dictionary:
	if quantity < 1:
		return _failure("Quantidade inválida.")
	var listing := catalog.entry(item_key)
	if listing.is_empty():
		return _failure("Este objecto não pertence ao catálogo comercial.")
	var total_price := int(listing.get("price", 0)) * quantity
	var working := state.duplicate(true)
	var sections := _mutable_sections(working)
	if sections.is_empty():
		return _failure("O save não tem a estrutura de personagem esperada.")
	var progression: Dictionary = sections.get("progression", {}) as Dictionary
	var inventory: Dictionary = sections.get("inventory", {}) as Dictionary
	var items: Dictionary = inventory.get("items", {}) as Dictionary
	var souls_before := int(progression.get("souls_held", 0))
	if souls_before < total_price:
		return _failure("Faltam %d almas." % (total_price - souls_before), {
			"required": total_price, "souls": souls_before})
	var kind := String(listing.get("kind", ""))
	if bool(listing.get("unique", false)) and _owned_count(working, item_key) > 0:
		return _failure("Já tens este objecto.")
	if bool(listing.get("unique", false)) and quantity != 1:
		return _failure("Objectos únicos compram-se um de cada vez.")
	if kind == "magia":
		var known: Array = (progression.get("known_spells", []) as Array).duplicate()
		known.append(String(listing.get("id", "")))
		progression["known_spells"] = known
	else:
		var current_count := int(items.get(item_key, 0))
		var maximum := _maximum_stack(listing)
		if current_count + quantity > maximum:
			return _failure("A pilha só comporta %d." % maximum)
		items[item_key] = current_count + quantity
		inventory["items"] = items
	progression["souls_held"] = souls_before - total_price
	_write_sections(working, progression, inventory)
	return {
		"ok": true,
		"message": "%s comprado por %d almas." % [String(listing.get("name", "")), total_price],
		"state": working,
		"item_key": item_key,
		"quantity": quantity,
		"souls_before": souls_before,
		"souls_after": souls_before - total_price,
		"price": total_price,
		"direction": "buy",
	}


func sell_in_state(state: Dictionary, item_key: String, quantity := 1) -> Dictionary:
	if quantity < 1:
		return _failure("Quantidade inválida.")
	var listing := catalog.entry(item_key)
	if listing.is_empty():
		return _failure("Este objecto não pertence ao catálogo comercial.")
	if String(listing.get("kind", "")) == "magia":
		return _failure("Conhecimento aprendido não se vende.")
	if _is_equipped(item_key, state):
		return _failure("Desequipa o objecto antes de o vender.")
	var owned := _owned_count(state, item_key)
	if owned < quantity:
		return _failure("Não tens essa quantidade.")
	var unit_price := catalog.sell_price(item_key)
	if unit_price <= 0:
		return _failure("Este objecto não tem valor de troca.")
	var working := state.duplicate(true)
	var sections := _mutable_sections(working)
	if sections.is_empty():
		return _failure("O save não tem a estrutura de personagem esperada.")
	var progression: Dictionary = sections.get("progression", {}) as Dictionary
	var inventory: Dictionary = sections.get("inventory", {}) as Dictionary
	var items: Dictionary = inventory.get("items", {}) as Dictionary
	var souls_before := int(progression.get("souls_held", 0))
	var remaining := owned - quantity
	if remaining == 0:
		items.erase(item_key)
	else:
		items[item_key] = remaining
	var total_price := unit_price * quantity
	progression["souls_held"] = souls_before + total_price
	inventory["items"] = items
	_write_sections(working, progression, inventory)
	return {
		"ok": true,
		"message": "%s vendido por %d almas." % [String(listing.get("name", "")), total_price],
		"state": working,
		"item_key": item_key,
		"quantity": quantity,
		"souls_before": souls_before,
		"souls_after": souls_before + total_price,
		"price": total_price,
		"direction": "sell",
	}


func owned_count(item_key: String, state: Dictionary = {}) -> int:
	var working := state
	if working.is_empty():
		working = _game_data.call("save_state_snapshot") as Dictionary
	return _owned_count(working, item_key)


func _commit(before: Dictionary, result: Dictionary) -> Dictionary:
	if not bool(result.get("ok", false)):
		return result
	_game_data.call("replace_save_state", result.get("state", {}) as Dictionary)
	if not bool(_save_system.call("save_current")):
		_game_data.call("replace_save_state", before)
		return _failure("Não foi possível guardar a compra; nenhuma alma foi gasta.")
	transaction_completed.emit(result)
	return result


func _mutable_sections(state: Dictionary) -> Dictionary:
	var character: Dictionary = state.get("character", {}) as Dictionary
	if character.is_empty():
		return {}
	var progression: Dictionary = character.get("progression", {}) as Dictionary
	var inventory: Dictionary = character.get("inventory", {}) as Dictionary
	if progression.is_empty() or inventory.is_empty():
		return {}
	return {"progression": progression, "inventory": inventory}


func _write_sections(state: Dictionary, progression: Dictionary, inventory: Dictionary) -> void:
	var character: Dictionary = state.get("character", {}) as Dictionary
	character["progression"] = progression
	character["inventory"] = inventory
	state["character"] = character


func _owned_count(state: Dictionary, item_key: String) -> int:
	var character: Dictionary = state.get("character", {}) as Dictionary
	var progression: Dictionary = character.get("progression", {}) as Dictionary
	if item_key.begins_with("magia:"):
		return 1 if (progression.get("known_spells", []) as Array).has(
			item_key.trim_prefix("magia:")) else 0
	var inventory: Dictionary = character.get("inventory", {}) as Dictionary
	return int((inventory.get("items", {}) as Dictionary).get(item_key, 0))


func _maximum_stack(listing: Dictionary) -> int:
	var kind := String(listing.get("kind", ""))
	var data: Dictionary = listing.get("data", {}) as Dictionary
	if kind == "consumivel":
		return int(data.get("max_stack", 1))
	if kind == "material":
		var economy: Dictionary = _game_data.get("economy") as Dictionary
		return int((economy.get("rules", {}) as Dictionary).get("material_stack_max", 1))
	return 1


func _is_equipped(item_key: String, state: Dictionary) -> bool:
	var character: Dictionary = state.get("character", {}) as Dictionary
	var inventory: Dictionary = character.get("inventory", {}) as Dictionary
	var equipment: Dictionary = inventory.get("equipment", {}) as Dictionary
	var item_id := item_key.get_slice(":", 1)
	for key: String in ["main", "offhand"]:
		if String(equipment.get(key, "")) == item_id:
			return true
	for array_key: String in ["right_hand_slots", "left_hand_slots", "armor", "rings"]:
		if _array_has_item(equipment.get(array_key, []) as Array, item_key, item_id):
			return true
	return _array_has_item(inventory.get("quick_slots", []) as Array, item_key, item_id)


func _array_has_item(values: Array, item_key: String, item_id: String) -> bool:
	for value: Variant in values:
		if String(value) in [item_key, item_id]:
			return true
	return false


func _failure(message: String, details := {}) -> Dictionary:
	var result := {"ok": false, "message": message}
	for key: Variant in (details as Dictionary).keys():
		result[key] = (details as Dictionary)[key]
	return result
