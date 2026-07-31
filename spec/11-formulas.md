# 11 — Atributos, fórmulas e dano

> **WP2.** A aritmética do jogo. O modelo é Dark Souls por decisão deles (sessão 1 · 06:33); os números e a resolução das sobreposições são `[FABLE]`, com razão e alternativa descartada. **É neste documento que a Lei 1 se ganha ou se perde** — por isso a última secção é um tecto matemático ao poder do nível.

## Os seis atributos

Na sessão 1 foram ditos quatro nomes: Vida, Sabedoria, Constituição, Stamina (06:33 · `[DECIDIDO]`). Dois problemas herdados: **Vida e Constituição sobrepõem-se**, e faltam os atributos que fazem a Lei 3 funcionar (requisitos e escala de armas precisam de Força/Destreza).

`[FABLE]` Resolução — seis atributos, cada um com um trabalho só:

| Atributo | O que faz, exactamente | Origem |
|---|---|---|
| **Vida** | Pontos de vida máximos | `[DECIDIDO]` 06:33 |
| **Stamina** | Stamina máxima | `[DECIDIDO]` 06:33 |
| **Constituição** | Defesa física, resistência a estados (veneno, queimadura, choque), e — quando existir armadura (pergunta 14) — capacidade de carga | `[DECIDIDO]` 06:33 · papel `[FABLE]` |
| **Força** | Requisito e escala das armas pesadas; empurra a balança do dano de postura | `[FABLE]` — acrescentado |
| **Destreza** | Requisito e escala das armas rápidas e do arco | `[FABLE]` — acrescentado |
| **Sabedoria** | Cargas de magia, requisito e escala das magias e do cajado | `[DECIDIDO]` 06:33 + 03:50 ("usos de magia" vivem aqui) |

*Porquê assim:* Constituição vira o atributo do "aguentar" (defesa/estados/carga) e Vida o do "quanto sangue tens" — deixa de haver dois nomes para a mesma coisa. Força/Destreza são o mínimo para requisitos de arma à Dark Souls, que é o sistema que eles escolheram para a Lei 3 (06:14). *Alternativa descartada:* fundir Vida+Constituição num só — deixava as armas sem eixo de requisito físico e a Lei 3 sem gramática.

**Usos de magia** (03:50) ficam como recurso derivado da Sabedoria — não são atributo à parte. A dúvida da gravação resolve-se assim, e a tabela de cargas está no WP4.

## Nível e pontos

| Parâmetro | Valor |
|---|---|
| Nível inicial | 1 (com os atributos da classe — WP3) |
| Nível máximo | **100** `[FABLE]` — adopta o "100" do Rico (06:33, `[SUGERIDO]` "100 ou 150"); 150 só espalha os mesmos ganhos por mais paragens |
| Pontos por nível | **1**, gasto num atributo à escolha |
| Onde se sobe | no ponto de descanso (fatia 1: a fogueira da entrada da Toca) |
| Reespecialização | fora da fatia 1; fica em "ideias para depois" (pergunta nova no 99) |

**Custo de subir** — a experiência chama-se **Essência** (nome provisório `[FABLE]`, o WP8B pode rebaptizar):

```
custo(n → n+1) = 60 + 25 × n^1,6        (arredondado às dezenas)
```

| Transição | Custo | Essência acumulada |
|---|---|---|
| 1 → 2 | 90 | 90 |
| 5 → 6 | 390 | ~1 300 |
| 9 → 10 | 850 | ~4 200 |

Calibração da fatia 1: limpar Brumal + a Toca uma vez rende ~2 600 de Essência (tabelas no WP6/WP9) → **nível 7–8 ao chegar a Vorgar, sem repetir nada**. Quem morre e re-limpa o caminho chega a 10. *Teste da Lei 1:* o nível 10 é alcançável sem grind; e o tecto da secção final garante que nem o 100 é porta. ✅

