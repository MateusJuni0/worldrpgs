# Briefing 2 — para o Fable

**De:** Mateus (via Claude) · **31-07-2026** · **É o único briefing. Cobre tudo.**

---

## Antes de tudo: lê dois ficheiros

1. ⭐ [`../ESTADO.md`](../ESTADO.md) — **o que é verdade hoje.** A spec tem 47 documentos e ~35 decisões, e **onze dos teus documentos de execução são anteriores a decisões que os mudam**
2. [`../DECISOES.md`](../DECISOES.md) — as decisões por ordem, com o que cada uma substitui

---

## O ponto de partida, verificado

**A tarefa 0 está fechada — o código está no repositório.** E não é pela tua palavra:

```
$ godot --headless --path game/ scenes/selftest.tscn
=== 130 passaram, 0 falharam ===
```

**Corri-os eu.** Os 8 commits originais confirmei-os um a um como ancestrais da `main`. É subtree a sério.

### O que temos, em números

| | Temos | A spec promete | Falta |
|---|---|---|---|
| **Documentos de spec** | 47 · 6330 linhas | — | — |
| **Código** | 46 ficheiros · 4033 linhas · 717 de dados | — | — |
| **Testes** | **130, todos a passar** | — | — |
| **Imagens** | 32 (cenários, classes, 7 raças) | — | ⚠️ **zero ícones de objecto** |
| **Armas** | **5** | ~120 | **115** |
| **Armaduras** | **0** | ~30 | **30** |
| **Anéis** | **0** | ~70 | **70** |
| **Feitiços** | **3** | catálogo largo | quase tudo |
| **Inimigos** | **3** | 7 raças + ~61 chefes | quase tudo |
| **Habilidades de classe** | 6 | 6 | ✅ |

⭐ **Esta tabela é o briefing.** O que falta não é arquitectura — é **conteúdo**, e é por isso que a ordem abaixo começa nos catálogos.

---

## ⭐ A instrução mais importante deste documento

> **O catálogo escreve-se em `spec/` E em `game/data/*.json`, no mesmo PR.**

O motor é data-driven por desenho teu — *"nenhum número de combate vive em código"*, e o `game_data.gd` recusa arrancar se os dados divergirem da spec.

**Isso significa que escrever o catálogo não é documentar o jogo: é construí-lo.** Uma arma nova é uma entrada no `weapons.json` + uma linha na spec, e passa a existir a jogar. **Não há passo de "implementação" a seguir.**

⚠️ **Se escreveres o catálogo só na spec, duplicas o trabalho** — e alguém (tu, mais tarde) tem de o transcrever para JSON com a spec já esquecida.

---

## O espírito

> **Liberdade sem limites na criatividade.** Palavras do Mateus. Inventa sistemas, propõe mecânicas, contraria o que está escrito se tiveres razão melhor.
>
> **Os guardas não são contra ideias. São contra pontas soltas.** O modo de falha deste projecto nunca foi uma ideia má — é uma ideia boa **a que ninguém ligou um comando, um teste, uma imagem ou um orçamento**.

### ⭐ As quatro perguntas do fio solto

**Nada entra sem responder às quatro.** Uma em branco é uma ponta solta.

| | Pergunta | Porquê |
|---|---|---|
| **1** | **Como é que o jogador usa isto?** | provaste-o tu: seis habilidades escritas, **zero teclas** |
| **2** | **Como é que se prova que funciona?** | um teste no `self_test.gd`, ou um número medido |
| **3** | **De onde vem a arte e o som?** | ⚠️ **um item sem descrição visual não aparece no ecrã** |
| **4** | **Quanto custa na máquina do Rico?** | 8 GB, Iris Xe. Lei 4 |

⚠️ **E a regra de processo, do Mateus:** *"estudar primeiro completo como funciona o jogo, cada funcionalidade e mecanismo, e depois implementar. A gente não quer o jogo superficial."* **Nada por analogia nem de memória** — estuda-se, escreve-se com **números e fonte**, decide-se depois. Os documentos [`35`](../spec/35-estudo-referencia.md), [`39`](../spec/39-estudo-profundo.md), [`41`](../spec/41-estudo-armas-e-golpes.md), [`42`](../spec/42-estudo-magia.md) e [`43`](../spec/43-estudo-espolio-inventario-mundo.md) são o padrão.

---

# ⭐ Como se escreve um catálogo de 120 armas sem enlouquecer

