# LACUNAS — o que falta, e ninguém está a fazer

**Actualizado: 31-07-2026.** Mantido pelo **Claude**. É a lista de tudo o que foi identificado como buraco e **ainda não tem dono**.

> **Porque existe:** as lacunas que eu encontro a rever viviam em **comentários de PR**. Um comentário lê-se uma vez e desaparece — e uma lacuna esquecida é uma lacuna que se descobre no fim, quando custa dez vezes mais.
>
> ⭐ **A regra:** encontrei uma lacuna → escrevo-a aqui **no mesmo acto**. Quando alguém a resolve, risca-se com o commit ao lado.

**Legenda:** 🔴 trava alguma coisa · 🟠 devia entrar na volta indicada · 🔵 quando houver tempo · ⏳ é dos donos, não dos agentes

---

## 🔴 Travam

**Da auditoria independente do Codex** ([`docs/AUDITORIA-CODEX-2026-08-01.md`](docs/AUDITORIA-CODEX-2026-08-01.md), 01-08). ⚠️ **As quatro primeiras são erros meus, não do Fable.**

| | Lacuna | Origem |
|---|---|---|
| ✅ | ~~"Rolar para o lado funciona sempre"~~ **CORRIGIDO 01-08** — cada ataque declara **momento de compromisso, curva de seguimento e vector de fuga**, escolhido de uma lista de 9. E o vector **tem de ser legível na animação** | [`38`](spec/38-ataques-e-honestidade.md) §2b |
| ✅ | ~~A hitbox de 3–6 frames é regra de espada aplicada a tudo~~ **CORRIGIDO 01-08** — três tipos de contacto: **instantâneo** (3–6 frames), **volume móvel** (uma vez por passagem), **volume persistente** (dano por intervalos declarados). A regra unificadora: *a hitbox vive exactamente enquanto o efeito se vê* | [`38`](spec/38-ataques-e-honestidade.md) §1b |
| 🔴 | ⭐ **A fórmula da estabilidade estava invertida** — eu escrevi `dano × (estabilidade/100)`, o que fazia o broquel de 50 bloquear melhor que o escudo grande de 85. ✅ **CORRIGIDO 01-08** para `× (1 − estabilidade/100)` | [`41`](spec/41-estudo-armas-e-golpes.md) §6 |
| ✅ | ~~O espelho é mais fácil do que o parry~~ **RESOLVIDO 01-08** — janela de 0,25 s, recuperação se falhar, escala pelo instrumento, e recompensa maior quando acerta | [`53`](spec/53-chefes-ritmo-e-o-mago-forte.md) §4 |
| ✅ | ~~O intervalo de 0,20 s entre atacantes não chega~~ **CORRIGIDO 01-08** — conta-se a partir de **quando o jogador pode agir**, não do relógio. E o tecto de 2 agressores passa a garantir **rota de fuga** em vez de um número | [`38`](spec/38-ataques-e-honestidade.md) §3 |
| 🔴 | ⚠️ **Melhoria de armas (+10%/nível) é a Lei 2 quebrada** — números, não opções. *(A dos feitiços foi resolvida: o Voto passou a trocar verbos, [`53`](spec/53-chefes-ritmo-e-o-mago-forte.md) §4)* | [`51`](spec/51-familias.md) |
| ✅ | ~~61 chefes = um encontro a cada 30–40 s~~ **DECIDIDO 01-08 pelo Mateus** — 13 verdadeiros + 12 subchefes + ~36 nomeados, travessia de 8–12 min, e **24–36 portas de história abertas** para crescer no futuro | [`53`](spec/53-chefes-ritmo-e-o-mago-forte.md) |
| ⏳ | ⭐ **Ordem de corte com menor perda**, se for preciso cortar: 1.ª pessoa → 48 chefes reclassificados → 5 slots de armadura → 6 slots de anel → armas acima de 24 → feitiços acima de 24. **Não cortar:** co-op, esquiva/parry/stamina, as 8 famílias, a identidade dos 12 biomas | auditoria §4 |

---

## 🟠 Para as voltas que aí vêm

### Volta 2 — fichas de raça 🔨 *em curso*

