# 40 — Decisões: espólio garantido, magia, inventário e carregamento

`[DECIDIDO]` (Mateus, 31-07-2026, segunda conversa) — quinze decisões de uma vez. Este documento é o **registo**; o estudo que as sustenta está nos [`41`](41-estudo-armas-e-golpes.md), [`42`](42-estudo-magia.md) e [`43`](43-estudo-espolio-inventario-mundo.md).

> ⚠️ **Leitura actual:** as falas dos donos ficam preservadas, mas os mecanismos de slots/bolo de cargas foram revogados pelo [`54`](54-mana-meditacao-e-tracos-de-classe.md). Hoje há Inteligência/Fé, mana sem regeneração, oito favoritos e artes a gastar mana ([`66`](66-catalogo-de-magia.md)). Carga equipada usa recuperação/regen/sobrecarga do [`70`](70-fecho-dos-sistemas-de-combate.md), e descanso por arco — não por porta — vem do [`53`](53-chefes-ritmo-e-o-mago-forte.md).

> **A instrução por trás de tudo, e é a mais importante:**
>
> *"É melhor estudar primeiro completo como funciona o jogo, cada funcionalidade, mecanismo e tudo do jogo, e depois a gente pega e implementa aqui no nosso projeto. Sinto que você está olhando muito superficial. A gente não quer o jogo superficial."*
>
> **Fica como regra de processo:** nenhum sistema entra nesta spec por analogia ou por memória. **Estuda-se o mecanismo, escreve-se com números e com fonte, e só depois se decide o nosso.** Vale para mim e vale para o Fable.

---

## 1. Reaparecimento — o descanso recarrega o mundo

`[DECIDIDO]`

| | |
|---|---|
| **Quando** | ao sentar no ponto de descanso |
| **O que volta** | **o mapa todo** — todos os inimigos daquela zona |
| **O que não volta** | **os chefes** |
| **Tecto** | **10 vezes por inimigo.** Depois disso não volta mais |

**A razão, nas palavras dele:** *"a gente não pode farmar nos inimigos."*

**O que isto fecha:** é a adopção do contador estudado no [`39`](39-estudo-profundo.md) §9, com o nosso número. Já não é proposta — **é decisão**. `→WP6`/`→WP9`

⚠️ **E abre a pergunta 22** de novo, agora com mais força: se cada inimigo só dá almas 10 vezes, **o mundo tem de ser grande que chegue** para lá chegar ao nível 100. O Mateus já respondeu a isso na mesma conversa (§9 deste documento): o mundo é vasto de propósito.

---

## 2. As almas variam por inimigo

`[DECIDIDO]` — *"dependendo dos inimigos, o tanto de alma que a gente ganha é diferente."*

`→WP6` — **cada ficha do bestiário traz o seu valor de almas**, e o valor é parte do desenho: um inimigo que dá muito é um convite a arriscar.

✅ **Entregue no [`67`](67-catalogo-do-bestiario.md):** almas por tipo e totais verificáveis de primeira limpeza e dez limpezas recompensadas nas 12 zonas.

⚠️ **E com o tecto de 10, o valor das almas passa a ser um orçamento fixo por zona**, não uma torneira. `→WP9` tem de somar: *quantas almas existem numa zona, ao todo?* É esse número que diz a que nível se chega lá.

---

## 3. ⭐ A garantia de espólio — a decisão mais forte desta conversa

`[DECIDIDO]`, e é uma promessa ao jogador:

> *"Tem que garantir que dentro dessas dez vezes ele vai largar todos os itens dele. Pelo menos uma de cada peça da armadura, e a arma que ele está usando. E também do chefe daquela área — a armadura e a arma. Se usa magia, também vai largar."*

### O que isto significa mesmo

**Nenhum item do jogo está atrás de sorte.** Se um inimigo usa elmo, peito, luvas, perneiras e um machado, **essas cinco coisas são tuas em 10 mortes, garantidamente**. Não há "má sorte". Não há farmar 200 vezes por uma peça.

