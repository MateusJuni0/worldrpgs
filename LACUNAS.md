# LACUNAS — o que falta, e ninguém está a fazer

**Actualizado: 01-08-2026.** Mantido pelo **Claude**. É a lista de tudo o que foi identificado como buraco e **ainda não tem dono**.

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
| 🔴 | ⭐ **A fórmula da estabilidade estava invertida** — eu escrevi `dano × (estabilidade/100)`, o que fazia o broquel de 50 bloquear melhor que o escudo grande de 85. ✅ **CORRIGIDO 01-08** para `× (1 − estabilidade/100)` | [`41`](spec/41-estudo-armas-e-golpes.md) §6 |
| ✅ | ~~O espelho é mais fácil do que o parry~~ **RESOLVIDO 01-08** — janela de 0,25 s, recuperação se falhar, escala pelo instrumento, e recompensa maior quando acerta | [`53`](spec/53-chefes-ritmo-e-o-mago-forte.md) §4 |
| ✅ | ~~O intervalo de 0,20 s entre atacantes não chega~~ **CORRIGIDO 01-08** — conta-se a partir de **quando o jogador pode agir**, não do relógio. E o tecto de 2 agressores passa a garantir **rota de fuga** em vez de um número | [`38`](spec/38-ataques-e-honestidade.md) §3 |
| 🔴 | ⚠️ **Melhoria de armas (+10%/nível) é a Lei 2 quebrada** — números, não opções. *(A dos feitiços foi resolvida: o Voto passou a trocar verbos, [`53`](spec/53-chefes-ritmo-e-o-mago-forte.md) §4)* | [`51`](spec/51-familias.md) |
| ✅ | ~~61 chefes = um encontro a cada 30–40 s~~ **DECIDIDO 01-08 pelo Mateus** — 13 verdadeiros + 12 subchefes + ~36 nomeados, travessia de 8–12 min, e **24–36 portas de história abertas** para crescer no futuro | [`53`](spec/53-chefes-ritmo-e-o-mago-forte.md) |
| ⏳ | ⭐ **Ordem de corte com menor perda**, se for preciso cortar: 1.ª pessoa → 48 chefes reclassificados → 5 slots de armadura → 6 slots de anel → armas acima de 24 → feitiços acima de 24. **Não cortar:** co-op, esquiva/parry/stamina, as 8 famílias, a identidade dos 12 biomas | auditoria §4 |

---

## 🟠 Para as voltas que aí vêm

### Volta 2 — fichas de raça 🔨 *em curso*

| | Lacuna | Origem |
|---|---|---|
| 🟠 | ⚠️ **A linha "porque está neste bioma"** é a única que liga a raça ao mapa, e é a que se salta. A resposta tem de sair de uma ficha de bioma já escrita | [`46`](spec/46-coerencia-bioma-raca-item.md) §5 |
| 🟠 | **Em que biomas cada raça aparece, e o que muda em cada variante** — e a variante tem de mudar **como se luta**, não só a cor | [`46`](spec/46-coerencia-bioma-raca-item.md) §7 |
| 🟠 | ⚠️ **Santuário Branco e A Raiz** são os dois biomas mais fáceis de deixar sem raça própria. Sem habitante próprio são cenários, não lugares | revisão do PR #14 |
| 🟠 | **Mímicos e Minotauros** estão na lista de raças, mas um é armadilha e o outro é subchefe. A ficha de 8 linhas não lhes assenta | [`15`](spec/15-inimigos.md) |

### Volta 3 — armas e armaduras

| | Lacuna | Origem |
|---|---|---|
| 🟠 | **Os 7 golpes por declarar** — cadeia de leves, leve→pesado, em corrida, a rolar, a saltar, de cima, empurrão | [`41`](spec/41-estudo-armas-e-golpes.md) §1 |
| 🟠 | **Melhoria de armas** — reforço e infusão. Nunca foi escrita | [`35`](spec/35-estudo-referencia.md) §6 |
| 🟠 | **Estados alterados** — veneno, sangramento, queimadura. Nunca mencionados | [`35`](spec/35-estudo-referencia.md) §5 |
| 🟠 | **Requisitos de atributo** — quanto é "não és tu que a usas" sem proibir (Lei 3) | [`41`](spec/41-estudo-armas-e-golpes.md) |
| 🟠 | **Duas armas ao mesmo tempo, uma em cada mão** — existe no nosso jogo? | [`41`](spec/41-estudo-armas-e-golpes.md) |
| 🔵 | **Como a mira do arco comunica a queda da flecha** — sem isso o jogador aprende "o arco falha às vezes" | [`36`](spec/36-fisica.md) §3 |

