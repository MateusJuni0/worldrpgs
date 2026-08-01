# WorldRPGs — Especificação

RPG 3D para PC, **primeira ou terceira pessoa à escolha**, souls-like, co-op para dois. Índice mestre.

> ⭐ **Se só leres um ficheiro, lê o [`ESTADO.md`](ESTADO.md).** É o que está verdadeiro **hoje**, com o que falta e por que ordem. Este índice diz onde as coisas estão; o `ESTADO.md` diz em que pé estão.

> 📋 Todas as decisões dos donos, por ordem, em [`DECISOES.md`](DECISOES.md) — é contra essa lista que se compara trabalho feito antes delas.

> **Fase: construção.** Os 20 pacotes de spec estão escritos. O jogo já se joga ([`spec/44-prototipo.md`](spec/44-prototipo.md)). Regras da fase em [`spec/32-construcao.md`](spec/32-construcao.md); o plano é o [`spec/24-plano.md`](spec/24-plano.md), M0 a M7.

> Cada afirmação traz a origem: `(sessão N · MM:SS)`. Nada entra por invenção.

## Etiquetas

| | |
|---|---|
| `[DECIDIDO]` | Fechado numa conversa. Muda-se com uma decisão nova, registada. |
| `[SUGERIDO]` | Foi dito, ninguém contrariou, ninguém confirmou. |
| `[EM ABERTO]` | Falta decidir. Está em [`spec/99-perguntas-abertas.md`](spec/99-perguntas-abertas.md). |
| `[TENSÃO]` | Duas coisas decididas que ainda não encaixam. |
| `[FABLE]` · `[CLAUDE]` | Decidido por um agente. Traz razão e alternativa descartada. |
| `[PROTO]` | O protótipo assumiu para poder correr. Não é decisão. |

## Os documentos

⚠️ **na coluna do estado = o Fable tem de lá voltar.** A razão está no [`ESTADO.md`](ESTADO.md).

### Sessão 1 — o registo original (30-07)

São o registo de uma conversa, **não o estado actual**. Em caso de divergência, manda o documento de execução.

| # | Documento | Do que trata | Estado |
|---|---|---|---|
| 00 | [Visão](spec/00-visao.md) | Pitch, os três pilares, referências, risco de escopo | 🟢 base sólida |
| 02 | [Personagem](spec/02-personagem.md) | Atributos, classes, evoluções, skills | 🔵 substituído pelo 11 e 12 |
| 03 | [Magia](spec/03-magia.md) | Bem e mal, usos, encantamentos | 🔵 substituído pelo 13 e 42 |
| 04 | [Inimigos e chefes](spec/04-inimigos-chefes.md) | Raças, hierarquia de chefes | 🔵 substituído pelo 15 e 16 |
| 05 | [Mundo](spec/05-mundo.md) | Mapa, biomas, dungeons, 3D | 🔵 substituído pelo 17 |
| 06 | [Itens e inventário](spec/06-itens-inventario.md) | Armas, mochila, montarias, drops | 🔵 substituído pelo 14 e 40 |
| 07 | [Multiplayer](spec/07-multiplayer.md) | Co-op, sincronização, recompensas | 🔵 substituído pelo 19 |
| 08 | [Interface](spec/08-ui.md) | HUD, hotbar, mochila | 🔵 substituído pelo 20 |
| 09 | [Técnico](spec/09-tecnico.md) | **Restrição de hardware** — as duas máquinas | 🟢 a tabela das máquinas continua a valer |
| 10 | [Fatia 1](spec/10-fatia-1.md) | O primeiro jogável, com critérios de feito | 🟢 **aprovada pelos dois** |

### Os 20 pacotes — a spec de execução

