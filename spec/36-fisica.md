# 36 — Física, projécteis e matemática do mundo

`[DECIDIDO]` (Mateus, 31-07-2026) — *"tem que pensar bastante na física do jogo também... precisa sempre calcular física, calcular os efeitos, o que é que vai acontecer depois, a matemática e tudo certinho."*

**Era um buraco a sério.** Antes deste documento, a spec inteira não falava de gravidade, de projécteis, de dano de queda nem de empurrão. Todos os números do combate ([`01-combate.md`](01-combate.md)) assumem um mundo plano onde tudo acontece à distância certa — e não é assim que um jogo se comporta.

Tudo aqui é `[CLAUDE]` salvo indicação: pontos de partida para o protótipo do M2 validar.

---

## 1. As constantes do mundo

Tudo o resto pendura-se nestas. Mudar uma muda o jogo todo, por isso vivem num sítio só.

| Constante | Valor | Porquê |
|---|---|---|
| **Gravidade** | **−18 m/s²** | ~1,8× a real. Jogos usam gravidade exagerada porque a real (9,81) faz as quedas parecerem lentas e flutuantes |
| Altura do jogador | 1,8 m · olhos a 1,7 m | a câmara de 1.ª pessoa assenta aqui ([`29-perspectiva.md`](29-perspectiva.md)) |
| Velocidade terminal | 40 m/s | tecto de segurança para o motor |
| Passo máximo sem saltar | **0,45 m** | degraus e raízes até esta altura atravessam-se a andar; autoridade de integração: [`73`](73-fecho-dos-buracos-de-integracao.md) §2 |
| Inclinação máxima | 45° | acima disto escorrega-se |
| Massa do jogador | 80 kg base + equipamento | usada no empurrão |

⚠️ **Estes números vêm da gramática do género, não de medições.** São ponto de partida; o marco 2 valida-os a jogar.

---

## 2. Queda — a matemática, e o que ela obriga

Com gravidade a −18 m/s², a velocidade ao aterrar de uma altura `h` é `v = √(2 × 18 × h)`:

| Altura | Tempo de queda | Velocidade ao aterrar | Dano |
|---|---|---|---|
| 3 m | 0,58 s | 10,4 m/s | **0** — o limiar |
| 5 m | 0,75 s | 13,4 m/s | ~8% dos PV máximos |
| 8 m | 0,94 s | 17,0 m/s | ~25% |
| 12 m | 1,15 s | 20,8 m/s | ~55% |
| 16 m | 1,33 s | 24,0 m/s | ~90% |
| 20 m+ | 1,49 s | 26,8 m/s | **morte** |

⚠️ **SUBSTITUÍDA** — a tabela acima fica como registo do raciocínio. O modelo de parte fixa + proporcional do [`37`](37-aneis-e-elementos.md) foi depois fechado pelo contrato canónico do [`70`](70-fecho-dos-sistemas-de-combate.md) §1: zero até 5 m, dano progressivo abaixo de 20 m e **morte absoluta aos 20 m**.

*O expoente 1,6 é o que interessa:* faz as quedas pequenas serem quase inofensivas e as grandes serem fatais depressa, em vez de uma rampa linear que castiga cair de um degrau.

### O que a queda obriga

1. ⚠️ **CORRIGIDO:** era percentagem pura; passa a **fixo + proporcional abaixo do limiar fatal** ([`37`](37-aneis-e-elementos.md) §3, fechado pelo [`70`](70-fecho-dos-sistemas-de-combate.md) §1). **A Lei 1 vive no tecto absoluto dos 20 m**, que ignora vida, carga e equipamento.
2. **A carga afecta a queda** (confirmado na referência): mais peso, mais dano. Proposta: `dano_final = dano × (1 + carga_relativa × 0,4)` — um jogador com armadura pesada leva até 40% mais.
3. **Armaduras que cortam o dano de queda** ([`34-catalogo-e-comandos.md`](34-catalogo-e-comandos.md) §2c) aplicam-se **depois** da carga. Uma peça que dê −50% torna quedas de 12 m sobreviváveis, e isso é uma construção legítima: trocar defesa por mobilidade vertical.
4. **`→WP8`:** o traçado das zonas tem de conhecer estes números. Um desnível de 4 m é atalho; um de 20 m é morte. **Os atalhos que descem desenham-se com a tabela à frente**, não a olho.

---

## 3. Projécteis — a classe Batedor obriga a isto

O arco é `⬜` fatia 2, mas as regras escrevem-se agora porque a magia já os usa.

### Setas — balística a sério

`[CLAUDE]` — **as setas têm queda.** Não vão em linha recta.

| Parâmetro | Valor |
|---|---|
| Velocidade inicial | 55 m/s (puxada completa) · 30 m/s a meia puxada |
| Gravidade sobre a seta | −18 m/s² (a mesma do mundo) |
| Arrasto | desprezado — simplificação deliberada |

**Trajectória:** `y(t) = v₀·sen(θ)·t − 9·t²` · `x(t) = v₀·cos(θ)·t`

O que isto dá na prática, com tiro horizontal:

| Distância | Tempo de voo | Queda |
|---|---|---|
| 10 m | 0,18 s | 0,30 m |
| 20 m | 0,36 s | 1,18 m |
| 30 m | 0,55 s | 2,7 m |
| 50 m | 0,91 s | 7,4 m |

**Aos 30 m já se falha um alvo humano se se apontar a direito.** É isso que torna o arco uma perícia em vez de um clique — e é a resposta correcta ao problema que o WP1 identificou (*"se atacar de longe for seguro, ninguém esquiva nem apara"*).

