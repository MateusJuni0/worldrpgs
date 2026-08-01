# 65 — Música e ambiente: atmosfera que nunca tapa informação

> **Tarefa 2.5 · Codex** (01-08-2026). Fecha o que toca, onde entra e sai, como os 182 `.ogg` existentes são realmente usados e como a mistura obedece ao contrato sonoro/visual do [`38`](38-ataques-e-honestidade.md) + [`62`](62-acessibilidade-auditiva.md). Tudo `[CODEX]` salvo indicação.

**Regra-mãe:** música e ambiente podem elevar uma cena; nunca podem esconder, substituir ou antecipar a informação que permite sobreviver.

`[CODEX]` **Razão:** num combate lido em frames, “soa épico” não compensa um ataque mascarado. **Alternativa descartada:** misturar tudo no mesmo bus e baixar o volume geral quando fica confuso; baixa também a telegrafia e conserva o problema.

---

## 1. A verdade dos assets — 182 não significa banda sonora

Inventário local medido com `ffprobe` em 01-08-2026:

| Pack | Ficheiros | Conteúdo real |
|---|---:|---|
| Kenney Impact Sounds | **130** | 25 passos por superfície + 105 impactos por material/peso |
| Kenney RPG Audio / `Audio` | **51** | portas, livro, roupa, couro, moedas, faca, passos e adereços |
| Kenney RPG Audio / `Preview.ogg` | **1** | demonstração de 26,13 s; **não é asset do jogo** |
| **Total** | **182** | **181 SFX utilizáveis; zero música; zero loop de ambiente** |

Os 181 efeitos somam **77,5 s**, média **0,428 s**, máximo **1,741 s**, e ocupam **1,68 MiB comprimidos**. O `Preview.ogg` não se copia para `game/`, não entra no catálogo e não se corta em sons — é só a montra do autor.

Além deles, o protótipo gera em código **17 sons** a 22,05 kHz: os 12 baselines (`swing_light`, `swing_heavy`, `hit_flesh`, `hit_block`, `parry`, `dodge`, `step`, `flask`, `telegraph`, `posture_break`, `enemy_death`, `fury`) + cinco apresentações semânticas de ataque (`attack_parry`, `attack_dodge`, `attack_moving`, `attack_area`, `attack_hunter`). São baseline funcional, **não faixas**. O [`67`](67-catalogo-do-bestiario.md) já retirou o `telegraph` único do caminho dos inimigos; a produção sonora continua subordinada ao mesmo `cue_id` do [`62`](62-acessibilidade-auditiva.md).

### Biblioteca não é runtime

- `art/audio/` conserva packs/licenças completos;
- só os sons aprovados são copiados para `game/audio/` e importados pelo Godot;
- o original nunca é editado; conversão para mono, trim, ganho e loop são receita de importação reproduzível;
- cada entrada guarda fonte, licença e hash; renomear no runtime não apaga a autoria do [`CREDITS`](../CREDITS.md).

---

## 2. Onde tocam os 181 efeitos

### Impact Sounds — 130 ficheiros

