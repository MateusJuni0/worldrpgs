# 01 — Combate

> **WP1.** O coração do jogo. Reescrito pelo Fable a partir das decisões da sessão 1; tudo o que aqui tem número novo é `[FABLE]`, com razão e alternativa descartada. Os frames contam a **60 fps** (1 frame = 16,7 ms) — a taxa alvo da Lei 4.
>
> Fronteira com o WP1B (`spec/25-controlo.md`, reservado ao Claude): **este documento diz o que cada mecânica faz e quanto dura; o WP1B diz como a entrada chega lá** (buffer de input, latência, câmara, sensação de impacto). Os números daqui assumem que o WP1B entrega entrada fiável.

## O que herda da sessão 1

| Elemento | Estado | Fonte |
|---|---|---|
| Corpo a corpo com espada, escudo, arco, magia | `[DECIDIDO]` | sessão 1 · 00:16 |
| Esquiva | `[DECIDIDO]` | 02:04 |
| Parry no corpo a corpo | `[DECIDIDO]` | 02:04, 02:11 |
| Stamina como recurso | `[DECIDIDO]` | 03:50, 06:33 |
| Ganha-se com habilidade (Lei 1) | `[DECIDIDO]` | 01:17 → 04:28 |

---

## A máquina de estados do personagem

Todo o resto do documento pendura aqui. Um personagem está sempre em exactamente **um** destes estados:

| Estado | Entra por | Sai para | Pode ser interrompido por dano? |
|---|---|---|---|
| **Parado / A andar** | omissão | qualquer um | sim → A levar dano |
| **A correr** | segurar corrida com stamina > 0 | qualquer um | sim |
| **A esquivar** | tecla de rolamento | Parado, Ataque (encadeado), Bloqueio | não (ver i-frames) |
| **A atacar** (leve/pesado/crítico) | botão de ataque | Parado, Esquiva (cancelamento), Ataque seguinte | sim, salvo hiperarmadura |
| **A bloquear** | segurar bloqueio com escudo/arma | qualquer um | absorve (ver bloqueio) |
| **A aparar (parry)** | tecla de parry | Parado, Riposte | sim, fora da janela activa |
| **A lançar magia** | botão de lançamento | Parado, Esquiva (só na recuperação) | sim — lançamento interrompido perde a carga? **não**, a carga só se gasta no frame de disparo |
| **A levar dano (stagger)** | dano sem hiperarmadura | Parado | não acumula: durante o stagger há 0,20 s de imunidade a novo stagger (nunca a dano) |
| **Quebra de guarda** | bloquear sem stamina | Parado (após 1,5 s) | sim — e fica ripostável |
| **Caído / A morrer** | vida a 0 | respawn | — |

`[FABLE]` **Sem salto manual.** O mundo desenha-se sem saltos obrigatórios; obstáculos até 0,5 m transpõem-se automaticamente ao andar. *Porquê:* menos um botão no esquema, menos ~8 animações, e um souls-like clássico prova que não faz falta. *Alternativa descartada:* salto livre à Elden Ring — custa animação, física de queda e desenho de mundo vertical, e não serve a fatia 1.

---

## Esquiva (rolamento)

`[FABLE]` — os números:

| Parâmetro | Valor | Em frames |
|---|---|---|
| Duração total | **0,60 s** | 36 f |
| Invencibilidade (i-frames) | **0,08 s → 0,38 s** | frames 5–23 (18 f = 300 ms) |
| Custo | **25 stamina** | — |
| Distância | **3,5 m** | — |
| Direcções | 8, relativas à câmara (com lock-on: relativas ao alvo) | — |
| Cancelável? | **Não** até 0,38 s. De 0,38 s em diante encadeia em: ataque leve (roll-attack), bloqueio | — |
| Nova esquiva | a partir de **0,45 s** | f 27 |

Durante a recuperação (0,38 → 0,60 s) o personagem é vulnerável — esquivar por hábito, sem ler o ataque, é punível. É essa a diferença entre esquivar e estar invencível.

