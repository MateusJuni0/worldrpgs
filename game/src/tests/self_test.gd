extends Node
## Auto-teste: verifica que o COMPORTAMENTO bate certo com a spec, nao so os dados.
##
## O GameData ja valida os dados no arranque. Isto e outra coisa: pega na maquina
## de estados e conta os frames um a um, para provar que a janela de i-frames abre
## mesmo no frame 5 e fecha mesmo no 23 — e nao "por volta de".
##
## Correr:  godot --path . --headless res://scenes/selftest.tscn
## Sai com codigo 1 se alguma verificacao falhar.

var _passed := 0
var _failed := 0


func _ready() -> void:
	print("\n=== AUTO-TESTE CONTRA A SPEC ===\n")
	_test_dodge_iframes()
	_test_parry_window()
	_test_weapon_frames()
	_test_stamina()
	_test_damage_worked_example()
	_test_time_to_kill()
	_test_enemy_contract()
	_test_movement_speeds()
	_test_spell_catalogue()
	_test_feel()
	_test_biomes()
	_test_races()
	_report()


# --- spec/50-racas.md (volta 2) · as 12 fichas de raca ------------------------

func _test_races() -> void:
	var ids := GameData.race_ids()

	# 12 racas verdadeiras + o mimico como praga (spec/50 §0).
	var true_races: Array[String] = []
	for id in ids:
		if String(GameData.race(id).get("tipo", "")) == "raca":
			true_races.append(id)
	_check(true_races.size() == 12, "12 racas verdadeiras (10-15 [DECIDIDO])")
	_check(String(GameData.race("mimicos").get("tipo", "")) == "praga",
		"o mimico e praga, nao raca")

	# So os orcs estao na fatia 1 (spec/10: lanceiro, brutamontes, Vorgar).
	var slice: Array[String] = []
	for id in ids:
		if bool(GameData.race(id).get("fatia_1", false)):
			slice.append(id)
	_check(slice.size() == 1 and slice[0] == "orcs", "fatia 1 = so orcs")

	# Cada bioma tem >= 3 papeis de combate diferentes entre as racas que aloja
	# + o mimico/chefe — aqui exigimos >= 2 so das racas residentes (o 3.o vem
	# do chefe ancora, WP7). Spec/38 §6 via spec/50 §13.
	for biome_id in GameData.biome_ids():
		var housed: Dictionary = GameData.biome(biome_id).get("racas", {}) as Dictionary
		var listed: Array = [String(housed.get("dominante", ""))]
		listed.append_array(housed.get("secundarias", []) as Array)
		var roles := {}
		for race_id: Variant in listed:
			var r := GameData.race(String(race_id))
			roles[String(r.get("papel", ""))] = true
			if r.has("papel_secundario"):
				roles[String(r.get("papel_secundario", ""))] = true
		_check(roles.size() >= 2, "%s: >= 2 papeis entre residentes (tem %d)" % [biome_id, roles.size()])

	# As 6 novas sao exactamente as semeadas na volta 1 (spec/49 §4).
	for new_race: String in ["teceloes", "ventaneiras", "borralheiros",
			"submersos", "penitentes", "sem_rosto"]:
		_check(not GameData.race(new_race).is_empty(), "raca nova '%s' existe" % new_race)

	# Nenhuma raca sem segredo — a linha 8 e a que faz reler (spec/46 §5).
	for id in ids:
		_check(String(GameData.race(id).get("segredo", "")) != "",
			"'%s' tem a linha 'ninguem sabe'" % id)


# --- spec/49-biomas.md (volta 1) · as 12 fichas de bioma ----------------------

