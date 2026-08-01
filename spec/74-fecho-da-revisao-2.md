# 74 — Fecho da Revisão 2: contratos executáveis e limites honestos

**Estado:** Tarefa 5 executada em 01-08-2026. Este documento fecha os buracos mecânicos da [`REVISAO-2`](../docs/REVISAO-2.md); não é uma terceira revisão.

> `[CODEX]` Os valores abaixo são baselines para deixar de haver decisões escondidas no código. Quando a spec anterior não dava o número, escolheu-se a alternativa mais conservadora que preserva leitura, fuga e Lei 4. Todos esses valores ficam para validar no M2 pelo protocolo do [`63`](63-como-se-afinam-os-numeros.md). Nenhuma `[TENSÃO]` foi decidida: 41, 43–56 continuam nas mãos de Mateus + Rico, mas o runtime já não finge que a resposta existe.

---

## 1. Regras que passam a ter parâmetros

### 1.1 Habilidades e Eco

| Origem | Activação | Compromisso | Interrupção | Começo do cooldown |
|---|---:|---:|---|---|
| Guerreiro | 0,35 s | 0,18 s | antes do compromisso | compromisso |
| Feiticeiro / Eco | 0,15 s | 0,15 s | antes do compromisso | compromisso do feitiço repetido |
| Tanque | 0,50 s | 0,30 s | antes do compromisso | compromisso |
| Assassino | 0,20 s | 0,10 s | antes do compromisso | compromisso |
| Berserker | 0,60 s | 0,40 s | antes do compromisso | compromisso |
| Paladino | 0,70 s | 0,45 s | antes do compromisso | compromisso |

`[CODEX]` O compromisso fica dentro da animação e mais tarde nas acções que mudam mais o combate. Alternativa descartada: cooldown no toque da tecla, porque cobrava tentativas interrompidas sem produzir o verbo.

O **Eco** repete o último feitiço que chegou ao compromisso, usa a mira/alvo actuais, conserva tempo e interrupção do original, custa zero mana e volta a cobrar PV, cadáver ou item. Sem feitiço anterior, alvo válido ou recurso não-mana, não activa nem começa cooldown. Isto é a recomendação da pergunta 45, usada como baseline M2, não uma decisão dos donos.

### 1.2 Projécteis inimigos

| Molde | Velocidade | Rotação | Gravidade | Raio | Vida | Impacto |
|---|---:|---:|---:|---:|---:|---|
| `tiro` | 18 m/s | 0 °/s | 0 | 0,16 m | 1,2 s | primeiro corpo ou sólido |
| `perseguidor` | 9 m/s | 120 °/s | 0 | 0,22 m | 1,2 s | primeiro corpo ou sólido; perde em quebra de LOS |

`[CODEX]` 18 m/s dá cerca de 0,55 s para dez metros e conserva a telegrafia mínima; 9 m/s + 120 °/s permite ao perseguidor corrigir uma vez sem fazer curva impossível. Alternativas descartadas: contacto instantâneo, que contradizia o volume visível, e perseguição sem limite de rotação, que apagava a esquiva lateral. Validar no M2.

### 1.3 As doze formas de feitiço

Todos os contratos declaram velocidade, rotação, gravidade, raio, vida, política de impacto, contagem, cadência e pulso. `GameData.spell_delivery_contract(id)` combina a forma com os overrides da ficha.

