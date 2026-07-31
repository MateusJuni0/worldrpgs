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
| 01 | [Combate](spec/01-combate.md) | Máquina de estados, esquiva, parry, stamina, as 5 armas | 🟠 números de partida `[FABLE]` (WP1) — validam-se no protótipo (marco 2) |
| 02 | [Personagem](spec/02-personagem.md) | Atributos, classes, evoluções, skills | 🟡 muito nomeado, pouco definido |
| 03 | [Magia](spec/03-magia.md) | Bem e mal, usos, encantamentos | 🟡 conceito sem mecânica |
| 04 | [Inimigos e chefes](spec/04-inimigos-chefes.md) | Raças, hierarquia de chefes | 🟡 quantidades por acertar |
| 05 | [Mundo](spec/05-mundo.md) | Mapa, biomas, dungeons, 3D | 🟢 forma decidida, escala não |
| 06 | [Itens e inventário](spec/06-itens-inventario.md) | Armas, mochila, montarias, drops | 🟢 a regra das armas está fechada |
| 07 | [Multiplayer](spec/07-multiplayer.md) | Co-op, sincronização, recompensas | 🟠 sistema complexo em uma frase |
| 08 | [Interface](spec/08-ui.md) | HUD, hotbar, mochila | 🟡 esqueleto |
| 09 | [Técnico](spec/09-tecnico.md) | **Restrição de hardware**, engine, rede | 🟠 restrição fixa, resto por decidir |
| 10 | [Fatia 1](spec/10-fatia-1.md) | O primeiro jogável: sistemas completos, conteúdo mínimo, critérios de feito | 🟠 proposta `[FABLE]` (WP0), aguarda Mateus + Rico |
| 11 | [Atributos e fórmulas](spec/11-formulas.md) | Os 6 atributos, fórmula de dano, curvas dos inimigos da fatia | 🟠 números de partida `[FABLE]` (WP2) — validam-se no protótipo |
| 12 | [Classes](spec/12-classes.md) | As 8 fichas, habilidades especiais, skills, e a tensão das evoluções proposta | 🟠 `[FABLE]` (WP3) — evoluções aguardam decisão A/B dos dois |
| 13 | [Magia, por dentro](spec/13-magia.md) | Bem/mal com mecânica proposta, catálogo, cargas, pergaminhos, encantamentos | 🟠 `[FABLE]` (WP4) — bem/mal aguarda o sim dos dois (pergunta 8) |
| 14 | [Armas e equipamento](spec/14-equipamento.md) | Catálogo completo de armas, Lei 3 em números, frasco de cura, armadura em proposta (WP5) | 🟠 proposta `[FABLE]` — pergunta 7 e 14 aguardam os dois |
| 15 | [Bestiário](spec/15-inimigos.md) | IA comum, as 7 raças em fichas com telegrafias, encontros da fatia (WP6) | 🟠 proposta `[FABLE]` — raças aguardam o sim do Mateus |
| 16 | [Chefes](spec/16-chefes.md) | Regras de camada da pirâmide, regras de todo o chefe, ficha completa do Vorgar (WP7) | 🟠 proposta `[FABLE]` — total da pirâmide (pergunta 13) fica com os dois |
| 17 | [Mundo e mapa](spec/17-mundo.md) | Rede de 6 zonas em números, dungeons com a regra das duas pistas, traçado de Brumal, tensões 2 e 4 propostas (WP8) | 🟠 proposta `[FABLE]` — escala e soft gating aguardam os dois |
| 18 | [Progressão e loot](spec/18-progressao.md) | Curva por zona, loot instanciado, o 40% de quem ajuda, moeda única proposta (WP9) | 🟠 proposta `[FABLE]` — perguntas 5 e 10 continuam dos dois |
| 19 | [Multiplayer e rede](spec/19-rede.md) | O 12:34 resolvido (dois sacos de estado), transporte, autoridade dividida, quedas (WP10) | 🟠 proposta `[FABLE]` — transporte e fogo amigo aguardam os dois |
| 20 | [Interface](spec/20-interface.md) | HUD ao pixel, mochila 24, magias 3-visíveis, menus, configurações completas (WP11) | 🟠 proposta `[FABLE]` — resolve o 04:55 das magias no ecrã |
| 21 | [Arte, render, animação, efeitos e som](spec/21-arte-render.md) | Direcção de arte, orçamentos da Lei 4, lista de animações, fichas de efeitos, som completo (WP12) | 🟠 proposta `[FABLE]` — estilo (pergunta 15) aguarda os dois |
| 22 | [Origem dos assets](spec/22-assets.md) | Modelos 3D, animações e áudio — fontes e licenças (WP13) | 🟢 regras fixas; inventário confirma-se no download |
| 23 | [Arquitectura técnica](spec/23-tecnico.md) | Engine (Godot, com a medição 0b), sistemas, dados afináveis, saves, ferramentas (WP14) | 🟠 proposta `[FABLE]` — engine aguarda o carimbo dos dois (pergunta 17) |
| 24 | [Plano de construção](spec/24-plano.md) | M0–M7 com verificação jogável por marco; M1 já medido; riscos com resposta (WP15) | 🟢 pronto para o Opus 5 — é o documento de arranque da construção |
| 25 | [Câmara, controlo e game feel](spec/25-controlo.md) | Câmara, input buffer, latência, hit-stop (WP1B) | 🟠 proposta `[CLAUDE]`, números afinam-se no protótipo |
| 26 | [Narrativa e NPCs](spec/26-narrativa.md) | Proposta mínima + as 7 perguntas que só uma gravação responde (WP8B) | 🟠 guião de gravação pronto, decisões são dos donos |
| 27 | [Aprender a jogar](spec/27-aprendizagem.md) | Os professores, os 5 primeiros minutos, curva e recuperação (WP11B) | 🟠 proposta `[CLAUDE]`, valida-se com gente de fora |
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

Quatro perguntas bloqueiam o resto (as duas primeiras já caíram) — detalhe em [`spec/99-perguntas-abertas.md`](spec/99-perguntas-abertas.md):

1. ~~Máquinas~~ ✅ **respondida** — as duas medidas. A do Rico (**8 GB**) é o alvo, por ser a mais fraca
2. ~~O 3D aguenta-se?~~ ✅ **medido no protótipo: aguenta** — 60 fps cravados no cenário da fatia, 20 min quentes sem degradação; ressalva: animação de esqueleto por medir (pergunta 0b)
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
