# Créditos de assets externos

Cada asset externo que entra no jogo tem uma linha aqui, **no mesmo PR em que entra**. Regra completa: [`spec/22-assets.md`](spec/22-assets.md).

| Asset / pack | Autor | Licença | Fonte | Usado em |
|---|---|---|---|---|
| **Universal Base Characters** (Standard) | Quaternius | CC0 1.0 | [quaternius.itch.io](https://quaternius.itch.io/universal-base-characters) | corpo base das 6 classes — esqueleto partilhado (Lei 3) |
| **Universal Animation Library** | Quaternius | CC0 1.0 | [quaternius.itch.io](https://quaternius.itch.io/universal-animation-library) | ⭐ ciclos de animação — é o que permite medir o risco do M1 |
| **Ultimate Monsters** | Quaternius | CC0 1.0 | [quaternius.com](https://quaternius.com/packs/ultimatemonsters.html) | Orc, Orc Small e Orc Skull — lanceiro, brutamontes e Vorgar |
| **KayKit — Adventurers** | Kay Lousberg | CC0 1.0 | [kaylousberg.itch.io](https://kaylousberg.itch.io/kaykit-adventurers) | personagens jogáveis, alternativa de silhueta |
| **KayKit — Dungeon Pack** | Kay Lousberg | CC0 1.0 | [kaylousberg.itch.io](https://kaylousberg.itch.io/kaykit-dungeon-pack) | a Toca (dungeon da fatia 1) |
| **KayKit — Skeletons** | Kay Lousberg | CC0 1.0 | [kaylousberg.itch.io](https://kaylousberg.itch.io/kaykit-skeletons) | raça esqueleto (Campas Cinzentas) |
| **Nature Kit** | Kenney | CC0 1.0 | [kenney.nl](https://kenney.nl/assets/nature-kit) | floresta de Brumal |
| **Graveyard Kit** | Kenney | CC0 1.0 | [kenney.nl](https://kenney.nl/assets/graveyard-kit) | Campas Cinzentas |
| **Castle Kit** | Kenney | CC0 1.0 | [kenney.nl](https://kenney.nl/assets/castle-kit) | estruturas de pedra, arenas |
| **Impact Sounds** | Kenney | CC0 1.0 | [kenney.nl](https://kenney.nl/assets/impact-sounds) | impactos de combate, passos |
| **RPG Audio** | Kenney | CC0 1.0 | [kenney.nl](https://kenney.nl/assets/rpg-audio) | sons de interface e objectos |

> CC0 também entra na tabela: é decência, não obrigação. O que for royalty-free sem redistribuição vive em `_local/` (gitignored) e é assinalado aqui na mesma, com a nota "não redistribuído".

## A licença foi lida no ficheiro, não na página

**Os onze packs trazem `License.txt` (ou `License_Standard.txt`) dentro da distribuição, com CC0 1.0 explícito.** Verifiquei um a um por leitura do ficheiro — uma página de download pode mudar; o ficheiro que veio com os assets é a prova, e fica junto deles.

No caso de **Ultimate Monsters**, a distribuição oficial é a pasta Google Drive ligada pela página do pack. O `License.txt` interno foi lido e copiado para `game/assets/models/characters/quaternius-ultimate-monsters/License.txt`; declara literalmente **CC0 1.0 Universal / Public Domain Dedication**. Há uma gralha de empacotamento que não se esconde: o cabeçalho desse ficheiro diz “Ultimate Platformer Pack”, apesar de viver na pasta oficial Ultimate Monsters. A página oficial e os nomes dos modelos confirmam a origem; a concessão CC0 do próprio ficheiro é inequívoca.

## Onde vivem, e o que o Godot vê

`[DECIDIDO]` (Rico, 01-08-2026, ⏳ falta o Mateus) — **os packs CC0 vivem no repositório**, em `art/models/` e `art/audio/`. Ver [`DECISOES.md`](DECISOES.md).

⚠️ **`art/` é a biblioteca; `game/` é o que o jogo carrega.** O projecto Godot tem a raiz em `game/`, por isso **não varre o `art/`** — nada aqui é importado por acidente nem pesa no arranque do editor. O que o jogo usa é copiado para `game/` deliberadamente, um de cada vez.
