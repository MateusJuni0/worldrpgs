# 68 — Catálogo de armas, armaduras, estados e anéis

> **WP5 fechado em 01-08-2026.** Este documento substitui a melhoria numérica do [`51`](51-familias.md) §7 e entrega a camada 2: **120 armas**, **68 peças de armadura**, **70 anéis**, os oito movesets completos, três estados e a proposta do Assassino. A fonte executável é [`equipment.json`](../game/data/equipment.json); a fonte editorial que a regenera é [`generate-equipment-catalogue.mjs`](../tools/generate-equipment-catalogue.mjs).
>
> Etiquetas: o catálogo é `[FABLE]` onde não havia palavra de dono. O Assassino continua **⏳ a aguardar confirmação do Mateus**; os três guardas do [`12`](12-classes.md) são obrigatórios e testados. Nenhuma tensão de dono foi decidida aqui.

---

## 1. O tamanho que agora existe

| Catálogo | Total | Fatia 1? | Regra de produção |
|---|---:|---:|---|
| Armas | **120** (as oito famílias; o escudo de madeira ocupa a 120.ª ficha) | **5** | as cinco imagens aprovadas são reutilizadas; 115 esperam |
| Armaduras | **68** (11 kits + 57 peças já prometidas nos baralhos do WP6) | **11** | estes onze ícones geram agora; 57 esperam |
| Anéis | **70** | **0** | nenhum cresce a Fatia 1 |

Cada linha dos três catálogos declara `descricao_visual` e `fatia_1`. “Espada” ou “katana” não são prompts: as fichas dizem comprimento, construção, material, fixação e marca do bioma. Qualquer origem equipa qualquer item; requisitos e afinidades dizem **como rende**, nunca “não podes”.

Os 32 IDs de arma, 57 de armadura e três de anel prometidos pelos 330 cartões do [`67`](67-catalogo-do-bestiario.md) resolvem todos no arranque. Materiais e consumíveis continuam no WP9; não são escondidos por esta entrega.

## 2. Os onze golpes em cada família

Os onze são: leve · pesado · cadeia · leve→pesado · corrida · rolar · saltar · de cima · empurrão · arte a uma mão · arte a duas mãos. A antiga regra global deixou de ser uma promessa: `family_movesets` materializa **88 fichas**. Todos os golpes declaram a pergunta que fazem; as artes custam mana.

| Família | Corrida | A rolar | A saltar | Empurrão | Artes 1 mão / 2 mãos |
|---|---|---|---|---|---|
| `espada_recta` | trocar alcance por recuperação | converter a saída da esquiva em aproximação punível | saltar por cima da linha e aceitar a aterragem | quebrar a guarda sem causar dano relevante | estocada perfurante / golpe circular |
| `adaga` | arriscar ficar dentro da guarda | converter a saída da esquiva em aproximação punível | saltar por cima da linha e aceitar a aterragem | quebrar a guarda sem causar dano relevante | apunhalar / dança de lâminas |
| `pesada_corte` | trocar durante o golpe inimigo | converter a saída da esquiva em aproximação punível | saltar por cima da linha e aceitar a aterragem | quebrar a guarda sem causar dano relevante | salto esmagador / rodopio |
| `katana` | guardar o iai até ao compromisso | converter a saída da esquiva em aproximação punível | saltar por cima da linha e aceitar a aterragem | quebrar a guarda sem causar dano relevante | iai / corte duplo |
| `haste` | estocar atrás da guarda | converter a saída da esquiva em aproximação punível | saltar por cima da linha e aceitar a aterragem | quebrar a guarda sem causar dano relevante | varrimento baixo / carga de lança |
| `cajado` | gastar mana na arte ou guardar para magia | converter a saída da esquiva em aproximação punível | saltar por cima da linha e aceitar a aterragem | quebrar a guarda sem causar dano relevante | rajada de bruma / conjuração firmada |
| `arco` | marcar para o parceiro | converter a saída da esquiva em aproximação punível | saltar por cima da linha e aceitar a aterragem | quebrar a guarda sem causar dano relevante | disparo firmado / chuva de flechas |
| `besta` | combinar o tiro com a mão livre | converter a saída da esquiva em aproximação punível | saltar por cima da linha e aceitar a aterragem | quebrar a guarda sem causar dano relevante | tiro rápido / mira ampliada |