| | Lacuna | Origem |
|---|---|---|
| 🟠 | ⚠️ **A linha "porque está neste bioma"** é a única que liga a raça ao mapa, e é a que se salta. A resposta tem de sair de uma ficha de bioma já escrita | [`46`](spec/46-coerencia-bioma-raca-item.md) §5 |
| 🟠 | **Em que biomas cada raça aparece, e o que muda em cada variante** — e a variante tem de mudar **como se luta**, não só a cor | [`46`](spec/46-coerencia-bioma-raca-item.md) §7 |
| 🟠 | ⚠️ **Santuário Branco e A Raiz** são os dois biomas mais fáceis de deixar sem raça própria. Sem habitante próprio são cenários, não lugares | revisão do PR #14 |
| 🟠 | **Mímicos e Minotauros** estão na lista de raças, mas um é armadilha e o outro é subchefe. A ficha de 8 linhas não lhes assenta | [`15`](spec/15-inimigos.md) |

### Volta 3 — armas e armaduras

| | Lacuna | Origem |
|---|---|---|
| 🟠 | **Os 7 golpes por declarar** — cadeia de leves, leve→pesado, em corrida, a rolar, a saltar, de cima, empurrão | [`41`](spec/41-estudo-armas-e-golpes.md) §1 |
| 🟠 | **Melhoria de armas** — reforço e infusão. Nunca foi escrita | [`35`](spec/35-estudo-referencia.md) §6 |
| 🟠 | **Estados alterados** — veneno, sangramento, queimadura. Nunca mencionados | [`35`](spec/35-estudo-referencia.md) §5 |
| 🟠 | **Requisitos de atributo** — quanto é "não és tu que a usas" sem proibir (Lei 3) | [`41`](spec/41-estudo-armas-e-golpes.md) |
| 🟠 | **Duas armas ao mesmo tempo, uma em cada mão** — existe no nosso jogo? | [`41`](spec/41-estudo-armas-e-golpes.md) |
| 🔵 | **Como a mira do arco comunica a queda da flecha** — sem isso o jogador aprende "o arco falha às vezes" | [`36`](spec/36-fisica.md) §3 |

### Volta 4 — magia

⭐ **A forma de entrega é obrigatória em toda a ficha** — [`55-formas-de-feitico.md`](spec/55-formas-de-feitico.md). 12 formas, e o dano é o que menos as separa.

| | Lacuna | Origem |
|---|---|---|
| 🟠 | ⭐ **Três formas que nos faltam:** perseguidor, chuva, e forma de arma (golpe de corpo a corpo feito de magia — resolve o "mago frágil ao perto" melhor que a besta) | [`55`](spec/55-formas-de-feitico.md) §5 |
| 🟠 | ⚠️ **O traçado das zonas passa a afectar a magia** — tectos, corredores, terreno partido. A chuva morre debaixo de tecto | [`55`](spec/55-formas-de-feitico.md) §2 |

⭐ **A escola vermelha já está desenhada** — [`52-mago-do-mal.md`](spec/52-mago-do-mal.md), feita pelo Claude a pedido do Mateus (é o personagem dele). O WP4 herda-a; **não a reescreve.**

| | Lacuna | Origem |
|---|---|---|
| ⏳ | ~~As 6 perguntas do mago do mal~~ ✅ **4 respondidas 31-07** (chefe portátil · sem tecto de invocados · Voto empilha 3× · instrumento livre). Faltam: que feitiços cortar, e o tecto de máquina | [`52`](spec/52-mago-do-mal.md) §11 |
| 🟠 | **Quem manda nos invocados em co-op?** *(proposta: quem os levantou)* | [`50`](spec/52-mago-do-mal.md) §9 |
| 🟠 | **Inimigos que lançam magia usam as mesmas regras?** *(proposta: sim, incluindo ser interrompíveis)* | [`42`](spec/42-estudo-magia.md), [`48`](spec/48-arcos-bestas-escudos.md) |
| 🟠 | **Quantos feitiços na fatia 1** *(proposta: 3 — dano, cura, utilidade)* | [`42`](spec/42-estudo-magia.md) |
| 🟠 | **O material de melhoria de feitiço é o mesmo das armas, ou outro?** | [`42`](spec/42-estudo-magia.md) §6 |

### Volta 5 — bestiário

| | Lacuna | Origem |
|---|---|---|
| 🟠 | ⚠️ **O som que anuncia cada ataque** — obrigatório pela regra da 1.ª pessoa, e continua por escrever em todas as fichas | [`38`](spec/38-ataques-e-honestidade.md) §3 |
| 🟠 | **Massa de cada inimigo**, para o empurrão | [`36`](spec/36-fisica.md) §4 |
| 🟠 | **Almas por inimigo, e o total por zona** — com o tecto de 10 reaparições, cada zona tem orçamento fixo | [`40`](spec/40-decisoes-espolio-magia-inventario.md) §2 |

### Volta 7 — chefes

