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

## P2 · ⚠️ Os dois mapas de comandos da spec nao batem certo

Durante a noite chegou `spec/25-controlo.md` (WP1B, do lado do Mateus). Traz um esquema de comandos **incompativel** com o de `spec/01-combate.md` (WP1, do lado do Rico):

| Accao | WP1 (`01-combate.md`) | WP1B (`25-controlo.md`) |
|---|---|---|
| Parry | `Q` | **`RMB` toque** (mesma tecla do bloqueio, ≤ 150 ms) |
| Lock-on | `Tab` | **`Q`** ou botao do meio |
| Interagir | `E` | **`F`** |
| Pocao / item | `R` | **`E`** |
| Trocar arma | — | **`R`** |
| Magias | `F` cicla | **`1`/`2`/`3`** directas |
| Mochila | `1`–`5` hotbar | **`Tab`** |

Nao e um detalhe: **o parry na mesma tecla do bloqueio muda o combate**. O proprio WP1B admite o risco e diz que "tem de ser testado cedo no protótipo — se os testes mostrarem parries engolidos pelo bloqueio, separa-se o parry para tecla propria **antes** de afinar qualquer outro numero, porque contamina todos os testes da Lei 1".

**Isto e para o Mateus e o Rico resolverem** — sao dois documentos da spec a discordar, nao um buraco meu para tapar. E tambem nenhum dos dois tem tecla para **lancar** magia (o WP1 so tem "magia seguinte"; o WP1B tem magias directas em 1/2/3, o que resolve por outro caminho).

**Contornado:** o protótipo usa o mapa do **WP1** (que é o documento do combate) mais `C` para conjurar. Tudo vive em `data/controls.json` — passar para o esquema do WP1B e editar esse ficheiro, sem tocar em codigo.

**Recomendacao:** testem o parry no `RMB` toque cedo. E o unico item desta lista que pode obrigar a refazer numeros.

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

## P9 · As habilidades de classe ja estao escritas, mas ainda nao construidas

O **WP3 chegou durante a noite** (`spec/12-classes.md`) e fecha o que faltava — seis habilidades, nenhuma delas um multiplicador passivo:

| Classe | Habilidade | Custo / recarga |
|---|---|---|
| Guerreiro | **Impeto** — avanco de 6 m que termina em golpe (MV 1,2) | 30 stamina · 15 s |
| Feiticeiro | **Eco** — repete a ultima magia sem gastar carga | 60 s |
| Tanque | **Provocacao** — inimigos num raio de 8 m atacam-no 4 s | 30 s |
| Assassino | **Passo Sombra** — a proxima esquiva atravessa o inimigo; backstab MV 2,0 nos 2 s seguintes | 25 s |
| Berserker | **Furia** — 8 s de hiper-armadura, mas nao pode bloquear nem esquivar | 45 s |
| Paladino | **Julgamento** — 10 s com a arma carregada de raio | 40 s |

**As fichas de atributos ja estao implementadas** (e verificadas contra a tabela do WP3). **As habilidades nao.** Chegaram tarde de mais na noite para as construir com cuidado, e sao seis features novas, nao numeros a alinhar.

**E o que fica em primeiro lugar na lista.** Sem elas, as seis classes ainda so se distinguem por numeros — que e o que a Lei 2 recusa — e "outra vez, mas eu de Assassino?", o teste verdadeiro da fatia, continua sem resposta a serio. A boa noticia e que o combate por baixo ja aguenta: hiper-armadura, i-frames, MV por golpe e recargas sao todos mecanismos que ja existem.

---

## P10 · Nao ha XP nem niveis implementados

O WP2 escreve a curva (`XP = 80 + 20n`, lanceiro 25 · brutamontes 45 · Vorgar 400) e a fatia vai do nivel 1 ao 10.

**Contornado:** o jogador e sempre nivel 1 com a distribuicao da classe. Nao e perda para o que a noite tinha de responder — o criterio 3 da fatia e **precisamente** "nivel 1, zero pontos, mata o Vorgar", e e nisso que o prototipo esta. Mas quem quiser sentir a progressao ainda nao pode.

### P4 — Tecla da habilidade especial nao existe na spec
A tabela de comandos do WP1 (spec/01-combate.md) nao reservou tecla para a
habilidade especial de classe (WP3). O prototipo usa V [PROTO]. O WP1/WP1B
devem fechar isto — e a tecla mais usada a seguir ao ataque.
