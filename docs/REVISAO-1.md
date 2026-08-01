# Revisão 1 de 3 — coerência interna

**01-08-2026 · Codex · passagem independente sobre números, regras, revogações, promessas e fichas.**

## Veredicto

Esta revisão **não passou a spec a verde**. Encontrou contradições objectivas em contratos correntes, regras revogadas ainda apresentadas como activas, estados falsos nas portas de entrada e promessas que não têm dados ou runtime para as garantir.

O núcleo executável ficou substancialmente mais coerente: o guarda passa e **8435/8435** auto-testes passam. Isso não fecha a spec inteira. Permanecem **cinco lacunas 🔴** em [`LACUNAS.md`](../LACUNAS.md) e **quatro tensões novas** nas perguntas 41–44 de [`99-perguntas-abertas.md`](../spec/99-perguntas-abertas.md).

## O que foi revisto

- Li primeiro as quatro autoridades obrigatórias: [`CODEX-CONTEXTO`](../prompts/CODEX-CONTEXTO.md), [`ESTADO`](../ESTADO.md), [`LACUNAS`](../LACUNAS.md) e [`MAPA`](../MAPA.md), e cruzei-as com [`DECISOES`](../DECISOES.md).
- Varri os **75 documentos de `spec/`**, as restantes portas de entrada e auditorias, os **17 JSON** de `game/data/` e os **18 GDScript** do protótipo.
- Comparei números repetidos e regras absolutas com os dados carregados e com os auto-testes. Documentos históricos só foram alterados quando não estavam claramente marcados como históricos ou ainda podiam ser usados como instrução corrente.
- Auditei as colunas obrigatórias dos catálogos e procurei células vazias, “não dá”, IDs sem destino e promessas universais sem campo executável.

O guarda de coerência do fecho analisou **125 ficheiros Markdown** sem erros. Os dois auto-testes acrescentados por esta revisão cobrem o frasco e a faixa de canalização da ressurreição; por isso a contagem subiu de 8433 para 8435.

## Contradições objectivas corrigidas

### Números

1. **Esquiva:** frames 5–23 inclusivos são **19 ticks**, isto é, **317 ms a 60 Hz**; não 18 ticks/300 ms. Spec, dados e prova dizem agora a mesma coisa.
2. **Queda:** zero dano até 5 m, progressão antes de 20 m e morte absoluta aos 20 m. Foram retirados limiares antigos que permitiam sobreviver por Vida.
3. **Travessia curta:** o passo automático corrente é **0,45 m**, não valores antigos que abriam topologia por atributo.
4. **Progressão:** as curvas próprias de Vida, Stamina, Constituição e Carga substituem o soft cap universal; as faixas de carga e a sobrecarga voltaram a coincidir com os dados.
5. **NG+:** `+1` usa ×1,30 PV/×1,15 dano; depois soma +0,05/+0,03 até `+7`. Retratos com uma percentagem única foram corrigidos.
6. **Defesa:** contra-ataque só beneficia perfuração; um escudo de 100% físico bloqueia 100% fora do piso corporal. Textos que generalizavam ambos foram corrigidos.
7. **Frasco:** **3 usos, 40% de PV, 1,2 s e 50% de movimento**. Restavam 1,0 s e 40% de movimento noutros documentos.
8. **Parry:** **8/8/40 frames**, não arranque de 4. **Ressurreição:** canalização sorteada entre **5–7 s** dentro de uma janela de 60 s, não 5 s fixos.
9. **Retrato do protótipo:** há **17 sons sintetizados** e **8 atributos**, não 12 e 6.
10. **Escala de conteúdo:** o total corrente é **61 encontros de chefe** — 13 chefes, 12 subchefes e 36 nomeados — e o catálogo contém **68 armaduras**, não o alvo decidido de ~30. O primeiro número foi corrigido; o segundo foi exposto como tensão, não legitimado.

### Regras e versões revogadas

