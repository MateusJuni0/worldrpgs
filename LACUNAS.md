# LACUNAS — o que falta, e ninguém está a fazer

**Actualizado: 01-08-2026, Revisão 3.** Mantido pelo **Claude/Codex**. É a lista de tudo o que foi identificado como buraco e **ainda não tem dono**.

> **Porque existe:** as lacunas que eu encontro a rever viviam em **comentários de PR**. Um comentário lê-se uma vez e desaparece — e uma lacuna esquecida é uma lacuna que se descobre no fim, quando custa dez vezes mais.
>
> ⭐ **A regra:** encontrei uma lacuna → escrevo-a aqui **no mesmo acto**. Quando alguém a resolve, risca-se com o commit ao lado.

**Legenda:** 🔴 trava alguma coisa · 🟠 devia entrar na volta indicada · 🔵 quando houver tempo · ⏳ é dos donos, não dos agentes

---

## 🔴 Travam

**Da auditoria independente do Codex** ([`docs/AUDITORIA-CODEX-2026-08-01.md`](docs/AUDITORIA-CODEX-2026-08-01.md), 01-08). ⚠️ **As quatro primeiras são erros meus, não do Fable.**

| | Lacuna | Origem |
|---|---|---|
| ✅ | ~~"Rolar para o lado funciona sempre"~~ **CORRIGIDO 01-08** — cada ataque declara **momento de compromisso, curva de seguimento e vector de fuga**, escolhido de uma lista de 9. E o vector **tem de ser legível na animação** | [`38`](spec/38-ataques-e-honestidade.md) §2b |
| ✅ | ~~A hitbox de 3–6 frames é regra de espada aplicada a tudo~~ **CORRIGIDO 01-08** — três tipos de contacto: **instantâneo** (3–6 frames), **volume móvel** (uma vez por passagem), **volume persistente** (dano por intervalos declarados). A regra unificadora: *a hitbox vive exactamente enquanto o efeito se vê* | [`38`](spec/38-ataques-e-honestidade.md) §1b |
| ✅ | ~~⭐ **A fórmula da estabilidade estava invertida**~~ **CORRIGIDO 01-08** para `dano × (1 − estabilidade/100)`; o broquel já não bloqueia melhor que o escudo grande | [`41`](spec/41-estudo-armas-e-golpes.md) §6 · `3f7fe16` |
| ✅ | ~~O espelho é mais fácil do que o parry~~ **RESOLVIDO 01-08** — janela de 0,25 s, recuperação se falhar, escala pelo instrumento, e recompensa maior quando acerta | [`53`](spec/53-chefes-ritmo-e-o-mago-forte.md) §4 |
| ✅ | ~~O intervalo de 0,20 s entre atacantes não chega~~ **CORRIGIDO 01-08** — conta-se a partir de **quando o jogador pode agir**, não do relógio. E o tecto de 2 agressores passa a garantir **rota de fuga** em vez de um número | [`38`](spec/38-ataques-e-honestidade.md) §3 |
| ✅ | ~~⚠️ **Melhoria de armas (+10%/nível) era a Lei 2 quebrada**~~ **RESOLVIDO 01-08** — base + seis níveis abrem postura/moveset, arte, troca de escala ou conversão elemental; zero aumento de dano base | [`68`](spec/68-catalogo-de-armas-armaduras-e-aneis.md) §3 |
| ✅ | ~~61 chefes = um encontro a cada 30–40 s~~ **RESOLVIDO 01-08** — 13 verdadeiros + 12 subchefes + ~36 nomeados, travessia de 8–12 min, e **30 portas de história catalogadas** para crescer no futuro | [`53`](spec/53-chefes-ritmo-e-o-mago-forte.md) · [`69`](spec/69-catalogo-do-mundo.md) |
| ✅ | ~~**Doze feitiços prometiam efeitos sem mecanismo executável**~~ **RESOLVIDO NA TAREFA 5** — os 12 têm `effect_type`, números, expiração/saída e baseline M2; Chama Faminta usa postura/guarda e Espelho aplica 0,25 s/0,6 s com escala pelo instrumento | [`74`](spec/74-fecho-da-revisao-2.md) §3 · `spells.json` |
| ✅ | ~~**As melhorias dos 53 feitiços fingiam semântica pronta**~~ **FECHADO COM GATE HONESTO** — só o nível 0 está disponível; +1–+5 não chegam ao runtime enquanto Mateus + Rico não resolverem a `[TENSÃO]` 41 | [`74`](spec/74-fecho-da-revisao-2.md) §3 · pergunta 41 |
| ✅ | ~~**Escudos aplicavam 50% mágico global apesar da afinidade não decidida**~~ **FECHADO SEM DECIDIR 43** — fallback passa a 0% e declara `blocked_owner_q43`; afinidade futura continua decisão dos donos, sem comportamento fantasma hoje | [`74`](spec/74-fecho-da-revisao-2.md) §3 · pergunta 43 |
| ✅ | ~~**A garantia “fugir funciona sempre” não tinha mecanismo em 18/33 fichas comuns**~~ **RESOLVIDO NA TAREFA 5** — as 18 recebem velocidade por papel e o auto-teste simula a fuga até ao leash, não só `<5,0` | [`74`](spec/74-fecho-da-revisao-2.md) §4 |
| ✅ | ~~**Cinco garantias visíveis apontavam para acessórios fantasma**~~ **RESOLVIDO NA TAREFA 5** — quatro sinos migrados para anéis existentes; o baralho da lanterna usa consumível + anel; `acessorio:*` é agora erro, não aviso | [`74`](spec/74-fecho-da-revisao-2.md) §2 |
| ✅ | ~~⭐ **Projécteis e formas de entrega não tinham física executável**~~ **RESOLVIDO NA TAREFA 5** — `tiro`, `perseguidor` e as 12 formas declaram movimento, colisão, cadência, pulso e expiração; projéctil móvel deixou de ser instantâneo | [`74`](spec/74-fecho-da-revisao-2.md) §1.2–1.3 · pergunta 46 continua dos donos |
| ✅ | ~~**Onze guardiões e doze subchefes deixavam IDs pendurados**~~ **DEPENDÊNCIA FECHADA** — 24 slots estáveis; Vorgar implementado, 23 com `enemy_id:null` + `blocked_owner_q52`, sem contar como conteúdo pronto | [`74`](spec/74-fecho-da-revisao-2.md) §2 · pergunta 52 |
| ✅ | ~~**As ameaças ambientais tinham 18 parâmetros por decidir**~~ **RESOLVIDO NA TAREFA 5** — as 12 têm `runtime_type`, números e `unresolved_parameters: []`; valores `[CODEX]` validam-se no M2 | [`74`](spec/74-fecho-da-revisao-2.md) §1.5 |
| ✅ | ~~**Habilidades/Eco não declaravam compromisso comum**~~ **RESOLVIDO COMO BASELINE M2** — seis activações/compromissos e Eco com fonte, alvo, tempo, custos e falha explícitos; 45 continua decisão dos donos | [`74`](spec/74-fecho-da-revisao-2.md) §1.1 |
| ✅ | ~~**Afinidade dos 70 anéis não tinha namespace nem semântica**~~ **RESOLVIDO SEM GATING** — nove etiquetas fechadas, só recomendação/bias de loot, validadas em todas as fichas | [`74`](spec/74-fecho-da-revisao-2.md) §2 · pergunta 48 |
| 🟠 | ~~**Percepção/retorno não tinham parâmetros completos**~~ **CONTRATO FECHADO** — cone, audição, alerta, chamada, desistência, regresso, cura e reaquisição têm números; implementar a máquina inteira é produção M2 | [`74`](spec/74-fecho-da-revisao-2.md) §1.4 · pergunta 53 |
| ✅ | ~~**As 57 armaduras futuras fingiam habilidade**~~ **RESOLVIDO** — dizem `effect_type:none`, `implemented:false`; as 11 iniciais continuam honestamente activas até 44/54 | [`74`](spec/74-fecho-da-revisao-2.md) §2 |
| ✅ | ~~**Os 70 anéis não tinham cliente e cinco inventavam sistemas**~~ **RESOLVIDO** — vocabulário fechado de clientes; cinco efeitos reescritos sem travessia/matchmaking novos | [`74`](spec/74-fecho-da-revisao-2.md) §2 · pergunta 55 |
| ✅ | ~~**Cinco dos seis instrumentos mágicos não existiam**~~ **DEPENDÊNCIA FECHADA** — só `cajado` é prometido e tem ficha 1,0; os outros cinco saíram das escolas até 56 lhes dar slot/comportamento | [`74`](spec/74-fecho-da-revisao-2.md) §2 |
| 🔴 | ⚠️ **Frame pacing continua a falhar, agora sem ambiguidade de medição:** fullscreen reduziu cinco UAL para p99 **18,323 ms** e pior **19,414 ms**; o pior passa 20 ms, p99 continua acima de 16,67. Sem VSync a mesma carga dá p99 5,714 ms, isolando pacing Windows/driver e não animação/culling/import. Falta o teste quente integrado 2+5 | [`74`](spec/74-fecho-da-revisao-2.md) §5 · [`medição`](medicoes/animacao-esqueleto-2026-08-01.json) |
| 🔴 | ⚠️ **O conjunto residente “zona actual + todas as vizinhas” não cabe sem um orçamento ainda inexistente por zona.** No Fojo são 6 zonas: o tecto global de 2,5 GB deixa **≈427 MiB por zona se runtime, áudio, jogadores e UI custassem zero**; na máquina de 8 GB partilhados isso é uma estimativa optimista. Definir política/per-zone budget antes da segunda zona final | revisão 2 · [`69`](spec/69-catalogo-do-mundo.md) §6 · pergunta 50 |
| 🔴 | ⚠️ **Invocações sem tecto colidem com o máximo de oito actores animados.** Um encontro de 2 jogadores + 5 inimigos já ocupa 7; sobra uma vaga para invocações dos dois, chefe portátil e qualquer reserva. Sem orçamento global, a promessa do mago pode exceder a Lei 4 na primeira conjuração extra | revisão 2 · [`21`](spec/21-arte-render.md) §2 · [`52`](spec/52-mago-do-mal.md) §10 · pergunta 51 |
| 🟠 | ⚠️ **Os 53 VFX não têm política de residência.** Não é o número de feitiços que custa por frame, é pré-carregá-los: uma implementação ingénua com 3 texturas RGBA8 1024² + mipmaps por feitiço rondaria **848 MiB**, acima do orçamento residente de texturas de 500 MB antes de cenário/personagens. Usar atlas partilhado e carregar só favoritos/escola/encounter; medir antes de produzir 50 VFX futuros | revisão 2 · [`21`](spec/21-arte-render.md) §2 · [`66`](spec/66-catalogo-de-magia.md) |
| ⏳ | ⭐ **Ordem de corte com menor perda**, se for preciso cortar: 1.ª pessoa → 48 chefes reclassificados → 5 slots de armadura → 6 slots de anel → armas acima de 24 → feitiços acima de 24. **Não cortar:** co-op, esquiva/parry/stamina, as 8 famílias, a identidade dos 12 biomas | auditoria §4 |

