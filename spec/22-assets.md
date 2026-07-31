# 22 — Origem dos assets: modelos 3D, animações e áudio (WP13)

> **Autor:** Claude. A parte das imagens geradas já vive em [`../art/MANIFESTO.md`](../art/MANIFESTO.md) + [`../art/prompts/`](../art/prompts/). Este documento trata do resto — o que **não sai de um gerador de imagens**: malhas, esqueletos, animações e som. Formato de importação e integração na engine são do WP14.

## A regra que organiza tudo: a licença decide onde o ficheiro pode viver

Este repositório é **público**. Isso transforma a licença de cada asset numa decisão de engenharia, não num rodapé:

| Classe de licença | Pode entrar no repo? | Tratamento |
|---|---|---|
| **CC0 / domínio público** | ✅ sim | Commit normal em `art/models/` ou `art/audio/`. Mesmo assim, linha no `CREDITS.md` — é decência, não obrigação |
| **CC-BY** | ✅ sim, com atribuição | Commit + entrada obrigatória no `CREDITS.md` (autor, obra, link, licença) |
| **Royalty-free sem redistribuição** (Mixamo, Sonniss, lojas) | ❌ **NUNCA** | Usável no jogo, mas pôr o ficheiro cru num repo público **é redistribuição** — viola os termos. Vive em `art/models/_local/` e `art/audio/_local/` (**gitignored**), entra só nos builds |
| **CC-BY-NC / sem licença clara** | ❌ nem local | Não se usa. "Encontrei na net" não é origem |

**Acções imediatas desta regra** (fazem parte deste WP):
1. `.gitignore` ganha `art/models/_local/` e `art/audio/_local/`
2. Nasce o `CREDITS.md` na raiz — cada asset externo, uma linha, no mesmo PR em que o asset entra
3. Cada pack descarregado guarda o seu `LICENSE.txt` original junto dos ficheiros

## Modelos 3D — de onde vêm

O estilo (estilizado com orçamento consciente — [`30-qualidade-visual.md`](30-qualidade-visual.md)) tem um ecossistema CC0 maduro. ⚠️ Ao escolher packs, verificar a contagem real: muitos assets CC0 são bem abaixo dos 8–15 mil tri que queremos, e ficam pobres ao lado do resto. Prioridade pela ordem:

| Fonte | O que dá | Licença | Custo | Encaixe |
|---|---|---|---|---|
| **KayKit** (Kay Lousberg) | Personagens de fantasia com esqueleto + animações, dungeons, adereços | CC0 | grátis (packs pagos opcionais) | ⭐ o melhor candidato — o pack *Adventurers* cobre guerreiro/mago/ladino, base para as 6 classes; *Dungeon* cobre a Toca |
| **Quaternius** | Monstros, personagens animados, natureza, armas | CC0 | grátis | ⭐ candidato aos orcs e à floresta de Brumal |
| **Kenney** | Adereços, natureza, armas, UI, e áudio | CC0 | grátis | Enchimento de mundo e adereços |
| **Poly Haven** | Texturas e HDRI | CC0 | grátis | Materiais e céu de referência |
| **OpenGameArt / itch.io** | De tudo | **varia por item** | varia | Só com licença verificada item a item |
| Lojas de engine (Unity/Unreal/Godot AL) | De tudo, qualidade alta | EULA da loja — sem redistribuição | pago | Última escolha: prende ficheiros ao `_local/` e por vezes à engine |

**Regra de coerência visual:** misturar packs de autores diferentes parte o estilo. Escolher **um autor-âncora** (KayKit *ou* Quaternius) para personagens+inimigos; os outros só para adereços e cenário. A arte de conceito gerada (`art/concept/`) é o árbitro — um modelo que destoa dela não entra, por muito grátis que seja.

### Lista de compras da fatia 1

| Preciso de | Candidato primeiro | Alternativa | Nota |
|---|---|---|---|
| Corpo base humanóide ×6 classes | KayKit Adventurers | Quaternius RPG characters | Lei 3: um corpo base + armas/peças trocadas vale mais que 6 modelos distintos — confirmar ao descarregar que o esqueleto é partilhado |
| Orc lanceiro + brutamontes | Quaternius Monsters | KayKit Skeletons como fallback de silhueta | O brutamontes precisa de aguentar a animação de armar exagerada |
| Vorgar (chefe) | Orc do pack ampliado ×1,6 escala + adereços de armadura | modelar por cima de base CC0 | Chefe único justifica trabalho manual por cima do pack |
| Floresta de Brumal | Quaternius Nature / Kenney Nature | Poly Haven para texturas de chão | Névoa faz metade do trabalho (Lei 4) |
| Toca (caverna + arena) | KayKit Dungeon | — | Verificar tecto ≥ 2,5 m nas peças de combate (regra da câmara, `25-controlo.md`) |
| 5 armas | Quaternius/Kenney Weapons | KayKit | Ícones já especificados em `art/prompts/04` — o modelo 3D segue o ícone, não o contrário |

