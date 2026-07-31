# 47 — Do greybox ao visual: o passo que ninguém tinha planeado

`[DECIDIDO]` (Mateus, 31-07-2026) — *"vê se não está estilo jogo de PS1, tem que ser estilo Dark Souls."*

---

## 1. O que está lá hoje — visto, não suposto

Corri o modo fotografia do protótipo (`--photos`) e olhei para as seis capturas.

**O que se vê:** cones verdes por árvores, cilindros castanhos por troncos, **cápsulas coloridas por personagens**, caixas cinzentas por rochas, chão de uma cor só. Neblina cinzenta. Sombras direccionais a funcionar. 60 fps cravados, 106 MB de VRAM, 83–100 draw calls.

### A resposta honesta à pergunta

**Não é "estilo PS1". É "sem estilo nenhum" — é greybox, e greybox é suposto ser assim.**

A diferença importa:

| | |
|---|---|
| **Estilo PS1** | uma escolha estética — poucos polígonos **de propósito**, texturas de 64px, cores berrantes |
| ⚠️ **O que temos** | **placeholder** — formas primitivas que dizem *"aqui vai estar uma árvore"*. Ninguém escolheu nada |

E a própria paleta do protótipo declara-o, no `game/data/graphics.json`:

> *"Cores por ESTADO, não por beleza. Legibilidade acima de tudo."*

**Está correcto para um protótipo de combate** — o amarelo é telegrafia, o vermelho é ataque, o branco é cambaleio. São cores que ensinam, não que decoram.

---

## 2. ⚠️ Mas o Mateus tem razão, e o risco é real

**O problema não é o greybox. É que não há nada no plano que o converta.**

A barra está fixada há muito ([`30-qualidade-visual.md`](30-qualidade-visual.md)): **Dark Souls 2 é o chão**, 8–15 mil triângulos por personagem, texturas 1024–2048. E o [`21-arte-render.md`](21-arte-render.md) (WP12) tem direcção de arte proposta.

⚠️ **O que não existe é a ponte entre as duas coisas.** Nenhum marco do [`24-plano.md`](24-plano.md) diz *"aqui o jogo deixa de ser cinzento"*. E é assim que um protótipo se torna o jogo: **ninguém decide manter o greybox — simplesmente nunca chega o dia de o substituir.**

⭐ **É o mesmo modo de falha das quatro perguntas do fio solto** ([`ESTADO.md`](../ESTADO.md) §5): a ideia está escrita, o alvo está escrito, e **falta a ponta que os liga**.

---

## 3. ⭐ O que faz um jogo parecer-se com a referência — e não é o número de polígonos

Esta é a parte que interessa, e é boa notícia para a Lei 4.

**A referência corre em hardware de 2011.** Os modelos dela cabem no nosso orçamento — está medido no [`31-referencias.md`](31-referencias.md). **O que faz aquilo parecer aquilo não é geometria.** É, por ordem de impacto:

| # | O que | Custo em fotogramas | Impacto |
|---|---|---|---|
| **1** | ⭐ **Contraste de luz** — uma direccional forte e um ambiente **escuro** | ~zero | **enorme** |
| **2** | ⭐ **Névoa com cor, e cor por bioma** — não cinzento neutro | ~zero | **enorme** |
| **3** | ⭐ **Gradação de cor no fim** (contraste, dessaturação, vinheta) | muito baixo | **enorme** |
| **4** | **Materiais com rugosidade** em vez de cor plana | baixo | alto |
| **5** | **Silhueta legível** — o inimigo lê-se contra o fundo | zero (é desenho) | alto |
| **6** | Modelos com detalhe | alto | **médio** |
| **7** | Texturas grandes | alto (VRAM) | médio |

### ⭐ A leitura que isto obriga

**Os três primeiros custam quase nada e valem mais do que os dois últimos.**

