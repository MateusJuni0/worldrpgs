# ESTADO — o que é verdade hoje

**Actualizado: 01-08-2026, Tarefa 5 concluída.** Este é o ficheiro que se lê primeiro. O [`SPEC.md`](SPEC.md) diz **onde** as coisas estão; este diz **em que pé** estão e **por que ordem** se pega nelas.

> **Porque existe:** a spec tem **75 documentos** e ~50 decisões. Onze dos documentos de execução são **anteriores** a decisões que os mudam. Sem um sítio que diga o que vale hoje, qualquer agente constrói sobre o que já foi substituído.

---

## 1. ⚠️ O jogo existe, e até hoje vivia num sítio só

**O protótipo joga-se.** Combate fiel ao WP1 + correcções canónicas do [`70`](spec/70-fecho-dos-sistemas-de-combate.md) (i-frames 5–23 inclusivos, **317 ms**, parry 8/8/40, empunhadura de 12 f, as 5 armas com frames exactos), lanceiro e brutamontes com telegrafia, 3 magias executáveis, o Vorgar com 2 fases, frasco de cura, 3/6 habilidades de classe no runtime e 17 sons sintetizados. **9531 auto-testes contra a spec.** Godot 4.7.1, renderer Mobile, greybox a **416 fps na máquina do Rico**. Cinco esqueletos UAL em fullscreen mantêm 60,0 fps médios e pior 19,414 ms, mas p99 real **18,323 ms > 16,67 ms**; continua a falhar estabilidade. Detalhe no [`74`](spec/74-fecho-da-revisao-2.md) e no [`artefacto`](medicoes/animacao-esqueleto-2026-08-01.json).

⚠️ **E até 31-07 vivia apenas no disco do Rico**, num repositório local `worldrpgs-game` que nunca chegou ao GitHub. Sem cópia. Sem revisão possível. Um disco avariado e perdia-se tudo.

### `[DECIDIDO]` (Mateus, 31-07-2026) — o código passa a viver aqui

**Neste repositório, ao lado da spec.**

O plano antigo ([`spec/23-tecnico.md`](spec/23-tecnico.md), [`spec/24-plano.md`](spec/24-plano.md)) previa um repositório separado. **Foi escrito quando este era só de especificação, e deixou de fazer sentido:**

| Razão | |
|---|---|
| ⭐ **A regra do "mesmo PR"** | o [`CLAUDE.md`](CLAUDE.md) manda que, se o código e a spec discordarem, **a spec muda primeiro, no mesmo PR**. Isso é **impossível** em dois repositórios |
| **Revisão** | o Claude revê o que está aqui. O que está fora não existe para a revisão |
| **Cópia de segurança** | um repositório é a cópia. Um disco não é |
| **Um sítio** | o Rico e o Fable já trabalham aqui |

**Estrutura:** o código vai para `game/`. A spec fica onde está.

---

### ✅ Feito — e verificado por mim, não pela palavra de ninguém

