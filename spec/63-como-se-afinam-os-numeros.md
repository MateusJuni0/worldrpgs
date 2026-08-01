# 63 — Como se afinam os números: medir, mudar um, provar

> **Tarefa 2.3 · Codex** (01-08-2026). O [`28`](28-testes.md) já define protocolos, métricas, sintomas-base, teste de fora, desempenho quente e rede. Este documento **não os repete**: transforma-os num processo diário para que “valida-se a jogar” tenha autor, ordem, tamanho de mudança, artefacto e condição de fecho. Tudo `[CODEX]` salvo indicação.

**A regra-mãe:** um número de partida só deixa de ser partida quando existe uma comparação antes/depois que mudou o sintoma previsto sem partir os guardas.

`[CODEX]` **Razão:** sem este ciclo, o primeiro valor que “não parece horrível” fica para sempre e passa por decisão sem nunca ter sido decidido. **Alternativa descartada:** afinar por consenso no fim de uma sessão; captura sensação, mas mistura dez causas, não se reproduz e não diz o que reverter.

---

## 1. O que o 28 possui e o que este documento acrescenta

| [`28`](28-testes.md) — continua autoritativo | Este `63` — camada que faltava |
|---|---|
| protocolo da Lei 1 | inventário de números e ordem causal |
| métricas do CSV | quem conduz, observa, calcula e altera |
| sintomas-base | árvore de diagnóstico antes de escolher valor |
| 3 sessões para confirmar sintoma | execução pareada A/B e tamanho máximo da mudança |
| teste de fora | quando um valor passa de partida a confirmado |
| desempenho/rede | artefacto, commit, regressão e congelamento |

Se os dois documentos parecerem divergir, o `28` manda nos **testes e tectos**; o `63` manda na **sequência de investigação e alteração**.

---

## 2. Quais números se afinam — e quais não são botões de dificuldade

### Grupo A — guardas: provam-se, não se “equilibram”

| Guarda | Onde | Regra |
|---|---|---|
| i-frames e duração da esquiva | `combat.json` / [`01`](01-combate.md) | não se alargam porque um ataque mata; o teste do rolamento prova-os |
| janela de parry | `combat.json` / [`01`](01-combate.md) | não escala por nível/classe; erro de input corrige controlo/telegrafia |
| aviso mínimo de 0,50 s | [`38`](38-ataques-e-honestidade.md) | é chão, não alvo; um ataque pode precisar de mais |
| hitbox = efeito visível | [`38`](38-ataques-e-honestidade.md) | muda geometria/arte em conjunto, nunca só para acertar mais |
| passo fixo 60 Hz | [`36`](36-fisica.md) | requisito de justiça |
| piso de defesa / soft caps / Lei 3 | [`39`](39-estudo-profundo.md) | corrigem-se para cumprir a lei, não por “sensação” isolada |
| p99 ≤ 16,7 ms / working set ≤ 2,5 GB | [`23`](23-tecnico.md), [`21`](21-arte-render.md) | optimiza-se o conteúdo; não se levanta o tecto |

Mudar um guarda é **mudar o jogo**. Só entra com evidência de que o contrato está errado, proposta explícita e decisão dos donos quando tocar numa `[TENSÃO]`/`[DECIDIDO]`.

### Grupo B — conteúdo afinável

| Família | Ficheiro(s) | Exemplos |
|---|---|---|
| Inimigo | `enemies.json` | PV, dano, postura, alcance, arco, recuperação, intervalo de padrões |
| Ataque | `enemies.json` + ficha do [`38`](38-ataques-e-honestidade.md) | abertura acima do mínimo, seguimento até compromisso, janela de castigo, volume/intervalo |
| Jogador/recursos | `combat.json`, `attributes.json` | custos/regeneração de stamina, frasco dentro do contrato, curvas de PV/DEF |
| Armas | `weapons.json` | dano base, custos, alcance, recuperação e postura entre famílias |
| Magias/habilidades | `spells.json`, `abilities.json` | custo, conjuração, alcance, área, duração, recuperação/cooldown |
| Armadura/carga | `armor.json`, `combat.json` | defesa/absorção, peso, regeneração e distância de rolamento sem tocar i-frames |
| Encontro | futuro `encontros.json` | composição, posição, intervalo e rota de fuga |
| Co-op/rede | inimigo + sessão | escolha de alvo, SEPARAR/JUNTAR, latência; multiplicador de PV continua pergunta 24 |
| Progressão/economia | curvas e catálogos futuros | custo de nível, almas por zona, preços, baralho garantido |
| Leitura/apresentação | [`21`](21-arte-render.md), [`62`](62-acessibilidade-auditiva.md) | duração/âncora do sinal, mistura, tamanho/opacidade, nunca janela escondida |

