# 29 — Perspectiva: primeira ou terceira pessoa

`[DECIDIDO]` (Mateus, 31-07-2026) — **o jogador escolhe.** Primeira pessoa ou terceira pessoa, a troca é dele.

Até aqui a spec inteira dizia "terceira pessoa" e mais nada. Isto muda documentos em cadeia, e a mudança não é cosmética — por isso tem documento próprio.

## O que isto obriga, sistema a sistema

### Câmara (`→WP1B`, [`25-controlo.md`](25-controlo.md))

Passam a existir **duas câmaras**, não uma com um interruptor:

| | Terceira pessoa | Primeira pessoa |
|---|---|---|
| Distância / pivô | 4,0 m · pivô 1,6 m | colada aos olhos, ~1,7 m |
| FOV | 55° | **75–90°** — abaixo disso enjoa em primeira pessoa |
| Colisão com paredes | cascata de três passos | não existe o problema |
| O que se lê | **a animação do próprio personagem** | só o inimigo e as mãos |
| Balanço de passo | não aplicável | tem de existir, e tem de ser desactivável |

A troca faz-se **fora de combate**, ou com uma transição curta (≤ 0,3 s). Trocar a meio de um golpe é bug à espera de acontecer.

### ⚠️ A consequência que importa, e é para a Lei 1

**Em primeira pessoa o jogador não vê o próprio corpo.** Num souls-like isso é grave: metade da leitura de uma esquiva ou de um parry vem de ver a animação do próprio personagem a começar. Sem ela, o jogador tem de aprender o timing só pelo som e pelo comportamento do inimigo.

Não é impossível — Chivalry, Mordhau e Dark Messiah fazem combate corpo a corpo em primeira pessoa e funciona. Mas exige coisas que a terceira pessoa não exige:

1. **Modelo de braços e arma em primeira pessoa** (*viewmodel*) — um conjunto de animações **separado** do corpo em terceira pessoa. É trabalho a dobrar nas animações de combate, e é a razão nº1 pela qual jogos escolhem uma perspectiva só.
2. **Feedback de estado sem corpo visível** — o jogador tem de saber que está em i-frames, que a stamina acabou, que o parry saiu. Em terceira pessoa a animação diz; em primeira pessoa tem de ser evento com som **e** equivalente de interface/efeito ([`62`](62-acessibilidade-auditiva.md)); nenhum canal é obrigatório para o jogador.
3. **Telegrafia dos inimigos ainda mais legível** — com FOV alto e sem visão periférica do próprio corpo, um ataque vindo de fora do ecrã é injusto. O WP6 herda: **todo o ataque fora do campo de visão emite som direccional e cunha visual com o mesmo compromisso**. Assim, primeira pessoa não fica trancada por audição.

### Lock-on (`→WP1`, `→WP1B`)

Em primeira pessoa o lock-on é estranho — prende a câmara e o jogador perde o controlo do olhar. Duas saídas, nenhuma decidida `[EM ABERTO]`:

- **(a)** lock-on só em terceira pessoa; em primeira pessoa há mira livre e um indicador de alvo
- **(b)** lock-on suave em primeira pessoa: a câmara ajuda a seguir mas não prende

### Combate, animação e arte

- **Animações:** cada arma passa a precisar do conjunto de terceira pessoa **e** do viewmodel de primeira. `→WP12` — o inventário de ~55 animações da fatia cresce, e é preciso recontar.
- **Modelo do jogador:** continua a ser preciso, porque em co-op **o outro jogador vê-te sempre em terceira pessoa**, independentemente da perspectiva em que tu estejas.
- **Level design (`→WP8`):** tectos, corredores e arenas têm de funcionar nos dois FOVs. Um espaço que se lê bem a 55° pode ficar claustrofóbico a 90°.

### Interface (`→WP11`)

O HUD tem de funcionar nas duas. Em primeira pessoa o ecrã está mais cheio (a arma ocupa canto), e os indicadores de stamina e vida ganham mais peso porque não há corpo a mostrar o estado.

## O que fica decidido já

1. **A escolha é do jogador**, e faz-se nas opções e fora de combate
2. **Terceira pessoa é a perspectiva de referência** — é nela que os números do combate se afinam primeiro (WP15B), porque é a que dá leitura completa
3. **Primeira pessoa não pode ser desvantagem competitiva**: se o teste do WP15B mostrar que é mais difícil vencer o Vorgar em primeira pessoa, o problema é de feedback, não do jogador — corrige-se nos dois canais do [`62`](62-acessibilidade-auditiva.md), nunca a baixar a dificuldade

## O que fica em aberto

- Lock-on em primeira pessoa: opção (a) ou (b)
- A fatia 1 sai com as duas perspectivas, ou terceira primeiro e primeira depois? *(Recomendação `[CLAUDE]`: **terceira primeiro**. A fatia existe para responder "o combate é bom?" — responde-se numa perspectiva, e a segunda entra quando a primeira estiver afinada. Isto não é cortar; é ordem.)*
- Balanço de passo em primeira pessoa: quanto, e desactivável a partir de quando

## Ligações

[`25-controlo.md`](25-controlo.md) · [`01-combate.md`](01-combate.md) · [`00-visao.md`](00-visao.md) · [`30-qualidade-visual.md`](30-qualidade-visual.md) · [`62-acessibilidade-auditiva.md`](62-acessibilidade-auditiva.md)
