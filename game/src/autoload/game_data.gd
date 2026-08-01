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
var races: Dictionary = {}
var armor: Dictionary = {}
var equipment: Dictionary = {}
var save_state: Dictionary = {}

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
	races = _load_json("races.json")
	armor = _load_json("armor.json")
	equipment = _load_json("equipment.json")
	_expand_enemy_catalog()
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


func ring(id: String) -> Dictionary:
	return (equipment.get("rings", {}) as Dictionary).get(id, {}) as Dictionary


func equipment_weapon(id: String) -> Dictionary:
	return (equipment.get("weapons", {}) as Dictionary).get(id, {}) as Dictionary


func equipment_armor(id: String) -> Dictionary:
	return (equipment.get("armor", {}) as Dictionary).get(id, {}) as Dictionary


## O JSON guarda declaracoes compactas de ataques, mas o runtime recebe sempre
## a ficha completa do spec/38. Assim um molde de contacto corrige todos os
## utilizadores sem apagar a pose, o som ou a ancora propria de cada golpe.
func _expand_enemy_catalog() -> void:
	var templates: Dictionary = enemies.get("_attack_templates", {}) as Dictionary
	var defaults: Dictionary = enemies.get("_enemy_defaults", {}) as Dictionary
	for enemy_id: String in enemies.keys():
		if enemy_id.begins_with("_"):
			continue
		var e: Dictionary = defaults.duplicate(true)
		e.merge(enemies[enemy_id] as Dictionary, true)
		enemies[enemy_id] = e
		var expanded: Array = []
		for value: Variant in e.get("attacks", []):
			var declared: Dictionary = value as Dictionary
			var template_id := String(declared.get("template", ""))
			var attack: Dictionary = (templates.get(template_id, {}) as Dictionary).duplicate(true)
			attack.merge(declared, true)
			var phase_1 := int(attack.get("phase_1_frames", 24))
			var phase_2 := int(attack.get("phase_2_frames", 12))
			var startup := phase_1 + phase_2
			var active := int(attack.get("active", 5))
			var recovery := int(attack.get("recovery", 30))
			var phase_4 := mini(int(attack.get("phase_4_frames", 8)), recovery)
			var actor := String(attack.get("actor", "corpo"))
			var tell := String(attack.get("tell", "recolhe antes de avancar"))
			var impact := String(attack.get("impact", "cruza o espaco marcado"))
			var sound_description := String(attack.get("sound", "esforco e deslocacao de ar distintos"))
			var anchor := String(attack.get("anchor", actor))
			attack["startup"] = startup
			attack["aviso_total_frames"] = startup
			attack["fase_1"] = "%d f — %s: %s" % [phase_1, actor, tell]
			attack["fase_2"] = "%d f — %s; ajuste cai para 30 graus/s" % [phase_2, sound_description]
			attack["fase_3"] = "%d f — %s" % [active, impact]
			attack["fases_4_5"] = "%d f de saida + %d f de regresso" % [phase_4, recovery - phase_4]
			attack["momento_compromisso_frame"] = phase_1
			attack["curva_seguimento"] = {
				"fase_1_deg_s": 180,
				"fase_2_deg_s": 30,
				"fase_3_deg_s": 0,
			}
			attack["som_anuncio"] = {
				"cue_id": "attack.%s.%s" % [enemy_id, attack.get("id", "unknown")],
				"descricao": sound_description,
				"profile": _attack_sound_profile(attack),
				"alcance_informativo_m": float(attack.get("informative_range_m", 18.0)),
			}
			attack["sinal_visual_equivalente"] = {
				"ancora": anchor,
				"forma": String(attack.get("visual_shape", "losango partido ESQUIVAR")),
				"inicio": "surge no frame 1, preso a %s" % anchor,
				"compromisso": "fecha no primeiro frame activo, frame %d" % (startup + 1),
				"fim": "dissolve no fim; se cancelado, quebra em 0,15 s",
				"fora_ecra": "cunha no bordo na direccao da origem, com a mesma forma e tres bandas de distancia",
			}
			if attack.has("radius"):
				attack["alcance_arco"] = "raio %.1f m · 360 graus" % float(attack.get("radius", 0.0))
			else:
				attack["alcance_arco"] = "%.1f m · %d graus" % [
					float(attack.get("range", 0.0)), int(attack.get("arc_degrees", 0))]
			attack["descricao_visual"] = "%s; %s; materiais e silhueta pertencem ao inimigo que o executa" % [tell, impact]
			attack["fatia_1"] = bool(e.get("fatia_1", false))
			expanded.append(attack)
		e["attacks"] = expanded

		if not bool(e.get("is_boss", false)):
			var cards: Array = (e.get("loot_cards", []) as Array).duplicate(true)
			var mandatory_count := mini(int(e.get("mandatory_loot_count", 0)), cards.size())
			var mandatory_indices: Array = []
			for index in mandatory_count:
				mandatory_indices.append(index)
			e["loot_deck"] = {
				"cards": cards,
				"mandatory_indices": mandatory_indices,
				"without_replacement": true,
				"bias_only_on_filler": true,
			}
		if not e.has("patterns") and not bool(e.get("is_boss", false)):
			var single_patterns: Array = []
			for attack_value: Variant in expanded:
				if not bool((attack_value as Dictionary).get("anti_kite_only", false)):
					single_patterns.append([String((attack_value as Dictionary).get("id", ""))])
			e["patterns"] = single_patterns
		e["gap_between_patterns"] = float(e.get("gap_between_patterns", 1.25))


