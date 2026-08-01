class_name GameShell
extends Node
## Casca navegavel do jogo: menu principal, criacao e transicao para o mundo.
## A cena 3D so nasce depois de um save valido, por isso arrancar nunca larga o
## jogador no greybox e os menus nao pagam o custo do mundo em segundo plano.

const GAMEPLAY_SCENE: PackedScene = preload("res://scenes/gameplay.tscn")
const CLASS_IDS: Array[String] = [
	"warrior", "sorcerer", "tank", "assassin", "berserker", "paladin",
]
const STEP_TITLES: Array[String] = ["1  Classe", "2  Aspecto", "3  Nome", "4  Rever"]
const SKIN_TINTS := {
	"skin_01": Color("9a6048"),
	"skin_02": Color("c88768"),
	"skin_03": Color("e1ad86"),
	"skin_04": Color("f0c9aa"),
}
const CLASS_ROLES := {
	"warrior": ["Equilibrado — a régua dos outros.", "Adapta-se a qualquer abertura.", "Nunca é o especialista da situação."],
	"sorcerer": ["Precisão azul, controlo e maior reserva de mana.", "Lê a distância e escolhe a forma certa.", "Sofre quando fica encostado."],
	"tank": ["Absorve, controla espaço e protege a dupla.", "Segura a atenção e mede o bloqueio.", "Mata devagar e sente o peso."],
	"assassin": ["Rápido, posicional e de parry arriscado.", "Conquista costas e encadeia golpes curtos.", "Sofre de frente contra armadura."],
	"berserker": ["Pressão bruta sem escudo.", "Troca segurança por avanço.", "Cada erro deixa uma recuperação longa."],
	"paladin": ["Ferro e magia de raio.", "Muda o tipo de resposta sem ganhar dano grátis.", "Divide os atributos no arranque."],
}

var _layer: CanvasLayer
var _screen: Control
var _gameplay: Node
var _theme: Theme
var _draft: Dictionary = {}
var _creation_step := 0
var _options_box: VBoxContainer
var _detail: RichTextLabel
var _footer_previous: Button
var _footer_next: Button
var _footer_create: Button
var _preview_viewport: SubViewport
var _preview_pivot: Node3D
var _preview_visual: CharacterVisual
var _preview_dragging := false
var _capture_screen := ""
var _capture_frames := 0


func _ready() -> void:
	_theme = _make_theme()
	_capture_screen = _argument_value("--capture-ui=")
	var measured_screen := Bench.scene_arg if Bench.is_benchmarking() else ""
	if measured_screen == "ui-main" or _capture_screen == "main":
		show_main_menu()
	elif measured_screen == "ui-creation" or _capture_screen == "creation":
		show_character_creation()
	elif Bench.is_benchmarking() or "--photos" in OS.get_cmdline_user_args():
		_start_gameplay()
	else:
		show_main_menu()
	set_process(_capture_screen != "")


func _process(_delta: float) -> void:
	if _capture_screen == "":
		return
	_capture_frames += 1
	if _capture_frames < 30:
		return
	var directory := ProjectSettings.globalize_path("res://captures")
	DirAccess.make_dir_recursive_absolute(directory)
	var path := "res://captures/%s.png" % _capture_screen
	# A criacao contem um SubViewport 3D; capturar explicitamente a janela raiz
	# evita que o ultimo viewport renderizado substitua a interface completa.
	var result := get_tree().root.get_texture().get_image().save_png(path)
	print("UI_CAPTURE %s %s" % [path, error_string(result)])
	get_tree().quit(0 if result == OK else 1)


