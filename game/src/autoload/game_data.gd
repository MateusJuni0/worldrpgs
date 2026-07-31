extends Node
## Carrega todos os ficheiros de dados e constroi o mapa de comandos em runtime.
##
## REGRA DO PROTOTIPO: nenhum numero de combate vive em codigo. Vive em res://data/*.json.
## Para afinar uma janela, um custo ou um MV, mexe-se no JSON e volta-se a correr — sem recompilar.
##
## Fontes: spec/01-combate.md (WP1 — frames, janelas, MV, custos)
##         spec/11-formulas.md (WP2 — atributos, formula de dano, curvas dos inimigos)

const DATA_DIR := "res://data/"

var combat: Dictionary = {}
var weapons: Dictionary = {}
var enemies: Dictionary = {}
var spells: Dictionary = {}
var controls: Dictionary = {}
var attributes: Dictionary = {}
var abilities: Dictionary = {}
var biomes: Dictionary = {}

var load_errors: Array[String] = []


func _ready() -> void:
	combat = _load_json("combat.json")
	weapons = _load_json("weapons.json")
	enemies = _load_json("enemies.json")
	spells = _load_json("spells.json")
	controls = _load_json("controls.json")
	attributes = _load_json("attributes.json")
	abilities = _load_json("abilities.json")
	biomes = _load_json("biomes.json")
	_build_input_map()
	_validate()


func _load_json(file_name: String) -> Dictionary:
	var path := DATA_DIR + file_name
	if not FileAccess.file_exists(path):
		_fail("Ficheiro de dados em falta: %s" % path)
		return {}
	var text := FileAccess.get_file_as_string(path)
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		_fail("JSON invalido em %s" % path)
		return {}
	return parsed as Dictionary


func _fail(message: String) -> void:
	load_errors.append(message)
	push_error(message)


# --- Acessos ------------------------------------------------------------------

## Converte frames (a 60 fps de referencia) em segundos.
func frames_to_seconds(f: float) -> float:
	return f / float(combat.get("reference_fps", 60))


func section(name: String) -> Dictionary:
	return combat.get(name, {}) as Dictionary


func weapon(id: String) -> Dictionary:
	if id == "":
		return {}
	return weapons.get(id, {}) as Dictionary


func enemy(id: String) -> Dictionary:
	return enemies.get(id, {}) as Dictionary


func spell(id: String) -> Dictionary:
	return spells.get(id, {}) as Dictionary


func class_attributes(class_id: String) -> Dictionary:
	return (attributes.get("classes", {}) as Dictionary).get(class_id, {}) as Dictionary


# --- Formulas do WP2 (spec/11-formulas.md) ------------------------------------

func _dmg_cfg() -> Dictionary:
	return attributes.get("damage", {}) as Dictionary


func _formula(name: String) -> Dictionary:
	return (attributes.get("formulas", {}) as Dictionary).get(name, {}) as Dictionary


## PV = 200 + 22 x Vida   (acima do soft cap, +8/ponto)
func max_health_for(vida: int) -> float:
	var f := _formula("health")
	var soft: int = attributes.get("soft_cap", 30)
	var base: float = f.get("base", 200.0)
	var per: float = f.get("per_point", 22.0)
	var per_after: float = f.get("per_point_after_soft_cap", 8.0)
	if vida <= soft:
		return base + per * float(vida)
	return base + per * float(soft) + per_after * float(vida - soft)


## STA = 80 + 2 x Stamina.  A regeneracao (40/s) nao escala — Lei 1.
func max_stamina_for(stamina_attr: int) -> float:
	var f := _formula("stamina")
	return float(f.get("base", 80.0)) + float(f.get("per_point", 2.0)) * float(stamina_attr)


## DEF = 2 x Constituicao
func defense_for(constituicao: int) -> float:
	return float(_formula("defense").get("per_point", 2.0)) * float(constituicao)


## cargas TOTAIS = 4 + floor(Sabedoria / 4)
func max_charges_for(sabedoria: int) -> int:
	var f := _formula("charges")
	var base: int = f.get("base", 4)
	var per: int = f.get("points_per_charge", 4)
	return base + int(floor(float(sabedoria) / float(per)))


