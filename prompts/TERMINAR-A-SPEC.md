# Terminar a spec — para o Opus 5

> ⚠️ **PROMPT HISTÓRICO, CONCLUÍDO NA TAREFA 4.** Não executar de novo nem usar as contagens abaixo como estado corrente. O resultado está nos contratos [`70`](../spec/70-fecho-dos-sistemas-de-combate.md)–[`73`](../spec/73-fecho-dos-buracos-de-integracao.md); o retrato actual vive no [`ESTADO`](../ESTADO.md).

**De:** Mateus (via Claude) · **01-08-2026** · **É o prompt para fechar a especificação.**

---

## O que é isto

O **WorldRPGs** é um souls-like 3D para PC, co-op para dois, feito pelo **Mateus** e pelo **Rico** como hobby. A spec tem **58 documentos**, o jogo **já se joga** (Godot 4.7.1, 226 auto-testes a passar), e as **três primeiras voltas de catálogo** estão feitas.

**A tua tarefa é fechar o que falta.** Não é rever nem reorganizar — é **escrever os sistemas que a spec assume e nunca definiu**, e acabar os catálogos.

---

## Lê estes cinco, por esta ordem, antes de escrever uma linha

| # | Ficheiro | Porquê |
|---|---|---|
| **1** | [`../ESTADO.md`](../ESTADO.md) | ⭐ **o que é verdade hoje.** 58 documentos e ~45 decisões; onze documentos de execução são **anteriores** a decisões que os mudam |
| **2** | [`../LACUNAS.md`](../LACUNAS.md) | ⭐ **a tua lista de trabalho.** Tudo o que falta, por prioridade, com a origem de cada buraco |
| **3** | [`../DECISOES.md`](../DECISOES.md) | as decisões por ordem, e **o que cada uma substitui** |
| **4** | [`../CLAUDE.md`](../CLAUDE.md) | as quatro leis, as etiquetas, e como se revê |
| **5** | [`../docs/AUDITORIA-CODEX-2026-08-01.md`](../docs/AUDITORIA-CODEX-2026-08-01.md) | ⚠️ auditoria independente. **Secção 4 (risco de escopo) antes de encheres catálogos** |

---

## As quatro leis — tudo o que escreveres é medido contra elas

| | |
|---|---|
| **1** | **Ganha-se com habilidade, não com nível.** O nível reduz a margem de erro, nunca abre uma porta. Sem gating, sem grind obrigatório |
| **2** | ⭐ **As melhorias dão OPÇÕES, não números.** É a lei mais fácil de quebrar sem dar por isso — *"+30% de dano"* quebra-a; *"passa a perfurar"* cumpre-a |
| **3** | **Qualquer classe pega em qualquer arma.** Diferenciação por atributos e traços, nunca por bloqueio |
| **4** | **A máquina alvo manda:** 8 GB, Intel Iris Xe integrados, 1080p @ 60 fps. **Queda de fotogramas num souls-like não é feio, é injusto** |

---

## ⭐ As quatro perguntas do fio solto

**Nada entra sem responder às quatro.** Uma em branco é uma ponta solta, e pontas soltas descobrem-se seis meses depois.

| | Pergunta |
|---|---|
| **1** | **Como é que o jogador usa isto?** — uma acção sem entrada não existe no jogo |
| **2** | **Como é que se prova que funciona?** — um teste em `game/src/tests/self_test.gd`, ou um número medido |
| **3** | **De onde vem a arte e o som?** — um item sem **descrição visual** não aparece no ecrã |
| **4** | **Quanto custa na máquina do Rico?** |

---

## ⭐ A instrução principal: o catálogo escreve-se em dois sítios

> **`spec/` E `game/data/*.json`, no mesmo PR.**

O motor é data-driven: `game/src/autoload/game_data.gd` **recusa arrancar** se os dados divergirem da spec. **Escrever o catálogo não é documentar o jogo — é construí-lo.** Uma arma nova é uma entrada no JSON + uma linha na spec, e passa a existir a jogar.

---

# A ordem do trabalho

## 🔴 FASE 1 — as duas fundações que travam tudo

**Estas duas vêm primeiro porque outras coisas já dependem delas.**

### 1.1 Sistema de saves

⚠️ **Não existe uma linha, e já tem três clientes:** progresso, inventário, e o mapa ([`57`](../spec/57-mapa-e-minimapa.md) §6).

**Tem de dizer:** o que se guarda · quando se guarda · **escrita atómica** (nunca um save corrompido a meio) · ⭐ **como funciona a dois** — cada um tem o seu save, ou há um save da dupla? · o que acontece se um desliga a meio de um chefe · e o ciclo novo (abaixo).

### 1.2 Arte: os packs CC0

⚠️ **Texturas, modelos 3D e som são ZERO.** O [`22-assets.md`](../spec/22-assets.md) escolheu as fontes (KayKit, Quaternius) e **ninguém as descarregou**.