*(Os conteúdos exactos de cada pack confirmam-se no download — os nomes acima são o ponto de partida, não inventário verificado.)*

## Animações — o risco nº 1 deste documento

Um souls-like **é** animação. A telegrafia do brutamontes, o armar do parry, o peso do machadão — tudo vive aqui, e é o que nenhum gerador dá.

| Fonte | O que dá | Licença | Regra |
|---|---|---|---|
| **Animações incluídas nos packs KayKit/Quaternius** | Ciclos base: idle, andar, correr, atacar, morrer | CC0 | ⭐ primeira escolha — já encaixam no esqueleto certo, zero retargeting |
| **Mixamo** (Adobe) | Biblioteca enorme de combate humanóide, auto-rigging | Royalty-free, **sem redistribuição** | Usável no jogo; ficheiros em `_local/`, **nunca no repo**. Exige retargeting para o esqueleto do pack |
| Feitas à mão (Blender) | O que faltar | próprias | Reservar para o que define o jogo: telegrafias dos inimigos e o conjunto do parry |

**Ordem de trabalho recomendada:** começar com o que os packs CC0 trazem (chega para o protótipo do marco 1); Mixamo para variedade de combate humano; **as telegrafias dos inimigos e o parry fazem-se à mão** — são a alma do jogo e nenhuma biblioteca genérica tem o armar exagerado de 40 frames que o brutamontes exige (`→WP6` define cada telegrafia; `→WP1` os frames).

**Inventário mínimo por entidade** (o WP12 detalha durações): jogador ≈ 20 animações (locomoção ×4, ataques ×4, esquiva, bloqueio, parry, reacções ×3, morte, poção, magia ×3…) · inimigo comum ≈ 10 · Vorgar ≈ 15 (duas fases). Com 1 esqueleto partilhado nas 6 classes, o total da fatia 1 ronda **55 animações**, das quais talvez 15 à mão. É o maior custo de produção do projeto — está aqui escrito para ninguém o descobrir em cima do marco.

## Áudio

| Preciso de | Fonte primeira | Licença | Regra |
|---|---|---|---|
| Efeitos de combate (aço, carne, madeira, parry) | Kenney Audio, freesound (filtro CC0) | CC0 | Commit ok |
| Passos por piso, ambiente de floresta/caverna | freesound CC0 · Sonniss GDC packs | CC0 / RF sem redist. | Sonniss → `_local/` |
| Grunhidos de orc, esforço do jogador | freesound CC0; gravar em casa é opção séria (dois tipos com um telemóvel fazem um orc) | CC0/próprio | Próprio = commit ok |
| Música (menu, Brumal, Toca, Vorgar ×2 fases) | Kevin MacLeod (CC-BY) · OGA CC0 | CC-BY / CC0 | CC-BY → linha no `CREDITS.md`. **4–5 faixas chegam para a fatia** |
| UI (confirmar, cancelar, subir nível, apanhar item) | Kenney Interface | CC0 | Commit ok |

`→WP12` define a lista fecho-a-fecho de sons e a regra "um chefe lê-se de ouvido".

## O que fica explicitamente adiado

- **Formato e pipeline de importação** (glTF vs FBX, escala, eixos, convenção de nomes) — `→WP14`, porque depende da engine
- **Retargeting concreto** Mixamo→esqueleto do pack — `→WP14`
- **Ferramenta de edição de áudio** e mistura — `→WP12`

## Checklist de fecho deste WP

- [x] Regra de licenças por classe, com o caso "público = redistribuição"
- [ ] `.gitignore` com `_local/` *(entra no commit deste documento)*
- [ ] `CREDITS.md` criado *(idem)*
- [ ] Primeiro download real dos packs-âncora e verificação do inventário — **fica para a sessão de construção**, não se verifica catálogo sem engine escolhida
