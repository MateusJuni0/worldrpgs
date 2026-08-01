# 69 — Catálogo do mundo: doze círculos que se aprendem

> **Tarefa 3.4 · Codex** (01-08-2026). Fecha o WP8 em dados executáveis. Herda os 12 biomas do [`49`](49-biomas.md), o círculo do [`39`](39-estudo-profundo.md) §8, o carregamento do [`43`](43-estudo-espolio-inventario-mundo.md) §6, o ritmo e as portas do [`53`](53-chefes-ritmo-e-o-mago-forte.md) §§2–3 e a leitura do [`57`](57-mapa-e-minimapa.md) §5. Tudo `[CODEX]` salvo decisão herdada.

**Regra-mãe:** uma zona só está acabada quando o caminho longo fecha um círculo horizontal, outro vertical e um atalho ganho pelo lado de dentro. O mapa regista essa aprendizagem; nunca a antecipa.

---

## 1. ⭐ A leitura foi decidida antes do traçado

| Campo | Contrato | Descrição visual | Fatia 1? |
|---|---|---|---|
| Projecção | vista inclinada a ~40° | mapa inclinado a quarenta graus em pergaminho cinzento, percurso já pisado a tinta âmbar, andar actual nítido e alturas vizinhas esbatidas | ⬜ |
| Revelação | só terreno percorrido; o desconhecido fica em branco | mapa inclinado a quarenta graus em pergaminho cinzento, percurso já pisado a tinta âmbar, andar actual nítido e alturas vizinhas esbatidas | ⬜ |
| Altura | andar actual realçado; restantes esbatidos | mapa inclinado a quarenta graus em pergaminho cinzento, percurso já pisado a tinta âmbar, andar actual nítido e alturas vizinhas esbatidas | ⬜ |
| Escopo | **continua dos donos:** mapa por zona ou do mundo inteiro; o traçado local funciona nos dois | mapa inclinado a quarenta graus em pergaminho cinzento, percurso já pisado a tinta âmbar, andar actual nítido e alturas vizinhas esbatidas | ⬜ |

O catálogo não toca na pergunta de escopo. A geometria usa patamares com separação de silhueta e evita empilhar três rotas idênticas no mesmo eixo; assim ambas as opções de UI continuam possíveis.

---

## 2. Escala, rede e carregamento

- Cada bioma mede **8–12 min** do primeiro descanso à porta do guardião, sem combate, atalhos ou exploração lateral.
- A rede não soma doze zonas em linha: o diâmetro útil é de **três travessias**. Costa Quebrada (11) + Cimeira (10) + Fulgor (9) = **30 min** de uma ponta à borda da Raiz.
- Há **21 ligações** e todos os biomas têm pelo menos duas saídas. Nenhuma porta verifica nível; a dificuldade é só *soft gating*.
- A unidade de streaming é uma zona; ficam residentes a actual e as vizinhas imediatas. Cada garganta lista exactamente os dois lados. Em co-op manda a máquina mais lenta.
- Viagem rápida abre com 3+ zonas implementadas, apenas entre descansos já visitados e a partir de outro descanso.

### Ligações físicas

| # | De | Para | Garganta / descrição visual | Fatia 1? |
|---:|---|---|---|---|
| 1 | Brumal | Selva Funda | **garganta de raízes:** raízes de carvalho-negro apertam um corredor de 5 m e tornam-se vime verde na saída | ⬜ |
| 2 | Brumal | Campas Cinzentas | **vale da bruma baixa:** trilho de pedra musgosa desce entre carvalhos negros até a água cinzenta cobrir as raízes | ⬜ |
| 3 | Brumal | Fojo | **arco da pedreira:** arco de granito partido fecha-se num corte ocre com carris de ferro bruto sob a bruma | ⬜ |
| 4 | Selva Funda | Fojo | **barranco das roldanas:** bambu negro e seda cedem lugar a andaimes de granito e uma roldana sobre o desfiladeiro | ⬜ |
| 5 | Selva Funda | Costa Quebrada | **rio das copas:** passadiço de vime acompanha água verde até árvores baixas retorcidas pelo vento salgado | ⬜ |
| 6 | Campas Cinzentas | Fojo | **dreno da mina:** canal de madeira encharcada entra num túnel de granito onde o lodo deixa marcas ferrugentas | ⬜ |
| 7 | Campas Cinzentas | Cidade Afogada | **calçada submersa:** lápides inclinadas transformam-se em marcos de mármore sob água verde cada vez mais funda | ⬜ |
| 8 | Fojo | Fulgor | **rampa do veio vítreo:** galeria de ferro abre num planalto onde o minério passa a vidro violeta fundido por raios | ⬜ |
| 9 | Costa Quebrada | Cimeira | **escada do granizo:** degraus de basalto molhado sobem entre mastros partidos até a chuva se tornar neve branca | ⬜ |
| 10 | Costa Quebrada | Cidade Afogada | **molhe quebrado:** molhe de madeira e bronze desce para telhados de mármore rodeados por água verde-clara | ⬜ |
| 11 | Cimeira | Fulgor | **colo da tempestade:** neve azul recua numa garganta de pedra seca onde nuvens violetas rodam abaixo da crista | ⬜ |
| 12 | Cimeira | Santuario Branco | **procissão gelada:** escadaria de pedra branca perde a neve e ganha filas de velas protegidas por nichos de ouro baço | ⬜ |
| 13 | Fornalha | Fulgor | **campo de escória vítrea:** obsidiana rachada arrefece em areia fundida, com relâmpagos presos em agulhas violetas | ⬜ |
| 14 | Fornalha | Raizama | **chaminé de esporos:** conduta de obsidiana desce até raízes húmidas onde brasas laranja passam a pontos ciano | ⬜ |
| 15 | Fornalha | Santuario Branco | **via dos cadinhos votivos:** placas de bronze queimado tornam-se degraus de ouro baço cobertos por cera derretida | ⬜ |
| 16 | Fulgor | A Raiz | **fenda aterrada:** correntes enterradas mergulham numa abertura de pedra negra onde a bruma sobe contra a gravidade | ⬜ |
| 17 | Raizama | Cidade Afogada | **aqueduto micelial:** raízes e cogumelos envolvem um aqueduto de mármore até a água substituir o chão | ⬜ |
| 18 | Raizama | A Raiz | **costela petrificada:** osso coberto de seda escurece e cresce até ser indistinguível das raízes-torre do abismo | ⬜ |
| 19 | Cidade Afogada | Santuario Branco | **via das estátuas lavadas:** estátuas de mármore saem da água em fila e chegam secas, cobertas de cera branca | ⬜ |
| 20 | Santuario Branco | A Raiz | **escada da sombra inteira:** mármore excessivamente branco escurece degrau a degrau até virar pedra negra com prata baça | ⬜ |
| 21 | Fojo | Fornalha | **veio da escória:** carris de ferro bruto descem por granito quente até a rocha ficar negra e o bronze aparecer fundido | ⬜ |

---

## 3. Quadro das doze zonas

