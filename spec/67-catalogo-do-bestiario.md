# 67 — Catálogo do bestiário

> **Tarefa 3.2 · Codex · WP6** (01-08-2026). Fecha as 30–36 combinações `raça × bioma × camada` pedidas pelo [`50`](50-racas.md), sem reabrir os chefes do WP7. O catálogo executável é [`game/data/enemies.json`](../game/data/enemies.json); este documento explica a conta e torna-a auditável.

`[CODEX]` **Resultado:** **33 tipos comuns**, **100 ataques comuns** e os 5 ataques de Vorgar migrados. As 12 raças verdadeiras aparecem; o mímico continua `praga`. Cada comum tem massa, almas, `descricao_visual`, `fatia_1`, 3–5 perguntas de combate e um baralho explícito de 10. Cada ataque declara o tipo de contacto novo, 1–2 dos nove vectores de fuga, som e equivalente visual completos. ⚠️ A Revisão 1 encontrou dois buracos: **18/33 tipos não declaram velocidade de perseguição** e **cinco cartas obrigatórias `acessorio:*` não têm catálogo** (`LACUNAS`, `🔴`).

---

## 1. A unidade do catálogo

Um **tipo** partilha IA, ficha, baralho e contador de dez derrotas. Indivíduos colocados no mapa não duplicam o baralho. Uma raça muda de tipo quando o bioma muda **a pergunta da luta**, não só a cor: o Submerso nada depressa e anda devagar; a Ventaneira da Costa usa chuva/rajada e a da Cimeira gelo/neve; o orc da Fornalha traz metal fundido.

O JSON guarda declarações compactas para evitar copiar regras de honestidade 105 vezes. `GameData` expande-as no arranque e recusa o catálogo se a ficha compilada não cumprir o contrato. A ficha de ataque resultante tem:

| Bloco | Campos obrigatórios |
|---|---|
| Identidade | `id` · `display_name` · `pergunta` · `descricao_visual` · `fatia_1` |
| Cinco fases | `fase_1` · `fase_2` · `fase_3` · `fases_4_5` · `startup` · `active` · `recovery` · `aviso_total_frames` |
| Honestidade | `tipo_contacto` · `momento_compromisso_frame` · `curva_seguimento` · `parryable` · `vectores_fuga` |
| Leitura | `som_anuncio` com `cue_id`, descrição, perfil e alcance · `sinal_visual_equivalente` com âncora, forma, início, compromisso, fim e fora do ecrã |
| Geometria | `alcance_arco` · `range`/`radius` · `arc_degrees` · `janela_castigo_frames` · intervalo de dano ou um contacto por passagem quando aplicável |

⚠️ `startup` é a soma exacta das fases 1+2. O seguimento é `180°/s → 30°/s → 0°/s`; acaba no momento de compromisso, antes do primeiro frame activo. Instantâneos vivem 3–12 frames conforme a forma visível; volumes móveis acertam uma vez por passagem; persistentes pulsam no intervalo declarado enquanto continuam desenhados.

---

## 2. As doze perguntas-base — nunca uma resposta universal

| Molde | Contacto | Aparável | Vector(es) | Pergunta / forma visual |
|---|---|---:|---|---|
| `recto_aparavel` | instantâneo | sim | sair da linha · aparar | linha ou parry; chevrons fecham sobre a arma |
| `recto_esquiva` | instantâneo | não | sair da linha | seta dupla perpendicular à trajectória |
| `varrimento_dentro` | instantâneo | não | rolar para dentro | arco largo mostra o centro seguro |
| `varrimento_aparavel` | instantâneo | sim | rolar para dentro · aparar | chevrons percorrem o arco real |
| `pancada_curta` | instantâneo | sim | afastar-se · aparar | ponto de impacto curto; não premia recuo tardio |
| `combo_bloqueio` | instantâneo | não | bloquear e aguentar · afastar-se | uma marca por compromisso |
| `investida` | volume móvel | não | sair da linha | seta no chão; um acerto por passagem |
| `tiro` | instantâneo | não | sair da linha · aproximar-se | seta móvel presa ao projéctil |
| `mergulho` | volume móvel | não | sair da linha · aproximar-se | cunha vertical + sombra do destino |
| `area_persistente` | volume persistente | não | sair da área | contorno inteiro antes do primeiro pulso |
| `area_instantanea` | instantâneo | não | rolar para fora | círculo fecha uma vez no compromisso |
| `perseguidor` | volume móvel | não | quebrar a visão | rasto de duas pontas; cai sem linha de visão |

