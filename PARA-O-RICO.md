# Rico, lê isto primeiro

Sou o Claude, trabalho com o Mateus. Peguei na gravação da vossa chamada de 30-07 e transformei-a na spec que está neste repo. Este ficheiro é o resumo do que encontrei — três coisas que vale a pena saberes antes de leres o resto.

**Ordem sugerida:** este ficheiro → [`SPEC.md`](SPEC.md) → [`spec/99-perguntas-abertas.md`](spec/99-perguntas-abertas.md).

---

## 1. Duas coisas que decidiram partem o vosso próprio pilar

O pilar que os dois defenderam com mais força foi este:

> **"tu tá nível 10 e aí o chefão é nível 11 e tu tá trancado e aí tu tem que ficar matando o bichinho lá, bichinho pra destrancar o jogo"** — tu, aos 01:17. E chamaste-lhe "mau".
>
> **"vai depender da tua habilidade no jogo. E não tanto da quantidade de poder."** — Mateus, aos 04:23.

Ficou como pilar nº1 da spec. Só que mais à frente decidiram duas coisas que fazem exactamente o contrário:

### a) Biomas por nível — 12:18

> "Por bioma, sei lá, **nível**, tipo."

Se o mapa se divide por nível, isso é trancar conteúdo por nível. É o gating que recusaram, com outro nome.

**A saída conhecida** (usada pelo Dark Souls, e ainda não decidida por vocês): *soft gating*. Podes ir para a zona difícil ao minuto um. Ninguém te impede. Simplesmente morres — a não ser que sejas bom. O nível reduz a margem de erro, não abre a porta.

### b) Evoluções de classe — 09:37

> "tem o mago nível 1 que usa e dá tanto dano. Aí tem o nível 2 e tem o nível 3, que **atira magia mais rápido**"

Lançar mais depressa é vantagem mecânica que veio do nível. Mesmo problema.

**E o mais curioso: tu já tinhas apontado a saída certa 16 segundos antes**, quando o Mateus sugeriu que a habilidade do mago fosse aumentar dano:

> "não, não aumentar o dano da magia, sei lá, **uma magia diferente**" — tu, aos 09:21

É essa a regra que resolve tudo: **as evoluções dão coisas novas para fazer, não números maiores.** Se ficar assim, o pilar aguenta-se de pé.

→ Perguntas 2 e 3 em [`spec/99-perguntas-abertas.md`](spec/99-perguntas-abertas.md)

---

## 2. O escopo, dito sem rodeios

Somando tudo o que descreveram em 13 minutos: mundo aberto grande, 3D, multi-bioma, **~61 chefes** (1 + 10 + 20 + 30, aos 03:25), 8 classes com evoluções, dois sistemas de magia, montarias, e co-op com mundo sincronizado.

Isso é trabalho de um estúdio com dezenas de pessoas, durante anos. Não é exagero meu — os três pontos que mais pesam:

1. **3D + souls-like** é dos géneros mais difíceis que há. O combate vive de animação, hitboxes e janelas de frames — precisamente o que é caro em 3D e barato em 2D.
2. **61 chefes.** Um chefe souls-like decente são dias de trabalho cada, mesmo com boas ferramentas.
3. **Mundo aberto grande** multiplica tudo: arte, colisões, navegação de IA, sincronização em rede.

**Não estou a dizer para cortar.** Está tudo escrito na spec, nada foi deitado fora. Mas há uma pergunta que decide se isto acaba ou fica numa pasta:

> Se só existisse **uma zona, um chefe e duas classes** — isso já era um jogo que vocês queriam jogar?

Se sim, é por aí que se começa, e o resto cresce por cima. Se se começar pelo mapa grande, é provável que nunca se chegue ao combate.

→ Pergunta 1 em [`spec/99-perguntas-abertas.md`](spec/99-perguntas-abertas.md)

---

## 3. Perdeu-se parte do que o Mateus disse

O microfone dele falhou. Cerca de 20 falas saíram como `[ininteligível]`. O teu áudio entrou limpo.

O que se perdeu, e importa:

| Momento | O que se perdeu |
|---|---|
| **05:40–05:41** | A resposta dele à tua pergunta sobre drops — *"Ou de acordo com a tua classe, será? O que que seria mais interessante?"*. **A pergunta ficou sem resposta.** |
| **10:44–10:56** | Um bloco inteiro, logo a seguir a perguntares *"como será que a gente faz o mundo?"*. Era provavelmente a resposta sobre o estilo visual. |
| 07:41–07:49 | Fala durante a lista das classes. Podem ter ficado classes por registar. |
| 06:17–06:18 | Reacção ao fecho da regra das armas. |

Se te lembrares do que ele disse nestes momentos, vale a pena recuperar. Está tudo em [`spec/99-perguntas-abertas.md`](spec/99-perguntas-abertas.md), na secção "Perdido no áudio".

---

## Como ler a spec

Cada afirmação traz uma etiqueta e o timestamp de onde saiu:

| | |
|---|---|
| `[DECIDIDO]` | Fechado por vocês. Não se muda sem uma decisão nova, registada. |
| `[SUGERIDO]` | Alguém disse, ninguém contrariou, ninguém confirmou. |
| `[EM ABERTO]` | Falta decidir. |
| `[TENSÃO]` | Duas coisas decididas que ainda não encaixam. |

Se vires algo marcado `[DECIDIDO]` que não te parece decidido, ou `[SUGERIDO]` que para ti já estava fechado — diz. A etiqueta é a minha leitura da gravação, e posso ter lido mal.

**Nada aqui foi inventado por mim.** Tudo tem origem na gravação. O que eu acrescentei são as tensões, os riscos e as perguntas — e está sempre identificado como tal.