| Grupo do pack | N | Uso canónico | Onde toca | Não usar para |
|---|---:|---|---|---|
| `footstep_grass_*` | 5 | passo exterior em vegetação | Brumal: erva, margem de trilho | pedra molhada / madeira |
| `footstep_concrete_*` | 5 | bota em pedra | ruínas de Brumal, Toca, arena de Vorgar | terra/folhas |
| `footstep_wood_*` | 5 | prancha/ponte | pontes, passadiços, tábuas da Toca | bloqueio de escudo |
| `footstep_carpet_*` | 5 | tecido/tapete | interiores futuros que declarem esse piso | fallback de qualquer chão |
| `footstep_snow_*` | 5 | neve | Cimeira/zonas futuras com neve na ficha | Brumal só porque tem névoa |
| `impactMetal_{light,medium,heavy}_*` | 15 | arma contra metal nu | arma, escudo metálico, corrente | carne/pedra |
| `impactPlate_{light,medium,heavy}_*` | 15 | golpe em armadura de placa | Tanque/Paladino, inimigo blindado | panelas/adereços |
| `impactWood_{light,medium,heavy}_*` | 15 | golpe/bloqueio em madeira | escudo de madeira, porta, pilar | passos |
| `impactPlank_medium_*` | 5 | prancha a partir/ceder | obstáculo ou chão de madeira | cada bloqueio comum |
| `impactSoft_{medium,heavy}_*` | 10 | roupa/corpo acolchoado | corpo vestido, queda no chão macio | carne aberta |
| `impactPunch_{medium,heavy}_*` | 10 | corpo/contusão | punho, ombro, pancada sem lâmina | corte/perfuração |
| `impactGlass_{light,medium,heavy}_*` | 15 | magia/Égide/frasco | Égide a partir, vidro, cristal | metal “brilhante” |
| `impactBell_heavy_*` | 5 | candidatos ao parry/ruptura icónica | banco A/B dos dois; seleccionar 3 | rotação aleatória sem escuta |
| `impactMining_*` | 5 | metal/pedra pesada | picareta, golpe no rochedo, ruína da Toca | impacto corporal |
| `impactTin_medium_*` | 5 | adereço metálico leve | recipiente, sucata, armadilha pequena | armadura de chefe |
| `impactGeneric_light_*` | 5 | fallback temporário marcado | só protótipo de evento sem família | shipping ou telegrafia |

### RPG Audio — 51 ficheiros

| Grupo | N | Uso | Onde |
|---|---:|---|---|
| `bookOpen/Close/Flip/Place*` | 8 | livro, diário, catálogo | descanso, vendedor, interface diegética |
| `beltHandle*`, `cloth*`, `clothBelt*`, `dropLeather`, `handleSmallLeather*` | 11 | equipar, mochila, rolamento, roupa | jogador/inventário; variação por acção |
| `doorOpen/Close_*`, `creak*`, `metalLatch` | 10 | portas, grades, baús | mundo e Toca; nevoeiro não é porta física |
| `drawKnife*`, `knifeSlice*`, `chop` | 6 | sacar adaga, corte leve, machado em madeira | arma concreta; nunca aviso genérico de inimigo |
| `handleCoins*` | 2 | transacção/almas materiais | vendedor/recompensa, não cada ponto de XP |
| `metalClick`, `metalPot*` | 4 | fecho/adereço/recipiente | mundo e inventário |
| `footstep00..09` | 10 | candidatos de calçado/foley genérico | ficam em quarentena até audição A/B contra os passos por piso |

“Candidato” é deliberado: nomes não provam timbre nem encaixe. A audição escolhe 2–5 variações por evento e o [`63`](63-como-se-afinam-os-numeros.md) regista ganho/pitch; não se importam 181 sons só porque existem.

### Matriz da fatia 1

| Momento | Som actual → fonte-alvo |
|---|---|
| passo em Brumal | `step` sintetizado → `footstep_grass`/`concrete`/`wood` conforme material sob o pé |
| golpe em orc | `hit_flesh` → soft/punch + camada própria de carne ainda em falta |
| espada/escudo | `hit_block` → metal/plate/wood pelo par real dos materiais |
| parry | sintetizado continua baseline → 3 candidatos `impactBell` testados pelos dois |
| rolamento/equipar | `dodge` → cloth/leather + impacto do piso, sem duplicar transientes fortes |
| frasco/Égide | `flask` + glass; Égide usa glass por peso |
| portas/Toca | door/creak/latch; mining/stone em pancadas no cenário |
| ataque inimigo | `telegraph` genérico → esforço/arma próprio de cada linha do [`38`](38-ataques-e-honestidade.md) |

Faltam carne, whooshes completos, vozes humanas/orcs, fauna, vento, folhagem, água/gotas e correntes. Os packs reduzem trabalho; não fecham o catálogo.

---

## 3. Música da fatia — seis peças e três stingers, ainda por produzir

Mantém-se o orçamento honesto do [`21`](21-arte-render.md):

