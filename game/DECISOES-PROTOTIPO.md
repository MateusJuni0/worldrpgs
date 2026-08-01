# Decisoes do prototipo `[PROTO]`

Decisoes pequenas que a spec nao cobre e que era preciso tomar para o codigo existir.
Cada uma tem a razao numa linha. **Nenhuma delas fecha uma pergunta da spec** — as
grandes estao em [PERGUNTAS.md](PERGUNTAS.md), por decidir pelo Mateus e pelo Rico.

Se a spec vier a dizer o contrario de qualquer uma destas, **manda a spec**.

---

### D1 · Dimensoes dos corpos
Jogador: capsula 1,80 m de altura, 0,35 m de raio. Lanceiro 1,90 / 0,45 · brutamontes 2,30 / 0,62 · Vorgar 3,00 / 0,85.
**Razao:** a spec fixa alcances de arma (1,2 a 2,3 m) mas nao tamanhos de corpo; os alcances so fazem sentido com corpos que lhes sirvam de escala. A silhueta tambem e informacao: o brutamontes tem de se ler como "lento e grande" antes de atacar.

### D2 · Motor: Godot 4.7.1-stable
**Instrucao directa do Rico**, nao decisao minha. Fica registado porque a spec tem a engine como `[EM ABERTO]` (WP13) — ver [PERGUNTAS.md](PERGUNTAS.md) P1. Instalado do canal oficial (`winget GodotEngine.GodotEngine`, que descarrega o zip do release `godotengine/godot` no GitHub com verificacao de hash).

### D3 · O combate corre em `_physics_process` a 60 Hz fixos
**Razao:** a spec escreve o combate em frames ("arranque 16 / activo 6 / recuperacao 18"). Com a fisica fixa em 60 Hz, 1 tick == 1 frame da spec e as janelas ficam **exactas mesmo que o render oscile**. Num souls-like, uma janela de i-frames que encolhe porque o fps caiu e injustica — e a Lei 4 a proteger a Lei 1.

### D4 · Tecla de conjurar: `C`
**Razao:** a tabela de comandos da spec tem "magia seguinte: F" mas **nao tem tecla para lancar a magia**. E um buraco, nao uma decisao — ver [PERGUNTAS.md](PERGUNTAS.md) P2. `C` esta livre e fica a mao esquerda.

### D5 · Bash de escudo = ataque leve com o escudo levantado
**Razao:** a spec da ao escudo um bash (14/4/16, MV 0,4, postura x2) mas nao lhe da botao. Sair com LMB durante o bloqueio e a convencao do genero e nao ocupa tecla nova.

### D6 · Andar (3,0 m/s) = segurar `Ctrl`; bloquear tambem move a 3,0
**Razao:** a spec da tres velocidades a pe (andar 3,0 · correr 5,0 · sprint 7,0) mas o teclado nao tem analogico — sem um modificador, os 3,0 m/s nunca sairiam. Correr continua a ser o passo por defeito, como a spec diz. Bloquear a andar e convencao do genero; a spec nao fixa velocidade a bloquear.

### ~~D7~~ · Numeros das magias — **SUBSTITUIDA pelo WP4**
`spec/13-magia.md` chegou durante a noite com o catalogo fechado, e os dados foram alinhados: Dardo 1 carga / 0,8 s / 45 base / 18 m a 20 m/s · Ruina 3 cargas / 1,6 s **parado** / 70 base / raio 4 m ate 12 m / marca 0,5 s antes · Egide 2 cargas / 0,5 s / absorve **120** ou dura **2,5 s**, com hiper-armadura enquanto dura. Acrescentou tambem que **conjurar exige cajado equipado**.
Ja nao ha nada `[PROTO]` nas magias da fatia.

### ~~D8~~ · Guarda de entrada — **SUBSTITUIDA pelo WP1B**
`spec/25-controlo.md` chegou durante a noite e fixa: entrada morre aos **400 ms**, capacidade **1**, a mais recente substitui a anterior, **esquiva tem prioridade** (esquiva no buffer nunca e trocada por ataque), e o **parry guarda-se so 80 ms** — porque guardar 200 ms de parry seria o jogo a acertar a janela pelo jogador. Implementado tal e qual, incluindo o contrato "o buffer nunca cancela nada".

### D9 · O cajado ocupa as duas maos (nao combina com escudo)
**Razao:** a spec contradiz-se — a tabela de bloqueio diz "machadao / cajado (duas maos) nao bloqueiam", e a linha seguinte diz "adaga/espada/**cajado** combinam com escudo na outra". Escolhi a tabela (numeros mandam sobre prosa) e o retrato do Feiticeiro em `10-fatia-1.md`: arranque so com cajado, "fragil ao perto", com o plano B a ser a pancada e nao o bloqueio. Ver [PERGUNTAS.md](PERGUNTAS.md) P3.