⚠️ **Isto é incompatível com espólio aleatório clássico**, e não é um detalhe — é matemática. Com 20% de hipótese por item, a probabilidade de tirar as 5 peças em 10 mortes é **muito baixa**. Sorte não garante nada; garantia exige outro mecanismo.

### O mecanismo — baralho, não dado `[CLAUDE]`

Cada inimigo tem um **baralho de 10 cartas**. Cada morte tira uma carta, **e essa carta não volta**:

| Cartas | Quantas |
|---|---|
| As peças que se vêem nele (elmo, peito, mãos, pernas) | 4 |
| A arma que ele traz na mão | 1 |
| O feitiço, **se ele lançar algum** | 0 ou 1 |
| Almas a mais, material, consumível — **as cartas de enchimento** | as restantes |

**A garantia é automática:** 5 ou 6 cartas obrigatórias num baralho de 10 saem sempre dentro de 10 mortes. **A ordem é que é aleatória** — e é ela que dá a emoção, sem custar a promessa.

**E resolve mais duas coisas de graça:**
- O jogador **vê ao longe** o que aquele inimigo tem, e sabe **quantas vezes** falta matá-lo. Nada é opaco
- Liga-se à regra do [`38`](38-ataques-e-honestidade.md) §5 — *o que larga é o que se vê no corpo dele*. Agora é a mesma regra, com garantia por trás

`→WP6` — **cada ficha do bestiário declara o seu baralho.** É coluna obrigatória.

✅ **Entregue no [`67`](67-catalogo-do-bestiario.md):** 33 baralhos de dez, índices obrigatórios, enviesamento só no enchimento e ordem reproduzível por semente.

### Os chefes

`[DECIDIDO]` — o chefe da zona larga **a armadura dele e a arma dele**. E o feitiço, se lançar.

⚠️ **Mas o chefe não reaparece** (§1). Logo o baralho não serve — **o chefe larga tudo de uma vez**, na primeira e única morte. `[CLAUDE]` `→WP7`

*E vale dizer o que a referência faz aqui, porque é diferente e é pior para nós:* lá, o chefe larga **uma alma**, que se troca por **um** de vários objectos possíveis — e escolher um **fecha os outros até uma passagem nova**. É uma boa mecânica de rejogo, mas **num jogo de dois amigos é frustração**: um escolhe, o outro queria o outro. **Nós largamos tudo.**

---

## 4. Armadura pesada — o custo é movimento

`[DECIDIDO]` — *"tem que ser tipo o Dark Souls: mais pesada, a rolagem vai demorar mais, ele não vai ter tanta agilidade."*

✅ **Já está desenhado** — [`39`](39-estudo-profundo.md) §3, com os três escalões e a tabela. **Confirma-se agora pelo dono.**

⚠️ **Linha que não se atravessa:** a carga nunca muda a invencibilidade ([`38`](38-ataques-e-honestidade.md), cláusula 3). O contrato corrente cobra recuperação e regeneração; acima de 100% remove esquiva/corrida/sprint ([`70`](70-fecho-dos-sistemas-de-combate.md) §1.1).

---

## 5. Os atributos — a lista fechada

`[DECIDIDO]` — *"tem que ver quais as habilidades: vida, stamina, magia, inteligência, slot de magia, carga."*

| Atributo | O que dá |
|---|---|
| **Vida** | pontos de vida |
| **Stamina** | o recurso de todas as acções |
| **Magia** | ⚠️ nome histórico; o modelo corrente usa **mana** calculada pelo maior de Inteligência/Fé |
| **Inteligência** | força dos feitiços |
| **Slots de magia** | quantos feitiços se levam |
| **Carga** | quanto se veste sem ficar pesado |

⚠️ **Duas notas honestas:**

1. ~~**"Magia" e "slot de magia" podem ser o mesmo atributo.**~~ **Superada:** não existem slots. A reserva de mana usa o maior de Inteligência/Fé; favoritos não são atributo ([`54`](54-mana-meditacao-e-tracos-de-classe.md)).
2. ⚠️ **Falta Força e Destreza nesta lista**, e o [`11-formulas.md`](11-formulas.md) já as tinha para os requisitos de arma. O Mateus falou de destreza logo a seguir (§7). **Assumo que continuam** — se não, é `[EM ABERTO]`. `→WP2`

