# PERF — a Lei 4 com números

> Este ficheiro responde à pergunta mais cara da spec, a `[TENSÃO]` **0b** de
> [`spec/09-tecnico.md`](../spec/09-tecnico.md):
> *o 3D aguenta-se neste hardware?*
>
> A spec pedia que se decidisse **com dados, não por palpite**. Aqui estão os dados.

## A máquina medida

É a **máquina-chão do projeto** — a mais fraca das duas, e portanto a que manda.

| | |
|---|---|
| Processador | Intel Core **i5-1334U** (13.ª gen), série U |
| Gráficos | **Intel(R) Iris(R) Xe Graphics**, integrados, a partilhar a RAM |
| RAM | 8 GB DDR4-3200, canal duplo |
| Ecrã | 1920 × 1080 @ 60 Hz |
| Sistema | Windows 11 Home |
| Motor | Godot 4.7.1-stable |

O nome do adaptador vem lido do próprio Godot em cada medição (`Intel(R) Iris(R) Xe Graphics`), não de uma tabela — é a máquina certa.

---

## A resposta curta

**O greybox aguenta-se com muita folga; o jogo vestido ainda não está aprovado.**

No cenário que a spec define como critério de aceitação — **2 jogadores + 3
inimigos no ecrã, a 1920×1080** — o jogo com cinco corpos Quaternius animados
corre a **60,0 fps travados, com 1% low de 60,0, pior frame de 16,67 ms e zero
frames fora do orçamento** durante 30 segundos. O número antigo de 377 fps sem
vsync pertence ao greybox; a medição actual sem vsync é registada abaixo.

Ao fim de **20 minutos quente**, a média do greybox é **416 fps** contra 412 a frio. **Não há degradação térmica mensurável nesse cenário.** O spike posterior com cinco esqueletos UAL manteve 60,0 fps médios, mas deu **p99 19,910 ms e pior frame 21,993 ms**. A Tarefa 5 melhorou fullscreen para **p99 real 18,323 ms/pior 19,414 ms**: o pico passa, o p99 não. Portanto a média não é prova de 60 fps estáveis do conteúdo final.

---

## Frio — os três renderers comparados

Cenário do marco 1: zona greybox de Brumal com névoa, 3 inimigos a patrulhar, câmara em órbita.
1920×1080, **sem vsync** (para se ver a folga real), 30 s de amostra depois de 6 s de aquecimento.

| Renderer | Driver | Média | **1% low** | Mín | Pior frame | Frames > 16,67 ms | VRAM | RAM |
|---|---|---|---|---|---|---|---|---|
| Forward+ | vulkan | 234,8 | 171,7 | 151,6 | **6,6 ms** | **0,0 %** | 94,7 MB | 55,0 MB |
| **Mobile** ✅ | vulkan | **412,2** | **250,9** | 86,1 | 11,61 ms | **0,0 %** | 63,3 MB | 46,9 MB |
| Compatibility | opengl3 | 414,6 | 142,7 | 77,0 | 12,99 ms | **0,0 %** | **31,9 MB** | 40,1 MB |

**Os três passam.** Nenhum deles deixou um único frame passar dos 16,67 ms.

### Porque é que ficou o Mobile

- **Melhor 1% low (250,9).** É a métrica que interessa num souls-like: não é a média que se sente, é o pior décimo de segundo. O Mobile ganha ao Compatibility por 76 % e ao Forward+ por 46 %.
- **−33 % de VRAM que o Forward+** (63 MB contra 95 MB). Numa máquina de 8 GB onde os gráficos *tiram* memória ao jogo — a spec estima 3 a 4 GB reais disponíveis — isso conta a dobrar.
- É o renderer Vulkan **desenhado para gráficos integrados**. É a ferramenta certa para o alvo.

**O que se perde:** o Forward+ tem o pior frame mais apertado (6,6 ms contra 11,6). Se algum dia a estabilidade se degradar, é para lá que se volta — e a mudança é uma linha em `project.godot`.

**O Compatibility fica em carteira:** gasta metade da VRAM de todos (31,9 MB). Se a memória apertar quando entrar conteúdo a sério, é a saída de emergência, ao preço do pior 1% low dos três.

---

## Quente — 20 minutos, o teste que a spec exige

> *"É um chip de portátil da série U... o problema não é o pico, é aguentar. O alvo de desempenho tem de ser medido quente, não frio."* — `spec/09-tecnico.md`

