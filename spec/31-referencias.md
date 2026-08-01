# 31 — Como usar o Dark Souls como referência

`[DECIDIDO]` (Mateus, 31-07-2026) — **Dark Souls é a referência de qualidade e de estrutura. O Dark Souls 2 é o chão aceitável.**

E `[DECIDIDO]` — quem trabalha nesta spec **vai buscar dados reais** dos jogos de referência, compara-os com o que temos, e escreve o que falta.

## A barra: Dark Souls 2 (2014) é o mínimo aceitável

Não é uma barra baixa — é uma barra **realista e alta**. O DS2 assenta quase exactamente no orçamento que a Lei 4 nos dá:

| | Dark Souls 2 | Nós ([`30-qualidade-visual.md`](30-qualidade-visual.md)) |
|---|---|---|
| Tri por personagem | ~10–20 mil | 10–15 mil |
| Texturas | 1024–2048 | 1024–2048 |
| Alvo | 60 fps em PC | 60 fps em PC |

Ou seja: **o que já está na spec chega para lá.** O que nos separa do DS2 não é hardware — é animação, iluminação e coerência, que é exactamente o que o [`30-qualidade-visual.md`](30-qualidade-visual.md) diz.

## A linha que não se atravessa

Este repositório é **público**. A distinção é simples e não é burocracia — é o que separa "inspirado em" de "cópia":

| ✅ Estudar e adaptar | ❌ Copiar |
|---|---|
| **Como** um chefe se estrutura em fases | O chefe em si — nome, aspecto, moveset |
| O vocabulário de telegrafia (o que avisa o quê) | As animações deles |
| **Quantos** tipos de arma existem e como se agrupam | A lista de armas, com nomes e números |
| Como as classes iniciais funcionam (presets, não trancas) | As classes deles, com as estatísticas |
| Como o mapa se interliga e onde ficam os atalhos | A planta de Lordran |
| Como a lore se conta (descrições de item, ambiente) | A lore deles |

**A regra prática:** se conseguires explicar o padrão numa frase sem dizer o nome do jogo, é padrão — adopta. Se precisares do nome para explicar, é conteúdo — não entra.

**Nunca** entram no repositório: imagens, modelos, sons, texto ou tabelas de dados extraídos dos jogos. Nem em `_local/`. *(Já houve um caso bem resolvido: a imagem de referência do Ceifador ficou de fora, e ficou só a descrição — [`04-inimigos-chefes.md`](04-inimigos-chefes.md).)*

## O que estudar, por área

Ordenado por onde a nossa spec mais ganha.

### Chefes e subchefes (`→WP7`)
- **Como as fases funcionam:** o que muda na segunda — padrões, alcance, ritmo. E o que **não** muda (mais vida não é fase)
- **O padrão do inimigo de elite no mundo aberto:** o adversário duro que aparece fora de uma arena, sem música de chefe, e que serve de exame ao que aprendeste. É o modelo natural para os nossos subchefes das camadas de baixo
- **Desenho de arena:** tamanho, obstáculos, onde é que o jogador se refugia, como a arena obriga a mexer
- **Ritmo do combate:** quantos segundos entre janelas de ataque do jogador, e quanto tempo dura o combate

### Armas e variedade (`→WP5`)
- **Como as armas se agrupam por família**, e quantas partilham conjunto de movimentos. É assim que se tem variedade sem animar cada uma de raiz — e é directamente aplicável às nossas 5
- **Requisitos e escala por atributo:** como uma arma comunica "não és tu que a usas" sem a proibir. É a nossa Lei 3, e eles resolveram-na antes
- **Quantas armas existem por altura do jogo** — para calibrarmos se 5 na fatia é pouco ou está certo

### Classes (`→WP3`)
Vale confirmar uma coisa que já intuímos: nesses jogos as classes iniciais são **presets de estatísticas e equipamento**, não caminhos fechados — qualquer personagem pode acabar a usar qualquer coisa. **É exactamente a nossa Lei 3**, e é bom saber que o modelo aguenta um jogo inteiro.

### Itens e consumíveis (`→WP9`)
- Como se estruturam: cura, buffs temporários, materiais de melhoria, itens-chave
- **Quantos consumíveis um jogador carrega de facto** — para dimensionar a nossa mochila
- Como a cura funciona e porque é que a escolha muda todo o ritmo. A **pergunta 7 decidiu** o Frasco de Bruma recarregável no descanso; a referência serve para afinar os baselines, não para reabrir poções finitas

### Mundo (`→WP8`)
- **Interligação e atalhos:** como um mapa grande se sente pequeno quando os caminhos se cruzam. Crítico para os nossos 10+ biomas e ~30 min a pé
- **Colocação de pontos de descanso:** distância entre eles, e o que isso faz à tensão
- Como se comunica que uma zona é perigosa **sem trancar nada** — é o nosso **soft gating**

### Progressão e morte (`→WP9`)
- O que se perde ao morrer e como se recupera. A **pergunta 10 decidiu** almas na mancha, perdidas se outra morte a substituir; a comparação serve para testar clareza e tensão
- Curva de custo de subir de nível

## O protocolo de investigação

Quem pegar num pacote faz isto **antes** de escrever:

1. **Recolher dados reais** da referência para a área do pacote — números, estruturas, contagens. De fontes públicas: wikis, documentação, análises técnicas, vídeos de análise de design.
2. **Escrever uma tabela de comparação** no documento: *o que eles têm · o que nós temos · a diferença.*
3. **Nomear a diferença**, e dizer se é intencional. *"Eles têm 200 armas, nós temos 5 na fatia — intencional, a fatia é mínima"* é uma boa resposta. *"Eles têm 4 tipos de esquiva e nós um — não tínhamos pensado nisso"* é uma descoberta.
4. **Escrever a nossa versão**, que resolve o mesmo problema com as nossas regras. Nunca copiar a resposta deles.
5. **Citar a fonte** dos números, para se poderem verificar.

O ponto 3 é o que faz isto valer a pena: **a comparação existe para encontrar o que não nos ocorreu**, não para nos aproximarmos deles.

## O que já sabemos que a comparação vai levantar

Registado agora, para não parecer descoberta depois:

- **Variedade de armas:** 5 na fatia contra as dezenas de um jogo completo. Intencional para a fatia; por decidir para o jogo inteiro
- **Número de chefes:** os nossos ~61 planeados são mais do que a maioria dos jogos do género tem. Já está assinalado como o maior risco de escopo ([`00-visao.md`](00-visao.md))
- **Densidade de conteúdo por zona:** com 10+ biomas, é a pergunta que o WP8 tem de responder com um número
- **Melhoria de armas:** já existe no [`68`](68-catalogo-de-armas-armaduras-e-aneis.md) como base + seis escolhas de verbo/escala/conversão, sem aumento linear de dano (`→WP5`)
- **Estados alterados** (veneno, sangramento, queimadura): nem mencionados na sessão 1, e são parte grande do género

## Ligações

[`30-qualidade-visual.md`](30-qualidade-visual.md) · [`29-perspectiva.md`](29-perspectiva.md) · [`00-visao.md`](00-visao.md) · [`../prompts/BRIEFING-FABLE.md`](../prompts/BRIEFING-FABLE.md)
