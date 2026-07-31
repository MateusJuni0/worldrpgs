# 25 — Câmara, controlo e game feel (WP1B)

> **Autor:** Claude (lado do Mateus). Tudo aqui é `[CLAUDE]` salvo indicação — proposto com justificação e alternativa descartada, à espera de confirmação de quem joga. **Fronteira com o WP1 (Fable):** o WP1 define *o que* as acções fazem (duração da esquiva, frames do parry, custos); este documento define *como se sente* dar a ordem — câmara, registo de comandos, latência e impacto. Onde um número daqui depende de um número do WP1, está marcado `→WP1`.

A lei que governa este documento é a 1, por uma via directa: **se o jogador carregou e o jogo não respondeu, ele não perdeu por falta de perícia — o jogo mentiu-lhe.** Cada sistema aqui existe para eliminar uma forma dessa mentira.

---

## 1. Câmara

### Números base

| Parâmetro | Valor | Porquê |
|---|---|---|
| Distância ao personagem | **4,0 m** (padrão) · 4,8 m em combate com lock-on | Perto o suficiente para ler a animação do jogador, longe o suficiente para ver o inimigo inteiro — num souls-like lê-se O INIMIGO, não o próprio boneco |
| Altura do pivô | 1,6 m (ombros) | Olhar por cima do ombro, não por cima da cabeça — mantém os inimigos no terço central do ecrã |
| Campo de visão (FOV) | **55°** vertical | FOV alto deforma a percepção de distância da esquiva; 55° é o compromisso entre leitura e claustrofobia. *Configurável 50–70° nas opções* |
| Suavização de seguimento | 0,12 s (posição) · 0,08 s (rotação) | Segue firme sem colar rígido; acima de 0,2 s a câmara "nada" e enjoa |
| Sensibilidade do rato | Linear, sem aceleração, escala 0,1×–3,0× | Aceleração de rato num jogo de precisão é a mentira nº1. **Nunca**, nem como opção |

*Alternativa descartada:* câmara à Zelda (mais alta, mais afastada) — vê mais mundo, mas lê pior a animação de um inimigo único, e este jogo vive disso.

### Colisão com geometria — a regra dos três passos

O caso que estraga um souls-like sozinho: corredor da dungeon, a câmara entala na parede, o jogador morre às cegas. Resolução em cascata:

1. **Encolher:** esfera de colisão da câmara (raio 0,25 m) desliza pela geometria; a câmara aproxima-se do personagem até ao mínimo de **1,2 m**.
2. **Desvanecer:** abaixo de 2,0 m de distância, o personagem fica translúcido (40% de opacidade) para não tapar o ecrã.
3. **Nunca atravessar:** a câmara não corta paredes. Se 1,2 m não chega (nicho fechado), sobe o pivô até 30° e olha de cima.

**Regra para o design das dungeons (`→WP8`):** nenhum espaço de combate com tecto abaixo de 2,5 m nem corredores de combate com menos de 3 m de largura. Combate em espaço apertado é escolha de design válida — mas testa-se com a câmara, não se descobre depois.

### Lock-on

`[CLAUDE]` — o lock-on existe. *Alternativa descartada:* câmara livre pura — mais "hardcore", mas com rato+teclado (a realidade das duas máquinas, sem comando) gerir câmara e esquiva ao mesmo tempo é fadiga sem recompensa.

| Parâmetro | Valor |
|---|---|
| Activação | Clique no botão do meio / Q · pressionar de novo solta |
| Alcance de aquisição | 18 m · perde-se a 24 m ou 3 s sem linha de vista |
| Troca de alvo | Flick do rato (±40 px horizontais) ou roda; 0,15 s de bloqueio entre trocas para não saltar sozinho |
| Enquadramento | Alvo no terço superior, jogador no terço inferior; a câmara roda a ≤ 180°/s — acima disso corta-se para o alvo |
| Alvo alto/próximo (chefe em cima do jogador) | O pivô inclina até 45° para cima; se o alvo ocupar > 60% da altura do ecrã, a câmara recua os 0,8 m extra do modo combate |
| Morte do alvo | Solta o lock e mantém a direcção da câmara — **não** salta sozinho para o inimigo seguinte (`[CLAUDE]`: saltar rouba a decisão ao jogador) |

