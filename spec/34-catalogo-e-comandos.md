# 34 — A escala do catálogo, e a regra dos comandos

`[DECIDIDO]` (Mateus, 31-07-2026) — a dimensão do equipamento, e uma regra de processo que vale para o projeto inteiro.

---

## 1. A escala

| | Alvo | Na fatia 1 |
|---|---|---|
| **Armaduras** | **~30**, cada uma com habilidade própria | por decidir — poucas |
| **Armas** | **~20 por classe** | 5 partilhadas |

`[DECIDIDO]` — **toda a armadura tem uma habilidade ou uma identidade visual própria.** Nenhuma peça existe só para dar +2 de defesa.

As habilidades podem ser defesa, sorte, ou o que fizer sentido — o critério é que **cada peça responda a "porque é que eu usaria esta e não outra?"** com algo que não seja um número maior.

### O que isto obriga

Com 6 classes, 20 armas por classe são **120 armas**. Mais 30 armaduras. É um catálogo grande, e é o que o Mateus quer — fica registado como decisão consciente, com duas condições:

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
