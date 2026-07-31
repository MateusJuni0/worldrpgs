# 14 — Armas e equipamento

> **WP5.** O catálogo. A regra que manda aqui é a **Lei 3** — qualquer classe pega em qualquer arma (05:44 → 06:17, `[DECIDIDO]`), com a diferença a vir de atributos e skills. Os números novos são `[FABLE]`. Frame data (arranque/activo/recuperação) vive no [`01-combate.md`](01-combate.md), por família; a fórmula e a curva de escala no [`11-formulas.md`](11-formulas.md).

## A Lei 3 com números

Qualquer um equipa qualquer arma, sempre. Quem **não cumpre o requisito**:

- perde toda a escala (`Σ escala = 0`), e
- sofre **−5% de dano base por ponto em falta**, com chão a **40%** do valor de tabela.

**Exemplo:** Feiticeiro (For 8) com o machadão (req. For 18): 10 pontos em falta → 55 × 0,50 = **27** por golpe de 0,90 s. Utilizável num aperto; nunca um Berserker. A diferenciação é física, não proibitiva. *Teste da Lei 1:* o chão dos 40% garante que arma nenhuma "não funciona" — funciona pior. ✅

Movesets **não mudam** com atributos — a velocidade da arma é da arma (senão a leitura do parceiro em co-op quebrava).

## Famílias e movesets

Uma família = um conjunto de animações (é a unidade de custo do WP12). A fatia 1 usa **5 famílias**; o jogo inteiro, 8.

| Família | Movimento | Fatia 1? |
|---|---|---|
| Espadas retas | o metro (frame data no WP1) | ✅ |
| Adagas | curta e rápida, backstab ×3,0 | ✅ |
| Machados grandes | lento, largo, hiperarmadura no pesado | ✅ |
| Cajados | Dardo gratuito + pancada; catalisador de magia | ✅ |
| Escudos | bloqueio + investida de postura | ✅ |
| Lanças/alabardas | alcance; ataca **com o escudo erguido** (identidade) | ⬜ |
| Martelos | dano de postura +50%, vs ossos | ⬜ |
| Arcos | puxar parado, munição, queda aos 20 m | ⬜ fatia 2 |

## Catálogo de armas

Colunas: dano base (físico salvo nota) · requisitos · escala (% por atributo, curva `f` do WP2) · alcance · stamina do leve.

| Arma | Família | Dano | Req. | Escala | Alcance | St. | Fatia 1? |
|---|---|---|---|---|---|---|---|
| **Espada longa** | espada reta | 40 | For 10 / Des 8 | For 60 / Des 40 | 1,8 m | 18 | ✅ |
| **Espada curta** | espada reta | 34 | For 8 / Des 8 | For 45 / Des 55 | 1,5 m | 15 | ✅ *(ver nota Tanque)* |
| **Adaga** | adaga | 26 | Des 12 | Des 90 | 1,2 m | 12 | ✅ |
| **Machadão** | machado grande | 55 | For 18 | For 90 | 2,2 m | 30 | ✅ |
| **Cajado do Aprendiz** | cajado | dardo 20 · pancada 25 | Sab 10 | Sab 60 (dardo) | 15 m / 1,6 m | 10 / 22 | ✅ |
| Montante | espada reta | 62 | For 20 / Des 10 | For 70 / Des 20 | 2,1 m | 26 | ⬜ |
| Maça | martelo | 45 | For 14 | For 80 | 1,6 m | 22 | ⬜ |
| Martelão | martelo | 70 | For 24 | For 95 | 2,3 m | 42 | ⬜ |
| Lança | lança | 38 | For 10 / Des 12 | Des 65 / For 25 | 2,6 m | 20 | ⬜ |
| Alabarda | lança | 50 | For 16 / Des 10 | For 55 / Des 35 | 2,5 m | 26 | ⬜ |
| Cajado de Carvalho | cajado | dardo 24 | Sab 20 | Sab 70 · poder arcano 115% | 15 m | 10 | ⬜ |
| Cajado de Ossos | cajado | dardo 22 | Sab 24 | Sab 70 · Sombra +25%, Luz −10% | 15 m | 10 | ⬜ |
| Arco curto | arco | 30 | Des 14 | Des 75 | 20 m+queda | puxa 1,2 s | ⬜ fatia 2 |
| Arco longo | arco | 45 | Des 18 / For 10 | Des 80 | 28 m+queda | puxa 1,6 s | ⬜ fatia 2 |

**Cajados como catalisadores:** o dano das magias multiplica pelo *poder arcano* do cajado equipado (Aprendiz 100%). É onde "encontrar um cajado bom" vale sem quebrar a objecção do Rico (05:57): quem não tem Sabedoria não tem cargas nem escala — o cajado bom na mão errada é um pau com brilho. ✅

**Arcos (fatia 2)** herdam a regra da pressão do WP1: puxar 1,2–1,6 s **parado**, munição limitada e comprável só onde houver economia (WP9), queda de dano além de 20 m. Sem metralhadora de flechas; o Batedor (WP3) entra com isto.

## Escudos