Constantes universais que preservam a gramática: leve→pesado corta 25% do arranque · rolar corta 4 frames e usa MV ×0,85 · saltar só tem hiper-armadura nos activos · empurrão é 12+4+14 f, 20 stamina, MV 0,05 e quebra guarda. A diferença vem da pergunta e da geometria da família, nunca de “esta dá mais dano”.

⚠️ O protótipo da Fatia 1 ainda executa leve, pesado, cadeia e bash. Corrida, saída de rolamento, salto, queda, empurrão universal, troca uma/duas mãos e artes entram no M2. O catálogo deixou de ser ambíguo; a animação/runtime ainda é trabalho real e fica em [`LACUNAS.md`](../LACUNAS.md).

## 3. Melhoria — seis níveis sem comprar força

`[FABLE]` A melhoria é um **voto reversível no altar**. Limalha abre +1…+3; Limalha Nobre abre +4…+6; ambas vêm de exploração fixa, nunca de inimigo repetível. Não há +10%, dano base, defesa, velocidade ou janela melhor.

| Nível | Eixo | Decisão | Aumenta dano base? |
|---:|---|---|---|
| 0 | base | arma sem voto | não |
| 1 | postura | postura avançada ou postura guardada; muda o golpe em corrida | não |
| 2 | arte_nova | troca uma das artes por uma arte da família encontrada no mundo | não |
| 3 | troca_escala | troca o atributo de escala; nunca soma dois atributos | não |
| 4 | conversao_elemental | converte parte física num elemento; o total base não cresce | não |
| 5 | postura | segunda postura incompatível com a primeira, incluindo uma fraqueza espacial | não |
| 6 | arte_nova | arte de mestre ocupa as duas artes e mantém custo de mana | não |

“Postura” significa **posição/moveset**, não dano de postura. Conversão troca parte física por um dos oito tipos e conserva o total base; troca de escala substitui o atributo em vez de somar dois. A arma melhorada sabe fazer coisas novas e também escolhe fraquezas novas.

## 4. Estados alterados — barra, consequência e saída

| Estado | Enche / decai | Ao disparar | Como se escapa | Origem | Fatia 1? |
|---|---|---|---|---|---|
| Veneno | 100; espera 2 s, −10/s | 12 s, 1% PV máx. a cada 2 s | antídoto, duração ou descanso; mortos-vivos legíveis imunes | Selva Funda / Raizama | Não |
| Sangramento | 100; espera 2 s, −14/s | 4% PV máx. + 30 stamina; regen espera 1,2 s | faixa limpa 45; distância deixa decair; sem-sangue imune | Campas Cinzentas | **Sim** |
| Queimadura | 100; espera 2 s, −12/s | 8 s, 1,5% PV máx. a cada 2 s; covardes recuam 2 s/pulso | rolar para água/cinza fria, duração ou descanso | Fornalha | Não |

As regras base aplicam-se a **jogador e inimigo**. A barra é sempre visível e o som tem equivalente visual; imunidade só existe quando o corpo a explica. O comportamento “covarde recua” é um traço de IA já declarado pela ficha, não uma regra diferente para dano recebido.

## 5. Assassino — proposta sob os três guardas

⏳ **Instrução do Rico; confirmação do Mateus pendente.** Não se marca `[DECIDIDO]`.

| Pedido | Proposta | Guarda que passa |
|---|---|---|
| Furtividade | **Passo Mudo:** caminhar sem correr suprime o som e marca visual dos passos; termina ao atacar, esquivar ou correr | não muda visão, alcance, estados nem exige IA nova |
| Velocidade | **Corte Alternado:** cada leve abre na recuperação uma resposta da adaga esquerda | é um ramo novo, nunca “+X%” |
| Sangramento | **Cruz Carmesim:** os dois lados somam 35+35 à barra visível | usa o mesmo estado e as mesmas saídas dos dois lados |
| Habilidade | **Entre Sombras:** 3 s para atravessar o volume inimigo com a próxima esquiva; se conseguir, abre Corte Cruzado por 2 s | i-frames não mudam; falhar gasta a janela |

O Assassino começa com duas adagas e a técnica. Qualquer origem pode aprendê-la como loot de marco: afinidade, não tranca. O runtime continua marcado para M2, tal como os restantes golpes novos.

