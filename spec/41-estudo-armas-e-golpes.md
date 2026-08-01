# 41 — Estudo: armas, golpes, e o que separa uma família da outra

> Estudo feito a 31-07-2026, a pedido do Mateus: *"nada é uma animação, tudo é calculado."* Números reais, com fonte. Protocolo do [`31-referencias.md`](31-referencias.md) — **estrutura, nunca conteúdo**.

**A pergunta a que este documento responde:** *o que é preciso declarar para que duas armas sejam mesmo diferentes, e não a mesma arma com outro modelo?*

---

## 1. O vocabulário de golpes — o que existe em cada arma

Antes de falar de famílias, é preciso saber **quantos golpes uma arma tem**. Na referência, cada arma traz este conjunto — e é o mesmo conjunto para todas, o que muda é o que cada entrada faz:

| Golpe | Como se faz lá | Nós |
|---|---|---|
| **Leve** | toque no ataque | `LMB` ✅ |
| **Pesado** | ataque forte | `Shift+LMB` ✅ |
| **Cadeia leve** | leves seguidos, animação diferente do 1.º | ✅ [`68`](68-catalogo-de-armas-armaduras-e-aneis.md) §2 |
| **Leve → pesado** | encadeamento com propriedades próprias | ✅ [`68`](68-catalogo-de-armas-armaduras-e-aneis.md) §2 |
| **A duas mãos** | conjunto **inteiro** diferente | ✅ decidido ([`34`](34-catalogo-e-comandos.md) §2b) |
| **Em corrida** | golpe próprio, fecha distância | ✅ [`68`](68-catalogo-de-armas-armaduras-e-aneis.md) §2 |
| **A rolar** | golpe próprio, sai do rolamento | ✅ [`68`](68-catalogo-de-armas-armaduras-e-aneis.md) §2 |
| **A saltar** | golpe próprio, tem hiper-armadura | ✅ [`68`](68-catalogo-de-armas-armaduras-e-aneis.md) §2 |
| **De cima** (queda) | crítico, é um dos quatro ([`39`](39-estudo-profundo.md) §5) | ✅ [`68`](68-catalogo-de-armas-armaduras-e-aneis.md) §2 |
| **Pontapé / empurrão** | quebra a guarda de quem bloqueia | ✅ [`68`](68-catalogo-de-armas-armaduras-e-aneis.md) §2 |
| **Arte da arma** | 1 mão e 2 mãos, custa **mana** — “energia” foi revogada pelo [`54`](54-mana-meditacao-e-tracos-de-classe.md) | ✅ alinhado no [`66`](66-catalogo-de-magia.md) |

✅ **As sete linhas foram declaradas família a família no [`68`](68-catalogo-de-armas-armaduras-e-aneis.md).** Não são enfeite: **o golpe em corrida é o que torna a distância jogável**, e **o golpe a rolar é o que faz a esquiva ser ofensiva** em vez de só defensiva. O runtime dos sete continua no M2.

`→WP1`/`→WP5` — **cada família declara os onze.** Se um não existe naquela família, escreve-se *"não tem"* e diz-se porquê.

