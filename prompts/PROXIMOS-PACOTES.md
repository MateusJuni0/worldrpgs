# Fila de trabalho — os 11 pacotes que faltam

> **Para o Fable.** Onze pacotes, por ordem de valor. Cada um diz o que tem de responder, **o que investigar da referência antes de escrever**, o que herda das decisões de 31-07, e as lacunas que já sabemos que existem.
>
> Antes de qualquer um: **reserva no [`COORDENACAO.md`](../COORDENACAO.md)**, e lê [`../spec/31-referencias.md`](../spec/31-referencias.md) (o protocolo de investigação e a linha entre inspirar e copiar).

## O que mudou e afecta tudo o que falta

| Decisão (31-07) | Quem herda |
|---|---|
| **Soft gating** — mapa aberto, dificuldade sugerida | WP6, WP7, WP8 |
| **Mapa ~30 min, 10+ biomas** | WP8 (densidade, reutilização, viagem rápida) |
| **Evoluções: opção A** — opções, não números; por marco | WP3 já escrito, WP9 |
| **Magia bem/mal aprovada** — preço em PV | WP4 já escrito, WP5 |
| **1.ª ou 3.ª pessoa à escolha** | WP6 (som direccional), WP8 (dois FOVs), WP11, WP12 (viewmodel) |
| **Barra visual: DS2, não PS1** — 8–15 mil tri | WP12, WP14 |
| **Tom sombrio a sério · português · PC** | todos |

---

## 🔴 Primeiro — desbloqueiam outros e alimentam as imagens

### WP6 — Bestiário · `spec/15-inimigos.md`

**O que responde:** cada inimigo do jogo, com o que faz e como se lê.

Por inimigo: nome, raça, onde aparece, vida, dano, postura, comportamento, e **a telegrafia de cada ataque** — que aviso dá, quantos frames, se é `aparável` ou `só esquiva`. Sem isto, esquiva e parry não funcionam e a Lei 1 cai.

**Investigar:** como um jogo do género constrói o vocabulário de telegrafia — o que sinaliza um golpe rápido contra um lento, como o jogador aprende a distinguir sem ninguém lhe dizer. E o padrão do **inimigo de elite no mundo aberto**: o adversário duro fora de arena que serve de exame.

**Herda:**
- **Soft gating:** nenhum inimigo verifica nível · o perigo comunica-se pela leitura · **fugir tem de funcionar sempre** (correr é grátis e mais rápido que qualquer patrulha — WP1)
- **1.ª pessoa:** sem visão periférica, **todo o ataque tem de ser anunciado por som direccional antes de entrar no campo de visão**
- As **7 raças aprovadas** (goblin, kobold, esqueleto, zumbi, orc, minotauro, mímico) e a regra: cada inimigo declara **que conceito ensina ou que combinação examina** ([`27-aprendizagem.md`](../spec/27-aprendizagem.md) §2)
- Do WP1: ≥ 0,5 s de aviso legível em todo o ataque · postura 0–100 por inimigo

**⚠️ Faz este primeiro** — é o que desbloqueia as próximas imagens (7 conceitos de raça, ~14 créditos).

### WP7 — Chefes · `spec/16-chefes.md`

**O que responde:** a hierarquia acertada, e o Vorgar ao pormenor.

**Investigar:** como as fases funcionam de verdade — o que muda na segunda (padrões, alcance, ritmo) e o que **não** muda (mais vida não é fase). Desenho de arena: tamanho, obstáculos, onde o jogador respira. E quantos chefes um jogo do género tem de facto, para calibrar os nossos ~61.

**Herda:** a hierarquia por acertar (1+10+20+30 ou 1+30+20 — pergunta 13) · **o Ceifador aprovado** com os ganchos já escritos · chefes a dois com vida ×1,8 (provisório do WP0) · nenhum chefe verifica nível.

**Lacuna conhecida:** ~61 chefes é mais do que a maioria dos jogos do género tem. Não é para cortar — é para dizer quantos na fatia 2 e como crescem.

### WP5 — Equipamento · `spec/14-equipamento.md`

**O que responde:** o catálogo de armas com requisitos e escala, armadura, e como se cura.

**Investigar:** como as armas se agrupam em **famílias que partilham conjunto de movimentos** — é assim que se tem variedade sem animar cada uma de raiz, e é directamente aplicável às nossas 5. E como uma arma comunica "não és tu que a usas" **sem a proibir** — é a nossa Lei 3, e eles resolveram-na antes.

