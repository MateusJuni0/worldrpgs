# 72 — Materiais, consumíveis e a transacção de espólio

`[CODEX]` — fecha materiais, consumíveis e a transacção de WP9 para os 330 cartões do [`67`](67-catalogo-do-bestiario.md), ligando derrota, baralho, inventário, almas, recibo e save sem decidir a `[TENSÃO]` de propriedade em co-op. A Tarefa 5 migrou os cinco `acessorio:*` para IDs catalogados; a economia já não carrega essa excepção.

O catálogo executável é [`game/data/economy.json`](../game/data/economy.json). O fluxo vive em `GameData.reward_enemy_defeat()` e a publicação atómica em `SaveSystem.commit_enemy_defeat()`.

## 1. Uma moeda e uma curva

Só existem **almas** como moeda de nível, compra e troca. O custo do nível que se compra é:

`max(1, round(0,02N³ + 3,06N² + 105,6N − 895))`, para `N=1…100`.

| Nível comprado | Custo exacto |
|---:|---:|
| 20 | 2 601 |
| 40 | 9 505 |
| 70 | 28 351 |
| 100 | 60 265 |

Isto materializa a curva corrigida do [`58`](58-fim-do-jogo-ciclos-e-a-curva.md). Os pontos altos não substituem as curvas diferentes por atributo do [`70`](70-fecho-dos-sistemas-de-combate.md): custo controla o ritmo; soft caps controlam o rendimento.

## 2. Os 40 materiais

Todos empilham até 99, têm origem, valor de troca, descrição visual e **refinamento 1–3**. O refinamento não é poder aleatório: é o número de pontos que a unidade satisfaz numa receita.

| Zona | Materiais fechados |
|---|---|
| Brumal | `limalha_ferro` · `couro_javali` |
| Selva Funda | `seiva_peconha` · `vime_trancado` · `seda_crua` · `corda_espinhosa` · `quitina_verde` |
| Campas Cinzentas | `cinza_ossario` · `osso_antigo` · `madeira_encharcada` · `lodo_mortuorio` · `bile_fatua` · `ferro_ferrugento` |
| Fojo | `ferro_bruto` · `corda_mina` · `chifre_riscado` · `madeira_bau_antiga` |
| Costa Quebrada | `bronze_mar` · `madeira_naufragio` · `membrana_mare` · `pena_tempestade` · `craca_branca` |
| Cimeira | `flor_gelo` · `pena_cimeira` · `chifre_gelado` |
| Fornalha | `obsidiana` · `bronze_fundido` |
| Fulgor | `fulgurite` · `chifre_tempestade` · `couro_seco` |
| Raizama | `esporo_lumen` · `seda_teia` · `madeira_cogumelo` |
| Cidade Afogada | `prata_afogada` · `vidro_afogado` · `marmore_afogado` |
| Santuário Branco | `cera_benta` · `ouro_baco` |
| Raiz | `lagrima_bruma` · `prata_baca` |

### 2.1. A pergunta que estava aberta: magia usa os mesmos materiais

`[CODEX]` — **sim**. Armas e feitiços usam o mesmo catálogo regional. Os seis níveis pedem **1/2/3/5/8/12 pontos de refinamento** do bioma de origem do item; cada nível abre a escolha declarada na sua ficha e nunca sobe dano base por si.

Razão: os baralhos já entregam uma oferta finita e legível por zona. Criar “pedra de magia” paralela duplicaria inventário, receitas, telas e casos de azar sem criar uma decisão — sobretudo porque qualquer classe pode aprender magia. A alternativa descartada foi duas moedas de melhoria; seria justificável apenas se os donos quisessem progressões de mundo separadas, o que nunca decidiram.

O enviesamento de classe continua real dentro do catálogo partilhado: uma carta `bias:classe` resolve para o material marcial ou arcano declarado para aquela zona. A promessa visível do inimigo nunca passa por esse enviesamento.

## 3. Os 15 consumíveis canónicos

O levantamento antigo contou **17 strings**, não 17 objectos válidos. Duas eram defeitos:

- `brasa_portatil` aparecia em dois baralhos, mas contradizia a Brasa única, colocada e não-farmável do [`70`](70-fecho-dos-sistemas-de-combate.md); as cartas passam a `sal_gelo` e a Brasa fica fora deste catálogo;
- `véu_sombra` e `veu_sombra` eram o mesmo objecto com dois IDs; `veu_sombra` é canónico e a grafia acentuada fica como alias de migração.

Logo, a promessa resolvida é **15 consumíveis reais**, não 17 duplicados/contraditórios:

