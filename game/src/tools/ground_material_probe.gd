extends SceneTree
## Sonda read-only para auditar as seis familias de detalhe do chao.
##
## Uso:
##   godot --headless --path . --script res://src/tools/ground_material_probe.gd
##
## Imprime um JSON por superficie com o modo de transparencia e o custo da
## malha. Serve para separar uma hipotese de alpha/overdraw de custo geometrico
## antes de alterar materiais ou aparencia.

const ASSETS := {
	"erva": "res://assets/models/environment/brumal/details/grass_leafs.glb",
	"arbusto": "res://assets/models/environment/brumal/details/plant_bushSmall.glb",
	"cogumelo": "res://assets/models/environment/brumal/details/mushroom_redGroup.glb",
	"tronco": "res://assets/models/environment/brumal/details/log_large.glb",
	"seixo": "res://assets/models/environment/brumal/details/stone_smallFlatA.glb",
	"flor": "res://assets/models/environment/brumal/details/flower_yellowB.glb",
}


func _initialize() -> void:
	for family: String in ASSETS:
		_probe_scene(family, String(ASSETS[family]))
	quit()


func _probe_scene(family: String, path: String) -> void:
	var packed := load(path) as PackedScene
	if packed == null:
		printerr("[GROUND_MATERIAL] nao carregou %s" % path)
		return
	var root := packed.instantiate()
	_probe_node(family, path, root)
	root.free()


func _probe_node(family: String, path: String, node: Node) -> void:
	if node is MeshInstance3D:
		var instance := node as MeshInstance3D
		if instance.mesh != null:
			for surface: int in instance.mesh.get_surface_count():
				var material := instance.material_override
				if material == null:
					material = instance.mesh.surface_get_material(surface)
				var result := {
					"family": family,
					"path": path,
					"node": String(instance.name),
					"surface": surface,
					"vertices": instance.mesh.surface_get_array_len(surface),
					"indices": instance.mesh.surface_get_array_index_len(surface),
					"aabb": str(instance.mesh.get_aabb()),
					"material_class": material.get_class() if material != null else "null",
				}
				if material is BaseMaterial3D:
					var base := material as BaseMaterial3D
					result.merge({
						"transparency": int(base.transparency),
						"albedo_alpha": base.albedo_color.a,
						"has_albedo_texture": base.albedo_texture != null,
						"alpha_scissor_threshold": base.alpha_scissor_threshold,
						"cull_mode": int(base.cull_mode),
						"depth_draw_mode": int(base.depth_draw_mode),
						"shading_mode": int(base.shading_mode),
					})
				print("GROUND_MATERIAL_JSON " + JSON.stringify(result))
	for child: Node in node.get_children():
		_probe_node(family, path, child)
