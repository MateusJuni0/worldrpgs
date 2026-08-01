# 99 — Perguntas em aberto

Tudo o que falta decidir, por ordem de urgência. Serve de guião para a próxima gravação: passem por esta lista e a spec cresce sozinha.

**Regra:** tudo o que ainda estiver aqui quando a construção começar é uma decisão que vocês entregaram a quem constrói, sem saber.

> **Estado a 31-07-2026:** as perguntas **0, 0b, 1, 2, 3, 4, 8 e 9 fecharam** com a aprovação do Mateus e do Rico — ficam riscadas, com a decisão por baixo, porque o raciocínio continua a valer. **Nada bloqueia nenhum pacote.** O que resta são decisões de tom e de detalhe, e cada uma diz onde é que a spec joga com provisórios até lá.

---

## 🔴 Bloqueiam tudo o resto

### 0. ~~As máquinas~~ — RESPONDIDA (31-07-2026)

As duas estão medidas. **A do Rico é a mais fraca, e é a que manda** — orçamenta-se sempre para a pior das duas.

| | Rico ⚠️ *(o alvo)* | Mateus |
|---|---|---|
| Processador | Intel Core i5-1334U (13.ª ger.) | Intel Core i7-1255U (12.ª ger.), 10 núcleos / 12 threads |
| Gráficos | Intel Iris Xe integrados | Intel Iris Xe integrados |
| RAM | **8 GB** — 2×4 GB, canal duplo | 16 GB — 2×8 GB @ 3200 MT/s, canal duplo |
| Disco | SSD NVMe 256 GB | SSD NVMe 512 GB |
| Ecrã | 1920×1080 @ 60 Hz | 1920×1080 @ 60 Hz |
| Sistema | Windows 11 Home 64 bits | Windows 11 Home 64 bits |
| Comando | nenhum ligado — teclado e rato | nenhum ligado — teclado e rato |

⚠️ **O orçamento aponta aos 8 GB, não aos 16.** Descontando o sistema e a memória que os gráficos integrados tiram — partilham a RAM, não têm memória própria — sobram na ordem de **3 a 4 GB** para o jogo na máquina do Rico. É um tecto apertado, e é o real.

Do lado bom, três coisas: as duas têm **canal duplo**, que é o melhor cenário para gráficos integrados, porque a largura de banda da memória é o estrangulamento principal; as duas têm **SSD NVMe**, o que ajuda a carregar com memória curta; e as duas são **60 Hz**, o que fecha a taxa alvo em 60 fps e evita perseguir mais.

⚠️ Ambas são **chips de portátil da série U**, de baixo consumo. O problema não é o pico, é aguentar: o alvo mede-se **quente**, ao fim de vinte minutos, não ao primeiro. E não há comando ligado em nenhuma — o esquema de controlos parte de teclado e rato.

> Os relatórios `dxdiag` completos ficam **fora do repositório**: trazem nome de máquina e de utilizador, e isto é público. O que interessa está nesta tabela.

→ [`09-tecnico.md`](09-tecnico.md)

### 0b. ~~O 3D aguenta-se neste hardware?~~ ✅ DECIDIDA — caminho A
**Medido no protótipo local (31-07-2026), na máquina mais fraca:** 60 fps cravados no cenário da fatia com vsync; 416 fps médios em greybox ao fim de **20 minutos quentes, sem degradação térmica**; renderer Mobile escolhido. Ressalvas: sem animação de esqueleto ainda (a incógnita cara), e memória a vigiar. Os três caminhos (3D / 2.5D / 2D) ficam com dados à frente.

✅ **CARIMBADO** `[DECIDIDO]` (Mateus + Rico, 31-07-2026) — **caminho A: 3D estilizado, optimizado.** A tensão fecha-se.

⚠️ Uma ressalva que a aprovação não apaga, porque é matéria de facto e não de decisão: **a medição não está sustentada no repositório** — não há protótipo, log nem artefacto que a acompanhe, e o próprio relatório ressalva que falta a animação de esqueleto, que é a parte cara. O caminho está escolhido; a prova de que aguenta com esqueletos animados continua por fazer, e é o marco 1 do WP15 que a dá.

