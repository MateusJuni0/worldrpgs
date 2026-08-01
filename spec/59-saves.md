# 59 — Saves: progresso que não volta atrás

`[CODEX]` (01-08-2026) — contrato técnico para o progresso, o inventário e o mapa. Implementado em [`game/src/autoload/save_system.gd`](../game/src/autoload/save_system.gd) e provado pelo auto-teste.

> ⭐ **Regra-mãe:** o save é uma consequência de jogar, não uma ferramenta para escolher resultados. O jogo grava cada alteração permanente; o menu não oferece «gravar agora» nem «carregar antes da morte».

Isto aplica a morte já `[DECIDIDO]` no [`33`](33-morte-e-almas.md), a divisão de autoridade do [`19`](19-rede.md), a mochila sem limite do [`40`](40-decisoes-espolio-magia-inventario.md) §9 e o estado de exploração e marcas do [`57`](57-mapa-e-minimapa.md) §6.

---

## 1. Onde vive e quem lhe toca

Cada slot é um documento JSON em `user://saves/`:

| Ficheiro | Papel |
|---|---|
| `slot_00.json` | geração confirmada que o jogo abre |
| `slot_00.json.tmp` | geração nova, ainda não confirmada |
| `slot_00.json.bak` | geração confirmada anterior |
| `slot_00.json.corrupt` | última cópia partida, preservada para diagnóstico |

`user://` é a pasta de dados da aplicação que o Godot resolve em cada PC. Nenhum caminho absoluto entra no repositório.

**Só o `SaveSystem` escreve estes ficheiros.** Progresso, inventário, mundo e mapa alteram o estado em memória no `GameData` e pedem ao `SaveSystem` um commit. Não há quatro gravadores com regras diferentes.

`[CODEX]` **JSON em vez de serialização binária:** é maior, mas legível e migrável. O mapa guarda a exploração compactada, por isso o limite de texto não manda no orçamento. Alternativa descartada agora: `store_var`, menor mas opaco e mais dependente dos tipos internos do Godot.

---

## 2. O formato v1 — campo a campo

Os IDs (`class_id`, `boss_id`, `item_id`, `zone_id`) são IDs estáveis do `GameData`, nunca nomes mostrados no ecrã. Traduzir «Vorgar» ou mudar uma descrição não parte um save.

### Cabeçalho

| Campo | Tipo | O que guarda |
|---|---|---|
| `format_version` | inteiro | versão estrutural; começa em **1** |
| `content_revision` | texto | versão do jogo que escreveu; diagnóstico, **não** decide compatibilidade |
| `saved_at_unix` | inteiro | instante do último commit confirmado |
| `checksum_sha256` | texto, 64 hex | SHA-256 do JSON canónico sem este campo; detecta truncagem e alteração silenciosa |
| `character` | objecto | o que pertence ao jogador e viaja com ele |
| `world` | objecto | o mundo deste perfil quando ele é anfitrião |

### `character` — o que viaja com a pessoa

