# art/PIPELINE.md — como as imagens são feitas

`[DECIDIDO]` (Mateus, 31-07-2026) — **as imagens geram-se, não se desenham à mão.** Modelo: **nano banana** (Gemini), o mesmo das 32 que já existem.

> **Porque existe:** o Mateus foi claro — *"não quero esses gráficos quadrados"*. As imagens são o que tira o jogo do greybox ([`../spec/47-do-greybox-ao-visual.md`](../spec/47-do-greybox-ao-visual.md)). Este documento diz **o que é preciso para as fazer** e **quem faz o quê**.

---

## 1. Quem faz o quê

| Quem | O quê |
|---|---|
| **Fable** | escreve o catálogo com a coluna **`descrição visual`** e a coluna **`Fatia 1?`** |
| **Claude** | gera as imagens a partir dessas colunas, arquiva em `art/`, e regista no [`MANIFESTO.md`](MANIFESTO.md) |
| **Mateus e Rico** | vêem e dizem se serve |

⭐ **O Fable nunca gera imagens.** Escreve as descrições; o Claude gera. É assim porque a consistência visual depende de **um só modelo e um só estilo** — misturar geradores parte o alinhamento, e já foi decidido.

---

## 2. ⭐ O que uma `descrição visual` tem de dizer

**Uma frase. Mas específica.**

| | |
|---|---|
| ❌ *"Katana"* | não gera nada — o modelo inventa |
| ✅ *"Lâmina curva estreita, aço polido, punho enfaixado a tecido escuro, 90 cm"* | gera |

### Por tipo

| O que | Tem de dizer |
|---|---|
| **Arma** | silhueta · material · comprimento · o que a distingue **dentro da família** |
| **Armadura** | peça · material · silhueta · **estado** (nova / gasta / partida) |
| **Feitiço** | cor · forma · elemento · **o que se vê quando acerta** |
| **Anel** | metal · pedra · motivo gravado |
| **Consumível** | forma do frasco ou da pedra · cor do conteúdo |
| **Inimigo** | altura · silhueta · o que veste · **como se lê a 30 m** |

⚠️ **E a linha que liga tudo ao [`46`](../spec/46-coerencia-bioma-raca-item.md):** a descrição visual **tem de usar o material do bioma** de onde o item vem. Um machado orc do bioma de fogo é de **obsidiana**, não de aço — e isso escreve-se na descrição visual, não se deixa ao acaso do gerador.

---

## 3. O orçamento, e é real

| | |
|---|---|
| Plano | starter · **143,75 créditos** (31-07) |
| `nano_banana_pro` (uma imagem) | **2 créditos** |
| `image_background_remover` (ícones) | **1 crédito** |
| **Dá para** | ~**70 imagens**, ou ~47 com fundo removido |
| Trabalhos em paralelo | **4 no máximo** |

⚠️ **70 imagens não chegam para 120 armas + 30 armaduras + 70 anéis.** Por isso:

> ⭐ **A coluna `Fatia 1?` é o que decide o que se gera.** Sem ela, ou gero 300 imagens (impossível) ou nenhuma.

**A ordem de geração** — o que rende mais primeiro:

| Prioridade | O quê | Porquê |
|---|---|---|
| **1** | as **8 famílias** de arma, uma imagem cada | é a família que dá identidade; as variantes herdam |
| **2** | os **9 tipos** de peça de armadura | idem |
| **3** | ícones dos feitiços da **fatia 1** | vão para a barra — vêem-se sempre |
| **4** | retratos dos **inimigos novos** | ajudam o WP12 a modelar |
| **5** | os itens marcados `Fatia 1?` ✅ | o resto espera |

---

## 4. As regras técnicas

| | |
|---|---|
| **Modelo** | `nano_banana_pro` — **não misturar**. As 32 existentes são todas dele |
| **Ícones** | passam pelo `image_background_remover` → **RGBA com fundo transparente**, verificado no ficheiro **e** no git |
| **Consistência** | importa onde os assets **partilham o mesmo ecrã** (ícones lado a lado na barra). Um retrato de conceito e um ícone não precisam de ser do mesmo lote |
| **Estilo** | a frase de estilo vive no [`MANIFESTO.md`](MANIFESTO.md) e é **a mesma em todos os prompts** |
| **Arquivo** | `art/ui/icons/` (itens) · `art/concept/` (conceito) · e a linha no [`MANIFESTO.md`](MANIFESTO.md) |
| ⚠️ **Nunca** | imagens extraídas de jogos comerciais ([`../spec/31-referencias.md`](../spec/31-referencias.md)) |

---

## 5. O que já existe

**32 imagens:** cenários de Brumal, as 6 classes, as 7 raças, o Ceifador, e ícones de interface.

⚠️ **Zero ícones de arma, armadura, feitiço, anel ou consumível** — porque o catálogo ainda não diz quais são. **É por isso que o catálogo vem antes das imagens**, e não ao contrário.

## Ligações

[`MANIFESTO.md`](MANIFESTO.md) · [`../spec/47-do-greybox-ao-visual.md`](../spec/47-do-greybox-ao-visual.md) · [`../spec/46-coerencia-bioma-raca-item.md`](../spec/46-coerencia-bioma-raca-item.md) · [`../spec/22-assets.md`](../spec/22-assets.md) · [`../spec/30-qualidade-visual.md`](../spec/30-qualidade-visual.md)
