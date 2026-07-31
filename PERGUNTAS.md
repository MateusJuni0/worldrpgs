# Perguntas que NAO decidi

Coisas grandes que apareceram a construir e que **nao sao minhas para decidir**.
Contornei cada uma para o prototipo andar, e deixo aqui o que fica em cima da mesa.

As pequenas, que decidi, estao em [DECISOES-PROTOTIPO.md](DECISOES-PROTOTIPO.md).

---

## P1 · A engine continua `[EM ABERTO]` na spec

`spec/09-tecnico.md` poe a engine como `[EM ABERTO]` e manda o **WP13** compara-las com um criterio explicito: *"o que e que cada engine consegue mesmo entregar sem GPU dedicada"*.

**Essa comparacao nunca foi feita.** Construi em Godot 4.7.1 por instrucao directa, nao por conclusao de uma analise.

**O que o prototipo acrescenta a decisao:** ha agora um dado real em vez de palpite — Godot 4.7 entrega, nesta Iris Xe, 412 fps medios a 1080p com a cena do marco 1. Nao prova que Godot e a melhor escolha; prova que **e uma escolha suficiente**. Se o WP13 se fizer, ja tem um numero contra o qual medir as alternativas.

**Contornado:** construi na engine que me foi indicada, e deixo o numero registado em [PERF.md](PERF.md).

---

## P2 · Falta uma tecla para lancar magia na tabela de comandos

`spec/01-combate.md` lista "Magia seguinte: F" mas **nao tem accao para conjurar**. Com o mapa da spec a letra, um Feiticeiro cicla magias e nunca lanca nenhuma.

E um buraco numa tabela `[FABLE]`, nao uma tensao — mas mexe na tabela de comandos, que e do WP1B/WP11.

**Contornado:** `C` conjura (D4). Uma linha em `data/controls.json` muda isso.

---

## P3 · A spec contradiz-se sobre o cajado

Em `spec/01-combate.md`, na mesma seccao:

- tabela de bloqueio: *"Machadao / cajado (duas maos) nao bloqueiam"*
- regras transversais: *"machadao e cajado ocupam as duas; adaga/espada/**cajado** combinam com escudo na outra"*

O cajado nao pode ocupar as duas maos **e** combinar com escudo.

**Contornado:** segui a tabela — cajado a duas maos, sem escudo (D9). Se a intencao era Feiticeiro com escudo, muda-se `hands` em `data/weapons.json` e o bloqueio passa a funcionar-lhe.

---

## P4 · Rede e co-op (WP10)

Fora do escopo desta noite por instrucao, e `[EM ABERTO]` na spec — incluindo a pergunta que magoa: **quem tem autoridade sobre o combate, cliente ou servidor**.

Deixei o caminho aberto: o `x1,8` de vida do Vorgar em co-op ja esta nos dados (`coop_health_multiplier`), e o `Enemy.setup()` aceita a bandeira. Nada mais foi construido, e nao construi nada que assuma um modelo de rede.

**Nota para quem pegar nisto:** a spec avisa que decidir a autoridade tarde da "golpes que parecem acertar e nao acertam". O combate esta todo em `_physics_process` deterministico a 60 Hz, o que ajuda — mas nao substitui a decisao.

---

## P5 · Pergunta 10 da spec — o que se perde ao morrer

Continua deles. E a decisao de **tom** do jogo inteiro.

**Contornado:** a fatia diz "nao se perde nada" e e isso que esta implementado — vida, stamina e cargas restauradas, chefe em reset total, nova tentativa em ~1,2 s. O provisorio da fatia, nao uma resposta a pergunta 10.

---

## P6 · Pergunta 7 — como se recupera vida

Nao ha item de cura, nem magia de cura, nem descanso. **Nao ha nenhuma forma de recuperar vida sem morrer.**

Isto muda o valor real dos 420 PV mais do que qualquer numero do WP2: com cura, 420 PV sao uma corrida de fundo; sem cura, sao 4 golpes do brutamontes e acabou.

**Contornado:** morrer restaura tudo. Na pratica o prototipo joga-se como se cada tentativa fosse uma vida so — o que **e** jogavel para testar o Vorgar, mas nao e o jogo.

**E a pergunta que mais afecta o teste da fatia** (criterio 3: nivel 1, zero pontos, mata o Vorgar). Vale a pena responder antes de afinar dificuldade.

---

## P7 · Pergunta 14 — armadura

Nao existe. O rolamento nao tem classes de peso, como a spec preve enquanto nao houver armadura.

**Contornado:** um so rolamento, 0,60 s para toda a gente. Se armadura entrar, muda-se em `spec/01-combate.md` **primeiro**, como a propria spec exige.

---

## P8 · A cadencia do chefe conta como "padrao" ou como "numero"?

`spec/10-fatia-1.md`: *"a segunda fase muda padroes, nao numeros"*. Os golpes do Vorgar sao identicos nas duas fases — mesmos frames, mesmo dano. Mudei a ordem, o comprimento das cadeias **e a pausa entre cadeias** (1,7 s → 1,0 s).

A pausa e ritmo (padrao) ou e um numero? Assumi ritmo (D15). Se acharem que e numero, a fase 2 fica so com cadeias mais longas — uma linha de JSON.

---

## P9 · As seis classes ainda nao tem habilidade especial (WP3)

`spec/02-personagem.md` decide que cada classe tem uma habilidade especial, e `10-fatia-1.md` conta o preco: seis habilidades a desenhar. O WP3 nao existe.

**Contornado:** as seis classes existem so como distribuicoes de atributos e equipamento de arranque. Diferenciam-se em numeros — que e exactamente o que a **Lei 2** recusa (*"melhorias dao opcoes, nao numeros"*).

**Isto e o maior buraco de design que fica.** Com o combate a funcionar, e agora barato testar habilidades; sem elas, "outra vez, mas eu de Assassino?" — o teste verdadeiro da fatia — ainda nao tem resposta a serio.

---

## P10 · Nao ha XP nem niveis implementados

O WP2 escreve a curva (`XP = 80 + 20n`, lanceiro 25 · brutamontes 45 · Vorgar 400) e a fatia vai do nivel 1 ao 10.

**Contornado:** o jogador e sempre nivel 1 com a distribuicao da classe. Nao e perda para o que a noite tinha de responder — o criterio 3 da fatia e **precisamente** "nivel 1, zero pontos, mata o Vorgar", e e nisso que o prototipo esta. Mas quem quiser sentir a progressao ainda nao pode.
