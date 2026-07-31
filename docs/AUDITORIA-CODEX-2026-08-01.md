# Auditoria independente — Codex (gpt-5.6-sol, esforço máximo)

**01-08-2026.** Auditoria pedida pelo Mateus. O Codex leu o repositório inteiro — 51 documentos de spec e ~4000 linhas de GDScript — com Dark Souls 2 e 3 como referência.

> **Não é para aceitar em bloco.** É uma segunda opinião, e algumas das críticas são discutíveis. O que **não** é discutível está marcado ⭐ no resumo do topo.

---

codex
# 1. O que nos escapou

## P0 — necessários antes de aumentar conteúdo

### 1. Modelo de agressão para dois jogadores

**Problema:** existe o limite de dois atacantes e a alternância dos chefes, mas não há regras para um inimigo normal escolher e trocar de alvo: distância, dano recebido, cura, ressurreição, linha de visão ou tempo no mesmo alvo.

**Porque importa:** sem isto, o co-op oscila entre dois maus extremos: o inimigo persegue permanentemente um jogador enquanto o outro bate grátis, ou muda de alvo sem aviso. A Provocação agrava o problema ao impor um alvo em vez de influenciar a ameaça.

**O que fazer:** definir uma pontuação de ameaça, actualizada apenas entre sequências. Trocas de alvo devem ter aviso corporal, intervalo mínimo e peso para dano recente, proximidade, cura e ressurreição. Provocação aumenta ameaça; não bloqueia a IA durante quatro segundos.

### 2. Estado do baralho de espólio em co-op

**Problema:** o baralho é por tipo de inimigo, o espólio é instanciado, mas não existe dono, cursor, seed ou regra para quem entra tarde na sessão. [Baralho por tipo](../spec/43-estudo-espolio-inventario-mundo.md) *(linha 45)* e [cópia para cada jogador](../spec/18-progressao.md) *(linha 30)* não chegam.

**Porque importa:** um convidado que entra depois de cinco compras do baralho pode ficar sem cartas obrigatórias; um recomeço de ligação pode repetir uma compra; dois mundos podem discordar sobre o que já saiu.

**O que fazer:** baralho por personagem e arquétipo, persistido no save dessa personagem. Cada morte faz uma transacção atómica: escolhe a carta, grava o cursor, entrega o item. Entrar tarde nunca usa o progresso do outro jogador.

### 3. Local seguro para manchas de almas e corpos

**Problema:** o corpo e as almas ficam onde se morreu, mas há precipícios, água profunda, empurrões, falhas de navegação e limites do mundo. Não existe “último chão recuperável”.

**Porque importa:** perder almas porque a mancha nasceu dentro do vazio, debaixo de água ou fora da malha não é dificuldade; é erro de coordenadas a violar a Lei 1.

**O que fazer:** guardar continuamente o último ponto navegável, estável e acessível. Mortes em queda, água, kill volumes ou fora da navegação colocam corpo e mancha nesse ponto.

### 4. Recuperação da postura

**Problema:** inimigos perdem postura até zero e só a recuperam depois do cambaleio. Não existe atraso, regeneração ou decadência entre golpes — nem na spec nem no código.

**Porque importa:** qualquer jogador pode dar um golpe, fugir durante um minuto, repetir e acabar por obter um crítico gratuito. A barra invisível torna-se apenas um contador permanente.

**O que fazer:** por exemplo, postura começa a recuperar dois segundos depois do último dano, rapidamente nos inimigos leves e lentamente nos pesados; chefes recuperam por fase ou ao completar uma sequência. O estado deve ter feedback visual antes de partir.

### 5. Contrato de backstab, agarrão e derrube

**Problema:** existem backstabs, críticos de queda, agarrões e arremessos, mas faltam ângulo, distância, confirmação, invulnerabilidade, posição dos dois corpos, recuperação no chão e arbitragem de rede.

**Porque importa:** em co-op, dois jogadores podem iniciar críticos sobre o mesmo alvo; um agarrão junto a uma parede pode atravessar geometria; sem protecção ao levantar, o jogador pode ser agarrado novamente antes de recuperar. DS2/DS3 tratam críticos como estados coreografados, não como multiplicadores aplicados a um golpe normal.

**O que fazer:** escrever um contrato único de críticos: cone traseiro, distância máxima, alvo elegível, reserva exclusiva, alinhamento seguro, cancelamento, invulnerabilidade e regras para chefes. Acrescentar estado de derrube e levantamento com protecção curta.

### 6. Regras centrais de acumulação e troca de efeitos

**Problema:** dez anéis, nove peças, buffs, artes, infusões, efeitos de classe e magia podem alterar a mesma variável. Não existe ordem aditiva/multiplicativa, categorias exclusivas, tectos ou momento de activação.

**Porque importa:** o equilíbrio será decidido por acidentes de cálculo. Pior: a mochila abre em tempo real e permite equipar em combate, logo pode trocar-se resistência antes do impacto ou anéis entre cada acção.

**O que fazer:** uma taxonomia central: um efeito por categoria forte, restantes com rendimentos decrescentes; ordem de cálculo fixa; armadura e anéis só mudam em descanso. Em combate, apenas dois conjuntos de armas previamente equipados.

### 7. Reespecialização

**Problema:** está explicitamente adiada e a interface diz “sem redistribuição”. Com requisitos, soft caps, 100 níveis e catálogo largo, uma escolha inicial mal informada pode estragar dezenas de horas.

**Porque importa:** isso combate directamente as Leis 2 e 3. “Qualquer classe usa qualquer arma” vale pouco se experimentar essa arma exigir começar de novo. DS2 tinha Soul Vessels; DS3 tinha Rosaria.

**O que fazer:** classe como configuração inicial, não destino. Reespecialização no descanso, gratuita ou paga com um pequeno número de objectos encontrados por exploração — nunca farmáveis.

### 8. Reinício do mundo e NG+

**Problema:** o NG+ tem uma única linha de “especifica-se se for preciso”. O mundo, entretanto, fica progressivamente vazio.

**Porque importa:** foi importado o desaparecimento de inimigos de DS2 sem importar as válvulas de segurança que o acompanhavam: formas de suspender/reiniciar o despawn e NG+. Também impede testar builds e repetir chefes a dois.

**O que fazer:** definir já um ciclo completo: preserva personagem e equipamento; repõe inimigos, baralhos, corpos e chefes; muda composições e acrescenta padrões, nunca apenas PV e dano. Um ritual opcional pode reiniciar apenas um bioma.

### 9. Apresentação de esquiva e críticos em primeira pessoa

**Problema:** a spec reconhece o viewmodel duplicado, mas não diz o que a câmara faz durante rolamento, backstab, riposte, agarrão, queda e morte. Não há regra de horizonte, balanço ou redução de movimento.

**Porque importa:** rodar a câmara com um rolamento de 3,5–4,5 m provoca náusea; mantê-la parada sem feedback torna os i-frames ilegíveis. O problema não se resolve apenas com mais sons.

**O que fazer:** em primeira pessoa, apresentar o rolamento como passo baixo sem rotação da câmara; limitar inclinação; usar braços/arma para comunicar recuperação. Críticos devem usar uma câmara própria testada, ou ficar indisponíveis até essa apresentação existir.

### 10. Colisão entre jogadores e invocações

**Problema:** os mortos levantados atravessam o parceiro, mas nada define colisão jogador–jogador, invocado–invocado, portas estreitas ou quem pode empurrar quem.

**Porque importa:** dois jogadores, cinco inimigos e vários invocados numa passagem estreita podem bloquear a sessão inteira.