## Ordem reproduzivel do baralho. O estado de save guarda depois o indice e as
## cartas tiradas; esta funcao garante que o mesmo ensaio + semente da spec/60
## produz exactamente a mesma sequencia.
func loot_draw_order(enemy_id: String, seed_value: int) -> Array:
	var cards: Array = ((enemy(enemy_id).get("loot_deck", {}) as Dictionary).get("cards", []) as Array).duplicate(true)
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value ^ hash(enemy_id)
	for i in range(cards.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var held: Variant = cards[i]
		cards[i] = cards[j]
		cards[j] = held
	return cards


func _attack_sound_profile(attack: Dictionary) -> String:
	var vectors: Array = attack.get("vectores_fuga", []) as Array
	if String(attack.get("tipo_contacto", "")) == "volume_persistente":
		return "attack_area"
	if vectors.has("quebrar_a_visao"):
		return "attack_hunter"
	if String(attack.get("tipo_contacto", "")) == "volume_movel":
		return "attack_moving"
	if bool(attack.get("parryable", false)):
		return "attack_parry"
	return "attack_dodge"


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


## A reserva de mana cresce com o melhor dos dois atributos de conjuracao.
## A escola vermelha usa o MENOR apenas para a eficacia do feitico, nunca para
## reduzir a reserva partilhada por todas as escolas (spec/42 + spec/66).
func max_mana_for(attrs: Dictionary) -> int:
	var f := _formula("mana")
	var intelligence := int(attrs.get("inteligencia", 8))
	var faith := int(attrs.get("fe", 8))
	var casting_attr := maxi(intelligence, faith)
	var soft_cap := int(f.get("soft_cap", 35))
	var first_band := mini(casting_attr, soft_cap)
	var after_cap := maxi(casting_attr - soft_cap, 0)
	return int(f.get("base", 60)) \
		+ first_band * int(f.get("per_point", 4)) \
		+ after_cap * int(f.get("per_point_after_soft_cap", 1))


func casting_attribute_for(school_id: String, attrs: Dictionary) -> float:
	var schools: Dictionary = spells.get("_schools", {}) as Dictionary
	var school: Dictionary = schools.get(school_id, {}) as Dictionary
	var intelligence := float(attrs.get("inteligencia", 8))
	var faith := float(attrs.get("fe", 8))
	match String(school.get("scaling", "inteligencia")):
		"fe":
			return faith
		"media_int_fe":
			return (intelligence + faith) * 0.5
		"menor_int_fe":
			return minf(intelligence, faith)
		_:
			return intelligence


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
	# A reserva usa o melhor atributo de conjuracao; a escola vermelha usa o menor
	# apenas na eficacia dos seus feiticos (spec/42 + spec/66).
	var sorcerer := class_attributes("sorcerer")
	if not sorcerer.is_empty():
		_expect(float(max_mana_for(sorcerer)), 116.0,
			"mana de arranque do Feiticeiro")
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

	# 7. O laco bioma <-> raca, nos dois sentidos (spec/50 + spec/46 §4).
	# Toda a raca que um bioma aloja existe em races.json E declara esse bioma;
	# todo o bioma que uma raca habita existe em biomes.json E lista essa raca.
	# E a regra anti-mistura em codigo: um boneco sem casa nao arranca o jogo.
	const RACE_FIELDS: Array[String] = ["nome", "tipo", "papel", "origem", "quer",
		"biomas", "relacoes", "mortos", "veste", "segredo", "descricao_visual", "fatia_1"]
	const VALID_ROLES: Array[String] = ["rapido", "pesado", "distancia", "grupo", "armadilha"]
	var true_races := 0
	for race_id in race_ids():
		var r := race(race_id)
		for field in RACE_FIELDS:
			if not r.has(field):
				_fail("[SPEC] raca '%s' sem o campo '%s' (spec/50)" % [race_id, field])
		if String(r.get("tipo", "")) == "raca":
			true_races += 1
		if String(r.get("papel", "")) not in VALID_ROLES:
			_fail("[SPEC] raca '%s' com papel '%s' fora do spec/38 §6" % [race_id, r.get("papel", "")])
		var homes: Dictionary = r.get("biomas", {}) as Dictionary
		if homes.is_empty():
			_fail("[SPEC] raca '%s' sem bioma nenhum (spec/46 §5)" % race_id)
		for home: String in homes.keys():
			if biome(home).is_empty():
				_fail("[SPEC] raca '%s' habita bioma inexistente '%s'" % [race_id, home])
			else:
				var housed: Dictionary = biome(home).get("racas", {}) as Dictionary
				var listed: Array = [String(housed.get("dominante", ""))]
				listed.append_array(housed.get("secundarias", []) as Array)
				if race_id not in listed:
					_fail("[SPEC] raca '%s' diz viver em '%s', mas o bioma nao a lista" % [race_id, home])
	if true_races != 12:
		_fail("[SPEC] %d racas verdadeiras (a spec/50 diz 12; pragas nao contam)" % true_races)
	for biome_id in biome_ids():
		var housed_b: Dictionary = biome(biome_id).get("racas", {}) as Dictionary
		var all_listed: Array = [String(housed_b.get("dominante", ""))]
		all_listed.append_array(housed_b.get("secundarias", []) as Array)
		for listed_race: Variant in all_listed:
			var rr := race(String(listed_race))
			if rr.is_empty():
				_fail("[SPEC] bioma '%s' aloja raca inexistente '%s'" % [biome_id, listed_race])
			elif not (rr.get("biomas", {}) as Dictionary).has(biome_id):
				_fail("[SPEC] bioma '%s' lista '%s', mas a raca nao declara esse bioma" % [biome_id, listed_race])
	checks += 1

	# 8. WP5 camada 1 (spec/51-familias.md): familias, kits e armadura.
	# A regra do 41 §2: uma familia sem a frase "onde e ma" esta listada, nao
	# desenhada — e aqui isso e um erro, nao uma opiniao.
	var fams: Dictionary = weapons.get("familias", {}) as Dictionary
	var fam_ids: Array[String] = []
	for f: String in fams.keys():
		if not f.begins_with("_"):
			fam_ids.append(f)
	if fam_ids.size() != 8:
		_fail("[SPEC] %d familias de arma (a spec/51 §2 diz 8)" % fam_ids.size())
	for fam_id in fam_ids:
		var fam: Dictionary = fams[fam_id]
		for field: String in ["nome", "onde_boa", "onde_ma", "interrupcao", "fatia_1"]:
			if not fam.has(field):
				_fail("[SPEC] familia '%s' sem '%s' (spec/51 §2)" % [fam_id, field])
		if String(fam.get("onde_ma", "")) == "":
			_fail("[SPEC] familia '%s' sem a frase 'onde e ma' — esta listada, nao desenhada" % fam_id)

	# Toda a arma da fatia declara a familia a que pertence, e ela existe.
	for w_id: String in weapons.keys():
		if w_id.begins_with("_") or w_id in ["familias", "familias_escudo", "loadouts",
				"test_loadouts", "golpes_universais"]:
			continue
		var w: Dictionary = weapons[w_id]
		if w.has("familia"):
			if not fams.has(String(w.get("familia"))):
				_fail("[SPEC] arma '%s' aponta a familia inexistente '%s'" % [w_id, w.get("familia")])
		elif not w.has("familia_escudo"):
			_fail("[SPEC] arma '%s' sem familia (spec/51 §2)" % w_id)

	# Escudos: o tecto de estabilidade e rigido — sem ele bloquear e gratis.
	var shields: Dictionary = weapons.get("familias_escudo", {}) as Dictionary
	var stab_max: float = shields.get("estabilidade_maxima", 85.0)
	for s_id: String in shields.keys():
		if s_id.begins_with("_") or typeof(shields[s_id]) != TYPE_DICTIONARY:
			continue
		if float((shields[s_id] as Dictionary).get("estabilidade", 0.0)) > stab_max:
			_fail("[SPEC] escudo '%s' passa o tecto de estabilidade %.0f (spec/51 §3)" % [s_id, stab_max])

	# Kits: nenhuma referencia fantasma, e a carga e uma das tres.
	var pieces: Dictionary = armor.get("pieces", {}) as Dictionary
	var loads: Dictionary = weapons.get("loadouts", {}) as Dictionary
	for class_id: String in loads.keys():
		if class_id.begins_with("_"):
			continue
		var kit: Dictionary = loads[class_id]
		for slot_key: String in ["main", "offhand"]:
			var wid: Variant = kit.get(slot_key, null)
			if wid != null and String(wid) != "" and not weapons.has(String(wid)):
				_fail("[SPEC] kit '%s': arma '%s' nao existe" % [class_id, wid])
		for piece: Variant in kit.get("pecas", []):
			if not pieces.has(String(piece)):
				_fail("[SPEC] kit '%s': peca '%s' nao existe em armor.json" % [class_id, piece])
		if String(kit.get("carga", "")) not in ["leve", "medio", "pesado"]:
			_fail("[SPEC] kit '%s' com carga '%s' fora das tres classes" % [class_id, kit.get("carga", "")])
		if not kit.has("pecas") or (kit.get("pecas", []) as Array).is_empty():
			_fail("[SPEC] kit '%s' sem pecas (instrucao do Rico, spec/51 §5)" % class_id)

	# Os i-frames NUNCA mudam com o peso (Lei 1, spec/51 §4).
	var carga: Dictionary = armor.get("carga", {}) as Dictionary
	for load_name: String in ["leve", "medio", "pesado"]:
		var c: Dictionary = carga.get(load_name, {}) as Dictionary
		if c.is_empty():
			_fail("[SPEC] classe de carga '%s' em falta (spec/51 §4)" % load_name)
		elif c.has("iframe_start_frame") or c.has("iframe_end_frame"):
			_fail("[SPEC] carga '%s' mexe nos i-frames — a Lei 1 nao deixa (spec/51 §4)" % load_name)
	checks += 1

	# 9. WP4 completo (spec/66): quatro escolas, 12 formas usadas, ficha de
	# honestidade e seis niveis. Isto corre no arranque normal, nao so no teste.
	var spell_ids: Array = spells.get("order", []) as Array
	var spell_schools: Dictionary = spells.get("_schools", {}) as Dictionary
	var delivery_forms: Array = spells.get("_delivery_forms", []) as Array
	var escape_vectors: Array = spells.get("_escape_vectors", []) as Array
	if spell_ids.size() != 53:
		_fail("[SPEC] %d feiticos (spec/66 diz 53)" % spell_ids.size())
	if spell_schools.size() != 4:
		_fail("[SPEC] %d escolas de magia (spec/66 diz 4)" % spell_schools.size())
	if delivery_forms.size() != 12:
		_fail("[SPEC] %d formas de entrega (spec/55 diz 12)" % delivery_forms.size())
	if escape_vectors.size() != 9:
		_fail("[SPEC] %d vectores de fuga (spec/38 diz 9)" % escape_vectors.size())
	var used_forms := {}
	var first_slice_spells: Array[String] = []
	const SPELL_FIELDS: Array[String] = ["display_name", "school", "question", "formula",
		"mana_cost", "cast_time", "delivery_form", "invalid_where", "escape_vector",
		"escape_method", "contact_type", "descricao_visual", "sound_cue", "visual_cue", "fatia_1"]
	for raw_spell_id: Variant in spell_ids:
		var spell_id := String(raw_spell_id)
		var s: Dictionary = spell(spell_id)
		for field: String in SPELL_FIELDS:
			if not s.has(field) or str(s.get(field, "")) == "":
				_fail("[SPEC] feitico '%s' sem '%s' (spec/66)" % [spell_id, field])
		if String(s.get("school", "")) not in spell_schools.keys():
			_fail("[SPEC] feitico '%s' aponta a escola inexistente '%s'" % [spell_id, s.get("school", "")])
		var form := String(s.get("delivery_form", ""))
		if form not in delivery_forms:
			_fail("[SPEC] feitico '%s' usa forma inexistente '%s'" % [spell_id, form])
		used_forms[form] = true
		var contact := String(s.get("contact_type", ""))
		if contact not in ["instantaneo", "volume_movel", "volume_persistente", "nenhum"]:
			_fail("[SPEC] feitico '%s' tem contacto invalido '%s'" % [spell_id, contact])
		elif contact != "nenhum" and String(s.get("escape_vector", "")) not in escape_vectors:
			_fail("[SPEC] feitico '%s' foge fora dos 9 vectores do spec/38" % spell_id)
		var upgrades: Array = s.get("upgrades", []) as Array
		if upgrades.size() != 6:
			_fail("[SPEC] feitico '%s' tem %d niveis de melhoria (spec/66 diz 6)" % [spell_id, upgrades.size()])
		else:
			for level: int in range(6):
				if int((upgrades[level] as Dictionary).get("level", -1)) != level:
					_fail("[SPEC] feitico '%s' tem tabela 0..5 fora de ordem" % spell_id)
			for level: int in [1, 3, 5]:
				if String((upgrades[level] as Dictionary).get("axis", "")) not in ["area", "lancamentos"]:
					_fail("[SPEC] feitico '%s' nivel %d nao abre area/lancamentos" % [spell_id, level])
		if bool(s.get("fatia_1", false)):
			first_slice_spells.append(spell_id)
	for form: Variant in delivery_forms:
		if not used_forms.has(String(form)):
			_fail("[SPEC] forma de entrega '%s' sem feitico (spec/66)" % form)
	if first_slice_spells != ["dardo", "ruina", "egide"]:
		_fail("[SPEC] Fatia 1 de magia tem %s; devia ter Dardo/Ruina/Egide" % first_slice_spells)
	var spell_rules: Dictionary = spells.get("_rules", {}) as Dictionary
	var favorites: Array = spell_rules.get("default_favorites", []) as Array
	if favorites.size() > int(spell_rules.get("favorite_limit", 0)):
		_fail("[SPEC] favoritos de fabrica excedem o limite de 8")
	for favorite: Variant in favorites:
		if not spell_ids.has(String(favorite)):
			_fail("[SPEC] favorito '%s' nao existe no catalogo" % favorite)
	checks += 1

	# 10. WP6 completo (spec/67): a ficha expandida é a fronteira de runtime.
	const CONTACT_TYPES: Array[String] = ["instantaneo", "volume_movel", "volume_persistente"]
	const ATTACK_VECTORS: Array[String] = ["sair_da_linha", "rolar_para_dentro",
		"rolar_para_fora", "afastar_se", "aproximar_se", "quebrar_a_visao",
		"sair_da_area", "aparar", "bloquear_e_aguentar"]
	var common_enemy_count := 0
	for bestiary_id: String in enemies.keys():
		if bestiary_id.begins_with("_"):
			continue
		var bestiary_enemy := enemy(bestiary_id)
		if bool(bestiary_enemy.get("is_boss", false)):
			continue
		common_enemy_count += 1
		if (bestiary_enemy.get("loot_deck", {}) as Dictionary).get("cards", []).size() != 10:
			_fail("[SPEC] '%s' sem baralho de 10 (spec/43 + spec/67)" % bestiary_id)
		if float(bestiary_enemy.get("mass_kg", 0.0)) <= 0.0 or int(bestiary_enemy.get("souls", 0)) <= 0:
			_fail("[SPEC] '%s' sem massa/almas positivas (spec/36 + spec/40)" % bestiary_id)
		var catalogue_attacks: Array = bestiary_enemy.get("attacks", []) as Array
		if catalogue_attacks.size() < 3 or catalogue_attacks.size() > 5:
			_fail("[SPEC] '%s' tem %d ataques; comum exige 3-5" % [bestiary_id, catalogue_attacks.size()])
		for catalogue_attack_value: Variant in catalogue_attacks:
			var catalogue_attack := catalogue_attack_value as Dictionary
			var label := "%s/%s" % [bestiary_id, catalogue_attack.get("id", "?")]
			if String(catalogue_attack.get("tipo_contacto", "")) not in CONTACT_TYPES:
				_fail("[SPEC] %s sem tipo de contacto valido" % label)
			var attack_vectors: Array = catalogue_attack.get("vectores_fuga", []) as Array
			if attack_vectors.is_empty() or attack_vectors.size() > 2:
				_fail("[SPEC] %s precisa de 1-2 vectores de fuga" % label)
			for vector: Variant in attack_vectors:
				if String(vector) not in ATTACK_VECTORS:
					_fail("[SPEC] %s usa vector inexistente '%s'" % [label, vector])
			var cue: Dictionary = catalogue_attack.get("sinal_visual_equivalente", {}) as Dictionary
			for cue_field: String in ["ancora", "forma", "inicio", "compromisso", "fim", "fora_ecra"]:
				if String(cue.get(cue_field, "")) == "":
					_fail("[SPEC] %s: equivalente visual sem '%s'" % [label, cue_field])
	if common_enemy_count != 33:
		_fail("[SPEC] bestiario tem %d tipos comuns; spec/67 fecha 33" % common_enemy_count)
	if (enemies.get("_zone_budgets", {}) as Dictionary).size() != 12:
		_fail("[SPEC] bestiario sem orcamento de almas para as 12 zonas")
	checks += 1

	# 11. WP5 completo (spec/68): catálogo fechado e todas as promessas do
	# bestiário resolvem. A validação duplica de propósito a fronteira do teste:
	# uma build normal também se recusa a arrancar com espólio fantasma.
	var catalogue_weapons: Dictionary = equipment.get("weapons", {}) as Dictionary
	var catalogue_armor: Dictionary = equipment.get("armor", {}) as Dictionary
	var catalogue_rings: Dictionary = equipment.get("rings", {}) as Dictionary
	if catalogue_weapons.size() != 120:
		_fail("[SPEC] catálogo WP5 tem %d armas; spec/68 diz 120" % catalogue_weapons.size())
	if catalogue_armor.size() != 68:
		_fail("[SPEC] catálogo WP5 tem %d armaduras; spec/68 diz 68" % catalogue_armor.size())
	if catalogue_rings.size() != 70:
		_fail("[SPEC] catálogo WP5 tem %d anéis; spec/68 diz 70" % catalogue_rings.size())
	for catalogue: Dictionary in [catalogue_weapons, catalogue_armor, catalogue_rings]:
		for item_id: String in catalogue.keys():
			var item := catalogue[item_id] as Dictionary
			if String(item.get("descricao_visual", "")).length() < 40:
				_fail("[SPEC] item '%s' sem descrição visual gerável" % item_id)
			if typeof(item.get("fatia_1")) != TYPE_BOOL:
				_fail("[SPEC] item '%s' sem Fatia 1? booleana" % item_id)

	var family_movesets: Dictionary = equipment.get("family_movesets", {}) as Dictionary
	const REQUIRED_STRIKES: Array[String] = ["leve", "pesado", "cadeia", "leve_para_pesado",
		"em_corrida", "a_rolar", "a_saltar", "de_cima", "empurrao", "arte_1mao", "arte_2maos"]
	if family_movesets.size() != 8:
		_fail("[SPEC] catálogo WP5 sem os oito movesets")
	for family_id: String in family_movesets.keys():
		var moveset := family_movesets[family_id] as Dictionary
		for strike: String in REQUIRED_STRIKES:
			if not moveset.has(strike) or (moveset[strike] as Dictionary).is_empty():
				_fail("[SPEC] família '%s' sem golpe '%s'" % [family_id, strike])

	var improvement_levels: Array = (equipment.get("weapon_improvement", {}) as Dictionary).get("levels", []) as Array
	if improvement_levels.size() != 7:
		_fail("[SPEC] melhoria de arma não declara base + seis níveis")
	for level: int in range(improvement_levels.size()):
		var improvement := improvement_levels[level] as Dictionary
		if int(improvement.get("level", -1)) != level or bool(improvement.get("increases_base_damage", true)):
			_fail("[SPEC] melhoria %d fora de ordem ou compra força" % level)

	var status_effects: Dictionary = equipment.get("status_effects", {}) as Dictionary
	for status_id: String in ["veneno", "sangramento", "queimadura"]:
		var status := status_effects.get(status_id, {}) as Dictionary
		if String(status.get("applies_to", "")) != "jogador_e_inimigo":
			_fail("[SPEC] estado '%s' não é simétrico" % status_id)
		for status_field: String in ["meter_max", "decay", "trigger", "effect", "escape", "visual_cue"]:
			if str(status.get(status_field, "")) == "":
				_fail("[SPEC] estado '%s' sem '%s'" % [status_id, status_field])

	var ring_axes: Dictionary = {}
	var ring_effects: Dictionary = {}
	for ring_id: String in catalogue_rings.keys():
		var catalogue_ring := catalogue_rings[ring_id] as Dictionary
		ring_axes[String(catalogue_ring.get("eixo", ""))] = true
		var ring_effect := String(catalogue_ring.get("efeito", ""))
		if ring_effects.has(ring_effect):
			_fail("[SPEC] anel '%s' repete um efeito" % ring_id)
		ring_effects[ring_effect] = true
		if catalogue_ring.has("input_action"):
			_fail("[SPEC] anel '%s' consome tecla" % ring_id)
		if float((catalogue_ring.get("numeros", {}) as Dictionary).get("max_percent", 0.0)) > 10.0:
			_fail("[SPEC] anel '%s' passa o tecto de 10%%" % ring_id)
	if ring_axes.size() != 8:
		_fail("[SPEC] os anéis só cobrem %d/8 eixos" % ring_axes.size())

	for loot_enemy_id: String in enemies.keys():
		if loot_enemy_id.begins_with("_") or bool(enemy(loot_enemy_id).get("is_boss", false)):
			continue
		for loot_card_value: Variant in enemy(loot_enemy_id).get("loot_cards", []):
			var split: PackedStringArray = String(loot_card_value).split(":", false, 1)
			if split.size() != 2:
				continue
			if split[0] == "arma" and not catalogue_weapons.has(split[1]):
				_fail("[SPEC] espólio arma '%s' não resolve" % split[1])
			elif split[0] == "armadura" and not catalogue_armor.has(split[1]):
				_fail("[SPEC] espólio armadura '%s' não resolve" % split[1])
			elif split[0] == "anel" and not catalogue_rings.has(split[1]):
				_fail("[SPEC] espólio anel '%s' não resolve" % split[1])
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


func race(id: String) -> Dictionary:
	return races.get(id, {}) as Dictionary


## Ids reais das racas (ignora as chaves "_meta" do JSON).
func race_ids() -> Array[String]:
	var out: Array[String] = []
	for k: String in races.keys():
		if not k.begins_with("_"):
			out.append(k)
	return out


# --- Estado persistente (spec/59-saves.md) -----------------------------------

func replace_save_state(state: Dictionary) -> void:
	save_state = state.duplicate(true)


func save_state_snapshot() -> Dictionary:
	return save_state.duplicate(true)
