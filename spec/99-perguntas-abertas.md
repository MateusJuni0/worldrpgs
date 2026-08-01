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

✅ **APROVADA** `[DECIDIDO]` (Mateus + Rico, 31-07-2026) — a fatia 1 é esta. É a linha que ordena todos os pacotes. ⚠️ O [`10`](10-fatia-1.md) preserva essa aprovação como camada histórica e aponta no topo para os catálogos/regras actuais; as referências antigas a cargas, seis zonas e loot sem baralho não reabrem esta decisão.
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

~~⚠️ **Diferença por acertar:** o WP8 ([`17-mundo.md`](17-mundo.md)) desenhou **6 zonas** de 2–3 min + núcleo final.~~ ✅ **Acertada e catalogada** ([`49`](49-biomas.md), [`69`](69-catalogo-do-mundo.md)): **12 biomas de 8–12 min numa rede compacta**, não doze em linha. As 21 ligações dão diâmetro de três travessias; Costa Quebrada (11) + Cimeira (10) + Fulgor (9) provam o alvo de **30 min**. A conta de encontros fica 1 Ultra + 12 guardiões + 12 subchefes + ~36 nomeados = **61**.
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

**→ Contrato executável (WP5):** Frasco de Bruma — 3 cargas, 40% de vida por gole, 1,2 s a beber a 50% de movimento, recarrega ao descansar; ampliações escondidas no mundo em vez de stock comprável (poções finitas convidam ao farm, que a Lei 1 proíbe). O **modelo** está aprovado; os números são baselines `[FABLE]` sujeitos ao protocolo de feel. Ver [`14-equipamento.md`](14-equipamento.md).
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
`[DECIDIDO]` (Mateus, 31-07-2026) — **perdem-se as almas** (a moeda e a experiência ao mesmo tempo), que ficam no sítio onde se morreu; morrer outra vez antes de as apanhar perde-as de vez. Renasce-se no último ponto de descanso. **Em co-op**: ficas no mundo do parceiro e ele tem **1 minuto** para te ressuscitar, canalizando **5–7 segundos** em cima do corpo. Detalhe em [`33-morte-e-almas.md`](33-morte-e-almas.md) e [`34`](34-catalogo-e-comandos.md) §3.

*(a pergunta original, para registo:)*
Nunca falado. É a decisão que define o tom de um souls-like: perde-se o quê, volta-se para onde, os inimigos voltam?

**→ Contrato corrente:** renascimento no último descanso; almas numa mancha persistida atomicamente; segunda morte substitui-a; em co-op há 1 minuto para ressuscitar durante **5–7 s**. O retry de chefe continua < 30 s. Ver [`33`](33-morte-e-almas.md), [`34`](34-catalogo-e-comandos.md) §3 e [`59`](59-saves.md).
→ [`01-combate.md`](01-combate.md)

---

## 🟡 Precisam de resposta antes de construir