| # | Zona | Min | Comuns | Elites | Nomeados | Descansos | Altura | Saídas | Descrição visual | Fatia 1? |
|---:|---|---:|---:|---:|---:|---:|---:|---:|---|---|
| 1 | Brumal | 8 | 12 | 3 | 2 | 2 | 7 m | 3 | floresta de carvalhos negros afogada em bruma verde-cinzenta, luz ambar de fim de tarde coada entre troncos, arco de pedra partido ao fundo | ✅ |
| 2 | Selva Funda | 10 | 14 | 4 | 2 | 3 | 40 m | 3 | selva vertical de copas fechadas, passadicos de vime goblin a 40 m do chao escuro, feixes de luz verde a cair como cordas | ⬜ |
| 3 | Campas Cinzentas | 9 | 13 | 3 | 3 | 2 | 6 m | 3 | pantano de arvores mortas e lapides tortas meio afundadas, agua parada cinzenta, fogos-fatuos verde-agua ao longe | ⬜ |
| 4 | Fojo | 9 | 16 | 4 | 2 | 3 | 28 m | 5 | desfiladeiro ocre estreito com andaimes e roldanas kobold, bocas de mina iluminadas a tocha, poeira suspensa na luz | ⬜ |
| 5 | Costa Quebrada | 11 | 15 | 4 | 3 | 2 | 34 m | 3 | falesias de basalto sob chuva fina, esqueletos de navios espetados nas rochas, bronze coberto de azinhavre | ⬜ |
| 6 | Cimeira | 10 | 14 | 3 | 2 | 3 | 48 m | 3 | encosta nevada acima das nuvens, ceu limpo azul-gelo, escadaria de pedra a desaparecer na neve — o unico bioma sem bruma | ⬜ |
| 7 | Fornalha | 10 | 17 | 5 | 2 | 2 | 32 m | 4 | monte negro de obsidiana com rios de lava, fumo a subir de chamines de pedra, forjas abandonadas ainda acesas | ⬜ |
| 8 | Fulgor | 9 | 16 | 4 | 3 | 3 | 36 m | 4 | planalto seco e rachado sob um tecto de nuvens violeta em rotacao lenta, relampagos a cravar-se em torres de vidro fulgurite | ⬜ |
| 9 | Raizama | 11 | 15 | 4 | 2 | 2 | 43 m | 3 | caverna colossal de raizes entrancadas e cogumelos-torre, escuro azul cortado por esporos ciano a flutuar | ⬜ |
| 10 | Cidade Afogada | 10 | 18 | 5 | 2 | 3 | 31 m | 4 | cidade de marmore mergulhada em agua verde-clara ate aos telhados, campanarios a tona, prata a luzir por baixo da superficie | ⬜ |
| 11 | Santuario Branco | 9 | 17 | 4 | 3 | 2 | 27 m | 4 | templo de marmore branco de brilho excessivo, ouro baco, milhares de velas acesas, sombras cortadas a preto | ⬜ |
| 12 | A Raiz | 12 | 20 | 5 | 2 | 3 | 52 m | 3 | abismo de pedra negra onde rios de bruma palida correm para cima, escuro quase total, raizes petrificadas do tamanho de torres | ⬜ |

### 3.1 Brumal

**Orçamento de travessia:** 8 min — Orla → caminho médio → clareira do brutamontes → árvore morta → porta da Toca. **Curva:** 12 comuns · 3 elites · 2 nomeados · 1 subchefe · descanso · 1 guardião. ⚠️ É alvo de catálogo; a medição real só fecha pelas cinco corridas da §9.

| Peça | Função | Descrição visual | Fatia 1? |
|---|---|---|---|
| Círculo horizontal — **Portão da Clareira** | trilho exterior da clareira à orla; abre por dentro; volta em 36 s | portão duplo de carvalho-negro com ferragens rudes, 4 m de largura, visto primeiro por trás | ✅ |
| Círculo vertical — **Círculo vertical de Brumal** | escada de raiz e plataforma que desce ao leito de bruma; 7 m; abre por dentro | plataforma quadrada de carvalho-negro suspensa por duas correntes de ferro rude, entre raízes de 2 m | ✅ |
| Atalho — **Portão da Árvore** | árvore morta → Orla, repetição em 38 s; abre por dentro e persiste | cancela de troncos negros com lingueta de ferro acessível apenas no lado da árvore morta | ✅ |
| Dungeon — **A Toca** | fenda sob a árvore morta; 2 pistas; 3 salas + guardião | entrada de rocha húmida com 2,5 m sob raízes de carvalho-negro, penas presas na bruma | ✅ |
| Ameaça — **bruma de borda** | a bruma fica opaca durante 3 s e vira o jogador para terreno seguro; saída: recuar antes dos 3 s | carvalho-negro, ferro rude, couro de javali; densidade sobe em três degraus; ramos e pedras apontam de volta | ✅ |

**Marcos e descansos**

| Tipo | Nome | Descrição visual | Fatia 1? |
|---|---|---|---|
| Marco | Arco Partido | arco de granito musgoso com 9 m, metade esquerda tombada entre carvalhos negros | ✅ |
| Marco | Árvore Morta | carvalho negro sem copa com 24 m, raízes levantadas e uma fenda de rocha por baixo | ✅ |
| Marco | Farol dos Corvos | torre baixa de granito com 12 m, três varas de ferro cobertas de corvos e braseiro âmbar | ✅ |
| Descanso | Descanso 1 de Brumal | carvalho-negro, ferro rude, couro de javali; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ✅ |
| Descanso | Descanso antes do guardião de Brumal | carvalho-negro, ferro rude, couro de javali; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ✅ |

### 3.2 Selva Funda

**Orçamento de travessia:** 10 min — Raízes → elevador de contrapeso → aldeia suspensa → ponte dos espinhos → ninho do guardião. **Curva:** 14 comuns · 4 elites · 2 nomeados · 1 subchefe · descanso · 1 guardião.

| Peça | Função | Descrição visual | Fatia 1? |
|---|---|---|---|
| Círculo horizontal — **Anel das Copas** | ponte exterior que volta da aldeia ao elevador; abre por dentro; volta em 46 s | passadiço circular de vime trançado com 3 m de largura, guarda de espinhos e flores peçonha | ⬜ |
| Círculo vertical — **Círculo vertical de Selva Funda** | elevador goblin de dois cestos entre raízes e copas; 40 m; abre por dentro | dois cestos de vime com 4 m presos a roldanas de bambu negro e contrapesos de pedra | ⬜ |
| Atalho — **Escada da Seiva** | ninho do guardião → aldeia, repetição em 52 s; abre por dentro e persiste | escada de corda e seda crua enrolada numa viga, solta apenas da plataforma superior | ⬜ |
| Dungeon — **Casulo Vazio** | bolsa de seda atrás da Cascata Verde; 2 pistas; 4 salas + guardião | casulo oval de seda crua com 5 m, rasgado por dentro e preso a raízes negras molhadas | ⬜ |
| Ameaça — **passadiço cedente** | tábua marcada range 1,2 s antes de cair para uma rede 4 m abaixo; saída: sair da placa ou usar a queda segura para o piso inferior | vime trancado, espinho de aves gigantes, seda crua; vime esbranquiçado, fibras soltas e oscilação crescente | ⬜ |

