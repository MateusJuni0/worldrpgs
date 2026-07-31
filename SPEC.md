# WorldRPGs — Especificação

RPG 3D em terceira pessoa, souls-like, co-op para dois. Índice mestre.

> Cada afirmação nos documentos abaixo traz a origem: `(sessão N · MM:SS)`. Nada entra por invenção.

## Etiquetas

| | |
|---|---|
| `[DECIDIDO]` | Fechado numa conversa. Muda-se com uma decisão nova, registada. |
| `[SUGERIDO]` | Foi dito, ninguém contrariou, ninguém confirmou. |
| `[EM ABERTO]` | Falta decidir. Está em [`spec/99-perguntas-abertas.md`](spec/99-perguntas-abertas.md). |
| `[TENSÃO]` | Duas coisas decididas que ainda não encaixam. |

## Os documentos

| # | Documento | Do que trata | Estado |
|---|---|---|---|
| 00 | [Visão](spec/00-visao.md) | Pitch, os três pilares, referências, risco de escopo | 🟢 base sólida |
| 01 | [Combate](spec/01-combate.md) | Esquiva, parry, stamina, armas | 🟢 números completos `[FABLE]` (WP1), aguarda Mateus + Rico |
| 02 | [Personagem](spec/02-personagem.md) | Atributos, classes, evoluções, skills | 🟡 muito nomeado, pouco definido |
| 03 | [Magia](spec/03-magia.md) | Bem e mal, usos, encantamentos | 🟡 conceito sem mecânica |
| 04 | [Inimigos e chefes](spec/04-inimigos-chefes.md) | Raças, hierarquia de chefes | 🟡 quantidades por acertar |
| 05 | [Mundo](spec/05-mundo.md) | Mapa, biomas, dungeons, 3D | 🟢 forma decidida, escala não |
| 06 | [Itens e inventário](spec/06-itens-inventario.md) | Armas, mochila, montarias, drops | 🟢 a regra das armas está fechada |
| 07 | [Multiplayer](spec/07-multiplayer.md) | Co-op, sincronização, recompensas | 🟠 sistema complexo em uma frase |
| 08 | [Interface](spec/08-ui.md) | HUD, hotbar, mochila | 🟡 esqueleto |
| 09 | [Técnico](spec/09-tecnico.md) | **Restrição de hardware**, engine, rede | 🟠 restrição fixa, resto por decidir |
| 10 | [Fatia 1](spec/10-fatia-1.md) | O primeiro jogável: sistemas completos, conteúdo mínimo, critérios de feito | 🟠 proposta `[FABLE]` (WP0), aguarda Mateus + Rico |
| 11 | [Fórmulas](spec/11-formulas.md) | Atributos, nível, fórmula de dano, curva dos inimigos, tecto da Lei 1 | 🟢 proposta `[FABLE]` (WP2), aguarda Mateus + Rico |
| 99 | [**Perguntas em aberto**](spec/99-perguntas-abertas.md) | Guião para a próxima sessão | — |

## O que está fechado

Doze coisas estão fechadas — onze da sessão 1, mais a restrição de hardware:

1. RPG de acção 3D, terceira pessoa, souls-like, fantasia medieval
2. **Ganha-se com habilidade, não com nível.** Sem gating, sem grind obrigatório
3. Co-op para dois, sempre disponível
4. Esquiva e parry no corpo a corpo
5. Espada, escudo, arco e flecha, magia
6. **Qualquer classe pega em qualquer arma.** A diferença vem das skills e atributos, não de bloqueios
7. Atributos ao estilo Dark Souls, distribuídos por nível
8. Escolha de classe, cada uma com uma habilidade especial
9. Magia do bem e do mal, com usos limitados, magias desenhadas à mão
10. Mundo aberto grande, por biomas, com dungeons escondidas em pontos do mapa
11. Hotbar no fundo do ecrã + mochila de capacidade limitada
12. **A máquina alvo é PC sem placa gráfica dedicada** — Iris Xe integrados, 1080p @ 60 Hz. Manda em toda a arte, render e escolha de engine

## O que trava

Cinco perguntas bloqueiam o resto (a primeira já caiu) — detalhe em [`spec/99-perguntas-abertas.md`](spec/99-perguntas-abertas.md):

1. ~~Máquinas~~ ✅ **respondida** — as duas medidas. A do Rico (**8 GB**) é o alvo, por ser a mais fraca
2. **O 3D aguenta-se neste hardware?** `[TENSÃO]` — quedas de fotogramas atacam o pilar 1
3. Qual é a fatia mais pequena disto que já é divertida a dois? — **proposta escrita em [`spec/10-fatia-1.md`](spec/10-fatia-1.md)**, falta o sim dos dois
4. Os biomas são patamares de dificuldade? (colide com o pilar 1)
5. As evoluções de classe dão poder ou dão opções? (colide com o pilar 1)
6. "Mapa grande" é quanto?

## A construir

[`prompts/BRIEFING-FABLE.md`](prompts/BRIEFING-FABLE.md) — o prompt-raiz. Manda o Fable detalhar isto tudo em 20 pacotes, um PR cada, até ficar implementável sem perguntas. Inclui o catálogo de assets, os prompts de imagem para o Codex/GPT image, e a estrutura de pastas de `art/`.

## Sessões

| # | Data | Duração | Transcrição | Ideias |
|---|---|---|---|---|
| 1 | 30-07-2026 | 13m13s | local | local |