11. **Números do combate** — *baseline canónico no [`70`](70-fecho-dos-sistemas-de-combate.md)* `[CODEX]`: esquiva 0,60 s com frames 5–23 inclusivos de invencibilidade (**317 ms**), parry **8/8/40**, stamina 100 e curvas próprias por atributo. O [`63`](63-como-se-afinam-os-numeros.md) fecha **como** se valida feel: baseline, ordem causal, um valor por A/B, três sessões e artefacto; i-frames/parry não são botões de dificuldade. Os números executáveis passam **8559 testes**, mas continuam ponto de partida até o `TuningRecorder` e o marco 2 os medirem a jogar. → [`70`](70-fecho-dos-sistemas-de-combate.md), [`28-testes.md`](28-testes.md)
12. **Vida e Constituição fazem o quê, cada um?** — *respondida no WP2* `[FABLE]`: Vida = PV (margem total), Constituição = defesa por golpe (dureza). E entraram Força/Destreza para os requisitos de arma que eles pediram (06:14). → [`11-formulas.md`](11-formulas.md)
13. ~~**Hierarquia de chefes: 1+10+20+30 ou 1+30+20?**~~ ✅ **DECIDIDA 01-08** — a `[TENSÃO]` original do [`04`](04-inimigos-chefes.md) e a conta intermédia de 61 foram reclassificadas pelo Mateus no [`53`](53-chefes-ritmo-e-o-mago-forte.md): **13 chefes verdadeiros** (12 guardiões + Ultra), **12 subchefes** no mundo e **~36 nomeados** que reutilizam inimigos comuns. O [`61`](61-arenas-de-chefe.md) dá arena selada aos 13 verdadeiros e bolsa de combate fugível aos subchefes; não volta a transformar os nomeados em chefes de produção completa. → [`16-chefes.md`](16-chefes.md), [`53-chefes-ritmo-e-o-mago-forte.md`](53-chefes-ritmo-e-o-mago-forte.md)
14. ~~**Existe armadura?**~~ ✅ **DECIDIDA pelo Mateus** — por peças, nove slots, carga leve/média/pesada e resistências por tipo; o peso muda recuperação/regen, **nunca os i-frames**. O [`68`](68-catalogo-de-armas-armaduras-e-aneis.md) fecha 68 peças. → [`33`](33-morte-e-almas.md), [`51`](51-familias.md)
15. **Estilo visual** — "realista não, mas tipo..." (10:24) ficou a meio da frase. **→ Proposta concreta no WP12** ([`21-arte-render.md`](21-arte-render.md): low-poly facetado, proporções 1:6,5, paleta de Brumal, referências Ashen/Absolver/Tunic), coerente com a frase de estilo do WP13. Caminho barato para o sim: gerar 3–4 conceitos com `art/prompts/` e escolherem. → [`05-mundo.md`](05-mundo.md)
21. **Tom, nome do jogo, idioma, e mais 4 perguntas de narrativa** — guião de gravação de ~15 min pronto em [`26-narrativa.md`](26-narrativa.md) §3.
16. **Lock-on em alvo?** — *respondida no WP1* `[FABLE]`: **sim** — engate a 18 m, quebra a 25 m, strafe, sem re-engate automático. A câmara do lock é do WP1B. → [`01-combate.md`](01-combate.md)
17. **Engine.** **→ Proposta escrita (WP14): Godot 4.x, renderer Mobile** — a única com medição real nas máquinas reais a favor (0b: 60 fps cravados); Unreal descartada pelo caminho feliz proibido pela Lei 4, Unity pelo peso do editor e risco de licença. Tabela completa em [`23-tecnico.md`](23-tecnico.md). Falta o carimbo dos dois — por baixo de números, não de palpite. → [`09-tecnico.md`](09-tecnico.md)
18. **Rede: P2P, relay ou servidor? E quem tem autoridade sobre o combate?** **→ Proposta escrita (WP10):** ligação directa com porta aberta (plano B: VPN de amigos tipo Tailscale), transporte agnóstico; **autoridade dividida** — anfitrião manda no mundo, cada jogador manda no próprio corpo (i-frames e parry avaliados localmente: entre amigos, a confiança é a compensação de latência). Ver [`19-rede.md`](19-rede.md). A escolha prática A/B é deles. → [`09-tecnico.md`](09-tecnico.md)
19. **Arte 3D: comprar, gerar ou fazer?** — *respondida em conjunto pelo WP13 + WP12*: modelos e ciclos base de packs CC0 (KayKit/Quaternius), Mixamo fora do repo, e **à mão o que é a alma** — telegrafias, parry, chefe. Fontes e licenças em [`22-assets.md`](22-assets.md); inventário de animações e orçamentos em [`21-arte-render.md`](21-arte-render.md). → [`09-tecnico.md`](09-tecnico.md)
20. **Fogo amigo em co-op?** **→ Proposta fechada no WP10: sem fogo amigo em nada** — com o círculo de agressão e arenas apertadas, feriria o co-op sem ganho de leitura; a Ruína continua a marcar o chão para o parceiro. Tom final é dos dois. → [`07-multiplayer.md`](07-multiplayer.md), [`19-rede.md`](19-rede.md)
22. ~~**Se os inimigos deixarem de reaparecer, de onde vêm as almas para o nível 100?**~~ ✅ **RESPONDIDA 01-08** — **a Brasa** ([`58`](58-fim-do-jogo-ciclos-e-a-curva.md) §6): queima-se numa fogueira, aquela zona sobe um ciclo, os inimigos voltam **e o contador reinicia**. ⚠️ Mas fica mais dura **para sempre** — não é grind, é **trocar dificuldade permanente por recurso**. E o nível 100 nunca é preciso: acaba-se o jogo pelo 60–70. *Registo do que era:* — o [`39-estudo-profundo.md`](39-estudo-profundo.md) §9 propõe um contador de mortes por sala (a Lei 1 posta em código: passadas N vezes, aquela sala fica limpa e não há grind possível). Isso obriga a uma de duas: ou o mundo é grande que chegue para o 100, ou **o 100 não é para atingir numa passagem**. Nenhuma é má; é escolha vossa. → [`39-estudo-profundo.md`](39-estudo-profundo.md)
> **Correcção da Tarefa 4 à resposta 22:** a Brasa continua a subir uma zona irreversivelmente, mas não pode ser comprada e não repõe rendimento já esgotado: limpeza já recompensada dá zero almas e o baralho não reinicia. Assim não se usa uma resposta anti-grind como motor de farm. Ver [`70`](70-fecho-dos-sistemas-de-combate.md) §5.

