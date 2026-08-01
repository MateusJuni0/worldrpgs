# Modelos importados para o runtime

Este directório é uma selecção deliberada dos packs CC0 em `art/models/`.
O Godot importa todos os ficheiros que encontra em `game/`, por isso cada
entrada tem de justificar um uso na Fatia 1.

| Runtime | Origem em `art/models/` | Uso |
|---|---|---|
| `characters/quaternius/Superhero_Male_FullBody.gltf` + `.bin` + 7 texturas | Universal Base Characters `[Standard]`, variante Godot/UE | corpo visual comum das seis classes jogáveis; um esqueleto de 65 ossos |
| `characters/quaternius-ultimate-monsters/{Orc_Small,Orc,Orc_Skull}.gltf` + `License.txt` | Quaternius Ultimate Monsters, distribuição oficial | só as três criaturas usadas pelo bestiário da Fatia 1: lanceiro, brutamontes e Vorgar; animações e texturas embebidas |
| `animations/quaternius/UAL1_Standard.glb` | Universal Animation Library `[Standard]`, variante sem root motion | biblioteca de animação compatível com o esqueleto Quaternius; movimento continua a pertencer à física |
| `environment/brumal/tree_{oak,thin,tall}_dark.glb` | Kenney Nature Kit | três silhuetas de carvalho negro para quebrar repetição sem importar o pack inteiro |
| `environment/brumal/rock_{largeA,largeC,smallA}.glb` | Kenney Nature Kit | três silhuetas de rocha para Brumal |
| `environment/brumal/ground_{grass,pathStraight}.glb` | Kenney Nature Kit | chão e leitura do caminho de Brumal |
| `environment/brumal/details/{grass_leafs,plant_bushSmall,mushroom_redGroup,log_large,stone_smallFlatA,flower_yellowB}.glb` | Kenney Nature Kit | seis famílias MultiMesh para vegetação rasteira, cogumelos, troncos, seixos, flores e detritos; não se copiou o pack inteiro |
| `environment/toca/{wall,wall_corner,wall_doorway,wall_broken,floor_tile_large,pillar,rubble_large,torch_mounted}.gltf` + `.bin` + `dungeon_texture.png` | KayKit Dungeon Pack 1.1 | kit mínimo para a entrada, três salas e arena da Toca |

Os dois URI de mapas normais do GLTF Quaternius apontavam para nomes que não
existem no pack (`*_png.png`). A cópia de runtime corrige esses URI para os
ficheiros CC0 fornecidos, sem alterar a biblioteca em `art/`.

As texturas do corpo usam compressão VRAM e mipmaps; corpo a 1024 px e cabelo
a 512 px. À distância de jogo preservam a leitura do original e evitam reter
os cinco mapas 2K sem compressão. O runtime extrai apenas a biblioteca de
animações do UAL, libertando a malha-manequim incluída no GLB.

## Verificação e limite da selecção

O `License.txt` junto dos monstros declara CC0 1.0. Foi lido a partir da pasta
oficial do pack antes de copiar os modelos; o cabeçalho traz a gralha
“Ultimate Platformer Pack”, registada também no `CREDITS.md`. Hashes SHA-256 das
fontes importadas: `Orc.gltf` `E61A37F8…526C1A3`, `Orc_Skull.gltf`
`E27E3ACF…28A710E` e `Orc_Small.gltf` `23D3E6E1…58B026`.

Não existe uma cópia integral de Ultimate Monsters em `art/` nem em `game/`:
entraram apenas três GLTF, 2,8 MiB no total. Do Nature Kit entraram seis GLB
adicionais, 55 KiB no total. Esta selecção é o limite deliberado do runtime.
