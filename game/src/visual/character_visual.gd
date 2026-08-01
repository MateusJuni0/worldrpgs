class_name CharacterVisual
extends Node3D
## Corpo Quaternius ou silhueta de classe KayKit sobre a capsula de fisica.
##
## Os dois corpos base partilham o esqueleto UAL de 65 ossos. Os fatos KayKit
## sao personagens completos com o seu rig comum de 23 ossos; o pack so traz
## clips gerais e de locomocao, por isso os verbos em falta usam equivalentes
## visuais ate existir uma biblioteca KayKit completa.

const BODY_PATHS := {
	"body_male": "res://assets/models/characters/quaternius/Superhero_Male_FullBody.gltf",
	"body_female": "res://assets/models/characters/quaternius/Superhero_Female_FullBody.gltf",
}
const BODY_SOURCE_HEIGHTS := {
	"body_male": 1.819586,
	"body_female": 1.775051,
}

# [CODEX] Uma silhueta distinta por origem. Razao: a classe tem de se ler antes
# do detalhe. Alternativa descartada: repetir Knight no guerreiro, tanque e
# paladino; poupava seleccao, mas os tornava iguais a distancia.
const CLASS_PATHS := {
	"warrior": "res://assets/models/characters/kaykit-adventurers/Ranger.glb",
	"sorcerer": "res://assets/models/characters/kaykit-adventurers/Mage.glb",
	"tank": "res://assets/models/characters/kaykit-adventurers/Knight.glb",
	"assassin": "res://assets/models/characters/kaykit-adventurers/Rogue_Hooded.glb",
	"berserker": "res://assets/models/characters/kaykit-adventurers/Barbarian.glb",
	"paladin": "res://assets/models/characters/kaykit-adventurers/Rogue.glb",
}
const CLASS_SOURCE_HEIGHTS := {
	"warrior": 2.274951,
	"sorcerer": 2.654696,
	"tank": 2.543104,
	"assassin": 2.172992,
	"berserker": 2.397775,
	"paladin": 2.180353,
}
const CLASS_TINTS := {
	"warrior": Color("d9b46f"),
	"sorcerer": Color("829de0"),
	"tank": Color("aeb8c5"),
	"assassin": Color("71907c"),
	"berserker": Color("c87562"),
	"paladin": Color("e2c66f"),
}
const CLASS_PROPS := {
	"paladin": {
		"path": "res://assets/models/characters/kaykit-adventurers/shield_badge_color.gltf",
		"bone": "handslot.l",
	},
}

const QUATERNIUS_ANIMATION_PATH := "res://assets/models/animations/quaternius/UAL1_Standard.glb"
const KAYKIT_ANIMATION_PATHS := [
	"res://assets/models/characters/kaykit-adventurers/Rig_Medium_General.glb",
	"res://assets/models/characters/kaykit-adventurers/Rig_Medium_MovementBasic.glb",
]
const KAYKIT_ANIMATION_ALIASES := {
	"Idle": "Idle_A",
	"Sword_Idle": "Idle_B",
	"Walk": "Walking_A",
	"Jog_Fwd": "Running_A",
	"Sprint": "Running_B",
	"Death01": "Death_A",
	"Hit_Chest": "Hit_A",
	"Interact": "Interact",
	"Sitting_Idle": "Idle_B",
	"Roll": "Jump_Full_Short",
	"Sword_Attack": "Throw",
	"Spell_Simple_Shoot": "Use_Item",
}

# Um unico ShaderMaterial por material-fonte; actor_tint e class_tint sao
# uniforms de instancia. Assim seis cores nao criam seis materiais por actor.
const CHARACTER_SHADER_SOURCE := """
shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec4 material_albedo : source_color = vec4(1.0);
uniform sampler2D albedo_texture : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform bool use_albedo_texture = false;
uniform float material_roughness = 1.0;
uniform sampler2D roughness_texture : hint_default_white, filter_linear_mipmap_anisotropic, repeat_enable;
uniform bool use_roughness_texture = false;
uniform sampler2D normal_texture : hint_normal, filter_linear_mipmap_anisotropic, repeat_enable;
uniform bool use_normal_texture = false;
uniform float normal_scale = 1.0;
instance uniform vec4 actor_tint : source_color = vec4(1.0);
instance uniform vec4 class_tint : source_color = vec4(1.0);

void fragment() {
	vec3 base_colour = material_albedo.rgb;
	if (use_albedo_texture) {
		base_colour *= texture(albedo_texture, UV).rgb;
	}
	ALBEDO = base_colour * actor_tint.rgb * mix(vec3(1.0), class_tint.rgb, 0.35);
	ROUGHNESS = material_roughness;
	if (use_roughness_texture) {
		ROUGHNESS *= texture(roughness_texture, UV).r;
	}
	if (use_normal_texture) {
		NORMAL_MAP = texture(normal_texture, UV).rgb;
		NORMAL_MAP_DEPTH = normal_scale;
	}
}
"""

