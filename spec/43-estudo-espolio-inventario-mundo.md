# 43 — Estudo: espólio, inventário, segredos e carregamento

> Estudo de 31-07-2026. Sustenta as decisões §3, §9, §10, §11, §14 e §15 do [`40`](40-decisoes-espolio-magia-inventario.md).

---

## 1. Como o espólio funciona lá — e porque é que não serve para nós

| | Como é |
|---|---|
| Base | **100** de "descoberta de itens" |
| Máximo | **410**, com equipamento dedicado |
| O atributo de sorte | **1 ponto = 1 de descoberta**, até 199 |
| O que o número faz | é um **multiplicador ao peso do item** na tabela (`descoberta ÷ 100`) |
| ⭐ Quando se calcula | **no momento da morte do inimigo** — mudar de anel depois de matar e antes de apanhar **não faz nada** |

### O que isto nos ensina

1. ⭐ **Calcular no momento da morte é a decisão correcta, e é anti-batota.** Sem isso, o jogo óptimo é matar tudo e depois trocar de equipamento antes de apanhar. **Adoptamos** `→WP9`
2. ⚠️ **Mas o modelo inteiro é probabilístico, e isso é incompatível com o que o Mateus decidiu.**

### A matemática, para ficar claro porque é que não serve

O Mateus quer que **em 10 mortes o inimigo largue as 4 peças + a arma**. Com espólio aleatório a 20% por item:

| | Probabilidade |
|---|---|
| Sair uma peça específica em 10 mortes | 89% |
| ⚠️ **Sair as 5 em 10 mortes** | ⚠️ **~32%** |

**Dois terços dos jogadores nunca completariam o conjunto** — e com o tecto de 10 mortes ([`40`](40-decisoes-espolio-magia-inventario.md) §1), **nunca mais teriam outra hipótese**. O item ficava perdido para sempre, por sorte.

⭐ **Sorte não é a Lei 1.** Um item atrás de um dado é conteúdo trancado por uma coisa que o jogador não controla — pior do que atrás de um nível, porque nem sequer se pode trabalhar para lá chegar.