| Campo | Tipo | O que guarda |
|---|---|---|
| `profile_id` | texto estável | dono do personagem; também torna eventos de rede idempotentes |
| `identity.name` | texto | nome escolhido na criação |
| `identity.class_id` | ID | classe inicial; não bloqueia armas (Lei 3) |
| `progression.level` | inteiro 1–100 | nível actual |
| `progression.souls_held` | inteiro ≥ 0 | almas que ainda estão no corpo |
| `progression.attributes` | `attribute_id → valor` | distribuição actual de atributos |
| `progression.unlocked_skills` | lista de IDs | opções de classe desbloqueadas |
| `progression.known_spells` | lista de IDs únicos | feitiços conhecidos; nunca duplica ([`40`](40-decisoes-espolio-magia-inventario.md) §12) |
| `progression.scrolls` | lista de IDs | pergaminhos obtidos |
| `progression.flask_upgrades` | objecto por eixo | ampliações do frasco, quando o WP5 as fechar |
| `progression.verbs` | lista de IDs | verbos recebidos de chefes e progressão |
| `progression.boss_rewards_claimed` | lista de `boss_id` | chefes pelos quais este personagem já recebeu progresso/recompensa; **não abre o mundo** |
| `progression.collected_placed_items` | lista de IDs | itens colocados apanhados por este personagem, uma vez para sempre |
| `progression.applied_event_ids` | lista de IDs | recibos co-op já aplicados; repetir uma mensagem não duplica prémios |
| `inventory.items` | `item_id → quantidade` | mochila inteira, sem limite de peso nem de espaços |
| `inventory.equipment.main` | ID ou `null` | mão principal |
| `inventory.equipment.offhand` | ID ou `null` | mão secundária |
| `inventory.equipment.armor` | lista de IDs | peças nos 9 slots definidos no [`51`](51-familias.md) |
| `inventory.equipment.rings` | lista de IDs | anéis equipados |
| `inventory.equipment.spell_favorites` | lista de IDs | favoritos preparados para a roda |
| `inventory.quick_slots` | lista de IDs | consumíveis nos atalhos |
| `inventory.weapon_upgrades` | `instance_id → estado` | reforço/infusão quando esse sistema for fechado; instância, porque armas repetem |
| `inventory.spell_upgrades` | `spell_id → estado` | eixos de melhoria do feitiço único |
| `checkpoint.zone_id` | ID | zona do último ponto de descanso |
| `checkpoint.rest_point_id` | ID | ponto onde o personagem reaparece; não se grava posição livre para saltar caminho |
| `death.soul_stain` | `null` ou objecto | mancha activa: `stain_id`, `amount`, `zone_id`, `position:[x,y,z]` e `death_sequence` |

⚠️ **O v1 aprovado fica intacto.** O criador do [`64`](64-criacao-de-personagem.md) exige que a próxima versão acrescente `identity.appearance` (corpo, pele, cabelo, sobrancelhas, acento e voz). A migração v1→v2 aplica a aparência de fábrica e preserva todos os campos existentes; implementar criador sem subir versão é partir o contrato deste documento.

`death_sequence` sobe em cada morte. Uma mancha nova substitui a anterior no mesmo commit que põe `souls_held = 0`; assim, morrer outra vez perde a primeira de verdade.

### `world` — o que pertence à casa do anfitrião

| Campo | Tipo | O que guarda |
|---|---|---|
| `owner_profile_id` | texto | perfil cujo mundo é este |
| `cycle` | inteiro 0–7 | passagem actual / NG+ |
| `bosses_defeated` | lista de IDs | chefes mortos **neste mundo**; abre arena, portão e consequências espaciais |
| `shortcuts_open` | lista de IDs | portas, elevadores e atalhos permanentes |
| `rest_points_discovered` | lista de IDs | pontos disponíveis neste mundo |
| `chests_opened` | lista de IDs | baús cujo estado é mundial; loot instanciado continua no personagem |
| `enemy_respawns` | `spawn_group_id → contador` | quantas reposições já gastou; aplica o tecto de 10 |
| `loot_decks` | `enemy/deck_id → estado` | semente, posição e cartas restantes do baralho sem reposição |
| `zone_flags` | `flag_id → valor JSON` | eventos permanentes de zona; só IDs documentados, não caminhos de nós |
| `map.exploration` | `zone_id → bloco` | células visitadas, em `bitset-base64-v1` com largura, altura, andares e dados |
| `map.marks_by_profile` | `profile_id → lista` | até 8 marcas por jogador: `mark_id`, tipo, zona e posição |
| `reward_receipts` | lista de objectos | evento de chefe confirmado pelo anfitrião: `event_id`, `boss_id`, participantes e prémios a aplicar uma vez |

O bitset evita guardar milhares de coordenadas como texto. Uma mudança futura de resolução do mapa cria uma migração; nunca interpreta bits antigos com uma grelha nova.

### O que **não** se guarda

- vida, postura, fase e posição corrente de um chefe;
- PV, posição, alvo ou animação de inimigos comuns;
- posição livre do jogador dentro da zona;
- posição/interpolação do parceiro e mensagens de rede em voo;
- nós, `NodePath`, recursos carregados ou números de combate do catálogo;
- configurações gráficas e mapa de teclas — vivem num `settings.json` separado.

