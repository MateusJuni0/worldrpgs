# 39 — Estudo profundo: como o jogo de referência funciona por dentro

`[DECIDIDO]` (Mateus, 31-07-2026) — *"estuda o jogo completo do Dark Souls a fundo, como funciona, pra gente saber e aplicar."*

> **O que isto é.** O [`35-estudo-referencia.md`](35-estudo-referencia.md) estudou seis áreas. Este vai ao resto — **os sistemas que nunca abrimos**, com os números reais e a fonte de cada um.
>
> ⚠️ **A linha do [`31-referencias.md`](31-referencias.md) mantém-se:** aqui não há nomes de armas, de chefes, de zonas nem de personagens. Há **fórmulas, limiares e arquitecturas** — e o que cada uma nos ensina.

**A descoberta maior deste estudo, se só leres uma linha:** o jogo de referência tem, escrito na fórmula do dano, **um piso de 30%**. Nenhuma quantidade de armadura, nível ou defesa reduz um golpe abaixo de 30% do valor dele. **É a nossa Lei 1 em forma de equação** — e nós não a tínhamos.

---

## 1. A matemática do dano — dois passos e um piso

É o sistema mais importante que nunca estudámos, e o que mais muda a nossa spec.

### Como funciona lá

O dano passa por **dois filtros diferentes**, por esta ordem:

| Passo | O que é | Como se comporta |
|---|---|---|
| **1. Defesa** | número plano | **não é subtracção** — é uma curva sobre a razão `ataque ÷ defesa` |
| **2. Absorção** | percentagem por tipo de dano | aplica-se **depois**, e acumula de forma **multiplicativa** |

**A curva da defesa**, por troços:

| Situação | Dano que passa |
|---|---|
| defesa > 8× ataque | **10% do ataque** — o mínimo por esta via |
| defesa > ataque | `(19,2/49 × (ATQ/DEF − 0,125)² + 0,1) × ATQ` |
| defesa > 0,4× ataque | `(−0,4/3 × (ATQ/DEF − 2,5)² + 0,7) × ATQ` |

**A acumulação da absorção** — quatro peças de armadura não somam:

`absorção_final = actual + nova − (actual × nova ÷ 100)`

Ou seja: 20% + 20% dá **36%**, não 40%. **Cada peça adicional vale menos que a anterior**, automaticamente, sem precisar de regra nenhuma escrita à mão.

### ⭐ E o piso

> **Nunca se leva menos de 30% do dano.** Por muita defesa e absorção que se tenha.

### O que isto nos ensina

1. ⭐ **O piso de 30% é a Lei 1 em equação, e é a peça que nos falta.** A nossa spec diz "o nível reduz a margem de erro, nunca abre uma porta" — mas não tem nenhum mecanismo que o **garanta**. Com um piso, um jogador de nível 100 com a melhor armadura do jogo **ainda leva 30%** do golpe de um inimigo comum. Nunca fica imune. Nunca deixa de ter de esquivar. `→WP2` **adoptar, com o nosso valor.**
2. **A defesa não deve ser subtracção.** Se fosse `dano − defesa`, chegava-se ao zero, e aí o jogo acaba. A curva sobre a **razão** nunca chega a zero — é a forma matematicamente correcta de fazer armadura sem quebrar o jogo.
3. **A absorção multiplicativa dá-nos rendimentos decrescentes de graça.** Não precisamos de tabelas de balanceamento por peça: a fórmula sozinha impede que quatro peças boas façam um jogador invencível.
4. ⚠️ **A nossa fórmula actual do [`11-formulas.md`](11-formulas.md) precisa desta revisão.** `→WP2`