**Fontes:** [Item Discovery — DS3](https://darksouls3.wiki.fextralife.com/Item_Discovery) · [Item Discovery — Wikidot](http://darksouls.wikidot.com/item-discovery) · [Item Discovery — DS2](https://darksouls2.wiki.gg/wiki/Item_Discovery)

---

## 2. ⭐ O baralho — o nosso mecanismo

`[CLAUDE]`, a cumprir a decisão do [`40`](40-decisoes-espolio-magia-inventario.md) §3.

### Como funciona

Cada **tipo** de inimigo tem um baralho de **10 cartas**. Cada morte **tira uma carta e não a repõe**.

```
Baralho do lanceiro leve:
  [elmo] [peito] [luvas] [perneiras] [lança]     ← as 5 obrigatórias
  [almas+] [almas+] [material] [consumível] [?]  ← as 5 de enchimento
                                                    ↑ enviesada pela classe
```

| Propriedade | Consequência |
|---|---|
| Sem reposição | **as 5 obrigatórias saem sempre** dentro de 10 mortes |
| Ordem baralhada | a **emoção** mantém-se — não se sabe qual sai hoje |
| 10 cartas = 10 mortes | ⭐ **encaixa exactamente no tecto de reaparecimento** |
| Baralho por **tipo**, não por indivíduo | matar lanceiros diferentes conta para o mesmo baralho |

### Porque é que isto é melhor do que aleatório

| | Aleatório | Baralho |
|---|---|---|
| Garante o conjunto? | ❌ 32% | ✅ **100%** |
| Mantém surpresa? | ✅ | ✅ **na ordem** |
| O jogador sabe quanto falta? | ❌ | ✅ **conta as mortes** |
| Pode dar má sorte? | ✅ | ❌ **impossível** |
| Custa mais a implementar? | — | **uma lista e um índice** |

### O enviesamento pela classe

`[DECIDIDO]` (Mateus) — as **cartas de enchimento** são enviesadas; **as 5 obrigatórias nunca**.

| Classe | O que sai mais nas cartas de enchimento |
|---|---|
| Mago | material de feitiço · cargas de energia · pergaminhos |
| Espadachim | pedras de melhoria · material de arma |
| — | almas continuam a sair para todos |

⚠️ **A promessa não muda com a classe.** O que muda é o **acompanhamento** — senão um mago nunca chegaria a completar uma armadura, e isso seria uma tranca por classe (Lei 3).

### Os chefes

**Não reaparecem** → não há baralho. **Largam tudo de uma vez:** armadura, arma, e o feitiço se lançarem. `→WP7`

`→WP6` — **coluna obrigatória no bestiário: o baralho de 10.**

---

## 3. Os espaços de equipamento

### Como é lá

| Espaço | Quantos |
|---|---|
| Arma na mão direita | **3**, trocáveis em combate |
| Mão esquerda (escudo, cajado, 2.ª arma) | **3**, trocáveis em combate |
| Armadura | **4** — elmo, peito, mãos, pernas |
| Anéis | 2 a 4 conforme o jogo |
| Munição | 2 tipos |
| Atalho de consumíveis | ~10 na roda |

### O que isto nos ensina

⭐ **Três armas trocáveis em combate é mais importante do que parece.** É o que permite ao jogador **responder ao inimigo à frente** — trocar para a arma que magoa aquele tipo ([`39`](39-estudo-profundo.md), fraquezas do bestiário) sem ir a menus.

⚠️ **Mas custa teclas**, e o nosso orçamento é apertado ([`34`](34-catalogo-e-comandos.md) §2). **Proposta `[CLAUDE]` `→WP11`: 2 na direita, 2 na esquerda**, trocadas com `Q` e `E`. Metade da flexibilidade, um quarto das teclas.

⚠️ **E os anéis:** já temos **10 espaços** decididos ([`37`](37-aneis-e-elementos.md)) — muito acima dos 2–4 da referência. **Não é erro**, é decisão do Mateus, mas obriga a que os efeitos sejam pequenos e combináveis, senão dez anéis somam-se num jogador invencível. Fica ligado ao **piso de 30%** do [`39`](39-estudo-profundo.md) §1, que é o travão final.

**Fonte:** [Bottomless Box — Dark Souls Wiki](https://darksouls.wiki.fextralife.com/Bottomless+Box)

---

## 4. Baús, paredes falsas e mímicos

`[DECIDIDO]` (Mateus) — *"tem que ter baús pra gente pegar armas e coisas assim."*

### Como funcionam os segredos lá

| | Como é |
|---|---|
| **Parede falsa** | desaparece ao ser **atingida**, ou com um objecto próprio |
| O que esconde | um baú · um ponto de descanso · ⭐ **uma zona inteira** |
| Variação | algumas **só** respondem a um golpe; outras a uma fonte de luz |
| A pista | ⭐ **mensagens de outros jogadores perto** — é assim que se aprende que existem |
| **Mímico** | um baú que é um inimigo. Existe *"para tramar quem verifica armadilhas antes de abrir"* |
| ⭐ **O sinal do mímico** | *"levanta a tampa devagar, e volta a fechá-la devagar"* |

### ⭐ O que isto nos ensina

**O sinal do mímico é o contrato de honestidade aplicado ao cenário**, e é lindo: **o baú falso mexe-se.** Quem olha, vê. Quem corre, morre. **Não é uma armadilha — é uma telegrafia, e a resposta é a mesma que para um ataque: prestar atenção.**

Isso valida a regra que já escrevemos no [`39`](39-estudo-profundo.md) §9 — *toda a emboscada tem de ser visível para quem olha antes de avançar*. `→WP6`/`→WP8`: **o nosso mímico respira.**

⚠️ **E a pista das paredes falsas é um problema nosso.** Lá, aprende-se que existem **porque outros jogadores deixam mensagens**. Nós somos dois, e não temos isso.

**Proposta `[CLAUDE]` `→WP8`:** a nossa parede falsa tem sempre **um sinal no próprio cenário** — uma marca, pó/vegetação puxados pela corrente de ar e, como redundância, som atrás. O [`62`](62-acessibilidade-auditiva.md) proíbe que o som seja a única pista. Sem mensagens de estranhos, **o cenário tem de fazer o trabalho todo**, senão ninguém encontra nada e o conteúdo escondido é conteúdo que não existe.

⭐ **E a coisa que vale mais copiar de todas:** uma parede falsa que esconde **uma zona inteira**. É o pico da recompensa por atenção, e é a resposta directa ao *"a gente nunca zera"* ([`39`](39-estudo-profundo.md) §12).

**Fontes:** [Illusory Wall — Wikidot](http://darksouls.wikidot.com/illusory-wall) · [Illusory Wall — Fandom](https://darksouls.fandom.com/wiki/Illusory_Wall) · [Mimic](https://darksouls.fandom.com/wiki/Mimic)

---

## 5. Inventário e armazém

### Como é lá

> **Não há limite de peso para carregar.** Só os itens **equipados** contam para a carga.

E há um **armazém** com ~2000 espaços, acessível só nos pontos de descanso. A razão de existir é curiosa: **não é espaço** — é para *"a mochila activa ficar mais pequena e ser mais rápido encontrar as coisas em combate"*.

### O que isto nos ensina

✅ **A decisão do Mateus ([`40`](40-decisoes-espolio-magia-inventario.md) §9) é exactamente este modelo.** Confirmado.

⭐ **E o armazém não nos faz falta — faz falta a razão dele.** O problema real que ele resolve é **a mochila cheia de lixo à procura do frasco**. Com 30 armaduras e 120 armas ([`34`](34-catalogo-e-comandos.md) §1), vamos ter esse problema a sério.

**Proposta `[CLAUDE]` `→WP11`:** sem armazém — **filtros e favoritos**. A mochila é infinita e nunca se gere; o que se gere é **a vista**. Menos sistema, mesmo resultado, e nada se perde por engano num baú a que não se pode chegar.

**Fonte:** [Bottomless Box — Dark Souls Wiki](https://darksouls.wiki.fextralife.com/Bottomless+Box)

---

## 6. Carregamento por área

`[DECIDIDO]` (Mateus) — *"carrega uma área por vez, assim a gente consegue melhor desempenho."*

### Como é lá

| | Como é |
|---|---|
| O mundo | *"sem costuras, com poucos tempos de carregamento"* |
| O mecanismo | as zonas **entram em memória à medida que se avança**, não todas de uma vez |
| ⭐ **A porta de nevoeiro** | ⭐ **é a barreira de carregamento disfarçada** — segura o jogador enquanto o outro lado entra |
| Onde se nota | numa zona central, o nevoeiro **desaparece quando tudo acabou de carregar** |

### ⭐ O que isto nos ensina

**A porta de nevoeiro é uma peça de engenharia vestida de ficção**, e é a melhor ideia técnica deste estudo inteiro. Resolve **quatro** problemas com um objecto:

| Problema | Como o nevoeiro resolve |
|---|---|
| Carregar sem ecrã de carregamento | segura o jogador o tempo necessário |
| Marcar o ponto de não-retorno antes do chefe | vê-se e percebe-se |
| Impedir que um entre sem o outro | é uma barreira física — **e a nós isto serve para o co-op** |
| Fazer o mundo parecer contínuo | não há corte, há atravessar |

⚠️ **E para nós é obrigatório, não opcional.** Com **8 GB e gráficos integrados** (Lei 4), **o mundo todo em memória não cabe.** Não é uma optimização a fazer depois — é a condição para o jogo existir.

**Proposta `[CLAUDE]` `→WP14`/`→WP8`:**

1. **Uma zona = uma unidade de carregamento.** O que se carrega é a zona actual **e as vizinhas imediatas**
2. **O nevoeiro nas fronteiras**, e ele só levanta quando o outro lado está pronto
3. ⚠️ **Em co-op, quem manda é o mais lento.** O nevoeiro levanta quando **os dois** carregaram — senão um entra e o outro cai no vazio. `→WP10`
4. ⚠️ **Os círculos e atalhos do [`39`](39-estudo-profundo.md) §8 complicam isto**, e é preciso dizê-lo: um atalho que liga duas zonas distantes obriga a ter as duas prontas. **O traçado das zonas e o orçamento de memória desenham-se juntos**, não um depois do outro

**Fontes:** [Why FromSoftware games have fog walls — ScreenRant](https://screenrant.com/dark-souls-fog-walls-fromsoftware-demons-souls-loading/) · [Technical reason for fog gates — NeoGAF](https://www.neogaf.com/threads/is-there-a-technical-reason-for-fog-gates-in-dark-souls.1329271/)

---

## 7. O que este estudo produziu

| # | Descoberta | Onde bate |
|---|---|---|
| 1 | ⭐ **O baralho de 10 sem reposição** cumpre a garantia; aleatório dá 32% e falha | `→WP6` |
| 2 | ⭐ **O espólio calcula-se no momento da morte** — anti-batota | `→WP9` |
| 3 | ⭐ **O mímico respira** — a telegrafia aplicada ao cenário | `→WP6`/`→WP8` |
| 4 | ⭐ **Parede falsa que esconde uma zona inteira** — o pico da recompensa por atenção | `→WP8` |
| 5 | ⚠️ **Sem mensagens de estranhos, o cenário tem de dar a pista sozinho** | `→WP8` |
| 6 | ⭐ **A porta de nevoeiro é a barreira de carregamento** — resolve 4 problemas com 1 objecto | `→WP14` |
| 7 | ⚠️ **Em co-op o nevoeiro levanta pelo mais lento** | `→WP10` |
| 8 | **Sem armazém: filtros e favoritos** — o problema real é a vista, não o espaço | `→WP11` |
| 9 | **2+2 armas trocáveis em combate**, não 3+3 — orçamento de teclas | `→WP11` |
| 10 | ⚠️ **10 anéis é 3× a referência** — só funciona com o piso de 30% a segurar | `→WP5` |

## Ligações

[`40-decisoes-espolio-magia-inventario.md`](40-decisoes-espolio-magia-inventario.md) · [`39-estudo-profundo.md`](39-estudo-profundo.md) · [`37-aneis-e-elementos.md`](37-aneis-e-elementos.md) · [`34-catalogo-e-comandos.md`](34-catalogo-e-comandos.md) · [`15-inimigos.md`](15-inimigos.md) · [`17-mundo.md`](17-mundo.md) · [`23-tecnico.md`](23-tecnico.md)