**Lei 2 durante a afinação:** base de dano pode equilibrar duas ferramentas existentes; uma **melhoria** não pode virar “+30%”. Se uma classe “não surpreende”, procura-se verbo, forma, custo e situação antes de multiplicador.

### Grupo C — nomes e escolhas dos donos

Valores dentro de `[TENSÃO]`, tom ou identidade não se fecham porque um CSV prefere uma opção. O agente apresenta as duas medições, recomenda e deixa a decisão no [`99`](99-perguntas-abertas.md). Exemplo actual: **PV do chefe a dois**.

---

## 3. A ordem causal — do instrumento ao número

Não se começa pelo valor que está mais perto no JSON.

| Ordem | Pergunta | Se falhar |
|---:|---|---|
| **0** | O build, save, semente, equipamento, perspectiva e commit são os mesmos? | invalida a comparação; refaz a baseline |
| **1** | O jogo corre justo? p99, input, latência e colisão passam? | corrige técnica primeiro; frame perdido imita dificuldade |
| **2** | O jogador percebeu origem, resposta e compromisso? | corrige silhueta/som/visual/ângulo; não toca dano |
| **3** | Havia uma resposta executável? rota, stamina, recuperação, tracking e sequência permitem agir? | corrige geometria/tempo de controlo |
| **4** | A resposta paga? janela de castigo, postura, posição e recurso premiam acerto? | corrige recompensa/recuperação |
| **5** | Quanto custa errar? | só agora dano, stamina perdida, frasco e estado |
| **6** | Quanto demora quando se joga bem? | PV/postura do alvo; dano global do jogador é último recurso |
| **7** | Funciona com duas pessoas/classes/perspectivas? | alvo, espaço e verbos co-op antes do multiplicador |
| **8** | A progressão/economia preserva isto ao longo da zona? | curva, almas, preços e drops depois do combate base |

**Se a ordem encontra uma falha, pára aí.** Afinar etapas abaixo enquanto uma acima falha mascara o defeito e cria outro.

### A ordem dentro da fatia 1

1. Input + esquiva/parry contra um lanceiro, sem dano.
2. Leitura áudio **e** visual dos ataques actuais.
3. Lanceiro (esquiva), brutamontes (parry), grupos e arena de Vorgar.
4. Stamina + frasco.
5. As 5 armas e 3 magias contra os mesmos três alvos.
6. Vorgar solo nível 1, depois personagem normal.
7. Vorgar co-op e latência.
8. Só depois: almas, custos, drops e curva de nível.

Afinam-se primeiro as ferramentas que contaminam todas as medições seguintes.

---

## 4. Quem mede o quê

| Papel | Pessoa/sistema | Responsabilidade |
|---|---|---|
| **Condutor** | Mateus ou Rico, alternados | joga o guião sem abrir dados nem receber coaching |
| **Observador** | o outro | marca contexto, intenção e frase exacta; não explica durante a tentativa |
| **Máquina alvo** | **Rico** | desempenho quente, memória e 1% low; a máquina do Mateus nunca aprova sozinha |
| **Dono do feel** | Mateus **e** Rico | dizem se a versão é divertida e se preserva identidade; empate não é resolvido pelo agente |
| **Instrumentação** | jogo + auto-testes | CSV/eventos, commit, semente, estado, invariantes e regressões |
| **Analista/executor** | Codex/Fable | agrega, formula hipótese, propõe uma mudança e actualiza spec + dados no mesmo commit |
| **Pessoa de fora** | alguém que não viu o jogo | aprendizagem/clareza no M5/M7; corrige o [`27`](27-aprendizagem.md) antes dos números |
| **Agente que joga** | banco do [`60`](60-o-agente-que-joga.md), quando existir | repetição determinística e combinações; não julga “percebi” ou “diverti-me” |

