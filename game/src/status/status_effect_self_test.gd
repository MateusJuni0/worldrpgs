extends SceneTree
## Prova focal dos estados alterados.
## Correr com: godot --headless --audio-driver Dummy --path game \
##   --script res://src/status/status_effect_self_test.gd

const StatusEffectManager = preload("res://src/status/status_effect_manager.gd")
const StatusEffectPresenter = preload("res://src/status/status_effect_presenter.gd")

var _passed := 0
var _failed := 0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_test_selected_effects_belong_to_brumal()
	_test_partial_buildup_warns_without_triggering()
	_test_threshold_triggers_after_warning()
	_test_decay_starts_only_after_grace()
	_test_poison_ticks_for_declared_duration()
	_test_legible_immunity_rejects_buildup()
	_test_catalogue_consumable_cures_and_resists()
	_test_ring_cures_only_on_declared_surface()
	_test_presenter_makes_buildup_visible_and_audible()
	_test_burn_pulse_respects_coward_trait()
	_test_active_status_does_not_rebuild_hidden_meter()
	_test_catalogue_integrations_resolve()
	_test_player_and_enemy_share_rules()
	_test_expired_status_leaves_the_hud()
	_test_catalogue_rings_publish_their_actions()
	_test_rest_clears_every_status()
	print("[estados] %d passaram, %d falharam" % [_passed, _failed])
	quit(0 if _failed == 0 else 1)


func _test_selected_effects_belong_to_brumal() -> void:
	var manager := StatusEffectManager.new()
	_check(manager.configure(), "catálogo configura a seleção de estados")
	var expected: Array = manager.verification_case("selected_effects").get("expected_ids", []) as Array
	_check(manager.effect_ids() == expected,
		"Brumal usa apenas veneno, sangramento e queimadura")
	manager.free()


func _test_rest_clears_every_status() -> void:
	var manager := StatusEffectManager.new()
	_check(manager.configure(), "catálogo configura a saída por descanso")
	var probe := manager.verification_case("partial_buildup")
	for status_value: Variant in manager.effect_ids():
		manager.apply_buildup(String(status_value), float(probe.get("amount", 0.0)))

	var cleared := manager.clear_on_rest()

	_check(cleared == manager.effect_ids(),
		"descanso limpa os três estados pelo mesmo verbo")
	for status_value: Variant in manager.effect_ids():
		var status_id := String(status_value)
		_check(is_zero_approx(manager.meter_value(status_id)) and not manager.is_active(status_id),
			"descanso deixa %s sem barra nem efeito ativo" % status_id)
	manager.free()


func _test_catalogue_rings_publish_their_actions() -> void:
	var manager := StatusEffectManager.new()
	_check(manager.configure(), "catálogo configura ações dos anéis")
	manager.equip_rings(["seiva_inversa", "osso_sem_sangue", "fome_do_musgo"])
	var feedback_events: Array[Dictionary] = []
	var ring_actions: Array[Dictionary] = []
	manager.feedback_requested.connect(func(event: Dictionary) -> void:
		feedback_events.append(event)
	)
	manager.ring_effect_requested.connect(func(event: Dictionary) -> void:
		ring_actions.append(event)
	)
	var partial := manager.verification_case("partial_buildup")
	manager.apply_buildup("veneno", float(partial.get("amount", 0.0)), "arma_teste")
	manager.set_target_tags(["sem_sangue"])
	manager.apply_buildup("sangramento", float(partial.get("amount", 0.0)), "arma_teste")
	manager.use_consumable("antidoto_selva")

	_check((feedback_events[0].get("ring_presentations", []) as Array).has("mirror_to_source_weapon"),
		"Seiva Inversa pede o espelho na arma de origem")
	_check((feedback_events[1].get("ring_presentations", []) as Array).has("replace_meter_with_immunity_material"),
		"Osso sem Sangue pede o material de imunidade no medidor")
	_check(ring_actions.size() == 1
		and String(ring_actions[0].get("action", "")) == "reveal_matching_plants",
		"Fome do Musgo pede ao mundo para revelar plantas")
	manager.free()


