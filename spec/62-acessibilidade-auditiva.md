# 62 — Acessibilidade auditiva: a mesma informação por outro canal

> **Tarefa 2.2 · Codex** (01-08-2026). Este documento corrige uma falha do contrato do [`38`](38-ataques-e-honestidade.md) §3: som direccional era informação obrigatória, sobretudo em primeira pessoa, mas não tinha equivalente para quem não o ouve. Tudo `[CODEX]` salvo indicação.

**Não é um sistema de legendas.** “Passos atrás” e “grito à esquerda” chegam tarde, ocupam leitura e não dizem **quando** o golpe acende. Cada tipo de som informativo recebe uma forma visual própria, no sítio, no tempo e com a duração da informação que substitui.

`[CODEX]` **Razão:** se desligar o som muda quais ataques são evitáveis, o volume é um selector de dificuldade escondido e a Lei 1 falha. **Alternativa descartada:** legendas direccionais genéricas; traduzem áudio em texto, mas obrigam o jogador a ler frases enquanto luta e não reproduzem trajectória, área nem momento de compromisso.

---

## 1. O evento de jogo vem antes do som

O código não pergunta “que áudio está a tocar?”. O ataque, perigo ou estado emite **um evento informativo**; áudio e visual são duas apresentações do mesmo facto.

```text
evento de jogo
  ├─ áudio: amostra + posição + atenuação
  └─ visual: forma + âncora + pulso + duração
```

Campos mínimos do evento:

| Campo | O que transporta |
|---|---|
| `cue_id` | identidade estável; nunca o nome do ficheiro de áudio |
| `tipo` | ataque, projéctil, área, alerta, estado, co-op, segredo ou confirmação |
| `origem` | entidade/posição que o som e o visual partilham |
| `inicio` · `compromisso` · `fim` | os três momentos que o pulso visual tem de reproduzir |
| `resposta` | aparar, esquivar, sair, juntar, separar, olhar ou confirmar |
| `alcance_informativo` | onde o som seria audível com mistura normal; o visual não atravessa o mundo inteiro |
| `oclusao` | visível, fora do ecrã ou atrás de obstáculo |
| `prioridade` | ameaça fatal > ataque > estado do jogador > co-op > confirmação > atmosfera |

**O volume não apaga o evento.** Efeitos, música, ambiente e vozes podem ir a **zero**; o renderer visual continua a receber os mesmos eventos. Inversamente, desligar reforços visuais não altera o som.

### O contrato de equivalência

O equivalente visual responde às mesmas cinco perguntas que o som:

1. **De onde vem?** — âncora no mundo ou bordo do ecrã com direcção.
2. **O que é?** — forma fixa por tipo/resposta, nunca apenas cor.
3. **Quando fica perigoso?** — pulso fecha no frame de compromisso.
4. **Até quando importa?** — persiste enquanto o projéctil/volume/estado persistir.
5. **O que aconteceu?** — acerto, cancelamento, defesa, erro ou fim têm saídas diferentes.

⚠️ **Não revela mais do que o áudio.** Atrás de uma parede mostra direcção e classe de perigo, não a silhueta exacta nem a barra do inimigo. A distância aparece em três bandas — perto, médio, longe — como a atenuação sonora, nunca em metros.

---

## 2. A língua visual do combate

### Âncora visível e indicador fora do ecrã

| Situação | Forma |
|---|---|
| Origem dentro do ecrã | sinal preso ao membro, arma, chão ou projéctil que produz a informação |
| Origem fora do ecrã | cunha no bordo, alinhada à direcção; aproxima-se do centro à medida que o compromisso chega |
| Origem atrás de obstáculo | cunha tracejada no bordo; nunca desenha contorno através da parede |
| Origem acima/abaixo | entalhe no topo/fundo da cunha; não depende de auscultadores para verticalidade |

O indicador aparece **no mesmo frame** em que começaria o som informativo e some quando a fonte deixa de poder afectar o jogador. Se o ataque é cancelado, a forma **quebra e dissolve em 0,15 s**; nunca continua a prometer um golpe que já não vem.

### Forma por resposta — cor é redundância

