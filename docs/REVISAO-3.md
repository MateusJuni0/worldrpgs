# REVISÃO 3 — Isto vai dar um bom jogo?

**Âmbito:** leitura de experiência, não nova auditoria de coerência nem de construção. Li a Fatia 1 como uma noite de jogo de Mateus + Rico: o que cada um faz, quando espera, onde decide e o que vai contar no dia seguinte.

> **Resposta curta:** há aqui um bom combate e três ou quatro momentos excelentes. Ainda **não há prova de um bom jogo co-op**. A versão corrente da Fatia 1 pode tornar-se um souls-like honesto jogado por duas pessoas em paralelo: repetição de dois inimigos, o melhor jogador a resolver as lutas, o convidado a avançar o mundo de outra pessoa e pausas de 40 segundos apresentadas como decisões.

Isto é sobretudo opinião de design. Onde encontrei uma regra objectivamente incompleta, corrigi-a à parte; onde a correcção mudaria a experiência, deixei `[TENSÃO]` no [`99`](../spec/99-perguntas-abertas.md).

---

## 1. 🔴 O co-op ainda é companhia, não interdependência

### O que o jogador sente

Dois jogadores podem atacar o mesmo lanceiro, ou dividir dois lanceiros e fazer um duelo cada um. O círculo de agressão limita os atacantes e protege uma rota de fuga; é uma boa regra de justiça, mas também facilita que cada jogador receba o seu adversário. Nenhum inimigo comum da Fatia 1 obriga um a ler o que o outro está a fazer.

As excepções são boas, mas tardias ou ainda por preencher:

- ressuscitar o parceiro é uma acção realmente partilhada;
- o Tanque pode provocar;
- a arena de Vorgar exige **SEPARAR/JUNTAR**, mas essas duas sequências ainda não foram autoradas;
- marcas, pings e voz posicional ajudam a comunicar, mas comunicação não é cooperação se os dois continuam a resolver perguntas independentes.

Se um dos dois for muito melhor, a spec não lhe dá razão para **precisar** do outro. Ele mata primeiro, abre caminho e o segundo acompanha. O jogador menos hábil recebe espólio instanciado mesmo quando não criou a vitória; pode passar uma noite inteira sem ter um momento decisivo.

Há ainda uma hierarquia escondida entre os dois: o anfitrião manda no mundo, abre os atalhos e conserva o mapa; o convidado leva personagem e recompensa, mas deixa o progresso espacial na casa do outro. A recomendação corrente da pergunta 32 chega a pedir que o convidado volte a matar no próprio mundo um chefe que já derrotou com o amigo. Isto duplica conteúdo como tarefa e torna um deles o protagonista e o outro o ajudante.

### Porque estraga muito

O pilar não é “há dois corpos no ecrã”; é “co-op sempre disponível”. Para Mateus e Rico, repetir a campanha trocando o anfitrião não é mais jogo — é manutenção de dois saves. E se a melhor estratégia de combate for ambos baterem no mesmo alvo até sobrar um, as classes e a voz não salvam o pilar.

### Proposta concreta

Antes de aumentar Brumal, provar três verbos num percurso de 20 minutos:

1. **salvar** — um inimigo cria uma situação legível que o parceiro consegue quebrar;
2. **preparar** — um jogador abre uma janela que só o outro aproveita;
3. **separar e reunir** — os dois têm tarefas simultâneas e voltam a convergir.

Vorgar tem de materializar uma pergunta **SEPARAR** e outra **JUNTAR**, não apenas alternar o alvo. Um lanceiro/brutamontes misto deve ter uma abertura preparada por um e consumida pelo outro, com versão solo honesta.

Para a campanha, recomendo um **save de dupla opt-in**: quando os dois estão presentes e no mesmo estado anterior, chefe, descanso e atalho abertos nessa sessão espelham-se nos dois mundos. O modo anfitrião/convidado continua disponível para sessões soltas. Assim ninguém é condenado a repetir o que já venceu para o seu save “contar”.

**Vai para:** perguntas **32 e 59** do [`99`](../spec/99-perguntas-abertas.md).

---

## 2. 🔴 Brumal estica dois professores até eles virarem trabalho

### Percurso mental, minuto a minuto

