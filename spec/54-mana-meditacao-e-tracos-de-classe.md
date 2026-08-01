# 54 — Mana, meditação, e o traço de classe

`[DECIDIDO]` (Mateus, 01-08-2026):

> *"Não quero limite para slot de magia, mas quero limite de uso, ou mana — acho que mana seria mais interessante. O mago do mal tem um buff de 40% de mana sempre, pela classe; os outros personagens também vão ter algo assim. Podemos parar e meditar para recuperar a mana: 40 segundos sentado recupera 100% da mana, mas não os frascos."*

---

## 1. ⚠️ O que isto substitui, e porque é que é melhor

**Isto revoga o sistema de cargas partilhadas** que eu tinha adoptado da referência ([`39`](39-estudo-profundo.md) §7): um bolo de ~15 cargas repartido entre **curar** e **lançar**, distribuído no ponto de descanso.

**Eu gostava desse sistema** — chamei-lhe *"a melhor peça de desenho deste estudo inteiro"*. Estava errado em pelo menos uma coisa importante, e é o Mateus que a resolve.

### O defeito que eu não tinha visto

⚠️ **O bolo partilhado obriga a decidir antes de saber.** Distribuis as cargas no descanso, **antes** de saber o que vem a seguir. Se puseres tudo em magia e o bioma for de corpo a corpo, jogaste mal por falta de informação — **não por falta de perícia**. Isso não é a Lei 1.

⭐ **A mana com meditação move a decisão para dentro do combate**, que é onde ela vale:

| | Bolo partilhado *(o meu)* | ⭐ Mana + meditação *(o dele)* |
|---|---|---|
| Quando decides | no descanso, sem informação | **a cada lançamento**, a ver o que se passa |
| O que arriscas | uma escolha errada há 10 minutos | **o próximo golpe** |
| Em co-op | cada um distribui em silêncio | ⭐ **"preciso de meditar" é uma conversa** |
| A tensão é | administrativa | **de momento** |

⭐ **E a peça que o meu sistema não tinha:** com meditação, **o tempo passa a ser o recurso**. Estar sentado 40 segundos num mundo hostil, com o parceiro à espera e de guarda, **é uma decisão real** — e é uma decisão que os dois tomam juntos.

---

## 2. Mana — as regras

`[DECIDIDO]`

| | |
|---|---|
| **Slots de magia** | ⭐ **não existem.** Levas tudo o que tens |
| **O limite** | **mana** |
| **Regeneração passiva** | ⚠️ **nenhuma.** A mana não volta sozinha |
| **Como se recupera** | **meditar** (§3) · **frascos de mana** · **anéis e efeitos** (§5) |
| **Atributo** | ⭐ mana é **um dos atributos** — sobe com o nível, como a vida |

### ⭐ Porque é que "sem regeneração passiva" é a decisão certa

Se a mana voltasse sozinha, a jogada óptima seria **esperar** — e esperar já foi apontado como defeito noutro sítio da spec ([auditoria](../docs/AUDITORIA-CODEX-2026-08-01.md), erro 11: *"cooldowns de 15–60 segundos convidam a esperar"*).

**Com mana que não regenera, o combate é a unidade.** O que levas para a luta é o que tens, e o que sobra no fim é teu para a próxima — ou meditas, e pagas em tempo e em risco.

### O custo dos feitiços

`[CLAUDE]` — ponto de partida, valida-se a jogar:

| Escalão | Custo | Exemplos |
|---|---|---|
| **Barato** | 8–15 | dardo, agulha, cegueira |
| **Médio** | 25–40 | mancha, marca ardente, dreno |
| **Caro** | 60–90 | ruína perfurante, nova escura, espelho |
| ⭐ **Necromancia** | **mana + PV** | levantar (§ [`52`](52-mago-do-mal.md)) |

⚠️ **A necromancia continua a custar vida além de mana.** É o travão da §2 do [`52`](52-mago-do-mal.md) e não se toca — sem ele, a mana recuperável tornaria os invocados grátis.

---

## 3. ⭐ Meditar

`[DECIDIDO]` — **40 segundos sentado = 100% da mana. Os frascos não voltam.**