- **Magia:** slots/cargas e o bolo partilhado foram retirados das instruções correntes. O mapa único é mana sem regeneração passiva, oito favoritos, `F`/roda para seleccionar, `C` para lançar e `M` para meditar. Consumíveis continuam na hotbar `1`–`5` e `R` usa o seleccionado.
- **Descanso:** é por arco, com descanso antes do guardião; não em cada porta de chefe.
- **Morte:** perde-se a mancha de almas recuperável. Textos e toast que prometiam “nada se perde” deixaram de o fazer onde o produtor de HP zero ainda não está ligado.
- **Inventário:** a mochila é infinita, navegada por filtros/favoritos; a limitação e o baú antigos foram retirados do briefing-raiz.
- **Magia inimiga:** `Fôlego Roubado` e `Chama Faminta` deixaram de depender de uma stamina inimiga inexistente. O primeiro tem postura/guarda executável; a segunda foi reaberta porque ainda não tem magnitudes.
- **Estado do projecto:** o `README` já não diz simultaneamente “spec completa” e “engine por decidir”; Godot 4.7.1/renderer Mobile e as cinco lacunas estão explícitos. O guia dos agentes já não chama actual ao prompt histórico `TERMINAR-A-SPEC`.

### Regras que se contradiziam

- **“Fugir funciona sempre” vs. sobrecarga:** acima de 100% de carga não há corrida nem esquiva. A promessa foi qualificada com essa excepção explícita; não foi apagado o custo decidido da sobrecarga.
- **“Fugir funciona sempre” vs. fichas inimigas:** só **15/33** tipos comuns declaram velocidade de perseguição. Nos outros 18, a promessa não pode ser provada. Isto ficou 🔴 em vez de se inventarem velocidades.
- **Hotbar única para consumíveis e magia vs. favoritos:** os contratos antigos ainda punham ambos em `1`–`5`+roda. O mapa corrente foi unificado sem criar comandos novos.

## Promessas sem mecanismo

As cinco lacunas vermelhas são promessas que pareciam fechadas e não estão:

1. **12 feitiços** prometem efeitos sem potência, duração, expiração ou semântica suficiente para implementação.
2. **53/53 árvores de melhoria de feitiço** passam validação sintáctica, mas os `+1` são redução numérica de mana e os níveis seguintes reutilizam moldes incompatíveis com várias fichas.
3. **Escudos elementais** foram decididos, mas os dados só têm físico/estabilidade por família e uma absorção mágica global.
4. **18/33 inimigos comuns** não têm velocidade de perseguição; não existe prova da fuga universal.
5. **Cinco acessórios obrigatórios de espólio** só existem como IDs em cartas: quatro sinos e uma lanterna. Não há catálogo, ficha ou cliente de entrega, e o teste ignorava a categoria desconhecida.

Havia ainda uma promessa factual falsa: os tempos das 12 zonas eram chamados “medidos”. Só Brumal existe, e o greybox actual mede 2–3 min; os 8–12 min das restantes zonas são **orçamentos de travessia**, não medições. A linguagem foi corrigida.

## Fichas obrigatórias

Não encontrei colunas obrigatórias literalmente vazias nem fichas correntes a dizer que um ataque “não dá” para evitar responder. Os testes continuam a exigir, entre outros, `Fatia 1?`, descrição visual, forma de entrega, contacto, vector/método de fuga, fases, aviso e janela de castigo.

Isso não equivale a fichas completas. A revisão encontrou três falhas semânticas que a validação de presença não via: os 12 feitiços, as 18 velocidades de perseguição e os cinco acessórios fantasma. A melhoria dos 53 feitiços é o caso mais claro de **colunas preenchidas com conteúdo que não cumpre o contrato**.

## As quatro leis

### Lei 1 — habilidade acima de nível

A queda aos 20 m voltou a ser absoluta, o passo automático deixou de depender de valores antigos e a fuga já não é apresentada como universal sem ressalva. A mancha de almas ainda precisa de ser ligada ao produtor de HP zero, mas a UI deixou de prometer uma segurança inexistente.

### Lei 2 — melhorias dão verbos, não números