## O que cada ponto compra

Curvas com retornos decrescentes — os primeiros 40 pontos valem, os últimos são vaidade:

| Atributo | Base (com 10 pontos) | 10→40 | 40→70 | 70→99 |
|---|---|---|---|---|
| Vida | 100 PV | +6 PV/ponto | +3 | +1 |
| Stamina | 100 | +2/ponto | +1 | +0,5 |
| Constituição (defesa física) | 20 | +2/ponto | +1 | +0,5 |
| Constituição (resist. estados) | 100 | +3/ponto | +2 | +1 |
| Força / Destreza / Sabedoria | — | alimentam a escala das armas/magias (curva abaixo) | | |

(Toda a classe começa com 10 em tudo, mais o seu desvio — WP3. "Base" é o valor com 10.)

## A fórmula de dano

Uma fórmula só, para tudo — golpes, magias, inimigos a bater em jogadores:

```
ataque  = base_da_arma × (1 + Σ escala)
dano    = ataque × 100 / (100 + defesa_do_alvo)      por tipo de dano
```

- `base_da_arma` — tabela do WP5 (magias: WP4).
- `escala` — soma dos bónus de atributo da arma (abaixo).
- `defesa` — do alvo, por tipo de dano (Físico, Fogo, Raio, Luz, Sombra).
- Multiplicadores aplicam-se ao fim, por ordem: combo (+10%/+20%) → crítico (×2,5/×3,0) → co-op/estado.

**A curva de escala** — cada arma diz quanto escala com cada atributo (ex.: espada longa: For 60%, Des 40%). O valor do atributo passa por `f(x)`, linear entre os pontos:

| x (atributo) | 10 | 20 | 40 | 60 | 99 |
|---|---|---|---|---|---|
| `f(x)` | 0,00 | 0,20 | 0,55 | 0,75 | 0,90 |

```
Σ escala = escala_For × f(For) + escala_Des × f(Des) + escala_Sab × f(Sab)
```

**Exemplo resolvido** — Guerreiro nível 8 (For 16, Des 12), espada longa (base 40, For 60%, Des 40%), contra orc lanceiro (defesa física 25):

```
f(16) = 0,12   f(12) = 0,04            (interpolação linear de 10→20)
Σ escala = 0,60 × 0,12 + 0,40 × 0,04 = 0,088
ataque   = 40 × 1,088 = 43,5
dano     = 43,5 × 100 / 125 = 34,8  →  35
```

O mesmo golpe no 3.º hit do combo (+20%): 42. Em riposte (×3,0 sobre o leve): 104.

**Sem requisitos, sem bónus** — a Lei 3 na prática (regra fina no WP5): quem não cumpre o requisito usa a arma na mesma, com `Σ escala = 0` e **−5% de dano base por ponto em falta, chão a 40%**. Um mago (For 8) com o machadão (req. For 18): 10 pontos em falta → 50% de 55 = 27 por golpe lento. Dá para usar; não dá para ser o Berserker. Nenhuma proibição — só física.

## Tipos de dano, defesas e estados

**Cinco tipos:** Físico · Fogo · Raio · **Luz** · **Sombra** (os dois últimos são as escolas de magia do bem e do mal — WP4).

Cada criatura tem uma linha de defesas e uma linha de acumulação de estados. Os três estados da fatia 1 (framework aqui, efeitos por magia/inimigo no WP4/WP6):

| Estado | Acumula por | Ao encher (100 de acumulação) | Duração |
|---|---|---|---|
| **Veneno** | golpes venenosos | 8 de dano/s, ignora defesa | 12 s |
| **Queimadura** | Fogo | 25 de dano imediato + pânico em inimigos com medo do fogo (WP6) | — |
| **Choque** | Raio | dano de postura ×2 durante o efeito | 6 s |

A acumulação esvazia a 15/s depois de 2 s sem novo acúmulo. Resistência a estados (Constituição) sobe o tecto de 100 para até 200.