| Momento | O que acontece | Risco de experiência |
|---|---|---|
| Escolha inicial | seis origens para dois lugares | promessa boa, mas Guerreiro/Tanque/Paladino começam todos em espada + escudo e ainda não contam três histórias distintas |
| Primeiros minutos | lanceiro, depois dois lanceiros, depois brutamontes | a dois, o “professor” morre depressa ou vira dois duelos; não garante que alguém aprenda esquiva/parry |
| Caminho de Brumal | 8 min **sem contar combate, atalhos ou exploração** | o relógio real cresce bastante; a densidade pede 12 comuns, 3 elites, 2 nomeados e 1 subchefe antes do guardião |
| Toca | três salas antes de Vorgar | sem terceiro papel, muda o corredor mas não muda a pergunta |
| Vorgar | pilares, duas fases, mancha e ressurreição | aqui há finalmente material para uma história que se conta |

O catálogo executável da Fatia 1 marca apenas `orc_spearman` e `orc_brute`. Brumal também orçamenta batedores e um nomeado baseado neles, mas `goblin_mist_scout` continua `fatia_1:false`. Portanto a zona pede uma curva larga com dois papéis reais: rápido e pesado.

Um inimigo com quatro ataques não equivale a um terceiro papel. Depois de se aprender o lanceiro, voltar a vê-lo com mais vida ou um ataque extra prolonga a prova; não cria uma nova decisão. O nomeado corre o mesmo risco: um nome não torna memorável uma luta cuja solução já era conhecida.

### Difícil ou frustrante?

Aqui o risco maior nem é frustração: é **apatia**. O jogador sabe o que fazer e repete-o. Pára de observar o cenário, corre para o próximo portão e transforma a travessia em intervalo entre coisas importantes.

### Proposta concreta

Até existir um terceiro papel verdadeiro, reduzir a curva da Fatia 1 para **seis a sete batidas de combate autoradas**, sem repetir a mesma composição mais de duas vezes. Recomendação: promover o Batedor goblin da bruma para a Fatia 1 e usá-lo como papel de grupo/controlo, ou cortar densidade até ele estar pronto. Não se deve preencher oito minutos com mais lanceiros.

Cada batida tem de mudar pelo menos uma destas perguntas: prioridade de alvo, espaço, ritmo, objectivo ou cooperação. “Mais dois corpos” não conta.

**Vai para:** pergunta **57** do [`99`](../spec/99-perguntas-abertas.md).

---

## 3. 🔴 A spec chama “decisão conjunta” a dois tipos de espera

### Meditação

Quarenta segundos para recuperar 100% de mana, duas tentativas por descanso, é risco quando há inimigos capazes de chegar. Num caminho já limpo é apenas um jogador sentado e o outro a guardar nada. Duas utilizações podem criar **80 segundos de inactividade** para quem não lançou a magia.

Pior: a espera compra outra reserva completa para a classe com mais soluções. O preço do mago forte é pago em parte pelo parceiro, não apenas pelo mago. Isto contradiz a promessa de que o tempo é uma escolha de ambos: se a Feiticeira precisa de mana para a próxima sala, a alternativa do Guerreiro é esperar ou pedir-lhe que jogue pior.

**Isto é frustrante, não difícil.** Não há erro para aprender num sítio seguro; há um cronómetro.

### Ressurreição

A ideia é excelente: abandonar dano para tentar salvar o amigo é co-op real. Os números correntes não demonstram que a jogada existe. A canalização exige 5–7 s sem interrupção; os ataques de Vorgar recuperam por bem menos de um segundo, e o refúgio de arena promete apenas 1–2 s para “beber ou ressuscitar”. O chefe ainda deve escolher o ressuscitador como alvo natural.

Se o jogador caído não tem acção durante esse minuto, ele vê o parceiro concluir uma luta impossível de interromper para o salvar. Ao fim do minuto reaparece fora; numa arena selada, pode continuar sem jogar até o combate terminar.

**Isto torna-se frustrante quando a spec promete uma janela que os próprios tempos não permitem.** Difícil seria ver a janela e falhar; aqui pode não existir janela nenhuma.

### Proposta concreta

