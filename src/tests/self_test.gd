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
	_report()


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
	_check(GameData.max_health_for(int(warrior.get("vida"))) == 420.0, "Guerreiro nivel 1: 420 PV")
	_check(GameData.max_stamina_for(int(warrior.get("stamina"))) == 100.0, "Guerreiro nivel 1: 100 STA")
	_check(GameData.defense_for(int(warrior.get("constituicao"))) == 20.0, "Guerreiro nivel 1: DEF 20")

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

	# E ao contrario: quantos golpes aguenta o jogador nivel 1.
	var hp := GameData.max_health_for(int(warrior.get("vida")))
	var def := GameData.defense_for(int(warrior.get("constituicao")))
	var brute_hit := GameData.apply_defense(130.0, def)
	_check(int(ceil(hp / brute_hit)) == 4, "brutamontes mata o nivel 1 em 4 golpes")
	var spear_hit := GameData.apply_defense(55.0, def)
	_check(int(ceil(hp / spear_hit)) == 12, "lanceiro mata o nivel 1 em 12 golpes")


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