func show_main_menu() -> void:
	_clear_gameplay()
	_begin_screen()
	_add_background(Color("071014"), Color("26313a"))

	var mist := Label.new()
	mist.text = "BRUMAL"
	mist.position = Vector2(1080, 92)
	mist.add_theme_font_size_override("font_size", 148)
	mist.add_theme_color_override("font_color", Color(0.58, 0.65, 0.68, 0.08))
	_screen.add_child(mist)

	var title := Label.new()
	title.text = "WORLDRPGS"
	title.position = Vector2(150, 160)
	title.add_theme_font_size_override("font_size", 76)
	title.add_theme_color_override("font_color", Color("e5d3aa"))
	_screen.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "A BRUMA CHEGOU.  ENTRA ONDE NINGUÉM ENTRA."
	subtitle.position = Vector2(156, 255)
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", Color("93a2a5"))
	_screen.add_child(subtitle)

	var rule := ColorRect.new()
	rule.color = Color("9a743d")
	rule.position = Vector2(156, 302)
	rule.size = Vector2(84, 2)
	_screen.add_child(rule)

	var menu := VBoxContainer.new()
	menu.position = Vector2(150, 380)
	menu.size = Vector2(430, 420)
	menu.add_theme_constant_override("separation", 12)
	_screen.add_child(menu)

	var continue_button := _menu_button("CONTINUAR", "Retomar no último ponto de descanso")
	continue_button.disabled = not _has_save()
	continue_button.pressed.connect(_continue_last_save)
	menu.add_child(continue_button)

	var new_button := _menu_button("NOVO JOGO", "Criar uma personagem")
	new_button.pressed.connect(show_character_creation)
	menu.add_child(new_button)

	var settings_button := _menu_button("CONFIGURAÇÕES", "Gráficos, controlos e áudio")
	settings_button.pressed.connect(_settings_placeholder)
	menu.add_child(settings_button)

	var quit_button := _menu_button("SAIR", "Fechar o jogo")
	quit_button.pressed.connect(get_tree().quit)
	menu.add_child(quit_button)

	var version := Label.new()
	version.text = "PROTÓTIPO DA FATIA 1  ·  %s" % ProjectSettings.get_setting(
		"application/config/version", "0.1.0")
	version.position = Vector2(151, 970)
	version.add_theme_font_size_override("font_size", 16)
	version.add_theme_color_override("font_color", Color("6f7b7d"))
	_screen.add_child(version)
	new_button.grab_focus()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func show_character_creation() -> void:
	_clear_gameplay()
	if _draft.is_empty():
		_draft = {
			"class_id": "warrior",
			"name": "",
			"appearance": (GameData.appearance.get("default", {}) as Dictionary).duplicate(true),
			"slot": _first_free_slot(),
		}
	_creation_step = clampi(_creation_step, 0, 3)
	_begin_screen()
	_add_background(Color("091116"), Color("1a2429"))

	var heading := Label.new()
	heading.text = "NOVO PERSONAGEM"
	heading.position = Vector2(48, 24)
	heading.add_theme_font_size_override("font_size", 30)
	heading.add_theme_color_override("font_color", Color("e5d3aa"))
	_screen.add_child(heading)

	var law := Label.new()
	law.text = "É SÓ O TEU COMEÇO.  PODES USAR QUALQUER ARMA, ARMADURA E MAGIA."
	law.position = Vector2(475, 32)
	law.add_theme_font_size_override("font_size", 18)
	law.add_theme_color_override("font_color", Color("d4b36f"))
	_screen.add_child(law)

	var access := Button.new()
	access.text = "ACESSIBILIDADE"
	access.position = Vector2(1660, 22)
	access.size = Vector2(220, 46)
	access.pressed.connect(_settings_placeholder)
	_screen.add_child(access)

	var left := _panel(Vector2(40, 92), Vector2(430, 870))
	var steps := VBoxContainer.new()
	steps.position = Vector2(22, 22)
	steps.size = Vector2(386, 210)
	steps.add_theme_constant_override("separation", 6)
	left.add_child(steps)
	for index: int in STEP_TITLES.size():
		var step_button := Button.new()
		step_button.text = STEP_TITLES[index]
		step_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		step_button.toggle_mode = true
		step_button.button_pressed = index == _creation_step
		step_button.pressed.connect(_set_creation_step.bind(index))
		steps.add_child(step_button)

	var separator := HSeparator.new()
	separator.position = Vector2(22, 240)
	separator.size = Vector2(386, 2)
	left.add_child(separator)
	_options_box = VBoxContainer.new()
	_options_box.position = Vector2(22, 262)
	_options_box.size = Vector2(386, 560)
	_options_box.add_theme_constant_override("separation", 8)
	left.add_child(_options_box)

	_build_preview(Vector2(490, 92), Vector2(760, 870))

	var right := _panel(Vector2(1270, 92), Vector2(610, 870))
	var detail_heading := Label.new()
	detail_heading.text = "O QUE ESTA ESCOLHA MUDA"
	detail_heading.position = Vector2(28, 26)
	detail_heading.add_theme_font_size_override("font_size", 18)
	detail_heading.add_theme_color_override("font_color", Color("d4b36f"))
	right.add_child(detail_heading)
	_detail = RichTextLabel.new()
	_detail.bbcode_enabled = true
	_detail.fit_content = false
	_detail.position = Vector2(28, 72)
	_detail.size = Vector2(554, 680)
	_detail.add_theme_font_size_override("normal_font_size", 20)
	_detail.add_theme_font_size_override("bold_font_size", 22)
	_detail.add_theme_color_override("default_color", Color("d7dddd"))
	right.add_child(_detail)

	var footer := HBoxContainer.new()
	footer.position = Vector2(28, 786)
	footer.size = Vector2(554, 60)
	footer.add_theme_constant_override("separation", 10)
	right.add_child(footer)
	var back := Button.new()
	back.text = "VOLTAR AO MENU"
	back.custom_minimum_size = Vector2(166, 54)
	back.pressed.connect(show_main_menu)
	footer.add_child(back)
	_footer_previous = Button.new()
	_footer_previous.text = "ANTERIOR"
	_footer_previous.custom_minimum_size = Vector2(112, 54)
	_footer_previous.pressed.connect(_previous_creation_step)
	footer.add_child(_footer_previous)
	_footer_next = Button.new()
	_footer_next.text = "SEGUINTE"
	_footer_next.custom_minimum_size = Vector2(112, 54)
	_footer_next.pressed.connect(_next_creation_step)
	footer.add_child(_footer_next)
	_footer_create = Button.new()
	_footer_create.text = "CRIAR"
	_footer_create.custom_minimum_size = Vector2(112, 54)
	_footer_create.pressed.connect(_create_character)
	footer.add_child(_footer_create)
	_refresh_creation_step()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _refresh_creation_step() -> void:
	if not is_instance_valid(_options_box):
		return
	for child: Node in _options_box.get_children():
		child.queue_free()
	match _creation_step:
		0: _build_class_options()
		1: _build_appearance_options()
		2: _build_name_options()
		3: _build_review()
	_footer_previous.disabled = _creation_step == 0
	_footer_next.visible = _creation_step < 3
	_footer_create.visible = _creation_step == 3
	if is_instance_valid(_preview_visual):
		_update_preview()