- **Meditação:** conservar os 40 s apenas quando geram uma defesa real. Recomendação: iniciar o ritual chama uma vaga finita sem almas/cartas; se não existir inimigo alcançável, a recuperação segura resolve em 5 s. Alternativa mais barata: 10 s para recuperar 40–50%, mantendo as duas tentativas.
- **Ressurreição:** tornar os 5–7 s **cumulativos** dentro de uma janela curta; dano interrompe o toque actual, mas não apaga todo o progresso. O caído pode rastejar devagar, mover a câmara e usar pings. Vorgar precisa de uma recuperação autorada que permita concluir a jogada depois de uma isca bem executada.

**Vai para:** perguntas **58 e 60** do [`99`](../spec/99-perguntas-abertas.md).

---

## 4. 🟠 Garantir tudo retirou quase todas as decisões do espólio

Separadamente, as decisões parecem amigas do jogador:

- mochila infinita;
- espólio instanciado;
- todas as peças visíveis garantidas em dez compras;
- chefe larga tudo de uma vez;
- inimigo deixa de sustentar recompensa/reaparição depois do tecto.

Juntas, produzem um checklist. Nunca se decide o que deixar, quem recebe, qual recompensa do chefe escolher ou se vale a pena perseguir uma peça incerta. Mata-se o tipo até o baralho acabar e guarda-se tudo. A surpresa é apenas a ordem de uma lista cujo final já se conhece.

Há ainda um problema objectivo por fechar na pergunta 23: o baralho e a transacção pagam almas apenas nas primeiras dez derrotas **do tipo**, mas o orçamento do bestiário promete `população colocada × almas × 10`. Em Brumal, quatro lanceiros partilham o mesmo baralho; o runtime fecha a torneira do tipo muito antes do orçamento publicado. O número depende da decisão “por sala, tipo ou indivíduo”, por isso não o corrigi à socapa.

### O que o jogador vai odiar

Depois de aprender que a décima morte fecha o baralho, explorar deixa de ser curiosidade e passa a ser contabilidade. E quando os inimigos deixam de reaparecer, a zona fica mais vazia precisamente para o jogador que mais gostou dela.

### Proposta concreta

Garantir **acesso**, não despejar propriedade:

- primeiras mortes revelam/entregam as peças visíveis;
- cartas seguintes dão uma escolha entre material, consumível ou uma peça já revelada;
- ao décimo registo, o catálogo completo desse tipo fica encomendável num vendedor/altar, sem depender de sorte;
- chefes apresentam uma escolha instanciada de verbo por jogador; os restantes ficam descobertos para ciclos/segredos, não perdidos para sempre.

Separar contabilmente almas e cartas: baralho por tipo; almas pelo contador de reaparição que os donos escolherem. Uma carta esgotada não pode apagar, por acidente, as almas que o orçamento ainda promete.

**Vai para:** perguntas **23 e 61** do [`99`](../spec/99-perguntas-abertas.md).

---

## 5. 🟠 “Nunca se zera” está, hoje, mais perto de “vai ficando vazio”

A estrutura tem boas sementes: círculos, atalhos, Brasa irreversível, NG+ até 7 e portas que podem responder numa leitura posterior. Mas a experiência especificada para a primeira passagem é finita e determinística: baralhos esgotam, inimigos desaparecem, chefe entrega tudo e o mapa regista terreno percorrido.

As **30 portas de história** agravam a tensão. Como escrita, são óptimas imagens. Como jogo, são 30 promessas que não abrem, custam tempo a testar e podem parecer conteúdo cortado. Dizer ao jogador que “não é obrigação preenchê-las” protege a produção, não protege a experiência. Mistério sem qualquer pagamento acaba por ensinar: “não vale a pena investigar portas”.

O NG+ promete inimigos novos, subchefe adicional, novo ataque e algumas portas abertas, mas quase nada disso tem identidade ou colocação autorada. Multiplicadores e um slot futuro não fazem um mundo que nunca se zera; fazem o mesmo percurso mais duro.

### Proposta concreta

Na Fatia 1, pôr **uma porta que não abre agora e uma passagem que realmente paga a curiosidade agora**. Nenhuma zona deve lançar 2–3 promessas fechadas sem pelo menos uma resposta no ciclo corrente.

