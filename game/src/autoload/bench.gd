extends Node
## Medicao de desempenho — a Lei 4 com numeros em vez de opiniao.
##
## Dois modos:
##  1. Sobreposicao em jogo (F1) — fps, tempo de frame, minimo da janela, draw calls.
##  2. Modo automatico, para correr da linha de comandos e escrever um resultado:
##
##     godot --path . --rendering-method mobile -- --bench --seconds=60 --label=mobile-frio
##
## Argumentos (depois de "--"):
##   --bench            liga o modo automatico (sai no fim)
##   --seconds=N        duracao da amostragem (defeito 30)
##   --warmup=N         segundos ignorados no inicio, para compilacao de shaders (defeito 6)
##   --vsync=on|off     defeito OFF — sem vsync ve-se a FOLGA real; com vsync ve-se se AGUENTA 60
##   --label=texto      etiqueta que vai no resultado
##   --out=caminho      ficheiro JSON de saida
##   --scene=nome       que cenario o main.gd monta (perf | combat | zone)

var scene_arg := "zone"

var _bench_active := false
var _label := "sem-etiqueta"
var _warmup := 6.0
var _duration := 30.0
var _vsync_on := false
var _out_path := ""

var _sampling := false
var _elapsed := 0.0
var _deltas: PackedFloat32Array = PackedFloat32Array()

var _layer: CanvasLayer
var _text: Label
var _visible := true
var _acc := 0.0
var _frames := 0
var _fps_shown := 0.0
var _window_worst := 9999.0
var _window_t := 0.0
var _worst_shown := 0.0
var _session_worst := 9999.0


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_parse_args()
	if _bench_active:
		_apply_bench_display()
	else:
		_build_overlay()


func _parse_args() -> void:
	for a in OS.get_cmdline_user_args():
		if a == "--bench":
			_bench_active = true
		elif a.begins_with("--seconds="):
			_duration = float(a.split("=")[1])
		elif a.begins_with("--warmup="):
			_warmup = float(a.split("=")[1])
		elif a.begins_with("--label="):
			_label = a.split("=")[1]
		elif a.begins_with("--out="):
			_out_path = a.split("=")[1]
		elif a.begins_with("--scene="):
			scene_arg = a.split("=")[1]
		elif a.begins_with("--vsync="):
			_vsync_on = a.split("=")[1] == "on"


func _apply_bench_display() -> void:
	if _vsync_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	Engine.max_fps = 0


func is_benchmarking() -> bool:
	return _bench_active


func set_overlay_visible(value: bool) -> void:
	if is_instance_valid(_layer):
		_layer.visible = value


func _process(delta: float) -> void:
	if _bench_active:
		_bench_tick(delta)
	else:
		_overlay_tick(delta)


func _bench_tick(delta: float) -> void:
	_elapsed += delta
	if not _sampling:
		if _elapsed >= _warmup:
			_sampling = true
			_elapsed = 0.0
			print("[bench] aquecimento feito, a amostrar %.0f s..." % _duration)
		return
	_deltas.append(delta)
	if _elapsed >= _duration:
		_finish()


func _finish() -> void:
	var result := _summarise()
	print("BENCH_RESULT_JSON " + JSON.stringify(result))
	if _out_path != "":
		var f := FileAccess.open(_out_path, FileAccess.WRITE)
		if f != null:
			f.store_string(JSON.stringify(result, "  "))
			f.close()
		else:
			printerr("[bench] nao consegui escrever em %s" % _out_path)
	get_tree().quit(0)


