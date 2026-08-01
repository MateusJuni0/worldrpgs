extends RefCounted
## Separação determinística entre inimigos. Não escolhe ataques nem altera
## velocidades: limita-se a somar o afastamento definido em enemies.json.


static func resolve_spawn_overlap(actor: CharacterBody3D, neighbours: Array,
		config: Dictionary) -> void:
	var attempts := int(config.get("spawn_resolution_attempts", 0))
	var slots := int(config.get("spawn_ring_slots", 0))
	if attempts <= 0 or slots <= 0:
		return
	var origin := actor.global_position
	var seed := absi(int(actor.get_instance_id()))
	for attempt: int in attempts:
		var required := _largest_overlap_distance(actor, neighbours, config)
		if required <= 0.0:
			return
		var ring := float(attempt / slots + 1)
		var slot := (seed + attempt) % slots
		var angle := TAU * float(slot) / float(slots)
		actor.global_position = origin + Vector3(cos(angle), 0.0, sin(angle)) * required * ring


static func separate_velocity(actor: CharacterBody3D, current: Vector3,
		neighbours: Array, config: Dictionary, maximum_speed: float) -> Vector3:
	var correction := Vector3.ZERO
	var own_radius := _body_radius(actor)
	var multiplier := float(config.get("separation_radius_multiplier", 0.0))
	for node: Variant in neighbours:
		if node == actor or not is_instance_valid(node) or not node is Node3D:
			continue
		var other := node as Node3D
		var offset := actor.global_position - other.global_position
		offset.y = 0.0
		var desired := (own_radius + _body_radius(other)) * multiplier
		if desired <= 0.0 or offset.length_squared() >= desired * desired:
			continue
		if offset.is_zero_approx():
			offset = Vector3.RIGHT if actor.get_instance_id() > other.get_instance_id() else Vector3.LEFT
		var distance := offset.length()
		correction += offset / distance * (1.0 - distance / desired)
	if correction.is_zero_approx():
		return current
	var horizontal := Vector3(current.x, 0.0, current.z)
	var separation_speed := float(config.get("separation_speed_m_s", 0.0))
	horizontal += correction.normalized() * separation_speed
	if maximum_speed > 0.0 and horizontal.length() > maximum_speed:
		horizontal = horizontal.normalized() * maximum_speed
	return Vector3(horizontal.x, current.y, horizontal.z)


static func _largest_overlap_distance(actor: Node3D, neighbours: Array,
		config: Dictionary) -> float:
	var required := 0.0
	var own_radius := _body_radius(actor)
	var clearance := float(config.get("spawn_clearance_m", 0.0))
	for node: Variant in neighbours:
		if node == actor or not is_instance_valid(node) or not node is Node3D:
			continue
		var other := node as Node3D
		var offset := actor.global_position - other.global_position
		offset.y = 0.0
		var minimum := own_radius + _body_radius(other) + clearance
		if offset.length_squared() < minimum * minimum:
			required = maxf(required, minimum)
	return required


static func _body_radius(node: Object) -> float:
	var value: Variant = node.get("body_radius")
	return float(value) if value != null else 0.0
