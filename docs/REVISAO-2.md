# Revisão 2 de 3 — isto é construível?

**Data:** 01-08-2026  
**Foco:** executabilidade, dependências, ordem de construção, Lei 4 e promessas verificáveis  
**Veredicto:** **`not_ready` para construir o jogo inteiro sem perguntas.** É possível começar amanhã pela fundação e pelo núcleo solo; não é possível terminar sequer a Fatia 1 exactamente como prometida sem uma decisão curta dos donos.

## Resposta curta

A spec deixou de ser apenas uma colecção de intenções: há um protótipo, 17 catálogos, saves atómicos, combate mensurável e **8559 auto-testes verdes**. A Revisão 2 também passou a verificar automaticamente **2380 referências/contratos** entre todos os JSON.

Mas «os dados carregam» não significa «o jogo está especificado». Persistem quatro classes de bloqueio:

1. **regras com substantivo e verbo, mas sem parâmetros ou compromisso** — projécteis, formas de feitiço, Eco, percepção inimiga e ameaças;
2. **conteúdo que aponta para uma categoria/sistema inexistente** — acessórios, instrumentos, guardiões, subchefes e efeitos de anel;
3. **produção multiplicada antes de fechar a interface** — 53 feitiços, 57 armaduras futuras, 70 anéis e 11 zonas;
4. **orçamentos da Lei 4 ainda incompatíveis ou por provar** — jitter dos esqueletos, seis zonas residentes no Fojo e invocações sem tecto dentro de oito actores.

Se cada decisão for pedida quando o programador tropeçar nela, o jogo inteiro provoca **30 paragens independentes**. A Fatia 1 provoca **12**. A ordem recomendada no §5 transforma-as em quatro gates de decisão antecipados, em vez de trinta interrupções dispersas.

---

## 1. O que foi auditado

- Contexto e autoridades: [`CODEX-CONTEXTO`](../prompts/CODEX-CONTEXTO.md), [`ESTADO`](../ESTADO.md), [`LACUNAS`](../LACUNAS.md), [`MAPA`](../MAPA.md), [`REVISAO-1`](REVISAO-1.md) e os documentos de execução ligados.
- Os 17 catálogos: `abilities`, `armor`, `attributes`, `biomes`, `combat`, `controls`, `economy`, `enemies`, `equipment`, `graphics`, `named_encounters`, `progression`, `races`, `spells`, `strings.pt`, `weapons` e `world`.
- Geradores dos catálogos de equipamento e mundo.
- Runtime e auto-testes, sem alterar as árvores reservadas ao agente `arte-e-modelos`.
- Provas de desempenho: [`game/PERF.md`](../game/PERF.md), [`23-tecnico`](../spec/23-tecnico.md), [`24-plano`](../spec/24-plano.md), [`28-testes`](../spec/28-testes.md) e a [medição de esqueletos](../medicoes/animacao-esqueleto-2026-08-01.json).

Comandos de fecho:

```text
node tools/check-coerencia.mjs
17 JSON · 2380 referências/contratos verificados · 0 erros novos

godot --headless --path game scenes/selftest.tscn
8559 passaram, 0 falharam
```

Os avisos conhecidos são deliberadamente falhas, não falsos verdes: cinco acessórios sem catálogo e onze guardiões sem ficha.

---

## 2. Achados por gravidade

| Gravidade | Achado | Consequência de construir já |
|---|---|---|
| 🔴 | 5 ataques inimigos `tiro` e 4 `perseguidor` sem física completa; 12 formas dos 53 feitiços sem contrato de colisão/cadência/expiração | cada programador inventa uma balística diferente; `tiro` é actualmente classificado como contacto instantâneo apesar de se mover |
| 🔴 | 12 feitiços de suporte já identificados sem potência/duração/saída; melhorias 53/53 semanticamente genéricas | não se consegue implementar nem provar a promessa «mago vasto e forte» |
| 🔴 | Só Vorgar resolve; faltam 11 guardiões e os 12 subchefes nem IDs têm | onze zonas prometem um gate final e um encontro intermédio que não podem ser instanciados |
| 🔴 | 57/68 armaduras dizem apenas «escolher uma resposta de `<slot>`» | a ficha parece pronta, mas não contém efeito, trigger, custo ou cliente |
| 🔴 | 70 anéis têm prosa/números, mas nenhum `effect_type` ou mapa de consumidores; cinco dependem de travessia/matchmaking inexistentes | implementar «anel» cria dezenas de sistemas laterais ou contradiz a travessia fechada |
| 🔴 | Cinco acessórios obrigatórios não têm catálogo; cinco instrumentos mágicos não existem; o cajado ignora a própria regra de força/velocidade do instrumento | loot garantido e cinco escolas/poses não chegam ao inventário nem à fórmula de combate |
| 🔴 | A IA comum especifica alerta/chamada/desistência, mas omite avanço/retorno/cura e o runtime salta esses estados | visão, som, kite e reset variam por implementação |
| 🔴 | 18 parâmetros de ameaças ambientais continuam abertos | as zonas têm descrição visual, não comportamento completo |
| 🔴 | Cinco esqueletos: p99 19,910 ms e pior 21,993 ms antes de IA/VFX/rede | falha o gate p99 ≤16,7 ms e o pico de arena ≤20 ms |
| 🔴 | Fojo implica seis zonas residentes; 2,5 GB/6 = 427 MiB por zona antes de runtime | a topologia não tem orçamento físico plausível por zona |
| 🔴 | 2 jogadores + 5 inimigos ocupam 7/8 actores, mas necromancia não tem tecto de design | a segunda invocação pode violar a Lei 4 por contrato |