---

## 🎮 Da Revisão 3 — lacunas de experiência

Relatório completo: [`docs/REVISAO-3.md`](docs/REVISAO-3.md). As linhas `⏳` são decisões dos donos; não autorizam um agente a redesenhar a spec.

| | Lacuna | Origem |
|---|---|---|
| ⏳ | 🔴 **O combate comum ainda não prova co-op:** nenhum encontro da Fatia 1 exige salvar, preparar uma abertura ou executar tarefas simultâneas; o jogador melhor pode limpar o caminho enquanto o outro acompanha | revisão 3 · perguntas 59/32 |
| ⏳ | 🔴 **Brumal pede densidade larga com só dois tipos `fatia_1:true`.** O Batedor e um nomeado que depende dele aparecem no orçamento, mas continuam fora da fatia; decidir promover o terceiro papel ou cortar para 6–7 batidas | revisão 3 · pergunta 57 |
| ⏳ | 🔴 **Meditação segura cria até 80 s de espera para o parceiro; ressurreição exige 5–7 s onde Vorgar/refúgios só declaram janelas abaixo de 2 s.** Falta agência do caído e uma janela executável | revisão 3 · perguntas 58/60 |
| 🔴 | **O orçamento de almas não pode ser pago pelo runtime corrente:** baralho/transacção fecham após 10 derrotas do tipo; `souls_ten_rewarded_clears` multiplica cada colocação por 10. Separar almas de cartas depois de Mateus + Rico fecharem o contador | revisão 3 · pergunta 23 · [`67`](spec/67-catalogo-do-bestiario.md) §6 · [`72`](spec/72-materiais-consumiveis-e-economia.md) §4 |
| ⏳ | 🟠 **Mochila infinita + loot instanciado + garantia + chefe que larga tudo transforma descoberta em checklist.** Falta uma escolha que preserve a garantia contra azar | revisão 3 · pergunta 61 |
| ⏳ | 🟠 **“Nunca se zera” não tem exemplar jogável:** recompensas/corpos esgotam, as 30 portas não devem resposta e a segunda leitura de Brumal não está autorada | revisão 3 · pergunta 62 |
| ⏳ | 🟠 **A promessa mais própria — cadáveres/Voto/chefe portátil — não é testada pela Fatia 1.** Decidir spike/epílogo antes de produzir 50 feitiços futuros | revisão 3 · pergunta 63 |
| 🟠 | **Vorgar ainda não tem as sequências SEPARAR/JUNTAR nem uma janela de ressurreição materializadas no greybox.** O contrato já as exige; falta autoria/prova M2 | revisão 3 · [`61`](spec/61-arenas-de-chefe.md) §7 |
| ⏳ | 🟡 **Até dez anéis + nove peças + oito favoritos podem transformar build em espera de menu co-op.** Validar 4 anéis/presets no descanso antes de abrir a escala toda | revisão 3 · pergunta 64 |
| ✅ | ~~O teste de honestidade só provava a esquiva certa~~ **CORRIGIDO** — agora duas esquivas sem sobreposição com o activo têm de falhar 10/10; um teste verde deixa de aceitar janela/hitbox que não discrimina timing | revisão 3 · [`38`](spec/38-ataques-e-honestidade.md) cláusula 5 |
| ✅ | ~~O fecho do `72` ainda dizia que cinco acessórios ficavam fora do contrato~~ **CORRIGIDO** — a fronteira reconhece a migração já feita pelo `74` | revisão 3 · [`72`](spec/72-materiais-consumiveis-e-economia.md) §6 |

