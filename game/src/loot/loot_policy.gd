class_name LootPolicy
extends RefCounted
## Uma fronteira pequena para baralhos, filtro regional e explicacao de itens.
## Recebe catalogos em vez de procurar autoloads, para a regra ser testavel sem
## uma cena nem um save real.

var _enemies: Dictionary = {}
var _economy: Dictionary = {}
var _equipment: Dictionary = {}


func configure(enemies: Dictionary, economy: Dictionary, equipment: Dictionary) -> bool:
	_enemies = enemies
	_economy = economy
	_equipment = equipment
	return not _enemies.is_empty() and not _economy.is_empty() \
		and not _equipment.is_empty() and validate_common_decks().is_empty()


## Compra uma carta sem reposicao. O estado pertence ao chamador e pode viver
## no save; a ordem so e criada na primeira compra do tipo.
func draw_common(deck_states: Dictionary, enemy_id: String, seed_value: int,
		receiver_class_id: String) -> Dictionary:
	var enemy: Dictionary = _enemies.get(enemy_id, {}) as Dictionary
	if enemy.is_empty() or bool(enemy.get("is_boss", false)):
		return {"status": "invalid"}
	var deck_state: Dictionary = deck_states.get(enemy_id, {}) as Dictionary
	if deck_state.is_empty():
		deck_state = {
			"order": _draw_order(enemy_id, seed_value),
			"next_index": 0,
		}
	var order: Array = deck_state.get("order", []) as Array
	var next_index := int(deck_state.get("next_index", 0))
	if next_index >= order.size():
		return {"status": "exhausted", "enemy_id": enemy_id}
	var raw_card := String(order[next_index])
	var resolved: Dictionary = resolve_card_for_biome(
		enemy_id, raw_card, receiver_class_id)
	if String(resolved.get("status", "")) != "allowed":
		return resolved
	deck_state["next_index"] = next_index + 1
	deck_states[enemy_id] = deck_state
	return {
		"status": "drawn",
		"enemy_id": enemy_id,
		"deck_index": next_index,
		"raw_card": raw_card,
		"resolved_card": String(resolved.get("card", "")),
	}


## Resolve a carta enviesada e aplica a pool do bioma antes de o indice andar.
## Assim um erro de catalogo falha fechado: nao entrega o item e nao consome a
## promessa das dez mortes.
func resolve_card_for_biome(enemy_id: String, raw_card: String,
		receiver_class_id: String) -> Dictionary:
	var enemy: Dictionary = _enemies.get(enemy_id, {}) as Dictionary
	var zones: Array = enemy.get("biome_ids", []) as Array
	if enemy.is_empty() or zones.is_empty():
		return {"status": "invalid", "enemy_id": enemy_id}
	var resolved_card := _canonical_card(
		_resolve_bias(enemy, raw_card, receiver_class_id))
	if resolved_card == "":
		return {"status": "invalid", "enemy_id": enemy_id}
	for zone_value: Variant in zones:
		if item_allowed_in_biome(resolved_card, String(zone_value)):
			return {"status": "allowed", "card": resolved_card,
				"enemy_id": enemy_id, "biome_id": String(zone_value)}
	return {"status": "wrong_biome", "card": resolved_card,
		"enemy_id": enemy_id, "biome_ids": zones.duplicate()}


func item_allowed_in_biome(item_key: String, biome_id: String) -> bool:
	var zones := _item_zones(_canonical_card(item_key))
	return zones.has("*") or zones.has(biome_id)


