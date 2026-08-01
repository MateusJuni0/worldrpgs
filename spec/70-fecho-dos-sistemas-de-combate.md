# 70 — Fecho dos sistemas de combate

> **Tarefa 4 · contrato canónico** (01-08-2026). Este documento fecha as correcções da auditoria comparativa e substitui, apenas nos pontos em que divergem, os números antigos dos [`01`](01-combate.md), [`11`](11-formulas.md), [`36`](36-fisica.md), [`39`](39-estudo-profundo.md), [`41`](41-estudo-armas-e-golpes.md), [`48`](48-arcos-bestas-escudos.md), [`51`](51-familias.md) e [`58`](58-fim-do-jogo-ciclos-e-a-curva.md). Os dados executáveis vivem em `game/data/`; uma divergência entre prosa e dados é erro.

O objectivo não é copiar Dark Souls. É conservar as quatro leis do WorldRPGs e corrigir mecanismos copiados pela metade: reacção sem compromisso, um soft cap universal, carga sem estado terminal e inimigos com sequências que só exigiam memória.

## 1. Números que passam a mandar

| Sistema | Contrato canónico | Porque muda |
|---|---|---|
| Parry | **8 f arranque · 8 f activos · 40 f recuperação**; falha total = **56 f** | 4 f deixavam aparar por reacção depois de ver o contacto. O arranque novo exige antecipar o compromisso sem encurtar a janela activa |
| Vida | quebras aos **20/50**: +22 PV/ponto até 20, +12 até 50, +4 depois | sobrevivência rende cedo e satura antes do dano |
| Stamina | quebras aos **20/40**: +2/ponto até 20, +1 até 40, +0,25 depois | a reserva cresce; regeneração e ferramentas nunca crescem — Lei 1 |
| Constituição | quebras aos **25/50**: +2 DEF/ponto até 25, +1 até 50, +0,5 depois | a defesa corporal já tem piso; a curva impede que Constituição linear seja a excepção dominante |
| Mana | quebra aos **35**: +4/ponto até 35, +1 depois | mantém a decisão já executável do catálogo de magia |
| Dano de atributo | quebras aos **40/60**: coeficiente 0,015 até 40, 0,0075 até 60, 0,00375 depois, antes do peso da escala | nível alto compra largura; empurrar um só atributo deixa de ser sempre a melhor resposta |
| Carga | atributo próprio, quebras aos **30/50/70**: +1,0/+0,5/+0,25/+0,10 de capacidade por ponto | a lista decidida pelos donos inclui Carga; não fica escondida em Constituição |
| Queda | 0 até **5 m**; dano progressivo de 5 a `<20 m`; **20 m mata sempre** | vida/equipamento não podem abrir atalhos topológicos |
| NG+ | ciclo 2: **PV ×1,30 · dano ×1,15**; ciclos 3–7 somam **+5% PV · +3% dano** por ciclo | separa margem de erro de letalidade; continua a ter tecto no ciclo 7 |

O máximo por atributo passa de 50 para **70**. O nível máximo continua 100 e cada nível continua a dar um ponto: chegar ao último breakpoint de um atributo é possível, chegar a todos não é. Todos os oito atributos começam a 8; a classe continua a distribuir exactamente +14 nos sete papéis já existentes e começa com Carga 8, portanto nenhum kit ou exemplo de nível 1 muda.

### 1.1. Carga equipada

| Banda | Fracção da capacidade | Recuperação extra da esquiva | Regen de stamina | Movimento |
|---|---:|---:|---:|---|
| Leve | `<30%` | +0 f | 40/s | normal |
| Média | `30–70%` | +4 f | **40/s** | normal |
| Pesada | `70–100%` | +8 f | **31/s** | normal |
| **Sobrecarregada** | `>100%` | não há esquiva | **26/s** | sem correr nem sprint; só marcha a 3 m/s |

