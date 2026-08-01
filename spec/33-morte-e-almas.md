# 33 — Morte, almas e ressurreição

`[DECIDIDO]` (Mateus, 31-07-2026) — respostas às perguntas **10** (o que se perde ao morrer), **7** (como se cura) e **14** (armadura), e ao que faltava sobre morte em co-op.

Este documento fecha o tom do jogo. Tudo o que estava provisório em [`10-fatia-1.md`](10-fatia-1.md), [`01-combate.md`](01-combate.md) e [`19-rede.md`](19-rede.md) sobre morte passa a assentar aqui.

---

## 1. As almas

`[DECIDIDO]` — **matar inimigos dá almas. As almas sobem o nível, de 1 a 100. Ao morrer, perdem-se.**

| | |
|---|---|
| Onde se ganham | matar inimigos e chefes |
| Para que servem | **subir de nível (1→100)** e, se houver vendedores, comprar |
| Ao morrer | **caem no sítio onde morreste** |
| Recuperar | voltar lá e apanhá-las |
| ⚠️ Morrer outra vez antes de as apanhar | **perdem-se de vez** |

Isto substitui o provisório do WP0 (*"não se perde nada"*) e a moeda única do WP9 confirma-se: **as almas são a moeda e a experiência ao mesmo tempo.** Subir de nível e comprar disputam o mesmo bolso — cada compra é uma decisão a sério.

### Porque é que isto muda o jogo todo

A morte deixa de custar caminho e passa a custar **o que trazias**. É a tensão que define o género: quanto mais tempo andas sem descansar, mais tens a perder, e mais a ganância te trai. Um jogador com 5.000 almas por gastar joga com mais cuidado do que um com 200 — **e isso é jogabilidade, não punição.**

### Teste da Lei 1

Perder almas **nunca torna um chefe impossível**. O jogador continua com o mesmo personagem, as mesmas armas, as mesmas janelas de esquiva e parry — só com menos margem para a próxima subida de nível. Nada se tranca. ✅

⚠️ **A regra que protege isto:** se um jogador perder as almas todas repetidamente e ficar preso, a resposta **nunca é baixar a dificuldade nem devolver as almas**. É verificar se a telegrafia do inimigo está legível ([`15-inimigos.md`](15-inimigos.md)) e se o retry é barato o suficiente.

~~`[EM ABERTO]` — quantas almas dá cada inimigo, e a curva de custo por nível até 100.~~ **FECHADO:** as 33 fichas e os orçamentos por zona estão no [`67`](67-catalogo-do-bestiario.md); a curva cúbica e os marcos exactos estão no [`72`](72-materiais-consumiveis-e-economia.md). A moeda chama-se **almas** em todas as fontes vigentes.

---

## 2. Cura e pontos de descanso

`[DECIDIDO]` — **frascos**, e **pontos de descanso ao estilo do género**.

### Os frascos

| | |
|---|---|
| Quantidade | limitada, e **recarrega ao descansar** — não se compram |
| Beber | acção com animação e vulnerabilidade (o custo é o tempo, não o dinheiro) |
| Melhorar | `[EM ABERTO]` — mais frascos ou frascos mais fortes? É do WP5 |

*Porquê frascos recarregáveis e não poções compráveis:* poções finitas empurram para acumular e para nunca as usar. Frascos que voltam ao descansar transformam cada gole numa **decisão táctica dentro do combate**, que é onde a tensão deve estar. E fecha a **pergunta 7**.

### Os pontos de descanso

| | |
|---|---|
| O que fazem | recarregam frascos · curam · **subir de nível faz-se aqui** |
| O preço | **os inimigos comuns voltam todos** |
| Renascer | morreste → acordas no último ponto de descanso onde descansaste |

**O preço é o que faz o sistema funcionar.** Descansar é sempre uma escolha: ganhas frascos e um lugar seguro, e pagas com o caminho todo outra vez.

`[EM ABERTO]` — como se descobre um ponto de descanso, se são visíveis de longe, e a distância entre eles (WP8, já tem a pergunta registada).

---