Os detalhes, estimativas e propostas vivem agora nas perguntas 41–56 do [`99`](../spec/99-perguntas-abertas.md) e no [`LACUNAS`](../LACUNAS.md).

---

## 3. Regras sem números ou sem mecanismo

### Corrigidas objectivamente

| Antes | Correcção |
|---|---|
| 18/33 inimigos herdavam silenciosamente `chase_speed` | as 33 fichas cruas declaram perseguição; o teste exige `<5,0 m/s` |
| Berserker e Paladino caíam num fallback de bias | as seis classes declaram perfil explicitamente |
| `abilities.json` tinha cooldowns, mas não dizia o verbo de runtime | as seis fichas declaram `effect_type`; Eco declara mana zero; Fúria/Julgamento/Assassino materializam restrições já decididas |
| números das ameaças viviam dentro de frases | cada ameaça tem `rules`; os 18 valores não dedutíveis ficam enumerados em `unresolved_parameters` |
| Fojo mandava «saltar» e Cidade «nadar» | ambas as saídas respeitam a travessia sem salto/natação livres |
| [`36-fisica`](../spec/36-fisica.md) ainda dizia Dardo 35/Ruína 20 m/s | corrigido para os 20/8 m/s canónicos e alcance/tempo de voo correspondentes |
| Fojo referia `minotauro`, que não era ID de guardião | normalizado para o placeholder estável `guardiao_fojo_wp7` |
| IA histórica fixava toda a perseguição em 4,5–5,0 m/s | tabela corrigida para 2,2–4,9 por ficha; patrulha base 1,6 m/s |

### Continuam sem decisão

| Família | O que existe | O que falta para código |
|---|---|---|
| Tiros inimigos | frames, alcance por ataque, tell e fuga | velocidade, gravidade, raio, vida e política de impacto |
| Perseguidores inimigos | 72 frames, alcance e quebra de LOS | velocidade, rotação, raio e colisão/expiração exacta |
| Formas mágicas | 53 fichas usam todas as 12 formas | interface física comum; chuva/cone/orbitante/persistente precisam de contagem, cadência, pulso e vida |
| Habilidades | seis verbos/cooldowns; três no runtime | compromisso/interrupção/cooldown; alvo e custos não-mana do Eco |
| IA | cone 90°/15 m, audição 8/20 m, alerta 2 s, chamada 10 m/0,8 s, desistência 6 s/30 m | avanço, caminho/velocidade de retorno, cura e reaquisição |
| Mundo | números conhecidos estruturados | 18 parâmetros, incluindo rotação da bruma, dardos, vento, relâmpago, esporos, água, cegueira e lanterna |
| Armadura | peso/resistência/slot em 68 peças | efeito real das 57 futuras ou `effect_type: none` |
| Anéis | 70 efeitos com pequenos números | evento/cliente; cinco efeitos pressupõem sistemas ausentes/proibidos |
| Instrumentos | escola/tipo conceptual e cajados como armas | fichas dos outros cinco, slot/mãos, força e velocidade por forma |

---

## 4. Dependências que não existem

### Cruzamento dos 17 JSON

O novo [`check-data-references.mjs`](../tools/check-data-references.mjs) valida classes/habilidades/loadouts, controlos, biomas/raças/mundo, inimigos/templates/padrões/loot, nomeados, economia, equipamento, feitiços, portas/ligações e preset gráfico. Resultado: **2380 referências/contratos**.

