# Manifesto de assets — fatia 1

Todos os assets visuais da fatia 1, cada um com o seu **ID** (é assim que a spec e o código o referem) e o seu **caminho canónico** (é aí que o ficheiro vive, com esse nome exacto).

> Gerado a partir do conteúdo do WP0 ([`../spec/10-fatia-1.md`](../spec/10-fatia-1.md)). Nomes de mundo (Brumal, Toca, Vorgar) são os provisórios do WP0 — se mudarem em WP6/7/8, os IDs mudam junto, num commit só.
>
> **Estilo:** frase única em [`prompts/00-estilo.md`](prompts/00-estilo.md), provisória até à pergunta 15. Prompts prontos a colar em [`prompts/`](prompts/).

## Conceitos de mundo — guiam a modelação, não entram no jogo

| ID | Asset | Caminho | Dim. | Prompt | Estado |
|---|---|---|---|---|---|
| `con_brumal_vista` | Brumal, vista geral da floresta com bruma | `art/concept/brumal-vista.png` | 1536×1024 | [01](prompts/01-concept-mundo.md) | ✅ |
| `con_brumal_caminho` | Caminho dentro de Brumal, escala humana | `art/concept/brumal-caminho.png` | 1536×1024 | [01](prompts/01-concept-mundo.md) | ✅ |
| `con_toca_entrada` | Entrada escondida da Toca (fenda + árvore morta) | `art/concept/toca-entrada.png` | 1536×1024 | [01](prompts/01-concept-mundo.md) | ✅ |
| `con_toca_interior` | Interior da Toca, sala típica | `art/concept/toca-interior.png` | 1536×1024 | [01](prompts/01-concept-mundo.md) | ✅ |
| `con_toca_arena` | Arena do Vorgar | `art/concept/toca-arena.png` | 1536×1024 | [01](prompts/01-concept-mundo.md) | ✅ |


## Conceitos de bioma — volta 1 (gerados 31-07, nano banana)

Um por bioma, a partir da coluna `descricao_visual` do [`../spec/49-biomas.md`](../spec/49-biomas.md). **Brumal já tinha** ([`con_brumal_vista`](concept/brumal-vista.png)).

| ID | Asset | Caminho | Dim. | Prompt | Estado |
|---|---|---|---|---|---|
| `con_bioma_selva_funda` | Selva Funda — selva vertical de copas fechadas, passadicos de vime goblin … | `art/concept/bioma-selva-funda.png` | 1536×1024 | volta 1 | ✅ |
| `con_bioma_campas_cinzentas` | Campas Cinzentas — pantano de arvores mortas e lapides tortas meio afundadas, a… | `art/concept/bioma-campas-cinzentas.png` | 1536×1024 | volta 1 | ✅ |
| `con_bioma_fojo` | Fojo — desfiladeiro ocre estreito com andaimes e roldanas kobold, b… | `art/concept/bioma-fojo.png` | 1536×1024 | volta 1 | ✅ |
| `con_bioma_costa_quebrada` | Costa Quebrada — falesias de basalto sob chuva fina, esqueletos de navios esp… | `art/concept/bioma-costa-quebrada.png` | 1536×1024 | volta 1 | ✅ |
| `con_bioma_cimeira` | Cimeira — encosta nevada acima das nuvens, ceu limpo azul-gelo, escada… | `art/concept/bioma-cimeira.png` | 1536×1024 | volta 1 | ✅ |
| `con_bioma_fornalha` | Fornalha — monte negro de obsidiana com rios de lava, fumo a subir de c… | `art/concept/bioma-fornalha.png` | 1536×1024 | volta 1 | ✅ |
| `con_bioma_fulgor` | Fulgor — planalto seco e rachado sob um tecto de nuvens violeta em ro… | `art/concept/bioma-fulgor.png` | 1536×1024 | volta 1 | ✅ |
| `con_bioma_raizama` | Raizama — caverna colossal de raizes entrancadas e cogumelos-torre, es… | `art/concept/bioma-raizama.png` | 1536×1024 | volta 1 | ✅ |
| `con_bioma_cidade_afogada` | Cidade Afogada — cidade de marmore mergulhada em agua verde-clara ate aos tel… | `art/concept/bioma-cidade-afogada.png` | 1536×1024 | volta 1 | ✅ |
| `con_bioma_santuario_branco` | Santuario Branco — templo de marmore branco de brilho excessivo, ouro baco, mil… | `art/concept/bioma-santuario-branco.png` | 1536×1024 | volta 1 | ✅ |
| `con_bioma_raiz` | A Raiz — abismo de pedra negra onde rios de bruma palida correm para … | `art/concept/bioma-raiz.png` | 1536×1024 | volta 1 | ✅ |

## Conceitos de personagens — as 6 classes da fatia