**Em co-op:** cada jogador tem a sua câmara, sem excepções. A restrição vai para o design das arenas (`→WP7/WP8`): o chefe tem de ser legível de dois ângulos ao mesmo tempo — nada de mecânicas que exijam os dois jogadores no mesmo quadrante.

---

## 2. Registo de comandos (input buffer)

É aqui que vive a diferença entre "o jogo comeu-me o botão" e "eu enganei-me".

### O modelo

Uma acção pedida durante outra acção **não se perde**: guarda-se e dispara no primeiro frame em que for legal.

| Parâmetro | Valor | Porquê |
|---|---|---|
| Janela de guarda | **200 ms** antes do fim da acção corrente | O padrão do género anda entre 150–250 ms. 200 ms apanha a intenção sem transformar o combate numa fila de pedidos |
| Vida no buffer | A entrada morre se não disparar em 400 ms | Um ataque pedido há meio segundo já não é intenção, é acidente |
| Capacidade | **1 entrada** — a mais recente substitui a anterior | Fila de 2+ entradas = o personagem "joga sozinho" durante um segundo. *Alternativa descartada por isso mesmo* |

### O que é guardável

| Acção | Guardável? | Nota |
|---|---|---|
| Ataque (leve/pesado) | ✅ | O caso principal: pedir o segundo golpe durante o primeiro |
| Esquiva | ✅ | **E tem prioridade:** esquiva no buffer substitui ataque no buffer, nunca o contrário — o pedido de sobrevivência vence o pedido de dano |
| Parry | ✅ mas com janela de guarda **reduzida a 80 ms** | Parry é timing puro; guardar 200 ms de parry seria o jogo a acertar a janela pelo jogador — quebra a Lei 1 no sentido inverso (perícia a menos a ganhar na mesma) |
| Poção / item | ❌ | Beber poção é decisão deliberada, não reflexo. Pedida durante outra acção, ignora-se |
| Troca de magia / arma | ❌ | Idem |
| Salto/interacção | ❌ | Fora de combate a latência não é crítica |

### Cancelamentos

O que uma acção em curso permite interromper é **do WP1** (`→WP1` define os frames de cancelamento de cada ataque). O contrato deste documento: **o buffer nunca cancela nada** — só dispara quando a acção corrente *permite* a próxima. Buffer ≠ cancel; confundi-los dá combates moles.

---

## 3. Orçamento de latência

**Alvo: ≤ 83 ms** (5 frames a 60 fps) entre o dedo e a resposta visível no ecrã. **Tecto absoluto: 100 ms** — acima disso o parry deixa de ser aprendível, porque o cérebro já não liga causa e efeito na janela do género.

| Etapa | Orçamento |
|---|---|
| Sondagem do input (polling) | ≤ 8 ms — ler o dispositivo a cada frame, nunca por eventos com fila |
| Lógica do jogo (frame N) | ≤ 16,7 ms |
| Render (frame N+1) | ≤ 16,7 ms |
| Apresentação + ecrã (60 Hz) | ~33 ms (espera de vsync + scanout) |
| **Total típico** | **~75 ms** ✅ |

Regras que defendem o orçamento:

- **A resposta começa no primeiro frame.** O primeiro frame da esquiva já mexe o corpo (mesmo que 2 cm). Animações com arranque "bonito" de 4 frames parados são latência disfarçada de estilo.
- **Fila de render de 1 frame no máximo.** Triple buffering com fila longa dá +33 ms invisíveis ao programador e óbvios à mão. (`→WP14`: configurar a engine explicitamente.)
- **Medir com câmara de telemóvel a 240 fps** apontada ao ecrã+teclado: método barato, real, e mede o sistema inteiro. Medição da engine sozinha mente por omissão (não vê o ecrã). Protocolo completo no WP15B.
- Queda de fps degrada isto tudo em cadeia — mais um motivo para os 60 estáveis da Lei 4 serem inegociáveis.

---

## 4. Sensação de impacto

O machadão tem de se sentir pesado e o parry tem de estalar. Quase tudo aqui é barato em desempenho — é design, não hardware.

### Paragem de impacto (hit-stop)

Congelar o jogo (os dois personagens envolvidos, não o mundo) por alguns frames no momento do acerto:

| Evento | Frames congelados (a 60) | Nota |
|---|---|---|
| Golpe leve acerta | 3 | Um "toque" |
| Golpe pesado / machadão acerta | 6 | O peso vem daqui, não do dano |
| **Parry bem-sucedido** | **10** + flash branco de 2 frames | O momento-assinatura do jogo; tem de ser inconfundível |
| Golpe bloqueado no escudo | 4 | |
| Golpe final (mata o inimigo) | 8 | Pontuação da frase |
| Jogador leva dano | 4 | O dano recebido também tem de "existir" |

*Custo: zero em render (é pausa de lógica local). O melhor rácio sensação/custo do jogo inteiro.*

### Tremor de ecrã

Sempre **rotacional pequeno** (±0,3°), nunca translação grande; duração ≤ 150 ms; decaimento exponencial.

| Evento | Intensidade |
|---|---|
| Golpe pesado acerta | 0,3° · 100 ms |
| Chefe bate no chão | 0,5° · 150 ms |
| Jogador leva dano | 0,2° · 80 ms |
| Golpes leves | **nenhum** — tremer a cada golpe anestesia o tremor |

**Tecto de acessibilidade:** slider de tremor 0–100% nas opções (`→WP11`). Enjoa gente real.

### Feedback de acerto — a pilha completa

Cada golpe que acerta dispara, em conjunto: hit-stop + flash no atingido (branco 1 frame) + partícula no ponto de impacto (faísca em metal, sangue escuro em carne, lasca em madeira/pedra — `→WP12`) + som da superfície certa (`→WP12`) + número de dano *(se existir — `[EM ABERTO]` para os donos: números a saltar é decisão de tom, não técnica)*.

**Regra de legibilidade (herdada do WP12):** nenhum efeito de impacto pode tapar a animação do inimigo. O jogador está a meio de ler o próximo ataque — um efeito bonito que esconde a telegrafia é um efeito mau.

### O parry, por extenso

O momento mais raro e mais valioso pede a pilha máxima: 10 frames de hit-stop, flash branco, som metálico único (inconfundível com bloqueio normal), o inimigo **visivelmente** desequilibrado (animação de stagger própria, `→WP1` define a duração da janela de castigo), e **sem tremor de ecrã** — o mundo pára limpo, não estremece. *Alternativa descartada: câmara a fazer zoom no parry — cinematográfico, mas rouba 200 ms de leitura do combate em curso.*

---

## 5. Esquema de comandos (teclado + rato — o que as duas máquinas têm)

`[CLAUDE]` proposta inicial; afina-se a jogar. Comando físico fica especificado quando existir um (`→WP11` faz o mapa completo e o remapeamento).

| Acção | Tecla |
|---|---|
| Mover | WASD |
| Câmara | Rato |
| Ataque leve / pesado | Clique esq. / Shift+clique esq. |
| Bloquear (manter) / **Parry (toque)** | Clique dir. (manter/tocar) — mesma tecla, intenção pelo tempo de pressão; limiar: toque ≤ 150 ms |
| Esquiva | Espaço |
| Lock-on | Q ou botão do meio |
| Poção | E · Magias: 1/2/3 · Interagir: F · Trocar arma: R · Mochila: Tab · Pausa: Esc |

*Nota ao limiar dos 150 ms:* bloquear e aparar na mesma tecla é a convenção do género com escudo; o limiar tem de ser testado cedo no protótipo (WP15B) — se os testes mostrarem parries "engolidos" pelo bloqueio, separa-se o parry para tecla própria **antes** de afinar qualquer outro número, porque contamina todos os testes da Lei 1.

---

## 6. O contrato deste documento

Quando um jogador disser **"eu carreguei e não fez"**, isso é um defeito destes sistemas — buffer, latência ou legibilidade — e trata-se como **bug de justiça**, prioridade acima de conteúdo novo. Nunca se responde "aprende o timing" sem primeiro provar (com a medição do §3) que o sistema não mentiu.

## Ligações

- Frames e custos das acções: `spec/01-combate.md` (WP1, Fable — em curso)
- Efeitos e sons de impacto: WP12 · Opções e remapeamento: WP11 · Protocolos de medição: WP15B
- Leis e etiquetas: [`../CLAUDE.md`](../CLAUDE.md) · [`../prompts/BRIEFING-FABLE.md`](../prompts/BRIEFING-FABLE.md)
