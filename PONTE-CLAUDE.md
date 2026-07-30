# Ponte Claude — guia do Rico

Tens um Claude ligado a este repositório. Não é o Fable — é outro, que vive aqui e serve para duas coisas.

## 1. Perguntar

Escreve **`@claude`** num comentário de issue ou de PR, e ele responde. Lê o repositório inteiro antes de responder, por isso podes perguntar coisas concretas:

> @claude isto que estou a propor bate com a lei do "habilidade acima de nível"?

> @claude onde é que ficou decidido que qualquer classe pega em qualquer arma?

> @claude o que é que ainda falta decidir sobre magia?

Serve para não teres de esperar pelo Mateus quando é uma dúvida que a spec já responde.

## 2. Rever

Quando abres um PR, ele revê sozinho e comenta o veredito:

- `VEREDITO: pode entrar`
- `VEREDITO: pode entrar com reparos`
- `VEREDITO: não deve entrar`

**Ele não faz merge.** Quem aprova e faz merge é o Mateus. O veredito é para lhe poupar tempo e para tu saberes se há algo a corrigir antes de ele olhar.

## O que ele verifica

Por ordem de gravidade:

1. **Mexeste num `[DECIDIDO]`?** É o mais grave. `[DECIDIDO]` é o que tu e o Mateus fecharam numa conversa gravada — não se muda sem uma decisão nova. Se o teu PR mexer num, **diz no PR qual foi a decisão que o substitui**, senão ele recusa.
2. Contradiz alguma das quatro leis (estão no [`CLAUDE.md`](CLAUDE.md))
3. Marcaste como `[DECIDIDO]` coisas que decidiste tu? Isso é `[FABLE]`, com justificação
4. Decidiste sozinho uma `[TENSÃO]`? Essas propõem-se, não se decidem
5. Adjectivos onde deviam estar números
6. Falta a coluna `Fatia 1?` nos catálogos
7. Escreveste código? Aqui não é sítio para isso

## Correr o guarda antes de abrir o PR

Poupa uma volta:

```bash
node tools/check-coerencia.mjs --base origin/main
```

Apanha links partidos, documentos que ficaram fora do `SPEC.md`, e `[DECIDIDO]` mexidos.

## O que ele não tem

- **Não tem acesso à máquina de ninguém.** Só ao repositório.
- **Não ouviu as gravações.** Sabe o que está escrito na spec, e os timestamps apontam para frases reais da conversa.
- **Não decide.** Nem ele nem o Fable. O jogo é teu e do Mateus.

## Se algo estiver errado na spec

Se vires um `[DECIDIDO]` que para ti não estava decidido, ou um `[SUGERIDO]` que já estava fechado — **diz**. As etiquetas são a leitura que foi feita da gravação, e pode ter-se lido mal. Abre uma issue ou comenta.
