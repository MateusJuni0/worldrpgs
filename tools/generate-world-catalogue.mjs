#!/usr/bin/env node
/**
 * Gera o catálogo fechado do WP8. A leitura do mapa aparece antes da topologia
 * de propósito: spec/57 §5 torna essa ordem parte do contrato.
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const read = (relative) => JSON.parse(fs.readFileSync(path.join(root, relative), "utf8"));
const biomes = read("game/data/biomes.json");
const realBiomes = Object.fromEntries(Object.entries(biomes).filter(([id]) => !id.startsWith("_")));
const boolMark = (value) => value ? "✅" : "⬜";
const asset = (relative) => `res://../${relative}`;

const profiles = {
  brumal: {
    minutes: 8, common: 12, elites: 3, named: 2, rests: 2,
    tiers: ["orla de carvalho a 0 m", "lombo da árvore morta a +7 m", "leito de bruma a -4 m"],
    route: "Orla → caminho médio → clareira do brutamontes → árvore morta → porta da Toca",
    landmarks: [
      ["Arco Partido", "arco de granito musgoso com 9 m, metade esquerda tombada entre carvalhos negros"],
      ["Árvore Morta", "carvalho negro sem copa com 24 m, raízes levantadas e uma fenda de rocha por baixo"],
      ["Farol dos Corvos", "torre baixa de granito com 12 m, três varas de ferro cobertas de corvos e braseiro âmbar"],
    ],
    horizontal: ["Portão da Clareira", "trilho exterior da clareira à orla", "portão duplo de carvalho-negro com ferragens rudes, 4 m de largura, visto primeiro por trás"],
    vertical: [7, "escada de raiz e plataforma que desce ao leito de bruma", "plataforma quadrada de carvalho-negro suspensa por duas correntes de ferro rude, entre raízes de 2 m"],
    shortcut: ["Portão da Árvore", "árvore morta → Orla, repetição em 38 s", "cancela de troncos negros com lingueta de ferro acessível apenas no lado da árvore morta"],
    dungeon: ["A Toca", "fenda sob a árvore morta", "tronco sem copa visível a 60 m; corvos entram na fenda e não voltam", "entrada de rocha húmida com 2,5 m sob raízes de carvalho-negro, penas presas na bruma"],
    threat: ["bruma de borda", "a bruma fica opaca durante 3 s e vira o jogador para terreno seguro", "densidade sobe em três degraus; ramos e pedras apontam de volta", "recuar antes dos 3 s"],
    threat_runtime: "safe_turn_volume",
    threat_rules: { telegraph_s: 3.0, turn_speed_deg_s: 180.0, control_lock_s: 0.5, cooldown_s: 8.0 },
    threat_unresolved: [],
  },
  selva_funda: {
    minutes: 10, common: 14, elites: 4, named: 2, rests: 3,
    tiers: ["solo de raízes a 0 m", "aldeia de passadiços a +18 m", "copas de vigia a +40 m"],
    route: "Raízes → elevador de contrapeso → aldeia suspensa → ponte dos espinhos → ninho do guardião",
    landmarks: [
      ["Figueira Escada", "figueira estranguladora com 45 m, degraus de vime enrolados no tronco e flores magenta na copa"],
      ["Ninho Partido", "taça de espinhos gigantes com 16 m presa entre três copas, metade caída em fios de seda"],
      ["Cascata Verde", "queda de água com 38 m coberta por trepadeiras, espuma verde visível entre os passadiços"],
    ],
    horizontal: ["Anel das Copas", "ponte exterior que volta da aldeia ao elevador", "passadiço circular de vime trançado com 3 m de largura, guarda de espinhos e flores peçonha"],
    vertical: [40, "elevador goblin de dois cestos entre raízes e copas", "dois cestos de vime com 4 m presos a roldanas de bambu negro e contrapesos de pedra"],
    shortcut: ["Escada da Seiva", "ninho do guardião → aldeia, repetição em 52 s", "escada de corda e seda crua enrolada numa viga, solta apenas da plataforma superior"],
    dungeon: ["Casulo Vazio", "bolsa de seda atrás da Cascata Verde", "fios secos atravessam a água; pequenas carapaças acumulam-se na margem", "casulo oval de seda crua com 5 m, rasgado por dentro e preso a raízes negras molhadas"],
    threat: ["passadiço cedente", "tábua marcada range 1,2 s antes de cair para uma rede 4 m abaixo", "vime esbranquiçado, fibras soltas e oscilação crescente", "sair da placa ou usar a queda segura para o piso inferior"],
    threat_runtime: "collapsing_floor",
    threat_rules: { telegraph_s: 1.2, safe_fall_m: 4.0, reset_s: 12.0 },
    threat_unresolved: [],
  },
  campas_cinzentas: {
    minutes: 9, common: 13, elites: 3, named: 3, rests: 2,
    tiers: ["lodo e campas a 0 m", "diques funerários a +5 m", "ossário drenado a -6 m"],
    route: "Cais seco → lápides inclinadas → dique dos estandartes → ossário → capela do guardião",
    landmarks: [
      ["Salgueiro Enforcado", "salgueiro morto com 19 m, raízes sobre água cinzenta e dezenas de elmos ferrugentos pendurados"],
      ["Dique dos Estandartes", "muralha de madeira encharcada com 6 m, coberta por panos cinzentos e lanças partidas"],
      ["Lua no Ossário", "óculo circular de pedra com 8 m reflectido no lodo, rodeado por ossos ordenados em espiral"],
    ],
    horizontal: ["Dique de Regresso", "coroa seca em redor do pântano até ao cais", "passagem de madeira encharcada sobre estacas de osso, 3 m de largura e archotes verde-água"],
    vertical: [6, "comporta baixa o lodo e revela a escada do ossário", "comporta de ferro ferrugento com roda de 2 m, canais de pedra e água cinzenta a escorrer"],
    shortcut: ["Comporta dos Mortos", "capela → cais seco, repetição em 45 s", "grade de ferro comida de ferrugem num canal estreito, manivela de osso apenas no lado da capela"],
    dungeon: ["Ossário Sem Ordens", "cripta sob o dique dos estandartes", "água corre para baixo entre duas lápides; um estandarte aponta contra o vento", "escadaria de pedra afundada entre lápides, degraus de osso seco e fogos-fátuos verde-água"],
    threat: ["lodo que agarra", "andar no lodo reduz a deslocação para 50%; rolar sai para terreno seco", "água opaca só até ao joelho, bolhas em linha e estacas que marcam o caminho firme", "usar diques ou rolar para uma ilha seca"],
    threat_runtime: "movement_volume",
    threat_rules: { movement_multiplier: 0.5 },
    threat_unresolved: [],
  },
  fojo: {
    minutes: 9, common: 16, elites: 4, named: 2, rests: 3,
    tiers: ["bordo do desfiladeiro a 0 m", "andaimes de mina a -12 m", "labirinto antigo a -28 m"],
    route: "Boca alta → andaimes → praça das roldanas → veio partido → labirinto do guardião",
    landmarks: [
      ["Guindaste de Pedra", "pilar de granito com 22 m, braço de madeira e roda dentada de ferro em bruto sobre o abismo"],
      ["Veio Rubro", "fenda mineral com 30 m de comprimento, ferro vermelho exposto e pó ocre suspenso"],
      ["Cabeça do Labirinto", "fachada de granito talhada como focinho de touro com 14 m, uma narina serve de entrada"],
    ],
    horizontal: ["Galeria de Contramina", "túnel exterior que devolve a praça à boca alta", "galeria de granito com 4 m, carris de ferro bruto e escoras de madeira marcadas por picareta"],
    vertical: [28, "plataforma de minério em três paragens", "jaula de ferro em bruto com 5 m presa a roldana de madeira, contrapeso de blocos de granito"],
    shortcut: ["Elevador do Veio", "labirinto → boca alta, repetição em 58 s", "plataforma de ferro de 4 m, alavanca dentada voltada para o fundo da mina e corrente grossa"],
    dungeon: ["Contramina Cega", "porta lateral atrás do Veio Rubro", "corrente de ar desloca a poeira; marcas de picareta terminam numa parede lisa", "porta rectangular de granito sem dobradiças, contorno de pó limpo e cunhas de ferro no chão"],
    threat: ["armadilhas kobold", "placas visíveis activam dardos ou queda sobrevivível de 4 m após 0,8 s", "pedra mais clara, fio de cobre e orifícios alinhados na parede", "parar antes da placa, recuar para fora da faixa ou bloquear os dardos"],
    threat_runtime: "pressure_plate_trap",
    threat_rules: { telegraph_s: 0.8, safe_fall_m: 4.0, dart_speed_m_s: 18.0, dart_damage: 45, reset_s: 10.0 },
    threat_unresolved: [],
  },
  costa_quebrada: {
    minutes: 11, common: 15, elites: 4, named: 3, rests: 2,
    tiers: ["praia de destroços a 0 m", "terraços de falésia a +16 m", "farol quebrado a +34 m"],
    route: "Praia → casco inclinado → terraço de azinhavre → escada do farol → promontório do guardião",
    landmarks: [
      ["Navio Vertical", "proa de madeira de naufrágio com 28 m cravada no basalto, mastros horizontais cobertos de corda"],
      ["Farol Cego", "torre de basalto com 34 m, cúpula partida e lentes verdes espalhadas pela encosta"],
      ["Três Dentes", "três agulhas de basalto no mar, cada uma com correntes de bronze verde presas ao topo"],
    ],
    horizontal: ["Ronda do Farol", "terraço abrigado que volta do farol ao casco", "caminho de basalto com 3 m entre parede molhada e parapeito de bronze coberto de azinhavre"],
    vertical: [34, "guincho de carga usa a quilha do navio como contrapeso", "gaiola de convés com tábuas salgadas, aro de bronze verde e corrente presa ao mastro quebrado"],
    shortcut: ["Guincho da Quilha", "promontório → praia, repetição em 49 s", "plataforma de madeira de naufrágio com travão de bronze, libertado apenas junto ao farol"],
    dungeon: ["Porão ao Contrário", "escotilha no casco do Navio Vertical", "água pinga para o lado errado; gaivotas pousam em redor mas nunca na tampa", "escotilha quadrada de bronze verde num casco vertical, corda salgada e cracas a formar um aro"],
    threat: ["rajada de falésia", "faixa exposta recebe empurrão máximo de 1,5 m após assobio de 1 s", "fitas de vela, chuva inclinada e espuma movem-se antes da força", "baixar-se atrás de quebra-ventos ou sair da faixa marcada"],
    threat_runtime: "wind_lane",
    threat_rules: { telegraph_s: 1.0, max_push_m: 1.5, lane_width_m: 4.0, repeat_interval_s: 8.0 },
    threat_unresolved: [],
  },
  cimeira: {
    minutes: 10, common: 14, elites: 3, named: 2, rests: 3,
    tiers: ["linha das nuvens a 0 m", "escadaria dos vigias a +22 m", "observatório a +48 m"],
    route: "Abrigo baixo → escadaria → ponte de gelo → vigia intermédia → observatório do guardião",
    landmarks: [
      ["Agulha Azul", "obelisco de gelo-azul com 31 m, translúcido e preso por três correntes de aço frio"],
      ["Observatório Partido", "cúpula de pedra branca com 26 m, metade aberta ao céu e telescópio virado para a Raiz"],
      ["Cabra de Pedra", "estátua de granito branco com 18 m, cornos cobertos de bandeiras azuis rasgadas"],
    ],
    horizontal: ["Varanda das Nuvens", "cornija larga que regressa do observatório ao abrigo", "varanda de pedra branca com 3 m, parapeito de aço frio e nuvens abaixo do chão"],
    vertical: [48, "elevador de vigia dentro da Agulha Azul", "cabina octogonal de aço frio e pele branca, suspensa numa fissura de gelo-azul iluminada"],
    shortcut: ["Ascensor da Agulha", "observatório → abrigo baixo, repetição em 55 s", "porta de aço frio sem puxador no piso baixo, alavanca azul apenas na estação superior"],
    dungeon: ["Sala do Horizonte", "porta sob o Observatório Partido", "a neve nunca assenta num círculo de 5 m; a sombra do telescópio aponta para a junta", "porta circular de aço frio com 4 m, vidro azul rachado e marcas de luvas na face interior"],
    threat: ["frio de exposição", "após 25 s sem abrigo, stamina máxima perde 5% a cada 20 s até ao tecto de 25%", "vinheta de gelo cresce em cinco marcas e a respiração ganha equivalente visual branco", "entrar num abrigo; recupera 10% por segundo junto a uma fogueira"],
    threat_runtime: "exposure_meter",
    threat_rules: { exposure_delay_s: 25.0, tick_s: 20.0, loss_fraction_per_tick: 0.05, max_loss_fraction: 0.25, recovery_fraction_s: 0.10 },
    threat_unresolved: [],
  },
  fornalha: {
    minutes: 10, common: 17, elites: 5, named: 2, rests: 2,
    tiers: ["escória fria a 0 m", "anel das forjas a +14 m", "cratera alimentadora a +32 m"],
    route: "Pátio de escória → forjas gémeas → ponte de obsidiana → chaminé → cratera do guardião",
    landmarks: [
      ["Martelo Imóvel", "martelo de forja em bronze com 20 m, suspenso sobre uma bigorna de obsidiana partida"],
      ["Sete Chaminés", "fileira de torres negras com 35 m, seis apagadas e uma a lançar fumo laranja"],
      ["Rio Preso", "canal de lava com 12 m de largura congelado por comportas de bronze fundido"],
    ],
    horizontal: ["Coroa da Bigorna", "galeria exterior em redor das forjas até ao pátio", "passadiço de placas de obsidiana com 4 m, rebites de bronze e calhas de lava cobertas"],
    vertical: [32, "elevador de cadinhos sobe pelo interior da chaminé activa", "cesto de bronze fundido com 5 m, placas de obsidiana e correntes negras sem partes móveis simuladas"],
    shortcut: ["Cadinho de Regresso", "cratera → pátio de escória, repetição em 57 s", "elevador de cadinho com trinco cerâmico acessível só no anel superior das forjas"],
    dungeon: ["Forja Sem Ferreiro", "conduta por baixo do Martelo Imóvel", "brasas formam pegadas que entram na parede; o bronze está quente só numa placa", "alçapão de bronze quadrado com 3 m, borda de obsidiana lascada e calor ondulante visível"],
    threat: ["crosta rubra", "crosta marcada cede 1 s depois e deixa cair 4 m numa calha lateral, nunca no vazio", "vermelho pulsante, fissuras concêntricas e pó a subir antes da quebra", "sair da placa ou aceitar o atalho de queda sobrevivível"],
    threat_runtime: "collapsing_floor",
    threat_rules: { telegraph_s: 1.0, safe_fall_m: 4.0, reset_s: 12.0 },
    threat_unresolved: [],
  },
  fulgor: {
    minutes: 9, common: 16, elites: 4, named: 3, rests: 3,
    tiers: ["planalto rachado a 0 m", "torres de fulgurite a +17 m", "olho da tempestade a +36 m"],
    route: "Marco de terra → campo rachado → bosque de vidro → espiral das torres → olho do guardião",
    landmarks: [
      ["Árvore de Vidro", "fulgurite ramificada com 24 m, centenas de pontas violetas fundidas num único impacto"],
      ["Pedra Aterrada", "monólito de granito com 15 m coberto por correntes que desaparecem no chão seco"],
      ["Olho Baixo", "anel de nuvens violeta visível a 36 m de altura, centrado numa torre de vidro torcida"],
    ],
    horizontal: ["Anel das Correntes", "trilho aterrado à volta das torres até ao marco inicial", "caminho de pedra escura com 4 m, correntes enterradas e fragmentos de fulgurite fora da faixa"],
    vertical: [36, "espiral de rampas entre torres de vidro ligadas", "rampa helicoidal de pedra seca com 4 m, guarda de osso e fulgurite a brilhar do lado exterior"],
    shortcut: ["Pára-Raios Tombado", "olho → Marco de terra, repetição em 46 s", "torre de fulgurite inclinada que vira ponte quando a corrente interior é libertada no topo"],
    dungeon: ["Câmara do Nono Raio", "fenda sob a Pedra Aterrada", "as correntes vibram sem vento; nove cicatrizes convergem na base", "abertura triangular no granito com 3 m, correntes negras, vidro violeta e areia fundida no limiar"],
    threat: ["queda de relâmpago", "o impacto ocorre 1 s depois de um círculo de 3 m acender no chão", "fissuras violetas convergem, poeira levanta e a silhueta do jogador ganha contorno branco", "sair do círculo ou ficar sobre a Pedra Aterrada"],
    threat_runtime: "strike_marker",
    threat_rules: { telegraph_s: 1.0, radius_m: 3.0, damage: 90, repeat_interval_s: 8.0 },
    threat_unresolved: [],
  },
  raizama: {
    minutes: 11, common: 15, elites: 4, named: 2, rests: 2,
    tiers: ["carcaça profunda a 0 m", "pontes de raiz a +21 m", "copas de cogumelo a +43 m"],
    route: "Costela aberta → lago de esporos → ponte de raiz → cogumelos-torre → crânio do guardião",
    landmarks: [
      ["Costela-Mãe", "arco de osso antigo com 38 m coberto por raízes e cogumelos ciano"],
      ["Lago de Luz", "bacia circular com 45 m cheia de esporos luminosos, sem água visível"],
      ["Crânio-Catedral", "crânio pétreo com 50 m, órbitas ocupadas por torres de cogumelo e teias"],
    ],
    horizontal: ["Círculo das Costelas", "passagem exterior que liga o crânio à costela aberta", "ponte de raízes entre arcos de osso, 4 m de largura, seda presa como guarda e esporos por baixo"],
    vertical: [43, "elevador de seda entre a carcaça e as copas", "plataforma de quitina com 5 m presa por oito fios de seda, guiada dentro de um tronco oco"],
    shortcut: ["Fio do Crânio", "crânio → Costela-Mãe, repetição em 59 s", "elevador de seda enrolado numa mandíbula gigante, comando de quitina apenas no topo"],
    dungeon: ["Medula Oca", "fissura dentro da Costela-Mãe", "esporos são sugados para a fenda; a seda forma setas viradas para dentro", "fenda vertical de 3 m em osso antigo, borda coberta de quitina e luz ciano a respirar"],
    threat: ["nuvem de esporos", "atravessar acumula veneno a 35 por segundo; fora da nuvem decai 20 por segundo", "volume ciano opaco com partículas a correr para cima e barra visível", "rebentar o saco à distância ou esperar a nuvem baixar"],
    threat_runtime: "buildup_volume",
    threat_rules: { poison_buildup_per_s: 35.0, poison_decay_per_s: 20.0, cloud_radius_m: 3.5, cloud_lifetime_s: 6.0, sack_respawn_s: 15.0 },
    threat_unresolved: [],
  },
  cidade_afogada: {
    minutes: 10, common: 18, elites: 5, named: 2, rests: 3,
    tiers: ["praça inundada a 0 m", "telhados e aquedutos a +13 m", "campanários a +31 m"],
    route: "Cais de mármore → mercado raso → aqueduto → telhados → torre do guardião",
    landmarks: [
      ["Sino à Tona", "campanário de mármore com 31 m, metade submerso, sino de prata escurecida acima da água"],
      ["Praça do Espelho", "praça circular com 40 m sob água verde-clara, mosaico visível inteiro da cobertura"],
      ["Aqueduto Quebrado", "arcada de mármore com 120 m, três vãos caídos e cascatas finas sobre os telhados"],
    ],
    horizontal: ["Ronda dos Telhados", "passarela seca que regressa da torre ao cais", "telhados de mármore ligados por pranchas de 4 m, corrimão de prata e vidro verde nas juntas"],
    vertical: [31, "contrapeso do sino move uma plataforma entre praça e campanário", "plataforma de mármore de 5 m suspensa por corrente de prata, água a cair das quatro bordas"],
    shortcut: ["Ascensor do Sino", "torre → cais, repetição em 51 s", "plataforma do campanário com alavanca de prata no piso superior e contrapeso visível sob a água"],
    dungeon: ["Arquivo Submerso", "porta seca sob o Aqueduto Quebrado", "folhas de prata boiam contra a corrente; bolhas escapam por uma junta acima da água", "porta de mármore azul com 4 m, moldura de prata escurecida e vidro verde intacto no centro"],
    threat: ["água profunda", "a rota principal usa passadiços; zonas opcionais fundas têm fundo caminhável lento e desactivam ataque e esquiva", "mudança do mármore claro para mosaico azul e silhuetas visíveis sob a água", "ficar nos aquedutos; a água funda nunca exige natação livre"],
    threat_runtime: "deep_water_volume",
    threat_rules: { free_swimming: false, deep_water_movement_multiplier: 0.45 },
    threat_unresolved: [],
  },
  santuario_branco: {
    minutes: 9, common: 17, elites: 4, named: 3, rests: 2,
    tiers: ["pátio das velas a 0 m", "claustro solar a +11 m", "coro alto a +27 m"],
    route: "Pórtico baço → pátio → nave sem sombra → claustro → coro do guardião",
    landmarks: [
      ["Sol de Mármore", "disco de mármore branco com 21 m suspenso por vigas douradas sobre a nave"],
      ["Mil Velas", "escadaria com 70 m coberta por velas de cera benta, todas da mesma altura e ainda acesas"],
      ["Sombra Vertical", "faixa negra com 27 m numa parede branca, recta apesar das colunas e da luz em redor"],
    ],
    horizontal: ["Claustro do Avesso", "corredor exterior que volta do coro ao pórtico", "claustro de mármore branco com 4 m, colunas douradas e sombras negras apontadas contra a luz"],
    vertical: [27, "elevador de altar sobe pela nave atrás do Sol de Mármore", "plataforma branca de 5 m coberta por cera, guiada por correntes de ouro baço dentro da parede"],
    shortcut: ["Altar Ascendente", "coro → pórtico, repetição em 43 s", "altar quadrado de mármore que desce quando a vela vermelha do coro é apagada pelo lado interior"],
    dungeon: ["Sacristia Sem Olhos", "porta atrás da Sombra Vertical", "a sombra continua por baixo da moldura; cera derretida corre para a porta em vez de sair", "porta estreita de mármore com 3 m, dez relevos sem olhos e uma linha de sangue seco na soleira"],
    threat: ["luz cegante", "encarar um foco marcado acumula 25 por segundo após 0,8 s; a barra cheia cega durante 3 s", "padrão radial no chão, sobre-exposição gradual e borda negra fora do foco", "olhar para baixo, quebrar visão numa coluna ou entrar na sombra"],
    threat_runtime: "gaze_meter",
    threat_rules: { exposure_delay_s: 0.8, blind_buildup_per_s: 25.0, blind_threshold: 100.0, blind_duration_s: 3.0 },
    threat_unresolved: [],
  },
  raiz: {
    minutes: 12, common: 20, elites: 5, named: 2, rests: 3,
    tiers: ["rio de bruma a 0 m", "raízes petrificadas a +24 m", "lábio do Portão a +52 m"],
    route: "Foz invertida → floresta de raízes → ponte negra → espiral da bruma → lábio do guardião",
    landmarks: [
      ["Rio Ascendente", "curso de bruma pálida com 20 m de largura que sobe em cascata para o tecto negro"],
      ["Raiz-Torre", "raiz petrificada com 52 m, oca ao centro e cercada por plataformas de prata baça"],
      ["Lábio do Portão", "arco de pedra negra com 30 m, selado por bruma violeta e raízes partidas para fora"],
    ],
    horizontal: ["Anel da Foz", "ponte exterior que devolve o lábio ao rio ascendente", "passagem de raiz petrificada com 5 m, placas de prata baça e bruma a correr para cima dos dois lados"],
    vertical: [52, "espiral interior da Raiz-Torre com três patamares", "escada helicoidal talhada em raiz negra, 5 m de largura, prata baça nas bordas e poço de bruma ao centro"],
    shortcut: ["Queda Invertida", "lábio → Foz invertida, repetição em 60 s", "plataforma de raiz que desce contra o fluxo da bruma quando o selo de prata no topo é quebrado"],
    dungeon: ["Câmara da Primeira Fenda", "abertura por trás do Rio Ascendente", "a bruma divide-se à volta de um rectângulo vazio; raízes quebradas apontam para dentro", "fenda rectangular de 5 m em pedra negra, moldura de prata baça e bruma pálida a contornar o vazio"],
    threat: ["escuro absoluto", "fora dos focos de bruma a visibilidade cai para 6 m; a lanterna ocupa a mão esquerda", "silhuetas brancas nas bordas, reflectores de prata no caminho e olhos do parceiro realçados", "usar a lanterna, caminhar junto ao rio ou trocar defesa por visão"],
    threat_runtime: "visibility_volume",
    threat_rules: { visibility_m: 6.0, lantern_slot: "left_hand", lantern_item_id: "consumivel:lanterna_raiz" },
    threat_unresolved: [],
  },
};

const edges = [
  ["brumal", "selva_funda", "garganta de raízes", "raízes de carvalho-negro apertam um corredor de 5 m e tornam-se vime verde na saída"],
  ["brumal", "campas_cinzentas", "vale da bruma baixa", "trilho de pedra musgosa desce entre carvalhos negros até a água cinzenta cobrir as raízes"],
  ["brumal", "fojo", "arco da pedreira", "arco de granito partido fecha-se num corte ocre com carris de ferro bruto sob a bruma"],
  ["selva_funda", "fojo", "barranco das roldanas", "bambu negro e seda cedem lugar a andaimes de granito e uma roldana sobre o desfiladeiro"],
  ["selva_funda", "costa_quebrada", "rio das copas", "passadiço de vime acompanha água verde até árvores baixas retorcidas pelo vento salgado"],
  ["campas_cinzentas", "fojo", "dreno da mina", "canal de madeira encharcada entra num túnel de granito onde o lodo deixa marcas ferrugentas"],
  ["campas_cinzentas", "cidade_afogada", "calçada submersa", "lápides inclinadas transformam-se em marcos de mármore sob água verde cada vez mais funda"],
  ["fojo", "fulgor", "rampa do veio vítreo", "galeria de ferro abre num planalto onde o minério passa a vidro violeta fundido por raios"],
  ["costa_quebrada", "cimeira", "escada do granizo", "degraus de basalto molhado sobem entre mastros partidos até a chuva se tornar neve branca"],
  ["costa_quebrada", "cidade_afogada", "molhe quebrado", "molhe de madeira e bronze desce para telhados de mármore rodeados por água verde-clara"],
  ["cimeira", "fulgor", "colo da tempestade", "neve azul recua numa garganta de pedra seca onde nuvens violetas rodam abaixo da crista"],
  ["cimeira", "santuario_branco", "procissão gelada", "escadaria de pedra branca perde a neve e ganha filas de velas protegidas por nichos de ouro baço"],
  ["fornalha", "fulgor", "campo de escória vítrea", "obsidiana rachada arrefece em areia fundida, com relâmpagos presos em agulhas violetas"],
  ["fornalha", "raizama", "chaminé de esporos", "conduta de obsidiana desce até raízes húmidas onde brasas laranja passam a pontos ciano"],
  ["fornalha", "santuario_branco", "via dos cadinhos votivos", "placas de bronze queimado tornam-se degraus de ouro baço cobertos por cera derretida"],
  ["fulgor", "raiz", "fenda aterrada", "correntes enterradas mergulham numa abertura de pedra negra onde a bruma sobe contra a gravidade"],
  ["raizama", "cidade_afogada", "aqueduto micelial", "raízes e cogumelos envolvem um aqueduto de mármore até a água substituir o chão"],
  ["raizama", "raiz", "costela petrificada", "osso coberto de seda escurece e cresce até ser indistinguível das raízes-torre do abismo"],
  ["cidade_afogada", "santuario_branco", "via das estátuas lavadas", "estátuas de mármore saem da água em fila e chegam secas, cobertas de cera branca"],
  ["santuario_branco", "raiz", "escada da sombra inteira", "mármore excessivamente branco escurece degrau a degrau até virar pedra negra com prata baça"],
  ["fojo", "fornalha", "veio da escória", "carris de ferro bruto descem por granito quente até a rocha ficar negra e o bronze aparecer fundido"],
];

const doorSeeds = {
  brumal: [
    ["Porta dos Sete Ferrolhos", "porta_selada", "uma laje sob raízes tem sete linguetas de ferro sem fechadura", "sete riscos no arco e uma chave sem dentes gravada numa pedra próxima", "dungeon sob Brumal", "laje de granito com 4 m apertada por raízes negras, sete ferrolhos de ferro rude e musgo intacto"],
    ["Torre dos Corvos", "torre_desabada", "a metade superior vê-se para lá da borda de bruma, sem caminho até ela", "corvos voam entre a Árvore Morta e a torre, sempre com palha no bico", "zona vertical de vigia", "torre de granito partida com 18 m para lá de bruma cinzenta, varas de ferro e ninhos negros no topo"],
    ["Nhal, Rei sem Bruma", "nome_sem_dono", "o nome está riscado em três pedras, mas nenhuma figura o representa", "as três inscrições repetem uma coroa antes de a bruma subir", "chefe futuro", "três estelas de granito cobertas de musgo, cada uma com o mesmo nome e uma coroa vazia talhada"],
  ],
  selva_funda: [
    ["Casulo da Matriarca", "porta_selada", "um casulo de pedra e seda não reage a fogo nem golpe", "Tecelões deixam oferendas frescas diante da costura central", "dungeon de ninhada", "casulo de granito verde com 7 m envolto em seda crua, costura vertical de quitina e flores magenta"],
    ["A Copa Sem Tronco", "torre_desabada", "uma aldeia suspensa aparece acima das copas sem qualquer árvore por baixo", "pontes cortadas apontam para ela e uma roldana continua a girar", "zona de copa superior", "grupo de cabanas de vime a 55 m, suspensas por fios de seda no vazio verde entre feixes de luz"],
    ["Iria das Oito Mãos", "nome_sem_dono", "o nome surge em nós de seda que nenhum Tecelão actual usa", "oito padrões idênticos aparecem nas guardas das pontes mais antigas", "chefe tecelão futuro", "oito faixas de seda branca trançadas numa árvore negra, cada uma com o mesmo nó espiral"],
  ],
  campas_cinzentas: [
    ["Cripta do Último Estandarte", "porta_selada", "uma porta de osso não abre e os mortos ajoelham-se virados para ela", "o estandarte cinzento preso na moldura nunca apodrece", "dungeon militar", "porta de osso com 5 m entre lápides afundadas, pano cinzento seco e fechos de ferro ferrugento"],
    ["Campanário Caído", "torre_desabada", "um sino toca debaixo do lodo onde só a ponta da torre é visível", "ondas circulares aparecem sem vento a cada toque", "torre subterrânea", "agulha de campanário em pedra cinzenta a sair 3 m do lodo, sino verde visível numa fenda"],
    ["General Sem Estandarte", "nome_sem_dono", "ordens gravadas acabam sempre antes do nome do comandante", "um elmo sem brasão ocupa sozinho uma mesa de pedra seca", "chefe morto-vivo futuro", "mesa de pedra sobre água cinzenta com um elmo ferrugento sem brasão e doze lanças apontadas para ele"],
  ],
  fojo: [
    ["Face de Bronze", "porta_selada", "uma cara metálica fecha o túnel e sopra poeira pelas narinas", "marcas kobold avisam para não responder quando ela pergunta", "labirinto falante", "rosto de bronze com 6 m encaixado no granito, olhos vazios, dentes quadrados e pó ocre nas narinas"],
    ["Poço da Décima Mina", "passagem_tapada", "carris terminam num desabamento numerado dez, embora só existam nove galerias", "vagonetas vazias chegam viradas para o desabamento após cada descanso", "mina adicional", "túnel de granito tapado por blocos, carris de ferro bruto entram nos escombros e o número X está pintado a ferrugem"],
    ["O Escultor do Touro", "nome_sem_dono", "a assinatura repete-se em estátuas anteriores à chegada dos kobolds", "ferramentas grandes demais permanecem alinhadas junto à Cabeça do Labirinto", "chefe construtor futuro", "cinzéis de ferro com 2 m encostados a uma cabeça de touro inacabada em granito ocre"],
  ],
  costa_quebrada: [
    ["Farol Cego", "porta_selada", "a porta verde do farol não tem abertura exterior", "uma lente intacta projecta à noite a imagem de uma chave partida", "dungeon do farol", "porta arqueada de bronze com azinhavre, 4 m, no basalto molhado, sem puxador e com lente verde por cima"],
    ["Quarto Mastro", "torre_desabada", "três mastros estão nos destroços; um quarto ergue-se numa agulha sem acesso", "cordas tensas ligam-no aos navios sempre que sopra vento de oeste", "ilha de naufrágio", "mastro salgado com 26 m sobre agulha de basalto, velas rasgadas e cordas esticadas sobre espuma branca"],
    ["Almirante sem Corpo", "nome_sem_dono", "o título aparece em sinos de três navios, mas nenhum registo tem nome", "cada sino traz a mesma mão de bronze de seis dedos", "chefe naval futuro", "três sinos de bronze verde alinhados na praia, cada um gravado com uma mão de seis dedos"],
  ],
  cimeira: [
    ["Observatório Interior", "porta_selada", "o telescópio aponta para uma cúpula fechada dentro da montanha", "mapas riscados mostram uma segunda abóbada por baixo da visível", "dungeon astronómica", "porta circular de aço frio com 5 m sob gelo azul, constelações perfuradas e neve sem pegadas"],
    ["Torre Além das Nuvens", "torre_desabada", "uma agulha aparece só quando as nuvens abrem, sem ponte nem trilho", "correntes cortadas na Agulha Azul têm a mesma espessura das que a sustentam", "torre de vigia futura", "agulha de pedra branca acima das nuvens, 40 m, varanda de aço azul e corrente cortada a pender no vazio"],
    ["A Vigia que Não Desceu", "nome_sem_dono", "um lugar à mesa recebe comida nova apesar de estar vazio", "pegadas começam na cadeira e terminam no bordo voltado para a Raiz", "chefe vigia futuro", "mesa de granito branco com uma tigela fumegante, cadeira vazia e pegadas na neve até ao precipício"],
  ],
  fornalha: [
    ["Oitava Chaminé", "passagem_tapada", "uma base octogonal tapada por escória completa a fila das Sete Chaminés", "brasas respiram sob as pedras ao ritmo da chaminé activa", "forja profunda", "base de chaminé em obsidiana com 9 m, coberta por escória negra rachada e luz laranja nas juntas"],
    ["Altar do Primeiro Carvão", "altar_apagado", "um cadinho frio recebe oferendas mas nunca acende", "as oferendas são ferramentas novas colocadas por mãos ausentes", "pacto ou ferreiro futuro", "cadinho de bronze com 2 m sobre altar de obsidiana, carvão branco intacto e tenazes alinhadas"],
  ],
  fulgor: [
    ["Galeria de Vidro Negro", "passagem_tapada", "um túnel vitrificado termina numa parede transparente com movimento atrás", "relâmpagos percorrem a parede mas desviam-se de uma junta em forma de porta", "dungeon da tempestade", "parede de vidro negro com 6 m, relâmpagos violetas ramificados e silhuetas distantes por trás"],
    ["Pastor do Nono Raio", "nome_sem_dono", "oito torres têm dono gravado; a nona traz apenas este título", "pegadas de casco rodeiam a torre e nunca saem do círculo", "chefe minotauro futuro", "nona torre de fulgurite torcida, círculo de pegadas de casco na poeira e título gravado em osso polido"],
  ],
  raizama: [
    ["Túnel da Seda Negra", "porta_selada", "uma membrana escura pulsa numa raiz onde os esporos não pousam", "Tecelões cortam todos os fios que se aproximam da membrana", "colónia profunda", "membrana oval negra com 5 m entre raízes, aro de quitina, fios de seda cortados e nenhum esporo ciano"],
    ["Altar da Carcaça", "altar_apagado", "um altar de osso tem espaço para um órgão que já não está", "raízes crescem para o vazio central e param a um palmo dele", "pacto da criatura morta", "altar de costelas brancas com cavidade de 2 m, raízes húmidas suspensas e cogumelos apagados"],
  ],
  cidade_afogada: [
    ["Sino Debaixo da Praça", "torre_desabada", "um campanário inteiro é visível sob o mosaico rachado da praça", "o sino toca e levanta bolhas sem mover a superfície", "bairro submerso", "campanário de mármore invertido sob água verde, sino de prata e mosaico circular rachado por cima"],
    ["Sineira sem Voz", "nome_sem_dono", "o nome está em partituras impermeáveis, mas falta sempre a linha da voz", "os sinos respondem quando as páginas são aproximadas da água", "chefe ou NPC futuro", "estante de prata à tona com partituras de vidro, pauta vazia e campanários reflectidos na água"],
  ],
  santuario_branco: [
    ["Porta da Cera Fria", "porta_selada", "uma porta inteiramente coberta de cera não derrete junto das velas", "mãos impressas na cera apontam todas para fora", "cripta penitente", "porta de mármore com 5 m sob camada grossa de cera branca, dezenas de mãos fundas e ouro baço na moldura"],
    ["Altar da Sombra Ausente", "altar_apagado", "mil velas iluminam o altar mas ele não projecta sombra", "um recipiente vazio tem a forma exacta de uma chama negra", "pacto de sombra futuro", "altar branco com 3 m cercado por velas, recipiente de ouro vazio e chão sem qualquer sombra"],
  ],
  raiz: [
    ["Passagem da Raiz Cortada", "passagem_tapada", "uma raiz-torre foi serrada e empilhada para fechar um arco antigo", "serradura negra continua fresca e a bruma evita os blocos", "ligação a bioma futuro", "arco de pedra negra com 8 m tapado por secções de raiz petrificada, cortes claros e prata baça nas fendas"],
    ["Primeiro Sem-Rosto", "nome_sem_dono", "o nome está escrito onde devia existir um rosto numa estátua lisa", "doze máscaras de outras raças olham para a estátua a partir do chão", "chefe primordial futuro", "estátua de pedra negra com 10 m e face lisa, cercada por doze máscaras de osso e rios de bruma ascendente"],
  ],
};

const mapReading = {
  decided_before_layout: true,
  projection: "inclinada_40_graus",
  reveal_rule: "apenas_terreno_percorrido",
  current_tier: "realcado",
  other_tiers: "esbatidos",
  never_reveals: ["caminhos_nao_percorridos", "inimigos", "itens", "paredes_falsas", "conteudo_atras_de_portas"],
  records: ["caminho_percorrido", "descansos_encontrados", "atalhos_abertos", "parceiro", "portas_vistas", "mancha_de_almas", "marcas_dos_jogadores"],
  scope_decision: "mapa_por_zona_ou_mundo_inteiro — donos, pergunta 38; o traçado local não depende da resposta",
  descricao_visual: "mapa inclinado a quarenta graus em pergaminho cinzento, percurso já pisado a tinta âmbar, andar actual nítido e alturas vizinhas esbatidas",
  fatia_1: false,
};

const zoneConnections = Object.fromEntries(Object.keys(profiles).map((id) => [id, []]));
const connections = edges.map(([from, to, name, description], index) => {
  if (zoneConnections[from].includes(to) || zoneConnections[to].includes(from)) {
    throw new Error(`ligação duplicada ${from}/${to}`);
  }
  zoneConnections[from].push(to);
  zoneConnections[to].push(from);
  return {
    id: `ligacao_${String(index + 1).padStart(2, "0")}`,
    nome: name,
    from,
    to,
    open_from_minute_one: true,
    soft_gate_only: true,
    loads: [from, to],
    fog_loading: "levanta quando as duas máquinas confirmam a zona vizinha pronta",
    descricao_visual: description,
    fatia_1: false,
  };
});

const zones = {};
for (const [id, profile] of Object.entries(profiles)) {
  const biome = realBiomes[id];
  if (!biome) throw new Error(`perfil sem bioma: ${id}`);
  const inSlice = Boolean(biome.fatia_1);
  const conceptName = id === "brumal" ? "brumal-vista.png" : `bioma-${id.replaceAll("_", "-")}.png`;
  const featureAsset = id === "brumal" ? asset("art/concept/brumal-caminho.png") : "planeado_depois_da_fatia_1";
  const dungeonAsset = id === "brumal" ? asset("art/concept/toca-entrada.png") : "planeado_depois_da_fatia_1";
  zones[id] = {
    nome: biome.nome,
    biome_id: id,
    order: biome.ordem,
    map_tiers: profile.tiers,
    traversal: {
      clean_minutes: profile.minutes,
      clean_route: profile.route,
      measurement: "corrida sem combate, sem atalhos e sem exploração lateral, do primeiro descanso à porta do guardião",
      target_after_shortcut_seconds: Math.max(38, Math.min(60, profile.minutes * 5)),
    },
    encounter_curve: {
      common: profile.common,
      elites: profile.elites,
      named: profile.named,
      subbosses: 1,
      guardians: 1,
      rhythm: ["comuns_faceis", "comuns_mais_elite", "nomeado", "descida", "grupo", "subchefe", "descanso", "guardiao"],
    },
    rest_points: Array.from({ length: profile.rests }, (_, index) => ({
      nome: index === profile.rests - 1 ? `Descanso antes do guardião de ${biome.nome}` : `Descanso ${index + 1} de ${biome.nome}`,
      role: index === profile.rests - 1 ? "antes_do_guardiao" : index === 0 ? "entrada_e_arco_inicial" : "meio_da_travessia",
      descricao_visual: `${biome.material}; círculo baixo de pedra com 3 m, cinza clara ao centro e três assentos virados para o marco seguinte`,
      fatia_1: inSlice,
    })),
    landmarks: profile.landmarks.map(([nome, descricao]) => ({ nome, descricao_visual: descricao, fatia_1: inSlice })),
    horizontal_loop: {
      nome: profile.horizontal[0], route: profile.horizontal[1], opens_from: "interior",
      return_time_seconds: Math.max(35, profile.minutes * 5 - 4),
      descricao_visual: profile.horizontal[2], image_source: featureAsset, fatia_1: inSlice,
    },
    vertical_loop: {
      nome: `Círculo vertical de ${biome.nome}`, height_gain_m: profile.vertical[0],
      outward_method: profile.vertical[1], return_method: profile.vertical[1], opens_from: "interior",
      safe_drop_limit_m: 4, lethal_drop_starts_m: 20,
      descricao_visual: profile.vertical[2], image_source: featureAsset, fatia_1: inSlice,
    },
    shortcut: {
      nome: profile.shortcut[0], connects: profile.shortcut[1], opens_from: "interior",
      interaction: "alavanca_ou_trinco_sem_chave", persistent: true,
      descricao_visual: profile.shortcut[2], image_source: featureAsset, fatia_1: inSlice,
    },
    dungeon: {
      nome: profile.dungeon[0], entrance: profile.dungeon[1], clue_count: 2,
      clues: profile.dungeon[2].split("; "), rooms_before_guardian: id === "brumal" ? 3 : 4,
      guardian_slot: id === "brumal" ? "vorgar" : `guardiao_${id}_wp7`,
      descricao_visual: profile.dungeon[3], image_source: dungeonAsset, fatia_1: inSlice,
    },
    subboss_slot: `subchefe_${id}_wp8`,
    environmental_threat: {
      nome: profile.threat[0], effect: profile.threat[1], telegraph: profile.threat[2], escape: profile.threat[3],
      runtime_type: profile.threat_runtime,
      rules: profile.threat_rules,
      unresolved_parameters: profile.threat_unresolved,
      requires_unresolved_movement: false,
      descricao_visual: `${biome.material}; ${profile.threat[2]}`,
      fatia_1: inSlice,
    },
    connections: zoneConnections[id].sort(),
    density_gate: "não entra na build sem rota medida, curva completa, subchefe, dungeon, dois círculos e atalho provado",
    descricao_visual: biome.descricao_visual,
    concept_art: asset(`art/concept/${conceptName}`),
    fatia_1: inSlice,
  };
}

const encounterSlots = {};
for (const [zoneId, zone] of Object.entries(zones)) {
  const guardianId = zone.dungeon.guardian_slot;
  encounterSlots[guardianId] = {
    kind: "guardian", zone_id: zoneId,
    content_state: zoneId === "brumal" ? "implemented" : "blocked_owner_q52",
    enemy_id: zoneId === "brumal" ? "vorgar" : null,
    owner_gate: zoneId === "brumal" ? null : 52,
  };
  const subbossId = zone.subboss_slot;
  encounterSlots[subbossId] = {
    kind: "subboss", zone_id: zoneId, content_state: "blocked_owner_q52",
    enemy_id: null, owner_gate: 52,
  };
}

const historyDoors = {};
for (const [biomeId, rows] of Object.entries(doorSeeds)) {
  rows.forEach(([nome, form, now, reason, future, visual], index) => {
    const id = `porta_${biomeId}_${String(index + 1).padStart(2, "0")}`;
    historyDoors[id] = {
      nome, biome_id: biomeId, form, what_exists_now: now, reason_is_legible: reason,
      future_slot: future, witness: "sinal_de_cenario_persistente", state: "promessa_nao_construida",
      descricao_visual: visual, fatia_1: false,
    };
  });
}

const world = {
  _meta: {
    source: "spec/69-catalogo-do-mundo.md",
    inherited: ["spec/39 §8", "spec/43 §6", "spec/49", "spec/53 §§2-3", "spec/57 §5"],
    rule: "a leitura vem antes do traçado; uma zona sem círculos horizontal e vertical não está acabada",
  },
  _traversal_rules: {
    free_swimming: false,
    free_climbing: false,
    free_traversal_jump: false,
    automatic_step_max_m: 0.45,
    authored_vertical_links: ["escada_interactiva", "elevador", "rampa", "queda_sem_retorno_legivel"],
    deep_water: "perigo ou rota lenta com fundo caminhável; nunca exige nadar",
    weapon_move_a_saltar: "investida terrestre de ataque; não é verbo de travessia",
    geometry_guard: "nenhuma rota obrigatória, segredo ou fuga depende de nadar, escalar ou saltar",
  },
  _subboss_rules: {
    on_flee: "o encontro recompõe-se no descanso e permanece na bolsa autorada",
    on_defeat: "fica morto nesse ciclo da zona",
    on_new_zone_cycle: "Brasa ou NG+ volta a colocá-lo; a recompensa fixa só pode sair uma vez por ciclo",
    presentation: "sem nevoeiro, barra global ou música própria; pode ser abandonado por qualquer saída legível",
  },
  _encounter_slot_rules: {
    stable_ids: true,
    implemented_requires_enemy_id: true,
    blocked_state: "bloqueia conteudo, nunca resolve por fallback",
  },
  map_reading: mapReading,
  world_scale: {
    target_endpoint_minutes: 30,
    proof_route: ["costa_quebrada", "cimeira", "fulgor"],
    proof_minutes: profiles.costa_quebrada.minutes + profiles.cimeira.minutes + profiles.fulgor.minutes,
    interpretation: "a rede compacta tem diâmetro de três travessias; 12 biomas não se somam em linha",
    fast_travel: "entre descansos visitados a partir de um descanso, disponível quando existirem 3+ zonas implementadas",
    descricao_visual: "rede de doze massas de terreno em três alturas, ligada por gargantas curtas e vários anéis, sem uma linha principal única",
    fatia_1: false,
  },
  streaming: {
    unit: "uma_zona",
    resident_set: "actual_e_vizinhas_imediatas",
    max_world_working_set_gb: 2.5,
    transition: "garganta_fisica_com_nevoeiro",
    coop_rule: "manda_a_maquina_mais_lenta",
    descricao_visual: "garganta estreita de material misto com cortina de bruma ao centro e silhuetas dos dois biomas nas extremidades",
    fatia_1: false,
  },
  connections,
  zones,
  encounter_slots: encounterSlots,
  history_doors: historyDoors,
};

const requiredVisual = (entity, label) => {
  if (typeof entity.descricao_visual !== "string" || entity.descricao_visual.length < 40) {
    throw new Error(`${label} sem descrição visual gerável`);
  }
  if (typeof entity.fatia_1 !== "boolean") throw new Error(`${label} sem Fatia 1? booleana`);
};

if (Object.keys(zones).length !== 12) throw new Error("o mundo precisa de 12 zonas");
if (Object.keys(encounterSlots).length !== 24) throw new Error("o mundo precisa de 24 slots de guardiao/subchefe");
if (Object.keys(historyDoors).length !== 30) throw new Error("o mundo precisa de 30 portas de história");
requiredVisual(mapReading, "leitura do mapa");
requiredVisual(world.world_scale, "escala do mundo");
requiredVisual(world.streaming, "streaming");
for (const [id, zone] of Object.entries(zones)) {
  if (zone.traversal.clean_minutes < 8 || zone.traversal.clean_minutes > 12) throw new Error(`${id}: travessia fora de 8-12`);
  if (zone.connections.length < 2) throw new Error(`${id}: rede linear`);
  if (!zone.environmental_threat.rules || !Array.isArray(zone.environmental_threat.unresolved_parameters)) {
    throw new Error(`${id}: ameaça sem contrato estruturado`);
  }
  for (const [key, entity] of Object.entries({
    ...Object.fromEntries(zone.landmarks.map((value, index) => [`landmark_${index}`, value])),
    ...Object.fromEntries(zone.rest_points.map((value, index) => [`rest_${index}`, value])),
    horizontal_loop: zone.horizontal_loop, vertical_loop: zone.vertical_loop,
    shortcut: zone.shortcut, dungeon: zone.dungeon, environmental_threat: zone.environmental_threat,
  })) requiredVisual(entity, `${id}/${key}`);
  for (const key of ["horizontal_loop", "vertical_loop", "shortcut"]) {
    if (zone[key].opens_from !== "interior") throw new Error(`${id}/${key} não abre por dentro`);
  }
  requiredVisual(zone, id);
  const conceptPath = path.join(root, zone.concept_art.replace("res://../", ""));
  if (!fs.existsSync(conceptPath)) throw new Error(`${id}: conceito em falta ${conceptPath}`);
  if (zone.fatia_1) {
    for (const key of ["horizontal_loop", "vertical_loop", "shortcut", "dungeon"]) {
      const source = zone[key].image_source.replace("res://../", "");
      if (!fs.existsSync(path.join(root, source))) throw new Error(`${id}/${key}: imagem da Fatia 1 em falta`);
    }
  }
}
for (const [id, door] of Object.entries(historyDoors)) requiredVisual(door, id);
for (const connection of connections) requiredVisual(connection, connection.id);

const lines = [
  "# 69 — Catálogo do mundo: doze círculos que se aprendem",
  "",
  "> **Tarefa 3.4 · Codex** (01-08-2026). Fecha o WP8 em dados executáveis. Herda os 12 biomas do [`49`](49-biomas.md), o círculo do [`39`](39-estudo-profundo.md) §8, o carregamento do [`43`](43-estudo-espolio-inventario-mundo.md) §6, o ritmo e as portas do [`53`](53-chefes-ritmo-e-o-mago-forte.md) §§2–3 e a leitura do [`57`](57-mapa-e-minimapa.md) §5. Tudo `[CODEX]` salvo decisão herdada.",
  "",
  "**Regra-mãe:** uma zona só está acabada quando o caminho longo fecha um círculo horizontal, outro vertical e um atalho ganho pelo lado de dentro. O mapa regista essa aprendizagem; nunca a antecipa.",
  "",
  "---",
  "",
  "## 1. ⭐ A leitura foi decidida antes do traçado",
  "",
  "| Campo | Contrato | Descrição visual | Fatia 1? |",
  "|---|---|---|---|",
  `| Projecção | vista inclinada a ~40° | ${mapReading.descricao_visual} | ${boolMark(mapReading.fatia_1)} |`,
  `| Revelação | só terreno percorrido; o desconhecido fica em branco | ${mapReading.descricao_visual} | ${boolMark(mapReading.fatia_1)} |`,
  `| Altura | andar actual realçado; restantes esbatidos | ${mapReading.descricao_visual} | ${boolMark(mapReading.fatia_1)} |`,
  `| Escopo | **continua dos donos:** mapa por zona ou do mundo inteiro; o traçado local funciona nos dois | ${mapReading.descricao_visual} | ${boolMark(mapReading.fatia_1)} |`,
  "",
  "O catálogo não toca na pergunta de escopo. A geometria usa patamares com separação de silhueta e evita empilhar três rotas idênticas no mesmo eixo; assim ambas as opções de UI continuam possíveis.",
  "",
  "---",
  "",
  "## 2. Escala, rede e carregamento",
  "",
  `- Cada bioma mede **8–12 min** do primeiro descanso à porta do guardião, sem combate, atalhos ou exploração lateral.`,
  `- A rede não soma doze zonas em linha: o diâmetro útil é de **três travessias**. Costa Quebrada (${profiles.costa_quebrada.minutes}) + Cimeira (${profiles.cimeira.minutes}) + Fulgor (${profiles.fulgor.minutes}) = **${world.world_scale.proof_minutes} min** de uma ponta à borda da Raiz.`,
  `- Há **${connections.length} ligações** e todos os biomas têm pelo menos duas saídas. Nenhuma porta verifica nível; a dificuldade é só *soft gating*.`,
  "- A unidade de streaming é uma zona; ficam residentes a actual e as vizinhas imediatas. Cada garganta lista exactamente os dois lados. Em co-op manda a máquina mais lenta.",
  "- Viagem rápida abre com 3+ zonas implementadas, apenas entre descansos já visitados e a partir de outro descanso.",
  "",
  "### Ligações físicas",
  "",
  "| # | De | Para | Garganta / descrição visual | Fatia 1? |",
  "|---:|---|---|---|---|",
  ...connections.map((edge, index) => `| ${index + 1} | ${zones[edge.from].nome} | ${zones[edge.to].nome} | **${edge.nome}:** ${edge.descricao_visual} | ${boolMark(edge.fatia_1)} |`),
  "",
  "---",
  "",
  "## 3. Quadro das doze zonas",
  "",
  "| # | Zona | Min | Comuns | Elites | Nomeados | Descansos | Altura | Saídas | Descrição visual | Fatia 1? |",
  "|---:|---|---:|---:|---:|---:|---:|---:|---:|---|---|",
  ...Object.values(zones).sort((a, b) => a.order - b.order).map((zone) =>
    `| ${zone.order} | ${zone.nome} | ${zone.traversal.clean_minutes} | ${zone.encounter_curve.common} | ${zone.encounter_curve.elites} | ${zone.encounter_curve.named} | ${zone.rest_points.length} | ${zone.vertical_loop.height_gain_m} m | ${zone.connections.length} | ${zone.descricao_visual} | ${boolMark(zone.fatia_1)} |`),
  "",
];

for (const zone of Object.values(zones).sort((a, b) => a.order - b.order)) {
  const traversalCaveat = zone.biome_id === "brumal"
    ? " ⚠️ É alvo de catálogo; a medição real só fecha pelas cinco corridas da §9."
    : "";
  lines.push(
    `### 3.${zone.order} ${zone.nome}`,
    "",
    `**Orçamento de travessia:** ${zone.traversal.clean_minutes} min — ${zone.traversal.clean_route}. **Curva:** ${zone.encounter_curve.common} comuns · ${zone.encounter_curve.elites} elites · ${zone.encounter_curve.named} nomeados · 1 subchefe · descanso · 1 guardião.${traversalCaveat}`,
    "",
    "| Peça | Função | Descrição visual | Fatia 1? |",
    "|---|---|---|---|",
    `| Círculo horizontal — **${zone.horizontal_loop.nome}** | ${zone.horizontal_loop.route}; abre por dentro; volta em ${zone.horizontal_loop.return_time_seconds} s | ${zone.horizontal_loop.descricao_visual} | ${boolMark(zone.horizontal_loop.fatia_1)} |`,
    `| Círculo vertical — **${zone.vertical_loop.nome}** | ${zone.vertical_loop.outward_method}; ${zone.vertical_loop.height_gain_m} m; abre por dentro | ${zone.vertical_loop.descricao_visual} | ${boolMark(zone.vertical_loop.fatia_1)} |`,
    `| Atalho — **${zone.shortcut.nome}** | ${zone.shortcut.connects}; abre por dentro e persiste | ${zone.shortcut.descricao_visual} | ${boolMark(zone.shortcut.fatia_1)} |`,
    `| Dungeon — **${zone.dungeon.nome}** | ${zone.dungeon.entrance}; ${zone.dungeon.clue_count} pistas; ${zone.dungeon.rooms_before_guardian} salas + guardião | ${zone.dungeon.descricao_visual} | ${boolMark(zone.dungeon.fatia_1)} |`,
    `| Ameaça — **${zone.environmental_threat.nome}** | ${zone.environmental_threat.effect}; saída: ${zone.environmental_threat.escape} | ${zone.environmental_threat.descricao_visual} | ${boolMark(zone.environmental_threat.fatia_1)} |`,
    "",
    "**Marcos e descansos**",
    "",
    "| Tipo | Nome | Descrição visual | Fatia 1? |",
    "|---|---|---|---|",
    ...zone.landmarks.map((landmark) => `| Marco | ${landmark.nome} | ${landmark.descricao_visual} | ${boolMark(landmark.fatia_1)} |`),
    ...zone.rest_points.map((rest) => `| Descanso | ${rest.nome} | ${rest.descricao_visual} | ${boolMark(rest.fatia_1)} |`),
    "",
  );
}

lines.push(
  "---",
  "",
  "## 4. ⭐ As 30 portas de história",
  "",
  "São **2–3 por bioma**, ficam deliberadamente sem construir e nenhuma parece bug: cada uma tem um testemunho de cenário que explica por que não abre ou por que o nome está vazio. São reservas, não promessas de data. A Fatia 1 continua sem história, como manda o [`10`](10-fatia-1.md).",
  "",
  "| # | Bioma | Porta / forma | O que existe hoje e por que se lê | Reserva futura | Descrição visual | Fatia 1? |",
  "|---:|---|---|---|---|---|---|",
  ...Object.entries(historyDoors).map(([id, door], index) =>
    `| ${index + 1} | ${zones[door.biome_id].nome} | **${door.nome}** · ${door.form} | ${door.what_exists_now}; **razão:** ${door.reason_is_legible} | ${door.future_slot} | ${door.descricao_visual} | ${boolMark(door.fatia_1)} |`),
  "",
  "---",
  "",
  "## 5. Densidade antes de expansão",
  "",
  "Uma zona só entra numa build pública quando tem: travessia cronometrada em 8–12 min; 12–20 comuns, 3–5 elites, 2–3 nomeados, subchefe e guardião colocados; 2–3 descansos; dungeon com duas pistas; círculos horizontal e vertical; atalho aberto por dentro; fuga contínua; garganta medida; e orçamento quente ≤ 2,5 GB. Falhar um item bloqueia a zona seguinte — conteúdo denso antes de hectares.",
  "",
  "Quedas de **até 4 m** podem servir de atalho; nenhuma rota pede salto de 20 m. Bordos letais seguem os quatro sinais do [`61`](61-arenas-de-chefe.md) §5. As rotas principais usam chão, escada, rampa ou elevador: não dependem de escalar, saltar ou nadar, cujos detalhes não são decididos aqui.",
  "",
  "---",
  "",
  "## 6. As quatro perguntas do fio solto",
  "",
  "### 1. Como é que o jogador usa isto?",
  "",
  "Entra por qualquer ligação sem teste de nível, lê um marco vertical, enfrenta a curva que sobe e desce, abre por dentro os dois círculos e o atalho, encontra a dungeon pelas duas pistas e regressa ao descanso em menos de 60 s. O mapa só desenha esse caminho depois de o jogador o pisar.",
  "",
  "### 2. Como é que se prova que funciona?",
  "",
  "Por zona: 5 corridas limpas em 1.ª e 3.ª pessoa dentro de 8–12 min; cada marco reconhecido a 40 m por 8/10 jogadores; 10 aberturas de cada atalho apenas pelo interior; 10 regressos < 60 s; duas pistas de dungeon encontradas sem marcador por 7/10; fuga do subchefe em 10/10 tentativas; mapa sem revelar uma célula não pisada. A rede inteira tem 12 nós ligados, grau mínimo 2 e prova de ponta-a-ponta de ~30 min.",
  "",
  "### 3. De onde vêm a arte e o som?",
  "",
  "Os 12 conceitos de bioma já estão arquivados no [`art/MANIFESTO.md`](../art/MANIFESTO.md). Brumal reutiliza `brumal-vista`, `brumal-caminho` e `toca-entrada`; logo não nasce imagem nova da Fatia 1 neste bloco. Cada entidade visual conserva descrição específica e `Fatia 1?` para a geração posterior. Materiais herdam do [`49`](49-biomas.md); ambientes, sinais e ducking herdam do [`65`](65-musica-e-ambiente.md) e do [`62`](62-acessibilidade-auditiva.md).",
  "",
  "### 4. Quanto custa na máquina do Rico?",
  "",
  "Uma zona e vizinhas imediatas, tecto total de 2,5 GB; gargantas seguram o jogador até ambas as máquinas confirmarem; elevadores são animações pré-feitas, não corpos rígidos; marcos usam kits modulares por bioma; portas futuras são malha estática e zero lógica. Falha de orçamento corta decoração e partículas, nunca rota, marco ou telegrafia.",
  "",
  "---",
  "",
  "## 7. O que continua aberto sem ser decidido aqui",
  "",
  "- **Mapa por zona ou do mundo inteiro** e se nomes de bioma não visitados aparecem — pergunta 38, donos.",
  "- ~~**Nadar, escalar e saltar**~~: ✅ não existem como verbos livres; água é perigo/fundo caminhável e toda a verticalidade usa ligações autoradas, segundo o [`73`](73-fecho-dos-buracos-de-integracao.md) §2.",
  "- **Conteúdo das reservas futuras:** as 30 portas declaram forma e razão, não data nem obrigação de as preencher.",
  "- Nomes definitivos de zonas, dungeons e sementes de história continuam sujeitos à gravação narrativa; IDs técnicos ficam estáveis.",
  "",
  "## Ligações",
  "",
  "[`17-mundo.md`](17-mundo.md) · [`36-fisica.md`](36-fisica.md) · [`39-estudo-profundo.md`](39-estudo-profundo.md) · [`43-estudo-espolio-inventario-mundo.md`](43-estudo-espolio-inventario-mundo.md) · [`49-biomas.md`](49-biomas.md) · [`53-chefes-ritmo-e-o-mago-forte.md`](53-chefes-ritmo-e-o-mago-forte.md) · [`57-mapa-e-minimapa.md`](57-mapa-e-minimapa.md) · [`61-arenas-de-chefe.md`](61-arenas-de-chefe.md) · [`game/data/world.json`](../game/data/world.json)",
  "",
);

fs.writeFileSync(path.join(root, "game/data/world.json"), `${JSON.stringify(world, null, 2)}\n`, "utf8");
fs.writeFileSync(path.join(root, "spec/69-catalogo-do-mundo.md"), `${lines.join("\n").trimEnd()}\n`, "utf8");
console.log(`${Object.keys(zones).length} zonas · ${connections.length} ligações · ${Object.keys(historyDoors).length} portas de história`);