func _test_biomes() -> void:
	var ids := GameData.biome_ids()
	_check(ids.size() == 12, "12 biomas em biomes.json (spec/49 §1)")

	# Exactamente UM bioma na fatia 1, e e Brumal.
	var slice: Array[String] = []
	for id in ids:
		if bool(GameData.biome(id).get("fatia_1", false)):
			slice.append(id)
	_check(slice.size() == 1 and slice[0] == "brumal", "fatia 1 = so Brumal")

	# As ordens sao 1..12, sem repeticao — a fila de construcao e inequivoca.
	var orders: Array[int] = []
	for id in ids:
		orders.append(int(GameData.biome(id).get("ordem", 0)))
	orders.sort()
	var orders_ok := orders.size() == 12
	for i in range(orders.size()):
		if orders[i] != i + 1:
			orders_ok = false
	_check(orders_ok, "ordens 1..12 unicas")

	# Nenhum elemento eficaz e orfao: existe como elemento de outro bioma
	# ou como escola de magia (luz/sombra) — spec/49 §4.
	var elements: Array[String] = []
	for id in ids:
		elements.append(String(GameData.biome(id).get("elemento", "")))
	for id in ids:
		var eff := String(GameData.biome(id).get("eficaz_contra_nativos", ""))
		_check(eff in elements or eff in ["luz", "sombra"],
			"'%s' (eficaz em %s) existe no mapa ou e escola" % [eff, id])

	# 12 colheitas distintas — cada bioma da um material proprio (spec/46 §2).
	var crops := {}
	for id in ids:
		crops[String(GameData.biome(id).get("colheita", ""))] = true
	_check(crops.size() == 12, "12 colheitas distintas")

	# A alavanca do 46 §7 com o travao proposto: nenhuma raca dominante ou
	# secundaria aparece em mais de 3 biomas.
	var race_count := {}
	for id in ids:
		var r: Dictionary = GameData.biome(id).get("racas", {}) as Dictionary
		var all_races: Array = [String(r.get("dominante", ""))]
		all_races.append_array(r.get("secundarias", []) as Array)
		for race: Variant in all_races:
			race_count[race] = int(race_count.get(race, 0)) + 1
	for race: Variant in race_count.keys():
		_check(int(race_count[race]) <= 3, "raca '%s' em <= 3 biomas" % race)

	# A ficha de Brumal FORMALIZA o que o prototipo ja mostra: a nevoa da ficha
	# e a mesma do palette de estados que as medicoes de PERF.md viram no ecra.
	var brumal_fog := String((GameData.biome("brumal").get("paleta", {}) as Dictionary).get("nevoa", ""))
	var state_fog := _graphics_fog()
	_check(brumal_fog == state_fog, "nevoa de Brumal = a do prototipo medido (%s)" % state_fog)


func _graphics_fog() -> String:
	var graphics: Variant = JSON.parse_string(
		FileAccess.get_file_as_string("res://data/graphics.json"))
	return String(((graphics as Dictionary).get("palette", {}) as Dictionary).get("fog", ""))


# --- spec/13-magia.md (WP4) · o catalogo --------------------------------------

func _test_spell_catalogue() -> void:
	# magia, cargas, tempo, dano base, alcance
	var table := [
		["dardo", 1, 0.8, 45, 18.0],
		["ruina", 3, 1.6, 70, 12.0],
		["egide", 2, 0.5, 0,  0.0],
	]
	for row: Array in table:
		var s := GameData.spell(String(row[0]))
		_check(int(s.get("charge_cost")) == int(row[1]), "%s custa %d cargas" % [row[0], row[1]])
		_check(absf(float(s.get("cast_time")) - float(row[2])) < 0.001,
			"%s conjura em %.1f s" % [row[0], row[2]])
		if int(row[3]) > 0:
			_check(int(s.get("base_damage")) == int(row[3]), "%s: dano base %d" % [row[0], row[3]])
		if float(row[4]) > 0.0:
			_check(absf(float(s.get("max_range")) - float(row[4])) < 0.001,
				"%s: alcance %.0f m" % [row[0], row[4]])

	var egide := GameData.spell("egide")
	_check(int(egide.get("absorb")) == 120, "Egide absorve 120")
	_check(absf(float(egide.get("duration")) - 2.5) < 0.001, "Egide dura 2,5 s")
	_check(bool(egide.get("hyper_armor_while_active")), "Egide da hiper-armadura enquanto dura")
	_check(bool(GameData.spell("ruina").get("movement_locked")), "Ruina conjura-se parado")
	_check(absf(float(GameData.spell("ruina").get("telegraph_seconds")) - 0.5) < 0.001,
		"Ruina marca o chao 0,5 s antes")
	_check(bool(GameData.spells.get("_rules", {}).get("requires_staff")),
		"conjurar exige cajado equipado")

	# O bolso unico e o puzzle: Sab 14 = 7 cargas = 7 Dardos ou 2 Ruinas + 1 Dardo.
	var pool := GameData.max_charges_for(14)
	_check(pool == 7, "bolso do Feiticeiro: 7 cargas")
	_check(2 * int(GameData.spell("ruina").get("charge_cost")) + 1 <= pool,
		"2 Ruinas + 1 Dardo cabem no bolso")