---

## 6. ⭐ A magia — a classe mais vasta do jogo

`[DECIDIDO]`, e com ênfase:

> *"O mago vai ser o que mais está dado no jogo, o mais apelão. As magias fazem tudo, desde cura a dano e buffs e elementos. Vamos ser bem vastos em magia — vai ser a classe que eu mais gosto."*

E `[DECIDIDO]` — **magia do mal** entra, ao lado de raio, fogo, veneno e escuridão ([`37`](37-aneis-e-elementos.md)).

**O estudo inteiro está no [`42-estudo-magia.md`](42-estudo-magia.md)** — é o documento mais longo deste lote, de propósito.

### ⚠️ E a tensão que isto cria, dita à frente

**Se a magia faz tudo — cura, dano, buffs, elementos — o mago é objectivamente melhor do que as outras classes.** Isso quebra a Lei 3 pela porta das traseiras: qualquer classe pode pegar num cajado, mas se o cajado resolve tudo, **só há uma escolha certa**.

`[TENSÃO]` — proponho, **não decido**:

> A magia é a mais **vasta em verbos** — faz coisas que mais nada faz. O travão corrente é mana sem regeneração, conjuração interrompível, oito favoritos e custos próprios da escola; **cura por frasco não partilha cargas** ([`54`](54-mana-meditacao-e-tracos-de-classe.md), [`66`](66-catalogo-de-magia.md)).

Assim o mago continua a ser a classe mais rica e mais divertida — que é o que o Mateus quer — **sem ser a classe correcta**. `→WP3`/`→WP4`, e vai à [`99`](99-perguntas-abertas.md).

---

## 7. As outras classes não levam menos cuidado

`[DECIDIDO]` — *"não temos que deixar de pensar nas outras classes. Espadachim também é muito legal — é muita habilidade e tem que ter destreza, geralmente é com katana. Capriche nas katanas, capriche nas espadas."*

`→WP3`/`→WP5`:
- **Espadachim = destreza**, e a katana é a arma-símbolo dele
- **Capricho** na família das katanas e na das espadas — mais variedade e mais cuidado do que a média

*Nota de estudo, no [`41`](41-estudo-armas-e-golpes.md) §2:* na referência as katanas são **meio-termo de alcance e velocidade, com dano de contra-ataque muito alto** e ataques em corrida fortes. **É uma família definida por punir quem ataca**, não por bater mais — e isso é exactamente "muita habilidade".

---

## 8. ⭐ Cada arma bate de forma diferente — e nada é decoração

`[DECIDIDO]`, e é uma regra de engenharia:

> *"Espada gigante, espada curta — tem que ser a forma que ele bate diferente. **Nada é uma animação, tudo é calculado.** Tudo é igual no Dark Souls, tem que ser pensado."*

**O que isto proíbe:** duas armas com números diferentes e o mesmo comportamento. Se a espada gigante só faz mais dano, **é a espada curta com outro modelo**.

**O que isto obriga** `→WP5` — cada família declara, **e cada número tem de significar alguma coisa no jogo**:

| O que declara | Porque é que muda o jogo |
|---|---|
| **Arco e alcance** do golpe | apanha dois inimigos, ou um |
| **Frames** de arranque, activos e recuperação | dá para encaixar entre golpes, ou não |
| **Dano de interrupção** ([`39`](39-estudo-profundo.md) §4) | interrompe o inimigo, ou não |
| **Se tem hiper-armadura**, e em que frames | aguenta o golpe dele para dar o meu |
| **Custo de stamina** por golpe | quantos golpes seguidos |
| **Bónus de contra-ataque** | recompensa quem ataca no tempo certo |
| **Multiplicador crítico** | vale mais pelas costas do que de frente |
| **Arte a 1 mão e a 2 mãos** ([`34`](34-catalogo-e-comandos.md) §2b) | dois verbos por arma |

⭐ **A regra de aceitação:** se duas armas só diferem em números, **uma delas não devia existir**. Uma família nova entra quando responde a uma **pergunta** que nenhuma outra responde.

---

## 9. Inventário sem limite — só o equipado pesa