**Herda:** Lei 3 · as 5 armas do WP1 com frames e MV já fixados · requisitos de atributo do WP2.

**⚠️ Duas lacunas a sério, ambas tuas:**
1. **Melhoria de armas não existe na spec.** Nesses jogos é um sistema inteiro — materiais, níveis, onde se faz. Decide se existe.
2. **Estados alterados** (veneno, sangramento, queimadura) **nunca foram mencionados**, e são parte grande do género.

Mais: **armadura** — nunca foi dita uma única vez na sessão 1 (pergunta 14, aberta) · **como se cura** (pergunta 7, aberta) — frasco recarregável ou poções finitas muda todo o ritmo da exploração.

---

## 🟠 Depois — dependem dos de cima

### WP8 — Mundo e mapa · `spec/17-mundo.md`

**Investigar:** **interligação e atalhos** — como um mapa grande se sente pequeno quando os caminhos se cruzam. É o que decide se os nossos 30 min a pé são exploração ou caminhada. E colocação de pontos de descanso: distância entre eles e o que isso faz à tensão.

**Herda:** ~30 min a pé, 10+ biomas · **soft gating** · três obrigações já escritas em [`05-mundo.md`](../spec/05-mundo.md): densidade mínima por zona, estratégia de reutilização de peças, viagem rápida · **dois FOVs** (55° e 90°) · tectos ≥ 2,5 m em espaços de combate (regra da câmara).

### WP9 — Progressão, loot e economia · `spec/18-progressao.md`

**Investigar:** o que se perde ao morrer e como se recupera — é a **pergunta 10**, aberta, e é a decisão de tom do jogo inteiro. Curva de custo de subir de nível. Como os consumíveis se estruturam.

**Herda:** evoluções opção A · loot instanciado (provisório) · recompensa reduzida ao ajudar (12:34).

### WP10 — Multiplayer e rede · `spec/19-rede.md`

O sistema mais complexo do jogo, descrito numa frase da gravação.

**Herda:** progresso individual em mundo partilhado · sessão de anfitrião (provisório do WP0) · **a decisão de autoridade cliente/servidor é a que fica cara se for adiada** — num souls-like com janelas de 133 ms, a autoridade errada dá parries que parecem acertar e não acertam.

### WP11 — Interface e configurações · `spec/20-interface.md`

**Herda:** HUD tem de funcionar **nas duas perspectivas** — em 1.ª pessoa o ecrã está mais cheio e os indicadores ganham peso porque não há corpo a mostrar estado · slider de tremor de ecrã (acessibilidade, WP1B) · a divergência do parry (`Q` vs toque de `RMB`) fecha aqui ou no protótipo.

### WP12 — Arte, render, efeitos e som · `spec/21-arte-render.md`

**Herda:** barra DS2, 8–15 mil tri ([`30-qualidade-visual.md`](../spec/30-qualidade-visual.md)) · **viewmodel de 1.ª pessoa com conjunto de animações separado** — o inventário de ~55 animações da fatia cresce, é preciso recontar · legibilidade vence beleza · o som é meio caminho da leitura em 1.ª pessoa.

---

## 🟡 Fecho

### WP14 — Arquitectura técnica · `spec/23-tecnico.md`
Engine decidida pela Lei 4 primeiro. **A perspectiva dupla pesa:** a engine tem de tornar barato manter dois conjuntos de animação de combate.

### WP15 — Plano de construção · `spec/24-plano.md`
O marco 1 é o teste de desempenho na máquina do Rico — e é ele que dá a prova que falta à pergunta 0b.

### WP15B — Testar e equilibrar · `spec/28-testes.md`
**Herda:** se o teste mostrar que é mais difícil vencer em 1.ª pessoa, o problema é de feedback e corrige-se em som e interface — **nunca a baixar a dificuldade** ([`29-perspectiva.md`](../spec/29-perspectiva.md)).

---

## A regra que vale para os onze

**Inspira-te na estrutura. Não copies o conteúdo.**

Se consegues explicar o padrão sem dizer o nome do jogo, é padrão — adopta. Se precisas do nome, é conteúdo — não entra. E nunca metas no repositório imagens, modelos, sons, texto ou tabelas extraídas de outro jogo: isto é público.

O objectivo da comparação **não é ficar parecido com eles.** É encontrar o que não nos ocorreu, e depois resolvê-lo à nossa maneira, com as nossas quatro leis.
