class_name VendorSelfTest
extends RefCounted
## Contrato dirigido que pode ser chamado pelo self_test canónico sem duplicar
## a lógica da loja. Também é executado isoladamente no pacote do vendedor.

const CatalogScript = preload("res://src/npc/vendor_catalog.gd")
const ServiceScript = preload("res://src/npc/vendor_service.gd")
const VendorScript = preload("res://src/npc/vendor.gd")
const SlotGrammar = preload("res://src/ui/shop_slots.gd")

var _passed := 0
var _errors: Array[String] = []


func run(game_data: Node, save_system: Node) -> Dictionary:
	_passed = 0
	_errors.clear()
	var catalog = CatalogScript.new()
	_check(catalog.load_from_game_data(game_data),
		"o catálogo comercial carrega sem erros")
	var expected: Dictionary = (catalog.config.get("catalogue_contract", {}) as Dictionary).get(
		"expected_counts", {}) as Dictionary
	var actual: Dictionary = catalog.counts()
	for kind_value: Variant in expected.keys():
		var kind := String(kind_value)
		_check(int(actual.get(kind, 0)) == int(expected.get(kind, -1)),
			"%s: todo o catálogo está à venda" % kind)
	_check(catalog.all_entries().size() == 366,
		"o vendedor expõe as 366 fichas sem consultar descoberta")
	_check(not bool((catalog.config.get("_decision", {}) as Dictionary).get(
		"discovery_gate", true)), "não existe gate de descoberta")
	_check(SlotGrammar.validate(catalog.config).is_empty(),
		"a gramática de casas tem mãos, anéis, rápidos e feitiços")
	for value: Dictionary in catalog.all_entries():
		_check(int(value.get("price", 0)) > 0,
			"%s tem preço positivo" % String(value.get("key", "")))
		var matched := false
		for group: Dictionary in SlotGrammar.definitions(catalog.config):
			matched = matched or SlotGrammar.matches(value, group)
		_check(matched, "%s aparece em pelo menos uma casa" % String(value.get("key", "")))
	_check(int(catalog.entry("arma:longsword").get("price", 0)) == 300,
		"arma de Brumal custa 300 almas")
	_check(int(catalog.entry("anel:raiz_entre_dois").get("price", 0)) == 5650,
		"anel da Raiz chega ao último degrau regional")
	var spell_prices: Array[int] = []
	for value: Dictionary in catalog.all_entries():
		if String(value.get("kind", "")) == "magia":
			spell_prices.append(int(value.get("price", 0)))
	_check(spell_prices.min() == 300 and spell_prices.max() == 9000,
		"feitiços cobrem as sete bandas de compromisso 300–9000")
	_check(int((catalog.config.get("presentation", {}) as Dictionary).get(
		"page_size", 0)) == 24, "nenhuma página mostra mais de 24 linhas")

	var service = ServiceScript.new()
	service.setup(catalog, game_data, save_system)
	var state: Dictionary = save_system.call("create_save", "vendor-contract", "warrior") as Dictionary
	_set_souls(state, 20000)
	var spell_result: Dictionary = service.purchase_in_state(state, "magia:cutelo_carmim")
	_check(bool(spell_result.get("ok", false)), "uma magia futura compra-se sem gate")
	var after_spell: Dictionary = spell_result.get("state", {}) as Dictionary
	_check(_known_spells(after_spell).has("cutelo_carmim"),
		"a compra acrescenta a magia ao conhecimento")
	_check(int(spell_result.get("souls_after", 0)) == 16200,
		"a compra gasta progression.souls_held, a moeda do nível")
	_check(not bool(service.purchase_in_state(after_spell,
		"magia:cutelo_carmim").get("ok", true)),
		"uma ficha única não compra duas vezes")
	var no_souls := state.duplicate(true)
	_set_souls(no_souls, 0)
	_check(not bool(service.purchase_in_state(no_souls,
		"consumivel:agua_lustral").get("ok", true)),
		"falta de almas recusa sem alterar estado")

	var material_state := state.duplicate(true)
	_set_souls(material_state, 0)
	_set_item_count(material_state, "material:bile_fatua", 2)
	var sale: Dictionary = service.sell_in_state(material_state, "material:bile_fatua")
	_check(bool(sale.get("ok", false)) and int(sale.get("souls_after", 0)) == 45,
		"material vende pelo trade_value do spec/72")
	_check(not bool(service.sell_in_state(state, "arma:longsword").get("ok", true)),
		"a loja recusa vender equipamento em uso")

	var vendor = VendorScript.new()
	vendor.set_trading_enabled(false, "estado externo")
	_check(not vendor.trade_enabled and vendor.unavailable_reason == "estado externo",
		"mortalidade cabe num interruptor externo sem mover stock")
	vendor.set_trading_enabled(true)
	_check(vendor.trade_enabled, "a opção imortal usa o mesmo contrato")
	vendor.free()
	return {"ok": _errors.is_empty(), "passed": _passed,
		"failed": _errors.size(), "errors": _errors.duplicate()}


func _set_souls(state: Dictionary, amount: int) -> void:
	var character: Dictionary = state.get("character", {}) as Dictionary
	var progression: Dictionary = character.get("progression", {}) as Dictionary
	progression["souls_held"] = amount
	character["progression"] = progression
	state["character"] = character


func _set_item_count(state: Dictionary, item_key: String, count: int) -> void:
	var character: Dictionary = state.get("character", {}) as Dictionary
	var inventory: Dictionary = character.get("inventory", {}) as Dictionary
	var items: Dictionary = inventory.get("items", {}) as Dictionary
	items[item_key] = count
	inventory["items"] = items
	character["inventory"] = inventory
	state["character"] = character


func _known_spells(state: Dictionary) -> Array:
	var character: Dictionary = state.get("character", {}) as Dictionary
	var progression: Dictionary = character.get("progression", {}) as Dictionary
	return progression.get("known_spells", []) as Array


func _check(condition: bool, description: String) -> void:
	if condition:
		_passed += 1
	else:
		_errors.append(description)
