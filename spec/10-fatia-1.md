# 10 — Fatia 1 · o primeiro jogável

> **WP0.** Este documento responde à pergunta 1 de [`99-perguntas-abertas.md`](99-perguntas-abertas.md): *qual é a fatia mais pequena disto que já é divertida a dois?* A proposta é minha `[FABLE]`; a confirmação é do Mateus e do Rico. Até esse sim, tudo aqui é provisório — mas é a linha que ordena todos os pacotes seguintes.

## A regra que define a fatia

**Sistemas completos, conteúdo mínimo.**

A fatia 1 não é uma demo nem um tutorial. É o jogo inteiro, encolhido: tudo o que faz o género funcionar — esquiva, parry, stamina, magia com cargas, morte, co-op — presente de corpo inteiro; e o conteúdo (mapa, chefes, armas) na quantidade mínima que ainda diverte.

**Porquê assim:** o risco nº1 do projeto é o combate não ser bom — e isso só se descobre a jogar ([`00-visao.md`](00-visao.md) · risco de escopo). A fatia existe para responder barato à pergunta cara. Se o combate da fatia for bom, mais conteúdo torna o jogo maior. Se for mau, mais conteúdo só o torna mais comprido.

A fatia é também onde a `[TENSÃO]` 0b (3D contra o hardware, [`09-tecnico.md`](09-tecnico.md)) se resolve **com dados**: o marco 1 do plano de construção (WP15) é um teste de desempenho dentro desta zona, nas máquinas reais.

## A experiência, do início ao fim

> Dois amigos escolhem cada um a sua classe — digamos um Guerreiro e uma Feiticeira — e aparecem na orla de **Brumal**, uma floresta fechada de bruma (o único cenário nomeado na gravação: floresta, 11:37; a bruma é aliada da Lei 4, esconde o corte do mundo). Atravessam-na a abrir caminho por orcs que lhes ensinam à força a esquiva e o parry, e encontram — porque exploraram, não porque uma seta apontou — a entrada escondida da **Toca**: uma fenda na rocha debaixo de uma árvore morta (dungeon escondida num local do mapa: 03:12). Lá em baixo, três salas de escuridão crescente e, no fundo, **Vorgar, o Guarda-Portão**, um chefe de guerra orc com duas fases. Morrem. Voltam em menos de 30 segundos. Aprendem os padrões. Quando Vorgar finalmente cai, a fatia está zerada — e o teste verdadeiro é a frase seguinte: *"outra vez, mas eu de Assassino?"*

Os nomes — Brumal, a Toca, Vorgar — são `[FABLE]` provisórios, para este documento ter chão concreto. Os finais fecham-se em WP6/WP7/WP8.

## Os números da fatia

| Conteúdo | Na fatia 1 | Notas | Detalha-se em |
|---|---|---|---|
| Zonas abertas | **1** — Brumal (floresta) | travessia limpa 2–3 min a pé; ao ritmo do género (~5 m/s de corrida) são ~600–900 m de caminho; velocidade final é do WP1 | WP8 |
| Dungeons | **1** — a Toca | 3 salas + arena; entrada escondida, descoberta por exploração | WP8 |
| Chefes | **1** — Vorgar, 2 fases | camada de baixo da pirâmide (03:25) — a hierarquia fica de pé, constrói-se por cima | WP7 |
| Tipos de inimigo | **2** — orc lanceiro, orc brutamontes | o lanceiro é rápido e ensina a esquiva; o brutamontes é lento, telegrafado, e ensina o parry | WP6 |
| Classes | **6** de 8 | ver tabela abaixo | WP3 |
| Armas | **5** — espada longa, escudo de madeira, cajado, adaga, machadão | qualquer classe pega em qualquer uma (Lei 3) | WP5 |
| Magias | **3** — Dardo, Ruína, Égide | três verbos diferentes, não três escalões de dano (Lei 2) | WP4 |
| Níveis | **1–10** | pontos por nível nos atributos; lista final de atributos é do WP2 | WP2 |
| Jogadores | **1–2** | co-op desde o primeiro dia — pilar 2 não é um extra a acrescentar no fim | WP10 |
| Montarias, moeda, vendedores, encantamentos, armadura | **0** | fora da fatia — justificação abaixo | — |

## Quanto dura

| Medida | Alvo |
|---|---|
| Travessia limpa até à entrada da Toca (quem já sabe) | 4–6 min |
| Primeira vitória sobre Vorgar (jogador novo, somando mortes) | 45–90 min |
| Noite típica de co-op | 60–120 min — chega para zerar a fatia |
| Recomeço depois de morrer no chefe | **< 30 s** |

*Teste da Lei 1:* se a primeira vitória média passar de 2 h, o chefe está a testar paciência, não habilidade — os números voltam atrás. Se ficar abaixo de 30 min, não está a exigir leitura nenhuma. A janela 45–90 min é a aposta; afina-se a jogar.

