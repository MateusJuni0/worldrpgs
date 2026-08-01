# Para o Opus do Rico — a camada de rede

> **Escrito 01-08-2026.** Enquanto isto for lido, há **8 agentes Codex a trabalhar em paralelo** no resto do jogo, cada um na sua árvore git. Este documento existe para o teu trabalho **não colidir com nenhum deles**.

---

## 1. Contexto da sessão pai

| | |
|---|---|
| **Projecto** | WorldRPGs — RPG 3D souls-like, co-op para dois. Hobby do Mateus e do Rico |
| **Repositório** | `MateusJuni0/worldrpgs` — **público**, ⚠️ nunca commitar segredos nem caminhos `C:\Users\...` |
| **Motor** | Godot 4.7.1-stable, renderer **Mobile**, GDScript |
| **Máquina alvo** | **Intel Iris Xe integrados, 8 GB RAM, 1080p @ 60 fps** — a do Rico, e é a mais fraca. É a Lei 4 |
| **Ler primeiro** | [`CLAUDE.md`](../CLAUDE.md) · [`ESTADO.md`](../ESTADO.md) · [`spec/19-rede.md`](../spec/19-rede.md) |

**Preferências que não se negoceiam:** comunicação e documentação em português; código, commits e nomes de ficheiro em inglês; **sem falhas silenciosas**.

---

## 2. ⭐ A tarefa: a camada de rede

**Porquê esta e não outra:** a `game/src/net/` está **vazia**. O jogo é co-op por desenho e hoje só se joga sozinho. É a maior peça em falta, está **completamente especificada**, e **nenhum dos 8 agentes lhe toca**.

### O que já está `[DECIDIDO]` — não voltes a decidir

Tudo isto vem do [`spec/19-rede.md`](../spec/19-rede.md), que está fechado:

- **Dois jogadores exactamente.** A arquitectura assume 2 e ganha simplicidade com isso
- **Um hospeda, o outro entra.** O mundo mostrado é o do anfitrião; qualquer um pode hospedar
- **Entrar numa sessão: menos de 2 minutos, sem editar ficheiros.** É critério de aceitação da fatia
- **Anfitrião autoritativo sobre o mundo; cada jogador autoritativo sobre o próprio corpo**
- **Instantâneos a 20 Hz** com interpolação de 100 ms · simulação local a 60 Hz
- **Eventos fiáveis e imediatos** para golpes, parries e aggro
- **Menos de 30 kbps por sentido**, com 2 jogadores e ≤ 5 inimigos
- **Latência alvo < 80 ms.** Acima de 150 ms sustentados, ⭐ **aviso discreto no ecrã** — o jogo não esconde a linha má, porque esconder faria a injustiça parecer do jogo
- ⭐ **Sem fogo amigo em nada** — nem magia, nem corpo a corpo
- ⭐ **Código agnóstico ao transporte.** Liga a um endereço; de onde ele vem não é problema do jogo. Isto é o que permite migrar para relay mais tarde sem partir nada

### ⏳ O que é decisão dos donos — propõe, não decides

- **Como se atravessa o NAT.** A recomendação escrita é *porta aberta, com Tailscale como plano B*. É a única decisão daqui que pede acção no router — **é do Mateus e do Rico**

### O que construir

1. ⭐ **Hospedar e entrar.** Menos de 2 minutos, sem editar ficheiros. Se falhar, **diz porquê em português no ecrã** — nunca um código de erro
2. ⭐ **Replicação do corpo:** posição, orientação, estado de animação, a 20 Hz com interpolação
3. ⭐ **Eventos de combate fiáveis:** golpe acertou, parry, morte, aggro. ⚠️ Estes **nunca** podem chegar fora de ordem nem perder-se — um golpe que não conta é a Lei 1 quebrada
4. **Estado do mundo do anfitrião:** inimigos, espólio, fogueiras
5. ⭐ **O medidor de latência visível** quando a linha está má
6. ⚠️ **Reconexão.** Cair a meio de um chefe e voltar tem de funcionar, ou tem de falhar de forma limpa e dizê-lo

