class_name AimHud
extends CanvasLayer
## Indicadores vetoriais da mira. Não usa texturas nem partículas: a arte é
## sintetizada por draw_* e acrescenta um único Control à moldura.

class AimSurface extends Control:
	var controller: Node

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	func _draw() -> void:
		if not is_instance_valid(controller):
			return
		var camera := get_viewport().get_camera_3d()
		if camera == null:
			return
		var target := controller.call("display_target") as Node3D
		if is_instance_valid(target):
			_draw_locked_target(camera, target)
		elif bool(controller.call("free_aim_visible")):
			_draw_free_aim(camera)

	func _draw_locked_target(camera: Camera3D, target: Node3D) -> void:
		var world_point := controller.call("target_visual_point", target) as Vector3
		if camera.is_position_behind(world_point):
			return
		var point := camera.unproject_position(world_point)
		var colour := Color("e2bb70")
		_draw_brackets(point, colour)
		var health := float(target.get("health"))
		var max_health := float(target.get("max_health"))
		var posture := float(target.get("posture"))
		var max_posture := float(target.get("max_posture"))
		var health_fraction := clampf(health / maxf(max_health, 1.0), 0.0, 1.0)
		var posture_fraction := clampf(posture / maxf(max_posture, 1.0), 0.0, 1.0)
		var health_rect := Rect2(point + Vector2(-60.0, 30.0), Vector2(120.0, 8.0))
		draw_rect(health_rect.grow(2.0), Color(0.02, 0.02, 0.025, 0.9))
		draw_rect(Rect2(health_rect.position,
			Vector2(health_rect.size.x * health_fraction, health_rect.size.y)), Color("b94b48"))
		var posture_rect := Rect2(point + Vector2(-60.0, 41.0), Vector2(120.0, 4.0))
		draw_rect(posture_rect, Color(0.04, 0.04, 0.05, 0.9))
		draw_rect(Rect2(posture_rect.position,
			Vector2(posture_rect.size.x * posture_fraction, posture_rect.size.y)), Color("d4b36f"))
		var binding := SettingsSystem.binding_label("lock_on").to_upper()
		_draw_centered_text(point + Vector2(0.0, 66.0), "%s  SOLTAR" % binding, 13, colour, 240.0)

	func _draw_free_aim(camera: Camera3D) -> void:
		var world_point := controller.call("free_aim_point") as Vector3
		if camera.is_position_behind(world_point):
			return
		var point := camera.unproject_position(world_point)
		var hits_enemy := bool(controller.call("free_aim_hits_enemy"))
		var colour := Color("9ed7ee") if hits_enemy else Color("e9e6d8")
		draw_circle(point, 10.0, colour, false, 2.0, true)
		draw_line(point + Vector2(-18.0, 0.0), point + Vector2(-7.0, 0.0), colour, 2.0, true)
		draw_line(point + Vector2(7.0, 0.0), point + Vector2(18.0, 0.0), colour, 2.0, true)
		draw_line(point + Vector2(0.0, -18.0), point + Vector2(0.0, -7.0), colour, 2.0, true)
		draw_line(point + Vector2(0.0, 7.0), point + Vector2(0.0, 18.0), colour, 2.0, true)
		if hits_enemy:
			var binding := SettingsSystem.binding_label("lock_on").to_upper()
			_draw_centered_text(point + Vector2(0.0, 38.0), "%s  ENGATAR" % binding,
				13, colour, 240.0)

	func _draw_brackets(point: Vector2, colour: Color) -> void:
		var inner := 13.0
		var outer := 24.0
		for sx: float in [-1.0, 1.0]:
			for sy: float in [-1.0, 1.0]:
				var corner := point + Vector2(sx * outer, sy * outer)
				draw_line(corner, Vector2(point.x + sx * inner, corner.y), colour, 3.0, true)
				draw_line(corner, Vector2(corner.x, point.y + sy * inner), colour, 3.0, true)

	func _draw_centered_text(at: Vector2, text: String, font_size: int,
			colour: Color, width: float) -> void:
		draw_string(ThemeDB.fallback_font, at - Vector2(width * 0.5, 0.0), text,
			HORIZONTAL_ALIGNMENT_CENTER, width, font_size, colour)


var _surface: AimSurface


func setup(controller: Node) -> void:
	layer = 54
	_surface = AimSurface.new()
	_surface.controller = controller
	add_child(_surface)


func _process(_delta: float) -> void:
	if is_instance_valid(_surface):
		_surface.queue_redraw()
