# 49 — As 12 fichas de bioma

> **Volta 1 · Fable** (31-07-2026). O motor de produção do [`46`](46-coerencia-bioma-raca-item.md) §2, preenchido: **12 biomas, 8 linhas cada**, mais a `descrição visual` e a coluna `Fatia 1?` que o pipeline de imagens exige. Herda: **~30 min a pé, 10+ biomas** `[DECIDIDO]` (Mateus + Rico, 31-07) · **soft gating** `[DECIDIDO]` · a lei da coerência `[DECIDIDO]` ([`46`](46-coerencia-bioma-raca-item.md)). Tudo `[FABLE]` salvo indicação.
>
> ⭐ **Estas fichas vivem também em [`game/data/biomes.json`](../game/data/biomes.json), no mesmo PR** — e não é cópia morta: o greybox passa a ler a luz e a névoa de Brumal **da ficha**, como o [`47`](47-do-greybox-ao-visual.md) §4 (passo 1) manda.

---

## 1. Porquê 12 — e não 10, nem 15

`[FABLE]` — **12 biomas**, porque é o único número que fecha as duas contas aprovadas ao mesmo tempo:

| Conta | Com 12 | A decisão que tem de bater |
|---|---|---|
| **Tempo a pé** | 12 zonas × 2–3 min de travessia (a régua do WP8) = **~30 min** | *"~30 min a pé"* `[DECIDIDO]` (31-07) — bate exacto |
| **Chefes** | 1 Ultra + 12 subchefes + 12 guardiões + 36 de campo = **61** | os **~61 chefes** prometidos desde o [`00-visao.md`](00-visao.md) — bate exacto ([`46`](46-coerencia-bioma-raca-item.md) §6) |

*Alternativas descartadas:* **10 biomas** → 51 chefes e ~25 min — fica abaixo das duas promessas; **15 biomas** → 76 chefes e ~38 min — rebenta o orçamento de produção de duas pessoas sem que nenhuma decisão o peça.

Isto fecha a *"diferença por acertar"* da pergunta 4 (o WP8 tinha desenhado 6 zonas; **as 6 mantêm-se e entram mais 6**) e dá à pergunta 13 o total que ficou *"em aberto de propósito — conta-se quando houver mapa"*. **Há mapa: 61.** O redesenho da rede de zonas do [`17-mundo.md`](17-mundo.md) é a volta 9; nada daqui obriga a mexer-lhe já.

**O Portão** (núcleo final) fica **fora da conta** — é a arena própria do Ultra, não um bioma: não tem colheita, não tem raça residente, não se vive lá.

---

## 2. A regra da paleta — três cores que são configuração, não decoração

`[FABLE]` — o [`47`](47-do-greybox-ao-visual.md) §4 manda ligar a paleta da ficha à luz e à névoa. A convenção, fixada de uma vez:

| Cor | É | Onde bate no motor |
|---|---|---|
| **1 — luz** | a cor da direccional (o "sol" daquele sítio) | `DirectionalLight3D.light_color` |
| **2 — névoa** | a cor da névoa de profundidade **e** do horizonte | `fog_light_color` + horizonte do céu |
| **3 — acento** | a assinatura — tochas, esporos, lava, relâmpago | emissivos, partículas, UI da zona |

*Alternativa descartada:* paleta como "3 cores de referência para a arte" sem ligação ao motor — era exactamente o que o 47 chama decoração, e ninguém a aplicaria.

**As quatro perguntas do fio solto, respondidas para este pacote:**

| | |
|---|---|
| **Como se usa?** | o jogador vê: cada bioma tem luz, névoa e acento próprios — o greybox de Brumal já os lê da ficha |
| **Como se prova?** | verificações novas no `self_test.gd`: 12 biomas, 8 campos cada, 3 cores hex válidas, exactamente 1 na fatia, raças residentes declaradas |
| **De onde vem a arte?** | `descrição visual` em todas as fichas → [`art/MANIFESTO.md`](../art/MANIFESTO.md); gera o Claude ([`art/PIPELINE.md`](../art/PIPELINE.md)) |
| **Quanto custa?** | zero — luz e névoa já existem no greybox; mudar-lhes a cor não custa um fotograma ([`47`](47-do-greybox-ao-visual.md) §3) |

