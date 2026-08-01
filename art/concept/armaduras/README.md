# Armaduras — folhas de conceito

**Geradas 01-08-2026** com `nano_banana_pro` (Higgsfield), 2k, 2 créditos cada.
Pedido do Mateus: *"imagens a sério estilo Dark Souls 3 das armaduras, não coisinha de PS1"*.

| Ficheiro | Origem | O que define |
|---|---|---|
| `guerreiro.png` | warrior | couraça de ferro sobre couro endurecido, kit de soldado, remendado |
| `tanque.png` | tank | placa completa, elmo barril, escudo torre amassado e re-martelado |
| `paladino.png` | paladin | placa polida mas embaciada, capa de lã, sol desbotado no peito |
| `assassino.png` | assassin | pano e couro em camadas, capuz e máscara, duas adagas curtas |
| `berserker.png` | berserker | braços nus, ombreiras de pele, machado a duas mãos |
| `feiticeiro.png` | sorcerer | manto de lã pesada húmida, capuz fundo, cajado com foco azul baço |

## ⚠️ O que isto é, e o que não é

⭐ **É o ALVO, não o asset.** Estas imagens dizem ao modelador (humano ou agente) que
materiais, que silhueta e que grau de desgaste perseguir. **Não entram no jogo**
— o jogo continua a precisar de geometria e materiais que corram numa Iris Xe.

⚠️ **A distância entre isto e o que está no ecrã é o trabalho que falta.** Não
confundir ter o conceito com ter a armadura.

## A linha que não se atravessa

O Dark Souls é **referência de tom, nunca de conteúdo** ([`spec/31-referencias.md`](../../../spec/31-referencias.md)).
Nenhum destes pedidos nomeia armaduras, personagens ou lugares deles. O que se
pediu foi a **atmosfera** — sombria, gasta, crível — aplicada ao nosso mundo.

## Como gerar mais

O guião está em `art/PIPELINE.md`. A base de estilo é comum às seis — é isso que
garante que parecem do mesmo jogo. Mudar a base obriga a regenerar todas.