---

## 🟠 Para as voltas que aí vêm

### Volta 2 — fichas de raça 🔨 *em curso*

| | Lacuna | Origem |
|---|---|---|
| ✅ | ~~⚠️ **A linha "porque está neste bioma"**~~ **RESOLVIDA** — as 12 fichas ligam origem/necessidade ao bioma e a validação cruza `races.json` ↔ `biomes.json` nos dois sentidos | [`50`](spec/50-racas.md) · `664ec7e` |
| ✅ | ~~**Em que biomas cada raça aparece, e o que muda em cada variante**~~ **RESOLVIDO** — variantes têm papel/ataques próprios nas fichas do bestiário, não apenas cor | [`50`](spec/50-racas.md) · [`67`](spec/67-catalogo-do-bestiario.md) · `d7088b7` |
| ✅ | ~~⚠️ **Santuário Branco e A Raiz sem raça própria**~~ **RESOLVIDO** — Penitentes e Sem-rosto são habitantes dominantes e têm fichas/combate | [`50`](spec/50-racas.md) · [`67`](spec/67-catalogo-do-bestiario.md) · `d7088b7` |
| ✅ | ~~**Mímicos e Minotauros sem ficha adequada**~~ **RESOLVIDO 01-08** — mímico é praga com duas fichas de encontro; minotauros comuns variam por bioma e o guardião singular continua WP7 | [`50`](spec/50-racas.md) · [`67`](spec/67-catalogo-do-bestiario.md) |

### Volta 3 — armas e armaduras

| | Lacuna | Origem |
|---|---|---|
| ✅ | ~~**Os 7 golpes por declarar**~~ **RESOLVIDO 01-08** — 88 fichas, onze por cada uma das oito famílias; runtime continua abaixo | [`68`](spec/68-catalogo-de-armas-armaduras-e-aneis.md) §2 |
| ✅ | ~~**Melhoria de armas**~~ **RESOLVIDO 01-08** — seis escolhas sem força | [`68`](spec/68-catalogo-de-armas-armaduras-e-aneis.md) §3 |
| ✅ | ~~**Estados alterados**~~ **RESOLVIDO 01-08** — veneno, sangramento e queimadura com barra, disparo, saída e simetria | [`68`](spec/68-catalogo-de-armas-armaduras-e-aneis.md) §4 |
| ✅ | ~~**Requisitos de atributo**~~ **RESOLVIDO** — abaixo do requisito continua utilizável a ×0,6 sem escala; nenhum catálogo passa 18 | [`11`](spec/11-formulas.md) · [`68`](spec/68-catalogo-de-armas-armaduras-e-aneis.md) |
| 🟠 | **Produção M2: executar os sete golpes novos, estados e segunda adaga.** O contrato está fechado; leve/pesado/cadeia/bash são o runtime actual, e corrida, rolar, salto de ataque, queda, empurrão universal, artes, medidores e Corte Alternado têm prova de saída no [`73`](spec/73-fecho-dos-buracos-de-integracao.md) §8 | encontrado ao fechar o [`68`](spec/68-catalogo-de-armas-armaduras-e-aneis.md) |
| 🟠 | **Equipar, votos de melhoria, 2→10 dedos e persistência não têm UI/save.** Dados e invariantes existem; clientes são WP11 + save v2 | encontrado ao fechar o [`68`](spec/68-catalogo-de-armas-armaduras-e-aneis.md) |
| 🟠 | **O catálogo de armadura cresceu do alvo `[DECIDIDO]` de ~30 para 68 peças** porque o WP6 já prometia 57 IDs além das 11 iniciais. A coluna `Fatia 1?` contém a produção (só 11 agora), mas Mateus + Rico têm de aceitar a expansão ou mandar consolidar IDs | [`34`](spec/34-catalogo-e-comandos.md) · [`67`](spec/67-catalogo-do-bestiario.md) · pergunta 44 |
| 🔵 | **Como a mira do arco comunica a queda da flecha** — sem isso o jogador aprende "o arco falha às vezes" | [`36`](spec/36-fisica.md) §3 |

### Volta 4 — magia

⭐ **A forma de entrega é obrigatória em toda a ficha** — [`55-formas-de-feitico.md`](spec/55-formas-de-feitico.md). 12 formas, e o dano é o que menos as separa.

| | Lacuna | Origem |
|---|---|---|
| ✅ | ~~⭐ **Três formas em falta**~~ **RESOLVIDO 01-08** — Caçador Carmim, Granizo Carmim e Cutelo Carmim ocupam perseguidor, chuva e forma de arma; as 12 formas têm pelo menos um feitiço | [`66`](spec/66-catalogo-de-magia.md) §4–6 |
| 🟠 | ⚠️ **O traçado das zonas passa a afectar a magia** — tectos, corredores, terreno partido. A chuva morre debaixo de tecto | [`55`](spec/55-formas-de-feitico.md) §2 |

⭐ **A escola vermelha já está desenhada** — [`52-mago-do-mal.md`](spec/52-mago-do-mal.md), feita pelo Claude a pedido do Mateus (é o personagem dele). O WP4 herda-a; **não a reescreve.**

| | Lacuna | Origem |
|---|---|---|
| ⏳ | ~~As 6 perguntas do mago do mal~~ ✅ **4 respondidas 31-07** (chefe portátil · sem tecto de invocados · Voto empilha 3× · instrumento livre). Faltam: que feitiços cortar, e o tecto de máquina | [`52`](spec/52-mago-do-mal.md) §11 |
| ⏳ | **Quem manda nos invocados em co-op?** *(proposta: quem os levantou)* — não decidido pelo agente | [`52`](spec/52-mago-do-mal.md) §9 · pergunta 35 |
| ✅ | ~~**Inimigos que lançam magia usam as mesmas regras?**~~ **FECHADO** — partilham honestidade/contacto/interrupção; IA declara padrão/cooldown/usos e não finge mana/meditação | [`73`](spec/73-fecho-dos-buracos-de-integracao.md) §1 |
| ✅ | ~~**Quantos feitiços na fatia 1**~~ **RESOLVIDO 01-08** — Dardo, Ruína e Égide; os três têm ícone aprovado e ficha completa | [`66`](spec/66-catalogo-de-magia.md) |
| ✅ | ~~**O material de melhoria de feitiço é o mesmo das armas, ou outro?**~~ **RESOLVIDO NA TAREFA 4** — catálogo regional partilhado; evita uma moeda paralela e conserva preferência marcial/arcana nas cartas `bias:classe` | [`72`](spec/72-materiais-consumiveis-e-economia.md) §2.1 |
| 🟠 | **Produção M3/fatias futuras: executar os 50 feitiços fora da Fatia 1.** Cada nova forma só entra com comportamento, hitbox e cue; a dívida tem autoridade e prova de saída no [`73`](spec/73-fecho-dos-buracos-de-integracao.md) §8 | encontrado ao implementar o [`66`](spec/66-catalogo-de-magia.md) |
| 🟠 | **Produção WP11: roda e edição dos 8 favoritos.** A regra “só fora de combate/no descanso” está fechada; falta a UI que a aplique e a prova negativa em combate | [`66`](spec/66-catalogo-de-magia.md) · [`73`](spec/73-fecho-dos-buracos-de-integracao.md) §8 |
| ✅ | ~~**Escolas declaravam cinco instrumentos sem ficha**~~ **FECHADO NA TAREFA 5** — só o cajado baseline 1,0 é declarado; sino/talismã/chama/relicário/híbrido só regressam depois da decisão e spike 56 | [`74`](spec/74-fecho-da-revisao-2.md) §2 |

