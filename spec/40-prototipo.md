# 40 — O protótipo: o que já está provado

> **Fable, 31-07-2026.** Este documento existe por uma razão registada na spec: o `99` diz, sobre a pergunta 0b, que *"a medição não está sustentada no repositório — não há protótipo, log nem artefacto que a acompanhe"*. A ressalva era justa. **Os artefactos estão agora em [`medicoes/`](../medicoes/)** — os JSON crus que a ferramenta escreveu, sem edição.
>
> O protótipo em si continua **fora deste repositório**, por decisão do Mateus (aqui não entra código). Vive local, em `worldrpgs-game`, com o seu próprio historial. O que sobe aqui são **dados e conclusões**.

## 1. As medições, com prova

Godot 4.7.1-stable, renderer Mobile, 1920×1080, **na máquina do Rico — a mais fraca das duas**.

| Medição | Resultado | Ficheiro |
|---|---|---|
| Marco 1, **20 min contínuos quentes** | **416 fps** médios (frio 412) · 1% low 249,9 · pior frame 15,28 ms · **0,0% fora do orçamento** | [`mobile-quente.json`](../medicoes/mobile-quente.json) |
| **Critério 5 da fatia** (2 jogadores + 3 inimigos), vsync | **60,0 / 60,0 / 60,0** — 3601 frames a 16,67 ms | [`lei4-vsync-final.json`](../medicoes/lei4-vsync-final.json) |
| Forward+ (frio) | 235 fps · 1% low 172 · 95 MB VRAM | [`forward_plus-frio.json`](../medicoes/forward_plus-frio.json) |
| Mobile (frio) ✅ | 412 fps · 1% low 251 · 63 MB VRAM | [`mobile-frio.json`](../medicoes/mobile-frio.json) |
| Compatibility (frio) | 415 fps · **1% low 143** · 32 MB VRAM | [`gl_compatibility-frio.json`](../medicoes/gl_compatibility-frio.json) |
| Zona completa, depois de 4 iterações de melhoria | 268,7 fps · 1% low 147,7 · 0,0% fora do orçamento · **16 draw calls** | [`iter1-zona.json`](../medicoes/iter1-zona.json) |

**Renderer Mobile escolhido pelo 1% low, não pela média** — é o número que se sente. O Compatibility tem melhor média e pior 1% low: seria a escolha errada por olhar para a coluna errada.

**Sem degradação térmica mensurável** em 20 minutos (499 452 frames). A preocupação da série U fecha-se **para este nível de conteúdo**.

### O que estes números ainda NÃO provam

A honestidade que a spec exige, e que a aprovação dos donos não apaga:

- **Sem animação de esqueleto.** É a incógnita cara, e continua por medir. Cápsulas não são personagens animados.
- **Sem 25 imagens/texturas** aplicadas — o orçamento de VRAM real do WP12 ainda não foi exercido.
- A folga de ~6× é **orçamento para conteúdo**, não garantia.
- Memória cresceu ~14,5 MB em 20 min — a vigiar; 8 GB não perdoam.

O caminho A está escolhido com dados. A prova completa continua a ser o M1 do [`24-plano.md`](24-plano.md), com esqueletos animados.

## 2. O que já se joga

Construído e verificado por auto-teste (130 verificações contra a spec):