| Estado | Dependência |
|---|---|
| ✅ | classes ↔ habilidades ↔ kits; seis biases explícitos |
| ✅ | raças ↔ biomas ↔ inimigos; ligações de mundo simétricas; portas e endpoints válidos |
| ✅ | ataques ↔ templates/padrões; nomeados ↔ tipo-base; loot material/consumível/arma/armadura/anel |
| ✅ | escolas/formas/vectores/favoritos ↔ 53 feitiços |
| ✅ | gerador de equipamento preserva agora ID, nome, forma e origem do mesmo objecto |
| 🔴 conhecido | `acessorio:*`: quatro sinos + `lanterna_violeta_antiga` sem catálogo |
| 🔴 conhecido | 11 `guardiao_<bioma>_wp7` sem ficha; Vorgar é o único resolvido |
| 🔴 estrutural | 12 subchefes prometidos por contagem, sem IDs/colocação/ficha |
| 🔴 estrutural | `sino`, `talisma`, `chama`, `relicario`, `instrumento_hibrido` são requisitos de magia, não itens equipáveis |
| 🔴 estrutural | nove afinidades de anel não pertencem a namespace validado |

O validador aceita apenas os dois conjuntos conhecidos como avisos explícitos. Qualquer novo ID partido falha; se um aviso desaparecer ou mudar sem actualizar o contrato, também falha. Assim, dívida conhecida não vira licença para dívida nova.

### Um erro real do gerador

Os IDs gerados de arma traziam bioma/forma correctos, mas o nome, material e origem vinham deslocados de outra entrada. Por exemplo, um ID Brumal podia descrever conteúdo de Fojo. O gerador foi corrigido na fonte e regenerado; não se remendou apenas o JSON.

---

## 5. ⭐ Ordem real de construção

```text
decisões + schemas + budgets
          │
          ├──> combate solo ──> equipamento/save/UI ──> rede
          │                                             │
          └──> harness Lei 4 ───────────────────────────┤
                                                        ▼
                                                   Brumal completo
                                                        ▼
                                                gate integrado da Fatia 1
                                                        ▼
                                                  pipelines reutilizáveis
                                                        ▼
                                                   zonas uma a uma
```

| Ordem | Construir | Gate de saída |
|---:|---|---|
| 0 | Responder em lote às 12 decisões da Fatia 1: 18, 20, 24, 29, 32, 37, 43, 45, 46, 49, 53 e 56. Fechar schema de forma, habilidade e IA. | zero parâmetro implícito nos exemplares da fatia |
| 1 | `TuningRecorder`, overlay p99/memória, latência artificial e cena integrada sintética de oito actores. | prova reproduzível; p99 regressa a ≤16,7 ms antes de vestir conteúdo |
| 2 | Núcleo solo: sete golpes/estados/offhand, seis habilidades, Dardo/Ruína/Égide sobre as interfaces finais. | testes de comportamento, não apenas presença de campos |
| 3 | Equipar/inventário/save/UI da fatia: 5 armas, 11 armaduras, loot, criador, remap e duas perspectivas. | 6 origens × equipamentos; save round-trip; nenhum texto de tecla fixo |
| 4 | Rede da Fatia 1: host/join, autoridade, recompensa/save, queda/ressurreição e latência. | duas máquinas, perda/reentrada, eventos idempotentes |
| 5 | Brumal completo: rota de 8 min, círculos, atalho, ameaça, Toca, Vorgar, arte/áudio. | cinco corridas por perspectiva; retry <30 s; cues sem áudio |
| 6 | Gate integrado: 2 jogadores + 5 inimigos, IA, VFX, HUD, áudio e rede simulada, quente 20 min. | p99 ≤16,7 ms, nenhum pico >20 ms, memória estável/≤2,5 GB |
| 7 | Só depois, extrair pipelines: instrumentos/formas, ring-event bus, arena/bolsa, streaming actual+transição. | um exemplar completo por família |
| 8 | Produzir uma zona de cada vez: zona + inimigos + nomeados + subchefe + guardião + loot + teste. | gate de densidade inteiro antes da zona seguinte |

### Ciclos encontrados e como os quebrar

