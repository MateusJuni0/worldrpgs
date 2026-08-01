# 60 — O agente que joga: banco de ensaio automático

`[DECIDIDO]` (Mateus, 01-08-2026) — *"temos que ter também um modo de pôr o Codex a jogar, testar o jogo, a funcionalidade e tudo das armas, dos itens, e configurações. **Mas só quando tiver o jogo pronto** para daí ele fazer essas coisas."*

> ⏳ **Isto não se constrói agora.** Fica escrito para estar pronto quando o jogo tiver conteúdo que valha a pena ensaiar — **depois** de os modelos entrarem e o catálogo estar cheio.

---

## 1. ⭐ Porque é que isto vale mais do que parece

**Temos 8433 auto-testes. Eles verificam que os números do código batem certo com os da spec.** É útil, e é estático.

⚠️ **O que eles não conseguem verificar é se o jogo cumpre as leis.**

| | Auto-teste (temos) | ⭐ Agente que joga (isto) |
|---|---|---|
| Verifica | *"o JSON diz frames 5–23 e o código lê 5–23"* | ⭐ *"rolei no frame certo e **não levei**"* |
| Natureza | estático | **dinâmico** |
| Prova a Lei 1? | ❌ | ⭐ **sim** |
| Prova a Lei 3? | ❌ | ⭐ **sim** |

⭐ **É isto que transforma as quatro leis de promessa em teste.** Hoje a Lei 1 é uma frase bonita no `00-visao.md`. Com um banco de ensaio, é uma coisa que passa ou falha.

### E há um teste que já está escrito e é impossível sem isto

O [`38-ataques-e-honestidade.md`](38-ataques-e-honestidade.md) §2, cláusula 5, exige:

> *"Um jogador que role no frame correcto atravessa o ataque **10 vezes em 10, sem excepção**. Se falhar uma vez, é bug — nunca 'o jogador enganou-se'."*

⚠️ **Isso não é verificável a olho, nem por auto-teste.** Precisa de alguém que role dez vezes e conte. **É exactamente o que um agente faz bem e um humano faz mal.**

---

## 2. ⚠️ O requisito que faz tudo isto funcionar: determinismo

**Sem determinismo, um teste que passa uma vez não prova nada.**

| | |
|---|---|
| **Passo fixo** | ✅ já decidido — a física de combate corre a **60 Hz fixos** ([`36`](36-fisica.md) §6) |
| **Semente fixa** | ✅ greybox, escolha de padrões da IA e ordem do baralho aceitam semente; mesma semente 42 repete a sequência ([`67`](67-catalogo-do-bestiario.md)) |
| **Sem relógio de parede** | ⚠️ nada pode depender de `Time.get_ticks()` — só do número de frames |
| **Entrada por guião** | ⚠️ o jogo tem de aceitar entradas de um ficheiro em vez do teclado |

⭐ **A semente fixa entrou no ponto certo:** com ela, correr o mesmo ensaio duas vezes dá **exactamente** a mesma colocação, escolha de padrão e ordem de espólio. O guarda automatizado compara semente 42 consigo própria e com 43.

---

## 3. Como funciona

```
   CODEX escreve um GUIÃO          →   ensaios/rolamento-lanceiro.json
        │
        ▼
   godot --headless --path game/ ensaio.tscn -- --guiao=<ficheiro> --semente=42
        │
        │  o jogo corre sem janela, a 60 Hz fixos,
        │  com as entradas do guião em vez do teclado
        ▼
   RELATÓRIO   →   ensaios/saida/rolamento-lanceiro.json
        │            frame a frame: posição, PV, stamina, estado, dano recebido
        ▼
   CODEX lê o relatório, compara com o esperado, e diagnostica
```

### O guião

`[CLAUDE]` — um ficheiro simples, legível, que um agente escreve à mão:

```json
{
  "cena": "arena", "semente": 42,
  "jogador": { "classe": "guerreiro", "arma": "espada_longa", "nivel": 1 },
  "inimigos": [ { "tipo": "orc_lanceiro", "posicao": [0, 0, 5] } ],
  "accoes": [
    { "frame": 0,   "fazer": "avancar", "durante": 60 },
    { "frame": 90,  "fazer": "esperar_telegrafia" },
    { "frame": "+2","fazer": "esquivar", "direccao": "lado" }
  ],
  "esperar": [
    { "que": "dano_recebido", "seja": 0 },
    { "que": "stamina_final", "acima_de": 20 }
  ]
}
```

⭐ **`"frame": "+2"` é a peça importante** — permite dizer *"dois frames depois de o inimigo dar o sinal"*, que é como se descreve uma esquiva. Sem isso, os guiões teriam números mágicos que partem quando alguém afina uma janela.

---

## 4. ⭐ Os ensaios que interessam — e cada um prova uma regra escrita

