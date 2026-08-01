# 58 — O fim do jogo, os ciclos, e a matemática do nível 100

`[DECIDIDO]` (Mateus, 01-08-2026) — *"fim do jogo igual Dark Souls 2 ou 3, new game+ e tal. Para a gente chegar no nível 100 calcula direitinho, tem que ser proporcional. **No nível 70 tamos apelão** — o Dark Souls equilibra isso bem, vê lá como as coisas."*

---

# PARTE A — a curva, e a resposta ao "no nível 70 tamos apelão"

## 1. ⭐ A resposta curta: aos 70 **estás mesmo** forte. E é assim que deve ser.

**O problema não é seres forte aos 70. É não haver razão para chegar aos 100.** E a referência resolve isso com **três travões que trabalham juntos** — nós temos dois e falta-nos o terceiro.

| Travão | Temos? |
|---|---|
| **1. Custo cúbico** — cada nível custa desproporcionalmente mais | ⚠️ **não** — a nossa curva é linear |
| **2. Soft caps aos 40** — os pontos rendem quase nada depois | ⚠️ **não** — decidido no [`39`](39-estudo-profundo.md) §2, **por implementar** |
| **3. ⭐ Os níveis tardios compram LARGURA, não profundidade** | ⚠️ **nunca foi escrito** |

---

## 2. A matemática, com os números reais

**A fórmula da referência**, cúbica: `custo(N) ≈ 0,02×N³ + 3,06×N² + 105,6×N − 895`

**O que ela faz aos nossos 100 níveis:**

| Nível | Custo desse nível | Quantas vezes o nível 20 |
|---|---|---|
| 20 | ~2 600 | 1× |
| 40 | ~9 500 | **3,7×** |
| 70 | ~28 400 | **11×** |
| 100 | ~60 300 | ⭐ **23×** |

### ⭐ E o número que responde à tua pergunta

> **Ir do nível 70 ao 100 custa cerca de TRÊS VEZES tudo o que gastaste do 1 ao 70.**

**Não é um erro de desenho — é o desenho.** Os últimos 30 níveis não são progressão: são **obsessão**, e são opcionais.

| | |
|---|---|
| **Acabar o jogo** | dá-se por volta do **60–70** |
| **Nível 100** | é para quem quer **experimentar tudo**, não para quem quer ganhar |
| ⚠️ **Nunca é preciso** | Lei 1 — nenhum chefe verifica nível |

---

## 3. ⭐ E o terceiro travão, que é o que faltava: os pontos ficam **caros e inúteis** ao mesmo tempo

**Os soft caps aos 40 fazem a segunda metade da conta.** Com 8 atributos, base 10 cada, e 1 ponto por nível:

| Nível | Pontos ganhos | O que dá |
|---|---|---|
| 40 | 39 | **um** atributo no soft cap, e sobra pouco |
| 70 | 69 | **dois** atributos no soft cap |
| **100** | 99 | ⭐ **três** atributos no soft cap — e **nunca mais do que isso** |

⭐ **Com 8 atributos e tecto 100, nunca podes ter mais de três especialidades. Nunca.** É isso que impede o nível 100 de ser "o jogador completo" — é o jogador que escolheu **três**.

⚠️ **E o soft cap é o que impede o 4.º de valer a pena:** depois dos 40, cada ponto rende tão pouco que **espalhar é sempre pior do que aprofundar**. A escolha é real, e é permanente até haver reespecialização.

### ⭐ Os níveis 71–100 compram largura

**Depois de dois atributos no soft cap, mais pontos no mesmo não fazem quase nada.** O que fazem é **abrir outras coisas**:

| | Nível 70 | ⭐ Nível 100 |
|---|---|---|
| O que sabes fazer | duas coisas, muito bem | ⭐ **três coisas, muito bem** |
| Armas que podes usar | as da tua família | ⭐ **as de três famílias** |
| Magia | uma escola, ou nenhuma | ⭐ **uma escola a sério, ou duas pela metade** |
| ⚠️ Danos por golpe | ~igual | **~igual** |
| ⚠️ Vida | ~igual | **~igual** |

