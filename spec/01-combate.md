# 01 — Combate

O núcleo do jogo. É aqui que o pilar "habilidade acima de nível" vive ou morre.

## O que ficou decidido

| Elemento | Estado | Timestamp |
|---|---|---|
| Corpo a corpo com espada | `[DECIDIDO]` | 00:16 |
| Escudo | `[DECIDIDO]` | 00:16 |
| Arco e flecha (distância) | `[DECIDIDO]` | 00:16 |
| Magia como forma de combate | `[DECIDIDO]` | 00:16 |
| **Esquiva** | `[DECIDIDO]` | 02:04 |
| **Parry** | `[DECIDIDO]` — "no combate corpo a corpo e tal" (Rico, 02:11) | 02:04, 02:11 |
| Stamina como recurso | `[DECIDIDO]` — aparece como atributo a subir | 03:50, 06:33 |

> "Esquiva, esse bagulho tem que ter também, né? Esquiva, bagulho de parry." — Mateus (02:04)

## O que isto implica, e que ninguém disse ainda

Esquiva e parry só significam alguma coisa se o combate for **legível e telegrafado**. São mecânicas de reacção: o inimigo avisa, o jogador responde na janela certa. Isso arrasta um conjunto de decisões que ainda não foram tomadas e que definem completamente como o jogo se sente:

- **Janela de invencibilidade da esquiva** `[EM ABERTO]` — quantos frames. É o número que decide se o jogo é justo ou frustrante.
- **Custo de stamina** por ataque, esquiva, bloqueio, corrida `[EM ABERTO]`
- **Velocidade de regeneração** da stamina, e se regenera enquanto se bloqueia `[EM ABERTO]`
- **O que acontece com stamina a zero** — fica-se vulnerável? Cambaleia? `[EM ABERTO]`
- **Parry: janela e recompensa** — abre um golpe crítico? Quebra a postura? `[EM ABERTO]`
- **Bloqueio com escudo** — absorve tudo à custa de stamina, ou deixa passar dano? `[EM ABERTO]`
- **Lock-on** num alvo `[EM ABERTO]` — não foi mencionado, mas praticamente todos os souls-like têm, e muda o esquema de controlos todo
- **Poise / interrupção** — o jogador é interrompido a meio de um ataque quando leva dano? `[EM ABERTO]`

Nenhuma destas se pode responder de cadeira. Respondem-se a jogar. Ver a proposta de protótipo em [`99-perguntas-abertas.md`](99-perguntas-abertas.md).

## Regra de ouro para este sistema

Sempre que se decidir um número aqui, passar pelo teste do pilar 1:

> Um jogador bom, com um personagem fraco, consegue ganhar isto?

Se a resposta for não porque **falta dano** ou porque **o inimigo tem vida a mais**, o número está errado — está a transformar habilidade em nível. Se for não porque **o jogador ainda não aprendeu o padrão**, o número está certo.

## Combate à distância e magia

O arco e a magia ficaram decididos como opções, mas nunca se falou de como equilibram com o corpo a corpo. `[EM ABERTO]`

O risco conhecido do género: se atacar à distância for seguro, o jogador nunca entra no alcance, e esquiva e parry — os dois pilares mecânicos — deixam de acontecer. Formas comuns de resolver (nenhuma decidida): munição limitada, tempo de preparação longo, inimigos que fecham distância depressa, custo de recurso alto.

Ver [`03-magia.md`](03-magia.md).

## Não discutido

Sem qualquer menção na sessão 1, e portanto sem decisão:

- Ataque leve vs pesado
- Ataques carregados, saltados, ataques por trás (backstab), golpe de misericórdia (riposte)
- Combos
- Armas a duas mãos
- Escalonamento de dano por atributo (o *scaling* do Dark Souls)
- Dano por elemento e resistências
- Estados alterados (veneno, sangramento, queimadura)
- Fogueiras / checkpoints e o que se perde ao morrer
- Dificuldade e se existe alguma opção