**Não é escrita — é execução.** Descarregar, importar em `game/`, e substituir as cápsulas por modelos. ⚠️ **A animação de esqueleto é o único risco técnico ainda por medir** ([`44`](../spec/44-prototipo.md)); mede-se aqui.

---

## 🟠 FASE 2 — os sistemas que a spec assume e nunca escreveu

Ordenados por quanto custam se ficarem para depois.

| | O quê | O que tem de responder |
|---|---|---|
| **2.1** | ⭐ **O fim do jogo** | mata-se o Ultra e **depois?** Nunca foi escrito. **Sem isto não há razão para o nível 100** |
| **2.2** | ⭐ **Ciclo novo (NG+)** | o [`40`](../spec/40-decisoes-espolio-magia-inventario.md) §1 diz *"até ao próximo ciclo"* — **e o ciclo não existe** |
| **2.3** | ⭐ **Arena de chefe** | 13 chefes precisam de 13 arenas. Sem regras de tamanho, obstáculos, refúgio e bordo, **saem 13 círculos vazios** |
| **2.4** | ⭐ **Acessibilidade auditiva** | ⚠️ **o mais grave que ninguém viu.** O [`38`](../spec/38-ataques-e-honestidade.md) §3 **obriga** a que cada ataque se anuncie por som, e a 1.ª pessoa depende disso. **Escrevemos uma regra que tranca o jogo a quem não ouve bem.** Precisa de indicador visual equivalente, e **desde já** — enxertado no fim obriga a mexer em todas as fichas |
| **2.5** | ⭐ **Como se afinam os 226 números** | centenas de valores marcados *"validam-se a jogar"* e **ninguém escreveu como**. Sem método, os números de partida viram finais por omissão |
| **2.6** | **Criação de personagem** | o primeiro ecrã do jogo. Classe, aspecto, nome |
| **2.7** | **Música e ambiente** | existem 12 sons sintetizados e mais nada |

---

## 🟠 FASE 3 — acabar os catálogos

⚠️ **Lê primeiro** [`55-formas-de-feitico.md`](../spec/55-formas-de-feitico.md) e [`54-mana-meditacao-e-tracos-de-classe.md`](../spec/54-mana-meditacao-e-tracos-de-classe.md) — **o modelo de magia mudou** e o trabalho anterior assume slots que já não existem.

### 3.1 Magia (WP4) — o maior

**Base:** [`42`](../spec/42-estudo-magia.md) (as escolas) · [`52`](../spec/52-mago-do-mal.md) (a escola vermelha, **do Mateus — herda-se, não se reescreve**) · [`55`](../spec/55-formas-de-feitico.md) (as formas).

- ⚠️ **Sem slots.** O limite é **mana**, que **não regenera** — recupera-se a **meditar 40 s** (mas não os frascos)
- ⭐ **Cada feitiço declara: forma de entrega · onde NÃO serve · como o inimigo lhe escapa** (varia por forma)
- **Faltam três formas:** perseguidor · chuva · ⭐ **forma de arma** (golpe corpo a corpo feito de magia — resolve o *"mago frágil ao perto"* melhor do que a besta)
- **A grelha de verbos** ([`42`](../spec/42-estudo-magia.md) §7) — **nenhuma casa pode ficar vazia**
- **Tabela de melhoria de 6 níveis** por feitiço: um nível em cada dois dá **área ou lançamentos**, nunca só força

### 3.2 Bestiário (WP6)

⚠️ **A ficha de ataque mudou** — [`38`](../spec/38-ataques-e-honestidade.md) §1b e §2b:

- ⭐ **Tipo de contacto:** instantâneo (3–6 frames) · volume móvel (uma vez por passagem) · **volume persistente** (intervalos declarados)
- ⭐ **Vector de fuga**, de uma lista de nove. ⚠️ **Nunca "funciona sempre"**, e **tem de ser legível na pose**
- **O som que anuncia cada ataque** — e agora também o **equivalente visual** (2.4)
- **O baralho de espólio de 10 cartas** ([`43`](../spec/43-estudo-espolio-inventario-mundo.md) §2)
- **Almas por inimigo**, e ⭐ **o total por zona** — com o tecto de 10 reaparições, cada zona tem orçamento fixo

### 3.3 Chefes (WP7) — **13, não 61**

[`53`](../spec/53-chefes-ritmo-e-o-mago-forte.md): 1 Ultra + 12 guardiões + 12 subchefes + **~36 nomeados**.

- ⭐ **O subchefe vive no mundo** — sem arena, sem porta, sem música, **e pode-se fugir dele**
- ⭐ **O nomeado** é um inimigo comum com nome, mais vida e **um ataque a mais**. **Não é produção nova**
- ⭐ **As portas de história:** cada bioma declara **2–3 sítios que poderiam existir e não existem**, e o mundo fala deles. ⚠️ **Nunca podem parecer um erro** — toda a porta traz a razão numa descrição ou num sinal

