# 12 — Classes

> **WP3.** As oito classes nomeadas na sessão 1 (07:13 → 07:57), das quais **seis entram na fatia 1** — `[DECIDIDO]` (Rico, 30-07, instrução directa) ⏳ falta o Mateus. Este documento dá-lhes corpo: atributos iniciais, equipamento, habilidade especial, skills. Habilidades desenhadas debaixo da **Lei 2** — "não aumentar o dano da magia, sei lá, uma magia diferente" (Rico, 09:21): **cada habilidade é um verbo novo, nunca um número maior.**

## O que uma classe é — e o que não é

- A classe fixa: **atributos iniciais**, **equipamento inicial**, **habilidade especial** (permanente, tecla própria).
- A classe **não** fixa: armas (Lei 3 — qualquer um pega em qualquer coisa), skills (equipáveis por todos), progressão de atributos (os pontos são livres).
- **Os dois podem escolher a mesma classe.** `[FABLE]` *Porquê:* proibir criava a única proibição dura do jogo, contra o espírito da Lei 3. *Alternativa descartada:* forçar classes distintas em co-op — fricção sem ganho; a rejogabilidade da fatia vem de querer variar, não de ser obrigado.

## Atributos iniciais

Todas as classes somam **66 pontos** (base 10 em tudo = 60, mais 6 de desvio) — nenhuma nasce numericamente à frente; nascem **viradas** para sítios diferentes. (Efeitos por ponto: [`11-formulas.md`](11-formulas.md).)

| Classe | Vida | Stamina | Const. | Força | Destreza | Sabedoria | Soma |
|---|---|---|---|---|---|---|---|
| **Guerreiro** | 12 | 12 | 11 | 13 | 10 | 8 | 66 |
| **Feiticeiro** | 9 | 10 | 8 | 8 | 11 | 20 | 66 |
| **Tanque** | 13 | 12 | 15 | 12 | 7 | 7 | 66 |
| **Assassino** | 9 | 13 | 8 | 9 | 19 | 8 | 66 |
| **Berserker** | 12 | 14 | 10 | 18 | 7 | 5 | 66 |
| **Paladino** | 12 | 10 | 12 | 12 | 8 | 12 | 66 |

## As seis da fatia 1

Formato: papel · equipamento inicial · como se joga · habilidade especial (tecla **V**, sem custo de stamina, recarga em segundos).

### Guerreiro — o metro do jogo
- **Equipamento:** espada longa + escudo de madeira. **Papel:** equilibrado; a régua por que se calibra tudo.
- **Como se joga:** troca de postura constante — bloqueia para aprender, esquiva quando já leu, aparece com o parry quando domina.
- **Habilidade — Provocação** `[FABLE]`: brado de guerra; inimigos num raio de 12 m passam a atacá-lo durante 6 s **e comprometem-se mais** (encurtam o tempo entre telegrafia e golpe em 20% — atacam mais, pensam menos). Recarga 30 s.
  - *O verbo novo:* controlar **quem** é atacado e **quando** — em co-op protege o parceiro caído ou o Feiticeiro a lançar; a solo transforma um grupo hesitante numa fila previsível de parries. *Alternativa descartada:* "+força temporária" (sugestão 08:39/08:53) — número, não verbo; a Lei 2 manda.

### Feiticeiro — as três magias e a distância
- **Equipamento:** cajado + 3 magias (Dardo, Ruína, Égide — WP4). **Papel:** dano à distância com prazo (regra da pressão, WP1).
- **Como se joga:** gasta espaço como recurso — cada lançamento é uma âncora; o Dardo gratuito é o ganha-pão, as cargas são as pontuações.
- **Habilidade — Marca Arcana** `[FABLE]`: planta uma marca no chão (dura 20 s); reactivar teletransporta-o de volta à marca (0,4 s de invocação, interrompível por dano). Recarga 25 s, contada do teletransporte.
  - *O verbo novo:* reposicionamento planeado — marca a saída antes de entrar na boca do lobo. É mobilidade **com premeditação**, o oposto da esquiva reactiva. *Alternativa descartada:* "uma magia a mais" (08:53) — é bom, mas é o que a Sabedoria já faz (mais cargas); a marca dá-lhe uma jogada que nenhum atributo compra.

