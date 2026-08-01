class_name PhotoTour
extends Node
## Photo mode: fly through canonical viewpoints, save PNGs, quit.
## Usage: godot --path . --rendering-method mobile -- --scene=zone --photos
## Output goes to captures/ (gitignored) — these are the improvement loop's eyes.

var _cam: Camera3D
var _main: Node3D


func run(main: Node3D) -> void:
	_main = main
	_cam = Camera3D.new()
	_cam.fov = 65.0
	add_child(_cam)
	_cam.make_current()
	_shoot_all.call_deferred()


func _shoot_all() -> void:
	await _wait(40)  # warmup: shader compilation, fog settling
	# ⚠️ 01-08: 40 frames chegavam para o greybox mas nao chegam para instanciar os
	# modelos .glb da fatia 1 — o mundo ainda era nulo, o tour morria EM SILENCIO, e
	# ficavam capturas velhas no disco a fingir que eram novas. Espera pelo mundo.
	var world = _main.world
	var esperou := 0
	while (world == null or not ("path_points" in world)) and esperou < 600:
		await _wait(10)
		world = _main.world
		esperou += 10
	if world == null or not ("path_points" in world):
		push_error("[photo] mundo nao ficou pronto em %d frames — SEM capturas novas" % (40 + esperou))
		_main.get_tree().quit(1)
		return
	var shots: Array = []
	if Bench.scene_arg == "combat":
		shots = [
			["arena-geral", world.arena_center + Vector3(0, 9, 16), world.arena_center],
			["arena-rasante", world.arena_center + Vector3(6, 1.6, 8), world.arena_center + Vector3(0, 1, 0)],
		]
	else:
		var mid: Vector3 = Vector3.ZERO
		if world.path_points.size() > 0:
			mid = world.path_points[world.path_points.size() / 2]
		shots = [
			["01-spawn-3a-pessoa", world.spawn_point + Vector3(0, 2.2, 4.5), world.spawn_point + Vector3(0, 1.2, -2)],
			["02-floresta-caminho", mid + Vector3(2, 1.7, 6), mid + Vector3(0, 1, -4)],
			["03-floresta-alto", mid + Vector3(0, 14, 18), mid],
			["04-entrada-toca", world.lair_entrance + Vector3(4, 2.0, 7), world.lair_entrance + Vector3(0, 0.5, 0)],
			["05-arena-vorgar", world.arena_center + Vector3(0, 8, 14), world.arena_center + Vector3(0, 1, 0)],
			["06-arena-rasante", world.arena_center + Vector3(5, 1.6, 7), world.arena_center + Vector3(0, 1.5, 0)],
		]
	var dir := ProjectSettings.globalize_path("res://captures/")
	DirAccess.make_dir_recursive_absolute(dir)
	for s in shots:
		_cam.look_at_from_position(s[1], s[2])
		await _wait(10)
		var img := get_viewport().get_texture().get_image()
		img.save_png(dir + String(s[0]) + ".png")
		print("[photo] ", s[0])
	print("[photo] done: ", shots.size(), " captures")
	get_tree().quit()


func _wait(frames: int) -> void:
	for _i in frames:
		await get_tree().process_frame
