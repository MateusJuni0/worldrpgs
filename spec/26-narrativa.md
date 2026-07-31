# 26 — Narrativa, mundo vivo e NPCs (WP8B)

> **Autor:** Claude. Este pacote é diferente dos outros de propósito: na sessão 1 **não se falou de história uma única vez** — nem nome do mundo, nem NPCs, nem missões. Território 100% dos donos. Por isso aqui **propõe-se o mínimo e pergunta-se o resto** — um mundo inteiro inventado por um agente seria exactamente o `[FABLE]`/`[CLAUDE]` que vale menos.

## O que já se sabe (tudo o que há)

| Facto | Origem |
|---|---|
| Fantasia medieval com orcs, paladinos, magia do bem e do mal | sessão 1 (00:16, 02:35, 07:40, 00:40) |
| "Realista não" | 10:24 |
| Mundo aberto que se explora, dungeons escondidas | 02:50 → 03:12 |
| Nomes provisórios da fatia: Brumal, a Toca, Vorgar "o Guarda-Portão" | WP0 `[FABLE]` |
| O jogo é para os dois — não há público a agradar | contexto do projeto |

## §1. A proposta mínima `[CLAUDE]` — o suficiente para a fatia 1 fazer sentido

Um souls-like vive bem de **ambiente + implicação**: o mundo conta-se pelo que se vê, não pelo que se lê. A proposta mínima que dá chão à fatia sem fechar nada:

> Brumal não foi sempre assim: a bruma **chegou**, e com ela os orcs. A Toca é uma mina/passagem antiga que os orcs tomaram, e Vorgar guarda o portão do fundo — **guarda-o de quê, ou para quem, é a pergunta que a fatia deixa no ar.** Os dois jogadores são forasteiros que entram onde ninguém entra.

Três frases. Chega para: justificar orcs na floresta, dar peso ao nome "Guarda-Portão", e deixar um gancho (o portão) que puxa para a fatia 2 sem prometer nada.

*Alternativa descartada:* escrever a cosmologia toda (deuses, eras, facções) — seria decidir o tom do jogo pelos donos, e tom é a decisão mais pessoal que há.

**Como se conta na fatia:** zero diálogo, zero texto de história. Só o cenário (a ruína na orla, os estandartes na arena) e **descrições de item de 1–2 frases** — o método do género, barato e opcional de ler. Exemplo do formato (conteúdo por escrever): *"Espada longa — o punho está gasto por mãos maiores que as tuas."*

## §2. NPCs e missões — a recomendação é a ausência

`[CLAUDE]` para a fatia 1: **zero NPCs, zero missões.** O mundo hostil e vazio é uma escolha estética válida do género, é gratuita em produção (cada NPC custa modelo+voz/texto+estado), e não fecha a porta: a clareira da fogueira (§1 do `27-aprendizagem.md`) é o sítio natural para um vendedor/ferreiro aparecer na fatia 2 **se eles quiserem**.

O que isto implica já: a cura da fatia vem de drops/descanso, não de loja (`→WP9` alinha; pergunta 7 continua dos donos).

## §3. As perguntas que só uma gravação responde

Ordenadas: as três primeiras mudam trabalho de todos os pacotes seguintes.

1. **Que tom tem este mundo?** Sombrio a sério (Dark Souls), sombrio com piscadela (a a frase de estilo tem "subtle grim humor" — confirmam?), ou leve? Muda a escrita toda, o som, e até as animações.
2. **O jogo chama-se mesmo WorldRPGs?** É o nome do repositório — serve como nome do jogo, ou é placeholder? E o mundo em si tem nome?
3. **Idioma do jogo:** português, inglês, ou os dois? (Jogam os dois em PT; inglês só faria sentido se um dia quiserem mostrar a estranhos. Decisão barata agora, cara depois.)
4. **História pessoal dos personagens:** os bonecos são avatares mudos sem passado (recomendação `[CLAUDE]` — alinha com §2), ou têm identidade?
5. **A quem pertencia a Toca antes dos orcs?** A resposta define a arte das ruínas (`→WP12`) e o que Vorgar guarda.
6. **Existe um "porquê" para o co-op?** Dois forasteiros por acaso, ou a história assume os dois? (O Dark Souls finge que o co-op é sobrenatural; aqui pode ser simplesmente ignorado.)
7. **Nomes provisórios** — Brumal, Toca, Vorgar: ficam ou mudam? (Custo de mudar agora: um commit. Depois das imagens geradas: regenerar conceitos.)

**Sugestão de método:** estas 7 perguntas são um guião de gravação de ~15 min, como a sessão 1. Não precisam de preparação — precisam dos dois a falar.

## §4. Regras de escrita (para quando houver texto)

Valem já, seja qual for o tom escolhido:

- **Descrições de item:** máx. 2 frases; a primeira diz o que é, a segunda insinua o mundo. Nunca explicam mecânica (isso é do tooltip, `→WP11`)
- **Nada de lore obrigatória:** quem não ler nada perde zero jogabilidade — coerente com as três proibições do `27-aprendizagem.md`
- **Nomes próprios:** pronunciáveis em voz alta numa chamada de WhatsApp — é assim que eles jogam. "Vorgar" passa o teste; "Xyl'thraz" não

## Pronto quando

- [ ] As 7 perguntas do §3 respondidas numa gravação e destiladas para cá
- [ ] O tom escolhido propagado: frase de estilo (`art/prompts/00`), som (`WP12`), descrições de item
- [ ] Nome do jogo confirmado ou substituído (afecta README, menu, e pouco mais — cedo é barato)

## Ligações

Fatia e nomes provisórios: [`10-fatia-1.md`](10-fatia-1.md) · Ensino sem texto: [`27-aprendizagem.md`](27-aprendizagem.md) · Estilo visual: [`../art/prompts/00-estilo.md`](../art/prompts/00-estilo.md) · Perguntas abertas: [`99-perguntas-abertas.md`](99-perguntas-abertas.md)