## escala = 1 + 0,015 x (atributo - 8) x peso_da_escala
func attribute_scale(attr_value: float, weight_name: String) -> float:
	var cfg := _dmg_cfg()
	var coef: float = cfg.get("scale_coefficient", 0.015)
	var weights: Dictionary = cfg.get("scale_weights", {}) as Dictionary
	var w: float = weights.get(weight_name, 0.6)
	var base_attr: float = float(attributes.get("base_value", 8))
	return 1.0 + coef * (attr_value - base_attr) * w


## O jogador cumpre os requisitos da arma?
## Lei 3: nunca proibe pegar na arma — falhar custa em numeros (x0,6), nao em permissao.
func meets_requirements(weapon_id: String, attrs: Dictionary) -> bool:
	var reqs: Dictionary = weapon(weapon_id).get("requirements", {}) as Dictionary
	for attr_name: String in reqs.keys():
		if float(attrs.get(attr_name, 0)) < float(reqs[attr_name]):
			return false
	return true


## dano = MV x dano_base_da_arma x escala - DEF_do_alvo
## A DEF corta no maximo 40% (minimo 60% do dano calculado).
## Abaixo do requisito da arma: dano x0,6 e escala = 1.
func compute_damage(mv: float, weapon_id: String, attrs: Dictionary, target_defense: float) -> float:
	var w := weapon(weapon_id)
	if w.is_empty():
		return 0.0
	var cfg := _dmg_cfg()
	var base: float = w.get("base_damage", 0.0)
	var scale := 1.0
	var penalty := 1.0
	if meets_requirements(weapon_id, attrs):
		var attr_name: String = w.get("scaling_attribute", "")
		var attr_value: float = float(attrs.get(attr_name, attributes.get("base_value", 8)))
		scale = attribute_scale(attr_value, String(w.get("scale_weight", "medio")))
	else:
		scale = float(cfg.get("below_requirement_scale", 1.0))
		penalty = float(cfg.get("below_requirement_damage_multiplier", 0.6))

	var raw := mv * base * scale * penalty
	return apply_defense(raw, target_defense)


## Aplica a DEF a um dano bruto, respeitando o tecto de 40% de corte.
## Usado pelos inimigos, cujo dano vem fixado no WP2 em vez de sair de uma arma.
func apply_defense(raw: float, target_defense: float) -> float:
	var floor_fraction: float = _dmg_cfg().get("min_damage_fraction_after_defense", 0.6)
	return maxf(raw * floor_fraction, raw - target_defense)


## Dano de postura por golpe = MV x 10 (spec/01-combate.md, "Poise e interrupcao")
func posture_damage_from_mv(mv: float, multiplier: float = 1.0) -> float:
	var per_mv: float = section("poise").get("posture_damage_per_mv", 10.0)
	return mv * per_mv * multiplier


# --- Mapa de comandos ---------------------------------------------------------

func _build_input_map() -> void:
	var actions: Dictionary = controls.get("actions", {}) as Dictionary
	for action_name: String in actions.keys():
		if action_name.begins_with("_"):
			continue
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name, 0.2)
		InputMap.action_erase_events(action_name)
		for binding: Variant in actions[action_name]:
			var event := _event_from_binding(binding as Dictionary, action_name)
			if event != null:
				InputMap.action_add_event(action_name, event)


func _event_from_binding(binding: Dictionary, action_name: String) -> InputEvent:
	match binding.get("type", ""):
		"key":
			var code := _keycode_from_name(String(binding.get("key", "")))
			if code == KEY_NONE:
				_fail("Tecla desconhecida '%s' na accao '%s'" % [binding.get("key", ""), action_name])
				return null
			var ev := InputEventKey.new()
			ev.physical_keycode = code
			return ev
		"mouse":
			var mb := InputEventMouseButton.new()
			mb.button_index = int(binding.get("button", 1)) as MouseButton
			return mb
	_fail("Tipo de ligacao desconhecido em '%s'" % action_name)
	return null