| ID | Duração-alvo | Onde | Comportamento |
|---|---:|---|---|
| `mus_menu_rest` | 2:00 loop | menu, criação e descanso | no descanso usa arranjo/camada mais baixa; não reinicia a melodia a cada menu |
| `mus_brumal_explore` | 3:00 loop | exterior de Brumal sem combate | esparsa; deixa espaço espectral e temporal aos sinais |
| `mus_brumal_tension` | 3:00 stem | mesmo exterior em combate | mesma grelha/loop do explore; sobe por crossfade, não começa do zero |
| `mus_toca` | 2:30 loop | dungeon da Toca | mais grave/espaçada; combate usa intensificação interna sem nova faixa na fatia |
| `mus_vorgar_p1` | 2:30 loop | arena, fase 1 | entra no evento de início do chefe, nunca ao aproximar do nevoeiro |
| `mus_vorgar_p2` | 2:30 loop | arena, fase 2 | alinhada ao mesmo mapa de compassos; entra no grito autoritativo |
| `st_death` | 5 s | morte | depois de 0,5 s de silêncio |
| `st_victory` | 8 s | morte de guardião/Ultra | depois de o golpe final e a queda respirarem |
| `st_discovery` | 3 s | descoberta maior | só se não houver chefe/morte/telegrafia activa |

**Não há ficheiro para nenhuma destas nove entradas.** Até existirem, o jogo pode correr em silêncio musical; impactos curtos não se esticam nem se empilham para fingir uma faixa.

### Direcção recomendada, não decisão dos donos

Recomendo composição original/adaptativa de **baixa densidade**, entregue em loops e stems com a mesma grelha, porque permite reservar espaço para telegrafia e coser fases sem cortes. Uma faixa pronta CC0/CC-BY continua possível, mas só entra se puder cumprir loop, stems/transição, licença e mistura. **Quem compõe/selecciona e o idioma musical final continuam pergunta dos donos** no [`99`](99-perguntas-abertas.md); este documento não os decide.

---

## 4. O director musical — estados, entradas e saídas

Um `MusicDirector` recebe **estado de jogo**, nunca distância improvisada ao inimigo:

```text
DEATH / VICTORY
       ↓ prioridade
BOSS_P3 > BOSS_P2 > BOSS_P1 > COMBAT > REST > EXPLORE > MENU > SILENCE
```

| Transição | Gatilho autoritativo | Entrada | Saída |
|---|---|---|---|
| boot → menu | menu pronto | fade **1,5 s** | — |
| menu → criação | ecrã abre | mantém posição do `mus_menu_rest` | não reinicia |
| mundo → descanso | controlo entra no estado seguro | crossfade **2 s** para camada baixa do motivo | volta ao estado da zona em 2 s ao levantar |
| carregar zona | jogador recupera controlo | música da zona em **3 s** | anterior sai nos mesmos 3 s |
| exploração → combate | primeira IA confirma `ALERT/AGGRO` | tension stem em **2 s**, alinhado ao compasso | nunca antes do alerta: não denuncia emboscada |
| combate → exploração | 4 s sem agressor, projéctil ou área hostil | base fica; tensão sai em **4 s** | se regressar ameaça, reverte sem reiniciar |
| nevoeiro → chefe | ambos atravessaram, carregamento acabou e o chefe activa | P1 no evento de intro | música da zona sai em 1 s |
| fase 1 → fase 2 | evento autoritativo do grito | stinger de 2 s + P2 no compasso marcado | P1 fecha no mesmo marcador |
| morte do jogador | HP zero confirmado | música corta no golpe fatal; **0,5 s silêncio**, `st_death` | depois regressa no respawn, não durante fade |
| morte do chefe | HP zero/recibo calculado | faixa fecha; queda + **0,5 s**, `st_victory` | exploração regressa depois do stinger/recompensa |
| descoberta | flag permanente confirmada | `st_discovery` sobre a zona | omite se prioridade superior estiver activa |

Subchefes **não ganham música própria**, como manda o [`61`](61-arenas-de-chefe.md): usam a tensão normal da zona e podem ser abandonados sem uma faixa a anunciar “arena”. Guardiões e Ultra têm música dedicada na ficha.