Os i-frames continuam 5–23 quando existe esquiva. Peso nunca compra nem remove frames dentro de uma esquiva; acima de 100% remove a acção inteira e comunica `SOBRECARGA` antes de o jogador sair do inventário.

## 2. Empunhadura: uma mão e duas mãos deixam de ser conteúdo morto

**Como se usa:** `T` no teclado e `Y/triângulo` no comando, remapeável como `toggle_grip`. A mudança dura **12 frames**, não gasta stamina e é interrompida por dano. Só começa em `LIVRE`; o buffer não cancela outra acção.

| Estado | Mão secundária | Bloqueio/parry | Arte seleccionada |
|---|---|---|---|
| Uma mão | visível e activa | vem da arma secundária; se não houver, da principal | `arte_1mao` |
| Duas mãos | recolhida e inactiva | só se a arma principal o declarar | `arte_2maos` |

Armas que exigem duas mãos arrancam nesse estado. Trocar a empunhadura **não** dá multiplicador de dano nem requisitos implícitos: só muda o conjunto de movimentos/arte e a disponibilidade da mão secundária. Se uma futura arma quiser bónus numérico, terá de o declarar na própria ficha e trazer teste; não nasce como regra invisível.

## 3. Contra-ataque, instabilidade, defesa e ressalto

- `CONTRA_PERFURANTE` só existe quando um golpe de **perfuração** acerta durante os frames activos do alvo: ×1,30. Hastes usam ×1,40; a katana usa ×1,45 **apenas na estocada**. Corte, contusão, flecha sem tag e magia não recebem bónus.
- `INSTÁVEL` é um estado diferente e dá **+25%** de dano recebido. Só nasce de guarda quebrada, parry falhado, aterragem pesada ou de uma recuperação que o ataque declare. Não se acumula com outra instabilidade; pode acumular com contra-perfurante porque as perguntas são diferentes.
- O piso de dano corporal pertence a defesa/armadura. Não pertence ao bloqueio. Escudos seleccionados podem absorver **100% físico**, nunca 100% elemental; estabilidade máxima continua 85 e stamina zero abre sempre a guarda.
- Um varrimento activo testa parede antes do alvo. Parede primeiro cancela o dano e dá **12–18 f** de `RECOIL`, segundo a força de ressalto da arma.
- Escudos declaram deflexão leve/média/pesada. Um ataque que não vence essa classe ressalta com a mesma recuperação.
- Zonas `CORPO_DURO` fazem ressaltar golpes leves a uma mão; pesado, duas mãos, contusão e arte atravessam. É posicionamento, não vida extra.

Não há física avançada: uma varredura já necessária para o contacto devolve a primeira colisão e uma comparação de classes. Custo: uma consulta no ataque activo, nunca um teste contínuo em repouso.

## 4. Gramática inimiga que faltava

As fichas em `game/data/enemies.json` ligam cada situação a um ataque real. `gramatica` é uma lista de verbos, não um nome decorativo. A IA decide em fronteiras de ataque e só pode ler estado **visível**, distância, ângulo e linha de visão — nunca o botão carregado.