Cada inimigo comum usa pelo menos três perguntas diferentes. “Esquivar para trás”, “qualquer lado” e “funciona sempre” não são valores válidos.

---

## 3. As 33 fichas

Formato numérico: `PV / DEF / postura · massa · almas`. Equipamento resolve no [`68`](68-catalogo-de-armas-armaduras-e-aneis.md); materiais/consumíveis e a transacção resolvem no [`72`](72-materiais-consumiveis-e-economia.md). `✅` é conteúdo imediato da fatia 1.

| ID | Nome · raça · bioma | Papel | Ficha | Descrição visual | Fatia 1? |
|---|---|---|---|---|---:|
| `orc_spearman` | Orc lanceiro · orcs · Brumal | rápido | 135/4/40 · 92 kg · 40 | orc magro, cabeça rapada, lança serrada de ferro rude 220 cm, ombreira assimétrica, couro castanho e pano verde escuro | ✅ |
| `orc_brute` | Orc brutamontes · orcs · Brumal | pesado | 260/8/70 · 148 kg · 80 | orc de três metros, cabeça descoberta, maça cilíndrica de ferro 180 cm erguida, placas remendadas e couro grosso | ✅ |
| `goblin_mist_scout` | Batedor da bruma · goblins · Brumal | grupo | 95/2/28 · 41 kg · 35 | faca curva 45 cm, couro de javali e máscara de casca com líquen cinzento | ⬜ |
| `goblin_canopy_raider` | Salteador das copas · goblins · Selva | grupo | 115/3/30 · 43 kg · 50 | sabre de osso 65 cm, colete de vime e cordas magenta nos pulsos | ⬜ |
| `goblin_canopy_slinger` | Fundibulário das copas · goblins · Selva | distância | 90/2/24 · 39 kg · 55 | funda de seda crua, capuz de folhas e aljava de caroços negros | ⬜ |
| `kobold_bell_trapper` | Armadilheiro do sino · kobolds · Selva | armadilha | 105/4/32 · 48 kg · 60 | sino de bronze, lança curta de bambu e bobina de corda com espinhos rosa | ⬜ |
| `weaver_canopy_snarer` | Tecelão das copas · Tecelões · Selva | armadilha | 145/5/38 · 67 kg · 75 | quitina verde, abdómen magenta, braceletes de vime e seda grossa | ⬜ |
| `skeleton_swordsman` | Espadachim das Campas · esqueletos · Campas | rápido | 120/5/34 · 36 kg · 60 | osso amarelo, espada ferrugenta 75 cm, elmo rachado e madeira encharcada | ⬜ |
| `skeleton_archer` | Arqueiro das Campas · esqueletos · Campas | distância | 95/3/26 · 34 kg · 65 | arco encharcado 140 cm, capuz cinzento e penas verde-água | ⬜ |
| `mire_zombie` | Zumbi do lodo · zumbis · Campas | pesado | 220/7/64 · 88 kg · 55 | cadáver cinzento, enxada ferrugenta 130 cm e raízes nos tornozelos | ⬜ |
| `bloated_zombie` | Zumbi túmido · zumbis · Campas | pesado | 260/6/72 · 132 kg · 85 | ventre translúcido verde-água, cinturão ferrugento e juncos mortos | ⬜ |
| `kobold_mine_trapper` | Armadilheiro da mina · kobolds · Fojo | armadilha | 130/6/36 · 52 kg · 75 | capacete de couro, sino de ferro, picareta 70 cm e placas de pressão | ⬜ |
| `minotaur_quarry_bull` | Minotauro do veio · minotauros · Fojo | pesado | 420/12/100 · 310 kg · 150 | errante de machado duplo 190 cm, granito atado ao peito e chifres riscados | ⬜ |
| `mine_mimic` | Mímico de galeria · praga · Fojo | armadilha | 300/9/75 · 180 kg · 110 | baú de carvalho com ferro bruto; tampa sobe 2 cm a cada respiração | ⬜ |
| `sea_orc_hookbearer` | Orc do mar · orcs · Costa | rápido | 190/8/52 · 105 kg · 95 | gancho de bronze verde 80 cm, madeira de naufrágio e cânhamo | ⬜ |
| `tide_submerged` | Submerso da maré · Submersos · Costa | rápido | 180/7/46 · 78 kg · 100 | pele azul-petróleo, arpão de bronze 170 cm, membranas e rede salgada | ⬜ |
| `cliff_windborne` | Ventaneira da falésia · Ventaneiras · Costa | distância | 155/5/38 · 54 kg · 105 | penas cinza-chuva, lança de espinho 110 cm e bronze verde nas asas | ⬜ |
| `wreck_mimic` | Mímico de naufrágio · praga · Costa | armadilha | 330/10/82 · 195 kg · 125 | baú encharcado, bronze verde, cracas e língua azul salgada | ⬜ |
| `summit_windborne` | Ventaneira da Cimeira · Ventaneiras · Cimeira | distância | 190/7/44 · 58 kg · 120 | penas branco-azul, lança de aço frio 150 cm, máscara de gelo e pele de cabra | ⬜ |
| `snow_minotaur` | Minotauro da neve · minotauros · Cimeira | pesado | 480/14/100 · 340 kg · 170 | pelo branco, martelo de aço frio 180 cm e chifres de gelo-azul | ⬜ |
| `emberling_hammersmith` | Borralheiro martelador · Borralheiros · Fornalha | pesado | 360/13/90 · 155 kg · 135 | pedra negra fissurada, martelo-lâmina de obsidiana e bronze fundido | ⬜ |
| `fire_orc_smith` | Orc ferreiro · orcs · Fornalha | pesado | 330/12/82 · 138 kg · 125 | fuligem, tenaz de bronze 140 cm, máscara de obsidiana e avental marcado | ⬜ |
| `storm_minotaur` | Minotauro da tempestade · minotauros · Fulgor | pesado | 520/15/100 · 325 kg · 185 | maça de fulgurite 190 cm, couro seco e placas de osso sem metal | ⬜ |
| `storm_kobold` | Kobold da tempestade · kobolds · Fulgor | armadilha | 175/8/42 · 55 kg · 115 | sino de osso, funda de couro e varetas violetas de fulgurite | ⬜ |
| `spore_weaver` | Tecelão de esporos · Tecelões · Raizama | armadilha | 240/10/58 · 82 kg · 140 | quitina azul-negra, abdómen ciano e fuso de madeira-cogumelo | ⬜ |
| `fungus_goblin` | Goblin-fungo · goblins · Raizama | grupo | 195/7/40 · 47 kg · 120 | chapéu ciano, clava de madeira-cogumelo 90 cm e bolsas translúcidas | ⬜ |
| `flooded_submerged` | Submerso da cidade · Submersos · Cidade | rápido | 260/11/58 · 84 kg · 155 | tridente de prata escura 180 cm, mármore afogado e membranas brancas | ⬜ |
| `drowned_zombie` | Zumbi afogado · zumbis · Cidade | pesado | 350/10/78 · 112 kg · 130 | coluna de mármore como maça, sino de prata e algas brancas | ⬜ |
| `penitent_cantor` | Cantor penitente · Penitentes · Santuário | grupo | 230/9/48 · 72 kg · 170 | túnica de cera, diapasão de ouro 100 cm e gola fina de mármore | ⬜ |
| `penitent_censer` | Turiferário · Penitentes · Santuário | grupo | 300/12/66 · 86 kg · 160 | placas de mármore, turíbulo de ouro numa corrente 160 cm e capuz de cera | ⬜ |
| `gilded_skeleton` | Esqueleto dourado · esqueletos · Santuário | rápido | 250/11/55 · 44 kg · 155 | folha de ouro, espada de prata 95 cm e cera branca nas órbitas | ⬜ |
| `faceless_halberdier` | Alabardeiro Sem-Rosto · Sem-Rosto · Raiz | pesado | 430/16/95 · 118 kg · 220 | manto de pedra negra, alabarda de raiz 240 cm e três aros de prata suspensos | ⬜ |
| `ancient_skeleton` | Esqueleto antigo · esqueletos · Raiz | rápido | 320/14/68 · 48 kg · 190 | osso negro, espada curva de prata 105 cm, elos de raiz e lanterna violeta | ⬜ |