| Forma | velocidade / rotação | raio · vida | contagem · cadência/pulso | política de impacto |
|---|---|---|---|---|
| projéctil simples | 18 m/s · 0°/s | 0,18 m · 1,5 s | 1 | primeiro corpo/sólido |
| perfurante | 20 m/s · 0°/s | 0,16 m · 1,4 s | 1 | até 3 corpos, depois sólido |
| perseguidor | 10 m/s · 120°/s | 0,22 m · 2,0 s | 1 | corpo/sólido; LOS quebra |
| orbitante | 0 · 180°/s | 0,28 m · 2,5 s | 3 · pulso 0,20 s | uma vez por alvo |
| feixe | 0 | 0,20 m · 0,60 s | pulso 0,20 s | linha visível até sólido |
| feixe rasteiro | 0 · 90°/s | 0,40 m · 1,0 s | pulso 0,20 s | linha no chão até sólido |
| barragem em cone | 18 m/s · arco 40° | 0,14 m · 1,2 s | 5 · 0,12 s | corpo/sólido por projéctil |
| chuva | 16 m/s · gravidade 9,8 | 0,18 m · 3,2 s · área 4,5 m | 20 · 0,12 s · pulso 0,40 s | corpo/chão por projéctil |
| forma de arma | 0 | 0,32 m · 0,60 s | 1 | uma vez por golpe |
| portador | 8 m/s · 90°/s | 0,30 m · 2,0 s | 3 · 0,50 s | corpo/sólido por portador |
| onda sem dano | 9 m/s | 0,15 m · 0,80 s | 1 | uma vez por alvo, sem dano |
| isco | 0 | 0,35 m · 8,0 s | pulso 1,0 s | atracção periódica, sem dano |

`[CODEX]` A família parte de velocidades já jogáveis do Dardo e de janelas de contacto legíveis; quantidades grandes distribuem-se no tempo. Alternativa descartada: um único valor por escola, porque forma e espaço — não dano — são a diferença decidida no [`55`](55-formas-de-feitico.md). Validar hitboxes, cobertura e cadências no M2 antes de produzir as 50 fichas futuras.

### 1.4 Percepção e regresso inimigo

O baseline comum passa a ser: cone **90°/15 m**; audição normal **8 m**, som de combate **20 m**; alerta **2 s** avançando **2 m**; chamada **10 m** após **0,8 s**; desistência após **6 s** ou **30 m** de casa; regresso à velocidade de perseguição; chegada a **1,2 m**; pulso visual de **1 s** que cura **100%**; dano durante o regresso readquire o alvo.

Os números já decididos vieram do [`15`](15-inimigos.md). `[CODEX]` 2 m, 1,2 m, pulso de 1 s, cura total e reaquisição são a recomendação da pergunta 53: deixam a transição visível e impedem puxar um inimigo ferido para sempre. Alternativa descartada: cura gradual fora de casa, porque recompensa exploração do leash. O runtime completo de LOS/audição/regresso é produção M2; os dados já não têm buracos.

### 1.5 Ameaças ambientais

As doze fichas têm agora `runtime_type`, `rules` e `unresolved_parameters: []`.

| Zona | Números que faltavam e agora existem |
|---|---|
| Brumal | virar 180°/s, bloquear controlo 0,5 s, cooldown 8 s |
| Selva Funda | reset 12 s |
| Fojo | dardo 18 m/s, dano 45, reset 10 s |
| Costa Quebrada | faixa 4 m, repetição 8 s |
| Fornalha | reset 12 s |
| Fulgor | dano 90, repetição 8 s |
| Raizama | raio 3,5 m, nuvem 6 s, saco 15 s |
| Cidade Afogada | movimento ×0,45 |
| Santuário Branco | cegueira a 100 |
| A Raiz | `consumivel:lanterna_raiz` na mão esquerda |

`[CODEX]` Resets de 8–15 s evitam encadear a mesma ameaça durante uma fuga; dano 45 é pressão não letal e 90 respeita o aviso de 1 s; volumes seguem os espaços já escritos. Alternativa descartada: deixar `null` até a zona ser produzida, porque o primeiro implementador voltaria a decidir o jogo sem registo. Tudo se valida por família no M2.

---

## 2. Referências para sistemas inexistentes