| ID | Uso exacto |
|---|---|
| `agua_lustral` | em 1,2 s limpa as barras de veneno, sangramento e queimadura |
| `antidoto_selva` | limpa veneno e reduz a acumulação a ×0,50 durante 20 s |
| `bomba_bruma` | nuvem de 4 m por 6 s; quebra tracking de não-chefes |
| `lanterna_raiz` | luz de 8 m por 90 s e revela tinta escondida |
| `musgo_seco` | limpa sangramento e reduz a acumulação a ×0,50 durante 20 s |
| `oleo_condutor` | cinco contactos de revestimento de raio, +12 de acumulação por contacto |
| `oleo_salino` | cinco contactos; ×1,15 dano contra Submersos |
| `pedra_raio` | arremesso a 12 m, raio 2 m, 20 de postura e interrompe armadilhas |
| `po_terra` | dano de raio recebido ×0,70 por 20 s; impede sprint na água durante o efeito |
| `resina_bruma` | cinco contactos; cada um atrasa a reaquisição inimiga em 0,35 s |
| `sal_gelo` | limpa queimadura e reduz a acumulação a ×0,50 durante 20 s |
| `sal_seco` | reduz em 30% a penalização de movimento na água por 30 s |
| `solvente_teia` | solta uma prisão e reduz nova acumulação a ×0,50 durante 20 s |
| `tocha_esporo` | luz de 6 m por 45 s e repele nuvens de esporos num raio de 2 m |
| `veu_sombra` | detecção inimiga ×0,65, termina ao atacar ou aos 30 s |

Cada ficha traz tempo de uso, pilha, efeito estruturado, objecto visual e som. O uso continua sujeito ao estado `USING_ITEM`; por isso o castigo de cura/consumo lê a animação visível, não o botão.

## 4. Derrota → baralho → recibo → save

Uma derrota comum recompensada é uma só transacção:

1. recebe `enemy_id`, `event_id`, semente e classe do **destinatário já escolhido pelo chamador**;
2. se o `event_id` já tem recibo, devolve `already_committed` e não altera nada;
3. cria uma ordem determinística na primeira derrota daquele tipo e guarda-a em `world.loot_decks`;
4. compra `order[next_index]`; `bias:classe` resolve pelo perfil/bioma, as outras cartas ficam intactas;
5. soma as almas-base e eventual `almas_bonus`, adiciona o item e avança o índice;
6. acrescenta um recibo com carta bruta, carta resolvida, almas e índice;
7. `SaveSystem` grava o estado inteiro por `.tmp` + verificação + rename; se falhar, repõe o snapshot anterior em memória.

Depois da décima carta, devolve `exhausted`: não há 11.ª recompensa. O `main.gd` liga `Enemy.died` a esta fronteira e apresenta almas/carta; chefes ficam fora porque entregam o conjunto fixo do WP7.

### 4.1. Co-op sem decisão à socapa

A infraestrutura **não escolhe** de quem é o enviesamento. Recebe `receiver_class_id`; o sistema de rede futuro terá de o chamar uma ou duas vezes segundo a resposta dos donos à pergunta 29 do [`99`](99-perguntas-abertas.md). Assim a transacção está completa e testável sem converter a proposta “uma carta para cada um” em decisão.

## 5. As quatro perguntas do fio solto

| Pergunta | Resposta |
|---|---|
| Como é que o jogador usa isto? | mata um inimigo para receber a próxima carta; consome no atalho de item; leva materiais ao altar para satisfazer a receita e abrir uma escolha de melhoria |
| Como é que se prova? | o auto-teste valida 40/15 catálogos, aliases, curva, bias marcial/arcano, dez compras sem reposição, idempotência e persistência conjunta de recibo/índice |
| De onde vêm a arte e o som? | cada entrada descreve objecto/material e cue; não há ícones aprovados fora da Fatia 1, portanto os assets só são produzidos quando `Fatia 1?` os promover |
| Quanto custa na máquina do Rico? | uma ordem de dez strings e um índice por tipo no save; uma escrita atómica por derrota recompensada; efeitos temporários só processam enquanto activos e não acrescentam polling aos inimigos |

## 6. Fronteira honesta

O catálogo de **materiais/consumíveis**, as fórmulas e a transacção local estão completos. Os cinco acessórios antigos já foram migrados para anéis/consumível pelo [`74`](74-fecho-da-revisao-2.md); não resta uma categoria de acessório fora do contrato. Ficam ainda de propósito para M2/WP10–11: UI do altar/inventário, renderer dos efeitos, apresentação final da carta e política de destinatário em co-op. A última é decisão dos donos; as outras são clientes dos contratos já fechados.

Este documento não decide nenhuma `[TENSÃO]`.
