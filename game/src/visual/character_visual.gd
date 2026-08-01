class_name CharacterVisual
extends Node3D
## Corpo visual Quaternius sobre a capsula de fisica.
##
## A malha e a animacao partilham exactamente o mesmo esqueleto de 65 ossos.
## O GLB de animacao e a variante sem root motion: deslocar o actor continua a
## ser responsabilidade do CharacterBody3D e dos numeros de combate.

const BODY_PATHS := {
	"body_male": "res://assets/models/characters/quaternius/Superhero_Male_FullBody.gltf",
	"body_female": "res://assets/models/characters/quaternius/Superhero_Female_FullBody.gltf",
}
const ANIMATION_PATH := "res://assets/models/animations/quaternius/UAL1_Standard.glb"
const SOURCE_HEIGHT := 1.819586

static var _shared_library: AnimationLibrary
static var _library_configured := false

var _animation_player: AnimationPlayer
var _materials: Array[StandardMaterial3D] = []
var _base_colours: Array[Color] = []
var _current_animation := ""
var _current_tint := Color(-1.0, -1.0, -1.0, -1.0)


func setup(target_height: float, tint := Color.WHITE, casts_shadow := true,
		body_id := "body_male") -> void:
	name = "CharacterVisual"
	var body_scene := load(String(BODY_PATHS.get(body_id, BODY_PATHS["body_male"]))) as PackedScene
	if body_scene == null:
		push_error("[CharacterVisual] Corpo desconhecido: %s" % body_id)
		return
	var body := body_scene.instantiate()
	body.name = "Body"
	# Os ficheiros Godot/UE chegam a olhar para +Z; o combate do projecto usa
	# -Z como frente (a antiga capsula tinha o bico nesse eixo).
	body.rotation.y = PI
	add_child(body)
	scale = Vector3.ONE * (target_height / SOURCE_HEIGHT)
	_collect_materials(body, casts_shadow)
	_build_animation_player(body)
	set_tint(tint)
	play_animation("Idle")


func set_tint(tint: Color) -> void:
	# A cor comunica estado e muda poucas vezes por ataque. Reescrever todos os
	# materiais a cada physics frame forçava uploads sem alterar um pixel e fazia
	# o p99 crescer com o quinto actor.
	if tint.is_equal_approx(_current_tint):
		return
	_current_tint = tint
	for index: int in _materials.size():
		_materials[index].albedo_color = _base_colours[index] * tint


func play_animation(animation_name: String, speed := 1.0) -> void:
	if _animation_player == null:
		return
	if not _animation_player.has_animation(animation_name):
		animation_name = "Idle"
	if _current_animation == animation_name and _animation_player.is_playing():
		return
	_current_animation = animation_name
	_animation_player.play(animation_name, 0.12, speed)


func _collect_materials(node: Node, casts_shadow: bool) -> void:
	for descendant: Node in node.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance := descendant as MeshInstance3D
		if not casts_shadow:
			# Três inimigos repetiriam toda a pele deformada no passe de sombra.
			# O jogador conserva a possibilidade de sombra nos presets que a
			# permitem; a bruma absorve a ausência nos adversários.
			mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		for surface: int in mesh_instance.mesh.get_surface_count():
			var source := mesh_instance.mesh.surface_get_material(surface) as StandardMaterial3D
			if source == null:
				continue
			var material := source.duplicate() as StandardMaterial3D
			# O pack traz mapa de rugosidade para o corpo. Mantemo-lo; o override
			# existe apenas para permitir a leitura de estados por actor.
			mesh_instance.set_surface_override_material(surface, material)
			_materials.append(material)
			_base_colours.append(material.albedo_color)


func _build_animation_player(body: Node) -> void:
	_ensure_shared_library()
	_animation_player = AnimationPlayer.new()
	_animation_player.name = "AnimationPlayer"
	_animation_player.root_node = NodePath("../Body")
	add_child(_animation_player)
	if _shared_library != null:
		_animation_player.add_animation_library("", _shared_library)


static func _ensure_shared_library() -> void:
	if _shared_library != null:
		return
	# Carregamento pontual: guardar o PackedScene como constante manteria tambem
	# a malha e as texturas do manequim UAL em VRAM. So retemos as animacoes.
	var source_scene := load(ANIMATION_PATH) as PackedScene
	if source_scene == null:
		return
	var source_root := source_scene.instantiate()
	var source_player := _find_animation_player(source_root)
	if source_player != null and source_player.has_animation_library(""):
		_shared_library = source_player.get_animation_library("")
	source_root.free()
	if _shared_library == null or _library_configured:
		return
	for looping: String in [
		"Idle", "Sword_Idle", "Walk", "Jog_Fwd", "Sprint", "Crouch_Idle",
		"Crouch_Fwd", "Spell_Simple_Idle", "Sitting_Idle",
	]:
		if _shared_library.has_animation(looping):
			_shared_library.get_animation(looping).loop_mode = Animation.LOOP_LINEAR
	_library_configured = true


static func _find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node as AnimationPlayer
	for child: Node in node.get_children():
		var found := _find_animation_player(child)
		if found != null:
			return found
	return null