### Volta 4 — magia

⭐ **A forma de entrega é obrigatória em toda a ficha** — [`55-formas-de-feitico.md`](spec/55-formas-de-feitico.md). 12 formas, e o dano é o que menos as separa.

| | Lacuna | Origem |
|---|---|---|
| 🟠 | ⭐ **Três formas que nos faltam:** perseguidor, chuva, e forma de arma (golpe de corpo a corpo feito de magia — resolve o "mago frágil ao perto" melhor que a besta) | [`55`](spec/55-formas-de-feitico.md) §5 |
| 🟠 | ⚠️ **O traçado das zonas passa a afectar a magia** — tectos, corredores, terreno partido. A chuva morre debaixo de tecto | [`55`](spec/55-formas-de-feitico.md) §2 |

⭐ **A escola vermelha já está desenhada** — [`52-mago-do-mal.md`](spec/52-mago-do-mal.md), feita pelo Claude a pedido do Mateus (é o personagem dele). O WP4 herda-a; **não a reescreve.**

| | Lacuna | Origem |
|---|---|---|
| ⏳ | ~~As 6 perguntas do mago do mal~~ ✅ **4 respondidas 31-07** (chefe portátil · sem tecto de invocados · Voto empilha 3× · instrumento livre). Faltam: que feitiços cortar, e o tecto de máquina | [`52`](spec/52-mago-do-mal.md) §11 |
| 🟠 | **Quem manda nos invocados em co-op?** *(proposta: quem os levantou)* | [`50`](spec/52-mago-do-mal.md) §9 |
| 🟠 | **Inimigos que lançam magia usam as mesmas regras?** *(proposta: sim, incluindo ser interrompíveis)* | [`42`](spec/42-estudo-magia.md), [`48`](spec/48-arcos-bestas-escudos.md) |
| 🟠 | **Quantos feitiços na fatia 1** *(proposta: 3 — dano, cura, utilidade)* | [`42`](spec/42-estudo-magia.md) |
| 🟠 | **O material de melhoria de feitiço é o mesmo das armas, ou outro?** | [`42`](spec/42-estudo-magia.md) §6 |

### Volta 5 — bestiário

| | Lacuna | Origem |
|---|---|---|
| 🟠 | ⚠️ **Preencher som + sinal visual em cada ataque do catálogo** — a ficha já tem as 12 colunas e a língua por tipo; falta conteúdo ataque a ataque | [`38`](spec/38-ataques-e-honestidade.md) §3 · [`62`](spec/62-acessibilidade-auditiva.md) |
| 🔴 | ⭐ **Implementar `GameplayCue` + renderer visual e migrar os 12 ataques actuais** — hoje `Sfx` toca o mesmo `telegraph` em todos; fazer antes de o WP6 multiplicar fichas | encontrado ao escrever o [`62`](spec/62-acessibilidade-auditiva.md) |
| 🟠 | **Massa de cada inimigo**, para o empurrão | [`36`](spec/36-fisica.md) §4 |
| 🟠 | **Almas por inimigo, e o total por zona** — com o tecto de 10 reaparições, cada zona tem orçamento fixo | [`40`](spec/40-decisoes-espolio-magia-inventario.md) §2 |

### Volta 7 — chefes

| | Lacuna | Origem |
|---|---|---|
| ✅ | ~~⚠️ **Desenho de arena de chefe**~~ **RESOLVIDO 01-08** — tamanho por camada, obstáculos/refúgios, duas rotas e perguntas SEPARAR/JUNTAR para co-op | [`61`](spec/61-arenas-de-chefe.md) |
| 🟠 | **Um subchefe pode ser fugido de vez, ou reaparece?** | [`46`](spec/46-coerencia-bioma-raca-item.md) §6 |
| ✅ | ~~**Como se sinaliza um precipício**~~ **RESOLVIDO 01-08** — faixa ≥ empurrão máximo + 0,5 m, padrão sem depender de cor, silhueta, movimento e som redundante | [`61`](spec/61-arenas-de-chefe.md) §5 |
| 🟠 | **As 12 fichas de arena depois de Vorgar** — 11 guardiões + Ultra; quais usam queda, obstáculos, SEPARAR/JUNTAR e prova em ambas as perspectivas | [`61`](spec/61-arenas-de-chefe.md) §7 |