| Resposta | Forma e movimento | Cor auxiliar |
|---|---|---|
| **APARAR** | dois chevrons finos `><` fecham no ponto de compromisso | branco frio |
| **ESQUIVAR** | losango partido roda um quarto de volta e fecha | vermelho |
| **SAIR DA ÁREA** | contorno hachurado no chão enche de fora para dentro | vermelho escuro |
| **MOVER PARA UM LADO** | seta dupla perpendicular ao vector do ataque | branco/vermelho |
| **JUNTAR** | dois arcos convergem para a mesma zona segura | âmbar |
| **SEPARAR** | dois arcos repelem-se e cada alvo recebe a sua metade | âmbar/vermelho |
| **OLHAR / ALERTA** | olho aberto + leque de direcção, sem pulso de impacto | branco |

**A silhueta e a marca no chão continuam a ser a primeira língua.** Estes sinais não substituem animação pobre; tornam visível a informação que antes existia só no som, sobretudo fora do ecrã e em primeira pessoa.

### Tempo

- O preenchimento é linear pelo **tempo real das fases 1+2** do [`38`](38-ataques-e-honestidade.md), não uma animação aproximada.
- O fecho coincide com o primeiro frame activo; antecipar ou atrasar **> 1 frame a 60 Hz** falha.
- Combos mostram um pulso por compromisso. O segundo golpe não herda um indicador ainda fechado do primeiro.
- Volume persistente mantém contorno e pulsa no intervalo real de dano; não sugere i-frames como resposta quando a resposta é sair.

---

## 3. O que substitui cada tipo de sinal sonoro do WorldRPGs

### A. Ataque inimigo — esforço, arrasto, assobio

| Som informativo | Equivalente visual |
|---|---|
| Esforço/arma a recuar | pulso preso ao membro/arma; forma APARAR ou ESQUIVAR fecha no compromisso |
| Arrasto grave de ataque não aparável | losango partido + brilho vermelho já exigido pelo [`21`](21-arte-render.md); não depende do grave ser audível |
| Agarrão com assobio agudo | dois ganchos visuais fecham em torno do torso do inimigo; fora do ecrã usa cunha ESQUIVAR |
| Ataque vindo de fora do ecrã | cunha direccional com a mesma forma de resposta e três bandas de distância |
| Combo / segundo tempo | novo pulso na mesma âncora; número de marcas curtas sob a forma diz quantos compromissos já foram anunciados |

**Campo obrigatório na ficha do [`38`](38-ataques-e-honestidade.md):** `sinal_visual_equivalente` — âncora, forma, início, compromisso, fim e comportamento fora do ecrã. “Brilho” sem dizer **onde/quando** não preenche o campo.

### B. Projéctil — voo, retorno e aproximação

| Som informativo | Equivalente visual |
|---|---|
| Projéctil lançado fora do ecrã | cunha nasce na origem e passa a seta móvel quando o projéctil pode acertar |
| Assobio de aproximação | rasto descontínuo cresce na direcção do movimento; a ponta aumenta nas bandas perto/médio/longe |
| Projéctil que volta | rasto tem duas pontas desde o lançamento; no retorno, a ponta traseira acende e o bordo oposto ganha cunha |
| Ricochete/aparável | chevrons APARAR presos ao projéctil apenas durante a janela em que pode ser desviado |

O arremesso de Vorgar deixa de depender do assobio do machado de regresso: o rasto e a cunha traseira são a segunda chamada, **1,2 s depois**, no mesmo instante do som escrito no [`16`](16-chefes.md).

### C. Área e perigo persistente

| Som informativo | Equivalente visual |
|---|---|
| Zumbido/carga de área | limite hachurado já inteiro no primeiro frame; preenchimento mostra quanto falta |
| Chão que causa dano por pulsos | segmentos do contorno piscam no intervalo real; a área nunca parece segura entre ticks |
| Sopro/onda atrás do jogador | leque no bordo mostra origem e abertura; ao entrar no ecrã liga-se à geometria real |
| Precipício por vento/água | faixa, silhueta e movimento do [`61`](61-arenas-de-chefe.md) §5; o som é só redundância |

### D. Alerta, perseguição e inimigo escondido

