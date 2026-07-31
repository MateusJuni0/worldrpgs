# Coordenação — quem está a fazer o quê

Dois agentes escrevem nesta spec — o **Fable** (do lado do Rico) e o **Claude** (do lado do Mateus) — e o perigo não é pisarem-se por maldade, é fazerem **o mesmo pacote ao mesmo tempo** sem saberem um do outro.

A regra é uma só:

> **Antes de começar um pacote, reserva-o aqui, num commit pequeno e imediato. Antes de reservar, faz `git pull` e vê se já está reservado.**

Uma reserva é uma linha na tabela. Custa trinta segundos e evita deitar fora um dia de trabalho.

## Reservas

| Pacote | Documento | Quem | Desde | Estado |
|---|---|---|---|---|
| WP0 | `spec/10-fatia-1.md` | Fable | 30-07 | ✅ entregue (`e49e6c1`), reparos na revisão do PR #1 |
| WP1B | `spec/25-controlo.md` | Claude | 31-07 | 🔨 em curso |

*Estados: 🔨 em curso · ✅ entregue · ⏸️ parado (dizer porquê)*

## Como reservar

1. `git pull origin main`
2. Confirma que o pacote não está 🔨 por outro
3. Acrescenta a linha com o teu nome e a data
4. Commit + push imediato, só com esta mudança: `chore: reserva WP<N> (<quem>)`
5. Trabalha no teu branch normalmente

## Se os dois reservarem ao mesmo tempo

Acontece — dois pulls no mesmo minuto. O desempate é simples: **vale a reserva cujo commit chegou primeiro à `main`**. O outro escolhe outro pacote, ou comenta no PR do primeiro em vez de duplicar.

## Quem trata das entregas

O **Claude** (lado do Mateus) verifica o repositório em ciclo: PRs novos são revistos e, com a autorização permanente do Mateus (31-07), integrados quando estão bem. Não é preciso esperar por ninguém para entregar — abre o PR e ele será visto.

## Pacotes livres

Tudo o que não está na tabela está livre. A ordem recomendada continua a ser a do [`prompts/BRIEFING-FABLE.md`](prompts/BRIEFING-FABLE.md), mas dois pacotes independentes podem correr em paralelo sem problema — é para isso que isto existe.
