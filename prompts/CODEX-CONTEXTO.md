# Contexto permanente — para o Codex

**Lê isto no início de cada tarefa.** É o que não muda. A tarefa concreta vem à parte.

---

## 1. O que é o projecto

**WorldRPGs** — RPG de acção 3D para PC, **souls-like**, **co-op para dois**, em português.

⚠️ **Não é um produto.** É um **hobby de dois amigos** — o **Mateus** e o **Rico** — que vão jogar isto um com o outro. Não há prazo, não há cliente, não há loja. **A régua é "os dois divertem-se", não "vende".**

**A referência é o Dark Souls**, sobretudo o **2** e o **3**. ⚠️ **Estudamos a estrutura, nunca copiamos o conteúdo** — sem nomes de armas, chefes, zonas ou personagens deles. A regra está em [`../spec/31-referencias.md`](../spec/31-referencias.md) e é dura: *se consegues explicar o padrão sem dizer o nome do jogo, é padrão e adopta-se; se precisas do nome para explicar, é conteúdo e não entra.*

---

## 2. ⚠️ A máquina alvo manda em tudo

| | |
|---|---|
| **CPU/GPU** | Intel **Iris Xe integrados** — não há placa gráfica |
| **Memória** | **8 GB**, partilhada com os gráficos |
| **Alvo** | **1080p @ 60 fps** |

**É a máquina do Rico, e é a mais fraca das duas.** Uma queda de fotogramas num souls-like **não é feio, é injusto** — o jogador perde por causa do motor, não por causa dele.

---

## 3. As quatro leis — tudo é medido contra elas

| | |
|---|---|
| **1** | **Ganha-se com habilidade, não com nível.** O nível reduz a margem de erro, **nunca abre uma porta**. Sem gating, sem grind obrigatório |
| **2** | ⭐ **As melhorias dão OPÇÕES, não números.** É a mais fácil de quebrar sem dar por isso — *"+30% de dano"* quebra-a, *"passa a perfurar"* cumpre-a |
| **3** | **Qualquer classe pega em qualquer arma.** A diferença vem de atributos e traços, nunca de bloqueio |
| **4** | **A máquina alvo manda** (secção 2) |

---

## 4. O que já existe

| | |
|---|---|
| **Especificação** | **~60 documentos**, ~15 000 linhas, em `spec/` |
| **Jogo** | **corre** — Godot **4.7.1**, renderer **Mobile**, em `game/` |
| **Testes** | **226 auto-testes** contra a spec, todos a passar |
| **Desempenho** | 416 fps na máquina do Rico *(greybox, sem animação de esqueleto)* |
| **Arte** | 43 conceitos gerados + **10 packs CC0** (785 modelos, 1954 texturas, 182 sons) |
| ⚠️ **Estado visual** | **greybox** — cones por árvores, cápsulas por personagens. Os packs estão no repositório mas **não estão importados** |

---

## 5. ⭐ A arquitectura, e a regra que a sustenta

> **Nenhum número de combate vive em código.** Vivem em `game/data/*.json`, e vêm da spec.

`game/src/autoload/game_data.gd` carrega-os e **recusa arrancar** se divergirem da spec.

⭐ **Consequência: escrever o catálogo não é documentar o jogo — é construí-lo.** Uma arma nova é uma entrada no JSON + uma linha na spec, e passa a existir a jogar. **Não há um passo de "implementação" a seguir.**

| Pasta | O que é |
|---|---|
| `spec/` | a especificação — **manda nos números** |
| `game/` | o projecto Godot — implementa a spec |
| `game/data/*.json` | os números, carregados em runtime |
| `art/` | biblioteca de assets. ⚠️ **O Godot não a varre** — o que o jogo usa vem para `game/` um a um |
| `tools/` | guarda de coerência e gerador de mapa |
| `docs/` | auditorias independentes |

---

## 6. Os ficheiros que se leem primeiro

| # | | |
|---|---|---|
| **1** | [`../ESTADO.md`](../ESTADO.md) | ⭐ **o que é verdade hoje** — e o que já foi substituído |
| **2** | [`../LACUNAS.md`](../LACUNAS.md) | ⭐ **o que falta e ninguém está a fazer**, por prioridade |
| **3** | [`../MAPA.md`](../MAPA.md) | a estrutura, e **quais são as fundações** — mexer numa obriga a rever quem aponta para lá |
| **4** | [`../DECISOES.md`](../DECISOES.md) | as decisões por ordem, e **o que cada uma substitui** |
| **5** | [`../SPEC.md`](../SPEC.md) | o índice |