**Marcos e descansos**

| Tipo | Nome | Descrição visual | Fatia 1? |
|---|---|---|---|
| Marco | Figueira Escada | figueira estranguladora com 45 m, degraus de vime enrolados no tronco e flores magenta na copa | ⬜ |
| Marco | Ninho Partido | taça de espinhos gigantes com 16 m presa entre três copas, metade caída em fios de seda | ⬜ |
| Marco | Cascata Verde | queda de água com 38 m coberta por trepadeiras, espuma verde visível entre os passadiços | ⬜ |
| Descanso | Descanso 1 de Selva Funda | vime trancado, espinho de aves gigantes, seda crua; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ⬜ |
| Descanso | Descanso 2 de Selva Funda | vime trancado, espinho de aves gigantes, seda crua; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ⬜ |
| Descanso | Descanso antes do guardião de Selva Funda | vime trancado, espinho de aves gigantes, seda crua; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ⬜ |

### 3.3 Campas Cinzentas

**Orçamento de travessia:** 9 min — Cais seco → lápides inclinadas → dique dos estandartes → ossário → capela do guardião. **Curva:** 13 comuns · 3 elites · 3 nomeados · 1 subchefe · descanso · 1 guardião.

| Peça | Função | Descrição visual | Fatia 1? |
|---|---|---|---|
| Círculo horizontal — **Dique de Regresso** | coroa seca em redor do pântano até ao cais; abre por dentro; volta em 41 s | passagem de madeira encharcada sobre estacas de osso, 3 m de largura e archotes verde-água | ⬜ |
| Círculo vertical — **Círculo vertical de Campas Cinzentas** | comporta baixa o lodo e revela a escada do ossário; 6 m; abre por dentro | comporta de ferro ferrugento com roda de 2 m, canais de pedra e água cinzenta a escorrer | ⬜ |
| Atalho — **Comporta dos Mortos** | capela → cais seco, repetição em 45 s; abre por dentro e persiste | grade de ferro comida de ferrugem num canal estreito, manivela de osso apenas no lado da capela | ⬜ |
| Dungeon — **Ossário Sem Ordens** | cripta sob o dique dos estandartes; 2 pistas; 4 salas + guardião | escadaria de pedra afundada entre lápides, degraus de osso seco e fogos-fátuos verde-água | ⬜ |
| Ameaça — **lodo que agarra** | andar no lodo reduz a deslocação para 50%; rolar sai para terreno seco; saída: usar diques ou rolar para uma ilha seca | osso, madeira encharcada, ferro comido de ferrugem; água opaca só até ao joelho, bolhas em linha e estacas que marcam o caminho firme | ⬜ |

**Marcos e descansos**

| Tipo | Nome | Descrição visual | Fatia 1? |
|---|---|---|---|
| Marco | Salgueiro Enforcado | salgueiro morto com 19 m, raízes sobre água cinzenta e dezenas de elmos ferrugentos pendurados | ⬜ |
| Marco | Dique dos Estandartes | muralha de madeira encharcada com 6 m, coberta por panos cinzentos e lanças partidas | ⬜ |
| Marco | Lua no Ossário | óculo circular de pedra com 8 m reflectido no lodo, rodeado por ossos ordenados em espiral | ⬜ |
| Descanso | Descanso 1 de Campas Cinzentas | osso, madeira encharcada, ferro comido de ferrugem; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ⬜ |
| Descanso | Descanso antes do guardião de Campas Cinzentas | osso, madeira encharcada, ferro comido de ferrugem; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ⬜ |

### 3.4 Fojo

**Orçamento de travessia:** 9 min — Boca alta → andaimes → praça das roldanas → veio partido → labirinto do guardião. **Curva:** 16 comuns · 4 elites · 2 nomeados · 1 subchefe · descanso · 1 guardião.

| Peça | Função | Descrição visual | Fatia 1? |
|---|---|---|---|
| Círculo horizontal — **Galeria de Contramina** | túnel exterior que devolve a praça à boca alta; abre por dentro; volta em 41 s | galeria de granito com 4 m, carris de ferro bruto e escoras de madeira marcadas por picareta | ⬜ |
| Círculo vertical — **Círculo vertical de Fojo** | plataforma de minério em três paragens; 28 m; abre por dentro | jaula de ferro em bruto com 5 m presa a roldana de madeira, contrapeso de blocos de granito | ⬜ |
| Atalho — **Elevador do Veio** | labirinto → boca alta, repetição em 58 s; abre por dentro e persiste | plataforma de ferro de 4 m, alavanca dentada voltada para o fundo da mina e corrente grossa | ⬜ |
| Dungeon — **Contramina Cega** | porta lateral atrás do Veio Rubro; 2 pistas; 4 salas + guardião | porta rectangular de granito sem dobradiças, contorno de pó limpo e cunhas de ferro no chão | ⬜ |
| Ameaça — **armadilhas kobold** | placas visíveis activam dardos ou queda sobrevivível de 4 m após 0,8 s; saída: parar antes da placa, saltar a faixa ou bloquear os dardos | granito, ferro em bruto, corda e roldana; pedra mais clara, fio de cobre e orifícios alinhados na parede | ⬜ |

**Marcos e descansos**

| Tipo | Nome | Descrição visual | Fatia 1? |
|---|---|---|---|
| Marco | Guindaste de Pedra | pilar de granito com 22 m, braço de madeira e roda dentada de ferro em bruto sobre o abismo | ⬜ |
| Marco | Veio Rubro | fenda mineral com 30 m de comprimento, ferro vermelho exposto e pó ocre suspenso | ⬜ |
| Marco | Cabeça do Labirinto | fachada de granito talhada como focinho de touro com 14 m, uma narina serve de entrada | ⬜ |
| Descanso | Descanso 1 de Fojo | granito, ferro em bruto, corda e roldana; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ⬜ |
| Descanso | Descanso 2 de Fojo | granito, ferro em bruto, corda e roldana; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ⬜ |
| Descanso | Descanso antes do guardião de Fojo | granito, ferro em bruto, corda e roldana; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ⬜ |

### 3.5 Costa Quebrada

**Orçamento de travessia:** 11 min — Praia → casco inclinado → terraço de azinhavre → escada do farol → promontório do guardião. **Curva:** 15 comuns · 4 elites · 3 nomeados · 1 subchefe · descanso · 1 guardião.