*Nota de coerência com "tem que ver a magia que tu usa nele" (05:04 · `[DECIDIDO]`):* as fraquezas dos inimigos expressam-se **nesta tabela de defesas** — um morto-vivo tem defesa Sombra 60 e defesa Luz −30 (dano amplificado). A regra de leitura: fraqueza tem de ser visível no corpo do inimigo (WP6/WP12 — um inimigo encharcado fumega ao apanhar Raio). ✅

## A curva dos inimigos — e o tecto que protege a Lei 1

Os dois números que matam souls-likes maus: vida de esponja e dano de um golpe. Regras duras, para o jogo inteiro:

1. **Tecto do poder do nível.** Entre um personagem nível 1 de arma inicial e o mesmo jogador no nível 100 com a mesma arma a +5, o dano por golpe **nunca excede ×2,5** (a curva `f` e o chão dos 40% garantem-no por construção). O nível compra margem, nunca a porta.
2. **Chão do dano.** Nenhum inimigo tem defesa que reduza o golpe de uma arma inicial nível 1 abaixo de **40% do seu valor de tabela** na zona a que pertence.
3. **Tecto do dano recebido.** Nenhum golpe de inimigo comum tira mais de **40% da vida base** (nível-1) da sua zona; chefes: **60%** no golpe mais forte, e só nos telegrafados longos (≥ 0,8 s). Morte em um golpe não existe.
4. **Orçamento de TTK (time-to-kill) dos chefes.** Vida do chefe = `dano_médio_nível_1 × golpes_alvo`, com `golpes_alvo` entre 35 e 50. Vorgar: 35 × 35 ≈ **1 250 PV** solo (WP7 fecha o valor final; ×1,8 a dois — provisório do WP0).

**Exemplo de verificação (o teste 3 do WP0, por antecipação):** jogador excelente, nível 1, espada longa base: dano 32/golpe em Vorgar (defesa 10 na sua zona) → 1 250 / 32 = **40 golpes**. A ~2,5 golpes seguros por padrão do chefe, são ~16 ciclos de padrão ≈ 3,5–4 min de luta limpa. Exigente, possível, nada de esponja. ✅

**Curva por zona** (esqueleto para WP6/WP7/WP8 preencherem — valores multiplicam os da fatia 1):

| Zona (ordem de desenho) | Vida dos inimigos | Dano | Nota |
|---|---|---|---|
| Brumal (fatia 1) | ×1,0 | ×1,0 | calibra tudo |
| Zonas seguintes | ×1,4 → ×2,2 | ×1,3 → ×1,8 | crescer devagar: a dificuldade nova vem de **padrões novos**, não de números (Lei 2 aplicada a inimigos) |
| Fim de jogo | ×3,0 tecto | ×2,2 tecto | com o tecto ×2,5 do jogador, o fim de jogo pesa como o início — margens, não paredes |

*Teste da Lei 1, geral:* com os quatro tecto/chãos, um nível 1 faz sempre ≥ 40% do dano de tabela e nunca morre num golpe — qualquer combate do jogo é vencível por leitura + esquiva/parry, por construção aritmética e não por promessa. ✅

## O que este documento não fecha

- Valores por arma (base, requisitos, escala) → WP5 · por magia → WP4 · por inimigo → WP6/WP7
- Atributos iniciais de cada classe → WP3
- Essência largada por inimigo e tabelas de loot → WP9
- Armadura e capacidade de carga → pergunta 14, deles; a Constituição já deixa o gancho

## Ligações

[`01-combate.md`](01-combate.md) · [`12-classes.md`](12-classes.md) · [`13-magia.md`](13-magia.md) · [`14-equipamento.md`](14-equipamento.md) · [`10-fatia-1.md`](10-fatia-1.md) · [`99-perguntas-abertas.md`](99-perguntas-abertas.md)