*Porquê estes números:* 300 ms de invencibilidade é janela generosa para reagir a qualquer telegrafia ≥ 0,5 s (todas as do jogo são — regra no WP6), e os 5 frames de arranque impedem a esquiva de ser um botão de pânico sem leitura. *Alternativa descartada:* i-frames desde o frame 1 (à Bloodborne) — torna a esquiva reactiva pura e mata o parry, porque esquivar passa a dominar sempre.

*Teste da Lei 1:* a invencibilidade não depende de atributo nenhum. Um personagem nível 1 atravessa **qualquer** ataque do jogo com a mesma janela que um nível 100. O nível compra mais stamina (mais esquivas seguidas = margem de erro), nunca uma esquiva melhor. ✅

`[FABLE]` **Sem backstep** na fatia 1 (o passo curto para trás do Dark Souls). *Porquê:* segunda animação, segunda tabela de i-frames, ganho pequeno. *Alternativa descartada:* backstep com 6 i-frames — fica em "ideias para depois".

---

## Parry

`[FABLE]` — os números:

| Parâmetro | Valor | Em frames |
|---|---|---|
| Arranque | 0,05 s | 3 f |
| **Janela activa** | **0,05 s → 0,20 s** | frames 4–12 (9 f = 150 ms) |
| Recuperação (se falha) | 0,20 → 0,60 s | 24 f vulnerável |
| Custo | 10 stamina | — |
| Com quê | escudo ou adaga na mão esquerda; cajado e machadão **não aparam** | — |

**Ao acertar:** o atacante entra em **Ruptura** — 2,5 s de stagger, cai de joelhos, e fica **ripostável** (ver críticos). O som e a faísca do parry saem no frame exacto do contacto (WP12), sempre iguais — é o "acertei" que se aprende de ouvido.

**Ao falhar:** 24 frames de recuperação de braços abertos. Falhar um parry na cara de um brutamontes é levar o golpe inteiro. É esse o contrato: risco alto, prémio alto.

**O que se apara e o que não:**

| Tipo de ataque | Aparável? | Como se comunica |
|---|---|---|
| Golpes de arma de humanoides (lanceiro, espadachins) | ✅ | telegrafia normal |
| Pancadas esmagadoras (brutamontes, martelos, quedas de cima) | ❌ — bloqueável, esquivável | o inimigo ergue a arma **acima da cabeça** — regra visual fixa do jogo inteiro |
| Agarrões (chefes) | ❌ — só esquiva | brilho vermelho curto no inimigo, 0,25 s antes (regra fixa) |
| Projécteis físicos (lanças atiradas, flechas) | ✅ — desvia, não abre riposte | — |
| Magia | ❌ na fatia 1 | fica em "ideias para depois" (aparar magia com Égide é candidato) |

*Porquê 150 ms de janela:* é apertado o suficiente para ser uma aposta (o dobro da esquiva de exigência), largo o suficiente para se aprender — com a telegrafia mínima de 0,5 s (WP6), o jogador tem de acertar o timing com ±75 ms, que é o alcance de um humano treinado num ritmo aprendido. *Alternativa descartada:* janela de 5 f (à Sekiro) — para dois jogadores casuais em máquinas de 60 Hz, transforma o parry em item de colecção.

*Teste da Lei 1:* o parry não escala com nada. A recompensa (riposte ×3,0) é fixa em multiplicador, por isso um jogador fraco que apare bem mata depressa na mesma. ✅ · E as regras visuais fixas (arma acima da cabeça = não aparável; brilho vermelho = só esquiva) fazem da leitura uma habilidade transferível a todo o bestiário.

---

## Bloqueio

Segurar o botão com escudo (ou arma a duas mãos, pior) à frente. Levantar o escudo demora **0,10 s** (6 f); baixar é imediato.

| Com | Absorção física | Absorção mágica | Custo por golpe |
|---|---|---|---|
| Escudo de madeira (fatia 1) | 90% | 40% | dano × 0,60 em stamina |
| Escudos melhores (WP5) | até 100% | até 70% | dano × 0,40–0,55 |
| Arma a duas mãos (guarda) | 60% | 20% | dano × 0,80 |

- Os 10% que passam ("chip damage") mantêm o bloqueio como adiamento, não como solução.
- **Stamina regenera a metade (20/s) com o escudo levantado.** Andar de escudo em riste o dia todo tem preço.
- **Quebra de guarda:** se o custo do golpe exceder a stamina restante, a guarda parte — 1,5 s (90 f) de stagger, **ripostável**. É a punição por bloquear o que devia ser esquivado.

