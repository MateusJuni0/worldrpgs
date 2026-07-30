# 07 — Multiplayer

O jogo é para dois. Não é um modo extra — é o motivo do projeto existir.

## Sempre disponível

`[DECIDIDO]` (sessão 1 · 05:15, 12:28)

> "dá pra nós jogar em dupla" — Rico (05:15)
> "Tu sempre pode jogar multiplayer." — Rico (12:28)

`[EM ABERTO]` — "Sempre" quer dizer o quê: sessão partilhada permanente (mundo comum, ambos entram e saem quando querem), ou possibilidade de convidar a qualquer momento para o mundo de um deles? São arquitecturas muito diferentes.

`[EM ABERTO]` — Dois jogadores exactamente, ou dois é só o caso deles? Nada foi dito sobre mais.

## Mundo sincronizado

`[SUGERIDO]` (12:34)

> "Os inimigos que te aparecem pra mim, aparecem pra tu, e vice-versa, mesmo se tu já matou ou não, tu me ajuda a matar, e aí tu ganha uma recompensa menor." — Rico

Há três coisas dentro desta frase, e vale a pena separá-las:

### 1. Os inimigos existem para ambos
Os dois jogadores vêem os mesmos inimigos. Combate cooperativo a sério, não mundos paralelos.

### 2. O progresso é individual
"mesmo se tu já matou ou não" — se um já matou um inimigo e o outro não, o inimigo continua a existir para quem falta. Ou seja: **cada jogador tem o seu estado de progresso**, e o mundo mostra-se conforme quem está a jogar.

### 3. Recompensa reduzida ao ajudar
Quem ajuda num inimigo que já matou recebe menos. Trava o farm repetido, mantém o incentivo a ajudar.

`[EM ABERTO]` — **Este é o sistema mais complexo do jogo inteiro, e está descrito numa frase.** Se cada jogador tem progresso próprio mas partilham espaço, é preciso resolver: um chefe já morto para um e vivo para o outro aparece? Se sim, como? Um deles abriu um atalho — está aberto para o outro? Vale a pena tratar isto numa sessão só para si.

## Drops em co-op

`[EM ABERTO]` — Ver [`06-itens-inventario.md`](06-itens-inventario.md). O Rico propôs cópia para os dois (05:29) e imediatamente se questionou (05:36); a resposta do Mateus perdeu-se no áudio.

## Escalonamento de dificuldade

`[EM ABERTO]` — Nunca mencionado. Dois jogadores contra um chefe desenhado para um é metade da dificuldade. Os souls-like normalmente aumentam a vida do chefe em co-op. Se não se decidir nada, o pilar 1 fica comprometido — porque a solução para qualquer chefe difícil passa a ser "chamar o outro".

## Rede

`[EM ABERTO]` — Nada foi decidido, e é a maior decisão técnica do projeto.

Sabe-se que jogam cada um no seu PC, em casas diferentes. Isso obriga a atravessar NAT, o que dá basicamente três caminhos:

| Caminho | A favor | Contra |
|---|---|---|
| **P2P com um a hospedar** | Sem custo, sem servidor | NAT é chato; quem hospeda tem vantagem de latência; se sai, acaba |
| **Servidor dedicado** | Justo, autoritativo | Custa dinheiro e trabalho |
| **Relay** (Steam, Epic, Photon, Nakama) | Resolve NAT sem servidor próprio | Prende a um serviço externo |

Ver [`09-tecnico.md`](09-tecnico.md).

`[EM ABERTO]` — Modelo de autoridade. Num souls-like, esquiva e parry vivem de janelas de milissegundos. Quem decide se a esquiva acertou: o cliente ou o servidor? Esta decisão condiciona toda a arquitectura e é fácil de adiar até ser cara.

## Não discutido

- Fogo amigo (a magia acerta no parceiro?)
- Ressuscitar o parceiro caído
- Voz e chat
- PvP e invasões (ambos existem no Dark Souls; nenhum foi mencionado)
- O que acontece se um se desligar a meio de um chefe
- Progresso de história partilhado ou separado