# --- spec/25-controlo.md (WP1B) · buffer e impacto ----------------------------

func _test_feel() -> void:
	var b := GameData.section("input_buffer")
	_check(int(b.get("life_ms")) == 400, "buffer: entrada morre aos 400 ms")
	_check(int(b.get("parry_life_ms")) == 80, "buffer: parry guarda-se so 80 ms")
	_check(int(b.get("capacity")) == 1, "buffer: capacidade 1")
	_check(bool(b.get("dodge_has_priority")), "buffer: esquiva tem prioridade sobre ataque")

	var hs := GameData.section("hit_stop")
	_check(int(hs.get("light_hit")) == 3, "hit-stop: golpe leve 3 f")
	_check(int(hs.get("heavy_hit")) == 6, "hit-stop: golpe pesado 6 f")
	_check(int(hs.get("parry_success")) == 10, "hit-stop: parry 10 f (o momento-assinatura)")
	_check(int(hs.get("blocked")) == 4, "hit-stop: bloqueado 4 f")
	_check(int(hs.get("killing_blow")) == 8, "hit-stop: golpe final 8 f")

	var c := GameData.section("camera")
	_check(absf(float(c.get("fov")) - 55.0) < 0.001, "camara: FOV 55 graus")
	_check(absf(float(c.get("distance")) - 4.0) < 0.001, "camara: 4,0 m")
	_check(absf(float(c.get("distance_locked_on")) - 4.8) < 0.001, "camara: 4,8 m com lock-on")
	_check(absf(float(c.get("pivot_height")) - 1.6) < 0.001, "camara: pivo aos ombros (1,6 m)")
	_check(not bool(c.get("mouse_acceleration")), "camara: SEM aceleracao de rato")

	# A esquiva no buffer nunca e substituida por um ataque.
	var p := _make_player()
	p._buffer("dodge")
	p._buffer("light")
	_check(p._peek_buffer() == "dodge", "esquiva no buffer nao e substituida por ataque")
	p._buffer("dodge")
	_check(p._peek_buffer() == "dodge", "esquiva substitui esquiva")
	p.free()


# --- spec/01-combate.md · Esquiva ---------------------------------------------

func _test_dodge_iframes() -> void:
	var p := _make_player()
	var cfg := GameData.section("dodge")
	var total := int(cfg.get("duration_frames", 36))
	var want_start := int(cfg.get("iframe_start_frame", 5))
	var want_end := int(cfg.get("iframe_end_frame", 23))

	p.state = Player.State.DODGE
	var first := -1
	var last := -1
	for f in range(0, total + 1):
		p.state_frame = f
		if p.has_iframes():
			if first < 0:
				first = f
			last = f

	_check(first == want_start, "esquiva: i-frames comecam no frame %d (spec: %d)" % [first, want_start])
	_check(last == want_end, "esquiva: i-frames acabam no frame %d (spec: %d)" % [last, want_end])
	_check(absf(GameData.frames_to_seconds(float(last - first + 1)) - 0.3167) < 0.02,
		"esquiva: %.0f ms de invencibilidade (spec: ~300 ms)"
		% (GameData.frames_to_seconds(float(last - first + 1)) * 1000.0))

	# A recuperacao dos 0,38 aos 0,60 s tem de ser vulneravel.
	p.state_frame = 30
	_check(not p.has_iframes(), "esquiva: frame 30 (0,50 s) ja e vulneravel")
	p.free()


# --- spec/01-combate.md · Parry -----------------------------------------------

func _test_parry_window() -> void:
	var p := _make_player()
	var cfg := GameData.section("parry")
	var startup := int(cfg.get("startup_frames", 4))
	var active := int(cfg.get("active_frames", 8))

	p.state = Player.State.PARRY
	var first := -1
	var last := -1
	for f in range(0, 60):
		p.state_frame = f
		if p.parry_window_open():
			if first < 0:
				first = f
			last = f

	_check(first == startup, "parry: janela abre no frame %d (spec: %d)" % [first, startup])
	_check(last - first + 1 == active, "parry: janela dura %d frames (spec: %d)" % [last - first + 1, active])
	_check(absf(GameData.frames_to_seconds(float(active)) - 0.1333) < 0.005,
		"parry: janela de %.0f ms (spec: 133 ms)" % (GameData.frames_to_seconds(float(active)) * 1000.0))

	var total := startup + active + int(cfg.get("whiff_recovery_frames", 40))
	_check(total == 52, "parry falhado: %d frames no total (4+8+40)" % total)
	_check(absf(GameData.frames_to_seconds(40.0) - 0.667) < 0.005, "parry falhado: 0,667 s exposto")
	p.free()


