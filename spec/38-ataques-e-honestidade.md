# 38 — Ataques dos inimigos e o contrato de honestidade

`[DECIDIDO]` (Mateus, 31-07-2026) — *"tem que ser verdadeiro, não pode ser nada mentira, não pode a gente se mover certinho e tomar dano."*

Este documento existe por causa dessa frase. **É o mais importante do combate depois do WP1**, porque descreve a diferença entre um jogo difícil e um jogo que engana.

---

## 1. A anatomia de um ataque — cinco fases

Adoptamos a estrutura de cinco fases da referência, que é mais precisa do que o `arranque/activo/recuperação` do WP1 e **não o contradiz** — detalha-o.

| Fase | O que é | Hitbox? | Duração alvo |
|---|---|---|---|
| **1. Pose de abertura** | o corpo prepara-se; é aqui que o jogador lê | não | ≥ 0,30 s |
| **2. Sinal** | a arma começa o arco; ainda não magoa | não | 0,10–0,25 s |
| **3. Golpe** | **a hitbox está viva** | **sim** | **3–6 frames (50–100 ms)** |
| **4. Pose final** | o golpe acabou; encadeia ou recupera | não | 0,10–0,20 s |
| **5. Regresso** | volta ao repouso — **a janela de castigo** | não | 0,30–0,80 s |

### As duas regras de tempo que não se negoceiam

**Regra A — o aviso é ≥ 0,50 s** (fases 1+2 somadas).

A referência usa ≥ 340 ms. **Nós usamos 500 ms**, e de propósito: a reacção humana é ~250 ms de processamento, e um jogo que dá 340 ms exige quase perfeição. Meio segundo dá margem para **ler, decidir e agir** — que é o que a Lei 1 promete.

**Regra B — a hitbox vive 3 a 6 frames.** Nunca mais.

Com a esquiva a dar **300 ms de invencibilidade** (WP1), uma janela de golpe de 50–100 ms cabe folgadamente lá dentro. **Isto é o que torna a esquiva verdadeira:** um rolamento bem cronometrado cobre o golpe inteiro com margem de 3×.

⚠️ **Hitboxes que ficam vivas 20 frames são a causa nº1 de "eu esquivei e levei na mesma"** — a hitbox continua lá depois de a invencibilidade acabar. Nenhum ataque deste jogo faz isso.

---

## 2. ⚠️ O contrato de honestidade

**Isto é uma promessa ao jogador, e é verificável.** Cinco cláusulas, todas obrigatórias.

### Cláusula 1 — a hitbox nunca é maior do que se vê

Na referência, *"a maior parte das hitboxes de arma são várias vezes maiores do que o modelo da arma"*. Isso é feito para a detecção não falhar em animações rápidas — e **é a razão apontada pelas queixas de que os golpes acertam quando visualmente falharam**.

**A nossa regra:** a hitbox pode ser **no máximo 10% maior** do que a forma visível da arma, e **nunca mais comprida**. Se a lâmina passou ao lado no ecrã, **passou ao lado**.

*O que isto custa:* golpes muito rápidos podem falhar por um triz. **Aceitamos.** Um golpe que falha por pouco é justo; um golpe que acerta sem tocar é mentira. E o **varrimento** ([`36-fisica.md`](36-fisica.md) §5) resolve a detecção sem precisar de inchar a hitbox.

### Cláusula 2 — o seguimento pára antes da hitbox acender

**É a causa mais comum de "esquivei e levei na mesma", e a mais invisível.**

Muitos jogos deixam o inimigo **rodar em direcção ao jogador durante o ataque**. O jogador rola para o lado, e o golpe **segue-o** — o ataque parece perseguir. Visualmente parece que se esquivou; mecanicamente não se esquivou de nada.

**A nossa regra, com números:**

| Fase | Rotação permitida |
|---|---|
| 1 — Pose de abertura | até **180°/s** — o inimigo pode virar-se para ti |
| 2 — Sinal | **≤ 30°/s** — só ajuste fino |
| 3 — Golpe | **0°/s** — **comprometido, ponto final** |
| 4–5 | 0°/s até ao fim do regresso |