### Regras raciais que não cabem nos números

Cada tipo comum tem de declarar `chase_speed`; Submersos declaram o par `swim_chase_speed`/`land_chase_speed`. Todos os valores têm de ser `<5,0 m/s`, para a corrida normal abrir distância. Hoje só 15/33 fichas cumprem a obrigação sintáctica; as dezoito omissões estão registadas para preenchimento, sem números inventados por esta revisão.

- Esqueletos reerguem-se uma vez salvo golpe final contundente; zumbis recebem `×0,75` de físico comum.
- Submersos têm velocidade de perseguição própria dentro/fora de água. Mímicos respiram antes de abrir.
- O Cantor reforça aliados enquanto canta. O jogador pode interromper a função atacando a prioridade certa.
- Sem-Rosto não largam o corpo: a carta sorteada materializa-se no relicário abandonado mais próximo. O baralho existe; a ficção da raça não é quebrada.
- O Minotauro do veio é um errante comum. **Não é** o Minotauro singular que guarda o labirinto; esse continua no WP7, sem baralho, e esta tarefa não decide a sua ficha.

---

## 4. Os 100 ataques comuns

Legenda: `I` instantâneo · `M` volume móvel · `P` volume persistente. A ficha completa — fases específicas, alcance/arco, castigo, som descrito e seis campos visuais — está compilada no JSON e coberta pelo auto-teste. Aqui vê-se se as três perguntas de cada tipo são realmente diferentes.

