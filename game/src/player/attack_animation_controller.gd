class_name AttackAnimationController
extends Node
## Movimentos do jogador por familia de arma.
##
## A UAL Quaternius (CC0) fornece o esqueleto e clips-base. As curvas que a
## biblioteca nao traz sao sintetizadas neste modulo; os tempos de combate nao
## vivem aqui e chegam sempre da ficha da arma em `weapons.json`.

const FAMILY_ANIMATIONS := {
	"espada_recta": {
		"leve_1": {"source_clip": "Sword_Attack", "motion": "corte_direita", "shape": "slash_right"},
		"leve_2": {"source_clip": "Sword_Attack", "motion": "corte_retorno", "shape": "slash_left"},
		"pesado": {"source_clip": "Sword_Attack", "motion": "vertical_duas_maos", "shape": "overhead"},
		"em_corrida": {"source_clip": "Sprint", "motion": "estocada_avanco", "shape": "thrust"},
	},
	"adaga": {
		"leve_1": {"source_clip": "Punch_Jab", "motion": "estocada_curta", "shape": "jab"},
		"leve_2": {"source_clip": "Punch_Cross", "motion": "corte_cruzado", "shape": "cross"},
		"pesado": {"source_clip": "Punch_Cross", "motion": "apunhalar_duas_maos", "shape": "double_thrust"},
		"em_corrida": {"source_clip": "Sprint", "motion": "entrada_baixa", "shape": "low_lunge"},
	},
	"pesada_corte": {
		"leve_1": {"source_clip": "Sword_Attack", "motion": "diagonal_com_peso", "shape": "diagonal_heavy"},
		"leve_2": {"source_clip": "Sword_Attack", "motion": "retorno_da_anca", "shape": "hip_return"},
		"pesado": {"source_clip": "Sword_Attack", "motion": "vertical_esmagador", "shape": "overhead_heavy"},
		"em_corrida": {"source_clip": "Sprint", "motion": "varrimento_em_corrida", "shape": "running_sweep"},
	},
	"katana": {
		"leve_1": {"source_clip": "Sword_Attack", "motion": "saque_horizontal", "shape": "draw_cut"},
		"leve_2": {"source_clip": "Sword_Attack", "motion": "corte_de_retorno_alto", "shape": "rising_return"},
		"pesado": {"source_clip": "Sword_Attack", "motion": "corte_vertical_controlado", "shape": "overhead_narrow"},
		"em_corrida": {"source_clip": "Sprint", "motion": "iai_em_corrida", "shape": "running_draw"},
	},
	"haste": {
		"leve_1": {"source_clip": "Sword_Attack", "motion": "estocada_longa", "shape": "long_thrust"},
		"leve_2": {"source_clip": "Sword_Attack", "motion": "estocada_recolhida", "shape": "retract_thrust"},
		"pesado": {"source_clip": "Sword_Attack", "motion": "varrimento_baixo", "shape": "low_sweep"},
		"em_corrida": {"source_clip": "Sprint", "motion": "carga_de_haste", "shape": "lance_charge"},
	},
	"cajado": {
		"leve_1": {"source_clip": "Sword_Attack", "motion": "bastao_lateral", "shape": "staff_sweep"},
		"leve_2": {"source_clip": "Sword_Attack", "motion": "bastao_de_retorno", "shape": "staff_return"},
		"pesado": {"source_clip": "Sword_Attack", "motion": "pancada_firmada", "shape": "staff_slam"},
		"em_corrida": {"source_clip": "Sprint", "motion": "empurrao_de_bastao", "shape": "staff_shove"},
	},
	"arco": {
		"leve_1": {"source_clip": "Pistol_Shoot", "motion": "soltar_flecha", "shape": "bow_release"},
		"leve_2": {"source_clip": "Pistol_Reload", "motion": "rearmar_do_lado", "shape": "bow_nock"},
		"pesado": {"source_clip": "Pistol_Aim_Neutral", "motion": "tiro_firmado", "shape": "bow_aim"},
		"em_corrida": {"source_clip": "Sprint", "motion": "disparo_em_corrida", "shape": "bow_running"},
	},
	"besta": {
		"leve_1": {"source_clip": "Pistol_Shoot", "motion": "gatilho_e_recuo", "shape": "crossbow_recoil"},
		"leve_2": {"source_clip": "Pistol_Reload", "motion": "baixar_e_rearmar", "shape": "crossbow_reload"},
		"pesado": {"source_clip": "Pistol_Aim_Neutral", "motion": "mira_ampliada", "shape": "crossbow_aim"},
		"em_corrida": {"source_clip": "Sprint", "motion": "tiro_da_anca", "shape": "crossbow_running"},
	},
}

