# 42 — Estudo: magia, do princípio ao fim

> ⚠️ **LEITURA ACTUAL:** as escolas e a grelha de verbos deste estudo continuam a mandar; a §3 (espaços/energia) e os travões da §8 que dependem de slots ou bolo partilhado foram **revogados** pelo [`54`](54-mana-meditacao-e-tracos-de-classe.md). O catálogo que os substitui é o [`66`](66-catalogo-de-magia.md).

`[DECIDIDO]` (Mateus, 31-07-2026) — *"o mago vai ser o que mais está dado no jogo, o mais apelão. As magias fazem tudo, desde cura a dano e buffs e elementos. Vamos ser bem vastos em magia — vai ser a classe que eu mais gosto."*

> **É o documento mais longo deste lote, de propósito.** A magia é a área onde o Mateus quer mais profundidade, e é também a que estava mais vazia na spec.

---

## 1. Como a magia se divide lá — e porquê

Não é uma lista de feitiços. São **escolas**, e cada uma existe por uma razão mecânica:

| Escola | Atributo | Instrumento | O que ela é |
|---|---|---|---|
| **Feitiçaria** | Inteligência | cajado | dano à distância, precisão, utilidade |
| **Milagre** | Fé | sino / talismã | **cura**, reforços, raio |
| **Piromancia** | INT **e** Fé juntas (tecto 40/40) | chama | fogo, e é **a mais fácil de entrar** |
| ⭐ **Feitiço do mal** | ⭐ **o MENOR dos dois** (INT ou Fé), tecto 30/30 | cajado **ou** sino | dano de escuridão + reforços próprios |

### ⭐ E a peça de desenho que vale ouro

> **O dano de escuridão escala com o MENOR entre Inteligência e Fé.**

Pára e pensa no que isto faz. Não é um detalhe — **é a única forma limpa de tornar uma escola cara sem lhe pôr um requisito artificial.**

Um mago puro tem 40 de Inteligência e 9 de Fé → **a magia do mal dele escala com 9**. Para a usar a sério, tem de **subir os dois**, e isso custa o dobro dos níveis. **A escola do mal é a mais poderosa e a mais cara, e o preço está na matemática, não numa tranca.**

É exactamente a Lei 3: **ninguém está proibido** de usar a magia do mal. Só que quem quiser tem de pagar por ela em pontos — e paga em vez de outra coisa.

⭐ **Proposta `[CLAUDE]` `→WP4`: adoptar tal e qual.** É a resposta certa para a *"magia do mal"* que o Mateus pediu.

