# WorldRPGs — protótipo da fatia 1

Protótipo jogável do combate e da zona descritos em [`spec/`](../spec).
Construído numa noite. **Isto é código; a spec é lei** — todos os números vêm de lá.

> **Motor:** Godot **4.7.1-stable** (oficial, `winget install --id=GodotEngine.GodotEngine`)
> **Alvo:** 1920×1080 @ 60 fps, Intel Iris Xe integrados, 8 GB RAM
> **Medido nesta máquina:** ver [PERF.md](PERF.md) — resposta com números à tensão 0b da spec

---

## Abrir e jogar (dois cliques)

**Duplo clique em `JOGAR.bat`.**

É tudo. O `.bat` encontra o Godot sozinho (no winget, no PATH, ou ao lado dele) e abre o jogo directamente — sem passar pelo editor.

- `JOGAR.bat` — a fatia inteira: Brumal → a Toca → Vorgar
- `JOGAR-ARENA.bat` — arena limpa com um lanceiro e um brutamontes, para sentir o combate sem floresta a meio

Se o Godot não estiver instalado, o `.bat` diz o comando exacto para o instalar.

**Para abrir no editor:** abre o Godot, *Import*, escolhe o `project.godot` desta pasta.

---

## Comandos

Vêm de `spec/01-combate.md`. Em jogo, **F2** mostra-os no ecrã.

| Acção | Tecla |
|---|---|
| Mover | `WASD` (correr 5,0 m/s — o passo por defeito) |
| Andar (3,0 m/s) | segurar `Ctrl` |
| Sprint (7,0 m/s, 8 stamina/s) | segurar `Space` |
| Esquiva | toque em `Space` — 0,60 s, invencível nos frames 5–23 inclusivos (317 ms) |
| Câmara | rato |
| Ataque leve | `LMB` |
| Ataque pesado | `Shift`+`LMB` (com machadão, segurar carrega) |
| Bloqueio | segurar `RMB` |
| Bash de escudo | `LMB` com o escudo levantado |
| Parry | `Q` — janela de 8 frames |
| Lock-on | `Tab` |
| Conjurar | `C` · magia seguinte `F` |
| Trocar de arma | `[` e `]` |

**Teclas de sessão:** `F1` fps · `F2` comandos · `F3` liberta o rato · `F5` reinicia · `Esc` sai.

### Como se joga isto

O brutamontes é o professor: **todos** os golpes dele dão para aparar, e todos levantam a arma durante meio segundo ou mais. O lanceiro é o contrário — rápido, e quase tudo nele só se esquiva. Aprende o parry no brutamontes e a esquiva no lanceiro; o Vorgar exige os dois.

Um parry certeiro parte a postura do inimigo (fica branco) — bate logo a seguir para o riposte, que dá 2,5× de dano e é invencível enquanto dura.

**As cores dizem tudo:** amarelo a crescer = está a preparar um golpe · vermelho = o golpe está a acertar agora · branco = postura partida, castiga.

---

## O que existe

| | |
|---|---|
| **Combate (WP1)** | máquina de estados completa: esquiva com i-frames, parry com riposte, bloqueio com guarda quebrada, stamina com atraso e histerese, hit-stun, poise/postura, hiper-armadura, lock-on, combos e cancelamentos |
| **5 armas** | adaga, espada longa, machadão (pesado carregável), cajado, escudo — frames e MV exactos da spec |
| **6 classes** | atributos e equipamento de arranque do WP2. Qualquer uma pega em qualquer arma (Lei 3) |
| **3 magias** | Dardo (projéctil), Ruína (área), Égide (barreira com hiper-armadura), com bolsa de cargas partilhada |
| **2 inimigos** | orc lanceiro (ensina a esquiva) e orc brutamontes (ensina o parry), com anti-kite aos 4 s |
| **Vorgar** | chefe de 2 fases — a segunda muda padrões, não números. Reset total quando morres |
| **Brumal + a Toca** | floresta greybox com névoa, caminho, entrada escondida sob a árvore morta, 3 salas e a arena |
| **Morte** | renasces em ~1,2 s, não se perde nada, os inimigos voltam (o alvo da spec era < 30 s) |
| **HUD** | vida, stamina, cargas, barra do chefe |

