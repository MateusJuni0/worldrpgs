# LACUNAS — o que falta, e ninguém está a fazer

**Actualizado: 31-07-2026.** Mantido pelo **Claude**. É a lista de tudo o que foi identificado como buraco e **ainda não tem dono**.

> **Porque existe:** as lacunas que eu encontro a rever viviam em **comentários de PR**. Um comentário lê-se uma vez e desaparece — e uma lacuna esquecida é uma lacuna que se descobre no fim, quando custa dez vezes mais.
>
> ⭐ **A regra:** encontrei uma lacuna → escrevo-a aqui **no mesmo acto**. Quando alguém a resolve, risca-se com o commit ao lado.

**Legenda:** 🔴 trava alguma coisa · 🟠 devia entrar na volta indicada · 🔵 quando houver tempo · ⏳ é dos donos, não dos agentes

---

## 🔴 Travam

*(nenhuma neste momento — nada impede o trabalho de continuar)*

---

## 🟠 Para as voltas que aí vêm

### Volta 2 — fichas de raça 🔨 *em curso*

| | Lacuna | Origem |
|---|---|---|
| 🟠 | ⚠️ **A linha "porque está neste bioma"** é a única que liga a raça ao mapa, e é a que se salta. A resposta tem de sair de uma ficha de bioma já escrita | [`46`](spec/46-coerencia-bioma-raca-item.md) §5 |
| 🟠 | **Em que biomas cada raça aparece, e o que muda em cada variante** — e a variante tem de mudar **como se luta**, não só a cor | [`46`](spec/46-coerencia-bioma-raca-item.md) §7 |
| 🟠 | ⚠️ **Santuário Branco e A Raiz** são os dois biomas mais fáceis de deixar sem raça própria. Sem habitante próprio são cenários, não lugares | revisão do PR #14 |
| 🟠 | **Mímicos e Minotauros** estão na lista de raças, mas um é armadilha e o outro é subchefe. A ficha de 8 linhas não lhes assenta | [`15`](spec/15-inimigos.md) |

### Volta 3 — armas e armaduras

| | Lacuna | Origem |
|---|---|---|
| 🟠 | **Os 7 golpes por declarar** — cadeia de leves, leve→pesado, em corrida, a rolar, a saltar, de cima, empurrão | [`41`](spec/41-estudo-armas-e-golpes.md) §1 |
| 🟠 | **Melhoria de armas** — reforço e infusão. Nunca foi escrita | [`35`](spec/35-estudo-referencia.md) §6 |
| 🟠 | **Estados alterados** — veneno, sangramento, queimadura. Nunca mencionados | [`35`](spec/35-estudo-referencia.md) §5 |
| 🟠 | **Requisitos de atributo** — quanto é "não és tu que a usas" sem proibir (Lei 3) | [`41`](spec/41-estudo-armas-e-golpes.md) |
| 🟠 | **Duas armas ao mesmo tempo, uma em cada mão** — existe no nosso jogo? | [`41`](spec/41-estudo-armas-e-golpes.md) |
| 🔵 | **Como a mira do arco comunica a queda da flecha** — sem isso o jogador aprende "o arco falha às vezes" | [`36`](spec/36-fisica.md) §3 |

### Volta 4 — magia

⭐ **A escola vermelha já está desenhada** — [`52-mago-do-mal.md`](spec/52-mago-do-mal.md), feita pelo Claude a pedido do Mateus (é o personagem dele). O WP4 herda-a; **não a reescreve.**

| | Lacuna | Origem |
|---|---|---|
| ⏳ | **As 6 perguntas do Mateus sobre o mago do mal** — instrumento, nº de invocados, custo do chefe, chefe portátil ou não, que feitiços cortar, e se o Voto de Sangue entra | [`50`](spec/52-mago-do-mal.md) §10 |
| 🟠 | **Quem manda nos invocados em co-op?** *(proposta: quem os levantou)* | [`50`](spec/52-mago-do-mal.md) §9 |
| 🟠 | **Inimigos que lançam magia usam as mesmas regras?** *(proposta: sim, incluindo ser interrompíveis)* | [`42`](spec/42-estudo-magia.md), [`48`](spec/48-arcos-bestas-escudos.md) |
| 🟠 | **Quantos feitiços na fatia 1** *(proposta: 3 — dano, cura, utilidade)* | [`42`](spec/42-estudo-magia.md) |
| 🟠 | **O material de melhoria de feitiço é o mesmo das armas, ou outro?** | [`42`](spec/42-estudo-magia.md) §6 |

### Volta 5 — bestiário

| | Lacuna | Origem |
|---|---|---|
| 🟠 | ⚠️ **O som que anuncia cada ataque** — obrigatório pela regra da 1.ª pessoa, e continua por escrever em todas as fichas | [`38`](spec/38-ataques-e-honestidade.md) §3 |
| 🟠 | **Massa de cada inimigo**, para o empurrão | [`36`](spec/36-fisica.md) §4 |
| 🟠 | **Almas por inimigo, e o total por zona** — com o tecto de 10 reaparições, cada zona tem orçamento fixo | [`40`](spec/40-decisoes-espolio-magia-inventario.md) §2 |