- **Acessórios:** a categoria fantasma foi eliminada. Os quatro sinos viraram anéis já catalogados (`fome_do_musgo`, `ganancia_mineira`, `ferro_aterrado`, `conta_afogada`). O baralho da lanterna usa `consumivel:lanterna_raiz` e `anel:eco_sem_face`. Não sobra `acessorio:*`.
- **Instrumentos:** só o `cajado` existe agora: arma principal, duas mãos, quatro escolas, `spell_power = 1,0` e multiplicador `1,0` nas doze formas. Sino, talismã, chama, relicário e híbrido foram retirados das fichas até a pergunta 56 lhes dar slot e comportamento; não há IDs prometidos sem ficha.
- **Guardiões e subchefes:** existem 24 slots estáveis. `vorgar` é `implemented`; os outros 23 têm `enemy_id: null`, `content_state: blocked_owner_q52` e nunca contam como encontro pronto. Isto reserva identidade sem fingir conteúdo.
- **Anéis:** os 70 declaram `effect_type`, `client_id` validado e afinidade num vocabulário de nove etiquetas. Afinidade é apenas recomendação/bias de loot, nunca requisito. Cinco efeitos incompatíveis foram reescritos para eventos existentes: retorno vertical autorado, abrigo de vento, atalho autorado, altar privado da dupla e a própria mancha/atalho — sem agarrar, escalada ou matchmaking público.
- **Armaduras:** as 11 iniciais são `implemented:true`; as 57 futuras dizem `effect_type:none`, `implemented:false` e esperam 44/54. Prosa genérica já não finge habilidade.

`[CODEX]` Preferiu-se migrar/remover uma promessa a criar cinco sistemas novos só para justificar conteúdo futuro. Alternativa descartada: allowlists no verificador, porque tornam uma referência pendurada num falso verde.

---

## 3. As cinco lacunas vermelhas herdadas da Revisão 1

| Lacuna | Fecho de execução |
|---|---|
| 12 feitiços só em prosa | todos têm `effect_type`, potência, duração/saída e baseline M2; Espelho aplica 0,25 s/0,6 s e escala pelo instrumento |
| melhorias genéricas dos 53 | apenas nível 0 fica disponível; `spell_upgrade(id, >0)` recusa enquanto a `[TENSÃO]` 41 estiver aberta |
| escudo mágico global fantasma | fallback 50% removido para 0%; estado `blocked_owner_q43` até afinidades por instância/família serem decididas |
| 18 perseguições sem garantia | preenchidas por papel e provadas no §4 |
| cinco acessórios sem catálogo | categoria removida e cartas migradas para IDs existentes no §2 |

Fechar aqui significa: o jogo não inventa uma resposta e o verificador não aceita a ausência. As escolhas de design 41 e 43 continuam abertas com proposta e recomendação no [`99`](99-perguntas-abertas.md).

---

## 4. As 18 velocidades de perseguição

| Papel | Velocidade | Razão | Fichas antes sem valor |
|---|---:|---|---|
| rápido | 4,6 m/s | ameaça aproxima-se, mas corrida a 5,0 ainda ganha 0,4 m/s | `skeleton_swordsman`, `sea_orc_hookbearer`, `gilded_skeleton`, `ancient_skeleton` |
| grupo | 4,0 m/s | o perigo vem da coordenação, não de ganhar a corrida | `goblin_mist_scout`, `goblin_canopy_raider`, `fungus_goblin`, `penitent_cantor`, `penitent_censer` |
| distância | 3,8 m/s | conserva posição e linha de tiro; não alcança a fuga | `goblin_canopy_slinger`, `skeleton_archer`, `cliff_windborne`, `summit_windborne` |
| armadilha | 3,4 m/s | o controlo do espaço é a arma; o corpo é deliberadamente lento | `kobold_bell_trapper`, `weaver_canopy_snarer`, `kobold_mine_trapper`, `storm_kobold`, `spore_weaver` |

O perfil pesado fica reservado em **3,2 m/s** para fichas desse papel, embora nenhuma das 18 fosse pesada. `[CODEX]` Todos ficam abaixo da corrida decidida de **5,0 m/s**. Alternativa descartada: copiar 4,2 m/s para todos, porque apagava o papel de combate.

**Prova comportamental:** para cada uma das 18 fichas, o auto-teste começa com 3,5 m de separação e simula jogador e inimigo a 60 Hz, em linha recta, até aos 34 m de leash. Exige separação sempre positiva, quebra em menos de 7 s e chegada do jogador ao leash. Não testa só `chase_speed < 5`: prova a promessa completa «correr abre distância até quebrar a perseguição».

---

## 5. Picos de frame: causa isolada, mitigação parcial

O benchmark anterior usava apenas `delta`; isso mistura tempo do motor com pacing da apresentação. A ferramenta passa a medir o intervalo real (`Time.get_ticks_usec`) e mostra o `delta` em separado, com `--window`, `--vsync` e `--gate` reprodutíveis.