| Escudo | Absorção fís. | Absorção mág. | Custo por golpe | Investida | Fatia 1? |
|---|---|---|---|---|---|
| **De madeira** | 90% | 40% | dano × 0,60 | 20 + postura 40 | ✅ |
| **De ferro** | 100% | 50% | dano × 0,50 | 24 + postura 48 | ✅ *(ver nota)* |
| De torre | 100% | 65% | dano × 0,40 | 30 + postura 60 · corrida −15% | ⬜ |

> **Nota — emenda ao WP0, à vista:** a tabela do WP0 dizia "5 armas". O WP3 deu ao Tanque espada curta + escudo de ferro, e este catálogo acompanha: a fatia passa a **7 itens em 5 famílias**. O custo real de animação (WP12) conta-se por família e não muda; a espada curta reutiliza o moveset da longa (−10% de recuperação) e o escudo de ferro o do de madeira. `[FABLE]` *Porquê:* sem isto o Tanque nasce igual ao Guerreiro. *Alternativa descartada:* corrigir o WP3 para equipamento partilhado — mais barato, mas apagava a identidade da classe que existe para "ficar com o escudo" (08:39).

## Melhoria de armas

`[FABLE]` — existe, pequena, fora da fatia 1 ⬜:

- Níveis **+1 a +5**, **+6% de dano base por nível** (tecto +30% — já contado no tecto ×2,5 da Lei 1, WP2).
- Materiais: **Limalha** (comum, zonas), **Limalha Nobre** (+4/+5, dungeons) — encontrados a explorar, **caem de baús e cantos, não de repetir inimigos** (Lei 1: sem grind obrigatório).
- Onde: no ponto de descanso (sem ferreiro até o WP8B decidir se há NPCs).
- *Alternativa descartada:* árvores de melhoria ramificadas (fogo/raio/etc. por forja) — os encantamentos (WP4) já fazem isso melhor, por escolha do jogador.

## Cura e consumíveis

`[DECIDIDO]` que há poções/itens de cura (00:26 → 00:32). O modelo `[FABLE]` — **frasco recarregável**, e a pergunta 7 fecha-se por proposta:

| Parâmetro | Valor |
|---|---|
| **Frasco de Bruma** | 3 cargas na fatia 1; ampliável até 5 (ampliações escondidas no mundo, uma por zona) |
| Cura | 40% da vida máxima por gole |
| Beber | 1,2 s, a andar a 50%; interrompível por dano (perde a carga — beber é decisão, não reflexo) |
| Recarrega | no ponto de descanso (junto com cargas de magia e renascer de inimigos) |

*Porquê frasco e não poções compráveis:* poções finitas criam o incentivo exacto que a Lei 1 proíbe — farmar até ir cheio; o frasco faz de cada tentativa um recomeço igual, e a exploração dá **ampliações** (opções permanentes, Lei 2) em vez de stock. *Alternativa descartada:* poções de loja — precisa de economia que a fatia não tem, e paga-se em grind. A **decisão de tom final continua na pergunta 7**, deles.

Outros consumíveis (facas de arremesso, bombas de fogo, antídotos) ⬜ — entram com a economia no WP9, todos debaixo da regra: consumível dá **conveniência**, nunca a única resposta a um padrão.

## Armadura — pergunta 14, formato de proposta

Nunca dita na gravação; a decisão é deles. As opções:

**Opção A — sem sistema de armadura.** Defesa vem de Constituição; cada classe tem vestes visuais próprias (identidade à vista, zero mecânica). *Ganha:* leitura limpa (a esquiva é igual para todos — Lei 1 sem asteriscos), custo de arte mínimo (Lei 4), zero equilíbrio extra. *Perde:* uma gaveta clássica de loot.

**Opção B — 3 arquétipos de peso** (leve/médio/pesado, conjunto único, sem peças): o peso troca i-frames por defesa (18 / 15 / 12 frames de invencibilidade). *Ganha:* uma escolha de corpo com sabor souls. *Perde:* três vezes a arte de personagem, e a esquiva deixa de ser uma constante do jogo.

**A minha recomendação: A** — para duas pessoas com Iris Xe, a Opção B compra uma gaveta de loot ao preço do triplo da arte e de uma Lei 1 com nota de rodapé. O loot de corpo pode vir de **talismãs** (acessórios sem malha 3D — ver ideias).

**Precisa de decisão de:** Mateus + Rico. Até lá a spec segue com A (é também o estado da fatia 1 no WP0).

## Montarias

O cavalo (05:15, `[SUGERIDO]`) continua guardado: um mapa de minutos não precisa dele. Reavalia-se no WP8 quando a escala do mundo (pergunta 4) tiver número. Nada a especificar aqui ainda — registado para não se perder.

## Ideias para depois

- **Talismãs** (2 espaços): efeitos laterais equipáveis — "parry devolve stamina", "backstab silencioso" — loot de corpo sem custo de malha
- Armas de chefe (a a espada de Vorgar) — só se a skill-por-chefe (WP3/WP9) souber a pouco
- Durabilidade: **não** — manutenção sem decisão interessante; fica registado como descartada

## Ligações

[`06-itens-inventario.md`](06-itens-inventario.md) (sessão 1) · [`01-combate.md`](01-combate.md) (frame data) · [`11-formulas.md`](11-formulas.md) (fórmula, curva `f`, tectos) · [`13-magia.md`](13-magia.md) (encantamentos) · [`10-fatia-1.md`](10-fatia-1.md)
