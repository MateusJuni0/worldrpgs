extends CanvasLayer
## Dono do minimapa e, nos blocos seguintes, do mapa grande e da persistencia.

const ExplorationMapScript = preload("res://src/world/exploration_map.gd")
const MapSurfaceScript = preload("res://src/ui/map_surface.gd")

var player: Node3D
var partner: Node3D
var world: Node3D
var zone_id := "brumal"
var minimap_enabled := true
var north_up := false

var _exploration: RefCounted
var _minimap_panel: Control
var _minimap_surface: Control
var _config: Dictionary = {}
var _update_clock := 0.0


func _ready() -> void:
	layer = 54
	process_mode = Node.PROCESS_MODE_ALWAYS


func initialize(p_player: Node3D, p_partner: Node3D, p_world: Node3D,
		p_zone_id := "brumal") -> void:
	player = p_player
	partner = p_partner
	world = p_world
	zone_id = p_zone_id
	_config = ((GameData.world.get("map_reading", {}) as Dictionary).get(
		"runtime", {}) as Dictionary).duplicate(true)
	for argument: String in OS.get_cmdline_user_args():
		if argument == "--minimap=off":
			minimap_enabled = false
	var bounds_data: Dictionary = _config.get("zone_bounds_m", {}) as Dictionary
	var bounds := Rect2(
		Vector2(float(bounds_data.get("min_x", -110.0)), float(bounds_data.get("min_z", -110.0))),
		Vector2(float(bounds_data.get("size_x", 220.0)), float(bounds_data.get("size_z", 220.0))))
	_exploration = ExplorationMapScript.new()
	_exploration.call("configure", zone_id, bounds, float(_config.get("cell_size_m", 4.0)))
	_exploration.call("reveal", player.global_position, float(_config.get("reveal_radius_m", 7.0)))
	_discover_nearby_landmarks()
	_build_minimap(bounds)
	set_minimap_enabled(minimap_enabled)


func set_minimap_enabled(enabled: bool) -> void:
	minimap_enabled = enabled
	if _minimap_panel != null:
		_minimap_panel.visible = enabled


func set_north_up(enabled: bool) -> void:
	north_up = enabled
	if _minimap_surface != null:
		_minimap_surface.set("north_up", north_up)
		_minimap_surface.queue_redraw()


func exploration_state() -> RefCounted:
	return _exploration


func _build_minimap(bounds: Rect2) -> void:
	_minimap_panel = Control.new()
	_minimap_panel.name = "Minimapa"
	_minimap_panel.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	_minimap_panel.offset_left = -302.0
	_minimap_panel.offset_top = 30.0
	_minimap_panel.offset_right = -30.0
	_minimap_panel.offset_bottom = 302.0
	_minimap_panel.clip_contents = true
	_minimap_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_minimap_panel)

	_minimap_surface = MapSurfaceScript.new()
	_minimap_surface.name = "Superficie"
	_minimap_surface.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_minimap_surface.offset_left = 5.0
	_minimap_surface.offset_top = 5.0
	_minimap_surface.offset_right = -5.0
	_minimap_surface.offset_bottom = -5.0
	_minimap_panel.add_child(_minimap_surface)
	_minimap_surface.call("set_context", _exploration, player, partner, bounds,
		world.get("path_points"), world.get("map_landmarks"), _config)
	_minimap_surface.set("north_up", north_up)


func _process(delta: float) -> void:
	if _exploration == null or not is_instance_valid(player) or not minimap_enabled:
		return
	_update_clock += delta
	var interval := 1.0 / maxf(float(_config.get("update_hz", 10.0)), 1.0)
	if _update_clock < interval:
		return
	_update_clock = 0.0
	var terrain_changed: bool = _exploration.call("reveal", player.global_position,
		float(_config.get("reveal_radius_m", 7.0)))
	var changed := _discover_nearby_landmarks() or terrain_changed
	if changed and _minimap_surface != null:
		if terrain_changed:
			_minimap_surface.call("update_revealed_cells",
				_exploration.get("last_revealed_cells"))
		_minimap_surface.queue_redraw()


func _discover_nearby_landmarks() -> bool:
	if not is_instance_valid(world) or not is_instance_valid(player):
		return false
	var changed := false
	for landmark: Dictionary in world.get("map_landmarks"):
		var at: Vector3 = landmark.get("position", Vector3.ZERO)
		if player.global_position.distance_to(at) <= float(landmark.get("discover_radius_m", 12.0)):
			changed = _exploration.call("discover_landmark",
				String(landmark.get("id", ""))) or changed
	return changed
