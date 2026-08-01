extends SceneTree
## Prova reproduzível dos 19 recursos 3D KayKit escolhidos para o bestiário.
## Corre com `godot --headless --path game/ --script res://src/enemies/enemy_asset_probe.gd`.

const ASSET_ROOT := "res://assets/models/enemies/kaykit-skeletons/"
const MODEL_PATHS := [
	"animations/Rig_Medium_General.glb",
	"animations/Rig_Medium_MovementBasic.glb",
	"characters/Skeleton_Mage.glb",
	"characters/Skeleton_Minion.glb",
	"characters/Skeleton_Rogue.glb",
	"characters/Skeleton_Warrior.glb",
	"props/Skeleton_Arrow.gltf",
	"props/Skeleton_Arrow_Broken.gltf",
	"props/Skeleton_Arrow_Broken_Half.gltf",
	"props/Skeleton_Arrow_Half.gltf",
	"props/Skeleton_Axe.gltf",
	"props/Skeleton_Blade.gltf",
	"props/Skeleton_Crossbow.gltf",
	"props/Skeleton_Quiver.gltf",
	"props/Skeleton_Shield_Large_A.gltf",
	"props/Skeleton_Shield_Large_B.gltf",
	"props/Skeleton_Shield_Small_A.gltf",
	"props/Skeleton_Shield_Small_B.gltf",
	"props/Skeleton_Staff.gltf",
]


func _initialize() -> void:
	var failures: Array[String] = []
	var animation_names: Dictionary = {}
	for relative_path: String in MODEL_PATHS:
		var path := ASSET_ROOT + relative_path
		var scene := load(path) as PackedScene
		if scene == null:
			failures.append(path)
			continue
		var root := scene.instantiate()
		var player := _find_animation_player(root)
		if player != null:
			animation_names[relative_path] = Array(player.get_animation_list())
		root.free()
	print("[enemy-assets] %d/%d modelos KayKit carregados" % [
		MODEL_PATHS.size() - failures.size(), MODEL_PATHS.size()])
	for path: String in animation_names:
		print("[enemy-assets] %s: %s" % [path, animation_names[path]])
	if not failures.is_empty():
		for path: String in failures:
			push_error("[enemy-assets] falhou: %s" % path)
		quit(1)
		return
	quit()


func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child: Node in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null
