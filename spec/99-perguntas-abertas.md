# 99 — Perguntas em aberto

Tudo o que falta decidir, por ordem de urgência. Serve de guião para a próxima gravação: passem por esta lista e a spec cresce sozinha.

**Regra:** tudo o que ainda estiver aqui quando a construção começar é uma decisão que vocês entregaram a quem constrói, sem saber.

---

## 🔴 Bloqueiam tudo o resto

### 0. Quais são as máquinas, ao certo?
`[DECIDIDO]` que é PC sem placa gráfica dedicada e ~12 GB de RAM. Mas "ou assim" não dá para orçamentar nada — nem polígonos, nem texturas, nem engine.

De **cada uma das duas máquinas**: processador, gráficos integrados (modelo exacto), RAM e se é canal simples ou duplo, SSD ou disco mecânico, resolução do ecrã, sistema operativo.

No Windows: `dxdiag` → *Guardar todas as informações*.

**Meio respondida (30-07-2026).** A máquina do Rico está medida; falta a do Mateus:

| | Máquina do Rico ✅ | Máquina do Mateus ⬜ |
|---|---|---|
| Processador | Intel Core i5-1334U (13.ª ger., 10 núcleos / 12 threads) | por medir |
| Gráficos | Intel Iris Xe (integrado, sem placa dedicada) | |
| RAM | **8 GB** — 2×4 GB DDR4-3200, **canal duplo** | |
| Disco | SSD NVMe, 256 GB | |
| Ecrã | 1920×1080 @ 60 Hz | |
| SO | Windows 11 Home 64-bit | |
| Comando | nenhum ligado — teclado+rato por agora | |

⚠️ **A restrição real é mais dura do que a Lei 4 assumia: 8 GB, não ~12.** O orçamento de WP12/WP13/WP14 aponta à mais fraca das duas máquinas. Do lado bom: o canal duplo é o melhor cenário para gráficos integrados, e o ecrã de 60 Hz faz de 60 fps o tecto útil.

→ [`09-tecnico.md`](09-tecnico.md)

### 0b. O 3D aguenta-se neste hardware?
`[TENSÃO]` registada: um souls-like vive de janelas de frames, e quedas de fotogramas não são feias, são **injustas** — atacam directamente o pilar 1. Três caminhos (3D estilizado optimizado / 2.5D / 2D), com recomendação de manter o 3D **e medir cedo**.
→ [`09-tecnico.md`](09-tecnico.md)

### 1. Qual é a fatia mais pequena disto que já é divertida a dois?
A sessão 1 descreveu mundo aberto grande, 3D, ~61 chefes, 8 classes, dois sistemas de magia, montarias e co-op sincronizado. Isso é anos de trabalho para uma equipa.

A pergunta não é "cortamos o quê". É: **se só existisse uma zona, um chefe e duas classes, isso já era um jogo que vocês queriam jogar?** Se sim, é por aí que se começa e o resto cresce por cima.

**→ Proposta escrita (WP0):** [`10-fatia-1.md`](10-fatia-1.md) — 1 zona + 1 dungeon + 1 chefe, 6 classes (instrução directa do Rico), 5 armas, 3 magias, co-op desde o dia 1. Falta o sim (ou a correcção) dos dois.
→ [`00-visao.md`](00-visao.md) · secção de risco

### 2. Os biomas são patamares de dificuldade?
"Por bioma, sei lá, nível, tipo" (12:18) choca de frente com o pilar "sem gating por nível". Ou o mapa tem zonas fechadas até se estar forte, ou pode ir-se a qualquer lado e morrer depressa. Não pode ser as duas.
→ [`05-mundo.md`](05-mundo.md), [`00-visao.md`](00-visao.md)

### 3. As evoluções de classe dão poder ou dão opções?
Se o mago nível 3 lança mais depressa que o nível 1, o nível está a dar vantagem — que é o que o pilar 1 recusa. O próprio Rico já apontou para o lado certo às 09:21 ("não aumentar o dano, uma magia diferente"). Falta confirmar como regra.
→ [`02-personagem.md`](02-personagem.md)

### 4. "Mapa grande" é quanto?
Sem uma referência concreta — minutos a atravessar a pé, ou um jogo conhecido como comparação — não dá para dimensionar mais nada.
→ [`05-mundo.md`](05-mundo.md)

---

## 🟠 Decidem o que se sente a jogar