Antes de vender “nunca se zera”, autorar uma segunda leitura concreta de Brumal: uma rota muda, um inimigo ocupa espaço diferente e uma porta responde ao que o jogador fez. O ciclo tem de mudar uma decisão, não apenas PV/dano.

**Vai para:** pergunta **62** do [`99`](../spec/99-perguntas-abertas.md).

---

## 6. 🟠 O mago apelão é a melhor promessa — e a Fatia 1 não a testa

A Escola vermelha contém as ideias mais contáveis da spec: usar cadáveres como moeda, levantar inimigos, encadear o Voto por verbos, devolver um feitiço no Espelho e levar um chefe derrotado como aliado. **Isto é específico do WorldRPGs.** Não é apenas “Dark Souls com mais feitiços”.

Mas a primeira noite só oferece Dardo, Ruína e Égide; o Mago do mal fica para a Fatia 2. Portanto a fatia que decide se vale a pena construir o jogo não testa a fantasia que Mateus mais quer.

Quando chegar, há o risco inverso: invocados e chefe portátil podem resolver a leitura dos inimigos, enquanto o parceiro segue atrás da procissão. “Apelão” é divertido quando permite um plano absurdo que os dois executam; deixa de ser quando a IA joga pelo jogador e torna o amigo redundante.

### Proposta concreta

Adicionar à prova da Fatia 1 um **epílogo opcional da Escola vermelha**, não o catálogo inteiro: depois de derrotar Vorgar, levantá-lo temporariamente e usá-lo numa curta luta de regresso desenhada para dois. O mago comanda/posiciona o cadáver; o parceiro cria a janela ou protege o custo de vida. É uma imagem que se conta e mede de uma vez magia forte, actores, co-op e honestidade.

Se isto não couber na Fatia 1 de produção, deve existir como spike jogável antes de multiplicar 50 feitiços. A promessa central não pode esperar pela segunda metade do projecto para ser testada.

**Vai para:** pergunta **63** do [`99`](../spec/99-perguntas-abertas.md).

---

## 7. 🟡 O combate honesto está muito bem especificado; falta provar que não ficou resolvido demais

Este é o pilar mais convincente da spec:

- compromisso pára seguimento antes do activo;
- hitbox acompanha a forma visível;
- cada ataque declara vector de fuga;
- grupos libertam o jogador antes do segundo activo;
- áudio e visual nascem do mesmo evento;
- sinais de resposta explícita ficam no modo reforçado, não são impostos a todos;
- o convidado avalia i-frames localmente.

Isto dá ao jogador uma explicação para a morte. É exactamente a diferença entre dificuldade e frustração.

O risco é a soma de margens: aviso mínimo de 500 ms, 317 ms de invencibilidade, activo instantâneo de 50–100 ms, quatro esquivas na reserva base e recuperação sempre explícita. O teste corrente só exige que o rolamento certo passe 10/10; não prova que um rolamento cedo ou tarde falha. Um jogo pode passar esse teste e ainda aceitar quase qualquer timing.

### Correcção sem decisão

Acrescentei à cláusula 5 do [`38`](../spec/38-ataques-e-honestidade.md) o controlo negativo: se o intervalo de invencibilidade não tocar no activo, o golpe tem de acertar 10/10. Isto não encurta i-frames nem decide feel; apenas impede um teste “verde” que não discrimina timing.

### Recomendação de feel

No M2, A/B de 317 ms contra uma janela menor, mudando só essa variável. Medir não apenas sucesso, mas **falsos positivos**: quantas esquivas que o jogador reconhece como cedo/tarde escapam na mesma. Honestidade é a imagem cumprir; não é toda a tentativa ser perdoada.

---

## 8. 🟡 O inventário ameaça pôr um menu entre os dois jogadores

Nove peças de armadura, até dez anéis, duas mãos/slots de arma, oito feitiços favoritos, consumíveis e mochila infinita criam muita triagem. Em solo, abrir um menu é pausa. Em co-op, é o parceiro a olhar para alguém parado.

Vários anéis ainda transformam informação aprendível em ocupação de slot. Uma vez aprendido o parry, queda ou rota, trocar um anel “de informação” parece trabalho de preparação, não construção de personagem.

### Proposta concreta

