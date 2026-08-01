# 64 — Criação de personagem: escolher um começo, não uma prisão

> **Tarefa 2.4 · Codex** (01-08-2026). Este é o primeiro ecrã de um **jogo novo**: classe, aspecto, voz e nome antes de carregar Brumal. Herda as seis fichas do [`12`](12-classes.md), os kits do [`51`](51-familias.md), a interface do [`20`](20-interface.md) e o save do [`59`](59-saves.md). Tudo `[CODEX]` salvo indicação.

**Regra-mãe:** a classe é um **preset de arranque**, nunca um caminho fechado. Escolhe o que trazes no minuto zero; não decide no que te podes tornar.

`[CODEX]` **Razão:** a primeira escolha tem de ensinar diferenças reais sem pedir a um jogador novo que adivinhe o futuro. **Alternativa descartada:** seis classes fechadas com armas, magia, espólio ou conteúdo exclusivo; contradiz a Lei 3 e transforma uma escolha sem informação numa dívida de dezenas de horas.

---

## 1. Quando abre e quando o mundo começa

```text
Arranque
  → menu principal
  → Novo personagem
  → escolher slot livre
  → CRIAÇÃO: classe → aspecto/voz → nome → rever
  → confirmar e gravar atomicamente
  → carregar Brumal no último ponto inicial
```

- É o primeiro ecrã **do percurso Novo personagem**. Não há cinemática, lore ou carregamento do mundo antes dele.
- No primeiro arranque, o atalho **Acessibilidade** fica sempre visível no topo e abre as opções do [`62`](62-acessibilidade-auditiva.md) sem perder escolhas. Não se obriga a ouvir um som para configurar o jogo.
- Voltar ao menu conserva o rascunho apenas nessa execução; sair do jogo descarta-o. Um rascunho nunca é um save.
- O mundo só carrega depois de o `SaveSystem` confirmar a escrita. Se falhar, a criação fica no ecrã com as escolhas intactas e explica o erro.
- Um slot ocupado nunca é substituído por este fluxo. Apagar/substituir save é outra acção, com confirmação explícita no menu de slots.

O caminho principal cabe num único ecrã a 1920×1080, sem assistente de cinco páginas: mudar de separador não esconde o boneco nem a frase da Lei 3.

---

## 2. O ecrã — três zonas e quatro passos

| Zona | Conteúdo | Regra |
|---|---|---|
| **esquerda · 360 px** | passos `1 Classe · 2 Aspecto · 3 Nome · 4 Rever` e as opções do passo | teclado e rato chegam a tudo; foco visível |
| **centro · 760 px** | personagem 3D inteiro; roda ±180°, zoom corpo/rosto, alterna `com kit`/`sem elmo` | só carrega a variante seleccionada |
| **direita · 560 px** | o que a escolha muda, o que não bloqueia, kit e validação | nunca depende só de cor ou ícone |

Barra inferior: `Voltar` · `Anterior` · `Seguinte`; no passo 4, `Criar personagem`. `Enter` avança, `Esc` volta, setas navegam, `Tab/Shift+Tab` percorre os controlos e o rato é opcional. Os nomes das teclas vêm do mapa configurável do [`45`](45-controlos-configuraveis.md), nunca de texto fixo.

**Não há valores aleatórios.** Reabrir o passo dá exactamente o que foi escolhido. **Não há botão “classe recomendada”**: o jogo ainda não conhece o jogador e não inventa uma resposta certa.

### Tempo-alvo

- quem aceita as omissões cria em **≤ 45 s**;
- quem lê as seis fichas e personaliza cria em **≤ 3 min**;
- nenhuma contagem decrescente, aviso ou recompensa apressa a decisão.

---

## 3. Classe — seis presets honestos

Só aparecem as seis classes confirmadas para a fatia: **Guerreiro, Feiticeiro, Tanque, Assassino, Berserker e Paladino**. Batedor e Mago do mal não surgem cinzentos nem como promessa; entram apenas quando tiverem ficha, kit e conteúdo jogável.

Cada cartão lê os mesmos dados que criam o save — não mantém uma segunda tabela escrita à mão:

