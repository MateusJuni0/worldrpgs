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

**A arena final real tem margem de render: 150,9 fps médios e p99 12,673 ms
numa prova de 60 s.** Esta prova tem dois jogadores, Vorgar e dois orcs, na arena
vestida, a 1080p/Mobile. Houve dois frames >20 ms (pior 29,98 ms) sob carga do
host; o benchmark antigo de 47 fps / 21 ms não descreve o custo sustentado
corrente, mas também não se apagam estes dois picos.

A zona completa e densa também cabe no orçamento numa amostra não contaminada:
162,5 fps médios e p99 15,338 ms. A máquina estava em uso por outros processos;
uma repetição com os mesmos 26 draw calls e 91 316 primitivas apanhou p99 17,396
ms. Esses picos externos não são escondidos nem atribuídos ao renderer sem
evidência. O gate renderizado passa; “nenhum pico em qualquer estado do Windows”
não está demonstrado.

| Prova final de 60 s — arena `vorgar` | Média | p95 | p99 | 1% low | >20 ms | Pior |
|---|---:|---:|---:|---:|---:|---:|
| Sem vsync — tempo real de render | **150,9 fps** | 9,923 ms | **12,673 ms** | 68,5 | 2 | 29,98 ms |
| Vsync 60 Hz — pacing do jogo | **59,9 fps** | 17,132 ms | **18,402 ms** | 45,5 | 12 | 33,33 ms |

Durante a segunda prova, três leituras do Windows deram **76%, 67% e 100% de
CPU total**, com vários processos `claude` da outra worktree/agentes activos.
Sem vsync, o motor fica 4,0 ms abaixo do orçamento no p99; com vsync perdeu um
vblank e não passa o gate de “zero quedas”. Conclusão honesta: **a carga do jogo
passa, a estabilidade absoluta nesta sessão saturada não está certificada**.
Não se mataram processos alheios nem se escolheu só a amostra bonita. Uma
amostra anterior de 30 s sem saturação deu 154,9 fps, p99 9,608 ms, pior 10,64
ms e zero frames fora do orçamento.

---

## Auditoria de qualidade de 01-08-2026

Todas as amostras abaixo são Mobile/Vulkan, 1920×1080, preset `medio`, sem
vsync, com 6–8 s de aquecimento. O benchmark passou a guardar p95, p99 e contagem
de frames acima de 20/33 ms; o teste isolado deixou de herdar vsync por engano.

### Causa corrigida — materiais reescritos a cada frame

`Enemy._refresh_colour()` chamava `set_tint()` em cada physics frame, mesmo
quando a cor não mudava. Cada chamada reescrevia o `albedo_color` de todas as
superfícies de cinco personagens. A cor e a animação já tinham estado; faltava
impedir o upload redundante do material.

| `lei4` — 2 jogadores + 3 inimigos | Média | p95 | p99 | 1% low | >16,67 ms | Draws |
|---|---:|---:|---:|---:|---:|---:|
| Antes, corpos humanos | 167,8 fps | 8,433 ms | **17,091 ms** | 50,5 | 1,5% | 16 |
| Cache de tinta, mesma cena | **188,1 fps** | 6,860 ms | **10,011 ms** | 70,0 | 0,1% | 16 |

Ganho reproduzido: **+12,1% de média e −7,080 ms no p99**, sem mudar um pixel.

### Investigação das hipóteses

| Hipótese | Prova | Decisão |
|---|---|---|
| Compilação de shaders em runtime | 8 s de aquecimento removem o arranque/import; amostras quentes não mostram degradação progressiva | não era a causa sustentada; manter aquecimento explícito |
| Fill-rate/resolução | arena `medio`: p99 10,459 ms; `baixo` a 85%: 10,068 ms, sem ganho coerente de média | não baixar resolução para esconder CPU |
| Sombras | o preset médio já tinha `shadows:false`; portanto não podiam explicar a regressão | não houve corte novo; no alto os monstros conservam `cast_shadow` |
| Draw calls/materiais sem instancing | antes da vegetação, 16–20 draw calls; o custo caiu sem alterar draws quando se cacheou tinta | uploads de material eram a causa; cenário estático já usava MultiMesh |
| Importação/animação | os recursos são importados antes da amostra; cinco UAL isolados, agora sem vsync, deram p99 8,996 ms | animação custa, mas não justifica 19,9 ms corrente |
| Culling | nevoeiro + `far=70 m`; famílias MultiMesh são cortadas como grupo. Detritos fora do frustum não mudaram draws/primitivas | não fragmentar em dezenas de chunks: aumentaria draw calls sem benefício medido |

O teste antigo de cinco esqueletos dava p99 **19,910 ms** e pico **21,993 ms**,
mas estava travado a 60 sem o declarar. Repetido com a ferramenta corrigida,
cinco UAL deram **297,4 fps**, p95 **6,659 ms**, p99 **8,996 ms**. Houve um
pico isolado de 55,095 ms enquanto a máquina tinha carga concorrente; por isso
o p99, não o pico único, governa a regressão do motor.

