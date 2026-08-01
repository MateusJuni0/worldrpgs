extends SceneTree
## Compila todas as assinaturas sonoras do catálogo sem precisar de altifalantes.
## Falha se algum ataque não produzir um AudioStreamWAV próprio.

const EnemyAttackAudio = preload("res://src/enemies/enemy_attack_audio.gd")

var _frames := 0


func _process(_delta: float) -> bool:
	_frames += 1
	if _frames <= 1:
		return false
	var game_data := root.get_node("GameData")
	var enemies: Dictionary = game_data.get("enemies") as Dictionary
	var presentation: Dictionary = enemies.get("_presentation", {}) as Dictionary
	var expected := 0
	for enemy_id: String in enemies.keys():
		if enemy_id.begins_with("_"):
			continue
		var enemy_data: Dictionary = game_data.call("enemy", enemy_id) as Dictionary
		var audio := EnemyAttackAudio.new()
		root.add_child(audio)
		audio.call("setup", enemy_id, String(enemy_data.get("race_id", "")), presentation)
		for attack_value: Variant in enemy_data.get("attacks", []):
			expected += 1
			audio.call("announce", attack_value as Dictionary)
		audio.free()
	var actual := EnemyAttackAudio.cached_signature_count()
	print("[enemy-audio] %d/%d ataques com assinatura sintetizada" % [actual, expected])
	if actual != expected:
		push_error("[enemy-audio] catálogo incompleto: %d de %d" % [actual, expected])
		quit(1)
		return false
	quit()
	return false