**O que fazer:** jogadores e invocados aliados não são sólidos entre si; inimigos mantêm colisão. Invocações devem ceder passagem, evitar portas e teleportar para um ponto seguro se ficarem presas.

# 2. Erros de desenho

### 1. Uma esquiva lateral resolve todo o jogo

**Problema:** a regra declara que, terminado o início da animação, o ataque está comprometido e “rolar para o lado funciona sempre”. O seguimento cai de 180°/s para 30°/s antes da hitbox. [Regras actuais](../spec/38-ataques-e-honestidade.md) *(linha 47)*.

**Porque importa:** transforma centenas de ataques numa pergunta com uma resposta universal. DS2/DS3 variam por golpe: alguns acompanham mais tempo, outros apanham rolamentos antecipados, outros pedem rolar para dentro, afastar ou simplesmente andar.

**O que fazer:** cada ataque declara momento de compromisso, curva de seguimento e vector de fuga. Nunca escrever “funciona sempre” para uma direcção de esquiva.

### 2. Hitboxes obrigatoriamente vivas apenas 3–6 frames

**Problema:** a regra “nunca mais” aplica-se a tudo. [Contrato actual](../spec/38-ataques-e-honestidade.md) *(linha 17)*.

**Porque importa:** não serve para investidas, corpos em movimento, sopros, feixes, poças, lâminas giratórias ou perigos persistentes. Vai obrigar a fingir que o efeito desapareceu enquanto visualmente continua activo.

**O que fazer:** separar contacto instantâneo, volume móvel e volume persistente. Cada alvo só pode ser atingido uma vez por passagem, ou a intervalos declarados. A hitbox deve acompanhar o que se vê, não um tecto universal.

### 3. O controlo de multidões cria filas e ainda permite stunlock

**Problema:** máximo de dois atacantes, ninguém activa no mesmo frame e intervalo mínimo de 0,20 s. O jogador, porém, fica em hit-stun durante 0,4–0,7 s.

**Porque importa:** o segundo golpe pode chegar durante a recuperação inevitável do primeiro. Ao mesmo tempo, os restantes inimigos orbitam visivelmente à espera da ficha, fazendo o sistema parecer uma fila.

**O que fazer:** o intervalo deve considerar hit-stun, knockdown e saída possível, não apenas relógio global. Permitir sobreposição de ameaças, mas garantir uma rota espacial de fuga.

### 4. Alternância fixa de alvo nos chefes

**Problema:** o chefe troca de alvo depois de cada sequência e evita repetir certos ataques. [Regra](../spec/16-chefes.md) *(linha 28)*.

**Porque importa:** os jogadores aprendem a vez: “agora é contigo, eu bato”. Isso não é leitura do chefe; é explorar o escalonador. DS2/DS3 usam atenção e posição suficientemente previsíveis para haver intenção, mas não uma alternância mecânica.

**O que fazer:** ameaça ponderada com cooldown de mudança, ataques específicos de troca e sinais claros de cabeça, tronco ou voz.

### 5. Cinco encontros de chefe em zonas de 2–3 minutos

**Problema:** 12 zonas de 2–3 minutos sustentam 36 chefes de campo, 12 subchefes e 12 guardiões. [Aritmética actual](../spec/49-biomas.md) *(linha 15)*.

**Porque importa:** há um encontro “de chefe” aproximadamente a cada 30–40 segundos de travessia limpa. Perde-se preparação, surpresa, escala e identidade. O descanso à vista de todas as portas elimina ainda a pressão de recursos antes de cada chefe.

**O que fazer:** um guardião verdadeiro por bioma. Transformar os 36 “chefes de campo” em elites/named encounters sem barra, arena ou produção exclusiva. Descansos devem servir arcos inteiros, não cada porta.

### 6. Reforço de armas e feitiços quebra frontalmente a Lei 2

**Problema:** armas sobem cerca de 10% por nível até +6; feitiços chegam a 175%, mais área, perfuração e lançamentos. [Armas](../spec/51-familias.md) *(linha 217)* e [feitiços](../spec/42-estudo-magia.md) *(linha 131)*.

**Porque importa:** DS2/DS3 usam reforço numérico, mas este projecto escreveu deliberadamente uma lei diferente. Aqui, uma arma não melhorada passa a ser a arma errada, criando gating por materiais.

**O que fazer:** melhoria desbloqueia postura, arte alternativa, alteração de escala, novo golpe ou conversão elemental. O dano-base deve variar pouco ou nada.

### 7. O mago do mal não está equilibrado; está autorizado a saltar o jogo

**Problema:** chefe portátil, número de invocados dependente apenas do hardware e Voto até +90% de dano. [Decisões](../spec/52-mago-do-mal.md) *(linha 268)*.

**Porque importa:** jogar com metade da vida não compensa acrescentar ao grupo um chefe com 60% dos PV, IA e dano. O outro jogador pode receber a atenção enquanto o exército produz dano. +90% é precisamente uma melhoria de números proibida pela Lei 2.

**O que fazer:** um invocado normal ou dois pequenos. Chefes derrotados dão um “eco” com um único ataque de assistência, não a IA completa. Voto deve trocar verbos — perfurar, espalhar fogo, consumir cadáver — não multiplicar dano.

### 8. Espelho é mais fácil do que o parry e escala com o inimigo

**Problema:** lança-se em 0,4 s, dura 1,5 s, anula o golpe e devolve todo o dano. Todos os ataques avisam pelo menos 0,5 s.

**Porque importa:** não exige timing real; pode ser lançado depois de ver quase qualquer aviso. Quanto mais forte o chefe, mais forte o feitiço, sem investimento do jogador.

**O que fazer:** janela activa de 0,15–0,20 s, recuperação falhada e reflexão limitada a projécteis ou convertida em dano de postura. O resultado deve escalar com o catalisador, não com o dano bruto do chefe.

### 9. A fórmula de estabilidade está invertida

**Problema:** `stamina_perdida = dano_de_stamina × (estabilidade / 100)`. [Fórmula](../spec/41-estudo-armas-e-golpes.md) *(linha 151)*. Quanto maior a estabilidade, mais stamina se perde.

**Porque importa:** o broquel de 50 é melhor a bloquear do que o escudo grande de 85. Além disso, o protótipo ainda usa 100% de absorção física, enquanto a regra nova fixa 90%.

**O que fazer:** `dano × (1 − estabilidade/100)` e um custo mínimo. Integrar a estabilidade concreta do escudo no código e eliminar a absorção universal antiga.

### 10. Dez anéis e nove slots de armadura

**Problema:** até dez dos 70 anéis equipados e nove slots de armadura. [Anéis](../spec/37-aneis-e-elementos.md) *(linha 9)* e [armadura](../spec/51-familias.md) *(linha 154)*.

**Porque importa:** DS2/DS3 usam quatro slots de anel e quatro peças de armadura. Com dez anéis, a oportunidade perdida por equipar um é pequena e a combinatória torna-se impossível de equilibrar. Com 30 peças distribuídas por nove slots há apenas 3,3 escolhas médias por slot; se forem 30 conjuntos, são 270 peças.

**O que fazer:** quatro anéis equipados e quatro slots visuais: cabeça, tronco, mãos, pernas. Capa, máscara e cinto podem ser cosméticos ou insígnias sem malha separada.

### 11. Cooldowns de 15–60 segundos convidam a esperar

**Problema:** habilidades de classe voltam com tempo real.

**Porque importa:** depois de cada encontro, a decisão óptima é ficar parado até Eco, Fúria ou Julgamento regressarem. DS2 usa stamina e lançamentos; DS3 usa stamina e FP. Nenhum pede ao jogador que espere um minuto no corredor.