| Som informativo | Equivalente visual |
|---|---|
| Inimigo viu/ouviu o jogador | olho abre sobre o inimigo se visível; fora do ecrã, leque branco aponta a origem |
| Chamada que acorda aliados | uma onda visual curta sai do autor; aliados activados recebem um traço vertical por 0,5 s |
| Passos de ameaça fora do ecrã | arco oco de presença no bordo, sem resposta de combate; só vira cunha quando começa um ataque |
| Emboscada visível por som | movimento/sombra no cenário + arco de presença; nunca apenas texto “passos atrás” |

O arco de presença não mostra identidade, vida nem distância exacta. Diz apenas o que os passos diriam: **há alguém naquela direcção**.

### E. Estado do jogador — som do próprio corpo

| Som informativo | Equivalente visual |
|---|---|
| Esquiva/vento do corpo | varrimento fino nas margens começa no frame 1 e desvanece até ao fim dos i-frames; em 1.ª pessoa substitui o corpo invisível |
| Stamina esgotada/respiração | barra fica cheia a hachura, pisca 2× e ícones de acções bloqueadas ganham cadeado até aos 15 de histerese |
| Bloqueio | arco curto no lado do escudo + redução fantasma na stamina |
| Parry | estrela dourada de 12 frames no contacto + hit-stop; é o par visual do sino |
| Guarda/Postura quebrada | fragmentos + anel âmbar e barra quebrada, como o [`21`](21-arte-render.md) §5 |
| Dano/morte | fantasma da vida + vinheta de 0,3 s; morte corta o HUD antes do ecrã de renascimento |
| Frasco | carga sai da hotbar no início; progresso circular de 1,2 s; cura entra na barra no frame autoritativo |

### F. Magia e habilidade

| Som informativo | Equivalente visual |
|---|---|
| Conjuração a carregar | glifo cresce durante o tempo real; cada forma tem silhueta própria, não apenas cor |
| Projéctil mágico em voo | rasto e ponta como B, com forma da escola |
| Égide a partir | placa visível estilhaça e a barra/ícone perde o segmento absorvido |
| Habilidade pronta | varrimento de recarga fecha e o ícone recupera contorno; o acorde é confirmação opcional |
| Magia do mal custa PV | motas saem do corpo no mesmo frame em que a barra perde PV, regra já escrita no [`21`](21-arte-render.md) |

### G. Co-op — parceiro, alvo e coordenação

| Som informativo | Equivalente visual |
|---|---|
| Parceiro leva golpe | barra do parceiro mostra dano fantasma; seta de parceiro pulsa na direcção |
| Parceiro cai / minuto começa | retrato muda para corpo caído + anel de 60 s; marcador no mundo é visível através da geometria porque representa o aliado, não um inimigo |
| Ressurreição a canalizar | anel de 5–7 s em volta do corpo, visto pelos dois; quebra visivelmente se interrompido |
| Chefe muda de alvo | olho âmbar já definido no [`20`](20-interface.md) + linha curta chefe→alvo durante 0,25 s |
| SEPARAR/JUNTAR | formas próprias do §2, ligadas às zonas da arena do [`61`](61-arenas-de-chefe.md) |
| Parceiro pronto no nevoeiro | nome + visto no patamar; “à espera” é estado, não pista sonora |

**Voz humana não é telegrafia.** Não se tenta transcrever conversa em combate como solução universal. Para quando um jogador não ouve ou a voz falha, a roda de comunicação tem quatro sinais visuais posicionais: **JUNTAR · ESPERA · AJUDA · OLHA**, com tecla configurável. A regra do [`56`](56-voz-e-vendedores.md) mantém-se: a voz nunca é dependência do jogo.

### H. Segredo, objecto e interface

| Som informativo | Equivalente visual |
|---|---|
| Mímico respira | tampa sobe/desce + pó sai da fresta; não há ícone que denuncie “mímico” |
| Corrente de ar/som atrás de parede falsa | pó e vegetação inclinam-se para a fenda + padrão/material diferente; preserva descoberta por atenção |
| Item/XP apanhado | objecto dissolve para o jogador + entrada curta no HUD com quantidade |
| Acção inválida / menu | controlo recusa, treme 2 px e mostra a razão junto ao campo; não depende de bip |
| Save/carregamento | selo de gravação anima enquanto escreve; nevoeiro mostra estado de prontidão |
| Música muda de exploração para combate/fase | estado já aparece no corpo, HUD/vida do chefe e geometria; a música nunca é a única notícia de combate |