func _keycode_from_name(n: String) -> Key:
	if n.length() == 1:
		var c := n.to_upper().unicode_at(0)
		if c >= 65 and c <= 90:
			return (KEY_A + (c - 65)) as Key
		if c >= 48 and c <= 57:
			return (KEY_0 + (c - 48)) as Key
	# F1..F12, genericamente — para nao voltar a faltar um F6.
	if n.length() >= 2 and n[0] == "F" and n.substr(1).is_valid_int():
		var fn := n.substr(1).to_int()
		if fn >= 1 and fn <= 12:
			return (KEY_F1 + (fn - 1)) as Key
	match n:
		"Space": return KEY_SPACE
		"Shift": return KEY_SHIFT
		"Ctrl", "Control": return KEY_CTRL
		"Alt": return KEY_ALT
		"Tab": return KEY_TAB
		"Escape": return KEY_ESCAPE
		"Enter", "Return": return KEY_ENTER
		"BracketLeft": return KEY_BRACKETLEFT
		"BracketRight": return KEY_BRACKETRIGHT
	return KEY_NONE


# --- Guardas de coerencia com a spec ------------------------------------------
# Falham alto (push_error) em vez de falhar em silencio. Um numero fora da spec
# e um bug critico neste prototipo: e a spec que manda.

