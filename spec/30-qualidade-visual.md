# 30 — A barra de qualidade visual

`[DECIDIDO]` (Mateus, 31-07-2026) — **"não é um RPG de PlayStation 1."**

Este documento existe porque a spec usava a expressão "baixo poligonal" em cinco sítios, e essa expressão é ambígua ao ponto de mandar quem constrói para o sítio errado.

## O mal-entendido, desfeito

**"Baixo poligonal" nunca quis dizer PlayStation 1.** A PS1 é hardware de 1994: personagens de 300–500 polígonos, texturas de 64×64, sem filtragem, vértices a tremer. Ninguém propôs isso e ninguém quer isso.

O que a Lei 4 obriga é outra coisa: **orçamento consciente**, não pobreza visual. A diferença entre as duas está em jogos que qualquer pessoa reconhece:

| | Polígonos por personagem | Corre em gráficos integrados? |
|---|---|---|
| PlayStation 1 (1994) | 300–500 | — |
| **A nossa faixa** | **8.000–15.000** | **sim** |
| AAA moderno | 50.000–150.000+ | não |

Valheim, Hollow Knight, Tunic, Hades — nenhum é PS1, todos correm em máquinas modestas, e todos parecem cuidados. É essa a faixa. **A qualidade não vem da contagem de polígonos; vem de silhueta, iluminação, animação e coerência.**

## O que faz um jogo parecer bom com pouco

Por ordem de impacto real, e é aqui que o esforço deve ir:

1. **Animação.** É o que separa "barato" de "cuidado", e é quase de graça em desempenho. Um personagem de 8.000 polígonos bem animado parece melhor do que um de 80.000 rígido.
2. **Iluminação assada com intenção.** Sombras cozidas de antemão custam zero em tempo real e dão profundidade. É como se ganha atmosfera sem GPU.
3. **Silhueta legível.** Reconhecer o que é uma coisa a 50 metros vale mais do que detalhe que ninguém vê.
4. **Coerência.** Vinte assets do mesmo sítio parecem um jogo; vinte de sítios diferentes parecem uma pasta. É a razão de existir a frase de estilo única ([`../art/prompts/00-estilo.md`](../art/prompts/00-estilo.md)).
5. **Efeitos de impacto** (`→WP1B`): paragem de impacto, tremor, faísca de parry. Custam quase nada e são metade da sensação de qualidade.

## Orçamento revisto `[CLAUDE]`

Substitui o que estava em [`09-tecnico.md`](09-tecnico.md) e [`22-assets.md`](22-assets.md). Continua a caber nos 8 GB e no Iris Xe da máquina do Rico — é orçamento apertado, não é pobre:

| | Alvo |
|---|---|
| Jogador e classes | 10.000–15.000 tri |
| Inimigo comum | 6.000–10.000 tri |
| Chefe | 20.000–30.000 tri |
| Adereços de cenário | 200–2.000 tri |
| Texturas de personagem | 2048² (albedo + normal + ORM) |
| Texturas de cenário | 1024², com atlas partilhado |
| Ecrã | 1080p · **60 fps estáveis, medidos quentes** |

**A regra que não muda:** o tecto é o desempenho na máquina do Rico, não o gosto. Uma técnica que parece bem e derruba os 60 fps não entra — porque queda de fotogramas num souls-like não é feio, é **injusto** (Lei 4).

## Onde a linguagem antiga foi corrigida

As expressões "baixo poligonal" e "baixa contagem de polígonos" passam a ler-se **"orçamento consciente"** em [`09-tecnico.md`](09-tecnico.md), [`00-visao.md`](00-visao.md) e [`22-assets.md`](22-assets.md). A frase de estilo das imagens mantém `simple readable shapes` — que é sobre **legibilidade**, não sobre pobreza, e as 25 imagens já geradas provam que não puxa para PS1.

## Ligações

[`09-tecnico.md`](09-tecnico.md) · [`29-perspectiva.md`](29-perspectiva.md) · [`../art/MANIFESTO.md`](../art/MANIFESTO.md) · Lei 4 em [`../CLAUDE.md`](../CLAUDE.md)