Renderer Mobile, 1920×1080, sem vsync, **1200 s de amostra contínua — 499 452 frames**.

| | Frio (30 s) | **Quente (20 min)** | Variação |
|---|---|---|---|
| Média | 412,2 | **416,2** | +1 % |
| **1% low** | 250,9 | **249,9** | −0,4 % |
| Mínimo | 86,1 | 65,4 | — |
| Pior frame | 11,61 ms | **15,28 ms** | ainda **abaixo** dos 16,67 |
| Frames > 16,67 ms | 0,0 % | **0,0 %** | — |
| VRAM | 63,3 MB | 63,3 MB | igual |
| RAM | 46,9 MB | 61,4 MB | **+14,5 MB** ⚠️ |

**Conclusão:** ao fim de 20 minutos, com o portátil quente, **nenhum dos 499 452 frames passou o orçamento**. O pior frame de vinte minutos inteiros foi 15,28 ms — e mesmo esse cabe nos 16,67. O 1% low é indistinguível do frio.

Isto fecha a preocupação da série U para este nível de conteúdo.

⚠️ **A ressalva:** a memória cresceu 14,5 MB em 20 minutos. Uma parte é do próprio medidor (guarda meio milhão de amostras, ~2 MB), o resto não está explicado. Não é urgente a este tamanho, mas **é para vigiar** — numa máquina de 8 GB, uma fuga lenta acaba por doer. Fica registado como coisa a medir outra vez quando houver conteúdo a sério.

---

## O critério 5 da fatia, medido à letra

> *"60 fps estáveis em combate — 2 jogadores + 3 inimigos no ecrã — na resolução nativa (1080p)... mínimo aceitável 50 fps com escala dinâmica de resolução."* — `spec/10-fatia-1.md`

Cenário `--scene=lei4`: dois jogadores e três inimigos (dois lanceiros e um brutamontes), 1920×1080, renderer Mobile.

| | Média | 1% low | Mín | Pior frame | Frames > 16,67 ms |
|---|---|---|---|---|---|
| Sem vsync (folga) | 377,1 | 206,3 | 70,6 | 14,17 ms | **0,0 %** |
| **Com vsync (o jogo real)** | **60,0** | **60,0** | **60,0** | **16,67 ms** | **0,0 %** |

Com vsync ligado, os **3601 frames** dos 60 segundos saíram todos a 16,67 ms exactos. Não é "60 fps em média" — é 60 fps **sem uma única variação**.

**Medido outra vez depois de entrar o game feel do WP1B** (paragem de impacto, câmara nova, buffer): 60,0 / 60,0 / 60,0, 0,0 % fora do orçamento. A paragem de impacto custa zero em render — é pausa de lógica local, como o WP1B previa.

**O critério 5 passa.** Não pelo mínimo aceitável de 50 com escala dinâmica: passa no alvo cheio, a 1080p nativos, com ~3,4× de folga no 1% low.

---

## Animação de esqueleto — medida no conteúdo importado

Medição de 01-08-2026, Iris Xe, Mobile/Vulkan, 1920×1080, depois de importar o
corpo e a biblioteca UAL que o jogo usa. A variante UAL é sem root motion e os
actores partilham a mesma estrutura de **65 ossos**.

| Cena | Actores | Média | p95 | p99 | Pior frame |
|---|---:|---:|---:|---:|---:|
| UAL isolado | 5 | **60,0 fps** | 17,773 ms | 18,723 ms | 20,619 ms |
| UAL isolado | 10 | **60,0 fps** | 16,666 ms | 17,323 ms | 18,539 ms |

Essas duas linhas são a campanha histórica baseada no `delta` do Godot. A Tarefa 5 descobriu que esse valor pode ser suavizado: em fullscreen/VSync o motor mostrou p99 **16,666 ms**, mas o relógio real entre callbacks mostrou **18,323 ms**. O benchmark mede agora ambos e o gate usa o relógio real.

| Tarefa 5 — 5 UAL | Média | p95 real | p99 real | Pior real |
|---|---:|---:|---:|---:|
| janela + VSync | 60,0 fps | 18,305 ms | 18,785 ms | 19,718 ms |
| **fullscreen + VSync** | **60,0 fps** | **17,778 ms** | **18,323 ms** | **19,414 ms** |
| fullscreen sem VSync | 392,9 fps | 4,404 ms | 5,714 ms | 7,176 ms |