✅ **Metade da ressalva fechada (31-07):** os artefactos crus estão agora em [`medicoes/`](../medicoes/) — 8 ficheiros JSON escritos pela ferramenta, sem edição, com o resumo em [`44-prototipo.md`](44-prototipo.md). **A outra metade mantém-se inteira e é a que importa:** continua a ser greybox **sem animação de esqueleto**. O M1 continua a ser quem dá a prova completa.
→ [`09-tecnico.md`](09-tecnico.md)

### 1. ~~Qual é a fatia mais pequena disto que já é divertida a dois?~~ ✅ APROVADA
A sessão 1 descreveu mundo aberto grande, 3D, ~61 chefes, 8 classes, dois sistemas de magia, montarias e co-op sincronizado. Isso é anos de trabalho para uma equipa.

A pergunta não é "cortamos o quê". É: **se só existisse uma zona, um chefe e duas classes, isso já era um jogo que vocês queriam jogar?** Se sim, é por aí que se começa e o resto cresce por cima.

**→ Proposta escrita (WP0):** [`10-fatia-1.md`](10-fatia-1.md) — 1 zona + 1 dungeon + 1 chefe, 6 classes (instrução directa do Rico), 5 armas, 3 magias, co-op desde o dia 1.

✅ **APROVADA** `[DECIDIDO]` (Mateus + Rico, 31-07-2026) — a fatia 1 é esta. É a linha que ordena todos os pacotes.
→ [`00-visao.md`](00-visao.md) · secção de risco

### 2. ~~Os biomas são patamares de dificuldade?~~ ✅ RESPONDIDA
`[DECIDIDO]` (Mateus + Rico, 31-07-2026) — **soft gating.** Mapa todo aberto; dificuldade sugerida, não exigida. Detalhe e o que obriga em [`05-mundo.md`](05-mundo.md).

O WP8 desenvolveu-o em [`17-mundo.md`](17-mundo.md): a dificuldade sobe pela curva do WP2 e pelos padrões dos inimigos, dentro dos tectos da Lei 1.
→ [`05-mundo.md`](05-mundo.md), [`00-visao.md`](00-visao.md)

### 3. ~~As evoluções de classe dão poder ou dão opções?~~ ✅ DECIDIDA — opção A
Se o mago nível 3 lança mais depressa que o nível 1, o nível está a dar vantagem — que é o que o pilar 1 recusa. O próprio Rico já apontou para o lado certo às 09:21 ("não aumentar o dano, uma magia diferente"). Falta confirmar como regra.

**→ Proposta escrita (WP3):** as duas opções lado a lado, com recomendação **A (opções)** e subida por marco em vez de nível — [`12-classes.md`](12-classes.md).

✅ **DECIDIDA** `[DECIDIDO]` (Mateus + Rico, 31-07-2026) — **opção A: as evoluções dão opções, não números**, e sobem por marco, não por nível. É a Lei 2 aplicada à progressão, e fecha a tensão com a Lei 1.
→ [`02-personagem.md`](02-personagem.md)

### 4. ~~"Mapa grande" é quanto?~~ ✅ RESPONDIDA
`[DECIDIDO]` (Mateus + Rico, 31-07-2026) — **~30 min a pé, 10+ biomas** (escala Elden Ring). A fatia 1 continua a ser Brumal sozinha; o resto cresce zona a zona. O WP8 herda três obrigações: densidade mínima por zona, estratégia de reutilização de peças, e viagem rápida. Ver [`05-mundo.md`](05-mundo.md).

~~⚠️ **Diferença por acertar:** o WP8 ([`17-mundo.md`](17-mundo.md)) desenhou **6 zonas** de 2–3 min + núcleo final (~35–45 min de travessia).~~ ✅ **Acertada na volta 1** ([`49-biomas.md`](49-biomas.md)) `[FABLE]`: **12 biomas** — as 6 zonas do WP8 mantêm-se e entram mais 6. É o único número que fecha as duas contas aprovadas ao mesmo tempo: 12 × 2–3 min ≈ 30 min a pé, e 1+12+12+36 = **61 chefes** (o número do [`00-visao.md`](00-visao.md)). A rede (quem liga a quem) redesenha-se na volta 9.
→ [`05-mundo.md`](05-mundo.md)

