# Fogueira, morte e almas — prova das quatro perguntas

Medição de 01-08-2026 na máquina alvo: Intel Iris Xe, Mobile/Vulkan,
1920×1080, vsync desligado, cena `lei4` (2 jogadores + 3 inimigos), 4 s de
aquecimento e 10 s de amostra.

| Amostra | FPS médio | 1% low | p95 | p99 | pior | draw calls | primitivas | memória estática | VRAM |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| baseline | 111,5 | 48,0 | 12,473 ms | 15,270 ms | 54,64 ms | 47 | 272 830 | 82,5 MiB | 118,9 MiB |
| 2 manchas sempre visíveis | 135,8 | 86,5 | 9,242 ms | 9,928 ms | 25,75 ms | 48 | 273 598 | 82,9 MiB | 118,9 MiB |

A diferença de FPS entre corridas é variação do sistema, não uma melhoria
causada pelas manchas. O custo estrutural observado no pior caso é **+1 draw
call, +768 primitivas e +0,4 MiB de memória estática**, com p95 abaixo do
orçamento de 16,67 ms. Uma tentativa anterior em que a cena não chegou a
montar produziu `draw_calls: 0` e foi descartada.

Comandos reproduzíveis:

```text
<godot> --audio-driver Dummy --path game/ --rendering-method mobile -- --bench --seconds=10 --warmup=4 --vsync=off --label=almas-baseline --scene=lei4
<godot> --audio-driver Dummy --path game/ --rendering-method mobile --script res://src/progression/soul_stain_benchmark.gd -- --bench --seconds=10 --warmup=4 --vsync=off --label=almas-duas-manchas-visiveis --scene=lei4
```

## As quatro perguntas

1. O jogador usa `interact` junto da fogueira para descansar e abrir
   nível/Brasa; chega fisicamente à mancha para a recuperar.
2. `progression_test.gd` prova os contratos; o auto-teste global continua a ser
   a guarda de regressão. Esta medição prova o custo visual.
3. A fogueira existente, a mancha e as confirmações sonoras são sintetizadas em
   código a partir de `progression.json`; nenhum asset externo foi acrescentado.
4. O custo medido está na tabela acima. A integração final na cena continua
   registada no `LACUNAS.md`, porque `main.gd` pertence a outra árvore.