func _build_class_options() -> void:
	var selected := String(_draft.get("class_id", "warrior"))
	for class_id: String in CLASS_IDS:
		var button := Button.new()
		button.text = String(GameData.class_attributes(class_id).get("display_name", class_id))
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.toggle_mode = true
		button.button_pressed = class_id == selected
		button.custom_minimum_size.y = 48
		button.pressed.connect(_select_class.bind(class_id))
		_options_box.add_child(button)
	_update_class_detail()


func _build_appearance_options() -> void:
	var axes := [
		["body_id", "CORPO"], ["skin_tone_id", "TOM DE PELE"],
		["hair_id", "CABELO"], ["hair_color_id", "COR DO CABELO"],
		["brows_id", "SOBRANCELHAS"], ["accent_id", "ACENTO DO KIT"],
		["voice_id", "VOZ"],
	]
	for axis: Array in axes:
		var key := String(axis[0])
		var label := Label.new()
		label.text = String(axis[1])
		label.add_theme_font_size_override("font_size", 15)
		label.add_theme_color_override("font_color", Color("99a8a9"))
		_options_box.add_child(label)
		var option := OptionButton.new()
		option.custom_minimum_size.y = 42
		var values: Array = (GameData.appearance.get("options", {}) as Dictionary).get(key, [])
		var labels: Dictionary = GameData.appearance.get("labels", {}) as Dictionary
		var current := String((_draft.get("appearance", {}) as Dictionary).get(key, ""))
		for value: Variant in values:
			option.add_item(String(labels.get(value, value)))
			option.set_item_metadata(option.item_count - 1, value)
			if String(value) == current:
				option.select(option.item_count - 1)
		option.item_selected.connect(_appearance_selected.bind(key, values))
		_options_box.add_child(option)
	_detail.text = "[b]Aspecto sem vantagem mecânica[/b]\n\nOs dois corpos usam o mesmo esqueleto, cápsula, alcance, câmara e frames. Corpo e voz são independentes.\n\nA amostra de voz é provisória; a escolha fica gravada sem inventar áudio."


