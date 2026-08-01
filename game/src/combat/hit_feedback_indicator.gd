class_name HitFeedbackIndicator
extends Control
## Seta de dano recebido: responde "quem e de onde" mesmo fora do ecra.
##
## Nao antecipa ataques nem substitui a cunha de telegrafia. So aparece depois
## do contacto confirmado e dura enquanto o jogador esta na reaccao autoritativa.

var actor: Node3D
var source_position := Vector3.ZERO
var reaction_frames_left := 0
var shown_physics_frame := -1


func setup(p_actor: Node3D) -> void:
	actor = p_actor
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	visible = false
	set_physics_process(false)


func show_source(at: Vector3, reaction_frames: int) -> void:
	source_position = at
	reaction_frames_left = reaction_frames
	shown_physics_frame = Engine.get_physics_frames()
	visible = reaction_frames_left > 0
	set_physics_process(visible)
	queue_redraw()


func _physics_process(_delta: float) -> void:
	if reaction_frames_left <= 0:
		visible = false
		set_physics_process(false)
		return
	reaction_frames_left -= 1
	if reaction_frames_left == 0:
		visible = false
		set_physics_process(false)
	else:
		queue_redraw()


func screen_direction_to_source() -> Vector2:
	if not is_instance_valid(actor):
		return Vector2.UP
	var camera := _active_camera()
	if camera == null:
		return Vector2.UP
	var to_source := source_position - actor.global_position
	to_source.y = 0.0
	if to_source.length_squared() <= 0.0:
		return Vector2.UP
	to_source = to_source.normalized()
	var camera_forward := -camera.global_transform.basis.z
	camera_forward.y = 0.0
	camera_forward = camera_forward.normalized()
	var camera_right := camera.global_transform.basis.x
	camera_right.y = 0.0
	camera_right = camera_right.normalized()
	return Vector2(camera_right.dot(to_source), -camera_forward.dot(to_source)).normalized()


func _draw() -> void:
	if not visible:
		return
	var viewport_size := get_viewport_rect().size
	var centre := viewport_size * 0.5
	var direction := screen_direction_to_source()
	var edge_radius := minf(viewport_size.x, viewport_size.y) * 0.38
	var tip := centre + direction * edge_radius
	var side := direction.orthogonal()
	var arrow_length := minf(viewport_size.x, viewport_size.y) * 0.045
	var arrow_width := arrow_length * 0.72
	var points := PackedVector2Array([
		tip,
		tip - direction * arrow_length + side * arrow_width,
		tip - direction * arrow_length * 0.58,
		tip - direction * arrow_length - side * arrow_width,
	])
	draw_colored_polygon(points, Color(0.82, 0.12, 0.10, 0.92))
	draw_polyline(PackedVector2Array([points[0], points[1], points[2], points[3], points[0]]),
		Color(1.0, 0.78, 0.58, 0.95), maxf(arrow_length * 0.08, 1.0), true)


func _active_camera() -> Camera3D:
	if is_instance_valid(actor):
		for property: Dictionary in actor.get_property_list():
			if String(property.get("name", "")) != "camera":
				continue
			var camera_rig: Variant = actor.get("camera")
			if camera_rig != null and camera_rig.has_method("get_camera"):
				var camera_value: Variant = camera_rig.call("get_camera")
				if camera_value is Camera3D:
					return camera_value as Camera3D
	return get_viewport().get_camera_3d()