| ID | Asset | Caminho | Dim. | Prompt | Estado |
|---|---|---|---|---|---|
| `con_classe_guerreiro` | Guerreiro (espada + escudo) | `art/concept/classe-guerreiro.png` | 1024×1536 | [02](prompts/02-concept-classes.md) | ✅ |
| `con_classe_feiticeiro` | Feiticeiro (cajado) | `art/concept/classe-feiticeiro.png` | 1024×1536 | [02](prompts/02-concept-classes.md) | ✅ |
| `con_classe_tanque` | Tanque (escudo grande) | `art/concept/classe-tanque.png` | 1024×1536 | [02](prompts/02-concept-classes.md) | ✅ |
| `con_classe_assassino` | Assassino (adaga) | `art/concept/classe-assassino.png` | 1024×1536 | [02](prompts/02-concept-classes.md) | ✅ |
| `con_classe_berserker` | Berserker (machadão) | `art/concept/classe-berserker.png` | 1024×1536 | [02](prompts/02-concept-classes.md) | ✅ |
| `con_classe_paladino` | Paladino (espada + escudo + raio) | `art/concept/classe-paladino.png` | 1024×1536 | [02](prompts/02-concept-classes.md) | ✅ |

## Conceitos de inimigos

| ID | Asset | Caminho | Dim. | Prompt | Estado |
|---|---|---|---|---|---|
| `con_orc_lanceiro` | Orc lanceiro (rápido — ensina a esquiva) | `art/concept/orc-lanceiro.png` | 1024×1536 | [03](prompts/03-concept-inimigos.md) | ✅ |
| `con_orc_brutamontes` | Orc brutamontes (lento, telegrafado — ensina o parry) | `art/concept/orc-brutamontes.png` | 1024×1536 | [03](prompts/03-concept-inimigos.md) | ✅ |
| `con_vorgar` | Vorgar, o Guarda-Portão (chefe, 2 fases) | `art/concept/vorgar.png` | 1536×1024 | [03](prompts/03-concept-inimigos.md) | ✅ |

## Ícones — entram no jogo

| ID | Asset | Caminho | Dim. | Prompt | Estado |
|---|---|---|---|---|---|
| `ico_arma_espada_longa` | Espada longa | `art/ui/icons/items/espada-longa.png` | 512×512 | [04](prompts/04-icones-armas.md) | ✅ |
| `ico_arma_escudo_madeira` | Escudo de madeira | `art/ui/icons/items/escudo-madeira.png` | 512×512 | [04](prompts/04-icones-armas.md) | ✅ |
| `ico_arma_cajado` | Cajado | `art/ui/icons/items/cajado.png` | 512×512 | [04](prompts/04-icones-armas.md) | ✅ |
| `ico_arma_adaga` | Adaga | `art/ui/icons/items/adaga.png` | 512×512 | [04](prompts/04-icones-armas.md) | ✅ |
| `ico_arma_machadao` | Machadão | `art/ui/icons/items/machadao.png` | 512×512 | [04](prompts/04-icones-armas.md) | ✅ |
| `ico_item_pocao_vida` | Poção de vida | `art/ui/icons/items/pocao-vida.png` | 512×512 | [05](prompts/05-icones-magias.md) | ✅ |
| `ico_magia_dardo` | Dardo (projéctil directo) | `art/ui/icons/spells/dardo.png` | 512×512 | [05](prompts/05-icones-magias.md) | ✅ |
| `ico_magia_ruina` | Ruína (dano de área) | `art/ui/icons/spells/ruina.png` | 512×512 | [05](prompts/05-icones-magias.md) | ✅ |
| `ico_magia_egide` | Égide (protecção) | `art/ui/icons/spells/egide.png` | 512×512 | [05](prompts/05-icones-magias.md) | ✅ |

## Interface e céu

| ID | Asset | Caminho | Dim. | Prompt | Estado |
|---|---|---|---|---|---|
| `ui_menu_fundo` | Fundo do menu principal | `art/ui/menus/menu-fundo.png` | 1536×1024 | [06](prompts/06-ui-ceu.md) | ✅ |
| `sky_brumal` | Céu de Brumal (entardecer enevoado) | `art/sky/brumal-ceu.png` | 1536×1024 | [06](prompts/06-ui-ceu.md) | ✅ |

## Conceitos de bioma — volta 1 ([`../spec/49-biomas.md`](../spec/49-biomas.md))

> A `descrição visual` de cada um está na ficha (spec/49 §3) e em `game/data/biomes.json`. Brumal já tem cenário (`con_brumal_vista`) — estes são os 11 que faltam. **Nenhum é da fatia 1**: geram-se quando o orçamento de créditos deixar, por ordem de zona.

