# PERF — a Lei 4 com números

> Este ficheiro responde à pergunta mais cara da spec, a `[TENSÃO]` **0b** de
> [`spec/09-tecnico.md`](../OneDrive/Área%20de%20Trabalho/Nova%20claude/worldrpgs/spec/09-tecnico.md):
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

**Aguenta-se, com muita folga.**

No cenário que a spec define como critério de aceitação — **2 jogadores + 3 inimigos no ecrã, a 1920×1080** — o jogo corre a **60,0 fps travados, com o pior frame em 16,67 ms e zero frames fora do orçamento**. Sem vsync, o mesmo cenário dá **377 fps médios**.

Ao fim de **20 minutos quente**, a média é **416 fps** contra 412 a frio. **Não há degradação térmica mensurável.**

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

## Como estes números foram conseguidos

Não foi por sorte. Três decisões deliberadas, todas por causa da Lei 4:

1. **Árvores e pedras em `MultiMeshInstance3D`.** Centenas de objetos, **12 a 20 draw calls no total**. Num gráfico integrado é o número de draw calls que mata, não os polígonos.
2. **A névoa é desempenho, não estética.** Corta a distância de visão para 70 m e esconde o corte do mundo. A spec já tinha percebido isto — *"a bruma é aliada da Lei 4"*.
3. **Tudo o que é caro está desligado, explicitamente:** sem SSAO, sem SSIL, sem SDFGI, sem glow, sem névoa volumétrica, sem MSAA, sombras numa só cascata e as copas das árvores não as lançam.

Malhas de baixa contagem: troncos com 6 lados, copas com 7, cápsulas com 8 segmentos. **23 mil primitivas na cena toda.**

---

## O que estes números NÃO provam

Sou obrigado a ser honesto sobre isto, senão o dado engana.

**Isto é um greybox.** Não há animação de esqueleto, nem texturas, nem partículas, nem som, nem interface a sério. Um souls-like vive de animação — e a animação de esqueleto é *a* grande incógnita que falta medir, porque é cara de CPU e o combate inteiro depende dela.

**A folga é o orçamento para o conteúdo, não uma garantia.** 377 fps no critério 5 quer dizer que há cerca de **6× de orçamento de frame** para gastar em arte, animação e efeitos antes de tocar nos 60. É muito. Não é infinito.

**Só uma máquina foi medida** — a do chão, que é a que manda. A do Mateus (i7-1255U, 16 GB) deve dar melhor, mas não está medida.

**O teste quente correu com a máquina a ser usada** para compilar e correr outras coisas em paralelo. Isso, se enviesa, enviesa **para pior** — o número real sozinho será igual ou melhor.

### O que medir a seguir, por ordem

1. **Animação de esqueleto** com 4–5 personagens animados ao mesmo tempo. É a incógnita que resta.
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
```

Os JSON crus ficam em `perf-raw/` (fora do git). Se algum número aqui e no JSON divergirem, **manda o JSON**.

Presets de qualidade em `data/graphics.json` (`--quality=alto|medio|baixo`). Todas as medições acima são no preset **médio**, que é o defeito.