## 6. As onze armaduras que geram primeiro

| ID | Nome | Slot | Material | Descrição visual | Fatia 1? |
|---|---|---|---|---|---|
| `couro_peitoral` | Peitoral de couro fervido | peito | couro de javali (Brumal) | peitoral de couro fervido castanho-escuro, costuras grossas, marcas de uso | Sim |
| `couro_botas` | Botas de couro | pes | couro de javali (Brumal) | botas de couro castanho ate meia perna, sola gasta, atacadores de tira | Sim |
| `ferro_elmo` | Elmo de ferro rude | cabeca | ferro rude (Brumal) | elmo de ferro martelado sem polimento, fenda em T, rebites a vista | Sim |
| `ferro_peitoral` | Peitoral de ferro rude | peito | ferro rude (Brumal) | peitoral de placas de ferro baco rebitadas sobre couro, ombros reforcados | Sim |
| `ferro_peitoral_polido` | Peitoral de ferro polido | peito | ferro rude polido (Brumal) | peitoral de ferro polido a espelho com relevo de raio no peito, correias claras | Sim |
| `pano_mascara` | Mascara de pano escuro | rosto | pano (neutro) | mascara de pano cinza-escuro que cobre nariz e boca, no atras da cabeca | Sim |
| `pano_botas` | Botas de pano | pes | pano (neutro) | botas macias de pano escuro de sola fina — feitas para nao fazer barulho | Sim |
| `couro_ombreiras` | Ombreiras de couro com pelo | ombros | couro e pelo de javali (Brumal) | ombreiras de couro cru com pelo de javali por cima, tiras cruzadas no peito nu | Sim |
| `la_capa` | Capa de la encerada | capa | la encerada (neutro) | capa de la grossa cor de carvao, encerada contra a humidade, capuz fundo | Sim |
| `la_capa_clara` | Capa de la clara | capa | la (neutro) | capa de la crua quase branca com debrum dourado gasto, capuz para tras | Sim |
| `couro_cinto` | Cinto de bolsas | cintura | couro (Brumal) | cinto largo de couro com quatro bolsas de tamanhos diferentes, rolhas de cortica a espreitar | Sim |

As outras 57 fichas preservam o que o inimigo realmente veste, com peso, resistência regional, fraqueza fora da região, localização e descrição visual. Não se geram até a coluna mudar.

## 7. Os 70 anéis

Começam-se com **dois dedos** e ganham-se até dez. Todos são passivos ou condicionais, nenhum consome tecla, cada efeito é único e nenhum número percentual passa 10%. Afinidade dá sabor, não exclusividade. Efeitos iguais só poderiam somar dois — mas este catálogo não repete efeitos.