23. **O contador é quanto, e conta o quê?** — o [`67`](67-catalogo-do-bestiario.md) fixa 10 cartas por **tipo** e o [`72`](72-materiais-consumiveis-e-economia.md) executa essa torneira independentemente da política de reaparecimento. Continua por decidir se o contador que remove corpos do mapa é **por sala, por tipo ou por indivíduo**, e se conta o par; proposta `[CLAUDE]`: **10 por sala, conta o par**. A pergunta já não bloqueia a recompensa; bloqueia quando uma colocação deixa de reaparecer. → [`39-estudo-profundo.md`](39-estudo-profundo.md), [`67`](67-catalogo-do-bestiario.md) §5–6
24. **Chefe a dois: aceitamos +40% de vida, ou zero?** — fecha a **pergunta 6**. O jogo de referência multiplica a vida por acompanhante, e a crítica dos próprios jogadores é que fica *esponja* e **castiga quem já está a perder** (a vida extra fica lá depois de um cair). Proposta `[CLAUDE]`: **no máximo +40%, dano igual, e a escala desce quando um morre**. O [`61`](61-arenas-de-chefe.md) já fecha a parte que não depende desta resposta: espaço para 6–10 m de separação, duas rotas, um ataque **SEPARAR** e outro **JUNTAR**. A `[TENSÃO]` que sobra é só o multiplicador — decidem Mateus e Rico. → [`39-estudo-profundo.md`](39-estudo-profundo.md) §10
25. ~~**As cargas de frasco repartem-se entre curar e usar?**~~ ✅ **SUPERADA 01-08** — o Mateus revogou o bolo partilhado no [`54`](54-mana-meditacao-e-tracos-de-classe.md): cura continua no frasco; feitiços e artes gastam mana; meditar não repõe frascos. O [`66`](66-catalogo-de-magia.md) acrescenta duas tentativas de meditação por descanso sem alterar os 40 s/100% decididos. O texto do [`39`](39-estudo-profundo.md) fica apenas como estudo histórico.
26. ~~**“Magia” e “slots de magia” são o mesmo atributo?**~~ ✅ **DISSOLVIDA 01-08** — **não existem slots.** Há Inteligência e Fé, uma reserva de mana calculada pelo maior dos dois e oito favoritos que só mudam fora de combate/no descanso. → [`54`](54-mana-meditacao-e-tracos-de-classe.md), [`66`](66-catalogo-de-magia.md)
27. **Força e Destreza continuam na lista de atributos?** — a lista dita a 31-07 (vida, stamina, magia, inteligência, slots, carga) não as inclui, mas o [`11-formulas.md`](11-formulas.md) já as tinha para os requisitos de arma, e o Mateus falou de destreza a seguir (espadachim). **Assumo que sim** até dizerem o contrário. → [`40-decisoes-espolio-magia-inventario.md`](40-decisoes-espolio-magia-inventario.md) §5
28. ⚠️ **Se a magia faz tudo, como é que o mago não é a classe correcta?** — `[TENSÃO]`, **não resolvida pelo catálogo**. O Mateus quer a magia *“bem vasta: cura, dano, buffs, elementos”* — e isso, sem travão, quebra a **Lei 3** pela porta das traseiras. O modelo actual já traz cinco custos observáveis: mana sem regeneração · lançamento interrompível com deslocação real · Escola vermelha escala pelo menor de Int/Fé e paga PV em necromancia · apenas um reforço de arma activo · oito favoritos fixos durante combate. A forma de arma remove a fraqueza artificial “mago nunca luta perto”, por isso não serve como travão. **Falta Mateus + Rico dizerem se estes custos chegam ou se querem outro limite; não se fecha aqui.** → [`42`](42-estudo-magia.md) §8, [`54`](54-mana-meditacao-e-tracos-de-classe.md), [`66`](66-catalogo-de-magia.md)
29. **Em co-op, o enviesamento do espólio é de quem dá o último golpe, ou partilhado?** — os 33 baralhos do [`67`](67-catalogo-do-bestiario.md) reservam `bias:classe` apenas no enchimento, sem escolher o dono da carta. O [`72`](72-materiais-consumiveis-e-economia.md) já fecha a infraestrutura: a transacção recebe explicitamente a classe do destinatário e nunca infere propriedade. Com dois jogadores de classes diferentes, falta decidir quantos destinatários a rede chama. Proposta `[CLAUDE]`: **cai uma carta para cada um, enviesada pela classe de cada um** — ninguém disputa espólio com um amigo. A política continua dos donos; já não bloqueia o save local nem o catálogo. → [`40-decisoes-espolio-magia-inventario.md`](40-decisoes-espolio-magia-inventario.md) §11
30. ~~**O parry tem dois botões em dois documentos aprovados.**~~ ✅ **DISSOLVIDA** `[DECIDIDO]` (Mateus, 31-07) — **os controlos escolhem-se dentro do jogo** ([`45-controlos-configuraveis.md`](45-controlos-configuraveis.md)). Ficam os dois, e cada jogador escolhe o seu; um pode jogar de uma maneira e o outro da outra, na mesma partida. Deixa de ser uma escolha e passa a ser uma opção. **O que sobra:** decidir o valor de fábrica — é o que 100% dos jogadores experimenta primeiro. *Registo do que era:* O [`01-combate.md`](01-combate.md) (WP1) diz **`Q`**, botão dedicado; o [`25-controlo.md`](25-controlo.md) (WP1B) diz **toque de `RMB`**, com o bloqueio no segurar. As duas filosofias são defensáveis, e o próprio WP1B avisa que **a escolha contamina todos os testes da Lei 1** — se o parry for difícil de accionar, todo o equilíbrio do combate sai enviesado. **Não se decide no papel:** o protótipo do Rico tem as duas a um `if` de distância. **Joguem cinco minutos e decidam.** → [`44-prototipo.md`](44-prototipo.md) §4
31. ~~**Quatro acções sem tecla.**~~ ✅ **DEIXA DE TRAVAR** pela mesma decisão — levam um valor de fábrica e o jogador muda se quiser. ⚠️ **Mas o mapa de teclas do WP11 continua a ter de fechar de uma vez**, não peça a peça. *Registo:* **quatro acções sem tecla na tabela de comandos** — encontradas ao construir, não ao escrever. É a regra do [`34`](34-catalogo-e-comandos.md) §2 do Mateus a apanhar um caso real à primeira tentativa: *"não crie habilidades e depois não cria os comandos pra gente usar elas."* Seis habilidades de classe escritas no WP3, **zero formas de as activar**. O protótipo atribuiu provisórias `[PROTO]` para poder correr — **as definitivas são vossas**: habilidade de classe (`V`), conjurar magia (`C`), bash de escudo (`LMB` com bloqueio activo), andar (`Ctrl`). ⚠️ **Nota do Claude:** `C` e `Ctrl` já apareciam na lista de teclas ocupadas do [`34`](34-catalogo-e-comandos.md) §2 — o mapa de teclas do WP11 tem de fechar isto de uma vez, não peça a peça. → [`44-prototipo.md`](44-prototipo.md) §3.2
32. ⚠️ **Matar um chefe no mundo do outro muda o teu próprio mundo?** — `[TENSÃO]`. O [`19-rede.md`](19-rede.md) diz ao mesmo tempo que **o anfitrião manda no mundo**, que atalhos ficam na casa, e que um chefe vivo para os dois «conta para os dois». O formato do [`59`](59-saves.md) separa `character.boss_rewards_claimed` de `world.bosses_defeated`, mas não promove um para o outro sem ordem dos donos. **Proposta recomendada `[CODEX]`: dois saves híbridos** — o Rico recebe vitória e recompensa no mundo do Mateus, mas o mundo do Rico não abre; quando ele hospedar, o chefe ainda existe. Alternativa: um save da dupla, que evita repetir mas cria conflitos quando jogam/hospedam separados. **Decidem Mateus + Rico.**
33. ~~⚠️ **Ouvir é requisito para vencer em primeira pessoa?**~~ ✅ **RESOLVIDA 01-08** — não. O [`62`](62-acessibilidade-auditiva.md) define a equivalência e o [`67`](67-catalogo-do-bestiario.md) constrói `GameplayCue`: faixa/área, glifo de resposta e cunha de bordo partilham origem, compromisso e duração com cinco famílias sonoras. Não é legenda genérica e não altera janelas nem dano. Falta o banco jogado sem som de WP15B, não uma decisão dos donos.
34. **Quem compõe/selecciona a música, e qual é o idioma musical?** — o inventário do [`65`](65-musica-e-ambiente.md) prova que os 182 OGG trazem **zero faixas**. O sistema e o orçamento estão fechados (6 peças + 3 stingers, loops/stems, transições e espaço para telegrafia). **Recomendação `[CODEX]`: música original de baixa densidade entregue em stems**, porque encaixa fases e reserva espaço aos cues; CC0/CC-BY continua opção se cumprir o mesmo contrato. A autoria e direcção criativa são decisão de Mateus + Rico, não do agente.
35. **Quem dá ordens aos invocados em co-op?** — a escola vermelha permite vários mortos e os dois jogadores podem aprendê-la. Proposta `[CODEX]`: cada invocado obedece a quem o levantou; autoridade e limite visual ficam associados a esse `profile_id`. Alternativa: o anfitrião comandar todos, que simplifica rede mas rouba o verbo ao convidado. **Decidem Mateus + Rico.** → [`52`](52-mago-do-mal.md) §9, [`66`](66-catalogo-de-magia.md)
36. **O Mago do mal é uma origem própria ou qualquer origem com a Escola vermelha?** — o [`54`](54-mana-meditacao-e-tracos-de-classe.md) deixou esta linha aberta e o [`66`](66-catalogo-de-magia.md) só fecha a escola, não a classe. Isto muda a ficha inicial, o traço de +40% de mana e o ecrã do [`64`](64-criacao-de-personagem.md). **Decidem Mateus + Rico.**
37. **O Mateus confirma a proposta do Assassino do [`68`](68-catalogo-de-armas-armaduras-e-aneis.md) §5?** — Rico pediu furtividade, velocidade, sangramento e duas adagas. A proposta passa os três guardas: Passo Mudo sem IA nova · Corte Alternado em vez de +X% · Cruz Carmesim/Entre Sombras aprendíveis por qualquer origem. O catálogo e os testes podem existir; **marcar a identidade como decidida espera o Mateus.**
38. **O mapa abre por zona com índice, ou mostra o mundo inteiro? E escreve nomes de biomas ainda não visitados?** — o [`69`](69-catalogo-do-mundo.md) não precisou de escolher: a vista inclinada, os patamares e a regra “só terreno percorrido” funcionam nos dois escopos. Proposta `[CLAUDE]`: **mapa por zona com índice**, nomes só depois de vistos; reduz sobreposição e não transforma um nome futuro em seta. **Decidem Mateus + Rico.**
39. **Os vendedores podem morrer? Se morrerem, o stock desaparece ou passa para outro ponto de descanso?** — isto é irreversível e pode apagar acesso a conteúdo já desbloqueado. Proposta `[CODEX]`: não morrem por dano acidental; consequências narrativas só depois de confirmação explícita e nunca destroem tomos entregues. Alternativa: morte permanente com stock perdido, mais fiel à referência e mais hostil. **Decidem Mateus + Rico.** → [`56`](56-voz-e-vendedores.md)
40. **O Coveiro vende só a quem usa a Escola vermelha?** — limitar pela origem/classe viola a Lei 3; limitar por um verbo aprendido ou por encontrar o relicário preserva descoberta sem caminho fechado. Proposta `[CODEX]`: qualquer origem pode aceder depois de descobrir a Escola vermelha. A identidade do vendedor e a regra final são dos dois. **Decidem Mateus + Rico.** → [`52`](52-mago-do-mal.md), [`56`](56-voz-e-vendedores.md)

