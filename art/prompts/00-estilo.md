# 00 — A frase de estilo

Tudo o que se gera para este jogo começa com a mesma frase. É ela que faz vinte, cinquenta, duzentas imagens parecerem **do mesmo jogo** em vez de uma colecção de imagens avulsas.

## A frase (copiar literalmente para o início de cada prompt)

> **Stylized dark fantasy game art, hand-painted look, muted earthy colors with cold mist accents, simple readable shapes, low-poly-friendly design, no photorealism, subtle grim humor.**

## Estado desta escolha

`[CLAUDE]` provisório — o estilo visual é a **pergunta 15** de [`../../spec/99-perguntas-abertas.md`](../../spec/99-perguntas-abertas.md), e é do Mateus e do Rico. A frase serve para gerar já sem bloquear; se eles fecharem outra direcção, regenera-se com a frase nova. Imagens são baratas de refazer — é por isso que isto não espera.

O que a frase respeita do que já está decidido:
- **"Realista não"** (sessão 1 · 10:24) → `no photorealism`
- **Selva/floresta com bruma** (11:37 + WP0 Brumal) → `cold mist accents`, paleta terrosa
- **Lei 4** (gráficos integrados) → `simple readable shapes, low-poly-friendly` — conceitos que um modelo baixo-poligonal consegue seguir
- **Souls-like** → tom sombrio; o `subtle grim humor` fica como tempero, não como piada

## Regras para todos os prompts

1. **Prompt em inglês.** Os geradores respondem melhor.
2. **A frase de estilo primeiro**, depois o assunto, depois os detalhes técnicos.
3. **Uma imagem por prompt.** Nada de "sheet with 6 variations" — sai inconsistente e pequeno demais.
4. **Sem texto dentro da imagem.** Os geradores estragam letras; qualquer texto entra depois, no jogo.
5. **Ícones: fundo transparente pedido explicitamente** (`isolated on transparent background`). Conceitos: fundo faz parte da cena.
6. **Guardar no caminho canónico do manifesto** ([`../MANIFESTO.md`](../MANIFESTO.md)), com o nome exacto do ID. É isso que liga a spec → ficheiro → jogo.
7. **Avaliar antes de arquivar** — cada prompt traz um "sai bem se". Se falhou, regenera-se; não se arquiva imagem má.

## Rota de geração (para quem gera)

Conforme a regra CMTec de 2026-07-04: **1–10 imagens → gpt-image (ChatGPT browser, grátis)**; lote >10 de uma vez → fal.ai/FLUX; falha do ChatGPT → fal.ai com aviso. Para a fatia 1 (~22 imagens) o prático é gerar por famílias — cada ficheiro `0X-*.md` desta pasta é uma sessão de geração de tamanho certo.
