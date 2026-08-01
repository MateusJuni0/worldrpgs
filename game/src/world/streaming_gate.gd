extends Node3D
## Garganta física entre duas zonas. O jogador usa-a só com movimento: a área
## exterior prepara a vizinha; a barreira de bruma desaparece quando todos estão
## prontos; a saída liberta a zona de retirada.

signal fog_changed(open: bool)

var _manager: Node
var _zone_a := ""
var _zone_b := ""
var _fog: MeshInstance3D
var _barrier: StaticBody3D
var _open := false
var _crossed := false


func configure(manager: Node, zone_a: String, zone_b: String,
		dimensions: Vector3) -> bool:
	if not is_instance_valid(manager) or zone_a == "" or zone_b == "" or zone_a == zone_b:
		return false
	if dimensions.x <= 0.0 or dimensions.y <= 0.0 or dimensions.z <= 0.0:
		return false
	for required_method: String in ["current_zone_id", "prepare_transition",
			"commit_transition", "release_retreat_zone", "cancel_transition"]:
		if not manager.has_method(required_method):
			return false
	_manager = manager
	_zone_a = zone_a
	_zone_b = zone_b
	_build_fog_and_barrier(dimensions)
	_build_proximity_areas(dimensions)
	_manager.transition_ready.connect(_on_transition_ready)
	_manager.zone_failed.connect(_on_zone_failed)
	_set_open(false)
	return true


func player_approached() -> bool:
	var target_zone_id := _other_zone(String(_manager.call("current_zone_id")))
	if target_zone_id == "":
		return false
	_crossed = false
	_set_open(false)
	return bool(_manager.call("prepare_transition", target_zone_id))


func player_crossed() -> bool:
	if not _open:
		return false
	var target_zone_id := _other_zone(String(_manager.call("current_zone_id")))
	if target_zone_id == "" or not bool(_manager.call("commit_transition", target_zone_id)):
		return false
	_crossed = true
	return true


func player_cleared() -> bool:
	if not _crossed or not bool(_manager.call("release_retreat_zone")):
		return false
	_crossed = false
	_set_open(false)
	return true


func player_withdrew() -> bool:
	if _crossed or not bool(_manager.call("cancel_transition")):
		return false
	_set_open(false)
	return true


func is_open() -> bool:
	return _open


func _build_fog_and_barrier(dimensions: Vector3) -> void:
	_fog = MeshInstance3D.new()
	_fog.name = "Fog"
	var fog_mesh := BoxMesh.new()
	fog_mesh.size = dimensions
	_fog.mesh = fog_mesh
	var fog_material := StandardMaterial3D.new()
	fog_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	fog_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	fog_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	fog_material.albedo_color = Color(0.62, 0.70, 0.66, 0.72)
	_fog.material_override = fog_material
	add_child(_fog)

	_barrier = StaticBody3D.new()
	_barrier.name = "FogBarrier"
	_barrier.collision_layer = 1
	_barrier.collision_mask = 0
	var barrier_shape := CollisionShape3D.new()
	var barrier_box := BoxShape3D.new()
	barrier_box.size = dimensions
	barrier_shape.shape = barrier_box
	_barrier.add_child(barrier_shape)
	add_child(_barrier)


func _build_proximity_areas(dimensions: Vector3) -> void:
	var approach := Area3D.new()
	approach.name = "Approach"
	approach.collision_layer = 0
	approach.collision_mask = 2
	var approach_shape := CollisionShape3D.new()
	var approach_box := BoxShape3D.new()
	approach_box.size = Vector3(dimensions.x * 2.0, dimensions.y, dimensions.z * 6.0)
	approach_shape.shape = approach_box
	approach.add_child(approach_shape)
	add_child(approach)
	approach.body_entered.connect(_on_approach_body_entered)
	approach.body_exited.connect(_on_approach_body_exited)

	var crossing := Area3D.new()
	crossing.name = "Crossing"
	crossing.collision_layer = 0
	crossing.collision_mask = 2
	var crossing_shape := CollisionShape3D.new()
	var crossing_box := BoxShape3D.new()
	crossing_box.size = dimensions
	crossing_shape.shape = crossing_box
	crossing.add_child(crossing_shape)
	add_child(crossing)
	crossing.body_entered.connect(_on_crossing_body_entered)


func _other_zone(current_zone_id: String) -> String:
	if current_zone_id == _zone_a:
		return _zone_b
	if current_zone_id == _zone_b:
		return _zone_a
	return ""


func _set_open(value: bool) -> void:
	if _open == value and is_instance_valid(_fog):
		_fog.visible = not value
		_barrier.collision_layer = 0 if value else 1
		return
	_open = value
	if is_instance_valid(_fog):
		_fog.visible = not value
	if is_instance_valid(_barrier):
		_barrier.collision_layer = 0 if value else 1
	fog_changed.emit(value)


func _is_player(body: Node3D) -> bool:
	return body.is_in_group("player")


func _on_approach_body_entered(body: Node3D) -> void:
	if _is_player(body):
		player_approached()


func _on_crossing_body_entered(body: Node3D) -> void:
	if _is_player(body):
		player_crossed()


func _on_approach_body_exited(body: Node3D) -> void:
	if not _is_player(body):
		return
	if _crossed:
		player_cleared()
	else:
		player_withdrew()


func _on_transition_ready(zone_id: String) -> void:
	if zone_id == _other_zone(String(_manager.call("current_zone_id"))):
		_set_open(true)


func _on_zone_failed(zone_id: String, _reason: String) -> void:
	if zone_id == _other_zone(String(_manager.call("current_zone_id"))):
		_set_open(false)