### Volta 5 — bestiário

| | Lacuna | Origem |
|---|---|---|
| ✅ | ~~**Som + sinal visual em cada ataque**~~ **RESOLVIDO 01-08** — 105 fichas compiladas têm cue ID/descrição e seis campos visuais | [`67`](spec/67-catalogo-do-bestiario.md) §4–7 |
| ✅ | ~~⭐ **`GameplayCue` + renderer e migração**~~ **RESOLVIDO 01-08** — faixa/área, glifo no mundo, bordo fora do ecrã, cancelamento 0,15 s e cinco perfis sonoros | [`67`](spec/67-catalogo-do-bestiario.md) §7 |
| ✅ | ~~**Massa de cada inimigo**~~ **RESOLVIDO 01-08** — 33 comuns + Vorgar, em kg, validada positiva | [`67`](spec/67-catalogo-do-bestiario.md) §3 |
| ✅ | ~~**Almas por inimigo e total por zona**~~ **RESOLVIDO 01-08** — primeira limpeza + limite de dez nas 12 zonas, recalculados no teste | [`67`](spec/67-catalogo-do-bestiario.md) §6 |
| ✅ | ~~**Ligar morte → compra do baralho → recibo/save**~~ **RESOLVIDO NA TAREFA 4** — `Enemy.died` chama compra idempotente; almas, item, índice e recibo são publicados na mesma geração atómica e a falha repõe o snapshot | [`72`](spec/72-materiais-consumiveis-e-economia.md) §4 · 9531 testes correntes |
| ✅ | ~~**Resolver os IDs de materiais e consumíveis dos cartões**~~ **RESOLVIDO NA TAREFA 4** — 40 materiais; os 17 tokens antigos eram 15 objectos + Brasa ilegal + grafia acentuada duplicada, ambos corrigidos | [`72`](spec/72-materiais-consumiveis-e-economia.md) §§2–3 |
| 🟠 | **31 fichas fora da Fatia 1 ainda não têm modelo/animações/hitboxes.** A descrição gerável existe; produzir só quando `Fatia 1?` mudar | [`67`](spec/67-catalogo-do-bestiario.md) §8 · `→WP15B` |

### Volta 7 — chefes

| | Lacuna | Origem |
|---|---|---|
| ✅ | ~~⚠️ **Desenho de arena de chefe**~~ **RESOLVIDO 01-08** — tamanho por camada, obstáculos/refúgios, duas rotas e perguntas SEPARAR/JUNTAR para co-op | [`61`](spec/61-arenas-de-chefe.md) |
| ✅ | ~~**Um subchefe pode ser fugido de vez, ou reaparece?**~~ **FECHADO** — fugir recompõe no descanso; matar persiste no ciclo; Brasa/NG+ volta a colocá-lo com uma recompensa fixa por ciclo | [`73`](spec/73-fecho-dos-buracos-de-integracao.md) §3 · `world.json` |
| ✅ | ~~**Como se sinaliza um precipício**~~ **RESOLVIDO 01-08** — faixa ≥ empurrão máximo + 0,5 m, padrão sem depender de cor, silhueta, movimento e som redundante | [`61`](spec/61-arenas-de-chefe.md) §5 |
| 🟠 | **As 12 fichas de arena depois de Vorgar** — 11 guardiões + Ultra; quais usam queda, obstáculos, SEPARAR/JUNTAR e prova em ambas as perspectivas | [`61`](spec/61-arenas-de-chefe.md) §7 |

### Volta 8 — sistemas