| Linha obrigatória | Fonte | Exemplo: Guerreiro |
|---|---|---|
| **Como se joga** | [`12`](12-classes.md) | “equilibrado — a régua dos outros” |
| **Começa com** | `weapons.json` / [`51`](51-familias.md) | espada, escudo, peitoral e botas |
| **É forte quando** | ficha da classe + família | adapta a arma e mede a abertura |
| **Sofre quando** | papel + “onde é má” do equipamento | nunca é o especialista da situação |
| **Verbo de assinatura** | `abilities.json` | Ímpeto: fecha 6 m e golpeia |
| **Traço de origem** | catálogo a fechar pelo [`54`](54-mana-meditacao-e-tracos-de-classe.md) | mostra apenas quando o traço estiver aprovado e implementado |
| **Atributos iniciais** | `attributes.json` | sete valores e diferença face à base 8 |

E, sem rodapé nem tooltip, todos mostram:

> **É só o teu começo.** Podes usar qualquer arma, armadura e magia, subir qualquer atributo e entrar em todo o conteúdo. Requisitos mudam eficácia; nunca proíbem equipar.

### O que a origem fixa

No instante da criação, `origin_class_id` — hoje chamado `class_id` no save — escolhe:

1. distribuição inicial de **+14 pontos**;
2. kit inicial completo;
3. habilidade e técnica de assinatura iniciais;
4. o traço de origem quando os donos fecharem as propostas do [`54`](54-mana-meditacao-e-tracos-de-classe.md).

O nome da origem continua na ficha para explicar esse arranque. Não existe botão de “mudar classe” porque os pontos e o kit já entraram no mundo; uma futura reespecialização é uma pergunta separada, não condição deste ecrã.

### O que a origem nunca fixa

- arma, armadura, escudo, escola de magia ou feitiço que se pode usar;
- atributo em que se pode investir;
- espólio que se pode receber ou guardar;
- zona, chefe, NPC, vendedor, final ou sessão co-op a que se pode aceder;
- composição da dupla — os dois podem escolher o mesmo preset;
- técnicas encontradas no mundo: a origem dá a primeira, não transforma a lista futura numa árvore proibida.

O traço permanente decidido no [`54`](54-mana-meditacao-e-tracos-de-classe.md) dá identidade ao **começo** sem abrir portas exclusivas. Se um traço futuro fizer uma arma, magia ou rota impossível para outra origem, falha a Lei 3 mesmo que a UI lhe chame “classe”.

### Comparar sem uma folha de cálculo

Seleccionar outra classe actualiza boneco, kit e sete barras na mesma escala. A UI destaca apenas diferenças face ao valor base 8 (`+6 Inteligência`, não “14 melhor”). Um botão `Comparar com anterior` sobrepõe os deltas e nada mais. Dano final, DPS e “dificuldade” não aparecem: dependem da ferramenta, do encontro e de números ainda por afinar no [`63`](63-como-se-afinam-os-numeros.md).

---

## 4. Aspecto — escolha finita que os assets conseguem pagar

Não se promete escultura facial, altura, peso nem dezenas de sliders. O corpo de combate tem um esqueleto, proporções e cápsula comuns; aparência é combinação de variantes discretas:

| Eixo | Opções da fatia | De onde vem |
|---|---:|---|
| **corpo** | 2 bases | `quaternius-base-characters`: os dois corpos completos existentes |
| **tom de pele** | 4 amostras | duas texturas-base existentes + duas variações de material validadas lado a lado |
| **cabelo** | nenhum + 6 formas | seis malhas `Hair_*` já presentes no pack |
| **cor do cabelo** | 6 amostras | paleta num único material; não duplica textura |
| **sobrancelhas** | 2 formas | `Eyebrows_Female` / `Eyebrows_Regular`, nomes internos não mostrados |
| **acento do kit** | 6 cores | pequena zona de pano/metal secundária; nunca muda silhueta de classe |
| **voz** | grave / aguda | os dois conjuntos já orçamentados no [`21`](21-arte-render.md) |

Corpo e voz são independentes. O jogo não infere género, pronome, atributos ou animação a partir deles. A narrativa em português não guarda um campo de género enquanto nenhum diálogo precisar dele; inventá-lo agora criaria uma promessa sem uso.

