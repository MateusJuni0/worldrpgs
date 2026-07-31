# Realinhamento — o que dar ao Fable depois dos commits dele

> **Estado: PARTE A escrita, PARTE B por preencher.** A parte B só se escreve depois de os commits do Fable chegarem e serem analisados.
>
> **Porque existe:** o Fable só vê o que está no repositório. Tudo o que o Mateus e o Claude decidiram por conversa só existe para ele se estiver escrito aqui. Ele esteve a construir localmente enquanto se decidiam sete coisas que mudam o que ele fez — este documento é a ponte.

---

## O processo, pela ordem

1. ⏳ **Os commits do Fable chegam** (o Rico avisa)
2. **O Claude analisa** — o que ele fez contra o [`../DECISOES.md`](../DECISOES.md), linha a linha
3. **Preenche-se a PARTE B** deste documento com o resultado
4. **Dá-se isto ao Fable** — ele lê e realinha
5. **Ele acaba o que falta** da spec
6. **Passa-se ao Opus 5** para construir

---

# PARTE A — o que já se sabe (escrito 31-07)

## A1. Sete decisões que ele não conhece

Todas de 31-07, todas depois de ele ter começado. Estão no [`../DECISOES.md`](../DECISOES.md) com o que cada uma substitui:

| Decisão | O que substitui no trabalho dele |
|---|---|
| **Almas** — moeda e XP, caem ao morrer, nível 1→100 | *"não se perde nada ao morrer"* |
| **Ressurreição em co-op** — 1 min, canalização 5–7 s em cima do corpo, larga itens | *"o jogador morto fica morto até o combate acabar"* |
| **Os quatro casos das almas** — incluindo os dois a morrer: duas manchas separadas | a linha vaga de que as almas "ficam no corpo" |
| **Frascos + pontos de descanso** que fazem voltar os inimigos | a pergunta 7 aberta |
| **Armadura por peças**, muitas, largadas pelos inimigos | a pergunta 14 aberta |
| **1.ª ou 3.ª pessoa à escolha** | "terceira pessoa" em toda a spec |
| **Qualidade DS2, não PS1** — 8–15 mil tri | "baixo poligonal" |

## A2. A escala e a regra dos comandos

- **~30 armaduras** com habilidade própria · **~20 armas por classe** (≈120), em famílias que partilham conjunto de movimentos
- ⚠️ **Toda a habilidade diz como se activa, na mesma linha.** Armaduras → passivas ou condicionais. Armas → **uma tecla partilhada** de arte de arma. Detalhe em [`../spec/34-catalogo-e-comandos.md`](../spec/34-catalogo-e-comandos.md)

## A3. O que continua por fazer na spec, independentemente do que ele commitou

**Reparos que já lhe foram apontados e ficaram por fazer:**

1. ✅ **O estudo da referência está feito** — [`../spec/35-estudo-referencia.md`](../spec/35-estudo-referencia.md), com fontes. **Produziu 8 descobertas accionáveis**, três delas obrigam a reescrever trabalho: armas por família e não por classe (WP5), curva de nível linear que devia ser cúbica (WP2/WP9), e a ambiguidade das 30 armaduras. Os 11 documentos ainda precisam de uma passagem contra isto
2. **Cada ficha do bestiário tem de dizer que som anuncia cada ataque** — a regra da 1.ª pessoa está lá marcada `[CLAUDE]`, por completar
3. **Melhoria de armas não existe na spec** (WP5)
4. **Estados alterados** — veneno, sangramento, queimadura — nunca mencionados (WP5)
5. **Uniformizar "XP" → "almas"** no WP9, que ainda usa o nome antigo

**Trabalho que as decisões novas abriram:**

| | Onde |
|---|---|
| Almas por inimigo e curva de custo até ao nível 100 | WP2 / WP9 |
| Catálogo de ~30 armaduras, por peças, com peso e resistências | WP5 |
| Catálogo de ~20 armas por classe, em famílias | WP5 |
| Que peças cada inimigo usa (= o que pode largar) | WP6 |
| Melhorar frascos: mais ou mais fortes | WP5 |
| Ressurreição: interrupção, vida ao ressuscitar, indicadores | WP10 |
| Distância e descoberta dos pontos de descanso | WP8 |
| **Rever WP3, WP4 e WP5 contra a regra dos comandos** | os três |
| **Viewmodel de 1.ª pessoa** — recontar as animações | WP12 |
| **Dois FOVs** (55° e 90°) no traçado das zonas | WP8 |

**Divergências vivas, que são dos donos:**

- **6 zonas vs 10+ biomas** — o WP8 desenhou 6; foram aprovados 10+
- **Lock-on em 1.ª pessoa** — duas opções propostas, nenhuma escolhida
- As perguntas **5, 6, 15** do 99, e as **7 perguntas de narrativa** do `26-narrativa.md` §3 (precisam de gravação)

## A4. Uma coisa que se arrumou hoje e ele deve saber

Os documentos da sessão 1 (`00`–`09`) marcavam dezenas de coisas como `[EM ABERTO]` que os pacotes WP já tinham respondido — o `07-multiplayer.md` sozinho tinha 7. **Levavam qualquer agente a pensar que havia buracos onde não havia.**

Levam agora um aviso no topo: *"é o registo da sessão 1, não o estado actual"*, com o ponteiro para o documento de execução. **Em caso de divergência, manda o documento de execução.**

---

# PARTE B — a preencher depois de analisar os commits

> Nada aqui até os commits chegarem. O que vai entrar:

## B1. O que ele construiu
*(inventário do que os commits trazem: ficheiros, sistemas, estado)*

## B2. O que assume premissas antigas
*(comparação linha a linha contra o A1 — o que tem de mudar no código dele)*

## B3. O que ele descobriu a construir e obriga a mudar a spec
*(o inverso: números que não funcionaram, e que **mudam a spec**, porque isso é bom — ver [`../spec/32-construcao.md`](../spec/32-construcao.md))*

## B4. A ordem do que fazer a seguir
*(realinhar → acabar a spec → passar ao Opus 5)*

---

## Como escrever a PARTE B, quando chegar a altura

1. **Inventariar** — que ficheiros, que sistemas, em que estado. Não assumir; ler
2. **Comparar contra o A1**, decisão a decisão. Para cada uma: *o código dele assume o contrário?*
3. **Procurar o inverso também.** Se ele descobriu a construir que um número não funciona, **isso muda a spec e é bom** — não é erro dele
4. **Não reescrever o trabalho dele.** Apontar, explicar porquê, e deixá-lo corrigir. É o que a revisão tem feito até agora e tem funcionado
5. **Ordenar por risco**, não por ordem de ficheiro. O que estiver mais fundo no código (morte, ressurreição, perspectiva) custa mais a mudar depois
