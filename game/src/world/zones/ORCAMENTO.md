# Orçamento de streaming por zona

> `[CODEX]` Proposta de implementação para a pergunta 50. Não substitui a
> `[TENSÃO]` entre `actual_e_vizinhas_imediatas` e `actual + transição`.

## Números antes do código

O contrato existente fixa **2,5 GiB (2 560 MiB)** como tecto verde do processo
e manda parar acima de **3,0 GiB**. A proposta já registada na pergunta 50
reserva no máximo **1,6 GiB (1 638 MiB)** para mundo/arte. Este carregador divide
o tecto assim:

| Parcela | Orçamento |
|---|---:|
| Mundo e arte residentes | 1 638 MiB |
| Runtime, jogadores, IA, UI, áudio e rede | 640 MiB |
| Margem contra picos, fragmentação e driver | 282 MiB |
| **Total** | **2 560 MiB** |

O Fojo tem cinco vizinhas; `actual + vizinhas` são **seis zonas**. Para essa
política caber na parcela de mundo, cada zona final só pode cobrar no máximo
**256 MiB incrementais**: `6 × 256 = 1 536 MiB`, deixando **102 MiB** da parcela
para recursos partilhados e para o pico de publicação. Dividir apenas o tecto
global daria 427 MiB por zona, mas esconderia que runtime, jogadores, áudio e UI
também precisam de memória.

Na política proposta `actual + transição`, há no máximo duas zonas publicadas.
O limite de admissão sobe para **512 MiB incrementais por zona**:
`2 × 512 = 1 024 MiB`, conservando **614 MiB** da parcela para recursos
partilhados e para carregar antes de descarregar. Uma zona acima do limite não
abre a bruma; a zona actual continua jogável e nunca aparece um ecrã de
carregamento durante a fuga.

`[CODEX]` **Recomendação:** usar `actual + transição` até seis zonas finais
provarem o orçamento de 256 MiB na máquina do Rico. **Razão:** é a única opção
que mantém sempre o lado de onde o jogador foge e o lado para onde corre sem
apostar 60% do tecto global em cinco saídas que ele não escolheu. **Alternativa
descartada por agora:** publicar todas as vizinhas; volta a ser válida se o pior
conjunto real medir `≤ 2 560 MiB` de working set quente, sem paginação, e cada
zona medir `≤ 256 MiB` incrementais.

## O que conta como memória de uma zona

O relatório conserva três medidas, sem fingir que são equivalentes:

- **working set do processo**, amostrado pelo sistema operativo: é o gate global;
- **memória estática do Godot**, disponível em builds de debug: delta de CPU;
- **memória de vídeo do renderer Mobile**: delta de texturas e buffers.

Para atribuição conservadora, `cobrança da zona = delta estático + delta de
vídeo`. O working set externo decide se o processo cabe; a soma serve para
encontrar qual zona queimou o orçamento. Recursos partilhados ficam na parcela
comum, não são cobrados seis vezes.

⚠️ Esta árvore corre num **i7-1255U/Iris Xe com 15,73 GiB**, confirmado em
01-08-2026; não é o PC alvo de 8 GiB do Rico. Os números finais só recebem
`[MEDIDO NO ALVO]` depois do mesmo benchmark correr no i5-1334U/8 GiB. Até lá,
o conjunto de seis zonas continua **`not_ready`**. Além disso, só Brumal existe
como nível: não é possível medir honestamente cinco zonas finais que ainda não
foram construídas.

## `[MEDIDO LOCAL]` — duas Brumal, Iris Xe / 15,73 GiB

Artefacto: [`medicao-streaming-local.json`](medicao-streaming-local.json),
Mobile/Vulkan, 1920×1080, preset médio, 01-08-2026.

| Fase | Working set | Pico | Estática Godot | Vídeo |
|---|---:|---:|---:|---:|
| Runtime sem zona | 481,1 MiB | 484,4 MiB | 56,9 MiB | 53,0 MiB |
| Uma Brumal | 550,2 MiB | 550,2 MiB | 69,8 MiB | 81,1 MiB |
| Candidata: segunda Brumal partilhada | 619,4 MiB | 619,4 MiB | 70,4 MiB | 101,1 MiB |
| Dois frames depois de rejeitar a candidata | 600,5 MiB | 629,6 MiB | 70,3 MiB | 81,1 MiB |

A primeira Brumal acrescentou **69,1 MiB de working set**; a candidata elevou o
working set observado mais **69,2 MiB**. A cobrança atribuível do carregador foi
**41 MiB** na primeira e **27 MiB** na cópia, porque os modelos/texturas são os
mesmos e a segunda reutiliza recursos. Isto prova que **este conteúdo actual
cabe com larga margem nesta máquina**; não prova cinco biomas finais com assets
distintos, nem o comportamento sob pressão de 8 GiB.

O bloqueio real foi tempo, não memória. A construção dinâmica da primeira zona
custou **300,273 ms** durante o arranque, onde uma espera inicial é permitida. A
segunda custou **113,004 ms** na publicação e a janela da transição teve
**p99/pior = 117,064 ms**. O gate de 20 ms recusou-a com
`publicacao_bloqueou_frame`; a bruma não abriu. Logo o adaptador de Brumal mede a
zona real, mas **não é uma forma apta de construir uma vizinha durante jogo**.
As zonas seguintes têm de chegar como `PackedScene` já autorada ou construir-se
incrementalmente antes da garganta; repetir `Greybox.build()` na aproximação é
uma alternativa medida e rejeitada.

## As quatro perguntas do fio solto

1. **Como é que o jogador usa isto?** Caminha para uma garganta com os controlos
   de movimento existentes. A aproximação inicia o carregamento; a bruma só
   deixa passar quando a zona local e, em co-op, a máquina mais lenta estão
   prontas. Não nasce tecla nova.
2. **Como se prova que funciona?** Um teste público conduz preparação, prontidão,
   travessia, regresso e descarga. O benchmark mede pico de working set, deltas
   estático/vídeo e frame time; gate: p99 `≤ 16,67 ms`, pior frame `≤ 20 ms`,
   processo `≤ 2 560 MiB` e zona dentro do limite da política.
3. **De onde vêm a arte e o som?** A bruma técnica e o seu bloqueio são
   sintetizados em código com primitivas do Godot. O carregador não inventa
   áudio; cada zona continua a usar os packs CC0 registados em `art/` e o
   director de áudio definido na spec quando esse conteúdo for promovido.
4. **Quanto custa na máquina do Rico?** O orçamento acima é executável, mas a
   medição desta implementação no PC de 8 GiB ainda não existe. Sem esse
   artefacto, a resposta honesta é **“limitado por código; não provado no alvo”**.