---

## 3. As fichas

Formato: as 8 linhas do [`46`](46-coerencia-bioma-raca-item.md) §2 + `descrição visual` + `Fatia 1?`. Raças marcadas **(nova)** são as 6 que a volta 2 inventa — ficam aqui semeadas de propósito, para que a ficha de raça já nasça com o *"porque está neste bioma"* respondido. Nomes de zona continuam provisórios até à gravação de narrativa ([`26-narrativa.md`](26-narrativa.md) §3).

### 3.1 Brumal — floresta de bruma · **Fatia 1 ✅**

| | |
|---|---|
| **Elemento dominante** | bruma (sombra rasteira — não é veneno nem frio: desorienta) |
| **Elemento que lá funciona** | fogo — abre clareiras na bruma e os orcs temem-no |
| **Material característico** | carvalho-negro, ferro rude, couro de javali |
| **Paleta** | luz `#ffebcc` · névoa `#8b96a3` · acento `#d9a441` (tochas) |
| **Raças que lá vivem** | **orcs** (dominante) · goblins na orla |
| **O que se colhe** | **limalha de ferro** — o material de reforço base (o WP9 já a nomeia) |
| **A ameaça** | a bruma densa das bordas: 3 s lá dentro e estás virado para trás (regra do [`17`](17-mundo.md)) |
| **O que aconteceu aqui** | a bruma subiu da terra no dia em que a Raiz foi aberta — e nunca mais baixou |
| **Descrição visual** | floresta de carvalhos negros afogada em bruma verde-cinzenta, luz âmbar de fim de tarde coada entre troncos, arco de pedra partido ao fundo |
| **Fatia 1?** | ✅ — é a zona da fatia; a paleta fixa o que o protótipo já mostra no ecrã |

### 3.2 Selva Funda — selva vertical

| | |
|---|---|
| **Elemento dominante** | veneno (tudo o que é verde aqui defende-se) |
| **Elemento que lá funciona** | fogo — a vegetação teme-o mais do que tudo |
| **Material característico** | vime trançado, espinho de aves gigantes, seda crua |
| **Paleta** | luz `#a8c46a` · névoa `#24422e` · acento `#c92f6b` (flores-peçonha) |
| **Raças que lá vivem** | **goblins** (dominante, nas copas) · Tecelões **(nova)** · kobolds nos barrancos |
| **O que se colhe** | seiva-peçonha — a raiz do estado *veneno* (volta 8) |
| **A ameaça** | a queda: o chão verdadeiro fica 40 m abaixo das copas, e os passadiços goblin **rangem antes de ceder** — o aviso é sonoro |
| **O que aconteceu aqui** | os goblins vivem nas copas porque o chão da Selva nunca foi deles |
| **Descrição visual** | selva vertical de copas fechadas, passadiços de vime goblin a 40 m do chão escuro, feixes de luz verde a cair como cordas |
| **Fatia 1?** | ⬜ — candidata a fatia 2 (já o era no [`17`](17-mundo.md)) |

### 3.3 Campas Cinzentas — pântano dos mortos

| | |
|---|---|
| **Elemento dominante** | morte (necromancia residual — não é doença, é teimosia) |
| **Elemento que lá funciona** | **luz** — a escola do bem; os mortos-vivos temem-na (`[DECIDIDO]` via pergunta 8) |
| **Material característico** | osso, madeira encharcada, ferro comido de ferrugem |
| **Paleta** | luz `#beb5a3` · névoa `#6f7468` · acento `#43c39b` (fogos-fátuos) |
| **Raças que lá vivem** | **esqueletos** (dominante) · zumbis |
| **O que se colhe** | cinza de ossário |
| **A ameaça** | o lodo agarra — na água parada anda-se a metade, e o que vive na água só ataca aí |
| **O que aconteceu aqui** | uma batalha acabou aqui sem vencedor; os mortos ainda esperam ordens |
| **Descrição visual** | pântano de árvores mortas e lápides tortas meio afundadas, água parada cinzenta, fogos-fátuos verde-água ao longe |
| **Fatia 1?** | ⬜ — candidata a fatia 2; o **Ceifador** (subchefe, Rico 31-07) vive aqui |

