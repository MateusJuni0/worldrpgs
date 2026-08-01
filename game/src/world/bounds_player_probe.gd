class_name BoundsPlayerProbe
extends Node3D
## Prova opt-in com a fisica real. O Player criado aqui nao esta ligado ao main,
## portanto morrer nao escreve save nem interfere com a mancha de almas.

var _player: Player
var _elapsed := 0.0
var _deadline := 0.0


func setup(palette: Dictionary, bounds: Dictionary, cell: float,
		step_height: float) -> void:
	var fall: Dictionary = GameData.progression.get("fall", {}) as Dictionary
	var fatal_height := float(fall.get("fatal_min_m"))
	var gravity := float(ProjectSettings.get_setting("physics/3d/default_gravity"))
	_deadline = sqrt(2.0 * fatal_height / gravity) \
		+ 4.0 / float(Engine.physics_ticks_per_second)

	_player = Player.new()
	_player.name = "FallPhysicsProbe"
	add_child(_player)
	_player.input_enabled = false
	_player.setup("warrior", palette)
	_player.global_position = Vector3(
		float(bounds.get("min_x")) + float(bounds.get("size_x")) * 0.5,
		step_height,
		float(bounds.get("min_z")) + float(bounds.get("size_z")) + cell)
	_player.died.connect(_on_player_died)


func _physics_process(delta: float) -> void:
	_elapsed += delta
	if _elapsed <= _deadline:
		return
	push_error("QUEDA: probe fisico nao morreu em %.3f s" % _deadline)
	get_tree().quit(1)


func _on_player_died() -> void:
	print("QUEDA_FISICA: Player.died em %.3f s (limite %.3f s)" % [
		_elapsed, _deadline])
	get_tree().quit(0)