## Valida o catalogo inteiro, nao apenas a carta sorteada num ensaio. O jogo
## pode chamar isto no arranque; o teste isolado torna a mesma fronteira prova.
func validate_common_decks() -> PackedStringArray:
	var errors := PackedStringArray()
	if _enemies.is_empty() or _economy.is_empty() or _equipment.is_empty():
		errors.append("catalogos vazios")
		return errors
	var biome_rules: Dictionary = _economy.get("loot_biomes", {}) as Dictionary
	var expected_size := int(biome_rules.get("common_deck_size", 0))
	var class_bias: Dictionary = _economy.get("class_bias", {}) as Dictionary
	var bias_by_zone: Dictionary = class_bias.get("by_zone", {}) as Dictionary
	for enemy_id: String in _enemies:
		if enemy_id.begins_with("_"):
			continue
		var enemy: Dictionary = _enemies.get(enemy_id, {}) as Dictionary
		if bool(enemy.get("is_boss", false)):
			continue
		var zones: Array = enemy.get("biome_ids", []) as Array
		var cards: Array = enemy.get("loot_cards", []) as Array
		if zones.size() != 1:
			errors.append("%s nao declara uma pool de bioma unica" % enemy_id)
			continue
		var biome_id := String(zones[0])
		if cards.size() != expected_size:
			errors.append("%s tem %d cartas; esperado %d" % [
				enemy_id, cards.size(), expected_size])
		var mandatory_count := int(enemy.get("mandatory_loot_count", 0))
		if mandatory_count <= 0 or mandatory_count > cards.size():
			errors.append("%s nao declara as cartas visiveis obrigatorias" % enemy_id)
		for card_value: Variant in cards:
			var raw_card := String(card_value)
			if raw_card == "bias:classe":
				var zone_bias: Dictionary = bias_by_zone.get(biome_id, {}) as Dictionary
				for biased_value: Variant in zone_bias.values():
					var biased_card := String(biased_value)
					if not item_allowed_in_biome(biased_card, biome_id):
						errors.append("%s enviesamento %s fora de %s" % [
							enemy_id, biased_card, biome_id])
			elif not item_allowed_in_biome(raw_card, biome_id):
				errors.append("%s carta %s fora de %s" % [
					enemy_id, raw_card, biome_id])
	return errors


## Explica a opcao no instante da queda. O chamador passa o snapshot anterior
## a recompensa, portanto equipar ou abrir menus depois nao reescreve a razao.
func describe_interest(item_key: String, state_before: Dictionary) -> Dictionary:
	var canonical := _canonical_card(item_key)
	var parts := canonical.split(":", false, 1)
	if parts.size() != 2:
		return {}
	var kind := String(parts[0])
	var item_id := String(parts[1])
	var result: Dictionary
	match kind:
		"arma":
			result = _describe_weapon(canonical, item_id, state_before)
		"armadura":
			result = _describe_armor(canonical, item_id, state_before)
		"anel":
			result = _describe_ring(canonical, item_id, state_before)
		"material":
			result = _describe_material(canonical, item_id, state_before)
		"consumivel":
			result = _describe_consumable(canonical, item_id, state_before)
		_:
			return {}
	return result


func _describe_weapon(item_key: String, item_id: String,
		state_before: Dictionary) -> Dictionary:
	var weapons: Dictionary = _equipment.get("weapons", {}) as Dictionary
	var item: Dictionary = weapons.get(item_id, {}) as Dictionary
	if item.is_empty():
		return {}
	var inventory := _inventory(state_before)
	var items: Dictionary = inventory.get("items", {}) as Dictionary
	var equipment: Dictionary = inventory.get("equipment", {}) as Dictionary
	var equipped_id := String(equipment.get(
		"offhand" if item.has("familia_escudo") else "main", ""))
	var equipped: Dictionary = weapons.get(equipped_id, {}) as Dictionary
	var name := String(item.get("nome", item_id.replace("_", " ").capitalize()))
	var reason := "Abre a pergunta: %s." % String(item.get("pergunta", "nova familia"))
	if int(items.get(item_key, 0)) > 0:
		reason = "Ja tens %s; a copia permite um voto alternativo no altar." % name
	elif not equipped.is_empty():
		var equipped_name := String(equipped.get("nome", equipped_id))
		reason = "Comparada com %s: abre %s; a equipada pede %s." % [
			equipped_name, String(item.get("pergunta", "outra resposta")),
			String(equipped.get("pergunta", "outra resposta"))]
	return {"item_key": item_key, "name": name, "reason": reason,
		"is_new": int(items.get(item_key, 0)) <= 0,
		"compared_to": equipped_id}