# --- spec/01-combate.md · tabela das armas ------------------------------------

func _test_weapon_frames() -> void:
	# arma, leve(a/a/r), pesado(a/a/r), MV leve, MV pesado, custo leve, alcance
	var table := [
		["dagger",    [12, 4, 14], [20, 5, 20], 0.55, 0.85, 12, 1.4],
		["longsword", [16, 6, 18], [28, 8, 26], 1.0,  1.6,  18, 2.0],
		["greataxe",  [24, 8, 26], [38, 10, 34], 1.5, 2.4,  28, 2.3],
		["staff",     [18, 5, 20], [30, 7, 28], 0.7,  1.1,  15, 1.8],
	]
	for row: Array in table:
		var id: String = row[0]
		var w := GameData.weapon(id)
		var light: Dictionary = w.get("light", {})
		var heavy: Dictionary = w.get("heavy", {})
		var lf: Array = row[1]
		var hf: Array = row[2]
		_check(int(light.get("startup")) == lf[0] and int(light.get("active")) == lf[1]
			and int(light.get("recovery")) == lf[2], "%s leve: %d/%d/%d" % [id, lf[0], lf[1], lf[2]])
		_check(int(heavy.get("startup")) == hf[0] and int(heavy.get("active")) == hf[1]
			and int(heavy.get("recovery")) == hf[2], "%s pesado: %d/%d/%d" % [id, hf[0], hf[1], hf[2]])
		_check(absf(float(light.get("mv")) - float(row[3])) < 0.001, "%s MV leve %.2f" % [id, row[3]])
		_check(absf(float(heavy.get("mv")) - float(row[4])) < 0.001, "%s MV pesado %.2f" % [id, row[4]])
		_check(int(light.get("stamina")) == int(row[5]), "%s custo do leve %d" % [id, row[5]])
		_check(absf(float(w.get("range")) - float(row[6])) < 0.001, "%s alcance %.1f m" % [id, row[6]])

	var bash: Dictionary = GameData.weapon("shield").get("bash", {})
	_check(int(bash.get("startup")) == 14 and int(bash.get("active")) == 4
		and int(bash.get("recovery")) == 16, "escudo bash: 14/4/16")
	_check(absf(float(bash.get("mv")) - 0.4) < 0.001, "escudo bash MV 0,4")
	_check(absf(float(bash.get("posture_multiplier")) - 2.0) < 0.001, "escudo bash: postura x2")

	var ga_heavy: Dictionary = GameData.weapon("greataxe").get("heavy", {})
	_check(int(ga_heavy.get("charge_max_frames")) == 20, "machadao: carrega ate +20 f")
	_check(absf(float(ga_heavy.get("charge_max_mv")) - 3.0) < 0.001, "machadao carregado: MV 3,0")


# --- spec/01-combate.md · Stamina ---------------------------------------------

func _test_stamina() -> void:
	var s := Stamina.new()
	s.configure(GameData.section("stamina"), 100.0)

	_check(s.maximum == 100.0, "stamina base 100")
	s.spend(25.0)
	_check(absf(s.current - 75.0) < 0.001, "esquiva custa 25")

	# Nao regenera antes de 0,8 s.
	s.tick(0.5, false)
	_check(absf(s.current - 75.0) < 0.001, "sem regeneracao antes de 0,8 s")
	# Depois de 0,8 s, 40/s.
	s.tick(0.4, false)
	s.tick(0.1, false)
	_check(s.current > 75.0, "regenera depois de 0,8 s")

	# Histerese: a zero tranca ate recuperar 15.
	s.refill()
	s.spend(100.0)
	_check(s.locked_out and not s.can_act(), "a zero: tranca as accoes")
	s.tick(1.0, false)   # 0,8 s de espera + 0,2 s x 40/s = 8
	_check(s.locked_out, "ainda trancada com menos de 15")
	s.tick(0.2, false)
	_check(s.can_act(), "destranca ao chegar aos 15 (%.1f)" % s.current)

	# A bloquear regenera a 10/s, nao a 40/s.
	var b := Stamina.new()
	b.configure(GameData.section("stamina"), 100.0)
	b.spend(50.0)
	b.tick(1.0, true)
	_check(absf(b.current - 60.0) < 0.5, "a bloquear regenera 10/s (deu %.1f)" % b.current)