## 3. Armadura

`[DECIDIDO]` — **existe, e há muitas.** Fecha a **pergunta 14**.

`[DECIDIDO]` — **chefes e inimigos largam partes da armadura que estão a usar.** Matar o Vorgar pode dar o elmo dele.

### O que isto obriga

1. **Armadura por peças** (elmo, peito, mãos, pernas), não conjuntos fechados — senão "largar parte da armadura" não quer dizer nada. Misturar peças de origens diferentes é meio caminho da personalização.
2. **Cada inimigo com armadura visível é um drop potencial.** O que se vê no corpo dele é o que pode cair. `→WP6` — as fichas do bestiário passam a dizer que peças o inimigo usa.
3. **A armadura tem de significar alguma coisa mecanicamente** sem quebrar a Lei 1. Ver o aviso abaixo.

### ⚠️ A tensão com a Lei 1, e como se resolve

Armadura que dá defesa é **exactamente** a "parede de estatísticas" que a Lei 1 recusa: se a única forma de sobreviver a um chefe for ter a armadura certa, o jogo passou a testar inventário em vez de perícia.

**A saída** `[CLAUDE]`, para o WP5 desenvolver: a armadura muda **como se joga**, não **quanto se aguenta**.

- Peso que afecta a **esquiva** — armadura pesada dá rolamento mais curto e mais lento; leve dá o rolamento base do WP1. É uma troca, não um upgrade
- Resistências **por tipo** (corte, contundente, fogo) em vez de "defesa" plana — escolher armadura passa a ser ler o inimigo que vem a seguir
- Um tecto duro: **nenhuma peça reduz mais de X% do dano de um golpe** (o WP2 já usa esse padrão na Constituição, com tecto de 40%)

*Alternativa descartada:* armadura puramente cosmética — não sustenta o loop de "matar o chefe para usar o que era dele", que é metade da graça.

---

## 4. Morte em co-op — o detalhe

`[DECIDIDO]` (Mateus, 31-07-2026). **Substitui** o provisório do WP1 (*"o jogador morto fica morto até o combate acabar"*).

### As regras

| | |
|---|---|
| Quando morres em casa alheia | **ficas no mundo dele** — não és expulso, não voltas ao teu jogo |
| O que és | um corpo caído no sítio onde morreste, visível para o parceiro |
| Janela de ressurreição | **1 minuto** |
| Como se ressuscita | o parceiro fica **5 a 7 segundos** em cima do corpo, sem interrupção (faixa a afinar no WP15B) |
| Se o minuto passar | acordas no último ponto de descanso; a sessão continua |
| Enfrentar o mesmo chefe | **sim, juntos** — a luta não acaba porque um caiu |

### Porque é que estes segundos são a peça inteligente

O Fable tinha escrito que ressuscitar a meio de um chefe *"transformava o ×1,8 de vida numa corrida de revezamento"* — e tinha razão **se a ressurreição fosse gratuita.**

**Não é.** Ficar 5 a 7 segundos parado em cima de um corpo, no meio de uma arena com um chefe vivo, é o risco mais alto do jogo. O parceiro tem de **criar a janela** — afastar o chefe, esperar o fim de um ataque longo, contar o tempo. Falhar significa dois corpos no chão.

Isso transforma a ressurreição naquilo que deve ser: **uma jogada, não um botão.** E é a única mecânica da spec que exige coordenação verbal a sério entre os dois — o que é o ponto do co-op.

### Detalhes que o WP10 tem de fechar

- **Interrompe?** Levar dano durante a canalização cancela? `[CLAUDE]` propõe: **sim** — senão o risco desaparece e volta a ser botão
- **Vida ao ressuscitar:** proposta `[CLAUDE]` — **metade**, e frascos como estavam. Ressuscitar não é um segundo fôlego completo
- **As almas do morto:** ver a matriz dos quatro casos abaixo — está toda definida
- **Itens largados** `[DECIDIDO]` (31-07): além das almas, quem morre larga itens que o parceiro pode apanhar. O corpo passa a ser um **sítio de decisão** — arriscar os 5–7 s para ressuscitar, ou pegar no que caiu e continuar sozinho? Ver [`34-catalogo-e-comandos.md`](34-catalogo-e-comandos.md) §3
- **A barra do minuto** vê-se? `[CLAUDE]` propõe: o morto vê o tempo dele; o parceiro vê um indicador no corpo
- **O chefe reage ao ressuscitador?** É o alvo natural durante os **5–7 s** — decisão do WP7