⚠️ **Onze documentos de execução são anteriores a decisões que os mudam.** A lista está no `ESTADO.md` §2. **Em caso de divergência, manda a decisão mais recente**, e o `DECISOES.md` diz qual é.

---

## 7. ⭐ As quatro perguntas do fio solto

**Nada entra sem responder às quatro.** Uma em branco é uma ponta solta, e pontas soltas descobrem-se seis meses depois quando custam dez vezes mais.

| | Pergunta | Porquê |
|---|---|---|
| **1** | **Como é que o jogador usa isto?** | já apanhou 4 casos reais — habilidades escritas sem tecla para as activar |
| **2** | **Como é que se prova que funciona?** | um teste em `game/src/tests/self_test.gd`, ou um número medido |
| **3** | **De onde vem a arte e o som?** | um item sem **descrição visual** não aparece no ecrã |
| **4** | **Quanto custa na máquina do Rico?** | Lei 4 |

---

## 8. As etiquetas

| | |
|---|---|
| `[DECIDIDO]` | fechado pelos donos. **Não se mexe** — detalha-se por baixo, nunca por cima |
| `[SUGERIDO]` | foi dito, ninguém confirmou |
| `[EM ABERTO]` | falta decidir — está no `99-perguntas-abertas.md` |
| ⚠️ `[TENSÃO]` | duas decisões que não encaixam. **Propõe-se e recomenda-se; NUNCA se decide** |
| `[CODEX]` | decidido por ti. **Traz razão e alternativa descartada** |
| `[PROTO]` | assumido para o protótipo poder correr. **Não é decisão** |

---

## 9. Como se trabalha — o ciclo

```
   CODEX                              CLAUDE (revisor)
     │                                     │
  1. reserva em COORDENACAO.md ──────────► │
     │  (pacote E número de ficheiro)      │
  2. escreve spec + game/data + código     │
  3. corre o guarda e os testes            │
  4. commit ────────────────────────────►  5. revê contra as 4 leis
     │                                     6. corrige o que estiver mal
     │                                     7. aponta os gaps seguintes
  8. tarefa seguinte  ◄──────────────────  │
```

| Regra | |
|---|---|
| ⚠️ **Reserva primeiro** | pacote **e número de ficheiro** em [`../COORDENACAO.md`](../COORDENACAO.md), com push imediato. **Já houve duas colisões** |
| **Spec + `game/data` no mesmo PR** | são a mesma coisa |
| **Corre os dois** | `node tools/check-coerencia.mjs` **e** `godot --headless --path game/ scenes/selftest.tscn` |
| **Actualiza no mesmo commit** | `SPEC.md`, `ESTADO.md`, `LACUNAS.md`, `99-perguntas-abertas.md` |
| ⭐ **Encontraste um buraco?** | **escreve-o no `LACUNAS.md` no mesmo acto.** Um buraco num comentário perde-se |

---

## 10. ⚠️ O que nunca se faz

| | |
|---|---|
| ❌ **Decidir uma `[TENSÃO]`** | propõe-se e recomenda-se. Decidem o Mateus e o Rico |
| ❌ **Mexer num `[DECIDIDO]`** | detalha-se por baixo |
| ❌ **Números de combate em `.gd`** | pertencem a `data/*.json` |
| ❌ **Binários novos no repositório** | já tem 460 MB de packs; ⚠️ o `game/.gitignore` **não trava** `.glb`, `.png` nem `.ogg` |
| ❌ **Caminhos absolutos ou segredos** | o repositório é **público** |
| ❌ **Assets de jogos comerciais** | |
| ❌ **Sobrevender** | ⭐ dizer **o que ainda não está provado** é o que torna um relatório útil |
| ❌ **Adjectivos onde deviam estar números** | *"combate responsivo"* não é spec; *"0,60 s, invencibilidade dos 0,08 aos 0,38"* é |

---

## 11. O risco, dito uma vez

**Duas pessoas e dois agentes.** O escopo aprovado é grande: 12 biomas, 13 chefes verdadeiros + 12 subchefes + ~36 nomeados, ~120 armas, ~30 armaduras, ~70 anéis, catálogo de magia largo.

Duas auditorias independentes ([`../docs/`](../docs/)) estimaram o que honestamente não fica feito, e deram uma **ordem de corte com menor perda**:

> 1.ª pessoa → chefes reclassificados → slots de armadura → slots de anel → armas acima de 24 → feitiços acima de 24

⚠️ **Não cortar:** co-op · esquiva/parry/stamina · as 8 famílias · a identidade dos 12 biomas.

**Não é para cortares nada por tua conta.** Está aqui para usares a coluna **`Fatia 1?`** em tudo o que escreveres — é ela que separa *"o jogo completo"* de *"o que se constrói primeiro"*.
