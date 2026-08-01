# 04 — Inimigos e chefes

> ⚠️ **Este é o registo da sessão 1 — o que eles disseram, com timestamps. NÃO é o estado actual do projeto.**
>
> Os `[EM ABERTO]` daqui para baixo foram, na maior parte, **respondidos** pelos pacotes de execução. Este documento fica como fonte histórica: é aqui que se vê o que saiu da boca deles e quando.
>
> **Onde está a resposta:** Bestiário → [`15-inimigos.md`](15-inimigos.md) (WP6) · Chefes → [`16-chefes.md`](16-chefes.md) (WP7)
>
> Em caso de divergência, **manda o documento de execução**. E o que estiver decidido pelos donos está em [`../DECISOES.md`](../DECISOES.md).

## Duas camadas

`[DECIDIDO]` (sessão 1 · 00:54) — inimigos normais espalhados pelo mundo, e chefes.

> "Vai ter tipo inimigo baixo e depois vai ter o chefão" — Rico

## Raças

`[DECIDIDO]` (02:25 → 02:37) — raças de fantasia clássicas. Orcs foram nomeados e aceites pelos dois.

> Mateus: "pode ser umas raças padrão, tipo, os orc, bagulho assim, né?" (02:25)
> Rico: "Ah, coisa de orc pode. Coisa de orc pode." (02:37)

`[DECIDIDO]` (Mateus + Rico, 31-07-2026) — **sete raças para espalhar pelo mapa**, com as notas dele e o gancho que cada uma já tem na spec:

| Raça | A nota do Rico | Gancho na spec | Fatia 1? |
|---|---|---|---|
| Goblin | pequeno, verde ou cinza, ataca em grupos | grupos são o primeiro inimigo que castiga o lock-on preso num alvo só ([`01-combate.md`](01-combate.md)) | ⬜ |
| Kobold | pequeno réptil covarde que gosta de armadilhas | foge e arma o terreno — par natural das dungeons ([`05-mundo.md`](05-mundo.md)) | ⬜ |
| Esqueleto | resto mortal reanimado por magia fraca | candidato óbvio a fraqueza clara — "a magia certa no inimigo certo" (05:04) | ⬜ |
| Zumbi | cadáver lento que resiste a dano comum | resistir a físico obriga a trocar de ferramenta — a Lei 2 do lado do inimigo | ⬜ |
| Orc | guerreiro tribal feroz e musculoso | já era `[DECIDIDO]` da sessão 1 (02:25) — é a raça da fatia | ✅ lanceiro, brutamontes, Vorgar |
| Minotauro | homem com cabeça de touro que vive em labirintos | pede uma dungeon-labirinto própria — candidato a subchefe com arena dedicada | ⬜ |
| Mímico | monstro que se disfarça de baú de tesouro | vive do loot: castiga a ganância; pede baús no mundo ([`06-itens-inventario.md`](06-itens-inventario.md)) | ⬜ |

Nenhuma destas entra na fatia 1 — a fatia continua com os 2 orcs + Vorgar ([`10-fatia-1.md`](10-fatia-1.md)). Entram no bestiário completo do WP6, por esta ordem de afinidade com o que já existe.

## Hierarquia de chefes

`[SUGERIDO]` (03:25) — uma pirâmide.

> "pode ter, por exemplo, um chefão ultra pra zerar o jogo, aí depois, sei lá, 10 subchefes, e aí depois mais 20 abaixo dele, e depois mais 30 abaixo" — Rico

| Camada | Quantidade | 
|---|---|
| Chefe final | 1 |
| Subchefes | 10 |
| Terceira camada | 20 |
| Quarta camada | 30 |
| **Total** | **61** |

A razão dada foi tempo de jogo: "uma hierarquia bastante pra gente ter bastante tempo de jogo" (03:43).

`[EM ABERTO]` — **Os números não bateram certo na própria sessão.** Às 11:54 o Mateus recapitulou como "um chefe principal, mais os 30, mais 20 abaixo dele", omitindo a camada dos 10. O Rico respondeu "a gente vai fazer várias coisas assim, a gente vai acertar isso" (12:05). Fica por acertar.

