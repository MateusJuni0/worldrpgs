extends SceneTree
## Inventário reproduzível dos rigs que podem receber armadura. Não altera assets.

const MODEL_PATHS := [
	"res://assets/models/characters/kaykit-adventurers/Knight.glb",
	"res://assets/models/characters/kaykit-adventurers/Ranger.glb",
	"res://assets/models/characters/kaykit-adventurers/Mage.glb",
	"res://assets/models/characters/kaykit-adventurers/Rogue.glb",
	"res://assets/models/characters/kaykit-adventurers/Rogue_Hooded.glb",
	"res://assets/models/characters/kaykit-adventurers/Barbarian.glb",
	"res://assets/models/characters/quaternius/Superhero_Male_FullBody.gltf",
	"res://assets/models/characters/quaternius/Superhero_Female_FullBody.gltf",
]


func _init() -> void:
	for model_path: String in MODEL_PATHS:
		_probe(model_path)
	quit()


func _probe(model_path: String) -> void:
	var packed := load(model_path) as PackedScene
	if packed == null:
		print("ARMOR_ASSET missing %s" % model_path)
		return
	var root := packed.instantiate()
	var skeletons := root.find_children("*", "Skeleton3D", true, false)
	var meshes := root.find_children("*", "MeshInstance3D", true, false)
	var surfaces := 0
	var mesh_names: Array[String] = []
	for mesh_node: Node in meshes:
		var mesh_instance := mesh_node as MeshInstance3D
		mesh_names.append("%s[%s]" % [mesh_instance.name, mesh_instance.get_aabb().size])
		if mesh_instance.mesh != null:
			surfaces += mesh_instance.mesh.get_surface_count()
	var bone_names: Array[String] = []
	if not skeletons.is_empty():
		var skeleton := skeletons[0] as Skeleton3D
		for bone_index: int in skeleton.get_bone_count():
			bone_names.append(skeleton.get_bone_name(bone_index))
	print("ARMOR_ASSET %s skeletons=%d meshes=%d surfaces=%d mesh_parts=%s bones=%s" % [
		model_path.get_file(), skeletons.size(), meshes.size(), surfaces,
		",".join(mesh_names), ",".join(bone_names)])
	root.free()