| # | Documento | Do que trata | Estado |
|---|---|---|---|
| 11 | [Atributos e fórmulas](spec/11-formulas.md) | Atributos, fórmula de dano, curvas (WP2) | ⚠️ **sem soft caps e sem o piso de 30%** — [`39`](spec/39-estudo-profundo.md) §1–2 |
| 12 | [Classes](spec/12-classes.md) | As fichas, habilidades especiais (WP3) | 🟢 seis presets; o [`64`](spec/64-criacao-de-personagem.md) impede que a origem feche o caminho |
| 13 | [Magia, por dentro](spec/13-magia.md) | Primeira proposta de escolas/catálogo (WP4) | 🔵 substituído pelo [`54`](spec/54-mana-meditacao-e-tracos-de-classe.md) + [`66`](spec/66-catalogo-de-magia.md) |
| 14 | [Armas e equipamento](spec/14-equipamento.md) | Catálogo, cura, melhoria (WP5) | 🔵 base antiga alinhada; catálogo completo no [`68`](spec/68-catalogo-de-armas-armaduras-e-aneis.md) |
| 15 | [Bestiário — primeira camada](spec/15-inimigos.md) | IA e primeiros encontros (WP6) | 🔵 catálogo substituído pelo [`67`](spec/67-catalogo-do-bestiario.md); a máquina comum e a Fatia 1 continuam herdadas |
| 16 | [Chefes](spec/16-chefes.md) | Camadas, regras, o Vorgar (WP7) | ⚠️ fichas de ataque pelo [`38`](spec/38-ataques-e-honestidade.md) · arenas pelo [`61`](spec/61-arenas-de-chefe.md) |
| 17 | [Mundo e mapa](spec/17-mundo.md) | Primeira proposta de rede, dungeons e traçado (WP8) | 🔵 substituído pelo catálogo completo do [`69`](spec/69-catalogo-do-mundo.md) |
| 18 | [Progressão e loot](spec/18-progressao.md) | Curva, loot, economia (WP9) | ⚠️ **curva linear, devia ser cúbica** · "XP" devia ser "almas" |
| 19 | [Multiplayer e rede](spec/19-rede.md) | Autoridade, transporte, quedas (WP10) | 🟠 proposta `[FABLE]` — transporte aguarda os dois |
| 20 | [Interface](spec/20-interface.md) | HUD, mochila, menus (WP11) | ⚠️ **o mapa de teclas tem de fechar de uma vez** — [`45`](spec/45-controlos-configuraveis.md) |
| 21 | [Arte e render](spec/21-arte-render.md) | Direcção, animações, efeitos, som (WP12) | 🟠 proposta `[FABLE]` |
| 22 | [Origem dos assets](spec/22-assets.md) | Modelos, animações, áudio: fontes e licenças (WP13) | 🟢 regras fixas |
| 23 | [Arquitectura técnica](spec/23-tecnico.md) | Engine, sistemas, dados, saves (WP14) | ⚠️ **falta o carregamento por área** — [`43`](spec/43-estudo-espolio-inventario-mundo.md) §6 |
| 24 | [Plano de construção](spec/24-plano.md) | M0–M7 com verificação jogável por marco (WP15) | 🟢 é o documento de arranque |
| 25 | [Câmara, controlo e game feel](spec/25-controlo.md) | Câmara, buffer de entrada, latência, hit-stop (WP1B) | 🟠 proposta `[CLAUDE]` |
| 26 | [Narrativa e NPCs](spec/26-narrativa.md) | Proposta mínima + 7 perguntas para gravação (WP8B) | 🟠 decisões são dos donos |
| 27 | [Aprender a jogar](spec/27-aprendizagem.md) | Os professores, os 5 primeiros minutos (WP11B) | 🟠 proposta `[CLAUDE]` |
| 28 | [Testar e equilibrar](spec/28-testes.md) | Protocolos, métricas e sintomas (WP15B) | 🟢 completado pelo ciclo operacional do [`63`](spec/63-como-se-afinam-os-numeros.md); ferramentas continuam por construir |
| 01 | [Combate](spec/01-combate.md) | Máquina de estados, esquiva, parry, as 5 armas (WP1) | ⚠️ **falta interrupção, contra-ataque e os 11 golpes** — [`41`](spec/41-estudo-armas-e-golpes.md) |

### Decisões e estudos (32–72)