⭐ **Razão:** combate a meio é transitório. Abrir o jogo coloca o personagem no último descanso e reinicia o chefe por inteiro; nunca permite congelar uma tentativa favorável.

---

## 3. Quando grava — sobretudo a morte

Não existe botão de save manual. O ícone discreto de gravação apenas informa; não recebe input.

| Evento | Momento do commit |
|---|---|
| ⚠️ **HP chega a zero** | **síncrono, antes do fade, corpo caído ou respawn:** cria/substitui a mancha, move as almas para ela e põe `souls_held = 0` no mesmo documento |
| Ressurreição dentro do minuto | síncrono antes de devolver controlo: devolve as almas e limpa a mancha |
| Recuperar a mancha | síncrono antes de a retirar do mundo |
| Morte do chefe | quando a vida chega a zero e a recompensa está calculada; mundo + recibo num commit do anfitrião |
| Item, feitiço, arma, armadura ou pergaminho obtido | antes de mostrar «obtido» como concluído |
| Subir nível, comprar, melhorar, equipar | ao confirmar a operação no menu |
| Abrir atalho/baú, descobrir descanso, gastar reposição | imediatamente depois da transição autoritativa |
| Criar, mover ou apagar marca | imediatamente; máximo de 8 validado pelo mapa |
| Exploração do mapa | acumula em memória e grava a cada **10 s**, e sempre ao mudar de zona, descansar, morrer ou sair |
| Sair/desligar sessão normalmente | commit final dos eventos já aceites; nunca inventa recompensa pendente |

⚠️ **Lei 1 / anti-save-scumming:** a morte não espera pelo menu, pela animação nem pelo fim da sessão. Se o processo cair depois de HP = 0, o próximo arranque encontra as almas na mancha, não no bolso. Copiar ficheiros à mão no Windows fica fora: são dois amigos e o [`19`](19-rede.md) já dispensa anti-cheat.

`[CODEX]` Os commits críticos são síncronos. Alternativa descartada: fila assíncrona para tudo — poupa um pico de disco mas abre a janela exacta em que desligar depois de morrer desfaz a morte.

---

## 4. ⚠️ Escrita atómica — nunca há meio save activo

Cada commit segue esta ordem e só devolve sucesso no fim:

1. tira um snapshot profundo do estado no `GameData`;
2. escreve versão, hora e checksum;
3. serializa tudo para `slot_00.json.tmp`;
4. chama `flush()`, fecha, volta a abrir o `.tmp`, faz parse, valida secções e checksum;
5. se o activo é íntegro, remove o backup antigo e faz **rename** do activo para `.bak`;
6. faz **rename** do `.tmp` para o nome activo;
7. se o segundo rename falhar, volta a pôr o `.bak` como activo e reporta erro.

Nunca se escreve por cima de `slot_00.json`. Cada rename publica um ficheiro completo.

| Queda | O que fica | Próximo arranque |
|---|---|---|
| durante a escrita do `.tmp` | activo intacto + temporário incompleto | abre o activo, ignora o `.tmp` |
| depois de activo → `.bak` | backup íntegro + temporário íntegro, sem activo | recupera primeiro o `.bak` |
| depois do rename final | activo novo + backup anterior | abre o activo novo |

Um activo já corrompido **nunca roda para cima de um backup bom**: vai para `.corrupt` e o backup fica quieto.

---

## 5. Corrupção e recuperação

Carregar não significa só «o JSON abre». A cópia candidata tem de:

1. ser JSON válido e um objecto;
2. ter uma versão suportada;
3. conter `character` e `world` com os tipos certos;
4. bater no `checksum_sha256`.

Ordem de recuperação: **activo → `.bak` → `.tmp` completo**. O `.tmp` só é candidato quando não existe uma geração confirmada recuperável.