O código está em [`game/`](game/) desde 31-07 (PR #13), com os 8 commits originais preservados por `git subtree` — confirmei um a um que são ancestrais da `main`.

```
$ godot --headless --path game/ scenes/selftest.tscn
=== 9531 passaram, 0 falharam ===
```

## 1b. ⭐ O que temos, em números

**Esta tabela é o retrato do projecto.** Falta conteúdo, mas a Revisão 2 provou que também faltam **interfaces executáveis entre catálogos e sistemas**.

| | Temos | A spec promete | Falta |
|---|---|---|---|
| Documentos de spec | **76** em `spec/` | — | — |
| Código e dados | **18** ficheiros `.gd` · **17** catálogos JSON | — | — |
| Testes | **9531, todos a passar** | — | — |
| Imagens curadas | **54** fora dos packs: 32 conceitos · 20 ícones · menu · céu | — | só itens futuros, travados por `Fatia 1?` |
| **Armas** | **120 fichas** · 8 famílias · 88 golpes ([`68`](spec/68-catalogo-de-armas-armaduras-e-aneis.md)) | 120 | 5 executáveis/com imagem; 115 esperam fatia/runtime |
| **Armaduras** | **68 peças** · 9 slots · 4 estados de carga · **11 ícones** ([`68`](spec/68-catalogo-de-armas-armaduras-e-aneis.md), [`70`](spec/70-fecho-dos-sistemas-de-combate.md)) | 68 | 57 esperam `Fatia 1?`; equipar é WP11 |
| **Anéis** | **70 fichas únicas** · 8 eixos · 2→10 dedos ([`68`](spec/68-catalogo-de-armas-armaduras-e-aneis.md)) | 70 | UI/save e imagens futuras |
| **Feitiços** | **53 fichas · 3 executáveis/Fatia 1** ([`66`](spec/66-catalogo-de-magia.md)) | catálogo largo | 50 renderers/comportamentos e roda |
| **Inimigos** | **33 tipos comuns · 100 ataques comuns · Vorgar migrado** ([`67`](spec/67-catalogo-do-bestiario.md)) | 12 raças + 61 chefes | modelos/animações dos 31 fora da Fatia 1 · chefes WP7 |
| Habilidades de classe | 6 fichas com compromisso; 3 no runtime | 6 | executar Eco, Entre Sombras e Julgamento no M2 |
| **Mundo / biomas** | **12 fichas · 21 ligações · 24 círculos · 12 atalhos · 30 portas** ([`69`](spec/69-catalogo-do-mundo.md) + `game/data/world.json`) | 12 | só Brumal é Fatia 1; mapa/streaming e 11 zonas não estão no runtime |
| **Raças** | **12 fichas + mímico** ([`50`](spec/50-racas.md) + `game/data/races.json`) | 10–15 | ✅ volta 2 |

⭐ **E a instrução que daí sai:** o motor é data-driven — o `game_data.gd` recusa arrancar se os dados divergirem da spec. **Escrever o catálogo não é documentar o jogo: é construí-lo.** O catálogo escreve-se em `spec/` **e** em `game/data/*.json`, no mesmo PR.

## 1c. ✅ A fundação de saves existe

O [`59`](spec/59-saves.md) define e o `SaveSystem` implementa: estado separado de personagem/mundo ligado ao `GameData`, autosave sem botão de recarregar, escrita `.tmp` + rename, geração `.bak`, checksum, recuperação de corrupção e migrações de formato. **19 verificações novas** cobrem round-trip, interrupção, corrupção silenciosa e v0→v1.

⚠️ **Isto desbloqueia, mas não finge que todos os clientes já existem:** a morte de inimigo já publica almas, item, índice do baralho e recibo numa geração atómica. Exploração do mapa, equipamento/UI, mancha definitiva de morte e progresso de chefe ainda chamam a mesma fronteira quando forem construídos. A regra de progresso de chefe no mundo alheio continua `[TENSÃO]`, pergunta 32 do [`99`](spec/99-perguntas-abertas.md).

## 1d. ✅ A arena deixou de ser um círculo vazio

O [`61`](spec/61-arenas-de-chefe.md) fecha a gramática espacial dos chefes: tamanho por camada, obstáculos com função, dois refúgios temporários, bordo letal anunciado antes do empurrão, porta de nevoeiro como carregamento sincronizado e duas perguntas próprias de co-op — **SEPARAR** e **JUNTAR**.

**O sistema está escrito; o conteúdo não é fingido:** Vorgar é a primeira instância e precisa de fechar a sua ficha no greybox. As outras **12 arenas seladas** nascem com os 11 guardiões restantes e o Ultra; os 12 subchefes recebem bolsas de combate abertas no mundo, sem porta nem música, como manda o [`53`](spec/53-chefes-ritmo-e-o-mago-forte.md).

⚠️ A escala de PV a dois continua `[TENSÃO]`, pergunta 24 do [`99`](spec/99-perguntas-abertas.md). O desenho espacial não a decide.

## 1e. ✅ Ouvir deixou de ser requisito para jogar

O [`62`](spec/62-acessibilidade-auditiva.md) corrige a tranca criada pelo [`38`](spec/38-ataques-e-honestidade.md) e pela primeira pessoa: cada som informativo passa a ser uma apresentação de um evento que também produz **forma, direcção, timing e duração visuais equivalentes**. Ataques, projécteis, áreas, alerta, estado do jogador, co-op, segredos e confirmações têm substituto próprio; não se usa uma legenda genérica em combate.

**A regra entrou na fundação agora:** a ficha de ataque passa de 11 para **12 colunas**, com `sinal_visual_equivalente`. O áudio pode ir a zero. O perfil é local e a roda JUNTAR/ESPERA/AJUDA/OLHA mantém coordenação mínima sem voz.

✅ **O canal já é runtime:** o [`67`](spec/67-catalogo-do-bestiario.md) introduziu o emissor/renderer `GameplayCue`, cinco famílias sonoras e a migração dos ataques da Fatia 1/Vorgar. O banco jogado sem som e a afinação de tamanho/opacidade continuam WP15B; já não são uma ausência de implementação.

## 1f. ✅ “Valida-se a jogar” já tem método

O [`63`](spec/63-como-se-afinam-os-numeros.md) completa o [`28`](spec/28-testes.md) sem o duplicar: separa guardas de valores afináveis, fixa a ordem **técnica → leitura → resposta → recompensa → custo → duração → co-op → progressão**, atribui papéis a Mateus/Rico/agentes, limita a primeira alteração e exige A/B de uma variável com baseline e artefacto.

**Um valor só fica confirmado** depois de três sessões comparáveis, protocolo do `28`, ausência de regressão e preferência dos dois donos. “Morro sempre no mesmo ataque” olha primeiro para leitura, tracking/hitbox, rota e controlo; dano é o último suspeito, nunca se oferece mais i-frames por reflexo.

⚠️ A verificação do código encontrou o buraco operacional: CSV sempre ligado, `tp arena_vorgar`, comandos, overlays e latência artificial estão escritos no `23`/`28`, mas **não existem**. A afinação reproduzível espera pelo `TuningRecorder`; os 9531 auto-testes provam coerência, não feel.

## 1g. ✅ A primeira escolha já não fecha o resto do jogo

O [`64`](spec/64-criacao-de-personagem.md) fecha o percurso **classe → aspecto/voz → nome → revisão → save**. As seis classes são presets que escolhem os +14 pontos, kit, verbo, técnica e futuro traço iniciais; nunca bloqueiam arma, magia, atributo, espólio, conteúdo ou composição co-op. Os cartões têm de dizer isso à vista.

O aspecto é finito e baseado no que está em `art/models/`: 2 corpos, 4 tons, 0+6 cabelos, 6 cores, 2 sobrancelhas, 6 acentos e 2 vozes, todos com a mesma cápsula e frames. Nome aceita 1–24 grafemas Unicode seguros e nunca serve de ID.

⚠️ **Desenho não é runtime:** hoje só existe a troca F6 do greybox. Faltam o ecrã, `appearance.json`, prova de retarget/encaixe dos kits, os dois conjuntos de voz e o **save v2 com migração do v1 aprovado**.

## 1h. ✅ A atmosfera já sabe quando se calar

O [`65`](spec/65-musica-e-ambiente.md) auditou os **182 `.ogg`**: 181 efeitos curtos utilizáveis (77,5 s, 1,68 MiB) + um `Preview.ogg` excluído; **zero música e zero loop de ambiente**. Mapeia cada família Kenney a superfície/material/acção e mantém os **17 sons sintetizados** apenas como baseline do protótipo — cinco são agora famílias informativas do `GameplayCue`.

A fatia pede 6 peças + 3 stingers. O `MusicDirector` entra por estado autoritativo, não por proximidade; não denuncia emboscadas, sincroniza fases co-op e corta na morte. `GameplayInfo` tem bus e 8 vozes reservadas: cada cue baixa música −8 dB e ambiente −6 dB, enquanto menus baixam só atmosfera porque o mundo não pára.

⚠️ **Desenho não é conteúdo:** `Sfx` ainda envia tudo para `Master`; não há catálogo, buses/directores, música, loops nem vozes. Os ataques têm cue ID/descrição próprios e cinco perfis sintetizados, mas os packs continuam biblioteca em `art/`, não áudio de produção importado em `game/`.

## 1i. ✅ O WP4 deixou de ser um catálogo de três linhas

O [`66`](spec/66-catalogo-de-magia.md) fecha **53 feitiços** em quatro escolas: 10 Feitiçaria, 9 Milagre, 9 Piromancia e os 25 da Escola vermelha (os 22 do [`52`](spec/52-mago-do-mal.md) herdados + as três formas que faltavam). As **12 formas** estão usadas, nenhuma casa da grelha de verbos ficou vazia e cada ficha declara custo, instrumento/escola, contacto, vector de fuga, falha espacial, som, sinal visual, descrição visual, `Fatia 1?` e melhoria 0…5.

O protótipo trocou cargas por **mana**: `60 + 4×maior(Int, Fé)` até 35; a Escola vermelha escala pelo **menor**. `M` inicia a meditação de 40 s, há duas tentativas por descanso, a mana parcial sobrevive à interrupção e artes de arma gastam mana. Dardo, Ruína e Égide continuam os três feitiços da Fatia 1 e ligam os ícones já aprovados no manifesto.

⚠️ **Catálogo não é renderer:** os outros 50 feitiços ainda não executam; a roda/edição de favoritos e os instrumentos além do cajado também não existem. O save v1 anterior a esta mudança pode conservar a chave histórica `sabedoria`; a migração deve entrar junto do save v2 do criador, sem consumir uma versão só para o greybox.

## 1j. ✅ O WP6 já tem tamanho, perguntas e orçamento

O [`67`](spec/67-catalogo-do-bestiario.md) fecha **33 tipos comuns** (dentro da conta 30–36 do [`50`](spec/50-racas.md)), **100 ataques comuns** e os cinco de Vorgar migrados. Cada ficha declara massa, almas, descrição visual, Fatia 1 e dez cartas sem reposição. Cada ataque compilado traz contacto instantâneo/móvel/persistente, 1–2 dos nove vectores, compromisso, seguimento `180→30→0°/s`, som próprio e equivalente visual de seis campos.

As 12 zonas têm população de referência e orçamento recalculado pelo teste: **390→2 050 almas** na primeira limpeza e exactamente ×10 no limite recompensado. `GameplayCue` apresenta a mesma informação por som e geometria/glifo/bordo; padrões de IA e baralhos aceitam semente. Os três conceitos imediatos — lanceiro, brutamontes e Vorgar — foram auditados e reutilizados; as outras 31 fichas ficam sem imagem até `Fatia 1?` mudar.

✅ O WP9 que este catálogo exigia foi entregue no [`72`](spec/72-materiais-consumiveis-e-economia.md): morte compra e grava carta/recibo, 40 materiais e 15 consumíveis canónicos resolvem. Os 17 tokens antigos continham uma Brasa repetível ilegal e uma grafia duplicada, ambas corrigidas. Os 31 inimigos futuros continuam sem modelo/animação/hitbox; a pergunta 29 só decide o destinatário co-op e não foi escolhida por Mateus/Rico.

## 1k. ✅ O WP5 deixou de ser cinco armas e uma promessa de anéis

O [`68`](spec/68-catalogo-de-armas-armaduras-e-aneis.md) fecha **120 armas, 68 armaduras e 70 anéis**. As oito famílias têm os onze golpes materializados (88 fichas), e cada item desses três catálogos traz `descricao_visual` + `Fatia 1?`. A Tarefa 5 fechou clientes/afinidades dos 70 anéis, bloqueou honestamente as 57 armaduras futuras e migrou as cinco cartas `acessorio:*` para anéis/consumível existentes.

A melhoria numérica foi revogada: base + seis níveis abrem postura/moveset, arte, troca de escala ou conversão elemental, sem subir dano base. Veneno, sangramento e queimadura têm barra, decaimento, disparo, saída, som/visual e regras simétricas. A proposta do Assassino passa os três guardas com Passo Mudo, Corte Alternado, Cruz Carmesim e Entre Sombras, mas **continua à espera da confirmação do Mateus** (pergunta 37).

Os **11 ícones de armadura da Fatia 1** foram gerados, curados para alfa real e registados no manifesto; os cinco ícones de arma são reutilizados. Catálogo não é runtime: sete golpes, estados, offhand, equipar, votos e dedos adicionais continuam explicitamente em M2/WP11.

## 1l. ✅ O WP8 deixou de ser seis caixas numa linha

O [`69`](spec/69-catalogo-do-mundo.md) fixa a leitura **antes** da topologia: vista inclinada a ~40°, apenas terreno percorrido, andar actual realçado e restantes esbatidos. Não decide a pergunta dos donos “mapa por zona ou do mundo inteiro”. Depois fecha **12 zonas de 8–12 min**, uma rede compacta com **21 ligações e diâmetro de três travessias**, 12 círculos horizontais, 12 verticais e 12 atalhos que se abrem pelo interior.

Cada zona tem curva de 12–20 comuns, 3–5 elites, 2–3 nomeados, subchefe, guardião, 2–3 descansos, dungeon com duas pistas, ameaça com saída e geometria que não depende de nadar/escalar/saltar. As **30 portas de história** cumprem o alvo 24–36: 2–3 por bioma, cada uma com razão visível para não parecer bug.

Os 12 conceitos de bioma já estavam arquivados; Brumal reutiliza também `brumal-caminho` e `toca-entrada`, portanto o bloco não inventou produção visual nova da Fatia 1. Catálogo não é nível: hoje só há o greybox curto de Brumal; topologia, streaming, mapa, atalhos e as outras onze zonas continuam por implementar e medir.

## 1m. ✅ O núcleo de combate deixou de contradizer a auditoria

O [`70`](spec/70-fecho-dos-sistemas-de-combate.md) passa a ser a autoridade das correcções: parry **8/8/40**, curvas diferentes por atributo, Carga como oitavo atributo, queda fatal absoluta aos **20 m**, quatro estados de carga incluindo sobrecarga, NG+ com PV/dano separados, contra-ataque só em perfuração, instabilidade separada e bloqueio físico de 100% fora do piso corporal.

`T` ou `Y/triângulo` muda a empunhadura em 12 frames interrompíveis. `hook_pull` atravessa 40% do escudo e `slam` custa ×2,5 stamina de guarda no runtime. O bestiário liga ainda duas largadas, ramo de combo, falsa recuperação, castigo de cura, fingir morte e corpo duro a fichas concretas. Estes ramos avançados estão especificados e testados como dados; animação/IA completa e ressalto geométrico continuam construção M2 conhecida.

Queda, ciclos, ressurreição partilhada e Brasa têm contrato executável em `progression.json`. `Fôlego Roubado` já não depende de uma stamina inimiga inexistente. **9531/9531** testes passam no fecho corrente.

## 1n. ✅ Os vazios entre comuns, chefes e recompensa estão fechados

O [`71`](spec/71-encontros-nomeados.md) fecha **36 encontros nomeados, exactamente três por zona**. Cada um reutiliza uma ficha comum, recebe multiplicadores curtos, exactamente um ataque extra com tell mensurável e uma carta garantida. Não cria esqueletos, arenas, barras ou música de chefe; quando o tipo-base entrar numa fatia, a dívida marginal é só um ataque/colocação.

O [`72`](spec/72-materiais-consumiveis-e-economia.md) fecha a economia prometida pelos baralhos: **40 materiais, 15 consumíveis canónicos**, curva cúbica com marcos exactos, receitas regionais partilhadas por arma/feitiço e enviesamento marcial/arcano apenas no enchimento. A transacção local é idempotente e publica almas, item, índice e recibo na mesma geração atómica do save; `Enemy.died` já a chama e apresenta a recompensa.

⚠️ A política de destinatário em co-op continua a pergunta 29 do [`99`](spec/99-perguntas-abertas.md). A infraestrutura recebe um destinatário explícito e, por isso, não decidiu à socapa se cai uma ou duas cartas.

## 1o. ⭐ Tarefa 5 — os buracos da Revisão 2 têm contrato; `ready` ainda não

O cruzamento automático carrega os **17 JSON** e verifica **2791 referências/contratos, com 0 erros e 0 allowlists de dívida**. `acessorio:*` é erro; os 24 slots de guardião/subchefe resolvem ou dizem `blocked_owner_q52`; instrumentos, anéis e afinidades só aceitam IDs/clientes catalogados.

O [`74`](spec/74-fecho-da-revisao-2.md) fecha números para projécteis, 12 formas, seis compromissos/Eco, percepção e ameaças; dá mecanismo aos 12 feitiços incompletos; bloqueia melhorias/escudos sem decidir 41/43; e preenche por papel as 18 perseguições. O auto-teste simula a fuga até ao leash. As perguntas 41 e 43–56 continuam no [`99`](spec/99-perguntas-abertas.md) com proposta, recomendação e estado de execução seguro.

A investigação de animação separou custo de carga e apresentação. Sem VSync, cinco UAL dão p99 **5,714 ms**; com VSync/fullscreen, p99 real **18,323 ms** e pior **19,414 ms**. Portanto animação/import/shader/culling não são o estrangulamento medido; o pacing Windows/driver é. Fullscreen reduziu os picos e fica por omissão, mas o gate p99 continua vermelho. Artefacto em [`medicoes/animacao-esqueleto-2026-08-01.json`](medicoes/animacao-esqueleto-2026-08-01.json).

**O que ficou por fazer de propósito — e porquê:**

| Não está feito | Porque não se finge completo |
|---|---|
| runtime dos sete golpes/estados/artes; 50 feitiços; favoritos; criador/save v2; directores/áudio; mundo/streaming/mapa | é produção M2/WP8/WP11/WP12/15, já com autoridade e prova de saída no `73`; construir tudo seria outra fase, não “fechar spec” |
| retarget KayKit/Quaternius dentro do nível completo | o spike mediu o custo do esqueleto, mas não prova encaixe, IA, efeitos e duas perspectivas juntos |
| `TuningRecorder` e três sessões de feel | 9531 testes provam coerência; não provam prazer nem confirmam os baselines `[CODEX]` do `74` |
| identidades/fichas dos 11 guardiões restantes e do Ultra; música final e narrativa | dependem das sete respostas do [`26`](spec/26-narrativa.md) e da pergunta 34; inventá-las seria decidir autoria dos donos |
| políticas co-op, mapa, Assassino, invocados, vendedores, melhorias/Voto, escudos elementais, streaming e conteúdo futuro | perguntas 24, 28, 29, 32 e 35–56 continuam em [`99`](spec/99-perguntas-abertas.md); o `74` só lhes dá baseline/bloqueio seguro, não decide `[TENSÃO]` |

Portanto, **não se declara o jogo completo nem `ready`**. Os contratos pedidos estão coerentes e verdes; frame pacing, gate integrado 2+5, streaming e orçamento de actores ainda precisam de prova/decisão.

## 2. Decisões que mudaram documentos de execução antigos

**~35 decisões, das quais estas são as que mais mudam trabalho já escrito.** A lista completa e por ordem está no [`DECISOES.md`](DECISOES.md).

| Decisão | Onde está | O que atinge |
|---|---|---|
| ⭐ **Piso de 30%** — nenhuma defesa reduz um golpe abaixo disso | [`39`](spec/39-estudo-profundo.md) §1 | WP2 |
| ⭐ **Curvas por atributo** — Vida 20/50 · Stamina 20/40 · Constituição 25/50 · mana 35 · dano 40/60 · Carga 30/50/70 | [`70`](spec/70-fecho-dos-sistemas-de-combate.md) §1 | WP2, WP9 |
| ⭐ **Interrupção e hiper-armadura** — sem isto armas lentas não existem | [`39`](spec/39-estudo-profundo.md) §4, [`41`](spec/41-estudo-armas-e-golpes.md) §4 | WP1, WP5 |
| ⭐ **Contra-ataque só em perfuração + instabilidade separada** | [`70`](spec/70-fecho-dos-sistemas-de-combate.md) §3 | WP1 |
| ⭐ **Sem slots: mana sem regeneração + meditação; artes gastam mana** | [`54`](spec/54-mana-meditacao-e-tracos-de-classe.md), [`66`](spec/66-catalogo-de-magia.md) | WP4, WP5, WP11 |
| ⭐ **Espólio garantido — baralho de 10 sem reposição** | [`40`](spec/40-decisoes-espolio-magia-inventario.md) §3, [`43`](spec/43-estudo-espolio-inventario-mundo.md) §2 | WP6, WP7, WP9 |
| ⭐ **Descanso recarrega o mapa · 10 reaparições · não se farma** | [`40`](spec/40-decisoes-espolio-magia-inventario.md) §1 | WP6, WP9 |
| ⭐ **Feitiços únicos + melhoria de feitiços em 3 eixos** | [`40`](spec/40-decisoes-espolio-magia-inventario.md) §12–13, [`42`](spec/42-estudo-magia.md) §6 | WP4 |
| ⭐ **A magia é a área mais vasta do jogo** | [`40`](spec/40-decisoes-espolio-magia-inventario.md) §6, [`42`](spec/42-estudo-magia.md) | WP3, WP4 |
| ⭐ **Armas por família, não por classe** | [`35`](spec/35-estudo-referencia.md) §1, [`41`](spec/41-estudo-armas-e-golpes.md) §2 | WP5 |
| ⭐ **O contrato de honestidade** — 5 cláusulas, e o teste do rolamento | [`38`](spec/38-ataques-e-honestidade.md) | WP6, WP7, WP15B |
| ⭐ **Toda a zona fecha dois círculos e um atalho por dentro · descanso antes do guardião, não do subchefe** | [`53`](spec/53-chefes-ritmo-e-o-mago-forte.md) §3, [`69`](spec/69-catalogo-do-mundo.md) | WP8 |
| ⭐ **Carregamento por área · a porta de nevoeiro é a barreira** | [`43`](spec/43-estudo-espolio-inventario-mundo.md) §6 | WP14, WP8 |
| ⭐ **Mochila sem limite — só o equipado pesa** | [`40`](spec/40-decisoes-espolio-magia-inventario.md) §9 | WP11, WP5 |
| ⭐ **Controlos configuráveis no jogo** | [`45`](spec/45-controlos-configuraveis.md) | WP11 |
| **Descrição em todo o objecto, colocado por relevância** | [`39`](spec/39-estudo-profundo.md) §12 | WP9, WP13 |
| **10 anéis / ~70 anéis** | [`37`](spec/37-aneis-e-elementos.md) | WP5 |
| **Física: gravidade, queda, balística, empurrão** | [`36`](spec/36-fisica.md) | WP1, WP8 |

---

## 3. ⭐ A ordem, e por que é esta

As fichas de bioma/raça, os catálogos e o alinhamento histórico estão feitos. A cadeia real a partir de amanhã é outra:

```
0. DECISÕES/GATES ─ streaming 50 · orçamento de actores 51 · frame pacing/integrado
        ▼
1. COMBATE SOLO ─ sete golpes/estados/offhand · 6 habilidades · 3 magias da fatia
        ▼
2. EQUIPAR + SAVE + UI ─ kits da fatia · loot garantido · criador · remap/perspectiva
        ▼
3. REDE DA FATIA ─ autoridade · recompensa/save · ressurreição · latência
        ▼
4. BRUMAL COMPLETO ─ rota/atalhos/ameaça · Vorgar · arte/áudio integrados
        ▼
5. GATE INTEGRADO ─ 2+5, duas perspectivas, áudio zero, p99/memória quentes
        ▼
6. PIPELINES FUTUROS ─ validar formas/instrumentos · arena/bolsa · streaming decidido
        ▼
7. UMA ZONA DE CADA VEZ ─ ficha + conteúdo + guardião/subchefe + prova; só depois a seguinte
```

O relatório [`docs/REVISAO-2.md`](docs/REVISAO-2.md) explica as dependências e os ciclos. A regra operacional é: **não produzir 50 feitiços, 11 zonas ou 23 confrontos sobre uma interface ainda implícita**. Fecha-se uma interface com um exemplar jogável, prova-se na máquina do Rico e só então se multiplica o conteúdo.

---

## 3b. ⭐ As lacunas vivem num sítio só

⚠️ **Ficheiro novo: [`LACUNAS.md`](LACUNAS.md)** — tudo o que foi identificado como buraco e **ainda não tem dono**, agrupado pela volta em que deve entrar.

**Porque existe:** as lacunas que o Claude encontra a rever viviam em **comentários de PR**. Um comentário lê-se uma vez e desaparece — e uma lacuna esquecida é uma que se descobre no fim, quando custa dez vezes mais. **Encontrou-se uma lacuna, escreve-se lá no mesmo acto.**

## 4. O que é dos donos, e só deles

Está tudo no [`99-perguntas-abertas.md`](spec/99-perguntas-abertas.md). O [`74`](spec/74-fecho-da-revisao-2.md) não decidiu nenhuma `[TENSÃO]`: 41/43 bloqueiam progressão futura de magia e afinidades de escudo; 44–49 e 52–56 têm baselines ou conteúdo explicitamente indisponível; **50–51 continuam a bloquear `ready`** por memória e actores. Há trabalho independente que pode continuar; produção larga não transforma baseline `[CODEX]` em aprovação dos donos.

**As três que mais mudam o jogo se a resposta for diferente da proposta:**

| # | Pergunta | Proposta em cima da mesa |
|---|---|---|
| **28** | ⚠️ Se a magia faz tudo, como é que o mago não é a classe correcta? | cinco travões — o principal é **quem lança muito, cura pouco** |
| **24** | Chefe a dois: +40% de vida, ou zero? | **+40%, dano igual, e a escala desce quando um morre** |
| **32** | ⚠️ Matar um chefe no mundo do outro muda o teu próprio mundo? | proposta: a recompensa viaja; o estado do mundo não |

E as sete perguntas de narrativa ([`26-narrativa.md`](spec/26-narrativa.md) §3) continuam a precisar de uma gravação — **nome do jogo incluído**.

---

## 5. Os guardas

**Não são para travar ideias. São contra esquecimentos** — o modo de falha real deste projecto é escrever uma coisa boa e deixar-lhe uma ponta solta.

### ⭐ As quatro perguntas do fio solto

> **Nada entra na spec sem responder às quatro.** Uma resposta em branco é uma ponta solta, e pontas soltas descobrem-se seis meses depois, quando custam dez vezes mais.

| | Pergunta | Origem |
|---|---|---|
| **1** | **Como é que o jogador usa isto?** | a regra do Mateus, [`34`](spec/34-catalogo-e-comandos.md) §2 — apanhou 4 lacunas reais à primeira tentativa |
| **2** | **Como é que se prova que funciona?** | um teste, um critério, um número a medir |
| **3** | **De onde vem a arte e o som?** | pack, geração, ou à mão — [`22`](spec/22-assets.md) |
| **4** | **Quanto custa na máquina do Rico?** | Lei 4 — 8 GB e Iris Xe |

### E as regras de sempre

| | |
|---|---|
| **Se o código e a spec discordam** | muda-se a spec primeiro, **no mesmo PR** |
| **Nada por analogia nem de memória** | estuda-se o mecanismo, escreve-se com **números e fonte**, e só depois se decide o nosso |
| **Reservar antes de começar** | pacote **e** número de ficheiro, em [`COORDENACAO.md`](COORDENACAO.md) |
| **Não decidir uma `[TENSÃO]`** | propõe-se e recomenda-se. Decidem os donos |
| **Adjectivos não são spec** | *"combate responsivo"* não é nada. *"0,60 s, invencibilidade nos frames 5–23 inclusivos (317 ms)"* é |
| **Coluna `Fatia 1?`** | em todo o catálogo. É o que trava o escopo |

---

## 6. O risco, dito uma vez

Mundo vasto + 13 chefes + 12 subchefes + 36 nomeados + 12 biomas + 120 armas + 68 armaduras + 70 anéis + 53 feitiços, **feito por duas pessoas e dois agentes**.

**Os donos sabem e decidiram avançar** — e a decisão é deles. Fica registado que a alavanca que dá vastidão sem custar produção são os **círculos e atalhos** ([`39`](spec/39-estudo-profundo.md) §8), e que a coluna `Fatia 1?` é o que impede o catálogo de virar um plano de dez anos.

---

## Onde continuar

| Quem | O quê |
|---|---|
| **Codex** | tarefa 5 concluída — contratos/referências/perseguições fechados no `74`; frame pacing investigado e ainda vermelho; não fazer push |
| **Fable** | não duplicar os catálogos 66/67/68/69; o traçado canónico está no `world.json` |
| **Mateus** | ⏳ **6 instruções do Rico à espera do 👍** — [`DECISOES.md`](DECISOES.md), 31-07 · noite. E os PRs #14, #15, #16 |
| **Donos** | perguntas 24, 28, 29, 32, 34–56 do [`99`](spec/99-perguntas-abertas.md); prioridade técnica 50–51, sem apagar as restantes; e a gravação da narrativa |
| **Claude** | rever o que chega; os 11 ícones de armadura já estão no manifesto |

### As três voltas de 31-07, e onde estão

| PR | Volta | Auto-teste |
|---|---|---|
| [#14](https://github.com/MateusJuni0/worldrpgs/pull/14) | 12 fichas de bioma · fecha as perguntas 4 e 13 | 130 → **160** |
| [#15](https://github.com/MateusJuni0/worldrpgs/pull/15) | 12 fichas de raça · o motor das 24 fichas fica completo | → **194** |
| [#16](https://github.com/MateusJuni0/worldrpgs/pull/16) | famílias, armadura, kits · a tensão da armadura resolvida | → **226** |