**Fontes:** [Absorption — DS3 Wiki](https://darksouls3.wiki.fextralife.com/Absorption) · [Physical Defense — DS3 Wiki](https://darksouls3.wiki.fextralife.com/Physical+Defense) · [PSA: How Defense is Calculated in DS3](https://steamcommunity.com/app/374320/discussions/0/361787186437554178/)

---

## 2. Atributos — a curva de saturação, e porque é ela que segura a Lei 1

### Como funciona lá

Um ponto de atributo **não vale sempre o mesmo**. Passa por uma tabela de conversão que sobe depressa no início e quase pára depois:

| | Soft cap | O que acontece depois |
|---|---|---|
| **Vida** | **27**, depois 44 | aos 44, cada nível dá **menos de 10 PV** |
| **Stamina** | **40** | aos 40 → 160 de stamina · aos **99** → **170**. 59 níveis para 10 pontos |
| **Força / Destreza** | 27, **40**, 60 | rendimentos decrescentes a sério depois dos 40 |
| **Inteligência / Fé** | **40** (armas), 60 (magia) | do 40 para o 50, o ganho quase **metade** |
| **Carga** | sem soft cap | é o atributo que continua a render |
| Tecto absoluto | **99** em tudo | |

### O que isto nos ensina

⭐ **É esta curva, e não outra coisa, que impede o nível de substituir a perícia.**

Repara no número da stamina: **dos 40 aos 99 ganham-se 10 pontos.** Cinquenta e nove níveis para 6% mais stamina. Isso significa que, na prática, **um jogador de nível 40 e um de nível 99 têm a mesma stamina** — e a stamina é o recurso que decide combates. **A perícia continua a mandar porque a estatística deixou de crescer.**

**O que isto obriga na nossa spec:**

| | Referência | Nós hoje | O que fazer |
|---|---|---|---|
| Tecto | 99 | **100** ✅ | manter |
| Soft cap | **~40** na maioria | ⬜ **não existe** | `→WP2` **criar** |
| Forma da curva | tabela de conversão, tramos lineares | linear pura | `→WP2` **substituir** |

⚠️ **Com tecto 100 e sem soft cap, o nosso nível 100 é 2,5× o nível 40 — e aí o nível ganha jogos.** Com soft cap aos 40, o nível 100 é ~1,15× o nível 40, e continua a ser a perícia a decidir. **A Lei 1 depende deste número.**

**Um sinal de que estamos no sítio certo:** com soft cap aos 40 e tecto nosso em 100, quase toda a nossa escala vive **antes** do ponto onde os pontos deixam de contar. É melhor desenho do que o deles, que tem 59 níveis onde já quase nada acontece.

**Fontes:** [Stats — DS3 Wiki](https://darksouls3.wiki.fextralife.com/Stats) · [Soft and hard stat caps — TheGamer](https://www.thegamer.com/dark-souls-3-stat-soft-caps-effects/) · [Parameter Bonus — Dark Souls Wiki](https://darksouls.fandom.com/wiki/Parameter_Bonus)

---

## 3. Carga e rolamento — ⭐ a confirmação do nosso contrato

Isto liga directamente ao [`38-ataques-e-honestidade.md`](38-ataques-e-honestidade.md), e confirma-o de uma forma que eu não esperava.

### Como funciona lá

| Carga | Rolamento |
|---|---|
| **< 30%** | mais longe, ataques de rolamento ligeiramente mais rápidos |
| **30–70%** | distância média, **com hiper-armadura** |
| **> 70%** | lento, curto, **−9 de regeneração de stamina** |

### ⭐ E o número que importa

> **Invencibilidade: 13 frames leve ou médio · 12 frames pesado.**
>
> *"A diferença é pequena demais para afectar a jogabilidade."* E as animações do rolamento leve e do médio **demoram exactamente o mesmo tempo**.

### O que isto nos ensina

**Eles chegaram, na prática, à mesma conclusão que nós escrevemos ontem por princípio.** A cláusula 3 do nosso contrato diz que a invencibilidade não escala com nada. O jogo de referência **quase** faz isso: 12 contra 13 frames é ruído.

⭐ **Na referência, a armadura pesa sem tocar materialmente na invencibilidade:**

| O que a carga muda | O que a carga **não** muda |
|---|---|
| **distância** do rolamento | a janela de invencibilidade |
| **velocidade** de deslocação | a duração da animação |
| **regeneração de stamina** (−9 no escalão pesado) | quantas vezes se pode esquivar seguido |
| ter ou não **hiper-armadura** | |

**A conclusão que conservamos é o custo sem mexer nos i-frames.** O contrato actual não herdou a distância variável da referência: cobra recuperação e regeneração, que são os campos executáveis de `armor.json`.

**A decisão corrente para nós**, fechada pelo [`70`](70-fecho-dos-sistemas-de-combate.md) §1.1:

| Escalão | Limiar | Esquiva | Invencibilidade | Regen. stamina |
|---|---|---|---|---|
| Leve | < 30% | base | **317 ms** | **40/s** |
| Médio | 30–70% | recuperação +4 f | **317 ms** | **40/s** |
| Pesado | >70–100% | recuperação +8 f | **317 ms** | **31/s** |
| **Sobrecarregado** | > 100% | **não existe**; sem corrida/sprint, marcha 3 m/s | — | **26/s** |

**Fontes:** [Equipment Weight Thresholds — TheGamer](https://www.thegamer.com/dark-souls-3-weight-ratio-dodge-roll/) · [Equipment Load — DS3 Wiki](https://darksouls3.wiki.fextralife.com/Equipment_Load)

---

## 4. Interrupção — o sistema inteiro que nos falta

**A nossa spec não tem nada sobre isto**, e é o que decide se levar um golpe a meio do teu te interrompe ou não. Sem ele, armas lentas são inutilizáveis: qualquer inimigo rápido cancela-te sempre.

### Como funciona lá

| Peça | Como é |
|---|---|
| **Vida de interrupção** | valor escondido, **100** para todos. A zero, cambaleias |
| **Regeneração** | **não** regenera aos poucos — **volta a 100% de golpe, a cada 30 s** ou quando chega a zero |
| **A estatística visível** | não é vida a mais — é uma **percentagem de redução** ao dano de interrupção recebido |
| **Acumulação entre peças** | a mesma fórmula multiplicativa do dano: `α + β − (α×β/100)` |
| **Máximo atingível** | ~67% de redução, e só com o equipamento mais pesado do jogo |
| **Hiper-armadura** | só em **certos ataques** (armas muito grandes, algumas artes, rolamentos médios/pesados) |

**Dano de interrupção por arma** (golpe básico): adaga **10** · espada recta **14** · espada grande **26** · espadão **31**. Inimigos humanóides fazem **15–45** em ataques rápidos e **70–130** nos fortes.

**E o detalhe que faz o sistema funcionar:** um ataque normal **repõe a tua vida de interrupção a 80%** ao começar; uma arte de arma repõe a **100%**. Durante o ataque aplica-se um multiplicador (0,10–0,27 nos normais; 0,30–2,00 nas artes).

### O que isto nos ensina

1. ⭐ **A hiper-armadura é o que dá razão de ser às armas lentas.** Sem ela, uma arma de 1,2 s de arranque nunca acerta — qualquer adaga a cancela. Com ela, o jogador pesado faz uma **troca**: levo o golpe dele, mas o meu sai. **Isso é uma decisão, e decisões são a Lei 2.**
2. **Repor a 80% ao atacar, não a 100%,** significa que atacar te torna ligeiramente mais frágil à interrupção. Elegante: agressão tem custo.
3. ⚠️ **A parte controversa, e nós devemos escolher melhor:** lá, a estatística de interrupção **só faz efeito durante os frames de hiper-armadura**. Fora deles não serve de nada — o que confunde toda a gente, porque o número aparece no ecrã e não faz o que parece. **Isso quebra a cláusula 4 do nosso contrato** (*o que se vê é o que acontece*).

   **Proposta `[CLAUDE]` `→WP1`:** a nossa resistência a interrupção **funciona sempre**, não só durante ataques. Mais simples de explicar, mais honesta, e não custa nada implementar.
4. **O número escondido é bom desenho.** Não pomos barra na interface — sente-se pelo comportamento. `→WP11`

**Fontes:** [Poise — DS3 Wiki](https://darksouls3.wiki.fextralife.com/Poise) · [Poise (DS3) — Dark Souls Wiki](https://darksouls.fandom.com/wiki/Poise_(Dark_Souls_III)) · [Hyper Armor](https://darksouls.fandom.com/wiki/Hyper_Armor)

---

## 5. Críticos — parry, contra-golpe e ataque pelas costas

### Como funciona lá

| | Como é |
|---|---|
| **Quatro tipos de crítico** | pelas costas · contra-golpe após parry · à cabeça · queda em cima |
| **Multiplicador** | 100 na maioria das armas; **adagas e estoques têm mais** |
| **Contra-golpe vs costas** | o contra-golpe dá **10–30% mais** — e é muito mais difícil |
| **Janela do parry** | três tipos: **rápida** (janela curta, recuperação curta) · normal · **longa** (janela longa, recuperação longa) |
| **Tempo para o contra-golpe** | ~**1 segundo** depois do parry acertado |
| **Durante a animação** | **os dois ficam invencíveis** (excepto dano ao longo do tempo) |

### O que isto nos ensina

1. ⭐ **A troca janela-longa/recuperação-longa é desenho excelente**, e é directamente a nossa Lei 2. Um escudo com janela larga é mais fácil de acertar **e mais caro de falhar**. Não é "melhor" — é **outra coisa**. `→WP5`: **cada escudo declara o seu tipo de parry**, e não há um que seja o melhor.
2. **Adagas com multiplicador crítico maior** é o que dá identidade a uma arma fraca. Uma adaga não ganha por dano bruto — ganha por **posicionamento**. Isso é a Lei 2 aplicada ao catálogo, e é a resposta para "porque é que eu usaria a arma pequena?". `→WP5`
3. ⭐ **A invencibilidade durante a animação de crítico resolve o nosso problema de co-op.** Com dois jogadores, um contra-golpe num inimigo que está a ser atacado pelo outro seria caos. Se os dois envolvidos ficam invencíveis durante a animação, o segundo jogador **não pode interromper nem roubar** o crítico. `→WP10` — **adoptar, e é obrigatório para dois jogadores.**
4. **Um segundo para reagir ao parry** é a janela certa: chega para o humano decidir, não chega para ser automático.

**Fontes:** [Critical attack — Dark Souls Wiki](https://darksouls.fandom.com/wiki/Critical_attack) · [Parry and Riposte](https://darksouls.fandom.com/wiki/Parry_and_Riposte) · [Criticals — Wikidot](http://darksouls.wikidot.com/critical-damage)

---

## 6. Melhoria de armas — dois eixos que fazem coisas diferentes

Era a lacuna nº6 do estudo anterior. Agora tem forma.

### Como funciona lá

**Eixo A — reforço.** Números maiores, mesma arma:

| Nível | Material |
|---|---|
| +1 a +3 | fragmento |
| +4 a +6 | fragmento grande |
| +7 a +9 | pedaço |
| **+10** | **laje** — rara, é o tecto |

Armas especiais têm caminho próprio e **param no +5**.

**Eixo B — infusão.** Muda o que a arma **é**:

> A infusão normalmente **remove a escala original** da arma em troca de dano elementar fixo e/ou escala noutro atributo.

E tem trancas deliberadas: **arcos, bestas, cajados e talismãs não se podem infundir**, nem nenhuma arma do caminho especial. Para infundir é preciso ter encontrado a peça de conhecimento certa **e** a gema **e** ter almas.

### O que isto nos ensina

1. ⭐ **Os dois eixos respondem a perguntas diferentes, e é por isso que funcionam.** O reforço responde *"quero isto mais forte"*; a infusão responde *"quero isto **diferente**"*. **A infusão é literalmente a Lei 2** — troca-se escala por escala, não se soma. `→WP5` **os dois eixos, e a infusão é a que interessa mais.**
2. ⚠️ **A escassez da laje é o que dá peso à decisão.** Se o material do último nível for abundante, tudo fica +10 e o sistema desaparece. **Ele existe porque é raro** — e isso é desenho de economia, não de combate. `→WP9`
3. **As trancas na infusão não são arbitrárias.** Não se pode infundir o que já é elemental por natureza. `→WP5`: escrever a regra **como princípio**, não como lista de excepções.
4. ⚠️ **Uma coisa a não copiar:** exigir três recursos separados (conhecimento + gema + almas) para uma infusão é fricção a mais para dois amigos num hobby. **Proposta `[CLAUDE]`: só o material.**

**Fontes:** [Upgrades — DS3 Wiki](https://darksouls3.wiki.fextralife.com/Upgrades) · [Infusion — DS3 Wiki](https://darksouls3.wiki.fextralife.com/Infusion) · [Upgrade Materials](https://darksouls3.wiki.fextralife.com/Upgrade+Materials)

---

## 7. Frascos — ⭐ a escolha que se faz no descanso

O estudo anterior viu os dois eixos de melhoria. Falta a peça melhor.

### Como funciona lá

> ⚠️ **MODELO REVOGADO PELO [`54`](54-mana-meditacao-e-tracos-de-classe.md):** o parágrafo abaixo fica como investigação histórica. O jogo actual separa frascos, mana e artes de arma; artes gastam mana e meditação segue o [`66`](66-catalogo-de-magia.md).

Há **dois frascos**: um cura vida, o outro repõe a energia que alimenta magias **e artes de arma**.

> **O total de cargas entre os dois chega a 15, e o jogador distribui-as como quiser** num sítio próprio.

### O que isto nos ensina

⭐ **Isto é a melhor peça de desenho deste estudo inteiro, e nós podemos adoptá-la quase tal e qual.**

Cada descanso passa a ter uma **pergunta**: vou lutar com o corpo ou com as ferramentas? Um jogador pode ir 15/0 e não usar magia nenhuma; outro vai 8/7 e joga de outra maneira. **A mesma personagem, dois jogos diferentes, sem uma linha de código de "classes".**

E olha o que resolve de uma vez:

| Problema nosso | Como isto resolve |
|---|---|
| Artes de arma sem custo seriam grátis e óbvias | passam a gastar do mesmo bolo que a cura |
| Magos e guerreiros precisarem de sistemas separados | **um** sistema, dois modos de o usar |
| A Lei 3 (*qualquer classe pega em qualquer arma*) | a divisão passa a ser **escolha por descanso**, não escolha na criação |
| Onde vive a decisão fora do combate | no ponto de descanso, que é onde já está o jogador |

⚠️ **MODELO REVOGADO:** não adoptar. Cura continua no frasco; feitiços e artes gastam mana; meditação e as duas tentativas por descanso vivem no [`54`](54-mana-meditacao-e-tracos-de-classe.md) e no [`66`](66-catalogo-de-magia.md).

~~A pergunta sobre repartir cargas em co-op~~ ficou **dissolvida** com a separação entre frasco e mana; registo no [`99`](99-perguntas-abertas.md) n.º 25.

**Fontes:** [Ashen Estus Flask — DS3 Wiki](https://darksouls3.wiki.fextralife.com/Ashen+Estus+Flask) · [Ashen Estus Flask — Wikidot](http://darksouls3.wikidot.com/tool:ashen-estus-flask)

---

## 8. O mundo — o círculo, e porque é que ele resolve o nosso maior risco

### Como funciona lá

> *"Um caminho que podia ser percorrido em linha recta é forçosamente transformado num círculo."*

- Os atalhos **abrem-se pelo lado de dentro** — ganham-se, não se encontram
- Os círculos são **verticais** tanto como horizontais — elevadores e escadas ligam andares que pareciam mundos diferentes
- É só **depois de abrir os atalhos** que a forma da terra aparece: *"não importa o caminho que escolhas, acabas quase sempre a voltar a um sítio onde já deixaste pegadas"*
- A recompensa emocional é concreta: lutar uma zona inteira, tomar um elevador, e **cair na fogueira central**

### O que isto nos ensina

⭐ **É a resposta directa ao nosso maior risco de escopo.**

O Mateus quer 10+ biomas e ~30 minutos a pé. Com um mapa linear, isso são 30 minutos de caminhada aborrecida a cada travessia. **Com círculos, um mapa grande sente-se pequeno** — e não se constrói mais mundo nenhum. **O atalho é o conteúdo mais barato que existe:** é uma porta, e transforma o mapa todo.

**A regra prática que tiro daqui, `→WP8`:**

1. **Toda a zona tem de fechar um círculo** para algum sítio já visitado. Se não fecha, ou não está acabada, ou está no sítio errado
2. **O atalho abre-se do lado de dentro** — é a prova de que passaste, não uma chave que encontraste
3. **Pelo menos um círculo por zona é vertical**, porque é o que faz o mundo parecer um sítio e não um corredor
4. **Desenhar com a tabela de queda à frente** ([`36-fisica.md`](36-fisica.md) §2): 4 m é atalho, 20 m é morte

### E a fogueira antes do chefe

O debate na comunidade é claro: **a corrida de volta ao chefe é fricção, não dificuldade.** Quem defende a fogueira perto da porta di-lo bem — quer *"dominar o chefe, e não passar 20 minutos a lá chegar de cada vez que morre"*.

⚠️ **CORRIGIDO PELO [`53`](53-chefes-ritmo-e-o-mago-forte.md) §3:** o princípio anti-`runback` mantém-se no **guardião**; o descanso é por arco e não aparece à porta de cada subchefe. Não há uma fogueira por cada encontro catalogado.

**Fontes:** [World Design lessons from FromSoftware](https://medium.com/@Jamesroha/world-design-lessons-from-fromsoftware-78cadc8982df) · [The Ultimate Methodology of creating Souls-like Level](https://medium.com/@bramasolejm030206/preface-ec08bc1459d0) · [Interconnected Level Design — TheGamer](https://www.thegamer.com/dark-souls-1-fromsoftwares-magnum-opus-of-interconnected-level-design/) · [Bonfires — DS3 Wiki](https://darksouls3.wiki.fextralife.com/Bonfires)

---

## 9. Inimigos — agressão, coordenação, e ⭐ o fim do grind

### Como funciona lá

**Agressão e perseguição:** os alcances de detecção variam muito entre jogos da série; num deles os inimigos perseguem para muito longe e **sobem escadas atrás do jogador**. E — o detalhe que interessa — **coordenam-se**: apanham rolamentos e **encadeiam ataques para acertar enquanto o jogador recupera de um cambaleio**.

⚠️ **Isso último é exactamente o que a nossa cláusula do [`38`](38-ataques-e-honestidade.md) §3 proíbe** (≥ 0,20 s entre golpes activos de inimigos diferentes). Fica registado como **coisa a não copiar**: encadear ataques para acertar na recuperação é impossível de responder, e impossível não é difícil.

**⭐ E o mecanismo anti-grind:**

> **Ao fim de 12 mortes, o inimigo deixa de reaparecer.** Permanentemente, até se começar um ciclo novo.

E a intenção declarada é **tornar o jogo mais fácil para quem está preso numa zona** — não punir. Quem quiser o contrário adere a um pacto que faz tudo reaparecer para sempre, **em troca de inimigos mais duros**.

### O que isto nos ensina

⭐ **O contador de 12 é a Lei 1 posta em código, e é a melhor solução que vi para o problema do grind.**

A nossa Lei 1 diz *"nada de grind obrigatório"*. Mas dizer não chega — se as almas são precisas para subir de nível, **o jogador vai fazer grind na mesma**, porque é a coisa racional a fazer. O contador remove a possibilidade: passadas 12 vezes, aquela sala está limpa e o jogador **tem** de avançar.

E o efeito secundário é ainda melhor: **quem está preso vai gradualmente tendo menos oposição** no caminho. A zona amolece sozinha, sem menu de dificuldade, sem o jogador ter de admitir nada. **É dificuldade adaptativa que não se nota.**

**Proposta `[CLAUDE]` `→WP6`/`→WP9`:** adoptar com o nosso número — proponho **10**, e a contagem é **por sala, não por zona**. Em co-op, conta o par, não cada um.

⚠️ **A pergunta que isto abre e é dos donos:** se os inimigos deixam de reaparecer, de onde vêm as almas para chegar ao nível 100? Ou o mundo é grande que chegue, ou o nível 100 não é para atingir numa passagem. **Nenhuma das duas é má** — mas tem de ser decidida. → `99`

**Fontes:** [Respawning — DS2 Wikidot](http://darksouls2.wikidot.com/respawning) · [Monsters stop spawning? — Steam](https://steamcommunity.com/app/335300/discussions/0/1735507984418076622/) · [Enemy behavior — Steam](https://steamcommunity.com/app/570940/discussions/0/1694922526901017327/)

### E a colocação — o critério que separa emboscada de armadilha barata

O debate é antigo e a formulação que vale é esta: os desenhadores **deixam os emboscadores à vista**, para que a emboscada seja justa **para quem repara**. A crítica ao jogo que exagerou é o inverso: muitos inimigos de uma vez, num sítio apertado, com a câmara sem espaço.

**A regra que tiro, `→WP8`/`→WP6`:** **toda a emboscada tem de ser visível para quem olha antes de avançar.** Uma sombra, uma marca no chão, um som. Se a única forma de a evitar é já ter morrido lá, **é armadilha, não é desenho** — e é a cláusula 4 do nosso contrato aplicada ao mundo.

**Fontes:** [Undead Burg — The Level Design Book](https://book.leveldesignbook.com/studies/sp/undead-burg) · [Enemy placement debate — GameFAQs](https://gamefaqs.gamespot.com/boards/168566-dark-souls-iii/73679192)

---

## 10. Co-op — o que fazem, e o que **não** devemos fazer

### Como funciona lá

| | Como é |
|---|---|
| Escala do chefe | **mais vida por cada acompanhante** — e continua a mais vida mesmo que ele morra ou nem entre |
| Dano do chefe | sobe um pouco |
| Efeito real | *"não fica exactamente mais difícil — fica mais uma esponja de dano"* |
| Risco conhecido | se os acompanhantes morrem a meio, fica-se com um chefe de vida enorme e pouca capacidade de o magoar |

### ⭐ O que isto nos ensina — e é um aviso, não um modelo

**Isto é a Lei 2 quebrada, e está escrito na crítica que os próprios jogadores fazem.** Mais vida **não é** mais dificuldade — é o mesmo combate, mais longo. E o pior está no fim: **quem já está a perder é castigado outra vez**, porque a vida extra fica lá depois do parceiro cair.

**O nosso jogo é co-op para dois desde o primeiro dia — não é um extra.** Isso muda tudo: não temos de "compensar" um acompanhante, temos de **desenhar para dois**.

**Proposta `[CLAUDE]` `→WP7`/`→WP10`, e é uma resposta directa à pergunta 6 do `99`:**

| ❌ Não fazer | ✅ Fazer |
|---|---|
| multiplicar a vida do chefe | **mais vida no máximo +40%**, e nunca mais |
| aumentar o dano | manter — o dano é o contrato de honestidade, não se toca |
| deixar a escala depois de um cair | ⭐ **a escala desce quando um morre** |
| — | **ataques que obrigam a separar** — área que apanha os dois se estiverem juntos |
| — | **ataques que escolhem alvo** — quem está longe também tem de trabalhar |

**A regra:** um chefe para dois é mais difícil porque **faz perguntas diferentes**, não porque demora mais. Se a única diferença é a barra ser mais comprida, ficámos com uma esponja.

**Fontes:** [Boss Health Modifiers and Summons — Fextralife Forum](https://fextralife.com/forums/t58360/boss-health-modifiers-and-summons) · [Cons to summoning — Steam](https://steamcommunity.com/app/374320/discussions/0/361787186429120965/)

---

## 11. Almas — uma moeda, duas saídas

### Como funciona lá

As almas são **ao mesmo tempo** a experiência e o dinheiro. Sobe-se de nível **ou** compra-se — nunca as duas com as mesmas.

E a nota que a comunidade repete: **quase nenhuma arma vale a pena comprar**. O que se compra é o que **facilita** — objectos de regresso, consumíveis, material.

### O que isto nos ensina

1. ⭐ **Uma moeda com duas saídas é uma decisão constante, e é grátis de implementar.** Cada alma gasta numa poção é um nível adiado. Não é preciso sistema nenhum de economia — a tensão nasce de só haver uma moeda.
2. ⚠️ **As lojas não devem vender poder.** Se se compram armas boas, o jogo passa a ser sobre acumular almas — que é grind, que é a Lei 1 quebrada. **A loja vende conveniência e material.** `→WP9`
3. **Guardar almas é uma aposta**, porque perdem-se ao morrer ([`33-morte-e-almas.md`](33-morte-e-almas.md)). Quem guarda para um nível grande arrisca mais. **Isso já está no nosso desenho** — só faltava perceber que é aqui que ele fecha.

**Fontes:** [Souls — Dark Souls Wiki](https://darksouls.wiki.fextralife.com/Souls) · [What to Do With Souls in DS3](https://gamevoyagers.com/what-to-do-with-souls-in-dark-souls-3/)

---

## 12. ⭐ Descoberta e rejogo — a resposta directa ao que o Mateus pediu

> *"A gente nunca zera. Dá pra zerar aquele jogo quinze vezes e ainda está descobrindo novas coisas. Eu quero um jogo assim."*

**Isto tem resposta, e não é conteúdo a mais.** É como o conteúdo está posto.

### Como funciona lá

| Mecanismo | Como é |
|---|---|
| **A história vive nos objectos** | as descrições dos itens carregam a lore; não há narrador |
| **Objectos colocados por relevância** | um objecto está naquele sítio **por causa** daquele sítio; ler os dois juntos conta uma terceira coisa |
| **Ambiguidade deliberada** | *"pede-se ao jogador que infira"* — não se explica |
| **O que a segunda passagem dá** | *"um mural que falhaste, um corpo posto assim mesmo"* — detalhes que **reenquadram** o que já sabias |
| **Ciclo novo** | o mundo repõe-se com tudo mais duro |

### ⭐ O que isto nos ensina, e é a coisa mais importante deste documento

**A rejogabilidade não vem de haver mais coisas. Vem de o jogador não ter tudo em mãos à primeira.**

Um mural que ele não olhou não é conteúdo extra — é **o mesmo conteúdo, visto outra vez com mais contexto**. Custa uma textura. E é isto que faz alguém acabar um jogo quinze vezes.

**As quatro regras que tiro, `→WP8`/`→WP9`/`→WP13`:**

1. ⭐ **Todo o objecto traz uma descrição, e a descrição diz uma coisa sobre o mundo** — não só o que faz. É o veículo de narrativa mais barato que existe: é texto, não custa fotogramas (Lei 4), e é o que o jogador relê
2. **Nada de narrador.** O que se percebe, percebe-se pelo sítio e pelo objecto
3. ⭐ **Cada zona esconde pelo menos uma coisa que só se encontra ao olhar para cima**, ou ao voltar depois de saber outra coisa. Não é um segredo com puzzle — é uma **recompensa por atenção**
4. **Um objecto nunca é genérico.** Se pode estar em qualquer sítio, está no sítio errado

⚠️ **E a advertência honesta:** este modelo é a coisa **mais barata de produzir** de todo este estudo e **a mais cara de escrever bem**. Duas pessoas conseguem 10 biomas com boa colocação de objectos. O que não se consegue é escrever 400 descrições de qualidade numa semana. `→WP13` — **é trabalho contínuo, não um pacote.**

**Fontes:** [Environmental Storytelling — Lokey Lore](https://lokeysouls.com/2020/11/16/environmental-storytelling/) · [How FromSoftware Tells Stories Without Words](https://www.amrsalehduat.com/duattales/how-fromsoftware-tells-stories-without-words) · [Lore hidden in item descriptions — Dualshockers](https://www.dualshockers.com/best-soulsborne-lore-hidden-item-descriptions/)

---

## 13. A filosofia declarada — e onde nós divergimos de propósito

Nas palavras do próprio autor:

> *"Não tentamos forçar a dificuldade nem tornar as coisas difíceis por serem difíceis. Queremos que o jogador use a astúcia, estude o jogo, memorize o que está a acontecer, e aprenda com os erros."*

E sobre não haver níveis de dificuldade:

> *"Sentimos que, se houvesse dificuldades diferentes, isso ia segmentar e fragmentar a base de utilizadores."*

### O que isto nos ensina

**A primeira citação é a nossa Lei 1, dita por outras palavras.** *Dificuldade não é o objectivo — é o preço da sensação de superar.* Bom sinal: não estamos a inventar uma filosofia, estamos a seguir uma que já se provou.

⚠️ **A segunda não se aplica a nós, e é importante perceber porquê.** A razão para não haver níveis de dificuldade é **social** — não fragmentar milhões de jogadores. **Nós somos dois amigos.** Não há base para fragmentar.

**O que isso liberta:** não temos de ser dogmáticos sobre isto. **Não vamos pôr um menu de "fácil/difícil"** — isso quebrava a Lei 1, que é sobre o jogo não ser trancado nem amolecido por um número. Mas **os ajustes que o mundo faz sozinho** — o contador de mortes da §9, o ponto de descanso à porta do chefe da §8 — são melhores do que um menu, e chegam ao mesmo sítio sem quebrar nada.

**Fontes:** [Miyazaki on difficulty philosophy](https://ixbt.games/en/news/2025/12/30/xidetaka-miiadzaki-obieiasnil-filosofiiu-sloznosti-v-igrax-vrode-dark-souls-i-elden-ring.html) · [Miyazaki on difficulty options](https://fandomwire.com/hidetaka-miyazaki-dark-souls-bloodborne-intentionally-lacking-1-feature-is-something-we-take-to-heart-when-we-design-games/)

---

## O que este estudo produziu — o accionável

Ordenado por **quanto muda a nossa spec**, não por ordem de secção.

| # | Descoberta | Onde bate | Peso |
|---|---|---|---|
| 1 | ⭐ **O piso de 30%** — nenhuma defesa reduz um golpe abaixo disso. É a Lei 1 em equação, e não a temos | `→WP2` | **adoptar** |
| 2 | ⭐ **Soft cap aos ~40** — sem ele, o nosso nível 100 ganha jogos e a Lei 1 cai | `→WP2` | **criar** |
| 3 | ⭐ **A carga nunca muda a invencibilidade**; no contrato actual cobra recuperação/regen e sobrecarga | [`70`](70-fecho-dos-sistemas-de-combate.md) §1.1 | **fechado** |
| 4 | ⭐ **Interrupção e hiper-armadura** — o sistema inteiro falta-nos; sem ele armas lentas não existem | `→WP1` | **criar** |
| 5 | ~~**Um bolo de cargas repartido entre curar e usar**~~ | [`54`](54-mana-meditacao-e-tracos-de-classe.md), [`66`](66-catalogo-de-magia.md) | **revogado: frasco + mana separados** |
| 6 | ⭐ **Contador de mortes por sala** — a Lei 1 posta em código; acaba com o grind e amolece a zona sozinha | `→WP6`/`→WP9` | **adoptar (10)** |
| 7 | ⭐ **Toda a zona fecha um círculo**, e o atalho abre-se do lado de dentro | `→WP8` | **regra** |
| 8 | ⭐ **Descanso antes do guardião**, por arco; não antes de cada subchefe | [`53`](53-chefes-ritmo-e-o-mago-forte.md) §3 | **fechado** |
| 9 | ⭐ **Descrição em todo o objecto, colocado por relevância** — é daqui que vem "nunca zera" | `→WP13` | **regra contínua** |
| 10 | **Defesa por curva sobre a razão, absorção multiplicativa** — dá decrescentes de graça | `→WP2` | substituir |
| 11 | **Dois eixos de melhoria:** reforço (números) e infusão (troca escala = Lei 2) | `→WP5` | criar |
| 12 | **Parry com três janelas** (curta/normal/longa), cada uma com a sua recuperação | `→WP5` | adoptar |
| 13 | **Invencibilidade durante o crítico** — impede o parceiro de interromper ou roubar | `→WP10` | obrigatório |
| 14 | **Adagas com multiplicador crítico maior** — identidade sem dano bruto | `→WP5` | adoptar |
| 15 | **A loja vende conveniência, nunca poder** | `→WP9` | regra |
| 16 | ⚠️ **NÃO copiar:** chefe de co-op só com mais vida (esponja, e castiga quem já perde) | `→WP7`/`→WP10` | **evitar** |
| 17 | ⚠️ **NÃO copiar:** inimigos que encadeiam ataques na recuperação do cambaleio | `→WP6` | **evitar** |
| 18 | ⚠️ **NÃO copiar:** estatística de interrupção que só funciona durante ataques (quebra a cláusula 4) | `→WP1` | **melhorar** |

---

## O que isto abre e é dos donos

| Pergunta | Porquê agora |
|---|---|
| **Se os inimigos param de reaparecer, de onde vêm as almas para o nível 100?** | ou o mundo é maior, ou o 100 não é para uma passagem |
| ~~**Cada jogador reparte as suas cargas — e se ficarem desequilibrados?**~~ | **dissolvida:** frasco e mana são recursos separados ([`54`](54-mana-meditacao-e-tracos-de-classe.md)) |
| **Aceitamos +40% de vida no chefe a dois, ou zero?** | fecha a pergunta 6 do `99` |
| **O contador é 10 por sala? por zona? por par ou por jogador?** | proposta `[CLAUDE]`: 10, por sala, por par |

→ entram no [`99-perguntas-abertas.md`](99-perguntas-abertas.md).

## Ligações

[`35-estudo-referencia.md`](35-estudo-referencia.md) · [`31-referencias.md`](31-referencias.md) · [`38-ataques-e-honestidade.md`](38-ataques-e-honestidade.md) · [`36-fisica.md`](36-fisica.md) · [`11-formulas.md`](11-formulas.md) · [`01-combate.md`](01-combate.md) · [`33-morte-e-almas.md`](33-morte-e-almas.md)
