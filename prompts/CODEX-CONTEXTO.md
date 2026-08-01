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
| **Especificação** | **75 documentos**, em `spec/` |
| **Jogo** | **corre** — Godot **4.7.1**, renderer **Mobile**, em `game/` |
| **Testes** | **8435 auto-testes** contra a spec, todos a passar |
| **Desempenho** | 416 fps na máquina do Rico *(greybox, sem animação de esqueleto)* |
| **Arte** | **54 imagens curadas** (32 conceitos, 20 ícones, menu e céu) + **10 packs CC0** (785 modelos, 1954 texturas, 182 sons) |
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
| ❌ **Binários novos no repositório** | `art/` ocupa **466,1 MiB** no working tree; as bibliotecas CC0 em `models/textures/audio` ocupam **203,2 MiB** · ⚠️ o `game/.gitignore` **não trava** `.glb`, `.png` nem `.ogg` |
| ❌ **Caminhos absolutos ou segredos** | o repositório é **público** |
| ❌ **Assets de jogos comerciais** | |
| ❌ **Sobrevender** | ⭐ dizer **o que ainda não está provado** é o que torna um relatório útil |
| ❌ **Adjectivos onde deviam estar números** | *"combate responsivo"* não é spec; *"0,60 s, invencibilidade nos frames 5–23 inclusivos (317 ms)"* é |

---

## 11. O risco, dito uma vez

**Duas pessoas e dois agentes.** O escopo escrito é grande: 12 biomas, 13 chefes verdadeiros + 12 subchefes + ~36 nomeados, 120 armas, **68 peças de armadura (acima do alvo decidido de ~30; pergunta 44)**, 70 anéis e 53 feitiços.

Duas auditorias independentes ([`../docs/`](../docs/)) estimaram o que honestamente não fica feito, e deram uma **ordem de corte com menor perda**:

> 1.ª pessoa → chefes reclassificados → slots de armadura → slots de anel → armas acima de 24 → feitiços acima de 24

⚠️ **Não cortar:** co-op · esquiva/parry/stamina · as 8 famílias · a identidade dos 12 biomas.

**Não é para cortares nada por tua conta.** Está aqui para usares a coluna **`Fatia 1?`** em tudo o que escreveres — é ela que separa *"o jogo completo"* de *"o que se constrói primeiro"*.

---

## 12. ⭐ As imagens são tua responsabilidade

`[DECIDIDO]` (Mateus, 01-08-2026) — **tu geras as imagens que faltam.** Não pedes a ninguém; resolves.

### O que falta

Os **modelos 3D, texturas e sons** já vêm dos packs CC0 em `art/`. **O que falta são ÍCONES** — as imagens pequenas da mochila e da barra, que nenhum pack traz porque são específicas deste jogo:

| O que | Quantos |
|---|---|
| Famílias de arma | **8** — cinco ícones da Fatia 1 prontos; o resto segue o catálogo WP5 |
| Peças de armadura | **11 da Fatia 1**, todas definidas e por gerar |
| Feitiços | **53 fichas**; Dardo, Ruína e Égide já têm ícone, os outros esperam pela sua fatia |
| Anéis | ~70 |
| Consumíveis | frascos, brasa, tomos |
| Retratos das 6 raças novas | 6 |

### As rotas, por ordem de preferência

**1. Higgsfield CLI** — é a que já usámos, e tem crédito:

```bash
higgsfield account status                      # ver saldo
higgsfield generate create nano_banana_pro --prompt "<prompt>" --aspect-ratio 1:1
higgsfield generate wait <job-id>              # devolve o URL
curl -fsSL "<url>" -o art/ui/icons/<nome>.png
```

⚠️ **Máximo 4 trabalhos em paralelo.** `nano_banana_pro` custa **2 créditos**; `image_background_remover` custa **1**.

**2. Se a CLI falhar** — o browser, ou qualquer outra via que consigas. **Contorna.** O que importa é a imagem ficar no caminho certo e registada.

**3. Se nada funcionar** — escreve o prompt em `art/prompts/` e regista no `LACUNAS.md` como *"por gerar"*. **Nunca inventes que geraste.**

### ⚠️ As regras que não se quebram

| | |
|---|---|
| **Modelo e proveniência explícitos** | os 43 assets históricos usam `nano_banana_pro`; os 11 ícones de armadura usam `imagegen`, conforme o manifesto. Não misturar estilos sem registar a mudança |
| ⭐ **A frase de estilo é literal** | está em [`../art/prompts/00-estilo.md`](../art/prompts/00-estilo.md) e vai **no início de cada prompt**, sem alterar uma palavra. É ela que faz 100 imagens parecerem do mesmo jogo |
| **Ícones com fundo transparente** | pede `isolated on transparent background`, e passa pelo `image_background_remover`. Verifica que sai **RGBA** |
| **Prompt em inglês** | os geradores respondem melhor |
| **Uma imagem por prompt** | nada de folhas com 6 variações |
| **Sem texto dentro da imagem** | |
| ⭐ **Regista no [`../art/MANIFESTO.md`](../art/MANIFESTO.md)** | ID, caminho canónico, estado. **Uma imagem que não está no manifesto não existe** |
| ⚠️ **Orçamento** | ~121 créditos ≈ **60 imagens**. Não chega para tudo — **a coluna `Fatia 1?` decide o que se gera primeiro** |
| ⚠️ **Nunca** | imagens extraídas de jogos comerciais |

### A descrição visual

Cada item do catálogo traz uma coluna `descrição visual`, e é dela que sai o prompt. **Uma frase, mas específica:**

> ❌ *"Katana"* — o modelo inventa
> ✅ *"Lâmina curva estreita, aço polido, punho enfaixado a tecido escuro, 90 cm"*

⚠️ **E usa o material do bioma** ([`../spec/46-coerencia-bioma-raca-item.md`](../spec/46-coerencia-bioma-raca-item.md)): um machado orc da Fornalha é de **obsidiana**, não de aço. **Escreve-se — não se deixa ao acaso do gerador.**

---

## 13. ⭐ Podes ver o jogo com os teus olhos

`[DECIDIDO]` (Mateus) — **tens permissão para correr o jogo e olhar para ele.**

**A forma mais barata já existe** — o modo fotografia que o Fable construiu:

```bash
<godot> --path game/ --rendering-method mobile -- --scene=zone --photos
# escreve 6 PNG em game/captures/ e sai
```

⭐ **Usa isto sempre que mexeres em alguma coisa visual.** Gera, **olha para a imagem**, e diz o que vês — não o que esperavas ver.

**E o critério que o [`../spec/47-do-greybox-ao-visual.md`](../spec/47-do-greybox-ao-visual.md) §5 fixa:**

> **Nenhum marco fecha sem capturas.** A pergunta é uma só: *isto está mais perto da barra do [`30-qualidade-visual.md`](../spec/30-qualidade-visual.md) do que estava antes?*

Se precisares de ver o jogo a correr de verdade — janela aberta, a jogar — **tens permissão para isso também.** Instala o que precisares.

---

## 14. ⚠️ Sobre o teu próprio esforço de raciocínio

**Usa o máximo por defeito.** É o que o Mateus quer, e é o que dá melhor trabalho.

⚠️ **Mas se sentires que estás a ficar sem contexto ou a demorar demais numa tarefa:**

1. **Pára**
2. **Commita o que tens**, mesmo a meio
3. **Escreve exactamente onde ficaste e o que falta**

⭐ **Um trabalho parado é retomável. Um trabalho alucinado tem de ser deitado fora.** Parar cedo não é falhar — é a única coisa que garante que nada se perde.