| # | Documento | Do que trata | Estado |
|---|---|---|---|
| 72 | [**Materiais, consumíveis e economia**](spec/72-materiais-consumiveis-e-economia.md) | curva cúbica exacta · 40 materiais · 15 consumíveis canónicos · bias por classe · morte→baralho→recibo/save | 🟢 WP9 fechado no contrato e na transacção local; política de destinatário co-op continua dos donos |
| 71 | [**Encontros nomeados**](spec/71-encontros-nomeados.md) | 36 fichas · 3 por zona · um ataque extra · carta garantida · reutilização de tipo-base | 🟢 catálogo fechado; produção segue a promoção `Fatia 1?` do tipo-base |
| 70 | [**Fecho dos sistemas de combate**](spec/70-fecho-dos-sistemas-de-combate.md) | parry 8/8/40 · curvas por atributo · sobrecarga · empunhadura · gramática inimiga | 🟢 contrato canónico da Tarefa 4; dados e invariantes executáveis |
| 69 | [**Catálogo do mundo: doze círculos que se aprendem**](spec/69-catalogo-do-mundo.md) | leitura antes do traçado · 12 zonas de 8–12 min · 21 ligações · círculos horizontais/verticais · atalhos por dentro · 30 portas de história | 🟢 WP8 fechado 01-08; mapa, streaming e 11 zonas continuam por construir |
| 68 | [**Catálogo de armas, armaduras, estados e anéis**](spec/68-catalogo-de-armas-armaduras-e-aneis.md) | 120 armas · 68 armaduras · 70 anéis · 8×11 golpes · melhoria sem força · estados · Assassino | 🟢 WP5 fechado 01-08; 5 armas e 11 armaduras na Fatia 1; Assassino aguarda confirmação do Mateus |
| 67 | [**Catálogo do bestiário**](spec/67-catalogo-do-bestiario.md) | 33 tipos · 100 ataques comuns · contacto/vector · 10 cartas · cues · massa · almas e 12 orçamentos | 🟢 WP6 fechado; recompensa/economia entregues no [`72`](spec/72-materiais-consumiveis-e-economia.md); modelos/animações e colocação continuam WP15/WP8 |
| 66 | [**Catálogo de magia: mana, formas e verbos**](spec/66-catalogo-de-magia.md) | 53 feitiços · 4 escolas · 12 formas · grelha sem vazios · custos · melhoria 0–5 · meditação/favoritos | 🟢 WP4 fechado 01-08; 3 da Fatia 1 executáveis, formas restantes por implementar |
| 65 | [**Música e ambiente: atmosfera que nunca tapa informação**](spec/65-musica-e-ambiente.md) | Inventário dos 182 OGG · mapa por uso · estados/transições · ambiente · buses/ducking · prova de mascaramento | 🟢 sistema fechado 01-08; zero música/loops e audio director por construir |
| 64 | [**Criação de personagem: escolher um começo, não uma prisão**](spec/64-criacao-de-personagem.md) | Fluxo inicial · seis presets · aspecto finito · nome · save · prova da Lei 3 | 🟢 sistema fechado 01-08; UI, retarget e save v2 por construir |
| 63 | [**Como se afinam os números: medir, mudar um, provar**](spec/63-como-se-afinam-os-numeros.md) | Inventário · ordem causal · papéis · A/B de uma variável · diagnóstico por sintoma · quando congelar | 🟢 método fechado 01-08; CSV/comandos assumidos pelo 28 não existem no código |
| 62 | [**Acessibilidade auditiva: a mesma informação por outro canal**](spec/62-acessibilidade-auditiva.md) | Evento único · forma visual por tipo de som · timing/direcção equivalentes · combate, co-op, segredos e estados sem áudio | 🟢 regra + `GameplayCue` + ataques actuais fechados no [`67`](spec/67-catalogo-do-bestiario.md); banco jogado sem som continua WP15B |
| 61 | [**Arenas de chefe: o espaço também luta**](spec/61-arenas-de-chefe.md) | Tamanho por camada · obstáculos/refúgios · bordo letal legível · nevoeiro como carregamento · ataques para separar e juntar dois jogadores | 🟢 sistema fechado 01-08; 12 fichas de guardião + Ultra são conteúdo do WP7 |
| 60 | [**O agente que joga**](spec/60-o-agente-que-joga.md) | Banco de ensaio automático: guiões, modo macaco, varrimento de 1728 combinações · ⏳ constrói-se depois do catálogo | 🟢 desenhado 01-08 |
| 59 | [**Saves: progresso que não volta atrás**](spec/59-saves.md) | Campos de personagem/mundo · autosave na morte · escrita atómica · recuperação · migrações · tensão do progresso co-op | 🟢 spec + código + testes 01-08 |
| 58 | [**O fim do jogo, os ciclos e a curva**](spec/58-fim-do-jogo-ciclos-e-a-curva.md) | Porque é que aos 70 estás forte e é assim que deve ser · a Brasa que resolve a pergunta 22 · NG+ com tecto no 7 · as portas que abrem no segundo percurso | 🟢 01-08 |
| 57 | [**O mapa e o minimapa**](spec/57-mapa-e-minimapa.md) | Mostra onde já estiveste, nunca onde as coisas estão · marcas partilhadas · vista inclinada para a verticalidade se ler | 🟢 01-08 |
| 56 | [**Voz no co-op e vendedores**](spec/56-voz-e-vendedores.md) | Voz pelo cano que já existe, posicional · e o vendedor vende o que TU encontraste | 🟢 01-08 |
| 55 | [**As formas de um feitiço**](spec/55-formas-de-feitico.md) | 12 formas de entrega diferentes · o espaço como variável (a chuva morre debaixo de tecto) · velocidade com rendimentos decrescentes · como se escapa a cada forma | 🟢 estudo 01-08 |
| 54 | [**Mana, meditação e traços de classe**](spec/54-mana-meditacao-e-tracos-de-classe.md) | Sem slots de magia · mana que não regenera · meditar 40 s (mas não os frascos) · um traço passivo por classe · a roda de feitiços obrigatória | 🟢 revoga o bolo de cargas do 39 §7 |
| 53 | [**13 chefes, o ritmo da travessia, e o mago forte**](spec/53-chefes-ritmo-e-o-mago-forte.md) | Resposta do Mateus à auditoria: 13 verdadeiros + portas de história abertas, travessia de 8–12 min, e o Voto de Sangue a trocar verbos em vez de multiplicar dano | 🟢  01-08 |
| 52 | [**O mago do mal — a escola vermelha**](spec/52-mago-do-mal.md) | O personagem do Mateus: cor como lei, cadáveres e vida como moeda, ~20 feitiços, levantar o chefe, o espelho | 🟢 proposta detalhada, 6 perguntas para ele |
| 51 | [**WP5 camada 1: famílias, armadura e kits**](spec/51-familias.md) | 8 famílias de arma (cada uma com onde é MÁ), 3 de escudo com tecto de estabilidade, 9 peças de armadura, os kits iniciais das 6 classes e as regras de espólio do Rico | 🟢 volta 3 entregue |
| 50 | [**As 12 fichas de raça**](spec/50-racas.md) | A segunda metade do motor: 6 raças aprovadas + 6 novas `[FABLE]`, papéis de combate, o mímico como praga · o laço bioma ↔ raça verificado no arranque | 🟢 volta 2 entregue |
| 49 | [**As 12 fichas de bioma**](spec/49-biomas.md) | O motor de produção preenchido: 12 fichas de 8 linhas + paleta ligada ao motor (`game/data/biomes.json`) · fecha as perguntas 4 e 13 · semeia as 6 raças novas da volta 2 | 🟢 volta 1 entregue |
| 48 | [**Arcos, bestas e escudos**](spec/48-arcos-bestas-escudos.md) | As 3 famílias sem cobertura: a munição é metade do arco, a besta é a Lei 3 em objecto, e o tecto de estabilidade que impede bloquear de graça | 🟢 matéria-prima da volta 3 |
| 47 | [**Do greybox ao visual**](spec/47-do-greybox-ao-visual.md) | O que temos hoje, visto e não suposto; o que faz parecer a referência (luz > polígonos); a ordem da conversão; capturas em todo o marco | 🟢 `[DECIDIDO]` 31-07 |
| 46 | [**Coerência: bioma → raça → item → história**](spec/46-coerencia-bioma-raca-item.md) | A lei que impede a sopa, o motor que gera 300 descrições de 24 fichas, a camada dos subchefes, e os 61 chefes derivados do mapa | 🟢 `[DECIDIDO]` 31-07 |
| 45 | [**Controlos configuráveis**](spec/45-controlos-configuraveis.md) | O jogador escolhe as teclas dentro do jogo — dissolve a guerra do parry | 🟢 `[DECIDIDO]` 31-07 |
| 44 | [**O protótipo**](spec/44-prototipo.md) | Medições com artefactos, o que já se joga, lacunas encontradas a construir | 🟢 metade da ressalva do 0b fechada |
| 43 | [**Estudo: espólio, inventário, segredos, carregamento**](spec/43-estudo-espolio-inventario-mundo.md) | O baralho de 10, espaços, mímicos, a porta de nevoeiro | 🟢 10 accionáveis |
| 42 | [**Estudo: magia**](spec/42-estudo-magia.md) | 4 escolas, instrumento, melhoria e grelha de verbos | 🟢 base herdada pelo 66; espaços/energia revogados pelo 54 |
| 41 | [**Estudo: armas e golpes**](spec/41-estudo-armas-e-golpes.md) | Os 11 golpes, o que separa cada família, contra-ataque, interrupção | 🟢 a base do WP5 |
| 40 | [**Decisões: espólio, magia, inventário**](spec/40-decisoes-espolio-magia-inventario.md) | 15 decisões do Mateus | 🟢 registo |
| 39 | [**Estudo profundo da referência**](spec/39-estudo-profundo.md) | Dano, saturação, interrupção, carga, críticos, mundo, co-op, descoberta | 🟢 18 accionáveis |
| 38 | [**Ataques e honestidade**](spec/38-ataques-e-honestidade.md) | As 5 fases e o contrato que faz a esquiva ser verdadeira | 🟢 contrato fixado |
| 37 | [**Anéis e elementos**](spec/37-aneis-e-elementos.md) | 70 anéis / 10 dedos, tipos de dano, dano de queda | 🟢 catálogo de 70 entregue no [`68`](spec/68-catalogo-de-armas-armaduras-e-aneis.md) |
| 36 | [**Física**](spec/36-fisica.md) | Gravidade, queda, balística, empurrão, colisão | 🟠 constantes validam-se no M2 |
| 35 | [**Estudo da referência**](spec/35-estudo-referencia.md) | Números reais comparados com os nossos | 🟢 8 accionáveis |
| 34 | [**Catálogo e comandos**](spec/34-catalogo-e-comandos.md) | A escala, e a regra de que toda a habilidade diz como se activa | 🟢 regra fixada |
| 33 | [**Morte e almas**](spec/33-morte-e-almas.md) | Almas, frascos, armadura, ressurreição em co-op | 🟢 |
| 32 | [**Construção**](spec/32-construcao.md) | Regras de código, o que muda no fluxo | 🟢 |
| 31 | [**Referências**](spec/31-referencias.md) | Como usar o Dark Souls, e a linha que não se atravessa | 🟢 protocolo |
| 30 | [Qualidade visual](spec/30-qualidade-visual.md) | A barra: orçamento consciente, **não** PlayStation 1 | 🟢 |
| 29 | [Perspectiva](spec/29-perspectiva.md) | 1.ª ou 3.ª pessoa à escolha | 🟠 lock-on em 1.ª pessoa em aberto |
| 99 | [**Perguntas em aberto**](spec/99-perguntas-abertas.md) | O que só os donos decidem | — |

