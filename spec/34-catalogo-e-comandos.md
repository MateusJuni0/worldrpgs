# 34 — A escala do catálogo, e a regra dos comandos

`[DECIDIDO]` (Mateus, 31-07-2026) — a dimensão do equipamento, e uma regra de processo que vale para o projeto inteiro.

> ⚠️ **TENSÃO POSTERIOR:** o alvo decidido abaixo era **~30 armaduras**. O catálogo [`68`](68-catalogo-de-armas-armaduras-e-aneis.md) cresceu para **68 peças** ao resolver os 57 IDs visíveis prometidos pelo bestiário, além das 11 iniciais. Nenhum agente transforma esse aumento em nova decisão: a pergunta 44 do [`99`](99-perguntas-abertas.md) pede aos donos que aceitem 68 ou mandem consolidar IDs.

---

## 1. A escala

| | Alvo | Na fatia 1 |
|---|---|---|
| **Armaduras** | **~30**, alvo original decidido; catálogo corrente 68 em `[TENSÃO]` | 11 peças |
| **Armas** | **~20 por classe** | 5 partilhadas |

`[DECIDIDO]` — **toda a armadura tem uma habilidade ou uma identidade visual própria.** Nenhuma peça existe só para dar +2 de defesa.

As habilidades podem ser defesa, sorte, ou o que fizer sentido — o critério é que **cada peça responda a "porque é que eu usaria esta e não outra?"** com algo que não seja um número maior.

### O que isto obriga

Com 6 classes, 20 armas por classe são **120 armas**. Mais **~30 armaduras no alvo original**; as 68 correntes aguardam a pergunta 44. É um catálogo grande, e fica registado como decisão consciente, com duas condições:

1. **Famílias que partilham conjunto de movimentos.** 120 armas não são 120 conjuntos de animação. São talvez 8 famílias (espada, machado, lança, adaga, cajado, arco, martelo, mangual) com variações dentro de cada — que é o padrão do género e está no [`31-referencias.md`](31-referencias.md). **A animação é o custo real, não o número de linhas na tabela.**
2. **A fatia 1 não cresce.** Continua com 5 armas e a armadura mínima que o WP5 definir. O catálogo constrói-se por cima da fatia, arma a arma — nunca de uma vez.

---

## 2. ⚠️ A regra dos comandos — e é a mais importante deste documento

`[DECIDIDO]` (Mateus, 31-07-2026), com as palavras dele:

> *"não crie habilidades e depois não cria os comandos pra gente usar elas. Tem sempre que ver se vai funcionar."*

**Toda a habilidade que se escreva na spec tem de dizer, na mesma linha, como o jogador a activa.** Sem isso, é conteúdo que não existe no jogo.

Este é o modo de falha mais comum numa spec grande: escrevem-se 30 habilidades bonitas, e na hora de construir descobre-se que não há teclas para elas. O resultado é metade do catálogo cortado, ou um sistema de menus improvisado à pressa.

### O orçamento de entrada é real e é pequeno

Não há comando ligado em nenhuma das duas máquinas ([`09-tecnico.md`](09-tecnico.md)) — **é teclado e rato**. O esquema do [`01-combate.md`](01-combate.md) e do [`25-controlo.md`](25-controlo.md) já usa quase tudo o que é confortável:

`WASD` · rato · `LMB` · `Shift+LMB` · `RMB` (manter e tocar) · `Espaço` · `Q` · `E` · `1`–`5` · `F` · `R` · `C` · `Tab` · `Ctrl` · `Esc`

**Sobra pouco.** E teclas longe da mão esquerda não servem para combate — ninguém carrega em `P` a meio de um parry.

### As três formas de uma habilidade ser usável

Toda a habilidade tem de encaixar numa destas. Se não encaixar em nenhuma, **não se escreve**:

| Tipo | Como se usa | Custo de entrada | Bom para |
|---|---|---|---|
| **Passiva** | não se activa — está sempre a funcionar | **zero** | ⭐ **a maioria das habilidades de armadura**. Sorte, resistências, peso, regeneração |
| **Condicional** | dispara sozinha quando uma condição acontece (parry acertado, vida < 30%, costas do inimigo) | **zero** | armaduras e armas com identidade sem ocupar tecla |
| **Activa** | tecla dedicada | **alta — é escassa** | reservada às **artes de arma**: uma tecla só, e o que ela faz depende da arma na mão |

### A regra prática

- **Armaduras: habilidades passivas ou condicionais.** Trinta armaduras com trinta teclas é impossível; trinta armaduras com trinta efeitos passivos é trivial e funciona.
- **Armas: uma tecla partilhada para a arte da arma.** 120 armas, uma tecla — o que ela faz depende do que tens na mão. É assim que o género resolve isto, e é o único modo que escala.
- **Consumíveis e magias: a barra de atalhos** que já existe (`1`–`5` + roda), com a mochila a trocar o que lá está.

### O que cada ficha tem de trazer

A partir daqui, **nenhuma habilidade entra na spec sem estas quatro colunas**:

| Habilidade | Tipo | Como se activa | Já existe a tecla? |
|---|---|---|---|
| exemplo: *Passo Firme* | passiva | — | ✅ n/a |
| exemplo: *Investida do Machadão* | activa | tecla de arte de arma | ✅ partilhada |
| exemplo: *Contra-golpe* | condicional | dispara ao aparar | ✅ n/a |

A última coluna é o ponto todo. **Se disser ❌, a habilidade não está pronta para entrar.**