| | Lacuna | Origem |
|---|---|---|
| 🟠 | ⚠️ **Desenho de arena de chefe** — tamanho, obstáculos, onde o jogador se refugia. **Sem cobertura nenhuma** | [`48`](spec/48-arcos-bestas-escudos.md) |
| 🟠 | **Um subchefe pode ser fugido de vez, ou reaparece?** | [`46`](spec/46-coerencia-bioma-raca-item.md) §6 |
| 🟠 | **Arenas com precipícios** — quais, e como se sinaliza o bordo | [`36`](spec/36-fisica.md) §4 |

### Volta 8 — sistemas

| | Lacuna | Origem |
|---|---|---|
| 🟠 | **A curva de nível é linear, devia ser cúbica** · **"XP" devia ser "almas"** | [`35`](spec/35-estudo-referencia.md) §3 |
| 🟠 | ⚠️ **Sistema de saves** — ⭐ **agora com TRÊS clientes à espera**: progresso, inventário e o **mapa** ([`57`](spec/57-mapa-e-minimapa.md) §6). Continua sem uma linha na spec |
| 🟠 | ⚠️ **A leitura do mapa tem de ser decidida ANTES de o WP8 traçar as zonas** — senão há zonas impossíveis de mapear | [`57`](spec/57-mapa-e-minimapa.md) §5 |
| 🟠 | ⚠️ **Texturas, modelos 3D e som: ZERO.** Os packs CC0 do [`22`](spec/22-assets.md) nunca foram descarregados nem importados. **Nenhuma volta cobre isto** |
| 🟠 | ~~Sistema de saves~~ *(linha antiga)* — onde vive o progresso, e como funciona a dois. **Sem cobertura** | [`48`](spec/48-arcos-bestas-escudos.md) |
| 🟠 | **Lock-on em 1.ª pessoa** — duas opções propostas, nenhuma escolhida | [`29`](spec/29-perspectiva.md) |
| 🟠 | **A cura à distância funciona com que latência?** | [`42`](spec/42-estudo-magia.md) |

### Volta 9 — mundo

| | Lacuna | Origem |
|---|---|---|
| 🟠 | **Nadar, escalar, saltar: existem?** Nunca foram mencionados | [`36`](spec/36-fisica.md) |
| 🟠 | ⚠️ **O traçado das zonas e o orçamento de memória desenham-se juntos** — um atalho entre zonas distantes obriga a ter as duas prontas | [`43`](spec/43-estudo-espolio-inventario-mundo.md) §6 |

---

## 🔵 Quando houver tempo

| | Lacuna | Origem |
|---|---|---|
| 🔵 | ⚠️ **A conversão visual, passos 1–3** — luz, névoa e gradação de cor. **Custa horas e vale mais do que trocar modelos** | [`47`](spec/47-do-greybox-ao-visual.md) §4 |
| 🔵 | **Capturas em todo o marco** — o critério que impede o visual de parar sem ninguém dar por isso | [`47`](spec/47-do-greybox-ao-visual.md) §5 |
| 🔵 | **Os 11 documentos antigos não trazem tabela `eles·nós·diferença` nem citam fontes** | [`31`](spec/31-referencias.md) |
| 🔵 | **Economia de vendedores** — a loja vende conveniência, nunca poder | [`39`](spec/39-estudo-profundo.md) §11 |
| 🔵 | **Validar as constantes de física a jogar** (marco 2) | [`36`](spec/36-fisica.md) |

---

## ⏳ Dos donos — não são para os agentes resolverem

Estão no [`99-perguntas-abertas.md`](spec/99-perguntas-abertas.md). As três que mais mudam o jogo:

| # | | |
|---|---|---|
| **28** | ⚠️ Se a magia faz tudo, como é que o mago não é a classe correcta? | cinco travões propostos |
| **24** | Chefe a dois: +40% de vida ou zero? | proposta: +40%, e desce quando um morre |
| **22** | Se os inimigos param de reaparecer, de onde vêm as almas para o nível 100? | ou o mundo é maior, ou o 100 não é para uma passagem |

E as **7 perguntas de narrativa** ([`26`](spec/26-narrativa.md) §3), que precisam de uma gravação — **o nome do jogo incluído**.

---

---

## 🕳️ Buracos de sistema — coisas que NUNCA foram escritas

**Varrimento de 01-08.** Não são detalhes por afinar: são sistemas inteiros que a spec assume e nunca definiu. Ordenados por quanto custa descobri-los tarde.