func _build_name_options() -> void:
	var label := Label.new()
	label.text = "NOME DA PERSONAGEM"
	label.add_theme_color_override("font_color", Color("99a8a9"))
	_options_box.add_child(label)
	var input := LineEdit.new()
	input.name = "CharacterName"
	input.placeholder_text = "1–24 caracteres"
	input.text = String(_draft.get("name", ""))
	input.max_length = 64
	input.custom_minimum_size.y = 54
	input.text_changed.connect(_name_changed)
	_options_box.add_child(input)
	var status := Label.new()
	status.name = "NameStatus"
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	status.custom_minimum_size.y = 80
	_options_box.add_child(status)
	_update_name_status(status)
	_detail.text = "[b]O nome é só texto mostrado.[/b]\n\nNunca é usado como nome de ficheiro, ID de rede ou chave de catálogo. Nomes repetidos são permitidos.\n\nAceita letras Unicode, espaço simples, apóstrofo e hífen."
	input.grab_focus()


func _build_review() -> void:
	var summary := Label.new()
	summary.text = "PRONTO PARA ENTRAR EM BRUMAL"
	summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	summary.add_theme_color_override("font_color", Color("d4b36f"))
	_options_box.add_child(summary)
	var validation := validate_character_name(String(_draft.get("name", "")))
	_footer_create.disabled = not bool(validation.get("valid", false)) or int(_draft.get("slot", -1)) < 0
	var class_id := String(_draft.get("class_id", "warrior"))
	var attrs := GameData.class_attributes(class_id)
	var loadout: Dictionary = (GameData.weapons.get("loadouts", {}) as Dictionary).get(class_id, {})
	var appearance: Dictionary = _draft.get("appearance", {}) as Dictionary
	var labels: Dictionary = GameData.appearance.get("labels", {}) as Dictionary
	_detail.text = "[b]%s[/b]\n%s\n\n[b]Origem[/b]\n%s — é só o começo.\n\n[b]Atributos[/b]\n%s\n\n[b]Equipamento inicial[/b]\n%s\n\n[b]Aspecto[/b]\n%s · %s\n\n[b]Slot[/b]\n%d" % [
		String(_draft.get("name", "—")),
		String(validation.get("error", "Nome válido.")),
		String(attrs.get("display_name", class_id)), _attribute_line(attrs),
		_loadout_line(loadout),
		String(labels.get(appearance.get("body_id", ""), appearance.get("body_id", ""))),
		String(labels.get(appearance.get("voice_id", ""), appearance.get("voice_id", ""))),
		int(_draft.get("slot", -1)) + 1,
	]


func _update_class_detail() -> void:
	var class_id := String(_draft.get("class_id", "warrior"))
	var attrs := GameData.class_attributes(class_id)
	var loadout: Dictionary = (GameData.weapons.get("loadouts", {}) as Dictionary).get(class_id, {})
	var ability := GameData.ability(class_id)
	var role: Array = CLASS_ROLES.get(class_id, ["", "", ""])
	_detail.text = "[b]%s[/b]\n%s\n\n[b]Começa com[/b]\n%s\n\n[b]É forte quando[/b]\n%s\n\n[b]Sofre quando[/b]\n%s\n\n[b]Verbo de assinatura[/b]\n%s\n\n[b]Atributos[/b]\n%s\n\n[color=#d4b36f]Podes mudar de arma e subir qualquer atributo.[/color]" % [
		String(attrs.get("display_name", class_id)), String(role[0]),
		_loadout_line(loadout), String(role[1]), String(role[2]),
		String(ability.get("display_name", "—")), _attribute_line(attrs),
	]