*Teste da Lei 1:* bloquear não exige atributos; a stamina baixa de um nível 1 só encurta quantos golpes aguenta antes de ter de fazer o que o jogo ensina — esquivar ou aparar. O escudo é rede de segurança, não resposta. ✅

---

## Stamina

| Parâmetro | Valor |
|---|---|
| Base no nível 1 | **100** (cresce com o atributo Stamina — fórmula no WP2) |
| Regeneração | **45/s**, após **0,7 s** sem gastar |
| Regeneração a bloquear | 20/s |
| Regeneração em exaustão (chegou a 0) | espera **1,0 s**, e o personagem só volta a poder agir com ≥ 20 pontos |
| Exaustão | não pode atacar, esquivar, aparar nem bloquear; anda a 80% da velocidade; **não cambaleia** (só a quebra de guarda cambaleia) |

**Custos de cada acção:**

| Acção | Custo |
|---|---|
| Rolamento | 25 |
| Parry | 10 |
| Corrida | 12/s |
| Ataque leve | 12–30 (por arma — tabela abaixo) |
| Ataque pesado | ×1,7 do leve da mesma arma |
| Bloquear um golpe | dano × factor do escudo |
| Andar, bloquear parado | 0 |

**Regra de justiça** `[FABLE]`: uma acção com stamina > 0 mas insuficiente **executa na mesma** e deixa a barra a zero (estilo Dark Souls). *Porquê:* recusar a acção "porque faltavam 3 pontos" é o jogo a comer botões — viola a regra final do WP1B. *Alternativa descartada:* bloquear acções sem stamina cheia para elas — pune a leitura certa por contabilidade errada.

*Teste da Lei 1:* com 100 de stamina, um nível 1 tem 4 rolamentos ou ~7 golpes leves de espada por barra — chega para qualquer padrão do jogo com gestão. O atributo compra fôlego (margem), não acesso. ✅

---

## Ataques

Dois botões: **leve** (encadeia até 3) e **pesado** (um golpe, mais lento, quebra postura). O dano base e os requisitos são do WP5; aqui ficam os tempos e custos das cinco armas da fatia 1:

| Arma | Golpe | Arranque | Activo | Recuperação | Total | Stamina | Notas |
|---|---|---|---|---|---|---|---|
| **Espada longa** | leve (×3) | 0,20 s | 0,10 s | 0,25 s | 0,55 s | 18 | o metro do jogo |
| | pesado | 0,45 s | 0,12 s | 0,45 s | 1,02 s | 30 | +50% dano de postura |
| **Adaga** | leve (×3) | 0,12 s | 0,08 s | 0,18 s | 0,38 s | 12 | alcance 1,2 m (curto) |
| | pesado | 0,30 s | 0,10 s | 0,30 s | 0,70 s | 20 | bónus de backstab ×3,0 (vs ×2,5) |
| **Machadão** | leve (×2) | 0,35 s | 0,15 s | 0,40 s | 0,90 s | 30 | arco largo, acerta grupos |
| | pesado | 0,60 s | 0,15 s | 0,60 s | 1,35 s | 45 | **hiperarmadura** 0,25 s → 0,75 s |
| **Cajado** | leve | 0,25 s | proj. | 0,35 s | 0,60 s | 10 | **Dardo do cajado** — ver plano B, WP4 |
| | pesado | 0,40 s | 0,10 s | 0,40 s | 0,90 s | 22 | pancada física |
| **Escudo** | investida | 0,25 s | 0,10 s | 0,35 s | 0,70 s | 15 | dano baixo, alto dano de postura |

**Encadeamento do combo leve:** o golpe seguinte aceita-se do início da recuperação até 0,4 s depois dela acabar; o 2.º e 3.º golpes da cadeia ganham +10% e +20% de dano. Largar a cadeia a meio não tem penalização.