### 3.4 Fojo — desfiladeiros e minas

| | |
|---|---|
| **Elemento dominante** | terra (pedra, poeira, escuro de mina) |
| **Elemento que lá funciona** | raio — corre nos veios metálicos e os kobolds têm-lhe pavor |
| **Material característico** | granito, ferro em bruto, corda e roldana |
| **Paleta** | luz `#e0a35c` · névoa `#55463a` · acento `#d94f2a` (brasas e ferrugem) |
| **Raças que lá vivem** | **kobolds** (dominante) · mímicos nas galerias · o **Minotauro** no labirinto (guardião) |
| **O que se colhe** | ferro em bruto — o veio principal do reforço de armas |
| **A ameaça** | as armadilhas kobold — todas com gatilho visível: punem a pressa, nunca o azar (Lei 1) |
| **O que aconteceu aqui** | os kobolds não cavaram as minas — mudaram-se para o que encontraram aberto |
| **Descrição visual** | desfiladeiro ocre estreito com andaimes e roldanas kobold, bocas de mina iluminadas a tocha, poeira suspensa na luz |
| **Fatia 1?** | ⬜ |

### 3.5 Costa Quebrada — falésias dos naufrágios

| | |
|---|---|
| **Elemento dominante** | tempestade (vento e chuva fina, sempre) |
| **Elemento que lá funciona** | raio — aqui tudo está molhado, e o que está molhado conduz |
| **Material característico** | madeira de naufrágio, bronze verde de azinhavre, sal |
| **Paleta** | luz `#b7c3cd` · névoa `#7d8fa0` · acento `#55a58a` (azinhavre) |
| **Raças que lá vivem** | **orcs do mar** (dominante) · mímicos nos destroços · Submersos **(nova)** na linha de maré · Ventaneiras **(nova)** nos ninhos altos |
| **O que se colhe** | bronze-do-mar |
| **A ameaça** | as rajadas: o vento empurra ([`36-fisica.md`](36-fisica.md)) e **assobia 1 s antes** de bater; junto à borda da falésia, é a queda |
| **O que aconteceu aqui** | uma frota inteira quebrou numa só noite, e o mar nunca devolveu um único corpo |
| **Descrição visual** | falésias de basalto sob chuva fina, esqueletos de navios espetados nas rochas, bronze coberto de azinhavre |
| **Fatia 1?** | ⬜ |

### 3.6 Cimeira — a montanha limpa

| | |
|---|---|
| **Elemento dominante** | gelo |
| **Elemento que lá funciona** | fogo |
| **Material característico** | aço temperado a frio, pele de cabra-das-neves, gelo-azul |
| **Paleta** | luz `#eef4fc` · névoa `#c3d4e6` · acento `#4f7fd9` (gelo-azul) |
| **Raças que lá vivem** | **Ventaneiras** (dominante, **nova**) · minotauros da neve |
| **O que se colhe** | flor-de-gelo |
| **A ameaça** | o frio rói a stamina máxima ao ar livre; abrigos e fogueiras devolvem-na (números → volta 9) |
| **O que aconteceu aqui** | quem subiu à Cimeira foi para vigiar uma coisa ao longe — e ainda está de vigia |
| **Descrição visual** | encosta nevada acima das nuvens, céu limpo azul-gelo, escadaria de pedra a desaparecer na neve — **o único bioma sem bruma**: a vista é a recompensa |
| **Fatia 1?** | ⬜ |