---

## 🟠 Decidem o que se sente a jogar

### 5. Como funcionam os drops em co-op?
O Rico levantou a pergunta às 05:36 e ficou sem resposta (o áudio do Mateus falhou). Três hipóteses: cópia para cada um, filtrado por classe, ou partilhado com negociação.

*Entretanto, a fatia 1 joga com loot instanciado provisório `[FABLE]` — [`10-fatia-1.md`](10-fatia-1.md).*

**→ Proposta escrita (WP9):** instanciado escolhido e justificado (é a leitura directa do 05:29; filtrar por classe contradiz a Lei 3; partilhado é atrito sem ganho), e o "recompensa menor" do 12:34 em números: quem ajuda no que já matou ganha 40% do XP e só materiais. Ver [`18-progressao.md`](18-progressao.md). **A resposta perdida do Mateus (05:40) tem precedência se for recuperada.**
→ [`06-itens-inventario.md`](06-itens-inventario.md)

### 6. Os chefes ficam mais duros com dois jogadores?
Nunca foi mencionado. Se não ficarem, a resposta a qualquer chefe difícil passa a ser "chamar o outro", e o pilar 1 morre.

*Entretanto, a fatia 1 joga com vida do chefe ×1,8 a dois, provisório `[FABLE]` — [`10-fatia-1.md`](10-fatia-1.md).*
→ [`07-multiplayer.md`](07-multiplayer.md)

### 7. ~~Como se recupera vida?~~ ✅ RESPONDIDA
`[DECIDIDO]` (Mateus, 31-07-2026) — **frascos, recarregados nos pontos de descanso.** Não se compram; o custo é o tempo de beber, não dinheiro. Detalhe em [`33-morte-e-almas.md`](33-morte-e-almas.md).

*(a pergunta original, para registo:)*
Frasco recarregável ao descansar, ou poções que se compram e acabam? Decide toda a tensão da exploração.

**→ Proposta escrita (WP5):** Frasco de Bruma — 3 cargas, 40% de vida por gole, 1,2 s a beber, recarrega ao descansar; ampliações escondidas no mundo em vez de stock comprável (poções finitas convidam ao farm, que a Lei 1 proíbe). Ver [`14-equipamento.md`](14-equipamento.md). Falta o sim dos dois.
→ [`06-itens-inventario.md`](06-itens-inventario.md), [`14-equipamento.md`](14-equipamento.md)

### 8. ~~O que é que "magia do bem e do mal" faz mecanicamente?~~ ✅ APROVADA
Hoje é só um nome. Pode ser o sistema mais interessante do jogo, ou decoração.

**→ Proposta escrita (WP4):** *bem = controlo sem preço; mal = ~1,5× mais forte por carga mas custa 8% dos PV por lançamento; qualquer um usa as duas; mortos-vivos temem o bem.* Detalhe e alternativa descartada em [`13-magia.md`](13-magia.md).

✅ **APROVADA** `[DECIDIDO]` (Mateus + Rico, 31-07-2026) — o preço da magia do mal é PV, à vista, sem medidor de corrupção. **A fatia 1 passa a poder usar as duas escolas.**
→ [`03-magia.md`](03-magia.md)

### 9. ~~Quantas classes no início?~~ ✅ CONFIRMADA — seis na fatia
Foram nomeadas 8. Como só jogam dois, a maior parte nunca vai ser jogada — mas todas custam trabalho.

**→ Respondida pelo Rico (30-07-2026, instrução directa): seis na fatia 1** — Guerreiro, Feiticeiro, Tanque, Assassino, Berserker, Paladino. O Batedor espera pelo arco; o Mago do mal, pela pergunta 8. Ver [`10-fatia-1.md`](10-fatia-1.md).