### Tanque — "fica com o escudo" (08:39)
- **Equipamento:** espada curta + escudo de ferro (absorção 100% física — WP5). **Papel:** segura espaço, mata devagar.
- **Como se joga:** o corpo é a parede; joga de posição e de paciência, e castiga com a investida de escudo (dano de postura).
- **Habilidade — Muralha** `[FABLE]`: postura firmada até 6 s (cancelável): bloqueio a 360°, imempurrável, custo de stamina dos bloqueios reduzido a metade, e o parceiro **colado às suas costas** (raio 1,5 m) é protegido pelos mesmos bloqueios. Recarga 20 s.
  - *O verbo novo:* virar terreno — cria uma sombra segura no meio de uma arena. Em co-op é a jogada de identidade da classe. *Alternativa descartada:* +defesa passiva — número.

### Assassino — "mais rápido" (09:37), mas por verbo
- **Equipamento:** adaga ×2 (segunda no cinto — cosmética até haver dual-wield, ver "ideias"). **Papel:** costas e rupturas.
- **Como se joga:** não tem pressa de bater — tem pressa de **estar atrás**. A esquiva dele é a mesma dos outros (Lei 1: i-frames iguais para todos); o que muda é o que faz com ela.
- **Habilidade — Passo Sombra** `[FABLE]`: durante 3 s, a próxima esquiva vira um deslize de 6 m que **atravessa inimigos** e, com lock-on, termina nas costas do alvo. Recarga 20 s.
  - *O verbo novo:* atravessar — a esquiva ganha uma gramática ofensiva; abre backstabs por leitura de padrão, não por rodeio. *Alternativa descartada:* +velocidade de movimento passiva (a leitura literal do "mais rápido") — número disfarçado, e pisava a Lei 1 ao dar i-frames efectivamente melhores.

### Berserker — o machadão e o limite
- **Equipamento:** machadão. Sem escudo — o corpo é a aposta. **Papel:** dano bruto e quebra de postura.
- **Como se joga:** vive dentro da hiperarmadura do pesado (WP1) e da gestão de uma stamina sempre no vermelho.
- **Habilidade — Fúria** `[FABLE]`: 8 s: **todos** os ataques ganham hiperarmadura e +30% de dano de postura; em troca, defesa −25% e não pode bloquear nem aparar enquanto dura. Recarga 45 s.
  - *O verbo novo:* trocar a defesa pela iniciativa — atravessar golpes de propósito é uma decisão de leitura (quais aguento? quais me matam?). Os números dentro dela são o preço e o prémio do verbo, não o verbo. *Alternativa descartada:* +dano puro — número, e sem o custo que faz a Fúria ser uma escolha.

### Paladino — espada, escudo e "um pouco de raio" (08:39)
- **Equipamento:** espada longa + escudo de madeira. **Papel:** o híbrido — corpo a corpo com uma saída elemental e de apoio.
- **Como se joga:** como o Guerreiro até ao momento em que o Raio muda a pergunta do combate.
- **Habilidade — Édito do Raio** `[FABLE]`: 12 s: a arma fica imbuída de Raio (acumula Choque — WP2: dano de postura ×2 no alvo em choque) e **cada bloqueio bem-sucedido liberta uma nova de choque** (raio 3 m, dano de postura, sem dano de vida). Recarga 40 s.
  - *O verbo novo:* transforma o bloqueio — a mecânica mais passiva do jogo — em detonador; e liga-o à identidade eléctrica pedida na gravação. *Alternativa descartada:* projéctil de raio simples — já existe no WP4 como magia; a habilidade duplicaria uma carga.

*Teste da Lei 1, comum às seis:* nenhuma habilidade altera i-frames, janelas de parry ou dano de vida directo do jogador; todas abrem jogadas que um jogador de nível 1 executa por inteiro. Recargas em segundos (não cargas/consumíveis) para o plano B nunca desaparecer. ✅

## As duas que esperam

