extends SceneTree
## Execução dirigida: godot --headless --path game --script res://src/npc/vendor_test_runner.gd

const Contract = preload("res://src/npc/vendor_self_test.gd")


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	await process_frame
	var game_data := root.get_node_or_null("GameData")
	var save_system := root.get_node_or_null("SaveSystem")
	if game_data == null or save_system == null:
		printerr("[VendorSelfTest] autoloads GameData/SaveSystem em falta")
		quit(1)
		return
	var result: Dictionary = Contract.new().run(game_data, save_system)
	for message: String in result.get("errors", []):
		printerr("[VendorSelfTest] FALHOU: %s" % message)
	print("[VendorSelfTest] %d passaram, %d falharam" % [
		int(result.get("passed", 0)), int(result.get("failed", 0))])
	quit(0 if bool(result.get("ok", false)) else 1)
