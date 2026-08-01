extends RefCounted
## Guarda de honestidade para ataques em grupo (spec/38 §3). Se outro inimigo
## já entrou no golpe neste frame, ou o jogador ainda está no hit-stun do golpe
## anterior + intervalo declarado, o segundo ataque cancela antes da hitbox.

static var _last_active_frame: Dictionary = {}
static var _blocked_until_frame: Dictionary = {}


static func can_enter_active(target: Node, attacker: Node, active_frames: int) -> bool:
	if not is_instance_valid(target) or not is_instance_valid(attacker):
		return false
	var target_key := int(target.get_instance_id())
	var frame := int(Engine.get_physics_frames())
	if frame <= int(_blocked_until_frame.get(target_key, -1)):
		return false
	if int(_last_active_frame.get(target_key, -1)) == frame:
		return false
	_last_active_frame[target_key] = frame
	_blocked_until_frame[target_key] = frame + maxi(active_frames, 1) - 1
	return true


static func record_hitstun(target: Node, hitstun_frames: int,
		config: Dictionary, reference_fps: float) -> void:
	if not is_instance_valid(target):
		return
	var gap_frames := ceili(float(config.get("post_action_gap_s", 0.0)) * reference_fps)
	var release_frame := int(Engine.get_physics_frames()) + hitstun_frames + gap_frames
	var key := int(target.get_instance_id())
	_blocked_until_frame[key] = maxi(int(_blocked_until_frame.get(key, -1)), release_frame)


static func forget_target(target: Node) -> void:
	if not is_instance_valid(target):
		return
	var key := int(target.get_instance_id())
	_last_active_frame.erase(key)
	_blocked_until_frame.erase(key)