### 3.7 Fornalha — o monte-forja

| | |
|---|---|
| **Elemento dominante** | fogo |
| **Elemento que lá funciona** | gelo |
| **Material característico** | obsidiana, bronze fundido, couro curtido — a ficha-exemplo do [`46`](46-coerencia-bioma-raca-item.md) §2, agora real |
| **Paleta** | luz `#ff8a4a` · névoa `#40302c` (fumo) · acento `#ffb347` (lava) |
| **Raças que lá vivem** | **Borralheiros** (dominante, **nova**) · orcs do fogo |
| **O que se colhe** | obsidiana |
| **A ameaça** | o chão mente: crosta escura aguenta, crosta rubra cede — a cor é a telegrafia |
| **O que aconteceu aqui** | a forja ainda está acesa; ninguém a alimenta há cem anos |
| **Descrição visual** | monte negro de obsidiana com rios de lava, fumo a subir de chaminés de pedra, forjas abandonadas ainda acesas |
| **Fatia 1?** | ⬜ |

### 3.8 Fulgor — o planalto da tempestade presa

| | |
|---|---|
| **Elemento dominante** | raio |
| **Elemento que lá funciona** | terra — o que está ligado ao chão não se electrocuta; os nativos evitam tudo o que é metal |
| **Material característico** | fulgurite (areia fundida pelos raios), couro seco, osso polido pelo vento |
| **Paleta** | luz `#d8cfa8` · névoa `#8a836b` (poeira) · acento `#a37fe8` (relâmpago) |
| **Raças que lá vivem** | **minotauros errantes** (dominante — manadas em migração eterna) · kobolds das tempestades |
| **O que se colhe** | fulgurite |
| **A ameaça** | os relâmpagos caem onde o chão **brilha 1 s antes** — telegrafia vinda do céu, esquiva-se como um golpe |
| **O que aconteceu aqui** | a tempestade não passa — está presa, a rodar o mesmo monte desde que alguém a prendeu |
| **Descrição visual** | planalto seco e rachado sob um tecto de nuvens violeta em rotação lenta, relâmpagos a cravar-se em torres de vidro fulgurite |
| **Fatia 1?** | ⬜ |

### 3.9 Raizama — a caverna do grande morto

| | |
|---|---|
| **Elemento dominante** | esporos (veneno lento, luminoso) |
| **Elemento que lá funciona** | fogo — os esporos ardem em cadeia |
| **Material característico** | quitina, madeira-cogumelo, seda de teia |
| **Paleta** | luz `#3f5c8f` · névoa `#1c2740` · acento `#64e0c8` (esporos) |
| **Raças que lá vivem** | **Tecelões** (dominante, **nova**) · goblins-fungo |
| **O que se colhe** | esporo-lúmen |
| **A ameaça** | as nuvens de esporos — visíveis, envenenam quem as atravessa; rebentá-las à distância limpa o caminho (opção, Lei 2) |
| **O que aconteceu aqui** | tudo aqui cresce sobre a carcaça de algo enorme; os cogumelos são a sua flor |
| **Descrição visual** | caverna colossal de raízes entrançadas e cogumelos-torre, escuro azul cortado por esporos ciano a flutuar |
| **Fatia 1?** | ⬜ |

### 3.10 Cidade Afogada — as ruínas debaixo de água parada

| | |
|---|---|
| **Elemento dominante** | água |
| **Elemento que lá funciona** | raio |
| **Material característico** | mármore afogado, prata escurecida, vidro |
| **Paleta** | luz `#6fa39b` · névoa `#3a5a60` · acento `#c9d2da` (prata) |
| **Raças que lá vivem** | **Submersos** (dominante, **nova**) · zumbis afogados |
| **O que se colhe** | prata afogada |
| **A ameaça** | a água profunda: a nadar não se ataca nem se esquiva — e o que nada por baixo caça o que faz barulho |
| **O que aconteceu aqui** | a água subiu num único dia e parou à altura dos sinos — que ainda tocam |
| **Descrição visual** | cidade de mármore mergulhada em água verde-clara até aos telhados, campanários à tona, prata a luzir por baixo da superfície |
| **Fatia 1?** | ⬜ |