# Graus de pose sao arte sintetizada, nao numeros de combate. Os tempos nunca
# aparecem nesta tabela; sao construidos exclusivamente com a ficha equipada.
const SHAPE_POSES := {
	"slash_right": {"windup": Vector3(-8, -48, -12), "strike": Vector3(6, 55, 14)},
	"slash_left": {"windup": Vector3(-4, 42, 10), "strike": Vector3(8, -58, -16)},
	"overhead": {"windup": Vector3(-42, -8, -5), "strike": Vector3(54, 6, 4)},
	"thrust": {"windup": Vector3(8, -24, 18), "strike": Vector3(-18, 12, -8)},
	"jab": {"windup": Vector3(12, -34, 24), "strike": Vector3(-12, 18, -16)},
	"cross": {"windup": Vector3(8, 38, -22), "strike": Vector3(-8, -26, 18)},
	"double_thrust": {"windup": Vector3(-16, -12, 28), "strike": Vector3(22, 10, -24)},
	"low_lunge": {"windup": Vector3(26, -28, 12), "strike": Vector3(-28, 16, -10)},
	"diagonal_heavy": {"windup": Vector3(-36, -46, -26), "strike": Vector3(46, 48, 28)},
	"hip_return": {"windup": Vector3(24, 52, 32), "strike": Vector3(-20, -58, -30)},
	"overhead_heavy": {"windup": Vector3(-58, 0, -12), "strike": Vector3(66, 0, 10)},
	"running_sweep": {"windup": Vector3(4, -62, -20), "strike": Vector3(10, 70, 22)},
	"draw_cut": {"windup": Vector3(20, -58, 30), "strike": Vector3(-8, 66, -18)},
	"rising_return": {"windup": Vector3(28, 46, -34), "strike": Vector3(-30, -54, 24)},
	"overhead_narrow": {"windup": Vector3(-48, -12, 8), "strike": Vector3(58, 14, -6)},
	"running_draw": {"windup": Vector3(18, -68, 24), "strike": Vector3(-18, 72, -20)},
	"long_thrust": {"windup": Vector3(4, -32, 8), "strike": Vector3(-8, 20, -4)},
	"retract_thrust": {"windup": Vector3(-6, 28, -10), "strike": Vector3(12, -18, 8)},
	"low_sweep": {"windup": Vector3(34, -52, -18), "strike": Vector3(22, 58, 20)},
	"lance_charge": {"windup": Vector3(18, -18, 2), "strike": Vector3(-32, 8, -2)},
	"staff_sweep": {"windup": Vector3(12, -46, -28), "strike": Vector3(18, 52, 32)},
	"staff_return": {"windup": Vector3(10, 48, 30), "strike": Vector3(16, -54, -34)},
	"staff_slam": {"windup": Vector3(-46, 6, -20), "strike": Vector3(58, -4, 18)},
	"staff_shove": {"windup": Vector3(6, -24, 30), "strike": Vector3(-14, 18, -28)},
	"bow_release": {"windup": Vector3(-6, -38, 36), "strike": Vector3(4, 20, -28)},
	"bow_nock": {"windup": Vector3(22, 28, -18), "strike": Vector3(-12, -34, 24)},
	"bow_aim": {"windup": Vector3(-18, -8, 42), "strike": Vector3(-4, 10, -36)},
	"bow_running": {"windup": Vector3(18, -44, 22), "strike": Vector3(-24, 30, -18)},
	"crossbow_recoil": {"windup": Vector3(-8, -18, 18), "strike": Vector3(16, 14, -14)},
	"crossbow_reload": {"windup": Vector3(30, 16, -26), "strike": Vector3(-22, -18, 30)},
	"crossbow_aim": {"windup": Vector3(-22, -4, 28), "strike": Vector3(12, 6, -22)},
	"crossbow_running": {"windup": Vector3(16, -30, 12), "strike": Vector3(-20, 24, -10)},
}

const FAMILY_ARM_BIAS := {
	"espada_recta": Vector3(0, 0, 0),
	"adaga": Vector3(18, 0, -20),
	"pesada_corte": Vector3(-24, 0, 26),
	"katana": Vector3(12, -12, -8),
	"haste": Vector3(-8, 18, 10),
	"cajado": Vector3(-16, -10, 18),
	"arco": Vector3(8, 26, -18),
	"besta": Vector3(-4, 18, 12),
}

const GENERATED_LIBRARY := "weapon_attacks"

