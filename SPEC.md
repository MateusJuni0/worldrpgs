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
| 01 | [Combate](spec/01-combate.md) | Esquiva, parry, stamina, armas | 🟡 direcção clara, números por decidir |
| 02 | [Personagem](spec/02-personagem.md) | Atributos, classes, evoluções, skills | 🟡 muito nomeado, pouco definido |
| 03 | [Magia](spec/03-magia.md) | Bem e mal, usos, encantamentos | 🟡 conceito sem mecânica |
| 04 | [Inimigos e chefes](spec/04-inimigos-chefes.md) | Raças, hierarquia de chefes | 🟡 quantidades por acertar |
| 05 | [Mundo](spec/05-mundo.md) | Mapa, biomas, dungeons, 3D | 🟢 forma decidida, escala não |
| 06 | [Itens e inventário](spec/06-itens-inventario.md) | Armas, mochila, montarias, drops | 🟢 a regra das armas está fechada |
| 07 | [Multiplayer](spec/07-multiplayer.md) | Co-op, sincronização, recompensas | 🟠 sistema complexo em uma frase |
| 08 | [Interface](spec/08-ui.md) | HUD, hotbar, mochila | 🟡 esqueleto |
| 09 | [Técnico](spec/09-tecnico.md) | Engine, rede, plataformas | 🔴 nada decidido |
| 99 | [**Perguntas em aberto**](spec/99-perguntas-abertas.md) | Guião para a próxima sessão | — |

## O que está fechado

Onze coisas saíram da sessão 1 como decisão:

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

## O que trava

Quatro perguntas bloqueiam o resto — detalhe em [`spec/99-perguntas-abertas.md`](spec/99-perguntas-abertas.md):

1. Qual é a fatia mais pequena disto que já é divertida a dois?
2. Os biomas são patamares de dificuldade? (colide com o pilar 1)
3. As evoluções de classe dão poder ou dão opções? (colide com o pilar 1)
4. "Mapa grande" é quanto?

## Sessões

| # | Data | Duração | Transcrição | Ideias |
|---|---|---|---|---|
| 1 | 30-07-2026 | 13m13s | [transcrição](design/transcripts/) | [ideias](design/ideas/) |
