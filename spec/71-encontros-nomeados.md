# 71 — Encontros nomeados: os 36 rostos entre a multidão e os chefes

`[CODEX]` — execução da promessa decidida no [`53`](53-chefes-ritmo-e-o-mago-forte.md) e desenhada no mapa do [`69`](69-catalogo-do-mundo.md): **três nomeados por zona**, sem os transformar em chefes baratos.

O catálogo executável é [`game/data/named_encounters.json`](../game/data/named_encounters.json). Este documento explica a gramática; o JSON manda nos multiplicadores, frames, localização e carta.

## 1. O que é — e o que não é

Um nomeado é uma colocação singular de um tipo comum já aprendido:

1. conserva modelo, esqueleto, arma, hitboxes e ataques do tipo-base;
2. recebe **PV ×1,25–1,55** e postura **×1,10–1,30**;
3. acrescenta **exactamente um** ataque, com pelo menos 30 frames de aviso;
4. entrega uma carta garantida antes da carta normal do baralho do tipo;
5. não recebe arena selada, barra de chefe, música própria, fase ou regra de câmara.

Isto ocupa o intervalo entre comum e subchefe sem inflacionar a conta de chefes. O nome torna a colocação memorável; a diferença mecânica cabe numa pergunta nova, não numa segunda ficha de inimigo.

## 2. Catálogo fechado

| Zona | Três nomeados | Tipos reutilizados | Ataques que os distinguem | Garantias |
|---|---|---|---|---|
| Brumal | Ghar da Lança Partida · Urok Sete-Rebites · Nilo da Máscara Molhada | lanceiro · brutamontes · batedor | Lança arrastada · Ombro de ferro · Salto da máscara | limalha · couro de javali · bomba de bruma |
| Selva Funda | Sira dos Três Cipos · Brol Olho-de-Seiva · Kek do Sino Mudo | salteador · fundibulário · armadilheiro | Corte de cipo · Pedra colada · Laço sem som | vime · seiva · corda espinhosa |
| Campas Cinzentas | Mara das Cinzas Frias · O Vigia sem Aljava · Doma Dois-Pulsos | espadachim · arqueiro · zumbi túmido | Saudação partida · Flecha da mão · Segundo pulso | cinza · osso · bile-fátua |
| Fojo | Tik da Picareta Cega · Baran do Veio Vermelho · O Baú que Respira | kobold · minotauro · mímico | Prego de tecto · Arado de pedra · Tampa em falso | corda · chifre · madeira antiga |
| Costa Quebrada | Goram do Último Cabo · A Nadadora sem Mar · Vesa da Asa Cosida | orc do mar · submersa · ventaneira | Nó de ressaca · Mergulho em seco · Queda cosida | bronze · membrana · pena de tempestade |
| Cimeira | Vela Bico-de-Gelo · Torv Chifre Branco · A Peregrina Azul | ventaneira · minotauro · ventaneira | Picada de neve · Quebra-gelo · Asa em atraso | pena · chifre · flor-de-gelo |
| Fornalha | Brak do Martelo Oco · Mog Mãos-Negras · O Borralheiro Apagado | borralheiro · orc ferreiro · borralheiro | Eco do cadinho · Tenaz incandescente · Brasa sob cinza | bronze · obsidiana · sal de gelo |
| Fulgor | Rusk Chifre-Condutor · Ket do Sino Rachado · Zil Couro-Queimado | minotauro · kobold · kobold | Arco entre chifres · Toque sem badalo · Salto ao raio | chifre · fulgurite · couro seco |
| Raizama | A Tecedeira Lúmen · Gobo Sete-Chapéus · Seda-Que-Não-Cede | tecelã · goblin-fungo · tecelã | Rede luminosa · Nuvem de chapéu · Fio de retorno | seda · madeira-cogumelo · esporo-lúmen |
| Cidade Afogada | Ira Três-Mergulhos · O Sineiro do Fundo · Nema Rosto-de-Vidro | submersa · zumbi · submersa | Terceiro mergulho · Sino submerso · Estilhaço de maré | prata · mármore · vidro |
| Santuário Branco | Arvo da Voz Baixa · Celma dos Três Fumos · O Dourado sem Nome | cantor · turiferária · esqueleto | Nota sob a nota · Terceiro fumo · Genuflexão cortante | cera · ouro · véu de sombra |
| Raiz | O Terceiro Aro · Sor Que Lembra · A Lanterna Ajoelhada | Sem-Rosto · esqueleto antigo · esqueleto antigo | Aro descendente · Corte lembrado · Luz sob os pés | prata baça · lágrima · lanterna |

Os 36 ataques declaram `startup`, `active`, `recovery`, `parryable`, tell e vector. O tell nasce sempre de uma peça já visível no modelo-base: arma, máscara, sino, asa, chifre, lanterna ou postura. Nenhum exige ler cor sozinha.

## 3. Colocação e persistência

- O `encounter_id` pertence à colocação, não ao tipo-base. Duas instâncias do mesmo tipo continuam a partilhar o baralho comum; só a colocação nomeada entrega a garantia uma vez por ciclo do mundo.
- A garantia sai antes da compra comum. Se a morte for repetida pela rede, o `event_id` encontra o recibo e não paga outra carta.
- Descansar repõe o corpo enquanto houver reaparições, mas não repõe a garantia. A Brasa também não repõe cartas ou garantias já recebidas.
- Em NG+, a mesma colocação usa os multiplicadores do ciclo e conserva o ataque extra; não ganha outro. Largura nova pertence aos subchefes/guardiões decididos no [`58`](58-fim-do-jogo-ciclos-e-a-curva.md), não a esta ficha.

## 4. Razão e alternativa descartada

`[CODEX]` — **três fixos por zona**, em vez de sortear 2–3 em cada descanso. O mapa já prometia 2–3, mas 36 era a contagem registada em `LACUNAS`; três fixa a conta, permite tell/colocação aprendíveis e não transforma exploração em roleta. A alternativa descartada — nomes procedurais com bónus aleatórios — custava menos texto, mas quebrava honestidade, descrição visual e teste reproduzível.

## 5. As quatro perguntas do fio solto

| Pergunta | Resposta |
|---|---|
| Como é que o jogador usa isto? | encontra uma figura identificável no percurso, lê o tell extra e decide se aceita a luta pela carta garantida; não abre menu nem aprende comando novo |
| Como é que se prova? | o auto-teste conta 36, exige exactamente 3 nas 12 zonas, valida tipo-base/bioma, faixas de PV/postura, um ataque mensurável e recompensa resolvida |
| De onde vêm a arte e o som? | do modelo, arma, paleta e banco do inimigo-base; o tell usa uma âncora já descrita e o ataque adopta o perfil `GameplayCue` do seu vector; zero esqueleto, arena ou faixa novos |
| Quanto custa na máquina do Rico? | três registos por zona e um ataque disponível por nomeado; só a colocação carregada existe e a decisão continua nas fronteiras de ataque, sem polling global |

## 6. Fronteira honesta

As fichas e invariantes estão completas. A produção dos 33 tipos-base fora da Fatia 1 continua dependente dos modelos/animações já registados como construção futura; o nomeado não acrescenta essa dívida. Promover um deles para a Fatia 1 exige materializar o tipo-base e o seu único ataque extra, não redesenhar o encontro.

Este documento não decide nenhuma tensão reservada aos donos.