**Em duas camadas, e a primeira é que interessa.**

### Camada 1 — as famílias (é design, e é onde está o jogo)

**8 famílias de arma, ~9 peças de armadura, as escolas de magia.** Cada uma responde a *uma pergunta que nenhuma outra responde*.

**É esta camada que decide se o jogo é bom.** 8 famílias bem desenhadas dão mais jogo do que 120 armas mal diferenciadas — porque é a família que traz o conjunto de movimentos, os frames, o dano de interrupção, a hiper-armadura.

### Camada 2 — as instâncias (é preenchimento, e é incremental)

As 120 armas **herdam** da família e variam em: requisitos, escala por atributo, dano, peso, arte da arma, **descrição visual** e **descrição de item** (a que conta a lore — [`39`](../spec/39-estudo-profundo.md) §12).

⭐ **A camada 2 pode entrar aos poucos, PR a PR.** A camada 1 não — está feita ou não está.

⚠️ **Coluna `Fatia 1?` em tudo.** É o que separa "o jogo completo" de "o que se constrói primeiro". **Sem ela o catálogo vira um plano de dez anos.**

---

# A ordem

```
1. CATÁLOGOS (camada 1 + fatia 1 da camada 2)
       ├──► desbloqueia AS IMAGENS
       └──► desbloqueia O CONTEÚDO (o catálogo É o jogo)
2. SISTEMAS que faltam
3. MUNDO
4. ALINHAMENTO dos documentos antigos
```

---

# Tarefa 1 — os catálogos

## 1a. Magia (WP4) — ⭐ o maior e o mais importante

O Mateus: *"o mago vai ser o mais apelão. As magias fazem tudo — cura, dano, buffs, elementos. Vamos ser bem vastos em magia."* **É a classe favorita dele.**

Base: [`../spec/42-estudo-magia.md`](../spec/42-estudo-magia.md). Falta encher:

- **As quatro escolas** (§1) — e a do mal escala com o **menor** dos dois atributos: a mais forte e a mais cara, sem tranca nenhuma
- ⭐ **A grelha de verbos** (§7) — **nenhuma casa pode ficar vazia.** Dano directo · área · ao longo do tempo · cura (incluindo **do parceiro à distância**) · reforço próprio · reforço de arma · enfraquecer · utilidade · defesa
- **A ficha de cada feitiço** (§9), 14 colunas, com ⚠️ **como o inimigo o esquiva — nunca "não dá"**
- ⭐ **A tabela de melhoria de 6 níveis** (§6): força · **área** · **lançamentos**. Regra: **um nível em cada dois dá área ou lançamentos, nunca só força**
- **Feitiços são únicos** — nunca há dois iguais no mundo

⚠️ **A tensão 28 é tua para resolver se souberes melhor:** se a magia faz tudo, o mago é a classe correcta e a Lei 3 cai. Há cinco travões propostos em [`42`](../spec/42-estudo-magia.md) §8 — **se tiveres um melhor, propõe.**

## 1b. Armas e armaduras (WP5)

Base: [`../spec/41-estudo-armas-e-golpes.md`](../spec/41-estudo-armas-e-golpes.md).

- ⚠️ **Reescrever por FAMÍLIA, não por classe.** 20 armas "do guerreiro" reintroduz por trás a divisão que a Lei 3 recusa pela frente
- **Os 11 golpes por família** (§1) — **sete não estão declarados em lado nenhum**: cadeia de leves, leve→pesado, em corrida, a rolar, a saltar, de cima, empurrão. O golpe em corrida é o que torna a distância jogável; o golpe a rolar é o que faz a esquiva ser ofensiva
- ⭐ **Cada família traz uma frase que diz ONDE É MÁ** (§2). Se não a consegues escrever, a família não está desenhada — está listada
- **Capricho nas katanas e nas espadas** — pedido directo. A katana é *a arma de quem ataca no tempo do inimigo*
- **Dano de interrupção e frames de hiper-armadura** por família (§4)
- **Arte a 1 mão e a 2 mãos**, verbos diferentes
- **~30 armaduras**, habilidade **por peça** e não por conjunto, passivas ou condicionais
- **~70 anéis, 10 dedos** ([`37`](../spec/37-aneis-e-elementos.md)) — sem repetir
- **Melhoria de armas**: reforço (números) e infusão (**troca** de escala = Lei 2)
- **Estados alterados** — veneno, sangramento, queimadura. Nunca foram escritos

