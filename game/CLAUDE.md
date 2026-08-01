# game/CLAUDE.md — contexto para quem escreve código aqui

Lê isto antes de tocar em `game/`. Para o contexto do projeto inteiro, sobe: [`../CLAUDE.md`](../CLAUDE.md) e [`../ESTADO.md`](../ESTADO.md).

## O que é isto

O protótipo jogável do WorldRPGs. **Godot 4.7.1-stable**, renderer **Mobile**. Vive aqui desde 31-07-2026, com os 8 commits originais preservados por `git subtree` — não é um despejo de ficheiros.

**Alvo:** 1920×1080 @ 60 fps, **Intel Iris Xe integrados, 8 GB RAM** — a máquina do Rico. É a Lei 4, e manda em tudo.

## ⭐ A regra de ouro

> **Nenhum número de combate vive em código.** Vivem em `data/*.json`, e vêm da spec.

`src/autoload/game_data.gd` carrega-os e **valida-os contra a spec ao arrancar — recusa arrancar se divergirem**. Afinar uma janela é editar JSON e voltar a correr; não é recompilar nada.

| Ficheiro | O que guarda |
|---|---|
| `data/combat.json` | frames, janelas, i-frames, stamina |
| `data/weapons.json` | as armas, com frames e multiplicadores |
| `data/attributes.json` | atributos e curvas |
| `data/spells.json` | os feitiços |
| `data/enemies.json` | o bestiário |
| `data/abilities.json` | habilidades de classe |
| `data/controls.json` | ⭐ o mapa de teclas — ver [`../spec/45-controlos-configuraveis.md`](../spec/45-controlos-configuraveis.md) |
| `data/graphics.json` | orçamentos de render |

⚠️ **Se te apanhares a escrever um `0.38` dentro de um `.gd`, pára.** Esse número pertence a um JSON, e provavelmente já lá está.

## A spec é lei

**Se o código e a spec discordarem, é o código que está errado** — até alguém mudar a spec. E a mudança da spec **vai no mesmo PR** que a do código. É a regra do repositório, e só funciona porque os dois vivem aqui.

Quando construir revelar que um número da spec não funciona — **e vai revelar** — isso é bom e é o objectivo. Mas escreve-se: a spec muda, com a razão e a medição ao lado.

## Antes de dizer que está feito

```bash
# auto-teste corrente: 8433 verificações contra a spec e os catálogos
godot --headless --path . scenes/selftest.tscn
```

E o guarda da spec, da raiz do repositório:

```bash
node tools/check-coerencia.mjs --base origin/main
```

## Correr

`JOGAR.bat` — a fatia inteira · `JOGAR-ARENA.bat` — arena limpa para sentir o combate.
Em jogo: `F1` fps · `F2` comandos · `F3` liberta o rato · `F5` reinicia · `F6` troca de classe.

## ⭐ As quatro perguntas do fio solto

Valem aqui tanto como na spec. **Nada entra sem responder às quatro:**

1. **Como é que o jogador usa isto?** — uma acção sem entrada não existe no jogo. Já aconteceu: seis habilidades de classe escritas, zero teclas
2. **Como é que se prova que funciona?** — um teste no `self_test.gd`, ou um número medido
3. **De onde vem a arte e o som?** — pack, geração, ou sintetizado em código como os 12 efeitos actuais
4. **Quanto custa na máquina do Rico?** — se mexeste no render, mede. `PERF.md` tem o método

## O que nunca entra

| | |
|---|---|
| **Builds e binários gerados** | `.exe`, `.pck`, `.zip`, `.godot/` — o `.gitignore` trava-os. ⚠️ **Modelos, texturas e áudio NÃO são travados por nada** (`.glb`, `.png`, `.ogg` passam): os assets CC0 vivem de propósito em [`../art/`](../art/) e vêm para cá **um a um, deliberadamente** ([`../CREDITS.md`](../CREDITS.md)). Nunca largues um pack inteiro aqui dentro — o Godot importa tudo o que encontrar em `game/`, e o arranque do editor paga por cada ficheiro |
| **Números de combate em `.gd`** | pertencem a `data/*.json` |
| **Caminhos absolutos** | nada de `C:\Users\...` — o repositório é público |
| **Segredos** | o repositório é público |
| **Assets de jogos comerciais** | [`../spec/31-referencias.md`](../spec/31-referencias.md) — a linha não se atravessa |

## Etiquetas, também no código

- `[PROTO]` — o protótipo assumiu para poder correr. **Não é decisão**, e alguém tem de a tomar
- `[FABLE]` / `[CLAUDE]` — decidido por um agente, com razão e alternativa descartada
- `[TENSÃO]` — **não se decide.** Propõe-se e recomenda-se; decidem o Mateus e o Rico

## Antes de começar

**Reserva em [`../COORDENACAO.md`](../COORDENACAO.md)** — o sistema em que vais mexer, e o número do ficheiro se criares um em `spec/`. Dois agentes escrevem aqui.