**O que fazer:** recurso restaurado no descanso ou ganho durante combate por parry, postura, dano ou assistência ao parceiro. Cooldown curto apenas para impedir repetição imediata.

### 12. Alguns biomas e segredos fazem gating de build

**Problema:** o frio reduz stamina máxima, a lanterna ocupa a mão do escudo e há propostas de patamares só alcançáveis por rolamento longo ou inimigos que apenas veneno mata a tempo.

**Porque importa:** é gating de classe/equipamento com outro nome. Também altera a gramática central de stamina por bioma.

**O que fazer:** perigos devem mudar trajectos e timings, não remover verbos. O rolamento normal chega sempre; equipamento oferece rotas alternativas, nunca acesso exclusivo permanente.

### 13. Espólio enviesado pela classe contradiz “qualquer classe usa qualquer arma”

**Problema:** o jogo promete liberdade universal, mas favorece cartas ligadas à classe inicial.

**Porque importa:** o Guerreiro pode usar magia em teoria, mas recebe menos ferramentas para a experimentar. A liberdade fica na interface, não na economia.

**O que fazer:** enviesamento por lista de desejos ou famílias actualmente equipadas, escolhido pelo jogador. Nunca pela classe inicial.

### 14. “O chefe larga tudo” é uma recompensa sem decisão

**Problema:** chefes largam armadura, arma e feitiço de uma vez.

**Porque importa:** elimina antecipação, escolhas e identidade da recompensa; também despeja vários objectos e modelos por chefe. DS2/DS3 frequentemente convertem a vitória numa escolha posterior através da alma do chefe.

**O que fazer:** um item de assinatura garantido e um eco/token que escolhe entre duas ou três opções. Nada se perde para sempre; a escolha pode ser revista em NG+ ou numa memória do chefe.

### 15. O protocolo de teste declara certas mortes automaticamente correctas

**Problema:** morrer repetidamente para o mesmo ataque com stamina disponível é classificado como “falha certa; não se mexe em nada”. [Critério](../spec/28-testes.md) *(linha 18)*.

**Porque importa:** também é exactamente o sintoma de telegrafia ilegível, atraso inconsistente ou resposta mal ensinada.

**O que fazer:** rever vídeo e perguntar ao jogador o que leu. Só é falha justa se antecipou correctamente o tipo de ataque, escolheu a resposta errada e consegue explicar o erro depois.

# 3. Interacções perigosas

### 1. Vida da necromancia × frascos × cura do parceiro

**Problema:** o documento primeiro diz que PV gastos voltam com frascos; depois trata o custo como redução da vida máxima e como orçamento impossível de recuperar.

**Porque importa:** se os frascos curam o custo, o limite de invocações é falso. Se reduzem vida máxima, a regra inicial está errada. Cura remota do parceiro pode ainda contornar o preço.

**O que fazer:** todos estes custos reservam vida máxima. Vida reservada não é curável por frasco, dreno ou parceiro; regressa apenas quando o efeito termina.

### 2. Escola vermelha × marca vermelha de ataque não aparável

**Problema:** vermelho significa simultaneamente “magia aliada do Mateus”, “invocado aliado” e “este ataque inimigo não pode ser aparado”.

**Porque importa:** a cor deixa de transportar informação precisamente quando a arena estiver cheia.

**O que fazer:** reservar vermelho vivo/contorno pulsante para perigo não aparável. A escola do mal usa carmesim escuro com símbolo, forma e som próprios; nunca depender apenas da cor.

### 3. Invocado conserva espólio × necromancia

**Problema:** o inimigo levantado continua explicitamente a “largar obsidiana”.

**Porque importa:** matar, receber carta/almas, levantar e matar novamente pode duplicar recompensas e corpos.

**O que fazer:** qualquer entidade com flag `summoned` dá zero almas, zero cartas, zero cadáver reutilizável e zero progresso de reaparecimento.

### 4. Limite gráfico × poder da classe

**Problema:** preset alto permite oito invocados, médio cinco e baixo três.

**Porque importa:** uma opção gráfica altera directamente o poder da personagem. A máquina mais forte joga uma classe melhor; a máquina alvo joga a versão enfraquecida.

**O que fazer:** limite de desenho idêntico em todas as máquinas. Presets reduzem partículas, sombras, detalhe e frequência de animação à distância — nunca entidades funcionais.

### 5. Hit-stop local × segundo jogador

**Problema:** o hit-stop congela só atacante e alvo, não o mundo.

**Porque importa:** o parceiro pode bater gratuitamente num chefe congelado; em rede, clientes podem discordar sobre quando a hitbox e a postura avançam.

**O que fazer:** durante hit-stop, o par de actores fica congelado e não aceita novos impactos, ou o evento corre na autoridade e é apresentado aos clientes como desaceleração cosmética curta.

### 6. Ressurreição × escala dinâmica × alternância/Provocação

**Problema:** está proposta a redução de escala quando alguém morre; o parceiro pode ressuscitar; o chefe alterna alvo e pode ser provocado.

**Porque importa:** a vida máxima do chefe pode oscilar dentro da tentativa e os jogadores conseguem fabricar uma janela previsível de cinco segundos.

**O que fazer:** escala fixa à entrada da arena até ao fim da tentativa. Ressuscitar não altera PV do chefe. O acto de ressuscitar gera muita ameaça, mas não garante alvo.

### 7. Morte larga itens × parceiro apanha × reconexão

**Problema:** não está definido se os itens apanhados pertencem imediatamente ao parceiro, regressam ao ressuscitado ou ficam duplicados nos dois saves.

**Porque importa:** qualquer queda de ligação entre apanhar e ressuscitar pode perder ou duplicar equipamento único.

**O que fazer:** os itens ficam num depósito temporário associado à tentativa. Ressurreição devolve-os; expiração transfere-os de forma atómica ao parceiro; abandono da sessão resolve o depósito antes de gravar.

### 8. Equipamento em tempo real × resistências de bioma × 19 efeitos passivos

**Problema:** pode trocar-se armadura e anéis em combate, e cada bioma empurra um elemento dominante.

**Porque importa:** a melhor estratégia é jogar no menu: equipar defesa de fogo durante o ataque, voltar a dano na recuperação, trocar equipamento antes de uma queda.

**O que fazer:** armas preparadas podem alternar; armadura, anéis e catalisadores só mudam em descanso.

### 9. Máximo de dois agressores × Provocação × cura/área sem fogo amigo

**Problema:** um Tanque segura os dois únicos atacantes enquanto o parceiro lança área e cura à distância sem risco de atingir aliados.

**Porque importa:** elimina posicionamento e pressão sobre a retaguarda. O grupo transforma-se numa composição MMO com papéis rígidos.

**O que fazer:** Provocação influencia, não fixa. Inimigos de distância e controlo de espaço ignoram-na parcialmente; certos ataques obrigam os dois jogadores a reposicionar-se.

### 10. Dez anéis × nove peças × artes × buffs × melhoria de magia

**Problema:** cada camada parece controlável isoladamente; juntas geram centenas de modificadores e combinações.

**Porque importa:** será impossível saber se um chefe foi vencido por leitura ou por uma combinação não prevista. Os auto-testes não cobrem esta explosão combinatória.

**O que fazer:** reduzir slots e definir um orçamento de modificadores: no máximo quatro anéis, duas passivas de armadura activas e um buff temporário por categoria.

# 4. O risco real de escopo

### 1. Os 61 chefes não serão 61 chefes de qualidade souls-like