Um cone verde debaixo de luz dura, com névoa azul-esverdeada e gradação de contraste, **já não parece PS1** — parece uma floresta estilizada. O mesmo cone com luz plana e névoa cinzenta parece um teste de motor.

⚠️ **E é por isso que "trocar os modelos" é a resposta errada para começar.** Trocar 40 modelos custa dias e dá um salto médio; afinar luz, névoa e gradação custa horas e dá o salto maior. **Faz-se primeiro o que é barato e visível.**

---

## 4. A ordem da conversão

`[CLAUDE]` `→WP12`. **Cada passo é jogável no fim — nunca há um estado "meio convertido e feio".**

| Passo | O que | Custo | Onde |
|---|---|---|---|
| **1** | ⭐ **Luz e névoa por bioma** — a ficha do [`46`](46-coerencia-bioma-raca-item.md) §2 já manda cada bioma declarar 3 cores. **Ligar essas cores à luz e à névoa** | horas | `graphics.json` |
| **2** | ⭐ **Gradação de cor** — contraste, dessaturação, vinheta ligeira | horas | ambiente |
| **3** | **Materiais com rugosidade e variação** em vez de albedo plano | horas | materiais |
| **4** | **Silhuetas** — o [`38`](38-ataques-e-honestidade.md) §6 já dá os papéis; cada papel tem de se ler a 30 m | dias | WP12 |
| **5** | **Modelos dos packs** ([`22-assets.md`](22-assets.md)) a substituir as cápsulas | dias | WP13 |
| **6** | ⚠️ **Animação de esqueleto** — **a incógnita cara, e ainda por medir** | dias | M1 |

⚠️ **O passo 6 continua a ser o único risco técnico real** e está assinalado desde o [`44-prototipo.md`](44-prototipo.md): *"cápsulas não são personagens animados"*. A folga de ~6× que a medição deu é **orçamento para isto**, não garantia.

---

## 5. ⚠️ O critério que impede isto de ser esquecido outra vez

**O problema deste documento não é saber o que fazer — é lembrar-se de o fazer.** Por isso:

> ⭐ **Nenhum marco do [`24-plano.md`](24-plano.md) fecha sem uma captura.**
>
> O modo fotografia já existe (`--photos`). Cada marco entrega **as suas seis capturas no PR**, e a pergunta é uma só: *isto está mais perto da barra do [`30-qualidade-visual.md`](30-qualidade-visual.md) do que estava no marco anterior?*

Se a resposta for não duas vezes seguidas, **o visual parou** — e alguém tem de dizer isso em voz alta, em vez de se descobrir daqui a três meses.

⭐ **É barato porque a ferramenta já está construída.** O Fable fez o modo fotografia para o ciclo de melhoria dele; **passa a ser a prova de que o jogo está a ficar melhor à vista**, e não só mais rápido.

---

## 6. O que fica decidido

| | |
|---|---|
| **O greybox actual está certo** para o que é — não se muda nada por pânico |
| ⚠️ **Mas a conversão é trabalho planeado**, com passos, e não "um dia trocamos os modelos" |
| ⭐ **Começa-se pelo barato e visível** — luz, névoa e gradação antes de modelos |
| ⭐ **A cor vem da ficha de bioma** ([`46`](46-coerencia-bioma-raca-item.md) §2) — os três valores de paleta deixam de ser decoração e passam a ser configuração |
| ⭐ **Capturas em todo o marco**, ou o visual perde-se sem ninguém dar por isso |
| **A barra continua a ser a do [`30-qualidade-visual.md`](30-qualidade-visual.md)** — não muda |

## Ligações

[`30-qualidade-visual.md`](30-qualidade-visual.md) · [`21-arte-render.md`](21-arte-render.md) · [`22-assets.md`](22-assets.md) · [`46-coerencia-bioma-raca-item.md`](46-coerencia-bioma-raca-item.md) · [`44-prototipo.md`](44-prototipo.md) · [`24-plano.md`](24-plano.md) · [`31-referencias.md`](31-referencias.md)