| Ciclo | Porque bloqueia | Corte recomendado |
|---|---|---|
| feitiço precisa da forma ↔ forma está inferida dos feitiços | 53 fichas parecem especificar a interface que consomem | definir interface de forma e provar quatro exemplares antes dos 50 futuros |
| zona precisa de streaming ↔ orçamento só aparece com zonas finais | produzir arte primeiro descobre tarde que seis zonas não cabem | spike sintético + orçamento por conjunto residente antes da segunda zona |
| loot visível precisa de equipamento ↔ equipamento gerado a partir do inimigo/bioma | um desfasamento no gerador corrompe ambos | IDs estáveis + gerador unidireccional + validador; já aplicado |
| recompensa/save precisa da política co-op ↔ rede precisa da transacção | último golpe/duplicação e mundo do convidado mudam a API | transacção local idempotente já pronta; decidir 29/32 antes do adaptador de rede |
| guardian/world/music/narrativa dependem uns dos outros | placeholders parecem conteúdo construível | reservar ID com `implemented:false`; gravar identidade antes do pacote da zona |
| anel depende do cliente ↔ cliente só seria criado ao implementar o anel | 70 pequenos sistemas laterais | vocabulário de eventos fechado; rejeitar anel sem consumidor existente |

---

## 6. Lei 4 — o que não cabe ou ainda não está provado

| Tema | Conta na máquina do Rico | Avaliação |
|---|---|---|
| Greybox 2+3 | 377 fps sem vsync; 60/60 com vsync | ✅ há margem no greybox |
| 5 esqueletos isolados | p99 19,910 ms; pior 21,993 ms | 🔴 falha os gates do próprio projecto antes da cena final |
| 10 esqueletos isolados | p99 19,861 ms; pior 22,532 ms | 🔴 média 60 não prova estabilidade |
| Streaming actual+vizinhas no Fojo | 6 zonas; 427 MiB/zona se todo o resto custasse zero | 🔴 política sem orçamento plausível; usar actual+transição ou provar ≤~400 MiB completo por zona |
| Invocações | encontro máximo usa 7/8 actores | 🔴 sem tecto de design, uma invocação por jogador já ultrapassa o orçamento |
| 53 VFX todos residentes | exemplo ingénuo 53×3×1024² RGBA8+mips ≈848 MiB | 🟠 acima dos 500 MB de texturas; atlas partilhado e residência por favoritos/escola/encontro |
| 34 tipos de inimigo numa zona | são variedade de catálogo, não simultaneidade | ✅ não é problema por si; o tecto simultâneo de actores é que manda |
| volumes persistentes/partículas | há 300 partículas e 4 emissores/personagem, mas não benchmark integrado | 🟠 cabe por contrato só se o pool/corte for realmente aplicado |
| 24 vozes áudio | SFX/ambiente têm prioridade e streaming planeado | ✅ razoável; falta medir directores, não parece o primeiro risco |

Conclusão honesta: **não há evidência para dizer que o jogo final corre a 60 fps estáveis**. Há evidência para dizer que o greybox corre e que o modelo UAL anima, mas a estabilidade já está amarela/vermelha isoladamente. A próxima unidade de trabalho de conteúdo deve começar pela prova integrada, não por mais assets.

---

## 7. Promessas ao jogador: mecanismo e teste

Legenda: ✅ guardada · 🟠 parcial · 🔴 vazia/quebrada.

| Promessa | Mecanismo escrito | Teste que a prova | Estado |
|---|---|---|---|
| perícia acima do nível | i-frames/parry fixos, soft caps, piso de dano, sem gating numérico | fórmulas e Vorgar a nível 1; não há percurso completo a nível baixo | 🟠 |
| melhorias dão opções, não números | armas base+6 por verbos | testes de estrutura das armas; feitiços 53/53 ainda reduzem mana e usam moldes genéricos | 🔴 |
| qualquer classe usa qualquer arma | abaixo do requisito usa ×0,6 sem bloquear | exemplos e requisitos de catálogo; falta 6×120 equip/UI/runtime | 🟠 |
| co-op do princípio ao fim | autoridade/eventos/save descritos | não há host/join nem teste em duas máquinas | 🔴 |
| espólio visível garantido até 10 | baralho sem reposição + transacção/save atómicos | compra/recibo/índice testados; cinco cartas obrigatórias não resolvem | 🔴 |
| ataques honestos e rolamento «10/10» | compromisso/tracking/contacto/vector/cue | auto-testes de dados/frames; não há banco 10/10 com animação final nas duas perspectivas | 🟠 |
| fugir funciona sempre até 100% de carga | 33 velocidades <5,0 m/s | catálogo e teste agora verdes; falta path/leash/terreno integrado | 🟠 |
| mago forte e vasto | 53 fichas, mana/interrupção/preço em PV | só 3 runtime; formas/instrumentos/efeitos/melhorias incompletos | 🔴 |
| nunca há grind obrigatório | baralhos finitos, Brasa não repõe recompensa, nível 60–70 previsto | cap de 10 testado; não existe prova de solvência da economia/caminho completo | 🟠 |
| ouvir não é requisito | `GameplayCue` com forma/direcção/timing visuais | renderer/schema testados; falta banco sem som em 1.ª/3.ª pessoa | 🟠 |
| morte/save não permite rollback | checksum, tmp/backup, recibos idempotentes | 19+ testes atómicos; HP0/mancha/mapa/equipamento/boss ainda sem produtores | 🟠 |
| primeira ou terceira pessoa | duas câmaras e obrigações escritas | não há prova completa; lock-on de 1.ª pessoa continua por escolher | 🟠 |
| controlos configuráveis | catálogo/InputMap único | acções sintéticas testadas; falta UI, persistência e comando físico | 🟠 |
| 60 fps na máquina do Rico | budgets, presets e harness | greybox passa; esqueleto p99/pico falha os gates | 🔴 |
| retry de chefe <30 s | atalhos/descansos catalogados | nenhum nível final medido | 🔴 |