⭐ **É a Lei 2 aplicada ao nível: os últimos 30 níveis dão OPÇÕES, não números.** Não ficas mais forte — ficas **mais versátil**. E versátil não ganha lutas sozinho.

⚠️ **Isto obriga a uma coisa no `→WP2`:** vida e stamina **têm de ter soft caps mais duros do que os atributos de dano**. Senão subir vida é sempre bom, e o jogador "apelão" aos 70 é o que tem 70 pontos em sobrevivência. **O piso de 30%** ([`39`](39-estudo-profundo.md) §1) já ajuda — nenhuma armadura te torna imune — mas a curva tem de ajudar também.

---

## 4. O que fica decidido — `→WP2`

| | |
|---|---|
| ⭐ **Curva cúbica**, com a forma da referência ajustada ao nosso tecto de 100 | substitui a linear `80 + 20n` |
| ⭐ **Soft caps aos 40** em todos os atributos | ⚠️ **mais duros em vida e stamina** |
| **Acaba-se o jogo pelo 60–70** | e ninguém verifica nível — Lei 1 |
| ⭐ **Os últimos 30 níveis compram largura** | três especialidades, nunca quatro |
| ⚠️ **A validar a jogar** (M2) | os números exactos da curva |

---

# PARTE B — o fim do jogo e os ciclos

## 5. O que a referência faz

| | |
|---|---|
| **NG+** | ⭐ **+40%** de vida e dano nos inimigos |
| **NG+2 a NG+7** | **+8%** por ciclo, sobre o anterior |
| **Tecto** | ⚠️ **pára no NG+7.** Do NG+8 em diante não sobe mais |
| **NG++** | 151% do jogo base |

⭐ **E o DS2 faz muito mais do que números:**

- **Inimigos novos** aparecem — versões "fantasma negro" dos que já lá estavam
- **Mais inimigos** nos mesmos sítios
- ⭐ **Alguns chefes mudam** — mecânicas novas, ataques novos, inimigos a acompanhar
- ⭐ **Itens diferentes** em baús e corpos, e **itens que só existem em NG+** (anéis de nível mais alto)

⚠️ **O tecto no NG+7 é a decisão mais importante da lista** e é fácil de não perceber: **sem tecto, o jogo acaba por ser impossível e o esforço deixa de valer.** Com tecto, o NG+7 é uma **barra final** que se pode dominar.