### Custo visual dos monstros CC0

| `lei4` | Média | p95 | p99 | >16,67 ms | Draws | Primitivas | VRAM |
|---|---:|---:|---:|---:|---:|---:|---:|
| Humanos, depois do cache | 188,1 | 6,860 ms | 10,011 ms | 0,1% | 16 | 43 132 | 106,9 MB |
| Orcs Small/Big reais, 45 s | 155,6 | 9,772 ms | 14,344 ms | 0,5% | 18 | 47 724 | 120,5 MB |

Trocar os “homens despidos” por três criaturas distintas custa **−17,3% de
média, +4,333 ms de p99, +2 draws, +4 592 primitivas e +13,6 MB VRAM**. É um
custo visual assumido, não escondido; continua abaixo dos 16,67 ms. Forçar os
AnimationPlayers a callback de física de 60 Hz foi tentado e rejeitado: p99
subiu de 15,961 para 16,793 ms numa amostra curta.

### Custo do mundo preenchido

| Zona completa | Média | p95 | p99 | Draws | Primitivas | VRAM |
|---|---:|---:|---:|---:|---:|---:|
| Orcs, sem detalhe de chão | 169,5 | 10,817 ms | 15,081 ms | 20 | 45 444 | 120,7 MB |
| 1 204 detalhes / 6 MultiMeshes | 165,8 | 11,284 ms | 14,641 ms | 26 | 67 936 | 120,8 MB |
| 1 962 detalhes + 35 árvores + 13 rochas | **162,5** | 10,321 ms | **15,338 ms** | 26 | 91 316 | 120,8 MB |

A primeira camada custou **−2,2% de média**, +6 draws e +0,1 MB; densificar e
concentrar as margens do caminho custou mais **−2,0%**, sem novos draws. A arena
final medida no novo cenário `vorgar` passou de 156,5 / p99 9,445 ms sem
detritos para 154,9 / p99 9,608 ms com detritos: **−1,0% e +0,163 ms**, zero
frames fora do orçamento nos dois casos.

Não se cortou conteúdo para obter estes números. O preset médio já desligava
sombras, SSAO, SSIL, SDFGI, glow, nevoeiro volumétrico e MSAA antes desta tarefa;
isso continua a ser o preço visual conhecido do alvo Iris Xe. Os monstros
mantêm a capacidade de projectar sombra no preset alto.

> As secções seguintes conservam as medições históricas do greybox e da primeira
> conversão visual. Quando divergem, a auditoria acima é o estado corrente e
> identifica explicitamente a versão defeituosa do benchmark de animação.

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

**Conclusão:** “cápsulas não são personagens animados” deixou de ser risco por
medir. Cinco e dez esqueletos mantêm 60 fps; cinco dentro do combate também.
Os picos curtos do ensaio isolado e sem vsync continuam a justificar medir de
novo depois de cada camada visual.

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

**Já não é greybox puro — há corpos, texturas e animação de esqueleto.** Mas faltam equipamento encaixado, efeitos, som e interface final. Não há texturas finais, partículas, som, interface a sério nem IA completa no mesmo teste. A animação de esqueleto já foi medida isoladamente ([`medicoes/animacao-esqueleto-2026-08-01.json`](../medicoes/animacao-esqueleto-2026-08-01.json)): cinco e dez actores deram 60,0 fps médios, mas p95 ≈18,5 ms, p99 ≈19,9 ms e picos de 22,0–22,5 ms. Isso fecha “consegue animar?”, mas **não** fecha o gate p99 ≤16,7 ms nem “aguenta o combate completo”.

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
godot --audio-driver Dummy --path . --rendering-method mobile -- --bench --scene=perf --seconds=30 --label=mobile-frio

# o critério 5 da fatia, travado a 60
godot --audio-driver Dummy --path . --rendering-method mobile -- --bench --scene=lei4 --seconds=60 --vsync=on --label=criterio-5

# arena final real, sem vsync para medir a folga e o p99
godot --audio-driver Dummy --path . --rendering-method mobile -- --bench --scene=vorgar --seconds=60 --vsync=off --label=arena-vorgar

# quente (20 min)
godot --audio-driver Dummy --path . --rendering-method mobile -- --bench --scene=perf --seconds=1200 --label=quente

# custo isolado de 5 e 10 esqueletos UAL reais
godot --audio-driver Dummy --path . --rendering-method mobile --script res://src/tools/animation_benchmark.gd -- --asset=res://assets/models/animations/quaternius/UAL1_Standard.glb --actors=5 --seconds=24 --warmup=6 --width=1920 --height=1080 --vsync=off
```

Os JSON crus ficam em `perf-raw/` (fora do git). Se algum número aqui e no JSON divergirem, **manda o JSON**.

Presets de qualidade em `data/graphics.json` (`--quality=alto|medio|baixo`). Todas as medições acima são no preset **médio**, que é o defeito.
