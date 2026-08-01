# WorldRPGs

RPG 3D para PC, **primeira ou terceira pessoa à escolha**, **souls-like**, co-op para dois. Projeto hobby do **Mateus** e do **Rico**.

> **Especificação primeiro, código depois — e o depois é agora.** Os 20 pacotes de spec estão escritos (31-07-2026) e a construção arrancou. A spec continua a mandar: código que diverja dela obriga a mudar a spec no mesmo PR.

## Estado

| | |
|---|---|
| Fase | **Construção** — 20/20 pacotes escritos; a Revisão 1 reabriu **5 lacunas vermelhas** em [`LACUNAS.md`](LACUNAS.md) |
| Máquina alvo | **Gráficos integrados, 1080p @ 60 fps** — sem placa dedicada |
| Código | **Em [`game/`](game/)** — protótipo jogável em Godot 4.7.1; abre com `game/JOGAR.bat` |
| Engine | **Godot 4.7.1**, renderer Mobile |
| Sessões gravadas | 1 (30-07-2026, 13m13s) |

## Como isto funciona

1. Mateus e Rico falam sobre o jogo numa chamada. O OBS grava.
2. A gravação é transcrita e as ideias organizadas → `design/`
3. O que ficou decidido entra na spec → `spec/`
4. O que ficou por decidir entra em [`spec/99-perguntas-abertas.md`](spec/99-perguntas-abertas.md) e volta para a conversa seguinte
5. Repete

A spec cresce a partir das conversas. Nada entra aqui por invenção — cada decisão tem o timestamp da gravação onde foi tomada.

## Mapa do repositório

```
CLAUDE.md                    contexto para os agentes que trabalham aqui
DECISOES.md                  registo de decisoes, por ordem, com o que substituem
PARA-O-RICO.md               o que encontrei na sessao 1 — ler primeiro
PONTE-CLAUDE.md              guia do Rico para a ponte
COORDENACAO.md               quem está a fazer o quê — reservar antes de começar
SPEC.md                      índice mestre, com o estado de cada área
spec/
  00-visao.md                o que é o jogo, e os pilares que não se negoceiam
  01-combate.md              esquiva, parry, stamina — o núcleo
  02-personagem.md           atributos, classes, evoluções, skills
  03-magia.md                magia do bem e do mal, encantamentos
  04-inimigos-chefes.md      bestiário e a hierarquia de chefes
  05-mundo.md                mapa, biomas, dungeons
  06-itens-inventario.md     armas, mochila, montarias, drops
  07-multiplayer.md          co-op, sincronização, recompensas
  08-ui.md                   HUD, hotbar, menus
  09-tecnico.md              engine, rede, plataformas
  99-perguntas-abertas.md    tudo o que falta decidir, por ordem de urgência
prompts/
  BRIEFING-FABLE.md          prompt-raiz do agente que detalha a spec
  ARRANQUE-FABLE.md          o que o Rico cola no Fable para arrancar
  PROXIMOS-PACOTES.md        a fila dos 11 pacotes que faltam
  REALINHAMENTO.md           o que dar ao Fable depois dos commits dele
art/                         assets: manifesto, prompts de imagem, ficheiros
game/                        o protótipo jogável (Godot 4.7.1) — JOGAR.bat abre com dois cliques
medicoes/                    medições de desempenho cruas, tal como a ferramenta as escreveu
tools/check-coerencia.mjs    guarda tecnico da spec, corre em cada PR
design/
  transcripts/               transcrições das sessões
  ideas/                     ideias organizadas por sessão
memory/                      contexto de longo prazo do projeto
```

## Convenções

Cada afirmação na spec traz uma etiqueta:

- **`[DECIDIDO]`** — ficou fechado numa conversa. Muda-se só com uma decisão nova, registada.
- **`[SUGERIDO]`** — foi dito, ninguém contrariou, mas também ninguém confirmou.
- **`[EM ABERTO]`** — falta decidir. Está em `99-perguntas-abertas.md`.
- **`[TENSÃO]`** — duas coisas decididas que ainda não encaixam uma na outra.

Referências à gravação vão como `(sessão 1 · 04:23)`.