var _actor: Node
var _character_visual: Node3D
var _animation_player: AnimationPlayer
var _generated_library: AnimationLibrary
var _last_request := ""
var _last_state_frame := -1
var _holding_charge := false
var _current_playback_name := ""


func setup(actor: Node, character_visual: Node3D) -> bool:
	_actor = actor
	_character_visual = character_visual
	_animation_player = _find_animation_player(character_visual)
	if _animation_player == null:
		push_error("[attack-animation] CharacterVisual sem AnimationPlayer")
		set_process(false)
		return false
	if _animation_player.has_animation_library(GENERATED_LIBRARY):
		_generated_library = _animation_player.get_animation_library(GENERATED_LIBRARY)
	else:
		_generated_library = AnimationLibrary.new()
		_animation_player.add_animation_library(GENERATED_LIBRARY, _generated_library)
	set_process(is_instance_valid(_actor))
	return true


func play_attack(weapon_id: String, attack_kind: String, combo_index: int,
		was_running: bool, attack: Dictionary) -> String:
	if _animation_player == null or _generated_library == null:
		return ""
	var game_data := get_node_or_null("/root/GameData")
	if game_data == null or not game_data.has_method("weapon"):
		return ""
	var weapon: Dictionary = game_data.call("weapon", weapon_id) as Dictionary
	var family_id := String(weapon.get("familia", ""))
	if not FAMILY_ANIMATIONS.has(family_id):
		return ""
	var action_id := "leve_1"
	if was_running:
		action_id = "em_corrida"
	elif attack_kind == "heavy":
		action_id = "pesado"
	elif combo_index > 1:
		action_id = "leve_2"
	var profile: Dictionary = (FAMILY_ANIMATIONS[family_id] as Dictionary)[action_id] as Dictionary
	var source_clip := String(profile.get("source_clip", ""))
	if not _animation_player.has_animation(source_clip):
		push_error("[attack-animation] clip UAL ausente: %s" % source_clip)
		return ""
	var animation_name := _generated_name(family_id, action_id, source_clip, attack)
	if not _generated_library.has_animation(animation_name):
		var generated := build_attack_animation(
			_animation_player.get_animation(source_clip), family_id, action_id, attack)
		if generated == null:
			return ""
		_generated_library.add_animation(animation_name, generated)
	var playback_name := "%s/%s" % [GENERATED_LIBRARY, animation_name]
	_animation_player.play(playback_name)
	return playback_name


func _process(_delta: float) -> void:
	if not is_instance_valid(_actor):
		return
	if not _actor.has_method("state_name") or String(_actor.call("state_name")) != "ataque":
		_last_request = ""
		_last_state_frame = -1
		_holding_charge = false
		_current_playback_name = ""
		return
	var state_frame := int(_read_property(_actor, "state_frame", -1))
	var weapon_id := String(_read_property(_actor, "_atk_weapon", ""))
	var attack_kind := String(_read_property(_actor, "_atk_kind", ""))
	var combo_index := int(_read_property(_actor, "_combo_index", 0))
	var was_running := bool(_read_property(_actor, "_sprinting", false))
	var charging := bool(_read_property(_actor, "_charging", false))
	var charge_frames := int(_read_property(_actor, "_charge_frames", 0))
	var attack := _read_property(_actor, "_atk", {}) as Dictionary
	# Corrida e uma propriedade do inicio do golpe. Largar Space durante o arco
	# nao pode transformar a animacao em leve parado a meio do contacto.
	var request := "%s|%s|%d" % [weapon_id, attack_kind, combo_index]
	if state_frame <= _last_state_frame or request != _last_request:
		_current_playback_name = play_attack(
			weapon_id, attack_kind, combo_index, was_running, attack)
		_last_request = request
		_holding_charge = false
	_sync_attack_pose(state_frame, attack, charge_frames, charging)
	_last_state_frame = state_frame


func _generated_name(family_id: String, action_id: String, source_clip: String,
		attack: Dictionary) -> String:
	return "%s_%s_%s_%s_%s_%s" % [
		family_id, action_id, source_clip,
		int(attack.get("startup", 0)), int(attack.get("active", 0)),
		int(attack.get("recovery", 0))]


func declared_family_animations() -> Dictionary:
	return FAMILY_ANIMATIONS.duplicate(true)


func visible_strike_active(state_frame: int, attack: Dictionary,
		charge_frames := 0) -> bool:
	## Espelha deliberadamente a fronteira publica do ataque no Player. Os tres
	## valores chegam da ficha equipada; este modulo nao os corrige nem completa.
	var startup := int(attack.get("startup", 0)) + charge_frames
	var active := int(attack.get("active", 0))
	return state_frame > startup and state_frame <= startup + active