| ID | Nome | Eixo | Efeito | Números | Afinidade | Soma? | Onde se encontra | Fatia 1? |
|---|---|---|---|---|---|---|---|---|
| `gota_guardada` | Gota Guardada | recursos | uma cura interrompida conserva metade da carga em vez de a perder | {"max_percent":0,"fraction":0.5} | paladin | não; altera a mesma interrupção | Brumal, no fundo do poço seco atrás da capela | Não |
| `pulmao_de_ferro` | Pulmão de Ferro | recursos | o primeiro gasto de stamina depois de oito segundos parado não inicia a demora de regeneração | {"max_percent":0,"wait_s":8} | tank | não; gatilho único | Fojo, sobre a viga que cruza o veio abandonado | Não |
| `eco_de_cinzas` | Eco de Cinzas | recursos | meditar junto de uma fogueira extinta reacende-a como ponto de meditação, não como descanso | {"max_percent":0,"meditate_s":40} | sorcerer | não; verbo de mundo | Campas Cinzentas, numa urna sem nome da cripta lateral | Não |
| `odre_inteiro` | Odre Inteiro | recursos | beber o último frasco deixa o recipiente marcar a fonte de água mais próxima | {"max_percent":0,"last_use":1} | warrior | sim; só com efeitos de navegação | Costa Quebrada, dentro do casco virado ao contrário | Não |
| `veio_de_mana` | Veio de Mana | recursos | parar uma magia antes do compromisso devolve a mana paga | {"max_percent":0,"before_commitment":true} | sorcerer | não; reembolso não acumula | Cidade Afogada, no balcão submerso do arquivo | Não |
| `brasa_economa` | Brasa Económica | recursos | uma resina não consumida porque o golpe falhou volta ao inventário no descanso | {"max_percent":0,"one_recovery":true} | berserker | não; restituição única | Fornalha, atrás do fole partido da oficina baixa | Não |
| `fome_do_musgo` | Fome do Musgo | recursos | usar um antídoto revela durante seis segundos todas as plantas iguais próximas | {"max_percent":0,"reveal_s":6} | batedor | sim; não aumenta alcance | Selva Funda, no ninho sob a ponte de cipós | Não |
| `dedo_do_ultimo_gole` | Dedo do Último Gole | recursos | curar o parceiro com o teu último frasco deixa-o escolher quem recebe a carga no próximo descanso | {"max_percent":0,"choice_count":1} | paladin | não; uma escolha por descanso | Santuário Branco, no cálice rachado da sacristia | Não |
| `semente_de_favorito` | Semente de Favorito | recursos | ao descansar permite trocar um favorito de magia sem abrir o menu completo | {"max_percent":0,"swaps":1} | mago_do_mal | não; interface única | A Raiz, dentro de um caroço negro que só abre após meditar | Não |
| `passo_de_linho` | Passo de Linho | movimento_e_fisica | andar sem correr deixa de emitir o sinal visual de passos, mas a visão inimiga não muda | {"max_percent":0,"walk_only":true} | assassin | não; mesma supressão | Campas Cinzentas, nos pés da efígie do corredor estreito | Não |
| `salto_de_cabra` | Salto de Cabra | movimento_e_fisica | agarrar uma borda depois de cair converte a queda em balanço uma vez por travessia | {"max_percent":0,"uses_per_crossing":1} | batedor | não; verbo único | Cimeira, sob a cornija alcançada pelo caminho de dentro | Não |
| `rolamento_de_mare` | Rolamento de Maré | movimento_e_fisica | a esquiva que termina dentro de água rasa continua em deslize, mas não pode encadear ataque | {"max_percent":0,"attack_lock_frames":18} | warrior | não; substitui a saída | Cidade Afogada, numa janela abaixo da linha de água | Não |
| `calcanhar_de_obsidiana` | Calcanhar de Obsidiana | movimento_e_fisica | uma aterragem pesada parte chão rachado sem exigir ataque de queda | {"max_percent":0,"heavy_landing":true} | berserker | não; verbo de terreno | Fornalha, na chaminé cujo piso soa oco | Não |
| `fio_de_vento` | Fio de Vento | movimento_e_fisica | saltar a favor de uma rajada prende o manto e mostra a próxima corrente ascendente | {"max_percent":0,"reveal_s":5} | batedor | sim; sem somar duração | Cimeira, pendurado no sino de gelo exterior | Não |
| `joelho_de_pedra` | Joelho de Pedra | movimento_e_fisica | empurrado contra uma parede, podes gastar uma esquiva para cair de lado em vez de ressaltar | {"max_percent":0,"stamina_cost":25} | tank | não; troca a reacção | Fojo, atrás da prensa de minério bloqueada | Não |
| `corda_do_naufrago` | Corda do Náufrago | movimento_e_fisica | uma corda cortada por ti fica escalável do lado de baixo até ao descanso | {"max_percent":0,"until_rest":true} | assassin | não; estado do atalho | Costa Quebrada, no mastro que só se alcança pela falésia | Não |
| `passada_de_raiz` | Passada de Raiz | movimento_e_fisica | raízes móveis deixam de agarrar enquanto caminhas para trás de frente para elas | {"max_percent":0,"backward_only":true} | sorcerer | não; condição espacial | Raizama, sob o micélio que recua da luz | Não |
| `queda_contada` | Queda Contada | movimento_e_fisica | antes de saltar, o bordo mostra se a queda causa dano, quase morte ou morte | {"max_percent":0,"categories":3} | universal | não; leitura única | Brumal, atrás do telhado quebrado do tutorial de quedas | Não |
| `guarda_tardia` | Guarda Tardia | combate_defensivo | bloquear depois do compromisso mostra quanto da stamina o golpe vai quebrar | {"max_percent":0,"preview_frames":8} | tank | não; leitura sobreposta | Fojo, no escudo abandonado junto ao elevador | Não |
| `eco_do_aparo` | Eco do Aparo | combate_defensivo | um parry falhado deixa uma imagem do frame correcto no chão até ao fim do combate | {"max_percent":0,"ghosts":1} | warrior | não; conserva só o último | Brumal, na arena de treino atrás da porta interior | Não |
| `muro_respirado` | Muro Respirado | combate_defensivo | baixar a guarda voluntariamente antes de quebrar converte a quebra em recuo sem atordoamento | {"max_percent":0,"before_zero":true} | tank | não; substitui a quebra | Santuário Branco, sob o banco dos penitentes armados | Não |
| `pele_de_sal` | Pele de Sal | combate_defensivo | o primeiro projéctil bloqueado marca no escudo a direcção do atirador | {"max_percent":0,"first_projectile":true} | paladin | sim; não soma marcas | Costa Quebrada, no ninho do atirador acima do cais | Não |
| `vigilia_dupla` | Vigília Dupla | combate_defensivo | ao fixar um alvo, um segundo atacante dentro do arco traseiro acende a borda do ecrã | {"max_percent":0,"attackers":1} | assassin | não; canal de acessibilidade | Selva Funda, na plataforma entre duas emboscadas | Não |
| `osso_que_cede` | Osso que Cede | combate_defensivo | receber contusão durante uma esquiva falhada permite rolar ao levantar, sem alterar i-frames | {"max_percent":0,"wakeup_option":true} | berserker | não; opção de levantar | Campas Cinzentas, na pilha de fémures sob o sino | Não |
| `nevoa_no_escudo` | Névoa no Escudo | combate_defensivo | bloquear magia deixa no escudo a cor e o símbolo do elemento que passou | {"max_percent":0,"until_next_hit":true} | sorcerer | sim; uma leitura por elemento | Cidade Afogada, no laboratório de escudos inundado | Não |
| `brasa_recuada` | Brasa Recuada | combate_defensivo | rolar para fora de uma área ardente deixa uma marca no limite seguro por três segundos | {"max_percent":0,"marker_s":3} | batedor | não; conserva a marca recente | Fornalha, no anel exterior do lago de escória | Não |
| `raiz_que_ampara` | Raiz que Ampara | combate_defensivo | um parceiro em guarda quebrada pode usar a tua colisão como cobertura sem te empurrar | {"max_percent":0,"partner_only":true} | paladin | não; regra de colisão | A Raiz, atrás das duas estátuas encostadas | Não |
| `primeiro_sulco` | Primeiro Sulco | combate_ofensivo | o primeiro golpe de uma cadeia grava a direcção de fuga usada pelo alvo | {"max_percent":0,"one_vector":true} | warrior | não; substitui a gravação | Brumal, na oficina do espadachim sem nome | Não |
| `agulha_de_costas` | Agulha de Costas | combate_ofensivo | um golpe nas costas deixa a segunda adaga pronta para o corte cruzado | {"max_percent":0,"followup_window_s":2} | assassin | não; ramo único | Selva Funda, no passadiço por trás do sentinela | Não |
| `peso_do_vazio` | Peso do Vazio | combate_ofensivo | um pesado que falha por menos de meio metro mostra a zona real do próximo arco | {"max_percent":0,"miss_distance_m":0.5} | berserker | não; treino do último golpe | Fojo, ao lado do bloco de teste rachado | Não |
| `linha_do_lanceiro` | Linha do Lanceiro | combate_ofensivo | uma estocada em contra-ataque prolonga no chão a linha que teria acertado | {"max_percent":0,"line_s":2} | paladin | sim; não multiplica dano | Santuário Branco, no corredor das lanças votivas | Não |
| `circulo_de_cinza` | Círculo de Cinza | combate_ofensivo | uma arte circular que acerta dois alvos marca o espaço ainda não coberto pelo arco | {"max_percent":0,"targets":2} | warrior | não; leitura da arte | Campas Cinzentas, no centro da rotunda funerária | Não |
| `mira_partilhada` | Mira Partilhada | combate_ofensivo | uma flecha sinalizadora faz o parceiro ver também a queda prevista do próximo disparo | {"max_percent":0,"next_shot":1} | batedor | não; partilha um traçado | Cimeira, no poleiro acima da ponte de vento | Não |
| `contracanto` | Contracanto | combate_ofensivo | conjurar durante o aviso sonoro inimigo mostra se a magia termina antes do compromisso | {"max_percent":0,"timing_preview":true} | sorcerer | não; leitura temporal | Cidade Afogada, no coro submerso do arquivo | Não |
| `dente_de_fogo` | Dente de Fogo | combate_ofensivo | atingir óleo com dano de fogo transforma a poça numa área persistente legível | {"max_percent":0,"area_s":6} | mago_do_mal | não; mesma área | Fornalha, dentro da cuba de têmpera vazia | Não |
| `raiz_do_empurrao` | Raiz do Empurrão | combate_ofensivo | empurrar um inimigo pesado revela a massa que faltou para o deslocar | {"max_percent":0,"reveal_kg":true} | tank | não; informação, não força | A Raiz, junto ao gigante que não pode ser movido | Não |
| `peito_aberto` | Peito Aberto | risco | sem peça de peito, um parry falhado permite um empurrão de emergência em vez de bloquear | {"max_percent":0,"stamina_cost":20} | berserker | não; condição de equipamento | Fornalha, sobre a armadura derretida do duelista | Não |
| `ultima_luz` | Última Luz | risco | abaixo de um quarto de vida, fontes de cura ainda não usadas deixam um rasto visível | {"max_percent":0,"health_threshold_percent":25} | paladin | não; não altera cura | Santuário Branco, atrás do vitral apagado | Não |
| `mana_vermelha` | Mana Vermelha | risco | sem mana, uma magia vermelha mostra exactamente os PV que cobraria antes de confirmar | {"max_percent":0,"preview_only":true} | mago_do_mal | não; informação única | A Raiz, na mesa onde o sangue não seca | Não |
| `passo_sem_regresso` | Passo sem Regresso | risco | entrar numa arena sem frascos mantém a porta aberta durante o primeiro aviso do chefe | {"max_percent":0,"one_warning":true} | assassin | não; condição de arena | Campas Cinzentas, na porta que fecha atrás do carrasco | Não |
| `trovao_na_mao` | Trovão na Mão | risco | segurar um pesado durante uma tempestade atrai um raio para a arma e marca o impacto | {"max_percent":0,"charge_required":true} | warrior | não; evento ambiental | Fulgor, no pára-raios tombado da praça | Não |
| `fundo_do_poco` | Fundo do Poço | risco | depois de sobreviver a uma queda quase mortal, revela a saída mais baixa da sala | {"max_percent":0,"near_death_fall":true} | batedor | não; uma saída por sala | Fojo, no patamar inferior do poço de minério | Não |
| `vidro_sem_armadura` | Vidro sem Armadura | risco | com carga leve e nenhum escudo, feitiços persistentes mostram o intervalo exacto entre pulsos | {"max_percent":0,"pulse_preview":true} | sorcerer | não; leitura de volume | Cidade Afogada, na redoma partida da torre | Não |
| `companhia_vazia` | Companhia Vazia | risco | sozinho num mundo co-op, altares de ressurreição apontam para o próximo sinal de invocação | {"max_percent":0,"solo_only":true} | universal | não; navegação condicional | Brumal, no segundo assento vazio da mesa de descanso | Não |
| `ganancia_mineira` | Ganância Mineira | almas | um veio explorado mostra quantos inimigos recompensados restam na zona | {"max_percent":0,"counter":true} | berserker | não; informação da zona | Fojo, carta rara do kobold armadilheiro da mina | Não |
| `fio_da_mancha` | Fio da Mancha | almas | a tua mancha de almas liga-se por fio ao último atalho aberto | {"max_percent":0,"one_anchor":true} | assassin | não; uma rota | Campas Cinzentas, sob a ponte que volta à fogueira | Não |
| `peso_do_morto` | Peso do Morto | almas | junto da mancha, o chão mostra a direcção do golpe que te matou | {"max_percent":0,"one_direction":true} | tank | não; memória da morte | Brumal, no cadáver atrás do primeiro brutamontes | Não |
| `dizimo_branco` | Dízimo Branco | almas | oferecer almas num altar deixa-as guardadas ali até ao próximo descanso | {"max_percent":0,"one_altar":true} | paladin | não; depósito não acumula entre altares | Santuário Branco, na caixa de esmolas selada por dentro | Não |
| `mapa_dos_caidos` | Mapa dos Caídos | almas | uma mancha recuperada revela outras manchas de jogadores na mesma travessia | {"max_percent":0,"reveal_s":12} | batedor | não; só sobreposição social | Cimeira, no memorial varrido pelo vento | Não |
| `conta_afogada` | Conta Afogada | almas | almas perdidas dentro de água sobem à superfície como bolhas visíveis | {"max_percent":0,"water_only":true} | sorcerer | não; muda apresentação | Cidade Afogada, no pescoço da estátua submersa | Não |
| `cinza_de_dez` | Cinza de Dez | almas | ao esgotar as dez derrotas recompensadas de um inimigo, marca a sua carta final no bestiário | {"max_percent":0,"rewarded_defeats":10} | universal | não; estado de catálogo | Fornalha, na décima urna da galeria de cinza | Não |
| `eco_sem_face` | Eco sem Face | almas | derrotar um sem-rosto faz a mancha repetir a silhueta do equipamento que ele largaria | {"max_percent":0,"preview_card":true} | mago_do_mal | não; pré-visualização única | A Raiz, carta rara do alabardeiro sem rosto | Não |
| `bruma_em_vidro` | Bruma em Vidro | elementos | bloquear bruma condensa gotas que assinalam chão escorregadio | {"max_percent":0,"marker_s":4} | tank | não; marca ambiental | Brumal, dentro da janela embaciada da torre | Não |
| `seiva_inversa` | Seiva Inversa | elementos | veneno acumulado também enche um traço verde na arma que o aplicou | {"max_percent":0,"mirrored_meter":true} | assassin | não; espelho visual | Selva Funda, no tronco oco da árvore venenosa | Não |
| `osso_sem_sangue` | Osso sem Sangue | elementos | atingir um alvo imune a sangramento troca o ícone da barra pelo material a usar | {"max_percent":0,"hint_count":1} | warrior | não; pista de fraqueza | Campas Cinzentas, na mão do esqueleto intacto | Não |
| `ferro_aterrado` | Ferro Aterrado | elementos | um raio bloqueado desenha no chão o caminho para a superfície não metálica mais próxima | {"max_percent":0,"path_s":3} | paladin | não; rota de fuga | Fulgor, sob a grelha electrificada da oficina | Não |
| `carvao_fendido` | Carvão Fendido | elementos | rolar apaga queimadura se a esquiva terminar em água ou cinza fria | {"max_percent":0,"required_surfaces":2} | berserker | não; cura binária | Fornalha, na vala de cinza junto ao forno | Não |
| `sal_da_sombra` | Sal da Sombra | elementos | escuridão recebida deixa visível a fonte mesmo atrás de cobertura durante um segundo | {"max_percent":0,"reveal_s":1} | mago_do_mal | não; sinal curto | Costa Quebrada, numa tigela de sal dentro da gruta | Não |
| `prata_da_mare` | Prata da Maré | elementos | dano mágico que atravessa o escudo colore apenas a parcela não absorvida | {"max_percent":0,"split_display":true} | sorcerer | não; apresentação de dano | Cidade Afogada, no escudo cerimonial do salão | Não |
| `cera_do_relampago` | Cera do Relâmpago | elementos | uma conversão elemental activa deixa uma vela no HUD que acaba com o efeito | {"max_percent":0,"hud_candle":true} | paladin | sim; não estende duração | Santuário Branco, atrás do altar atingido por raio | Não |
| `lagrima_vermelha` | Lágrima Vermelha | elementos | pagar PV por necromancia desenha a rota de regresso à última fonte de cura | {"max_percent":0,"route_until_heal":true} | mago_do_mal | não; uma rota activa | A Raiz, dentro do relicário que pulsa sem som | Não |
| `marujo_perdido` | Marujo Perdido | coop | separados por uma parede, ambos vêem a porta que volta a juntá-los | {"max_percent":0,"both_players":true} | batedor | não; uma porta comum | Costa Quebrada, carta rara do submerso do cais | Não |
| `pulso_gemeo` | Pulso Gémeo | coop | quando o parceiro inicia ressurreição, o teu HUD mostra o seu círculo e compromisso | {"max_percent":0,"cue_equivalence":true} | paladin | não; canal partilhado | Santuário Branco, entre as duas campas paralelas | Não |
| `guarda_revezada` | Guarda Revezada | coop | baixar a guarda junto do parceiro transfere para ele a marca do atacante fixado | {"max_percent":0,"range_m":2} | tank | não; uma marca | Brumal, na torre defendida por dois orcs | Não |
| `passo_em_eco` | Passo em Eco | coop | atravessar um atalho faz o parceiro ver a tua última pegada do outro lado | {"max_percent":0,"footsteps":1} | assassin | não; conserva uma pegada | Selva Funda, na ponte dupla sob a copa | Não |
| `mana_partida` | Mana Partida | coop | ao meditar lado a lado, cada jogador escolhe quem termina primeiro e quem mantém a vigília | {"max_percent":0,"choices":2} | sorcerer | não; decisão conjunta | Cidade Afogada, no banco duplo do observatório | Não |
| `furia_avisada` | Fúria Avisada | coop | activar Fúria envia ao parceiro o símbolo das acções que deixaste de poder usar | {"max_percent":0,"symbols":2} | berserker | não; acessibilidade | Fornalha, no balcão acima da arena do ferreiro | Não |
| `alvo_de_neve` | Alvo de Neve | coop | um inimigo marcado por flecha mostra ao parceiro a tua linha de tiro bloqueada | {"max_percent":0,"line_of_fire":true} | batedor | não; uma linha | Cimeira, no posto dos dois vigias congelados | Não |
| `sangue_em_dueto` | Sangue em Dueto | coop | se ambos enchem sangramento no mesmo alvo, as duas contribuições aparecem em metades da barra | {"max_percent":0,"split_meter":true} | assassin | não; apresentação partilhada | Campas Cinzentas, no sarcófago aberto por duas alavancas | Não |
| `raiz_entre_dois` | Raiz entre Dois | coop | se o parceiro cai fora do ecrã, raízes no chão apontam para a rota navegável até ele | {"max_percent":0,"route_until_revive":true} | universal | não; uma rota por queda | A Raiz, entre os dois tronos vazios | Não |

