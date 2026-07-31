# 09 — Técnico

## ⚠️ A restrição que manda em tudo

`[DECIDIDO]` (Mateus, 31-07-2026)

> **PC sem placa gráfica dedicada. O alvo é a máquina mais fraca das duas: 8 GB de RAM.**

Isto não é um detalhe de configuração. É a restrição mais dura do projeto e vem **antes** de qualquer decisão de arte, render ou engine. O jogo tem de correr bem nas máquinas deles, ou não existe.

### Máquina 1 — Mateus `[MEDIDO]` (31-07-2026)

Não estimado. Lido da máquina.

| | |
|---|---|
| Processador | Intel Core **i7-1255U** (12.ª geração) — 10 núcleos, 12 threads, série U de baixo consumo |
| Gráficos | **Intel Iris Xe**, integrados · 2 GB reservados · driver 32.0.101.7082 |
| RAM | **16 GB** (15,73 utilizáveis) — 2 × 8 GB @ 3200 MT/s, **canal duplo** |
| Disco | SSD **NVMe** 512 GB |
| Ecrã | 1920 × 1080 @ **60 Hz** |
| Sistema | Windows 11 Home, build 26200, 64 bits |

**Melhor do que a estimativa inicial (~12 GB):** são 16, em canal duplo — e num gráfico integrado a largura de banda da memória é o estrangulamento principal. Mas esta é a máquina FORTE das duas.

**O que continua a limitar**, e não se resolve com RAM:

- É um chip de portátil da **série U**, de baixo consumo. O problema não é o pico — é aguentar. Ao fim de vinte minutos de jogo, com o portátil quente, a velocidade cai. **O alvo de desempenho tem de ser medido quente, não frio.**
- Os gráficos **partilham a RAM do sistema**. Não há memória de vídeo à parte; tudo o que a textura ocupa, tira ao jogo.
- **60 Hz** fecha a questão da taxa alvo: 60 fps, e não faz sentido perseguir mais.

### Máquina 2 — Rico `[MEDIDO]` (30-07-2026, via WP0) — ⚠️ **é o alvo**

| | |
|---|---|
| Processador | Intel Core **i5-1334U** (13.ª geração), série U |
| Gráficos | **Intel Iris Xe**, integrados |
| RAM | **8 GB** — 2 × 4 GB DDR4-3200, **canal duplo** |
| Disco | SSD **NVMe** 256 GB |
| Ecrã | 1920 × 1080 @ **60 Hz** |
| Sistema | Windows 11 Home, 64 bits |
| Comando | nenhum — teclado e rato |

**O orçamento aponta a esta máquina**, por ser a mais fraca — não adianta o jogo correr bem num PC se corre mal no outro. Descontando o sistema e a memória que os gráficos integrados tiram (partilham a RAM), sobram na ordem de **3 a 4 GB para o jogo**. É o tecto real do projeto.

> Os relatórios completos de `dxdiag` ficam **fora deste repositório**: trazem nome da máquina e do utilizador, e o repositório é público. O que interessa está na tabela.

### O que isto implica

Fica praticamente fora de questão: iluminação global em tempo real, sombras dinâmicas em quantidade, pós-processamento pesado, texturas 4K, malhas de alta densidade, render diferido, e as engines que assumem tudo isto por defeito.

Fica dentro: 3D estilizado com **orçamento consciente** (8–15 mil tri por personagem — ver [`30-qualidade-visual.md`](30-qualidade-visual.md)), iluminação assada, poucas luzes dinâmicas, texturas de 1–2 K, render *forward*, distância de visão curta com névoa a esconder o corte.

**Isto não é má notícia.** Baixo poligonal estilizado é mais barato de produzir *e* de correr — alinha com serem duas pessoas. O que morre é o realismo, e o realismo já tinha sido recusado na sessão 1 ("Realista não", 10:24).

**Alvo:** 1920 × 1080, 60 fps estáveis, medidos na máquina do Rico, quente.

### `[TENSÃO]` — 3D contra o hardware

O 3D foi decidido (11:28), mas o Mateus deixou a porta aberta: *"pode ser de início. Vamos ver como é que..."* (11:32).

Um souls-like vive de leitura de animação e janelas de frames. Num gráfico integrado, manter 60 fps estáveis em 3D com vários inimigos é difícil — e **quedas de fotogramas num souls-like não são feio, são injusto**: uma esquiva falha porque o jogo engasgou, não porque o jogador errou. Isso ataca directamente a Lei 1.

Três caminhos, nenhum decidido:

| | O que é | A favor | Contra |
|---|---|---|---|
| **A** | 3D estilizado com orçamento consciente, muito optimizado | É o que decidiram | Exige disciplina técnica constante; risco real de não chegar a 60 fps |
| **B** | 2.5D — cenário 3D, câmara fixa ou isométrica | Corta a maior parte do custo gráfico e de animação | Não é o que imaginaram |
| **C** | 2D com esqueletos | Souls-likes 2D excelentes existem (Hollow Knight corre em qualquer coisa) | Afasta-se muito da conversa |

