# 35 — Estudo da referência: números reais e o que eles nos dizem

> **Feito a 31-07-2026 pelo Claude**, aplicando o protocolo do [`31-referencias.md`](31-referencias.md) que nenhum dos 11 documentos do PR #11 chegou a usar. Dados de fontes públicas, com ligação.
>
> ⚠️ **A linha, outra vez:** isto estuda **estrutura**, não copia **conteúdo**. Não há aqui nomes de armas, de chefes, de zonas nem de personagens. Há contagens, arquitecturas e o que elas nos ensinam sobre as nossas.

---

## 1. Armas — a lição das categorias

| | Referência (DS2) | Nós | Diferença |
|---|---|---|---|
| Categorias de arma | **27** | 8 famílias propostas (WP5) | eles têm 3× mais **famílias**, não só mais armas |
| Total de armas | mais de 200 | ~120 alvo (20 × 6 classes) | comparável |
| Armas na fatia inicial | — | 5 | intencional |

### O que isto nos diz, e é a descoberta mais útil deste estudo

**Eles não têm 200 armas com 200 conjuntos de movimentos. Têm 27 categorias, e as armas dentro de cada categoria partilham o conjunto.** Espadas rectas movem-se todas da mesma forma; o que muda são requisitos, escala por atributo, dano, peso e a arte da arma.

⚠️ **O nosso plano de 20 armas por classe está mal enquadrado.** Categorias de arma **não pertencem a classes** — a Lei 3 diz precisamente que qualquer classe pega em qualquer arma. Se organizarmos 20 armas "do guerreiro" e 20 "do mago", estamos a reintroduzir por trás a divisão que a Lei 3 recusa pela frente.

**O que a estrutura deles sugere:** organizar por **família de movimento**, não por classe. Com 8 famílias × 15 armas = 120, chega-se ao mesmo número **com 8 conjuntos de animação** em vez de um por arma. E cada classe *tende* para umas famílias por causa dos atributos, sem nunca ser proibida das outras.

`→WP5` — vale a pena reescrever o catálogo por famílias antes de o encher.

