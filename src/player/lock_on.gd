class_name LockOn
extends Node
## Engate de alvo — spec/01-combate.md, seccao Lock-on.
##
##   engate 18 m com linha de vista · quebra > 25 m, 1,5 s sem linha de vista, ou alvo morto
##   trocar de alvo com flick do rato · NAO re-engata sozinho
##
## O "nao re-engata sozinho" e deliberado: evita a camara saltar para o parceiro
## ou para o inimigo errado a meio de um combo.

signal target_changed(new_target: Node3D)

var target: Node3D = null

var _owner: Node3D
var _engage_range := 18.0
var _break_range := 25.0
var _los_grace := 1.5
var _no_los_time := 0.0


func setup(p_owner: Node3D, cfg: Dictionary) -> void:
	_owner = p_owner
	_engage_range = cfg.get("engage_range", 18.0)
	_break_range = cfg.get("break_range", 25.0)
	_los_grace = cfg.get("los_grace", 1.5)


func toggle() -> void:
	if target != null:
		_set_target(null)
	else:
		_set_target(_best_candidate(null))


## Flick do rato: troca para o alvo seguinte a esquerda ou a direita.
func cycle(direction: float) -> void:
	if target == null:
		return
	var next := _best_candidate(target, direction)
	if next != null:
		_set_target(next)


func tick(delta: float) -> void:
	if target == null:
		return
	if not is_instance_valid(target) or not _is_alive(target):
		_set_target(null)   # alvo morto: quebra e NAO re-engata
		return

	var d := _owner.global_position.distance_to(target.global_position)
	if d > _break_range:
		_set_target(null)
		return

	if _has_line_of_sight(target):
		_no_los_time = 0.0
	else:
		_no_los_time += delta
		if _no_los_time >= _los_grace:
			_set_target(null)


func _set_target(t: Node3D) -> void:
	target = t
	_no_los_time = 0.0
	target_changed.emit(t)


func _is_alive(n: Node) -> bool:
	if n.has_method("is_alive"):
		return bool(n.call("is_alive"))
	return true


func _best_candidate(exclude: Node3D, direction := 0.0) -> Node3D:
	var best: Node3D = null
	var best_score := -INF
	var cam := _owner.get_viewport().get_camera_3d()
	if cam == null:
		return null

	for node in _owner.get_tree().get_nodes_in_group("enemies"):
		var e := node as Node3D
		if e == null or e == exclude or not _is_alive(e):
			continue
		var to := e.global_position - _owner.global_position
		var dist := to.length()
		if dist > _engage_range or not _has_line_of_sight(e):
			continue

		# Prefere o que esta mais ao centro do ecra, e depois o mais perto.
		var screen_dir := (e.global_position - cam.global_position).normalized()
		var centredness := screen_dir.dot(-cam.global_transform.basis.z)
		if centredness <= 0.0:
			continue
		var score := centredness * 2.0 - dist / _engage_range

		if direction != 0.0:
			# A trocar de alvo: so conta quem esta do lado para onde o rato foi.
			var side := cam.global_transform.basis.x.dot(to.normalized())
			if signf(side) != signf(direction):
				continue
			score += absf(side)

		if score > best_score:
			best_score = score
			best = e

	return best


func _has_line_of_sight(t: Node3D) -> bool:
	var space := _owner.get_world_3d().direct_space_state
	var from := _owner.global_position + Vector3.UP * 1.2
	var to := t.global_position + Vector3.UP * 1.0
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 1   # so o cenario bloqueia a vista
	query.exclude = [_owner.get_rid()]
	return space.intersect_ray(query).is_empty()