**A partir do fim da fase 1, o ataque está comprometido com a direcção.** Rolar para o lado funciona **sempre**, porque o golpe já não te pode seguir.

### Cláusula 3 — a invencibilidade não escala com nada

Já estava decidido (WP1) e repete-se aqui porque é o outro pecado conhecido: na referência (DS2), a **velocidade do rolamento depende de um atributo**, e isso escondeu uma perícia atrás de uma estatística.

**No nosso jogo, os 300 ms de invencibilidade são iguais ao nível 1 e ao nível 100.** Não há atributo, anel ou armadura que os aumente. *(Armadura pode mudar a **distância** e o **custo** do rolamento — nunca a invencibilidade.)*

### Cláusula 4 — o que se vê é o que acontece

- A animação **começa** no primeiro frame da fase 1 — nada de arranques invisíveis
- A arma está **onde parece estar** em cada frame; nada de teleportes
- **Nenhum ataque acerta atrás do inimigo** a menos que a animação vá lá atrás
- Efeitos visuais **nunca escondem a telegrafia** (regra já no WP12)

### Cláusula 5 — o teste que prova isto

`→WP15B` — **o teste do rolamento**, obrigatório para cada ataque de cada inimigo:

> Um jogador que role **no frame correcto** atravessa o ataque **10 vezes em 10, sem excepção**.

Se falhar uma vez, é bug — nunca "o jogador enganou-se". Investiga-se por esta ordem: a hitbox está viva demasiado tempo? o inimigo rodou durante o golpe? a hitbox é maior do que o modelo?

⚠️ **E o teste da rede:** o mesmo, em co-op, do lado do convidado. Se a latência quebrar isto, a decisão de autoridade do WP10 está errada — não é o jogador que tem de compensar.

---

## 3. O padrão de ataques de cada inimigo

`[DECIDIDO]` (Mateus, 31-07-2026) — **cada inimigo tem 3 a 5 ataques.** Chefes têm mais.

| | Ataques | Porquê |
|---|---|---|
| Inimigo comum | **3** | um jogador aprende três padrões numa passagem |
| Inimigo de elite | **4–5** | exige leitura, não memória |
| Chefe, fase 1 | **5–7** | |
| Chefe, fase 2 | **+3–4 novos** (a Lei 2: padrões novos, não números maiores) | |

### A regra que faz um conjunto de ataques valer alguma coisa

**Os 3 ataques têm de ser três perguntas diferentes.** Se os três se resolvem rolando para trás, o inimigo tem um ataque com três animações.

O molde: **um que se apara, um que só se esquiva, e um que obriga a mexer o pé.**

| Ataque | Pergunta que faz | Resposta |
|---|---|---|
| A — golpe recto e lento | *consegues aparar?* | **parry**, ou esquiva lateral |
| B — varrimento largo | *consegues sair do arco?* | **só esquiva** — para dentro ou para fora |
| C — investida ou salto | *consegues ler a distância?* | esquiva lateral no momento, **nunca para trás** |

### Cada ataque traz uma ficha completa

`→WP6` e `→WP7`. **Nenhum ataque entra na spec sem estas onze colunas:**

| Coluna | Exemplo |
|---|---|
| Nome | Machado descendente |
| Fase 1 (abertura) | 0,45 s — arma acima da cabeça, corpo recua |
| Fase 2 (sinal) | 0,15 s |
| Fase 3 (golpe) | **4 frames** |
| Fases 4+5 | 0,15 s + 0,60 s |
| **Aviso total** | **0,60 s** ✅ ≥ 0,50 |
| Aparável? | ✅ sim |
| **Como se escapa** | rolar para qualquer lado, ou parry |
| **Som que o anuncia** | grunhido grave + arrastar de metal *(obrigatório — 1.ª pessoa)* |
| Alcance / arco | 2,4 m · 60° à frente |
| Janela de castigo | 0,60 s no regresso |

