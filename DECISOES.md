# Registo de decisões

Todas as decisões dos donos, por ordem, com o que cada uma substitui.

**Para que serve:** o Fable esteve a construir localmente enquanto isto era decidido. Quando os commits dele chegarem, é contra esta lista que se compara — linha a linha, para ver o que foi construído sobre premissas antigas.

Ordem inversa: **o mais recente primeiro.**

---

## 31-07-2026 · tarde

### Escala do catálogo e a regra dos comandos → [`spec/34-catalogo-e-comandos.md`](spec/34-catalogo-e-comandos.md)
- ~**30 armaduras**, cada uma com habilidade ou identidade própria. Nenhuma existe só para dar defesa
- ~**20 armas por classe** (≈120), em famílias que **partilham conjunto de movimentos**
- ⚠️ **Toda a habilidade diz como se activa, na mesma linha.** Armaduras → passivas ou condicionais; armas → uma tecla partilhada de arte de arma
- **Substitui:** nada. Acrescenta uma regra de processo que vale para trás — o WP3, WP4 e WP5 têm de ser revistos contra ela

### Os quatro casos das almas → [`spec/33-morte-e-almas.md`](spec/33-morte-e-almas.md) §4
- **Um ressuscitado a tempo:** não perde nada · **um morre e o minuto passa:** almas ficam onde caiu · **os dois morrem:** duas manchas separadas, uma por cada · **solo:** igual ao segundo caso
- Recuperar = voltar e apanhar. **Morrer outra vez antes de apanhar perde-as de vez**
- ⚠️ Se os dois morrerem na arena do chefe, as manchas ficam lá dentro com o chefe vivo. **É tensão de propósito — ninguém conserte isto**
- **Substitui:** a linha vaga de que as almas "ficam no corpo"

### Ressurreição afinada → [`spec/34-catalogo-e-comandos.md`](spec/34-catalogo-e-comandos.md) §3
- Canalização passa a **5–7 s** (era 5 fixo)
- **Quem morre larga itens**, não só almas
- **Substitui:** o valor fixo de 5 s no [`33-morte-e-almas.md`](spec/33-morte-e-almas.md)

### Morte, almas, cura e armadura → [`spec/33-morte-e-almas.md`](spec/33-morte-e-almas.md)
- **Almas** = moeda e experiência. Nível **1→100**. Caem no sítio da morte; morrer outra vez perde-as
- **Frascos** que recarregam nos **pontos de descanso**; descansar **faz voltar os inimigos**
- **Armadura existe, muitas, por peças**; inimigos largam o que usam
- **Co-op:** o morto fica no mundo do parceiro, **1 min** de janela, ressuscita-se ficando em cima do corpo
- **Substitui:** *"não se perde nada ao morrer"* (WP0) · *"o jogador morto fica morto até o combate acabar"* (WP1) · a pergunta 7 aberta · a pergunta 14 aberta

### A fase muda: spec → construção → [`spec/32-construcao.md`](spec/32-construcao.md)
- O Fable **passa a escrever código**
- **A spec manda:** código que diverja obriga a mudar a spec no mesmo PR
- Reserva passa a ser **por marco**, não por pacote
- **Substitui:** a regra *"não escreves código"* no briefing, no `CLAUDE.md` e no `README.md`

### Referências → [`spec/31-referencias.md`](spec/31-referencias.md)
- **Dark Souls** é a referência; **DS2 é o chão aceitável**
- **Protocolo:** recolher números → tabela *eles·nós·diferença* → nomear a diferença → escrever a nossa versão → citar fonte
- ⚠️ **A linha:** padrões sim, conteúdo não. Nada extraído de outro jogo entra no repositório
- **Substitui:** nada. ⏳ **Os 11 documentos do PR #11 não passaram por este protocolo** — falta uma revisão

### Qualidade visual → [`spec/30-qualidade-visual.md`](spec/30-qualidade-visual.md)
- **Não é PlayStation 1.** 8–15 mil tri por personagem, texturas 1–2K
- **Substitui:** a expressão *"baixo poligonal"* em cinco documentos

### Perspectiva → [`spec/29-perspectiva.md`](spec/29-perspectiva.md)
- **Primeira ou terceira pessoa, à escolha do jogador**
- ⚠️ Em 1.ª pessoa não há visão periférica → **todo o ataque anunciado por som direccional antes de entrar no ecrã**
- **Plataforma: PC**
- **Substitui:** *"terceira pessoa"* em 6 documentos. ⏳ O bestiário do PR #11 ainda não tem os sons por ataque

## 31-07-2026 · manhã

### Sete decisões aprovadas pelos dois
| | |
|---|---|
| Fatia 1 | aprovada como está |
| 6 classes na fatia | confirmadas |
| **Evoluções de classe** | **opção A** — opções, não números; por marco, não por nível |
| **Magia bem/mal** | aprovada; preço do mal é **PV à vista**. A fatia usa **as duas escolas** |
| 7 raças + Ceifador | aprovados |
| 3D | **caminho A** |
| **Soft gating** | mapa aberto, dificuldade sugerida e não exigida |
| **Mapa** | ~30 min a pé, **10+ biomas** |
| **Tom** | sombrio a sério · **Idioma:** português |

⚠️ **Divergência viva:** o WP8 desenhou **6 zonas**; foram aprovados **10+**.

## 30-07-2026 · sessão 1 (gravada)

As decisões originais, com timestamp, em [`spec/00-visao.md`](spec/00-visao.md) e nos documentos de cada área. As quatro leis saem daqui.

---

## Como usar isto quando os commits do Fable chegarem

1. **Ver a data do trabalho dele.** Tudo o que for anterior a 31-07 tarde não conhece as decisões de cima
2. **Percorrer esta lista de cima para baixo**, e para cada uma perguntar: *o código dele assume o contrário?*
3. **Os candidatos mais prováveis a divergir**, por ordem de risco:
   - **Morte** — se implementou "não se perde nada", está desactualizado
   - **Ressurreição em co-op** — se implementou "fica morto até o combate acabar", está desactualizado
   - **Perspectiva** — se assumiu só terceira pessoa, falta metade
   - **Habilidades sem tecla** — se criou habilidades sem dizer como se activam
   - **Cura** — se assumiu poções compráveis em vez de frascos
4. **A spec manda** ([`spec/32-construcao.md`](spec/32-construcao.md)): o código alinha-se com ela, não o contrário. Mas se ele descobriu a construir que um número não funciona, **isso muda a spec** — e é bom.