### Co-op e carregamento

- o anfitrião replica `music_state`, `transition_event_id` e tempo musical; não transmite áudio;
- cada máquina toca ficheiros locais e entra no compasso correcto, com erro-alvo **≤ 50 ms**;
- jogador atrasado não reinicia a faixa para o outro; faz fade de 250 ms para a posição corrente;
- a porta pode pré-carregar streams, mas nenhuma música de chefe soa antes de ambos recuperarem controlo;
- perder o convidado não reinicia a música nem a fase; perder anfitrião acaba a sessão como no [`19`](19-rede.md).

A música nunca é a única notícia de alerta, fase, morte, vitória ou descoberta — corpo, HUD e mundo declaram o mesmo estado, conforme o [`62`](62-acessibilidade-auditiva.md).

---

## 5. Ambiente — base, detalhe e eventos raros

Ambiente não é uma faixa musical. Cada zona declara quatro camadas com posições e intervalos:

| Camada | Regra | Fatia 1: Brumal | Fatia 1: Toca |
|---|---|---|---|
| **base estéreo** | 1 loop largo, sem evento mecânico | vento filtrado na copa | ar/rumble de caverna, sem subgrave que coma ataques |
| **material local** | até 2 loops 3D por sector | folhagem, água distante quando existir | gotas, corrente distante |
| **one-shots** | 2 emissores, intervalo sem relógio audível | ramo/folha/fauna a cada **20–60 s** | gota/rocha/creak a cada **12–40 s** |
| **estado** | entra por flag real, não por música | vento muda junto à queda, mas bordo continua visual | porta, mecanismo, água e corrente seguem objecto |

Semente do one-shot deriva de zona+sessão e não de frame; a distribuição impede repetir o mesmo ficheiro duas vezes seguidas. Evento raro não toca dentro de **1,5 s antes/depois** de uma telegrafia na mesma direcção, para não criar falso ataque.

### O ambiente não mente

- não põe passos de inimigo aleatórios sem haver entidade nessa direcção;
- não usa rugido, arma, sino de parry ou alerta como decoração;
- fauna decorativa fica fora da banda/timbre reservado aos sinais de combate;
- vento/água de precipício nasce do bordo real, mas a faixa visual do [`61`](61-arenas-de-chefe.md) continua suficiente sem som;
- reverb da Toca recebe impactos/ambiente; `GameplayInfo` mantém ataque curto e direcção legível, com envio mínimo.

Cada novo bioma do [`49`](49-biomas.md) ganha uma ficha: loop base · 2 materiais · 3 one-shots · silêncio característico · o que **nunca** usa por colidir com inimigo/elemento. Sem a ficha, não se copia Brumal e muda o pitch.

---

## 6. A mistura — informação tem via própria

### Buses internos

```text
Master
├─ GameplayInfo   # ataque, projéctil, alerta, estado e coordenação
├─ Impact         # golpe, parry, bloqueio, foley e mundo
├─ Voice          # jogador, NPC e voz co-op
├─ UI
├─ Music
└─ Ambience
```

Na interface, `GameplayInfo` + `Impact` continuam debaixo do slider **Efeitos** para não criar um painel técnico. Internamente ficam separados para a atmosfera poder baixar sem alterar a telegrafia. Todos os sliders podem ir a zero; o evento continua a alimentar o renderer do [`62`](62-acessibilidade-auditiva.md).

### Prioridade e reserva

| Prioridade | Vozes |
|---:|---|
| **0 — nunca cortar dentro do alcance** | `GameplayInfo`: ataques, projécteis, alerta, parceiro |
| **1** | golpe no jogador, parry, guarda/postura partida, fala crítica |
| **2** | voz humana/co-op, impactos causais próximos |
| **3** | passos e foley próximos, UI |
| **4** | one-shots de ambiente, impactos distantes |
| **5** | detalhes decorativos |