### Volta 8 — sistemas

| | Lacuna | Origem |
|---|---|---|
| 🟠 | **A curva de nível é linear, devia ser cúbica** · **"XP" devia ser "almas"** | [`35`](spec/35-estudo-referencia.md) §3 |
| ✅ | ~~**Sistema de saves sem uma linha**~~ **RESOLVIDO 01-08** — formato campo a campo, morte sem save-scumming, escrita atómica, recuperação e migração, com código e testes | [`59`](spec/59-saves.md) · `game/src/autoload/save_system.gd` |
| 🟠 | ⚠️ **A leitura do mapa tem de ser decidida ANTES de o WP8 traçar as zonas** — senão há zonas impossíveis de mapear | [`57`](spec/57-mapa-e-minimapa.md) §5 |
| 🟠 | ⚠️ **Os packs CC0 estão em `art/`, mas quase nada está integrado em `game/`.** Biblioteca não é runtime: cada modelo/som ainda precisa de importação, orçamento e prova no motor | [`22`](spec/22-assets.md), verificado no [`64`](spec/64-criacao-de-personagem.md) |
| 🟠 | ⚠️ **Ligar os três produtores ao `SaveSystem`** — o greybox ainda não tem almas/inventário/mapa persistentes; quando cada sistema entrar, tem de emitir os eventos do [`59`](spec/59-saves.md) §3. Hoje `main.gd` ainda diz «Nada se perdeu» | encontrado ao implementar o [`59`](spec/59-saves.md) |
| 🔴 | ⭐ **A infra-estrutura de afinação escrita no `23`/`28` não existe** — sem CSV, `tp arena_vorgar`, `latencia`, overlays ou fixtures A/B; só a semente fixa do greybox existe. Construir `TuningRecorder` antes de chamar qualquer valor “confirmado” | encontrado ao verificar o código para o [`63`](spec/63-como-se-afinam-os-numeros.md) |
| 🔴 | **O criador não existe** — o greybox só troca classe com F6. Faltam ecrã/slots, `appearance.json`, validação do nome, save v2 + migração v1 e teste 6 origens × armas | encontrado ao escrever o [`64`](spec/64-criacao-de-personagem.md) |
| 🟠 | **Os corpos Quaternius, classes KayKit e 11 peças não têm retarget/encaixe provado; os 2 conjuntos de voz também não existem** | conteúdo e integração exigidos pelo [`64`](spec/64-criacao-de-personagem.md) |
| 🔴 | **Áudio sem arquitectura:** os 12 sons sintetizados vão todos para `Master`; faltam `audio_catalog.json`, buses, `AudioDirector`/`MusicDirector`, 8 vozes reservadas e ducking que proteja `GameplayInfo` | encontrado ao escrever o [`65`](spec/65-musica-e-ambiente.md) |
| 🔴 | **Zero música e zero loop de ambiente.** Os 182 OGG são 181 SFX + 1 preview; faltam 6 peças, 3 stingers, Brumal/Toca, vozes, orcs, carne e magia própria | inventário medido no [`65`](spec/65-musica-e-ambiente.md) |
| 🟠 | **Lock-on em 1.ª pessoa** — duas opções propostas, nenhuma escolhida | [`29`](spec/29-perspectiva.md) |
| 🟠 | **A cura à distância funciona com que latência?** | [`42`](spec/42-estudo-magia.md) |

### Volta 9 — mundo

| | Lacuna | Origem |
|---|---|---|
| 🟠 | **Nadar, escalar, saltar: existem?** Nunca foram mencionados | [`36`](spec/36-fisica.md) |
| 🟠 | ⚠️ **O traçado das zonas e o orçamento de memória desenham-se juntos** — um atalho entre zonas distantes obriga a ter as duas prontas | [`43`](spec/43-estudo-espolio-inventario-mundo.md) §6 |

---

## 🔵 Quando houver tempo

