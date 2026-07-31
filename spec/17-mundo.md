# 17 — Mundo e mapa

> **WP8 · Fable** (31-07-2026). O mundo em números. O que herda: mundo aberto com dungeons escondidas `[DECIDIDO]` (02:50 → 03:12), mapa grande `[DECIDIDO]` (12:13), biomas `[DECIDIDO]` (12:13 → 12:21), selva e floresta nomeadas (11:37), 3D (11:28). As duas perguntas vermelhas que vivem aqui — **"grande é quanto?" (4)** e **"biomas são níveis?" (2)** — são deles: este documento põe as propostas em formato de decisão e trabalha com o provisório marcado. Tudo `[FABLE]` salvo indicação.

## "Mapa grande é quanto?" — a pergunta 4 em formato de decisão

"Grande" não se constrói; zonas constroem-se. A proposta muda a unidade de medida:

**Opção A — grande por zonas, não por hectares.** O mundo é uma rede de **6 zonas** feitas à mão (+ o núcleo final), cada uma com 2–3 min de travessia limpa (600–900 m de caminho — a régua do WP0). Total caminhável na versão "zerável": ~35–45 min de travessia contínua, **densa** — cada zona com a sua dungeon escondida, o seu subchefe, os seus segredos. *Ganha:* cabe em duas pessoas (é ~6× a fatia, que já está orçada), cabe nos 8 GB (uma zona + vizinha em memória), e "grande" sente-se pela **variedade**, que é o que os biomas prometem. *Perde:* não é um Elden Ring — quem esperar horizonte infinito nota o desenho por zonas.

**Opção B — um contínuo grande a sério** (~10–16 km²). *Ganha:* a fantasia literal do "mapa grande". *Perde:* multiplica arte, colisões, IA e streaming por área vazia — é exactamente o ponto 3 do risco de escopo ([`00-visao.md`](00-visao.md)), e enche RAM que não existe (Lei 4).

**A minha recomendação: A.** O "grande" que eles descreveram na gravação era sempre sobre *haver muito que descobrir* (biomas, dungeons, chefes) — nunca sobre quilómetros vazios. **Decidem: Mateus + Rico.** Até lá, tudo abaixo assume A, marcado provisório.

## A rede de zonas — o mundo proposto

Cada zona: bioma próprio, paleta com cor de assinatura (WP12), 1 dungeon escondida no mínimo, 1 subchefe ou guardião, 1 atalho destrancável, 1 ponto de descanso. As raças do bestiário ([`15-inimigos.md`](15-inimigos.md)) distribuem-se assim:

| # | Zona (nomes provisórios) | Bioma | Habitantes | Chefe âncora | Fatia |
|---|---|---|---|---|---|
| 1 | **Brumal** | floresta fechada de bruma (11:37) | orcs | Vorgar (guardião, na Toca) | ✅ 1 |
| 2 | **Selva Funda** | selva densa, vertical, escura em baixo (11:37) | goblins (bandos) | subchefe goblin a desenhar | ⬜ 2 |
| 3 | **Campas Cinzentas** | pântano de árvores mortas | esqueletos, zumbis | **o Ceifador** (subchefe — Rico 31-07 ⏳) | ⬜ 2 |
| 4 | **Fojo** | desfiladeiros e minas | kobolds (armadilhas) | **Minotauro** (guardião, no labirinto) | ⬜ |
| 5 | **Costa Quebrada** | falésias, vento, chuva fina | orcs do mar / mímicos nos destroços | a desenhar | ⬜ |
| 6 | **Cimeira** | montanha, neve, ar limpo (o único bioma sem bruma — a vista é a recompensa) | a desenhar | subchefe a desenhar | ⬜ |
| 7 | **O Portão** | núcleo final | élites | o Ultra (camada 1) | ⬜ |

