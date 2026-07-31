# Briefing 2 — para o Fable

**De:** Mateus (via Claude) · **31-07-2026** · **É o único briefing. Cobre tudo.**

---

## Antes de tudo: lê dois ficheiros

1. ⭐ [`../ESTADO.md`](../ESTADO.md) — **o que é verdade hoje.** A spec tem 46 documentos e ~35 decisões, e **onze dos teus documentos de execução são anteriores a decisões que os mudam**. O `ESTADO.md` existe para não construíres sobre o que já foi substituído
2. [`../DECISOES.md`](../DECISOES.md) — as decisões por ordem, com o que cada uma substitui

**Depois volta aqui.**

---

## O espírito deste briefing

> **Tens liberdade sem limites na criatividade.** Inventa sistemas, propõe mecânicas, contraria o que está escrito se tiveres razão melhor. O Mateus disse-o por palavras dele: **livre, sem limites.**
>
> **Os guardas não são contra ideias. São contra pontas soltas.** O modo de falha real deste projecto não é uma ideia má — é uma ideia boa **a que ninguém ligou um comando, um teste, uma imagem ou um orçamento**. Já aconteceu quatro vezes, e foste tu que as encontraste.

### ⭐ As quatro perguntas do fio solto

**Nada entra sem responder às quatro.** Uma em branco é uma ponta solta.

| | Pergunta | Porquê |
|---|---|---|
| **1** | **Como é que o jogador usa isto?** | tu próprio provaste que era preciso: seis habilidades de classe escritas, **zero teclas** ([`../spec/44-prototipo.md`](../spec/44-prototipo.md) §3.1) |
| **2** | **Como é que se prova que funciona?** | um teste, um critério, um número. Os teus 130 auto-testes são exactamente isto |
| **3** | **De onde vem a arte e o som?** | pack, geração ou à mão ([`../spec/22-assets.md`](../spec/22-assets.md)). Um item sem isto **não aparece no ecrã** |
| **4** | **Quanto custa na máquina do Rico?** | 8 GB, Iris Xe. Lei 4 |

⚠️ **E a regra de processo, que é do Mateus:** *"é melhor estudar primeiro completo como funciona o jogo, cada funcionalidade e mecanismo, e depois implementar. A gente não quer o jogo superficial."* **Nada por analogia nem de memória — estuda-se o mecanismo, escreve-se com números e com fonte, e só depois se decide o nosso.** Os documentos [`35`](../spec/35-estudo-referencia.md), [`39`](../spec/39-estudo-profundo.md), [`41`](../spec/41-estudo-armas-e-golpes.md), [`42`](../spec/42-estudo-magia.md) e [`43`](../spec/43-estudo-espolio-inventario-mundo.md) são o padrão: comparação, números, ligação à fonte.

---

# Tarefa 0 — traz o código para cá

`[DECIDIDO]` (Mateus, 31-07-2026) — **o código do jogo passa a viver neste repositório, em `game/`.**

O plano antigo previa um repositório separado. Foi escrito quando este era só de especificação, e caiu por três razões:

- ⭐ **A regra do "mesmo PR" é impossível em dois repositórios.** Se o código e a spec discordam, a spec muda primeiro **no mesmo PR**
- **O que está fora não é revisto** — eu não vejo o teu código
- **Um repositório é uma cópia de segurança. Um disco não é.** O jogo esteve até hoje a existir num sítio só

**O que fazer:** trazer o `worldrpgs-game` para `game/`, com o historial se der. Um `.gitignore` para `build/`, `.godot/` e afins. E um `game/CLAUDE.md` com as convenções: versão do Godot, onde vivem os `data/*.json`, como se corre os auto-testes, o que nunca se mete em código.

⚠️ **Isto vem antes de tudo.** Nada do resto é revisível enquanto o código não estiver aqui.

---

# A ordem do resto, e porque é esta

```
1. CATÁLOGOS ──┬──► desbloqueia AS IMAGENS
               └──► desbloqueia O CONTEÚDO (o motor é data-driven: o catálogo É o jogo)
2. SISTEMAS que faltam
3. MUNDO
4. ALINHAMENTO dos documentos antigos
```

⭐ **O catálogo vem primeiro porque é o único passo que abre dois caminhos ao mesmo tempo.** As imagens estão paradas à espera dele — os 32 assets que existem cobrem cenários, classes e as 7 raças, e **não há um único ícone de arma, armadura ou feitiço**, porque ninguém sabe ainda quais são.

---

# Tarefa 1 — os catálogos