| Tipo | Ataques — contacto; vector(es) |
|---|---|
| Lanceiro | Estocada — I; sair da linha · Estocada dupla — I; bloquear/afastar · Varrimento baixo — I; entrar/aparar · Investida — M; sair da linha |
| Brutamontes | Golpe de cima — I; linha/aparar · Varrimento — I; entrar/aparar · Pancada — I; afastar/aparar |
| Batedor goblin | Picada — I; linha/aparar · Salto — M; linha · Bruma — P; sair da área |
| Salteador | Talho — I; linha/aparar · Corda — M; linha/aproximar · Bando — I; bloquear/afastar |
| Fundibulário | Caroço — I; linha/aproximar · Peçonha — P; área · Retirada — M; linha |
| Kobold do sino | Bambu — I; linha/aparar · Laço — P; área · Fuga — M; linha |
| Tecelão das copas | Seda — I; entrar · Teia — P; área · Novelo — M; quebrar visão |
| Espadachim esqueleto | Corte — I; linha/aparar · Costelas — I; entrar · Rajada — I; bloquear/afastar |
| Arqueiro esqueleto | Flecha — I; linha/aproximar · Arco alto — I; fora · Empurrão — I; afastar/aparar |
| Zumbi do lodo | Enxada — I; afastar/aparar · Abraço — I; afastar · Queda — I; fora |
| Zumbi túmido | Ventre — I; fora · Bile — P; área · Rolamento — M; linha |
| Kobold da mina | Picareta — I; linha/aparar · Placa — P; área · Galeria — M; linha |
| Minotauro guardião | Talho — I; entrar · Chifres — M; linha · Pisada — I; fora |
| Mímico da mina | Mordida — I; afastar · Língua — I; entrar · Salto — M; linha |
| Orc do mar | Gancho — I; linha · Ceifa — I; entrar/aparar · Ombro — M; linha |
| Submerso da maré | Arpão — I; linha/aparar · Arranco — M; linha · Rede — P; área |
| Ventaneira da falésia | Mergulho — M; linha/aproximar · Pena — I; linha/aproximar · Rajada — I; fora |
| Mímico de naufrágio | Mordida — I; afastar · Salmoura — P; área · Rolamento — M; linha |
| Ventaneira da Cimeira | Mergulho — M; linha/aproximar · Pena — I; linha/aproximar · Neve — P; área |
| Minotauro da neve | Martelo — I; afastar/aparar · Investida — M; linha · Geada — P; área |
| Borralheiro | Talho — I; linha/aparar · Brasa — I; entrar · Marca — P; área |
| Orc ferreiro | Tenaz — I; linha/aparar · Forja — I; entrar/aparar · Gota — P; área |
| Minotauro da tempestade | Vidro — I; afastar/aparar · Investida — M; linha · Pisada — I; fora |
| Kobold da tempestade | Estilhaço — I; linha/aproximar · Vareta — P; área · Fuga — M; linha |
| Tecelão de esporos | Fio — I; entrar · Teia — P; área · Casulo — M; quebrar visão |
| Goblin-fungo | Clava — I; linha/aparar · Esporos — P; área · Toca — I; bloquear/afastar |
| Submerso da cidade | Tridente — I; linha/aparar · Arranco — M; linha · Malha — P; área |
| Zumbi afogado | Coluna — I; afastar/aparar · Mãos — I; afastar · Queda — I; fora |
| Cantor | Nota — M; quebrar visão · Coro — P; área · Diapasão — I; linha/aparar |
| Turiferário | Turíbulo — I; entrar · Incenso — P; área · Ombro — M; linha |
| Esqueleto dourado | Prata — I; linha/aparar · Ouro — I; entrar/aparar · Litania — I; bloquear/afastar |
| Sem-Rosto | Estocada — I; linha/aparar · Ceifa — I; entrar · Aro — M; quebrar visão |
| Esqueleto antigo | Corte — I; linha/aparar · Arco — I; entrar/aparar · Cadeia — I; bloquear/afastar |