## 1c. Bestiário (WP6)

- ⭐ **O baralho de espólio de 10 cartas por inimigo** ([`43`](../spec/43-estudo-espolio-inventario-mundo.md) §2) — é o que cumpre a garantia do Mateus
- **Ficha de 11 colunas por ataque** ([`38`](../spec/38-ataques-e-honestidade.md) §3), com ⚠️ **"como se escapa" obrigatório e nunca "não dá"**
- **3–5 ataques, e os três são três perguntas diferentes** — um que se apara, um que só se esquiva, um que obriga a mexer o pé
- **O som que anuncia cada ataque**
- **Almas por inimigo** — e com o tecto de 10 reaparições, **soma o orçamento total de almas por zona**
- **Massa de cada inimigo**, para o empurrão

---

# Tarefa 2 — os sistemas que faltam

**Não é investigação — é integração.** Todos com números já estudados.

| Sistema | Onde está |
|---|---|
| ⭐ **Piso de 30%** — nenhuma defesa reduz um golpe abaixo disso | [`39`](../spec/39-estudo-profundo.md) §1 |
| ⭐ **Soft caps aos ~40** e curva de saturação | [`39`](../spec/39-estudo-profundo.md) §2 |
| **Defesa por curva sobre a razão + absorção multiplicativa** | [`39`](../spec/39-estudo-profundo.md) §1 |
| ⭐ **Interrupção e hiper-armadura** — sem isto armas lentas não existem | [`39`](../spec/39-estudo-profundo.md) §4, [`41`](../spec/41-estudo-armas-e-golpes.md) §4 |
| ⭐ **Contra-ataque +30%** — com som e faísca próprios, senão ninguém aprende | [`41`](../spec/41-estudo-armas-e-golpes.md) §3 |
| **Stamina: 1 ponto chega para agir · negativo com tecto** | [`41`](../spec/41-estudo-armas-e-golpes.md) §5 |
| **Bloqueio, estabilidade, quebra de guarda** | [`41`](../spec/41-estudo-armas-e-golpes.md) §6 |
| ⭐ **Cargas repartidas entre curar e usar** | [`39`](../spec/39-estudo-profundo.md) §7 |
| ⭐ **Contador de 10 mortes por sala** | [`40`](../spec/40-decisoes-espolio-magia-inventario.md) §1 |
| ⭐ **Controlos configuráveis** | [`45`](../spec/45-controlos-configuraveis.md) |
| ⭐ **Carregamento por área + porta de nevoeiro** | [`43`](../spec/43-estudo-espolio-inventario-mundo.md) §6 |
| **Curva de nível cúbica** (a actual é linear) · "XP"→"almas" | [`35`](../spec/35-estudo-referencia.md) §3 |
| **Mochila sem limite, só o equipado pesa** | [`40`](../spec/40-decisoes-espolio-magia-inventario.md) §9 |
| **Teste do rolamento: 10 em 10, sem excepção** | [`38`](../spec/38-ataques-e-honestidade.md) §2 |

### ⭐ Controlos configuráveis — já tens metade feito

O `data/controls.json` **já constrói o mapa em runtime**. Falta o ecrã.

`[DECIDIDO]` — **o jogador escolhe as teclas dentro do jogo.** Isto **dissolve a guerra do parry**: `Q` e toque de `RMB` ficam os dois.

⚠️ **Mas os valores de fábrica continuam a ser desenho** — são o que 100% dos jogadores experimenta primeiro. Fecha o mapa **de uma vez**: o `C` e o `Ctrl` que puseste já apareciam como ocupados no [`34`](../spec/34-catalogo-e-comandos.md) §2.

⚠️ **E a regra que se esquece sempre:** o jogo mostra **a tecla do jogador**, nunca a de fábrica. Se alguém remapeia a esquiva e o `F2` continua a dizer `Space`, **o F2 passa a mentir**. Barato agora, caro depois.

---

# Tarefa 3 — o mundo (WP8)