**Recomendação:** A, com um teste de desempenho logo no primeiro marco — um boneco a andar, três inimigos e uma zona pequena, medido na máquina deles. Se não der 60 fps estáveis, decide-se aí, com dados, e não agora por palpite.

**Decidem:** Mateus + Rico.

### `[MEDIDO]` — o marco 1 correu antecipado (protótipo local, 31-07-2026)

Protótipo greybox em Godot 4.7.1, medido **na máquina do Rico — a mais fraca**, 1920×1080:

| Cena | Resultado |
|---|---|
| Marco 1 (cápsula + 3 inimigos + zona com névoa) | **416 fps médios ao fim de 20 minutos contínuos e quentes** (frio: 412) · 1% low ~250 · pior frame em vinte minutos: 15,3 ms · **0,0% dos frames fora do orçamento de 16,67 ms** |
| Cenário do critério 5 da fatia (2 jogadores + 3 inimigos) | **60,0 fps cravados com vsync** — 3601 frames a 16,67 ms exactos |
| Renderers comparados (frio, médias) | Forward+ 235 · **Mobile 412 ✅ escolhido** (melhor 1% low, −33% de VRAM) · Compatibility 415 mas 1% low fraco |

**Sem degradação térmica mensurável** — a preocupação da série U fica fechada para este nível de conteúdo.

**Ressalvas honestas, escritas no próprio relatório de medição:** é um greybox **sem animação de esqueleto** (a incógnita cara que falta medir — WP12); a folga de ~6× é orçamento para o conteúdo, não garantia; e a memória cresceu 14,5 MB em 20 min — a vigiar, que 8 GB não perdoam.

**Leitura:** o caminho A deixa de ser aposta e passa a ser plano com dados. O carimbo formal continua a ser vosso — mas agora é assinar por baixo de números, não de palpite.

## Engine

`[EM ABERTO]` — Nunca foi mencionada. A escolha decide-se pela restrição de hardware acima, não por gosto nem por popularidade.

O que a spec exige: 3D **em primeira e terceira pessoa** ([`29-perspectiva.md`](29-perspectiva.md)), animação precisa, mundo aberto, rede para dois, e **correr em gráficos integrados**. A perspectiva dupla pesa na escolha: a engine tem de tornar barato manter dois conjuntos de animação de combate.

Fica para o Fable comparar e propor, em [`prompts/BRIEFING-FABLE.md`](../prompts/BRIEFING-FABLE.md) · WP13. Critério que não pode faltar na comparação: **o que é que cada engine consegue mesmo entregar sem GPU dedicada.**

## Rede

`[EM ABERTO]` — Ver [`07-multiplayer.md`](07-multiplayer.md). Duas perguntas ligadas:

- Como se ligam duas casas diferentes: P2P com NAT punching, relay, ou servidor
- **Quem tem autoridade sobre o combate:** cliente ou servidor

A segunda é a que magoa se for adiada. Num souls-like com esquiva e parry, a autoridade errada dá golpes que parecem acertar e não acertam, e não há forma barata de corrigir depois.

## Arte e assets

`[EM ABERTO]` — Ver [`21-arte-render.md`] (a criar pelo Fable, WP12).

Fica já registada uma distinção que é fácil de confundir e cara de descobrir tarde:

> **Gerar imagens não é gerar modelos 3D.**

A geração de imagens (Codex / GPT image) serve para:

- ✅ Texturas (mapas de cor)
- ✅ Ícones de interface, itens, magias
- ✅ Arte de conceito, para guiar quem modela
- ✅ Retratos, cartas, ecrãs de menu
- ✅ Céus e fundos

E **não** serve para:

- ❌ Malhas 3D
- ❌ Esqueletos e animação
- ❌ Colisões

Ou seja: as imagens resolvem uma fatia grande do trabalho visual, mas **os modelos e as animações têm de vir de outro lado** — bibliotecas gratuitas, lojas, ou feitos à mão. O Fable tem de resolver isso explicitamente em WP12, e dizer de onde vem cada coisa.

## Gravação de progresso

`[EM ABERTO]` — Com progresso individual num mundo partilhado ([`07-multiplayer.md`](07-multiplayer.md)), falta decidir onde fica o estado de cada jogador e quem manda quando divergem.

## Nota sobre o método

A spec vai ser detalhada pelo **Fable do Rico** e implementada depois pelo **Opus 5**. O que estiver vago aqui vai ser decidido por quem constrói, e provavelmente de forma diferente do que os dois imaginam.

**Tudo o que estiver `[EM ABERTO]` quando a construção começar é uma decisão delegada sem se dar por isso.** Ver [`99-perguntas-abertas.md`](99-perguntas-abertas.md).