static var _quaternius_library: AnimationLibrary
static var _kaykit_library: AnimationLibrary
static var _quaternius_library_configured := false
static var _shared_shader: Shader
static var _shared_materials: Dictionary = {}

var _animation_player: AnimationPlayer
var _meshes: Array[MeshInstance3D] = []
var _current_animation := ""
var _current_tint := Color(-1.0, -1.0, -1.0, -1.0)


func setup(target_height: float, tint := Color.WHITE, casts_shadow := true,
		body_id := "body_male", class_id := "") -> void:
	name = "CharacterVisual"
	# Player ja conhece a origem antes de construir o visual. Esta leitura deixa
	# o chamador actual vestido sem tocar em player.gd, que pertence a outro agente.
	if class_id.is_empty():
		class_id = _parent_class_id()
	var uses_class_outfit := CLASS_PATHS.has(class_id)
	var model_path := String(CLASS_PATHS.get(class_id, BODY_PATHS.get(
		body_id, BODY_PATHS["body_male"])))
	var source_height := float(CLASS_SOURCE_HEIGHTS.get(class_id, BODY_SOURCE_HEIGHTS.get(
		body_id, BODY_SOURCE_HEIGHTS["body_male"])))
	var body_scene := load(model_path) as PackedScene
	if body_scene == null:
		push_error("[CharacterVisual] Modelo desconhecido: %s / %s" % [body_id, class_id])
		return
	var body := body_scene.instantiate()
	body.name = "Body"
	# Ambos os packs chegam a olhar para +Z; o combate usa -Z como frente.
	body.rotation.y = PI
	add_child(body)
	scale = Vector3.ONE * (target_height / source_height)
	if uses_class_outfit:
		_attach_class_prop(body, class_id)
	var class_tint: Color = CLASS_TINTS.get(class_id, Color.WHITE)
	_collect_meshes(body, casts_shadow, class_tint)
	_build_animation_player(uses_class_outfit)
	set_tint(tint)
	play_animation("Idle")


func set_tint(tint: Color) -> void:
	# Uniform de instancia: muda estado/cor sem duplicar nem reescrever materiais.
	if tint.is_equal_approx(_current_tint):
		return
	_current_tint = tint
	for mesh_instance: MeshInstance3D in _meshes:
		mesh_instance.set_instance_shader_parameter("actor_tint", tint)


func play_animation(animation_name: String, speed := 1.0) -> void:
	if _animation_player == null:
		return
	if not _animation_player.has_animation(animation_name):
		animation_name = "Idle"
	if _current_animation == animation_name and _animation_player.is_playing():
		return
	_current_animation = animation_name
	_animation_player.play(animation_name, 0.12, speed)


func _parent_class_id() -> String:
	var parent := get_parent()
	if parent == null:
		return ""
	for property: Dictionary in parent.get_property_list():
		if String(property.get("name", "")) == "class_id":
			return String(parent.get("class_id"))
	return ""


func _collect_meshes(node: Node, casts_shadow: bool, class_tint: Color) -> void:
	for descendant: Node in node.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := descendant as MeshInstance3D
		_meshes.append(mesh_instance)
		mesh_instance.set_instance_shader_parameter("class_tint", class_tint)
		if not casts_shadow:
			mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for surface: int in mesh_instance.mesh.get_surface_count():
			var source := mesh_instance.mesh.surface_get_material(surface) as StandardMaterial3D
			if source != null:
				mesh_instance.set_surface_override_material(surface, _shared_material_for(source))


func _attach_class_prop(body: Node, class_id: String) -> void:
	if not CLASS_PROPS.has(class_id):
		return
	var config: Dictionary = CLASS_PROPS[class_id]
	var prop_scene := load(String(config["path"])) as PackedScene
	var skeleton := _find_skeleton(body)
	if prop_scene == null or skeleton == null:
		push_warning("[CharacterVisual] Acessorio de %s nao encontrou modelo/rig" % class_id)
		return
	var attachment := BoneAttachment3D.new()
	attachment.name = "ClassProp"
	attachment.bone_name = String(config["bone"])
	skeleton.add_child(attachment)
	attachment.add_child(prop_scene.instantiate())