### 3.11 Santuário Branco — o templo que rezou de mais

| | |
|---|---|
| **Elemento dominante** | luz — mas errada: brilha de mais, aquece de menos |
| **Elemento que lá funciona** | **sombra** — a escola do mal; é o único bioma onde ela é a resposta natural (o espelho das Campas) |
| **Material característico** | mármore branco, ouro baço, cera |
| **Paleta** | luz `#f7ecca` · névoa `#ded0ac` · acento `#8a2f2f` (sangue seco) |
| **Raças que lá vivem** | **Penitentes** (dominante, **nova**) · esqueletos dourados |
| **O que se colhe** | cera benta |
| **A ameaça** | a luz cega: encarar as zonas de brilho marcadas queima a visão por segundos — os Penitentes não têm olhos, e a eles não lhes faz nada |
| **O que aconteceu aqui** | rezaram até a luz responder; o que respondeu não era o que chamavam |
| **Descrição visual** | templo de mármore branco de brilho excessivo, ouro baço, milhares de velas acesas, sombras cortadas a preto |
| **Fatia 1?** | ⬜ |

### 3.12 A Raiz — o abismo de onde a bruma sai

| | |
|---|---|
| **Elemento dominante** | sombra |
| **Elemento que lá funciona** | luz |
| **Material característico** | pedra negra, raiz petrificada, prata baça |
| **Paleta** | luz `#4a4260` · névoa `#151221` · acento `#b8b2d9` — **a cor da bruma de Brumal**: é daqui que ela vem, e a paleta di-lo sem uma palavra |
| **Raças que lá vivem** | **Sem-Rosto** (dominante, **nova**) · esqueletos antigos — e élites das outras raças, descidas atrás do que se perdeu |
| **O que se colhe** | lágrima de bruma |
| **A ameaça** | o escuro absoluto: a lanterna ocupa a mão do escudo — ver ou defender, nunca os dois (Lei 2: é uma escolha, não um número) |
| **O que aconteceu aqui** | foi daqui que a bruma saiu, pela porta que alguém deixou aberta |
| **Descrição visual** | abismo de pedra negra onde rios de bruma pálida correm **para cima**, escuro quase total, raízes petrificadas do tamanho de torres |
| **Fatia 1?** | ⬜ — antecâmara do Portão (o núcleo final vem a seguir) |

---

## 4. O quadro-resumo

| # | Bioma | Elemento | Eficaz contra ele | Colheita | Raça dominante | Fatia 1? |
|---|---|---|---|---|---|---|
| 1 | Brumal | bruma | fogo | limalha de ferro | orcs | ✅ |
| 2 | Selva Funda | veneno | fogo | seiva-peçonha | goblins | ⬜ |
| 3 | Campas Cinzentas | morte | luz | cinza de ossário | esqueletos | ⬜ |
| 4 | Fojo | terra | raio | ferro em bruto | kobolds | ⬜ |
| 5 | Costa Quebrada | tempestade | raio | bronze-do-mar | orcs do mar | ⬜ |
| 6 | Cimeira | gelo | fogo | flor-de-gelo | Ventaneiras *(nova)* | ⬜ |
| 7 | Fornalha | fogo | gelo | obsidiana | Borralheiros *(nova)* | ⬜ |
| 8 | Fulgor | raio | terra | fulgurite | minotauros errantes | ⬜ |
| 9 | Raizama | esporos | fogo | esporo-lúmen | Tecelões *(nova)* | ⬜ |
| 10 | Cidade Afogada | água | raio | prata afogada | Submersos *(nova)* | ⬜ |
| 11 | Santuário Branco | luz | sombra | cera benta | Penitentes *(nova)* | ⬜ |
| 12 | A Raiz | sombra | luz | lágrima de bruma | Sem-Rosto *(nova)* | ⬜ |