- ⚠️ **6 zonas contra 10+ biomas aprovados.** Resolve
- ⭐ **Toda a zona fecha um círculo** para um sítio já visitado, e **o atalho abre-se do lado de dentro**. Pelo menos um círculo por zona é **vertical**
- ⭐ **Ponto de descanso à vista da porta de cada chefe.** Sem excepção — a dois, a corrida de volta multiplica-se porque um espera pelo outro
- **Desnível desenhado com a tabela de queda à frente** ([`36`](../spec/36-fisica.md) §2): 4 m é atalho, 20 m é morte
- **Paredes falsas** — pelo menos uma que esconda **uma zona inteira**. ⚠️ Sem mensagens de estranhos, **o cenário dá a pista sozinho**
- **Baús**, e o mímico **respira** — é telegrafia, não armadilha
- ⚠️ **Traçado e orçamento de memória desenham-se juntos**

---

# Tarefa 4 — alinhar os documentos antigos

Por último — é limpeza, e metade resolve-se ao reescrever os catálogos. A lista está no [`ESTADO.md`](../ESTADO.md) §2.

⚠️ **Reparo antigo ainda aberto:** nenhum dos 11 documentos traz a tabela `eles · nós · diferença` nem cita fontes, como manda o [`31-referencias.md`](../spec/31-referencias.md).

---

# ⭐ O que preciso de ti para gerar as imagens

**32 imagens existem — cenários, classes, as 7 raças. Não há um único ícone de objecto**, porque ninguém sabe ainda quais são.

**Uma coluna `descrição visual` em tudo o que vai ter imagem.** Uma frase, mas específica:

> ❌ *"Katana"* — não gera nada
> ✅ *"Lâmina curva estreita, aço polido, punho enfaixado a tecido escuro, 90 cm"* — gera

| O que | O que a coluna precisa de dizer |
|---|---|
| **Armas** | silhueta, material, comprimento, o que a distingue na família |
| **Armaduras** | material, silhueta, estado (novo / gasto / partido) |
| **Feitiços** | cor, forma, elemento, o que se vê quando acerta |
| **Anéis** | material, pedra, motivo |
| **Consumíveis** | forma, cor |

⚠️ **E `Fatia 1?` em tudo** — é o que me diz o que gerar primeiro. Sem isso, ou gero 300 imagens ou nenhuma.

---

# Skills

**Secundárias — o `game/CLAUDE.md` rende mais.** Mas estas ajudam mesmo:

| Skill | Quando |
|---|---|
| `brainstorming` | **antes** de inventar sistema novo |
| `writing-plans` / `executing-plans` | qualquer tarefa com mais de 3 passos |
| `test-driven-development` | ⭐ já o fazes — 130 testes contra a spec é isto |
| `systematic-debugging` | quando um número não bate e não se percebe porquê |
| `verification-before-completion` | **antes** de dizer "está feito" |
| `karpathy-guidelines` | antes de código não-trivial |
| `using-git-worktrees` | dois pacotes em paralelo sem te pisares |

---

# Como entregar

| | |
|---|---|
| **Reserva primeiro** | pacote **e** número de ficheiro em [`../COORDENACAO.md`](../COORDENACAO.md). **46+ livre** |
| **PRs pequenos e temáticos** | um pacote por PR. O #11 trouxe 1333 linhas e 11 pacotes, e o conflito foi feio |
| **Spec + `game/data` no mesmo PR** | ⭐ é a instrução principal deste briefing |
| **Corre os dois** | `node tools/check-coerencia.mjs --base origin/main` **e** o `selftest.tscn` |
| **Actualiza no mesmo PR** | [`../SPEC.md`](../SPEC.md), [`../spec/99-perguntas-abertas.md`](../spec/99-perguntas-abertas.md), [`../ESTADO.md`](../ESTADO.md) |
| **Etiqueta** | `[FABLE]` o que decides (razão **e** alternativa) · `[PROTO]` o que o protótipo assume · `[TENSÃO]` o que **não** decides |
| **Não sobrevendas** | dizer o que **ainda não está provado** é o que torna um relatório útil |

---

# O risco, dito uma vez

~120 armas + 30 armaduras + 70 anéis + catálogo de magia largo + 61 chefes + 10+ biomas, **por duas pessoas e dois agentes**.

**Os donos sabem e decidiram avançar. Não é para cortares nada.** As duas alavancas:

- ⭐ **Camada 1 antes da camada 2** — 8 famílias bem desenhadas valem mais que 120 armas mal diferenciadas
- ⭐ **A coluna `Fatia 1?`** — é o que impede o catálogo de virar um plano de dez anos

**Tens liberdade sem limites. Usa-a — e deixa cada ideia com as quatro pontas atadas.**