func _attribute_line(attrs: Dictionary) -> String:
	var parts: Array[String] = []
	for key: String in ["vida", "stamina", "constituicao", "inteligencia", "fe", "forca", "destreza", "carga"]:
		var short := String({"constituicao": "con", "inteligencia": "int", "destreza": "des"}.get(key, key))
		parts.append("%s %d" % [short, int(attrs.get(key, 8))])
	return " · ".join(parts)


func _loadout_line(loadout: Dictionary) -> String:
	var items: Array[String] = []
	for key: String in ["main", "offhand"]:
		var item: Variant = loadout.get(key)
		if item != null and String(item) != "":
			items.append(String(GameData.weapon(String(item)).get("display_name", item)))
	for piece: Variant in loadout.get("pecas", []):
		items.append(String(piece).replace("_", " ").capitalize())
	return ", ".join(items)


func _select_class(class_id: String) -> void:
	_draft["class_id"] = class_id
	_refresh_creation_step()


func _appearance_selected(index: int, key: String, values: Array) -> void:
	if index < 0 or index >= values.size():
		return
	var appearance: Dictionary = _draft.get("appearance", {}) as Dictionary
	appearance[key] = values[index]
	_draft["appearance"] = appearance
	_update_preview()


func _name_changed(value: String) -> void:
	_draft["name"] = value
	var status := _options_box.get_node_or_null("NameStatus") as Label
	if status != null:
		_update_name_status(status)


func _update_name_status(status: Label) -> void:
	var validation := validate_character_name(String(_draft.get("name", "")))
	status.text = "%d/24\n%s" % [int(validation.get("count", 0)), String(validation.get("error", "Nome válido."))]
	status.add_theme_color_override("font_color", Color("9fc59f") if validation.get("valid") else Color("db8d7c"))


func _set_creation_step(index: int) -> void:
	_creation_step = clampi(index, 0, 3)
	show_character_creation()


func _previous_creation_step() -> void:
	_set_creation_step(_creation_step - 1)


func _next_creation_step() -> void:
	if _creation_step == 2 and not validate_character_name(String(_draft.get("name", ""))).get("valid"):
		return
	_set_creation_step(_creation_step + 1)


func _create_character() -> void:
	var validation := validate_character_name(String(_draft.get("name", "")))
	if not bool(validation.get("valid", false)):
		_creation_step = 2
		show_character_creation()
		return
	var slot := int(_draft.get("slot", -1))
	if slot < 0 or FileAccess.file_exists(SaveSystem.slot_path(slot)):
		_show_modal("SEM SLOT LIVRE", "Os três slots estão ocupados. Este fluxo nunca substitui um save.")
		return
	var identity := {
		"name": String(validation.get("name", "")),
		"appearance": (_draft.get("appearance", {}) as Dictionary).duplicate(true),
	}
	var profile_id := "local-%d-%d" % [int(Time.get_unix_time_from_system()), Time.get_ticks_msec()]
	if not SaveSystem.new_game(profile_id, String(_draft.get("class_id", "warrior")), slot, identity):
		_show_modal("NÃO FOI POSSÍVEL GRAVAR", SaveSystem.last_error)
		return
	_start_gameplay()


func _continue_last_save() -> void:
	var slot := SaveSystem.latest_slot()
	if slot < 0:
		_show_modal("SEM SAVE", "Não existe uma gravação íntegra para continuar.")
		return
	var loaded := SaveSystem.load_slot(slot)
	if loaded.is_empty():
		_show_modal("NÃO FOI POSSÍVEL CARREGAR", SaveSystem.last_error)
		return
	_start_gameplay()


func _start_gameplay() -> void:
	_clear_screen()
	if is_instance_valid(_gameplay):
		_gameplay.queue_free()
	_gameplay = GAMEPLAY_SCENE.instantiate()
	add_child(_gameplay)


func return_to_main_menu() -> void:
	show_main_menu()


func _settings_placeholder() -> void:
	_show_modal("CONFIGURAÇÕES", "O menu completo abre neste mesmo ecrã sem perder as escolhas.")


func _show_modal(title: String, message: String) -> void:
	var dialog := AcceptDialog.new()
	dialog.title = title
	dialog.dialog_text = message
	dialog.min_size = Vector2i(560, 220)
	_screen.add_child(dialog)
	dialog.popup_centered()