✅ **CONFIRMADA** `[DECIDIDO]` (Mateus + Rico, 31-07-2026) — seis classes na fatia, com o custo aceite de olhos abertos (6 habilidades + 5 conjuntos de animação). O [`64`](64-criacao-de-personagem.md) fecha a apresentação: são **presets de arranque**, nunca caminhos fechados, e só as seis prontas aparecem no primeiro ecrã.
→ [`02-personagem.md`](02-personagem.md), [`12-classes.md`](12-classes.md), [`64-criacao-de-personagem.md`](64-criacao-de-personagem.md)

### 10. ~~O que acontece quando se morre?~~ ✅ RESPONDIDA
`[DECIDIDO]` (Mateus, 31-07-2026) — **perdem-se as almas** (a moeda e a experiência ao mesmo tempo), que ficam no sítio onde se morreu; morrer outra vez antes de as apanhar perde-as de vez. Renasce-se no último ponto de descanso. **Em co-op**: ficas no mundo do parceiro e ele tem **1 minuto** para te ressuscitar, ficando **5 segundos** em cima do corpo. Detalhe em [`33-morte-e-almas.md`](33-morte-e-almas.md).

*(a pergunta original, para registo:)*
Nunca falado. É a decisão que define o tom de um souls-like: perde-se o quê, volta-se para onde, os inimigos voltam?

*Entretanto, a fatia 1 joga com renascimento na entrada, nada perdido, retry < 30 s — provisório `[FABLE]`, [`10-fatia-1.md`](10-fatia-1.md), formalizado no WP1 ([`01-combate.md`](01-combate.md), secção Morte, incluindo morte em co-op). O tom definitivo decide-se aqui.*
→ [`01-combate.md`](01-combate.md)

---

## 🟡 Precisam de resposta antes de construir