| | Lacuna | Origem |
|---|---|---|
| 🔵 | ⚠️ **A conversão visual, passos 1–3** — luz, névoa e gradação de cor. **Custa horas e vale mais do que trocar modelos** | [`47`](spec/47-do-greybox-ao-visual.md) §4 |
| 🔵 | **Capturas em todo o marco** — o critério que impede o visual de parar sem ninguém dar por isso | [`47`](spec/47-do-greybox-ao-visual.md) §5 |
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
| **Ficou** | **~460 MB** · 3298 ficheiros |
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
| 🔴 | ⭐ **Meditar 40 s em qualquer sítio não é um custo — é tempo morto.** A mana volta sempre a 100% e as artes continuam a dizer que custam "energia", que foi revogada. **Não há economia de recursos entre descansos.** Proposta: um recurso único, meditação com **cargas finitas** (2 por descanso) e a repor **40–50%**, não 100% | [`54`](spec/54-mana-meditacao-e-tracos-de-classe.md) §3 |
| 🔴 | ⭐ **Uma mão / duas mãos não tem comando nem estado.** Cada arma declara duas artes e **não há forma de trocar** — é conteúdo que não pode ser seleccionado. É a regra do fio solto a apanhar-nos. Precisa de input, estado e transição (~12 frames, interrompível) | [`34`](spec/34-catalogo-e-comandos.md) §2b |
| 🔴 | ⭐ **Os 8 favoritos mudáveis a qualquer momento = os 25 feitiços estão sempre preparados.** Morre a decisão *"o que levo para esta zona?"*. **Só se muda fora de combate ou no descanso** | [`54`](spec/54-mana-meditacao-e-tracos-de-classe.md) §6 |
| 🟠 | ⚠️ **Parry com 4 frames de arranque é reactivo demais** — no DS3 o mais rápido começa aos **8**. Com 4, aparas depois de já veres o golpe. **Subir para 8–12** | [`01`](spec/01-combate.md) |
| 🟠 | ⚠️ **Soft cap de 40 em tudo é errado** — DS2/DS3 usam curvas diferentes por atributo. Proposta: **vida 20/50 · stamina 20/40 · mana 35 · dano 40/60 · carga 30/50/70** | [`39`](spec/39-estudo-profundo.md) §2 |
| 🟠 | **Queda fatal aos 25 m** — o DS2 mata aos 19,5 m e os limiares do género rondam os 20. **Baixar para 20 m** | [`37`](spec/37-aneis-e-elementos.md) §3 |
| 🟠 | ⚠️ **Falta o estado de sobrecarga (>100%)** — hoje um jogador a 71% e outro a 140% movem-se igual. **Acima de 100%: sem rolamento nem sprint, só marcha** | [`39`](spec/39-estudo-profundo.md) §3 |
| 🟠 | **NG+ com +40% em vida E dano é demasiado grosseiro** — separar. Proposta: **+30% vida / +15% dano**, ciclos seguintes **+5%/+3%** | [`58`](spec/58-fim-do-jogo-ciclos-e-a-curva.md) §5 |
| 🟠 | **Contra-ataque +30% universal** — no DS3 é **só para perfuração**. Proposta: ×1,30 perfuração · ×1,40 lança · ×1,45 só na estocada da katana | [`41`](spec/41-estudo-armas-e-golpes.md) §3 |
| 🟠 | ⭐ **Separar "contra-ataque" de "instável"** — apanhar alguém a meio do ataque e apanhar alguém desequilibrado são coisas diferentes. Instável só em guarda quebrada, parry falhado e aterragem pesada | [`41`](spec/41-estudo-armas-e-golpes.md) §3 |
| 🟠 | ⭐ **Não há ressalto contra paredes nem escudos.** Um golpe que bate numa parede devia ser cancelado com 12–18 frames de recuo. **Sem isto, o espaço quase não interage com o combate** | [`38`](spec/38-ataques-e-honestidade.md) |
| 🟠 | **O piso de 30% aplicado a escudos elimina os escudos de 100% físico** — misturámos absorção de armadura com bloqueio. **São sistemas diferentes** | [`48`](spec/48-arcos-bestas-escudos.md) §3 |
| 🔵 | **Regeneração de stamina: o DS3 não penaliza entre 30–70%** — a nossa penalização de −10% no escalão médio não existe lá | [`41`](spec/41-estudo-armas-e-golpes.md) §5 |

### ⭐ Gramática de combate que nos falta (secção 4 da auditoria)

Vocabulário de situações que o DS tem e a nossa spec **não menciona em lado nenhum**:

| | |
|---|---|
| 🟠 | **Ataques inimigos que atravessam escudo** |
| 🟠 | **Esmagamento de guarda dedicado** — um golpe cujo trabalho é abrir quem bloqueia |
| 🟠 | ⭐ **Mesmo aviso, dois tempos de largada** — o inimigo faz a mesma pose e larga mais tarde. **É o que ensina a não rolar por reflexo** |
| 🟠 | **Ramos condicionais de combo** — a sequência muda conforme o que tu fazes |
| 🟠 | ⭐ **Falsa recuperação** — parece que acabou, e não acabou |
| 🟠 | ⭐ **Castigo de cura** — o inimigo reage a ver-te beber |
| 🟠 | **Fingir morte, e atacar ao levantar** |

