# Modelos importados para o runtime

Este directório é uma selecção deliberada dos packs CC0 em `art/models/`.
O Godot importa todos os ficheiros que encontra em `game/`, por isso cada
entrada tem de justificar um uso na Fatia 1.

| Runtime | Origem em `art/models/` | Uso |
|---|---|---|
| `characters/quaternius/Superhero_Male_FullBody.gltf` + `.bin` + 7 texturas | Universal Base Characters `[Standard]`, variante Godot/UE | corpo visual comum do jogador e dos três orcs provisórios; um esqueleto de 65 ossos |
| `animations/quaternius/UAL1_Standard.glb` | Universal Animation Library `[Standard]`, variante sem root motion | biblioteca de animação compatível com o esqueleto Quaternius; movimento continua a pertencer à física |
| `environment/brumal/tree_{oak,thin,tall}_dark.glb` | Kenney Nature Kit | três silhuetas de carvalho negro para quebrar repetição sem importar o pack inteiro |
| `environment/brumal/rock_{largeA,largeC,smallA}.glb` | Kenney Nature Kit | três silhuetas de rocha para Brumal |
| `environment/brumal/ground_{grass,pathStraight}.glb` | Kenney Nature Kit | chão e leitura do caminho de Brumal |
| `environment/toca/{wall,wall_corner,wall_doorway,wall_broken,floor_tile_large,pillar,rubble_large,torch_mounted}.gltf` + `.bin` + `dungeon_texture.png` | KayKit Dungeon Pack 1.1 | kit mínimo para a entrada, três salas e arena da Toca |

Os dois URI de mapas normais do GLTF Quaternius apontavam para nomes que não
existem no pack (`*_png.png`). A cópia de runtime corrige esses URI para os
ficheiros CC0 fornecidos, sem alterar a biblioteca em `art/`.

As texturas do corpo usam compressão VRAM e mipmaps; corpo a 1024 px e cabelo
a 512 px. À distância de jogo preservam a leitura do original e evitam reter
os cinco mapas 2K sem compressão. O runtime extrai apenas a biblioteca de
animações do UAL, libertando a malha-manequim incluída no GLB.

## Limite conhecido

O catálogo de assets (`spec/22-assets.md`) escolhe Quaternius Monsters para o
lanceiro e o brutamontes, mas esse pack não está presente em `art/models/`.
Até ele existir, os inimigos usam variantes do corpo-base Quaternius para manter
o autor-âncora e o esqueleto partilhado. Não são modelos orc finais.
