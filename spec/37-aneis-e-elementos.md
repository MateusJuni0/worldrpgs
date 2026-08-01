# 37 — Anéis e elementos

`[DECIDIDO]` (Mateus, 31-07-2026) — o sistema de anéis, os tipos de dano, e a correcção ao dano de queda.

---

## 1. Anéis

`[DECIDIDO]` — **~70 anéis. Até 10 equipados, um por dedo. Cada um com uma habilidade própria.**

`[DECIDIDO]` — **cerca de 10 por classe**, com sabor da classe, **mas qualquer classe os pode usar**. É a Lei 3 estendida aos anéis: sem trancas, só afinidades.

`[DECIDIDO]` — **serem criativos e não se repetirem.** Alguns podem somar-se entre si.

### Como isto se compara com a referência

| | Referência (DS2) | Nós |
|---|---|---|
| Anéis equipados | **4** | **10** |
| Total | ~100 | ~70 |
| Efeitos típicos | recuperação de stamina, carga, dano de postura, durabilidade | **70 verbos no [`68`](68-catalogo-de-armas-armaduras-e-aneis.md) §7** |

**Fonte:** [Rings — DS2 Wiki](https://darksouls2.wiki.fextralife.com/Rings)

### ⚠️ O problema dos 10 dedos, e como se resolve

Dez espaços com 70 anéis significa que o jogador usa **14% do catálogo ao mesmo tempo**. Isso tem uma consequência matemática inevitável: **ou cada anel é pequeno, ou o personagem vira uma pilha de bónus** e a Lei 1 morre — deixa de ganhar quem lê o inimigo e passa a ganhar quem juntou os dez anéis certos.

Não é razão para reduzir o número. É razão para desenhar com cuidado:

**Regra 1 — os dedos ganham-se, não vêm de graça** `[CLAUDE]`

Começar com **2 espaços** e ganhar os outros ao longo do jogo (chefes, segredos, exploração). Isto dá três coisas de uma vez:
- O poder cresce a par do conteúdo, em vez de tudo de uma vez
- **Cada dedo novo é uma descoberta**, que é exactamente o que o Mateus quer do jogo
- O equilíbrio dos primeiros combates não tem de assumir dez anéis

**Regra 2 — nenhum anel dá mais de 10% de nada**

Com 10 espaços, um anel de +20% torna-se +200% em conjunto. O tecto por anel mantém o total num sítio onde a perícia continua a decidir.

**Regra 3 — a maioria muda *como* se joga, não *quanto*** (Lei 2)

Um anel que dá "+8% de dano" é preenchimento. Um anel que faz o rolamento ser mais longo mas gastar mais stamina **muda decisões**. A proporção alvo `[CLAUDE]`: no máximo um terço de números, o resto verbos.

**Regra 4 — soma-se, mas com regra escrita**

Dois anéis do mesmo efeito somam-se; três do mesmo efeito **não**. Sem isso, o jogador que encontra três anéis de stamina quebra o sistema de stamina inteiro.

### Os oito eixos onde os anéis podem viver

Para o WP5 ter onde começar, sem repetir:

| Eixo | Exemplos de verbo |
|---|---|
| **Recursos** | stamina regenera mais depressa · mais mana máxima/recuperada · frascos curam mais |
| **Movimento e física** | rolamento mais longo mas mais caro · menos dano de queda · passos silenciosos |
| **Combate defensivo** | janela de parry maior mas mais castigo ao falhar · guarda quebra mais tarde |
| **Combate ofensivo** | mais dano de postura · costas do inimigo dão mais · primeiro golpe do combate |
| **Risco** | mais forte com pouca vida · mais forte sem armadura · mais forte sozinho |
| **Almas** | ganha mais almas · não as perde ao morrer uma vez · vê as manchas de longe |
| **Elementos** | resistência ou conversão de dano — ver §2 |
| **Co-op** | ressuscitar mais depressa · o parceiro cura ao teu lado · vês o que ele vê |

⚠️ **O eixo de co-op é o mais interessante e o mais fácil de esquecer.** O jogo é para dois; anéis que só fazem sentido a dois dão razão para jogarem juntos que não é só "é mais fácil".

⚠️ **Todos passivos ou condicionais** — a regra dos comandos ([`34-catalogo-e-comandos.md`](34-catalogo-e-comandos.md) §2). Nenhum anel gasta tecla.

### ✅ O que o WP5 entregou

O [`68`](68-catalogo-de-armas-armaduras-e-aneis.md) §7 entrega as 70 linhas: nome · eixo · efeito em verbo · números · afinidade de classe · **soma com outro?** · onde se encontra · descrição visual · `Fatia 1?`. Os oito eixos aparecem, nenhum efeito se repete e nenhum anel consome tecla.

**A coluna "onde se encontra" é o que faz o jogo do Mateus.** Um anel que se compra é uma linha na tabela; um anel que está atrás de um chefe opcional ou num sítio que só se descobre à quinta partida **é uma memória**. É disso que ele falou quando disse *"dá para zerar aquele jogo quinze vezes e ainda estás a descobrir coisas"*.

---

## 2. Elementos e tipos de dano

`[DECIDIDO]` (Mateus, 31-07-2026) — **não é só físico e mágico.** Entram **fogo, raio, veneno, escuridão e magia do mal**.

### O modelo, e o que a referência ensina

Lá, o dano divide-se em **físico** (com subtipos: corte, perfuração, contundente) e **elemental** (mágico, fogo, raio). Cada tipo tem a sua defesa. Uma arma pode dar **físico + elemental ao mesmo tempo**.

**Fontes:** [Damage Types — DS Wiki](https://darksouls.wiki.fextralife.com/Damage+Types) · [Physical Damage Types](https://dark-souls-remastered.fandom.com/wiki/Physical_Damage_Types)

### A nossa tabela `[CLAUDE]`

| Tipo | Quem o dá | Forte contra | Fraco contra |
|---|---|---|---|
| **Corte** | espadas, adagas, machados | carne desprotegida | esqueletos, armadura pesada |
| **Contundente** | machadão, martelos, bash | **esqueletos**, armadura | criaturas moles |
| **Perfuração** | lanças, estoques | fendas de armadura | massas grandes |
| **Fogo** | encantamentos, magia | **zumbis**, criaturas de floresta | criaturas de fogo |
| **Raio** | paladino, encantamentos | **armadura metálica** | criaturas de tempestade |
| **Veneno** | adagas, armadilhas de kobold | vivos | **mortos-vivos: imunes** |
| **Escuridão** | magia do mal | criaturas de luz | criaturas das trevas |
| **Mágico** | magia do bem | genérico, poucas fraquezas | resistências mágicas |

⚠️ **Isto liga-se directamente ao bestiário.** A regra do WP6 é que **a fraqueza se lê no corpo** — o zumbi escorre (arde bem), o esqueleto é osso seco (parte-se ao contundente, ri-se do corte), o morto-vivo não sangra nem envenena. **A tabela acima é a mecânica por trás daquilo que já se via no desenho.** `→WP6` tem de a alinhar ficha a ficha.

### Escudos por elemento

`[DECIDIDO]` — **os escudos diferem por elemento.** Há escudos melhores contra magia, contra fogo, contra raio.

Na referência, quase todos os escudos bloqueiam **100% do físico**, e o que os distingue é **quanto de cada elemento deixam passar**, mais a estabilidade (quanta stamina custa aguentar). Adoptamos o mesmo:

| | Escudo de madeira (fatia 1) | Escudo pesado | Escudo mágico |
|---|---|---|---|
| Físico | 100% | 100% | 90% |
| Fogo | 40% | 60% | 50% |
| Raio | 40% | 30% | 50% |
| Mágico | 30% | 40% | **90%** |
| Estabilidade (custo de stamina) | alta | baixa | média |

*Números `[CLAUDE]` de partida.* **A decisão de desenho que importa:** nenhum escudo é bom em tudo. Escolher escudo passa a ser **ler a zona onde se vai entrar**, que é o mesmo princípio da armadura por resistências ([`33-morte-e-almas.md`](33-morte-e-almas.md) §3).

⚠️ **A magia do mal já tem preço em PV** (WP4, decidido). O elemento **escuridão** é o dano que ela faz; **não é um segundo preço.** Não somar castigos.

`→WP5` catálogo de escudos e armas elementais · `→WP4` alinhar as escolas com os elementos · `→WP6` fraquezas ficha a ficha

---

## 3. ✏️ Correcção: o dano de queda

`[DECIDIDO]` (Mateus, 31-07-2026) — **subir de nível tem de fazer diferença nas quedas.** Nível 1 e nível 55 a saltar do mesmo sítio não podem ter o mesmo resultado.

### O que estava errado, e porquê

O [`36-fisica.md`](36-fisica.md) escreveu o dano de queda como **percentagem pura dos PV máximos**, o que faz o nível não valer absolutamente nada nas quedas. A justificação era a Lei 1.

**Estava mal aplicada.** A Lei 1 diz que o nível não abre portas — não tranca conteúdo, não deixa passar um chefe que a perícia não passa. **Sobreviver a uma queda não é conteúdo trancado.** Investir em Vida e notar isso ao cair de um sítio alto é progressão a funcionar, não a Lei 1 a quebrar.

### O modelo corrente — parte fixa + parte proporcional, com limiar fatal absoluto

`dano = fixo(h) + proporcional(h) × PV_máximos`, interpolado entre os nós abaixo. O [`70`](70-fecho-dos-sistemas-de-combate.md) §1 e `progression.json` são a autoridade executável:

| Altura | Fixo | Proporcional | Resultado |
|---|---|---|---|
| até 5 m | 0 | 0% | **0** |
| 8 m | 45 | 10% | dano progressivo; Vida muda a margem |
| 12 m | 90 | 20% | dano progressivo; Vida muda a margem |
| 16 m | 150 | 32% | dano progressivo; Vida muda a margem |
| **20 m+** | — | — | **morte absoluta**, antes de vida, carga ou equipamento |

### O que este modelo dá

- **Abaixo de 20 m:** Vida faz diferença na margem de erro, como o Mateus decidiu
- **Aos 20 m:** ninguém sobrevive, em nível nenhum. É isto que impede vida/equipamento de abrirem atalhos topológicos — e é aqui que a Lei 1 se aplica

E continua verdade que:
- **A carga aumenta o dano** (`×(1 + carga_relativa × 0,4)`)
- **As peças de armadura que cortam a queda** aplicam-se depois da carga, mas apenas abaixo de 20 m; nunca alteram o limiar fatal

**Substitui** a tabela de percentagem pura do [`36-fisica.md`](36-fisica.md) §2.

---

## 4. Distinção de poder — o que o Mateus quer sentir

*"tem que ter bastante distinção de poder"* e *"dá para zerar aquele jogo quinze vezes e ainda estás a descobrir coisas"*.

Isto não é um sistema — é um critério que vale para tudo o que se escrever a seguir. Três coisas fazem-no acontecer, e nenhuma é "números maiores":

1. **Distinção vem de verbos, não de escalas.** Um jogador de nível 55 não deve sentir-se "20% mais forte" — deve sentir-se **capaz de coisas que antes não era**. Rolamentos que agora chegam, quedas que agora se sobrevivem, elementos que agora se aproveitam, dedos que agora tem.
2. **A descoberta está em *onde*, não em *quantos*.** 70 anéis numa loja são uma lista. 70 anéis espalhados por sítios que só se encontram jogando de maneiras diferentes são o jogo que ele descreveu. **A coluna "onde se encontra" é a mais importante do catálogo.**
3. **Classes diferentes têm de ver mundos diferentes.** Se o Batedor e o Berserker encontram o mesmo em sítios diferentes, a rejogabilidade é falsa. Se há sítios que só um alcança — um patamar que só se chega com o rolamento longo, um inimigo que só o veneno mata a tempo — aí sim.

`→` vale para WP5, WP6, WP7, WP8 e WP9. **Escreva-se cada catálogo a perguntar: "isto dá razão para voltar cá com outra classe?"**

---

## Nota: a stamina já existe

O Mateus perguntou pela stamina. **Está feita e completa** no [`01-combate.md`](01-combate.md): 100 de base, regeneração de 40/s após 0,8 s, 10/s a bloquear, custos por acção (esquiva 25, parry 10, sprint 8/s, ataques por arma), e Guarda Quebrada quando chega a zero a absorver um golpe.

---

## Ligações

[`36-fisica.md`](36-fisica.md) · [`34-catalogo-e-comandos.md`](34-catalogo-e-comandos.md) · [`33-morte-e-almas.md`](33-morte-e-almas.md) · [`14-equipamento.md`](14-equipamento.md) · [`15-inimigos.md`](15-inimigos.md) · [`35-estudo-referencia.md`](35-estudo-referencia.md)