`[DECIDIDO]` — *"a gente não pode ter limites para carregar no inventário, não vamos ter isso. O que está equipado é diferente — a gente pode usar o mesmo sistema do Dark Souls: setenta por cento do peso, o personagem fica pesado."*

| | |
|---|---|
| **Mochila** | **sem limite**, de peso ou de espaços |
| **Peso** | conta **só o que está vestido ou na mão** |
| **Limiar** | **70%** → pesado ([`39`](39-estudo-profundo.md) §3) |

✅ **É exactamente o modelo da referência**, e está confirmado: *"não há limite de peso; só os itens equipados contam para a carga."*

⭐ **E é a decisão certa por uma razão que vale escrever:** gerir espaço na mochila **não é jogabilidade, é administração**. O que é jogabilidade é decidir **o que vestir** — e essa decisão fica intacta, porque o peso do equipado continua a contar. `→WP5`/`→WP11`

---

## 10. Baús

`[DECIDIDO]` — *"tem que ter baús pra gente pegar armas e coisas assim."*

`→WP8` — e o estudo da colocação de segredos está no [`43`](43-estudo-espolio-inventario-mundo.md) §4.

---

## 11. ⭐ Espólio com preferência pela classe

`[DECIDIDO]` — *"de preferência que o jogo dê alguma preferência nos itens dropados da nossa classe. Por exemplo, se eu jogar com mago, é mais chance de vir coisas de magia — recuperação de magia, feitiços e coisas assim."*

### Como isto encaixa no baralho `[CLAUDE]`

Sem quebrar a garantia da §3:

| Cartas | Enviesadas pela classe? |
|---|---|
| **As peças e a arma que se vêem no inimigo** | ❌ **nunca** — são a promessa, e a promessa não muda |
| **As cartas de enchimento** | ✅ **sim** — é aqui que vive a preferência |

**Um mago tira das cartas de enchimento** mais material de feitiço; um espadachim tira mais pedras de melhoria e material de arma. A mana não cai como “carga de energia”.

⚠️ **E a regra que isto obriga em co-op** `→WP10`: se os dois jogam classes diferentes, **o enviesamento é de quem dá o golpe final** ou é partilhado? Vai à [`99`](99-perguntas-abertas.md). *(Proposta `[CLAUDE]`: cai uma carta para cada um, enviesada pela classe de cada um. Ninguém disputa espólio com um amigo.)*

---

## 12. ⭐ Feitiços nunca repetem; armas podem

`[DECIDIDO]` — *"a gente não pode ter dois feitiços repetidos. Armas e coisas assim a gente pode."*

| | Repete? |
|---|---|
| **Feitiços** | ❌ **nunca.** Cada feitiço existe **uma vez no mundo** |
| Armas, armaduras, material, consumíveis | ✅ sim |

⚠️ **Isto proíbe uma mecânica da referência, e o Mateus tem razão em proibi-la.** Lá, atribuir o **mesmo feitiço duas vezes soma as cargas** — dois espaços do mesmo feitiço dão o dobro dos lançamentos. É a forma como se conseguem mais lançamentos, e transforma os espaços de magia numa conta de multiplicar em vez de numa escolha.

**Com feitiços únicos, cada espaço é uma decisão a sério:** o que levo é o que vou ter, e mais nada.

⭐ **Mas isso abre um buraco que tem de ser tapado:** se não se pode duplicar, **como é que se ganham mais lançamentos?** A resposta é a decisão seguinte, e as duas encaixam uma na outra.

---

## 13. ⭐ Melhoria de feitiços

`[DECIDIDO]` — *"a gente também tem que conseguir fazer o upgrade nas coisas, nas armas. As magias também podem ter o upgrade — torná-las mais fortes, mais áreas atingidas."*

⭐ **Isto não existe na referência**, e é uma das nossas melhores ideias próprias. Lá, um feitiço é o que é para sempre; a única forma de o "melhorar" é duplicá-lo — que é precisamente o que a §12 proíbe.

**Um feitiço melhora em três eixos** `[CLAUDE]`, e devem ser **eixos separados**, não um número só:

| Eixo | O que muda | Lei 2? |
|---|---|---|
| **Força** | dano ou cura | número — o eixo aborrecido |
| ⭐ **Área** | de um alvo para vários; raio maior | **verbo novo** |
| ⭐ **Lançamentos** | mais vezes por descanso | substitui a duplicação proibida |

⭐ **E a regra que faz isto valer a pena:** pelo menos um nível de melhoria de cada feitiço tem de dar **área ou lançamentos**, nunca só força. Um feitiço melhorado que só faz mais dano é a Lei 2 quebrada. `→WP4`

**O sistema inteiro fica desenhado no [`42-estudo-magia.md`](42-estudo-magia.md) §6.**

---

## 14. Carregamento por área

`[DECIDIDO]` — *"dá pra colocar o jogo pra carregar apenas a área que a gente está indo. Não carregar o jogo inteiro — carrega uma área por vez. Assim a gente já consegue melhor desempenho."*

✅ **Sim, dá — e é exactamente o que a referência faz.** Com 8 GB de memória e gráficos integrados (Lei 4), **não é uma optimização: é a única forma de o jogo caber.**

O estudo técnico está no [`43`](43-estudo-espolio-inventario-mundo.md) §6. `→WP14`

---

## 15. O mundo é vasto de propósito

`[DECIDIDO]` — *"dá pra perceber que ele vai ter o mundo bem vasto porque são bastantes chefes, bastantes inimigos. O jogo não pode ser muito curto, os inimigos um em cima do outro. A gente tem que descobrir coisa."*

**Duas coisas, e são diferentes:**
1. **Não amontoar inimigos.** Densidade não é dificuldade — é a crítica que o [`39`](39-estudo-profundo.md) §9 já registou
2. **Tem de haver o que descobrir.** É o [`39`](39-estudo-profundo.md) §12, agora confirmado pelo dono

⚠️ **E fica dito o que isto custa, porque o meu trabalho é dizer:** mundo vasto + 61 chefes + 10+ biomas, **feito por duas pessoas**, é o maior risco do projecto e está assinalado desde o [`00-visao.md`](00-visao.md). **Não estou a pedir para cortar** — o Mateus decidiu e é o dono. Estou a registar que a resposta certa é a do [`39`](39-estudo-profundo.md) §8: **círculos e atalhos fazem um mundo grande sentir-se grande sem custar conteúdo.** É a única alavanca que dá vastidão barata.

---

## 16. Instrução para o Fable

`[DECIDIDO]` — *"temos que instruir o do Henrique a fazer isso nos colaboradores, porque daí a gente consegue muita coisa nesse jogo."*

*(«Henrique» = **Rico** — [`CLAUDE.md`](../CLAUDE.md).)*

Entra no [`prompts/REALINHAMENTO.md`](../prompts/REALINHAMENTO.md), parte A.

---

## O que isto abre e é dos donos

| Pergunta | Onde |
|---|---|
| ~~"Magia" e "slots de magia" são o mesmo atributo?~~ **Dissolvida: não há slots** | [`54`](54-mana-meditacao-e-tracos-de-classe.md) |
| Força e Destreza continuam na lista? | §5 |
| ⚠️ **O mago faz tudo — como é que não é a classe correcta?** *(custos actuais em mana/tempo/favoritos; suficiência continua na pergunta 28 do [`99`](99-perguntas-abertas.md))* | §6 |
| Em co-op, o enviesamento do espólio é de quem dá o último golpe? *(proposta: uma carta para cada um)* | §11 |

→ entram na [`99-perguntas-abertas.md`](99-perguntas-abertas.md).

## Ligações

[`41-estudo-armas-e-golpes.md`](41-estudo-armas-e-golpes.md) · [`42-estudo-magia.md`](42-estudo-magia.md) · [`43-estudo-espolio-inventario-mundo.md`](43-estudo-espolio-inventario-mundo.md) · [`39-estudo-profundo.md`](39-estudo-profundo.md) · [`38-ataques-e-honestidade.md`](38-ataques-e-honestidade.md) · [`34-catalogo-e-comandos.md`](34-catalogo-e-comandos.md)