| | Lacuna | Origem |
|---|---|---|
| ✅ | ~~**A curva de nível era linear e chamava “XP”**~~ **CORRIGIDO** — custo cúbico em almas, com marcos 20/40/70/100 executáveis | [`72`](spec/72-materiais-consumiveis-e-economia.md) §2 · `860204f` |
| ✅ | ~~**Sistema de saves sem uma linha**~~ **RESOLVIDO 01-08** — formato campo a campo, morte sem save-scumming, escrita atómica, recuperação e migração, com código e testes | [`59`](spec/59-saves.md) · `game/src/autoload/save_system.gd` |
| ✅ | ~~**A migração de `sabedoria` não tinha algoritmo**~~ **FECHADO NO CONTRATO** — v2 move o valor para o eixo mágico da origem, repõe o outro na base e prova que não duplicou pontos; implementação entra com `appearance` | [`73`](spec/73-fecho-dos-buracos-de-integracao.md) §7 |
| ✅ | ~~⚠️ **A leitura do mapa tinha de ser decidida antes do traçado**~~ **RESOLVIDO NO CONTRATO 01-08** — vista inclinada a ~40°, só terreno percorrido, andar actual realçado; a escolha zona/mundo continua dos donos sem bloquear a geometria | [`57`](spec/57-mapa-e-minimapa.md) §5 · [`69`](spec/69-catalogo-do-mundo.md) §1 |
| 🟠 | ⚠️ **A selecção visual da Fatia 1 já está integrada em `game/`; sons e conteúdo posterior continuam apenas em `art/`.** Biblioteca não é runtime: cada asset restante ainda precisa de importação deliberada, orçamento e prova no motor | [`22`](spec/22-assets.md), `game/assets/models/ASSETS.md` |
| 🟠 | ⚠️ **Ligar os produtores restantes ao `SaveSystem`.** Morte de inimigo → almas/inventário/baralho/recibo já é atómica; HP zero → mancha, exploração do mapa, equipamento e UI entram quando esses clientes forem construídos. O toast já deixou de prometer falsamente que nada se perdeu | [`59`](spec/59-saves.md) · [`72`](spec/72-materiais-consumiveis-e-economia.md) |
| 🟠 | ⚠️ **O catálogo de 120 armas não declara peso numérico.** Armaduras e famílias de escudo têm `peso`, as armas têm apenas `peso_escala`; a mochila mostra e calcula honestamente o **peso declarado** do equipado, sem inventar quilogramas. Falta acrescentar peso numérico às armas antes de a carga poder contar todo o kit | [`40`](spec/40-decisoes-espolio-magia-inventario.md) §9 · [`68`](spec/68-catalogo-de-armas-armaduras-e-aneis.md) |
| 🟠 | ⭐ **Produção M2: construir `TuningRecorder`.** CSV, `tp arena_vorgar`, `latencia`, overlays e fixtures A/B já têm contrato; até existirem, os números dizem **baseline**, nunca “confirmado” | [`63`](spec/63-como-se-afinam-os-numeros.md) · [`73`](spec/73-fecho-dos-buracos-de-integracao.md) §8 |
| 🟠 | **Produção WP11: construir o criador.** Ecrã/slots, `appearance.json`, nome, save v2/migração e matriz 6 origens × armas têm contrato e prova de saída | [`64`](spec/64-criacao-de-personagem.md) · [`73`](spec/73-fecho-dos-buracos-de-integracao.md) §§7–8 |
| 🟠 | **Os corpos Quaternius, classes KayKit e 11 peças não têm retarget/encaixe provado; os 2 conjuntos de voz também não existem** | conteúdo e integração exigidos pelo [`64`](spec/64-criacao-de-personagem.md) |
| 🟠 | **Produção WP12/15: arquitectura de áudio.** `audio_catalog.json`, buses, `AudioDirector`/`MusicDirector`, 8 vozes e ducking estão especificados; o runtime actual ainda envia os sintetizados para `Master` | [`65`](spec/65-musica-e-ambiente.md) · [`73`](spec/73-fecho-dos-buracos-de-integracao.md) §8 |
| 🟠 | **Produção/autoria: zero música e zero loop de ambiente.** Faltam 6 peças, 3 stingers, Brumal/Toca, vozes e materiais próprios; autoria/direcção continua pergunta 34 dos donos | [`65`](spec/65-musica-e-ambiente.md) · pergunta 34 |
| 🟠 | **Lock-on em 1.ª pessoa** — duas opções propostas, nenhuma escolhida | [`29`](spec/29-perspectiva.md) |
| ✅ | ~~**A cura à distância funciona com que latência?**~~ **FECHADO** — evento fiável/ordenado, `cast_id`, validação anfitriã e aplicação pelo dono no tempo de voo; nunca rebobina morte, >150 ms avisa | [`42`](spec/42-estudo-magia.md) · [`73`](spec/73-fecho-dos-buracos-de-integracao.md) §1.1 |

### Volta 9 — mundo

| | Lacuna | Origem |
|---|---|---|
| ✅ | ~~**Nadar, escalar, saltar: existem?**~~ **FECHADO** — sem verbos livres; passo automático ≤0,45 m e ligações verticais autoradas; “a saltar” é golpe terrestre | [`73`](spec/73-fecho-dos-buracos-de-integracao.md) §2 · `world.json` |
| 🔴 | ⚠️ **Traçado e orçamento de memória ainda não nasceram juntos em números por zona.** As 21 gargantas estão fechadas, mas `actual + vizinhas` chega a 6 zonas no Fojo; 2,5 GB/6 = 427 MiB antes de runtime/áudio/UI. A topologia existe, a prova de que o pior conjunto residente cabe não | [`43`](spec/43-estudo-espolio-inventario-mundo.md) §6 · [`69`](spec/69-catalogo-do-mundo.md) §2 · pergunta 50 |
| 🟠 | **Produção WP8: o catálogo do mundo ainda não tem runtime.** Topologia, streaming por garganta, mapa/minimapa, elevadores, atalhos persistentes e 11 zonas têm contrato e prova de saída; hoje só Brumal existe | [`69`](spec/69-catalogo-do-mundo.md) · [`73`](spec/73-fecho-dos-buracos-de-integracao.md) §8 |
| 🟠 | **Brumal cresceu do greybox de 2–3/4–6 min para uma travessia catalogada de 8 min.** O nível actual tem de ganhar círculos horizontal/vertical, atalho por dentro, segundo descanso e densidade sem virar corredor; só fica confirmado depois de cinco corridas medidas em ambas as perspectivas | [`10`](spec/10-fatia-1.md) · [`53`](spec/53-chefes-ritmo-e-o-mago-forte.md) §3 · [`69`](spec/69-catalogo-do-mundo.md) §3.1 |
| 🟠 | **As 30 portas são malha estática e escrita, não conteúdo futuro construído.** Quando uma for promovida, precisa de novo `Fatia 1?`, orçamento, destino e revisão da promessa; hoje nenhuma entra na primeira fatia | [`69`](spec/69-catalogo-do-mundo.md) §4 |

---

## 🔵 Quando houver tempo

| | Lacuna | Origem |
|---|---|---|
| ✅ | ~~⚠️ **A conversão visual, passos 1–3**~~ **FEITA E MEDIDA 01-08** — paleta de luz/névoa vem da ficha do bioma; contraste, dessaturação e vinheta são graduados; Kenney/KayKit substituem chão, árvores, rochas e Toca com rugosidade. A primeira versão falhou a Lei 4 a 57,4 fps e foi optimizada até 60/60/60 | [`47`](spec/47-do-greybox-ao-visual.md) §4 · [`PERF`](game/PERF.md) |
| ✅ | ~~**Capturas em todo o marco**~~ **FEITAS 01-08** — seis pontos canónicos revistos depois de cada passo; os PNG finais ficam em `game/captures/` fora do git | [`47`](spec/47-do-greybox-ao-visual.md) §5 |
| 🔵 | **Os 11 documentos antigos não trazem tabela `eles·nós·diferença` nem citam fontes** | [`31`](spec/31-referencias.md) |
| 🔵 | **Economia de vendedores** — a loja vende conveniência, nunca poder | [`39`](spec/39-estudo-profundo.md) §11 |
| 🔵 | **Validar as constantes de física a jogar** (marco 2) | [`36`](spec/36-fisica.md) |

---

## ⏳ Dos donos — não são para os agentes resolverem

Estão no [`99-perguntas-abertas.md`](spec/99-perguntas-abertas.md). As que mais mudam o jogo:

