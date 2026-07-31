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

### D7 · Numeros das magias que o WP4 ainda nao escreveu
A spec fixa **so os tempos de conjuracao** (Dardo 0,8 · Ruina 1,6 · Egide 0,5) e a hiper-armadura da Egide. Custo em cargas, dano base, raio, velocidade e duracao sao `[PROTO]`: Dardo 1 carga / 34 base · Ruina 2 cargas / 60 base / raio 4 m · Egide 1 carga / absorve 90 / 6 s.
**Razao:** sem isto as magias nao existem. A bolsa de cargas em si **nao** e `[PROTO]` — vem do WP2 (`cargas = 4 + ⌊Sab/4⌋`, totais e partilhadas).

### D8 · Guarda de entrada (*input buffer*) de 8 frames (~133 ms)
**Razao:** e territorio do WP1B (que ainda nao existe), mas sem buffer nenhum o jogo e injogavel — carregar em esquiva 2 frames antes da recuperacao acabar nao devia ser um erro do jogador. 8 frames e conservador; se o WP1B decidir outro valor, muda-se a constante.

### D9 · O cajado ocupa as duas maos (nao combina com escudo)
**Razao:** a spec contradiz-se — a tabela de bloqueio diz "machadao / cajado (duas maos) nao bloqueiam", e a linha seguinte diz "adaga/espada/**cajado** combinam com escudo na outra". Escolhi a tabela (numeros mandam sobre prosa) e o retrato do Feiticeiro em `10-fatia-1.md`: arranque so com cajado, "fragil ao perto", com o plano B a ser a pancada e nao o bloqueio. Ver [PERGUNTAS.md](PERGUNTAS.md) P3.

### D10 · Distribuicao de atributos das seis classes
O WP3 nao existe. Todas distribuem os +14 do WP2 sobre a base 8. **O Guerreiro nao e invencao**: esta ancorado no exemplo resolvido de `11-formulas.md` (For 12, Vida 10, Con 10, Stamina 10 → 420 PV, DEF 20, STA 100). As outras cinco sao `[PROTO]` ao gosto do papel. Um teste no arranque falha alto se alguma classe nao gastar exactamente +14.

### D11 · Curva de saida do rolamento
A spec da distancia (3,5 m) e duracao (0,60 s) mas nao a curva. Uso *ease-out* quadratica, cujo integral da exactamente 3,5 m.
**Razao:** velocidade constante faria o rolamento parar a seco; rapido no arranque e a morrer no fim e o que faz os i-frames dos 0,08–0,38 s cairem onde e util.

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
