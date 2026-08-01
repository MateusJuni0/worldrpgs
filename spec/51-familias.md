# 51 — WP5 camada 1: as famílias de arma, os escudos, as peças de armadura e os kits

> **Volta 3 · Fable** (31-07-2026). A camada que decide se o jogo é bom: **8 famílias de arma** (cada uma com a frase de onde é MÁ), **3 famílias de escudo**, **9 slots / 11 peças iniciais de armadura** e — instrução directa do Rico (31-07, ⏳ falta o Mateus) — **o kit inicial de cada classe** e as **regras de espólio de equipamento**. Base: [`41-estudo-armas-e-golpes.md`](41-estudo-armas-e-golpes.md) (ficha §9, golpes §1, interrupção §4) · [`48-arcos-bestas-escudos.md`](48-arcos-bestas-escudos.md) · [`46-coerencia-bioma-raca-item.md`](46-coerencia-bioma-raca-item.md). A camada completa está no [`68`](68-catalogo-de-armas-armaduras-e-aneis.md).
>
> ⭐ **Vive também em [`game/data/weapons.json`](../game/data/weapons.json), [`game/data/armor.json`](../game/data/armor.json) e no catálogo fechado [`equipment.json`](../game/data/equipment.json).** O motor valida família, kit, 88 golpes e todas as referências de espólio — qualquer fantasma impede o arranque.

---

## 1. Os 11 golpes — a grelha universal, e as excepções por família

O [`41`](41-estudo-armas-e-golpes.md) §1 manda cada família declarar os onze. **Sete não existiam em lado nenhum.** A tabela abaixo conserva as constantes; o [`68`](68-catalogo-de-armas-armaduras-e-aneis.md) §2 materializa agora as **88 células**, com pergunta e excepção por família:

| Golpe | Regra universal `[FABLE]` | Porquê |
|---|---|---|
| Leve · Pesado · Cadeia | os frames da ficha de família (§2) | já eram do WP1 |
| **Leve → pesado** | o pesado encadeado corta 25% do arranque | premeia ritmo, não spam |
| **Em corrida** | o leve com avanço de 2–3 m e +50% de dano de postura | ⭐ é o que torna a distância jogável |
| **A rolar** | o leve com arranque −4 f, MV ×0,85 | ⭐ faz a esquiva ser ofensiva |
| **A saltar** | o pesado com hiper-armadura nos frames activos | a única hiper-armadura universal |
| **De cima** (queda) | crítico da tabela dos quatro ([`39`](39-estudo-profundo.md) §5) | já estava |
| **Empurrão** | universal: 12+4+14 f, dano ~0, **quebra guarda** | [`41`](41-estudo-armas-e-golpes.md) §6 — sem ele o jogo é dois escudos a olhar |
| **Arte da arma** | 1 mão / 2 mãos, custa **mana**, **repõe a interrupção a 100%** | [`41`](41-estudo-armas-e-golpes.md) §8 · [`66`](66-catalogo-de-magia.md) |

⚠️ **O empurrão precisa da tecla** que o [`34`](34-catalogo-e-comandos.md) §2 já reservou — entra no mapa de fábrica do WP11.

---

## 2. As 8 famílias de arma

Formato: a ficha do [`41`](41-estudo-armas-e-golpes.md) §9. Frames a 60 fps, ancorados nas 5 armas medidas do WP1 (`weapons.json`). **A frase "onde é MÁ" é obrigatória — sem ela a família está listada, não desenhada.**

### 2.1 Espadas rectas — o padrão · **Fatia 1 ✅** (espada longa)

| | |
|---|---|
| **Onde é boa** | em todo o lado — é a régua contra a qual tudo se mede |
| ⭐ **Onde é MÁ** | onde qualquer especialista está: **nunca é a melhor arma numa situação lida.** Quem domina uma leitura ganha mais com outra família |
| Alcance · arco | 2,0 m · 100° |
| Leve | 16+6+18 f (0,67 s) · MV 1,0 · 18 sta |
| Interrupção · hiper-armadura | **14** · não tem |
| Contra-ataque · crítico | +30% base · normal |
| Arte (1 mão · 2 mãos) | estocada perfurante · golpe circular |
| Escala | força (médio) |