func _build_preview(pos: Vector2, dimensions: Vector2) -> void:
	var frame := _panel(pos, dimensions)
	var caption := Label.new()
	caption.text = "ARRASTA PARA RODAR  ·  RODA DO RATO PARA APROXIMAR"
	caption.position = Vector2(22, 22)
	caption.add_theme_font_size_override("font_size", 15)
	caption.add_theme_color_override("font_color", Color("7f8e90"))
	frame.add_child(caption)
	var container := SubViewportContainer.new()
	container.position = Vector2(18, 58)
	container.size = dimensions - Vector2(36, 84)
	container.stretch = true
	container.gui_input.connect(_preview_input)
	frame.add_child(container)
	_preview_viewport = SubViewport.new()
	_preview_viewport.size = Vector2i(724, 786)
	_preview_viewport.transparent_bg = true
	_preview_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	container.add_child(_preview_viewport)
	var environment := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color("10191d")
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color("8b9ba0")
	env.ambient_light_energy = 1.2
	environment.environment = env
	_preview_viewport.add_child(environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-35, -30, 0)
	light.light_color = Color("f0d8ae")
	light.light_energy = 2.0
	light.shadow_enabled = false
	_preview_viewport.add_child(light)
	var rim := OmniLight3D.new()
	rim.position = Vector3(-2.5, 2.2, -1.5)
	rim.light_color = Color("7196a5")
	rim.omni_range = 6.0
	rim.light_energy = 4.0
	_preview_viewport.add_child(rim)
	_preview_pivot = Node3D.new()
	_preview_viewport.add_child(_preview_pivot)
	var camera := Camera3D.new()
	camera.position = Vector3(0, 1.0, -4.4)
	camera.fov = 33.0
	_preview_viewport.add_child(camera)
	camera.look_at(Vector3(0, 0.9, 0))
	_update_preview()


func _update_preview() -> void:
	if not is_instance_valid(_preview_pivot):
		return
	if is_instance_valid(_preview_visual):
		_preview_visual.free()
	var appearance: Dictionary = _draft.get("appearance", {}) as Dictionary
	_preview_visual = CharacterVisual.new()
	_preview_pivot.add_child(_preview_visual)
	var tint: Color = SKIN_TINTS.get(String(appearance.get("skin_tone_id", "skin_02")), Color.WHITE)
	# O tint da pre-visualizacao distingue os quatro tons sem duplicar texturas;
	# a fisica e o material do mundo continuam independentes desta escolha.
	_preview_visual.setup(2.2, tint, false, String(appearance.get("body_id", "body_male")))
	_preview_visual.position = Vector3(0, -0.15, 0)


func _preview_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		if mouse_button.button_index == MOUSE_BUTTON_LEFT:
			_preview_dragging = mouse_button.pressed
		elif mouse_button.pressed and mouse_button.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			var camera := _preview_viewport.get_camera_3d()
			if camera != null:
				camera.position.z = clampf(camera.position.z + (-0.25 if mouse_button.button_index == MOUSE_BUTTON_WHEEL_UP else 0.25), 2.8, 5.2)
	elif event is InputEventMouseMotion and _preview_dragging:
		_preview_pivot.rotation.y += (event as InputEventMouseMotion).relative.x * 0.01


func _begin_screen() -> void:
	_clear_screen()
	_layer = CanvasLayer.new()
	_layer.layer = 200
	add_child(_layer)
	_screen = Control.new()
	_screen.name = "Screen"
	_screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_screen.theme = _theme
	_layer.add_child(_screen)


func _clear_screen() -> void:
	if is_instance_valid(_layer):
		_layer.free()
	_layer = null
	_screen = null
	_preview_viewport = null
	_preview_pivot = null
	_preview_visual = null


func _clear_gameplay() -> void:
	if is_instance_valid(_gameplay):
		_gameplay.free()
	_gameplay = null


func _add_background(top: Color, bottom: Color) -> void:
	var texture := GradientTexture2D.new()
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([top, bottom])
	gradient.offsets = PackedFloat32Array([0.0, 1.0])
	texture.gradient = gradient
	texture.fill_from = Vector2(0.2, 0.0)
	texture.fill_to = Vector2(0.8, 1.0)
	var background := TextureRect.new()
	background.texture = texture
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_screen.add_child(background)
	_screen.move_child(background, 0)