# --- spec/11-formulas.md · o exemplo resolvido --------------------------------

func _test_damage_worked_example() -> void:
	var warrior := GameData.class_attributes("warrior")
	# O exemplo resolvido do WP2 usa o atributo 10 como referencia.
	_check(GameData.max_health_for(10) == 420.0, "formula de PV: Vida 10 -> 420")
	_check(GameData.max_stamina_for(10) == 100.0, "formula de STA: Stamina 10 -> 100")
	_check(GameData.defense_for(10) == 20.0, "formula de DEF: Con 10 -> 20")

	# As fichas do WP3 (spec/12-classes.md), a letra.
	var sheets := {
		"warrior":   [11, 11, 10, 8,  12, 10],
		"sorcerer":  [10, 10, 9,  14, 9,  10],
		"tank":      [12, 10, 13, 8,  11, 8],
		"assassin":  [10, 12, 9,  8,  9,  14],
		"berserker": [11, 12, 9,  8,  14, 8],
		"paladin":   [11, 10, 10, 11, 11, 9],
	}
	var order := ["vida", "stamina", "constituicao", "sabedoria", "forca", "destreza"]
	for class_id: String in sheets.keys():
		var c := GameData.class_attributes(class_id)
		var want: Array = sheets[class_id]
		var ok := true
		for i in order.size():
			if int(c.get(order[i], -1)) != int(want[i]):
				ok = false
		_check(ok, "ficha do WP3: %s" % class_id)

	_check(GameData.max_charges_for(14) == 7, "Feiticeiro (Sab 14) arranca com 7 cargas")
	_check(GameData.meets_requirements("greataxe", GameData.class_attributes("berserker")),
		"Berserker cumpre o machadao (For 14)")
	_check(not GameData.meets_requirements("greataxe", warrior),
		"Guerreiro NAO cumpre o machadao (For 12) — pode pegar, paga x0,6")

	var scale := GameData.attribute_scale(12.0, "medio")
	_check(absf(scale - 1.036) < 0.001, "escala For 12 / peso medio = 1,036 (deu %.4f)" % scale)

	var dmg := GameData.compute_damage(1.0, "longsword", warrior, 4.0)
	_check(absf(dmg - 37.4) < 0.6, "leve de espada no lanceiro = ~37 (deu %.1f)" % dmg)

	# Lei 3: abaixo do requisito continua a funcionar, so custa em numeros.
	var weak := {"forca": 8, "destreza": 8, "sabedoria": 8, "vida": 8, "stamina": 8, "constituicao": 8}
	var weak_dmg := GameData.compute_damage(1.0, "greataxe", weak, 0.0)
	_check(weak_dmg > 0.0, "Lei 3: machadao abaixo do requisito ainda da dano (%.1f)" % weak_dmg)
	_check(absf(weak_dmg - 52.0 * 0.6) < 0.1, "abaixo do requisito: dano x0,6")

	# A DEF nunca corta mais de 40%.
	var capped := GameData.apply_defense(100.0, 90.0)
	_check(absf(capped - 60.0) < 0.001, "DEF corta no maximo 40%% (deu %.1f)" % capped)


# --- spec/01-combate.md · golpes para matar -----------------------------------

func _test_time_to_kill() -> void:
	var warrior := GameData.class_attributes("warrior")
	var cases := [["orc_spearman", 3, 5], ["orc_brute", 6, 9], ["vorgar", 45, 70]]
	for c: Array in cases:
		var e := GameData.enemy(c[0])
		var per := GameData.compute_damage(1.0, "longsword", warrior, float(e.get("defense", 0)))
		var hits := int(ceil(float(e.get("health")) / per))
		_check(hits >= int(c[1]) and hits <= int(c[2]),
			"%s morre em %d leves de espada (spec: %d-%d)" % [c[0], hits, c[1], c[2]])

	# E ao contrario: quantos golpes aguenta o jogador. O WP2 escreve estes numeros
	# sobre a ficha de REFERENCIA (Vida 10 -> 420 PV, Con 10 -> DEF 20), nao sobre
	# uma classe concreta — nenhuma das seis do WP3 tem exactamente esse par.
	var hp := GameData.max_health_for(10)
	var def := GameData.defense_for(10)
	_check(int(ceil(hp / GameData.apply_defense(130.0, def))) == 4,
		"brutamontes mata a ficha de referencia em 4 golpes")
	_check(int(ceil(hp / GameData.apply_defense(55.0, def))) == 12,
		"lanceiro mata a ficha de referencia em 12 golpes")

	# E o que isso da nas fichas reais do WP3, so para ficar registado.
	var w_hp := GameData.max_health_for(int(warrior.get("vida")))
	var w_def := GameData.defense_for(int(warrior.get("constituicao")))
	var w_brute := int(ceil(w_hp / GameData.apply_defense(130.0, w_def)))
	_check(w_brute >= 4 and w_brute <= 5,
		"Guerreiro do WP3 (%d PV) aguenta %d golpes do brutamontes" % [int(w_hp), w_brute])