**Problema:** cada chefe pede pelo menos 8–11 ataques entre fases: perto de 500 ataques de chefe, antes de arenas, áudio, VFX, rede e testes.

**Porque importa:** dois agentes aceleram escrita e código; não produzem animação afinada, level design nem centenas de sessões de teste.

**O que fazer:** 13 chefes verdadeiros — um por bioma e o final. Doze subchefes reutilizam rigs com dois ataques novos. Os 36 “chefes de campo” passam a encontros nomeados com elites.

### 2. Primeira e terceira pessoa não ficarão igualmente boas

**Problema:** cada família precisa de animação corporal e viewmodel, mais duas câmaras, dois modelos de colisão visual e duas passagens completas de afinação.

**Porque importa:** oito famílias × onze ataques × duas perspectivas são pelo menos 176 clips, antes de artes, críticos e locomoção.

**O que fazer:** cortar primeiro o combate em primeira pessoa. Manter terceira pessoa como jogo; primeira pessoa pode voltar como modo de exploração quando tudo o resto estiver fechado.

### 3. As 120 armas não serão 120 armas mecanicamente distintas

**Problema:** a camada de dados é barata; malhas, mãos, clipping, som, VFX, arte, balanceamento e rede não são.

**Porque importa:** tentar diferenciá-las todas dará 120 variações superficiais.

**O que fazer:** lançar 16–24 armas: duas ou três por cada uma das oito famílias. A arte é da família, não de cada arma. Variantes mudam alcance, peso, escala e material.

### 4. Nove slots e 30 armaduras não fecham

**Problema:** 30 peças são poucas para nove slots; 30 conjuntos são 270 peças.

**Porque importa:** rigging modular, clipping de capas/ombros/cintos e combinações visuais tornam-se um projecto próprio.

**O que fazer:** quatro slots e 16–24 peças no primeiro jogo fechado. Efeitos adicionais vivem em anéis ou insígnias sem nova malha.

### 5. A magia larga mais necromancia completa não será equilibrada

**Problema:** a escola vermelha já tem cerca de 20 feitiços; faltam as restantes escolas, inimigos mágicos, upgrades, VFX e rede de invocações.

**Porque importa:** “o mesmo inimigo, agora aliado” exige facções, navegação, autoridade, colisões, recompensa, save e compatibilidade com todas as arenas.

**O que fazer:** 18–24 feitiços totais no primeiro jogo. Um único sistema de invocação normal e ecos simplificados de chefe.

### 6. Doze biomas profundos não cabem numa primeira versão

**Problema:** cada bioma promete dungeon, atalhos, segredos, cinco encontros de chefe, perigos, raças, materiais e arte própria.

**Porque importa:** se todos avançarem ao mesmo tempo, serão doze corredores com cores diferentes.

**O que fazer:** construir quatro biomas completos em sequência. Os restantes oito continuam aprovados como mapa de expansão, mas nenhum recebe conteúdo até o anterior passar combate, memória, navegação e co-op.

### 7. O co-op não deve ser cortado; deve ser estreitado

**Problema:** progresso individual, morte com transferência de itens, autoridade dividida, invocações e entrada tardia formam uma rede de persistência muito maior do que “dois amigos ligam-se”.

**Porque importa:** é o sistema central do projecto, mas também o mais capaz de consumir anos sozinho.

**O que fazer:** manter convite directo/Tailscale e dois jogadores. Na primeira versão, criar uma campanha da dupla com progresso comum enquanto jogam juntos; evitar resolver todos os estados possíveis de mundos divergentes.

**Ordem de corte com menor perda:** primeira pessoa → 48 chefes reclassificados → cinco slots de armadura → seis slots de anel → variantes de armas acima de 24 → feitiços acima de 24. Não cortar co-op, esquiva/parry/stamina, oito famílias nem a identidade dos 12 biomas.

# 5. Mais jogo por menos trabalho

### 1. Contar 61 encontros, não 61 produções de chefe

**Problema:** o número aprovado está a ser interpretado como 61 chefes completos.

**Porque rende:** um encontro nomeado pode ser memorável por espaço, composição e regra, sem rig ou IA exclusivos.

**O que fazer:** 13 guardiões, 12 campeões e 36 encontros nomeados. Só os guardiões têm barra, arena e fases.

### 2. Ecos de chefe para o mago do mal

**Problema:** transportar a IA completa de qualquer chefe é caríssimo e destrutivo.

**Porque rende:** preserva a fantasia de “levantei o chefe” usando animação e VFX já existentes.

**O que fazer:** cada chefe derrotado desbloqueia um eco espectral: aparece, executa um único ataque de assinatura e desaparece. Um eco equipado de cada vez.

### 3. Cinco chassis de comportamento para todas as raças

**Problema:** 30–36 fichas de inimigo ameaçam tornar-se 30 IAs.

**Porque rende:** rápido, pesado, distância, grupo e armadilha já existem como papéis.

**O que fazer:** construir cinco máquinas-base. Cada raça acrescenta silhueta, material, um ataque próprio e uma reacção ao ambiente. Variantes de bioma mudam uma decisão de combate, não apenas resistência.

### 4. Ritual de intensidade no descanso

**Problema:** o mundo esvazia e o conteúdo derrotado deixa de servir.

**Porque rende:** reutiliza zonas, inimigos e chefes sem novas malhas.

**O que fazer:** um ritual reinicia um bioma e altera composição, posições e uma sequência dos chefes. Recompensa cosméticos, ecos ou opções — nunca mais dano.

### 5. Memórias de chefe

**Problema:** um chefe caro é jogado uma vez por campanha.

**Porque rende:** o melhor conteúdo do jogo passa a ser também modo de treino e actividade co-op.

**O que fazer:** depois da vitória, o descanso permite repetir o chefe sem almas nem espólio. Acrescentar desafios opcionais: sem cura, sem invocados, parry obrigatório ou papéis trocados.

### 6. Armas modulares por família

**Problema:** 120 modelos completos continuam caros mesmo partilhando movimentos.

**Porque rende:** lâmina, guarda, cabo e material podem recombinar-se dentro da mesma família.

**O que fazer:** duas ou três silhuetas-base por família e conjuntos de materiais dos biomas. Produz variedade visual suficiente sem fingir que cada variante é uma arma nova.

### 7. Magia por verbos-base, não por feitiços isolados

**Problema:** dezenas de feitiços independentes multiplicam código e VFX.

**Porque rende:** projéctil, linha, cone, campo, marca, barreira, dreno e invocação cobrem quase todo o catálogo.

**O que fazer:** oito kernels testados; cada escola altera comportamento e leitura. Exemplo: a linha azul empurra, a vermelha perfura e incendeia cadáveres. Não gerar todas as combinações — escolher apenas as que produzem decisões distintas.

### 8. Usar o desaparecimento dos inimigos para transformar o mundo

**Problema:** após dez mortes, actualmente sobra apenas uma sala vazia.

**Porque rende:** a própria regra pode produzir progressão espacial sem inimigos novos.

**O que fazer:** a sala muda de estado: barricada destruída, atalho aberto, cadáveres que revelam uma pista, raça rival que ocupa o espaço ou perigo ambiental removido. O jogador vê que alterou o mundo.

### 9. Baralhos como trilhos de escolha

**Problema:** dez compras aleatórias garantidas ainda produzem muito lixo e duplicação de interface.

**Porque rende:** mantém surpresa e garantia com menos itens produzidos.

**O que fazer:** algumas cartas dão escolha entre duas opções da família; outras desbloqueiam receita visual ou variante de arte. Um único item passa a suportar várias builds.

