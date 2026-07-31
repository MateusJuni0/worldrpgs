# Coordenação — quem está a fazer o quê

Dois agentes escrevem nesta spec — o **Fable** (do lado do Rico) e o **Claude** (do lado do Mateus) — e o perigo não é pisarem-se por maldade, é fazerem **o mesmo pacote ao mesmo tempo** sem saberem um do outro.

A regra é uma só:

> **Antes de começar um pacote, reserva-o aqui, num commit pequeno e imediato. Antes de reservar, faz `git pull` e vê se já está reservado.**

Uma reserva é uma linha na tabela. Custa trinta segundos e evita deitar fora um dia de trabalho.

## Reservas

> **Desde 31-07: reserva-se por MARCO (M0…M7) ou por sistema, não por pacote de spec.** Os 20 pacotes estão escritos — ver [`spec/32-construcao.md`](spec/32-construcao.md).

| Pacote | Documento | Quem | Desde | Estado |
|---|---|---|---|---|
| WP0 | `spec/10-fatia-1.md` | Fable | 30-07 | ✅ entregue (`e49e6c1`), reparos na revisão do PR #1 |
| WP1 | `spec/01-combate.md` | Fable | 31-07 | ✅ entregue (PR #5, `0de11ef`) |
| WP1B | `spec/25-controlo.md` | Claude | 31-07 | ✅ entregue — números `[CLAUDE]`, afinam-se no protótipo |
| WP2 | `spec/11-formulas.md` | Fable | 31-07 | ✅ entregue (PR #6, `dc710d2`) |
| WP3 | `spec/12-classes.md` | Fable | 31-07 | ✅ entregue (PR #8, `dc710d2`) |
| WP4 | `spec/13-magia.md` | Fable | 31-07 | ✅ entregue (PR #9, `dc710d2`) |
| — | `spec/04-inimigos-chefes.md` (7 raças + Ceifador) | Fable | 31-07 | ✅ entregue (PR #7, `dc710d2`) — aprovado pelos dois |
| WP13 | `art/` + `spec/22-assets.md` | Claude | 31-07 | ✅ entregue — manifesto, prompts, fontes/licenças **e as 25 imagens geradas** (`83df034`) |
| WP11B | `spec/27-aprendizagem.md` | Claude | 31-07 | ✅ entregue — valida-se com teste de pessoa de fora (WP15B) |
| WP8B | `spec/26-narrativa.md` | Claude | 31-07 | ✅ entregue — guião de gravação de 7 perguntas para os donos |
| — | `spec/29-perspectiva.md` (1.ª/3.ª pessoa) | Claude | 31-07 | ✅ entregue — decisão nova do Mateus, com o que obriga |
| — | `spec/30-qualidade-visual.md` (barra visual) | Claude | 31-07 | ✅ entregue — desfaz o mal-entendido do "baixo poligonal" |
| — | `spec/31-referencias.md` (protocolo de investigação) | Claude | 31-07 | ✅ entregue — o que estudar do Dark Souls, e a linha |
| WP5 | `spec/14-equipamento.md` | Fable | 31-07 | ✅ entregue no branch `claude/game-spec-completa-81xz3g` — alinhado aos números do WP1/WP2 |
| WP12 | `spec/21-arte-render.md` | Fable | 31-07 | ✅ entregue no branch — animações, efeitos e som (pedido do Rico 31-07) |
| WP6 | `spec/15-inimigos.md` | Fable | 31-07 | ✅ entregue no branch — bestiário das 7 raças, IA comum, encontros da fatia |
| WP7 | `spec/16-chefes.md` | Fable | 31-07 | ✅ entregue no branch — regras de camada + ficha completa do Vorgar |
| WP8 | `spec/17-mundo.md` | Fable | 31-07 | ✅ entregue no branch — rede de zonas, dungeons, traçado de Brumal |
| WP9 | `spec/18-progressao.md` | Fable | 31-07 | ✅ entregue no branch — curva, loot instanciado, recompensa de ajuda a 40% |
| WP10 | `spec/19-rede.md` | Fable | 31-07 | ✅ entregue no branch — progresso individual resolvido, autoridade dividida, transporte |
| WP11 | `spec/20-interface.md` | Fable | 31-07 | ✅ entregue no branch — HUD, mochila, menus, configurações |
| WP14 | `spec/23-tecnico.md` | Fable | 31-07 | ✅ entregue no branch — Godot escolhido com dados, sistemas, dados afináveis, ferramentas |
| WP15 | `spec/24-plano.md` | Fable | 31-07 | ✅ entregue no branch — M0–M7, M1 já medido, riscos com resposta |
| WP15B | `spec/28-testes.md` | Fable | 31-07 | ✅ entregue no branch — protocolos, sintomas, ordem de afinação. **Todos os 20 pacotes do briefing estão escritos.** |

*Estados: 🔨 em curso · ✅ entregue · ⏸️ parado (dizer porquê)*

> Nota (31-07, Fable): uma segunda sessão do Fable chegou a duplicar WP1–WP4 sem ver estas reservas (os branches ainda não estavam na `main`). Resolvido a favor das versões com PR aberto e protótipo — as duplicadas foram descartadas no merge, e é por casos destes que a reserva se faz com push imediato.

## Como reservar

1. `git pull origin main`
2. Confirma que o pacote não está 🔨 por outro
3. Acrescenta a linha com o teu nome e a data
4. Commit + push imediato, só com esta mudança: `chore: reserva WP<N> (<quem>)`
5. Trabalha no teu branch normalmente

## Se os dois reservarem ao mesmo tempo

Acontece — dois pulls no mesmo minuto. O desempate é simples: **vale a reserva cujo commit chegou primeiro à `main`**. O outro escolhe outro pacote, ou comenta no PR do primeiro em vez de duplicar.

## Regra que faltava

**Quem faz o merge actualiza a linha desta tabela no mesmo acto.** A tabela ficou quatro pacotes atrasada a 31-07 e deu a impressão de que havia trabalho por entrar quando estava tudo dentro. Uma tabela de estado errada é pior do que não ter tabela nenhuma.

## ⚠️ Reservar NÚMEROS de documento, não só pacotes

**Regra nova (31-07, escrita depois de a quebrar).** A tabela acima reserva **pacotes**. Faltava reservar **números de ficheiro** — e a 31-07 os dois lados criaram um `spec/40-*.md` ao mesmo tempo. O do Fable teve de passar a `44` no merge.

**A culpa foi do lado do Claude:** publicou o 40, 41, 42 e 43 de uma vez sem avisar aqui. Fica a regra:

> **Antes de criar um ficheiro novo em `spec/`, acrescenta o número a esta lista e faz push imediato.** Um commit de uma linha chega.

### Números tomados

| Nº | Quem | O quê |
|---|---|---|
| 32–43 | Claude | construção, referências, morte, catálogo, estudos, física, anéis, ataques, decisões |
| 44 | Fable | protótipo |
| 45 | Claude | controlos configuráveis |
| 46 | Claude | coerência bioma→raça→item |
| 47 | Claude | do greybox ao visual |
| 48 | Claude | arcos, bestas e escudos |
| **49+** | **livre** | |

## ⭐ O ciclo Fable ↔ Claude — como se trabalha a partir de 31-07

`[DECIDIDO]` (Mateus, 31-07-2026) — *"conforme ele vai fazendo ele vai comitando, e tu vais vendo, aprovando, e daí ele vai pro próximo. Nesse meio tempo tu aprovas o commit que ele fez e pensas em mais gaps pra ele resolver."*

**Não é uma entrega grande no fim. São voltas pequenas, e os dois trabalham ao mesmo tempo.**

```
   FABLE                              CLAUDE
     │                                   │
  1. reserva o pacote aqui  ──────────►  │
     │  (push imediato)                  │
  2. escreve spec + game/data            │
  3. abre PR + avisa na issue #3 ─────►  4. revê contra as 4 leis e o DECISOES
     │                                   5. aprova e faz merge
     │                                   │
  7. pega no próximo  ◄──────────────── 6. comenta no PR:
     │                                      (a) o veredito
     │                                      (b) as IMAGENS que o pacote desbloqueou
     │                                      (c) os GAPS novos para o próximo
     ▼                                   │
  (volta ao 1)                           │  ⭐ enquanto ele escreve o seguinte,
                                         │  o Claude gera as imagens do anterior
                                         │  e procura lacunas
```

⭐ **O paralelismo é o ponto.** Enquanto o Fable escreve o pacote N+1, o Claude está a **gerar as imagens do pacote N** e a **caçar lacunas**. Ninguém espera por ninguém.

### As regras do ciclo

| | |
|---|---|
| **Um pacote por PR** | o #11 trouxe 1333 linhas e 11 pacotes, e o conflito foi feio |
| **Spec + `game/data` no mesmo PR** | o motor é data-driven: escrever o catálogo **é** construir o jogo |
| **Avisar na issue #3** | uma linha — *"pacote X pronto, PR #N"*. É o sino |
| **O Claude não trava** | se o PR está bom, entra. Reparos vão no comentário, não bloqueiam |
| ⚠️ **O Claude comenta sempre com os gaps do próximo** | é o que faz a volta seguinte arrancar sem esperar pelo Mateus |
| **Não decidir `[TENSÃO]`** | propõe-se; decidem o Mateus e o Rico |

### A fila — 10 voltas até à spec completa

| # | Pacote | O que desbloqueia |
|---|---|---|
| **1** | **12 fichas de bioma** ([`spec/46`](spec/46-coerencia-bioma-raca-item.md) §2) | paletas, luz e névoa · **fecha as perguntas 4 e 13** |
| **2** | **12 fichas de raça** (§5) — 6 novas | descrições de tudo · inimigos |
| **3** | **WP5 camada 1** — 8 famílias de arma + 9 peças de armadura | 🖼️ **17 imagens** |
| **4** | **WP4 magia** — escolas + grelha de verbos + melhoria | 🖼️ ícones de feitiço |
| **5** | **WP6 bestiário** — fichas de inimigo + baralhos de espólio | 🖼️ retratos |
| **6** | **WP5 camada 2** — instâncias da fatia 1, com `descrição visual` | 🖼️ ícones de item |
| **7** | **WP7 chefes** — subchefes, guardiões, fichas de ataque | |
| **8** | **Sistemas** — interrupção, contra-ataque, soft caps, piso de 30% | |
| **9** | **WP8 mundo** — círculos, atalhos, 12 biomas | |
| **10** | **Alinhamento** dos 11 documentos antigos | |

⚠️ **A ordem não é negociável nas três primeiras.** As fichas de bioma e raça são o motor que gera todas as descrições ([`spec/46`](spec/46-coerencia-bioma-raca-item.md) §5) — feitas ao contrário, cada descrição é inventada de novo e nada combina.

### 🖼️ As imagens

O caminho completo está em [`art/PIPELINE.md`](art/PIPELINE.md). O resumo:

- **O Fable escreve** a coluna `descrição visual` e a coluna `Fatia 1?`. **Nunca gera imagens**
- **O Claude gera** com **nano banana** (o mesmo modelo das 32 que existem — não se mistura), remove fundo nos ícones, arquiva e regista
- ⚠️ **Orçamento real: ~70 imagens.** É a coluna `Fatia 1?` que decide quais

## Quem trata das entregas

O **Claude** (lado do Mateus) verifica o repositório em ciclo: PRs novos são revistos e, com a autorização permanente do Mateus (31-07), integrados quando estão bem. Não é preciso esperar por ninguém para entregar — abre o PR e ele será visto.

## Pacotes livres

Tudo o que não está na tabela está livre. A ordem recomendada continua a ser a do [`prompts/BRIEFING-FABLE.md`](prompts/BRIEFING-FABLE.md), mas dois pacotes independentes podem correr em paralelo sem problema — é para isso que isto existe.