### 5. Como funcionam os drops em co-op?
O Rico levantou a pergunta às 05:36 e ficou sem resposta (o áudio do Mateus falhou). Três hipóteses: cópia para cada um, filtrado por classe, ou partilhado com negociação.

*Entretanto, a fatia 1 joga com loot instanciado provisório `[FABLE]` — [`10-fatia-1.md`](10-fatia-1.md). A decisão final continua aqui.*
→ [`06-itens-inventario.md`](06-itens-inventario.md)

### 6. Os chefes ficam mais duros com dois jogadores?
Nunca foi mencionado. Se não ficarem, a resposta a qualquer chefe difícil passa a ser "chamar o outro", e o pilar 1 morre.

*Entretanto, a fatia 1 joga com vida do chefe ×1,8 a dois, provisório `[FABLE]` — [`10-fatia-1.md`](10-fatia-1.md).*
→ [`07-multiplayer.md`](07-multiplayer.md)

### 7. Como se recupera vida?
Frasco recarregável ao descansar, ou poções que se compram e acabam? Decide toda a tensão da exploração.
→ [`06-itens-inventario.md`](06-itens-inventario.md)

### 8. O que é que "magia do bem e do mal" faz mecanicamente?
Hoje é só um nome. Pode ser o sistema mais interessante do jogo, ou decoração.
→ [`03-magia.md`](03-magia.md)

### 9. Quantas classes no início?
Foram nomeadas 8. Como só jogam dois, a maior parte nunca vai ser jogada — mas todas custam trabalho.

**→ Respondida pelo Rico (30-07-2026, instrução directa): seis na fatia 1** — Guerreiro, Feiticeiro, Tanque, Assassino, Berserker, Paladino. O Batedor espera pelo arco; o Mago do mal, pela pergunta 8. Ver [`10-fatia-1.md`](10-fatia-1.md). Falta a palavra do Mateus.
→ [`02-personagem.md`](02-personagem.md)

### 10. O que acontece quando se morre?
Nunca falado. É a decisão que define o tom de um souls-like: perde-se o quê, volta-se para onde, os inimigos voltam?

*Entretanto, a fatia 1 joga com renascimento na entrada, nada perdido, retry < 30 s — provisório `[FABLE]`, [`10-fatia-1.md`](10-fatia-1.md). O tom definitivo decide-se aqui.*
→ [`01-combate.md`](01-combate.md)

---

## 🟡 Precisam de resposta antes de construir

11. **Números do combate** — janela de invencibilidade da esquiva, custos de stamina, janela de parry. Não se decidem em conversa; decidem-se a jogar um protótipo. → [`01-combate.md`](01-combate.md)
12. **Vida e Constituição fazem o quê, cada um?** Sobrepõem-se como estão. → [`02-personagem.md`](02-personagem.md)
13. **Hierarquia de chefes: 1+10+20+30 ou 1+30+20?** Os dois disseram versões diferentes e ficou por acertar (12:05). → [`04-inimigos-chefes.md`](04-inimigos-chefes.md)
14. **Existe armadura?** Não foi dita uma única vez. → [`06-itens-inventario.md`](06-itens-inventario.md)
15. **Estilo visual** — "realista não, mas tipo..." (10:24) ficou a meio da frase. → [`05-mundo.md`](05-mundo.md)
16. **Lock-on em alvo?** Muda o esquema de controlos inteiro. → [`01-combate.md`](01-combate.md)
17. **Engine.** → [`09-tecnico.md`](09-tecnico.md)
18. **Rede: P2P, relay ou servidor? E quem tem autoridade sobre o combate?** A segunda é a que magoa se for adiada. → [`09-tecnico.md`](09-tecnico.md)
19. **Arte 3D: comprar, gerar ou fazer?** Provavelmente o maior custo real. → [`09-tecnico.md`](09-tecnico.md)
20. **Fogo amigo em co-op?** → [`07-multiplayer.md`](07-multiplayer.md)

---

## Perdido no áudio

Estas ficaram sem registo porque o microfone do Mateus falhou. Se se lembrarem, vale a pena recuperar:

| Momento | O que se perdeu |
|---|---|
| 05:40–05:41 | A resposta do Mateus sobre drops por classe — a pergunta 5 desta lista |
| 10:44–10:56 | Um bloco inteiro de fala, logo a seguir a "como será que a gente faz o mundo?" — provavelmente a resposta à pergunta 15 |
| 07:41–07:49 | Fala durante a enumeração das classes — podem ter ficado classes por registar |
| 06:17–06:18 | Reacção ao fecho da regra das armas |