| Situação | Ficha ligada | Contrato executável |
|---|---|---|
| Atravessa escudo | `sea_orc_hookbearer/hook_pull` | `ATRAVESSA_ESCUDO`, 40% do bloqueio físico é penetrado; tell estreito da ponta curva |
| Esmaga guarda | `orc_brute/slam` | `ESMAGA_GUARDA`, custo de stamina ao bloquear ×2,5; continua bloqueável se a reserva chegar |
| Mesmo aviso, duas largadas | `vorgar/overhead_crush` | largadas legais no f56 e f72; a tardia muda som e eleva o gume no f64, antes dos activos; escolha ponderada 80/20, nunca depois de ler o input |
| Combo condicional | `orc_spearman/double_thrust` | no fim, perto e à frente → `sweep_low`; nas costas → rodar e terminar; longe → terminar. Uma avaliação, sem seguir durante o activo |
| Falsa recuperação | `skeleton_swordsman/bone_rattle` | extensão rara `rib_sweep` se o jogador entra; a guarda óssea fica alta na falsa janela e baixa na recuperação verdadeira |
| Castigo de cura | `orc_spearman/closing_lunge` | lê `USING_ITEM` visível com linha de visão e **9 f/150 ms** de latência; nunca lê `use_item` |
| Fingir morte | `ancient_skeleton/black_cut` | cadáver pré-colocado, espada agarrada e pulso violeta audível; a 2,6 m levanta e entra no corte; acontece sempre naquela colocação, uma vez |
| Corpo duro | `minotaur_quarry_bull/stone_stomp` | chifres e placas de granito usam `CORPO_DURO`; as excepções são as da §3 |

### 4.1. Regras de justiça

1. A variação de largada nunca move os activos sem um segundo sinal acessível.
2. A falsa recuperação tem uma pose aprendível; “raro” não significa aleatório sem leitura.
3. O castigo de cura reage à animação replicada, logo host e convidado vêem a mesma causa.
4. Fingir morte é propriedade da colocação guardada no mapa; recarregar não sorteia cadáveres.
5. Um inimigo comum usa no máximo uma destas excepções. Elites podem usar duas; chefes, até quatro, desde que cada uma tenha sinal próprio.

## 5. Outros mecanismos corrigidos pela auditoria

- `Fôlego Roubado` e efeitos semelhantes deixam de referir “stamina inimiga”, que nunca foi definida. Aplicam dano de postura/guarda e devolvem stamina ao jogador proporcional ao dano de postura realmente causado.
- A ressurreição em co-op tem **uma utilização partilhada por tentativa/descanso**. Mantém 5–7 s, 50% de vida e os frascos que o jogador tinha; sem carga partilhada, a alternância de mortes dava vidas ilimitadas.
- A Brasa é selector de desafio, não motor de farm: uma por zona e ciclo, recompensa única/colocada, não comprável; uma limpeza que já esgotou recompensa dá zero almas e não repõe cartas tiradas.
- Os ciclos guardam o índice 1–7 por zona. Uma Brasa sobe exactamente uma zona em um ciclo, aplica os multiplicadores dessa zona e não altera o resto do mundo.

## 6. As quatro perguntas do fio solto

| Pergunta | Resposta deste pacote |
|---|---|
| Como é que o jogador usa isto? | Empunhadura em `T`/`Y`; parry, carga e bloqueio usam os comandos existentes; a gramática é encontrada ao ler e responder às fichas inimigas |
| Como é que se prova? | auto-testes contam 8/8/40, curvas nos breakpoints, quatro bandas de carga, contrato de empunhadura, tags de bloqueio e as oito ligações do bestiário; a prova jogada da leitura continua no M2 |
| De onde vêm arte e som? | as fichas reutilizam modelo, arma, `descricao_visual`, `som_anuncio` e `sinal_visual_equivalente` já fechados no catálogo WP6; nenhuma situação pede asset novo para existir |
| Quanto custa na máquina do Rico? | metadados em JSON; uma decisão no fim de golpe; uma consulta de linha de visão no evento de cura; uma varredura nos frames activos. Zero polling adicional em repouso e zero material/partícula nova |

## 7. Fronteira honesta

O contrato, dados e invariantes ficam fechados aqui. O protótipo executa já a empunhadura, o arranque do parry, a penetração de escudo e o esmagamento de guarda. O grafo completo de ramos, as poses animadas, o ressalto por geometria e a sincronização co-op pertencem ao M2/WP10: estão especificados até ao evento e ao campo, mas só se podem provar como experiência quando existirem personagens animados. Isso é construção futura conhecida, não decisão de design em aberto.

Este documento não decide nenhuma tensão reservada aos donos.