41. ⚠️ **As melhorias de feitiço cumprem a decisão dos três eixos ou a Lei 2?** — `[TENSÃO]`. O Mateus decidiu **força, área e lançamentos** ([`40`](40-decisoes-espolio-magia-inventario.md) §10), mas a Lei 2 proíbe melhorias que sejam só números. Hoje 53/53 níveis `+1` são redução directa do custo de mana e o catálogo não contém o eixo “força”; os níveis seguintes reutilizam quatro moldes genéricos que nem sempre descrevem o feitiço. **Proposta:** interpretar os três eixos como escolhas com troca visível — potência por alcance/tempo/risco, área por concentração e lançamentos por condição executada — nunca como aumento líquido. **Recomendação `[CODEX]`:** conservar os três eixos, mas exigir que todo o número venha emparelhado com uma perda ou um verbo; remover a redução incondicional de mana. Mateus + Rico decidem se “força/lançamentos” autorizava números líquidos ou se a Lei 2 prevalece. → [`66`](66-catalogo-de-magia.md) §7 · `spells.json`

42. ⚠️ **Qual Voto de Sangue é o decidido?** — `[TENSÃO]`. O Mateus decidiu explicitamente até três camadas por **+30/+60/+90% de dano** ([`52`](52-mago-do-mal.md) §§8, 12); o [`53`](53-chefes-ritmo-e-o-mago-forte.md) e `spells.json` substituem isso por **perfurar · chão a arder · mortos que explodem** para cumprir a Lei 2, mas a substituição está marcada `[CLAUDE]`, não `[DECIDIDO]`. **Proposta e recomendação `[CODEX]`:** aprovar a versão por verbos, porque preserva o custo de vida e a fantasia “apelona” sem criar melhoria numérica proibida. Até Mateus + Rico confirmarem, os dados são uma implementação provisória, não uma decisão retroactiva.