Está bem: alvo técnico medido a quente, combate data-driven e retry curto são fundações úteis. Os 226 auto-testes passam; actualmente provam fidelidade à spec, incluindo as regras que precisam de ser mudadas.
tokens used
536 757
# 1. O que nos escapou

## P0 — necessários antes de aumentar conteúdo

### 1. Modelo de agressão para dois jogadores

**Problema:** existe o limite de dois atacantes e a alternância dos chefes, mas não há regras para um inimigo normal escolher e trocar de alvo: distância, dano recebido, cura, ressurreição, linha de visão ou tempo no mesmo alvo.

**Porque importa:** sem isto, o co-op oscila entre dois maus extremos: o inimigo persegue permanentemente um jogador enquanto o outro bate grátis, ou muda de alvo sem aviso. A Provocação agrava o problema ao impor um alvo em vez de influenciar a ameaça.

**O que fazer:** definir uma pontuação de ameaça, actualizada apenas entre sequências. Trocas de alvo devem ter aviso corporal, intervalo mínimo e peso para dano recente, proximidade, cura e ressurreição. Provocação aumenta ameaça; não bloqueia a IA durante quatro segundos.

### 2. Estado do baralho de espólio em co-op

**Problema:** o baralho é por tipo de inimigo, o espólio é instanciado, mas não existe dono, cursor, seed ou regra para quem entra tarde na sessão. [Baralho por tipo](../spec/43-estudo-espolio-inventario-mundo.md) *(linha 45)* e [cópia para cada jogador](../spec/18-progressao.md) *(linha 30)* não chegam.

**Porque importa:** um convidado que entra depois de cinco compras do baralho pode ficar sem cartas obrigatórias; um recomeço de ligação pode repetir uma compra; dois mundos podem discordar sobre o que já saiu.

**O que fazer:** baralho por personagem e arquétipo, persistido no save dessa personagem. Cada morte faz uma transacção atómica: escolhe a carta, grava o cursor, entrega o item. Entrar tarde nunca usa o progresso do outro jogador.

### 3. Local seguro para manchas de almas e corpos

**Problema:** o corpo e as almas ficam onde se morreu, mas há precipícios, água profunda, empurrões, falhas de navegação e limites do mundo. Não existe “último chão recuperável”.

**Porque importa:** perder almas porque a mancha nasceu dentro do vazio, debaixo de água ou fora da malha não é dificuldade; é erro de coordenadas a violar a Lei 1.

**O que fazer:** guardar continuamente o último ponto navegável, estável e acessível. Mortes em queda, água, kill volumes ou fora da navegação colocam corpo e mancha nesse ponto.

### 4. Recuperação da postura

**Problema:** inimigos perdem postura até zero e só a recuperam depois do cambaleio. Não existe atraso, regeneração ou decadência entre golpes — nem na spec nem no código.

**Porque importa:** qualquer jogador pode dar um golpe, fugir durante um minuto, repetir e acabar por obter um crítico gratuito. A barra invisível torna-se apenas um contador permanente.

**O que fazer:** por exemplo, postura começa a recuperar dois segundos depois do último dano, rapidamente nos inimigos leves e lentamente nos pesados; chefes recuperam por fase ou ao completar uma sequência. O estado deve ter feedback visual antes de partir.

### 5. Contrato de backstab, agarrão e derrube

**Problema:** existem backstabs, críticos de queda, agarrões e arremessos, mas faltam ângulo, distância, confirmação, invulnerabilidade, posição dos dois corpos, recuperação no chão e arbitragem de rede.

**Porque importa:** em co-op, dois jogadores podem iniciar críticos sobre o mesmo alvo; um agarrão junto a uma parede pode atravessar geometria; sem protecção ao levantar, o jogador pode ser agarrado novamente antes de recuperar. DS2/DS3 tratam críticos como estados coreografados, não como multiplicadores aplicados a um golpe normal.

**O que fazer:** escrever um contrato único de críticos: cone traseiro, distância máxima, alvo elegível, reserva exclusiva, alinhamento seguro, cancelamento, invulnerabilidade e regras para chefes. Acrescentar estado de derrube e levantamento com protecção curta.

### 6. Regras centrais de acumulação e troca de efeitos

**Problema:** dez anéis, nove peças, buffs, artes, infusões, efeitos de classe e magia podem alterar a mesma variável. Não existe ordem aditiva/multiplicativa, categorias exclusivas, tectos ou momento de activação.

**Porque importa:** o equilíbrio será decidido por acidentes de cálculo. Pior: a mochila abre em tempo real e permite equipar em combate, logo pode trocar-se resistência antes do impacto ou anéis entre cada acção.

**O que fazer:** uma taxonomia central: um efeito por categoria forte, restantes com rendimentos decrescentes; ordem de cálculo fixa; armadura e anéis só mudam em descanso. Em combate, apenas dois conjuntos de armas previamente equipados.

### 7. Reespecialização

**Problema:** está explicitamente adiada e a interface diz “sem redistribuição”. Com requisitos, soft caps, 100 níveis e catálogo largo, uma escolha inicial mal informada pode estragar dezenas de horas.

**Porque importa:** isso combate directamente as Leis 2 e 3. “Qualquer classe usa qualquer arma” vale pouco se experimentar essa arma exigir começar de novo. DS2 tinha Soul Vessels; DS3 tinha Rosaria.

**O que fazer:** classe como configuração inicial, não destino. Reespecialização no descanso, gratuita ou paga com um pequeno número de objectos encontrados por exploração — nunca farmáveis.

### 8. Reinício do mundo e NG+

**Problema:** o NG+ tem uma única linha de “especifica-se se for preciso”. O mundo, entretanto, fica progressivamente vazio.

**Porque importa:** foi importado o desaparecimento de inimigos de DS2 sem importar as válvulas de segurança que o acompanhavam: formas de suspender/reiniciar o despawn e NG+. Também impede testar builds e repetir chefes a dois.

**O que fazer:** definir já um ciclo completo: preserva personagem e equipamento; repõe inimigos, baralhos, corpos e chefes; muda composições e acrescenta padrões, nunca apenas PV e dano. Um ritual opcional pode reiniciar apenas um bioma.

### 9. Apresentação de esquiva e críticos em primeira pessoa

**Problema:** a spec reconhece o viewmodel duplicado, mas não diz o que a câmara faz durante rolamento, backstab, riposte, agarrão, queda e morte. Não há regra de horizonte, balanço ou redução de movimento.

**Porque importa:** rodar a câmara com um rolamento de 3,5–4,5 m provoca náusea; mantê-la parada sem feedback torna os i-frames ilegíveis. O problema não se resolve apenas com mais sons.

**O que fazer:** em primeira pessoa, apresentar o rolamento como passo baixo sem rotação da câmara; limitar inclinação; usar braços/arma para comunicar recuperação. Críticos devem usar uma câmara própria testada, ou ficar indisponíveis até essa apresentação existir.

### 10. Colisão entre jogadores e invocações

**Problema:** os mortos levantados atravessam o parceiro, mas nada define colisão jogador–jogador, invocado–invocado, portas estreitas ou quem pode empurrar quem.

**Porque importa:** dois jogadores, cinco inimigos e vários invocados numa passagem estreita podem bloquear a sessão inteira.

**O que fazer:** jogadores e invocados aliados não são sólidos entre si; inimigos mantêm colisão. Invocações devem ceder passagem, evitar portas e teleportar para um ponto seguro se ficarem presas.

# 2. Erros de desenho

