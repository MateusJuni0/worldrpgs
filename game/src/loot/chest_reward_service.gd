class_name ChestRewardService
extends RefCounted
## Abre baus como uma unica mudanca de estado: marca o bau e acrescenta todo o
## conjunto. Nao conhece peso porque a mochila, por decisao, nao tem limite.

var _economy: Dictionary = {}
var _policy: RefCounted


func configure(economy: Dictionary, policy: RefCounted) -> bool:
	_economy = economy
	_policy = policy
	return not _economy.is_empty() and _policy != null \
		and validate_chests().is_empty()


func open_chest(state: Dictionary, chest_id: String) -> Dictionary:
	var definitions: Dictionary = _economy.get("chests", {}) as Dictionary
	var definition: Dictionary = definitions.get(chest_id, {}) as Dictionary
	if state.is_empty() or definition.is_empty():
		return {"status": "invalid", "chest_id": chest_id}
	var rules: Dictionary = _economy.get("chest_rules", {}) as Dictionary
	var state_key := String(rules.get("opened_state_key", "opened_chests"))
	var world: Dictionary = state.get("world", {}) as Dictionary
	var opened: Array = world.get(state_key, []) as Array
	if opened.has(chest_id):
		return {"status": "already_opened", "chest_id": chest_id}

	var biome_id := String(definition.get("biome_id", ""))
	var rewards: Array = definition.get("rewards", []) as Array
	for reward_value: Variant in rewards:
		var reward: Dictionary = reward_value as Dictionary
		var item_key := String(reward.get("item", ""))
		if int(reward.get("count", 0)) <= 0 \
				or not bool(_policy.call("item_allowed_in_biome", item_key, biome_id)):
			return {"status": "invalid_reward", "chest_id": chest_id,
				"item": item_key}

	var character: Dictionary = state.get("character", {}) as Dictionary
	var inventory: Dictionary = character.get("inventory", {}) as Dictionary
	var items: Dictionary = inventory.get("items", {}) as Dictionary
	for reward_value: Variant in rewards:
		var reward: Dictionary = reward_value as Dictionary
		var item_key := String(reward.get("item", ""))
		items[item_key] = int(items.get(item_key, 0)) + int(reward.get("count", 0))
	inventory["items"] = items
	character["inventory"] = inventory
	state["character"] = character
	opened.append(chest_id)
	world[state_key] = opened
	state["world"] = world
	return {"status": "opened", "chest_id": chest_id,
		"biome_id": biome_id, "rewards": rewards.duplicate(true)}


func validate_chests() -> PackedStringArray:
	var errors := PackedStringArray()
	var definitions: Dictionary = _economy.get("chests", {}) as Dictionary
	var rules: Dictionary = _economy.get("chest_rules", {}) as Dictionary
	if bool(rules.get("random_rewards", true)):
		errors.append("baus nao podem usar recompensa aleatoria")
	if bool(rules.get("backpack_capacity_check", true)):
		errors.append("baus nao podem inventar limite de mochila")
	for chest_id: String in definitions:
		var definition: Dictionary = definitions.get(chest_id, {}) as Dictionary
		var biome_id := String(definition.get("biome_id", ""))
		var rewards: Array = definition.get("rewards", []) as Array
		if rewards.size() < 2:
			errors.append("%s nao paga o desvio com duas utilidades" % chest_id)
		if not bool(definition.get("fatia_1", false)):
			errors.append("%s nao pertence a Fatia 1" % chest_id)
		for reward_value: Variant in rewards:
			var reward: Dictionary = reward_value as Dictionary
			var item_key := String(reward.get("item", ""))
			if int(reward.get("count", 0)) <= 0:
				errors.append("%s tem contagem invalida para %s" % [chest_id, item_key])
			elif not bool(_policy.call("item_allowed_in_biome", item_key, biome_id)):
				errors.append("%s mistura %s em %s" % [chest_id, item_key, biome_id])
	return errors