43. ⚠️ **A afinidade elemental do escudo pertence à família ou ao escudo individual?** — `[TENSÃO]` de execução. Está `[DECIDIDO]` que escudos diferem por elemento ([`37`](37-aneis-e-elementos.md) §2), mas `weapons.json` só diferencia estabilidade/físico e o runtime usa absorção mágica global de 50%. **Proposta e recomendação `[CODEX]`:** família define parry, estabilidade, deflexão e físico; cada instância define o mapa fogo/raio/mágico/escuridão. Assim um escudo grande não fica preso para sempre a um elemento e a decisão produz escolhas reais. Mateus + Rico confirmam o eixo antes de se inventarem os valores.

44. ⚠️ **O alvo é ~30 armaduras ou o catálogo corrente de 68 peças?** — `[TENSÃO]` de escopo. O Mateus decidiu **~30 armaduras, cada uma com identidade própria** ([`34`](34-catalogo-e-comandos.md) §1), mas o [`68`](68-catalogo-de-armas-armaduras-e-aneis.md) materializou **68 peças**: 11 iniciais + 57 IDs de equipamento visível que o bestiário já prometia largar. A matriz de coerência [`46`](46-coerencia-bioma-raca-item.md) também dependia do alvo original. **Proposta:** ou Mateus + Rico aceitam explicitamente as 68, ou o catálogo consolida vários IDs visuais em peças partilhadas/variantes até regressar a ~30 sem quebrar «larga o que se vê». **Recomendação `[CODEX]`:** manter só as 11 da Fatia 1 agora e, antes de produzir as outras 57, rever o catálogo por famílias visuais para aproximar o alvo de ~30; só conservar 68 quando uma peça responder a uma escolha distinta, não apenas a outro nome.