func _panel(pos: Vector2, dimensions: Vector2) -> Panel:
	var panel := Panel.new()
	panel.position = pos
	panel.size = dimensions
	_screen.add_child(panel)
	return panel


func _menu_button(label: String, description: String) -> Button:
	var button := Button.new()
	button.text = "%s\n%s" % [label, description]
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.custom_minimum_size = Vector2(430, 76)
	return button


func _make_theme() -> Theme:
	var theme := Theme.new()
	theme.set_default_font_size(18)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.025, 0.045, 0.055, 0.94)
	panel_style.border_color = Color(0.34, 0.39, 0.39, 0.8)
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(3)
	theme.set_stylebox("panel", "Panel", panel_style)
	for state: String in ["normal", "hover", "pressed", "focus", "disabled"]:
		var style := StyleBoxFlat.new()
		style.bg_color = {
			"normal": Color(0.07, 0.10, 0.11, 0.92),
			"hover": Color(0.15, 0.18, 0.18, 0.98),
			"pressed": Color(0.28, 0.22, 0.13, 0.98),
			"focus": Color(0.12, 0.15, 0.16, 0.98),
			"disabled": Color(0.035, 0.05, 0.055, 0.7),
		}[state]
		style.border_color = Color("9a743d") if state in ["hover", "pressed", "focus"] else Color("3f4849")
		style.set_border_width_all(2 if state == "focus" else 1)
		style.set_corner_radius_all(2)
		style.content_margin_left = 18
		style.content_margin_right = 14
		style.content_margin_top = 8
		style.content_margin_bottom = 8
		theme.set_stylebox(state, "Button", style)
	theme.set_color("font_color", "Button", Color("d9dfdd"))
	theme.set_color("font_hover_color", "Button", Color("f2dfb5"))
	theme.set_color("font_pressed_color", "Button", Color("f5d28a"))
	theme.set_color("font_disabled_color", "Button", Color("596366"))
	theme.set_font_size("font_size", "Button", 18)
	return theme


func _has_save() -> bool:
	for slot: int in range(3):
		if SaveSystem.has_save(slot):
			return true
	return false


func _first_free_slot() -> int:
	for slot: int in range(3):
		if not FileAccess.file_exists(SaveSystem.slot_path(slot)):
			return slot
	return -1


func _argument_value(prefix: String) -> String:
	for argument: String in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""


static func validate_character_name(raw_name: String) -> Dictionary:
	var name := raw_name.strip_edges()
	var graphemes := 0
	var previous_space := false
	if name == "":
		return {"valid": false, "name": name, "count": 0, "error": "Escreve um nome."}
	for index: int in name.length():
		var code := name.unicode_at(index)
		var combining := (code >= 0x0300 and code <= 0x036f) or (code >= 0x1ab0 and code <= 0x1aff)
		if not combining:
			graphemes += 1
		var is_space := code == 0x20
		if is_space and previous_space:
			return {"valid": false, "name": name, "count": graphemes, "error": "Usa apenas um espaço entre palavras."}
		previous_space = is_space
		var ascii_letter := (code >= 65 and code <= 90) or (code >= 97 and code <= 122)
		var unicode_letter_or_mark := code >= 0x00c0 and not (code >= 0x2000 and code <= 0x206f)
		var punctuation_allowed := code in [0x20, 0x27, 0x2019, 0x2d]
		if code < 0x20 or code in [0x2f, 0x5c, 0x3a, 0x3c, 0x3e, 0x5b, 0x5d, 0x7b, 0x7d] \
				or not (ascii_letter or unicode_letter_or_mark or punctuation_allowed or combining):
			return {"valid": false, "name": name, "count": graphemes, "error": "Usa letras, espaço simples, apóstrofo ou hífen."}
	if graphemes > 24:
		return {"valid": false, "name": name, "count": graphemes, "error": "O nome pode ter no máximo 24 caracteres."}
	return {"valid": true, "name": name, "count": graphemes, "error": ""}