Validar a experiência inicialmente com **quatro anéis equipáveis no máximo** e presets trocados apenas no descanso. Informação descoberta passa para bestiário/acessibilidade permanente; anéis devem mudar uma acção ou uma decisão. Os 2→10 dedos podem continuar como fantasia futura, mas só depois de um teste cronometrado provar que montar um kit a dois não cria pausas longas.

**Vai para:** pergunta **64** do [`99`](../spec/99-perguntas-abertas.md).

---

## 9. 🟡 Sombrio está no sistema; ainda não está na memória

Brumal tem paleta, nevoeiro, carvalhos negros, pedra húmida, som direccional e morte com mancha. Os círculos e atalhos dão a sensação correcta de espaço aprendido. Isto cumpre boa parte do “souls-like sombrio”.

Mas a Fatia 1 exclui história, NPCs e vendedores e dá-nos apenas “orcs guardam uma porta”. Sem uma ferida concreta, uma escolha humana ou uma descoberta que reinterprete o lugar, o sombrio pode ser só cinzento. Atmosfera é onde se está; memória é **o que aconteceu ali**.

### Proposta concreta

Sem acrescentar uma missão, ligar três objectos já baratos — um cadáver/colocação, uma peça de espólio e a porta — numa pergunta ambiental com resposta dentro da própria Fatia 1. O jogador deve conseguir dizer no fim não apenas “matei Vorgar”, mas “percebi porque ele guardava aquilo”. A identidade e a resposta são dos donos; não as invento nesta revisão.

---

## As quatro promessas, sem adjectivos

| Promessa | Cumpre hoje? | Prova a favor | Onde falha |
|---|---|---|---|
| **Souls-like sombrio** | **sim no combate; incompleto no mundo** | stamina/compromisso, mancha de almas, descanso, atalhos, boss retry, ambiente legível | Brumal não tem ainda uma pergunta narrativa própria; pode ser floresta cinzenta genérica |
| **Mago apelão e surpreendente** | **sim na imaginação; não na Fatia 1** | Voto por verbos, cadáveres, Espelho, levantar chefe | os três feitiços iniciais são convencionais; invocados podem substituir os dois jogadores |
| **Mundo que nunca se zera** | **ainda não** | Brasa, NG+7, círculos, portas com leitura posterior | recompensa e corpos esgotam; 30 portas não pagas e NG+ por autorar apontam ao contrário |
| **Combate honesto** | **é a promessa mais bem cumprida** | hitbox visível, compromisso, vector, canais equivalentes, autoridade local | margens podem retirar timing; faltava controlo negativo e o co-op/summons pode contornar a leitura |

---

## Os momentos que alguém pode contar depois

Já existem quatro boas sementes:

1. recuperar duas manchas separadas dentro da arena depois de uma derrota conjunta;
2. distrair Vorgar, ressuscitar o amigo no limite e vê-lo voltar com metade da vida;
3. levar a investida de Vorgar a partir um pilar e mudar a arena antes do segundo machado;
4. derrotar um chefe e, mais tarde, levantá-lo para lutar ao nosso lado.

O problema não é ausência total. É que **2 ainda pode ser impossível pelos tempos, 4 não está na Fatia 1 e 1–3 ainda não formam uma sequência co-op autorada**. A melhor versão da primeira noite é fácil de imaginar: um cai junto da mancha, o outro usa o pilar para criar a janela, ressuscita-o, os dois sobrevivem ao SEPARAR/JUNTAR e terminam juntos. A spec tem todas as peças; falta compô-las para que esse acontecimento não seja acidente.

---

## O VEREDITO

**Eu construiria a Fatia 1, mas não construiria ainda o mundo à volta dela.** A base de combate é rara: explica as mortes, respeita duas perspectivas e contém um chefe com espaço para uma boa história. O perigo não é a spec ser má; é ela já ter confundido quantidade catalogada com variedade jogada e presença de dois corpos com cooperação.

### Se só pudesse dizer uma coisa ao Mateus e ao Rico

> **Não multipliquem conteúdo até Brumal produzir um momento que só podia ter acontecido porque eram dois.** Hoje o jogo sabe ser um souls-like honesto; ainda tem de provar que não é apenas dois solos lado a lado. Cortem repetição, façam o jogador menos hábil salvar a tentativa e testem essa história antes das outras onze zonas.