## 8. As quatro perguntas do fio solto

| Pergunta | Resposta |
|---|---|
| **Como se usa?** | armas herdam o moveset da família; melhoria escolhe-se no altar; armadura e anéis equipam-se no ecrã WP11; estados entram por ataque e mostram barra/saída; Assassino usa duas adagas e habilidade de classe |
| **Como se prova?** | `GameData` valida contagens, 88 golpes, seis níveis sem força, estados simétricos, oito eixos e todos os IDs WP6; `self_test.gd` repete a fronteira e os três guardas do Assassino |
| **De onde vem a arte?** | cada item/estado tem `descricao_visual`; cinco armas reutilizam imagens aprovadas, onze armaduras geram neste bloco e tudo o resto espera `Fatia 1?` |
| **Quanto custa?** | agora: 11 fontes 1254×1254 com import de UI a 512; futuro: 115 armas + 57 armaduras + 70 anéis, produzidos só quando entrarem numa fatia; runtime dos sete golpes e equipar ficam para M2/WP11 |

## 9. O que continua aberto

- ⏳ Mateus confirmar ou alterar a proposta do Assassino; este catálogo não transforma a instrução do Rico em consenso.
- 🔴 Implementar no M2 os sete golpes novos, artes e estados; a troca uma/duas mãos já executa em 12 frames e os dados fixam o restante contrato.
- 🟠 O ecrã de equipamento/anéis, ganho dos oito dedos adicionais e persistência dos votos pertencem ao WP11/save v2.
- ✅ O [`70`](70-fecho-dos-sistemas-de-combate.md) fechou contra-ataque só em perfuração, piso corporal fora do bloqueio e empunhadura; a tensão elemental dos escudos é agora a pergunta 43.

## Ligações

[`12-classes.md`](12-classes.md) · [`14-equipamento.md`](14-equipamento.md) · [`37-aneis-e-elementos.md`](37-aneis-e-elementos.md) · [`41-estudo-armas-e-golpes.md`](41-estudo-armas-e-golpes.md) · [`51-familias.md`](51-familias.md) · [`67-catalogo-do-bestiario.md`](67-catalogo-do-bestiario.md) · [`equipment.json`](../game/data/equipment.json)