| | |
|---|---|
| Tempo | **40 s** |
| Recupera | **toda a mana** |
| ⚠️ **Não recupera** | **frascos** · vida · invocados · o Voto de Sangue |
| Onde | ⭐ **em qualquer sítio** — não é preciso ponto de descanso |
| ⚠️ Interrompe-se | **com qualquer dano**, e a mana ganha até ali **fica** |
| ⚠️ O mundo | **não pára.** Os inimigos continuam a andar e podem encontrar-te |

### ⭐ Porque é que isto é bom desenho, e não uma conveniência

**É a única mecânica do jogo que custa tempo em vez de recursos** — e num jogo de dois isso muda o que ela significa:

| Sozinho | ⭐ A dois |
|---|---|
| 40 s de risco | **um medita, o outro faz guarda** |
| decisão individual | ⭐ **decisão conjunta: "aguentas 40 segundos?"** |
| pausa | **uma cena** |

⭐ **Meditar num sítio limpo é seguro e aborrecido. Meditar a meio de uma zona é uma aposta.** E o parceiro de guarda tem um papel — que é exactamente o tipo de coisa que faz um co-op valer a pena.

⚠️ **E a regra que impede o abuso é a que já existe:** os frascos **não voltam** a meditar. Só no ponto de descanso — que faz reaparecer os inimigos todos ([`40`](40-decisoes-espolio-magia-inventario.md) §1). **Logo: mana é barata em tempo, vida é cara em progresso.** Continuam a ser duas economias diferentes, como no meu sistema — só que agora com moedas separadas em vez de um bolo.

---

## 4. ⭐ O traço de classe

`[DECIDIDO]` (Mateus) — *"o mago do mal tem um buff de 40% de mana sempre, pela classe; os outros também vão ter algo assim."*

**Isto é um sistema novo, e é bom:** cada classe tem **uma coisa passiva que nunca perde**, e que a define mesmo depois de trocar todo o equipamento.

⭐ **É a resposta certa à Lei 3, com o limite fechado no [`64`](64-criacao-de-personagem.md).** Qualquer origem pega em qualquer arma, magia e técnica encontrada — mas o **traço de origem** não se troca. É identidade persistente, não caminho: nunca abre/fecha item, escola, espólio, NPC, zona ou chefe.

| Classe | ⭐ Traço `[CLAUDE]`, proposta |
|---|---|
| ⭐ **Mago do mal** | **+40% de mana** `[DECIDIDO]` |
| **Feiticeiro** (azul) | os feitiços **lançam 15% mais depressa** |
| **Guerreiro** | recupera **stamina 20% mais depressa** |
| **Tanque** | ⭐ **bloquear com stamina a zero não parte a guarda** — cambaleias, mas não abres |
| **Assassino** | ⭐ os **críticos pelas costas** dão mana e stamina de volta |
| **Berserker** | ⭐ **quanto menos vida, mais depressa ataca** (até +25% abaixo de 30%) |
| **Paladino** | ⭐ **cura o parceiro 30% do que se curar a si** — o traço que só existe porque somos dois |

⚠️ **A regra que os mantém honestos:** um traço **nunca é um número de dano**. É **velocidade, recurso, ou uma regra que muda** — senão é a Lei 2 quebrada, que foi o erro que a auditoria apanhou no Voto de Sangue.

⚠️ **E um `[EM ABERTO]` que isto levanta:** o **mago do mal** é uma **classe própria** ou é o **feiticeiro** com a escola vermelha? O Mateus disse *"pela classe"*, o que sugere classe própria — mas o [`12-classes.md`](12-classes.md) tem seis e o feiticeiro é uma delas. **Decisão dos donos.** → [`99`](99-perguntas-abertas.md)

---

## 5. Absorver mana ao matar

`[DECIDIDO]` (Mateus) — *"um anel ou assim com poder de absorver mana quando mata, além das almas."*

`[CLAUDE]` `→WP5`, e é uma **família** de anéis, não um anel:

| Anel | O que faz |
|---|---|
| **Anel do Usurário** | +8 de mana por inimigo morto |
| **Anel do Faminto** | +25 de mana, **mas só quando és tu a dar o último golpe** |
| ⭐ **Anel do Coveiro** | mana quando um **morto teu** mata — recompensa quem joga com invocados |
| **Anel do Jejum** | ⚠️ **não ganhas mana a matar**, mas a **meditação passa a 25 s** |

⭐ **O do Jejum é o mais interessante** porque troca um eixo pelo outro: quem o usa não vive de matar, vive de parar. **São duas formas de jogar o mesmo mago**, e é a Lei 2.