### ~~D10~~ · Distribuicao de atributos das classes — **SUBSTITUIDA pelo WP3**
`spec/12-classes.md` chegou durante a noite com as seis fichas fechadas, e os dados foram alinhados a letra (Guerreiro 11/11/10/8/12/10, Feiticeiro 10/10/9/14/9/10, etc.). O auto-teste compara cada ficha com a tabela do WP3.

**O que isto revelou:** o WP2 escreve "contra o jogador nivel 1 (Vida 10 → 420 PV, Con 10 → DEF 20)" e daí tira "o brutamontes mata em 4 golpes". Mas **nenhuma** das seis fichas do WP3 tem esse par — o Guerreiro tem Vida 11 (442 PV) e aguenta 5. Nao e contradicao, e uma ficha de referencia ilustrativa que deixou de existir quando as classes ficaram concretas. O teste verifica as duas coisas em separado.

### D11 · Curva de saida do rolamento
A spec da distancia (3,5 m) e duracao (0,60 s) mas nao a curva. Uso *ease-out* quadratica, cujo integral da exactamente 3,5 m.
**Razao:** velocidade constante faria o rolamento parar a seco; rapido no arranque e a morrer no fim e o que faz os i-frames 5–23 inclusivos (317 ms) cairem onde e util.

### D12 · Hiper-armadura do machadao carregado
A spec diz "frames 30–48". Sem carga isso e exactamente do frame 30 ao fim dos frames activos. Implementei como **frame 30 ate ao fim dos activos**, para que ao carregar (+20 f) a hiper-armadura continue a cobrir o golpe em vez de acabar antes dele.
**Razao:** ler "30–48" a letra faria o golpe carregado — o mais comprometido do jogo — ficar sem protecao precisamente quando bate.

### D13 · Alcances de IA (aggro, leash, distancia preferida, arcos dos golpes)
Nao estao na spec. Lanceiro agride a 16 m, larga a 34 · brutamontes 14 / 30 · Vorgar 20 / nunca larga.
**Razao:** sao os numeros que fazem a IA existir. O que a spec **impoe** esta cumprido e testado no arranque: arranque ≥ 30 f em todo o ataque, perseguicao < 5,0 m/s, anti-kite aos 4 s.

### D14 · O mundo e construido em codigo, nao em ficheiros de cena
**Razao:** greybox e so caixas e cilindros. Em codigo, o repositorio nao leva ficheiros binarios, cada mudanca de mundo e um diff legivel, e as arvores/pedras cabem em `MultiMeshInstance3D` — que e o que segura os draw calls em **20** e faz os 60 fps na Iris Xe.

### D15 · Fase 2 do Vorgar: a cadencia conta como padrao
A spec diz "a segunda muda padroes, nao numeros". Os golpes, frames e dano sao **identicos** nas duas fases; o que muda e a ordem, o comprimento das cadeias (1–2 → 2–3 golpes) e a pausa entre cadeias (1,7 s → 1,0 s).
**Razao:** sem mexer na pausa, a fase 2 quase nao se distingue. Assumi que ritmo e padrao. Ver [PERGUNTAS.md](PERGUNTAS.md) P8 — se acharem que a pausa e "numero", muda-se numa linha de JSON.

### D16 · Presets de qualidade (alto / medio / baixo)
Nao estao na spec. Existem para a Lei 4 ter um botao: mexem em sombras, densidade de nevoa, distancia de visao, numero de arvores e escala de render. Defeito **medio**.
**Razao:** e a forma honesta de escolher 60 fps em vez de bonito quando for preciso, sem tocar no combate.

### D8 — Frasco de cura (iteracao 2 do loop; substituida pela decisao da pergunta 7)
O prototipo nasceu com 3 usos, cura de 40% dos PV, 1,0 s a 40% de velocidade e
recarga no renascimento. A pergunta 7 decidiu depois o **modelo**: frasco
recarregavel no descanso, nunca pocoes compraveis. O contrato corrente do
[`spec/14`](../spec/14-equipamento.md) preserva 3 usos/40%, mas fixa os baselines
em 1,2 s e 50% de movimento. O gole continua gasto ao COMECAR — interrompido =
perdido. Tecla R, reservada na spec para 'usar item activo'. Valores correntes em
`data/combat.json` (`flask`).