### E os sistemas deles que o Codex diz para **não** copiar

Atributo que controla i-frames *(viola a nossa Lei 1)* · durabilidade *(só gera viagens ao descanso)* · invasões, pactos e sinais de invocação *(resolvem emparelhamento público — nós somos dois)* · penalização de vida máxima por morrer *(espiral de fracasso)*.

⭐ **E disse que o nosso mapa é melhor do que não ter mapa**, para dois amigos. Fica.

---

| 🔴 | ⭐ **A semente fixa do acaso — é a única parte do banco de ensaio que tem de ser feita JÁ.** Se o baralho de espólio, a variação de IA e a colocação forem escritos sem semente, enxertá-la depois obriga a mexer em tudo. **Escrita agora custa uma linha por sítio** | [`60`](spec/60-o-agente-que-joga.md) §2 |

---

## 🕳️ Buracos de sistema — coisas que NUNCA foram escritas

**Varrimento de 01-08.** Não são detalhes por afinar: são sistemas inteiros que a spec assume e nunca definiu. Ordenados por quanto custa descobri-los tarde.

| | Buraco | Porque dói tarde |
|---|---|---|
| ✅ | ~~⭐ **Sistema de saves**~~ **ESCRITO E IMPLEMENTADO 01-08** — dois domínios, escrita atómica, backup, checksum, recuperação e migrações | [`59`](spec/59-saves.md) · 19 auto-testes novos |
| ✅ | ~~⭐ **Packs CC0 por descarregar**~~ **RESOLVIDO 01-08** — modelos e 182 OGG estão em `art/`; integração no jogo continua nas linhas próprias abaixo/acima | [`CREDITS`](CREDITS.md), [`22`](spec/22-assets.md), [`65`](spec/65-musica-e-ambiente.md) |
| 🔴 | ⚠️ **O `.gitignore` NÃO trava os binários, ao contrário do que o [`game/CLAUDE.md`](game/CLAUDE.md) afirma.** Ele diz *"Binários: modelos, texturas, áudio, builds — `.gitignore` já os trava"*. **É falso:** o `game/.gitignore` trava `*.zip`, `*.exe`, `*.pck` e mais nada — `.glb`, `.gltf`, `.fbx`, `.obj`, `.png` e `.ogg` passam. O `.gitignore` da raiz só trava `art/models/_local/` e `art/audio/_local/`. **Consequência:** um pack CC0 largado em `art/models/` entra no repositório **público e para sempre** (o git guarda o histórico). Precisa de decisão antes da fase 1.2 — ver abaixo | encontrado 01-08 ao preparar a fase 1.2 |
| 🟠 | ⭐ **Os packs entraram, mas NENHUM MODELO ESTÁ NO JOGO.** A fase 1.2 tinha três partes: descarregar ✅ · importar em `game/` ⬜ · substituir as cápsulas ⬜. **Só a primeira está feita.** As cápsulas continuam lá, e o jogo continua greybox | fase 1.2, 01-08 |
| 🔴 | ⭐ **A animação de esqueleto CONTINUA POR MEDIR** — é o único risco técnico real, aberto desde o [`44`](spec/44-prototipo.md) (*"cápsulas não são personagens animados"*). ⭐ **A ferramenta chegou:** a *Universal Animation Library* (CC0, esqueleto partilhado) está em `art/models/`. Falta pôr N personagens animados em cena e medir na Iris Xe. **Sem esse número, a folga de 6× do M1 é orçamento, não garantia** | fase 1.2, 01-08 |
| 🔵 | **120 MB dos 410 são formatos que o Godot não usa** — `.fbx`, `.obj`, `.mtl`, `.stl`, `.dae`, duplicados do `.glb` que já lá está. Entraram porque a decisão foi *"tudo no repositório"*, e limpar depois obriga a reescrever a história. *Se algum dia se reescrever o histórico por outra razão, aproveita-se* | fase 1.2, 01-08 |
| ⏳ | ~~⭐ **Onde vivem os modelos CC0: no repositório ou em `_local/`?**~~ ✅ **DECIDIDO 01-08 pelo Rico** — no repositório, com o custo à vista. Custo real medido: **410 MB** empacotados, 6451 ficheiros. *(registo do que era:)* O [`22`](spec/22-assets.md) diz que CC0 *pode* entrar, mas ninguém pesou o tamanho nem o facto de o git nunca esquecer. **É decisão dos donos** porque é praticamente irreversível: 1 pack Kenney ≈ 2–10 MB, mas o conjunto de personagens+animações+natureza+dungeon anda pelas **centenas de MB**, e um `git clone` passa a custar isso a toda a gente, para sempre. *Proposta: `art/models/` no repo só para o que o jogo carrega mesmo (poucos MB, optimizado), e os packs crus em `_local/`* | encontrado 01-08 |
| ✅ | ~~⭐ **Desenho de arena de chefe**~~ **ESCRITO 01-08** — 13 arenas seladas, bolsas abertas para subchefes, bordo legível, nevoeiro/carregamento e espaço desenhado para dois | [`61`](spec/61-arenas-de-chefe.md) |
| ✅ | ~~O fim do jogo~~ **ESCRITO 01-08** — escolha final que **os dois têm de concordar**; estrutura fixada, conteúdo depende das 7 perguntas de narrativa | [`58`](spec/58-fim-do-jogo-ciclos-e-a-curva.md) |
| ✅ | ~~Ciclo novo (NG+)~~ **ESCRITO 01-08** — +40% no NG+, +8% por ciclo, ⚠️ **tecto no NG+7**. E a **Brasa** sobe UMA zona sem recomeçar o jogo | [`58`](spec/58-fim-do-jogo-ciclos-e-a-curva.md) |
| ✅ | ~~**Criação de personagem**~~ **ESCRITO 01-08** — seis presets sem caminhos fechados, aspecto finito, voz independente, nome seguro, revisão e save atómico | [`64`](spec/64-criacao-de-personagem.md) |
| ✅ | ~~⭐ **Quem afina os números**~~ **ESCRITO 01-08** — inventário, ordem causal, papéis, passos máximos, A/B, diagnóstico e critério para congelar sem transformar partidas em finais | [`63`](spec/63-como-se-afinam-os-numeros.md) |
| ✅ | ~~⚠️ **Desligar a meio de um chefe**~~ **RESOLVIDO 01-08** — sem progresso parcial; commit autoritativo em HP zero; recibo persistente e idempotente para a queda depois da morte | [`59`](spec/59-saves.md) §8 |
| 🔵 | **Medir p95 da escrita com o mapa completo na máquina do Rico** — a fixture actual tem guarda < 64 KiB; o orçamento cheio é 2 MiB e ainda não existe conteúdo para o medir | [`59`](spec/59-saves.md) §10 |
| ✅ | ~~**Música e ambiente**~~ **ESCRITO 01-08** — inventário real, mapa de uso, estados/transições, camadas, buses, ducking e prova; produção em falta fica vermelha acima | [`65`](spec/65-musica-e-ambiente.md) |
| ✅ | ~~⭐ **Acessibilidade auditiva**~~ **ESCRITA 01-08** — cada tipo de som informativo tem equivalente próprio de forma/direcção/timing; sem legendas genéricas e com ficha de ataque alterada já | [`62`](spec/62-acessibilidade-auditiva.md) |
| 🔵 | **Onde vivem os textos** | português decidido; falta dizer se as strings estão em ficheiro ou no código |
| 🔵 | **Comando / gamepad** | [`45`](spec/45-controlos-configuraveis.md) §5 propõe nascer agnóstico da fonte; por confirmar |
| 🔵 | **Os vendedores morrem?** | na referência alguns morrem e perde-se o stock. ⏳ donos |
| 🔵 | **Voz: Godot faz nativamente?** | [`56`](spec/56-voz-e-vendedores.md) — a validar no `→WP14` |

### ⚠️ E três que são de coerência, não de conteúdo

| | Buraco | |
|---|---|---|
| 🟠 | ⭐ **A fatia 1 ([`10`](spec/10-fatia-1.md)) foi aprovada antes de ~40 decisões** | fala de cargas de magia que já não existem, de 6 zonas, de espólio sem baralho. **Precisa de uma passagem** |
| 🟠 | **Os ~36 "nomeados"** que substituíram os chefes de campo ([`53`](spec/53-chefes-ritmo-e-o-mago-forte.md) §1) | ninguém os desenhou ainda — são 36 fichas curtas |
| 🟠 | **O Assassino** — furtividade, velocidade, sangramento | marcado no [`12`](spec/12-classes.md) pelo Fable, com os 3 guardas escritos. **Por desenhar** |

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
