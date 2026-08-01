# Conceitos — o alvo visual do WorldRPGs

**Aprovado pelo Mateus, 01-08-2026:** *"isso mesmo, o tom tá certo, esse estilo"*.

## ⭐ Para que serve, e como se usa

Estas imagens são **o alvo, não o asset**. Dizem a quem modela — pessoa ou agente —
que **materiais**, que **silhueta** e que **grau de desgaste** perseguir.

⚠️ **Nada disto entra no jogo.** O jogo corre numa Intel Iris Xe e precisa de
geometria *low-poly* com poucos materiais. A distância entre estas imagens e o que
está no ecrã **é o trabalho que falta** — não confundir ter o conceito com ter a coisa.

### Como um agente deve usá-las

1. **Antes de escolher um modelo de um pack**, abrir o conceito da mesma coisa
2. Perguntar: *este modelo pode chegar aqui só com materiais, cor e escala?*
3. Se **não** puder — ⚠️ **não usar o menos mau**. Escrever no [`LACUNAS.md`](../../LACUNAS.md)
   exactamente que peça falta, e porquê aquela não serve
4. O que **nunca** se aceita: caras a sorrir, olhos grandes e redondos, cores
   saturadas, proporções de desenho animado

## A base de estilo

As imagens partilham uma base de texto comum — paleta fria e dessaturada, ferro
molhado, couro húmido, nevoeiro pesado, luz lateral de céu encoberto, desgaste
visível no material. ⚠️ **É essa base que as faz parecer do mesmo jogo.** Mudá-la
obriga a regenerar tudo.

Guião de geração em [`../PIPELINE.md`](../PIPELINE.md). Modelo: `nano_banana_pro`, 2k, 2 créditos.

## A linha que não se atravessa

O Dark Souls é **referência de tom, nunca de conteúdo** ([`spec/31-referencias.md`](../../spec/31-referencias.md)).
Nenhum pedido nomeia armaduras, criaturas, personagens ou lugares deles. Pede-se a
**atmosfera** — sombria, gasta, crível — aplicada ao nosso mundo.

## O que existe

| Pasta | O que lá está |
|---|---|
| `armaduras/` | as seis origens vestidas — o kit inicial de cada uma |
| `inimigos/` | ⭐ o alvo que os orcs actuais **não** cumprem |
| `chefes/` | Vorgar e a arena dele |
| `classes/` | o Mago do Mal, a 7.ª origem |
| `ambiente/` | Brumal, a fogueira, a entrada da Toca |
| `armas/` | as famílias, em folhas de catálogo |