- Activo partido + backup bom: renomeia o activo para `.corrupt`, restaura o backup atomicamente e emite `recovery_completed`. O menu mostra «O último save estava danificado; recuperámos a cópia anterior».
- Activo ausente depois de queda entre renames: restaura o backup.
- Primeiro save interrompido, sem activo/backup, mas `.tmp` completo: confirma o temporário.
- Nenhuma cópia íntegra: preserva o partido, **não cria nem grava um jogo novo por cima**, desactiva «Continuar» e oferece começar noutro slot. Recuperação manual continua possível.
- Save de versão **mais nova**: não é «corrupção»; recusa abrir e nunca o substitui por um backup antigo.

Guarda-se uma cópia `.corrupt`; uma nova corrupção substitui a anterior. Quatro ficheiros por slot é um tecto, não uma pasta que cresce para sempre.

---

## 6. Versionamento — abrir daqui a três meses

`format_version` muda apenas quando a estrutura muda. `content_revision` pode mudar em cada build sem obrigar migração.

As migrações são uma escada, nunca um salto:

```text
v0 sem versão → migrate_v0_to_v1 → valida v1 → grava v1 atomicamente
v1            → abre directamente
v2 futuro     → recusa sem alterar o ficheiro
```

Cada `migrate_vN_to_vN+1`:

- preserva campos e IDs conhecidos;
- acrescenta novos campos com defaults derivados do `GameData`;
- não ressuscita conteúdo removido nem converte um ID desconhecido noutro «parecido»;
- deixa a geração antiga no `.bak` antes de confirmar a migrada;
- tem teste com uma fixture da versão anterior.

A implementação já traz a migração do legado sem versão (`player` → `character`) para v1. Quando a spec mudar, o commit que sobe `CURRENT_FORMAT_VERSION` traz a função e o teste no mesmo acto.

---

## 7. ⭐ Como funciona a dois — a tensão que não se decide aqui

O [`19`](19-rede.md) decidiu duas coisas:

- **o anfitrião manda no mundo; cada jogador manda no próprio corpo**;
- o personagem leva nível, inventário e flags de chefe, mas atalhos ficam na casa.

`[TENSÃO]` Se o Rico matar um chefe vivo no mundo do Mateus, «conta para os dois» pode querer dizer duas coisas incompatíveis: Rico recebe a vitória/recompensa, ou o chefe também desaparece quando Rico voltar a hospedar. A primeira preserva a autoridade do anfitrião; a segunda partilha progresso espacial.

### Opção A — dois saves híbridos **(recomendada)**

Cada um tem **um ficheiro local com dois sacos**:

- `character`: viaja e grava no PC do próprio;
- `world`: só muda quando esse perfil hospeda.

No exemplo, a recomendação é: Rico recebe `boss_rewards_claimed` e o prémio, mas `world.bosses_defeated` do Rico não muda; quando ele hospedar, o chefe ainda existe e os atalhos continuam como estavam. É a leitura que melhor preserva «o anfitrião manda no mundo» e permite jogar o encontro outra vez com papéis trocados.

### Opção B — um save da dupla

Um mundo partilhado replica chefes e atalhos para os dois. Resolve «não repetir chefe», mas cria conflitos offline, exige escolher quem guarda a verdade quando os dois hospedaram separados e desfaz a ideia de entrar no mundo de um deles.

⭐ **Recomendação: A. Não está decidida.** O formato v1 separa os dois campos para não bloquear código, mas nenhuma regra promove `boss_rewards_claimed` para `world.bosses_defeated` até Mateus e Rico responderem à pergunta 32 do [`99`](99-perguntas-abertas.md).

---

## 8. Desligar a meio de um chefe

Mantém-se o movimento decidido no [`19`](19-rede.md): se o convidado cair, o anfitrião continua e a vida máxima do chefe reescala proporcionalmente; se cair o anfitrião, a sessão acaba. Para persistência:

| Momento | Resultado persistente |
|---|---|
| convidado cai **antes** de HP do chefe chegar a zero | nenhum progresso parcial; volta no descanso; ganhos já confirmados antes da luta continuam no save dele |
| anfitrião cai antes do commit de morte | o chefe reinicia inteiro no próximo arranque; ninguém recebe prémio de chefe |
| chefe morre e o convidado continua ligado | anfitrião grava mundo + `reward_receipt`; cada jogador aplica o recibo uma vez e grava o próprio personagem |
| linha cai depois do commit do anfitrião mas antes do save do convidado | o recibo fica no mundo do anfitrião e é reenviado na próxima ligação; `applied_event_ids` impede duplicar |
| convidado já estava desligado quando o chefe morreu | não entra nos participantes do recibo; não recebe vitória retroactiva |