**Quem jogou não altera a meio.** Termina o bloco, fecha o relatório e só depois vê a hipótese. Isso impede que uma morte recente transforme o valor seguinte em vingança.

---

## 5. Uma volta de afinação — o protocolo de mudança

### 5.1 Congelar a baseline

Registar antes de jogar:

```text
commit · build · save/fixture · semente · solo/co-op · anfitrião
classe · atributos · equipamento · perspectiva · perfil áudio/visual
zona/inimigo/ataque · máquina · resolução · versão da spec
```

Sem isto, “ontem estava melhor” não pode ser investigado.

### 5.2 Escrever uma hipótese, não um desejo

```text
Sintoma: morro no ataque X apesar de identificar a resposta.
Suspeita: o seguimento continua 3 frames depois do compromisso.
Métrica que muda: mortes com esquiva correcta em 10 tentativas.
Mudança única: tracking_stop 3 frames mais cedo.
Guarda: aviso, dano, i-frames e outros ataques ficam iguais.
Resultado esperado: 0/10 mortes depois de sair do vector; TTK não muda.
```

### 5.3 Mudar uma variável

Primeiro passo normal, salvo bug matemático:

| Tipo | Passo máximo inicial |
|---|---:|
| abertura/recuperação/seguimento | **2 frames** (33 ms) |
| conjuração/cooldown curto | **0,10 s** |
| alcance/deslocamento | **0,25 m** |
| dano, PV, postura, custos e cura | **5%** |
| multiplicador co-op | **0,10** |
| grupo/carga/slot/carta | **1 unidade** |
| mistura | **2 dB** |
| sinal de UI | **10%** de tamanho/opacidade, dentro dos tectos |

Se 5% parece pequeno de mais para ser detectado, isso é sinal de que a hipótese ainda não está isolada — não licença para saltar 30%.

### 5.4 Comparar A/B pareado

- A = commit anterior; B = uma mudança.
- Mesma fixture/semente/equipamento e mesmo número de tentativas.
- Alterna ordem **A–B / B–A** entre condutores para aprendizagem/cansaço não favorecer sempre B.
- O CSV mede; o observador regista frases sem as traduzir (*“rolei e puxou-me”*, não *“hitbox má”*).
- Uma sessão detecta; **três sessões com o mesmo sintoma decidem**, como manda o [`28`](28-testes.md).

### 5.5 Aceitar, reverter ou repetir

| Resultado | Acção |
|---|---|
| métrica prevista melhora e guardas ficam verdes | aceita; repete 3 sessões e congela |
| não muda | reverte; a suspeita estava errada |
| melhora sintoma mas cria regressão vermelha | reverte; procura causa acima na ordem |
| dados dividem Mateus/Rico em questão de feel/tom | mantém proposta, regista `[TENSÃO]`, não decide |
| diferença existe só numa perspectiva/canal/classe | corrige essa apresentação/situação; não globaliza número |

---

## 6. Do sintoma ao primeiro valor — diagnóstico accionável