⚠️ **A coluna "como se escapa" é obrigatória e nunca pode dizer "não dá".** Se um ataque não tem escapatória, não é difícil — é injusto, e não entra. **Todo o ataque tem pelo menos uma resposta que funciona sempre.**

### Ataques em grupo

O **círculo de agressão** do WP6 (máximo 2 a atacar) já resolve a maior parte. Duas regras a acrescentar:

- **Dois inimigos nunca entram na fase 3 no mesmo frame.** Há sempre ≥ 0,20 s entre golpes activos — senão é impossível de esquivar, e impossível não é difícil
- **Ataques de fora do ecrã anunciam-se por som** ([`29-perspectiva.md`](29-perspectiva.md)) — em primeira pessoa não há visão periférica

---

## 4. Chefes — as fases

`→WP7` desenvolve. As regras que valem para todos:

1. **A fase 2 muda padrões, não números.** Mais vida não é fase. Se a fase 2 for a fase 1 com o dobro do dano, não é fase — é uma barra mais comprida
2. **A transição é uma janela de respiração**, não um ataque grátis. O jogador precisa de ver o que mudou
3. **Cada fase mantém a regra dos três tipos:** aparável, só esquiva, mexer o pé
4. **Ataques de área anunciam-se com o corpo.** A referência ensina que um varrimento de 180° é quase sempre precedido de o inimigo se centrar no jogador. Adoptamos: **toda a área tem uma pose que a denuncia antes de acontecer**
5. **Nada de ataques que ignoram a invencibilidade.** Alguns jogos do género têm-nos; é traição pura ao contrato

---

## 5. O que largam quando caem

`[DECIDIDO]` — **almas sempre.** O resto por tabela:

| | O que larga |
|---|---|
| **Todos** | almas (valor por ficha, WP2/WP9) |
| **Com armadura visível** | hipótese de largar **as peças que se vêem** ([`33-morte-e-almas.md`](33-morte-e-almas.md) §3) |
| **Com arma** | hipótese de largar essa arma |
| **Elite / subchefe** | garantido: uma peça, um anel ou um material |
| **Chefe** | garantido: **um verbo novo** — arte de arma, magia ou anel que muda o que se pode fazer (Lei 2) |

⚠️ **A regra que faz isto valer:** o que larga **é o que se vê no corpo dele**. Um inimigo com elmo de ferro larga um elmo de ferro. Isso torna o mundo legível — vê-se ao longe se vale a pena — e é a mesma regra das fraquezas do WP6.

---

## 6. Tipos de inimigo — os papéis

`→WP6` já tem o bestiário; isto é a grelha de papéis que garante que os encontros não se repetem. **Uma zona precisa de pelo menos três papéis diferentes**, senão o combate é o mesmo o tempo todo:

| Papel | O que faz | Ensina |
|---|---|---|
| **Rápido** | pressiona, fecha distância, castiga a hesitação | esquiva |
| **Pesado** | lento, telegrafado, dói muito | parry e paciência |
| **Distância** | obriga a mexer, castiga quem fica parado | posicionamento |
| **Grupo** | fraco sozinho, perigoso em três | gestão de espaço e lock-on |
| **Armadilha** | não ataca — prepara o terreno | atenção ao cenário |
| **Elite** | exame do que a zona ensinou | tudo junto |

---

## Ligações

[`01-combate.md`](01-combate.md) · [`15-inimigos.md`](15-inimigos.md) · [`16-chefes.md`](16-chefes.md) · [`36-fisica.md`](36-fisica.md) · [`28-testes.md`](28-testes.md) · [`29-perspectiva.md`](29-perspectiva.md)

**Fontes:** [Anatomy of an Enemy Attack in Dark Souls 3 — Game Developer](https://www.gamedeveloper.com/game-platforms/anatomy-of-an-enemy-attack-in-dark-souls-3) · [How to read boss attack patterns](https://nextgamenavigator.com/en/how-to-read-boss-attack-patterns-counter-any-boss)