**Cancelamentos** `[FABLE]`:
- Ataque leve → **rolamento**, a partir de 60% da recuperação. *Porquê:* premeia agressão com leitura; sem isto, atacar ao pé de um chefe é sempre erro.
- Ataque pesado → **não cancela**. É um compromisso; a hiperarmadura (machadão) é a compensação.
- Bloqueio e corrida cancelam para qualquer coisa de imediato.
- *Alternativa descartada:* cancelar tudo a qualquer momento (à action game) — dissolve o peso das escolhas, e o peso é o género.

**Hiperarmadura:** durante os frames marcados, dano recebido **não interrompe** a animação (o dano entra na mesma). Reservada a: pesado do machadão, habilidades marcadas no WP3, ataques marcados de inimigos grandes (WP6).

**Poise / interrupção do jogador** `[FABLE]`: levar dano fora de i-frames e sem hiperarmadura causa **stagger de 0,35 s** e interrompe o que estava a meio. Não há barra de poise no jogador na fatia 1 — armadura ainda não existe (pergunta 14). *Alternativa descartada:* poise numérico à Dark Souls já — sem armadura para o alimentar, era um número morto.

**Postura dos inimigos:** cada inimigo tem **Postura** (valor no WP6). Cada golpe tira postura (dano de postura ≈ custo de stamina do golpe; pesados +50%). A zero → **Ruptura**: 2,0 s de stagger, ripostável, postura recomeça cheia. Regenera 10/s após 3 s sem levar dano de postura.

---

## Críticos: riposte e backstab

| Crítico | Condição | Multiplicador | Animação |
|---|---|---|---|
| **Riposte** | inimigo em Ruptura (parry ou postura a zero) + ataque leve de frente | **×3,0** do dano do leve | 1,8 s, invencível durante a execução |
| **Backstab** | cone de 60° nas costas de inimigo comum, arma de uma mão, ataque leve | **×2,5** (adaga: ×3,0) | 1,5 s, invencível durante a execução |

Chefes **não** têm backstab; têm Ruptura (a barra de postura é a porta de entrada do crítico neles). A invencibilidade durante a animação é o que torna o crítico seguro em co-op — o parceiro não te acerta lá dentro (ver fogo amigo, WP4/WP10).

*Teste da Lei 1:* os críticos multiplicam o dano que o jogador tem, seja ele qual for. Um nível 1 que domine parry mata o lanceiro em 2 ripostes; um nível 50 em 1. Margem, não porta. ✅

---

## Lock-on

`[FABLE]` — existe, e é o modo por omissão de ler um inimigo:

| Parâmetro | Valor |
|---|---|
| Alcance de aquisição | 20 m, no cone de 30° do centro da câmara |
| Quebra | > 28 m, ou 2 s sem linha de vista |
| Troca de alvo | roda do rato (com lock activo); movimento lateral do rato > 300 px/s também troca |
| Movimento | vira o personagem para o alvo; andar passa a *strafe*; correr quebra o strafe (continua locked) |
| Esquiva com lock | nas 8 direcções relativas ao alvo |

Sem alvo, os ataques saem na direcção da câmara. O comportamento da câmara com lock (enquadramento, chefe gigante em cima, co-op) é do WP1B.

*Alternativa descartada:* combate só de câmara livre (à Monster Hunter antigo) — exige mira manual constante que o rato até suporta, mas o parry e o strafe à volta de um chefe ficam muito mais caros de aprender. O jogo é dos dois, não de veteranos.

---

## Combate à distância — a regra da pressão

O problema conhecido do género, dito no documento antigo: **se atacar de longe for seguro, ninguém esquiva nem apara, e as duas mecânicas centrais morrem.**

`[FABLE]` A resposta é uma regra com três dentes, e chama-se **regra da pressão**:

1. **Custo auto-limitado.** Magia gasta cargas (WP4); o Dardo do cajado é gratuito mas fraco e com queda: **−50% de dano além de 8 m** (queda linear de 8 m a 15 m, alcance máximo 15 m). Não há metralhadora arcana.
2. **Os inimigos fecham.** Qualquer inimigo atingido ou que veja um projéctil entra em comportamento de fecho: corre ao jogador a velocidade ≥ da corrida do jogador (6 m/s), em zigue-zague leve (WP6). Ficar parado a disparar é decisão com prazo.
3. **Lançar é âncora.** Lançamentos de magia (0,4–1,2 s por magia, WP4) e puxar de arco (1,2 s, fatia 2) fazem-se **parado ou a andar a 50%**. Distância compra dano por tempo, não segurança.