⚠️ **A mira tem de mostrar isto.** Sem indicação da queda, o jogador não aprende — aprende que "o arco falha às vezes", que é frustração e não perícia. `→WP11`: retículo que sobe com a distância, ou linha de trajectória a puxar.

### Magia — deliberadamente diferente

| | Dardo | Ruína | Égide |
|---|---|---|---|
| Trajectória | recta, **sem queda** | arco alto até um ponto do chão | no próprio |
| Velocidade | 35 m/s | 20 m/s | — |
| A 20 m | 0,57 s de voo | 1,0 s | — |

*Porquê a magia não tem queda e a seta tem:* são ferramentas diferentes. A seta é precisão que se aprende; o dardo é fiável mas caro (gasta mana). Se ambas tivessem balística, a magia perdia a identidade — e o mago já é frágil ao perto.

⚠️ **Tudo o que voa pode ser interrompido a meio da conjuração** (WP1) e **tem tempo de voo**. Um inimigo que se mexa 3 m durante o voo do dardo esquiva-o por si — o que faz a distância ser uma leitura, não um clique garantido.

---

## 4. Empurrão e impacto

Quando um golpe acerta, além do dano há movimento. É metade da sensação de peso.

| Golpe | Empurrão no alvo | Recuo em quem bate |
|---|---|---|
| Leve | 0,3 m | 0 |
| Pesado | 0,8 m | 0,1 m |
| Machadão carregado | 1,5 m | 0,2 m |
| Bash de escudo | 1,2 m | 0 |
| **Parry acertado** | 0,5 m + cambaleio | 0 |

**Escala com a massa:** `empurrão_real = empurrão_base × (80 / massa_do_alvo)`. O brutamontes (≈200 kg) recua 40% do que um lanceiro (≈90 kg) recua. **Um chefe grande quase não recua** — e isso comunica peso sem precisar de dizer nada.

⚠️ **Empurrão perto de um precipício mata.** É a interacção entre este sistema e o da queda, e **é uma boa mecânica se for legível** — o WP8 deve desenhar arenas onde isso aconteça de propósito, com o bordo bem visível. O que não pode é ser surpresa num sítio onde o jogador não via o buraco.

---

## 5. Colisão e alcance — onde a matemática do combate se cumpre

Os números do WP1 (alcance 1,4 m da adaga, 2,3 m do machadão) só significam alguma coisa com uma definição de como se mede.

| | Forma | Nota |
|---|---|---|
| **Corpo** (leva dano) | cápsula, raio 0,35 m, altura 1,8 m | simples e barata (Lei 4) |
| **Arma** (dá dano) | varrimento de esfera ao longo da lâmina, nos frames activos | *sweep*, não ponto — senão atravessa alvos em golpes rápidos |
| Alcance efectivo | alcance da arma + 0,35 do corpo | um machadão de 2,3 m acerta a 2,65 m do centro do alvo |
| Frames activos | só nestes é que a arma tem colisão | WP1, por arma |

⚠️ **O varrimento é obrigatório, não opcional.** Uma arma que testa colisão só na posição de cada frame **atravessa** um inimigo fino num golpe rápido — o jogador vê a lâmina passar pelo corpo e não acontece nada. É o defeito que faz um combate parecer barato, e é barato de evitar se for feito desde o início.

---

## 6. O que a física custa (Lei 4)

Tudo isto corre numa máquina com 8 GB e gráficos integrados:

| Sistema | Custo | Decisão |
|---|---|---|
| Cápsulas e varrimentos | baixo | ✅ é o que usamos |
| Projécteis (poucos, simples) | baixo | ✅ |
| Corpos rígidos completos em tudo | **alto** | ❌ não |
| Tecido e cabelo simulados | alto | ❌ — animação assada |
| Destruição de cenário | alto | ❌ |

**Regra:** física é **para o combate e o movimento**. Adereços de cenário não caem, barris não rolam, capas não ondulam. Isso é enfeite que custa fotogramas, e fotogramas são justiça (Lei 4).

⚠️ **Passo fixo para o combate.** A física de combate corre a **60 Hz fixos**, independentemente dos fotogramas desenhados. Senão, num engasgo os números do WP1 mudam sozinhos — a esquiva de 317 ms deixa de ter 19 ticks. É a única forma de as janelas de frames significarem o mesmo sempre. `→WP14`

---

## O que fica em aberto

| | Onde |
|---|---|
| Validar todas estas constantes a jogar | WP15B, marco 2 |
| Como a mira do arco comunica a queda | WP11 |
| Quais das 12 arenas futuras usam precipícios | conteúdo WP7; os quatro sinais e a faixa segura já estão fechados no [`61`](61-arenas-de-chefe.md) |
| ~~Nadar, escalar, saltar: existem?~~ | ✅ sem verbos livres; passo automático ≤0,45 m e ligações verticais autoradas no [`73`](73-fecho-dos-buracos-de-integracao.md) §2 |
| ~~Massa de cada inimigo (para o empurrão)~~ | ✅ [`67`](67-catalogo-do-bestiario.md): 33 comuns + Vorgar, validada no arranque |

## Ligações

[`01-combate.md`](01-combate.md) · [`11-formulas.md`](11-formulas.md) · [`34-catalogo-e-comandos.md`](34-catalogo-e-comandos.md) · [`29-perspectiva.md`](29-perspectiva.md) · [`23-tecnico.md`](23-tecnico.md)