**Diálogo e narrativa podem ter legendas próprias.** Isso é texto falado, não o sistema de sinais de combate deste documento. Nunca se usa uma legenda para substituir timing.

---

## 4. Aplicação imediata à fatia 1

As fichas existentes não ganham uma frase genérica; ganham a família visual correspondente:

| Inimigo / ataque | Som que informa | Equivalente visual obrigatório |
|---|---|---|
| Lanceiro · estocada | recuo/assobio da lança | linha fina na lança + seta perpendicular; cunha ESQUIVAR fora do ecrã |
| Lanceiro · dupla | dois esforços | duas marcas curtas; pulso reinicia no segundo compromisso |
| Lanceiro · varrimento baixo | arrasto horizontal | arco hachurado ao nível do chão + chevrons APARAR |
| Lanceiro · fecho/investida | patada + whoosh | seta no chão pela direcção real + cunha que fecha |
| Brutamontes · golpes aparáveis | esforço grave distinto | chevrons APARAR presos à arma; vertical/arco/impacto têm silhuetas diferentes |
| Vorgar · talho/varrimento/esmagamento | esforços por peso | APARAR com linha/arco/ponto de impacto próprios |
| Vorgar · investida | patada no chão | vector de 6,5 m no chão + ESQUIVAR; pilar que pode receber o choque pisca contorno uma vez |
| Vorgar · pancada de chão | carga grave | círculo hachurado de 5 m enche no aviso; não aparável sem depender do grave |
| Vorgar · transição | grito + música | corpo invulnerável, barra marca fase 2 e arena mostra o que mudou |
| Vorgar · machado de retorno do [`16`](16-chefes.md) | assobio traseiro | rasto de duas pontas + nova cunha no retorno |

⚠️ **Estado real do protótipo:** `Sfx` toca hoje um único `telegraph` sintetizado para todo o ataque e não existe renderer destes sinais. O desenho fica fechado agora para as próximas fichas nascerem com o campo; implementação e migração dos 12 ataques de `game/data/enemies.json` continuam trabalho de construção, registado no [`LACUNAS`](../LACUNAS.md).

---

## 5. Opções — o jogador escolhe intensidade, não acesso à informação

No primeiro arranque e em **Opções → Acessibilidade**:

| Opção | Valores |
|---|---|
| **Sinais visuais de jogo** | `essenciais` (silhueta/chão/estado) · **`reforçados`** (bordo direccional, presença, resposta e co-op) |
| Tamanho | 100% · 125% · 150% |
| Opacidade | 60–100%; nunca abaixo de 60 para sinais de dano |
| Reduzir flashes | on/off; on troca flash por expansão/contracção sem perder o frame |
| Cor | normal · deuteranopia · protanopia · tritanopia; forma e padrão não mudam |
| Áudio de jogo | qualquer canal pode ir a **0** sem aviso bloqueador |

**“Reforçados” é a recomendação para quem não usa áudio.** Não aumenta janela, alcance, dano nem i-frames; torna visível o mesmo evento. Pode ser activado durante o jogo, sem reiniciar e sem afectar o parceiro.

O perfil é configuração local, não estado de personagem; cada amigo vê os seus sinais e guarda-os fora do save de progresso do [`59`](59-saves.md).

---

## 6. Como se prova equivalência

### Banco sem som

Com efeitos, música, ambiente e vozes a **0**, em 1.ª e 3.ª pessoa:

1. Mostrar 20 ataques em ordem sem dano e pedir **origem · resposta · compromisso · fim**.
2. O jogador identifica **≥ 18/20** de cada perspectiva depois da apresentação inicial.
3. O teste do rolamento do [`38`](38-ataques-e-honestidade.md) continua **10/10**; o convidado repete com latência.
4. Vorgar: 10 tentativas com áudio e 10 sem áudio. A taxa de morte por ataque não pode piorar **> 10 pontos percentuais** sem explicação de aprendizagem.
5. Co-op: cada um reconhece 10/10 mudanças de alvo, quedas, SEPARAR/JUNTAR e nevoeiro pronto sem voz.