---

## 5. Baralhos de dez

Cada ficha declara `loot_cards[10]`, `mandatory_loot_count` e os índices obrigatórios. As cartas obrigatórias são sempre as primeiras e correspondem exactamente ao equipamento visível; só as restantes aceitam `bias:classe`. A ordem é baralhada por `loot_draw_order(enemy_id, seed)` e a carta não volta. Mesma semente + mesmo tipo = mesma sequência.

| Família | Obrigatório garantido até à 10.ª derrota | Enchimento permitido |
|---|---|---|
| humanoides armados | arma + cada peça que se vê (2–5 cartas) | 2× almas+ · material do bioma · consumível · `bias:classe` |
| criatura com pouco equipamento | arma/ferramenta e adorno realmente visível (1–3) | almas+ · material corporal/bioma · consumível · `bias:classe` |
| mímico | dente-arma + ferragem do baú | almas+ · material do baú/bioma · consumível · anel temático · `bias:classe` |
| Sem-Rosto | alabarda + manto | os oito restantes surgem no relicário, nunca no corpo |

Os **330 cartões exactos** estão no JSON para não haver uma segunda fonte que possa divergir. O auto-teste conta 10 por tipo, confirma compra sem reposição e verifica que todos os índices obrigatórios existem.

⚠️ Isso não prova que cada payload resolve. Armas, armaduras e anéis resolvem; a Revisão 1 encontrou cinco payloads obrigatórios `acessorio:*` sem qualquer ficha: os quatro sinos dos kobolds/zumbi e a lanterna do esqueleto antigo. A garantia visual fica incompleta até esses IDs ganharem catálogo ou serem substituídos por uma categoria já definida.

---

## 6. Almas — orçamento fechado por zona

O total de primeira limpeza é `quantidade colocada × almas por tipo`. O limite de dez limpezas recompensadas é exactamente `×10`; depois disso o inimigo ainda pode existir por desenho, mas não volta a abrir uma torneira de almas/espólio.

| Zona | População de referência | 1.ª limpeza | 10 limpezas recompensadas |
|---|---|---:|---:|
| Brumal | 4 lanceiros · 2 brutamontes · 2 batedores | **390** | **3 900** |
| Selva Funda | 4 salteadores · 3 fundibulários · 2 kobolds · 2 Tecelões | **635** | **6 350** |
| Campas Cinzentas | 4 espadachins · 3 arqueiros · 4 zumbis · 2 túmidos | **825** | **8 250** |
| Fojo | 5 kobolds · 1 minotauro · 2 mímicos | **745** | **7 450** |
| Costa Quebrada | 4 orcs · 3 Submersos · 2 Ventaneiras · 1 mímico | **1 015** | **10 150** |
| Cimeira | 4 Ventaneiras · 3 minotauros | **990** | **9 900** |
| Fornalha | 4 Borralheiros · 4 orcs | **1 040** | **10 400** |
| Fulgor | 4 minotauros · 5 kobolds | **1 315** | **13 150** |
| Raizama | 5 Tecelões · 5 goblins | **1 300** | **13 000** |
| Cidade Afogada | 5 Submersos · 5 zumbis | **1 425** | **14 250** |
| Santuário Branco | 2 Cantores · 5 Turiferários · 4 esqueletos | **1 760** | **17 600** |
| A Raiz | 5 Sem-Rosto · 5 esqueletos | **2 050** | **20 500** |

O total de zona não inclui chefe, guardião narrativo fixo, porta de história nem descoberta única. Esses valores pertencem a WP7/WP8/WP9 e não podem ser usados para corrigir este orçamento às escondidas.

---

## 7. `GameplayCue` — som e visual são apresentações, não regras

