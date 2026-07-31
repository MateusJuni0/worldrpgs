# Decisões

Formato: `### [DATA] [origem] — decisão`. As decisões de design vivem em `spec/`, com o timestamp da gravação. Aqui ficam as decisões *sobre o projeto*.

### [2026-07-31] [Mateus] — Repo público na conta pessoal
`MateusJuni0/worldrpgs`, público. Hobby, fora da CMTec.

### [2026-07-31] [Mateus] — ~~Só spec, nada de código~~ → **SUBSTITUÍDA** (ver abaixo)
"não vamos fazer, vamos apenas spec tudo de tudo mesmo do jogo". A construção fica para o Fable do Rico, a partir desta spec.

### [2026-07-31, 17:41] [Mateus] — O código vive AQUI, neste repositório
Substitui a decisão de cima. As palavras dele:

> "E vive num só sítio: o disco do Rico. O repositório worldrpgs-game foi planeado no WP14/WP15 mas nunca foi criado no GitHub. **Não há cópia, não há histórico partilhado, e eu não consigo rever uma linha do que ele escreveu.**"
>
> "diz pra ele comitar no nosso repositório" — https://github.com/MateusJuni0/worldrpgs

Três razões, todas boas: **cópia de segurança** (estava num disco só), **histórico partilhado**, e **revisão** — o dono não conseguia ver o código.

**O que muda:** o protótipo passa a viver em [`game/`](../game/), com o seu histórico completo trazido por `git subtree` — os 8 commits originais estão no DAG deste repositório e revêem-se um a um. A spec continua a mandar nos números; o código é a implementação dela, não uma fonte paralela de verdade.

### [2026-07-31] [Mateus] — O método é gravação → transcrição → spec
Sessões gravadas em OBS durante chamada de WhatsApp. Claude transcreve, organiza e estrutura. A spec cresce das conversas.

### [2026-07-31] [claude] — Uma etiqueta por afirmação na spec
`[DECIDIDO]` / `[SUGERIDO]` / `[EM ABERTO]` / `[TENSÃO]`, cada uma com `(sessão N · MM:SS)`. Serve para distinguir o que eles decidiram do que eu deduzi.