45. ⚠️ **Quando é que uma habilidade de classe compromete, pode ser interrompida e começa o cooldown? E o que repete exactamente o Eco?** — `[TENSÃO]` de execução. `abilities.json` já declara os seis verbos, custos, durações e cooldowns dedutíveis, mas não existe um contrato comum de `activation_s`, `interruptible`, `commit_point` e `cooldown_starts`; no Eco também faltam alvo, validade e custos não-mana. **Proposta e recomendação `[CODEX]`:** o Eco repete o último feitiço que chegou ao compromisso, usa alvo/mira actuais, repete o tempo e a interrupção normais, custa zero mana mas preserva PV/cadáver/item exigidos; sem alvo ou recurso válido não activa nem inicia cooldown. Nas outras cinco, o cooldown começa no compromisso e cada ficha tem de declarar os quatro campos antes do runtime. Mateus + Rico confirmam sobretudo se Eco conserva os custos não-mana.

46. ⚠️ **Qual é o contrato físico dos projécteis e das doze formas de entrega?** — `[TENSÃO]` de execução. Cinco ataques inimigos usam `tiro` sem velocidade, raio, gravidade ou vida; quatro usam `perseguidor` sem velocidade, rotação, raio ou vida. Os 53 feitiços nomeiam doze formas, mas forma não define colisão, cadência, distribuição de chuva, pulso, expiração nem reacção a cobertura. **Proposta `[CODEX]`:** uma ficha de forma comum declara `speed_m_s`, `turn_deg_s`, `gravity_m_s2`, `collision_radius_m`, `lifetime_s`, `hit_policy`, `count`, `cadence_s` e `pulse_s`, usando `null` só quando o campo não se aplica; cada ataque só substitui diferenças. **Recomendação:** fechar e provar primeiro `projectil_simples`, `perseguidor`, `orbitante` e `volume_persistente` com Dardo, Égide, Ruína e um ataque inimigo; nenhuma das outras formas entra em produção enquanto tiver parâmetros implícitos. → [`36-fisica.md`](36-fisica.md), [`66`](66-catalogo-de-magia.md), [`67`](67-catalogo-do-bestiario.md)