⚠️ **E o tecto que isto precisa:** absorver mana ao matar **não pode dar mais do que se gastou a matar**. Senão um feitiço barato que mata um inimigo fraco é mana infinita. **Regra: o ganho por morte tem tecto de 30% do custo do feitiço mais caro que tens equipado.** `→WP2`

---

## 6. ⚠️ O que isto obriga na interface — e é o custo real desta decisão

**Sem slots, levas 25 feitiços. E é aqui que a decisão do Mateus custa alguma coisa.**

⭐ **A restrição mudou de sítio:** deixou de estar na ficha da personagem e **passou a estar no ecrã**. Não se percorrem 25 feitiços a meio de um combate com uma tecla.

`→WP11` — **e isto é obrigatório, não é enfeite:**

| | |
|---|---|
| **Roda de feitiços** | segurar uma tecla abre uma roda; o rato escolhe; largar lança |
| **Favoritos** | 8 na roda, mudáveis **a qualquer momento**, não só no descanso |
| **`F` cicla** | dentro dos favoritos, não dentro dos 25 |
| ⚠️ **A roda abranda o tempo?** | ⚠️ **NÃO.** Abrandar o tempo para escolher é uma pausa disfarçada, e mata o combate |
| **Cor** | ⭐ vermelho e azul na roda ([`52`](52-mago-do-mal.md) §1) |

⚠️ **A linha de "não abranda o tempo" é a que faz isto continuar a ser um souls-like.** Abrir a roda tem de custar — ficas parado e vulnerável durante ~0,5 s. **Escolher o feitiço certo passa a ser uma decisão que se paga**, e não um menu grátis.

---

## 7. O que muda noutros documentos

| Documento | O que muda |
|---|---|
| [`39`](39-estudo-profundo.md) §7 | ⚠️ **REVOGADO** — o bolo de cargas partilhado dá lugar a mana + frascos separados |
| [`42`](42-estudo-magia.md) §3 | ⚠️ os **espaços de magia deixam de existir**; a tabela de 1→6 slots cai |
| [`42`](42-estudo-magia.md) §8 | o travão 1 (*"quem lança muito cura pouco"*) cai — **substituído pelo custo em tempo da meditação** |
| [`52`](52-mago-do-mal.md) | os feitiços passam a custar **mana**; a necromancia continua a custar **mana + PV** |
| [`12`](12-classes.md) | ganha a coluna **traço de classe** |
| [`20`](20-interface.md) | ⚠️ **roda de feitiços obrigatória** |
| [`11`](11-formulas.md) | **mana entra como atributo** |

⚠️ **O travão que cai é o mais importante desta lista.** O [`42`](42-estudo-magia.md) §8 tinha cinco regras para o mago não ser a classe correcta, e a primeira era *"a energia vem do mesmo bolo que a cura"*. **Essa deixou de existir.**

**Os outros quatro mantêm-se** (feitiços interrompíveis com tempo de voo · a escola do mal custa o dobro em níveis · reforços só um de cada vez · frágil ao perto), **e o novo é o tempo:** 40 segundos sentado, num mundo que não pára, com um parceiro à espera.

⭐ **E o Mateus já respondeu à pergunta 28 com isto, mesmo sem lhe chamar isso:** *"melhor tá apelão"*. **O mago é a classe mais forte, por decisão.** O que estas regras garantem não é que ele seja igual — é que **ser forte custe alguma coisa que se sente**.

## O que fica em aberto

| | |
|---|---|
| **O mago do mal é classe própria ou o feiticeiro com escola vermelha?** | ⏳ donos |
| Os traços das outras 5 classes — a proposta da §4 serve? | ⏳ donos |
| Quanto é a mana base, e quanto sobe por ponto | `→WP2` |
| A roda abre com que tecla, e quantos favoritos | `→WP11` |

## Ligações

[`52-mago-do-mal.md`](52-mago-do-mal.md) · [`53-chefes-ritmo-e-o-mago-forte.md`](53-chefes-ritmo-e-o-mago-forte.md) · [`42-estudo-magia.md`](42-estudo-magia.md) · [`39-estudo-profundo.md`](39-estudo-profundo.md) · [`12-classes.md`](12-classes.md) · [`20-interface.md`](20-interface.md) · [`11-formulas.md`](11-formulas.md)