### 1. Uma esquiva lateral resolve todo o jogo

**Problema:** a regra declara que, terminado o início da animação, o ataque está comprometido e “rolar para o lado funciona sempre”. O seguimento cai de 180°/s para 30°/s antes da hitbox. [Regras actuais](../spec/38-ataques-e-honestidade.md) *(linha 47)*.

**Porque importa:** transforma centenas de ataques numa pergunta com uma resposta universal. DS2/DS3 variam por golpe: alguns acompanham mais tempo, outros apanham rolamentos antecipados, outros pedem rolar para dentro, afastar ou simplesmente andar.

**O que fazer:** cada ataque declara momento de compromisso, curva de seguimento e vector de fuga. Nunca escrever “funciona sempre” para uma direcção de esquiva.

### 2. Hitboxes obrigatoriamente vivas apenas 3–6 frames

**Problema:** a regra “nunca mais” aplica-se a tudo. [Contrato actual](../spec/38-ataques-e-honestidade.md) *(linha 17)*.

**Porque importa:** não serve para investidas, corpos em movimento, sopros, feixes, poças, lâminas giratórias ou perigos persistentes. Vai obrigar a fingir que o efeito desapareceu enquanto visualmente continua activo.

**O que fazer:** separar contacto instantâneo, volume móvel e volume persistente. Cada alvo só pode ser atingido uma vez por passagem, ou a intervalos declarados. A hitbox deve acompanhar o que se vê, não um tecto universal.

### 3. O controlo de multidões cria filas e ainda permite stunlock

**Problema:** máximo de dois atacantes, ninguém activa no mesmo frame e intervalo mínimo de 0,20 s. O jogador, porém, fica em hit-stun durante 0,4–0,7 s.

**Porque importa:** o segundo golpe pode chegar durante a recuperação inevitável do primeiro. Ao mesmo tempo, os restantes inimigos orbitam visivelmente à espera da ficha, fazendo o sistema parecer uma fila.

**O que fazer:** o intervalo deve considerar hit-stun, knockdown e saída possível, não apenas relógio global. Permitir sobreposição de ameaças, mas garantir uma rota espacial de fuga.

### 4. Alternância fixa de alvo nos chefes

**Problema:** o chefe troca de alvo depois de cada sequência e evita repetir certos ataques. [Regra](../spec/16-chefes.md) *(linha 28)*.

**Porque importa:** os jogadores aprendem a vez: “agora é contigo, eu bato”. Isso não é leitura do chefe; é explorar o escalonador. DS2/DS3 usam atenção e posição suficientemente previsíveis para haver intenção, mas não uma alternância mecânica.

**O que fazer:** ameaça ponderada com cooldown de mudança, ataques específicos de troca e sinais claros de cabeça, tronco ou voz.

### 5. Cinco encontros de chefe em zonas de 2–3 minutos

**Problema:** 12 zonas de 2–3 minutos sustentam 36 chefes de campo, 12 subchefes e 12 guardiões. [Aritmética actual](../spec/49-biomas.md) *(linha 15)*.

**Porque importa:** há um encontro “de chefe” aproximadamente a cada 30–40 segundos de travessia limpa. Perde-se preparação, surpresa, escala e identidade. O descanso à vista de todas as portas elimina ainda a pressão de recursos antes de cada chefe.

**O que fazer:** um guardião verdadeiro por bioma. Transformar os 36 “chefes de campo” em elites/named encounters sem barra, arena ou produção exclusiva. Descansos devem servir arcos inteiros, não cada porta.

### 6. Reforço de armas e feitiços quebra frontalmente a Lei 2

**Problema:** armas sobem cerca de 10% por nível até +6; feitiços chegam a 175%, mais área, perfuração e lançamentos. [Armas](../spec/51-familias.md) *(linha 217)* e [feitiços](../spec/42-estudo-magia.md) *(linha 131)*.

**Porque importa:** DS2/DS3 usam reforço numérico, mas este projecto escreveu deliberadamente uma lei diferente. Aqui, uma arma não melhorada passa a ser a arma errada, criando gating por materiais.

**O que fazer:** melhoria desbloqueia postura, arte alternativa, alteração de escala, novo golpe ou conversão elemental. O dano-base deve variar pouco ou nada.

### 7. O mago do mal não está equilibrado; está autorizado a saltar o jogo

**Problema:** chefe portátil, número de invocados dependente apenas do hardware e Voto até +90% de dano. [Decisões](../spec/52-mago-do-mal.md) *(linha 268)*.

**Porque importa:** jogar com metade da vida não compensa acrescentar ao grupo um chefe com 60% dos PV, IA e dano. O outro jogador pode receber a atenção enquanto o exército produz dano. +90% é precisamente uma melhoria de números proibida pela Lei 2.

**O que fazer:** um invocado normal ou dois pequenos. Chefes derrotados dão um “eco” com um único ataque de assistência, não a IA completa. Voto deve trocar verbos — perfurar, espalhar fogo, consumir cadáver — não multiplicar dano.

### 8. Espelho é mais fácil do que o parry e escala com o inimigo

**Problema:** lança-se em 0,4 s, dura 1,5 s, anula o golpe e devolve todo o dano. Todos os ataques avisam pelo menos 0,5 s.

**Porque importa:** não exige timing real; pode ser lançado depois de ver quase qualquer aviso. Quanto mais forte o chefe, mais forte o feitiço, sem investimento do jogador.

**O que fazer:** janela activa de 0,15–0,20 s, recuperação falhada e reflexão limitada a projécteis ou convertida em dano de postura. O resultado deve escalar com o catalisador, não com o dano bruto do chefe.

### 9. A fórmula de estabilidade está invertida

**Problema:** `stamina_perdida = dano_de_stamina × (estabilidade / 100)`. [Fórmula](../spec/41-estudo-armas-e-golpes.md) *(linha 151)*. Quanto maior a estabilidade, mais stamina se perde.

**Porque importa:** o broquel de 50 é melhor a bloquear do que o escudo grande de 85. Além disso, o protótipo ainda usa 100% de absorção física, enquanto a regra nova fixa 90%.

**O que fazer:** `dano × (1 − estabilidade/100)` e um custo mínimo. Integrar a estabilidade concreta do escudo no código e eliminar a absorção universal antiga.

### 10. Dez anéis e nove slots de armadura

**Problema:** até dez dos 70 anéis equipados e nove slots de armadura. [Anéis](../spec/37-aneis-e-elementos.md) *(linha 9)* e [armadura](../spec/51-familias.md) *(linha 154)*.

**Porque importa:** DS2/DS3 usam quatro slots de anel e quatro peças de armadura. Com dez anéis, a oportunidade perdida por equipar um é pequena e a combinatória torna-se impossível de equilibrar. Com 30 peças distribuídas por nove slots há apenas 3,3 escolhas médias por slot; se forem 30 conjuntos, são 270 peças.

**O que fazer:** quatro anéis equipados e quatro slots visuais: cabeça, tronco, mãos, pernas. Capa, máscara e cinto podem ser cosméticos ou insígnias sem malha separada.

### 11. Cooldowns de 15–60 segundos convidam a esperar

**Problema:** habilidades de classe voltam com tempo real.

**Porque importa:** depois de cada encontro, a decisão óptima é ficar parado até Eco, Fúria ou Julgamento regressarem. DS2 usa stamina e lançamentos; DS3 usa stamina e FP. Nenhum pede ao jogador que espere um minuto no corredor.

**O que fazer:** recurso restaurado no descanso ou ganho durante combate por parry, postura, dano ou assistência ao parceiro. Cooldown curto apenas para impedir repetição imediata.

