# 02 — Personagem

> ⚠️ **Este é o registo da sessão 1 — o que eles disseram, com timestamps. NÃO é o estado actual do projeto.**
>
> Os `[EM ABERTO]` daqui para baixo foram, na maior parte, **respondidos** pelos pacotes de execução. Este documento fica como fonte histórica: é aqui que se vê o que saiu da boca deles e quando.
>
> **Onde está a resposta:** Atributos e fórmulas → [`11-formulas.md`](11-formulas.md) (WP2) · Classes, habilidades e skills → [`12-classes.md`](12-classes.md) (WP3)
>
> Em caso de divergência, **manda o documento de execução**. E o que estiver decidido pelos donos está em [`../DECISOES.md`](../DECISOES.md).

## Atributos

Modelo Dark Souls: pontos ganhos por nível, distribuídos à escolha. `[DECIDIDO]` (sessão 1 · 06:33)

> "a gente pode ir upando, tipo, 30 em vida, 40 em sabedoria, em constituição, ou stamina, tipo, tudo estilo Dark Souls" — Rico (06:33)

Atributos nomeados na conversa:

| Atributo | Nomeado | Estado |
|---|---|---|
| Vida | 06:33 | `[DECIDIDO]` |
| Sabedoria | 06:33 | `[DECIDIDO]` |
| Constituição | 06:33 | `[DECIDIDO]` |
| Stamina | 06:33 | `[DECIDIDO]` |
| Usos de magia | 03:50 | `[DECIDIDO]` — pode ser atributo ou recurso à parte, não ficou claro |

`[EM ABERTO]` — **Constituição e Vida sobrepõem-se.** No Dark Souls são coisas diferentes (Vigor dá vida, Endurance dá stamina, Vitality dá capacidade de carga). Aqui foram ditos os quatro sem se definir o que cada um faz. Precisa de resolução antes de qualquer fórmula.

`[EM ABERTO]` — Força, destreza, fé, inteligência, resistência: não mencionados. Faltam, se se quiser mesmo o modelo Dark Souls.

### Nível máximo

`[SUGERIDO]` — 100 ou 150 (06:33). O Rico disse "vai até o nível 100, ou, sei lá, 150". Não foi confirmado.

## Classes

Escolhe-se uma classe no início. `[DECIDIDO]` (06:55)

> "tu escolheria a tua classe e a partir daí tu..." — Rico (06:55)
> "E botaria as skill no personagem que tu é." — Mateus (07:02)

### As classes nomeadas `[SUGERIDO]`

Saíram de uma enumeração rápida entre os dois (07:13 → 07:57). Nenhuma foi confirmada nem descartada:

1. Feiticeiro / Mago (Rico, 07:13)
2. Guerreiro (Rico, 07:13)
3. Assassino (Mateus, 07:27)
4. Batedor (Rico, 07:29)
5. Berserker (Mateus, 07:35)
6. Tanque (Mateus, 07:35)
7. Paladino (Rico, 07:40)
8. Mago do mal (Rico, 07:57)

`[EM ABERTO]` — **Oito classes é muito para dois jogadores.** Cada classe precisa de skills próprias, habilidade especial, equilíbrio, e provavelmente animações. E como só jogam dois de cada vez, a maior parte nunca vai ser jogada. Vale a pena perguntar quantas é que querem mesmo no início.

`[TENSÃO]` — Berserker e Tanque são quase o oposto um do outro em papel, mas ambos são guerreiro de armadura. Assassino e Batedor sobrepõem-se muito. Feiticeiro e Mago do mal podem ser a mesma classe com escolas de magia diferentes — ver [`03-magia.md`](03-magia.md).

### Habilidade especial por classe

Cada classe tem uma habilidade especial que é o seu ponto forte. `[DECIDIDO]` (08:08)

O conteúdo dessas habilidades foi **explicitamente adiado**:

> "isso a gente pode pensar depois, não precisa pensar agora" — Rico (08:31)
> "Sim, tá. Pode adicionar depois." — Mateus (08:35)

Ideias soltas que saíram na mesma (todas `[SUGERIDO]`):

| Classe | Ideia | Timestamp |
|---|---|---|
| Guerreiro | Mais vida, mais força | 08:39, 08:53 |
| Paladino | "um pouco de raio" | 08:39 |
| Tanque | Fica com o escudo | 08:39 |
| Mago | Um feitiço a mais, um conjuramento | 08:53 |
| Assassino | Mais rápido | 09:37 |

Sobre a habilidade do mago houve uma correcção que vale a pena guardar, porque diz muito sobre o gosto deles:

> Mateus: "Do mago, aumentar o dano da magia." (09:18)
> Rico: "não, não aumentar o dano da magia, sei lá, uma magia diferente" (09:21)

Ou seja: preferem **habilidades que mudam o que se pode fazer** a habilidades que mudam números. Isso é uma directriz de design útil e deve valer para todas as classes.

## Evoluções de classe

`[SUGERIDO]` (09:37) — o personagem evolui por patamares dentro da classe.

> "tem o mago nível 1 que usa e dá tanto dano. Aí tem o nível 2 e tem o nível 3, que atira magia mais rápido, que faz mais coisa mais rápido. Ou assim para as outras classes também" — Rico (09:37)

Exemplos dados: mago lança mais rápido; assassino mais rápido; outras classes mais resistentes.

`[EM ABERTO]` — Como é que se sobe de patamar? Por nível? Por missão? Por item? Não foi dito.

`[TENSÃO]` — **Isto colide com o pilar 1.** Se o mago nível 3 lança magia mais depressa que o mago nível 1, então o nível está a dar vantagem mecânica, que é exactamente o que o pilar 1 recusa. Há duas saídas, e é preciso escolher uma:
- **(a)** as evoluções dão opções novas em vez de números melhores (alinha com a correcção do Rico às 09:21)
- **(b)** as evoluções dão mesmo poder, e aceita-se que o pilar 1 é sobre chefes e não sobre progressão interna

## Skills

`[DECIDIDO]` (06:04, 07:02) — o personagem tem skills que se activam, e são elas que definem o que ele é bom a fazer.

> "Vai depender das skill que tu ativar no teu personagem, né?" — Mateus (06:04)

Isto é a peça que resolve o problema das armas: não se bloqueia o uso de uma arma, mas quem não tem as skills não a aproveita. Ver [`06-itens-inventario.md`](06-itens-inventario.md).

`[EM ABERTO]` — Tudo o resto sobre skills: quantas, como se ganham, se são árvore ou lista, se se pode trocar, se há limite de skills activas ao mesmo tempo.

## Não discutido

- Criação de personagem / aparência
- Género do personagem
- Nome, história, motivação
- Reespecialização (mudar de classe ou redistribuir pontos)
- Se os dois jogadores podem escolher a mesma classe

> **RESOLVIDO 01-08 no [`64`](64-criacao-de-personagem.md):** nome, aspecto/voz e fluxo de criação; os dois podem escolher a mesma origem. A classe é preset inicial e não fecha arma, magia, atributo, espólio ou conteúdo. Reespecialização continua separada e em aberto.