| # | | |
|---|---|---|
| **32** | ⚠️ Matar um chefe no mundo do outro muda o teu próprio mundo? | proposta: vitória/recompensa viaja; mundo e atalhos não |
| **28** | ⚠️ Se a magia faz tudo, como é que o mago não é a classe correcta? | cinco travões propostos |
| **24** | Chefe a dois: +40% de vida ou zero? | proposta: +40%, e desce quando um morre |
| **37** | O Mateus confirma o Assassino do catálogo? | proposta completa no `68`, sem fingir aprovação |
| **38** | Mapa por zona ou do mundo inteiro; mostra nomes não visitados? | proposta: por zona, nomes só depois de vistos |
| **39** | Os vendedores morrem e o stock pode desaparecer? | proposta: sem morte acidental; consequência só explícita |
| **40** | O Coveiro fecha acesso por origem/classe? | proposta: qualquer origem depois de descobrir a Escola vermelha |
| **41** | `[TENSÃO]` Melhorias de feitiço: três eixos ou Lei 2? | recomendação: escolhas com perda/verbo; runtime fica no nível 0 |
| **43** | `[TENSÃO]` Afinidade elemental por família ou instância de escudo? | recomendação: instância; fallback mágico fica 0 até resposta |
| **44** | `[TENSÃO]` ~30 ou 68 armaduras? | recomendação: produzir só 11 e consolidar futuras por escolha real |
| **45** | Compromisso das habilidades e semântica do Eco | baseline/recomendação: repete compromisso/tempo e conserva custos não-mana |
| **46** | Física de projécteis e formas de entrega | baseline M2 escrito; donos confirmam antes de produção larga |
| **47–48** | Categoria de acessórios e afinidade dos anéis | acessórios fantasma removidos; recomendação: afinidade nunca faz gating |
| **49** | Parâmetros ambientais | baselines escritos; uma família por spike e lista vazia como gate da zona |
| **50–51** | Streaming e orçamento global de actores | proposta: actual + transição; oito actores incluindo invocados |
| **52** | Identidade de onze guardiões e doze subchefes | 23 slots bloqueados, sem IDs de inimigo fingidos; conteúdo é dos donos |
| **53** | Percepção, retorno e cura dos inimigos | baseline 2 m/regresso/cura total escrito; donos confirmam antes do runtime M2 |
| **54–55** | Habilidades de armadura e alcance dos sistemas de anel | futuros bloqueados/clientes fechados; donos só decidem expandir capacidades |
| **56** | Slots, força e velocidade de instrumentos futuros | só cajado 1,0 existe; recomendação: spike sino/talismã antes de reabrir IDs |

E as **7 perguntas de narrativa** ([`26`](spec/26-narrativa.md) §3), que precisam de uma gravação — **o nome do jogo incluído**.

---

---

---

## 📦 Os packs CC0 — o que entrou e o que ficou de fora

