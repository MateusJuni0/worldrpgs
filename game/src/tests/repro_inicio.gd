extends Node
## Reproducao do que o Mateus faz: escolher classe -> iniciar jogo.
## Corre com:  godot --headless --path game/ scenes/repro-inicio.tscn
##
## Existe porque o jogo fechava neste ponto e o auto-teste NAO apanhava: o
## auto-teste valida dados e contratos, nao INSTANCIA a casca nem a cena de
## jogo. Um teste que nunca abre o jogo nao prova que o jogo abre.

const GAMEPLAY := preload("res://scenes/gameplay.tscn")

var _passos := 0


func _ready() -> void:
	# ⚠️ ESTE TESTE NAO PODE OCUPAR OS SLOTS DO JOGADOR.
	# Ja aconteceu (01-08): escreveu nos tres slots da pasta real e o Mateus
	# ficou sem conseguir comecar jogo nenhum — o ecra dizia "os tres slots
	# estao ocupados", e fazia bem, porque este fluxo nunca substitui um save.
	# Todas as arvores de trabalho partilham a MESMA pasta user:// porque tem o
	# mesmo nome de projecto. Logo: limpa o que escreveste, sempre.
	# Tenta TODAS as origens, nao so a primeira: o Mateus escolhe a dele.
	var origens := GameShell.CLASS_IDS
	for i in origens.size():
		var origem: String = origens[i]
		print("[repro] 1.%d new_game(%s)" % [i, origem])
		var slot: int = i - (i / 3) * 3
		var ok: bool = SaveSystem.new_game("repro-" + origem, origem, slot, {
			"name": "R", "appearance": {},
		})
		if not ok:
			printerr("[repro] FALHOU em new_game(%s): %s" % [origem, SaveSystem.last_error])
			get_tree().quit(1)
			return

	print("[repro] 2. a instanciar a casca (GameShell)")
	var casca := GameShell.new()
	add_child(casca)
	print("[repro] 3. casca viva")

	# ⭐ Navegar os ecras E VOLTAR ATRAS e o que apanha o defeito do fecho: era
	# aqui que o jogo morria, porque cada troca de ecra libertava o botao que
	# ainda estava a emitir o sinal.
	print("[repro] 3b. a saltar entre ecras (menu <-> criacao <-> opcoes)")
	for volta in 3:
		casca.show_main_menu()
		casca.show_character_creation()
		casca.show_main_menu()
	print("[repro] 3c. sobreviveu a %d trocas de ecra" % 9)

	print("[repro] 3d. a ABERTURA (show_opening)")
	casca.show_opening()
	print("[repro] 3e. abertura viva")

	print("[repro] 4. a instanciar a cena de jogo")
	var jogo: Node = GAMEPLAY.instantiate()
	add_child(jogo)
	print("[repro] 5. cena de jogo instanciada")


func _process(_delta: float) -> void:
	_passos += 1
	if _passos == 90:
		print("[repro] 6. sobreviveu a 90 frames")
		_limpar_slots_de_teste()
		print("=== ARRANQUE OK ===")
		get_tree().quit(0)


## Apaga os saves que este teste criou. Sem isto, o jogador fica sem slots.
func _limpar_slots_de_teste() -> void:
	var apagados := 0
	for slot in 3:
		for caminho: String in [SaveSystem.slot_path(slot), SaveSystem.slot_path(slot) + ".bak"]:
			if FileAccess.file_exists(caminho):
				DirAccess.remove_absolute(ProjectSettings.globalize_path(caminho))
				apagados += 1
	print("[repro] 7. slots de teste apagados: %d" % apagados)