func _test_expired_status_leaves_the_hud() -> void:
	var manager := StatusEffectManager.new()
	_check(manager.configure(), "catálogo configura a saída visual")
	var presenter := StatusEffectPresenter.new()
	root.add_child(presenter)
	var presentation := manager.presentation_config()
	presentation["playback_enabled"] = false
	presenter.configure(presentation)
	presenter.bind(manager)
	var probe := manager.verification_case("poison_duration")
	var status_id := String(probe.get("status_id", ""))
	manager.apply_buildup(status_id, float(probe.get("trigger_amount", 0.0)))
	_check(presenter.visible_status_ids().has(status_id),
		"estado disparado permanece visível durante a duração")

	manager.tick(float(probe.get("elapsed_s", 0.0)))

	_check(not presenter.visible_status_ids().has(status_id),
		"estado expirado sai do HUD")
	presenter.free()
	manager.free()


func _test_catalogue_integrations_resolve() -> void:
	var manager := StatusEffectManager.new()
	_check(manager.configure(), "catálogo configura as integrações")
	var expected_consumables := ["agua_lustral", "antidoto_selva", "musgo_seco", "sal_gelo"]
	var expected_rings := ["fome_do_musgo", "seiva_inversa", "osso_sem_sangue",
		"carvao_fendido", "sangue_em_dueto"]
	_check(manager.integration_ids("consumables") == expected_consumables,
		"os quatro consumíveis são os IDs existentes")
	for item_id: String in expected_consumables:
		_check(bool(manager.use_consumable(item_id).get("used", false)),
			"consumível %s resolve e é utilizável" % item_id)
	_check(manager.equip_rings(expected_rings) == expected_rings,
		"os cinco anéis de estado resolvem no catálogo")
	manager.free()


func _test_player_and_enemy_share_rules() -> void:
	var player_status := StatusEffectManager.new()
	var enemy_status := StatusEffectManager.new()
	_check(player_status.configure() and enemy_status.configure(),
		"dois lados configuram o mesmo catálogo")
	var probe := player_status.verification_case("partial_buildup")
	var player_result := player_status.apply_buildup(
		String(probe.get("status_id", "")), float(probe.get("amount", 0.0)))
	var enemy_result := enemy_status.apply_buildup(
		String(probe.get("status_id", "")), float(probe.get("amount", 0.0)))
	_check(player_result == enemy_result,
		"jogador e inimigo acumulam exatamente pelas mesmas regras")
	player_status.free()
	enemy_status.free()


func _test_active_status_does_not_rebuild_hidden_meter() -> void:
	var manager := StatusEffectManager.new()
	_check(manager.configure(), "catálogo configura a política de novo acúmulo")
	var probe := manager.verification_case("active_rebuild_blocked")
	var status_id := String(probe.get("status_id", ""))
	manager.apply_buildup(status_id, float(probe.get("trigger_amount", 0.0)))

	var result := manager.apply_buildup(status_id, float(probe.get("rebuild_amount", 0.0)))

	_check(not bool(result.get("accepted", true))
		and String(result.get("reason", "")) == String(probe.get("expected_reason", "")),
		"estado ativo rejeita um segundo acúmulo escondido")
	_check(is_equal_approx(manager.meter_value(status_id), float(probe.get("expected_meter", -1.0))),
		"barra fica vazia enquanto o estado ativo é legível")
	manager.free()


func _test_burn_pulse_respects_coward_trait() -> void:
	var manager := StatusEffectManager.new()
	_check(manager.configure(), "catálogo configura a reação de queimadura")
	var probe := manager.verification_case("burn_coward_pulse")
	manager.set_target_tags(probe.get("target_tags", []) as Array)
	manager.apply_buildup(
		String(probe.get("status_id", "")),
		float(probe.get("trigger_amount", 0.0))
	)

	var outcomes := manager.tick(float(probe.get("elapsed_s", 0.0)))
	_check(outcomes.size() == 1
		and (outcomes[0].get("consequences", {}) as Dictionary) ==
		(probe.get("expected_consequences", {}) as Dictionary),
		"pulso faz covarde recuar sem mudar o dano dos outros alvos")
	manager.free()


func _test_presenter_makes_buildup_visible_and_audible() -> void:
	var manager := StatusEffectManager.new()
	_check(manager.configure(), "catálogo configura a apresentação")
	var presenter := StatusEffectPresenter.new()
	root.add_child(presenter)
	var presentation := manager.presentation_config()
	presentation["playback_enabled"] = false
	presenter.configure(presentation)
	presenter.bind(manager)
	var probe := manager.verification_case("partial_buildup")
	var status_id := String(probe.get("status_id", ""))

	manager.apply_buildup(status_id, float(probe.get("amount", 0.0)))

	_check(presenter.visible_status_ids().has(status_id),
		"a acumulação aparece numa barra visível")
	_check(presenter.last_sound_stream() != null
		and presenter.last_sound_stream().data.size() > 0,
		"a acumulação sintetiza um aviso sonoro real")
	_check(presenter.visual_announcement_count == presenter.sound_announcement_count,
		"o mesmo evento chega aos dois canais")
	presenter.free()
	manager.free()


