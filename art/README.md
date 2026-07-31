# art/

Assets visuais e sonoros do jogo. **Fonte de verdade: [`MANIFESTO.md`](MANIFESTO.md)** — cada asset tem um ID e um caminho canónico; o código e a spec referem o ID, o ficheiro vive no caminho, com esse nome exacto.

| Pasta | O que vive lá | Vem de |
|---|---|---|
| `prompts/` | Prompts prontos a colar no gerador, por família | escritos à mão |
| `concept/` | Arte de conceito — guia a modelação, **não entra no jogo** | gerado (gpt-image) |
| `ui/icons/` | Ícones de itens e magias — **entram no jogo** | gerado |
| `ui/menus/` | Fundos de menu | gerado |
| `sky/` | Céus | gerado |
| `textures/` | Texturas para materiais 3D | gerado + editado |
| `vfx/` | Texturas de partículas e efeitos | gerado + editado |
| `models/` | Malhas 3D, esqueletos, animações — **NÃO saem de geradores de imagem** | bibliotecas/lojas (ver `spec/22-assets.md`) |
| `audio/` | Música e som | ver `spec/22-assets.md` |

Convenções: PNG para tudo o que é gerado · nomes em kebab-case, sem acentos · ícones 512×512 com fundo transparente (o jogo encolhe) · conceitos 1536×1024 ou 1024×1536.

Fluxo: prompt (`prompts/`) → gerar → avaliar contra o "sai bem se" → arquivar no caminho do manifesto → marcar ✅ no manifesto, no mesmo commit.