---

## 3. ⛔ Ficheiros que **não** podes tocar

Cada um tem dono a trabalhar neste momento:

| Não tocar | Quem está lá |
|---|---|
| `game/src/coop/` · `game/src/enemies/encounter*.gd` | agente do co-op |
| `game/src/enemies/boss*.gd` · `game/src/world/arena*.gd` | agente do Vorgar |
| `game/src/world/bonfire*.gd` · `game/src/progression/` | agente da fogueira e das almas |
| `game/data/enemies.json` | agente da gramática de ataque |
| `game/src/spells/` · `game/src/vfx/` | agente da magia |
| `game/src/ui/equipment_screen*.gd` · `game/src/visual/armor_visual*.gd` | agente do equipamento |
| `game/src/ui/game_shell.gd` · `hud.gd` · `inventory_menu.gd` | vários |

**Teus:** `game/src/net/` (vazia, é tua toda) · `spec/19-rede.md`.

⭐ **Precisas de algo que está fora disto?** Escreve no [`LACUNAS.md`](../LACUNAS.md) exactamente o que precisas e de quem. **Não mexas.**

---

## 4. As regras do repositório

### As quatro leis
1. **Ganha-se com habilidade, não com nível.** Nada de gating, nada de grind
2. **As melhorias dão opções, não números**
3. **Qualquer classe pega em qualquer arma**
4. **A máquina alvo manda.** Queda de fotogramas num souls-like não é feio, é injusto

### As etiquetas
`[DECIDIDO]` não se mexe · `[TENSÃO]` **não se decide**, propõe-se · o que decidires é `[CODEX]` ou `[FABLE]` **com razão e alternativa descartada**

### Antes de dizer que está feito
```bash
cd game && ./VERIFICAR.bat
```
São **6 verificações**, incluindo o arranque real do jogo. **9703 têm de continuar a passar, nunca menos.**

⚠️ Se der `Identifier X not declared`, corre primeiro com `--import` — é a cache de classes do Godot, não é o teu código.

### ⭐ As quatro perguntas do fio solto
**Nada entra sem responder às quatro:**
1. Como é que o jogador usa isto? *(uma acção sem tecla não existe no jogo)*
2. Como é que se prova que funciona? *(um teste, ou um número medido)*
3. De onde vem a arte e o som?
4. Quanto custa na máquina do Rico?

### Aviso de processo, aprendido hoje da maneira difícil
⚠️ **Um teste em ficheiro próprio que ninguém corre não é um teste, é um ficheiro.** Já aconteceu aqui: 92 verificações a existir e a não correr. **Se criares um script de teste, acrescenta-o ao `game/VERIFICAR.bat` no mesmo acto.**

⚠️ **E não sujes a pasta de saves.** Todas as árvores partilham o mesmo `user://`. Um teste que escreveu nos três slots deixou o Mateus sem conseguir começar jogo nenhum. **Limpa o que escreveres.**

---

## 5. Alternativas, se a rede não servir

Por ordem de valor, e todas livres de donos:

| | O quê | Porquê importa |
|---|---|---|
| **B** | **O mundo para além de Brumal** — os 12 biomas, WP8 | Está desenhado e não construído. O jogo tem uma zona |
| **C** | **NG+ e o fim do jogo** — [`spec/58`](../spec/58-fim-do-jogo-ciclos-e-a-curva.md) | Escrito com a curva calculada, zero código |
| **D** | **Os outros 12 chefes** | Só o Vorgar existe |

---

## 6. Como entregar

- **Commits em português**, a explicar **o porquê**, não o quê
- ⚠️ **Não faças push para `main`.** Abre PR, ou commita no teu ramo e avisa
- No fim: um resumo do que ficou feito, do que ficou por fazer, e **os números que mediste**