## 1a. Magia (WP4) — ⭐ o maior, e o mais importante

O Mateus foi explícito: *"o mago vai ser o que mais está dado no jogo, o mais apelão. As magias fazem tudo — cura, dano, buffs, elementos. Vamos ser bem vastos em magia."*

**A base está escrita no [`../spec/42-estudo-magia.md`](../spec/42-estudo-magia.md).** Falta encher:

- **As quatro escolas** (§1) — e a do mal escala com o **menor** entre os dois atributos, o que a torna a mais forte e a mais cara sem nenhuma tranca
- **A grelha de verbos** (§7) — **nenhuma casa pode ficar vazia.** Dano directo, área, ao longo do tempo, cura (incluindo **do parceiro à distância**), reforço próprio, reforço de arma, enfraquecer, utilidade, defesa
- **A ficha de cada feitiço** (§9) — 14 colunas, incluindo ⚠️ **como o inimigo o esquiva, que nunca pode ser "não dá"**
- ⭐ **A tabela de melhoria de seis níveis por feitiço** (§6) — força, **área**, **lançamentos**. Regra: **um nível em cada dois tem de dar área ou lançamentos, nunca só força**
- Feitiços são **únicos** — nunca há dois iguais no mundo

**Sê generoso aqui.** É a área onde o Mateus quer mais, e é onde tens mais espaço para inventar.

⚠️ **E não te esqueças da tensão 28:** se a magia faz tudo, o mago é a classe correcta e a Lei 3 cai. Há cinco travões propostos em [`42`](../spec/42-estudo-magia.md) §8 — **se tiveres um travão melhor, propõe-no.**

## 1b. Armas e armaduras (WP5)

**A base é [`../spec/41-estudo-armas-e-golpes.md`](../spec/41-estudo-armas-e-golpes.md).**

- ⚠️ **Reescrever por FAMÍLIA, não por classe.** 20 armas "do guerreiro" reintroduz por trás a divisão que a Lei 3 recusa pela frente
- **Os 11 golpes por família** (§1) — sete deles não estão declarados em lado nenhum: cadeia de leves, leve→pesado, em corrida, a rolar, a saltar, de cima, empurrão
- ⭐ **Cada família traz uma frase que diz ONDE É MÁ** (§2). Se não a consegues escrever, a família não está desenhada — está listada
- **Capricho nas katanas e nas espadas** — pedido directo do Mateus. A katana é *a arma de quem ataca no tempo do inimigo*, não *a espada fixe*
- **Dano de interrupção e frames de hiper-armadura** por família (§4)
- **Arte a 1 mão e a 2 mãos**, verbos diferentes ([`34`](../spec/34-catalogo-e-comandos.md) §2b)
- **~30 armaduras**, habilidade **por peça** e não por conjunto, todas passivas ou condicionais
- **~70 anéis, 10 dedos** ([`37`](../spec/37-aneis-e-elementos.md)) — criatividade sem repetir
- **Melhoria de armas** — reforço (números) e infusão (**troca** de escala = Lei 2)
- **Estados alterados** — veneno, sangramento, queimadura. Nunca foram escritos

## 1c. Bestiário (WP6)

- ⭐ **O baralho de espólio de 10 cartas por inimigo** ([`43`](../spec/43-estudo-espolio-inventario-mundo.md) §2). É o que cumpre a garantia do Mateus: em 10 mortes larga **tudo o que se vê nele**
- **A ficha de 11 colunas por ataque** ([`38`](../spec/38-ataques-e-honestidade.md) §3), com ⚠️ **"como se escapa" obrigatório e nunca "não dá"**
- **3 a 5 ataques por inimigo, e os três têm de ser três perguntas diferentes** — um que se apara, um que só se esquiva, um que obriga a mexer o pé
- **O som que anuncia cada ataque** — obrigatório, é a regra da 1.ª pessoa
- **Almas por inimigo** — com o tecto de 10 reaparições, cada zona passa a ter um **orçamento fixo de almas**. Soma-o
- **Massa de cada inimigo**, para o empurrão ([`36`](../spec/36-fisica.md) §4)

---

# Tarefa 2 — os sistemas que faltam

Todos com números já estudados. **Não é investigação — é integração.**

