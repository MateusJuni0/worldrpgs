class_name WeaponVisual
extends "res://src/visual/weapon_attach.gd"
## Preview de equipamento que usa exactamente o renderer das armas em jogo.
##
## A lista de conteudo pertence a `weapons.json`: cada entrada executavel
## declara `presentation.model_asset`. Um caminho `res://` escolhe um modelo
## curado; `procedural:<forma>` escolhe uma das formas low-poly do renderer
## partilhado com o Player. Assim uma arma nova nao fica invisivel por faltar
## numa segunda lista escrita a mao.

# Compatibilidade transitória com a prova isolada antiga. Deliberadamente
# vazio: o catálogo, e não este símbolo, descobre as armas executáveis.
const WEAPON_SCENES := {}

static var _audited_signature := ""
static var _audited_errors := PackedStringArray()
static var _audited_count := 0
static var _audited_usec := 0


func setup(actor: Node, character_visual: Node3D) -> bool:
	var ready := super.setup(actor, character_visual)
	name = "WeaponVisual"
	if not ready:
		return false
	# Instanciar dez modelos serve a prova, não o frame em que o jogador abre o
	# menu. `repro-inicio` expõe `_falhar`; as sondas `--script` não têm
	# current_scene. Em produção fica apenas o modelo seleccionado pelo jogador.
	var scene := get_tree().current_scene
	if scene != null and not scene.has_method("_falhar"):
		return true
	var signature := _catalogue_signature()
	if signature != _audited_signature:
		var started_usec := Time.get_ticks_usec()
		_audited_errors = _prove_executable_catalogue_visible()
		_audited_usec = Time.get_ticks_usec() - started_usec
		_audited_signature = signature
	if not _audited_errors.is_empty():
		var message := "catalogo executavel sem resultado visivel: %s" % \
			" | ".join(_audited_errors)
		# `repro-inicio.tscn` chega aqui depois de o jogador abrir a mochila e
		# carregar em EDITAR ACESSO RAPIDO. Delegar a falha à cena conserva o
		# código de saída e, sobretudo, a limpeza dos saves isolados da prova.
		if scene != null and scene.has_method("_falhar"):
			scene.call_deferred("_falhar", "armas visiveis: %s" % message)
		else:
			assert(false, "[weapon-visual] %s" % message)
		return false
	print("[weapon-visual] %d armas executaveis visiveis no ecrã (%d us)" % [
		_audited_count, _audited_usec])
	return true


func model_declaration_for(weapon_id: String) -> String:
	var presentation := _weapon_data(weapon_id).get("presentation", {}) as Dictionary
	var declaration: Variant = presentation.get("model_asset", "")
	return "" if declaration == null else String(declaration)


func model_source_for(weapon_id: String) -> String:
	var declaration := model_declaration_for(weapon_id)
	return declaration if declaration.begins_with("res://") else ""


func has_visible_weapon(weapon_id: String, main_hand := true) -> bool:
	# O preview historico aceitava apenas o ID e procurava nas duas maos. Mantem
	# esse contrato, sem alterar a versao estrita usada pelo Player.
	return super.has_visible_weapon(weapon_id, main_hand) \
		or (main_hand and super.has_visible_weapon(weapon_id, false))


func catalogue_visual_audit() -> Dictionary:
	return {
		"executable_count": _audited_count,
		"errors": Array(_audited_errors),
		"elapsed_usec": _audited_usec,
	}


func _catalogue_signature() -> String:
	var game_data := get_node_or_null("/root/GameData")
	if game_data == null:
		return "missing-game-data"
	var catalogue := game_data.get("weapons") as Dictionary
	var declarations: Array[String] = []
	for id_value: Variant in catalogue.keys():
		var weapon_id := String(id_value)
		var value: Variant = catalogue.get(weapon_id, {})
		if typeof(value) != TYPE_DICTIONARY:
			continue
		var entry := value as Dictionary
		if _is_executable_entry(weapon_id, entry):
			declarations.append("%s=%s" % [weapon_id, model_declaration_for(weapon_id)])
	declarations.sort()
	return "|".join(declarations)