func _describe_armor(item_key: String, item_id: String,
		state_before: Dictionary) -> Dictionary:
	var armors: Dictionary = _equipment.get("armor", {}) as Dictionary
	var item: Dictionary = armors.get(item_id, {}) as Dictionary
	if item.is_empty():
		return {}
	var inventory := _inventory(state_before)
	var items: Dictionary = inventory.get("items", {}) as Dictionary
	var equipment: Dictionary = inventory.get("equipment", {}) as Dictionary
	var slot := String(item.get("slot", "corpo"))
	var equipped_id := ""
	for armor_value: Variant in equipment.get("armor", []) as Array:
		var candidate_id := String(armor_value)
		var candidate: Dictionary = armors.get(candidate_id, {}) as Dictionary
		if String(candidate.get("slot", "")) == slot:
			equipped_id = candidate_id
			break
	var name := String(item.get("nome", item_id.replace("_", " ").capitalize()))
	var protection := _joined_keys(item.get("resistencias", {}) as Dictionary)
	var reason := "Ocupa %s e abre proteccao em %s." % [
		slot, protection if protection != "" else "outro conjunto"]
	if int(items.get(item_key, 0)) > 0:
		reason = "Ja tens %s; a copia pode ficar noutro conjunto de equipamento." % name
	elif equipped_id != "":
		var equipped: Dictionary = armors.get(equipped_id, {}) as Dictionary
		var weight_relation := "mantem a carga"
		if float(item.get("peso", 0.0)) < float(equipped.get("peso", 0.0)):
			weight_relation = "alivia a carga"
		elif float(item.get("peso", 0.0)) > float(equipped.get("peso", 0.0)):
			weight_relation = "aumenta a carga"
		reason = "No lugar de %s, %s e protege em %s." % [
			String(equipped.get("nome", equipped_id)), weight_relation,
			protection if protection != "" else "outra ameaca"]
	return {"item_key": item_key, "name": name, "reason": reason,
		"is_new": int(items.get(item_key, 0)) <= 0,
		"compared_to": equipped_id}


func _describe_ring(item_key: String, item_id: String,
		state_before: Dictionary) -> Dictionary:
	var ring: Dictionary = (_equipment.get("rings", {}) as Dictionary).get(
		item_id, {}) as Dictionary
	if ring.is_empty():
		return {}
	var items: Dictionary = _inventory(state_before).get("items", {}) as Dictionary
	return {"item_key": item_key,
		"name": String(ring.get("nome", item_id.replace("_", " ").capitalize())),
		"reason": "Abre esta opcao passiva: %s." % String(ring.get(
			"efeito", "muda uma resposta sem bloquear classes")),
		"is_new": int(items.get(item_key, 0)) <= 0, "compared_to": ""}


func _describe_material(item_key: String, item_id: String,
		state_before: Dictionary) -> Dictionary:
	var material: Dictionary = (_economy.get("materials", {}) as Dictionary).get(
		item_id, {}) as Dictionary
	if material.is_empty():
		return {}
	var items: Dictionary = _inventory(state_before).get("items", {}) as Dictionary
	return {"item_key": item_key,
		"name": String(material.get("display_name", item_id.replace("_", " ").capitalize())),
		"reason": "Material de %s: abre escolhas de melhoria com refinamento %d." % [
			String(material.get("zone_id", "origem desconhecida")),
			int(material.get("refinement", 0))],
		"is_new": int(items.get(item_key, 0)) <= 0, "compared_to": ""}


func _describe_consumable(item_key: String, item_id: String,
		state_before: Dictionary) -> Dictionary:
	var consumable: Dictionary = (_economy.get("consumables", {}) as Dictionary).get(
		item_id, {}) as Dictionary
	if consumable.is_empty():
		return {}
	var items: Dictionary = _inventory(state_before).get("items", {}) as Dictionary
	return {"item_key": item_key,
		"name": String(consumable.get("display_name", item_id.replace("_", " ").capitalize())),
		"reason": _consumable_reason(consumable.get("effect", {}) as Dictionary),
		"is_new": int(items.get(item_key, 0)) <= 0, "compared_to": ""}


func _consumable_reason(effect: Dictionary) -> String:
	if effect.has("clear_status_meters"):
		return "Uso unico: limpa %s e abre uma resposta ao estado." % \
			", ".join(effect.get("clear_status_meters", []) as Array)
	if effect.has("weapon_coating"):
		return "Uso unico: reveste a arma com %s para mudar a resposta ao alvo." % \
			String(effect.get("weapon_coating", "outro material"))
	if effect.has("cloud_radius_m"):
		return "Uso unico: cria uma nuvem que quebra o seguimento de inimigos comuns."
	if effect.has("light_radius_m"):
		return "Uso unico: cria luz e revela o que o escuro escondia."
	if effect.has("thrown_range_m"):
		return "Uso unico: projectil que interrompe armadilhas a distancia."
	if effect.has("raio_damage_multiplier"):
		return "Uso unico: abre uma resposta defensiva contra raio."
	if effect.has("water_slow_multiplier"):
		return "Uso unico: reduz a lentidao imposta pela agua."
	if effect.has("clears_restraint"):
		return "Uso unico: solta uma prisao e dificulta a seguinte."
	if effect.has("enemy_detection_range_multiplier"):
		return "Uso unico: reduz deteccao ate atacar ou a janela terminar."
	return "Uso unico: acrescenta uma resposta situacional descrita na mochila."