## As seis classes

`[DECIDIDO]` (Mateus + Rico, 31-07-2026) — **a fatia 1 leva seis classes**, não duas. *(Proposto pelo Rico a 30-07 por instrução directa; confirmado pelos dois a 31-07.)*

Das oito nomeadas na gravação (07:13 → 07:57), entram as seis mais distintas entre si:

| Classe | Papel, numa linha | Arranque típico | Origem | Fatia 1? |
|---|---|---|---|---|
| **Guerreiro** | o equilibrado — espada e escudo, o metro dos outros | espada longa + escudo | 07:13 | ✅ |
| **Feiticeiro** | as três magias e o cajado; frágil ao perto | cajado | 07:13 | ✅ |
| **Tanque** | "fica com o escudo" (08:39) — absorve, controla espaço, mata devagar | escudo + espada | 07:35 | ✅ |
| **Assassino** | "mais rápido" (09:37) — adaga, esquiva curta, castiga costas | adaga | 07:27 | ✅ |
| **Berserker** | machadão a duas mãos; dano bruto, sem escudo, stamina no limite | machadão | 07:35 | ✅ |
| **Paladino** | espada e escudo com "um pouco de raio" (08:39) — o híbrido | espada + escudo | 07:40 | ✅ |
| Batedor | o de arco — espera que o arco entre (ver "fora da fatia") | — | 07:29 | ⬜ fatia 2 |
| Mago do mal | espera que a pergunta 8 (bem/mal mecânico) tenha resposta | — | 07:57 | ⬜ |

O "arranque típico" é o equipamento inicial — pela Lei 3, qualquer um pega em qualquer arma da fatia no minuto seguinte. A diferenciação a sério (atributos iniciais, habilidade especial de cada um, skills) é o trabalho do WP3, debaixo da Lei 2: **habilidades que mudam o que se pode fazer, não os números** (09:21).

**O preço, dito com todas as letras:** seis classes na fatia são seis habilidades especiais a desenhar no WP3, cinco conjuntos de animação de arma no WP12, e equilíbrio a seis no protótipo. É a maior fatia de trabalho do primeiro jogável — fica registado como decisão consciente, não como acidente.

## Decisões provisórias que a fatia obriga a tomar já

Cada uma é `[FABLE]` **provisória**: serve a fatia, não fecha a pergunta original — que continua no [`99-perguntas-abertas.md`](99-perguntas-abertas.md), à espera deles.

### Morte (pergunta 10 continua aberta)
Morreste → voltas à entrada de Brumal; depois de descoberta a Toca, ela própria é o ponto de renascimento. Inimigos normais renascem; **não se perde nada** — na fatia não há economia, e punição sem economia seria arbitrária. *Alternativa descartada:* perder XP/"almas" ao morrer — é a decisão de tom do jogo inteiro (pergunta 10) e é deles; a fatia não a antecipa à socapa. *Teste da Lei 1:* a morte custa caminho (< 30 s no chefe), nunca grind. ✅

### Drops em co-op (pergunta 5 continua aberta)
**Loot instanciado** — cada jogador recebe a sua cópia. *Alternativa descartada:* partilhado com negociação — mais rede, mais fricção entre amigos, zero ganho na pergunta que a fatia responde. A resposta do Mateus perdida no áudio (05:40) continua a ser a decisão final.

### Chefe a dois (pergunta 6 continua aberta)
Com dois jogadores, Vorgar leva **×1,8 de vida** (ponto de partida; afina-se no protótipo) e os ataques alternam de alvo. Sem isto, a resposta a qualquer chefe difícil passa a ser "chamar o outro" — e a Lei 1 morre. *Alternativa descartada:* dificuldade igual a solo e a dois — descartada exactamente por essa razão.

### Sessão de rede (modelo final é do WP10)
Um hospeda, o outro entra por convite; o mundo e a gravação são do anfitrião. O **progresso individual em mundo partilhado** (12:34) — o sistema mais complexo do jogo — fica explicitamente fora da fatia e resolve-se no WP10. *Alternativa descartada:* persistência partilhada já na fatia — é arquitectura de outro tamanho, e a fatia não pode depender dela.

### Solo
A fatia joga-se a um, desenhada para dois. O pilar 2 diz "sempre **disponível**", não "obrigatório" — se um dos dois não puder, o outro ainda treina o Vorgar.

## O que fica explicitamente de fora