**Fontes:** [Weapon Types (DS3) — Dark Souls Wiki](https://darksouls.fandom.com/wiki/Weapon_Types_(Dark_Souls_III)) · [Weapons — DS3 Wiki](https://darksouls3.wiki.fextralife.com/Weapons)

---

## 2. As famílias — o que as separa mesmo

Isto é a resposta directa ao *"espada gigante e espada curta têm de bater diferente"*. Na referência, cada família tem uma **identidade funcional**, não um número:

| Família | O que a define lá | A pergunta que ela responde |
|---|---|---|
| **Katana** | *meio-termo de alcance e velocidade, **dano de contra-ataque muito alto**, ataques em corrida fortes*; corta **e** estoca | *consegues bater no momento em que ele ataca?* |
| **Espada recta** | equilíbrio; o padrão contra o qual tudo se mede | — |
| **Espada curva** | **menos alcance, mais rápida**; boa em espaço apertado e contra alvos leves; **fraca contra armadura pesada** | *consegues encher de golpes antes de ele reagir?* |
| **Espada grande** | *arco largo, boa para **apanhar quem se mexe muito*** | *consegues apanhar dois de uma vez?* |
| **Espadão** | *tem de acertar; se falha, fica exposto a contra-ataque pesado*; **o melhor contra-ataque das armas pesadas** | *consegues ler o momento certo uma vez só?* |
| **Estoque** | ignora armadura pesada; feito para **interromper o ataque dele** | *consegues punir o arranque?* |
| **Adaga** | dano baixo, ⭐ **multiplicador crítico escondido, mais alto** | *consegues chegar às costas?* |

### ⭐ O que isto nos ensina, e é a regra que faltava

**Nenhuma destas famílias é definida por "dá mais dano".** Cada uma é definida por **uma situação onde é a melhor** — e, implicitamente, por todas as outras onde não é.

A espada curva é **explicitamente má** contra armadura pesada. A adaga tem dano mau e crítico bom. O espadão castiga quem falha. **É isto que faz escolher arma ser uma decisão em vez de uma tabela.**

⭐ **A regra de aceitação para o nosso catálogo** `→WP5`:

> **Cada família tem de trazer uma frase que diz onde é MÁ.** Se não se consegue escrever essa frase, a família não está desenhada — está só listada.

*E é aqui que se cumpre o pedido das katanas:* a nossa katana não é "a espada fixe". É **a arma de quem ataca no tempo do inimigo** — bónus de contra-ataque alto, alcance médio, e forte em corrida. Quem não sabe ler o ataque do inimigo tem uma arma medíocre nas mãos. **Isso é "muita habilidade" em forma de mecânica.**

**Fontes:** [Katanas — DS3 Wiki](https://darksouls3.wiki.fextralife.com/Katanas) · [Thrusting Swords — DS3 Wiki](https://darksouls3.wiki.fextralife.com/Thrusting%20Swords) · [Weapon Types (DS3)](https://darksouls.fandom.com/wiki/Weapon_Types_(Dark_Souls_III))

---

## 3. ⭐ Contra-ataque — o mecanismo que premeia a coragem

### Como funciona lá

> **Um golpe que acerta num inimigo que está a meio do ataque dele faz +30% de dano.**

E há uma camada em cima: em alguns jogos da série o bónus aplica-se **só a golpes de estocada**, e há um anel que o leva a ~68% no total.

### O que isto nos ensina

⭐ **É a peça mais elegante do combate inteiro, e nós não a temos.**

Pensa no que ela faz. O jogo já te ensina a **recuar** quando o inimigo ataca. O contra-ataque diz: *há uma resposta melhor, e é mais difícil* — bater **enquanto** ele bate, aceitando que se falhares o tempo levas o golpe todo.

**Isso é a Lei 1 em estado puro:** não é um número que se compra, é uma leitura que se aprende. E premeia exactamente o que o Mateus quer do espadachim.

**Contrato corrente**, fechado pelo [`70`](70-fecho-dos-sistemas-de-combate.md) §3:

| | |
|---|---|
| Bónus | **×1,30**, apenas em golpes marcados `perfuracao`; haste ×1,40; katana ×1,45 só na estocada |
| Quando | o golpe perfurante acerta durante os frames activos do ataque do alvo |
| Quem não recebe | corte, contusão, flecha sem tag e magia |
| ⚠️ Como se vê | **som e faísca próprios** — senão o jogador nunca aprende que existe |

⚠️ **A última linha é obrigatória.** Um bónus invisível não ensina nada — é sorte, do ponto de vista de quem joga. Cláusula 4 do contrato ([`38`](38-ataques-e-honestidade.md)).

**Fontes:** [DS3 mechanics cheat sheet](https://github.com/gastevens/dark-souls-3-mechanics-cheat-sheet/blob/master/ds3mechanicscheatsheet.md) · [Counter Damage — Dark Souls Wiki](https://darksouls.wiki.fextralife.com/Counter+Damage) · [Counter Attack](https://darksouls.fandom.com/wiki/Counter_Attack)

---

## 4. Dano de interrupção por família — os números

Liga ao sistema do [`39`](39-estudo-profundo.md) §4. **Estes números são o que faz uma arma pesada sentir-se pesada:**

| Família | Dano de interrupção (golpe leve) |
|---|---|
| Adaga | **10** |
| Espada recta · pique · chicote | **14** |
| Espada grande | **26** |
| Espadão | **31** |
| Martelo grande | **35** |
| *Espadão, encadeamento pesado* | **65,1** |

Contra uma vida de interrupção de **100**, lê-se assim: **três golpes de espadão** interrompem quem não tem armadura; **dez golpes de adaga**.

E a fórmula da armadura: `dano_recebido = dano_do_outro × (1 − armadura/100)`.

### ⭐ E onde ficam os frames de hiper-armadura

> **Na segunda metade do arranque e na primeira metade dos frames activos.**

⭐ **Isto é preciso e é bonito.** A hiper-armadura **não** cobre o ataque todo — cobre **o meio**, o momento em que já estás comprometido e ainda não acertaste. **É exactamente a janela em que o jogador precisa de protecção**, e nem um frame a mais.

`→WP5` — **coluna obrigatória por família:** dano de interrupção, e em que frames tem hiper-armadura.

**Fonte:** [DS3 mechanics cheat sheet](https://github.com/gastevens/dark-souls-3-mechanics-cheat-sheet/blob/master/ds3mechanicscheatsheet.md)

---

## 5. Stamina — os números que governam tudo

| | Referência | Nós hoje |
|---|---|---|
| Regeneração base | **45/s** | ⬜ |
| Tecto útil | **160** aos 40 de atributo | ⬜ |
| Acima de ~70% de carga | **37/s** — cerca de **20% menos** | ⬜ |
| Pode ir a negativo | até **−60** antes de recuperar | ⬜ |
| Mínimo para agir | **1 ponto chega** para executar uma acção |

### ⭐ As duas linhas do fim são desenho, não detalhe

**"1 ponto chega para agir"** significa que **nunca ficas bloqueado a olhar**. Consegues sempre dar aquele último golpe ou aquela última esquiva — e depois pagas, ficando a zero. ⭐ **Transforma a stamina de uma parede numa dívida**, e uma dívida é muito mais interessante: dá para arriscar.

**E o negativo até −60** é o castigo por abusar: quanto mais fundo vais, mais tempo ficas parado.

**Proposta `[CLAUDE]` `→WP1`** — adoptar os três: regeneração fixa, **1 ponto chega para agir**, e negativo com tecto.

⚠️ **E a interacção com a carga**, que já vinha do [`39`](39-estudo-profundo.md) §3: **estar pesado tira ~20% da regeneração.** É esse o custo real da armadura pesada — não é a esquiva, é **quantas vezes seguidas se pode esquivar**.

**Fonte:** [DS3 mechanics cheat sheet](https://github.com/gastevens/dark-souls-3-mechanics-cheat-sheet/blob/master/ds3mechanicscheatsheet.md)

---

## 6. Bloqueio, estabilidade e quebra de guarda

**A fórmula:** `stamina_perdida = dano_de_stamina × (1 − estabilidade/100)`

**A quebra de guarda acontece de duas formas:**
1. Um golpe próprio de **empurrão** contra quem está a bloquear
2. **Esgotar a stamina** de quem bloqueia

### O que isto nos ensina

⭐ **O escudo não é "menos dano" — é uma troca de recurso.** Converte dano em stamina. E quando a stamina acaba, **a guarda parte-se e ficas exposto** — o que dá ao bloquear um risco próprio, em vez de ser a opção segura por defeito.

⚠️ **O empurrão é a peça que impede o jogo de ser dois escudos a olhar um para o outro.** Sem ele, bloquear não tem resposta. Com ele, tem. `→WP1` — **o empurrão precisa de tecla** ([`34`](34-catalogo-e-comandos.md) §2), e é das poucas coisas que **justifica gastar uma**.

**Fontes:** [DS3 mechanics cheat sheet](https://github.com/gastevens/dark-souls-3-mechanics-cheat-sheet/blob/master/ds3mechanicscheatsheet.md) · [Guard Break](https://darksouls.wiki.fextralife.com/Counter+Damage)

---

## 7. Reforços temporários na arma

| | Como é lá |
|---|---|
| Fonte | consumível que se passa na lâmina, **ou** feitiço |
| Duração | **90 s** para os consumíveis |
| Força | o do feitiço **escala** com o cajado; o do consumível é fixo |
| ⚠️ Regra | **só um reforço de cada vez por arma**. Duas armas nas mãos → cada uma o seu |
| Trancas | armas já elementais por natureza **não se reforçam** |

### O que isto nos ensina

⭐ **"Só um de cada vez" é o que impede o jogo de virar uma lista de preparativos.** Sem essa regra, o combate óptimo é passar 30 segundos a acumular reforços antes de cada porta — o que não é jogo, é ritual.

⭐ **E dá uma vantagem real ao mago sem lhe dar números:** o reforço dele **escala** com o cajado, o do guerreiro é fixo. Isso é a §6 do [`40`](40-decisoes-espolio-magia-inventario.md) — a magia é mais **vasta**, e paga-se noutro sítio.

`→WP5`/`→WP4` — adoptar as três regras, **90 s**.

**Fontes:** [Weapon Buffs — DS2 Wiki](https://darksouls2.wiki.gg/wiki/Weapon_Buffs) · [Weapon Augmentation](https://darksouls.fandom.com/wiki/Weapon_Augmentation)

---

## 8. Artes de arma — o que se sabe agora

Já decidido em [`34`](34-catalogo-e-comandos.md) §2b (uma tecla, arte diferente a 1 e a 2 mãos). O que o estudo acrescenta:

| | Como é lá |
|---|---|
| Custo | **mana**, da mesma reserva dos feitiços ([`54`](54-mana-meditacao-e-tracos-de-classe.md), [`66`](66-catalogo-de-magia.md)) |
| ⭐ Interrupção | a arte **repõe a vida de interrupção a 100%**; um ataque normal só repõe a 80% |
| Redução de custo | existe equipamento que corta **30%** ao custo das artes |

⭐ **A linha do meio é a mais importante, e explica para que serve uma arte.** Não é só um golpe especial: é **o golpe que aguenta**. Repor a 100% significa que a arte é o que se usa **quando se quer trocar** — levar o golpe dele para meter o nosso. É a Lei 2 numa mecânica.

`→WP5` — **coluna obrigatória:** custo em mana, e o que a arte faz à vida de interrupção.

**Fonte:** [DS3 mechanics cheat sheet](https://github.com/gastevens/dark-souls-3-mechanics-cheat-sheet/blob/master/ds3mechanicscheatsheet.md)

---

## 9. A ficha de família — o que o WP5 tem de produzir

Juntando tudo, **nenhuma família entra no catálogo sem isto**:

| Campo | Exemplo |
|---|---|
| Nome da família | — |
| ⭐ **Onde é boa** | uma frase |
| ⭐ **Onde é má** | uma frase — **obrigatória** (§2) |
| Alcance · arco | 1,8 m · 90° |
| Os 11 golpes (§1) | frames de cada, ou *"não tem"* |
| Custo de stamina por golpe | — |
| **Dano de interrupção** | 14 |
| **Frames de hiper-armadura** | 2.ª metade do arranque + 1.ª metade dos activos, ou *"não tem"* |
| **Bónus de contra-ataque** | `nenhum` ou multiplicador de `CONTRA_PERFURANTE`: ×1,30 base · haste ×1,40 · katana/estocada ×1,45 |
| **Multiplicador crítico** | normal / alto |
| Arte a 1 mão · a 2 mãos | verbo + custo |
| Atributo que escala | — |
| Aceita reforço temporário? | ✅/❌ |
| **Fatia 1?** | ✅/⬜ |

---

## O que fica por estudar

| | Onde |
|---|---|
| Arcos e bestas: mira, tipos de munição, puxada | `→WP5`, e a balística já está no [`36`](36-fisica.md) §3 |
| Armas de duas mãos ao mesmo tempo (uma em cada) | `→WP1` — existe no nosso jogo? |
| Escudos: quantos, e a estabilidade de cada | `→WP5` |
| Requisitos de atributo: quanto é "não és tu que a usas" sem proibir (Lei 3) | `→WP5` |

## Ligações

[`40-decisoes-espolio-magia-inventario.md`](40-decisoes-espolio-magia-inventario.md) · [`39-estudo-profundo.md`](39-estudo-profundo.md) · [`38-ataques-e-honestidade.md`](38-ataques-e-honestidade.md) · [`34-catalogo-e-comandos.md`](34-catalogo-e-comandos.md) · [`01-combate.md`](01-combate.md) · [`14-equipamento.md`](14-equipamento.md)