| Ensaio | O que prova | Onde está escrita |
|---|---|---|
| ⭐ **Rolamento 10/10** | por **cada ataque de cada inimigo**: rolar no vector certo funciona **sempre** | [`38`](38-ataques-e-honestidade.md) §2 cl. 5 |
| ⭐ **O vector correcto** | e que o vector **errado** falha — senão a regra não vale nada | [`38`](38-ataques-e-honestidade.md) §2b |
| ⭐ **Nível 1 vence** | cada chefe é vencível a nível 1, só por leitura | **Lei 1** |
| ⭐ **Qualquer arma serve** | um mago com um machadão mata o lanceiro; uma arma abaixo do requisito faz 60% e **não bloqueia** | **Lei 3** |
| **Piso de 30%** | com a melhor armadura do jogo, ainda se leva 30% | [`39`](39-estudo-profundo.md) §1 |
| **Orçamento de stamina** | a sequência que a ficha da arma promete **cabe** na stamina | [`41`](41-estudo-armas-e-golpes.md) §5 |
| **Tempo até matar** | por arma × inimigo, contra o alvo do WP2 |[`11`](11-formulas.md) |
| ⭐ **Não há stunlock** | dois inimigos nunca acertam durante o hit-stun um do outro | [`38`](38-ataques-e-honestidade.md) §3 |
| **Interrupção** | 3 golpes de espadão interrompem; 10 de adaga não | [`39`](39-estudo-profundo.md) §4 |
| **Espólio garantido** | 10 mortes largam as 5 peças, **em 100 corridas de 100** | [`43`](43-estudo-espolio-inventario-mundo.md) §2 |
| ⭐ **Soft caps** | nível 40 → 70 → 100 e medir o que muda de facto | [`58`](58-fim-do-jogo-ciclos-e-a-curva.md) §3 |
| **Save round-trip** | grava, lê, e o estado é idêntico | `→WP14` |
| ⚠️ **Desempenho quente** | 20 min com conteúdo real, na Iris Xe | **Lei 4** |

⭐ **A linha do espólio é a que mais rende:** *"em 100 corridas de 100"* é literalmente impossível à mão, e é a única forma de provar uma garantia probabilística.

---

## 5. ⭐ E o modo que o Mateus descreveu: o agente **explora**

**Além dos ensaios escritos, há um modo que vale mais: deixar o agente andar por aí a partir coisas.**

| Modo | O que faz | O que apanha |
|---|---|---|
| **Guião** | faz exactamente o que está escrito | regressões — o que já funcionava e partiu |
| ⭐ **Macaco** | acções aleatórias com semente, milhares de frames | ⭐ **o que ninguém pensou em testar** |
| ⭐ **Varrimento** | percorre **todas** as combinações de arma × inimigo × classe | buracos de catálogo — a arma que ninguém testou |

⚠️ **O modo macaco é o que apanha os bugs de verdade**, e é barato: com semente fixa, um bug encontrado é **reproduzível**, o que é metade do trabalho de o corrigir.

**E o varrimento é o que escala com o catálogo:** 8 famílias × 36 inimigos × 6 classes = **1728 combinações**. Nenhum humano testa isso; um agente testa numa noite.

---

## 6. ⚠️ O que isto NÃO consegue fazer — e é importante dizer

| | |
|---|---|
| ❌ **Se o combate é divertido** | é a única coisa que importa e nenhuma máquina a mede |
| ❌ **Se um ataque "lê" bem** | o teste diz que **há** 0,50 s de aviso; não diz se se **percebe** |
| ❌ **Se a dificuldade está certa** | um agente com entrada perfeita ganha a tudo |
| ❌ **Se o mundo é interessante** | |

⭐ **Por isso o banco de ensaio não substitui o [`28-testes.md`](28-testes.md).** Ele prova que **o jogo faz o que a spec diz**. Se a spec diz a coisa errada, passa a verde na mesma.

⚠️ **A frase que fica:** *o agente prova a correcção; os dois amigos provam o jogo.*

---

## 7. Quando se constrói

⏳ **Não agora.** A ordem, e é do Mateus:

```
1. os modelos entram e substituem as cápsulas   ← fase 1.2, a meio
2. o catálogo enche (magia, armas, bestiário)
3. ⭐ AQUI — o banco de ensaio
4. e a partir daí corre em cada commit
```

⭐ **Porque é que faz sentido esperar:** um banco de ensaio sobre um jogo de 5 armas e 3 inimigos testa quase nada. Sobre 8 famílias e 36 inimigos, testa **1728 combinações** — e aí paga-se sozinho na primeira noite.

✅ **A peça barata foi feita antes de multiplicar conteúdo:** a **semente fixa** (§2) atravessa baralho, variação de IA e colocação. O banco completo continua `→WP14`; já não precisa de enxertar determinismo depois.

## O que fica em aberto

| | |
|---|---|
| O guião é JSON ou GDScript? *(proposta: JSON — um agente escreve-o sem compilar)* | `→WP14` |
| O modo macaco corre em cada commit, ou só de noite? | `→WP15B` |
| Quem lê os relatórios — o Codex sozinho, ou passa pelo Claude? | ⏳ donos |

## Ligações

[`38-ataques-e-honestidade.md`](38-ataques-e-honestidade.md) · [`28-testes.md`](28-testes.md) · [`36-fisica.md`](36-fisica.md) · [`43-estudo-espolio-inventario-mundo.md`](43-estudo-espolio-inventario-mundo.md) · [`58-fim-do-jogo-ciclos-e-a-curva.md`](58-fim-do-jogo-ciclos-e-a-curva.md) · [`44-prototipo.md`](44-prototipo.md) · [`23-tecnico.md`](23-tecnico.md)