func _sync_charge_hold(state_frame: int, attack: Dictionary, charging: bool) -> void:
	if _animation_player == null or attack.is_empty():
		return
	var startup_frames := int(attack.get("startup", 0))
	if charging and state_frame >= startup_frames:
		var ticks_per_second := float(ProjectSettings.get_setting(
			"physics/common/physics_ticks_per_second"))
		if ticks_per_second <= 0.0:
			return
		# O aviso chegou ao fim, mas a hitbox do Player tambem esta a ser adiada.
		# Congelar aqui conserva pose, som e dano na mesma verdade observavel.
		_animation_player.seek(float(startup_frames) / ticks_per_second, true)
		_animation_player.pause()
		_holding_charge = true
	elif _holding_charge:
		# `play()` sem nome retoma a animacao atribuida na posicao congelada.
		_animation_player.play()
		_holding_charge = false


func _sync_attack_pose(state_frame: int, attack: Dictionary,
		charge_frames: int, charging: bool) -> void:
	## `Player._refresh_animation()` ainda pede Sword_Attack em todos os ticks.
	## Repor e procurar a pose pelo frame autoritativo impede essa chamada de
	## apagar o moveset e impede a cadencia do render de deslocar a hitbox.
	if _animation_player == null or _current_playback_name.is_empty() \
			or attack.is_empty():
		return
	var ticks_per_second := float(ProjectSettings.get_setting(
		"physics/common/physics_ticks_per_second"))
	if ticks_per_second <= 0.0:
		return
	var startup_frames := int(attack.get("startup", 0))
	var visual_frame := maxi(0, state_frame - charge_frames)
	if charging and state_frame >= startup_frames:
		visual_frame = startup_frames
	if _animation_player.assigned_animation != _current_playback_name:
		_animation_player.play(_current_playback_name)
	_animation_player.seek(float(visual_frame) / ticks_per_second, true)
	_animation_player.pause()
	_holding_charge = charging and state_frame >= startup_frames


func build_attack_animation(source_animation: Animation, family_id: String,
		action_id: String, attack: Dictionary) -> Animation:
	## Faz uma animacao completa a partir da UAL, mas substitui tronco e bracos
	## por quatro poses: neutra, aviso, fim do contacto e recuperacao. Assim a
	## lamina so percorre o arco ofensivo entre `startup` e `startup + active`.
	if source_animation == null or not FAMILY_ANIMATIONS.has(family_id):
		return null
	var family: Dictionary = FAMILY_ANIMATIONS[family_id] as Dictionary
	if not family.has(action_id):
		return null
	for field: String in ["startup", "active", "recovery"]:
		if not attack.has(field) or int(attack[field]) <= 0:
			return null
	var ticks_per_second := float(ProjectSettings.get_setting(
		"physics/common/physics_ticks_per_second"))
	if ticks_per_second <= 0.0:
		return null

	var startup_s := float(int(attack["startup"])) / ticks_per_second
	var active_end_s := float(int(attack["startup"]) + int(attack["active"])) \
		/ ticks_per_second
	var duration_s := float(int(attack["startup"]) + int(attack["active"]) \
		+ int(attack["recovery"])) / ticks_per_second
	var generated := source_animation.duplicate(true) as Animation
	if generated == null:
		return null
	_rescale_animation(generated, duration_s)
	generated.loop_mode = Animation.LOOP_NONE
	generated.resource_name = "%s_%s" % [family_id, action_id]

	var profile: Dictionary = family[action_id] as Dictionary
	var shape: Dictionary = SHAPE_POSES.get(String(profile.get("shape", "")), {}) as Dictionary
	if shape.is_empty():
		return null
	var windup: Vector3 = shape.get("windup", Vector3.ZERO) as Vector3
	var strike: Vector3 = shape.get("strike", Vector3.ZERO) as Vector3
	var arm_bias: Vector3 = FAMILY_ARM_BIAS.get(family_id, Vector3.ZERO) as Vector3
	for bone_name: String in [
			"spine_03", "upperarm_r", "lowerarm_r", "upperarm_l", "lowerarm_l"]:
		_replace_bone_rotation_track(generated, source_animation, bone_name,
			startup_s, active_end_s, duration_s,
			_bone_pose_degrees(bone_name, windup, arm_bias),
			_bone_pose_degrees(bone_name, strike, arm_bias))
	return generated