### 2.2 Adagas — as costas · **Fatia 1 ✅** (adaga)

| | |
|---|---|
| **Onde é boa** | crítico nas costas e depois do parry — **o multiplicador mais alto do jogo**; cadeia de 4 |
| ⭐ **Onde é MÁ** | de frente para armadura pesada: dano de interrupção 10 — **dez golpes** para interromper o que o espadão interrompe em três |
| Alcance · arco | 1,4 m · 70° |
| Leve | 12+4+14 f (0,50 s) · MV 0,55 · 12 sta |
| Interrupção · hiper-armadura | **10** · não tem |
| Contra-ataque · crítico | +30% · ⭐ **alto** |
| Arte | apunhalar (avanço) · dança de lâminas |
| Escala | destreza (forte) |

### 2.3 Pesadas de corte — o compromisso · **Fatia 1 ✅** (machadão)

| | |
|---|---|
| **Onde é boa** | interromper (31), varrer grupos, trocar no meio do golpe dele — a hiper-armadura é dela |
| ⭐ **Onde é MÁ** | contra quem não falha: 34 f de recuperação são **meio segundo de janela aberta** a cada erro. E em tectos baixos, o arco vertical não sai |
| Alcance · arco | 2,3 m · 140° |
| Leve | 24+8+26 f (0,97 s) · MV 1,5 · 28 sta |
| Interrupção · hiper-armadura | **31** · 2.ª metade do arranque + 1.ª metade dos activos ([`41`](41-estudo-armas-e-golpes.md) §4); carregado: frame 30 → fim dos activos (WP1) |
| Contra-ataque · crítico | +30% · normal |
| Arte | salto esmagador · rodopio |
| Escala | força (forte) |

### 2.4 Katanas — o tempo do inimigo `[FABLE]` — pedido directo do Mateus

| | |
|---|---|
| **Onde é boa** | ⭐ **a bater enquanto ele bate**: contra-ataque **+45%** (o +30% base e +15 da família), e o golpe em corrida mais forte do jogo (avanço 3 m) |
| ⭐ **Onde é MÁ** | nas mãos de quem não lê: sem contra-ataques é uma espada recta pior (MV 0,9). E contra armadura pesada, o corte fino entra mal |
| Alcance · arco | 2,1 m · 90° |
| Leve | 14+5+16 f (0,58 s) · MV 0,9 · 16 sta |
| Interrupção · hiper-armadura | **13** · não tem |
| Contra-ataque · crítico | ⭐ **+45%** · normal |
| Arte | iai (embainhar → corte instantâneo, o tempo de carga é a leitura) · corte duplo |
| Escala | destreza (forte) |

### 2.5 Hastes — a distância honesta `[FABLE]` (lanças e piques)

| | |
|---|---|
| **Onde é boa** | estocar a 2,8 m **com o escudo levantado** — a única família que ataca sem baixar a guarda; +40% de contra-ataque em estocada |
| ⭐ **Onde é MÁ** | colado ao corpo: dentro de 1,2 m os golpes **falham por dentro** — o inimigo que entra anula-a |
| Alcance · arco | 2,8 m · 30° (estocada) |
| Leve | 18+6+20 f (0,73 s) · MV 0,95 · 18 sta |
| Interrupção · hiper-armadura | **14** · não tem |
| Contra-ataque · crítico | **+40%** (estocada) · normal |
| Arte | varrimento baixo (derruba) · carga de lança |
| Escala | destreza (médio) |

### 2.6 Cajados — o conduto · **Fatia 1 ✅** (cajado)