Na prova integrada `lei4`, com **2 jogadores + 3 inimigos**, modelos, texturas,
IA, animação e colisões reais, 30 s com vsync deram **60,0 fps de média, 60,0 de
1% low, mínimo 60,0, pior frame 16,67 ms e 0,0% acima do orçamento**. A cena
ocupou 115,2 MB de memória gráfica, fez 22 draw calls e desenhou 100 228
primitivas.

Sem vsync, uma amostra curta deu 154,7 fps médios, mas apanhou um pico isolado
de 75,2 ms: o 1% low caiu para 57,7 e 0,2% dos frames passaram 16,67 ms. Uma
amostra anterior na mesma sessão deu 219,3 fps e 1% low de 88,4. Esta variação
é ruído real da máquina enquanto estava a ser usada; não se esconde. O critério
de jogo, medido com o limite real de 60 fps durante 30 s, passou sem uma quebra.

**Diagnóstico:** sem VSync há mais de 10 ms de margem; importação acontece antes da amostra; 5 s de aquecimento retiram shader frio; 5 e 10 actores não mostram escala proporcional. O factor isolado é o pacing de apresentação/VSync no Windows/driver Iris Xe, não animação, importação ou culling. Exclusivo, adaptativo e mailbox foram piores. Fullscreen normal ficou por omissão porque foi a melhor mitigação útil, mas **o gate p99 continua a falhar**.

**Conclusão:** “cápsulas não são personagens animados” deixou de ser risco por medir; estabilidade de apresentação não. A prova integrada antiga usa a métrica legada e é 2+3. Falta a prova quente 2+5 com relógio real, IA, VFX, HUD e rede.

Dados reproduzíveis: [`medicoes/animacao-esqueleto-2026-08-01.json`](../medicoes/animacao-esqueleto-2026-08-01.json)
e `src/tools/animation_benchmark.gd`.

---

## Conversão visual — orçamento por passo

Medições de 01-08-2026 na mesma Iris Xe, Mobile/Vulkan e 1920×1080. As duas
primeiras usam 12 s sem vsync para mostrar a folga; a aceitação final usa 30 s
com vsync, como o jogo real.

| Passo | Média | 1% low | Frames > 16,67 ms | Resultado |
|---|---:|---:|---:|---|
| 4.1 luz e névoa por bioma | 183,1 fps | 61,3 | 0,1% | passa |
| 4.2 contraste, dessaturação, vinheta | 157,3 fps | 60,5 | 0,3% | passa |
| 4.3 primeira troca integral de cenário | 57,4 fps | 40,3 | 61,8% | **rejeitada** |
| 4.3 optimizado, critério final | **60,0 fps** | **60,0** | **0,0%** | **passa** |

A primeira versão de 4.3 não foi escondida: 200 árvores Kenney, materiais
especulares e o passe de sombras elevaram a cena a 134 034 primitivas e
falharam a Lei 4. O preset médio final usa 100 árvores repartidas por três
silhuetas, materiais mates no chão e nas copas e deixa o mapa de sombras para o
preset alto. Continua a 1080p nativos. No critério final, mínimo e 1% low foram
ambos 60,0, o pior frame foi 16,67 ms, houve 20 draw calls, 68 852 primitivas e
107,9 MB de memória gráfica.

As capturas do modo fotografia mostram quedas enquanto o motor copia e grava
cada PNG; esses valores no overlay não são uma medição de jogo. A prova acima
corre sem capturas durante a amostra.

---

## Minimapa 2D — custo isolado, 01-08-2026

Mesmo executável, cena `zone`, preset médio, Mobile/Vulkan, 1920×1080,
VSync desligado, 6 s de aquecimento + 30 s de amostra. O piloto percorre a zona;
`--minimap=off` desliga o cliente sem mudar mundo, actores ou câmara.

| | Sem minimapa | Com minimapa | Diferença |
|---|---:|---:|---:|
| FPS médio | 143,7 | **138,6** | −5,1 (−3,5%) |
| Frame médio | 6,96 ms | **7,21 ms** | +0,25 ms |
| 1% low | 83,2 fps | **81,9 fps** | −1,3 fps |
| Pior frame | 46,93 ms | **32,42 ms** | ruído favorável ao mapa |
| Frames >16,67 ms | 0,1% | **0,1%** | igual |
| Draw calls | 19 | **25** | +6 |
| Primitivas | 262 678 | **262 712** | +34 |
| Memória estática | 85,3 MB | **85,5 MB** | +0,2 MB |