# --- contrato que o WP1 impoe ao WP6 ------------------------------------------

func _test_enemy_contract() -> void:
	for id: String in ["orc_spearman", "orc_brute", "vorgar"]:
		var e := GameData.enemy(id)
		for a: Variant in e.get("attacks", []):
			var atk := a as Dictionary
			var startup := int(atk.get("startup", 0))
			_check(startup >= 30, "%s/%s telegrafa %d f = %.2f s (minimo 30 f)"
				% [id, atk.get("id"), startup, GameData.frames_to_seconds(float(startup))])
		_check(float(e.get("chase_speed", 99.0)) < 5.0,
			"%s persegue a %.1f m/s (< 5,0 do correr)" % [id, e.get("chase_speed")])

	var brute := GameData.enemy("orc_brute")
	var all_parryable := true
	for a: Variant in brute.get("attacks", []):
		if not bool((a as Dictionary).get("parryable", false)):
			all_parryable = false
	_check(all_parryable, "brutamontes: TODOS os golpes aparaveis (e o professor de parry)")

	# A fase 2 do Vorgar muda padroes, nao numeros.
	var v := GameData.enemy("vorgar")
	var phases: Dictionary = v.get("phases", {})
	var p1: Array = (phases.get("1", {}) as Dictionary).get("patterns", [])
	var p2: Array = (phases.get("2", {}) as Dictionary).get("patterns", [])
	_check(p1 != p2, "Vorgar: a fase 2 tem padroes diferentes")
	var longest_1 := 0
	var longest_2 := 0
	for pat: Variant in p1:
		longest_1 = maxi(longest_1, (pat as Array).size())
	for pat: Variant in p2:
		longest_2 = maxi(longest_2, (pat as Array).size())
	_check(longest_2 > longest_1, "Vorgar: cadeias mais longas na fase 2 (%d vs %d)" % [longest_2, longest_1])


# --- spec/01-combate.md · Movimento -------------------------------------------

func _test_movement_speeds() -> void:
	var m := GameData.section("movement")
	_check(float(m.get("walk_speed")) == 3.0, "andar 3,0 m/s")
	_check(float(m.get("run_speed")) == 5.0, "correr 5,0 m/s")
	_check(float(m.get("sprint_speed")) == 7.0, "sprint 7,0 m/s")
	_check(float(m.get("strafe_speed")) == 4.0, "strafe 4,0 m/s")
	_check(float(m.get("sprint_stamina_per_second")) == 8.0, "sprint custa 8 stamina/s")
	_check(absf(float(m.get("cast_move_multiplier")) - 0.40) < 0.001, "conjurar trava o movimento a 40%")

	var l := GameData.section("lock_on")
	_check(float(l.get("engage_range")) == 18.0, "lock-on engata a 18 m")
	_check(float(l.get("break_range")) == 25.0, "lock-on quebra a 25 m")
	_check(bool(l.get("auto_reacquire")) == false, "lock-on NAO re-engata sozinho")


# --- utilidades ---------------------------------------------------------------

func _make_player() -> Player:
	var p := Player.new()
	p.setup("warrior", {})
	return p


func _check(condition: bool, description: String) -> void:
	if condition:
		_passed += 1
		print("  ok    %s" % description)
	else:
		_failed += 1
		printerr("  FALHA %s" % description)


func _report() -> void:
	print("\n=== %d passaram, %d falharam ===\n" % [_passed, _failed])
	get_tree().quit(1 if _failed > 0 else 0)
