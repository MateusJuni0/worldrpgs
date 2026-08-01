# 73 — Fecho dos buracos de integração e da fronteira spec → produção

`[CODEX]` · Tarefa 4.4 · 01-08-2026

Este documento fecha regras que a spec usava sem as ter dito. **Não transforma trabalho ainda por construir em trabalho feito.** A partir daqui:

- 🔴 em [`LACUNAS`](../LACUNAS.md) quer dizer “uma decisão ou contrato em falta impede implementar correctamente”;
- uma regra fechada cuja UI, conteúdo, arte ou runtime ainda não existe é dívida de **produção**, com marco e prova próprios;
- um assunto reservado a Mateus + Rico fica ⏳ e nunca é decidido por este documento.

As fontes executáveis desta camada são [`controls.json`](../game/data/controls.json), [`strings.pt.json`](../game/data/strings.pt.json), as regras de topo de [`enemies.json`](../game/data/enemies.json) e [`world.json`](../game/data/world.json).

---

## 1. Magia inimiga é ataque do bestiário, não um segundo sistema

Um inimigo conjurador usa as mesmas regras perceptíveis do jogador: forma de entrega, tell, momento de compromisso, contacto que vive enquanto o efeito se vê, elemento, interrupção, cue sonoro/visual e um ou dois vectores de fuga. A magia entra na lista `attacks` da ficha do inimigo e passa as guardas do [`38`](38-ataques-e-honestidade.md), [`55`](55-formas-de-feitico.md), [`62`](62-acessibilidade-auditiva.md) e [`67`](67-catalogo-do-bestiario.md).

Não copia recursos que só existem para o jogador. Um inimigo não medita, não abre favoritos e não finge gastar a mana da interface. A ficha de IA declara padrão, cooldown e número de usos quando finito. Dano de postura que esgote a postura antes do compromisso interrompe; depois do compromisso, o efeito já lançado resolve. Assim “usa as mesmas regras” significa **a mesma honestidade e contacto**, não simular um inventário invisível.

### 1.1 Cura remota e latência

**Elo Curador cura 30% dos PV máximos do parceiro vivo**, uma vez por `cast_id`; não escolhe invocados e nunca ressuscita. No compromisso, o anfitrião valida alvo, 24 m e linha de visão e envia um evento fiável/ordenado. O dono do corpo aplica a cura em `commit_time + distância/12 m/s`; se a mensagem chegar depois desse instante, aplica ao receber. A morte não é rebobinada. Acima de 150 ms usa-se o aviso geral de latência do [`19`](19-rede.md), sem aumentar a cura nem esconder a demora.

O efeito visual percorre a mesma duração nas duas máquinas. Duplicar/reordenar o pacote não duplica PV; perder ligação deixa o save anterior intacto. Esta cura usa canal de gameplay fiável, ao contrário de voz e posições efémeras.

## 2. Verbos de travessia

Não há natação livre, escalada livre nem salto livre de travessia. A malha do [`69`](69-catalogo-do-mundo.md) nunca exige esses verbos para rota principal, segredo ou fuga:

| Situação | Contrato |
|---|---|
| pequeno desnível | passo automático até **0,45 m** |
| subir/descer | rampa, escada interactiva ou elevador autorado |
| água funda | perigo ou fundo caminhável lento; nunca “carrega para nadar” |
| queda sem regresso | bordo e destino legíveis; obedece à curva de queda do [`70`](70-fecho-dos-sistemas-de-combate.md) |
| golpe “a saltar” | investida terrestre de arma; não cria um botão de salto |

Alternativa descartada: três sistemas de locomoção, rigs e estados de rede novos para verbos que nenhuma das 21 ligações precisa. Isto reduz superfície técnica sem transformar uma parede baixa numa adivinha.

## 3. Persistência do subchefe

Fugir recompõe o encontro no descanso, na mesma bolsa aberta. Matá-lo remove-o durante o ciclo actual daquela zona. Brasa ou NG+ cria novo ciclo e volta a colocá-lo; a recompensa fixa tem recibo e só sai uma vez por ciclo. O subchefe continua sem nevoeiro, barra global ou música própria, e toda a bolsa tem uma saída legível.

Isto distingue três estados que antes estavam misturados: abandonar a tentativa, vencer o encontro e reiniciar deliberadamente a zona.

## 4. Onde vivem os textos

Texto apresentado ao jogador vive em `game/data/strings.<locale>.json`, por ID estável. Nomes internos, mensagens de erro e diagnósticos ficam no código/dado que os produz. O português é a língua de origem e também o fallback; a ausência de um ID obrigatório falha o auto-teste em vez de mostrar o próprio ID.

O HUD e os toasts da fatia já consomem [`strings.pt.json`](../game/data/strings.pt.json). Catálogos mantêm `display_name` junto da entidade porque o nome é dado de jogo; quando existir uma segunda língua, esses campos passam a guardar ID, numa migração de conteúdo única — não se espalham traduções pelo código.

## 5. Comando completo e agnóstico da fonte

Cada acção nuclear — incluindo movimento e quatro eixos de câmara — tem pelo menos uma ligação de teclado/rato e uma de comando. `GameData` constrói ambas a partir do mesmo catálogo e aceita botão ou eixo; gameplay continua a perguntar pela **acção**, nunca pelo dispositivo. O stick direito roda a 2,5 rad/s como baseline de fábrica. Contextos podem partilhar `X/quadrado` para conjurar/interagir porque não estão activos ao mesmo tempo.

Nenhuma das duas máquinas tem comando. Por isso o catálogo fecha a arquitectura e permite teste sintético, mas conforto, labels por fabricante, deadzones e conflitos precisam de uma sessão física no M2. Um mau default medido muda dados, não código.