`[EM ABERTO]` — **61 chefes é o maior risco de escopo do projeto.** Ver a secção de risco em [`00-visao.md`](00-visao.md). A pergunta útil não é "quantos chefes" mas "quantos chefes no primeiro jogável".

`[EM ABERTO]` — A hierarquia é de **dificuldade** ou de **narrativa**? Um chefe da quarta camada é um capanga do subchefe, ou apenas um chefe mais fraco noutro sítio do mapa? Muda completamente o design do mundo.

### O Ceifador — candidato a subchefe

`[DECIDIDO]` (Mateus + Rico, 31-07-2026) — entra como chefe ou subchefe. *(Ideia do Rico: "adiciona como um boss ou subchefe, achei ele legal"; confirmado pelos dois a 31-07.)* A camada exacta fica com a pergunta 13.

Referência visual enviada pelo Rico: figura alta encapuzada, armadura escura ornamentada, manto esfarrapado, **foice de lâmina de osso serrado**. A imagem de referência é arte de outro jogo e **não entra no repositório** (isto é público) — fica esta descrição; a arte final é nossa, feita no pipeline do WP13 ao estilo da referência.

Ganchos de design `[FABLE]`, para o WP7 desenvolver:

- A foice ataca em **arcos largos e varridos** — o espaço seguro é *dentro* do arco, colado ao corpo dele. É o subchefe que ensina a esquivar **para a frente**: o anti-instinto que separa quem lê o inimigo de quem só reage.
- Varridos: `só esquiva`. O golpe descendente (overhead): `aparável` — a única janela de parry dele, lenta e bem telegrafada.
- Par temático natural: esqueletos e zumbis como inimigos da zona dele — a raça morta-viva ganha o seu senhor.

## Como se chega aos chefes

`[DECIDIDO]` (01:17 → 04:28) — **não há bloqueio por nível.** É o pilar 1. Ver [`00-visao.md`](00-visao.md).

Em termos de inimigos, isto significa:
- Nenhum chefe verifica o nível do jogador para deixar entrar
- Nenhum chefe é impossível por falta de estatísticas, só por falta de perícia
- Não existe conteúdo desenhado para obrigar a *grind*

~~`[TENSÃO]`~~ **RESOLVIDA** — `[DECIDIDO]` (Mateus + Rico, 31-07-2026): **soft gating.** O mapa está todo aberto; as zonas têm dificuldade **sugerida, não exigida**. Ver [`05-mundo.md`](05-mundo.md).

O que o bestiário (WP6) herda: **nenhum inimigo verifica nível**, os inimigos de zona alta comunicam o perigo **pela leitura** (aspecto, restos no chão, o que fazem antes de atacar), e a corrida normal tem de superar a perseguição comum. O contrato posterior limita a garantia a carga ≤100% ([`70`](70-fecho-dos-sistemas-de-combate.md) §1.1); a Revisão 2 preencheu as 18 velocidades omitidas e passou a validar as 33 fichas contra o tecto de 5,0 m/s ([`67`](67-catalogo-do-bestiario.md) §3; `LACUNAS`).

## Inimigos e magia

Implícito em "tem que ver a magia que tu usa nele" (05:04): os inimigos têm fraquezas. `[EM ABERTO]` — nenhum sistema definido. Ver [`03-magia.md`](03-magia.md).

## Não discutido

- Comportamento e IA dos inimigos
- Telegrafia dos ataques (essencial para esquiva e parry funcionarem — ver [`01-combate.md`](01-combate.md))
- Se os inimigos reaparecem, e quando
- Chefes com várias fases
- Chefes opcionais
- Inimigos únicos vs reutilizados com estatísticas diferentes
- Vida, dano, recompensa de qualquer inimigo
- Chefes em co-op: ajustam a dificuldade para dois jogadores? Ver [`07-multiplayer.md`](07-multiplayer.md)
