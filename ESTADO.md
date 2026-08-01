# ESTADO — o que é verdade hoje

**Actualizado: 01-08-2026, catálogo do bestiário.** Este é o ficheiro que se lê primeiro. O [`SPEC.md`](SPEC.md) diz **onde** as coisas estão; este diz **em que pé** estão e **por que ordem** se pega nelas.

> **Porque existe:** a spec tem 62 documentos e ~35 decisões. Onze dos documentos de execução são **anteriores** a decisões que os mudam. Sem um sítio que diga o que vale hoje, qualquer agente constrói sobre o que já foi substituído.

---

## 1. ⚠️ O jogo existe, e até hoje vivia num sítio só

**O protótipo joga-se.** Combate fiel ao WP1 (i-frames 0,08→0,38, parry de 8 frames + contra-golpe, as 5 armas com frames exactos), lanceiro e brutamontes com telegrafia, 3 magias executáveis, o Vorgar com 2 fases, frasco de cura, habilidades de classe e 17 sons sintetizados. **5737 auto-testes contra a spec.** Godot 4.7.1, renderer Mobile, **416 fps na máquina do Rico**. Detalhe em [`spec/44-prototipo.md`](spec/44-prototipo.md).

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
=== 130 passaram, 0 falharam ===
```

## 1b. ⭐ O que temos, em números

**Esta tabela é o retrato do projecto.** O que falta não é arquitectura — é **conteúdo**.

| | Temos | A spec promete | Falta |
|---|---|---|---|
| Documentos de spec | **69** em `spec/` | — | — |
| Código e dados | 16 ficheiros `.gd` · 11 catálogos JSON | — | — |
| Testes | **5737, todos a passar** | — | — |
| Imagens curadas | **43** fora dos packs: 32 conceitos · 9 ícones · menu · céu | — | 11 ícones de armadura por gerar |
| **Armas** | 5 instâncias · **8 famílias** ([`51`](spec/51-familias.md)) | ~120 | as instâncias (camada 2) |
| **Armaduras** | **11 peças** · 9 slots · 3 cargas ([`51`](spec/51-familias.md)) | ~30 | ~19 |
| **Anéis** | **0** | ~70 | **70** |
| **Feitiços** | **53 fichas · 3 executáveis/Fatia 1** ([`66`](spec/66-catalogo-de-magia.md)) | catálogo largo | 50 renderers/comportamentos e roda |
| **Inimigos** | **33 tipos comuns · 100 ataques comuns · Vorgar migrado** ([`67`](spec/67-catalogo-do-bestiario.md)) | 12 raças + 61 chefes | modelos/animações dos 31 fora da Fatia 1 · chefes WP7 |
| Habilidades de classe | 6 | 6 | ✅ |
| **Biomas** | **12 fichas** ([`49`](spec/49-biomas.md) + `game/data/biomes.json`) | 12 | ✅ volta 1 |
| **Raças** | **12 fichas + mímico** ([`50`](spec/50-racas.md) + `game/data/races.json`) | 10–15 | ✅ volta 2 |

⭐ **E a instrução que daí sai:** o motor é data-driven — o `game_data.gd` recusa arrancar se os dados divergirem da spec. **Escrever o catálogo não é documentar o jogo: é construí-lo.** O catálogo escreve-se em `spec/` **e** em `game/data/*.json`, no mesmo PR.

## 1c. ✅ A fundação de saves existe

O [`59`](spec/59-saves.md) define e o `SaveSystem` implementa: estado separado de personagem/mundo ligado ao `GameData`, autosave sem botão de recarregar, escrita `.tmp` + rename, geração `.bak`, checksum, recuperação de corrupção e migrações de formato. **19 verificações novas** cobrem round-trip, interrupção, corrupção silenciosa e v0→v1.

⚠️ **Isto desbloqueia, mas não finge que os clientes já existem:** o greybox ainda não tem almas, mochila ou mapa persistentes. Quando cada sistema entrar, chama a fronteira única do save. A regra de progresso de chefe no mundo alheio continua `[TENSÃO]`, pergunta 32 do [`99`](spec/99-perguntas-abertas.md).

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

⚠️ A verificação do código encontrou o buraco operacional: CSV sempre ligado, `tp arena_vorgar`, comandos, overlays e latência artificial estão escritos no `23`/`28`, mas **não existem**. A afinação reproduzível espera pelo `TuningRecorder`; os 5737 auto-testes provam coerência, não feel.

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

⚠️ O catálogo não finge WP9/WP15: morte ainda não compra/grava a carta, IDs de objecto fecham nos pacotes seguintes e os 31 inimigos futuros não têm modelo/animação/hitbox. As perguntas 23 e 29 do [`99`](spec/99-perguntas-abertas.md) continuam abertas; o `67` não escolheu por Mateus/Rico.

## 2. Decisões que mudaram documentos de execução antigos

**~35 decisões, das quais estas são as que mais mudam trabalho já escrito.** A lista completa e por ordem está no [`DECISOES.md`](DECISOES.md).

| Decisão | Onde está | O que atinge |
|---|---|---|
| ⭐ **Piso de 30%** — nenhuma defesa reduz um golpe abaixo disso | [`39`](spec/39-estudo-profundo.md) §1 | WP2 |
| ⭐ **Soft cap aos ~40** — sem ele o nível 100 ganha jogos | [`39`](spec/39-estudo-profundo.md) §2 | WP2, WP9 |
| ⭐ **Interrupção e hiper-armadura** — sem isto armas lentas não existem | [`39`](spec/39-estudo-profundo.md) §4, [`41`](spec/41-estudo-armas-e-golpes.md) §4 | WP1, WP5 |
| ⭐ **Contra-ataque +30%** por bater enquanto o inimigo ataca | [`41`](spec/41-estudo-armas-e-golpes.md) §3 | WP1 |
| ⭐ **Sem slots: mana sem regeneração + meditação; artes gastam mana** | [`54`](spec/54-mana-meditacao-e-tracos-de-classe.md), [`66`](spec/66-catalogo-de-magia.md) | WP4, WP5, WP11 |
| ⭐ **Espólio garantido — baralho de 10 sem reposição** | [`40`](spec/40-decisoes-espolio-magia-inventario.md) §3, [`43`](spec/43-estudo-espolio-inventario-mundo.md) §2 | WP6, WP7, WP9 |
| ⭐ **Descanso recarrega o mapa · 10 reaparições · não se farma** | [`40`](spec/40-decisoes-espolio-magia-inventario.md) §1 | WP6, WP9 |
| ⭐ **Feitiços únicos + melhoria de feitiços em 3 eixos** | [`40`](spec/40-decisoes-espolio-magia-inventario.md) §12–13, [`42`](spec/42-estudo-magia.md) §6 | WP4 |
| ⭐ **A magia é a área mais vasta do jogo** | [`40`](spec/40-decisoes-espolio-magia-inventario.md) §6, [`42`](spec/42-estudo-magia.md) | WP3, WP4 |
| ⭐ **Armas por família, não por classe** | [`35`](spec/35-estudo-referencia.md) §1, [`41`](spec/41-estudo-armas-e-golpes.md) §2 | WP5 |
| ⭐ **O contrato de honestidade** — 5 cláusulas, e o teste do rolamento | [`38`](spec/38-ataques-e-honestidade.md) | WP6, WP7, WP15B |
| ⭐ **Toda a zona fecha um círculo · descanso à vista do chefe** | [`39`](spec/39-estudo-profundo.md) §8 | WP8 |
| ⭐ **Carregamento por área · a porta de nevoeiro é a barreira** | [`43`](spec/43-estudo-espolio-inventario-mundo.md) §6 | WP14, WP8 |
| ⭐ **Mochila sem limite — só o equipado pesa** | [`40`](spec/40-decisoes-espolio-magia-inventario.md) §9 | WP11, WP5 |
| ⭐ **Controlos configuráveis no jogo** | [`45`](spec/45-controlos-configuraveis.md) | WP11 |
| **Descrição em todo o objecto, colocado por relevância** | [`39`](spec/39-estudo-profundo.md) §12 | WP9, WP13 |
| **10 anéis / ~70 anéis** | [`37`](spec/37-aneis-e-elementos.md) | WP5 |
| **Física: gravidade, queda, balística, empurrão** | [`36`](spec/36-fisica.md) | WP1, WP8 |

---

## 3. ⭐ A ordem, e por que é esta

⚠️ **Actualizada a 31-07 pelo [`46`](spec/46-coerencia-bioma-raca-item.md):** as **24 fichas** (12 de bioma + 12 de raça) vêm **antes** dos catálogos. São 8 linhas cada, meio dia de trabalho, e é delas que saem as descrições de tudo — com coerência de graça. Ao contrário, cada descrição é inventada de novo e a regra anti-mistura é impossível de aplicar porque não há biomas definidos para comparar.



**Não é uma lista de desejos — é uma cadeia de dependências.** Cada passo desbloqueia o seguinte.

```
0. ✅ O código veio para o repositório               (feito, PR #13)
        ▼
1. ✅ AS 24 FICHAS ── 12 de bioma (spec/49) + 12 de raça (spec/50)
        │           O MOTOR DE PRODUÇÃO ESTÁ COMPLETO — cada descrição
        │           é agora uma intersecção de duas fichas que existem
        ▼
2. Os CATÁLOGOS  (WP4 magia · WP5 armas e armaduras · WP6 bestiário)
        │           cada item = intersecção de uma ficha de bioma
        │           com uma de raça — a descrição sai quase sozinha
        │
        ├──► desbloqueia AS IMAGENS ──► não se desenham 120 armas
        │                               sem saber quais são
        │
        └──► desbloqueia O CONTEÚDO ──► o motor é data-driven:
                                        o catálogo É o jogo
        ▼
3. Os SISTEMAS que faltam  (saves: fundação ✅, faltam os clientes · interrupção ·
        │                   contra-ataque · baralho · soft caps · piso de 30% ·
        │                   carregamento por área)
        ▼
4. O MUNDO  (WP8: círculos, atalhos, 12 biomas, descanso à porta do chefe)
        ▼
5. O ALINHAMENTO dos documentos antigos contra o DECISOES.md
```

### Porque é que as fichas vêm antes do catálogo

⭐ **Porque são o motor de produção.** 12 fichas de bioma + 12 de raça = **24 fichas de 8 linhas**, e cada uma das ~300 descrições do jogo é **uma intersecção de duas delas**. Se a ficha do bioma diz *"obsidiana"* e a da raça diz *"usam os ossos dos inimigos"*, o machado escreve-se sozinho.

⚠️ **Ao contrário, cada descrição é inventada de novo, nenhuma combina com as outras, e a regra anti-mistura do [`46`](spec/46-coerencia-bioma-raca-item.md) §4 é impossível de aplicar** — não há biomas definidos contra os quais comparar.

### E porque é que o catálogo vem antes dos sistemas

As imagens seguem a mesma ordem: os ícones de armas e dos três feitiços da Fatia 1 já existem; os **11 ícones de armadura** continuam por gerar, e os itens fora da fatia esperam pela sua coluna. O motor é data-driven por desenho ([`44`](spec/44-prototipo.md) §2): *“nenhum número de combate vive em código”*. **Escrever o catálogo é, literalmente, produzir conteúdo jogável.**

### E o alinhamento vem por último de propósito

É limpeza — necessária, mas **não produz nada novo**, e metade dele resolve-se sozinho à medida que os catálogos se reescrevem.

---

## 3b. ⭐ As lacunas vivem num sítio só

⚠️ **Ficheiro novo: [`LACUNAS.md`](LACUNAS.md)** — tudo o que foi identificado como buraco e **ainda não tem dono**, agrupado pela volta em que deve entrar.

**Porque existe:** as lacunas que o Claude encontra a rever viviam em **comentários de PR**. Um comentário lê-se uma vez e desaparece — e uma lacuna esquecida é uma que se descobre no fim, quando custa dez vezes mais. **Encontrou-se uma lacuna, escreve-se lá no mesmo acto.**

## 4. O que é dos donos, e só deles

Está tudo no [`99-perguntas-abertas.md`](spec/99-perguntas-abertas.md). **Nenhuma destas trava o trabalho** — todas têm proposta escrita, e o Fable avança com a proposta enquanto elas não fecham.

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
| **Adjectivos não são spec** | *"combate responsivo"* não é nada. *"0,60 s, invencibilidade dos 0,08 aos 0,38"* é |
| **Coluna `Fatia 1?`** | em todo o catálogo. É o que trava o escopo |

---

## 6. O risco, dito uma vez

Mundo vasto + ~61 chefes + 10+ biomas + ~120 armas + 30 armaduras + ~70 anéis + catálogo de magia largo, **feito por duas pessoas e dois agentes**.

**Os donos sabem e decidiram avançar** — e a decisão é deles. Fica registado que a alavanca que dá vastidão sem custar produção são os **círculos e atalhos** ([`39`](spec/39-estudo-profundo.md) §8), e que a coluna `Fatia 1?` é o que impede o catálogo de virar um plano de dez anos.

---

## Onde continuar

| Quem | O quê |
|---|---|
| **Codex** | **tarefa 3.3 — armas e armaduras:** 7 golpes universais, melhoria sem +10%, estados, ~70 anéis e Assassino |
| **Fable** | não duplicar o WP4: o [`66`](spec/66-catalogo-de-magia.md) já fechou o catálogo; a identidade do Assassino entra na tarefa 3.3 |
| **Mateus** | ⏳ **6 instruções do Rico à espera do 👍** — [`DECISOES.md`](DECISOES.md), 31-07 · noite. E os PRs #14, #15, #16 |
| **Donos** | as perguntas 24, 28 e 32 do [`99`](spec/99-perguntas-abertas.md), e uma gravação para a narrativa |
| **Claude** | rever o que chega · ⭐ **gerar os 11 ícones de armadura** (fatia 1, prioridade sobre biomas e raças) |

### As três voltas de 31-07, e onde estão

| PR | Volta | Auto-teste |
|---|---|---|
| [#14](https://github.com/MateusJuni0/worldrpgs/pull/14) | 12 fichas de bioma · fecha as perguntas 4 e 13 | 130 → **160** |
| [#15](https://github.com/MateusJuni0/worldrpgs/pull/15) | 12 fichas de raça · o motor das 24 fichas fica completo | → **194** |
| [#16](https://github.com/MateusJuni0/worldrpgs/pull/16) | famílias, armadura, kits · a tensão da armadura resolvida | → **226** |