### Guardas visuais e mecânicas

- mesma altura, raiz, velocidade, alcance, hurtbox, câmara e frames para todas as combinações;
- cabelo que atravessa elmo/capuz esconde-se por `hide_group`, não deforma física nem armadura;
- `sem elmo` é **só uma pré-visualização** na criação; no jogo, a peça equipada manda;
- tom/acento nunca codificam classe, raridade, perigo ou forma de telegrafia;
- em 1.ª pessoa, mãos/antebraços usam o mesmo tom escolhido; em 3.ª pessoa, o parceiro vê a combinação completa;
- a fotografia do slot é gerada da combinação real depois do primeiro carregamento, não é um retrato genérico da classe.

⚠️ **O inventário prova matéria-prima, não integração:** os corpos Quaternius e as classes KayKit podem ter rigs diferentes. A importação tem de provar retarget, encaixe dos onze kits e 57 clips antes de prometer as 2 bases no build. Está registado no [`LACUNAS`](../LACUNAS.md).

---

## 5. Nome — texto mostrado, nunca identidade técnica

| Regra | Contrato |
|---|---|
| comprimento | **1–24 grafemas** depois de aparar início/fim |
| permitido | letras Unicode, marcas combinantes, espaços simples, apóstrofo (`'`/`’`) e hífen (`-`) |
| recusado | controlos, quebras de linha, tabs, markup, separadores de caminho, espaço duplo ou nome vazio |
| normalização | NFC antes de validar e gravar |
| repetidos | **permitidos** — `profile_id`, não o nome, identifica o save e a rede |
| filtro de palavras | nenhum; é um jogo privado de dois amigos, e falsos positivos não compram segurança |

O campo mostra `0/24` e o erro por baixo sem apagar texto. Colar segue as mesmas regras que escrever. O nome aparece no slot, ficha, HUD do parceiro, lobby e recibos legíveis; nunca entra em nome de ficheiro, `NodePath`, ID de rede ou chave de catálogo.

Se dois personagens têm o mesmo nome, o lobby junta ícone de origem e miniatura; internamente continuam `profile_id` distintos.

---

## 6. Rever, confirmar e gravar

O último passo mostra num só quadro:

- nome + miniatura da aparência;
- preset e frase “só o começo”;
- atributos, arma, offhand e peças iniciais;
- habilidade/técnica e traço **apenas se existirem no catálogo**;
- o slot de destino.

`Criar personagem` abre uma confirmação curta: **“Criar <nome> com o preset <classe> neste slot?”** Confirmar chama uma única fronteira:

```text
new_game(profile_id, origin_class_id, identity, slot)
  → valida IDs e nome
  → deriva atributos e kit do GameData
  → escreve save atómico
  → só em sucesso carrega Brumal
```

Nunca se aceitam atributos, itens ou habilidade vindos da UI. A UI envia IDs de origem/aparência e nome; `GameData` deriva tudo o que tem efeito mecânico.

### Persistência e migração

O v1 do [`59`](59-saves.md) já guarda `identity.name` e `identity.class_id`, mas não aparência/voz. Quando o criador for implementado, o formato seguinte acrescenta:

```json
"identity": {
  "name": "Ari",
  "class_id": "warrior",
  "appearance": {
    "body_id": "body_a",
    "skin_tone_id": "skin_02",
    "hair_id": "hair_buzzed",
    "hair_color_id": "hair_03",
    "brows_id": "brows_regular",
    "accent_id": "accent_amber",
    "voice_id": "voice_low"
  }
}
```

A migração v1→v2 preserva nome/classe/progresso e aplica a combinação visual de fábrica; nunca reabre criação nem troca kit. Nome e aspecto podem ser alterados gratuitamente na ficha **apenas num ponto de descanso**. Origem e distribuição inicial não mudam aí.

---

## 7. Como se prova que não mentiu

### Automatizado