func _validate() -> void:
	var checks := 0

	# 1. Todo o ataque inimigo tem de ter >= 0,5 s (30 f) de aviso legivel.
	const MIN_STARTUP := 30
	for enemy_id: String in enemies.keys():
		if enemy_id.begins_with("_"):
			continue
		var e: Dictionary = enemies[enemy_id]
		for atk: Variant in e.get("attacks", []):
			var a := atk as Dictionary
			if int(a.get("startup", 0)) < MIN_STARTUP:
				_fail("[SPEC] %s/%s tem arranque %d f (< %d f = 0,5 s de aviso)"
					% [enemy_id, a.get("id", "?"), int(a.get("startup", 0)), MIN_STARTUP])
			var follow: Variant = a.get("followup", null)
			if follow != null and int((follow as Dictionary).get("startup", 0)) < MIN_STARTUP:
				_fail("[SPEC] %s/%s (seguimento) tem arranque abaixo de %d f"
					% [enemy_id, a.get("id", "?"), MIN_STARTUP])
		# Fugir tem de ser sempre possivel: perseguicao abaixo do correr do jogador.
		var run_speed: float = section("movement").get("run_speed", 5.0)
		if float(e.get("chase_speed", 0.0)) >= run_speed:
			_fail("[SPEC] %s persegue a %.1f m/s (>= correr do jogador, %.1f)"
				% [enemy_id, e.get("chase_speed", 0.0), run_speed])
	checks += 1

	# 2. O brutamontes e o professor de parry: TODOS os golpes dele sao aparaveis.
	for atk: Variant in enemy("orc_brute").get("attacks", []):
		if not bool((atk as Dictionary).get("parryable", false)):
			_fail("[SPEC] orc_brute/%s nao e aparavel — todos os golpes do brutamontes tem de ser"
				% (atk as Dictionary).get("id", "?"))
	checks += 1

	# 3. Golpes-para-matar a nivel 1, Guerreiro, leve de espada longa (spec/01 + spec/11).
	var warrior := class_attributes("warrior")
	var light_mv: float = (weapon("longsword").get("light", {}) as Dictionary).get("mv", 1.0)
	if not warrior.is_empty():
		_check_hits("orc_spearman", light_mv, warrior, 3, 5)
		_check_hits("orc_brute", light_mv, warrior, 6, 9)
		_check_hits("vorgar", light_mv, warrior, 45, 70)
	checks += 1

	# 4. As formulas do WP2 no exemplo resolvido (atributo 10 = o caso de referencia).
	_expect(max_health_for(10), 420.0, "formula de PV com Vida 10")
	_expect(max_stamina_for(10), 100.0, "formula de STA com Stamina 10")
	_expect(defense_for(10), 20.0, "formula de DEF com Constituicao 10")
	# O caso de referencia que o WP4 usa: Feiticeiro com Sab 14 arranca com 7 cargas.
	var sorcerer := class_attributes("sorcerer")
	if not sorcerer.is_empty():
		_expect(float(max_charges_for(int(sorcerer.get("sabedoria", 0)))), 7.0,
			"cargas de arranque do Feiticeiro")
	checks += 1

	# 5. Cada classe distribui exactamente +14 pontos sobre a base 8.
	var base_v: int = attributes.get("base_value", 8)
	var bonus: int = attributes.get("class_bonus_points", 14)
	var ids: Array = attributes.get("attribute_ids", [])
	for class_id: String in (attributes.get("classes", {}) as Dictionary).keys():
		if class_id.begins_with("_"):
			continue
		var c: Dictionary = class_attributes(class_id)
		var spent := 0
		for attr_name: Variant in ids:
			spent += int(c.get(attr_name, base_v)) - base_v
		if spent != bonus:
			_fail("[SPEC] classe '%s' distribui %d pontos (a spec da %d)" % [class_id, spent, bonus])
	checks += 1

	# 6. As 12 fichas de bioma (spec/49-biomas.md): 8 linhas cada, paleta de 3
	# cores hex, e exactamente UMA na fatia 1 (Brumal). A ficha e a fonte da
	# luz e da nevoa — um campo em falta e um bioma que nao se consegue construir.
	const BIOME_FIELDS: Array[String] = ["nome", "elemento", "eficaz_contra_nativos",
		"material", "paleta", "racas", "colheita", "ameaca", "historia",
		"descricao_visual", "fatia_1"]
	var ids_b := biome_ids()
	if ids_b.size() != 12:
		_fail("[SPEC] %d biomas em biomes.json (a spec/49 diz 12)" % ids_b.size())
	var in_slice := 0
	for biome_id in ids_b:
		var b := biome(biome_id)
		for field in BIOME_FIELDS:
			if not b.has(field):
				_fail("[SPEC] bioma '%s' sem o campo '%s' (spec/49 §3)" % [biome_id, field])
		var pal: Dictionary = b.get("paleta", {}) as Dictionary
		for colour_key: String in ["luz", "nevoa", "acento"]:
			var c := String(pal.get(colour_key, ""))
			if not c.is_valid_html_color():
				_fail("[SPEC] bioma '%s': cor '%s' invalida ('%s')" % [biome_id, colour_key, c])
		if String((b.get("racas", {}) as Dictionary).get("dominante", "")) == "":
			_fail("[SPEC] bioma '%s' sem raca dominante (spec/46 §2)" % biome_id)
		if bool(b.get("fatia_1", false)):
			in_slice += 1
	if in_slice != 1:
		_fail("[SPEC] %d biomas na fatia 1 (a spec/10 diz 1 — Brumal)" % in_slice)
	checks += 1

	if load_errors.is_empty():
		print("[GameData] dados carregados — %d grupos de verificacoes contra a spec passaram" % checks)
	else:
		printerr("[GameData] %d PROBLEMAS DE COERENCIA COM A SPEC" % load_errors.size())


func _check_hits(enemy_id: String, mv: float, attrs: Dictionary, lo: int, hi: int) -> void:
	var e := enemy(enemy_id)
	var per_hit := compute_damage(mv, "longsword", attrs, float(e.get("defense", 0.0)))
	if per_hit <= 0.0:
		_fail("[SPEC] dano nulo contra %s" % enemy_id)
		return
	var hits := int(ceil(float(e.get("health", 0.0)) / per_hit))
	if hits < lo or hits > hi:
		_fail("[SPEC] %s morre em %d leves de espada (a spec exige %d-%d)" % [enemy_id, hits, lo, hi])


func _expect(got: float, want: float, what: String) -> void:
	if absf(got - want) > 0.01:
		_fail("[SPEC] %s deu %.1f, a spec diz %.1f" % [what, got, want])


func ability(class_id: String) -> Dictionary:
	return abilities.get(class_id, {}) as Dictionary


func biome(id: String) -> Dictionary:
	return biomes.get(id, {}) as Dictionary


## Ids reais dos biomas (ignora as chaves "_meta" do JSON).
func biome_ids() -> Array[String]:
	var out: Array[String] = []
	for k: String in biomes.keys():
		if not k.begins_with("_"):
			out.append(k)
	return out
