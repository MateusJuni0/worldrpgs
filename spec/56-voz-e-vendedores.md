# 56 — Voz no co-op, e os vendedores

`[DECIDIDO]` (Mateus, 01-08-2026):

> *"Não esquece de ligar microfone e tal para o co-op, um túnel bom, presta atenção para não ficar dando erro, interferência ou assim."*
>
> *"Tem que ter também os vendedores para vender todas as magias do jogo, ou todas as armaduras, poções, elixir e essas coisas todas, itens e etc. Igual no Dark Souls."*

---

# PARTE A — Voz

## 1. A decisão, e é mais fácil do que parece

**Já temos a ligação.** O [`19-rede.md`](19-rede.md) decidiu ligação directa entre os dois (plano B: VPN de amigos tipo Tailscale). **A voz vai pelo mesmo cano** — não é infra-estrutura nova, é mais um canal na que já existe.

| | |
|---|---|
| **Transporte** | o mesmo da rede do jogo — **canal separado, não fiável** *(a voz atrasada não se repete: deita-se fora)* |
| **Codec** | **Opus**, 24 kbps mono. É o padrão para voz e o Godot suporta-o |
| **Largura de banda** | ~3 KB/s por pessoa — **irrelevante** ao lado do estado do jogo |
| **Latência alvo** | < 150 ms boca a ouvido |

⭐ **A voz é o tráfego mais barato do jogo.** O que custa é a qualidade, e é aí que está o teu aviso.

---

## 2. ⚠️ "Não ficar dando erro, interferência" — as quatro causas, e a resposta a cada uma

**Isto é o pedido, e cada problema tem uma solução conhecida. Nenhuma é opcional.**

| Problema | O que se ouve | A resposta |
|---|---|---|
| ⭐ **Eco** | ouves-te a ti próprio meio segundo depois | ⚠️ **cancelamento de eco obrigatório** — é o defeito nº1, e vem de o microfone apanhar as colunas |
| **Ruído de fundo** | ventoinha, teclado, rua | **supressão de ruído** + porta de ruído |
| ⭐ **Corte / robô** | a voz parte-se aos bocados | ⚠️ **buffer de jitter adaptativo** de 40–120 ms. Sem ele, qualquer variação de rede parte a frase |
| **Microfone aberto** | ouve-se tudo o que se passa na sala | ⭐ **push-to-talk por defeito**, com voz-activada como opção |

⚠️ **O cancelamento de eco é o que separa "voz que funciona" de "voz que se desliga ao fim de 10 minutos".** Se um dos dois joga com colunas em vez de auscultadores — e joga — sem cancelamento **o outro ouve-se a si próprio a toda a hora**. É insuportável e é a razão nº1 pela qual as pessoas voltam ao Discord.

**A regra que resolve 90% de graça:** ⭐ **auscultadores recomendados no ecrã, na primeira vez que se liga a voz.** Custa uma linha de texto e evita o problema todo.

---

## 3. ⭐ E a ideia que faz a voz valer mais do que o Discord

**Se a voz vive dentro do jogo, pode saber onde tu estás.**

| | Discord | ⭐ Voz no jogo |
|---|---|---|
| De onde vem o som | dos dois lados, sempre igual | ⭐ **da direcção onde o parceiro está** |
| Quando ele se afasta | igual | ⭐ **fica mais longe e mais abafada** |
| Quando leva um golpe | ele diz | ⭐ **ouves o grunhido dele **e** o som do golpe, do mesmo sítio** |
| Atrás de uma parede | igual | ⭐ **abafada — e sabes que ele está do outro lado** |

⭐ **Isto é enorme para um souls-like e custa quase nada** — o motor já tem áudio posicional para tudo o resto ([`21-arte-render.md`](21-arte-render.md)). É pôr a voz do parceiro numa fonte 3D em vez de num canal plano.

**O que dá:** perdes o parceiro numa zona escura e **ouves de que lado ele está**. Ele grita e tu sabes se é ao pé ou ao longe. **Isso é informação de jogo, não é conversa.**

⚠️ **Com um travão, e é de segurança:** tem de haver **um botão que volta a pôr a voz plana**. Se a voz posicional falhar ou incomodar, não se pode ficar sem conseguir falar com o amigo. `→WP11`

---

## 4. O que fica decidido

| | |
|---|---|
| **Voz integrada**, pelo mesmo canal da rede | `[DECIDIDO]` |
| **Opus mono**, canal não fiável, jitter buffer adaptativo | `[CLAUDE]` `→WP10` |
| ⚠️ **Cancelamento de eco, supressão de ruído e push-to-talk** — os três obrigatórios | `→WP10` |
| ⭐ **Voz posicional**, com botão para a pôr plana | `[CLAUDE]` `→WP10`/`→WP11` |
| **Aviso de auscultadores** na primeira ligação | `→WP11` |
| ⚠️ **Se a voz falhar, o jogo continua** — nunca é dependência | regra |

---

# PARTE B — Vendedores

## 5. ⚠️ O pedido choca com uma regra já escrita — e a referência resolve

**O Mateus quer vendedores que vendam "todas as magias do jogo, ou todas as armaduras, poções, elixir".**

