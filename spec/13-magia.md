# 13 — Magia

> **WP4.** O que a sessão 1 fechou: duas escolas, bem e mal (00:40, 05:04); magias desenhadas à mão, não genéricas (05:04); usos limitados (03:50); encantamentos existem (00:38 → 00:45). O que faltava era a mecânica — e a pergunta 8 ("o que é que bem/mal **faz**?") é o coração deste documento. A proposta é `[FABLE]`; o sim é deles.

## A proposta: duas escolas, duas moedas

**Luz** (a do bem) e **Sombra** (a do mal) não se distinguem por tema — distinguem-se pelo **que pagam**:

| | **Luz** | **Sombra** |
|---|---|---|
| Paga com | **cargas**, só | cargas **+ vida** (o *preço de sangue*, % da vida máxima) |
| Gramática | precisão — recompensa posição e timing | risco — poder maior, pago no corpo |
| Verbos típicos | proteger, revelar, ferir com pontaria | drenar, corromper, trocar vida por poder |
| Falha típica | errar o alvo = carga perdida | acertar e mesmo assim sangrar de mais |

- **Qualquer personagem usa as duas** — Lei 3: nenhum bloqueio por classe ou por "alinhamento". O requisito é Sabedoria; a diferença entre um especialista e um curioso vem da escala e das cargas ([`11-formulas.md`](11-formulas.md)), e a Sombra tem um custo que a Sabedoria **não** reduz: o sangue é o mesmo para todos.
- **Os inimigos respondem às escolas** — "tem que ver a magia que tu usa nele" (05:04): as fraquezas cruzadas vivem na tabela de defesas do WP2 (ex.: mortos-vivos: Luz −30 de defesa, Sombra +60), e têm de ser **legíveis no corpo** do inimigo (regra no WP6/WP12).

*Porquê esta divisão:* dá às duas escolas **sensações** diferentes sem duplicar sistemas — uma moeda nova (vida) em vez de uma barra nova. O preço de sangue auto-equilibra a Sombra: mais forte por golpe, auto-limitada pelo mesmo recurso que o inimigo ataca. *Alternativa descartada:* bem/mal por reputação/corrupção narrativa — não há NPCs nem narrativa fechada (WP8B é território virgem), seria decoração pendurada no vazio.

*Teste da Lei 1:* o preço de sangue é % da vida máxima — um nível 1 e um nível 100 pagam a mesma fracção; a Sombra não fica "grátis" com nível. ✅

## Cargas

`[DECIDIDO]` (03:50) usos limitados; o desenho `[FABLE]`:

- **Cargas por magia** (à Dark Souls), não reservatório comum. *Porquê:* faz de cada magia um recurso com identidade ("ainda tenho duas Ruínas") e impede que uma magia boa esvazie as outras. *Alternativa descartada:* mana contínua — vira metralhadora com pausa, e a regra da pressão (WP1) morre.
- **Recuperam ao descansar** no ponto de descanso (o mesmo que renasce inimigos).
- **Sabedoria dá cargas extra:** +25% às cargas base de cada magia com Sab 25, +50% com Sab 45 (arredonda para baixo).
- **Em combate:** sem recuperação na fatia 1. O **Cristal de Éter** (consumível raro, restaura todas as cargas) entra com a economia no WP9. ⬜
- **3 magias equipadas** ao mesmo tempo (slots — WP11 mostra-as); troca em combate livre, gesto de 0,3 s. A magia é um verbo; trancar verbos a meio da luta seria trancar botões.

**O plano B, sem o qual a Lei 1 quebrava:** o **Dardo do cajado** (WP1) — ataque leve do cajado, projéctil gratuito, dano baixo, queda além de 8 m. O mago sem cargas ainda é um duelista fraco à distância, nunca um espectador. A `[TENSÃO]` "usos limitados vs Lei 1" do documento antigo fecha-se aqui: cargas vazias tiram o **melhor** verbo, não o único. ✅

## O catálogo

Colunas: lançamento (âncora — parado ou a 50% de andamento, WP1), cargas base, preço de sangue (% vida máx.), e o verbo — porque **cada magia é um verbo, não um escalão de dano** (Lei 2 + "as magias são diferentes, não são padrão", 05:04).

### Luz

| Magia | Verbo | Lançamento | Alcance / área | Efeito | Cargas | Fatia 1? |
|---|---|---|---|---|---|---|
| **Dardo** | ferir com pontaria | 0,45 s | projéctil, 15 m | 55 de dano Luz | 8 | ✅ |
| **Égide** | apagar um erro | 0,30 s | própria | escudo orbital 6 s: anula **um** golpe por completo (qualquer) | 4 | ✅ |
| **Lança Solar** | atravessar a fila | 1,20 s | linha, 12 m | 120 Luz, perfura todos na linha | 3 | ⬜ |
| **Clarão** | roubar um turno | 0,60 s | nova 8 m | cega 2 s (inimigos perdem o alvo), interrompe telegrafias aparáveis | 3 | ⬜ |
| **Elo** | dividir o fardo | 2,0 s canal | toque, parceiro | transfere até 30% da tua vida para ele (não cria vida — move) | 5 | ⬜ |
| **Cólera do Céu** | pregar ao chão | 0,90 s | alvo marcado, 14 m | 70 Raio + acumulação de Choque 60 | 4 | ⬜ |