1. existem exactamente 6 cartões e cada ID existe em atributos, kit e habilidade;
2. o resumo usa os mesmos valores que `create_save`; nenhuma tabela de UI duplica atributos/itens;
3. cada uma das 6 origens consegue equipar cada arma da fatia — requisito em falta aplica a penalidade escrita, nunca `bloqueado`;
4. os dois jogadores podem criar a mesma origem e o mesmo nome com `profile_id` diferentes;
5. matriz do nome: 1 e 24 grafemas passam; 0/25, controlo, newline e caminho falham; NFC faz round-trip;
6. todas as opções de aparência referem IDs existentes e sobrevivem save→load;
7. fixture v1 migra com aparência de fábrica sem alterar qualquer outro campo;
8. falha de escrita não entra no mundo e mantém o formulário preenchido.

### No ecrã

- teclado sem rato percorre, muda e confirma tudo; `Esc` nunca apaga sem perguntar;
- 1920×1080 e 1280×720 não cortam nome, frase da Lei 3 nem botões;
- seis pessoas que nunca viram as fichas respondem, depois de escolher: “o que recebo agora?” e “posso mudar para outra arma?” — **6/6** têm de acertar;
- 12 combinações (2 corpos × 6 classes) correm os 57 clips com arma, escudo, cabelo e kit sem atravessamento que esconda mãos/cabeça;
- miniatura e parceiro mostram a mesma aparência que o slot gravou.

---

## 8. As quatro perguntas do fio solto

### 1. Como é que o jogador usa isto?

Escolhe uma das seis maneiras de começar, ajusta um conjunto curto de variantes, escreve o nome, revê o kit real e confirma. Pode recuar sem perder o rascunho. Depois, no ponto de descanso, muda nome/aspecto; a evolução mecânica faz-se no jogo, não voltando ao criador.

### 2. Como é que se prova que funciona?

Schema e save provam IDs/round-trip/migração; a matriz Lei 3 prova que 6 origens × 5 armas não bloqueiam; o teste de ecrã prova navegação, compreensão e encaixe das 12 combinações de corpo/classe.

### 3. De onde vêm a arte e o som?

Os seis conceitos já estão em [`art/concept`](../art/concept) e podem servir de cartão até às capturas 3D. Corpos/cabelos/sobrancelhas vêm de `art/models/quaternius-base-characters`; armas/classes do KayKit; a licença e autoria ficam no [`CREDITS`](../CREDITS.md). Voz grave/aguda precisa dos dois conjuntos de esforço/dano/morte previstos no [`21`](21-arte-render.md); até existirem, o selector é marcado “amostra provisória” e não toca voz inventada.

### 4. Quanto custa na máquina do Rico?

Uma personagem, uma luz e fundo estático: **≤ 8 000 tris**, **≤ 4 draw calls de corpo/kit**, texturas 1024² já residentes só para a variante activa. Troca liberta a anterior antes de pré-carregar a próxima; alvo **p99 ≤ 16,7 ms** e **≤ 120 MB** de pico adicional no criador. A miniatura grava-se uma vez fora do frame de combate.

---

## O que fica por construir

| | Estado |
|---|---|
| ecrã de criação/slots | 🔴 hoje F6 troca classe no greybox; não existe menu |
| catálogo `appearance.json` + import/retarget | validar os dois rigs e todos os kits antes de expor opções |
| save v2 + migração v1 | necessário para aspecto/voz; nome/classe já existem no v1 |
| dois conjuntos de voz | conteúdo em falta; não bloqueia criação silenciosa |
| traços de origem | só mostrar os que Mateus/Rico aprovarem no [`54`](54-mana-meditacao-e-tracos-de-classe.md); não decidir aqui |

## Ligações

[`02-personagem.md`](02-personagem.md) · [`12-classes.md`](12-classes.md) · [`20-interface.md`](20-interface.md) · [`21-arte-render.md`](21-arte-render.md) · [`22-assets.md`](22-assets.md) · [`45-controlos-configuraveis.md`](45-controlos-configuraveis.md) · [`51-familias.md`](51-familias.md) · [`54-mana-meditacao-e-tracos-de-classe.md`](54-mana-meditacao-e-tracos-de-classe.md) · [`59-saves.md`](59-saves.md) · [`62-acessibilidade-auditiva.md`](62-acessibilidade-auditiva.md) · [`63-como-se-afinam-os-numeros.md`](63-como-se-afinam-os-numeros.md) · [`99-perguntas-abertas.md`](99-perguntas-abertas.md)