Tecto da fatia: **24 vozes SFX**, com **8 reservadas** a `GameplayInfo`. Música (máximo 2 streams durante crossfade) e 3 loops de ambiente têm players próprios. Ao saturar: corta 5→4→3; nunca substitui um cue informativo por outro mais distante.

### Ducking que protege o ataque

Quando começa um `GameplayCue` capaz de afectar o jogador:

- `Music`: **−8 dB**;
- `Ambience`: **−6 dB**;
- ataque **20 ms**, sustentação até ao compromisso/último tick, libertação **250 ms**;
- cues sobrepostos prolongam o envelope, não acumulam −8−8−8;
- `GameplayInfo`, impacto do jogador e voz do parceiro não baixam com ele.

Isto substitui o −4 dB genérico do [`21`](21-arte-render.md). Composição ainda reserva pausas e a banda média aos sinais: ducking é cinto de segurança, não licença para uma parede de som.

**Abrir Pausa/Inventário não pára o mundo.** Baixa só `Music` e `Ambience` em −8 dB; `GameplayInfo`, `Impact` e `Voice` continuam normais. A regra antiga “baixa tudo menos UI” esconderia precisamente o golpe que continua a acontecer.

### Espaço e normalização

- sinais de entidade são mono/3D e seguem a origem do `GameplayCue`; música/UI ficam 2D;
- variação de pitch **±3% passos / ±5% impactos**, nunca em telegrafia cuja identidade depende do tom;
- distância e oclusão não tornam inaudível um ataque que ainda pode acertar; o alcance informativo do [`62`](62-acessibilidade-auditiva.md) manda;
- master limita a **−1 dBTP**; nenhum asset entra sem medir pico e ganho no contexto;
- não se comprime o bus informativo até destruir ataque/compromisso; clipar é falha, não “impacto”.

---

## 7. Dados e código que impedem regressão

Cada entrada de `audio_catalog.json` declara:

```text
id · source_file · license_id · hash
bus · spatial · max_distance_m · gain_db · pitch_range
loop · stream · variations · max_polyphony · priority
informative · gameplay_cue_type · visual_cue_id
where · state · _estado
```

Guardas:

1. `informative: true` exige `GameplayInfo`, origem e `visual_cue_id` válido;
2. `Music`/`Ambience` não podem ser `informative`;
3. loop exige teste de costura; stream é obrigatório para música/base de ambiente;
4. `Preview.ogg` e qualquer ficheiro fora do catálogo não entram no export;
5. variante não repete até esgotar a bolsa; pitch/gain ficam nos limites da família;
6. ataque da ficha do [`38`](38-ataques-e-honestidade.md) aponta para cue próprio, nunca `telegraph` genérico;
7. material de impacto é par `arma × alvo`, não nome fixo no código do inimigo.

`AudioDirector` recebe eventos; `MusicDirector` gere estados; `GameplayCue` do [`62`](62-acessibilidade-auditiva.md) produz áudio + visual. Nenhum inimigo chama directamente `AudioStreamPlayer` e inventa prioridade local.

---

## 8. Como se prova que não tapa o jogo

### Automatizado

- inventário reconhece exactamente 181 candidatos; catálogo runtime só contém os aprovados, todos com ID/fonte/licença/bus, e `Preview` fica excluído;
- todo ataque tem cue áudio + visual e nenhum chama o `telegraph` genérico em conteúdo final;
- teste de estado percorre menu→zona→combate→chefe P1→P2→vitória/morte sem reinício indevido;
- stress com 32 pedidos simultâneos conserva todos os `GameplayInfo` em alcance e respeita 24 vozes SFX;
- sliders a zero não desligam eventos/visuais; Pausa baixa só música/ambiente;
- dois peers recebem o mesmo evento de fase e convergem em **≤ 50 ms**;
- loop roda 10 vezes sem salto, silêncio extra ou crescimento de memória.

### Ouvir e jogar

No cenário mais ruidoso da fatia — dois jogadores, 3 inimigos, tensão de Brumal, 3 camadas de ambiente, impactos e voz:

