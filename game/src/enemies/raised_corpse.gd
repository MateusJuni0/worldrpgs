class_name RaisedCorpse
extends Node3D
## Registo visível de um inimigo morto diante do necromante. O modelo tombado
## continua a ser o do próprio inimigo; este nó só lhe dá identidade e posse.

var corpse_id := ""
var enemy_id := ""
var body_size := ""
var is_boss := false
var caster_owner_id := &""
var simulation_authority_id := &""
var source_body: Node3D
var source_visual: Node3D
var _claimed := false


func setup_from_enemy(defeated: Node3D, stable_corpse_id: String = "") -> void:
	source_body = defeated
	source_visual = defeated.get("_visual") as Node3D
	corpse_id = stable_corpse_id if not stable_corpse_id.is_empty() else \
		"%s:%s" % [String(defeated.get("enemy_id")),
			str(defeated.get_instance_id())]
	enemy_id = String(defeated.get("enemy_id"))
	is_boss = bool(defeated.get("is_boss"))
	var enemy_data := defeated.get("data") as Dictionary
	body_size = String(enemy_data.get("necromancy_body_size", ""))
	global_position = defeated.global_position
	add_to_group("necromancy_corpses")


func is_visible_corpse() -> bool:
	return is_instance_valid(source_body) and is_instance_valid(source_visual) \
		and source_body.is_visible_in_tree() and source_visual.is_visible_in_tree()


func is_available() -> bool:
	return not _claimed and is_visible_corpse()


func try_claim(owner_id: StringName, authority_id: StringName) -> bool:
	if not is_available():
		return false
	_claimed = true
	caster_owner_id = owner_id
	simulation_authority_id = authority_id
	return true


func release_claim() -> void:
	_claimed = false
	caster_owner_id = &""
	simulation_authority_id = &""


func take_source_visual(next_parent: Node3D) -> Node3D:
	if not is_instance_valid(next_parent) or not is_instance_valid(source_body) \
			or not is_instance_valid(source_visual):
		return null
	# Transferir o próprio nó preserva modelo, escala, arma, materiais e variante.
	# Recriá-lo a partir do enemy_id foi precisamente o que trocou a skin.
	# O novo corpo físico herda também a orientação da morte; conservar depois o
	# transform local mantém arte e hitbox viradas para o mesmo lado ao atacar.
	next_parent.global_rotation = source_body.global_rotation
	source_visual.reparent(next_parent, false)
	return source_visual


func consume() -> void:
	if is_instance_valid(source_body):
		source_body.queue_free()
		source_body = null
	source_visual = null
	queue_free()