| | |
|---|---|
| **Onde é boa** | é o que conjura ([`13-magia.md`](13-magia.md)) — e a pancada é o plano B sem custo de mana |
| ⭐ **Onde é MÁ** | como arma: MV 0,7, sem crítico, sem contra-bónus. **Um mago encostado à parede tem um pau na mão** |
| Alcance · arco | 1,8 m · 80° |
| Leve | 18+5+20 f (0,72 s) · MV 0,7 · 15 sta |
| Interrupção · hiper-armadura | **8** · não tem |
| Contra-ataque · crítico | +30% · normal |
| Arte | rajada de bruma (empurra, dano ~0) · conjuração firmada (a próxima magia não é interrompível) |
| Escala | inteligência (fraco) |

### 2.7 Arcos — a arma que é metade flecha `[FABLE]` sobre o [`48`](48-arcos-bestas-escudos.md) §1 · **fora da fatia** (WP0 `[DECIDIDO]`)

| | |
|---|---|
| **Onde é boa** | abrir o combate, cabeças (crítico automático), e **marcar para o parceiro** (flecha sinalizadora) |
| ⭐ **Onde é MÁ** | ao perto (a mirar anda-se devagar e **não se dispara em movimento**) — e **cada flecha custa**: a munição é finita e faz-se das colheitas de bioma ([`49`](49-biomas.md)) |
| Modos | engatado (rápido, impreciso) · mira (lento, preciso) |
| Interrupção | **8** por flecha comum |
| Munição (6 tipos) | comum · pesada · farpada (sangramento) · fogo · gelo · ⭐ sinalizadora (dano 0, marca o alvo) |
| Escala | destreza (médio) |
| ⚠️ Porque está fora da fatia | ataque à distância seguro mata a esquiva e o parry — entra pós-fatia, com o Batedor (WP0) |

### 2.8 Bestas — a Lei 3 em objecto `[FABLE]` sobre o [`48`](48-arcos-bestas-escudos.md) §2

| | |
|---|---|
| **Onde é boa** | ⭐ **nas mãos de toda a gente**: requisitos baixos e **zero escala** — o dano não depende de atributos. Uma mão: combina com escudo, arma ou cajado. É uma resposta à distância que não gasta mana |
| ⭐ **Onde é MÁ** | na cadência: **dois tempos** (carregar → disparar), e a recarga a meio do combate é um convite ao golpe |
| Interrupção | **16** por virote |
| A duas mãos | ganha mira ampliada |
| Escala | ⭐ **nenhuma** — é essa a família |

---

## 3. Os escudos — três famílias e o tecto que impede bloquear de graça

Adoptado do [`48`](48-arcos-bestas-escudos.md) §3, com os números dele:

| Família | Estabilidade | Peso | Parry | ⭐ Onde é MÁ |
|---|---|---|---|---|
| **Broquel** | ~50 | muito leve | **janela longa** (+2 f) | aguenta mal um pesado — a guarda parte depressa |
| **Escudo médio** · **Fatia 1 ✅** (madeira) | ~70 | médio | normal (8 f) | não brilha em nada — é o padrão |
| **Escudo grande** | **85 — tecto rígido** | pesadíssimo (tira a carga leve) | ⚠️ **não apara** | a escolha dói dos dois lados: sem parry, e sem esquiva leve |

Regras que valem para os três (`[FABLE]` = as do 48): estabilidade máxima **85** (bloquear custa **sempre**) · defesa física máxima **90%** (o piso de 30% vale para tudo) · **penalidade de espreitar** — atacar por trás do escudo perde absorção e estabilidade.

---

## 4. As 9 peças de armadura — slots, peso e a tensão resolvida

`[DECIDIDO]` (Mateus, [`33`](33-morte-e-almas.md)): armadura existe, **por peças**, e os inimigos largam partes do que usam. A tensão registada lá — *defesa plana é a parede de estatísticas que a Lei 1 recusa* — resolve-se aqui na direcção proposta:

> ⭐ **A armadura muda COMO se joga, nunca quanto se aguenta de graça:** peso e **resistências por tipo** (corte · contusão · perfuração · os 8 elementos dos biomas), com **tecto duro por peça**. Nada de "defesa +12".

### Os 9 slots

| # | Slot | Nota |
|---|---|---|
| 1 | Cabeça (elmo) | |
| 2 | Rosto (máscara) | separado da cabeça — dá identidade barata (o assassino é a máscara) |
| 3 | Ombros | |
| 4 | Peito | a peça de maior peso e tecto |
| 5 | Mãos | |
| 6 | Cintura (cinto) | o slot dos utilitários |
| 7 | Pernas | |
| 8 | Pés | |
| 9 | Capa | a peça de resistência elemental por excelência — e a mais visível de costas (3.ª pessoa) |

**Habilidade por peça, não por conjunto** (briefing): cada peça *pode* trazer uma passiva ou condicional — mas **as peças dos kits iniciais não trazem nenhuma** (o combate medido do WP1 não muda no dia 1). Habilidades entram na camada 2, peça a peça.

### As 3 classes de carga — e a linha que a Lei 1 não deixa cruzar

| Carga (% do limite) | Esquiva | Regeneração de stamina |
|---|---|---|
| **Leve** < 30% | 0,60 s, i-frames 0,08–0,38 | 40/s (integral) |
| **Médio** 30–70% | igual, **recuperação +4 f** | −10% |
| **Pesado** > 70% | igual, **recuperação +8 f** | ⭐ **−20%** ([`41`](41-estudo-armas-e-golpes.md) §5) |

⚠️ **Os i-frames nunca mudam.** A janela 0,08–0,38 s é a gramática que o jogador aprendeu — mexer-lhe com equipamento seria mudar a leitura por baixo dos pés dele (Lei 1). **O peso paga-se na recuperação e na regeneração** — quantas vezes seguidas se esquiva, não se a esquiva funciona. *Alternativa descartada:* "fat roll" da referência (janela menor com peso) — muda a leitura, e a leitura é sagrada aqui.

---

## 5. Os kits iniciais — instrução do Rico (31-07, ⏳ falta o Mateus)

> *"quando começar o jogo escolhemos uma classe tem que vim os items de inicio de acordo com a classe."*

A fatia já dava a arma ([`10-fatia-1.md`](10-fatia-1.md), `loadouts`); passa a dar o conjunto. Regras: material de **Brumal ou neutro** (o jogo começa lá — lei do [`46`](46-coerencia-bioma-raca-item.md) §4) · peças iniciais **sem habilidades** · todos os kits em carga **leve**, excepto o Tanque (**médio** — a identidade dele é sentir o peso). Frasco (3 usos) é universal.

| Classe | Armas | Peças | Carga |
|---|---|---|---|
| **Guerreiro** | espada longa + escudo de madeira | peitoral de couro fervido · botas de couro | leve |
| **Feiticeiro** | cajado | capa de lã encerada · cinto de bolsas | leve |
| **Tanque** | espada longa + escudo de madeira | elmo de ferro rude · peitoral de ferro rude | ⭐ **médio** |
| **Assassino** | **duas adagas** | máscara de pano escuro · botas de pano | leve |
| **Berserker** | machadão | ombreiras de couro com pelo — **e mais nada** (a pele à mostra é a identidade) | leve |
| **Paladino** | espada longa + escudo de madeira | peitoral de ferro polido · capa de lã clara | leve |

Cada peça tem `descrição visual` no [`armor.json`](../game/data/armor.json). **Fatia 1? ✅ nas 11 peças dos kits** — são as primeiras armaduras geradas.

Na criação, a classe selecciona este kit como **preset**, não como restrição futura: qualquer origem pode equipar qualquer peça/arma que encontre. O acento cosmético do [`64`](64-criacao-de-personagem.md) altera só a zona secundária permitida; material, silhueta, peso e estatísticas continuam a vir desta ficha.