| Sintoma | Olha primeiro | Depois | Número só no fim | Não fazer |
|---|---|---|---|---|
| **“Morro sempre no mesmo ataque”** | identificação origem/resposta/compromisso nos dois canais | tracking, hitbox↔visual, rota, recovery/hit-stun, latência | dano **desse** ataque, se tudo acima passa | dar mais PV/i-frames ao jogador |
| “Esquivei certo e levou na mesma” | teste do rolamento + frame activo | seguimento pára antes da hitbox? colisão e rede | — é correcção, não balance | aumentar janela de esquiva |
| “Nunca consigo aparar este golpe” | forma APARAR/som e input real | startup acima do mínimo, limiar toque/segurar, recuperação falhada | recompensa do parry | alargar janela por classe/nível |
| “Este ataque nunca acerta” | alcance, navegação e vector de fuga | tracking até compromisso e escolha de distância | recuperação/dano não resolvem whiff | aumentar hitbox além do visual |
| “Morro com stamina cheia” | jogador tinha controlo e leu? | dano/combos sem intervalo | dano por golpe | subir stamina base global |
| “Morro sempre sem stamina” | causa do gasto: spam, bloqueio ou custo inevitável | regeneração/histerese e encontro | custo da acção concreta ±5% | dar stamina grátis por classe |
| “Chefe demora demais numa tentativa boa” | uptime: janelas de castigo e corrida até alvo | output esperado da arma/feitiço e defesa | PV/postura do chefe | subir dano de todas as armas |
| “Chefe acaba em segundos a dois” | escolha/alterna alvo e perguntas SEPARAR/JUNTAR | uptime duplo e controlo do espaço | PV co-op, sem fechar pergunta 24 | aumentar dano do chefe |
| “Uma classe é sempre a correcta” | que verbos/situações só ela resolve | custos, riscos, recuperação e ferramentas das outras | base de uma ferramenta concreta | bloquear arma ou buffar cinco classes |
| “Frasco nunca é usado” | existe janela segura e feedback de cura? | valor recebido vs dano médio | cura ±5% | encurtar animação decidida sem prova |
| “Frasco acaba sempre antes do chefe” | dano por encontro/rota e descanso | comuns que drenam recurso | dano desses comuns | dar cargas sem corrigir a zona |
| “A versão sem som morre mais” | paridade de forma/âncora/timing do [`62`](62-acessibilidade-auditiva.md) | oclusão/tamanho e sobreposição | opacidade/tamanho | baixar dificuldade do perfil |
| “Baixa fps só nesta arena” | draw calls, overdraw, animações e streaming | decoração/partículas/áudio residente | LOD/distância visual | encolher rota ou subir tecto de p99 |
| “O convidado leva golpes fantasma” | autoridade local, timestamp e latência | interpolação/rollback e indicador | tolerância de rede dentro do contrato | mexer nos frames do ataque |
| “Subir nível tornou a zona automática” | soft cap/curva/piso de defesa | fraquezas e padrões ignorados | escala do atributo | escalar inimigo pelo nível (gating escondido) |

### A pergunta exacta: “morro sempre no mesmo ataque”

1. Aconteceu em **3 sessões** ou é uma aprendizagem de hoje?
2. Antes do golpe, o jogador acertou origem + resposta + compromisso em **≥ 18/20**? Se não, leitura.
3. A resposta escrita em `como se escapa` funcionou **10/10** no banco? Se não, contrato/hitbox/tracking.
4. O jogador podia agir, tinha rota e recurso? Se não, sequência/arena/stamina.
5. Só então: o golpe respeita o tecto e a margem de erros prevista? Se não, dano.
6. Se tudo passa e o jogador escolheu outra resposta, **não muda nada**: é o jogo a ensinar padrão, como já distingue o [`28`](28-testes.md).

---

## 7. Como se sabe que está bom

Um valor fica **confirmado**, não “perfeito”, quando:

1. o guarda e os auto-testes passam;
2. o protocolo específico do [`28`](28-testes.md) passa;
3. o sintoma não reaparece em **3 sessões comparáveis**;
4. a mudança melhorou a métrica prevista sem regressão em classe, co-op, perspectiva, canal ou desempenho;
5. Mateus e Rico conseguem explicar **o que mudou e porquê** e ambos preferem jogar a versão;
6. existe artefacto com baseline, hipótese, diff, CSV/resumo e veredicto.

**Estado de afinação** (não são etiquetas da spec):

| Estado | Significa |
|---|---|
| `partida` | escrito por cálculo/referência, nunca comparado |
| `observado` | uma sessão mostrou efeito; não decide |
| `confirmado` | três sessões + guardas + artefacto |
| `regressão` | um conteúdo novo partiu um confirmado; reabre com a baseline antiga |

Depois de `confirmado`, congela-se. Só reabre por conteúdo novo, bug, decisão dos donos ou regressão medida. **Não se micro-afina porque uma tentativa correu mal.**

### Onde fica a prova