47. ⚠️ **Os cinco `acessorio:*` garantidos são anéis, itens de mão ou uma quarta categoria de equipamento?** — `[TENSÃO]` e dependência partida. Quatro sinos e `lanterna_violeta_antiga` são recompensas obrigatórias dos baralhos, mas não têm catálogo, slot, efeito nem cliente de inventário. A lanterna da Raiz também promete ocupar a mão esquerda. **Proposta e recomendação `[CODEX]`:** criar a categoria `accessories` com `slot`, `effect_type`, números e origem; sinos usam slot de acessório passivo, a lanterna usa `left_hand` e exclui escudo/arma secundária. Se os sinos forem apenas anéis, migrar já o prefixo e os cinco IDs em vez de manter uma quarta categoria vazia. Mateus + Rico escolhem a fantasia e o slot antes de produzir os objectos.

48. ⚠️ **`afinidade` dos anéis é etiqueta, classe ou restrição?** — `[TENSÃO]` de namespace. O catálogo usa as seis classes, `batedor`, `mago_do_mal` e `universal`, mas não existe catálogo de etiquetas nem regra que diga se afinidade altera peso de drop, descrição, efeito ou possibilidade de equipar. Interpretá-la como requisito quebraria a Lei 3. **Proposta e recomendação `[CODEX]`:** afinidade é apenas etiqueta de recomendação e enviesamento de espólio, nunca gating; criar `_affinity_tags` com os nove IDs e validar todos os consumidores contra ele. Mateus + Rico confirmam se a etiqueta tem algum efeito mecânico adicional.

49. ⚠️ **Quais são os 18 parâmetros ainda em falta nas ameaças ambientais?** — `[TENSÃO]` de execução. A Revisão 2 materializou todos os números já escritos em `world.json` e enumerou o resto em `unresolved_parameters`: rotação/controlo da bruma, resets, dardos, faixa/intervalo do vento, dano/intervalo do raio, volume dos esporos, velocidade em água, limiar de cegueira e ID da lanterna. **Proposta `[CODEX]`:** afinar uma ameaça de cada família na cena de teste, gravar os números na ficha e exigir `unresolved_parameters: []` como gate da respectiva zona. **Recomendação:** Brumal primeiro; nenhuma zona é considerada construível enquanto a lista dela não estiver vazia.

50. ⚠️ **O streaming conserva todas as vizinhas da zona actual, ou apenas a transição escolhida?** — `[TENSÃO]` de Lei 4. O contrato diz `actual_e_vizinhas_imediatas`; no Fojo isso significa seis zonas residentes. O único tecto é 2,5 GB global, sem orçamento por zona, e a Iris Xe partilha os 8 GB de RAM. **Proposta e recomendação `[CODEX]`:** manter zona actual + uma vizinha de transição; descarregar as restantes, conservar apenas estado lógico e reservar no máximo 1,6 GB para mundo/arte, deixando margem ao runtime, áudio e sistema. Se todas as vizinhas tiverem de ficar residentes, cada zona do pior nó recebe tecto aproximado de 400 MB e a prova tem de existir antes da segunda zona final.

51. ⚠️ **O limite de invocados é de design ou um orçamento global de actores?** — `[TENSÃO]` de Lei 4. A Escola vermelha diz que não há limite de design, enquanto os presets técnicos admitem 8/5/3 personagens animadas. Um combate máximo já usa 2 jogadores + 5 inimigos = 7; sobra um actor antes de invocações de ambos, chefe portátil ou efeitos com esqueleto. **Proposta e recomendação `[CODEX]`:** um orçamento global por máquina; no preset Rico há oito actores animados, invocados ocupam vagas e o feitiço falha de forma legível quando não existe vaga. A autoridade continua por `profile_id` conforme a pergunta 35; Mateus + Rico decidem se um invocado novo substitui o mais antigo ou se o lançamento fica bloqueado.

52. ⚠️ **Quem são e onde vivem os onze guardiões e doze subchefes ainda sem ficha?** — `[TENSÃO]` de conteúdo com dependência técnica. `world.json` promete um de cada por zona; só Vorgar resolve para uma ficha. A Revisão 2 normalizou o slot partido de Fojo para `guardiao_fojo_wp7`, mas os onze guardiões continuam placeholders e os doze subchefes nem têm IDs. **Proposta `[CODEX]`:** reservar já `guardiao_<bioma>_wp7` e `subchefe_<bioma>_wp7`, com `implemented:false`, e bloquear o gate de densidade de cada zona até a ficha, arena/bolsa, loot e teste existirem. Identidade, história e verbos são gravação de Mateus + Rico; os placeholders não fingem conteúdo.

