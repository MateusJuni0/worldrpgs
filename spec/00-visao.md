# 00 — Visão

## Pitch

Um RPG de acção em 3D, terceira pessoa, com combate souls-like, num mundo aberto grande dividido por biomas, onde dois amigos jogam juntos do princípio ao fim. `[DECIDIDO]` (sessão 1 · 00:04, 11:28, 12:28)

## Os pilares

Três coisas que, se se perderem, deixa de ser este jogo.

### 1. Ganha-se com habilidade, não com nível `[DECIDIDO]` (sessão 1 · 01:17 → 04:28)

Este é **o** pilar. Foi a única coisa da sessão em que os dois insistiram, e o Rico chegou a chamar "mau" ao jogo que faz o contrário.

O que fica proibido, nas palavras deles:

> "tu tá nível 10 e aí o chefão é nível 11 e tu tá trancado e aí tu tem que ficar matando o bichinho lá, bichinho pra destrancar o jogo" — Rico (01:17)

O que fica no lugar:

> "se tu conseguisse esquivar, se tu conseguir fazer as coisas..." — Rico (04:10)
> "vai depender da tua habilidade no jogo. E não tanto da quantidade de poder." — Mateus (04:23)

**Consequência prática:** um jogador bom tem de conseguir matar um chefe muito acima do seu nível. O nível reduz a margem de erro; não é uma chave que abre a porta. Qualquer sistema que se desenhe daqui para a frente tem de passar neste teste.

### 2. Dois jogadores, sempre `[DECIDIDO]` (sessão 1 · 12:28)

> "Tu sempre pode jogar multiplayer" — Rico

Não é um modo à parte nem um extra. O jogo é para ser jogado a dois. Ver [`07-multiplayer.md`](07-multiplayer.md).

### 3. Longo `[DECIDIDO]` (sessão 1 · 03:43)

> "uma hierarquia bastante pra gente ter bastante tempo de jogo" — Rico

Querem um jogo que dure. Isto entra em tensão directa com o esforço que dá construir 3D — ver a secção de risco abaixo.

## Referência principal: Dark Souls

Citado quatro vezes, e sempre para coisas concretas:

| O que se vai buscar | Onde | Timestamp |
|---|---|---|
| Habilidade acima de nível | O pilar 1 | 01:51 |
| Sistema de requisitos de arma (sem bloqueio duro por classe) | [`06-itens-inventario.md`](06-itens-inventario.md) | 06:14 |
| Atributos e leveling (vida, sabedoria, constituição, stamina) | [`02-personagem.md`](02-personagem.md) | 06:33 |
| Esquiva e parry no corpo a corpo | [`01-combate.md`](01-combate.md) | 02:04 |

O que **não** foi discutido do Dark Souls, e portanto não está decidido: fogueiras/checkpoints, perder as almas ao morrer, invasões PvP, poise, tolerância de i-frames, mensagens no chão.

## Género e tom

- 3D `[DECIDIDO]` (11:28) — "Acho que o jogo pode ser em 3D", com o Mateus a acrescentar "pode ser de início" (11:32), ou seja, sem se fechar a mudar
- Não realista `[SUGERIDO]` (10:24) — "Realista não, mas tipo..." e a frase ficou por acabar
- Fantasia medieval: espadas, escudos, arco e flecha, magia, orcs, paladinos, cavalos `[DECIDIDO]` (00:16, 02:35, 07:40, 05:15)
- Estilo visual concreto `[EM ABERTO]` — a pergunta "como será que a gente faz o mundo?" (10:32) ficou sem resposta na gravação

## Para quem é

Para os dois. Não há intenção de vender, publicar ou fazer disto produto. Isso muda o que faz sentido: podem cortar tudo o que existe só para agradar a estranhos (tutorial extenso, acessibilidade de mercado, localização, monetização), e podem manter coisas que só fazem sentido para eles.

## ⚠️ Risco de escopo — ler antes de decidir mais

Nada disto invalida o projeto. Mas fica registado, porque é a diferença entre um jogo acabado e uma pasta abandonada.

O que a sessão 1 descreveu é, somando: mundo aberto grande, 3D, multi-bioma, ~61 chefes, 8 classes com evoluções, dois sistemas de magia, montarias, e co-op sincronizado. Isso é escala de estúdio com dezenas de pessoas e anos.

Os três pontos que mais pesam, por ordem:

1. **3D + souls-like** é dos géneros mais difíceis que existem. O combate vive de animação, hitboxes, i-frames e feedback — precisamente o que é caro em 3D e barato em 2D.
2. **~61 chefes** (01 ultra + 10 + 20 + 30, dito às 03:25). Um chefe souls-like decente são dias de trabalho cada, mesmo com ferramentas boas.
3. **Mundo aberto grande** multiplica tudo: arte, colisões, navegação de IA, sincronização em rede.

**Isto não é para cortar agora.** É para responder a uma pergunta em [`99-perguntas-abertas.md`](99-perguntas-abertas.md): *qual é a fatia mais pequena disto que já é divertida de jogar a dois?* Se essa fatia funcionar, o resto cresce por cima. Se se começar pelo mapa grande, provavelmente não se chega ao combate.

## Ligações

- Perguntas por responder: [`99-perguntas-abertas.md`](99-perguntas-abertas.md)
- Transcrição da sessão 1: [`../design/transcripts/`](../design/transcripts/)