func _prove_executable_catalogue_visible() -> PackedStringArray:
	var errors := PackedStringArray()
	var game_data := get_node_or_null("/root/GameData")
	if game_data == null:
		errors.append("GameData nao entrou no jogo")
		return errors
	var catalogue := game_data.get("weapons") as Dictionary
	var executable_ids: Array[String] = []
	for id_value: Variant in catalogue.keys():
		var weapon_id := String(id_value)
		var value: Variant = catalogue.get(weapon_id, {})
		if typeof(value) == TYPE_DICTIONARY and _is_executable_entry(
				weapon_id, value as Dictionary):
			executable_ids.append(weapon_id)
	executable_ids.sort()
	_audited_count = executable_ids.size()

	var original_main := _main_weapon_id
	var original_offhand := _offhand_weapon_id
	var original_two_handed := _two_handed
	var talisman_signature := ""
	var bell_signature := ""
	var shield_signatures: Array[String] = []

	for weapon_id: String in executable_ids:
		var raw_entry := catalogue.get(weapon_id, {}) as Dictionary
		var data := _weapon_data(weapon_id)
		var declaration := model_declaration_for(weapon_id)
		if declaration.is_empty():
			errors.append("%s nao declara presentation.model_asset" % weapon_id)
		elif declaration.begins_with("res://"):
			if not ResourceLoader.exists(declaration):
				errors.append("%s aponta para modelo inexistente: %s" % [
					weapon_id, declaration])
		elif declaration.begins_with("procedural:"):
			var declared_kind := declaration.trim_prefix("procedural:")
			var inferred_kind := _procedural_kind(data)
			if declared_kind != inferred_kind:
				errors.append("%s declara %s mas a ficha descreve %s" % [
					weapon_id, declared_kind, inferred_kind])
		else:
			errors.append("%s usa declaracao de modelo desconhecida: %s" % [
				weapon_id, declaration])

		var offhand := String(raw_entry.get("slot", "")) == "offhand"
		if offhand:
			sync_loadout("", weapon_id, false)
		else:
			sync_loadout(weapon_id, "", false)
		var model := _offhand_model if offhand else _main_model
		if not is_instance_valid(model) or not model.visible:
			errors.append("%s nao apareceu na mao do preview real" % weapon_id)
			continue
		var mesh_count := _mesh_count(model)
		if mesh_count == 0:
			errors.append("%s apareceu sem geometria renderizavel" % weapon_id)
			continue
		var visual_signature := _silhouette_signature(model, mesh_count)
		var procedural_kind := _procedural_kind(data)
		if procedural_kind == "talisman":
			talisman_signature = visual_signature
		elif procedural_kind == "bell":
			bell_signature = visual_signature
		if not String(raw_entry.get("familia_escudo", "")).is_empty():
			shield_signatures.append(visual_signature)

	if not talisman_signature.is_empty():
		if talisman_signature == bell_signature:
			errors.append("talisma e sino produzem a mesma silhueta")
		for shield_signature: String in shield_signatures:
			if talisman_signature == shield_signature:
				errors.append("talisma reutiliza a silhueta de um escudo pequeno")
				break
			if bell_signature == shield_signature:
				errors.append("sino reutiliza a silhueta de um escudo pequeno")
				break

	# A auditoria usa as mesmas duas mãos do preview antes de o SubViewport ser
	# mostrado. Devolve já o loadout que o jogador estava a comparar.
	sync_loadout("", "", false)
	_main_weapon_id = ""
	_offhand_weapon_id = ""
	sync_loadout(original_main, original_offhand, original_two_handed)
	return errors


static func _is_executable_entry(weapon_id: String, entry: Dictionary) -> bool:
	return not weapon_id.begins_with("_") \
		and entry.has("slot") and entry.has("hands")


static func _procedural_kind(data: Dictionary) -> String:
	var visual_kind := _visual_kind(data)
	if visual_kind in ["bell", "talisman"]:
		return visual_kind
	var description := String(data.get("descricao_visual",
		data.get("visual_description", "")))
	if description.is_empty():
		description = String((data.get("visual", {}) as Dictionary).get(
			"visual_description", ""))
	var normal := description.to_lower()
	if "curva" in normal and ("lamina" in normal or "lâmina" in normal):
		return "curved_blade"
	if "cajado" in normal:
		return "staff"
	if "haste" in normal or "lanca" in normal or "lança" in normal:
		return "polearm"
	return ""


static func _mesh_count(model: Node3D) -> int:
	var result := 1 if model is MeshInstance3D \
		and (model as MeshInstance3D).mesh != null else 0
	for descendant: Node in model.find_children("*", "MeshInstance3D", true, false):
		if (descendant as MeshInstance3D).mesh != null:
			result += 1
	return result


static func _silhouette_signature(model: Node3D, mesh_count: int) -> String:
	var size := _model_bounds(model).size.abs()
	var dimensions: Array[float] = [size.x, size.y, size.z]
	dimensions.sort()
	var largest := dimensions[2]
	if largest <= 0.0:
		return "empty:%d" % mesh_count
	return "%.4f:%.4f:%d" % [
		dimensions[0] / largest, dimensions[1] / largest, mesh_count]