| ID | Asset | Caminho | Dim. | Prompt | Estado |
|---|---|---|---|---|---|
| `con_bioma_selva_funda` | Selva Funda (selva vertical, passadiços goblin) | `art/concept/bioma-selva-funda.png` | 1536×1024 | ficha §3.2 | ⬜ |
| `con_bioma_campas` | Campas Cinzentas (pântano dos mortos) | `art/concept/bioma-campas.png` | 1536×1024 | ficha §3.3 | ⬜ |
| `con_bioma_fojo` | Fojo (desfiladeiros e minas kobold) | `art/concept/bioma-fojo.png` | 1536×1024 | ficha §3.4 | ⬜ |
| `con_bioma_costa` | Costa Quebrada (falésias dos naufrágios) | `art/concept/bioma-costa.png` | 1536×1024 | ficha §3.5 | ⬜ |
| `con_bioma_cimeira` | Cimeira (a montanha limpa, sem bruma) | `art/concept/bioma-cimeira.png` | 1536×1024 | ficha §3.6 | ⬜ |
| `con_bioma_fornalha` | Fornalha (o monte-forja) | `art/concept/bioma-fornalha.png` | 1536×1024 | ficha §3.7 | ⬜ |
| `con_bioma_fulgor` | Fulgor (planalto da tempestade presa) | `art/concept/bioma-fulgor.png` | 1536×1024 | ficha §3.8 | ⬜ |
| `con_bioma_raizama` | Raizama (caverna do grande morto) | `art/concept/bioma-raizama.png` | 1536×1024 | ficha §3.9 | ⬜ |
| `con_bioma_cidade_afogada` | Cidade Afogada (ruínas na água parada) | `art/concept/bioma-cidade-afogada.png` | 1536×1024 | ficha §3.10 | ⬜ |
| `con_bioma_santuario` | Santuário Branco (o templo que rezou de mais) | `art/concept/bioma-santuario.png` | 1536×1024 | ficha §3.11 | ⬜ |
| `con_bioma_raiz` | A Raiz (o abismo de onde a bruma sai) | `art/concept/bioma-raiz.png` | 1536×1024 | ficha §3.12 | ⬜ |

**Total: 32 assets gerados + 11 conceitos de bioma por gerar.** Estados: ⬜ por gerar · 🔄 gerado, por avaliar · ✅ arquivado no caminho.

> **Nota de contagem:** este manifesto dizia "22" na primeira versão. São 25 — a soma estava errada, não a lista.
>
> **Modelo:** `nano_banana_pro` (Nano Banana Pro — o modelo de imagem do Gemini) via Higgsfield CLI, 2 créditos cada. **Todas as 25 saíram do mesmo gerador**, que é o que mantém a consistência de pé. Os 5 cenários foram primeiro feitos com gpt-image pelo browser e depois regenerados aqui, por decisão do Mateus — não misturar.
>
> **Ícones:** gerados com fundo cinzento chapado e depois passados pelo removedor de fundo do Higgsfield (1 crédito cada) — ficam RGBA com transparência real, que é o que a hotbar precisa.


## Bestiário — as 7 raças do WP6 (fatia 2+)

> Geradas a 31-07 depois do bestiário entrar ([`../spec/15-inimigos.md`](../spec/15-inimigos.md)). Nenhuma entra na fatia 1 — a fatia continua com os 2 orcs + Vorgar.

| ID | Asset | Caminho | Dim. | Estado |
|---|---|---|---|---|
| `con_raca_goblin` | Goblin — o cerco | `art/concept/raca-goblin.png` | 1024×1536 | ✅ |
| `con_raca_kobold` | Kobold — o terreno e as armadilhas | `art/concept/raca-kobold.png` | 1024×1536 | ✅ |
| `con_raca_esqueleto` | Esqueleto — seco e quebradiço | `art/concept/raca-esqueleto.png` | 1024×1536 | ✅ |
| `con_raca_zumbi` | Zumbi — lento e resistente a corte | `art/concept/raca-zumbi.png` | 1024×1536 | ✅ |
| `con_raca_minotauro` | Minotauro — subchefe de labirinto | `art/concept/raca-minotauro.png` | 1024×1536 | ✅ |
| `con_raca_mimico` | Mímico — o castigo da ganância | `art/concept/raca-mimico.png` | 1024×1536 | ✅ |
| `con_ceifador` | O Ceifador — subchefe (ideia do Rico) | `art/concept/ceifador.png` | 1536×1024 | ✅ |

## O que este manifesto NÃO cobre — e é de propósito

Malhas 3D, esqueletos, animações e colisões **não saem de geradores de imagem** (ver [`../spec/09-tecnico.md`](../spec/09-tecnico.md)). A origem desses fica no `spec/22-assets.md` (parte restante do WP13). As barras de HUD (vida/stamina/cargas) desenham-se na engine, não se geram — entram como spec no WP11.