### 12. Alguns biomas e segredos fazem gating de build

**Problema:** o frio reduz stamina máxima, a lanterna ocupa a mão do escudo e há propostas de patamares só alcançáveis por rolamento longo ou inimigos que apenas veneno mata a tempo.

**Porque importa:** é gating de classe/equipamento com outro nome. Também altera a gramática central de stamina por bioma.

**O que fazer:** perigos devem mudar trajectos e timings, não remover verbos. O rolamento normal chega sempre; equipamento oferece rotas alternativas, nunca acesso exclusivo permanente.

### 13. Espólio enviesado pela classe contradiz “qualquer classe usa qualquer arma”

**Problema:** o jogo promete liberdade universal, mas favorece cartas ligadas à classe inicial.

**Porque importa:** o Guerreiro pode usar magia em teoria, mas recebe menos ferramentas para a experimentar. A liberdade fica na interface, não na economia.

**O que fazer:** enviesamento por lista de desejos ou famílias actualmente equipadas, escolhido pelo jogador. Nunca pela classe inicial.

### 14. “O chefe larga tudo” é uma recompensa sem decisão

**Problema:** chefes largam armadura, arma e feitiço de uma vez.

**Porque importa:** elimina antecipação, escolhas e identidade da recompensa; também despeja vários objectos e modelos por chefe. DS2/DS3 frequentemente convertem a vitória numa escolha posterior através da alma do chefe.

**O que fazer:** um item de assinatura garantido e um eco/token que escolhe entre duas ou três opções. Nada se perde para sempre; a escolha pode ser revista em NG+ ou numa memória do chefe.

### 15. O protocolo de teste declara certas mortes automaticamente correctas

**Problema:** morrer repetidamente para o mesmo ataque com stamina disponível é classificado como “falha certa; não se mexe em nada”. [Critério](../spec/28-testes.md) *(linha 18)*.

**Porque importa:** também é exactamente o sintoma de telegrafia ilegível, atraso inconsistente ou resposta mal ensinada.

**O que fazer:** rever vídeo e perguntar ao jogador o que leu. Só é falha justa se antecipou correctamente o tipo de ataque, escolheu a resposta errada e consegue explicar o erro depois.

# 3. Interacções perigosas

### 1. Vida da necromancia × frascos × cura do parceiro

**Problema:** o documento primeiro diz que PV gastos voltam com frascos; depois trata o custo como redução da vida máxima e como orçamento impossível de recuperar.

**Porque importa:** se os frascos curam o custo, o limite de invocações é falso. Se reduzem vida máxima, a regra inicial está errada. Cura remota do parceiro pode ainda contornar o preço.

**O que fazer:** todos estes custos reservam vida máxima. Vida reservada não é curável por frasco, dreno ou parceiro; regressa apenas quando o efeito termina.

### 2. Escola vermelha × marca vermelha de ataque não aparável

**Problema:** vermelho significa simultaneamente “magia aliada do Mateus”, “invocado aliado” e “este ataque inimigo não pode ser aparado”.

**Porque importa:** a cor deixa de transportar informação precisamente quando a arena estiver cheia.

**O que fazer:** reservar vermelho vivo/contorno pulsante para perigo não aparável. A escola do mal usa carmesim escuro com símbolo, forma e som próprios; nunca depender apenas da cor.

### 3. Invocado conserva espólio × necromancia

**Problema:** o inimigo levantado continua explicitamente a “largar obsidiana”.

**Porque importa:** matar, receber carta/almas, levantar e matar novamente pode duplicar recompensas e corpos.

**O que fazer:** qualquer entidade com flag `summoned` dá zero almas, zero cartas, zero cadáver reutilizável e zero progresso de reaparecimento.

### 4. Limite gráfico × poder da classe

**Problema:** preset alto permite oito invocados, médio cinco e baixo três.

**Porque importa:** uma opção gráfica altera directamente o poder da personagem. A máquina mais forte joga uma classe melhor; a máquina alvo joga a versão enfraquecida.

**O que fazer:** limite de desenho idêntico em todas as máquinas. Presets reduzem partículas, sombras, detalhe e frequência de animação à distância — nunca entidades funcionais.

### 5. Hit-stop local × segundo jogador

**Problema:** o hit-stop congela só atacante e alvo, não o mundo.

**Porque importa:** o parceiro pode bater gratuitamente num chefe congelado; em rede, clientes podem discordar sobre quando a hitbox e a postura avançam.

**O que fazer:** durante hit-stop, o par de actores fica congelado e não aceita novos impactos, ou o evento corre na autoridade e é apresentado aos clientes como desaceleração cosmética curta.

### 6. Ressurreição × escala dinâmica × alternância/Provocação

**Problema:** está proposta a redução de escala quando alguém morre; o parceiro pode ressuscitar; o chefe alterna alvo e pode ser provocado.

**Porque importa:** a vida máxima do chefe pode oscilar dentro da tentativa e os jogadores conseguem fabricar uma janela previsível de cinco segundos.

**O que fazer:** escala fixa à entrada da arena até ao fim da tentativa. Ressuscitar não altera PV do chefe. O acto de ressuscitar gera muita ameaça, mas não garante alvo.

### 7. Morte larga itens × parceiro apanha × reconexão

**Problema:** não está definido se os itens apanhados pertencem imediatamente ao parceiro, regressam ao ressuscitado ou ficam duplicados nos dois saves.

**Porque importa:** qualquer queda de ligação entre apanhar e ressuscitar pode perder ou duplicar equipamento único.

**O que fazer:** os itens ficam num depósito temporário associado à tentativa. Ressurreição devolve-os; expiração transfere-os de forma atómica ao parceiro; abandono da sessão resolve o depósito antes de gravar.

### 8. Equipamento em tempo real × resistências de bioma × 19 efeitos passivos

**Problema:** pode trocar-se armadura e anéis em combate, e cada bioma empurra um elemento dominante.

**Porque importa:** a melhor estratégia é jogar no menu: equipar defesa de fogo durante o ataque, voltar a dano na recuperação, trocar equipamento antes de uma queda.

**O que fazer:** armas preparadas podem alternar; armadura, anéis e catalisadores só mudam em descanso.

### 9. Máximo de dois agressores × Provocação × cura/área sem fogo amigo

**Problema:** um Tanque segura os dois únicos atacantes enquanto o parceiro lança área e cura à distância sem risco de atingir aliados.

**Porque importa:** elimina posicionamento e pressão sobre a retaguarda. O grupo transforma-se numa composição MMO com papéis rígidos.

**O que fazer:** Provocação influencia, não fixa. Inimigos de distância e controlo de espaço ignoram-na parcialmente; certos ataques obrigam os dois jogadores a reposicionar-se.

### 10. Dez anéis × nove peças × artes × buffs × melhoria de magia

**Problema:** cada camada parece controlável isoladamente; juntas geram centenas de modificadores e combinações.

**Porque importa:** será impossível saber se um chefe foi vencido por leitura ou por uma combinação não prevista. Os auto-testes não cobrem esta explosão combinatória.

**O que fazer:** reduzir slots e definir um orçamento de modificadores: no máximo quatro anéis, duas passivas de armadura activas e um buff temporário por categoria.

# 4. O risco real de escopo

### 1. Os 61 chefes não serão 61 chefes de qualidade souls-like

**Problema:** cada chefe pede pelo menos 8–11 ataques entre fases: perto de 500 ataques de chefe, antes de arenas, áudio, VFX, rede e testes.

**Porque importa:** dois agentes aceleram escrita e código; não produzem animação afinada, level design nem centenas de sessões de teste.