**Veredito:** passa a Lei 4 com folga no ensaio sem VSync. O mapa não usa uma
segunda câmara: é uma textura de **55×55** células que só recebe os novos pixels,
mais o marcador do jogador. O custo medido é 0,25 ms médios; a estabilidade
continua limitada pelo frame pacing já documentado, não pelo minimapa.

Artefactos crus: `captures/orientacao-a-b-{sem,com}-minimapa-30s.json`
(fora do git, como as restantes medições locais).

## Como estes números foram conseguidos

Não foi por sorte. Três decisões deliberadas, todas por causa da Lei 4:

1. **Árvores e pedras em `MultiMeshInstance3D`.** Centenas de objetos, **12 a 20 draw calls no total**. Num gráfico integrado é o número de draw calls que mata, não os polígonos.
2. **A névoa é desempenho, não estética.** Corta a distância de visão para 70 m e esconde o corte do mundo. A spec já tinha percebido isto — *"a bruma é aliada da Lei 4"*.
3. **Tudo o que é caro está desligado, explicitamente:** sem SSAO, sem SSIL, sem SDFGI, sem glow, sem névoa volumétrica, sem MSAA, sombras numa só cascata e as copas das árvores não as lançam.

Os 23 mil primitivos e as cápsulas desta secção descrevem a medição histórica
do greybox. Com cinco corpos importados, a cena integrada actual chega a
100 228 primitivas e continua dentro do alvo.

---

## O que estes números NÃO provam

Sou obrigado a ser honesto sobre isto, senão o dado engana.

**Já não é greybox puro — há corpos, texturas e animação de esqueleto.** Mas faltam equipamento encaixado, efeitos, som e interface final. Não há texturas finais, partículas, som, interface a sério nem IA completa no mesmo teste. A animação de esqueleto já foi medida isoladamente ([`medicoes/animacao-esqueleto-2026-08-01.json`](../medicoes/animacao-esqueleto-2026-08-01.json)): o melhor modo útil dá p99 real 18,323 ms e pior 19,414 ms. Isso fecha “consegue animar?”, mas **não** fecha o gate p99 ≤16,7 ms nem “aguenta o combate completo”.

**A folga é o orçamento para o conteúdo, não uma garantia.** Os 154–219 fps sem
vsync medidos com cinco corpos deixam margem média, mas os picos mostram por que
razão cada camada visual tem de voltar a ser medida.

**Só uma máquina foi medida** — a do chão, que é a que manda. A do Mateus (i7-1255U, 16 GB) deve dar melhor, mas não está medida.

**O teste quente correu com a máquina a ser usada** para compilar e correr outras coisas em paralelo. Isso, se enviesa, enviesa **para pior** — o número real sozinho será igual ou melhor.

### O que medir a seguir, por ordem

1. **Oito personagens animadas dentro do nível completo**, com IA, colisões, VFX, cues, HUD e rede simulada, quente durante 20 min; o gate é p99 ≤16,7 ms e nenhum pico >20 ms em arena.
2. A fuga de memória dos 14,5 MB / 20 min.
3. A zona inteira percorrida a pé, em vez da câmara em órbita.
4. A máquina do Mateus, para confirmar que o chão é mesmo o chão.

---

## Repetir estas medições

```bash
# comparar renderers a frio
godot --path . --rendering-method mobile -- --bench --scene=perf --seconds=30 --label=mobile-frio

# o critério 5 da fatia, travado a 60
godot --path . --rendering-method mobile -- --bench --scene=lei4 --seconds=60 --vsync=on --label=criterio-5

# quente (20 min)
godot --path . --rendering-method mobile -- --bench --scene=perf --seconds=1200 --label=quente

# custo isolado de 5 esqueletos UAL reais; sai com código 1 se falhar p99/pico
godot --path . --rendering-method mobile --script res://src/tools/animation_benchmark.gd -- --asset=res://assets/models/animations/quaternius/UAL1_Standard.glb --actors=5 --seconds=12 --warmup=5 --width=1920 --height=1080 --window=fullscreen --vsync=on --gate
```

Os JSON crus ficam em `perf-raw/` (fora do git). Se algum número aqui e no JSON divergirem, **manda o JSON**.

Presets de qualidade em `data/graphics.json` (`--quality=alto|medio|baixo`). Todas as medições acima são no preset **médio**, que é o defeito.