| | Buraco | Porque dói tarde |
|---|---|---|
| 🔴 | ⭐ **Sistema de saves** — onde vive o progresso, e como funciona a dois | **três clientes já dependem dele**: progresso, inventário e o mapa. É fundação, e fundações metem-se primeiro |
| 🔴 | ⭐ **Texturas, modelos 3D e som: ZERO** | os packs CC0 do [`22`](spec/22-assets.md) nunca foram descarregados. **É o que separa o greybox do jogo**, e nenhuma volta cobre |
| 🟠 | ⭐ **Desenho de arena de chefe** | 13 chefes precisam de 13 arenas. Sem regras, saem 13 círculos vazios |
| ✅ | ~~O fim do jogo~~ **ESCRITO 01-08** — escolha final que **os dois têm de concordar**; estrutura fixada, conteúdo depende das 7 perguntas de narrativa | [`58`](spec/58-fim-do-jogo-ciclos-e-a-curva.md) |
| ✅ | ~~Ciclo novo (NG+)~~ **ESCRITO 01-08** — +40% no NG+, +8% por ciclo, ⚠️ **tecto no NG+7**. E a **Brasa** sobe UMA zona sem recomeçar o jogo | [`58`](spec/58-fim-do-jogo-ciclos-e-a-curva.md) |
| 🟠 | **Criação de personagem** | escolhe-se classe, e mais? Aspecto, nome, o primeiro ecrã do jogo |
| 🟠 | ⭐ **Quem afina os 226 números** | há centenas de valores `[FABLE]`/`[CLAUDE]` marcados *"validam-se a jogar"*. **Ninguém escreveu como** |
| 🟠 | ⚠️ **Desligar a meio de um chefe** | o [`19`](spec/19-rede.md) trata quedas, mas não **o que fica** — o chefe recupera vida? O progresso conta? |
| 🟠 | **Música e ambiente** | o [`21`](spec/21-arte-render.md) propõe; existem **12 sons sintetizados** e mais nada |
| 🟠 | ⭐ **Acessibilidade auditiva** | ⚠️ o [`38`](spec/38-ataques-e-honestidade.md) §3 **obriga** a que cada ataque se anuncie por som, e a 1.ª pessoa depende disso. **Quem não ouve bem fica trancado** — precisa de indicador visual equivalente |
| 🔵 | **Onde vivem os textos** | português decidido; falta dizer se as strings estão em ficheiro ou no código |
| 🔵 | **Comando / gamepad** | [`45`](spec/45-controlos-configuraveis.md) §5 propõe nascer agnóstico da fonte; por confirmar |
| 🔵 | **Os vendedores morrem?** | na referência alguns morrem e perde-se o stock. ⏳ donos |
| 🔵 | **Voz: Godot faz nativamente?** | [`56`](spec/56-voz-e-vendedores.md) — a validar no `→WP14` |

### ⚠️ E três que são de coerência, não de conteúdo

| | Buraco | |
|---|---|---|
| 🟠 | ⭐ **A fatia 1 ([`10`](spec/10-fatia-1.md)) foi aprovada antes de ~40 decisões** | fala de cargas de magia que já não existem, de 6 zonas, de espólio sem baralho. **Precisa de uma passagem** |
| 🟠 | **Os ~36 "nomeados"** que substituíram os chefes de campo ([`53`](spec/53-chefes-ritmo-e-o-mago-forte.md) §1) | ninguém os desenhou ainda — são 36 fichas curtas |
| 🟠 | **O Assassino** — furtividade, velocidade, sangramento | marcado no [`12`](spec/12-classes.md) pelo Fable, com os 3 guardas escritos. **Por desenhar** |

---

## ✅ Fechadas

| Lacuna | Fechada em |
|---|---|
| ~~O código vive fora do repositório~~ | PR #13 |
| ~~A medição 0b não tem artefacto~~ | PR #12 *(metade — falta a animação de esqueleto)* |
| ~~Arcos, bestas e escudos sem mecânica~~ | [`48`](spec/48-arcos-bestas-escudos.md) |
| ~~6 zonas contra 10+ biomas~~ | PR #14 — **12 biomas** |
| ~~Quantos chefes ao todo~~ | PR #14 — **61, derivado do mapa** |
| ~~O parry tem dois botões~~ | [`45`](spec/45-controlos-configuraveis.md) — controlos configuráveis |
| ~~Sem sistema de interrupção~~ | [`39`](spec/39-estudo-profundo.md) §4 · [`41`](spec/41-estudo-armas-e-golpes.md) §4 *(escrito; falta implementar)* |
| ~~Espólio sem garantia~~ | [`43`](spec/43-estudo-espolio-inventario-mundo.md) §2 — o baralho de 10 |