*Teste da Lei 1:* um mago excelente gere as cargas, ganha espaço com a esquiva e termina com o Dardo — habilidade. Um mago mau esvazia as cargas ao longe e morre com o lanceiro em cima — leu mal. Nenhum dos dois resolve com nível. ✅

O arco e flecha (decidido a 00:16) entra na **fatia 2** com este sistema: munição limitada, 1,2 s de puxa, dano cai com a distância a partir de 20 m. Detalhe no WP5 quando chegar a vez.

---

## Morte

Provisório da fatia 1, herdado do WP0 (pergunta 10 continua aberta — é a decisão de tom deles):

- Vida a 0 → animação de queda (1,5 s) → ecrã de morte (2 s) → respawn no último ponto de descanso. **Total < 30 s até estar a jogar.**
- Inimigos normais renascem no respawn; chefes não.
- **Nada se perde.** Sem economia na fatia, punição de perda seria arbitrária.
- Em co-op: o caído fica no chão **ressuscitável durante 30 s** (parceiro segura interacção 3 s ao lado, canalizável — interrompe-se com dano). Se os 30 s passarem ou o parceiro também cair, os dois voltam ao ponto de descanso. `[FABLE]` *Porquê:* transforma "ele morreu" em decisão táctica de risco em vez de espera. *Alternativa descartada:* morte de um = reset imediato — pune o jogador que ainda está de pé e a aprender.

---

## Dificuldade

`[FABLE]` **Não há selector de dificuldade.** A dificuldade é o desenho dos padrões; a margem vem do nível (Lei 1) e do co-op (pilar 2). *Alternativa descartada:* modos fácil/normal/difícil — obrigam a equilibrar o jogo três vezes, e o jogo é para dois jogadores concretos, não para um mercado.

---

## Comandos

Teclado e rato é o esquema principal — **nenhuma das duas máquinas tem comando** (pergunta 0). Remapeável no WP11.

| Acção | Teclado + rato | Comando (futuro) |
|---|---|---|
| Mover | WASD | analógico esq. |
| Correr | Shift (segurar) | B/○ (segurar) |
| Rolamento | Espaço | B/○ (toque) |
| Ataque leve | botão esq. do rato | R1 |
| Ataque pesado | botão dir. do rato | R2 |
| Bloquear | Ctrl (segurar) | L1 |
| Parry | F | L2 |
| Lock-on | Q ou botão do meio | analógico dir. (clique) |
| Trocar alvo / magia | roda do rato / roda com Alt | analógico dir. / d-pad |
| Lançar magia (cajado na mão) | botão dir. do rato | L2 |
| Frasco / consumível activo | R | quadrado/X |
| Interagir | E | A/✕ |
| Hotbar | 1–8 | d-pad |
| Mochila | Tab | opções |

Nota de coerência: com cajado equipado, o botão direito lança a magia activa (o cajado não bloqueia nem tem pesado útil — a pancada pesada fica em Shift+botão esq., parado). Cada arma diz o seu mapa no WP5.

---

## O que este documento não fecha

- **Buffer de entrada, latência, câmara, hit-stop** → WP1B (Claude, reservado)
- **Dano base, requisitos e escala das armas** → WP5 · **Fórmula de dano e defesas** → WP2
- **Telegrafias concretas de cada inimigo** (com a regra mínima: aviso ≥ 0,5 s) → WP6
- **Cargas e catálogo de magia** → WP4 · **Fogo amigo** → pergunta 20, provisório no WP4
- **Morte definitiva** (perde-se algo? fogueiras?) → pergunta 10, deles
- **Estados alterados** (veneno, fogo, choque) → framework no WP2, efeitos no WP4/WP6

## Ligações

- Pilares e Lei 1: [`00-visao.md`](00-visao.md) · Fatia 1: [`10-fatia-1.md`](10-fatia-1.md)
- Controlo e game feel: `25-controlo.md` (WP1B, em curso pelo Claude)
- Fórmulas: [`11-formulas.md`](11-formulas.md) · Armas: [`14-equipamento.md`](14-equipamento.md) · Magia: [`13-magia.md`](13-magia.md)