### Testes de falsos positivos

- Ataque cancelado: 20/20 sinais quebram antes do compromisso.
- Inimigo atrás de parede: o sinal dá direcção, mas 0/20 vezes revela identidade exacta.
- Som fora de alcance: não aparece indicador visual de ameaça.
- Música/ambiente a zero: nenhum evento informativo deixa de aparecer.
- Reduzir flashes ligado: tempos e respostas continuam iguais.

### Critério comparativo

“Parece legível” não fecha. Com o mesmo guião, a diferença entre o perfil áudio e o perfil visual mede-se em acertos e morte por ataque. Se o visual falha, corrige-se **âncora → forma → timing → tamanho**, por esta ordem; não se alarga a esquiva nem se baixa o dano.

---

## 7. As quatro perguntas do fio solto

### 1. Como é que o jogador usa isto?

Escolhe sinais `reforçados` no primeiro arranque ou nas opções. Durante o jogo lê formas presas à origem, cunhas no bordo, marcas no chão, estado do HUD e quatro pings de co-op. Não há comando novo para combate; a roda de comunicação usa uma acção configurável.

### 2. Como é que se prova que funciona?

Banco sem som, 20 sinais por perspectiva, rolamento 10/10, comparação áudio/visual de Vorgar, convidado com latência e testes de cancelamento/oclusão do §6. Cada ataque futuro falha o guarda de conteúdo se não declarar som **e** equivalente visual.

### 3. De onde vêm a arte e o som?

As formas são vectores simples num atlas/UI feito no projecto — chevrons, cunhas, hachuras, olho e arcos; não exigem binário nem pack novo. Rastros e marcas reutilizam efeitos do [`21`](21-arte-render.md). O áudio mantém os packs CC0 `Kenney — Impact Sounds` e `Kenney — RPG Audio` já em `art/audio/`; samples futuros não definem a regra, apenas apresentam o evento.

### 4. Quanto custa na máquina do Rico?

Máximo **8 sinais informativos activos**, um atlas, formas batched e zero texto/layout por frame. A prioridade nunca corta uma telegrafia que pode causar dano; corta primeiro atmosfera e confirmações. Orçamento: **≤ 0,20 ms de CPU e ≤ 2 draw calls** para o overlay no cenário 2 jogadores + 3 inimigos; p99 global continua ≤ 16,7 ms quente. Marcas 3D contam dentro das 300 partículas/4 emissores por personagem do [`21`](21-arte-render.md).

---

## O que fica por construir

| | Estado |
|---|---|
| Emissor comum `GameplayCue` + renderer visual | código; tem de entrar antes do catálogo WP6 crescer |
| Migrar os 12 ataques actuais para som/visual próprios | dados + teste de schema; o `telegraph` único é provisório |
| Roda JUNTAR/ESPERA/AJUDA/OLHA | WP10/WP11, agnóstica de teclado/comando |
| Afinar tamanho/opacidade | valores de partida acima; medem-se pelo [`63`](63-como-se-afinam-os-numeros.md) |

## Ligações

[`15-inimigos.md`](15-inimigos.md) · [`16-chefes.md`](16-chefes.md) · [`20-interface.md`](20-interface.md) · [`21-arte-render.md`](21-arte-render.md) · [`29-perspectiva.md`](29-perspectiva.md) · [`38-ataques-e-honestidade.md`](38-ataques-e-honestidade.md) · [`43-estudo-espolio-inventario-mundo.md`](43-estudo-espolio-inventario-mundo.md) · [`56-voz-e-vendedores.md`](56-voz-e-vendedores.md) · [`61-arenas-de-chefe.md`](61-arenas-de-chefe.md) · [`63-como-se-afinam-os-numeros.md`](63-como-se-afinam-os-numeros.md) · [`99-perguntas-abertas.md`](99-perguntas-abertas.md)
