# 75 — Artes de arma e movesets: duas mãos mudam a opção, não o número

> **Pedido directo do Mateus, 01-08-2026:** *"temos que criar o mesmo sistema do Dark Souls 3 de weapon arts. Que as armas empunhadas em duas maos tenham habilidade especial para lancar. A gente tem 70 armas, entao podemos ter 70 movesets diferentes, um pra cada arma."*

Este documento segue o protocolo do [`31`](31-referencias.md): mede a referência, nomeia a diferença e constrói a nossa resposta sem copiar nomes, animações, valores ou assets comerciais. O contrato de honestidade do [`38`](38-ataques-e-honestidade.md) aplica-se também a quem joga: toda a arte declara momento de compromisso, curva de seguimento, vector de fuga, anúncio sonoro e equivalente visual.

⚠️ **Duas contagens não encaixam e não são corrigidas à socapa.** O pedido fala em **70 armas**; o catálogo `[DECIDIDO]` do [`68`](68-catalogo-de-armas-armaduras-e-aneis.md) e `equipment.json` contém **120 fichas**. Os cálculos abaixo mostram as duas escalas. Reduzir o catálogo exige decisão nova dos donos.

## 1. O que DS3 faz realmente

### Evidência

| Facto | Evidência | Confiança |
|---|---|---|
| A skill gasta **FP**, a mesma reserva usada por magia; não é stamina normal | O [manual Web oficial da FromSoftware](https://www.fromsoftware.jp/manual/darksouls3/ps4/action2.html) diz que a skill reduz a barra de FP e que sem FP não produz o efeito. Acesso: 01-08-2026 | alta · fonte primária |
| A configuração das mãos muda **qual comando fica acessível**, não cria em regra duas skills intrínsecas por arma | O mesmo manual manda empunhar a arma direita a duas mãos para usar a skill; um escudo com encaminhamento permite usar **essa skill da arma direita** sem trocar para duas mãos. O guia oficial repete que a skill do escudo tem prioridade enquanto o escudo está empunhado. [Starter Guide oficial](https://d1vtv52f4vjbmu.cloudfront.net/manuals/darksouls3/goty/ps4/DarkSouls3Goty_PS4_StarterGuide_GBQS.pdf). Acesso: 01-08-2026 | alta · fonte primária |
| Algumas skills abrem seguimentos no ataque leve/pesado | O manual oficial diz que, conforme a arma, os dois botões de ataque produzem derivações depois da skill | alta · fonte primária |
| A intenção é reforçar a identidade da **categoria** de arma | Miyazaki diz que o sistema nasceu para aumentar as características distintas de cada categoria. [Entrevista Xbox Wire](https://news.xbox.com/en-us/2022/05/27/from-softwares-hidetaka-miyazaki-on-the-secrets-of-elden-rings-development/), 27-05-2022. Acesso: 01-08-2026 | alta · responsável directo |
| Movesets e skills são largamente partilhados, com excepções | A tabela comunitária liga cada arma a uma categoria e skill; a página de skills registava **85 skills no jogo base** e **98 depois da primeira expansão**, menos do que uma combinação completamente nova por arma/configuração. [Tabela de armas](https://darksouls3.wikidot.com/weapons-tabview) · [skills](https://darksouls.fandom.com/wiki/Skill). Acesso: 01-08-2026 | média · catálogo comunitário; a contagem de 98 não inclui a segunda expansão e não é usada como total final |
| Entrar num ataque é aceitar a animação; não se sai para esquiva a meio | Uma análise académica compara os grafos de estado e observa que o ataque de DS3 não pode ser cancelado depois de começar. [Meaningful Choices in Combat Systems](https://reposit.haw-hamburg.de/bitstream/20.500.12738/15849/1/MA_Meaningful_choices_combat_systems.pdf), p. 15. Acesso: 01-08-2026 | média · análise secundária |

### Comparação obrigatória: eles · nós · diferença

| Eixo | Eles | Nós antes deste pacote | Diferença |
|---|---|---|---|
| Recurso | FP separado da stamina; partilhado com magia | mana já `[DECIDIDO]` nos [`54`](54-mana-meditacao-e-tracos-de-classe.md), [`66`](66-catalogo-de-magia.md) e [`41`](41-estudo-armas-e-golpes.md) | intencional: chama-se mana, mas cumpre a mesma separação da stamina |
| Uma/duas mãos | muda a skill acessível ou encaminhada; em regra a arma conserva a sua skill | o [`34`](34-catalogo-e-comandos.md) já decide **duas artes diferentes por arma** | intencional: a proposta do Mateus vai além da referência e dá uma escolha nova à mesma tecla |
| Compromisso | ataque iniciado prende a personagem à animação | havia texto de “compromisso”, mas não estado executável nem frame | lacuna real: passa a existir sessão com arranque, compromisso, activos e recuperação; nunca há cancelamento voluntário |
| Seguimento e fuga | variam por skill/moveset | as artes não declaravam curva nem vector | lacuna contra o `38`: ambos passam a ser dados obrigatórios |
| Som | animação/efeito comunica a acção | existia som de impacto, não contrato de anúncio por arte | lacuna: cada arte anuncia o compromisso no bus informativo e tem forma visual equivalente |
| Partilha | categoria/moveset é a unidade principal; algumas armas recebem excepções | 8 famílias, mas o pedido propõe 70 conjuntos | a diferença é de produção, não de ambição jogável |

**Conclusão da comparação:** não copiamos a prioridade de escudo nem a possibilidade de executar uma versão degradada sem recurso. Conservamos o problema resolvido — uma opção especial legível, paga e comprometida — e usamos a decisão própria uma mão/duas mãos.

## 2. Setenta movesets únicos: a conta honesta

O [`41`](41-estudo-armas-e-golpes.md) fixa **11 entradas por conjunto**. Duas são artes (uma e duas mãos); as outras nove são ataques/encadeamentos. A perspectiva é escolha `[DECIDIDO]`, portanto a auditoria já conta **dois clips por entrada**: corpo de terceira pessoa + viewmodel de primeira pessoa.

### Base medida local

`UAL1_Standard.glb`, a biblioteca CC0 que já está em `game/assets/`, contém **43 clips**. O GLB tem **5 150 952 bytes** de buffer views referenciados pelas animações: média observada **119 790 bytes/clip**. Isto mede payload importado, não RAM descomprimida; RAM real pode ser maior e só fecha quando os clips finais existirem.

| Hipótese para 70 armas | Conta | Clips | Payload projectado pela média UAL |
|---|---:|---:|---:|
| 70 movesets totalmente únicos | `70 × 11 × 2 perspectivas` | **1 540** | **175,9 MiB** |
| moveset por 8 famílias + duas artes atribuídas por arma | `8 × 9 × 2 + 70 × 2 × 2` | **424** | **48,4 MiB** |
| **diferença** |  | **−1 116 clips (−72,5%)** | **−127,5 MiB** |

O catálogo actual de 120 muda a escala, não a conclusão:

| Hipótese para 120 fichas actuais | Clips | Payload projectado |
|---|---:|---:|
| 120 movesets totalmente únicos | **2 640** | **301,6 MiB** |
| 8 famílias + duas artes atribuídas por arma | **624** | **71,3 MiB** |
| **diferença** | **−2 016 clips** | **−230,3 MiB** |

### Tempo: sensibilidade, não promessa

Não existe ainda uma cadência medida do animador deste projecto. A tabela é deliberadamente uma **estimativa paramétrica** por clip completo — bloquear, limpar, exportar, importar, marcar activos/compromisso/som e testar clipping. Não inclui conceito, som, VFX, rede, balanceamento nem as sessões de feel.

| 70 armas | a 0,5 dia/clip | a 1 dia/clip | a 2 dias/clip |
|---|---:|---:|---:|
| 70 únicos · 1 540 clips | **770 dias-pessoa** | **1 540** | **3 080** |
| famílias + artes · 424 clips | **212 dias-pessoa** | **424** | **848** |
| diferença | **558** | **1 116** | **2 232** |

Mesmo o extremo de 0,5 dia/clip é um cenário de planeamento optimista, não uma medição. O custo de execução por frame não cresce com todos os clips se só o conjunto equipado for residente; o risco para a Iris Xe/8 GB é carregar bibliotecas inteiras, RAM partilhada e picos de apresentação. O streaming deve manter apenas família, artes equipadas e transições comuns residentes.

As contas de 424/624 são ainda um **tecto conservador**: assumem duas animações de arte exclusivas para cada ficha. O catálogo executável permite que várias armas apontem para a mesma definição e para os mesmos clips — como a referência faz — e só reserva excepções quando a pergunta jogável muda.

### Recomendação sem decidir a tensão

`[TENSÃO]` **“70 movesets únicos” versus a máquina/produção e o catálogo actual de 120.** O pedido do Mateus não é cortado neste documento.

`[CODEX]` **Recomendo moveset por família e arte atribuída por arma, com poucas excepções de moveset.** Razão: entrega **70/120 identidades jogáveis** pela combinação `família + arte a uma mão + arte a duas mãos + assinatura`, reduz pelo menos 72,5% dos clips na escala pedida e segue a intenção declarada pelo próprio criador da referência: categoria primeiro. Uma arte pode ser partilhada; a ficha da arma continua a escolhê-la explicitamente.

**Alternativa descartada pelo Codex, não pelos donos:** 70 conjuntos completamente únicos desde a Fatia 1. Perde 1 116 clips na escala pedida antes de produzir um segundo inimigo, duplica tudo nas duas perspectivas e transforma Lei 4 num risco de memória/pacing. **Se o Mateus mantiver os 70 únicos, a alternativa executável é faseá-los:** uma arma vertical por família, medir produção e feel, depois autorizar cada conjunto seguinte; este documento não o proíbe.

## 3. O nosso contrato executável

### 3.1. Acção e selecção

- Acção sem dispositivo: `weapon_art`, remapeável; o runtime nunca pergunta por tecla física.
- Só começa em `LIVRE`; não cancela ataque, esquiva, bloqueio, item, magia, habilidade, meditação ou troca de empunhadura.
- Uma mão resolve o slot técnico `one_hand`; duas mãos resolve `two_hands`.
- A arma que exige duas mãos arranca nesse estado, como manda o [`70`](70-fecho-dos-sistemas-de-combate.md).
- Mana insuficiente recusa antes de entrar no estado e não cobra nada. `[CODEX]` Razão: uma versão escondida/degradada cria uma terceira arte que a ficha não ensina. Alternativa descartada: imitar a execução sem FP da referência.

### 3.2. Recurso e compromisso

- A mana é cobrada ao entrar; a stamina é copiada sem alteração.
- Não existe cancelamento voluntário em nenhuma fase.
- Dano de postura pode interromper **antes** do `momento_compromisso_frame`; a mana continua gasta. A arte repõe a vida de interrupção a 100% ao começar, conforme o [`41`](41-estudo-armas-e-golpes.md) §8.
- No compromisso, a direcção e a decisão fecham. Se o corpo for interrompido depois, o efeito já comprometido resolve uma vez; não se lê input de novo.
- Activos e recuperação vêm integralmente do JSON. Nenhum frame/custo/MV vive em `.gd`.

### 3.3. Honestidade obrigatória por arte

Cada ficha resolvida traz:

| Campo | Regra |
|---|---|
| `momento_compromisso_frame` | positivo, depois do aviso e antes/igual ao primeiro activo |
| `curva_seguimento` | segmentos ordenados; termina no compromisso e fica 0°/s depois |
| `vector_fuga` | exactamente um dos nove vectores do [`38`](38-ataques-e-honestidade.md), nunca “qualquer” |
| `som_anuncio` | `cue_id`, descrição, perfil sintetizado e alcance; começa antes do compromisso |
| `sinal_visual_equivalente` | âncora, forma, início, compromisso, fim e tratamento fora do ecrã |
| `pergunta` e `verbo` | opção espacial/táctica; “mais dano” é inválido |
| `tradeoff` | o que se perde ao escolher esta resposta |

### 3.4. Base + seis níveis

O sistema consome o estado já fechado no [`68`](68-catalogo-de-armas-armaduras-e-aneis.md), sem inventar dano:

| Estado | O que abre |
|---|---|
| base | moveset/assinatura da família + duas artes base |
| +1 | uma das duas posturas e o movimento que ela torna disponível |
| +2 | troca **uma** arte escolhida; a outra empunhadura conserva a base |
| +3 | troca de escala; não altera frames nem arte |
| +4 | conversão de tipo; conserva o total base e o moveset |
| +5 | postura mestra substitui a de +1 e abre geometria estreita ou ampla |
| +6 | arte mestra ocupa os dois slots como custo de oportunidade |

## 4. Lei 2: as artes fazem perguntas

As famílias começam por pares de verbos, não por multiplicadores:

| Família | Uma mão | Duas mãos | Diferença de decisão |
|---|---|---|---|
| espada recta | atravessar linha estreita | limpar o espaço circular | alvo isolado versus grupo |
| adaga | conquistar costas | fechar duas saídas curtas | posição versus permanência ao perto |
| pesada de corte | fechar distância por queda | controlar um arco pesado | mobilidade arriscada versus espaço |
| katana | guardar contra-corte | obrigar duas respostas | timing inimigo versus sequência própria |
| haste | tirar pés/conservar mão livre | comprometer uma carga linear | controlo baixo versus alcance |
| cajado | empurrar/organizar espaço | firmar a próxima conjuração | reposicionar versus resistir a interrupção |
| arco | fixar uma linha | anunciar uma área balística | precisão versus negação de área |
| besta | gastar o ferrolho armado | comprar leitura longa | resposta imediata versus preparação |

As excepções por arma só entram quando mudam `pergunta`, `vector_fuga` ou `tradeoff`. Trocar nome, cor ou MV não conta como arte nova.

## 5. As quatro perguntas do fio solto

| Pergunta | Resposta |
|---|---|
| **Como usa o jogador?** | carrega a acção remapeável `weapon_art` quando está `LIVRE`; `toggle_grip` escolhe o slot sem menu. O altar abre postura/arte nos níveis já decididos. A ligação ao `Player`/mapa de controlos pertence aos respectivos donos e fica explicitamente em `LACUNAS.md`, não fingida aqui. |
| **Como se prova?** | `weapon_art_selftest.gd` percorre as 119 armas principais do catálogo, as duas empunhaduras e níveis 0…6; prova mana≠stamina, recusa sem recurso, bloqueio de cancelamento, compromisso, curva/vector/cues, partilha/excepções e mede resolução. Em 01-08-2026: **848 passaram, 0 falharam**, **31,275 µs p95/resolução** e **17 487 B** de catálogo serializado. O auto-teste global nunca pode descer dos 9703. |
| **De onde vêm arte e som?** | malha equipada e geometria do `GameplayCue`; anúncio/impacto usam os perfis sintetizados já existentes em `Sfx` (`attack_*`, `swing_*`, `posture_break`). A UAL CC0 é referência técnica de rig/payload, mas **não contém os movesets finais**; os clips novos são dívida do dono de animação. Zero asset comercial. |
| **Quanto custa na máquina do Rico?** | catálogo/estado puro medido: **31,275 µs p95/resolução** contra orçamento de 250 µs e **17 487 B** contra 256 KiB. Animação: 175,9 MiB de payload projectado para 70 únicos contra 48,4 MiB por família+artes, antes de RAM descomprimida. O renderer não muda neste pacote, portanto não se atribui um delta de FPS falso; a prova integrada continua a exigir 2 jogadores + 3 inimigos a 1080p/60 quando os clips existirem. |

## 6. Fronteira honesta

Este pacote pode fechar **dados, selecção, recurso, estado, compromisso, upgrade e prova dedicada** apenas dentro dos ficheiros atribuídos. Não pode ligar a nova acção ao `Player`, ao ecrã de controlos, ao `GameplayCue`, à rede nem ao `character_visual.gd`; esses ficheiros pertencem a agentes paralelos. Cada integração recebe contrato exacto no `LACUNAS.md`.

## Ligações

[`31-referencias.md`](31-referencias.md) · [`34-catalogo-e-comandos.md`](34-catalogo-e-comandos.md) · [`38-ataques-e-honestidade.md`](38-ataques-e-honestidade.md) · [`41-estudo-armas-e-golpes.md`](41-estudo-armas-e-golpes.md) · [`68-catalogo-de-armas-armaduras-e-aneis.md`](68-catalogo-de-armas-armaduras-e-aneis.md) · [`70-fecho-dos-sistemas-de-combate.md`](70-fecho-dos-sistemas-de-combate.md)