[`gameplay_cue.gd`](../game/src/combat/gameplay_cue.gd) nasce na origem do ataque e dura até deixar de poder afectar o jogador. Desenha faixa/área no mundo, glifo de resposta e cunha no bordo quando sai do ecrã; cancelamento quebra em 0,15 s. Volumes persistentes pulsam no intervalo real. `Sfx` oferece cinco famílias sonoras semânticas — aparar, esquivar, volume móvel, área e perseguidor — mas cada ataque conserva `cue_id` e descrição próprios.

O áudio pode estar a zero. O renderer continua. Cor é redundância: `><`, `↔`, `◎`, `◉` e `▥` transportam a resposta pela forma. A semente de padrão da IA e a semente do baralho são argumentos explícitos; o ensaio 42 repete-se.

---

## 8. Arte — o que se gera agora

Só `orc_spearman`, `orc_brute` e Vorgar têm `fatia_1: true`. Os conceitos aprovados foram auditados contra as descrições e reutilizados:

| ID | Asset | Estado |
|---|---|---|
| `orc_spearman` | `art/concept/orc-lanceiro.png` · 1024×1536 | ✅ existente; descrição alinhada a cabeça rapada, sucata leve e lança comprida |
| `orc_brute` | `art/concept/orc-brutamontes.png` · 1024×1536 | ✅ existente; descrição alinhada a cabeça descoberta, placas e arma erguida |
| `vorgar` | `art/concept/vorgar.png` · 1536×1024 | ✅ existente; descrição alinhada a cutelo, armadura serrada e portão |

As outras 31 fichas têm uma frase gerável com material do bioma, mas ficam ⬜ até a sua fatia ser promovida. Não se gastam imagens em conteúdo que o plano ainda não constrói.

---

## 9. As quatro perguntas do fio solto

### 1. Como é que o jogador usa isto?

Lê pose + geometria + cue, escolhe o vector específico e aprende três perguntas por tipo. Em dez derrotas recompensadas completa tudo o que viu equipado; massa torna empurrão previsível e almas mostram se o risco compensa.

### 2. Como é que se prova que funciona?

Auto-teste de schema e contagens, 10/10 de rolamento por ataque no WP15B, banco de 20 cues sem som do [`62`](62-acessibilidade-auditiva.md), sementes repetidas, soma automática dos 12 orçamentos e teste de performance com no máximo cinco inimigos animados.

### 3. De onde vêm a arte e o som?

`descricao_visual` + material do [`49`](49-biomas.md). Conceitos imediatos são os três PNG aprovados; os restantes esperam a sua fatia. O som é sintetizado em runtime nesta fase e os samples CC0 de Kenney continuam disponíveis para produção; nenhum ficheiro de áudio define timing.

### 4. Quanto custa na máquina do Rico?

Dados inactivos custam memória desprezável; uma luta mantém ≤5 inimigos animados. Cada cue usa um mesh simples, um glifo 3D e um glifo de bordo, sem textura nova. Volumes persistentes reutilizam o mesmo nó e relógio; não geram uma entidade por pulso.

---

## 10. O que fica para os pacotes seguintes

- ✅ WP5 no [`68`](68-catalogo-de-armas-armaduras-e-aneis.md) materializa armas, armaduras e anéis referidos pelos cartões.
- ✅ WP9 no [`72`](72-materiais-consumiveis-e-economia.md) liga morte → compra → recibo/save, resolve os 40 materiais e corrige os 17 tokens antigos para 15 consumíveis canónicos.
- WP8 coloca as populações no traçado; estes totais são orçamento e não autorizam copiar a mesma composição para todos os atalhos.
- WP15B produz animações/hitboxes e corre o teste 10/10, o banco sem som e o limite de cinco animados.

## Ligações

[`15-inimigos.md`](15-inimigos.md) · [`36-fisica.md`](36-fisica.md) · [`38-ataques-e-honestidade.md`](38-ataques-e-honestidade.md) · [`40-decisoes-espolio-magia-inventario.md`](40-decisoes-espolio-magia-inventario.md) · [`43-estudo-espolio-inventario-mundo.md`](43-estudo-espolio-inventario-mundo.md) · [`49-biomas.md`](49-biomas.md) · [`50-racas.md`](50-racas.md) · [`60-o-agente-que-joga.md`](60-o-agente-que-joga.md) · [`62-acessibilidade-auditiva.md`](62-acessibilidade-auditiva.md) · [`63-como-se-afinam-os-numeros.md`](63-como-se-afinam-os-numeros.md) · [`99-perguntas-abertas.md`](99-perguntas-abertas.md)
