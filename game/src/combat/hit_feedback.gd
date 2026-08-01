class_name HitFeedback
extends Node
## Coordenador barato do impacto confirmado.
##
## Escolha [CODEX]: hit-stop local ja existente + reaccao de dor + pulso no
## contacto + som por superficie + direccao quando o jogador sofre o golpe.
## Razao: cobre peso, confirmacao e origem sem esconder a proxima telegrafia.
## Alternativas descartadas: numeros flutuantes (tom [EM ABERTO]) e tremor a
## cada golpe (ruido visual, enjoo e nenhum dado novo sobre o contacto).

const ImpactEffectRenderer = preload("res://src/combat/impact_effect.gd")
const ImpactAudioRenderer = preload("res://src/combat/hit_feedback_audio.gd")
const DirectionIndicatorRenderer = preload("res://src/combat/hit_feedback_indicator.gd")
const MAX_SIMULTANEOUS_IMPACTS := 5

var actor: Node3D
var audio_enabled := true
var effects_enabled := true
var last_impact_physics_frame := -1
var last_contact_point := Vector3.ZERO
var last_surface := ""

var _audio: HitFeedbackAudio
var _indicator: HitFeedbackIndicator
var _effect_pool: Array[ImpactEffect] = []


static func install(on_actor: Node3D) -> HitFeedback:
	var existing := on_actor.get_node_or_null("HitFeedback") as HitFeedback
	if existing != null:
		return existing
	var feedback := HitFeedback.new()
	feedback.name = "HitFeedback"
	on_actor.add_child(feedback)
	feedback.setup(on_actor)
	return feedback


static func for_actor(on_actor: Node) -> HitFeedback:
	if not is_instance_valid(on_actor):
		return null
	return on_actor.get_node_or_null("HitFeedback") as HitFeedback


func setup(on_actor: Node3D) -> void:
	actor = on_actor
	if _audio == null:
		_audio = ImpactAudioRenderer.new() as HitFeedbackAudio
		_audio.name = "ImpactAudio"
		add_child(_audio)
	if _indicator == null:
		var layer := CanvasLayer.new()
		layer.name = "IncomingImpactLayer"
		layer.layer = 80
		add_child(layer)
		_indicator = DirectionIndicatorRenderer.new() as HitFeedbackIndicator
		_indicator.name = "IncomingDirection"
		layer.add_child(_indicator)
		_indicator.setup(actor)
	_build_effect_pool()


func present_hit(attacker: Node3D, target: Node3D, info: DamageInfo,
		surface := "flesh", active_frames_override := -1) -> ImpactEffect:
	var event := ImpactEvent.capture(attacker, target, info, surface,
		active_frames_override)
	if event.active_frames_remaining <= 0:
		push_error("[impacto] dano apresentado fora da hitbox activa")
		return null

	last_impact_physics_frame = event.physics_frame
	last_contact_point = event.contact_point
	last_surface = event.surface

	var effect: ImpactEffect = null
	if effects_enabled:
		effect = _available_effect()
		effect.setup(event)
	if audio_enabled and is_instance_valid(_audio):
		_audio.play_surface(event.surface, event.contact_point)
	_play_hit_reaction(target)
	if target == actor and is_instance_valid(_indicator):
		_indicator.show_source(event.source_position, event.reaction_frames)
	return effect


func incoming_indicator() -> HitFeedbackIndicator:
	return _indicator


func _play_hit_reaction(target: Node3D) -> void:
	if not is_instance_valid(target):
		return
	if target.has_method("is_alive") and not bool(target.call("is_alive")):
		return
	for property: Dictionary in target.get_property_list():
		if String(property.get("name", "")) != "_visual":
			continue
		var visual: Variant = target.get("_visual")
		if visual != null and visual.has_method("play_animation"):
			visual.call("play_animation", "Hit_Chest")
		return


func _effect_parent() -> Node:
	var scene := get_tree().current_scene
	return scene if scene != null else get_tree().root


func _build_effect_pool() -> void:
	if not _effect_pool.is_empty():
		return
	for index in MAX_SIMULTANEOUS_IMPACTS:
		var effect := ImpactEffectRenderer.new() as ImpactEffect
		effect.name = "ImpactPool%d" % index
		_effect_parent().add_child(effect)
		effect.prepare()
		_effect_pool.append(effect)


func _available_effect() -> ImpactEffect:
	for effect: ImpactEffect in _effect_pool:
		if effect.is_available():
			return effect
	# O orçamento e cinco contactos simultaneos. Se forem excedidos, reutiliza o
	# pulso mais perto do fim em vez de alocar durante o frame de combate.
	var candidate := _effect_pool[0]
	for effect: ImpactEffect in _effect_pool:
		if effect.active_frames_left < candidate.active_frames_left:
			candidate = effect
	return candidate


func _exit_tree() -> void:
	for effect: ImpactEffect in _effect_pool:
		if is_instance_valid(effect):
			effect.queue_free()
	_effect_pool.clear()