### Os quatro casos das almas `[DECIDIDO]` (Mateus, 31-07-2026)

Nenhum fica por definir:

| Caso | O que acontece às almas |
|---|---|
| **1. Um morre e é ressuscitado** dentro do minuto | **Não perde nada.** As almas voltam com ele — a ressurreição apaga a morte |
| **2. Um morre, o minuto passa**, o parceiro continua vivo | Renasce no ponto de descanso. As almas **ficam onde caiu**, à espera |
| **3. Os dois morrem** | Ambos renascem no ponto de descanso. **As almas de cada um ficam onde cada um caiu** — são duas manchas separadas, não uma |
| **4. A solo** | Igual ao caso 2, sem a hipótese de ressurreição |

**Recuperar é sempre igual:** voltar ao sítio e apanhar. ⚠️ **Morrer outra vez antes de apanhar perde-as de vez** — a mancha nova substitui a antiga.

*Porquê duas manchas separadas no caso 3:* juntar as almas dos dois num sítio só era mais simples de programar, mas apagava a decisão. Separadas, os dois têm de escolher a ordem, e talvez de se defender um ao outro enquanto o primeiro apanha. É co-op a sério.

#### ⚠️ O caso que dá o melhor momento do jogo

Se os dois morrerem **dentro da arena do chefe**, as manchas ficam lá dentro — e o chefe voltou ao princípio. Recuperar as almas significa **entrar outra vez e chegar aonde caíram**, com o chefe vivo.

Isso é tensão de propósito, não bug. É o momento em que o jogo pergunta se as almas valem o risco, e a resposta certa às vezes é *não vale, vamos sem elas*. **Ninguém "conserte" isto mais tarde** — se o WP15B mostrar que é frustrante, o ajuste é na distância do ponto de descanso à arena, nunca em fazer as almas aparecerem à porta.

### E a solo

O jogo é **inteiramente jogável sozinho** `[DECIDIDO]`. Sozinho não há ressurreição: morreste, acordas no ponto de descanso, as almas ficam onde caíste.

⚠️ **A consequência que o WP15B tem de medir:** a dois há uma rede que a solo não existe. Se o teste mostrar que o Vorgar é muito mais fácil a dois **por causa disso**, não se tira a ressurreição nem se penaliza quem joga sozinho. A resposta de PV/padrões segue a `[TENSÃO]` da pergunta 24; o ×1,8 existente é apenas `[PROTO]`, não decisão fechada.

---

## O que isto fecha e o que abre

**Fecha:** perguntas 7 (cura), 10 (morte), 14 (armadura), e a morte em co-op.

**Abre, e é trabalho:**

| | Onde |
|---|---|
| Almas por inimigo e curva de custo até ao nível 100 | WP2 / WP9 |
| ~~Uniformizar XP/almas~~ **Fechado: fontes vigentes e runtime dizem almas; documentos 10–20 preservam “XP” apenas sob aviso histórico** | ✅ [`72`](72-materiais-consumiveis-e-economia.md) |
| Catálogo de armadura por peças, com peso e resistências | WP5 |
| Que peças cada inimigo usa (= o que pode largar) | WP6 |
| Melhorar frascos: mais ou mais fortes | WP5 |
| Interrupção, vida ao ressuscitar, indicadores | WP10 |
| Distância e descoberta dos pontos de descanso | WP8 |

## Ligações

[`18-progressao.md`](18-progressao.md) · [`19-rede.md`](19-rede.md) · [`14-equipamento.md`](14-equipamento.md) · [`01-combate.md`](01-combate.md) · [`99-perguntas-abertas.md`](99-perguntas-abertas.md)