func _test_ring_cures_only_on_declared_surface() -> void:
	var manager := StatusEffectManager.new()
	_check(manager.configure(), "catálogo liga os anéis existentes")
	var probe := manager.verification_case("ring_surface_cure")
	var status_id := String(probe.get("status_id", ""))
	var equipped := manager.equip_rings([String(probe.get("ring_id", ""))])
	_check(equipped.size() == 1,
		"Carvão Fendido resolve pelo ID do catálogo")
	manager.apply_buildup(status_id, float(probe.get("trigger_amount", 0.0)))
	_check(manager.is_active(status_id),
		"queimadura está ativa antes da ação do anel")

	manager.finish_dodge(String(probe.get("wrong_surface", "")))
	_check(manager.is_active(status_id),
		"esquiva em superfície comum não cura")
	manager.finish_dodge(String(probe.get("valid_surface", "")))
	_check(not manager.is_active(status_id),
		"esquiva que termina em água apaga queimadura")
	manager.free()


func _test_catalogue_consumable_cures_and_resists() -> void:
	var manager := StatusEffectManager.new()
	_check(manager.configure(), "catálogo liga os consumíveis existentes")
	var probe := manager.verification_case("catalogue_cure_and_resistance")
	var status_id := String(probe.get("status_id", ""))
	var amount := float(probe.get("initial_amount", 0.0))
	manager.apply_buildup(status_id, amount)

	var use_result := manager.use_consumable(String(probe.get("consumable_id", "")))
	_check(bool(use_result.get("used", false)),
		"Antídoto da Selva resolve pelo ID do catálogo")
	_check(is_equal_approx(manager.meter_value(status_id), float(probe.get("expected_cleared_meter", -1.0))),
		"antídoto limpa a barra de veneno")
	_check(is_equal_approx(manager.resistance_multiplier(status_id), float(probe.get("expected_multiplier", -1.0))),
		"antídoto ativa a resistência catalogada")
	manager.apply_buildup(status_id, amount)
	_check(is_equal_approx(manager.meter_value(status_id), float(probe.get("expected_resisted_meter", -1.0))),
		"resistência reduz acumulação sem alterar o limiar")
	manager.tick(float(use_result.get("resistance_duration_s", 0.0)))
	_check(is_equal_approx(manager.resistance_multiplier(status_id),
		float(probe.get("expected_multiplier_after_expiry", -1.0))),
		"resistência termina na duração do item")
	manager.free()


func _test_legible_immunity_rejects_buildup() -> void:
	var manager := StatusEffectManager.new()
	_check(manager.configure(), "catálogo configura imunidades legíveis")
	var probe := manager.verification_case("legible_immunity")
	manager.set_target_tags(probe.get("target_tags", []) as Array)
	var feedback_events: Array[Dictionary] = []
	manager.feedback_requested.connect(func(event: Dictionary) -> void:
		feedback_events.append(event)
	)

	var result := manager.apply_buildup(
		String(probe.get("status_id", "")),
		float(probe.get("amount", 0.0))
	)

	_check(bool(result.get("immune", false)),
		"corpo sem sangue rejeita sangramento")
	_check(is_equal_approx(float(result.get("meter", -1.0)), float(probe.get("expected_meter", -2.0))),
		"imunidade não enche a barra")
	_check(feedback_events.size() == 1
		and not (feedback_events[0].get("visual", {}) as Dictionary).is_empty()
		and not (feedback_events[0].get("sound", {}) as Dictionary).is_empty(),
		"imunidade confirma-se por sinal visual e sonoro")
	manager.free()