**Fontes:** [Weapons — DS2 Wiki (Fextralife)](https://darksouls2.wiki.fextralife.com/Weapons) · [Weapon Types — Dark Souls Wiki](https://darksouls.fandom.com/wiki/Weapon_Types_(Dark_Souls_II))

---

## 2. Armadura — o nosso número está curto

| | Referência (DS2) | Nós | Diferença |
|---|---|---|---|
| Peças | 4 espaços: elmo, peito, mãos, pernas | 4 espaços (já decidido) | ✅ igual |
| Conjuntos | **mais de 100** | ~30 alvo | eles têm 3× mais |
| Mistura de peças | livre, sem bónus de conjunto | livre | ✅ igual |
| Melhoria | +5 dá **+50%** de defesa · +10 dá **+100%** | não existe | ⬜ lacuna |

**Cada peça carrega:** defesa física, mágica, de fogo e de raio · **poise** (resistência a ser interrompido) · resistências a veneno, sangramento, escuro, petrificação e maldição.

### O que isto nos diz

1. **30 armaduras não são muitas — são poucas.** Como são 4 peças, 30 *conjuntos* dão 120 peças, e aí o número faz sentido. Mas se "30 armaduras" significar 30 peças no total, o jogador terá pouca escolha. `→WP5` tem de dizer qual dos dois.
2. **A nossa ideia de "resistências por tipo em vez de defesa plana" já é o modelo deles** — e é a saída para a tensão com a Lei 1 que registámos no [`33-morte-e-almas.md`](33-morte-e-almas.md). Boa notícia: não estamos a inventar, estamos a seguir um padrão provado.
3. ⚠️ **O detalhe do DS2 que vale ouro para nós:** naquele jogo, a velocidade do rolamento **não depende só do peso** — depende de um atributo próprio (Adaptabilidade). Isso foi das mecânicas mais criticadas do jogo, precisamente porque **esconde uma coisa de perícia (a esquiva) atrás de uma estatística.**

   **É exactamente o que a nossa Lei 1 proíbe.** Fica registado como coisa a **não** copiar: no nosso jogo a janela de invencibilidade da esquiva é fixa (300 ms, WP1) e não escala com atributo nenhum. Se alguém propuser um "atributo de agilidade" que melhore a esquiva, a resposta é não.

**Fonte:** [Armor — DS2 Wiki (Fextralife)](https://darksouls2.wiki.fextralife.com/Armor)

---

## 3. Progressão — a curva de almas

| | Referência (DS2) | Nós |
|---|---|---|
| Custo por nível | cúbico: ≈ `0,02×N³ + 3,06×N² + 105,6×N − 895` | por definir |
| Tecto | 838 (soft cap ~199) | **100** `[DECIDIDO]` |
| Custo até ao tecto | ~406 milhões de almas | por definir |

### O que isto nos diz

- **A curva é cúbica, não linear.** Cada nível custa desproporcionalmente mais do que o anterior. É isso que faz os primeiros 30 níveis serem rápidos e os últimos serem uma escolha a sério.
- **O nosso tecto de 100 é bem mais apertado que o deles**, e isso é bom: com soft cap deles aos ~199, o nosso 100 fica dentro da zona onde cada ponto ainda conta. Não temos o problema de níveis que não fazem diferença.
- ~~⚠️ **O WP9 escreveu a curva com `XP = 80 + 20×n` — que é linear.**~~ **CORRIGIDO NA TAREFA 4:** a moeda chama-se almas e a curva cúbica, os quatro marcos e o runtime canónico vivem no [`72`](72-materiais-consumiveis-e-economia.md) §2. A observação histórica explica o porquê da correcção, não reabre a fórmula.

**Fontes:** [Level — DS2 Wikidot](http://darksouls2.wikidot.com/level) · [Level Up — Dark Souls Wiki](https://darksouls.fandom.com/wiki/Level_Up)

---

## 4. Cura — os dois eixos do frasco

| | Referência (DS2) | Nós |
|---|---|---|
| Frascos iniciais | 1 | por definir |
| Máximo | **12** (11 melhorias) | por definir |
| Cura por frasco | 550 → **800** no máximo (+50 por melhoria, até +5) | por definir |
| Beber | **pára o jogador completamente** | ✅ igual (WP1) |
| Alternativa | consumível mais lento que só abranda o movimento | não existe |

### O que isto nos diz

**Melhora-se em dois eixos separados:** quantos frascos (11 melhorias) e quanto cada um cura (5 melhorias). Isso responde à pergunta que ficou aberta no [`33-morte-e-almas.md`](33-morte-e-almas.md) — *"mais frascos ou frascos mais fortes?"*. **A resposta deles é as duas coisas, com moedas de melhoria diferentes**, e é uma boa resposta: dá ao jogador uma escolha real sobre como quer sobreviver.

**A segunda lição é mais subtil:** eles têm um consumível alternativo que cura **devagar mas sem parar o jogador**. Isso cria uma decisão táctica dentro do combate — curar depressa e ficar exposto, ou curar devagar e continuar a mexer. Vale a pena considerar. `→WP5`

**Fontes:** [Estus Flask — DS2 Wiki](https://darksouls2.wiki.fextralife.com/Estus_Flask) · [Estus Flask Shard](https://darksouls2.wiki.fextralife.com/Estus_Flask_Shard)

---

## 5. Estados alterados — a lacuna, agora com forma

Era uma das duas lacunas reconhecidas ([`31-referencias.md`](31-referencias.md)). Como funcionam lá:

| Estado | Como funciona |
|---|---|
| **Sangramento** | medidor que enche; ao encher, **dano de golpe** (200) **+ stamina máxima e recuperação drasticamente reduzidas**, rolamento mais lento, movimento mais lento. O medidor **desce sozinho** se parar de levar |
| **Veneno** | dano ao longo de ~20 s, ~1080 no total se não for curado |
| **Maldição** | efeito permanente até ser removido; bloqueia funcionalidades |
| **Resistência** | cada 10 pontos reduz 1% de acumulação; 900 dá imunidade |

### O que isto nos diz, e é importante para a Lei 1

**O modelo do medidor que enche e desce sozinho é o certo para nós.** Não é dano surpresa: o jogador **vê** a barra a encher e pode reagir — afastar-se, curar, mudar de abordagem. É informação, não punição aleatória.

E repara no que o sangramento deles faz: **ataca a stamina**, não a vida. Isso é muito mais interessante do que "tira vida ao longo do tempo", porque muda **como se joga** o resto do combate — menos esquivas, menos ataques. É a Lei 2 aplicada ao lado do inimigo.

⚠️ **Uma coisa a evitar:** o estado que bloqueia funcionalidades (a maldição) é castigo administrativo, não jogabilidade. Com dois amigos a jogar, não faz sentido nenhum.

**Fontes:** [Negative Status Effects (DS2)](https://darksouls.fandom.com/wiki/Negative_Status_Effects_(Dark_Souls_II)) · [Status Effects — DS2 Wiki](https://darksouls2.wiki.fextralife.com/Status_Effects)

---

## 6. Chefes — o nosso número é o problema que já sabíamos

| | Referência (DS2) | Nós |
|---|---|---|
| Jogo base | **33** | ~61 planeados |
| Com todo o conteúdo adicional | **42** | — |
| Na fatia inicial | — | 1 |

**Um jogo inteiro e aclamado do género tem 33 chefes.** Nós temos 61 planeados, **feitos por duas pessoas**. Isto já estava assinalado como o maior risco de escopo ([`00-visao.md`](00-visao.md)); agora tem um número ao lado para comparar.

Não é para cortar hoje. É para saber que **61 é quase o dobro de um jogo completo com estúdio por trás**, e que a pergunta certa não é "quantos chefes" mas "quantos na fatia 2".

**Fonte:** [Bosses — DS2 Wiki](https://darksouls2.wiki.fextralife.com/Bosses)

---

## O que este estudo produziu — resumo accionável

| # | Descoberta | Onde bate |
|---|---|---|
| 1 | **Organizar armas por família de movimento, não por classe** — 20 armas por classe reintroduz a divisão que a Lei 3 recusa | `→WP5` **reescrever** |
| 2 | A curva de nível deles é **cúbica**; a nossa (`80 + 20n`) é **linear** e perde a tensão | `→WP2/WP9` **rever** |
| 3 | **30 armaduras**: são 30 conjuntos (=120 peças) ou 30 peças? Muda tudo | `→WP5` **definir** |
| 4 | Melhoria de frascos tem **dois eixos** (quantidade e potência), com moedas diferentes | `→WP5` |
| 5 | Estados alterados: **medidor visível que enche e desce**; o de sangramento ataca a **stamina**, não a vida | `→WP5/WP6` |
| 6 | **Melhoria de armas** existe lá como sistema inteiro (+5/+10 com percentagens); na nossa spec não existe | `→WP5` |
| 7 | ⚠️ **A esquiva deles depende de um atributo — não copiar.** É o que a nossa Lei 1 proíbe, e foi das coisas mais criticadas do jogo | regra a manter |
| 8 | Um jogo completo do género tem **33 chefes**; nós planeámos 61 | `→WP7` calibrar |

## O que ainda não foi estudado

Fica para quem pegar nos pacotes: interligação de mapa e atalhos (`→WP8`) · colocação de pontos de descanso (`→WP8`) · estrutura de fases de chefe (`→WP7`) · IA e agressão (`→WP6`, mas o nosso círculo de agressão já é boa resposta) · economia de vendedores (`→WP9`).