### 3.4 Armas, armaduras e anéis (WP5) — acabar

- ⚠️ **Os 7 golpes universais** ainda não estão declarados: cadeia de leves, leve→pesado, em corrida, a rolar, a saltar, de cima, empurrão
- 🔴 **A melhoria de armas a +10%/nível quebra a Lei 2** ([auditoria](../docs/AUDITORIA-CODEX-2026-08-01.md) erro 6). **Deve dar postura, arte nova, troca de escala ou conversão elemental — não números**
- **Estados alterados** — veneno, sangramento, queimadura. Nunca foram escritos
- **~70 anéis**, e o **Assassino** ([`12`](../spec/12-classes.md)), com os três guardas já escritos

### 3.5 Mundo (WP8)

- **12 biomas**, travessia de **8–12 min**, descanso **por arco** e não a cada porta
- ⭐ **Toda a zona fecha um círculo**, e o atalho **abre-se do lado de dentro**
- ⭐ **Verticalidade** — a mesma pegada a três alturas é **3× o percurso com 1× de chão**. É a alavanca mais barata para o mapa ser maior
- ⚠️ **A leitura do mapa decide-se ANTES do traçado** ([`57`](../spec/57-mapa-e-minimapa.md) §5) — senão há zonas impossíveis de mapear
- ⚠️ **O traçado e o orçamento de memória desenham-se juntos**

---

## 🟠 FASE 4 — alinhar o que ficou para trás

| | |
|---|---|
| ⚠️ **A fatia 1 ([`10`](../spec/10-fatia-1.md)) foi aprovada antes de ~40 decisões** — fala de cargas de magia que já não existem, de 6 zonas, de espólio sem baralho |
| **Onze documentos de execução** são anteriores a decisões que os mudam — a lista está no [`ESTADO.md`](../ESTADO.md) §2 |
| **Nenhum dos 11 traz a tabela `eles·nós·diferença` nem cita fontes**, como manda o [`31`](../spec/31-referencias.md). Os documentos 35, 39, 41, 42, 43, 48 e 55 são o formato |

---

## Como entregar

| | |
|---|---|
| **Reserva primeiro** | pacote **e** número de ficheiro em [`../COORDENACAO.md`](../COORDENACAO.md), com push imediato. **58+ livre** |
| **PRs pequenos** | um sistema por PR. O #11 trouxe 1333 linhas e o conflito foi feio |
| **Spec + `game/data` no mesmo PR** | |
| **Corre os dois** | `node tools/check-coerencia.mjs --base origin/main` **e** `godot --headless --path game/ scenes/selftest.tscn` |
| **Actualiza no mesmo PR** | [`../SPEC.md`](../SPEC.md), [`../ESTADO.md`](../ESTADO.md), [`../LACUNAS.md`](../LACUNAS.md), [`../spec/99-perguntas-abertas.md`](../spec/99-perguntas-abertas.md) |
| **Etiqueta** | `[FABLE]` o que decides (razão **e** alternativa descartada) · `[PROTO]` o que se assume para correr · `[TENSÃO]` o que **não** decides |
| ⚠️ **Encontraste um buraco novo?** | **escreve-o no [`LACUNAS.md`](../LACUNAS.md) no mesmo acto.** Um buraco num comentário de PR perde-se |

---

## O que NÃO fazer

| | |
|---|---|
| ❌ **Não decidas uma `[TENSÃO]`** | propõe e recomenda. Decidem o Mateus e o Rico |
| ❌ **Não reescrevas a escola vermelha** ([`52`](../spec/52-mago-do-mal.md)) | é o personagem do Mateus, e as decisões dele estão tomadas |
| ❌ **Não mexas em `[DECIDIDO]`** | detalha por baixo, nunca por cima |
| ❌ **Não sobrevendas** | dizer o que **ainda não está provado** é o que torna um relatório útil |
| ❌ **Não escrevas código nos documentos de spec** | a spec descreve o que o jogo faz; o `game/` implementa |

---

## ⚠️ O risco, dito uma vez

**Duas pessoas e dois agentes.** A [auditoria](../docs/AUDITORIA-CODEX-2026-08-01.md) §4 estimou o que honestamente não fica feito, e deu uma **ordem de corte com menor perda**:

> 1.ª pessoa → 48 chefes reclassificados → 5 slots de armadura → 6 slots de anel → armas acima de 24 → feitiços acima de 24

⚠️ **Não cortar:** co-op · esquiva/parry/stamina · as 8 famílias · a identidade dos 12 biomas.

**Não é para cortares nada por tua conta** — os donos decidiram avançar. Está aqui para saberes onde estão as alavancas, e para **usares a coluna `Fatia 1?`** em tudo o que escreveres. É ela que separa *"o jogo completo"* de *"o que se constrói primeiro"*.

**Tens liberdade sem limites na criatividade. Deixa cada ideia com as quatro pontas atadas.**
