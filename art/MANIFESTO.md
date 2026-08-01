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

✅ **Auditoria WP8 (01-08):** o [`69`](../spec/69-catalogo-do-mundo.md) reutiliza estes 12 conceitos. Os elementos da Fatia 1 apontam ainda para `brumal-caminho` e `toca-entrada`; por isso o novo traçado não abre nenhuma imagem prioritária em falta.

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
| `ico_arma_espada_longa` | Espada longa | `art/ui/icons/items/espada-longa.png` | 2048×2048 | [04](prompts/04-icones-armas.md) | ✅ |
| `ico_arma_escudo_madeira` | Escudo de madeira | `art/ui/icons/items/escudo-madeira.png` | 2048×2048 | [04](prompts/04-icones-armas.md) | ✅ |
| `ico_arma_cajado` | Cajado | `art/ui/icons/items/cajado.png` | 2048×2048 | [04](prompts/04-icones-armas.md) | ✅ |
| `ico_arma_adaga` | Adaga | `art/ui/icons/items/adaga.png` | 2048×2048 | [04](prompts/04-icones-armas.md) | ✅ |
| `ico_arma_machadao` | Machadão | `art/ui/icons/items/machadao.png` | 2048×2048 | [04](prompts/04-icones-armas.md) | ✅ |
| `ico_item_pocao_vida` | Poção de vida | `art/ui/icons/items/pocao-vida.png` | 2048×2048 | [05](prompts/05-icones-magias.md) | ✅ |
| `ico_magia_dardo` | Dardo (projéctil directo) | `art/ui/icons/spells/dardo.png` | 2048×2048 | [05](prompts/05-icones-magias.md) | ✅ |
| `ico_magia_ruina` | Ruína (dano de área) | `art/ui/icons/spells/ruina.png` | 2048×2048 | [05](prompts/05-icones-magias.md) | ✅ |
| `ico_magia_egide` | Égide (protecção) | `art/ui/icons/spells/egide.png` | 2048×2048 | [05](prompts/05-icones-magias.md) | ✅ |

## Interface e céu

| ID | Asset | Caminho | Dim. | Prompt | Estado |
|---|---|---|---|---|---|
| `ui_menu_fundo` | Fundo do menu principal | `art/ui/menus/menu-fundo.png` | 1536×1024 | [06](prompts/06-ui-ceu.md) | ✅ |
| `sky_brumal` | Céu de Brumal (entardecer enevoado) | `art/sky/brumal-ceu.png` | 1536×1024 | [06](prompts/06-ui-ceu.md) | ✅ |

## Conceitos das raças novas — volta 2 ([`../spec/50-racas.md`](../spec/50-racas.md))

> As 6 raças `[FABLE]` da volta 2. A `descrição visual` está na ficha (spec/50) e em `game/data/races.json`. As 7 raças aprovadas já têm retrato. **Nenhuma é da fatia 1.**

| ID | Asset | Caminho | Dim. | Prompt | Estado |
|---|---|---|---|---|---|
| `con_raca_tecelao` | Tecelão (aranha-povo da Raizama) | `art/concept/raca-tecelao.png` | 1024×1536 | ficha §7 | ⬜ |
| `con_raca_ventaneira` | Ventaneira (vigia alada da Cimeira) | `art/concept/raca-ventaneira.png` | 1024×1536 | ficha §8 | ⬜ |
| `con_raca_borralheiro` | Borralheiro (povo da forja) | `art/concept/raca-borralheiro.png` | 1024×1536 | ficha §9 | ⬜ |
| `con_raca_submerso` | Submerso (afogado da Cidade) | `art/concept/raca-submerso.png` | 1024×1536 | ficha §10 | ⬜ |
| `con_raca_penitente` | Penitente (o cego do Santuário) | `art/concept/raca-penitente.png` | 1024×1536 | ficha §11 | ⬜ |
| `con_raca_sem_rosto` | Sem-Rosto (o guarda da Raiz) | `art/concept/raca-sem-rosto.png` | 1024×1536 | ficha §12 | ⬜ |

## Ícones de armadura — volta 3, **fatia 1** ([`../spec/51-familias.md`](../spec/51-familias.md) §5)

> ⭐ **São as primeiras armaduras do jogo** — as 11 peças dos kits iniciais das 6 classes. Todas `Fatia 1 ✅`, todas com `descrição visual` em `game/data/armor.json`. Geradas uma a uma pelo [prompt 07](prompts/07-icones-armaduras.md), com chroma key removido para alfa real.

| ID | Asset | Caminho | Dim. | Classe(s) | Estado |
|---|---|---|---|---|---|
| `ico_arm_couro_peitoral` | Peitoral de couro fervido | `art/ui/icons/armor/couro-peitoral.png` | 1254×1254 | Guerreiro | ✅ |
| `ico_arm_couro_botas` | Botas de couro | `art/ui/icons/armor/couro-botas.png` | 1254×1254 | Guerreiro | ✅ |
| `ico_arm_ferro_elmo` | Elmo de ferro rude | `art/ui/icons/armor/ferro-elmo.png` | 1254×1254 | Tanque | ✅ |
| `ico_arm_ferro_peitoral` | Peitoral de ferro rude | `art/ui/icons/armor/ferro-peitoral.png` | 1254×1254 | Tanque | ✅ |
| `ico_arm_ferro_peitoral_polido` | Peitoral de ferro polido | `art/ui/icons/armor/ferro-peitoral-polido.png` | 1254×1254 | Paladino | ✅ |
| `ico_arm_pano_mascara` | Máscara de pano escuro | `art/ui/icons/armor/pano-mascara.png` | 1254×1254 | Assassino | ✅ |
| `ico_arm_pano_botas` | Botas de pano | `art/ui/icons/armor/pano-botas.png` | 1254×1254 | Assassino | ✅ |
| `ico_arm_couro_ombreiras` | Ombreiras de couro com pelo | `art/ui/icons/armor/couro-ombreiras.png` | 1254×1254 | Berserker | ✅ |
| `ico_arm_la_capa` | Capa de lã encerada | `art/ui/icons/armor/la-capa.png` | 1254×1254 | Feiticeiro | ✅ |
| `ico_arm_la_capa_clara` | Capa de lã clara | `art/ui/icons/armor/la-capa-clara.png` | 1254×1254 | Paladino | ✅ |
| `ico_arm_couro_cinto` | Cinto de bolsas | `art/ui/icons/armor/couro-cinto.png` | 1254×1254 | Feiticeiro | ✅ |

**Total: 54 assets arquivados** — 32 conceitos · 20 ícones · fundo de menu · céu. Estados: ⬜ por gerar · 🔄 gerado, por avaliar · ✅ arquivado no caminho.

> **Nota de contagem:** este manifesto dizia "22" na primeira versão. São 25 — a soma estava errada, não a lista.
>
> **Proveniência:** os 43 assets históricos saíram do pipeline Nano Banana/Higgsfield registado nesta versão do manifesto. Os 11 ícones de armadura foram gerados pelo pipeline integrado `imagegen`, mantendo literalmente a mesma frase de estilo e um objecto por prompt; o prompt 07 conserva a reprodução exacta.
>
> **Ícones:** os históricos vivem a 2048²; as 11 armaduras vivem a 1254². As armaduras foram geradas sobre chroma key e passadas pelo helper `remove_chroma_key.py`: todas RGBA, alfa 0–255 e fundo realmente transparente. Ao importar no runtime, o limite continua **512²**; o manifesto regista a dimensão real da fonte.


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