- **Como se ligam:** rede com anéis, não linha — Brumal abre para 2 e 3; a partir daí há sempre ≥ 2 direcções possíveis. A ordem "esperada" existe (numeração), mas nenhuma porta a impõe.
- **Transições:** gargantas físicas (portões de pedra, troncos caídos, cortinas de bruma) que mascaram o streaming — carrega-se a zona seguinte ao entrar na garganta. Uma zona + a vizinha em memória, nunca mais (orçamento de 2,5 GB, WP12). *Alternativa descartada:* mundo contínuo sem costuras — streaming aberto de verdade não cabe nos 8 GB com folga honesta.
- Os nomes são `[FABLE]` provisórios como os do WP0 — o WP8B pode rebaptizar tudo quando a gravação de narrativa acontecer.

## `[TENSÃO]` Biomas por nível vs Lei 1 — a pergunta 2, proposta

**O conflito:** "Por bioma, sei lá, nível, tipo" (12:18) contra o pilar que os dois defenderam com mais força (01:17 → 04:28).

**Opção A — soft gating.** Toda a zona está aberta desde o minuto 1. A dificuldade sobe pela curva do WP2 (×1,4 → ×2,2 → ×3,0) e por **padrões novos** — mas os tectos da Lei 1 (chão de dano 60%, sem morte em um golpe *da sua zona*) valem em todas. Quem entra na Cimeira a nível 3 morre muito e aprende depressa — ou é bom, e passa. O aviso é diegético: os inimigos da entrada mostram o tamanho do osso (e um jogador que mata 3 élites da orla sabe que aguenta a zona).

**Opção B — gating literal.** Portas que pedem nível/chave de progresso. *É a cena exacta que o Rico chamou "má" (01:17)* — fica listada por honestidade, não por mérito.

**A minha recomendação: A**, sem reserva — é a conciliação clássica do género e a única compatível com a Lei 1. A frase do 12:18 lê-se como "os biomas têm dificuldades diferentes", que a Opção A entrega. **Decidem: Mateus + Rico.** Tudo acima assume A.

## Dungeons

`[DECIDIDO]` (03:12): escondidas, em qualquer sítio do mapa, não obrigatoriamente cavernas. O desenho `[FABLE]`:

- **Uma por zona no mínimo**, feitas **à mão** (*alternativa descartada:* geração procedimental — barata em quantidade, cara em qualidade de leitura; um souls-like vive de espaços desenhados, e quem desenha aqui são duas pessoas com uma spec — a mão ganha).
- **Como se descobrem — a regra das duas pistas:** toda a entrada escondida tem **≥ 2 pistas legíveis no terreno** a ≤ 30 m (a árvore morta da Toca + o corvo pousado; trilho de pegadas + arranhões na rocha). Nunca marcador de mapa, nunca brilho flutuante. *Porquê:* "o cara pode **descobrir**" (03:12) — descobrir exige que haja o que ler; pista zero é lotaria, não exploração.
- **Formato:** 3–6 salas + arena de guardião (camada 3, WP7). Entradas variadas por decisão deles: fenda, poço, porta em ruína, tronco oco.
- **A Toca** (fatia): fenda na rocha debaixo da árvore morta; sala 1 (descida, 15×10 m, luz da entrada), sala 2 (emboscada, 18×12 m, 2 lanceiros às costas — o som avisa, WP6), sala 3 (12×20 m, brutamontes + 2 lanceiros, tochas), arena de Vorgar (20×16 m, WP7). Tecto ≥ 2,5 m em todo o percurso — regra da câmara do WP1B.

## Traçado de Brumal — a zona da fatia, ao metro

~600 × 400 m úteis, bruma a 60 m de visão (WP12), bordas em despenhadeiro-de-bruma (não há parede invisível: há bruma densa que devolve o jogador — 3 s dentro dela e está virado para trás).

O caminho esperado (encontros exactos no WP6):

