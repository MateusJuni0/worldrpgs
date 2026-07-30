# 09 — Técnico

**Nada foi decidido nesta área.** Não é lapso da spec: a sessão 1 foi sobre o jogo, não sobre como construí-lo. Este documento existe para registar o tamanho do buraco.

## O que se sabe

| | |
|---|---|
| 3D | `[DECIDIDO]` (11:28), com "pode ser de início" do Mateus a deixar porta aberta (11:32) |
| Plataforma | PC, os dois, cada um em sua casa — implícito em toda a conversa |
| Rede | Necessária. Nada mais decidido. |

## O que falta decidir, por ordem de peso

### 1. Engine `[EM ABERTO]`

Não foi mencionada nenhuma. É a decisão que condiciona tudo o resto e não deve ser tomada por gosto, mas pelo que a spec pede: 3D, terceira pessoa, combate com animação precisa, mundo aberto, rede para dois.

A discutir na próxima sessão sobre técnica, não agora.

### 2. Rede `[EM ABERTO]`

Ver [`07-multiplayer.md`](07-multiplayer.md). Duas perguntas ligadas:
- Como se ligam duas casas diferentes (P2P com NAT punching, relay, ou servidor)
- Quem tem autoridade sobre o combate (cliente ou servidor)

A segunda é a que magoa se for adiada. Um souls-like em rede com autoridade errada dá esquivas que parecem acertar e não acertam, e não há forma barata de corrigir depois.

### 3. Arte 3D `[EM ABERTO]`

É provavelmente o maior custo real do projeto, e não foi falado. Modelos, animações de combate, cenários, efeitos. Comprar pronto, gerar, ou fazer? A resposta muda o cronograma numa ordem de grandeza.

### 4. Gravação de progresso `[EM ABERTO]`

Com progresso individual num mundo partilhado ([`07-multiplayer.md`](07-multiplayer.md)), onde é que fica guardado o estado de cada jogador, e quem manda quando divergem.

## Nota sobre o método

A intenção é o Fable do Rico construir a partir desta spec. Isso levanta a exigência de precisão: o que estiver vago aqui vai ser decidido por quem constrói, e provavelmente de forma diferente do que os dois imaginam.

A regra útil: **tudo o que estiver `[EM ABERTO]` quando a construção começar é uma decisão que vocês delegaram sem saber.** Ver [`99-perguntas-abertas.md`](99-perguntas-abertas.md).
