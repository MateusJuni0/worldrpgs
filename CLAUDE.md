# CLAUDE.md — contexto do repositório

Lê isto antes de responder ou de rever seja o que for. É daqui que vem o contexto, não do prompt do workflow — regra nova escreve-se aqui.

## O que é este repositório

**WorldRPGs** — RPG 3D em terceira pessoa, souls-like, co-op para dois. Projeto hobby do **Mateus** e do **Rico**.

**É um repositório de especificação. Não tem código, e é de propósito.** A spec cresce a partir de conversas gravadas entre os dois; a construção vem depois, com o Opus 5.

Fluxo: eles falam numa chamada → o OBS grava → transcrição → o que ficou decidido entra em `spec/` com o timestamp de origem → o que ficou por decidir entra em `spec/99-perguntas-abertas.md`.

## Quem é quem

| | |
|---|---|
| **Mateus** (`MateusJuni0`) | Dono. Aprova tudo. Faz o merge. |
| **Rico** (`dionersilvaggr6`, = Dioner) | Co-autor do design. Abre PRs. **Tratar sempre por Rico.** |
| **Fable** | Agente do Rico. Detalha a spec, seguindo `prompts/BRIEFING-FABLE.md`. |
| **Opus 5** | Quem vai construir, depois da spec estar feita. |

## As quatro leis

Estão desenvolvidas em [`spec/00-visao.md`](spec/00-visao.md) e em [`prompts/BRIEFING-FABLE.md`](prompts/BRIEFING-FABLE.md). Resumo, para reveres contra elas:

1. **Ganha-se com habilidade, não com nível.** O nível reduz a margem de erro, nunca abre uma porta. Nada de gating, nada de grind obrigatório.
2. **As melhorias dão opções, não números.**
3. **Qualquer classe pega em qualquer arma.** Diferenciação por atributos e skills, nunca por bloqueio.
4. **A máquina alvo manda:** as duas medidas — **a do Rico é o alvo (8 GB, Iris Xe integrados, 1080p @ 60 Hz)**, por ser a mais fraca. E queda de fotogramas num souls-like não é feio, é injusto — ataca a lei 1.

## As etiquetas

| | | |
|---|---|---|
| `[DECIDIDO]` | Fechado pelo Mateus e pelo Rico numa gravação | **Ninguém mexe** sem uma decisão nova, registada. **Indica sempre a fonte**; se só um dos dois decidiu, fica marcado ⏳ até o outro confirmar |
| `[SUGERIDO]` | Dito, não confirmado | Pode ser adoptado, virando `[FABLE]` |
| `[EM ABERTO]` | Por decidir | É trabalho a fazer |
| `[TENSÃO]` | Duas decisões que não encaixam | Propõe-se, **não se decide** |
| `[FABLE]` | Decidido pelo Fable | Tem de trazer razão e alternativa descartada |

## O que verificar numa revisão

Por ordem de gravidade:

1. **Mexeu num `[DECIDIDO]`?** É o mais grave. Corre `node tools/check-coerencia.mjs --base origin/main`. Se mexeu, o PR tem de dizer qual foi a decisão nova que o substitui. Se não disser, é motivo para não entrar.
2. **Contradiz alguma das quatro leis?** Sobretudo a 1 e a 4, que são as fáceis de quebrar sem dar por isso.
3. **Inventou coisas como se fossem deles?** Tudo o que vem do Fable é `[FABLE]`, com justificação. Um `[DECIDIDO]` novo tem de dizer a fonte — e se só um dos dois decidiu, tem de estar marcado que falta o outro. O guarda assinala as linhas promovidas a `[DECIDIDO]` em cada PR.
4. **Decidiu sozinho uma `[TENSÃO]`?** Não é dele para decidir. Tem de propor e recomendar.
5. **Adjectivos onde deviam estar números?** "Combate responsivo" não é spec. "0,60 s, invencibilidade dos 0,08 aos 0,38" é.
6. **Falta a coluna `Fatia 1?`** nos catálogos? É o que trava o escopo.
7. **Escreveu código?** Não é para escrever código neste repositório.
8. **Actualizou o `SPEC.md` e o `99-perguntas-abertas.md`?** Devem ir no mesmo PR.

## O que não fazer

- **Não faças merge.** Quem aprova é o Mateus. Comentas o veredito e ficas por aí.
- **Não reescrevas a spec ao rever.** Aponta, não corrijas por cima.
- **Não trates o Rico por Dioner.**

## Coordenação entre agentes

Dois agentes escrevem aqui — o Fable (lado do Rico) e o Claude (lado do Mateus). **Antes de começar um pacote, reserva-o em [`COORDENACAO.md`](COORDENACAO.md)** com um commit pequeno e imediato; antes de reservar, `git pull` e vê se já está reservado. O desempate é a ordem de chegada à `main`. Numa revisão, um PR que faz um pacote reservado por outro merece esse reparo.

## Documentos importantes

| | |
|---|---|
| [`SPEC.md`](SPEC.md) | Índice, e o estado de cada área |
| [`spec/00-visao.md`](spec/00-visao.md) | Os pilares. O documento mais importante. |
| [`spec/99-perguntas-abertas.md`](spec/99-perguntas-abertas.md) | O que falta decidir |
| [`prompts/BRIEFING-FABLE.md`](prompts/BRIEFING-FABLE.md) | A raiz do projeto — o que o Fable tem de fazer |
| [`PARA-O-RICO.md`](PARA-O-RICO.md) | As tensões e o risco de escopo |
| [`PONTE-CLAUDE.md`](PONTE-CLAUDE.md) | Como o Rico usa isto |
| [`COORDENACAO.md`](COORDENACAO.md) | Quem está a fazer o quê — reservar antes de começar |