**Fontes:** [New Game Plus — DS3 Wiki](https://darksouls3.wiki.fextralife.com/New_Game_Plus) · [NG Cycles — DS2 Wiki](https://darksouls2.wiki.gg/wiki/NG_Cycles) · [New Game Plus (DS2)](https://darksouls.fandom.com/wiki/New_Game_Plus_(Dark_Souls_II))

---

## 6. ⭐ E a peça que resolve um problema NOSSO: a brasa

**No DS2 há um item que sobe o ciclo de UMA zona só**, sem recomeçar o jogo. Queima-se na fogueira daquela zona, e aquela zona passa a NG+ — inimigos mais fortes, itens repostos, e ⭐ **o contador de mortes volta ao início**.

⭐ **Isto é a resposta à nossa pergunta 22, e andava à espera há dias.**

**O problema:** decidimos que cada inimigo só reaparece **10 vezes** ([`40`](40-decisoes-espolio-magia-inventario.md) §1), e a pergunta ficou aberta: *se os inimigos acabam, de onde vêm as almas para o nível 100?*

**A resposta:**

| | |
|---|---|
| ⭐ **A Brasa** | queima-se numa fogueira → **aquela zona sobe um ciclo** |
| O que faz | inimigos voltam **e o contador reinicia** · ficam mais fortes · itens repostos · **espólio novo** |
| ⚠️ **Não se desfaz** | aquela zona fica mais dura **para sempre** |
| Onde se arranja | rara — de chefes, de segredos, de vendedor a preço alto |

⭐ **E é por isso que não é grind:** não estás a repetir a mesma coisa por almas. **Estás a trocar dificuldade permanente por recurso.** Queimar uma brasa em Brumal é dizer *"nunca mais volto aqui a passear"* — e isso é uma decisão, não uma tarefa.

⚠️ **Com o travão que a mantém honesta:** a brasa sobe **uma zona**, nunca o mundo. E ⭐ **o guardião daquela zona volta** — pelo que a decisão é *"quero lutar com ele outra vez, mais forte?"*, e não *"quero mais almas"*.

---

## 7. O fim do jogo

`[CLAUDE]` `→WP8B` — ⚠️ **isto depende das 7 perguntas de narrativa** ([`26`](26-narrativa.md) §3) que continuam a precisar de uma gravação. **A estrutura pode fixar-se já; o conteúdo é dos donos.**

### A estrutura

```
matas o ULTRA
      │
      ▼
⭐ ESCOLHA — e é a última decisão do jogo
      │
      ├──► ⭐ os dois têm de concordar (somos dois)
      │
      ▼
 desfecho · créditos
      │
      ▼
⭐ NG+ — o mundo recomeça, tu não
```

### O que fica decidido

| | |
|---|---|
| ⭐ **O fim é uma escolha**, não um botão | é o que faz a segunda passagem valer |
| ⭐ **Em co-op, os dois têm de concordar** | ⚠️ e se não concordarem, **isso é uma conversa** — e é a melhor cena que este jogo pode dar |
| **Guarda-se tudo** | níveis, equipamento, feitiços, almas, brasas |
| ⚠️ **Perde-se** | ⭐ **as chaves e os atalhos** — o mundo volta a estar fechado. É o que faz o NG+ ser um percurso e não um passeio |
| **NG+** | **+40%** de vida e dano |
| **NG+2 a NG+7** | **+8%** por ciclo |
| ⚠️ **Tecto no NG+7** | **sem tecto, o esforço deixa de valer** |

### ⭐ E o que muda além dos números — que é o que faz voltar

| | |
|---|---|
| ⭐ **Inimigos novos** em sítios conhecidos | um bioma que sabes de cor deixa de ser seguro |
| ⭐ **Um subchefe a mais por bioma** | e não está onde estava |
| ⭐ **Alguns chefes ganham um ataque** | ⚠️ **um ataque, não uma fase.** Mais vida não é fase (Lei 2) |
| ⭐ **Itens só de NG+** | os anéis do fundo da escala, e **os feitiços que faltam ao catálogo** |
| ⭐ **As portas de história abrem-se** | ⚠️ **algumas.** As que o [`53`](53-chefes-ritmo-e-o-mago-forte.md) §2 deixou fechadas passam a ter resposta em NG+ |

⭐ **A última linha é a melhor ideia deste documento.** As portas que ficam por abrir no primeiro percurso — a torre desabada, o nome sem dono — **algumas respondem em NG+**. Isso transforma o segundo percurso de *"o mesmo mais difícil"* em ***"agora vou saber"***.

---

## O que fica em aberto

| | |
|---|---|
| ⏳ **Quantos desfechos, e quais** — precisa das 7 perguntas de narrativa | donos |
| ⏳ **Se os dois discordarem do desfecho, o que acontece?** | donos — **e é uma boa cena** |
| **Quantas portas abrem em NG+, e quais** | `→WP8` |
| **A brasa custa quanto, e onde se encontra** | `→WP9` |
| **Números exactos da curva cúbica ajustada ao tecto 100** | `→WP2`, valida-se no M2 |

## Ligações

[`39-estudo-profundo.md`](39-estudo-profundo.md) · [`40-decisoes-espolio-magia-inventario.md`](40-decisoes-espolio-magia-inventario.md) · [`53-chefes-ritmo-e-o-mago-forte.md`](53-chefes-ritmo-e-o-mago-forte.md) · [`11-formulas.md`](11-formulas.md) · [`18-progressao.md`](18-progressao.md) · [`26-narrativa.md`](26-narrativa.md) · [`99-perguntas-abertas.md`](99-perguntas-abertas.md)