O padrão é claro: as promessas nucleares têm bons **mecanismos de papel**, mas os testes são sobretudo unitários/estruturais. As mais caras — co-op, 60 fps, mundo aberto, feel e magia vasta — ainda não têm prova integrada.

---

## 8. O que falta para jogar

### Mesmo que alguém implementasse exactamente tudo o que está escrito

O jogador continuaria sem conseguir, de forma determinística:

- receber/equipar os cinco acessórios garantidos;
- lutar contra onze guardiões e doze subchefes, porque não há fichas;
- usar sino, talismã, chama, relicário ou híbrido, nem obter a força/velocidade prometida do cajado;
- saber como tiros/perseguidores/chuvas/orbitantes/persistentes colidem e expiram;
- usar 57 armaduras futuras por uma habilidade definida e os 70 anéis por um cliente conhecido;
- atravessar as ameaças das zonas com comportamento completo;
- resolver alerta/chamada/regresso/cura dos inimigos sem uma regra inventada;
- saber o resultado co-op de loot, chefe morto no mundo alheio, summons e escala de boss;
- carregar o pior nó do mundo com uma política que caiba comprovadamente em 8 GB.

### No protótipo corrente, além disso

- Eco, Entre Sombras e Julgamento não executam;
- 50/53 feitiços, sete golpes, estados, artes, segunda adaga e equipamento completo não executam;
- não há criador final, UI de equipar/anéis/favoritos/remap nem save v2 desses clientes;
- não há host/join, voz, autoridade de combate, ressurreição em rede ou teste de latência;
- não há mapa/streaming/atalhos/11 zonas finais, nem Brumal de 8 minutos medido;
- não há áudio/música/vozes finais nem integração dos packs no runtime;
- morte do jogador, exploração, equipamento e boss ainda não publicam todo o estado no save;
- não há fim de jogo, NG+ jogável, Ultra ou cadeia narrativa implementada.

---

## 9. Quantas vezes teria de parar para perguntar?

### Jogo inteiro: 30

São 30 forks de construção ainda sem carimbo: perguntas **18, 20, 23, 24, 28, 29, 32 e 34–56**. Não conto escolhas de feel que o protocolo permite A/B sem decisão prévia, nem as sete perguntas narrativas separadamente; se as contasse, o número seria maior.

### Fatia 1: 12

Antes de poder prometer a fatia aprovada: **18** rede, **20** fogo amigo, **24** PV do boss, **29** loot, **32** progresso do convidado, **37** Assassino, **43** escudo elemental, **45** habilidades/Eco, **46** projécteis/formas, **49** ameaça Brumal, **53** IA e **56** cajado/instrumento.

Isto não implica doze reuniões. A ordem do §5 permite um gate de combate/dados, um de co-op, um de conteúdo e um de desempenho. A avaliação, porém, é inequívoca: **dar a pasta hoje a um implementador e dizer “segue a spec” não chega.**

---

## 10. Correcções e commits desta passagem

| Família | Resultado |
|---|---|
| `9d54007` — catálogos/IDs | gerador de equipamento corrigido; perseguição explícita; seis biases; validador dos 17 JSON |
| `3a7ab4e` — contratos de execução | habilidades estruturadas; regras ambientais; rotas sem salto/natação; velocidades mágicas; guardião de Fojo; perguntas 45–52 |
| documentação/risco | estados históricos actualizados; IA/armaduras/anéis/instrumentos isolados; Lei 4 reavaliada; perguntas 53–56; este relatório |

Não houve push. Não foram tocados `game/scenes/`, `art/models/` nem `art/textures/`.