53. ⚠️ **Como termina o ciclo de percepção, alerta, chamada e desistência dos inimigos?** — `[TENSÃO]` de IA. A tabela do [`15`](15-inimigos.md) fecha cone/alcance auditivo, 2 s de alerta, chamada 10 m/0,8 s e desistência 6 s/30 m, mas dizia “dois passos” sem distância e “cura ao chegar” sem velocidade, quantidade, tempo ou regra de reaquisição. O runtime corrente salta directamente de raio de aggro para perseguição e abandona no leash, sem LOS, audição, chamada, regresso a casa nem cura. **Proposta `[CODEX]`:** avanço de alerta 2 m; regresso à velocidade de perseguição; ao chegar a ≤1,2 m de `home`, pulso visual de 1 s repõe 100% da vida e só depois reabre percepção. Dano durante regresso volta a confirmar o alvo. Mateus + Rico confirmam sobretudo a cura total e a reaquisição; depois os campos vivem em `_enemy_defaults` e o teste cobre a máquina inteira.

54. ⚠️ **As 57 armaduras futuras têm habilidade própria ou só resistências/peso?** — `[TENSÃO]` semântica e de escopo, ligada à pergunta 44. As 11 peças iniciais dizem honestamente `nenhuma`; as outras 57 repetem “permite escolher uma resposta de <slot>” sem dizer qual resposta, trigger, efeito, custo ou cliente. São placeholders com aspecto de regra pronta. **Proposta e recomendação `[CODEX]`:** cada peça futura ou declara `effect_type: none`, ou liga um `effect_type` estruturado a um sistema já existente com condição/números/saída; peças que não criem uma escolha distinta são variante visual consolidada. Não produzir as 57 antes de fechar 44+54.

55. ⚠️ **Um anel pode inventar um verbo ou serviço que o jogo não tem?** — `[TENSÃO]` de dependências. Os 70 anéis têm números, mas só prosa para o efeito e nenhum `effect_type`/consumidor. Pelo menos `salto_de_cabra`, `fio_de_vento` e `corda_do_naufrago` reintroduzem agarrar/saltar/escalar contra a travessia fechada; `companhia_vazia` e `mapa_dos_caidos` dependem de sinais/jogadores públicos que o co-op privado não define. **Proposta e recomendação `[CODEX]`:** anéis só subscrevem um vocabulário fechado de eventos/sistemas existentes; nenhum cria travessia ou matchmaking. Adicionar `effect_type` + cliente validado, substituir os cinco exemplos incompatíveis e só então implementar os restantes. Mateus + Rico confirmam se querem abrir alguma dessas capacidades como sistema global.

56. ⚠️ **O que é um instrumento mágico como item executável?** — `[TENSÃO]` de equipamento/magia. A spec diz que força e velocidade vivem no instrumento; `spells.json` exige cajado, sino, talismã, chama, relicário ou híbrido. O catálogo só tem a família cajado, sem `spell_power` nem multiplicador de lançamento, e o runtime usa dano/tempo fixos do feitiço. Não existem instâncias, slots, mãos, escalas ou animações para os outros cinco. **Proposta e recomendação `[CODEX]`:** todo instrumento é ficha de equipamento com `instrument_type`, `school_tags`, `slot`, `hands`, `spell_power` e `cast_speed_multiplier_by_form`; cajado da Fatia 1 fixa o baseline 1,0 e os restantes só entram depois de um spike sino/talismã. Mateus + Rico decidem sobretudo se sino/chama/relicário ocupam mão secundária ou principal e se a fórmula do instrumento substitui o `base_damage` corrente.

---

## Perdido no áudio

Estas ficaram sem registo porque o microfone do Mateus falhou. Se se lembrarem, vale a pena recuperar:

| Momento | O que se perdeu |
|---|---|
| 05:40–05:41 | A resposta do Mateus sobre drops por classe — a pergunta 5 desta lista |
| 10:44–10:56 | Um bloco inteiro de fala, logo a seguir a "como será que a gente faz o mundo?" — provavelmente a resposta à pergunta 15 |
| 07:41–07:49 | Fala durante a enumeração das classes — podem ter ficado classes por registar |
| 06:17–06:18 | Reacção ao fecho da regra das armas |