**A verificação da alavanca do [`46`](46-coerencia-bioma-raca-item.md) §7** — cada raça existente aparece 2–3 vezes, nenhuma mais de 3: orcs ×3 (1, 5, 7) · goblins ×3 (1, 2, 9) · kobolds ×3 (2, 4, 8) · esqueletos ×3 (3, 11, 12) · zumbis ×2 (3, 10) · minotauros ×3 (4, 6, 8) · mímicos ×2 (4, 5). **As 6 raças novas da volta 2 já têm casa e motivo:** Tecelões, Ventaneiras, Borralheiros, Submersos, Penitentes, Sem-Rosto.

**E os pares elementais fecham:** fogo↔gelo (7↔6), luz↔morte/sombra (11↔3/12), raio↔terra (8↔4), e a água conduz o raio (5, 10). Nenhum elemento é órfão — todo o "eficaz contra" existe como colheita ou escola em algum lado do mapa.

---

## 5. O fio que atravessa as doze

`[FABLE]` — proposta de espinha, **não fecha lore dos donos** (os nomes e o tom final são da gravação de narrativa, [`26`](26-narrativa.md) §3):

> **Alguém abriu a Raiz. A bruma saiu por essa porta e afogou Brumal. A Cimeira vigia-a desde então; o Santuário rezou contra ela até enlouquecer; as Campas são a guerra que se travou — e perdeu — no caminho.**

Quatro fichas contam-no sem uma linha de diálogo (1, 6, 11, 12 — e a paleta da Raiz partilha o tom da bruma de Brumal de propósito). É o [`39`](39-estudo-profundo.md) §12: não há narrador; há sítios que se leem.

---

## 6. O que fecha, o que abre, o que entrega

**Fecha** (com carimbo `[FABLE]` — os donos podem trocar o 12 por outro número, mas barato só até à volta 5, quando o bestiário começa a multiplicar raça × bioma):

- **Pergunta 4, a diferença por acertar** — as 6 zonas do WP8 crescem para 12; os ~30 min mantêm-se.
- **Pergunta 13, o total** — *"conta-se quando houver mapa"*: há mapa, e a conta dá **61**.

**Abre:**

| Pergunta | Para |
|---|---|
| As 8 linhas de cada raça nova (6) | **volta 2** — já sabem onde vivem e porquê |
| Que peças de armadura cada raça larga por bioma | volta 5 (WP6) — herda da decisão da armadura por peças |
| A rede: quem liga a quem, círculos e atalhos das 6 zonas novas | volta 9 (WP8) |
| Números do frio (6), do lodo (3) e da cegueira (11) | volta 9, com a Lei 1 como tecto |

**Entrega já:**

| Para | O quê |
|---|---|
| **WP12 / [`47`](47-do-greybox-ao-visual.md)** | 12 paletas ligadas ao motor — o passo 1 da conversão deixa de estar bloqueado |
| **volta 3 (armas)** | 12 materiais característicos + 12 colheitas — nenhuma arma nasce sem saber de que é feita |
| **volta 5 (bestiário)** | a matriz raça × bioma pronta a preencher (~30–36 fichas) |
| **Claude (imagens)** | 11 `descrição visual` novas (Brumal já tem cenário gerado) — ver nota no [`art/MANIFESTO.md`](../art/MANIFESTO.md) |

## Ligações

[`46-coerencia-bioma-raca-item.md`](46-coerencia-bioma-raca-item.md) · [`47-do-greybox-ao-visual.md`](47-do-greybox-ao-visual.md) · [`17-mundo.md`](17-mundo.md) · [`36-fisica.md`](36-fisica.md) · [`26-narrativa.md`](26-narrativa.md) · [`99-perguntas-abertas.md`](99-perguntas-abertas.md) · [`game/data/biomes.json`](../game/data/biomes.json)
