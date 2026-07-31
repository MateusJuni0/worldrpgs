 ✅ | ✅ | ✅ | ✅ |# Manifesto de assets — fatia 1

Todos os assets visuais da fatia 1, cada um com o seu **ID** (é assim que a spec e o código o referem) e o seu **caminho canónico** (é aí que o ficheiro vive, com esse nome exacto).

> Gerado a partir do conteúdo do WP0 ([`../spec/10-fatia-1.md`](../spec/10-fatia-1.md)). Nomes de mundo (Brumal, Toca, Vorgar) são os provisórios do WP0 — se mudarem em WP6/7/8, os IDs mudam junto, num commit só.
>
> **Estilo:** frase única em [`prompts/00-estilo.md`](prompts/00-estilo.md), provisória até à pergunta 15. Prompts prontos a colar em [`prompts/`](prompts/).

## Conceitos de mundo — guiam a modelação, não entram no jogo

| ID | Asset | Caminho | Dim. | Prompt | Estado |
|---|---|---|---|---|---|
| `con_brumal_vista` | Brumal, vista geral da floresta com bruma | `art/concept/brumal-vista.png` | 1536×1024 | [01](prompts/01-concept-mundo.md) | ⬜ |
| `con_brumal_caminho` | Caminho dentro de Brumal, escala humana | `art/concept/brumal-caminho.png` | 1536×1024 | [01](prompts/01-concept-mundo.md) | ⬜ |
| `con_toca_entrada` | Entrada escondida da Toca (fenda + árvore morta) | `art/concept/toca-entrada.png` | 1536×1024 | [01](prompts/01-concept-mundo.md) | ⬜ |
| `con_toca_interior` | Interior da Toca, sala típica | `art/concept/toca-interior.png` | 1536×1024 | [01](prompts/01-concept-mundo.md) | ⬜ |
| `con_toca_arena` | Arena do Vorgar | `art/concept/toca-arena.png` | 1536×1024 | [01](prompts/01-concept-mundo.md) | ⬜ |

## Conceitos de personagens — as 6 classes da fatia

| ID | Asset | Caminho | Dim. | Prompt | Estado |
|---|---|---|---|---|---|
| `con_classe_guerreiro` | Guerreiro (espada + escudo) | `art/concept/classe-guerreiro.png` | 1024×1536 | [02](prompts/02-concept-classes.md) | ⬜ |
| `con_classe_feiticeiro` | Feiticeiro (cajado) | `art/concept/classe-feiticeiro.png` | 1024×1536 | [02](prompts/02-concept-classes.md) | ⬜ |
| `con_classe_tanque` | Tanque (escudo grande) | `art/concept/classe-tanque.png` | 1024×1536 | [02](prompts/02-concept-classes.md) | ⬜ |
| `con_classe_assassino` | Assassino (adaga) | `art/concept/classe-assassino.png` | 1024×1536 | [02](prompts/02-concept-classes.md) | ⬜ |
| `con_classe_berserker` | Berserker (machadão) | `art/concept/classe-berserker.png` | 1024×1536 | [02](prompts/02-concept-classes.md) | ⬜ |
| `con_classe_paladino` | Paladino (espada + escudo + raio) | `art/concept/classe-paladino.png` | 1024×1536 | [02](prompts/02-concept-classes.md) | ⬜ |

## Conceitos de inimigos

| ID | Asset | Caminho | Dim. | Prompt | Estado |
|---|---|---|---|---|---|
| `con_orc_lanceiro` | Orc lanceiro (rápido — ensina a esquiva) | `art/concept/orc-lanceiro.png` | 1024×1536 | [03](prompts/03-concept-inimigos.md) | ⬜ |
| `con_orc_brutamontes` | Orc brutamontes (lento, telegrafado — ensina o parry) | `art/concept/orc-brutamontes.png` | 1024×1536 | [03](prompts/03-concept-inimigos.md) | ⬜ |
| `con_vorgar` | Vorgar, o Guarda-Portão (chefe, 2 fases) | `art/concept/vorgar.png` | 1536×1024 | [03](prompts/03-concept-inimigos.md) | ⬜ |

## Ícones — entram no jogo

| ID | Asset | Caminho | Dim. | Prompt | Estado |
|---|---|---|---|---|---|
| `ico_arma_espada_longa` | Espada longa | `art/ui/icons/items/espada-longa.png` | 512×512 | [04](prompts/04-icones-armas.md) | ⬜ |
| `ico_arma_escudo_madeira` | Escudo de madeira | `art/ui/icons/items/escudo-madeira.png` | 512×512 | [04](prompts/04-icones-armas.md) | ⬜ |
| `ico_arma_cajado` | Cajado | `art/ui/icons/items/cajado.png` | 512×512 | [04](prompts/04-icones-armas.md) | ⬜ |
| `ico_arma_adaga` | Adaga | `art/ui/icons/items/adaga.png` | 512×512 | [04](prompts/04-icones-armas.md) | ⬜ |
| `ico_arma_machadao` | Machadão | `art/ui/icons/items/machadao.png` | 512×512 | [04](prompts/04-icones-armas.md) | ⬜ |
| `ico_item_pocao_vida` | Poção de vida | `art/ui/icons/items/pocao-vida.png` | 512×512 | [05](prompts/05-icones-magias.md) | ⬜ |
| `ico_magia_dardo` | Dardo (projéctil directo) | `art/ui/icons/spells/dardo.png` | 512×512 | [05](prompts/05-icones-magias.md) | ⬜ |
| `ico_magia_ruina` | Ruína (dano de área) | `art/ui/icons/spells/ruina.png` | 512×512 | [05](prompts/05-icones-magias.md) | ⬜ |
| `ico_magia_egide` | Égide (protecção) | `art/ui/icons/spells/egide.png` | 512×512 | [05](prompts/05-icones-magias.md) | ⬜ |

## Interface e céu

| ID | Asset | Caminho | Dim. | Prompt | Estado |
|---|---|---|---|---|---|
| `ui_menu_fundo` | Fundo do menu principal | `art/ui/menus/menu-fundo.png` | 1536×1024 | [06](prompts/06-ui-ceu.md) | ⬜ |
| `sky_brumal` | Céu de Brumal (entardecer enevoado) | `art/sky/brumal-ceu.png` | 1536×1024 | [06](prompts/06-ui-ceu.md) | ⬜ |

**Total: 22 assets.** Estados: ⬜ por gerar · 🔄 gerado, por avaliar · ✅ arquivado no caminho.

## O que este manifesto NÃO cobre — e é de propósito

Malhas 3D, esqueletos, animações e colisões **não saem de geradores de imagem** (ver [`../spec/09-tecnico.md`](../spec/09-tecnico.md)). A origem desses fica no `spec/22-assets.md` (parte restante do WP13). As barras de HUD (vida/stamina/cargas) desenham-se na engine, não se geram — entram como spec no WP11.