Cinco UAL, Mobile/Vulkan, Iris Xe, 1920×1080, 5 s de aquecimento e 12 s de amostra:

| Modo | Média | p99 real | Pior | Resultado |
|---|---:|---:|---:|---|
| janela + VSync | 16,666 ms | 18,785 ms | 19,718 ms | falha p99 |
| fullscreen + VSync | 16,666 ms | **18,323 ms** | **19,414 ms** | falha p99; pior passa 20 ms |
| fullscreen sem VSync | 2,545 ms / 392,9 fps | 5,714 ms | 7,176 ms | custo de animação/render cabe |
| exclusivo + VSync | — | 18,698 ms | 19,492 ms | pior |
| adaptativo + fullscreen | — | 18,686 ms | 19,762 ms | pior |
| mailbox + fullscreen | — | 18,503 ms | 19,308 ms | pior |

**Diagnóstico:** não é importação (acontece antes da amostra), nem shader frio (5 s de aquecimento), nem custo de skinning/culling (sem VSync há margem de ~11 ms e as medições de 5/10 actores não escalam com contagem). O factor isolado é **pacing de apresentação/VSync no Windows + driver Iris Xe**. O `delta` reportou p99 16,666 ms na execução em que o relógio real viu 18,323 ms, por isso já não serve para aprovar estabilidade.

**Mitigação aplicada:** fullscreen nativo + VSync normal por omissão, que foi a melhor variante útil e baixou o pior histórico citado pela Revisão 2 de 21,993 para 19,414 ms. Desligar VSync passaria o tempo de frame mas trocaria o defeito por tearing; não se mascara o gate assim.

**Estado honesto:** o pior frame passa o tecto de 20 ms nesta repetição, mas o **p99 continua acima de 16,67 ms**. Não há corte de conteúdo que se justifique: a carga sem VSync prova margem grande. Falta resolver pacing/driver e executar o ensaio quente integrado 2 jogadores + 5 inimigos com IA/VFX/HUD/rede. O gate continua vermelho.

Artefacto: [`medicoes/animacao-esqueleto-2026-08-01.json`](../medicoes/animacao-esqueleto-2026-08-01.json).

---

## 6. As quatro perguntas do fio solto

| Pergunta | Resposta |
|---|---|
| **Como é que o jogador usa isto?** | As regras não criam teclas novas: habilidades usam o comando de classe; feitiços usam conjurar + mira; fugir usa corrida; ameaças usam movimento/bloqueio; equipamento ocupa os slots já declarados. Conteúdo futuro bloqueado não aparece nem equipa. |
| **Como se prova que funciona?** | `self_test.gd` cobre contratos, os 12 efeitos, referências, slots e a simulação das 18 fugas; `check-data-references.mjs` rejeita ID/cliente desconhecido; o benchmark devolve falha quando p99 > 16,67 ms ou pior > 20 ms. |
| **De onde vem a arte e o som?** | Esta tarefa reutiliza modelos/ícones/cues já catalogados. Não cria guardiões, instrumentos ou acessórios sem produção visual; os 23 encontros futuros e 57 armaduras futuras ficam explicitamente bloqueados. Ameaças conservam telegraph/descrição visual das fichas. |
| **Quanto custa na máquina do Rico?** | Os contratos não instanciam conteúdo futuro. Cinco esqueletos custam p99 5,714 ms sem VSync, mas apresentação VSync dá p99 18,323 ms; por isso o custo computacional passa e o frame pacing continua a reprovar. |

---

## 7. Veredito desta tarefa

As quatro classes pedidas pela Tarefa 5 ficaram sem parâmetros vazios, categorias fantasma ou velocidades implícitas. As decisões dos donos continuam no [`99`](99-perguntas-abertas.md) com execução segura até resposta.

O projecto, porém, continua **`not_ready`**: o p99 de apresentação ainda falha, o ensaio integrado quente 2+5 não existe, e as perguntas de orçamento de streaming/invocados (50–51) permanecem `[TENSÃO]`. Dizer `ready` agora esconderia precisamente o número que esta tarefa veio investigar.