### Sombra

| Magia | Verbo | Lançamento | Alcance / área | Efeito | Cargas | Sangue | Fatia 1? |
|---|---|---|---|---|---|---|---|
| **Ruína** | arrasar a roda | 0,80 s | esfera lançada, área 3,5 m | 90 Sombra em área | 5 | 8% | ✅ |
| **Sanguessuga** | comer para viver | 0,55 s | projéctil, 12 m | 40 Sombra; devolve metade do dano causado como vida | 6 | 5% | ⬜ |
| **Mortalha** | desaparecer | 0,50 s | própria, 6 s | inimigos a > 6 m perdem-te; dreno de 4% vida/s enquanto dura | 3 | — (dreno) | ⬜ |
| **Espinhos do Lodo** | envenenar o chão | 0,90 s | círculo 5 m, 8 s | 10 Sombra/s + acumulação de Veneno 20/s a quem lá estiver | 4 | 10% | ⬜ |
| **Pacto** | hipotecar o corpo | 0,40 s | própria | sacrifica 25% da vida: as próximas 3 magias não gastam cargas | 2 | 25% | ⬜ |

A fatia 1 leva **Dardo, Égide e Ruína** (WP0) — e com a Ruína na Sombra, a fatia já testa as duas moedas: se o preço de sangue não souber bem no protótipo, a pergunta 8 responde-se com dados.

*Teste da Lei 1 (dano):* Dardo 55 com escala de Sabedoria entra na mesma fórmula e nos mesmos tectos do WP2 (nível ≤ ×2,5); nenhum inimigo é imune às **duas** escolas ao mesmo tempo, e o Dardo do cajado nunca cai abaixo do chão dos 40%. ✅

## Como se aprendem

`[FABLE]` **Tomos encontrados** — exploração (baús, altares escondidos) e chefes (a recompensa é um verbo novo — Lei 2 aplicada ao loot, WP9). Nunca desbloqueadas por nível, nunca compradas com Essência. *Alternativa descartada:* árvore de magias por nível — é gating de conteúdo por número, Lei 1 proíbe. Um jogador nível 1 que encontre o tomo da Lança Solar **usa-a** (mal, com Sab 10 — mas usa).

## Encantamentos

`[DECIDIDO]` que existem (00:45, "espada de fogo"). O desenho `[FABLE]`:

- **O jogador aplica** — **Pedras de Encantar** encontradas no mundo; aplicam-se no ponto de descanso.
- **Permanentes até substituir; uma por arma.** Substituir devolve nada — a pedra velha desfaz-se (escolher custa).
- Efeito: converte 30% do dano físico da arma no elemento da pedra + acumulação de estado respectiva (Fogo → Queimadura, Raio → Choque, Sombra → dreno 3%, Luz → +dano a criaturas fracas a Luz).
- *Alternativa descartada:* encantamentos prontos no loot ("espada de fogo" cai feita) — colide com a Lei 3 na prática: o jogo passa a mandar na tua arma; com pedras, a espada de fogo do exemplo continua a existir — és tu que a fazes.
- Fatia 1: **fora** (WP0). Entra no WP5/WP9 com o loot.

## Magia em co-op

Provisório `[FABLE]`, enquanto a pergunta 20 (fogo amigo) não é deles:

- **Dano directo de magia não acerta o parceiro** — nem projécteis nem áreas (a Ruína ao lado do Tanque não o fere).
- Efeitos **positivos** de área/toque (Égide não, é própria; Elo sim) afectam só quem se escolhe.
- *Porquê:* fogo amigo com áreas de Sombra transformava o Feiticeiro num risco para o parceiro em arenas apertadas — fricção entre amigos sem ganho de leitura. *Alternativa descartada:* fogo amigo total "por realismo" — realismo não é pilar; a decisão de tom fica com eles na pergunta 20.

## O Mago do mal — esboço para quando a pergunta 8 tiver o sim

Se a divisão Luz/Sombra por moeda for aprovada, a oitava classe ganha chão: especialista em Sombra — arranque Sab 18 / Vida 13 (o corpo é a mana), habilidade especial candidata: **Pacto Maior** (a versão-habilidade do Pacto: converte vida em cargas, recarga 60 s). Fica esboço ⬜ — não entra em catálogo nenhum antes da decisão deles (WP0 já o deixou fora da fatia).

## O que este documento não fecha

- **Fogo amigo** — pergunta 20, deles; aqui joga-se com o provisório acima
- **Efeitos visuais e som de cada magia** → WP12 (cada linha do catálogo ganha lá a sua ficha de efeito)
- **Tomos: onde estão no mapa** → WP8/WP9 · **Cristal de Éter e economia** → WP9
- **A pergunta 8 continua no 99** até os dois dizerem sim a esta mecânica — é a decisão que desbloqueia o Mago do mal

## Ligações

[`03-magia.md`](03-magia.md) (o que a sessão 1 disse) · [`01-combate.md`](01-combate.md) (regra da pressão, Dardo do cajado) · [`11-formulas.md`](11-formulas.md) (escala, defesas, estados) · [`12-classes.md`](12-classes.md) · [`10-fatia-1.md`](10-fatia-1.md)
