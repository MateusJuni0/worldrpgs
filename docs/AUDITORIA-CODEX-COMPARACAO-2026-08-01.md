# Auditoria 2 — comparação sistemática com Dark Souls 2 e 3

**01-08-2026, Codex (gpt-5.6-sol, esforço máximo).** Segunda auditoria, pedida pelo Mateus: *"lança o codex a comparar a nossa spec com o jogo"*. Leu os 58 documentos e comparou sistema a sistema.

> ⚠️ **Não é para aceitar em bloco.** Algumas críticas são discutíveis; o que **não** é está marcado no [`../LACUNAS.md`](../LACUNAS.md).

---

# 1. Sistemas que o DS2/DS3 têm e aqui faltam

## 1.1. Orçamento finito de magia e artes — P0

**Problema ·** A mana pode regressar a 100% em qualquer lugar após 40 segundos; simultaneamente, as artes continuam a “custar energia”, embora essa energia tenha sido revogada. Não existe, portanto, uma economia coerente de recursos entre descansos.

**DS2/DS3 ·** No DS2 cada feitiço tem usos próprios, normalmente entre 1 e 30, e descansar repõe esses usos mas também o mundo. No DS3, feitiços e weapon skills gastam o mesmo FP, reposto por descanso ou Ashen Estus finito. Isto obriga magia e artes a disputar um orçamento real. [Manual oficial do DS2](https://media-center.namcobandaigames.eu/manuals/darksouls2/pc/DS2-PC-Manual-EN.pdf), [FP no DS3](https://darksouls3.wikidot.com/focus-points).

**O que fazer ·** Criar um único recurso `Foco` para feitiços e artes. A meditação deve consumir uma carga finita, por exemplo duas por descanso, e recuperar 40–50% de Foco. Alternativa ainda mais barata: meditação só em pontos de descanso. A duração de 40 segundos, sozinha, não é um custo.

## 1.2. Estado real de uma mão/duas mãos — P0

**Problema ·** Cada arma tem uma arte a uma mão e outra a duas, mas não há comando, estado na máquina do jogador, transição ou regras de disponibilidade. É conteúdo que não pode ser seleccionado.

**DS2/DS3 ·** `Y/Triângulo` alterna a arma direita entre uma e duas mãos; manter alterna a esquerda. Isto troca moveset, bloqueio, skill e requisitos. No DS3, duas mãos também multiplicam Força efectiva por 1,5. [Controlos e duas mãos no DS3](https://darksouls3.wiki.fextralife.com/Dark%20Souls%203%20Wiki), [controlos do DS2](https://darksouls2.wikidot.com/controls).

**O que fazer ·** Adicionar `Empunhadura1H`/`Empunhadura2H`, um input próprio e uma transição de cerca de 12 frames, interrompível por dano. Cada ficha de arma declara moveset, bloqueio, arte e mãos ocupadas em ambos os estados. Não copiar o bónus de Força: aqui duas mãos deve dar opções, não números.

## 1.3. Preparação de feitiços

**Problema ·** Os oito favoritos podem ser alterados a qualquer momento. Logo, são apenas interface: os 25 feitiços estão efectivamente preparados em permanência. Desaparece a decisão “o que levo para esta zona?”.

**DS2/DS3 ·** Ambos usam Attunement: os feitiços são equipados no descanso e alguns ocupam vários espaços. No DS2 existem ainda usos por feitiço; no DS3 os espaços coexistem com FP. [Attunement no DS2](https://darksouls2.wiki.gg/wiki/Attunement), [Attunement no DS3](https://darksouls3.wiki.fextralife.com/Attunement).

**O que fazer ·** Manter os oito favoritos, mas só permitir alterá-los fora de combate ou num descanso. Não é necessário recuperar a estatística Attunement nem impedir que o jogador aprenda todos os feitiços.

## 1.4. Estado de sobrecarga

**Problema ·** A tabela termina em “pesado >70%”. Um jogador a 71% e outro a 140% têm a mesma mobilidade.

**DS2/DS3 ·** No DS3 existem três bandas até 100%; acima de 100% não se pode rolar, correr ou fazer sprint. No DS2 a distância do rolamento e a regeneração variam continuamente com o peso, com penalidades especiais acima de 100%. [Carga no DS3](https://www.gamerguides.com/dark-souls-iii/guide/basics/gameplay-2824/weapons-and-equipment), [carga no DS2](https://darksouls2.wiki.gg/wiki/Equipment_Load).

**O que fazer ·** Acrescentar `>100%`: sem rolamento nem sprint, apenas marcha. É barato, fecha exploits de inventário e dá significado ao limite máximo.

## 1.5. Repercussão contra paredes, escudos e corpos duros

**Problema ·** A spec diz que certos golpes verticais “não saem” em tectos baixos, mas não existe um sistema geral para uma arma embater numa parede ou ressaltar num escudo. Sem isto, alcance e direcção do golpe quase não interagem com o espaço.

**DS2/DS3 ·** Ataques podem ressaltar em paredes; escudos têm uma categoria oculta de deflection e podem provocar recoil no atacante. Escudos pequenos, médios e grandes deflectem classes diferentes de ataques. [Deflection no DS3](https://darksouls3.wikidot.com/falling), [parâmetros de recoil](https://soulsmodding.com/doku.php?id=tutorial%3Amodding-movesets-the-muffin-knowledge-compenium-ds3).

**O que fazer ·** Uma verificação de parede por varrimento activo; colisão antes do alvo cancela o dano e provoca 12–18 frames de recoil. Escudos recebem `Deflexão leve/média/pesada`; ataques recebem `Força de ressalto`. Não precisa de física avançada nem de novos VFX.

## 1.6. Instabilidade separada de contra-ataque

**Problema ·** Tudo foi condensado num `+30%` de contra-ataque. Perde-se a diferença entre apanhar uma estocada durante um ataque e apanhar alguém desequilibrado.

**DS2/DS3 ·** No DS3, counter reduz em 30% a absorção contra perfuração durante certos frames de ataque; Instability é outro estado, normalmente +40% de dano, aplicado em recuperações e animações desequilibradas. [Counter e Instability no DS3](https://darksouls3.wikidot.com/falling).

**O que fazer ·** Separar `CounterPerfurante` de `Instável`. Usar Instável apenas em guarda quebrada, parry falhado, aterragem pesada e algumas recuperações. Para este jogo, +20–25% chega; +40% seria demasiado com dois atacantes.

## Sistemas deles que não servem

- **Adaptability/Agility do DS2 ·** Controla i-frames, uso de itens e outras velocidades. Viola a gramática fixa do nível 1 ao 100. Não copiar.
- **Durabilidade ·** No DS2 é uma economia de manutenção; no DS3 quase só gera viagens ao descanso. Para um projecto hobby não justifica inventário, UI e testes.
- **Invasões, covenants, summon signs, Soul Memory e Ember ·** Resolvem matchmaking público e PvP assimétrico. Não servem um duo privado fixo.
- **Penalidade de vida máxima por mortes/hollowing ·** Acrescentaria uma espiral de fracasso contrária à prioridade da perícia.
- **Mapa ausente ·** Aqui o mapa só de áreas exploradas e a posição do parceiro são melhores para dois amigos. Manter.

# 2. Sistemas que existem, mas estão piores

## 2.1. Meditação infinita

**Problema ·** Depois de limpar uma sala, os jogadores recuam para uma zona vazia e meditam. Os inimigos não regressam sem descanso, portanto os “40 segundos de risco” transformam-se em 40 segundos de espera. Antes de cada chefe, a mana estará sempre cheia.

**DS2/DS3 ·** O reset gratuito está acoplado ao respawn dos inimigos; reposições sem reset são consumíveis ou frascos finitos.

**O que fazer ·** Duas meditações por descanso, 50% cada, ou uma carga partilhada pelo duo. O anel de 25 segundos deve reduzir o consumo ou permitir movimento lento, não apenas encurtar espera.

## 2.2. Traços permanentes de classe — P0

**Problema ·** `+40% mana`, `−15% cast time`, `+20% regeneração`, `+25% velocidade de ataque` e “stamina zero não abre guarda” criam a classe correcta para cada papel. Qualquer classe pode segurar qualquer arma, mas algumas ficam permanentemente piores a usá-la. O traço do Tanque apaga a regra central de guarda quebrada; o do Berserker altera timings aprendidos e animações de rede.

**DS2/DS3 ·** A classe define apenas nível, atributos e equipamento inicial; depois, a construção pode mudar de direcção. [Classes do DS3](https://darksouls3.wikidot.com/class).

**O que fazer ·** Classes passam a kits iniciais. Se quiserem identidade permanente, criar `Juramentos` permutáveis no descanso e compostos por verbos: contra-atacar depois de bloquear, converter uma cura em área, sacrificar vida por invocação. Nada de velocidade, percentagens ou imunidade a estados centrais.

## 2.3. Escudos

**Problema ·** Defesa física máxima de 90%, estabilidade máxima de 85 e um “piso de 30% que vale para tudo” misturam três camadas diferentes. Se o piso força sempre 30% de dano, a defesa de 90% é efectivamente 70%. Além disso, o Tanque pode chegar a stamina zero sem ficar aberto.

**DS2/DS3 ·** Bons escudos médios e grandes chegam a 100% de bloqueio físico; estabilidade controla stamina, não dano que atravessa. O Black Knight Shield começa com 100 físico e 60 estabilidade. Quando o último ponto de stamina é gasto no DS2, há guarda quebrada e riposte. [Black Knight Shield](https://darksouls3.wikidot.com/black-knight-shield), [guarda quebrada no DS2](https://darksouls2.wiki.gg/wiki/Backstabs_%26_Ripostes).

**O que fazer ·** Permitir 100% físico em alguns escudos; manter elemental abaixo de 100; estabilidade máxima 85; stamina zero abre sempre guarda. O piso de dano pertence à absorção de armadura, nunca ao bloqueio.

## 2.4. Ressurreição ilimitada

**Problema ·** Cinco a sete segundos é risco, mas não é um recurso. Com dois jogadores, provocação e uma janela de um minuto, o padrão óptimo é alternar mortes e ressurreições. A tentativa pode ter vidas ilimitadas.

**DS2/DS3 ·** Fantasmas mortos regressam ao próprio mundo; não há ressurreição a meio da luta. [Fantasmas no DS3](https://darksouls3.wikidot.com/phantoms).

**O que fazer ·** Uma ressurreição partilhada por descanso/tentativa. Manter os 5–7 segundos e 50% de vida; o ressuscitado mantém os frascos que tinha. Alternativa: cada ressurreição consome um frasco do ressuscitador.

## 2.5. Contra-ataque universal

**Problema ·** Todas as famílias têm +30%, a katana +45% e a polearm +40%, independentemente de o golpe ser corte, impacto ou perfuração.

**DS2/DS3 ·** No DS3 o counter de 30% é exclusivamente contra dano de perfuração. No DS2 cada arma tem Counter Strength próprio: 100 significa sem bónus e os valores variam por arma. [Counter no DS3](https://darksouls3.wikidot.com/falling), [armas e Counter Strength no DS2](https://darksouls2.wikidot.com/weapons-tabview).

**O que fazer ·** Só ataques marcados `PERFURAÇÃO` recebem counter. Base ×1,30; polearms ×1,40; a katana recebe ×1,45 apenas na estocada. Cortes e pancadas ficam a ×1,00.

## 2.6. Brasa local

**Problema ·** A Brasa é apresentada como resposta ao grind, mas repõe inimigos, boss, loot e contador de mortes, podendo ser comprada com almas. Isso é uma máquina de converter almas em mais almas. Se for rentável uma vez, o uso óptimo é repeti-la até ao limite.

**DS2/DS3 ·** O Bonfire Ascetic do DS2 faz precisamente isso e é usado para farmar bosses, almas e materiais; aumenta irreversivelmente a intensidade local e repõe conteúdo. [Bonfire Ascetic](https://darksouls2.wikidot.com/bonfire-ascetic).

**O que fazer ·** A Brasa não pode ser comprada nem repor recompensas económicas infinitamente. Dar uma por zona/ciclo; repõe o boss e abre loot opcional único, mas inimigos já esgotados dão zero almas ou rendimento fortemente reduzido. Caso contrário, remover a alegação “sem grind”.

## 2.7. Carga equipada

**Problema ·** Leve e médio têm o mesmo rolamento e médio perde 10% de regeneração. A carga leve não compra mobilidade; a média é apenas pior sem escolha visível.

**DS2/DS3 ·** No DS3, leve e médio conservam os mesmos i-frames, mas o leve percorre mais distância; a regeneração só sofre penalidade relevante acima de 70%. No DS2 distância e regeneração degradam continuamente.

**O que fazer ·** Para o modelo simples do DS3: leve 110% da distância, médio 100%, pesado 75%; regeneração 40/40/31 por segundo; acima de 100%, sem rolamento e cerca de 26/s. Os i-frames podem continuar fixos.

## 2.8. Quedas

**Problema ·** O limite absoluto de 25 m e a mistura de dano fixo com vida máxima fazem níveis e equipamento abrirem atalhos verticais. Um jogador com mais vida sobrevive a 20 m; outro não. Isso é gating numérico de topologia.

**DS2/DS3 ·** No DS2 não há dano até 5 m e qualquer queda de 19,5 m ou mais é fatal, independentemente da vida e da redução. O limiar clássico do DS3 anda igualmente perto dos 20 m. [Fórmulas de queda](https://darksouls.fandom.com/wiki/Fall_damage).

**O que fazer ·** 0 até 5 m; dano progressivo entre 5 e menos de 20 m; morte absoluta a 20 m. Carga e equipamento podem alterar o dano não fatal, nunca o limiar de morte.

## 2.9. Coisas em que a nossa versão é melhor

- **Mapa de espaço conhecido + parceiro ·** melhor para duo; não acrescentar marcadores de conteúdo desconhecido.
- **I-frames independentes de nível/carga ·** melhor do que Agility do DS2.
- **Respawn máximo de 10 ·** próximo dos 12 abates normais do DS2 e coerente com o anti-grind. Manter.
- **Voz posicional integrada ·** adequada ao projecto; não existe equivalente sistémico importante no DS2/DS3.

# 3. Números que estão errados

| Valor actual | Problema face ao DS2/DS3 | Valor para o WorldRPGs |
|---|---|---|
| Parry: **4 f startup / 8 f activos / 40 f recuperação** | No DS3, a opção mais rápida começa aos 8 f; punho 8/8/42, fist/claw 9/8/38, curved sword 12/4/38. Quatro frames tornam o parry quase reactivo depois do contacto visual. [Frame data](https://darksouls3.wikidot.com/parry) | Startup **8–12 f**. Manter 8 activos/40 recuperação como baseline. |
| Rolamento: **18 f de i-frames** | É equivalente ao breakpoint baixo de 88 Agility no DS2. 96 AGL dá 11 frames a 30 fps, isto é, 0,367 s; 99 dá 0,4 s. [Tabela de Agility](https://darksouls2.wikidot.com/agility) | Começar em **22 f/0,367 s**. Se o protótipo ficar permissivo, voltar aos 18; não mexer por nível. |
| Médio: **−10% regen** | O DS3 não penaliza a regeneração entre 30–70%; a escolha é sobretudo distância. | **40/s** tanto em leve como médio. |
| Pesado: **−20% regen** | Está próximo do DS3: 45/s base menos 9. | Com base World de 40/s: **31/s**. |
| Escudo: **máximo 90% + piso de 30%** | Mistura absorção de armadura com bloqueio. Elimina a função dos escudos físicos de 100%. | **100% físico** em escudos seleccionados; 85 estabilidade máxima; elemental 50–85%. |
| Queda fatal: **25 m** | DS2 mata a 19,5 m; os limiares Souls rondam 20 m. | **20 m** absolutos. |
| Nível 70→100: “**3× tudo 1→70**” | Com a própria fórmula, 1→70 custa cerca de **689 mil** e 71→100 cerca de **1,309 milhões**: aproximadamente **1,90×**, não 3×. A fórmula é a do DS1/DS3, não a do DS2. [Fórmula](https://darksouls.wikidot.com/soul-level), [tabela diferente do DS2](https://darksouls2.wikidot.com/level) | Corrigir para **~1,9×** ou tornar a curva mais inclinada se 3× for realmente o objectivo. |
| Soft cap: **40 em tudo** | DS2/DS3 não usam um único breakpoint: Vida, stamina, carga, mana e dano têm curvas diferentes. Força no DS3, por exemplo, tem breakpoints aos 40 e 60; FP tem soft cap perto de 35. [Força](https://darksouls3.wikidot.com/strength), [Attunement](https://darksouls3.wiki.fextralife.com/Attunement) | Baseline: Vida **20/50**; stamina **20/40**; mana **35**; dano **40/60**; carga **30/50/70**. |
| NG+: **+40% vida e dano**, depois **+8% composto** | O primeiro salto do DS3 varia por área; os ciclos posteriores usam tabelas, não um +8% universal. No DS2 a vida varia por inimigo e os multiplicadores de almas são 2/2,5/2,75/3/3,25/3,5/4. [NG+ DS3](https://darksouls3.wikidot.com/souls), [NG+ DS2](https://darksouls2.wikidot.com/new-game-plus/noredirect/true) | Separar vida e dano. Proposta inicial: NG+ **+30% vida/+15% dano**; ciclos seguintes **+5% vida/+3% dano**, até +7, com correcção por zona. |
| Counter: **+30% universal; +40/+45 por família** | No DS3 é 30% apenas para perfuração; no DS2 é propriedade da arma. | ×1,30 só em perfuração; ×1,40 polearm; ×1,45 apenas na estocada da katana. |
| Meditação: **40 s = 100%** | A duração não limita quantidade; só acrescenta tempo morto. | **40 s = 40–50% e uma carga**, máximo duas por descanso. |

Estão bem como ponto de partida: stamina 100; regeneração base 40/s; custo de rolamento 25; 0,8 s antes de regenerar; parry activo de 8 f; recuperação falhada de 40 f; velocidades 3/5/7 m/s; frames base da adaga, espada e machadão.

# 4. Gramática de combate que falta

## 4.1. Perfuração de escudo por ataques inimigos

**Problema ·** Há magia que ignora escudos, mas não existe uma tag de ataque corpo-a-corpo que atravesse parcialmente bloqueio.

**DS2/DS3 ·** Shotel, Darkdrift e outras armas têm ataques de shield pierce; testes do DS2 colocam vários perto de 70% de penetração. [Testes de shield pierce](https://www.reddit.com/r/DarkSouls2/comments/36wa5g/some_findings_on_shield_piercing_weapons/).

**O que fazer ·** Uma família rara de estocadas curvas que atravesse 30–50% do bloqueio físico, com tell estreito e reconhecível.

## 4.2. Esmagamento de guarda dedicado

**Problema ·** A guarda só cai por acumulação normal de custo ou pelo empurrão universal. Falta um ataque inimigo cuja função explícita seja obrigar a largar o escudo.

**DS2/DS3 ·** Kicks, guard breaks, Shield Splitter e golpes pesados têm dano de stamina/guard muito acima do dano normal.

**O que fazer ·** Tag `ESMAGA_GUARDA`, custo de bloqueio ×2,5, tell vertical pesado. Bloqueável se houver stamina suficiente; caso contrário, guarda quebrada.

## 4.3. Mesmo tell, dois tempos de largada

**Problema ·** As sequências têm tempos fixos. Depois de memorizar a antecipação, o jogador reage sempre no mesmo instante.

**DS2/DS3 ·** Ataques carregáveis podem ser largados cedo ou tarde; inimigos e bosses usam pausas longas para apanhar o rolamento antecipado. No DS3, os ataques fortes do jogador também permitem largada parcial. [Ataques carregáveis no DS3](https://darksouls3.wiki.fextralife.com/Dark%20Souls%203%20Wiki).

**O que fazer ·** Em elites e bosses, 15–25% dos ataques têm duas largadas legais separadas por 12–20 frames. A segunda largada precisa de uma alteração visível/sonora antes dos frames activos; não pode ser uma pausa arbitrária invisível.

## 4.4. Ramos condicionais de combo

**Problema ·** As sequências são escritas como `1→5`, `3→2`. Não existe “continua se o jogador ficou perto; termina se saiu; roda se foi para as costas”.

**DS2/DS3 ·** Os grafos de combo avaliam distância, ângulo e estado para escolher a continuação.

**O que fazer ·** Cada elite recebe dois ramos; cada boss, dois a quatro. A decisão ocorre no fim do golpe anterior e lê posição/ângulo, nunca o botão que o jogador acabou de carregar.

## 4.5. Falsa recuperação

**Problema ·** Todo whiff longo é uma janela segura. Não existem inimigos que pareçam terminar uma sequência e tenham uma continuação rara.

**DS2/DS3 ·** Vários inimigos guardam uma extensão ou ataque de recuo para punir quem entra imediatamente após o aparente último golpe.

**O que fazer ·** Um ou dois ataques por elite com continuação opcional. A pose de recuperação deve ser ligeiramente diferente; depois de aprendida, pode ser lida consistentemente.

## 4.6. Castigo de cura

**Problema ·** O anti-kite fecha distância após quatro segundos, mas não há reacção à animação longa de beber um frasco. Curar à distância máxima tende a ser sempre seguro.

**DS2/DS3 ·** Muitos inimigos possuem ataques rápidos de fecho adequados a punir a recuperação de Estus.

**O que fazer ·** Inimigos agressivos podem reagir à animação de cura visível, com latência de pelo menos 150 ms e apenas se tiverem linha de visão. Não ler o input; ler o estado animado.

## 4.7. Ressalto contra armadura/corpo duro

**Problema ·** Escudos, carapaças e inimigos de pedra só alteram dano/postura. A arma atravessa visualmente todos da mesma maneira.

**DS2/DS3 ·** Corpos e estados de elevada deflection podem provocar recoil, tal como escudos.

**O que fazer ·** Certos lados do inimigo recebem `CorpoDuro`. Golpes leves a uma mão ressaltam; pesados, duas mãos, impacto e artes atravessam. Isto cria posicionamento sem acrescentar vida.

## 4.8. Fingir morte e ataque ao levantar

**Problema ·** Há mímicos e esqueletos que se reerguem, mas não inimigos que usem o estado de cadáver como início de um ataque.

**DS2/DS3 ·** Corpos aparentemente inertes levantam-se quando o jogador passa ou interage; alguns entram directamente numa estocada ou agarrão.

**O que fazer ·** Uma família por dois ou três biomas, nunca aleatória: arma ainda agarrada, respiração ou som subtil. Depois da primeira ocorrência, deve ser legível.

# 5. Regras copiadas sem o mecanismo que as justifica

## 5.1. “Artes custam energia”

**Problema ·** Foi copiado o custo das weapon arts do DS3, mas o recurso foi revogado quando entrou a mana.

**DS2/DS3 ·** No DS3 skills e feitiços partilham FP.

**O que fazer ·** Foco único ou custos explicitamente diferentes. Não deixar “energia” como recurso fantasma.

## 5.2. Artes diferentes a uma e duas mãos

**Problema ·** Foi copiada a importância da empunhadura, mas não o botão nem o estado que a tornam uma decisão de combate.

**DS2/DS3 ·** Uma e duas mãos são estados centrais do moveset.

**O que fazer ·** Implementar a empunhadura antes de catalogar mais artes.

## 5.3. “Stamina do inimigo”

**Problema ·** `Dreno de vigor` e `Fôlego Roubado` retiram stamina inimiga; a zero, o inimigo não ataca nem bloqueia. Nenhuma ficha inimiga define stamina máxima, custos, regeneração ou comportamento a zero.

**DS2/DS3 ·** Os jogadores têm uma economia explícita de stamina; os inimigos usam estados e parâmetros internos próprios, não necessariamente a mesma barra do jogador.

**O que fazer ·** Ou criar `VigorInimigo` completo — máximo, custos, regeneração e UI — ou, preferível, converter o feitiço em dano de postura/guarda e devolver stamina proporcional ao efeito conseguido.

## 5.4. Piso de 30% aplicado a escudos

**Problema ·** Uma regra de absorção/defesa foi aplicada ao bloqueio.

**DS2/DS3 ·** Defesa, absorção, redução do escudo e estabilidade são camadas separadas.

**O que fazer ·** Piso apenas na mitigação corporal; bloqueio físico pode ser 100%, mas custa stamina e perde para guard crush, pierce e ataques não bloqueáveis.

## 5.5. Soft caps como forma de impedir largura

**Problema ·** O texto afirma que depois de 40 “espalhar é pior do que aprofundar”. É ao contrário: depois do soft cap, abrir um terceiro atributo é mais eficiente do que continuar a empurrar o primeiro.

**DS2/DS3 ·** Soft caps promovem construções especializadas no início e mais largas a nível alto; o que impede omnipotência é o custo total e a convenção de nível, não o soft cap sozinho.

**O que fazer ·** Corrigir a razão: o nível 70 especializa; 71–100 compra largura. O limite de nível 100 impede chegar a tudo.

## 5.6. Brasa apresentada como anti-grind

**Problema ·** Foi copiado o reset local do DS2, mas negada a sua função económica real: farm.

**DS2/DS3 ·** O Bonfire Ascetic é simultaneamente selector de desafio, acesso antecipado a NG+ e ferramenta de farm.

**O que fazer ·** Escolher: ou a Brasa permite farm assumidamente, ou deixa de repor rendimento repetível.

## 5.7. Liberdade de classe com vantagens permanentes

**Problema ·** Foi copiada a frase “qualquer classe usa qualquer arma”, mas não o mecanismo que a torna verdadeira: classes de partida sem capacidades exclusivas permanentes.

**DS2/DS3 ·** A classe altera o ponto de partida, não o tecto funcional.

**O que fazer ·** Remover os traços numéricos permanentes ou transformá-los em opções permutáveis.

## 5.8. A fórmula de níveis sem a matemática acumulada

**Problema ·** A fórmula do DS1/DS3 foi copiada correctamente, mas a conclusão “70→100 custa 3×” não foi calculada. Também não é a curva do DS2.

**DS2/DS3 ·** O valor por nível e o custo acumulado são tratados separadamente; o DS2 tem uma tabela bastante mais barata.

**O que fazer ·** Gerar a tabela completa 1–100 e guardar três colunas: custo do próximo nível, custo acumulado e percentagem do total. Com a curva actual, escrever **1,9×**, não 3×.
tokens used
639 149
# 1. Sistemas que o DS2/DS3 têm e aqui faltam

## 1.1. Orçamento finito de magia e artes — P0

**Problema ·** A mana pode regressar a 100% em qualquer lugar após 40 segundos; simultaneamente, as artes continuam a “custar energia”, embora essa energia tenha sido revogada. Não existe, portanto, uma economia coerente de recursos entre descansos.

**DS2/DS3 ·** No DS2 cada feitiço tem usos próprios, normalmente entre 1 e 30, e descansar repõe esses usos mas também o mundo. No DS3, feitiços e weapon skills gastam o mesmo FP, reposto por descanso ou Ashen Estus finito. Isto obriga magia e artes a disputar um orçamento real. [Manual oficial do DS2](https://media-center.namcobandaigames.eu/manuals/darksouls2/pc/DS2-PC-Manual-EN.pdf), [FP no DS3](https://darksouls3.wikidot.com/focus-points).

**O que fazer ·** Criar um único recurso `Foco` para feitiços e artes. A meditação deve consumir uma carga finita, por exemplo duas por descanso, e recuperar 40–50% de Foco. Alternativa ainda mais barata: meditação só em pontos de descanso. A duração de 40 segundos, sozinha, não é um custo.

## 1.2. Estado real de uma mão/duas mãos — P0

**Problema ·** Cada arma tem uma arte a uma mão e outra a duas, mas não há comando, estado na máquina do jogador, transição ou regras de disponibilidade. É conteúdo que não pode ser seleccionado.

**DS2/DS3 ·** `Y/Triângulo` alterna a arma direita entre uma e duas mãos; manter alterna a esquerda. Isto troca moveset, bloqueio, skill e requisitos. No DS3, duas mãos também multiplicam Força efectiva por 1,5. [Controlos e duas mãos no DS3](https://darksouls3.wiki.fextralife.com/Dark%20Souls%203%20Wiki), [controlos do DS2](https://darksouls2.wikidot.com/controls).

**O que fazer ·** Adicionar `Empunhadura1H`/`Empunhadura2H`, um input próprio e uma transição de cerca de 12 frames, interrompível por dano. Cada ficha de arma declara moveset, bloqueio, arte e mãos ocupadas em ambos os estados. Não copiar o bónus de Força: aqui duas mãos deve dar opções, não números.

## 1.3. Preparação de feitiços

**Problema ·** Os oito favoritos podem ser alterados a qualquer momento. Logo, são apenas interface: os 25 feitiços estão efectivamente preparados em permanência. Desaparece a decisão “o que levo para esta zona?”.

**DS2/DS3 ·** Ambos usam Attunement: os feitiços são equipados no descanso e alguns ocupam vários espaços. No DS2 existem ainda usos por feitiço; no DS3 os espaços coexistem com FP. [Attunement no DS2](https://darksouls2.wiki.gg/wiki/Attunement), [Attunement no DS3](https://darksouls3.wiki.fextralife.com/Attunement).

**O que fazer ·** Manter os oito favoritos, mas só permitir alterá-los fora de combate ou num descanso. Não é necessário recuperar a estatística Attunement nem impedir que o jogador aprenda todos os feitiços.

## 1.4. Estado de sobrecarga

**Problema ·** A tabela termina em “pesado >70%”. Um jogador a 71% e outro a 140% têm a mesma mobilidade.

**DS2/DS3 ·** No DS3 existem três bandas até 100%; acima de 100% não se pode rolar, correr ou fazer sprint. No DS2 a distância do rolamento e a regeneração variam continuamente com o peso, com penalidades especiais acima de 100%. [Carga no DS3](https://www.gamerguides.com/dark-souls-iii/guide/basics/gameplay-2824/weapons-and-equipment), [carga no DS2](https://darksouls2.wiki.gg/wiki/Equipment_Load).

**O que fazer ·** Acrescentar `>100%`: sem rolamento nem sprint, apenas marcha. É barato, fecha exploits de inventário e dá significado ao limite máximo.

## 1.5. Repercussão contra paredes, escudos e corpos duros

**Problema ·** A spec diz que certos golpes verticais “não saem” em tectos baixos, mas não existe um sistema geral para uma arma embater numa parede ou ressaltar num escudo. Sem isto, alcance e direcção do golpe quase não interagem com o espaço.

**DS2/DS3 ·** Ataques podem ressaltar em paredes; escudos têm uma categoria oculta de deflection e podem provocar recoil no atacante. Escudos pequenos, médios e grandes deflectem classes diferentes de ataques. [Deflection no DS3](https://darksouls3.wikidot.com/falling), [parâmetros de recoil](https://soulsmodding.com/doku.php?id=tutorial%3Amodding-movesets-the-muffin-knowledge-compenium-ds3).

**O que fazer ·** Uma verificação de parede por varrimento activo; colisão antes do alvo cancela o dano e provoca 12–18 frames de recoil. Escudos recebem `Deflexão leve/média/pesada`; ataques recebem `Força de ressalto`. Não precisa de física avançada nem de novos VFX.

## 1.6. Instabilidade separada de contra-ataque

**Problema ·** Tudo foi condensado num `+30%` de contra-ataque. Perde-se a diferença entre apanhar uma estocada durante um ataque e apanhar alguém desequilibrado.

**DS2/DS3 ·** No DS3, counter reduz em 30% a absorção contra perfuração durante certos frames de ataque; Instability é outro estado, normalmente +40% de dano, aplicado em recuperações e animações desequilibradas. [Counter e Instability no DS3](https://darksouls3.wikidot.com/falling).

**O que fazer ·** Separar `CounterPerfurante` de `Instável`. Usar Instável apenas em guarda quebrada, parry falhado, aterragem pesada e algumas recuperações. Para este jogo, +20–25% chega; +40% seria demasiado com dois atacantes.

## Sistemas deles que não servem

- **Adaptability/Agility do DS2 ·** Controla i-frames, uso de itens e outras velocidades. Viola a gramática fixa do nível 1 ao 100. Não copiar.
- **Durabilidade ·** No DS2 é uma economia de manutenção; no DS3 quase só gera viagens ao descanso. Para um projecto hobby não justifica inventário, UI e testes.
- **Invasões, covenants, summon signs, Soul Memory e Ember ·** Resolvem matchmaking público e PvP assimétrico. Não servem um duo privado fixo.
- **Penalidade de vida máxima por mortes/hollowing ·** Acrescentaria uma espiral de fracasso contrária à prioridade da perícia.
- **Mapa ausente ·** Aqui o mapa só de áreas exploradas e a posição do parceiro são melhores para dois amigos. Manter.

# 2. Sistemas que existem, mas estão piores

## 2.1. Meditação infinita

**Problema ·** Depois de limpar uma sala, os jogadores recuam para uma zona vazia e meditam. Os inimigos não regressam sem descanso, portanto os “40 segundos de risco” transformam-se em 40 segundos de espera. Antes de cada chefe, a mana estará sempre cheia.

**DS2/DS3 ·** O reset gratuito está acoplado ao respawn dos inimigos; reposições sem reset são consumíveis ou frascos finitos.

**O que fazer ·** Duas meditações por descanso, 50% cada, ou uma carga partilhada pelo duo. O anel de 25 segundos deve reduzir o consumo ou permitir movimento lento, não apenas encurtar espera.

## 2.2. Traços permanentes de classe — P0

**Problema ·** `+40% mana`, `−15% cast time`, `+20% regeneração`, `+25% velocidade de ataque` e “stamina zero não abre guarda” criam a classe correcta para cada papel. Qualquer classe pode segurar qualquer arma, mas algumas ficam permanentemente piores a usá-la. O traço do Tanque apaga a regra central de guarda quebrada; o do Berserker altera timings aprendidos e animações de rede.

**DS2/DS3 ·** A classe define apenas nível, atributos e equipamento inicial; depois, a construção pode mudar de direcção. [Classes do DS3](https://darksouls3.wikidot.com/class).

**O que fazer ·** Classes passam a kits iniciais. Se quiserem identidade permanente, criar `Juramentos` permutáveis no descanso e compostos por verbos: contra-atacar depois de bloquear, converter uma cura em área, sacrificar vida por invocação. Nada de velocidade, percentagens ou imunidade a estados centrais.

## 2.3. Escudos

**Problema ·** Defesa física máxima de 90%, estabilidade máxima de 85 e um “piso de 30% que vale para tudo” misturam três camadas diferentes. Se o piso força sempre 30% de dano, a defesa de 90% é efectivamente 70%. Além disso, o Tanque pode chegar a stamina zero sem ficar aberto.

**DS2/DS3 ·** Bons escudos médios e grandes chegam a 100% de bloqueio físico; estabilidade controla stamina, não dano que atravessa. O Black Knight Shield começa com 100 físico e 60 estabilidade. Quando o último ponto de stamina é gasto no DS2, há guarda quebrada e riposte. [Black Knight Shield](https://darksouls3.wikidot.com/black-knight-shield), [guarda quebrada no DS2](https://darksouls2.wiki.gg/wiki/Backstabs_%26_Ripostes).

**O que fazer ·** Permitir 100% físico em alguns escudos; manter elemental abaixo de 100; estabilidade máxima 85; stamina zero abre sempre guarda. O piso de dano pertence à absorção de armadura, nunca ao bloqueio.

## 2.4. Ressurreição ilimitada

**Problema ·** Cinco a sete segundos é risco, mas não é um recurso. Com dois jogadores, provocação e uma janela de um minuto, o padrão óptimo é alternar mortes e ressurreições. A tentativa pode ter vidas ilimitadas.

**DS2/DS3 ·** Fantasmas mortos regressam ao próprio mundo; não há ressurreição a meio da luta. [Fantasmas no DS3](https://darksouls3.wikidot.com/phantoms).

**O que fazer ·** Uma ressurreição partilhada por descanso/tentativa. Manter os 5–7 segundos e 50% de vida; o ressuscitado mantém os frascos que tinha. Alternativa: cada ressurreição consome um frasco do ressuscitador.

## 2.5. Contra-ataque universal

**Problema ·** Todas as famílias têm +30%, a katana +45% e a polearm +40%, independentemente de o golpe ser corte, impacto ou perfuração.

**DS2/DS3 ·** No DS3 o counter de 30% é exclusivamente contra dano de perfuração. No DS2 cada arma tem Counter Strength próprio: 100 significa sem bónus e os valores variam por arma. [Counter no DS3](https://darksouls3.wikidot.com/falling), [armas e Counter Strength no DS2](https://darksouls2.wikidot.com/weapons-tabview).

**O que fazer ·** Só ataques marcados `PERFURAÇÃO` recebem counter. Base ×1,30; polearms ×1,40; a katana recebe ×1,45 apenas na estocada. Cortes e pancadas ficam a ×1,00.

## 2.6. Brasa local

**Problema ·** A Brasa é apresentada como resposta ao grind, mas repõe inimigos, boss, loot e contador de mortes, podendo ser comprada com almas. Isso é uma máquina de converter almas em mais almas. Se for rentável uma vez, o uso óptimo é repeti-la até ao limite.

**DS2/DS3 ·** O Bonfire Ascetic do DS2 faz precisamente isso e é usado para farmar bosses, almas e materiais; aumenta irreversivelmente a intensidade local e repõe conteúdo. [Bonfire Ascetic](https://darksouls2.wikidot.com/bonfire-ascetic).

**O que fazer ·** A Brasa não pode ser comprada nem repor recompensas económicas infinitamente. Dar uma por zona/ciclo; repõe o boss e abre loot opcional único, mas inimigos já esgotados dão zero almas ou rendimento fortemente reduzido. Caso contrário, remover a alegação “sem grind”.

## 2.7. Carga equipada

**Problema ·** Leve e médio têm o mesmo rolamento e médio perde 10% de regeneração. A carga leve não compra mobilidade; a média é apenas pior sem escolha visível.

**DS2/DS3 ·** No DS3, leve e médio conservam os mesmos i-frames, mas o leve percorre mais distância; a regeneração só sofre penalidade relevante acima de 70%. No DS2 distância e regeneração degradam continuamente.

**O que fazer ·** Para o modelo simples do DS3: leve 110% da distância, médio 100%, pesado 75%; regeneração 40/40/31 por segundo; acima de 100%, sem rolamento e cerca de 26/s. Os i-frames podem continuar fixos.

## 2.8. Quedas

**Problema ·** O limite absoluto de 25 m e a mistura de dano fixo com vida máxima fazem níveis e equipamento abrirem atalhos verticais. Um jogador com mais vida sobrevive a 20 m; outro não. Isso é gating numérico de topologia.

**DS2/DS3 ·** No DS2 não há dano até 5 m e qualquer queda de 19,5 m ou mais é fatal, independentemente da vida e da redução. O limiar clássico do DS3 anda igualmente perto dos 20 m. [Fórmulas de queda](https://darksouls.fandom.com/wiki/Fall_damage).

**O que fazer ·** 0 até 5 m; dano progressivo entre 5 e menos de 20 m; morte absoluta a 20 m. Carga e equipamento podem alterar o dano não fatal, nunca o limiar de morte.

## 2.9. Coisas em que a nossa versão é melhor

- **Mapa de espaço conhecido + parceiro ·** melhor para duo; não acrescentar marcadores de conteúdo desconhecido.
- **I-frames independentes de nível/carga ·** melhor do que Agility do DS2.
- **Respawn máximo de 10 ·** próximo dos 12 abates normais do DS2 e coerente com o anti-grind. Manter.
- **Voz posicional integrada ·** adequada ao projecto; não existe equivalente sistémico importante no DS2/DS3.

# 3. Números que estão errados

| Valor actual | Problema face ao DS2/DS3 | Valor para o WorldRPGs |
|---|---|---|
| Parry: **4 f startup / 8 f activos / 40 f recuperação** | No DS3, a opção mais rápida começa aos 8 f; punho 8/8/42, fist/claw 9/8/38, curved sword 12/4/38. Quatro frames tornam o parry quase reactivo depois do contacto visual. [Frame data](https://darksouls3.wikidot.com/parry) | Startup **8–12 f**. Manter 8 activos/40 recuperação como baseline. |
| Rolamento: **18 f de i-frames** | É equivalente ao breakpoint baixo de 88 Agility no DS2. 96 AGL dá 11 frames a 30 fps, isto é, 0,367 s; 99 dá 0,4 s. [Tabela de Agility](https://darksouls2.wikidot.com/agility) | Começar em **22 f/0,367 s**. Se o protótipo ficar permissivo, voltar aos 18; não mexer por nível. |
| Médio: **−10% regen** | O DS3 não penaliza a regeneração entre 30–70%; a escolha é sobretudo distância. | **40/s** tanto em leve como médio. |
| Pesado: **−20% regen** | Está próximo do DS3: 45/s base menos 9. | Com base World de 40/s: **31/s**. |
| Escudo: **máximo 90% + piso de 30%** | Mistura absorção de armadura com bloqueio. Elimina a função dos escudos físicos de 100%. | **100% físico** em escudos seleccionados; 85 estabilidade máxima; elemental 50–85%. |
| Queda fatal: **25 m** | DS2 mata a 19,5 m; os limiares Souls rondam 20 m. | **20 m** absolutos. |
| Nível 70→100: “**3× tudo 1→70**” | Com a própria fórmula, 1→70 custa cerca de **689 mil** e 71→100 cerca de **1,309 milhões**: aproximadamente **1,90×**, não 3×. A fórmula é a do DS1/DS3, não a do DS2. [Fórmula](https://darksouls.wikidot.com/soul-level), [tabela diferente do DS2](https://darksouls2.wikidot.com/level) | Corrigir para **~1,9×** ou tornar a curva mais inclinada se 3× for realmente o objectivo. |
| Soft cap: **40 em tudo** | DS2/DS3 não usam um único breakpoint: Vida, stamina, carga, mana e dano têm curvas diferentes. Força no DS3, por exemplo, tem breakpoints aos 40 e 60; FP tem soft cap perto de 35. [Força](https://darksouls3.wikidot.com/strength), [Attunement](https://darksouls3.wiki.fextralife.com/Attunement) | Baseline: Vida **20/50**; stamina **20/40**; mana **35**; dano **40/60**; carga **30/50/70**. |
| NG+: **+40% vida e dano**, depois **+8% composto** | O primeiro salto do DS3 varia por área; os ciclos posteriores usam tabelas, não um +8% universal. No DS2 a vida varia por inimigo e os multiplicadores de almas são 2/2,5/2,75/3/3,25/3,5/4. [NG+ DS3](https://darksouls3.wikidot.com/souls), [NG+ DS2](https://darksouls2.wikidot.com/new-game-plus/noredirect/true) | Separar vida e dano. Proposta inicial: NG+ **+30% vida/+15% dano**; ciclos seguintes **+5% vida/+3% dano**, até +7, com correcção por zona. |
| Counter: **+30% universal; +40/+45 por família** | No DS3 é 30% apenas para perfuração; no DS2 é propriedade da arma. | ×1,30 só em perfuração; ×1,40 polearm; ×1,45 apenas na estocada da katana. |
| Meditação: **40 s = 100%** | A duração não limita quantidade; só acrescenta tempo morto. | **40 s = 40–50% e uma carga**, máximo duas por descanso. |

Estão bem como ponto de partida: stamina 100; regeneração base 40/s; custo de rolamento 25; 0,8 s antes de regenerar; parry activo de 8 f; recuperação falhada de 40 f; velocidades 3/5/7 m/s; frames base da adaga, espada e machadão.

# 4. Gramática de combate que falta

## 4.1. Perfuração de escudo por ataques inimigos

**Problema ·** Há magia que ignora escudos, mas não existe uma tag de ataque corpo-a-corpo que atravesse parcialmente bloqueio.

**DS2/DS3 ·** Shotel, Darkdrift e outras armas têm ataques de shield pierce; testes do DS2 colocam vários perto de 70% de penetração. [Testes de shield pierce](https://www.reddit.com/r/DarkSouls2/comments/36wa5g/some_findings_on_shield_piercing_weapons/).

**O que fazer ·** Uma família rara de estocadas curvas que atravesse 30–50% do bloqueio físico, com tell estreito e reconhecível.

## 4.2. Esmagamento de guarda dedicado

**Problema ·** A guarda só cai por acumulação normal de custo ou pelo empurrão universal. Falta um ataque inimigo cuja função explícita seja obrigar a largar o escudo.

**DS2/DS3 ·** Kicks, guard breaks, Shield Splitter e golpes pesados têm dano de stamina/guard muito acima do dano normal.

**O que fazer ·** Tag `ESMAGA_GUARDA`, custo de bloqueio ×2,5, tell vertical pesado. Bloqueável se houver stamina suficiente; caso contrário, guarda quebrada.

## 4.3. Mesmo tell, dois tempos de largada

**Problema ·** As sequências têm tempos fixos. Depois de memorizar a antecipação, o jogador reage sempre no mesmo instante.

**DS2/DS3 ·** Ataques carregáveis podem ser largados cedo ou tarde; inimigos e bosses usam pausas longas para apanhar o rolamento antecipado. No DS3, os ataques fortes do jogador também permitem largada parcial. [Ataques carregáveis no DS3](https://darksouls3.wiki.fextralife.com/Dark%20Souls%203%20Wiki).

**O que fazer ·** Em elites e bosses, 15–25% dos ataques têm duas largadas legais separadas por 12–20 frames. A segunda largada precisa de uma alteração visível/sonora antes dos frames activos; não pode ser uma pausa arbitrária invisível.

## 4.4. Ramos condicionais de combo

**Problema ·** As sequências são escritas como `1→5`, `3→2`. Não existe “continua se o jogador ficou perto; termina se saiu; roda se foi para as costas”.

**DS2/DS3 ·** Os grafos de combo avaliam distância, ângulo e estado para escolher a continuação.

**O que fazer ·** Cada elite recebe dois ramos; cada boss, dois a quatro. A decisão ocorre no fim do golpe anterior e lê posição/ângulo, nunca o botão que o jogador acabou de carregar.

## 4.5. Falsa recuperação

**Problema ·** Todo whiff longo é uma janela segura. Não existem inimigos que pareçam terminar uma sequência e tenham uma continuação rara.

**DS2/DS3 ·** Vários inimigos guardam uma extensão ou ataque de recuo para punir quem entra imediatamente após o aparente último golpe.

**O que fazer ·** Um ou dois ataques por elite com continuação opcional. A pose de recuperação deve ser ligeiramente diferente; depois de aprendida, pode ser lida consistentemente.

## 4.6. Castigo de cura

**Problema ·** O anti-kite fecha distância após quatro segundos, mas não há reacção à animação longa de beber um frasco. Curar à distância máxima tende a ser sempre seguro.

**DS2/DS3 ·** Muitos inimigos possuem ataques rápidos de fecho adequados a punir a recuperação de Estus.

**O que fazer ·** Inimigos agressivos podem reagir à animação de cura visível, com latência de pelo menos 150 ms e apenas se tiverem linha de visão. Não ler o input; ler o estado animado.

## 4.7. Ressalto contra armadura/corpo duro

**Problema ·** Escudos, carapaças e inimigos de pedra só alteram dano/postura. A arma atravessa visualmente todos da mesma maneira.

**DS2/DS3 ·** Corpos e estados de elevada deflection podem provocar recoil, tal como escudos.

**O que fazer ·** Certos lados do inimigo recebem `CorpoDuro`. Golpes leves a uma mão ressaltam; pesados, duas mãos, impacto e artes atravessam. Isto cria posicionamento sem acrescentar vida.

## 4.8. Fingir morte e ataque ao levantar

**Problema ·** Há mímicos e esqueletos que se reerguem, mas não inimigos que usem o estado de cadáver como início de um ataque.

**DS2/DS3 ·** Corpos aparentemente inertes levantam-se quando o jogador passa ou interage; alguns entram directamente numa estocada ou agarrão.

**O que fazer ·** Uma família por dois ou três biomas, nunca aleatória: arma ainda agarrada, respiração ou som subtil. Depois da primeira ocorrência, deve ser legível.

# 5. Regras copiadas sem o mecanismo que as justifica

## 5.1. “Artes custam energia”

**Problema ·** Foi copiado o custo das weapon arts do DS3, mas o recurso foi revogado quando entrou a mana.

**DS2/DS3 ·** No DS3 skills e feitiços partilham FP.

**O que fazer ·** Foco único ou custos explicitamente diferentes. Não deixar “energia” como recurso fantasma.

## 5.2. Artes diferentes a uma e duas mãos

**Problema ·** Foi copiada a importância da empunhadura, mas não o botão nem o estado que a tornam uma decisão de combate.

**DS2/DS3 ·** Uma e duas mãos são estados centrais do moveset.

**O que fazer ·** Implementar a empunhadura antes de catalogar mais artes.

## 5.3. “Stamina do inimigo”

**Problema ·** `Dreno de vigor` e `Fôlego Roubado` retiram stamina inimiga; a zero, o inimigo não ataca nem bloqueia. Nenhuma ficha inimiga define stamina máxima, custos, regeneração ou comportamento a zero.

**DS2/DS3 ·** Os jogadores têm uma economia explícita de stamina; os inimigos usam estados e parâmetros internos próprios, não necessariamente a mesma barra do jogador.

**O que fazer ·** Ou criar `VigorInimigo` completo — máximo, custos, regeneração e UI — ou, preferível, converter o feitiço em dano de postura/guarda e devolver stamina proporcional ao efeito conseguido.

## 5.4. Piso de 30% aplicado a escudos

**Problema ·** Uma regra de absorção/defesa foi aplicada ao bloqueio.

**DS2/DS3 ·** Defesa, absorção, redução do escudo e estabilidade são camadas separadas.

**O que fazer ·** Piso apenas na mitigação corporal; bloqueio físico pode ser 100%, mas custa stamina e perde para guard crush, pierce e ataques não bloqueáveis.

## 5.5. Soft caps como forma de impedir largura

**Problema ·** O texto afirma que depois de 40 “espalhar é pior do que aprofundar”. É ao contrário: depois do soft cap, abrir um terceiro atributo é mais eficiente do que continuar a empurrar o primeiro.

**DS2/DS3 ·** Soft caps promovem construções especializadas no início e mais largas a nível alto; o que impede omnipotência é o custo total e a convenção de nível, não o soft cap sozinho.

**O que fazer ·** Corrigir a razão: o nível 70 especializa; 71–100 compra largura. O limite de nível 100 impede chegar a tudo.

## 5.6. Brasa apresentada como anti-grind

**Problema ·** Foi copiado o reset local do DS2, mas negada a sua função económica real: farm.

**DS2/DS3 ·** O Bonfire Ascetic é simultaneamente selector de desafio, acesso antecipado a NG+ e ferramenta de farm.

**O que fazer ·** Escolher: ou a Brasa permite farm assumidamente, ou deixa de repor rendimento repetível.

## 5.7. Liberdade de classe com vantagens permanentes

**Problema ·** Foi copiada a frase “qualquer classe usa qualquer arma”, mas não o mecanismo que a torna verdadeira: classes de partida sem capacidades exclusivas permanentes.

**DS2/DS3 ·** A classe altera o ponto de partida, não o tecto funcional.

**O que fazer ·** Remover os traços numéricos permanentes ou transformá-los em opções permutáveis.

## 5.8. A fórmula de níveis sem a matemática acumulada

**Problema ·** A fórmula do DS1/DS3 foi copiada correctamente, mas a conclusão “70→100 custa 3×” não foi calculada. Também não é a curva do DS2.

**DS2/DS3 ·** O valor por nível e o custo acumulado são tratados separadamente; o DS2 tem uma tabela bastante mais barata.

**O que fazer ·** Gerar a tabela completa 1–100 e guardar três colunas: custo do próximo nível, custo acumulado e percentagem do total. Com a curva actual, escrever **1,9×**, não 3×.
