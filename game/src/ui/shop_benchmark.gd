extends SceneTree
## Smoke visual e medicao repetivel da loja. Executar com uma janela 1920x1080;
## a imagem fica no overlay de teste, nunca no repositorio de entrega.

const CAPTURE_PATH := "res://captures/shop-menu-benchmark.png"
const WARMUP_SECONDS := 2.0
const SAMPLE_SECONDS := 5.0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	await create_timer(WARMUP_SECONDS).timeout
	var baseline := await _measure(SAMPLE_SECONDS)
	var save_system := root.get_node_or_null("SaveSystem")
	var game_data := root.get_node_or_null("GameData")
	if save_system == null or game_data == null:
		push_error("[ShopBenchmark] autoloads de dados indisponiveis")
		quit(1)
		return
	var state: Dictionary = save_system.call("create_save", "shop-benchmark", "warrior")
	game_data.call("replace_save_state", state)
	var shop_menu_script := load("res://src/ui/shop_menu.gd")
	if shop_menu_script == null:
		push_error("[ShopBenchmark] script da loja indisponivel")
		quit(1)
		return
	var menu = shop_menu_script.new()
	root.add_child(menu)
	if not menu.open(Theme.new(), "ferreiro"):
		push_error("[ShopBenchmark] a loja recusou abrir")
		quit(1)
		return
	await create_timer(WARMUP_SECONDS).timeout
	var item_list: ItemList = menu.get("_item_list") as ItemList
	if item_list == null or item_list.item_count > 24:
		push_error("[ShopBenchmark] pagina excede o limite de 24 opcoes")
		quit(1)
		return
	var capture_error := get_root().get_texture().get_image().save_png(CAPTURE_PATH)
	if capture_error != OK:
		push_error("[ShopBenchmark] falhou a captura: %s" % error_string(capture_error))
		quit(1)
		return
	var shop := await _measure(SAMPLE_SECONDS)
	print("[ShopBenchmark] GPU: %s" % RenderingServer.get_video_adapter_name())
	print("[ShopBenchmark] baseline: %.1f fps | p99 %.2f ms" % [
		float(baseline.get("fps", 0.0)), float(baseline.get("p99_ms", 0.0))])
	print("[ShopBenchmark] loja: %.1f fps | p99 %.2f ms | %d itens/pagina | %d draw calls" % [
		float(shop.get("fps", 0.0)), float(shop.get("p99_ms", 0.0)),
		item_list.item_count,
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME)])
	print("[ShopBenchmark] captura: %s" % CAPTURE_PATH)
	quit(0)


func _measure(seconds: float) -> Dictionary:
	var frame_ms: Array[float] = []
	var started := Time.get_ticks_usec()
	var previous := started
	while float(Time.get_ticks_usec() - started) / 1_000_000.0 < seconds:
		await process_frame
		var now := Time.get_ticks_usec()
		frame_ms.append(float(now - previous) / 1000.0)
		previous = now
	frame_ms.sort()
	var elapsed_s := maxf(float(previous - started) / 1_000_000.0, 0.001)
	var p99_index := clampi(ceili(float(frame_ms.size()) * 0.99) - 1, 0,
		maxi(frame_ms.size() - 1, 0))
	return {
		"fps": float(frame_ms.size()) / elapsed_s,
		"p99_ms": frame_ms[p99_index] if not frame_ms.is_empty() else 0.0,
	}