⚠️ **E o [`39-estudo-profundo.md`](39-estudo-profundo.md) §11 diz o contrário:** *"a loja vende conveniência, nunca poder. Se se compram armas boas, o jogo passa a ser sobre acumular almas — que é grind, que é a Lei 1 quebrada."*

**Os dois têm razão, e a referência tem a resposta.**

## 6. ⭐ O mecanismo: o vendedor vende o que TU encontraste

Na referência, um vendedor não nasce com o catálogo cheio. **Tu encontras um livro, um saco de cinzas, um pergaminho — e entregas-lho. A partir daí ele vende aquilo.**

⭐ **Isto dá ao Mateus exactamente o que ele quer, sem quebrar nada:**

| | |
|---|---|
| **Compra-se tudo?** | ⭐ **sim, no fim** |
| **Está tudo à venda no início?** | ❌ **não** |
| **O que desbloqueia?** | ⭐ **encontrar o tomo no mundo** |
| **O que se ganha com almas?** | a **segunda** cópia, e a conveniência |
| **A Lei 1 aguenta?** | ✅ **o gate é exploração, não almas** |

**O ciclo:**

```
exploras ──► encontras o TOMO DAS CINZAS numa dungeon
                      │
                      ▼
         entregas ao vendedor
                      │
                      ▼
   ⭐ ele passa a vender as 6 magias dessa escola
                      │
                      ▼
      compras com almas as que quiseres
```

⭐ **E repara no que isto faz ao mundo:** o tomo que encontras **não é um feitiço — são seis**. Encontrar um tomo é um dos melhores achados do jogo, e é conteúdo escondido que **vale muito e custa pouco de produzir**.

## 7. Os vendedores — quem são e o que vendem

`[CLAUDE]` `→WP9`. **Poucos, com identidade, e cada um só sabe de uma coisa:**

| Vendedor | Vende | Desbloqueia-se com |
|---|---|---|
| **O Caldeireiro** | frascos, elixires, consumíveis | está no ponto de descanso desde o início |
| **A Escriba** | ⭐ **magias**, por escola | os **tomos** de cada escola |
| **O Ferreiro** | melhoria de armas, material comum | está desde o início |
| **O Trapeiro** | armadura, e **recompra o que largaste** | encontrá-lo numa zona |
| ⭐ **O Coveiro** | ⚠️ **só ao mago do mal** — material de necromancia, relicários | encontrá-lo n'A Raiz |

⚠️ **E a regra que os mantém honestos, que é o [`39`](39-estudo-profundo.md) §11 intacto:**

> **Nenhum vendedor vende a melhor coisa da sua categoria.** O melhor de tudo **encontra-se**. O que se compra é **a base larga** — e a base larga é o que o Mateus quer, e é justo que se compre.

⭐ **Assim compram-se as 6 magias de uma escola, mas a sétima — a boa — está numa parede falsa** ([`43`](43-estudo-espolio-inventario-mundo.md) §4).

## 8. ⚠️ E o problema das almas, que isto levanta

**Com o tecto de 10 reaparições** ([`40`](40-decisoes-espolio-magia-inventario.md) §1), **cada zona tem um orçamento fixo de almas.** Se houver muito para comprar, o orçamento não chega — e o jogador fica preso sem poder farmar.

⭐ **A resposta, e resolve a pergunta 22 de caminho:**

| | |
|---|---|
| **O que se compra é barato** | um feitiço da base larga custa o equivalente a ~15 inimigos |
| ⭐ **Vender também dá almas** | o espólio repetido do baralho ([`43`](43-estudo-espolio-inventario-mundo.md) §2) **vende-se** — e é aí que ele deixa de ser lixo |
| **Subir de nível continua a ser o buraco fundo** | é onde as almas devem doer |
| ⚠️ **O `→WP9` tem de somar** | *quantas almas existem numa zona × quanto custa tudo o que lá se pode comprar* |

⭐ **A segunda linha é a peça que faltava:** o baralho de espólio garante que apanhas tudo — mas apanhas **repetido**. **Vender o repetido é o que transforma a garantia numa economia.**

---

## O que fica em aberto

| | |
|---|---|
| Voz: **Godot faz isto nativamente ou precisa de biblioteca?** | `→WP14` — a validar |
| **Os vendedores morrem?** Na referência alguns morrem e perde-se o stock | ⏳ donos |
| **O Coveiro só serve o mago do mal — isso é gating de classe?** | ⚠️ **provavelmente sim.** Rever contra a Lei 3 |
| Preços concretos, e o total comprável por zona | `→WP9` |

## Ligações

[`19-rede.md`](19-rede.md) · [`39-estudo-profundo.md`](39-estudo-profundo.md) · [`43-estudo-espolio-inventario-mundo.md`](43-estudo-espolio-inventario-mundo.md) · [`54-mana-meditacao-e-tracos-de-classe.md`](54-mana-meditacao-e-tracos-de-classe.md) · [`52-mago-do-mal.md`](52-mago-do-mal.md) · [`18-progressao.md`](18-progressao.md) · [`20-interface.md`](20-interface.md)