O lock-on existe nas duas perspectivas. A escolha entre câmara magnetizada ou alvo apenas assistido em primeira pessoa continua ensaio de feel do [`29`](29-perspectiva.md); as duas opções obedecem aos mesmos 18/25 m e nenhuma falta de câmara volta a bloquear combate ou mundo.

## 6. Voz: o que o Godot dá e o que não dá

Godot dá captura de amostras em tempo real e entrada de microfone. A documentação oficial diz explicitamente que [`AudioEffectCapture`](https://docs.godotengine.org/en/latest/classes/class_audioeffectcapture.html) disponibiliza amostras cruas e que estas podem ser transmitidas pela rede; [`AudioStreamMicrophone`](https://docs.godotengine.org/en/stable/classes/class_audiostreammicrophone.html) fornece a origem, com a activação de entrada de áudio descrita no [tutorial oficial de gravação](https://docs.godotengine.org/en/stable/tutorials/audio/recording_with_microphone.html).

Isto **não** entrega sozinho voz pronta. Codec Opus, cancelamento de eco, supressão de ruído, jitter adaptativo, pacotes, perda e reconexão continuam integração. Em plataformas nativas, o [WebRTC de Godot](https://docs.godotengine.org/en/4.7/tutorials/networking/webrtc.html) requer uma extensão GDExtension externa; portanto não se pode chamar WebRTC completo “nativo e gratuito” sem declarar a dependência.

Decisão técnica: manter o contrato do [`56`](56-voz-e-vendedores.md) no canal não fiável da rede do jogo e escolher no WP14 uma implementação Opus/AEC compatível com a licença. Se a extensão faltar ou a voz cair, os quatro pings continuam e o jogo nunca bloqueia. A escolha da biblioteca exige spike e revisão de licença; não é uma decisão criativa nem um buraco de spec.

## 7. Migração histórica de `sabedoria`

O save v2 do criador faz a conversão apenas se existir `sabedoria` **e** faltarem `inteligencia`/`fe`:

1. lê a origem guardada e os valores-base dessa origem;
2. Paladino recebe o valor antigo em `fe`; Feiticeiro recebe-o em `inteligencia`; nas quatro origens sem eixo mágico, usa `inteligencia` como destino neutro;
3. o outro atributo recebe o seu valor-base da origem;
4. apaga `sabedoria` e confirma que a soma de pontos acima da base não mudou.

Se já houver qualquer um dos campos modernos, a migração recusa o estado ambíguo em vez de duplicar pontos. A implementação entra junto de `appearance` e do aumento de versão já exigidos pelo [`64`](64-criacao-de-personagem.md), com fixture própria.

## 8. O que está fechado em papel e falta construir

Estas linhas deixaram de ser 🔴 de **spec**, mas continuam trabalho real. “Fechado” abaixo significa que há autoridade suficiente para implementar; não significa que o jogo já o faça.

| Produção ainda ausente | Autoridade | Marco e prova de saída |
|---|---|---|
| sete golpes, estados, segunda adaga e artes | [`68`](68-catalogo-de-armas-armaduras-e-aneis.md), [`70`](70-fecho-dos-sistemas-de-combate.md) | M2 · cada ficha executa frames/contacto/cue e matriz das famílias passa |
| 50 feitiços além da fatia, instrumentos e favoritos | [`66`](66-catalogo-de-magia.md) | M3/fatias futuras · renderer/hitbox/cue por forma; UI impede edição em combate |
| `TuningRecorder`, teleporte, latência e A/B | [`63`](63-como-se-afinam-os-numeros.md) | M2 · CSV reproduzível e três sessões; até lá números são baseline, não “confirmados” |
| criador, aparência, vozes e save v2 | [`64`](64-criacao-de-personagem.md), §7 acima | WP11 · 6 origens × kits, migração e round-trip |
| buses, directores, música, ambiente e vozes | [`65`](65-musica-e-ambiente.md) | WP12/15 · `GameplayInfo` protegido; 6 peças + 3 stingers e loops medidos |
| topologia/streaming/mapa/elevadores e 11 zonas | [`69`](69-catalogo-do-mundo.md), §§2–3 acima | WP8 · gargantas, conjunto residente, atalhos e persistência em duas máquinas |
| modelos e animação de esqueleto | [`21`](21-arte-render.md), [`44`](44-prototipo.md) | fase 1.2 · actor retargetado em cena e benchmark Iris Xe, sem inferir pela cápsula |

Música e os 12 guardiões/Ultra também dependem de autoria narrativa. A pergunta 34 e as sete perguntas do [`26`](26-narrativa.md) continuam dos donos; o agente não inventa essa identidade para poder escrever “completo”.

## 9. Quatro perguntas do fio solto

| Pergunta | Resposta deste fecho |
|---|---|
| Se um inimigo lança o mesmo feitiço, tem de fingir que medita? | Não. Partilha honestidade/contacto; IA declara cooldown/usos. |
| O golpe “a saltar” obriga o mundo a suportar salto livre? | Não. É uma investida terrestre e a geometria não exige salto. |
| Fugir de um subchefe é o mesmo que matá-lo? | Não. Fugir recompõe no descanso; matar persiste durante o ciclo. |
| Capturar microfone no Godot quer dizer que voz já está resolvida? | Não. Captura é nativa; codec/AEC/jitter/transporte e licença precisam do spike WP14. |

## 10. Critério de fecho

Este buraco fecha quando dados e testes provam: contrato de magia inimiga, verbos de travessia, ciclo de subchefe, catálogo português obrigatório e ligações de comando das acções nucleares. Dívida de produção fica no [`ESTADO`](../ESTADO.md), com marco; tensões e decisões reservadas aos donos ficam no [`99`](99-perguntas-abertas.md), sem resposta escondida neste fecho.