| Peça | Função | Descrição visual | Fatia 1? |
|---|---|---|---|
| Círculo horizontal — **Ronda do Farol** | terraço abrigado que volta do farol ao casco; abre por dentro; volta em 51 s | caminho de basalto com 3 m entre parede molhada e parapeito de bronze coberto de azinhavre | ⬜ |
| Círculo vertical — **Círculo vertical de Costa Quebrada** | guincho de carga usa a quilha do navio como contrapeso; 34 m; abre por dentro | gaiola de convés com tábuas salgadas, aro de bronze verde e corrente presa ao mastro quebrado | ⬜ |
| Atalho — **Guincho da Quilha** | promontório → praia, repetição em 49 s; abre por dentro e persiste | plataforma de madeira de naufrágio com travão de bronze, libertado apenas junto ao farol | ⬜ |
| Dungeon — **Porão ao Contrário** | escotilha no casco do Navio Vertical; 2 pistas; 4 salas + guardião | escotilha quadrada de bronze verde num casco vertical, corda salgada e cracas a formar um aro | ⬜ |
| Ameaça — **rajada de falésia** | faixa exposta recebe empurrão máximo de 1,5 m após assobio de 1 s; saída: baixar-se atrás de quebra-ventos ou sair da faixa marcada | madeira de naufragio, bronze verde de azinhavre, sal; fitas de vela, chuva inclinada e espuma movem-se antes da força | ⬜ |

**Marcos e descansos**

| Tipo | Nome | Descrição visual | Fatia 1? |
|---|---|---|---|
| Marco | Navio Vertical | proa de madeira de naufrágio com 28 m cravada no basalto, mastros horizontais cobertos de corda | ⬜ |
| Marco | Farol Cego | torre de basalto com 34 m, cúpula partida e lentes verdes espalhadas pela encosta | ⬜ |
| Marco | Três Dentes | três agulhas de basalto no mar, cada uma com correntes de bronze verde presas ao topo | ⬜ |
| Descanso | Descanso 1 de Costa Quebrada | madeira de naufragio, bronze verde de azinhavre, sal; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ⬜ |
| Descanso | Descanso antes do guardião de Costa Quebrada | madeira de naufragio, bronze verde de azinhavre, sal; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ⬜ |

### 3.6 Cimeira

**Orçamento de travessia:** 10 min — Abrigo baixo → escadaria → ponte de gelo → vigia intermédia → observatório do guardião. **Curva:** 14 comuns · 3 elites · 2 nomeados · 1 subchefe · descanso · 1 guardião.

| Peça | Função | Descrição visual | Fatia 1? |
|---|---|---|---|
| Círculo horizontal — **Varanda das Nuvens** | cornija larga que regressa do observatório ao abrigo; abre por dentro; volta em 46 s | varanda de pedra branca com 3 m, parapeito de aço frio e nuvens abaixo do chão | ⬜ |
| Círculo vertical — **Círculo vertical de Cimeira** | elevador de vigia dentro da Agulha Azul; 48 m; abre por dentro | cabina octogonal de aço frio e pele branca, suspensa numa fissura de gelo-azul iluminada | ⬜ |
| Atalho — **Ascensor da Agulha** | observatório → abrigo baixo, repetição em 55 s; abre por dentro e persiste | porta de aço frio sem puxador no piso baixo, alavanca azul apenas na estação superior | ⬜ |
| Dungeon — **Sala do Horizonte** | porta sob o Observatório Partido; 2 pistas; 4 salas + guardião | porta circular de aço frio com 4 m, vidro azul rachado e marcas de luvas na face interior | ⬜ |
| Ameaça — **frio de exposição** | após 25 s sem abrigo, stamina máxima perde 5% a cada 20 s até ao tecto de 25%; saída: entrar num abrigo; recupera 10% por segundo junto a uma fogueira | aco temperado a frio, pele de cabra-das-neves, gelo-azul; vinheta de gelo cresce em cinco marcas e a respiração ganha equivalente visual branco | ⬜ |

**Marcos e descansos**

| Tipo | Nome | Descrição visual | Fatia 1? |
|---|---|---|---|
| Marco | Agulha Azul | obelisco de gelo-azul com 31 m, translúcido e preso por três correntes de aço frio | ⬜ |
| Marco | Observatório Partido | cúpula de pedra branca com 26 m, metade aberta ao céu e telescópio virado para a Raiz | ⬜ |
| Marco | Cabra de Pedra | estátua de granito branco com 18 m, cornos cobertos de bandeiras azuis rasgadas | ⬜ |
| Descanso | Descanso 1 de Cimeira | aco temperado a frio, pele de cabra-das-neves, gelo-azul; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ⬜ |
| Descanso | Descanso 2 de Cimeira | aco temperado a frio, pele de cabra-das-neves, gelo-azul; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ⬜ |
| Descanso | Descanso antes do guardião de Cimeira | aco temperado a frio, pele de cabra-das-neves, gelo-azul; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ⬜ |

### 3.7 Fornalha

**Orçamento de travessia:** 10 min — Pátio de escória → forjas gémeas → ponte de obsidiana → chaminé → cratera do guardião. **Curva:** 17 comuns · 5 elites · 2 nomeados · 1 subchefe · descanso · 1 guardião.

| Peça | Função | Descrição visual | Fatia 1? |
|---|---|---|---|
| Círculo horizontal — **Coroa da Bigorna** | galeria exterior em redor das forjas até ao pátio; abre por dentro; volta em 46 s | passadiço de placas de obsidiana com 4 m, rebites de bronze e calhas de lava cobertas | ⬜ |
| Círculo vertical — **Círculo vertical de Fornalha** | elevador de cadinhos sobe pelo interior da chaminé activa; 32 m; abre por dentro | cesto de bronze fundido com 5 m, placas de obsidiana e correntes negras sem partes móveis simuladas | ⬜ |
| Atalho — **Cadinho de Regresso** | cratera → pátio de escória, repetição em 57 s; abre por dentro e persiste | elevador de cadinho com trinco cerâmico acessível só no anel superior das forjas | ⬜ |
| Dungeon — **Forja Sem Ferreiro** | conduta por baixo do Martelo Imóvel; 2 pistas; 4 salas + guardião | alçapão de bronze quadrado com 3 m, borda de obsidiana lascada e calor ondulante visível | ⬜ |
| Ameaça — **crosta rubra** | crosta marcada cede 1 s depois e deixa cair 4 m numa calha lateral, nunca no vazio; saída: sair da placa ou aceitar o atalho de queda sobrevivível | obsidiana, bronze fundido, couro curtido; vermelho pulsante, fissuras concêntricas e pó a subir antes da quebra | ⬜ |

**Marcos e descansos**

| Tipo | Nome | Descrição visual | Fatia 1? |
|---|---|---|---|
| Marco | Martelo Imóvel | martelo de forja em bronze com 20 m, suspenso sobre uma bigorna de obsidiana partida | ⬜ |
| Marco | Sete Chaminés | fileira de torres negras com 35 m, seis apagadas e uma a lançar fumo laranja | ⬜ |
| Marco | Rio Preso | canal de lava com 12 m de largura congelado por comportas de bronze fundido | ⬜ |
| Descanso | Descanso 1 de Fornalha | obsidiana, bronze fundido, couro curtido; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ⬜ |
| Descanso | Descanso antes do guardião de Fornalha | obsidiana, bronze fundido, couro curtido; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ⬜ |

### 3.8 Fulgor

**Orçamento de travessia:** 9 min — Marco de terra → campo rachado → bosque de vidro → espiral das torres → olho do guardião. **Curva:** 16 comuns · 4 elites · 3 nomeados · 1 subchefe · descanso · 1 guardião.