static func _shared_material_for(source: StandardMaterial3D) -> ShaderMaterial:
	var key := source.get_instance_id()
	if _shared_materials.has(key):
		return _shared_materials[key] as ShaderMaterial
	if _shared_shader == null:
		_shared_shader = Shader.new()
		_shared_shader.code = CHARACTER_SHADER_SOURCE
	var material := ShaderMaterial.new()
	material.shader = _shared_shader
	material.set_shader_parameter("material_albedo", source.albedo_color)
	material.set_shader_parameter("material_roughness", source.roughness)
	if source.albedo_texture != null:
		material.set_shader_parameter("albedo_texture", source.albedo_texture)
		material.set_shader_parameter("use_albedo_texture", true)
	if source.roughness_texture != null:
		material.set_shader_parameter("roughness_texture", source.roughness_texture)
		material.set_shader_parameter("use_roughness_texture", true)
	if source.normal_enabled and source.normal_texture != null:
		material.set_shader_parameter("normal_texture", source.normal_texture)
		material.set_shader_parameter("use_normal_texture", true)
		material.set_shader_parameter("normal_scale", source.normal_scale)
	_shared_materials[key] = material
	return material


func _build_animation_player(uses_kaykit: bool) -> void:
	var library := _kaykit_animation_library() if uses_kaykit else _quaternius_animation_library()
	_animation_player = AnimationPlayer.new()
	_animation_player.name = "AnimationPlayer"
	_animation_player.root_node = NodePath("../Body")
	add_child(_animation_player)
	if library != null:
		_animation_player.add_animation_library("", library)


static func _quaternius_animation_library() -> AnimationLibrary:
	if _quaternius_library != null:
		return _quaternius_library
	var source_scene := load(QUATERNIUS_ANIMATION_PATH) as PackedScene
	if source_scene == null:
		return null
	var source_root := source_scene.instantiate()
	var source_player := _find_animation_player(source_root)
	if source_player != null and source_player.has_animation_library(""):
		_quaternius_library = source_player.get_animation_library("")
	source_root.free()
	if _quaternius_library == null or _quaternius_library_configured:
		return _quaternius_library
	for looping: String in [
		"Idle", "Sword_Idle", "Walk", "Jog_Fwd", "Sprint", "Crouch_Idle",
		"Crouch_Fwd", "Spell_Simple_Idle", "Sitting_Idle",
	]:
		if _quaternius_library.has_animation(looping):
			_quaternius_library.get_animation(looping).loop_mode = Animation.LOOP_LINEAR
	_quaternius_library_configured = true
	return _quaternius_library


static func _kaykit_animation_library() -> AnimationLibrary:
	if _kaykit_library != null:
		return _kaykit_library
	var sources := {}
	for path: String in KAYKIT_ANIMATION_PATHS:
		var source_scene := load(path) as PackedScene
		if source_scene == null:
			continue
		var source_root := source_scene.instantiate()
		var source_player := _find_animation_player(source_root)
		if source_player != null and source_player.has_animation_library(""):
			var source_library := source_player.get_animation_library("")
			for animation_name: StringName in source_library.get_animation_list():
				sources[String(animation_name)] = source_library.get_animation(animation_name)
		source_root.free()
	_kaykit_library = AnimationLibrary.new()
	for semantic_name: String in KAYKIT_ANIMATION_ALIASES:
		var source_name := String(KAYKIT_ANIMATION_ALIASES[semantic_name])
		if sources.has(source_name):
			_kaykit_library.add_animation(semantic_name, sources[source_name])
	for looping: String in ["Idle", "Sword_Idle", "Walk", "Jog_Fwd", "Sprint", "Sitting_Idle"]:
		if _kaykit_library.has_animation(looping):
			_kaykit_library.get_animation(looping).loop_mode = Animation.LOOP_LINEAR
	return _kaykit_library


static func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child: Node in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null


static func _find_skeleton(node: Node) -> Skeleton3D:
	if node is Skeleton3D:
		return node as Skeleton3D
	for child: Node in node.get_children():
		var found := _find_skeleton(child)
		if found != null:
			return found
	return null
