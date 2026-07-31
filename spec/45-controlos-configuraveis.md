# 45 — Controlos configuráveis dentro do jogo

`[DECIDIDO]` (Mateus, 31-07-2026) — *"tem que dar pra gente escolher os controles no jogo mesmo."*

---

## 1. O que isto dissolve

⭐ **Duas perguntas abertas deixam de existir — e uma delas era a mais urgente da lista.**

| Pergunta | O que era | Como se dissolve |
|---|---|---|
| **30** | O parry tem `Q` no [`01-combate.md`](01-combate.md) e toque de `RMB` no [`25-controlo.md`](25-controlo.md). Dois documentos aprovados, dois botões | **ficam os dois.** Cada jogador escolhe. Um pode jogar de uma maneira e o outro da outra, na mesma partida |
| **31** | Quatro acções sem tecla, encontradas a construir | **deixam de precisar de acordo prévio.** Levam um valor de fábrica e o jogador muda se quiser |

⚠️ **Isto não apaga o trabalho — muda a natureza dele.** O mapa de teclas ([`20-interface.md`](20-interface.md), WP11) continua a ter de existir: alguém tem de decidir **os valores de fábrica**, e esses são a primeira experiência de quem joga. O que deixa de existir é a **discussão** sobre qual é o certo.

---

## 2. Porque é que isto é mais importante do que parece

Não é uma opção de menu. **É a Lei 1.**

O [`25-controlo.md`](25-controlo.md) avisa que a escolha do botão de parry **contamina todos os testes da Lei 1**: se o parry for desconfortável de accionar, o jogo parece injusto e **começa-se a baixar a dificuldade para compensar um problema que é de teclado**. Todo o equilíbrio sai enviesado a partir daí.

⭐ **Com teclas configuráveis, esse enviesamento desaparece.** Quem testa afina o comando ao seu dedo, e o que sobra a medir é o jogo — não a mão de quem joga.

E há a razão simples: **são dois amigos com mãos diferentes.** Não há nenhuma tecla que seja a certa para os dois.

---

## 3. O que tem de ser configurável

`→WP11` — **tudo o que é entrada.** Sem lista de excepções:

| Grupo | Exemplos |
|---|---|
| **Movimento** | andar, correr, esquivar, saltar, andar devagar |
| **Combate** | ataque leve, pesado, **parry**, bloquear, empurrão, arte de arma, habilidade de classe |
| **Magia e itens** | conjurar, feitiço seguinte/anterior, atalhos `1`–`5`, frasco |
| **Câmara e alvo** | engatar alvo, trocar de alvo, inverter eixos, sensibilidade, campo de visão |
| **Mundo** | interagir, apanhar, mapa, mochila, descansar |
| **Sistema** | pausa, capturas, consola de depuração |

### As regras que fazem um remapeamento não partir o jogo

`[CLAUDE]`, `→WP11`:

1. ⚠️ **Detecção de conflito obrigatória.** Se o jogador põe duas acções na mesma tecla, o ecrã **diz qual é a outra** e pergunta. Nunca aceitar em silêncio — é o defeito nº1 destes menus
2. **Uma acção pode ter duas teclas.** É assim que o parry fica em `Q` **e** no toque de `RMB` ao mesmo tempo, se alguém quiser
3. ⭐ **Distinguir *tocar* de *manter*.** O esquema do WP1B depende disto (bloquear a segurar, parry a tocar). O menu tem de o permitir por acção, senão metade das propostas do WP1B ficam impossíveis
4. **Repor valores de fábrica**, sempre a um clique
5. ⚠️ **O jogo mostra a tecla do jogador, nunca a de fábrica.** Toda a dica no ecrã, tutorial e menu lê o mapa actual. Se um jogador remapeia a esquiva e o tutorial continua a dizer `Espaço`, **o tutorial passa a mentir** — e isso é a cláusula 4 do [`38`](38-ataques-e-honestidade.md)
6. **Perfis separados por jogador**, guardados fora do save da personagem

⚠️ **A regra 5 é a que se esquece sempre, e é a mais cara de corrigir tarde.** Cada texto de interface que tenha um nome de tecla tem de o ir buscar ao mapa. Escrito no início é trivial; enxertado no fim obriga a mexer em toda a interface.

---

## 4. O que isto não muda

- ⚠️ **A regra do [`34`](34-catalogo-e-comandos.md) §2 continua inteira.** Toda a habilidade tem de dizer **como se activa** — o que muda é que a resposta passa a ser *"acção X, de fábrica na tecla Y"* em vez de *"tecla Y"*. **Uma habilidade sem acção associada continua a não existir no jogo**
- **O orçamento de teclas continua a ser real.** Configurável não é infinito: quem joga só tem uma mão esquerda, e acções a mais continuam a ser acções que ninguém usa
- **Os valores de fábrica continuam a ser desenho**, e dos importantes — são o que 100% dos jogadores experimenta primeiro

---

## 5. Comando (`gamepad`)

`[EM ABERTO]` — nenhuma das duas máquinas tem comando ligado ([`09-tecnico.md`](09-tecnico.md)), e a spec foi escrita para teclado e rato.

**Proposta `[CLAUDE]`:** o sistema de remapeamento nasce **agnóstico da fonte** — uma acção liga-se a *uma entrada*, seja tecla, botão de rato ou botão de comando. **Não custa quase nada agora e poupa uma reescrita** se algum dia ligarem um comando. `→WP11`/`→WP14`

## Ligações

[`20-interface.md`](20-interface.md) · [`25-controlo.md`](25-controlo.md) · [`34-catalogo-e-comandos.md`](34-catalogo-e-comandos.md) · [`01-combate.md`](01-combate.md) · [`44-prototipo.md`](44-prototipo.md) · [`38-ataques-e-honestidade.md`](38-ataques-e-honestidade.md)