1. 20 cues aleatórios: origem + família de resposta + compromisso acertados em **≥ 18/20** com mix normal;
2. repetir com música a 100% e ambiente a 100%: resultado não pode cair mais de **1 cue**;
3. executar a resposta escrita 10× por ataque: som ligado e som a zero passam **10/10**, como no [`62`](62-acessibilidade-auditiva.md);
4. comparar morte/erro com atmosfera ligada/desligada segundo o [`63`](63-como-se-afinam-os-numeros.md); se a diferença vem de mascaramento, baixa arranjo/bus antes de alongar ataque;
5. Mateus/Rico escolhem à cegas as 3 variações de parry e rejeitam as que se confundem com armadura/porta.

### Desempenho

- SFX seleccionados e descodificados: **≤ 32 MiB** residentes;
- música + base ambiente em streaming; no máximo 2 streams musicais em crossfade;
- mistura/directores: **≤ 0,30 ms CPU p99** no cenário ruidoso;
- zero leitura de disco no primeiro compromisso de chefe — a porta pré-carrega o necessário;
- working set e frame global continuam dentro de 2,5 GB / 16,7 ms na máquina do Rico.

---

## 9. As quatro perguntas do fio solto

### 1. Como é que o jogador usa isto?

Joga; o director muda música pelo estado real e cada superfície/objecto escolhe a família certa. Nas opções, Geral/Música/Efeitos/Ambiente/Vozes vão a zero separadamente. Não há “modo acessível” com mistura diferente: o canal visual equivalente existe sempre.

### 2. Como é que se prova que funciona?

Catálogo e stress provam prioridade; transições e loops têm testes; 20 cues no pior mix provam leitura; o banco sem som prova que atmosfera nunca virou requisito. Ganhos só ficam confirmados pelo ciclo do [`63`](63-como-se-afinam-os-numeros.md).

### 3. De onde vêm a arte e o som?

181 SFX vêm dos dois packs Kenney CC0 já creditados; 12 sintetizados continuam como baseline/fallback de protótipo. Música, loops de vento/folhagem/caverna, carne, vozes e criaturas **não existem** e precisam de composição, gravação própria ou asset licenciado registado no `CREDITS`. Recomendo música original em stems; os donos escolhem quem a faz.

### 4. Quanto custa na máquina do Rico?

24 vozes SFX, 8 reservadas à informação, 2 streams de música em transição, até 3 loops de ambiente, ≤ 32 MiB SFX e ≤ 0,30 ms de mistura/directores. A porta pré-carrega boss; ambiente decorativo é o primeiro a ser cortado quando o orçamento aperta.

---

## O que fica por construir/produzir

| | Estado |
|---|---|
| `audio_catalog.json`, buses e directores | 🔴 inexistentes; hoje todos os 12 sintetizados usam `Master` |
| importar/seleccionar Kenney | 181 candidatos em `art/`, zero em `game/`; ouvir, catalogar e copiar só os aprovados |
| `GameplayCue` e sons por ataque | buraco já aberto no [`62`](62-acessibilidade-auditiva.md); retirar `telegraph` genérico |
| seis peças + três stingers | 🔴 zero ficheiros; quem compõe/selecciona continua pergunta dos donos |
| ambiente Brumal/Toca | 🔴 zero loops; packs só cobrem alguns one-shots |
| vozes, orcs, carne e magia própria | conteúdo a gravar/adquirir; não fingir com `Preview.ogg` |

## Ligações

[`16-chefes.md`](16-chefes.md) · [`19-rede.md`](19-rede.md) · [`20-interface.md`](20-interface.md) · [`21-arte-render.md`](21-arte-render.md) · [`22-assets.md`](22-assets.md) · [`38-ataques-e-honestidade.md`](38-ataques-e-honestidade.md) · [`49-biomas.md`](49-biomas.md) · [`61-arenas-de-chefe.md`](61-arenas-de-chefe.md) · [`62-acessibilidade-auditiva.md`](62-acessibilidade-auditiva.md) · [`63-como-se-afinam-os-numeros.md`](63-como-se-afinam-os-numeros.md) · [`99-perguntas-abertas.md`](99-perguntas-abertas.md)