| Classe | Espera por quê | Estado |
|---|---|---|
| **Batedor** | o arco e o sistema de pressão à distância (WP1/WP5, fatia 2) | ⬜ desenhado no WP5 quando o arco entrar |
| **Mago do mal** | a pergunta 8 (bem/mal mecânico) ter resposta deles — o WP4 propõe | ⬜ esboço no WP4 |

## Skills

`[DECIDIDO]` (06:04, 07:02) que existem e que definem o que o personagem é bom a fazer. O sistema `[FABLE]`:

- **Skills são técnicas equipáveis, universais** — qualquer classe equipa qualquer skill (coerência com a Lei 3). Limite: **2 activas + 2 passivas**.
- **Ganham-se por encontro e por feito, nunca por nível** (Lei 1: o nível não abre portas; Lei 2: recompensas são opções). Fontes: baús escondidos, chefes (cada chefe larga uma skill — a recompensa é um verbo, WP7/WP9), feitos concretos ("apara 10 golpes" → skill de parry avançado).
- Trocam-se no ponto de descanso, sem custo.

**Catálogo inicial** (as da fatia 1; cresce no WP7/WP9 com um verbo por chefe):

| Skill | Tipo | O que faz | Fonte na fatia 1 | Fatia 1? |
|---|---|---|---|---|
| **Chuto de Quebra** | activa | pontapé (0,4 s): não fere, tira 40 de postura e empurra 1,5 m; quebra guardas erguidas | baú na 2.ª sala da Toca | ✅ |
| **Lançamento de Adaga** | activa | atira a adaga do cinto (12 m, dano baixo, recupera-se no chão) | escondida em Brumal (árvore morta) | ✅ |
| **Presa de Ferro** | passiva | a quebra de guarda que **tu** sofres encurta de 1,5 s para 0,9 s | derrotar Vorgar | ✅ |
| **Fôlego de Duelista** | passiva | parry bem-sucedido devolve 15 de stamina | feito: aparar 10 golpes | ✅ |
| (por chefe, jogo inteiro) | — | um verbo novo por chefe — catálogo cresce no WP7 | — | ⬜ |

## `[TENSÃO]` Evoluções de classe vs Lei 1

**O conflito:** "o mago nível 2 e nível 3 atira magia mais rápido" (Rico, 09:37) dá vantagem mecânica pelo nível — exactamente o que a Lei 1 recusa. O próprio Rico apontou a saída 16 segundos antes (09:21).

**Opção A — evoluções dão verbos.** Cada classe tem 3 patamares; sobe-se por **feito** (derrotar chefes-marco, não por nível). Cada patamar oferece **uma escolha entre duas variantes da habilidade especial** — ex.: Marca Arcana evolui para "duas marcas simultâneas" **ou** "a marca detona ao teleportar (dano de postura)". Poder lateral: mais jogadas, mesmos números.

**Opção B — evoluções dão números pequenos.** Lançar 10% mais rápido, esquiva 5% mais barata. Fiel à letra do 09:37; aceita-se que a Lei 1 é sobre chefes/gating, não sobre progressão interna.

**A minha recomendação: A** — é literalmente a correcção do Rico às 09:21 aplicada às evoluções, e mantém a Lei 1 sem asteriscos. O 09:37 ("mais rápido") lê-se como intenção de *sentir* evolução, que a Opção A entrega por variante em vez de por multiplicador.

**Precisa de decisão de:** Mateus + Rico. **Até lá:** trabalho com a Opção A, marcada provisória; as variantes concretas por classe desenham-se no fim do WP7 (as evoluções penduram nos chefes-marco). Nada disto entra na fatia 1 (WP0 já a deixou de fora).

## Ideias para depois (não pedidas — não crescem sozinhas)

- Dual-wield de adagas para o Assassino (a segunda adaga já está no cinto)
- Backstep (WP1) como skill passiva encontrável
- Skills de co-op puras (ex.: arremessar o parceiro leve por cima de um brutamontes) — piada dos dois primeiro, spec depois

## Ligações

[`02-personagem.md`](02-personagem.md) (o que a sessão 1 disse) · [`11-formulas.md`](11-formulas.md) · [`13-magia.md`](13-magia.md) · [`14-equipamento.md`](14-equipamento.md) · [`10-fatia-1.md`](10-fatia-1.md)