| O quê | Porquê fica fora | Volta em |
|---|---|---|
| **Arco e flecha** | Decidido no jogo (00:16), fora da fatia: se atacar de longe for seguro, ninguém esquiva nem apara — as duas mecânicas centrais morrem ([`01-combate.md`](01-combate.md)). A magia já cobre "longe" com custo auto-limitado (cargas). O arco entra quando o WP1 tiver o sistema de pressão (munição, tempo de puxar, inimigos que fecham). | WP1 define, fatia 2 constrói |
| **Batedor** | É a classe do arco — entra com ele. | fatia 2 |
| **Mago do mal** | A divisão bem/mal ainda não faz nada mecanicamente (pergunta 8). Metê-lo já era decoração — e a regra deles é "cada magia é certinha" (05:04). | WP4 propõe, eles decidem |
| **Evoluções de classe** | `[TENSÃO]` aberta com a Lei 1 (pergunta 3). Não se constrói em cima de uma tensão por resolver. | WP3 propõe |
| **Encantamentos** | Dependem do catálogo de itens; não mudam a pergunta que a fatia responde. | WP5 |
| **Biomas múltiplos / mapa grande** | A fatia prova a **forma** decidida — zona aberta + dungeon escondida (02:50, 03:12) — à escala mínima. A escala precisa de número (pergunta 4) e a tensão dos biomas (pergunta 2) é deles. | WP8 |
| **Pirâmide de ~61 chefes** | Vorgar é um da camada de baixo. A pirâmide (03:25) fica de pé; constrói-se chefe a chefe por cima da fatia. | WP7 |
| **Progresso individual em mundo partilhado** | O sistema mais complexo do jogo, descrito numa frase (12:34). Não se resolve de passagem. | WP10 |
| **Armadura** | Nunca foi mencionada na gravação (pergunta 14) — existir ou não é decisão deles. | WP5 |
| **Montarias** | Um mapa de minutos não precisa de cavalo. O cavalo (05:15) fica guardado. | WP5/WP8 |
| **História, NPCs, missões, vendedores, moeda, viagem rápida, dia/noite** | A fatia responde a combate + co-op, não a mundo vivo. | WP8/WP9 |

Nada disto é corte. É ordem.

## Porquê é que isto já é divertido a dois

- **O loop do género está inteiro:** ler o inimigo → errar → morrer barato → voltar já → acertar. A fatia não corta nenhum passo do loop; corta repetições dele.
- **Seis classes para dois lugares:** a conversa "quem vais ser?" começa antes do jogo abrir, e o "outra vez, de outra coisa" é rejogabilidade grátis — a mesma Toca é outro jogo de adaga ou de machadão.
- **Combinações a dois:** Tanque a segurar o brutamontes enquanto a Feiticeira gasta a Ruína; Berserker a aproveitar as costas que o Paladino abre. As classes obrigam a falar.
- **A Lei 3 em acção:** a meio da run, trocar de arma um com o outro é possível e muda tudo.
- **Vorgar com duas fases:** a segunda muda padrões, não números — a Lei 2 aplicada a chefes.
- E a pergunta cara — *o combate é bom?* — respondida barato.

## Está feita e funciona quando

1. **Rede:** dois PCs em casas diferentes entram numa sessão em < 2 min, sem editar ficheiros de configuração.
2. **Chegável:** um jogador novo mata Vorgar em < 2 h de tentativas somadas.
3. **Teste da Lei 1, jogado, não argumentado:** um jogador que já zerou, com um personagem **nível 1 e zero pontos gastos**, mata Vorgar. Se falhar por falta de dano ou excesso de vida do chefe, os números (WP2/WP7) voltam atrás.
4. **Morte barata:** morrer no chefe → nova tentativa em < 30 s, também em co-op.
5. **Lei 4 com números reais:** 60 fps estáveis em combate — 2 jogadores + 3 inimigos no ecrã — na resolução nativa (1080p), **nas duas máquinas reais**. A do Rico já está medida (Iris Xe, 8 GB em canal duplo — pergunta 0); mínimo aceitável 50 fps com escala dinâmica de resolução; abaixo disso pára-se o conteúdo e optimiza-se (marco 1 do WP15).
6. **Telegrafia a funcionar:** numa sessão de teste, o jogador diz antes de cada golpe do brutamontes se dá para aparar — e acerta ≥ 8 em 10. Os avisos especificam-se no WP6.
7. **O voto:** no fim de uma noite, Mateus e Rico querem a fatia 2. Subjectivo de propósito — o jogo é deles.

## O que a fatia NÃO responde, de propósito

As perguntas 2 (biomas/nível), 3 (evoluções), 4 (mapa grande), 8 (bem/mal), 10 (morte definitiva), 14 (armadura) e 15 (estilo visual) **continuam abertas** no [`99-perguntas-abertas.md`](99-perguntas-abertas.md). A fatia joga com provisórios marcados; não fecha nada à socapa.

## Ligações

- Risco de escopo que este documento responde: [`00-visao.md`](00-visao.md)
- Perguntas em aberto: [`99-perguntas-abertas.md`](99-perguntas-abertas.md)
- Restrição de hardware e tensão do 3D: [`09-tecnico.md`](09-tecnico.md)
- Ordem dos pacotes que herdam esta linha: [`../prompts/BRIEFING-FABLE.md`](../prompts/BRIEFING-FABLE.md)