---

## 6. O espólio de equipamento — as regras do Rico (31-07, ⏳ falta o Mateus)

| # | Regra | Onde aterra |
|---|---|---|
| 1 | ⭐ **Aleatório só nos inimigos comuns** — o baralho de 10 sem reposição ([`43`](43-estudo-espolio-inventario-mundo.md) §2) é deles | volta 5: baralhos por raça × bioma |
| 2 | **Chefes e baús têm espólio fixo, desenhado** — sem sorte no que importa | volta 7 (chefes) · volta 9 (baús) |
| 3 | ⭐ **Chefes largam as próprias peças, e equipam-se** — a armadura que se vê no chefe é a que cai | volta 7 define qual; o sistema de equipar é o §4 + ecrã do WP11 |
| 4 | ⭐ **A pool aleatória filtra pelo bioma** — cai o que existe no cenário onde se está | é a lei do [`46`](46-coerencia-bioma-raca-item.md) §4 com palavra de dono; a pool de uma zona = itens cujo material a ficha do bioma dá |
| 5 | **Menos almas por chefe já morto em co-op** | confirma a direcção do WP9 ([`18-progressao.md`](18-progressao.md): 40% + só materiais). O número fecha-se lá |

---

## 7. Melhoria e estados alterados — fechados pelo catálogo

✅ O [`68`](68-catalogo-de-armas-armaduras-e-aneis.md) §3–4 substitui esta proposta. A melhoria 0…6 abre **postura/moveset, arte, troca de escala ou conversão elemental** e nunca aumenta dano base. Veneno, sangramento e queimadura têm barra 0…100, decaimento, disparo, saída, som/visual equivalente e as mesmas regras para jogador e inimigo.

---

## 8. As quatro perguntas do fio solto

| | |
|---|---|
| **Como se usa?** | armas: teclas do WP1 já no jogo · empurrão e artes: teclas reservadas no [`34`](34-catalogo-e-comandos.md), entram no mapa de fábrica do WP11 · equipar peças: ecrã do WP11 — **em dados desde já**, marcado `_estado: "por implementar"` como as habilidades fizeram |
| **Como se prova?** | grupos 8 e 11 do `game_data.gd` + `self_test.gd`: famílias, 88 golpes, catálogos, estados, anéis, kits e referências WP6 |
| **De onde vem a arte?** | `descricao_visual` + `Fatia 1?` em todo o catálogo; 5 armas reutilizadas e 11 armaduras geradas; o resto espera |
| **Quanto custa?** | esta fatia: 11 ícones; futuro: runtime M2/WP11 e imagens apenas quando a coluna mudar |

## O que fica dito e não está provado

- **As 120 instâncias existem em catálogo, mas só cinco armas têm runtime/arte de Fatia 1** — os frames futuros `[FABLE]` afinam-se no protótipo como os do WP1.
- **O equipar não está implementado** — os dados existem e validam; o ecrã é do WP11, a mecânica entra no M2.
- Os 7 golpes universais novos (§1) estão declarados **sem protótipo** — o primeiro a implementar deve ser o **em corrida** (é o que muda mais o combate).

## Ligações

[`41-estudo-armas-e-golpes.md`](41-estudo-armas-e-golpes.md) · [`48-arcos-bestas-escudos.md`](48-arcos-bestas-escudos.md) · [`46-coerencia-bioma-raca-item.md`](46-coerencia-bioma-raca-item.md) · [`49-biomas.md`](49-biomas.md) · [`33-morte-e-almas.md`](33-morte-e-almas.md) · [`14-equipamento.md`](14-equipamento.md) · [`10-fatia-1.md`](10-fatia-1.md) · [`game/data/weapons.json`](../game/data/weapons.json) · [`game/data/armor.json`](../game/data/armor.json)