func _inventory(state: Dictionary) -> Dictionary:
	var character: Dictionary = state.get("character", {}) as Dictionary
	return character.get("inventory", {}) as Dictionary


func _joined_keys(values: Dictionary) -> String:
	var labels := PackedStringArray()
	for key_value: Variant in values.keys():
		labels.append(String(key_value).replace("_", " "))
	return ", ".join(labels)


func _draw_order(enemy_id: String, seed_value: int) -> Array:
	var enemy: Dictionary = _enemies.get(enemy_id, {}) as Dictionary
	var cards: Array = (enemy.get("loot_cards", []) as Array).duplicate(true)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value ^ hash(enemy_id)
	for index: int in range(cards.size() - 1, 0, -1):
		var swap_index := rng.randi_range(0, index)
		var held: Variant = cards[index]
		cards[index] = cards[swap_index]
		cards[swap_index] = held
	return cards


func _resolve_bias(enemy: Dictionary, raw_card: String,
		receiver_class_id: String) -> String:
	if raw_card != "bias:classe":
		return raw_card
	var zones: Array = enemy.get("biome_ids", []) as Array
	if zones.is_empty():
		return ""
	var bias: Dictionary = _economy.get("class_bias", {}) as Dictionary
	var profiles: Dictionary = bias.get("profiles", {}) as Dictionary
	var profile := String(profiles.get(receiver_class_id, ""))
	var by_zone: Dictionary = bias.get("by_zone", {}) as Dictionary
	var zone_pool: Dictionary = by_zone.get(String(zones[0]), {}) as Dictionary
	return String(zone_pool.get(profile, ""))


func _canonical_card(item_key: String) -> String:
	var parts := item_key.split(":", false, 1)
	if parts.size() != 2 or String(parts[0]) != "consumivel":
		return item_key
	var aliases: Dictionary = _economy.get("aliases", {}) as Dictionary
	return "consumivel:%s" % String(aliases.get(parts[1], parts[1]))


func _item_zones(item_key: String) -> Array[String]:
	var result: Array[String] = []
	var parts := item_key.split(":", false, 1)
	if parts.size() != 2:
		return result
	var kind := String(parts[0])
	var item_id := String(parts[1])
	if kind == "almas_bonus":
		return ["*"]
	var biome_rules: Dictionary = _economy.get("loot_biomes", {}) as Dictionary
	var overrides: Dictionary = biome_rules.get("item_zone_overrides", {}) as Dictionary
	if overrides.has(item_key):
		for zone_value: Variant in overrides[item_key] as Array:
			result.append(String(zone_value))
		return result
	match kind:
		"material":
			var material: Dictionary = (_economy.get("materials", {}) as Dictionary).get(
				item_id, {}) as Dictionary
			_append_zone(result, String(material.get("zone_id", "")))
		"arma":
			var weapon: Dictionary = (_equipment.get("weapons", {}) as Dictionary).get(
				item_id, {}) as Dictionary
			_append_zone(result, String(weapon.get("origem", "")))
		"armadura":
			var armor: Dictionary = (_equipment.get("armor", {}) as Dictionary).get(
				item_id, {}) as Dictionary
			var known_ids: Dictionary = _known_biome_ids()
			for resistance_value: Variant in (armor.get("resistencias", {}) as Dictionary).keys():
				var resistance := String(resistance_value)
				if known_ids.has(resistance):
					_append_zone(result, resistance)
		"anel":
			var ring: Dictionary = (_equipment.get("rings", {}) as Dictionary).get(
				item_id, {}) as Dictionary
			var location := String(ring.get("onde_se_encontra", "")).split(",")[0]
			var display_to_id: Dictionary = biome_rules.get("display_to_id", {}) as Dictionary
			_append_zone(result, String(display_to_id.get(location, "")))
	return result


func _known_biome_ids() -> Dictionary:
	var result := {}
	var bias: Dictionary = _economy.get("class_bias", {}) as Dictionary
	for zone_value: Variant in (bias.get("by_zone", {}) as Dictionary).keys():
		result[String(zone_value)] = true
	return result


func _append_zone(zones: Array[String], biome_id: String) -> void:
	if biome_id != "" and not zones.has(biome_id):
		zones.append(biome_id)