| Peça | Função | Descrição visual | Fatia 1? |
|---|---|---|---|
| Círculo horizontal — **Anel das Correntes** | trilho aterrado à volta das torres até ao marco inicial; abre por dentro; volta em 41 s | caminho de pedra escura com 4 m, correntes enterradas e fragmentos de fulgurite fora da faixa | ⬜ |
| Círculo vertical — **Círculo vertical de Fulgor** | espiral de rampas entre torres de vidro ligadas; 36 m; abre por dentro | rampa helicoidal de pedra seca com 4 m, guarda de osso e fulgurite a brilhar do lado exterior | ⬜ |
| Atalho — **Pára-Raios Tombado** | olho → Marco de terra, repetição em 46 s; abre por dentro e persiste | torre de fulgurite inclinada que vira ponte quando a corrente interior é libertada no topo | ⬜ |
| Dungeon — **Câmara do Nono Raio** | fenda sob a Pedra Aterrada; 2 pistas; 4 salas + guardião | abertura triangular no granito com 3 m, correntes negras, vidro violeta e areia fundida no limiar | ⬜ |
| Ameaça — **queda de relâmpago** | o impacto ocorre 1 s depois de um círculo de 3 m acender no chão; saída: sair do círculo ou ficar sobre a Pedra Aterrada | fulgurite, couro seco, osso polido pelo vento; fissuras violetas convergem, poeira levanta e a silhueta do jogador ganha contorno branco | ⬜ |

**Marcos e descansos**

| Tipo | Nome | Descrição visual | Fatia 1? |
|---|---|---|---|
| Marco | Árvore de Vidro | fulgurite ramificada com 24 m, centenas de pontas violetas fundidas num único impacto | ⬜ |
| Marco | Pedra Aterrada | monólito de granito com 15 m coberto por correntes que desaparecem no chão seco | ⬜ |
| Marco | Olho Baixo | anel de nuvens violeta visível a 36 m de altura, centrado numa torre de vidro torcida | ⬜ |
| Descanso | Descanso 1 de Fulgor | fulgurite, couro seco, osso polido pelo vento; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ⬜ |
| Descanso | Descanso 2 de Fulgor | fulgurite, couro seco, osso polido pelo vento; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ⬜ |
| Descanso | Descanso antes do guardião de Fulgor | fulgurite, couro seco, osso polido pelo vento; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ⬜ |

### 3.9 Raizama

**Orçamento de travessia:** 11 min — Costela aberta → lago de esporos → ponte de raiz → cogumelos-torre → crânio do guardião. **Curva:** 15 comuns · 4 elites · 2 nomeados · 1 subchefe · descanso · 1 guardião.

| Peça | Função | Descrição visual | Fatia 1? |
|---|---|---|---|
| Círculo horizontal — **Círculo das Costelas** | passagem exterior que liga o crânio à costela aberta; abre por dentro; volta em 51 s | ponte de raízes entre arcos de osso, 4 m de largura, seda presa como guarda e esporos por baixo | ⬜ |
| Círculo vertical — **Círculo vertical de Raizama** | elevador de seda entre a carcaça e as copas; 43 m; abre por dentro | plataforma de quitina com 5 m presa por oito fios de seda, guiada dentro de um tronco oco | ⬜ |
| Atalho — **Fio do Crânio** | crânio → Costela-Mãe, repetição em 59 s; abre por dentro e persiste | elevador de seda enrolado numa mandíbula gigante, comando de quitina apenas no topo | ⬜ |
| Dungeon — **Medula Oca** | fissura dentro da Costela-Mãe; 2 pistas; 4 salas + guardião | fenda vertical de 3 m em osso antigo, borda coberta de quitina e luz ciano a respirar | ⬜ |
| Ameaça — **nuvem de esporos** | atravessar acumula veneno a 35 por segundo; fora da nuvem decai 20 por segundo; saída: rebentar o saco à distância ou esperar a nuvem baixar | quitina, madeira-cogumelo, seda de teia; volume ciano opaco com partículas a correr para cima e barra visível | ⬜ |

**Marcos e descansos**

| Tipo | Nome | Descrição visual | Fatia 1? |
|---|---|---|---|
| Marco | Costela-Mãe | arco de osso antigo com 38 m coberto por raízes e cogumelos ciano | ⬜ |
| Marco | Lago de Luz | bacia circular com 45 m cheia de esporos luminosos, sem água visível | ⬜ |
| Marco | Crânio-Catedral | crânio pétreo com 50 m, órbitas ocupadas por torres de cogumelo e teias | ⬜ |
| Descanso | Descanso 1 de Raizama | quitina, madeira-cogumelo, seda de teia; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ⬜ |
| Descanso | Descanso antes do guardião de Raizama | quitina, madeira-cogumelo, seda de teia; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ⬜ |

### 3.10 Cidade Afogada

**Orçamento de travessia:** 10 min — Cais de mármore → mercado raso → aqueduto → telhados → torre do guardião. **Curva:** 18 comuns · 5 elites · 2 nomeados · 1 subchefe · descanso · 1 guardião.

| Peça | Função | Descrição visual | Fatia 1? |
|---|---|---|---|
| Círculo horizontal — **Ronda dos Telhados** | passarela seca que regressa da torre ao cais; abre por dentro; volta em 46 s | telhados de mármore ligados por pranchas de 4 m, corrimão de prata e vidro verde nas juntas | ⬜ |
| Círculo vertical — **Círculo vertical de Cidade Afogada** | contrapeso do sino move uma plataforma entre praça e campanário; 31 m; abre por dentro | plataforma de mármore de 5 m suspensa por corrente de prata, água a cair das quatro bordas | ⬜ |
| Atalho — **Ascensor do Sino** | torre → cais, repetição em 51 s; abre por dentro e persiste | plataforma do campanário com alavanca de prata no piso superior e contrapeso visível sob a água | ⬜ |
| Dungeon — **Arquivo Submerso** | porta seca sob o Aqueduto Quebrado; 2 pistas; 4 salas + guardião | porta de mármore azul com 4 m, moldura de prata escurecida e vidro verde intacto no centro | ⬜ |
| Ameaça — **água profunda** | a rota principal usa passadiços; zonas opcionais fundas desactivam ataque e esquiva enquanto se nada; saída: ficar nos aquedutos; natação não é necessária para chegar ao guardião | marmore afogado, prata escurecida, vidro; mudança do mármore claro para mosaico azul e silhuetas visíveis sob a água | ⬜ |

**Marcos e descansos**

| Tipo | Nome | Descrição visual | Fatia 1? |
|---|---|---|---|
| Marco | Sino à Tona | campanário de mármore com 31 m, metade submerso, sino de prata escurecida acima da água | ⬜ |
| Marco | Praça do Espelho | praça circular com 40 m sob água verde-clara, mosaico visível inteiro da cobertura | ⬜ |
| Marco | Aqueduto Quebrado | arcada de mármore com 120 m, três vãos caídos e cascatas finas sobre os telhados | ⬜ |
| Descanso | Descanso 1 de Cidade Afogada | marmore afogado, prata escurecida, vidro; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ⬜ |
| Descanso | Descanso 2 de Cidade Afogada | marmore afogado, prata escurecida, vidro; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ⬜ |
| Descanso | Descanso antes do guardião de Cidade Afogada | marmore afogado, prata escurecida, vidro; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ⬜ |