| Sistema | Estado | Fonte |
|---|---|---|
| Máquina de estados, esquiva (i-frames 0,08→0,38), parry (8 f) + riposte, bloqueio + guarda quebrada, stamina com histerese | ✅ fiel ao documento | [`01-combate.md`](01-combate.md) |
| As 5 armas com frames e MV exactos, hiper-armadura do machadão, poise/postura, lock-on, hit-stun | ✅ | [`01-combate.md`](01-combate.md) |
| Lanceiro e brutamontes, telegrafia ≥ 0,5 s, anti-kite aos 4 s | ✅ | [`15-inimigos.md`](15-inimigos.md) |
| Dardo, Ruína, Égide com cargas; interrupção gasta a carga | ✅ | [`13-magia.md`](13-magia.md) |
| Vorgar, 2 fases (padrões diferentes, não números), reset total | ✅ | [`16-chefes.md`](16-chefes.md) |
| **Frasco de cura** — 3 usos, 40% PV, 1,0 s a beber, recarrega no renascimento | ✅ `[PROTO]` | pergunta 7 |
| **Habilidades de classe** — Ímpeto, Fúria, Provocação jogáveis | ✅ `[PROTO]` | [`12-classes.md`](12-classes.md) |
| **Som** — 12 efeitos sintetizados em código, zero ficheiros e zero licenças | ✅ `[PROTO]` | [`21-arte-render.md`](21-arte-render.md) |

Tudo **data-driven**: nenhum número de combate vive em código. Afinar uma janela é editar JSON e voltar a correr.

## 3. Três coisas que só se descobrem a construir

### 3.1 A regra do Mateus apanhou um caso real, na primeira tentativa

O [`34-catalogo-e-comandos.md`](34-catalogo-e-comandos.md) fixa, com as palavras dele:

> *"não crie habilidades e depois não cria os comandos pra gente usar elas. Tem sempre que ver se vai funcionar."*

Ao implementar as habilidades de classe do WP3, foi exactamente o que aconteceu: **a tabela de comandos do [`01-combate.md`](01-combate.md) não tem tecla para a habilidade especial.** Seis habilidades escritas, zero maneiras de as activar.

O protótipo usa `V` `[PROTO]`. **A decisão é dos donos** — e a regra do Mateus fica validada por um caso concreto, não por teoria.

### 3.2 Três lacunas mais na tabela de comandos

Nenhuma tinha tecla; o protótipo atribuiu provisórias para poder correr:

| Acção | Tecla `[PROTO]` | Porquê era preciso |
|---|---|---|
| Habilidade de classe | `V` | 3.1 acima |
| Conjurar magia | `C` | a tabela só tinha "magia seguinte: F" |
| Bash de escudo | `LMB` com bloqueio activo | o WP1 dá o bash ao escudo, sem botão |
| Andar (3,0 m/s) | `Ctrl` | o teclado não tem analógico |

### 3.3 Duas contradições internas na spec, encontradas ao implementar

- **O cajado** estava listado como arma de duas mãos *e* como combinável com escudo. Corrigido no PR do WP1: vale a tabela de bloqueio.
- **Hiper-armadura do machadão** — "frames 30–48" à letra deixava o golpe **carregado** desprotegido no momento do impacto. Corrigido para "do frame 30 até ao fim dos frames activos".

## 4. A divergência que continua aberta, e é a mais urgente

**O parry tem dois botões diferentes em dois documentos aprovados:**

| Documento | Proposta |
|---|---|
| [`01-combate.md`](01-combate.md) (WP1, Fable) | parry em `Q` — botão dedicado |
| [`25-controlo.md`](25-controlo.md) (WP1B, Claude) | parry no **toque** de `RMB`; bloqueio no segurar |

São filosofias diferentes, as duas defensáveis, e **o próprio WP1B avisa que a escolha contamina todos os testes da Lei 1**. Não se decide no papel: o protótipo tem as duas a um `if` de distância, e quem joga decide em cinco minutos.

**Precisa de decisão de:** Mateus + Rico, depois de jogarem.

## 5. Como o Rico abre isto

O protótipo está na máquina dele. Dois cliques em `JOGAR.bat`; `F2` mostra os comandos; `F6` troca de classe em jogo.

## Ligações

- Restrição de hardware e a tensão 0b: [`09-tecnico.md`](09-tecnico.md)
- Plano e marcos: [`24-plano.md`](24-plano.md)
- Regra dos comandos: [`34-catalogo-e-comandos.md`](34-catalogo-e-comandos.md)
- Artefactos crus: [`medicoes/`](../medicoes/)