func _summarise() -> Dictionary:
	var n := _deltas.size()
	if n == 0:
		return { "label": _label, "error": "sem amostras" }

	var sorted: Array = Array(_deltas)
	sorted.sort()

	var total := 0.0
	for d: float in _deltas:
		total += d

	var avg_fps := float(n) / total
	var worst_delta: float = sorted[n - 1]
	var min_fps := (1.0 / worst_delta) if worst_delta > 0.0 else 0.0

	# 1% low: media dos 1% de frames mais lentos (o que se SENTE, nao o pico isolado)
	var one_pct := maxi(1, int(float(n) * 0.01))
	var slow_total := 0.0
	for i in range(n - one_pct, n):
		slow_total += float(sorted[i])
	var p1_low := (float(one_pct) / slow_total) if slow_total > 0.0 else 0.0

	var budget := 1.0 / 60.0
	var over := 0
	for d: float in _deltas:
		if d > budget:
			over += 1

	var vp_size := get_viewport().get_visible_rect().size
	return {
		"label": _label,
		"rendering_method": RenderingServer.get_current_rendering_method(),
		"rendering_driver": RenderingServer.get_current_rendering_driver_name(),
		"adapter": RenderingServer.get_video_adapter_name(),
		"resolution": "%dx%d" % [int(vp_size.x), int(vp_size.y)],
		"vsync": "on" if _vsync_on else "off",
		"scene": scene_arg,
		"seconds_sampled": snappedf(_duration, 0.1),
		"frames": n,
		"avg_fps": snappedf(avg_fps, 0.1),
		"min_fps": snappedf(min_fps, 0.1),
		"p1_low_fps": snappedf(p1_low, 0.1),
		"avg_frame_ms": snappedf(total / float(n) * 1000.0, 0.01),
		"worst_frame_ms": snappedf(worst_delta * 1000.0, 0.01),
		"pct_frames_over_16_67ms": snappedf(100.0 * float(over) / float(n), 0.1),
		"static_memory_mb": snappedf(float(OS.get_static_memory_usage()) / 1048576.0, 0.1),
		"draw_calls": int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
		"primitives": int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME)),
		"video_mem_mb": snappedf(Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0, 0.1),
	}


func _build_overlay() -> void:
	_layer = CanvasLayer.new()
	_layer.layer = 100
	add_child(_layer)
	_text = Label.new()
	_text.position = Vector2(12, 10)
	_text.add_theme_color_override("font_color", Color(0.6, 1.0, 0.6))
	_text.add_theme_color_override("font_outline_color", Color.BLACK)
	_text.add_theme_constant_override("outline_size", 4)
	_layer.add_child(_text)


func _overlay_tick(delta: float) -> void:
	if _text == null:
		return
	if InputMap.has_action("toggle_perf") and Input.is_action_just_pressed("toggle_perf"):
		_visible = not _visible
		_text.visible = _visible
	if not _visible:
		return

	_acc += delta
	_frames += 1
	var fps_now := (1.0 / delta) if delta > 0.0 else 0.0
	_window_worst = minf(_window_worst, fps_now)
	_window_t += delta
	if _window_t > 3.0:
		_worst_shown = _window_worst
		_session_worst = minf(_session_worst, _window_worst)
		_window_worst = 9999.0
		_window_t = 0.0

	if _acc >= 0.25:
		_fps_shown = float(_frames) / _acc
		_acc = 0.0
		_frames = 0
		_refresh_text()


func _refresh_text() -> void:
	var vp := get_viewport().get_visible_rect().size
	var ms := 1000.0 / maxf(_fps_shown, 0.001)
	var colour := Color(0.6, 1.0, 0.6)
	if _fps_shown < 55.0:
		colour = Color(1.0, 0.45, 0.45)
	elif _fps_shown < 59.0:
		colour = Color(1.0, 0.9, 0.4)
	_text.add_theme_color_override("font_color", colour)
	_text.text = "%.0f fps  (%.2f ms)   min 3s: %.0f   min sessao: %.0f\n%s / %s  %dx%d   draw %d   vram %.0f MB\nF1 esconde  ·  F2 comandos" % [
		_fps_shown, ms, _worst_shown,
		(_session_worst if _session_worst < 9000.0 else 0.0),
		RenderingServer.get_current_rendering_method(),
		RenderingServer.get_current_rendering_driver_name(),
		int(vp.x), int(vp.y),
		int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)),
		Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0,
	]