`→WP5` (armas e armaduras) · `→WP3` (habilidades de classe) · `→WP4` (magias) · `→WP11` (o mapa de teclas fecha aqui, e é ele que valida a coluna)

---

## 2b. Artes de arma — uma mão e duas mãos

`[DECIDIDO]` (Mateus, 31-07-2026) — **cada arma dá uma habilidade a uma mão e outra a duas mãos.**

### Como funciona na referência, e porque é que a nossa versão é melhor

Na referência (DS3), a tecla de arte usa a habilidade da **arma da mão esquerda**, ou da arma principal **quando se empunha a duas mãos**. Ou seja: empunhar a duas mãos muda **qual** arma dá a arte, não **que** arte essa arma dá.

A proposta do Mateus é diferente e resolve um problema nosso: **a mesma arma dá artes diferentes conforme as mãos.** `[DECIDIDO]`

**Porque é que isto é a peça certa para nós:** a regra dos comandos (§2) diz que só temos **uma tecla** para artes de arma. Com esta variante, essa tecla passa a dar **duas habilidades por arma** sem gastar tecla nenhuma:

| Famílias | Artes distintas | Teclas gastas |
|---|---|---|
| 8 | **16** (8 × 1 mão + 8 × 2 mãos) | **1** |

Empunhar a duas mãos já é uma decisão que o jogador toma em combate — troca defesa por alcance e dano. **Agora essa decisão também escolhe a habilidade**, e isso dá profundidade sem custar nem uma tecla nem uma animação de menu.

### O que cada ficha de arma passa a ter de trazer

| Arma | Arte a **1 mão** | Arte a **2 mãos** | Custo | Tecla |
|---|---|---|---|---|
| *exemplo: espada longa* | investida rápida à frente | golpe circular em área | stamina | ✅ partilhada |

`→WP5` — o catálogo cresce nesta coluna, não em teclas.

⚠️ **A regra que protege isto:** as duas artes têm de ser **verbos diferentes**, não a mesma coisa com números diferentes. Se a versão a duas mãos for só "o mesmo mas mais forte", é a Lei 2 quebrada e vale mais não existir.

---

## 2c. Habilidades de armadura — por peça, não por conjunto

`[DECIDIDO]` (Mateus, 31-07-2026) — **a habilidade vive na peça, não no conjunto.** Quem quiser o efeito veste só a peça que o dá.

Isto está confirmado na referência: há perneiras que **cortam o dano de queda e silenciam os passos**, e conjuntos em que **cada peça acumula** o mesmo efeito. Ver [`35-estudo-referencia.md`](35-estudo-referencia.md) §2 e a [fonte](https://darksouls2.wiki.fextralife.com/Armors+with+Special+Effects).

### Porque é que isto é a decisão certa

**Sem bónus de conjunto, misturar peças passa a ser jogabilidade.** O jogador que quer descer penhascos veste as perneiras que cortam a queda com o peito que lhe interessa por outra razão. A personalização deixa de ser cosmética e passa a ser construção — e é grátis: não custa sistema nenhum, só disciplina ao escrever o catálogo.

### O tipo de efeito que faz sentido

Todos **passivos** (§2 — armaduras não gastam teclas):

| Categoria | Exemplos do género |
|---|---|
| Movimento e física | menos dano de queda · passos silenciosos · rolamento mais longo |
| Recursos | mais almas ganhas · stamina regenera mais depressa · mais mana máxima/recuperada |
| Resistências | veneno, sangramento, fogo — por tipo, nunca defesa plana (Lei 1) |
| Situacionais | melhor com pouca vida · melhor de noite · melhor sozinho |

⚠️ **Nós não temos anéis.** Na referência, metade destes efeitos vive em anéis e não na armadura. Como a nossa spec não tem sistema de anéis, **a armadura carrega tudo** — o que é mais simples (um sistema em vez de dois) e torna cada peça mais interessante. `[CLAUDE]`, para o WP5 confirmar ou propor anéis.

---

## 3. Ressurreição — afinação

`[DECIDIDO]` (Mateus, 31-07-2026) — a janela de canalização passa a **5 a 7 segundos**, para o WP15B afinar dentro dessa faixa.

`[DECIDIDO]` — **quem morre pode largar itens no chão**, além das almas, para o parceiro apanhar.

### O que isto acrescenta ao [`33-morte-e-almas.md`](33-morte-e-almas.md)

Não é um detalhe cosmético — muda o que acontece quando o minuto passa:

- Se o parceiro **não** te ressuscita a tempo, o que largaste **continua lá**. Ele pode ir buscar, e devolver-te depois
- Isso transforma o corpo caído num **sítio de decisão**: arriscar os 5–7 segundos para te ressuscitar, ou pegar no que caiu e continuar a luta sozinho?

`[EM ABERTO]` — **o que se larga.** Propostas `[CLAUDE]` para o WP9 fechar: as almas (já decidido) · frascos por usar · o item que estava na mão. *Não* o equipamento vestido — perder a armadura ao morrer é castigo a mais e obriga a um sistema de recuperação inteiro.

---

## Ligações

[`33-morte-e-almas.md`](33-morte-e-almas.md) · [`14-equipamento.md`](14-equipamento.md) · [`01-combate.md`](01-combate.md) · [`25-controlo.md`](25-controlo.md) · [`20-interface.md`](20-interface.md) · [`31-referencias.md`](31-referencias.md)