### 3.11 Santuario Branco

**Orçamento de travessia:** 9 min — Pórtico baço → pátio → nave sem sombra → claustro → coro do guardião. **Curva:** 17 comuns · 4 elites · 3 nomeados · 1 subchefe · descanso · 1 guardião.

| Peça | Função | Descrição visual | Fatia 1? |
|---|---|---|---|
| Círculo horizontal — **Claustro do Avesso** | corredor exterior que volta do coro ao pórtico; abre por dentro; volta em 41 s | claustro de mármore branco com 4 m, colunas douradas e sombras negras apontadas contra a luz | ⬜ |
| Círculo vertical — **Círculo vertical de Santuario Branco** | elevador de altar sobe pela nave atrás do Sol de Mármore; 27 m; abre por dentro | plataforma branca de 5 m coberta por cera, guiada por correntes de ouro baço dentro da parede | ⬜ |
| Atalho — **Altar Ascendente** | coro → pórtico, repetição em 43 s; abre por dentro e persiste | altar quadrado de mármore que desce quando a vela vermelha do coro é apagada pelo lado interior | ⬜ |
| Dungeon — **Sacristia Sem Olhos** | porta atrás da Sombra Vertical; 2 pistas; 4 salas + guardião | porta estreita de mármore com 3 m, dez relevos sem olhos e uma linha de sangue seco na soleira | ⬜ |
| Ameaça — **luz cegante** | encarar um foco marcado acumula 25 por segundo após 0,8 s; a barra cheia cega durante 3 s; saída: olhar para baixo, quebrar visão numa coluna ou entrar na sombra | marmore branco, ouro baco, cera; padrão radial no chão, sobre-exposição gradual e borda negra fora do foco | ⬜ |

**Marcos e descansos**

| Tipo | Nome | Descrição visual | Fatia 1? |
|---|---|---|---|
| Marco | Sol de Mármore | disco de mármore branco com 21 m suspenso por vigas douradas sobre a nave | ⬜ |
| Marco | Mil Velas | escadaria com 70 m coberta por velas de cera benta, todas da mesma altura e ainda acesas | ⬜ |
| Marco | Sombra Vertical | faixa negra com 27 m numa parede branca, recta apesar das colunas e da luz em redor | ⬜ |
| Descanso | Descanso 1 de Santuario Branco | marmore branco, ouro baco, cera; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ⬜ |
| Descanso | Descanso antes do guardião de Santuario Branco | marmore branco, ouro baco, cera; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ⬜ |

### 3.12 A Raiz

**Orçamento de travessia:** 12 min — Foz invertida → floresta de raízes → ponte negra → espiral da bruma → lábio do guardião. **Curva:** 20 comuns · 5 elites · 2 nomeados · 1 subchefe · descanso · 1 guardião.

| Peça | Função | Descrição visual | Fatia 1? |
|---|---|---|---|
| Círculo horizontal — **Anel da Foz** | ponte exterior que devolve o lábio ao rio ascendente; abre por dentro; volta em 56 s | passagem de raiz petrificada com 5 m, placas de prata baça e bruma a correr para cima dos dois lados | ⬜ |
| Círculo vertical — **Círculo vertical de A Raiz** | espiral interior da Raiz-Torre com três patamares; 52 m; abre por dentro | escada helicoidal talhada em raiz negra, 5 m de largura, prata baça nas bordas e poço de bruma ao centro | ⬜ |
| Atalho — **Queda Invertida** | lábio → Foz invertida, repetição em 60 s; abre por dentro e persiste | plataforma de raiz que desce contra o fluxo da bruma quando o selo de prata no topo é quebrado | ⬜ |
| Dungeon — **Câmara da Primeira Fenda** | abertura por trás do Rio Ascendente; 2 pistas; 4 salas + guardião | fenda rectangular de 5 m em pedra negra, moldura de prata baça e bruma pálida a contornar o vazio | ⬜ |
| Ameaça — **escuro absoluto** | fora dos focos de bruma a visibilidade cai para 6 m; a lanterna ocupa a mão esquerda; saída: usar a lanterna, caminhar junto ao rio ou trocar defesa por visão | pedra negra, raiz petrificada, prata baca; silhuetas brancas nas bordas, reflectores de prata no caminho e olhos do parceiro realçados | ⬜ |

**Marcos e descansos**

| Tipo | Nome | Descrição visual | Fatia 1? |
|---|---|---|---|
| Marco | Rio Ascendente | curso de bruma pálida com 20 m de largura que sobe em cascata para o tecto negro | ⬜ |
| Marco | Raiz-Torre | raiz petrificada com 52 m, oca ao centro e cercada por plataformas de prata baça | ⬜ |
| Marco | Lábio do Portão | arco de pedra negra com 30 m, selado por bruma violeta e raízes partidas para fora | ⬜ |
| Descanso | Descanso 1 de A Raiz | pedra negra, raiz petrificada, prata baca; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ⬜ |
| Descanso | Descanso 2 de A Raiz | pedra negra, raiz petrificada, prata baca; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ⬜ |
| Descanso | Descanso antes do guardião de A Raiz | pedra negra, raiz petrificada, prata baca; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte | ⬜ |

---

## 4. ⭐ As 30 portas de história

São **2–3 por bioma**, ficam deliberadamente sem construir e nenhuma parece bug: cada uma tem um testemunho de cenário que explica por que não abre ou por que o nome está vazio. São reservas, não promessas de data. A Fatia 1 continua sem história, como manda o [`10`](10-fatia-1.md).