| Sistema | Onde está | Onde entra |
|---|---|---|
| ⭐ **Piso de 30%** — nenhuma defesa reduz um golpe abaixo disso | [`39`](../spec/39-estudo-profundo.md) §1 | WP2 |
| ⭐ **Soft caps aos ~40** e curva de saturação | [`39`](../spec/39-estudo-profundo.md) §2 | WP2, WP9 |
| **Defesa por curva sobre a razão + absorção multiplicativa** | [`39`](../spec/39-estudo-profundo.md) §1 | WP2 |
| ⭐ **Interrupção e hiper-armadura** | [`39`](../spec/39-estudo-profundo.md) §4, [`41`](../spec/41-estudo-armas-e-golpes.md) §4 | WP1 |
| ⭐ **Contra-ataque +30%** — com som e faísca próprios, senão ninguém aprende | [`41`](../spec/41-estudo-armas-e-golpes.md) §3 | WP1 |
| **Stamina: regen fixa, 1 ponto chega para agir, negativo com tecto** | [`41`](../spec/41-estudo-armas-e-golpes.md) §5 | WP1 |
| **Bloqueio, estabilidade, quebra de guarda** | [`41`](../spec/41-estudo-armas-e-golpes.md) §6 | WP1 |
| ⭐ **Cargas repartidas entre curar e usar** | [`39`](../spec/39-estudo-profundo.md) §7 | WP5, WP9 |
| ⭐ **Contador de 10 mortes por sala** | [`40`](../spec/40-decisoes-espolio-magia-inventario.md) §1 | WP6, WP9 |
| ⭐ **Controlos configuráveis** | [`45`](../spec/45-controlos-configuraveis.md) | WP11 |
| ⭐ **Carregamento por área + porta de nevoeiro** | [`43`](../spec/43-estudo-espolio-inventario-mundo.md) §6 | WP14 |
| **Curva de nível cúbica** (a actual é linear) e "XP"→"almas" | [`35`](../spec/35-estudo-referencia.md) §3 | WP9 |
| **Mochila sem limite, só o equipado pesa** | [`40`](../spec/40-decisoes-espolio-magia-inventario.md) §9 | WP11 |
| **Teste do rolamento: 10 em 10, sem excepção** | [`38`](../spec/38-ataques-e-honestidade.md) §2 | WP15B |

### ⭐ Sobre os controlos configuráveis

`[DECIDIDO]` — **o jogador escolhe as teclas dentro do jogo.** Isto **dissolve a guerra do parry**: `Q` e toque de `RMB` ficam os dois, e cada um escolhe.

⚠️ **Mas o mapa de teclas continua a ter de fechar**, porque alguém tem de decidir os **valores de fábrica** — e são o que 100% dos jogadores experimenta primeiro. Fecha-o **de uma vez**, não peça a peça: o `C` e o `Ctrl` que o protótipo atribuiu **já apareciam como ocupados** no [`34`](../spec/34-catalogo-e-comandos.md) §2, e assim vamos descobrir colisões uma a uma para sempre.

⚠️ **E a regra que se esquece sempre:** o jogo mostra **a tecla do jogador**, nunca a de fábrica. Se alguém remapeia a esquiva e o tutorial continua a dizer `Espaço`, **o tutorial passa a mentir**. Barato agora, caro depois.

---

# Tarefa 3 — o mundo (WP8)

- ⚠️ **6 zonas contra 10+ biomas aprovados.** Resolve
- ⭐ **Toda a zona fecha um círculo** para um sítio já visitado, e **o atalho abre-se do lado de dentro** — é a prova de que passaste, não uma chave que encontraste. Pelo menos um círculo por zona é **vertical**
- ⭐ **Ponto de descanso à vista da porta de cada chefe.** Sem excepção — a corrida de volta é fricção, e a dois multiplica-se porque um espera pelo outro
- **Desnível desenhado com a tabela de queda à frente** ([`36`](../spec/36-fisica.md) §2): 4 m é atalho, 20 m é morte
- **Segredos:** paredes falsas — pelo menos uma que esconda **uma zona inteira**. ⚠️ E como não temos mensagens de estranhos, **o cenário tem de dar a pista sozinho**
- **Baús**, e o mímico **respira** — levanta a tampa devagar. É telegrafia, não armadilha
- ⚠️ **O traçado e o orçamento de memória desenham-se juntos** — um atalho que liga duas zonas distantes obriga a ter as duas prontas

---

# Tarefa 4 — alinhar os documentos antigos

**Por último de propósito** — é limpeza, e metade resolve-se sozinha ao reescrever os catálogos. Onze documentos são anteriores a decisões que os mudam; o [`ESTADO.md`](../ESTADO.md) §2 tem a lista.

⚠️ **Um reparo antigo que continua aberto:** nenhum dos 11 documentos traz a tabela de comparação `eles · nós · diferença` nem cita fontes, como manda o [`31-referencias.md`](../spec/31-referencias.md). Os documentos 35, 39, 41, 42 e 43 mostram o formato.