**O que fazer:** 13 chefes verdadeiros — um por bioma e o final. Doze subchefes reutilizam rigs com dois ataques novos. Os 36 “chefes de campo” passam a encontros nomeados com elites.

### 2. Primeira e terceira pessoa não ficarão igualmente boas

**Problema:** cada família precisa de animação corporal e viewmodel, mais duas câmaras, dois modelos de colisão visual e duas passagens completas de afinação.

**Porque importa:** oito famílias × onze ataques × duas perspectivas são pelo menos 176 clips, antes de artes, críticos e locomoção.

**O que fazer:** cortar primeiro o combate em primeira pessoa. Manter terceira pessoa como jogo; primeira pessoa pode voltar como modo de exploração quando tudo o resto estiver fechado.

### 3. As 120 armas não serão 120 armas mecanicamente distintas

**Problema:** a camada de dados é barata; malhas, mãos, clipping, som, VFX, arte, balanceamento e rede não são.

**Porque importa:** tentar diferenciá-las todas dará 120 variações superficiais.

**O que fazer:** lançar 16–24 armas: duas ou três por cada uma das oito famílias. A arte é da família, não de cada arma. Variantes mudam alcance, peso, escala e material.

### 4. Nove slots e 30 armaduras não fecham

**Problema:** 30 peças são poucas para nove slots; 30 conjuntos são 270 peças.

**Porque importa:** rigging modular, clipping de capas/ombros/cintos e combinações visuais tornam-se um projecto próprio.

**O que fazer:** quatro slots e 16–24 peças no primeiro jogo fechado. Efeitos adicionais vivem em anéis ou insígnias sem nova malha.

### 5. A magia larga mais necromancia completa não será equilibrada

**Problema:** a escola vermelha já tem cerca de 20 feitiços; faltam as restantes escolas, inimigos mágicos, upgrades, VFX e rede de invocações.

**Porque importa:** “o mesmo inimigo, agora aliado” exige facções, navegação, autoridade, colisões, recompensa, save e compatibilidade com todas as arenas.

**O que fazer:** 18–24 feitiços totais no primeiro jogo. Um único sistema de invocação normal e ecos simplificados de chefe.

### 6. Doze biomas profundos não cabem numa primeira versão

**Problema:** cada bioma promete dungeon, atalhos, segredos, cinco encontros de chefe, perigos, raças, materiais e arte própria.

**Porque importa:** se todos avançarem ao mesmo tempo, serão doze corredores com cores diferentes.

**O que fazer:** construir quatro biomas completos em sequência. Os restantes oito continuam aprovados como mapa de expansão, mas nenhum recebe conteúdo até o anterior passar combate, memória, navegação e co-op.

### 7. O co-op não deve ser cortado; deve ser estreitado

**Problema:** progresso individual, morte com transferência de itens, autoridade dividida, invocações e entrada tardia formam uma rede de persistência muito maior do que “dois amigos ligam-se”.

**Porque importa:** é o sistema central do projecto, mas também o mais capaz de consumir anos sozinho.

**O que fazer:** manter convite directo/Tailscale e dois jogadores. Na primeira versão, criar uma campanha da dupla com progresso comum enquanto jogam juntos; evitar resolver todos os estados possíveis de mundos divergentes.

**Ordem de corte com menor perda:** primeira pessoa → 48 chefes reclassificados → cinco slots de armadura → seis slots de anel → variantes de armas acima de 24 → feitiços acima de 24. Não cortar co-op, esquiva/parry/stamina, oito famílias nem a identidade dos 12 biomas.

# 5. Mais jogo por menos trabalho

### 1. Contar 61 encontros, não 61 produções de chefe

**Problema:** o número aprovado está a ser interpretado como 61 chefes completos.

**Porque rende:** um encontro nomeado pode ser memorável por espaço, composição e regra, sem rig ou IA exclusivos.

**O que fazer:** 13 guardiões, 12 campeões e 36 encontros nomeados. Só os guardiões têm barra, arena e fases.

### 2. Ecos de chefe para o mago do mal

**Problema:** transportar a IA completa de qualquer chefe é caríssimo e destrutivo.

**Porque rende:** preserva a fantasia de “levantei o chefe” usando animação e VFX já existentes.

**O que fazer:** cada chefe derrotado desbloqueia um eco espectral: aparece, executa um único ataque de assinatura e desaparece. Um eco equipado de cada vez.

### 3. Cinco chassis de comportamento para todas as raças

**Problema:** 30–36 fichas de inimigo ameaçam tornar-se 30 IAs.

**Porque rende:** rápido, pesado, distância, grupo e armadilha já existem como papéis.

**O que fazer:** construir cinco máquinas-base. Cada raça acrescenta silhueta, material, um ataque próprio e uma reacção ao ambiente. Variantes de bioma mudam uma decisão de combate, não apenas resistência.

### 4. Ritual de intensidade no descanso

**Problema:** o mundo esvazia e o conteúdo derrotado deixa de servir.

**Porque rende:** reutiliza zonas, inimigos e chefes sem novas malhas.

**O que fazer:** um ritual reinicia um bioma e altera composição, posições e uma sequência dos chefes. Recompensa cosméticos, ecos ou opções — nunca mais dano.

### 5. Memórias de chefe

**Problema:** um chefe caro é jogado uma vez por campanha.

**Porque rende:** o melhor conteúdo do jogo passa a ser também modo de treino e actividade co-op.

**O que fazer:** depois da vitória, o descanso permite repetir o chefe sem almas nem espólio. Acrescentar desafios opcionais: sem cura, sem invocados, parry obrigatório ou papéis trocados.

### 6. Armas modulares por família

**Problema:** 120 modelos completos continuam caros mesmo partilhando movimentos.

**Porque rende:** lâmina, guarda, cabo e material podem recombinar-se dentro da mesma família.

**O que fazer:** duas ou três silhuetas-base por família e conjuntos de materiais dos biomas. Produz variedade visual suficiente sem fingir que cada variante é uma arma nova.

### 7. Magia por verbos-base, não por feitiços isolados

**Problema:** dezenas de feitiços independentes multiplicam código e VFX.

**Porque rende:** projéctil, linha, cone, campo, marca, barreira, dreno e invocação cobrem quase todo o catálogo.

**O que fazer:** oito kernels testados; cada escola altera comportamento e leitura. Exemplo: a linha azul empurra, a vermelha perfura e incendeia cadáveres. Não gerar todas as combinações — escolher apenas as que produzem decisões distintas.

### 8. Usar o desaparecimento dos inimigos para transformar o mundo

**Problema:** após dez mortes, actualmente sobra apenas uma sala vazia.

**Porque rende:** a própria regra pode produzir progressão espacial sem inimigos novos.

**O que fazer:** a sala muda de estado: barricada destruída, atalho aberto, cadáveres que revelam uma pista, raça rival que ocupa o espaço ou perigo ambiental removido. O jogador vê que alterou o mundo.

### 9. Baralhos como trilhos de escolha

**Problema:** dez compras aleatórias garantidas ainda produzem muito lixo e duplicação de interface.

**Porque rende:** mantém surpresa e garantia com menos itens produzidos.

**O que fazer:** algumas cartas dão escolha entre duas opções da família; outras desbloqueiam receita visual ou variante de arte. Um único item passa a suportar várias builds.

Está bem: alvo técnico medido a quente, combate data-driven e retry curto são fundações úteis. Os 226 auto-testes passam; actualmente provam fidelidade à spec, incluindo as regras que precisam de ser mudadas.
