# Carregamento de zonas

`streaming_manager.gd` mantém a simulação actual viva enquanto carrega uma cena
com `ResourceLoader.load_threaded_request`. `streaming_gate.gd` transforma essa
fronteira numa garganta física: aproximar prepara, a bruma abre só depois da
memória/local/peers passarem, atravessar confirma, e sair descarrega o lado de
retirada. Não há tecla nem ecrã de carregamento a meio do mundo.

## Integração

O dono do compositor do mundo cria um registo por build/fatia; não se colocam
caminhos de cenas em `world.json` enquanto as zonas ainda não existem:

```gdscript
var manager := preload("res://src/world/streaming_manager.gd").new()
add_child(manager)
manager.configure(GameData.world, {
    "brumal": {
        "scene_path": "res://src/world/zones/brumal.tscn",
        "budget_mib": 512,
        "origin": Vector3.ZERO,
    },
    "fojo": {
        "scene_path": "res://src/world/zones/fojo.tscn",
        "budget_mib": 512,
        "origin": Vector3(260.0, 0.0, 0.0),
    },
}, "current_and_transition")
manager.request_initial_zone("brumal")
```

Cada garganta recebe os dois IDs e o volume físico autorado:

```gdscript
var gate := preload("res://src/world/streaming_gate.gd").new()
add_child(gate)
gate.configure(manager, "brumal", "fojo", Vector3(5.0, 4.0, 2.0))
```

Em co-op, o adaptador de rede chama `set_required_peers()` uma vez e
`set_peer_zone_ready()` quando recebe a confirmação remota. O manager não
escolhe transporte nem autoridade; apenas aplica a regra já escrita de que a
máquina mais lenta manda.

`current_and_neighbors` existe no planeador para auditar a alternativa da
pergunta 50 e impõe 256 MiB por zona. O runtime jogável aqui implementado usa a
proposta reversível `current_and_transition`, 512 MiB por zona. A escolha final
continua dos donos; nenhum dado `[DECIDIDO]` foi alterado.

## Contrato de uma cena de zona

- caminho `res://`, nunca caminho da máquina;
- orçamento incremental declarado e medido;
- nenhum `load()` bloqueante no jogador;
- `_ready()` barato: uma publicação de transição acima de 20 ms é rejeitada;
- os recursos pesados pertencem à própria `PackedScene`, para o loader os poder
  preparar no worker;
- estado lógico vive no save/directores, não fica preso ao Node descarregado;
- arte e som vêm dos packs/manifesto; só a bruma técnica é sintetizada aqui.

`brumal_streaming_zone.tscn` é uma sonda da zona actual. Constrói o `Greybox`
monolítico para medir e, por isso, reprova deliberadamente o gate de frame como
vizinha. Não deve substituir o mundo actual até Brumal ser empacotada ou
construída por etapas.

## Provas

```text
godot --headless --audio-driver Dummy --path game/ \
  --script res://src/world/zones/streaming_self_test.gd

godot --audio-driver Dummy --path game/ --rendering-method mobile \
  --script res://src/world/zones/streaming_benchmark.gd -- \
  --quality=medio \
  --out=res://src/world/zones/medicao-streaming-local.json
```

O primeiro cobre orçamento, I/O assíncrono, fuga/regresso, peer lento,
proximidade, cancelamento, memória real e gate de frame. O segundo mede a cena
disponível. O veredito e a limitação da máquina estão no `ORCAMENTO.md`.