É a lei com risco real. As melhorias dos 53 feitiços e o Voto de Sangue entram directamente em tensão com ela. Não os reescrevi como decisão. Bónus de origem de classe, NG+ e valores condicionais de anéis foram verificados separadamente: são identidade inicial, escala de dificuldade ou condições com verbo, não níveis de melhoria vertical. Não encontrei anéis duplicados cujo único efeito seja “o mesmo, mas +X%”.

### Lei 3 — qualquer classe pega em qualquer arma

Não encontrei bloqueio de equipamento contraditório. O runtime conserva o uso abaixo do requisito com penalização ×0,6, e os testes provam que a arma continua utilizável.

### Lei 4 — a máquina alvo manda

Foi retirada a falsa linguagem de medição das 11 zonas inexistentes. O teste quente do greybox e a ressalva de que oito esqueletos animados não provam a cena final continuam separados. Não encontrei uma nova promessa de desempenho final apresentada como medição actual.

## O que ficou para os donos decidirem

Não tomei nenhuma destas decisões:

- **Pergunta 41:** como preservar os eixos decididos “força, área, lançamentos” sem transformar melhorias em números proibidos. **Recomendação:** cada aumento leva uma perda ou muda um verbo; remover a redução incondicional de mana.
- **Pergunta 42:** Voto de Sangue decidido como +30/+60/+90% ou versão posterior por verbos. **Recomendação:** aprovar os verbos perfurar/chão a arder/mortos explodem, preservando custo de vida e fantasia sem quebrar a Lei 2.
- **Pergunta 43:** afinidade elemental do escudo por família ou instância. **Recomendação:** família define comportamento físico; cada escudo define o mapa elemental.
- **Pergunta 44:** alvo decidido de ~30 armaduras ou catálogo corrente de 68. **Recomendação:** produzir apenas as 11 da Fatia 1 e consolidar famílias antes de aceitar 68.

## Rasto dos commits

Cada família foi validada com o guarda e o auto-teste antes do commit:

| Commit | Família |
|---|---|
| `89de947` | i-frames: 19 ticks/317 ms |
| `1f57e71` | números revogados nos contratos activos |
| `961a28e` | regras e retratos revogados |
| `d7a4bf4` | lacunas sem mecanismo e primeiras tensões |
| `a123607` | frasco 1,2 s/50% |
| `2a67441` | regras revogadas nos documentos correntes |
| `763dcb0` | contagens do protótipo |
| `ec26eb2` | morte sem perda prometida pela UI |
| `e007932` | estados falsamente abertos |
| `7eb0ed3` | tensão 30/68 armaduras |
| `359bd19` | parry e ressurreição |
| `eea9934` | morte sem perda em retratos antigos |
| `be3b1a5` | fuga sem velocidade em 18 fichas |
| `8cb9c94` | cinco acessórios sem catálogo |
| `bff626b` | orçamento de travessia vs. medição |
| `24f7108` | índices que escondiam lacunas vermelhas |
| `bacc88b` | stamina inimiga ainda citada pela magia |
| `b435edc` | estado falso nas portas de entrada |
| `c046c5f` | comandos de magia vs. hotbar |

## Quanto confio agora

**Confiança global: 7/10.** Antes desta passagem, o verde dos testes dava uma confiança falsa porque várias asserções só verificavam presença ou repetiam o número errado.

- **Núcleo executável da Fatia 1: 8,5/10.** Combate, frasco, morte contratada, progressão, comandos e dados carregados estão muito mais alinhados e têm regressões concretas.
- **Catálogos enquanto estrutura: 8/10.** As colunas existem e a maioria dos IDs resolve, mas a revisão provou que “preenchido” não significa “implementável”.
- **Conteúdo futuro de magia, escudos, espólio e perseguição: 5/10.** As cinco lacunas vermelhas atingem precisamente garantias que o jogo faria em runtime.

Portanto, confio que a spec já distingue melhor facto, orçamento e decisão. **Não confio ainda nela como contrato global pronto para implementação sem perguntas.** Fechar as cinco lacunas e as perguntas 41–44 é condição para essa confiança subir de forma honesta.

Não foi feito push.
