# BRAIN — WorldRPGs

Contexto de sessão. Ler ao começar a trabalhar, actualizar ao acabar.

## O que é

Jogo hobby do Mateus e do Rico. RPG 3D souls-like, co-op para dois. Repo **público**: https://github.com/MateusJuni0/worldrpgs

**Não é projeto CMTec.** Não tem cliente, prazo, nem faturação.

## Como se trabalha aqui

1. Mateus e Rico falam do jogo numa chamada de WhatsApp. O OBS grava.
2. A gravação passa por `~/.openclaw/workspace/tools/session-transcriber/` → transcrição + ideias organizadas
3. O que ficou decidido entra em `spec/`, com o timestamp de origem
4. O que ficou por decidir entra em `spec/99-perguntas-abertas.md` e volta para a conversa seguinte

**A spec cresce das gravações, não de perguntas minhas.** Não interrogar o Mateus com listas de design — a resposta aparece na sessão seguinte. O meu papel é extrair, organizar, apontar tensões e escopo.

Comando:

```bash
cd ~/.openclaw/workspace/tools/session-transcriber
node transcribe.mjs "C:/Users/mjnol/Videos/<ficheiro>.mp4" \
  --out ~/.openclaw/workspace/projects/worldrpgs/design \
  --speakers "Mateus,Rico" \
  --topic "Sessao N de brainstorm do WorldRPGs: RPG souls-like 3D co-op..."
```

## Estado — 31-07-2026

- Sessão 1 gravada (30-07, 13m13s), transcrita e especificada
- Repo criado, estrutura montada, 11 documentos de spec escritos
- **Zero código, por decisão.** O Fable do Rico constrói depois, a partir desta spec
- Próximo: sessão 2, com o guião de `spec/99-perguntas-abertas.md`

## Decisões que definem tudo

1. **Habilidade acima de nível.** Sem gating, sem grind. É o pilar; qualquer sistema tem de passar neste teste
2. **Qualquer classe pega em qualquer arma.** Diferenciação por skills e atributos, não por bloqueio
3. **Co-op sempre disponível**, mundo sincronizado com progresso individual

## O que está por resolver e é grande

- Escopo: o que foi descrito na sessão 1 são anos de trabalho. A pergunta certa é qual a fatia mínima jogável
- Duas tensões directas com o pilar 1: biomas por nível, e evoluções de classe que dão poder
- Área técnica inteira em branco: engine, rede, arte 3D

## Armadilhas

- **O microfone do Mateus falhou na sessão 1.** ~20 falas dele saíram `[ininteligível]`, incluindo a resposta à pergunta dos drops (05:40). Verificar o áudio dele no OBS antes da sessão 2.
- `gemini-2.5-flash` no transcritor. Os `gemini-3.x` dão 429 no free tier.
- As chaves `GEMINI_API_KEY*` do `workspace/.env` estão mortas; a que funciona está hardcoded em `workspace/wiki/enrique-rocha/transcribe.mjs`.