| # | Bioma | Porta / forma | O que existe hoje e por que se lê | Reserva futura | Descrição visual | Fatia 1? |
|---:|---|---|---|---|---|---|
| 1 | Brumal | **Porta dos Sete Ferrolhos** · porta_selada | uma laje sob raízes tem sete linguetas de ferro sem fechadura; **razão:** sete riscos no arco e uma chave sem dentes gravada numa pedra próxima | dungeon sob Brumal | laje de granito com 4 m apertada por raízes negras, sete ferrolhos de ferro rude e musgo intacto | ⬜ |
| 2 | Brumal | **Torre dos Corvos** · torre_desabada | a metade superior vê-se para lá da borda de bruma, sem caminho até ela; **razão:** corvos voam entre a Árvore Morta e a torre, sempre com palha no bico | zona vertical de vigia | torre de granito partida com 18 m para lá de bruma cinzenta, varas de ferro e ninhos negros no topo | ⬜ |
| 3 | Brumal | **Nhal, Rei sem Bruma** · nome_sem_dono | o nome está riscado em três pedras, mas nenhuma figura o representa; **razão:** as três inscrições repetem uma coroa antes de a bruma subir | chefe futuro | três estelas de granito cobertas de musgo, cada uma com o mesmo nome e uma coroa vazia talhada | ⬜ |
| 4 | Selva Funda | **Casulo da Matriarca** · porta_selada | um casulo de pedra e seda não reage a fogo nem golpe; **razão:** Tecelões deixam oferendas frescas diante da costura central | dungeon de ninhada | casulo de granito verde com 7 m envolto em seda crua, costura vertical de quitina e flores magenta | ⬜ |
| 5 | Selva Funda | **A Copa Sem Tronco** · torre_desabada | uma aldeia suspensa aparece acima das copas sem qualquer árvore por baixo; **razão:** pontes cortadas apontam para ela e uma roldana continua a girar | zona de copa superior | grupo de cabanas de vime a 55 m, suspensas por fios de seda no vazio verde entre feixes de luz | ⬜ |
| 6 | Selva Funda | **Iria das Oito Mãos** · nome_sem_dono | o nome surge em nós de seda que nenhum Tecelão actual usa; **razão:** oito padrões idênticos aparecem nas guardas das pontes mais antigas | chefe tecelão futuro | oito faixas de seda branca trançadas numa árvore negra, cada uma com o mesmo nó espiral | ⬜ |
| 7 | Campas Cinzentas | **Cripta do Último Estandarte** · porta_selada | uma porta de osso não abre e os mortos ajoelham-se virados para ela; **razão:** o estandarte cinzento preso na moldura nunca apodrece | dungeon militar | porta de osso com 5 m entre lápides afundadas, pano cinzento seco e fechos de ferro ferrugento | ⬜ |
| 8 | Campas Cinzentas | **Campanário Caído** · torre_desabada | um sino toca debaixo do lodo onde só a ponta da torre é visível; **razão:** ondas circulares aparecem sem vento a cada toque | torre subterrânea | agulha de campanário em pedra cinzenta a sair 3 m do lodo, sino verde visível numa fenda | ⬜ |
| 9 | Campas Cinzentas | **General Sem Estandarte** · nome_sem_dono | ordens gravadas acabam sempre antes do nome do comandante; **razão:** um elmo sem brasão ocupa sozinho uma mesa de pedra seca | chefe morto-vivo futuro | mesa de pedra sobre água cinzenta com um elmo ferrugento sem brasão e doze lanças apontadas para ele | ⬜ |
| 10 | Fojo | **Face de Bronze** · porta_selada | uma cara metálica fecha o túnel e sopra poeira pelas narinas; **razão:** marcas kobold avisam para não responder quando ela pergunta | labirinto falante | rosto de bronze com 6 m encaixado no granito, olhos vazios, dentes quadrados e pó ocre nas narinas | ⬜ |
| 11 | Fojo | **Poço da Décima Mina** · passagem_tapada | carris terminam num desabamento numerado dez, embora só existam nove galerias; **razão:** vagonetas vazias chegam viradas para o desabamento após cada descanso | mina adicional | túnel de granito tapado por blocos, carris de ferro bruto entram nos escombros e o número X está pintado a ferrugem | ⬜ |
| 12 | Fojo | **O Escultor do Touro** · nome_sem_dono | a assinatura repete-se em estátuas anteriores à chegada dos kobolds; **razão:** ferramentas grandes demais permanecem alinhadas junto à Cabeça do Labirinto | chefe construtor futuro | cinzéis de ferro com 2 m encostados a uma cabeça de touro inacabada em granito ocre | ⬜ |
| 13 | Costa Quebrada | **Farol Cego** · porta_selada | a porta verde do farol não tem abertura exterior; **razão:** uma lente intacta projecta à noite a imagem de uma chave partida | dungeon do farol | porta arqueada de bronze com azinhavre, 4 m, no basalto molhado, sem puxador e com lente verde por cima | ⬜ |
| 14 | Costa Quebrada | **Quarto Mastro** · torre_desabada | três mastros estão nos destroços; um quarto ergue-se numa agulha sem acesso; **razão:** cordas tensas ligam-no aos navios sempre que sopra vento de oeste | ilha de naufrágio | mastro salgado com 26 m sobre agulha de basalto, velas rasgadas e cordas esticadas sobre espuma branca | ⬜ |
| 15 | Costa Quebrada | **Almirante sem Corpo** · nome_sem_dono | o título aparece em sinos de três navios, mas nenhum registo tem nome; **razão:** cada sino traz a mesma mão de bronze de seis dedos | chefe naval futuro | três sinos de bronze verde alinhados na praia, cada um gravado com uma mão de seis dedos | ⬜ |
| 16 | Cimeira | **Observatório Interior** · porta_selada | o telescópio aponta para uma cúpula fechada dentro da montanha; **razão:** mapas riscados mostram uma segunda abóbada por baixo da visível | dungeon astronómica | porta circular de aço frio com 5 m sob gelo azul, constelações perfuradas e neve sem pegadas | ⬜ |
| 17 | Cimeira | **Torre Além das Nuvens** · torre_desabada | uma agulha aparece só quando as nuvens abrem, sem ponte nem trilho; **razão:** correntes cortadas na Agulha Azul têm a mesma espessura das que a sustentam | torre de vigia futura | agulha de pedra branca acima das nuvens, 40 m, varanda de aço azul e corrente cortada a pender no vazio | ⬜ |
| 18 | Cimeira | **A Vigia que Não Desceu** · nome_sem_dono | um lugar à mesa recebe comida nova apesar de estar vazio; **razão:** pegadas começam na cadeira e terminam no bordo voltado para a Raiz | chefe vigia futuro | mesa de granito branco com uma tigela fumegante, cadeira vazia e pegadas na neve até ao precipício | ⬜ |
| 19 | Fornalha | **Oitava Chaminé** · passagem_tapada | uma base octogonal tapada por escória completa a fila das Sete Chaminés; **razão:** brasas respiram sob as pedras ao ritmo da chaminé activa | forja profunda | base de chaminé em obsidiana com 9 m, coberta por escória negra rachada e luz laranja nas juntas | ⬜ |
| 20 | Fornalha | **Altar do Primeiro Carvão** · altar_apagado | um cadinho frio recebe oferendas mas nunca acende; **razão:** as oferendas são ferramentas novas colocadas por mãos ausentes | pacto ou ferreiro futuro | cadinho de bronze com 2 m sobre altar de obsidiana, carvão branco intacto e tenazes alinhadas | ⬜ |
| 21 | Fulgor | **Galeria de Vidro Negro** · passagem_tapada | um túnel vitrificado termina numa parede transparente com movimento atrás; **razão:** relâmpagos percorrem a parede mas desviam-se de uma junta em forma de porta | dungeon da tempestade | parede de vidro negro com 6 m, relâmpagos violetas ramificados e silhuetas distantes por trás | ⬜ |
| 22 | Fulgor | **Pastor do Nono Raio** · nome_sem_dono | oito torres têm dono gravado; a nona traz apenas este título; **razão:** pegadas de casco rodeiam a torre e nunca saem do círculo | chefe minotauro futuro | nona torre de fulgurite torcida, círculo de pegadas de casco na poeira e título gravado em osso polido | ⬜ |
| 23 | Raizama | **Túnel da Seda Negra** · porta_selada | uma membrana escura pulsa numa raiz onde os esporos não pousam; **razão:** Tecelões cortam todos os fios que se aproximam da membrana | colónia profunda | membrana oval negra com 5 m entre raízes, aro de quitina, fios de seda cortados e nenhum esporo ciano | ⬜ |
| 24 | Raizama | **Altar da Carcaça** · altar_apagado | um altar de osso tem espaço para um órgão que já não está; **razão:** raízes crescem para o vazio central e param a um palmo dele | pacto da criatura morta | altar de costelas brancas com cavidade de 2 m, raízes húmidas suspensas e cogumelos apagados | ⬜ |
| 25 | Cidade Afogada | **Sino Debaixo da Praça** · torre_desabada | um campanário inteiro é visível sob o mosaico rachado da praça; **razão:** o sino toca e levanta bolhas sem mover a superfície | bairro submerso | campanário de mármore invertido sob água verde, sino de prata e mosaico circular rachado por cima | ⬜ |
| 26 | Cidade Afogada | **Sineira sem Voz** · nome_sem_dono | o nome está em partituras impermeáveis, mas falta sempre a linha da voz; **razão:** os sinos respondem quando as páginas são aproximadas da água | chefe ou NPC futuro | estante de prata à tona com partituras de vidro, pauta vazia e campanários reflectidos na água | ⬜ |
| 27 | Santuario Branco | **Porta da Cera Fria** · porta_selada | uma porta inteiramente coberta de cera não derrete junto das velas; **razão:** mãos impressas na cera apontam todas para fora | cripta penitente | porta de mármore com 5 m sob camada grossa de cera branca, dezenas de mãos fundas e ouro baço na moldura | ⬜ |
| 28 | Santuario Branco | **Altar da Sombra Ausente** · altar_apagado | mil velas iluminam o altar mas ele não projecta sombra; **razão:** um recipiente vazio tem a forma exacta de uma chama negra | pacto de sombra futuro | altar branco com 3 m cercado por velas, recipiente de ouro vazio e chão sem qualquer sombra | ⬜ |
| 29 | A Raiz | **Passagem da Raiz Cortada** · passagem_tapada | uma raiz-torre foi serrada e empilhada para fechar um arco antigo; **razão:** serradura negra continua fresca e a bruma evita os blocos | ligação a bioma futuro | arco de pedra negra com 8 m tapado por secções de raiz petrificada, cortes claros e prata baça nas fendas | ⬜ |
| 30 | A Raiz | **Primeiro Sem-Rosto** · nome_sem_dono | o nome está escrito onde devia existir um rosto numa estátua lisa; **razão:** doze máscaras de outras raças olham para a estátua a partir do chão | chefe primordial futuro | estátua de pedra negra com 10 m e face lisa, cercada por doze máscaras de osso e rios de bruma ascendente | ⬜ |