**01-08.** Os dez packs entraram no repositório (PR #19), com uma limpeza feita no merge.

| | |
|---|---|
| Descarregado pelo Fable | **571 MB** · 6511 ficheiros |
| ⭐ **Removido no merge** | **~120 MB** · 3213 ficheiros — os formatos `.fbx` `.obj` `.mtl` `.stl` `.dae` que **o Godot não lê** |
| **Ficou no merge** | **~452 MiB** · 3298 ficheiros; o working tree corrente tem 3310 ficheiros / **466,1 MiB** depois dos ícones posteriores |
| ⚠️ **Preservados de propósito** | **5** ficheiros `.obj` do pack de masmorra que **não têm equivalente** em `.gltf` — peças soltas (tampa de baú, porta) |

⭐ **Porque é que não se perdeu nada:** o `.glb`/`.gltf` é o **mais completo** dos formatos — carrega malha, materiais, esqueleto e animações. O `.obj` não tem esqueleto nem animação; o `.stl` só tem a malha. **Os apagados eram versões com menos informação do que a que ficou.**

| | Lacuna | |
|---|---|---|
| 🔵 | ⚠️ **411 MB dos 460 são texturas PNG** — algumas acima do orçamento de 1024–2048 do [`30`](spec/30-qualidade-visual.md). **Reduzi-las é a próxima poupança grande**, e ao contrário dos formatos duplicados **isto mexe na qualidade** — decisão dos donos | [`30`](spec/30-qualidade-visual.md) |
| 🔵 | **Se algum dia se reescrever o histórico por outra razão**, aproveitar para tirar o resto | — |

---

## 🔬 Da auditoria de comparação com DS2/DS3 (01-08)

[`docs/AUDITORIA-CODEX-COMPARACAO-2026-08-01.md`](docs/AUDITORIA-CODEX-COMPARACAO-2026-08-01.md). ⚠️ **A primeira é um erro de conta meu, já corrigido.**

| | Achado | Origem |
|---|---|---|
| ✅ | ~~*"do 70 ao 100 custa 3× tudo o que gastaste do 1 ao 70"*~~ **ERRO MEU, CORRIGIDO** — somei só o termo cúbico e ignorei `3,06N²` e `105,6N`, que pesam mais nos níveis baixos. **A conta certa é 1,92×** (680 663 contra 1 308 518). Refiz-a e confirma | [`58`](spec/58-fim-do-jogo-ciclos-e-a-curva.md) §2 |
| ✅ | ~~⭐ **Meditação infinita + artes a gastar “energia” revogada**~~ **RESOLVIDO 01-08** — 2 tentativas por descanso, consumidas ao sentar; 40 s/100% preservados por serem decisão dos donos; interrupção guarda o parcial; artes gastam mana | [`66`](spec/66-catalogo-de-magia.md) §3 · runtime testado |
| ✅ | ~~⭐ **Uma mão / duas mãos não tinha comando nem estado**~~ **RESOLVIDO NA TAREFA 4** — `T`/`Y`, estado próprio de 12 f interrompível, offhand recolhido e arte seleccionada pela empunhadura | [`70`](spec/70-fecho-dos-sistemas-de-combate.md) §2 · 9531 testes correntes |
| ✅ | ~~⭐ **8 favoritos mudáveis a qualquer momento**~~ **RESOLVIDO NO CONTRATO 01-08** — só mudam fora de combate/no descanso; a UI que aplica a regra está registada acima como construção em falta | [`66`](spec/66-catalogo-de-magia.md) §3 |
| ✅ | ~~⚠️ **Parry com 4 frames de arranque**~~ **CORRIGIDO** — baseline executável **8/8/40**, falha total 56 f | [`70`](spec/70-fecho-dos-sistemas-de-combate.md) §1 |
| ✅ | ~~⚠️ **Soft cap de 40 em tudo**~~ **CORRIGIDO** — Vida 20/50 · Stamina 20/40 · Constituição 25/50 · mana 35 · dano 40/60 · Carga 30/50/70 | [`70`](spec/70-fecho-dos-sistemas-de-combate.md) §1 |
| ✅ | ~~**Queda fatal aos 25 m**~~ **CORRIGIDO** — zero até 5 m, progressiva abaixo de 20 m, fatal absoluta aos 20 m | [`70`](spec/70-fecho-dos-sistemas-de-combate.md) §1 · `progression.json` |
| ✅ | ~~⚠️ **Faltava sobrecarga (>100%)**~~ **RESOLVIDO** — sem esquiva/corrida/sprint; marcha 3 m/s e regen 26/s | [`70`](spec/70-fecho-dos-sistemas-de-combate.md) §1.1 |
| ✅ | ~~**NG+ somava vida e dano por igual**~~ **CORRIGIDO** — +30% PV/+15% dano, depois +5%/+3% até +7 | [`70`](spec/70-fecho-dos-sistemas-de-combate.md) §1 |
| ✅ | ~~**Contra-ataque +30% universal**~~ **CORRIGIDO** — só perfuração: ×1,30; haste ×1,40; só estocada da katana ×1,45 | [`70`](spec/70-fecho-dos-sistemas-de-combate.md) §3 |
| ✅ | ~~⭐ **Contra-ataque e instável estavam misturados**~~ **SEPARADOS** — instável ×1,25 só nas quatro fontes declaradas | [`70`](spec/70-fecho-dos-sistemas-de-combate.md) §3 |
| ✅ | ~~⭐ **Ressalto não tinha contrato**~~ **ESCRITO** — parede/deflexão/corpo duro, primeira colisão e 12–18 f; varredura geométrica continua M2 | [`70`](spec/70-fecho-dos-sistemas-de-combate.md) §3 |
| ✅ | ~~**O piso corporal estava aplicado a escudos**~~ **SEPARADO** — seleccionados chegam a 100% físico; estabilidade continua ≤85 | [`70`](spec/70-fecho-dos-sistemas-de-combate.md) §3 |
| ✅ | ~~**Carga média perdia 10% de regeneração**~~ **CORRIGIDO** — leve/média 40/s; pesada 31/s | [`70`](spec/70-fecho-dos-sistemas-de-combate.md) §1.1 |

### ⭐ Gramática de combate que nos falta (secção 4 da auditoria)

Vocabulário de situações que o DS tem e a nossa spec **não menciona em lado nenhum**:

| | |
|---|---|
| ✅ | ~~**Ataques inimigos que atravessam escudo**~~ — `sea_orc_hookbearer/hook_pull`, 40% |
| ✅ | ~~**Esmagamento de guarda dedicado**~~ — `orc_brute/slam`, custo ×2,5 |
| ✅ | ~~⭐ **Mesmo aviso, dois tempos de largada**~~ — `vorgar/overhead_crush`, f56/f72 com segundo sinal |
| ✅ | ~~**Ramos condicionais de combo**~~ — `orc_spearman/double_thrust`, distância/ângulo, nunca input |
| ✅ | ~~⭐ **Falsa recuperação**~~ — `skeleton_swordsman/bone_rattle`, pose diferente e extensão legível |
| ✅ | ~~⭐ **Castigo de cura**~~ — `orc_spearman/closing_lunge`, estado visível + LOS + 9 f |
| ✅ | ~~**Fingir morte e atacar ao levantar**~~ — `ancient_skeleton/black_cut`, colocação determinística |

### E os sistemas deles que o Codex diz para **não** copiar

Atributo que controla i-frames *(viola a nossa Lei 1)* · durabilidade *(só gera viagens ao descanso)* · invasões, pactos e sinais de invocação *(resolvem emparelhamento público — nós somos dois)* · penalização de vida máxima por morrer *(espiral de fracasso)*.

⭐ **E disse que o nosso mapa é melhor do que não ter mapa**, para dois amigos. Fica.

---

| ✅ | ~~⭐ **A semente fixa do acaso**~~ **RESOLVIDO 01-08** — greybox, escolha de padrões e ordem do baralho aceitam semente; 42 repete e 43 diverge no auto-teste | [`60`](spec/60-o-agente-que-joga.md) §2 · [`67`](spec/67-catalogo-do-bestiario.md) §5 |

---

## 🕳️ Buracos de sistema — coisas que NUNCA foram escritas

**Varrimento de 01-08.** Não são detalhes por afinar: são sistemas inteiros que a spec assume e nunca definiu. Ordenados por quanto custa descobri-los tarde.

| | Buraco | Porque dói tarde |
|---|---|---|
| ✅ | ~~⭐ **Sistema de saves**~~ **ESCRITO E IMPLEMENTADO 01-08** — dois domínios, escrita atómica, backup, checksum, recuperação e migrações | [`59`](spec/59-saves.md) · 19 auto-testes novos |
| ✅ | ~~⭐ **Packs CC0 por descarregar**~~ **RESOLVIDO 01-08** — modelos e 182 OGG estão em `art/`; integração no jogo continua nas linhas próprias abaixo/acima | [`CREDITS`](CREDITS.md), [`22`](spec/22-assets.md), [`65`](spec/65-musica-e-ambiente.md) |
| ✅ | ~~⚠️ **O `.gitignore` e o `game/CLAUDE.md` contradiziam-se sobre binários**~~ **RESOLVIDO** — os packs CC0 entram deliberadamente no repositório; `game/CLAUDE.md` já distingue builds ignoradas de assets versionados | `953589c` |
| 🟠 | ⭐ **A selecção da Fatia 1 está importada e integrada: corpos Quaternius animados, três árvores/três rochas/chão Kenney e módulos KayKit na Toca; as `CapsuleShape3D` de física ficaram byte-a-byte com as dimensões anteriores.** Entraram 35 ficheiros/22,4 MiB. ⚠️ `spec/22` escolhe Quaternius Monsters para os orcs, mas esse pack não existe em `art/models/`; até entrar, lanceiro/brutamontes/Vorgar usam escala e cor provisórias do corpo-base para preservar autor e o esqueleto comum de 65 ossos | fase 1.2, 01-08 · `game/assets/models/ASSETS.md` |
| ✅ | ~~⭐ **A animação de esqueleto estava por medir**~~ **MEDIDA NA IRIS XE E NO NÍVEL** — UAL Standard, Mobile/Vulkan, 1920×1080: 5 e 10 actores deram ambos 60,0 fps médios; p95 17,773/16,666 ms, pior 20,619/18,539 ms. A prova `lei4` com 2 jogadores + 3 inimigos importados manteve média, mínimo e 1% low de 60,0 durante 30 s; os picos sem vsync ficam documentados, não escondidos | [`PERF`](game/PERF.md) · [`animacao-esqueleto-2026-08-01.json`](medicoes/animacao-esqueleto-2026-08-01.json) · [`44`](spec/44-prototipo.md) |
| 🔵 | **120 MB dos 410 são formatos que o Godot não usa** — `.fbx`, `.obj`, `.mtl`, `.stl`, `.dae`, duplicados do `.glb` que já lá está. Entraram porque a decisão foi *"tudo no repositório"*, e limpar depois obriga a reescrever a história. *Se algum dia se reescrever o histórico por outra razão, aproveita-se* | fase 1.2, 01-08 |
| ⏳ | ~~⭐ **Onde vivem os modelos CC0: no repositório ou em `_local/`?**~~ ✅ **DECIDIDO 01-08 pelo Rico** — no repositório, com o custo à vista. A estimativa preliminar foi 410 MB/6451 ficheiros; a medição final do import e da limpeza está na tabela acima. *(registo do que era:)* O [`22`](spec/22-assets.md) diz que CC0 *pode* entrar, mas ninguém pesou o tamanho nem o facto de o git nunca esquecer. **É decisão dos donos** porque é praticamente irreversível: 1 pack Kenney ≈ 2–10 MB, mas o conjunto de personagens+animações+natureza+dungeon anda pelas **centenas de MB**, e um `git clone` passa a custar isso a toda a gente, para sempre. *Proposta: `art/models/` no repo só para o que o jogo carrega mesmo (poucos MB, optimizado), e os packs crus em `_local/`* | encontrado 01-08 |
| ✅ | ~~⭐ **Desenho de arena de chefe**~~ **ESCRITO 01-08** — 13 arenas seladas, bolsas abertas para subchefes, bordo legível, nevoeiro/carregamento e espaço desenhado para dois | [`61`](spec/61-arenas-de-chefe.md) |
| ✅ | ~~O fim do jogo~~ **ESCRITO 01-08** — escolha final que **os dois têm de concordar**; estrutura fixada, conteúdo depende das 7 perguntas de narrativa | [`58`](spec/58-fim-do-jogo-ciclos-e-a-curva.md) |
| ✅ | ~~Ciclo novo (NG+)~~ **FECHADO 01-08** — ciclo 2: PV ×1,30/dano ×1,15; ciclos 3–7: +5% PV/+3% dano, com tecto no ciclo 7. A **Brasa** sobe uma zona sem recomeçar o jogo | [`70`](spec/70-fecho-dos-sistemas-de-combate.md) §1 · `progression.json` |
| ✅ | ~~**Criação de personagem**~~ **ESCRITO 01-08** — seis presets sem caminhos fechados, aspecto finito, voz independente, nome seguro, revisão e save atómico | [`64`](spec/64-criacao-de-personagem.md) |
| ✅ | ~~⭐ **Quem afina os números**~~ **ESCRITO 01-08** — inventário, ordem causal, papéis, passos máximos, A/B, diagnóstico e critério para congelar sem transformar partidas em finais | [`63`](spec/63-como-se-afinam-os-numeros.md) |
| ✅ | ~~⚠️ **Desligar a meio de um chefe**~~ **RESOLVIDO 01-08** — sem progresso parcial; commit autoritativo em HP zero; recibo persistente e idempotente para a queda depois da morte | [`59`](spec/59-saves.md) §8 |
| 🔵 | **Medir p95 da escrita com o mapa completo na máquina do Rico** — a fixture actual tem guarda < 64 KiB; o orçamento cheio é 2 MiB e ainda não existe conteúdo para o medir | [`59`](spec/59-saves.md) §10 |
| ✅ | ~~**Música e ambiente**~~ **ESCRITO 01-08** — inventário real, mapa de uso, estados/transições, camadas, buses, ducking e prova; produção em falta fica vermelha acima | [`65`](spec/65-musica-e-ambiente.md) |
| ✅ | ~~⭐ **Acessibilidade auditiva**~~ **ESCRITA 01-08** — cada tipo de som informativo tem equivalente próprio de forma/direcção/timing; sem legendas genéricas e com ficha de ataque alterada já | [`62`](spec/62-acessibilidade-auditiva.md) |
| ✅ | ~~**Onde vivem os textos**~~ — `strings.<locale>.json` por ID estável; HUD/toasts já consomem português e IDs obrigatórios falham o teste | [`73`](spec/73-fecho-dos-buracos-de-integracao.md) §4 · `strings.pt.json` |
| ✅ | ~~**Comando / gamepad**~~ — todas as acções nucleares, incluindo câmara, têm teclado/rato + botão/eixo, construídos do mesmo catálogo; conforto/deadzone esperam comando físico no M2 | [`73`](spec/73-fecho-dos-buracos-de-integracao.md) §5 · 9531 testes correntes |
| ⏳ | **Os vendedores morrem?** — não decidido pelo agente; morte pode destruir stock e é irreversível | pergunta 39 dos donos |
| ✅ | ~~**Voz: Godot faz nativamente?**~~ — captura/microfone sim; Opus/AEC/jitter/transporte completos exigem integração e possível GDExtension nativa, com spike/licença no WP14 | [`56`](spec/56-voz-e-vendedores.md) · [`73`](spec/73-fecho-dos-buracos-de-integracao.md) §6 |

### ⚠️ E três que são de coerência, não de conteúdo

| | Buraco | |
|---|---|---|
| ✅ | ~~⭐ **A fatia 1 foi aprovada antes de ~40 decisões**~~ **RESOLVIDO NA TAREFA 4** — o `10` e os WP2–WP11 (`11`–`20`) preservam o texto histórico, mas abrem agora com aviso e apontam às autoridades/dados actuais | [`10`](spec/10-fatia-1.md) · [`11`](spec/11-formulas.md)–[`20`](spec/20-interface.md) |
| ✅ | ~~**Os ~36 "nomeados" que substituíram os chefes de campo**~~ **RESOLVIDO NA TAREFA 4** — 36 fichas, exactamente 3 por zona, com tipo-base, localização, multiplicadores curtos, um ataque extra e carta garantida | [`71`](spec/71-encontros-nomeados.md) |
| ⏳ | **O Assassino** — proposta completa escrita e testada; **falta o Mateus confirmar** Passo Mudo, Corte Alternado, Cruz Carmesim e Entre Sombras | [`68`](spec/68-catalogo-de-armas-armaduras-e-aneis.md) §5 · pergunta 37 |

---

## ✅ Fechadas

| Lacuna | Fechada em |
|---|---|
| ~~O código vive fora do repositório~~ | PR #13 |
| ~~A medição 0b não tem artefacto~~ | PR #12 *(metade — falta a animação de esqueleto)* |
| ~~Arcos, bestas e escudos sem mecânica~~ | [`48`](spec/48-arcos-bestas-escudos.md) |
| ~~6 zonas contra 10+ biomas~~ | PR #14 — **12 biomas** |
| ~~Quantos chefes ao todo~~ | PR #14 — **61, derivado do mapa** |
| ~~O parry tem dois botões~~ | [`45`](spec/45-controlos-configuraveis.md) — controlos configuráveis |
| ~~Sem sistema de interrupção~~ | [`39`](spec/39-estudo-profundo.md) §4 · [`41`](spec/41-estudo-armas-e-golpes.md) §4 *(escrito; falta implementar)* |
| ~~Espólio sem garantia~~ | [`43`](spec/43-estudo-espolio-inventario-mundo.md) §2 — o baralho de 10 |
| ~~WP6 sem catálogo executável~~ | [`67`](spec/67-catalogo-do-bestiario.md) — 33 tipos, 100 ataques comuns, 33 baralhos e 12 orçamentos |
| ~~Ataques dependiam de áudio~~ | [`67`](spec/67-catalogo-do-bestiario.md) §7 — `GameplayCue` apresenta som e visual equivalentes |
# Casca do jogo — decisões de implementação a rever

- `[CODEX]` **Pausa solo/co-op (01-08-2026):** a implementação pausa a árvore do mundo em solo e mantém o mundo a correr em co-op, com o estado escrito no próprio ecrã. Razão: o pedido actual do Mateus distingue explicitamente os dois modos e uma sessão de rede não pode congelar o parceiro. Alternativa descartada: nunca pausar, como recomenda a camada histórica de `spec/20-interface.md`; conserva um único hábito, mas deixa o pedido de pausa sem efeito no único modo onde parar é tecnicamente honesto. Se Mateus e Rico preferirem a regra histórica, mudar `GameShell.pause_world_for_mode()` para devolver sempre `false` é a única fronteira funcional.
