# 07 — Ícones das 11 armaduras da Fatia 1

> Fonte: [`spec/68`](../../spec/68-catalogo-de-armas-armaduras-e-aneis.md) §6 e `game/data/armor.json`. Uma imagem por prompt; objecto isolado, vista de três quartos, sem corpo, texto, pedestal ou sombra projectada. Geração em fundo verde puro `#00ff00`, removido para alfa real com o helper da skill `imagegen`; saída nativa 1254×1254 com alfa real, reduzida pelo importador de UI quando necessário.

Todos os prompts começam literalmente com:

> **Stylized dark fantasy game art, hand-painted look, muted earthy colors with cold mist accents, simple readable shapes, low-poly-friendly design, no photorealism, grim and unforgiving, no whimsy.**

| ID | Assunto exacto depois da frase de estilo | Caminho |
|---|---|---|
| `ico_arm_couro_peitoral` | single boiled dark-brown boar-leather cuirass, thick visible stitching, scuffed use marks, broad chest panel and side straps | `art/ui/icons/armor/couro-peitoral.png` |
| `ico_arm_couro_botas` | single pair of brown leather mid-calf boots, worn thick soles, rawhide strip laces, toes slightly apart | `art/ui/icons/armor/couro-botas.png` |
| `ico_arm_ferro_elmo` | single rough hammered iron helmet, unpolished surface, T-shaped visor slit, exposed round rivets | `art/ui/icons/armor/ferro-elmo.png` |
| `ico_arm_ferro_peitoral` | single cuirass of dull riveted iron plates over dark leather, reinforced shoulders, broad readable silhouette | `art/ui/icons/armor/ferro-peitoral.png` |
| `ico_arm_ferro_peitoral_polido` | single mirror-polished iron cuirass, shallow lightning relief centered on chest, pale leather straps | `art/ui/icons/armor/ferro-peitoral-polido.png` |
| `ico_arm_pano_mascara` | single charcoal-grey cloth mask covering nose and mouth, long rear knot and two cloth ties, no head or face | `art/ui/icons/armor/pano-mascara.png` |
| `ico_arm_pano_botas` | single pair of soft dark-cloth ankle boots, thin quiet soles, wrapped fabric closures, toes slightly apart | `art/ui/icons/armor/pano-botas.png` |
| `ico_arm_couro_ombreiras` | single pair of raw leather shoulder guards topped with coarse dark boar fur, crossed chest straps visible | `art/ui/icons/armor/couro-ombreiras.png` |
| `ico_arm_la_capa` | single charcoal waxed-wool cloak, heavy folds, deep hood, hem at calf height, hanging without a body | `art/ui/icons/armor/la-capa.png` |
| `ico_arm_la_capa_clara` | single raw off-white wool cloak, worn dull-gold edging, hood folded back, hanging without a body | `art/ui/icons/armor/la-capa-clara.png` |
| `ico_arm_couro_cinto` | single broad brown leather belt with four unequal pouches, cork stoppers peeking out, iron buckle | `art/ui/icons/armor/couro-cinto.png` |

Sufixo comum: `centered game inventory icon, three-quarter view, fully inside frame, one object only, flat pure #00ff00 chroma key background edge to edge, no gradient, no floor, no cast shadow, no text, no border, no person, no mannequin.`

**Sai bem se:** a silhueta se lê a 64 px, o material continua inequívoco e o recorte não come correias, atacadores, pelo ou bainha.