`[CODEX]` O instante autoritativo é o commit do anfitrião em HP zero, não dano parcial nem «ajudou durante N segundos». Alternativa descartada: prémio proporcional a uma luta abandonada — abre duplicação, divergência e discussões sobre quanto conta.

---

## 9. A interface no código

O singleton `SaveSystem`, carregado depois de `GameData`, expõe:

| Chamada | Uso |
|---|---|
| `create_save(profile_id, class_id)` | cria v1 com atributos e kit inicial vindos do `GameData` |
| `new_game(profile_id, class_id, slot)` | cria, liga ao `GameData` e confirma o slot |
| `save_current(slot)` | snapshot do `GameData` → escrita atómica |
| `load_slot(slot)` | valida/recupera/migra → substitui o estado no `GameData` |
| `save_to_path` / `load_from_path` | mesma fronteira para testes e ferramentas, sem tocar em caminhos reais |

Os sinais `save_completed`, `save_failed` e `recovery_completed` permitem à UI informar sem conhecer ficheiros.

Quando o [`64`](64-criacao-de-personagem.md) entrar, `new_game` recebe também a identidade já validada. A UI nunca envia atributos ou kit: esses continuam derivados do `class_id` pelo `GameData`.

⚠️ **O que ainda não está ligado:** o greybox não implementa almas, mochila nem mapa persistente; logo ainda não produz esses eventos. O `SaveSystem` e o estado no `GameData` estão prontos, mas os três clientes têm de chamar `save_current()` quando forem construídos.

---

## 10. As quatro perguntas do fio solto

| Pergunta | Resposta |
|---|---|
| **Como é que o jogador usa isto?** | Joga. Escolhe slot em «Novo jogo/Continuar» e vê um indicador durante autosave ou recuperação; não há comando de gravar/carregar para explorar resultados |
| **Como é que se prova?** | [`self_test.gd`](../game/src/tests/self_test.gd): round-trip completo e aplicação ao `GameData`; temporário interrompido + rotação de backup; corrupção com JSON ainda válido e checksum errado; migração v0→v1 |
| **De onde vêm arte e som?** | não precisa de asset novo: texto e indicador geométrico na UI existente; **sem som**, para uma operação automática frequente não competir com telegrafia de combate |
| **Quanto custa na máquina do Rico?** | **0 trabalho por frame**; uma serialização por evento, exploração agrupada a 10 s; orçamento de **2 MiB por geração**, quatro ficheiros/slot, pico transitório ≤ **6 MiB** em memória. A fixture completa do auto-teste tem guarda de **< 64 KiB**; medir p95 da escrita com o mapa cheio antes do M4 |

O custo de `flush()` é deliberado só nos eventos que não podem voltar atrás. Chamar a cada célula do mapa violaria a Lei 4 e a própria recomendação do Godot de não fazer flush constante.

**Fontes técnicas:** [Godot — guardar jogos e limites do JSON](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html) · [Godot — `FileAccess.flush()`](https://docs.godotengine.org/en/stable/classes/class_fileaccess.html) · [Godot — `DirAccess.rename_absolute()`](https://docs.godotengine.org/en/stable/classes/class_diraccess.html)

## Ligações

[`19-rede.md`](19-rede.md) · [`33-morte-e-almas.md`](33-morte-e-almas.md) · [`40-decisoes-espolio-magia-inventario.md`](40-decisoes-espolio-magia-inventario.md) · [`57-mapa-e-minimapa.md`](57-mapa-e-minimapa.md) · [`23-tecnico.md`](23-tecnico.md) · [`64-criacao-de-personagem.md`](64-criacao-de-personagem.md) · [`99-perguntas-abertas.md`](99-perguntas-abertas.md)