func _rescale_animation(animation: Animation, target_length: float) -> void:
	var source_length := animation.length
	if source_length <= 0.0:
		animation.length = target_length
		return
	var scale_factor := target_length / source_length
	# Alterar tempos no proprio track pode fundir chaves importadas que passam
	# temporariamente pela mesma posicao (acontecia no Sprint). Reconstruir os
	# tracks preserva cada chave e evita indices invalidos.
	var track_copies: Array[Dictionary] = []
	for track: int in animation.get_track_count():
		var keys: Array[Dictionary] = []
		for key: int in animation.track_get_key_count(track):
			keys.append({
				"time": animation.track_get_key_time(track, key) * scale_factor,
				"value": animation.track_get_key_value(track, key),
				"transition": animation.track_get_key_transition(track, key),
			})
		track_copies.append({
			"type": animation.track_get_type(track),
			"path": animation.track_get_path(track),
			"interpolation": animation.track_get_interpolation_type(track),
			"enabled": animation.track_is_enabled(track),
			"keys": keys,
		})
	for track: int in range(animation.get_track_count() - 1, -1, -1):
		animation.remove_track(track)
	for track_copy: Dictionary in track_copies:
		var rebuilt_track := animation.add_track(int(track_copy["type"]))
		animation.track_set_path(rebuilt_track, track_copy["path"] as NodePath)
		animation.track_set_interpolation_type(
			rebuilt_track, int(track_copy["interpolation"]))
		animation.track_set_enabled(rebuilt_track, bool(track_copy["enabled"]))
		for key_copy: Dictionary in track_copy["keys"] as Array[Dictionary]:
			animation.track_insert_key(rebuilt_track, float(key_copy["time"]),
				key_copy["value"], float(key_copy["transition"]))
	animation.length = target_length


func _replace_bone_rotation_track(generated: Animation, source: Animation,
		bone_name: String, startup_s: float, active_end_s: float, duration_s: float,
		windup_degrees: Vector3, strike_degrees: Vector3) -> void:
	var source_track := _rotation_track_for_bone(source, bone_name)
	var generated_track := _rotation_track_for_bone(generated, bone_name)
	if source_track < 0 or generated_track < 0:
		return
	var path := generated.track_get_path(generated_track)
	var base_rotation := source.rotation_track_interpolate(source_track, 0.0)
	generated.remove_track(generated_track)
	var track := generated.add_track(Animation.TYPE_ROTATION_3D)
	generated.track_set_path(track, path)
	generated.track_set_interpolation_type(track, Animation.INTERPOLATION_LINEAR)
	generated.track_insert_key(track, 0.0, base_rotation)
	generated.track_insert_key(track, startup_s,
		base_rotation * Quaternion.from_euler(_radians(windup_degrees)))
	generated.track_insert_key(track, active_end_s,
		base_rotation * Quaternion.from_euler(_radians(strike_degrees)))
	generated.track_insert_key(track, duration_s, base_rotation)


func _rotation_track_for_bone(animation: Animation, bone_name: String) -> int:
	for track: int in animation.get_track_count():
		if animation.track_get_type(track) != Animation.TYPE_ROTATION_3D:
			continue
		if String(animation.track_get_path(track)).ends_with(":%s" % bone_name):
			return track
	return -1


func _bone_pose_degrees(bone_name: String, torso: Vector3,
		arm_bias: Vector3) -> Vector3:
	match bone_name:
		"spine_03":
			return torso * 0.45
		"upperarm_r":
			return Vector3(torso.x - 34.0, torso.y, torso.z + 48.0) + arm_bias
		"lowerarm_r":
			return Vector3(torso.x * 0.35, torso.y * 0.25, torso.z * 0.70) \
				+ arm_bias * 0.25
		"upperarm_l":
			return Vector3(torso.x - 22.0, -torso.y * 0.55,
				-torso.z * 0.60) + Vector3(arm_bias.x, -arm_bias.y, -arm_bias.z) * 0.65
		"lowerarm_l":
			return Vector3(torso.x * 0.30, -torso.y * 0.20,
				-torso.z * 0.55) + Vector3(arm_bias.x, -arm_bias.y, -arm_bias.z) * 0.20
	return Vector3.ZERO


func _radians(degrees: Vector3) -> Vector3:
	return Vector3(deg_to_rad(degrees.x), deg_to_rad(degrees.y),
		deg_to_rad(degrees.z))


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child: Node in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null


func _read_property(object: Object, property_name: StringName,
		fallback: Variant) -> Variant:
	for property: Dictionary in object.get_property_list():
		if StringName(property.get("name", "")) == property_name:
			return object.get(property_name)
	return fallback