---

## 5. Densidade antes de expansão

Uma zona só entra numa build pública quando tem: travessia cronometrada em 8–12 min; 12–20 comuns, 3–5 elites, 2–3 nomeados, subchefe e guardião colocados; 2–3 descansos; dungeon com duas pistas; círculos horizontal e vertical; atalho aberto por dentro; fuga contínua; garganta medida; e orçamento quente ≤ 2,5 GB. Falhar um item bloqueia a zona seguinte — conteúdo denso antes de hectares.

Quedas de **até 4 m** podem servir de atalho; nenhuma rota pede salto de 20 m. Bordos letais seguem os quatro sinais do [`61`](61-arenas-de-chefe.md) §5. As rotas principais usam chão, escada, rampa ou elevador: não dependem de escalar, saltar ou nadar, cujos detalhes não são decididos aqui.

---

## 6. As quatro perguntas do fio solto

### 1. Como é que o jogador usa isto?

Entra por qualquer ligação sem teste de nível, lê um marco vertical, enfrenta a curva que sobe e desce, abre por dentro os dois círculos e o atalho, encontra a dungeon pelas duas pistas e regressa ao descanso em menos de 60 s. O mapa só desenha esse caminho depois de o jogador o pisar.

### 2. Como é que se prova que funciona?

Por zona: 5 corridas limpas em 1.ª e 3.ª pessoa dentro de 8–12 min; cada marco reconhecido a 40 m por 8/10 jogadores; 10 aberturas de cada atalho apenas pelo interior; 10 regressos < 60 s; duas pistas de dungeon encontradas sem marcador por 7/10; fuga do subchefe em 10/10 tentativas; mapa sem revelar uma célula não pisada. A rede inteira tem 12 nós ligados, grau mínimo 2 e prova de ponta-a-ponta de ~30 min.

### 3. De onde vêm a arte e o som?

Os 12 conceitos de bioma já estão arquivados no [`art/MANIFESTO.md`](../art/MANIFESTO.md). Brumal reutiliza `brumal-vista`, `brumal-caminho` e `toca-entrada`; logo não nasce imagem nova da Fatia 1 neste bloco. Cada entidade visual conserva descrição específica e `Fatia 1?` para a geração posterior. Materiais herdam do [`49`](49-biomas.md); ambientes, sinais e ducking herdam do [`65`](65-musica-e-ambiente.md) e do [`62`](62-acessibilidade-auditiva.md).

### 4. Quanto custa na máquina do Rico?

Uma zona e vizinhas imediatas, tecto total de 2,5 GB; gargantas seguram o jogador até ambas as máquinas confirmarem; elevadores são animações pré-feitas, não corpos rígidos; marcos usam kits modulares por bioma; portas futuras são malha estática e zero lógica. Falha de orçamento corta decoração e partículas, nunca rota, marco ou telegrafia.

---

## 7. O que continua aberto sem ser decidido aqui

- **Mapa por zona ou do mundo inteiro** e se nomes de bioma não visitados aparecem — pergunta 38, donos.
- ~~**Nadar, escalar e saltar**~~: ✅ não existem como verbos livres; água é perigo/fundo caminhável e toda a verticalidade usa ligações autoradas, segundo o [`73`](73-fecho-dos-buracos-de-integracao.md) §2.
- **Conteúdo das reservas futuras:** as 30 portas declaram forma e razão, não data nem obrigação de as preencher.
- Nomes definitivos de zonas, dungeons e sementes de história continuam sujeitos à gravação narrativa; IDs técnicos ficam estáveis.

## Ligações

[`17-mundo.md`](17-mundo.md) · [`36-fisica.md`](36-fisica.md) · [`39-estudo-profundo.md`](39-estudo-profundo.md) · [`43-estudo-espolio-inventario-mundo.md`](43-estudo-espolio-inventario-mundo.md) · [`49-biomas.md`](49-biomas.md) · [`53-chefes-ritmo-e-o-mago-forte.md`](53-chefes-ritmo-e-o-mago-forte.md) · [`57-mapa-e-minimapa.md`](57-mapa-e-minimapa.md) · [`61-arenas-de-chefe.md`](61-arenas-de-chefe.md) · [`game/data/world.json`](../game/data/world.json)