```text
medicoes/afinacao/<AAAA-MM-DD>-<sistema>/
  resumo.md          # baseline, hipótese, mudança, resultado, veredicto
  antes.csv          # ou referência ao artefacto bruto
  depois.csv
```

O commit que aceita B altera **spec + `game/data` + resumo** no mesmo acto e explica o porquê em português. CSV grande pode ficar como artefacto de medição se o tamanho o justificar; o resumo e hashes ficam no repositório.

---

## 8. A infra-estrutura que o método assume

O [`28`](28-testes.md) e o [`23`](23-tecnico.md) já assumem CSV sempre ligado, `tp arena_vorgar`, overlay, hitboxes e latência artificial. **Verificação no código a 01-08:** nada disso existe ainda; só há a semente fixa do greybox.

Antes da primeira afinação séria entram:

1. `TuningRecorder` com eventos do §2 do [`28`](28-testes.md), commit/fixture/semente e saída CSV;
2. comandos `tp`, `spawn`, `latencia`, `equipar`, `fase`, `invulneravel` e reset de tentativa;
3. overlay de hitbox, estado/frames, alvo/tracking, p99/memória e indicador de semente;
4. fixtures estáveis solo/co-op e perfis 1.ª/3.ª pessoa, áudio/visual;
5. comparação que recusa A/B com commits, fixtures ou dados diferentes fora da variável declarada.

**O medidor não pode mudar o que mede:** ring buffer em memória, escrita fora do frame de combate, ≤ **0,10 ms CPU** e ≤ **5 MB** residentes. Mede-se o overhead ligado/desligado antes de confiar nele.

---

## 9. As quatro perguntas do fio solto

### 1. Como é que o jogador usa isto?

Mateus/Rico escolhem um guião do `28`, um conduz e o outro observa. O agente congela baseline, escreve hipótese, muda uma variável em dados, alterna A/B e apresenta o veredicto. Não há menu de “balance”; são ferramentas de desenvolvimento fora da sessão normal.

### 2. Como é que se prova que funciona?

Cada número confirmado tem 3 sessões comparáveis, métrica prevista, guardas, antes/depois e artefacto. O próprio método passa quando uma fixture conhecida detecta uma mudança de 5%, reverte uma hipótese falsa e reproduz o mesmo relatório com a mesma semente.

### 3. De onde vêm a arte e o som?

Não cria conteúdo final. Overlay usa linhas, cápsulas e texto monoespaçado do debug; hitboxes e sinais reutilizam as formas já existentes. Som do jogo é o real da build para testar mistura/leitura; o gravador não toca som nem adiciona assets.

### 4. Quanto custa na máquina do Rico?

Instrumentação ≤ 0,10 ms CPU e ≤ 5 MB; grava em buffer e descarrega fora do frame de combate. O teste de desempenho final mede com overlay fechado e recorder ligado, porque o CSV “sempre ligado” faz parte do jogo de desenvolvimento. Se exceder, optimiza-se o recorder antes de afinar qualquer número.

---

## O que fica por construir

| | Estado |
|---|---|
| CSV/TuningRecorder e comandos que o `28` já assume | 🔴 bloqueia afinação reproduzível; registado no [`LACUNAS`](../LACUNAS.md) |
| Fixtures A/B e pasta `medicoes/afinacao/` | criam-se com a primeira volta real, não com dados inventados |
| Valores actuais da fatia | continuam `partida` até passarem este ciclo; 8435 auto-testes provam coerência, não feel |
| Pergunta 24 e outras `[TENSÃO]` | mede-se e recomenda-se; agentes não decidem |

## Ligações

[`01-combate.md`](01-combate.md) · [`11-formulas.md`](11-formulas.md) · [`21-arte-render.md`](21-arte-render.md) · [`23-tecnico.md`](23-tecnico.md) · [`28-testes.md`](28-testes.md) · [`38-ataques-e-honestidade.md`](38-ataques-e-honestidade.md) · [`60-o-agente-que-joga.md`](60-o-agente-que-joga.md) · [`62-acessibilidade-auditiva.md`](62-acessibilidade-auditiva.md) · [`99-perguntas-abertas.md`](99-perguntas-abertas.md)