1. **Orla** — clareira de entrada, ponto de descanso inicial, 1 lanceiro à vista (o primeiro duelo). Marco visual: um arco de pedra partido.
2. **Caminho do meio** (~200 m, serpenteia) — 2 lanceiros; bifurcação com pista falsa (leva ao segredo 1, não à Toca).
3. **Clareira do brutamontes** — o professor do parry, sozinho; atrás dele, visível, a **árvore morta** (o marco da dungeon).
4. **Árvore morta** — as 2 pistas da Toca (árvore + corvos); a skill *Lançamento de Adaga* escondida no oco (WP3/WP9 fecham o loot).
5. **Entrada da Toca** — brutamontes + lanceiro (o exame); descoberta a entrada, ela vira ponto de renascimento (WP1).

**Segredos de Brumal (3):** ampliação do Frasco (WP5) atrás da cascata de bruma; a adaga no oco da árvore; um miradouro com vista para a Selva Funda — o teaser da zona 2, e nada mais. *Regra: todo o segredo paga em opção (Lei 2), nunca em números.*

**Atalho:** portão de madeira trancado por dentro, da clareira do brutamontes à orla — abre-se ao voltar da árvore morta; corta a travessia para < 40 s e serve o critério de morte < 30 s quando o renascimento ainda é na orla.

## Navegação, mapa e viagem

- **Sem minimapa.** O mundo lê-se no mundo — marcos verticais (a árvore morta vê-se de metade de Brumal), a bruma orienta por densidade. *Alternativa descartada:* minimapa — mata a leitura de terreno que o género treina e o 27-aprendizagem assume.
- **Mapa de pausa ilustrado** (estilo pintado, WP13 gera): mostra a zona, os marcos descobertos e o ponto de descanso; a posição do jogador marca-se **por área, não por seta GPS**.
- **Viagem rápida:** nenhuma na fatia (uma zona não precisa). Com 3+ zonas: **entre pontos de descanso já visitados**, a partir de qualquer ponto de descanso — nunca em campo aberto. *Porquê:* poupa travessias repetidas (que seriam grind de pernas) sem apagar o mundo.
- **Montarias:** continuam guardadas (05:15) — com zonas de 2–3 min e viagem entre descansos, o cavalo não tem trabalho. Reavalia-se se a Opção B da escala ganhar.
- **Dia/noite e meteorologia: não.** Iluminação é assada (Lei 4/WP12) — um ciclo dinâmico duplicaria os lightmaps no mínimo. A hora de cada zona é fixa e faz parte da identidade dela (a Cimeira ao fim da tarde, as Campas ao lusco-fusco). *Alternativa descartada:* ciclo em tempo real — custo alto, ganho decorativo.

## O que este documento entrega aos outros

| Para | O quê |
|---|---|
| **WP6/WP7** | zonas × raças × chefes âncora; a curva ×1,4 → ×3,0 mapeada a zonas concretas |
| **WP9** | segredos pagam em opções; ampliações de frasco 1/zona; onde vivem pergaminhos e Limalha |
| **WP10** | transições por garganta = pontos naturais de sincronização de zona em co-op |
| **WP11** | mapa de pausa ilustrado, sem minimapa |
| **WP12/WP13** | 6 paletas de zona + marcos verticais por zona; o mapa ilustrado como asset |
| **WP15** | a ordem de construção das zonas é a numeração; a fatia 2 é Selva Funda **ou** Campas (decisão deles na gravação) |

## O que continua aberto

- **Pergunta 4** (escala — Opção A/B acima) e **pergunta 2** (soft gating — Opção A/B acima): deles, com recomendações escritas
- Nomes definitivos das zonas → WP8B/gravação · Fatia 2: Selva ou Campas primeiro → deles
- O interior das zonas 2–7 desenha-se zona a zona, cada uma no seu pacote de conteúdo, quando a fatia 1 estiver validada

## Ligações

[`05-mundo.md`](05-mundo.md) (sessão 1) · [`10-fatia-1.md`](10-fatia-1.md) · [`15-inimigos.md`](15-inimigos.md) · [`16-chefes.md`](16-chefes.md) · [`21-arte-render.md`](21-arte-render.md) · [`99-perguntas-abertas.md`](99-perguntas-abertas.md)