11. **Números do combate** — *ponto de partida completo escrito no WP1* `[FABLE]`: esquiva 0,60 s com 300 ms de invencibilidade, parry 133 ms, stamina 100 com custos por acção, frames das 5 armas. O [`63`](63-como-se-afinam-os-numeros.md) fecha **como** se validam: baseline, ordem causal, um valor por A/B, três sessões e artefacto; i-frames/parry não são botões de dificuldade. Os valores continuam `partida` até o `TuningRecorder` e o marco 2 os medirem — isto pede execução, não nova decisão dos donos. → [`01-combate.md`](01-combate.md), [`28-testes.md`](28-testes.md)
12. **Vida e Constituição fazem o quê, cada um?** — *respondida no WP2* `[FABLE]`: Vida = PV (margem total), Constituição = defesa por golpe (dureza). E entraram Força/Destreza para os requisitos de arma que eles pediram (06:14). → [`11-formulas.md`](11-formulas.md)
13. ~~**Hierarquia de chefes: 1+10+20+30 ou 1+30+20?**~~ ✅ **DECIDIDA 01-08** — a `[TENSÃO]` original do [`04`](04-inimigos-chefes.md) e a conta intermédia de 61 foram reclassificadas pelo Mateus no [`53`](53-chefes-ritmo-e-o-mago-forte.md): **13 chefes verdadeiros** (12 guardiões + Ultra), **12 subchefes** no mundo e **~36 nomeados** que reutilizam inimigos comuns. O [`61`](61-arenas-de-chefe.md) dá arena selada aos 13 verdadeiros e bolsa de combate fugível aos subchefes; não volta a transformar os nomeados em chefes de produção completa. → [`16-chefes.md`](16-chefes.md), [`53-chefes-ritmo-e-o-mago-forte.md`](53-chefes-ritmo-e-o-mago-forte.md)
14. **Existe armadura?** Não foi dita uma única vez. **→ Posta em formato de proposta no WP5** (A: sem sistema, vestes visuais + talismãs; B: 3 pesos que trocam i-frames por defesa; recomendação A pela Lei 4). Decisão dos dois. → [`14-equipamento.md`](14-equipamento.md)
15. **Estilo visual** — "realista não, mas tipo..." (10:24) ficou a meio da frase. **→ Proposta concreta no WP12** ([`21-arte-render.md`](21-arte-render.md): low-poly facetado, proporções 1:6,5, paleta de Brumal, referências Ashen/Absolver/Tunic), coerente com a frase de estilo do WP13. Caminho barato para o sim: gerar 3–4 conceitos com `art/prompts/` e escolherem. → [`05-mundo.md`](05-mundo.md)
21. **Tom, nome do jogo, idioma, e mais 4 perguntas de narrativa** — guião de gravação de ~15 min pronto em [`26-narrativa.md`](26-narrativa.md) §3.
16. **Lock-on em alvo?** — *respondida no WP1* `[FABLE]`: **sim** — engate a 18 m, quebra a 25 m, strafe, sem re-engate automático. A câmara do lock é do WP1B. → [`01-combate.md`](01-combate.md)
17. **Engine.** **→ Proposta escrita (WP14): Godot 4.x, renderer Mobile** — a única com medição real nas máquinas reais a favor (0b: 60 fps cravados); Unreal descartada pelo caminho feliz proibido pela Lei 4, Unity pelo peso do editor e risco de licença. Tabela completa em [`23-tecnico.md`](23-tecnico.md). Falta o carimbo dos dois — por baixo de números, não de palpite. → [`09-tecnico.md`](09-tecnico.md)
18. **Rede: P2P, relay ou servidor? E quem tem autoridade sobre o combate?** **→ Proposta escrita (WP10):** ligação directa com porta aberta (plano B: VPN de amigos tipo Tailscale), transporte agnóstico; **autoridade dividida** — anfitrião manda no mundo, cada jogador manda no próprio corpo (i-frames e parry avaliados localmente: entre amigos, a confiança é a compensação de latência). Ver [`19-rede.md`](19-rede.md). A escolha prática A/B é deles. → [`09-tecnico.md`](09-tecnico.md)
19. **Arte 3D: comprar, gerar ou fazer?** — *respondida em conjunto pelo WP13 + WP12*: modelos e ciclos base de packs CC0 (KayKit/Quaternius), Mixamo fora do repo, e **à mão o que é a alma** — telegrafias, parry, chefe. Fontes e licenças em [`22-assets.md`](22-assets.md); inventário de animações e orçamentos em [`21-arte-render.md`](21-arte-render.md). → [`09-tecnico.md`](09-tecnico.md)
20. **Fogo amigo em co-op?** **→ Proposta fechada no WP10: sem fogo amigo em nada** — com o círculo de agressão e arenas apertadas, feriria o co-op sem ganho de leitura; a Ruína continua a marcar o chão para o parceiro. Tom final é dos dois. → [`07-multiplayer.md`](07-multiplayer.md), [`19-rede.md`](19-rede.md)
22. ~~**Se os inimigos deixarem de reaparecer, de onde vêm as almas para o nível 100?**~~ ✅ **RESPONDIDA 01-08** — **a Brasa** ([`58`](58-fim-do-jogo-ciclos-e-a-curva.md) §6): queima-se numa fogueira, aquela zona sobe um ciclo, os inimigos voltam **e o contador reinicia**. ⚠️ Mas fica mais dura **para sempre** — não é grind, é **trocar dificuldade permanente por recurso**. E o nível 100 nunca é preciso: acaba-se o jogo pelo 60–70. *Registo do que era:* — o [`39-estudo-profundo.md`](39-estudo-profundo.md) §9 propõe um contador de mortes por sala (a Lei 1 posta em código: passadas N vezes, aquela sala fica limpa e não há grind possível). Isso obriga a uma de duas: ou o mundo é grande que chegue para o 100, ou **o 100 não é para atingir numa passagem**. Nenhuma é má; é escolha vossa. → [`39-estudo-profundo.md`](39-estudo-profundo.md)
23. **O contador é quanto, e conta o quê?** — proposta `[CLAUDE]`: **10, por sala, e conta o par** (não cada jogador). → [`39-estudo-profundo.md`](39-estudo-profundo.md)
24. **Chefe a dois: aceitamos +40% de vida, ou zero?** — fecha a **pergunta 6**. O jogo de referência multiplica a vida por acompanhante, e a crítica dos próprios jogadores é que fica *esponja* e **castiga quem já está a perder** (a vida extra fica lá depois de um cair). Proposta `[CLAUDE]`: **no máximo +40%, dano igual, e a escala desce quando um morre**. O [`61`](61-arenas-de-chefe.md) já fecha a parte que não depende desta resposta: espaço para 6–10 m de separação, duas rotas, um ataque **SEPARAR** e outro **JUNTAR**. A `[TENSÃO]` que sobra é só o multiplicador — decidem Mateus e Rico. → [`39-estudo-profundo.md`](39-estudo-profundo.md) §10
25. **As cargas de frasco repartem-se entre curar e usar — e se os dois ficarem desequilibrados?** — o modelo é um bolo único (~12–15) que cada um distribui no ponto de descanso entre **cura** e **energia** (magias e artes de arma). Resolve a Lei 3 de uma vez: a divisão passa a ser escolha por descanso, não escolha na criação. Em co-op, cada um reparte as suas — o que **obriga os dois a falar antes de entrar**. Boa tensão, mas é vossa. → [`39-estudo-profundo.md`](39-estudo-profundo.md) §7
26. **"Magia" e "slots de magia" são o mesmo atributo?** — o [`42-estudo-magia.md`](42-estudo-magia.md) §3 mostra que na referência **são**: um atributo dá espaços **e** energia, com tectos diferentes (espaços param aos 30, energia continua). É melhor desenho do que dois atributos, porque um só já obriga a escolher — quem quer variedade pára aos 30, quem quer lançar mais continua. Proposta `[CLAUDE]`: **fundir**. → [`40-decisoes-espolio-magia-inventario.md`](40-decisoes-espolio-magia-inventario.md) §5
27. **Força e Destreza continuam na lista de atributos?** — a lista dita a 31-07 (vida, stamina, magia, inteligência, slots, carga) não as inclui, mas o [`11-formulas.md`](11-formulas.md) já as tinha para os requisitos de arma, e o Mateus falou de destreza a seguir (espadachim). **Assumo que sim** até dizerem o contrário. → [`40-decisoes-espolio-magia-inventario.md`](40-decisoes-espolio-magia-inventario.md) §5
28. ⚠️ **Se a magia faz tudo, como é que o mago não é a classe correcta?** — `[TENSÃO]`. O Mateus quer a magia *"bem vasta: cura, dano, buffs, elementos"* — e isso, sem travão, quebra a **Lei 3** pela porta das traseiras (qualquer classe pega num cajado, mas se o cajado resolve tudo só há uma escolha certa). Proposta `[CLAUDE]` com **cinco regras** que mantêm a magia a mais rica sem a tornar a mais fácil: a energia vem do mesmo bolo que a cura · 5–6 espaços e feitiços que não repetem · tudo o que voa é interrompível e tem tempo de voo · a escola do mal custa o dobro em níveis · reforços só um de cada vez, 90 s. **Decisão dos donos.** → [`42-estudo-magia.md`](42-estudo-magia.md) §8
29. **Em co-op, o enviesamento do espólio é de quem dá o último golpe, ou partilhado?** — as cartas de enchimento são enviesadas pela classe ([`43`](43-estudo-espolio-inventario-mundo.md) §2). Com dois jogadores de classes diferentes, é preciso decidir de quem. Proposta `[CLAUDE]`: **cai uma carta para cada um, enviesada pela classe de cada um** — ninguém disputa espólio com um amigo. → [`40-decisoes-espolio-magia-inventario.md`](40-decisoes-espolio-magia-inventario.md) §11
30. ~~**O parry tem dois botões em dois documentos aprovados.**~~ ✅ **DISSOLVIDA** `[DECIDIDO]` (Mateus, 31-07) — **os controlos escolhem-se dentro do jogo** ([`45-controlos-configuraveis.md`](45-controlos-configuraveis.md)). Ficam os dois, e cada jogador escolhe o seu; um pode jogar de uma maneira e o outro da outra, na mesma partida. Deixa de ser uma escolha e passa a ser uma opção. **O que sobra:** decidir o valor de fábrica — é o que 100% dos jogadores experimenta primeiro. *Registo do que era:* O [`01-combate.md`](01-combate.md) (WP1) diz **`Q`**, botão dedicado; o [`25-controlo.md`](25-controlo.md) (WP1B) diz **toque de `RMB`**, com o bloqueio no segurar. As duas filosofias são defensáveis, e o próprio WP1B avisa que **a escolha contamina todos os testes da Lei 1** — se o parry for difícil de accionar, todo o equilíbrio do combate sai enviesado. **Não se decide no papel:** o protótipo do Rico tem as duas a um `if` de distância. **Joguem cinco minutos e decidam.** → [`44-prototipo.md`](44-prototipo.md) §4
31. ~~**Quatro acções sem tecla.**~~ ✅ **DEIXA DE TRAVAR** pela mesma decisão — levam um valor de fábrica e o jogador muda se quiser. ⚠️ **Mas o mapa de teclas do WP11 continua a ter de fechar de uma vez**, não peça a peça. *Registo:* **quatro acções sem tecla na tabela de comandos** — encontradas ao construir, não ao escrever. É a regra do [`34`](34-catalogo-e-comandos.md) §2 do Mateus a apanhar um caso real à primeira tentativa: *"não crie habilidades e depois não cria os comandos pra gente usar elas."* Seis habilidades de classe escritas no WP3, **zero formas de as activar**. O protótipo atribuiu provisórias `[PROTO]` para poder correr — **as definitivas são vossas**: habilidade de classe (`V`), conjurar magia (`C`), bash de escudo (`LMB` com bloqueio activo), andar (`Ctrl`). ⚠️ **Nota do Claude:** `C` e `Ctrl` já apareciam na lista de teclas ocupadas do [`34`](34-catalogo-e-comandos.md) §2 — o mapa de teclas do WP11 tem de fechar isto de uma vez, não peça a peça. → [`44-prototipo.md`](44-prototipo.md) §3.2
32. ⚠️ **Matar um chefe no mundo do outro muda o teu próprio mundo?** — `[TENSÃO]`. O [`19-rede.md`](19-rede.md) diz ao mesmo tempo que **o anfitrião manda no mundo**, que atalhos ficam na casa, e que um chefe vivo para os dois «conta para os dois». O formato do [`59`](59-saves.md) separa `character.boss_rewards_claimed` de `world.bosses_defeated`, mas não promove um para o outro sem ordem dos donos. **Proposta recomendada `[CODEX]`: dois saves híbridos** — o Rico recebe vitória e recompensa no mundo do Mateus, mas o mundo do Rico não abre; quando ele hospedar, o chefe ainda existe. Alternativa: um save da dupla, que evita repetir mas cria conflitos quando jogam/hospedam separados. **Decidem Mateus + Rico.**
33. ~~⚠️ **Ouvir é requisito para vencer em primeira pessoa?**~~ ✅ **RESOLVIDA 01-08** — não. O [`62`](62-acessibilidade-auditiva.md) substitui cada **tipo** de som informativo por uma forma própria com a mesma origem, resposta, compromisso e duração: cunha de ataque fora do ecrã, rasto de projéctil, área hachurada, estado no HUD, sinal de parceiro e pista física de segredo. Não é uma legenda genérica e não altera janelas nem dano. O protótipo ainda precisa do renderer; isso é construção registada no [`LACUNAS`](../LACUNAS.md), não decisão dos donos.

---

## Perdido no áudio

Estas ficaram sem registo porque o microfone do Mateus falhou. Se se lembrarem, vale a pena recuperar:

| Momento | O que se perdeu |
|---|---|
| 05:40–05:41 | A resposta do Mateus sobre drops por classe — a pergunta 5 desta lista |
| 10:44–10:56 | Um bloco inteiro de fala, logo a seguir a "como será que a gente faz o mundo?" — provavelmente a resposta à pergunta 15 |
| 07:41–07:49 | Fala durante a enumeração das classes — podem ter ficado classes por registar |
| 06:17–06:18 | Reacção ao fecho da regra das armas |