## O que está fechado

1. RPG de acção 3D para PC, **1.ª ou 3.ª pessoa à escolha**, souls-like, fantasia medieval
2. **Ganha-se com habilidade, não com nível.** Sem gating, sem grind obrigatório
3. Co-op para dois, sempre disponível
4. Esquiva e parry no corpo a corpo
5. **Qualquer classe pega em qualquer arma** — a diferença vem de atributos e habilidades
6. Atributos distribuídos por nível, tecto **100**
7. Magia do bem e do mal, com usos limitados
8. **Mundo vasto**, por biomas, ~30 min a pé, **12 biomas catalogados**, dungeons escondidas
9. **Mochila sem limite** — só o equipado pesa (70%)
10. **A máquina alvo é a do Rico** — 8 GB, Iris Xe, 1080p @ 60 Hz. Manda em tudo
11. **A barra visual não é PlayStation 1** — 8–15 mil tri por personagem
12. **Dark Souls 2 é o chão de qualidade**, e estuda-se a referência antes de escrever
13. **Tom sombrio a sério** · **português**, tudo
14. **Espólio garantido:** em 10 mortes o inimigo larga tudo o que se vê nele
15. **Descanso recarrega o mapa**, tecto de 10 reaparições — não se farma
16. **Carregamento por área**, não o mundo todo
17. ⭐ **Os controlos escolhem-se dentro do jogo** — [`45`](spec/45-controlos-configuraveis.md)
18. ⭐ **O código do jogo vive neste repositório** — decisão de 31-07, ver [`ESTADO.md`](ESTADO.md)

## O que trava

**Nada trava a construção.** O que falta são decisões que se tomam a jogar, não a escrever — estão no [`99`](spec/99-perguntas-abertas.md) e o [`ESTADO.md`](ESTADO.md) diz quais são mesmo urgentes.

⚠️ **O único risco vermelho é de escopo, e é conhecido:** mundo vasto + ~61 encontros maiores + 12 biomas + 120 armas + 68 armaduras + 70 anéis, **feito por duas pessoas e dois agentes**. Os donos sabem e decidiram avançar. A alavanca que dá vastidão barata são os **círculos e atalhos** ([`39`](spec/39-estudo-profundo.md) §8, [`69`](spec/69-catalogo-do-mundo.md)).

## Sessões

| # | Data | Duração | Transcrição | Ideias |
|---|---|---|---|---|
| 1 | 30-07-2026 | 13m13s | local | local |
| 2 | 31-07-2026 | conversa escrita | — | [`40`](spec/40-decisoes-espolio-magia-inventario.md) |