### Volta 7 — chefes

| | Lacuna | Origem |
|---|---|---|
| 🟠 | ⚠️ **Desenho de arena de chefe** — tamanho, obstáculos, onde o jogador se refugia. **Sem cobertura nenhuma** | [`48`](spec/48-arcos-bestas-escudos.md) |
| 🟠 | **Um subchefe pode ser fugido de vez, ou reaparece?** | [`46`](spec/46-coerencia-bioma-raca-item.md) §6 |
| 🟠 | **Arenas com precipícios** — quais, e como se sinaliza o bordo | [`36`](spec/36-fisica.md) §4 |

### Volta 8 — sistemas

| | Lacuna | Origem |
|---|---|---|
| 🟠 | **A curva de nível é linear, devia ser cúbica** · **"XP" devia ser "almas"** | [`35`](spec/35-estudo-referencia.md) §3 |
| 🟠 | ⚠️ **Sistema de saves** — onde vive o progresso, e como funciona a dois. **Sem cobertura** | [`48`](spec/48-arcos-bestas-escudos.md) |
| 🟠 | **Lock-on em 1.ª pessoa** — duas opções propostas, nenhuma escolhida | [`29`](spec/29-perspectiva.md) |
| 🟠 | **A cura à distância funciona com que latência?** | [`42`](spec/42-estudo-magia.md) |

### Volta 9 — mundo

| | Lacuna | Origem |
|---|---|---|
| 🟠 | **Nadar, escalar, saltar: existem?** Nunca foram mencionados | [`36`](spec/36-fisica.md) |
| 🟠 | ⚠️ **O traçado das zonas e o orçamento de memória desenham-se juntos** — um atalho entre zonas distantes obriga a ter as duas prontas | [`43`](spec/43-estudo-espolio-inventario-mundo.md) §6 |

---

## 🔵 Quando houver tempo

| | Lacuna | Origem |
|---|---|---|
| 🔵 | ⚠️ **A conversão visual, passos 1–3** — luz, névoa e gradação de cor. **Custa horas e vale mais do que trocar modelos** | [`47`](spec/47-do-greybox-ao-visual.md) §4 |
| 🔵 | **Capturas em todo o marco** — o critério que impede o visual de parar sem ninguém dar por isso | [`47`](spec/47-do-greybox-ao-visual.md) §5 |
| 🔵 | **Os 11 documentos antigos não trazem tabela `eles·nós·diferença` nem citam fontes** | [`31`](spec/31-referencias.md) |
| 🔵 | **Economia de vendedores** — a loja vende conveniência, nunca poder | [`39`](spec/39-estudo-profundo.md) §11 |
| 🔵 | **Validar as constantes de física a jogar** (marco 2) | [`36`](spec/36-fisica.md) |

---

## ⏳ Dos donos — não são para os agentes resolverem

Estão no [`99-perguntas-abertas.md`](spec/99-perguntas-abertas.md). As três que mais mudam o jogo:

| # | | |
|---|---|---|
| **28** | ⚠️ Se a magia faz tudo, como é que o mago não é a classe correcta? | cinco travões propostos |
| **24** | Chefe a dois: +40% de vida ou zero? | proposta: +40%, e desce quando um morre |
| **22** | Se os inimigos param de reaparecer, de onde vêm as almas para o nível 100? | ou o mundo é maior, ou o 100 não é para uma passagem |

E as **7 perguntas de narrativa** ([`26`](spec/26-narrativa.md) §3), que precisam de uma gravação — **o nome do jogo incluído**.

---

## ✅ Fechadas

| Lacuna | Fechada em |
|---|---|
| ~~O código vive fora do repositório~~ | PR #13 |
| ~~A medição 0b não tem artefacto~~ | PR #12 *(metade — falta a animação de esqueleto)* |
| ~~Arcos, bestas e escudos sem mecânica~~ | [`48`](spec/48-arcos-bestas-escudos.md) |
| ~~6 zonas contra 10+ biomas~~ | PR #14 — **12 biomas** |
| ~~Quantos chefes ao todo~~ | PR #14 — **61, derivado do mapa** |
| ~~O parry tem dois botões~~ | [`45`](spec/45-controlos-configuraveis.md) — controlos configuráveis |
| ~~Sem sistema de interrupção~~ | [`39`](spec/39-estudo-profundo.md) §4 · [`41`](spec/41-estudo-armas-e-golpes.md) §4 *(escrito; falta implementar)* |
| ~~Espólio sem garantia~~ | [`43`](spec/43-estudo-espolio-inventario-mundo.md) §2 — o baralho de 10 |