func _test_poison_ticks_for_declared_duration() -> void:
	var manager := StatusEffectManager.new()
	_check(manager.configure(), "catálogo configura estados com duração")
	var probe := manager.verification_case("poison_duration")
	var status_id := String(probe.get("status_id", ""))
	manager.apply_buildup(status_id, float(probe.get("trigger_amount", 0.0)))

	var outcomes: Array = manager.tick(float(probe.get("elapsed_s", 0.0))) as Array
	var total_fraction := 0.0
	for outcome_value: Variant in outcomes:
		var outcome := outcome_value as Dictionary
		total_fraction += float((outcome.get("consequences", {}) as Dictionary).get("health_max_fraction", 0.0))
	_check(outcomes.size() == int(probe.get("expected_tick_count", -1)),
		"veneno pulsa no intervalo declarado durante toda a duração")
	_check(is_equal_approx(total_fraction, float(probe.get("expected_total_health_max_fraction", -1.0))),
		"os pulsos somam apenas o dano percentual declarado")
	_check(not manager.is_active(status_id),
		"veneno termina quando a duração acaba")
	manager.free()


func _test_partial_buildup_warns_without_triggering() -> void:
	var manager := StatusEffectManager.new()
	_check(manager.configure(), "catálogo configura o gestor")
	var probe := manager.verification_case("partial_buildup")
	var feedback_events: Array[Dictionary] = []
	manager.feedback_requested.connect(func(event: Dictionary) -> void:
		feedback_events.append(event)
	)

	var result := manager.apply_buildup(
		String(probe.get("status_id", "")),
		float(probe.get("amount", 0.0)),
		String(probe.get("source_id", ""))
	)

	_check(not bool(result.get("triggered", true)),
		"acumulação parcial não aplica o estado")
	_check(is_equal_approx(float(result.get("meter", -1.0)), float(probe.get("expected_meter", -2.0))),
		"a barra mostra a acumulação antes do limiar")
	_check(feedback_events.size() == 1,
		"a alteração da barra publica um único aviso sincronizado")
	if feedback_events.size() == 1:
		var feedback := feedback_events[0]
		_check(not (feedback.get("visual", {}) as Dictionary).is_empty(),
			"o aviso traz sinal visual")
		_check(not (feedback.get("sound", {}) as Dictionary).is_empty(),
			"o aviso traz sinal sonoro")
	manager.free()


func _test_decay_starts_only_after_grace() -> void:
	var manager := StatusEffectManager.new()
	_check(manager.configure(), "catálogo configura o relógio de decaimento")
	var probe := manager.verification_case("decay_after_grace")
	var status_id := String(probe.get("status_id", ""))
	manager.apply_buildup(status_id, float(probe.get("amount", 0.0)))

	manager.tick(float(probe.get("inside_grace_s", 0.0)))
	_check(is_equal_approx(manager.meter_value(status_id), float(probe.get("expected_inside_grace", -1.0))),
		"a barra não decai durante a janela de reação")
	manager.tick(float(probe.get("cross_grace_s", 0.0)))
	_check(is_equal_approx(manager.meter_value(status_id), float(probe.get("expected_after_crossing", -1.0))),
		"só o tempo posterior ao atraso faz a barra decair")
	manager.free()


func _test_threshold_triggers_after_warning() -> void:
	var manager := StatusEffectManager.new()
	_check(manager.configure(), "catálogo reconfigura um segundo alvo")
	var probe := manager.verification_case("threshold_trigger")
	var phases: Array[String] = []
	manager.feedback_requested.connect(func(event: Dictionary) -> void:
		phases.append(String(event.get("phase", "")))
	)
	manager.apply_buildup(
		String(probe.get("status_id", "")),
		float(probe.get("setup_amount", 0.0)),
		String(probe.get("source_id", ""))
	)

	var result := manager.apply_buildup(
		String(probe.get("status_id", "")),
		float(probe.get("trigger_amount", 0.0)),
		String(probe.get("source_id", ""))
	)

	_check(bool(result.get("triggered", false)),
		"o limiar dispara sangramento")
	_check(is_equal_approx(float(result.get("meter", -1.0)), float(probe.get("expected_meter", -2.0))),
		"o disparo limpa a barra")
	_check((result.get("consequences", {}) as Dictionary) ==
		(probe.get("expected_consequences", {}) as Dictionary),
		"o disparo devolve as consequências decididas")
	_check(phases.slice(phases.size() - 2) == ["buildup", "trigger"],
		"o aviso precede o disparo no mesmo limiar")
	manager.free()


func _check(condition: bool, message: String) -> void:
	if condition:
		_passed += 1
	else:
		_failed += 1
		push_error("[estados] FALHOU: %s" % message)