**Fontes:** [Hexes — DS2 Wiki](https://darksouls2.wiki.fextralife.com/Hexes) · [Magic — DS2 Wiki](https://darksouls2.wiki.fextralife.com/Magic) · [How do hexes scale](https://gamefaqs.gamespot.com/boards/693331-dark-souls-ii/68852769)

---

## 2. O instrumento importa tanto como o feitiço

⭐ **Um feitiço não tem dano próprio.** O que ele tem é uma **percentagem** — e a força vem do instrumento que o lança.

**As fórmulas reais**, e reparem no formato:

| Feitiço | Fórmula |
|---|---|
| dardo simples | `dano = 1,16 × força_do_cajado − 42,2` |
| dardo pesado grande | `dano = 2,84 × força_do_cajado − 111,8` |
| cura pequena | `150% × força_do_instrumento` |
| cura grande | `550% × força` |
| cura maior | `700% × força` |

### O que isto nos ensina, e muda o nosso catálogo

1. ⭐ **O cajado é metade da personagem.** Trocar de cajado muda **todos** os feitiços de uma vez. Isso é uma decisão grande e barata de implementar — é um número, não um sistema
2. ⭐ **A subtracção no fim (`− 42,2`) é anti-truque.** Faz com que um feitiço forte lançado com um instrumento fraco seja **desproporcionalmente mau**. Impede o jogador de apanhar o feitiço mais forte cedo e saltar metade do jogo. **É a Lei 1 na equação:** o poder está na personagem, não no objecto que se encontrou
3. **A cura na mesma escala que o dano** significa que investir em magia **cura mais**. É elegante — não é preciso um atributo de cura

`→WP4` — **todo o feitiço se escreve como percentagem + subtracção, nunca como número fixo.**

**Fonte:** [DS3 mechanics cheat sheet](https://github.com/gastevens/dark-souls-3-mechanics-cheat-sheet/blob/master/ds3mechanicscheatsheet.md)

---

## 3. Os espaços e a energia — os números exactos

O atributo de magia dá **duas coisas ao mesmo tempo**, com tectos diferentes:

| Atributo | Espaços | Energia |
|---|---|---|
| 10 | **1** | 93 |
| 14 | 2 | 114 |
| 18 | 3 | 136 |
| 24 | 4 | 181 |
| **30** | **5** ← tecto dos espaços | 233 |
| 40 | 6 | 296 |
| **35** | — | ← tecto da energia |

### O que isto nos ensina

⭐ **Os saltos são irregulares de propósito** — 10, 14, 18, 24, 30, 40. Os primeiros espaços são baratos e os últimos são caríssimos. **Cada espaço novo é uma decisão maior do que o anterior**, e isso é o que impede o mago de levar tudo.

⭐ **E um atributo que dá duas coisas com tectos diferentes é melhor desenho do que dois atributos.** Depois dos 30, continuar a subir já **não dá espaços** — só energia. O jogador que quer mais variedade **pára aos 30**; o que quer lançar mais vezes continua. **Um número, duas construções.**

✅ **É a resposta directa à pergunta aberta na §5 do [`40`](40-decisoes-espolio-magia-inventario.md):** *"magia" e "slots de magia" são o mesmo atributo?* **A referência diz que sim, e diz porquê.** Recomendo fundir.

**Proposta `[CLAUDE]` `→WP2`/`→WP4`,** ajustada ao nosso tecto de nível 100:

| Atributo | Espaços |
|---|---|
| 10 | 1 |
| 14 | 2 |
| 18 | 3 |
| 24 | 4 |
| 30 | 5 |
| 40 | **6 — tecto** |

**Fontes:** [Attunement — DS3 Wiki](https://darksouls3.wiki.fextralife.com/Attunement) · [DS3 mechanics cheat sheet](https://github.com/gastevens/dark-souls-3-mechanics-cheat-sheet/blob/master/ds3mechanicscheatsheet.md)

---

## 4. Velocidade de lançamento — a estatística escondida

> **É a Destreza que governa a velocidade de lançamento**, e são precisos **50** para a máxima.

⭐ **Isto é fascinante, e é uma armadilha que devemos evitar.**

O que faz: obriga o mago a subir **Destreza** — um atributo que, à primeira vista, é do espadachim. Isso é bom, porque cria construções mistas e liga as classes.

⚠️ **Mas quebra a nossa cláusula 4** ([`38`](38-ataques-e-honestidade.md)): *o que se vê é o que acontece*. Um jogador que sobe Inteligência e vê os feitiços saírem à mesma velocidade **não faz ideia porquê**, porque nada no ecrã liga Destreza a magia.

**Proposta `[CLAUDE]` `→WP4`:** a velocidade de lançamento **vive no instrumento**, não num atributo escondido. Um cajado leve lança depressa e bate pouco; um pesado lança devagar e bate muito. **Mesma decisão, mesma profundidade — e visível.**

**Fonte:** [DS3 mechanics cheat sheet](https://github.com/gastevens/dark-souls-3-mechanics-cheat-sheet/blob/master/ds3mechanicscheatsheet.md)

---

## 5. ⚠️ O que a referência faz e nós proibimos

`[DECIDIDO]` (Mateus) — **não pode haver dois feitiços repetidos.**

**O que isso proíbe:** lá, atribuir **o mesmo feitiço em dois espaços soma os lançamentos** — duas cópias de um feitiço de 3 lançamentos dão 6. É assim que se ganham mais lançamentos, e há quem ande a caçar cópias em vez de feitiços novos.

⭐ **O Mateus tem razão em proibir, e a razão é boa:** com duplicação, um espaço de magia deixa de ser *"que feitiço levo?"* e passa a ser *"quantas cópias do melhor levo?"*. **Transforma uma escolha numa conta de multiplicar** — e o jogador acaba com um feitiço, seis vezes.

**Com feitiços únicos, cada espaço é uma pergunta a sério.** Cinco espaços, cinco verbos diferentes, e o que se deixa em casa dói.

⚠️ **Mas abre um buraco:** sem duplicação, **como é que se ganham mais lançamentos?** É a secção seguinte.

**Fontes:** [Attunement — DS2 Wiki](https://darksouls2.wiki.fextralife.com/Attunement) · [Same spells in multiple slots — Steam](https://steamcommunity.com/app/570940/discussions/0/2956039954084272350/)

---

## 6. ⭐ Melhoria de feitiços — o nosso sistema, que não existe lá

`[DECIDIDO]` (Mateus) — *"as magias também podem ter o upgrade: torná-las mais fortes, mais áreas atingidas."*

⭐ **Isto não existe na referência.** Lá, um feitiço é o que é para sempre. **É invenção nossa, e tapa exactamente o buraco que a §5 abriu.**

### Os três eixos

| Nível | Força | Área | Lançamentos |
|---|---|---|---|
| base | 100% | 1 alvo | 3 |
| +1 | 115% | 1 alvo | **4** |
| +2 | 130% | ⭐ **raio 2 m** | 4 |
| +3 | 145% | raio 2 m | **5** |
| +4 | 160% | ⭐ **atravessa, 2 alvos** | 5 |
| **+5** | **175%** | ⭐ **raio 4 m + atravessa** | **6** |

*(Números `[CLAUDE]`, ponto de partida para o marco 2 validar.)*

### ⭐ A regra que faz isto valer a pena

> **Pelo menos um nível em cada dois tem de dar ÁREA ou LANÇAMENTOS, nunca só força.**

Um feitiço melhorado que só faz mais dano é a Lei 2 quebrada — é o mesmo verbo com um número maior. **Um feitiço que passa a apanhar dois alvos é outro feitiço.**

⭐ **E há aqui uma coisa melhor do que na referência**, que vale escrever: lá, os feitiços fortes são feitiços **diferentes** dos fracos — apanha-se um novo e deita-se fora o antigo. **No nosso, o feitiço que apanhaste na primeira hora pode ser o que usas no fim**, porque cresceu contigo. Isso liga o jogador ao que ele encontrou, e é o oposto de descartável.

⚠️ **O que isto obriga:** o material de melhoria de feitiço é **escasso e é uma escolha** — melhorar este ou aquele. Se chegar para todos, o sistema desaparece. `→WP9`

`→WP4` — **cada feitiço traz a sua tabela de seis níveis.**

---

## 7. O catálogo de verbos — o que a magia faz

O Mateus quer *"bem vasto"*. Vasto não é muitos feitiços — é **muitos verbos**. Esta é a grelha que o `→WP4` tem de encher, e **nenhuma casa pode ficar vazia**:

| Categoria | Verbos | Elementos |
|---|---|---|
| **Dano directo** | dardo · raio traçado · projéctil pesado · explosão no alvo | fogo · raio · escuridão · **mal** |
| **Dano em área** | no chão · em redor de si · rasto que fica | fogo · veneno · escuridão |
| **Ao longo do tempo** | veneno · queimadura · rasto persistente | veneno · fogo |
| **Cura** | própria · ⭐ **do parceiro à distância** · ao longo do tempo | — |
| **Reforço próprio** | dano · defesa · stamina · velocidade | — |
| **Reforço da arma** | elemento na lâmina, 90 s ([`41`](41-estudo-armas-e-golpes.md) §7) | todos |
| **Enfraquecer** | menos defesa · mais lento · **atrair a atenção** | escuridão · mal |
| **Utilidade** | luz · ver no escuro · silenciar passos · ⭐ **marcar o inimigo para o parceiro** | — |
| **Defesa** | escudo temporário · reflectir · absorver um golpe | — |

⭐ **As três linhas com estrela são o que faz a magia valer num jogo de dois** — curar o parceiro à distância, marcar-lhe o alvo, dar-lhe visão. **São verbos que só existem porque somos dois**, e nenhum deles precisa de um número grande para ser bom.

⚠️ **E a regra de aceitação, a mesma das armas:** *cada feitiço tem de responder a uma pergunta que nenhum outro responde.* Dois feitiços de dano directo com elementos diferentes **são um feitiço**, a menos que o elemento mude o que se faz com ele.

`→WP4` — a grelha inteira, com pelo menos um feitiço por casa.

---

## 8. ⚠️ As regras que impedem o mago de ser a resposta certa

**A tensão está registada** no [`40`](40-decisoes-espolio-magia-inventario.md) §6: se a magia faz tudo, escolher outra coisa é escolher pior. **A Lei 3 cai pela porta das traseiras.**

**Aqui ficam as cinco regras que resolvem isso sem tirar nada ao que o Mateus quer.** A magia continua a ser a mais vasta e a mais divertida — só não é a mais fácil:

| # | Regra | O que custa ao mago |
|---|---|---|
| 1 | ⭐ **A energia vem do mesmo bolo que a cura** ([`39`](39-estudo-profundo.md) §7) | quem lança muito **cura pouco** |
| 2 | **5 ou 6 espaços, e os feitiços não repetem** (§3, §5) | leva 6 verbos, não 20 |
| 3 | ⭐ **Tudo o que voa tem tempo de voo e pode ser interrompido** ([`36`](36-fisica.md) §3) | ao perto, o mago perde |
| 4 | **A escola do mal custa o dobro em níveis** (§1) | o melhor é o mais caro |
| 5 | **Os reforços duram 90 s e só um de cada vez** ([`41`](41-estudo-armas-e-golpes.md) §7) | não dá para acumular antes de cada porta |

⭐ **A frase que resume:** o mago tem **as ferramentas mais interessantes do jogo e o menor número de erros permitidos**. É a classe mais rica e a mais exigente — que é, exactamente, a classe favorita de quem gosta de magia.

---

## 9. O que cada ficha de feitiço tem de trazer

`→WP4` — **nenhum feitiço entra sem estas colunas:**

| Campo | Exemplo |
|---|---|
| Nome · escola | Dardo · feitiçaria |
| **A pergunta que responde** | *dano fiável a média distância* |
| Fórmula | `1,16 × força − 42,2` |
| Custo em mana | 12 |
| Tempo de lançamento | 0,8 s |
| ⚠️ **Interrompível?** | ✅ sempre (regra do [`36`](36-fisica.md)) |
| Velocidade de voo · alcance | 35 m/s · 40 m |
| Tem queda? | ❌ (regra do [`36`](36-fisica.md) §3) |
| **Forma de entrega · contacto** | projéctil simples · instantâneo ([`55`](55-formas-de-feitico.md), [`38`](38-ataques-e-honestidade.md)) |
| **Onde não serve** | atrás de cobertura ou contra grupos dispersos |
| **Vector + como o inimigo escapa** | sair da linha · nunca “não dá” |
| **Tabela de 6 níveis** (§6) | forma · área · lançamentos; +1/+3/+5 abrem área ou lançamentos |
| ⚠️ **Como se activa** | selecciona num dos 8 favoritos e lança com `C`; ambos remapeáveis ([`34`](34-catalogo-e-comandos.md), [`66`](66-catalogo-de-magia.md)) |
| **Som + sinal visual equivalente** | assinatura material · silhueta/timing com a mesma informação |
| **Descrição visual** | material, forma, escala e acabamento específicos — fonte do prompt |
| **Fatia 1?** | ⬜ |

⚠️ **A penúltima linha vale para os dois lados.** O contrato de honestidade não é só para o inimigo — **um feitiço do jogador que não tem esquiva é tão injusto quanto um ataque de chefe que não tem.** Vai fazer falta no dia em que se testar co-op competitivo, e faz falta já para os inimigos que também lançam.

---

## O que fica em aberto

| | Onde |
|---|---|
| ~~Inimigos que lançam magia usam as mesmas regras?~~ **Sim na honestidade/contacto; não fingem mana/meditação do jogador.** | ✅ [`73`](73-fecho-dos-buracos-de-integracao.md) §1 |
| ~~A cura à distância funciona com que latência?~~ **Evento fiável/ordenado no compromisso, validado pelo anfitrião e aplicado pelo dono do corpo no tempo de voo; `cast_id` impede repetição, nunca rebobina morte e >150 ms mostra aviso. Elo Curador cura 30% de PV máximo.** | ✅ [`73`](73-fecho-dos-buracos-de-integracao.md) §1.1 |
| ~~Quantos feitiços na fatia 1?~~ **3: Dardo, Ruína e Égide** | ✅ [`66`](66-catalogo-de-magia.md) |
| ~~O material de melhoria de feitiço é o mesmo das armas, ou outro?~~ **Catálogo regional partilhado, sem moeda paralela.** | ✅ [`72`](72-materiais-consumiveis-e-economia.md) §2.1 |

## Ligações

[`40-decisoes-espolio-magia-inventario.md`](40-decisoes-espolio-magia-inventario.md) · [`41-estudo-armas-e-golpes.md`](41-estudo-armas-e-golpes.md) · [`39-estudo-profundo.md`](39-estudo-profundo.md) · [`37-aneis-e-elementos.md`](37-aneis-e-elementos.md) · [`36-fisica.md`](36-fisica.md) · [`13-magia.md`](13-magia.md) · [`12-classes.md`](12-classes.md)
