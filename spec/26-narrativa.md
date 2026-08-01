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

### §1.1. A abertura é jogável `[CODEX]`

O jogo novo entra **directamente na orla**, junto do primeiro ponto de descanso. Não há prólogo separado: o jogador recupera a câmara e o movimento no primeiro frame visível, enquanto a linha `A fogueira ainda arde.` desaparece sem bloquear nada. A primeira coisa que faz é mexer-se e olhar; a dica contextual de movimento confirma as teclas sem parar o boneco. Daí em diante, seguem-se exactamente as cinco batidas do [`27-aprendizagem.md`](27-aprendizagem.md) §1.

**Razão `[CODEX]`:** o problema observado pelo Mateus não é a falta de um resumo antes do mapa; é o jogador aparecer no mapa sem um começo. Acordar num lugar, ler esse lugar e agir nele resolve o começo sem transformar história em vídeo. **Alternativa descartada:** conservar um ecrã de cinco frases antes do mundo — dá contexto, mas tira o controlo, repete nomes ainda provisórios e deixa a primeira acção continuar a ser carregar num botão de menu.

O lugar conta apenas factos que já cabem em qualquer resposta do §3:

1. o ponto de descanso ainda arde, mas ninguém o guarda;
2. um caminho antigo entra na bruma e o primeiro orc ocupa-o de costas para quem acorda;
3. mais à frente, ruína, bivaque e arco de pedra mostram uso anterior e ocupação presente sem dizer **quem** construiu nada.

Nada disto precisa de narrador, diálogo, novo modelo ou marcador de objectivo. A fogueira, caminho, bruma, inimigos e arco já são peças do troço jogável; a autoria visual posterior pode reforçá-las sem mudar a sequência.

#### Onde encaixam as sete respostas — sem as antecipar

| Pergunta do §3 | O que a abertura faz agora | Encaixe depois da resposta |
|---|---|---|
| 1. Tom | respeita o tom já registado, sem humor nem explicação solene | rever apenas a cadência das linhas `intro.*` e a encenação do despertar |
| 2. Nome do jogo/mundo | não pronuncia nenhum dos dois | título de menu e cartão de lugar; não muda combate nem geometria |
| 3. Idioma | consome o catálogo português já decidido | nenhum trabalho enquanto a decisão se mantiver |
| 4. Passado dos personagens | não chama herói, condenado, morto ou escolhido a quem acorda | uma memória/item depois da fogueira, se os donos quiserem passado explícito |
| 5. Antigos donos da Toca | mostra pedra anterior às marcas presentes, sem brasão legível | arte do arco + descrição do primeiro item encontrado dentro da Toca |
| 6. Porquê do co-op | a mesma sequência funciona com um ou dois corpos, sem explicação sobrenatural | sinal visual no ponto de despertar, ou ausência deliberada, conforme a resposta |
| 7. Nomes provisórios | nenhum nome próprio é necessário para começar a jogar | trocar valores de texto; os IDs internos continuam estáveis |

Esta tabela é um mapa de integração, **não responde a nenhuma pergunta em aberto**.

### §1.2. Os cinco itens iniciais começam a contar o mundo `[CODEX]`

As descrições ligam-se pelos IDs reais de [`weapons.json`](../game/data/weapons.json), vivem em [`strings.pt.json`](../game/data/strings.pt.json) e têm no máximo duas frases. A mochila pode mostrá-las sem duplicar texto no catálogo mecânico.

| ID do catálogo | Descrição de história |
|---|---|
| `dagger` | Lâmina curta, afiada tantas vezes que perdeu a largura original. A bainha guarda terra escura nas costuras. |
| `longsword` | Espada de guarda simples, marcada por uso paciente. No pomo, alguém apagou um brasão a golpes de lima. |
| `greataxe` | Machadão de ferro rude, remendado onde o cabo cedeu. As marcas na lâmina são mais largas do que a mão que agora o segura. |
| `staff` | Cajado escurecido pela humidade, com um foco azul preso por arame. A madeira permanece seca quando a bruma se aproxima. |
| `shield` | Escudo de madeira reforçado com ferro desigual. Três cortes foram tapados; o quarto ficou aberto. |

**Razão `[CODEX]`:** os cinco IDs cobrem os kits das seis origens sem inventar uma recompensa nova e dão história opcional desde a primeira abertura da mochila. As marcas insinuam uso, perda e ocupação, mas não identificam o mundo, os personagens, os antigos donos da Toca nem a causa do co-op. **Alternativa descartada:** pôr números, função ou instruções nestas frases — isso duplicaria tooltips e desperdiçaria o único espaço reservado à história do objecto.

## §2. NPCs e missões — a recomendação é a ausência

`[CLAUDE]` para a fatia 1: **zero NPCs, zero missões.** O mundo hostil e vazio é uma escolha estética válida do género, é gratuita em produção (cada NPC custa modelo+voz/texto+estado), e não fecha a porta: a clareira da fogueira (§1 do `27-aprendizagem.md`) é o sítio natural para um vendedor/ferreiro aparecer na fatia 2 **se eles quiserem**.

O que isto implica já: a cura da fatia vem do **Frasco de Bruma recarregado no descanso**, não de loja — modelo decidido na pergunta 7 (`→WP9` alinha).

## §3. As perguntas que só uma gravação responde

Ordenadas: as três primeiras mudam trabalho de todos os pacotes seguintes.

1. ~~**Que tom tem este mundo?**~~ ✅ `[DECIDIDO]` (Mateus + Rico, 31-07-2026) — **sombrio a sério.** Dark Souls puro: sem piscadelas, sem alívio cómico. A frase de estilo das imagens foi reescrita no mesmo dia (`grim and unforgiving, no whimsy`). Vale para a escrita, o som e as animações.
2. **O jogo chama-se mesmo WorldRPGs?** É o nome do repositório — serve como nome do jogo, ou é placeholder? E o mundo em si tem nome?
3. ~~**Idioma do jogo**~~ ✅ `[DECIDIDO]` (Mateus + Rico, 31-07-2026) — **português.** Tudo: menus, descrições de item, nomes. Sem versão inglesa, sem preparação para localização (já estava fora de escopo).
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