---

# ⭐ O que eu preciso de ti para gerar as imagens

**Isto é o desbloqueio directo do próximo lote de arte, e é barato.**

Existem 32 assets (cenários, classes, as 7 raças). **Falta tudo o que é objecto** — e não consigo desenhar nada sem saber o que é.

**Acrescenta uma coluna `descrição visual` a tudo o que vai ter imagem:**

| O que | Quantos | O que a coluna precisa de dizer |
|---|---|---|
| **Armas** | por família primeiro, depois as variantes | silhueta, material, comprimento, o que a distingue na família |
| **Armaduras** | por peça | material, silhueta, estado (novo/gasto/partido) |
| **Feitiços** | por escola | cor, forma, elemento, o que se vê quando acerta |
| **Anéis** | ~70 | material, pedra, motivo |
| **Consumíveis e materiais** | os da fatia 1 | forma do frasco/pedra, cor |

**Uma frase por item chega.** Não precisa de ser prosa — precisa de ser específica. *"Lâmina curva estreita, aço polido, punho enfaixado a tecido escuro, 90 cm"* dá para gerar. *"Katana"* não dá.

⚠️ **E a coluna `Fatia 1?` em tudo** — é o que me diz o que gerar primeiro. Sem ela, ou gero 300 imagens ou não gero nenhuma.

---

# Skills — o que vale a pena instalar

**Digo já que isto é secundário.** O que mais rende é o `game/CLAUDE.md` da tarefa 0: uma skill sem contexto do projecto não salva nada, e o contexto é o que te falta.

Dito isso, para construir jogo estas rendem mesmo:

| Skill | Quando |
|---|---|
| `brainstorming` | **antes** de inventar sistema novo — e vais inventar muitos |
| `writing-plans` / `executing-plans` | qualquer tarefa com mais de 3 passos |
| `test-driven-development` | ⭐ já o fazes — 130 auto-testes contra a spec é exactamente isto |
| `systematic-debugging` | quando um número não bate certo e não se percebe porquê |
| `verification-before-completion` | **antes** de dizer "está feito" |
| `karpathy-guidelines` | antes de código não-trivial: pensar antes de escrever, mudanças cirúrgicas |
| `using-git-worktrees` | se quiseres correr dois pacotes em paralelo sem te pisares |

---

# Como entregar

| | |
|---|---|
| **Reserva primeiro** | pacote **e** número de ficheiro, em [`../COORDENACAO.md`](../COORDENACAO.md). ⚠️ Regra nova, escrita depois de eu a quebrar: publiquei 40–43 sem avisar e o teu 40 teve de passar a 44. Números **45 tomado, 46+ livre** |
| **PRs pequenos e temáticos** | um pacote por PR. O #11 trouxe 1333 linhas e 11 pacotes de uma vez, e o conflito foi feio |
| **Corre o guarda** | `node tools/check-coerencia.mjs --base origin/main` |
| **Actualiza no mesmo PR** | [`../SPEC.md`](../SPEC.md), [`../spec/99-perguntas-abertas.md`](../spec/99-perguntas-abertas.md) e [`../ESTADO.md`](../ESTADO.md) |
| **Etiqueta** | `[FABLE]` o que decides (com razão **e** alternativa descartada) · `[PROTO]` o que o protótipo assume · `[TENSÃO]` o que **não** decides |
| **Não decidas uma `[TENSÃO]`** | propõe e recomenda. Decidem o Mateus e o Rico |
| **Não sobrevendas** | o que fizeste no [`44`](../spec/44-prototipo.md) — dizer o que **ainda não está provado** — é o que torna um relatório útil. Continua assim |

---

# Uma coisa que tens de saber, e não é um travão

O escopo aprovado é: mundo vasto, ~61 chefes, 10+ biomas, ~120 armas, ~30 armaduras, ~70 anéis, catálogo de magia largo. **Feito por duas pessoas e dois agentes.**

**Os donos sabem e decidiram avançar. Não é para cortares nada.** Fica escrito só para saberes onde estão as duas alavancas:

- ⭐ **Círculos e atalhos** dão vastidão sem custar produção — um mapa grande sente-se grande com portas, não com mais mundo
- ⭐ **A coluna `Fatia 1?`** é o que separa "o jogo completo" de "o que se constrói primeiro". Sem ela, o catálogo vira um plano de dez anos

**Tens liberdade sem limites. Usa-a — e deixa cada ideia com as quatro pontas atadas.**