Inclui o **game feel do WP1B**: paragem de impacto (3 f num leve, 6 f num pesado, **10 f num parry**), registo de comandos com a esquiva a ter prioridade, e a câmara nos números da spec (4,0 m / 4,8 m com lock-on, FOV 55°, sem aceleração de rato).

## O que falta

Por ordem de importância — o detalhe está em [PERGUNTAS.md](PERGUNTAS.md).

1. **As 6 habilidades de classe** — o WP3 chegou já de madrugada e escreve-as (Ímpeto, Eco, Provocação, Passo Sombra, Fúria, Julgamento). Os atributos já estão implementados; **as habilidades não**. Sem elas, as classes só se distinguem por números — o que a Lei 2 recusa
2. **Curar** — não há forma nenhuma de recuperar vida sem morrer (pergunta 7 da spec)
3. **⚠️ Os dois mapas de comandos da spec discordam** — o WP1 põe o parry em `Q`, o WP1B põe-no no toque do `RMB`. Não é meu para decidir; ver P2
4. **Rede / co-op (WP10)** — fora do escopo desta noite, e `[EM ABERTO]` na spec
5. **XP e níveis** — a curva do WP2 está nos dados, mas não há progressão
6. **Arco e Batedor** — fatia 2, por decisão da spec
7. Animações, som, tremor de ecrã e partículas de impacto (WP12)

---

## Mexer nos números sem recompilar

**Nenhum número de combate está escrito em código.** Está tudo em `data/`:

| Ficheiro | O quê |
|---|---|
| `combat.json` | janelas, custos, stamina, poise, lock-on (spec/01) |
| `weapons.json` | frames e MV das armas + dano base e requisitos (spec/01 + spec/11) |
| `enemies.json` | PV, DEF, dano, postura, padrões de ataque (spec/11) |
| `attributes.json` | os 6 atributos, fórmulas e classes (spec/11) |
| `spells.json` | as 3 magias |
| `controls.json` | o mapa de teclas — remapear é editar aqui |
| `graphics.json` | presets de qualidade `alto`/`medio`/`baixo` |

Editas o JSON, voltas a abrir, está afinado.

**O jogo protege-se contra si próprio:** ao arrancar, o `GameData` verifica os dados contra a spec e grita se algo sair fora — telegrafo inimigo abaixo de 0,5 s, perseguição igual ou mais rápida que o correr do jogador, golpes-para-matar fora das janelas do WP1, brutamontes com um golpe não aparável.

---

## Verificar e medir

**Auto-teste contra a spec** (86 verificações, conta frames um a um):

```
godot --path . --headless res://scenes/selftest.tscn
```

**Medir desempenho** (escreve JSON e sai):

```
godot --path . --rendering-method mobile -- --bench --scene=perf --seconds=60 --label=o-que-quiseres
```

Opções: `--vsync=on` mede se *aguenta* 60; sem ela (defeito) mede a **folga** real.
`--scene=` aceita `perf`, `combat` ou `zone`. `--quality=` aceita `alto`, `medio`, `baixo`.

---

## Estrutura

```
data/      os números — a spec transformada em JSON
src/
  autoload/  GameData (carrega e valida), Bench (mede)
  player/    máquina de estados, câmara, lock-on
  enemies/   IA por padrões
  combat/    stamina, dano, magias
  world/     construtor do greybox
  ui/        HUD
  tests/     auto-teste contra a spec
scenes/    main.tscn e selftest.tscn (o mundo é construído em código)
```

---

- [PERF.md](PERF.md) — os fps medidos, frio e quente, e porque é este o renderer
- [DECISOES-PROTOTIPO.md](DECISOES-PROTOTIPO.md) — o que decidi sozinho, e porquê
- [PERGUNTAS.md](PERGUNTAS.md) — o que **não** decidi, porque não é meu para decidir
