#!/usr/bin/env node
/**
 * Gera o catálogo fechado do WP5 a partir das promessas já feitas pelo WP6.
 *
 * As listas editoriais (nomes, verbos e achados) vivem aqui; a saída é JSON
 * estável para o Godot validar sem executar JavaScript. Não há números de
 * combate inventados no runtime.
 */
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const read = (relative) => JSON.parse(fs.readFileSync(path.join(root, relative), "utf8"));
const enemies = read("game/data/enemies.json");
const starterArmor = read("game/data/armor.json").pieces;

const biomeRows = [
  ["brumal", "Brumal", "ferro rude e couro de javali"],
  ["selva_funda", "Selva Funda", "bambu negro, seda crua e seiva-peçonha"],
  ["campas_cinzentas", "Campas Cinzentas", "osso seco, linho tumular e ferro ferrugento"],
  ["fojo", "Fojo", "ferro em bruto marcado por picareta"],
  ["costa_quebrada", "Costa Quebrada", "bronze-do-mar, corda salgada e madeira de naufrágio"],
  ["cimeira", "Cimeira", "aço frio, couro branco e flor-de-gelo"],
  ["fornalha", "Fornalha", "obsidiana, bronze fundido e couro chamuscado"],
  ["fulgor", "Fulgor", "fulgurite, prata baça e couro isolante"],
  ["raizama", "Raizama", "raiz petrificada, quitina e esporo-lúmen"],
  ["cidade_afogada", "Cidade Afogada", "prata afogada, vidro verde e mármore molhado"],
  ["santuario_branco", "Santuário Branco", "mármore branco, cera benta e ouro baço"],
  ["raiz", "A Raiz", "madeira negra, lágrima de bruma e osso antigo"],
];
const biomeById = Object.fromEntries(biomeRows.map(([id, nome, material]) => [id, { nome, material }]));
const slug = (value) => value.normalize("NFD").replace(/[\u0300-\u036f]/g, "").toLowerCase()
  .replace(/[^a-z0-9]+/g, "_").replace(/^_|_$/g, "");
const title = (id) => id.split("_").map((word) => word.charAt(0).toUpperCase() + word.slice(1)).join(" ");

const lootByKind = { arma: new Set(), armadura: new Set(), anel: new Set() };
const lootOrigin = { arma: {}, armadura: {}, anel: {} };
for (const [enemyId, enemy] of Object.entries(enemies)) {
  if (enemyId.startsWith("_")) continue;
  for (const card of enemy.loot_cards ?? []) {
    const split = card.split(":", 2);
    if (lootByKind[split[0]]) {
      lootByKind[split[0]].add(split[1]);
      lootOrigin[split[0]][split[1]] ??= enemy.biome_ids?.[0] ?? "brumal";
    }
  }
}

const familyProfiles = {
  espada_recta: {
    nome: "Espada recta", hands: 1, range: 2.0, scale: "forca", weight: "medio",
    silhouette: "lâmina recta de dois gumes com 90 cm, guarda cruciforme curta e pomo circular",
    forms: ["Espada de vigília", "Lâmina de romeiro", "Espada de muralha", "Ferro de juramento", "Lâmina de ponte", "Espada do sineiro", "Guarda de peregrino", "Lâmina de fronteira", "Espada de procissão", "Ferro de sentinela", "Espada de cripta", "Lâmina de maré", "Espada de cinza", "Ferro do último portão", "Espada de raiz"],
    known: ["longsword", "espada_curta_campas", "espada_prata_santuario"],
    questions: ["manter a cadência sem uma especialidade", "trocar alcance por recuperação", "ler quando abandonar a cadeia"],
    arts: ["estocada perfurante", "golpe circular"], frames: [16, 6, 18], mv: 1.0,
  },
  adaga: {
    nome: "Adaga", hands: 1, range: 1.4, scale: "destreza", weight: "forte",
    silhouette: "lâmina estreita de um gume com 38 cm, ponta reforçada, guarda mínima e punho enfaixado",
    forms: ["Punhal de nevoeiro", "Dente de vigia", "Faca de ritual", "Agulha de sal", "Punhal de copa", "Dente de ossário", "Faca de fundidor", "Agulha de trovão", "Punhal de esporo", "Dente afogado", "Faca penitente", "Agulha da raiz", "Punhal de caçador", "Dente de vidro", "Faca sem reflexo"],
    known: ["dagger", "faca_goblin_bruma", "dente_mimico_costa", "dente_mimico_fojo"],
    questions: ["conquistar as costas", "arriscar ficar dentro da guarda", "sair antes da resposta pesada"],
    arts: ["apunhalar", "dança de lâminas"], frames: [12, 4, 14], mv: 0.55,
  },
  pesada_corte: {
    nome: "Pesada de corte", hands: 2, range: 2.3, scale: "forca", weight: "forte",
    silhouette: "cabeça assimétrica de corte com 42 cm presa a haste de 125 cm, cunha grossa e contrapeso de ferro",
    forms: ["Machado de quebra", "Malho de pedreira", "Cutelo de forja", "Machado de carrasco", "Martelo de sino", "Picareta de veio", "Clava de tronco", "Tenaz de fundidor", "Machado de maré", "Malho de ossário", "Cutelo de gelo", "Martelo de fulgor", "Picareta de raiz", "Clava de mármore", "Machado do fundo"],
    known: ["greataxe", "clava_cogumelo_goblin", "coluna_marmore_zumbi", "enxada_lodo", "maca_fulgurite_minotauro", "maca_orc_pesada", "machado_labirinto", "martelo_aco_frio", "martelo_lamina_obsidiana", "picareta_kobold_fojo", "tenaz_orc_fornalha"],
    questions: ["comprometer o arco inteiro", "trocar durante o golpe inimigo", "aceitar a recuperação se falhar"],
    arts: ["salto esmagador", "rodopio"], frames: [24, 8, 26], mv: 1.5,
  },
  katana: {
    nome: "Katana", hands: 1, range: 2.1, scale: "destreza", weight: "forte",
    silhouette: "lâmina curva estreita de um gume com 90 cm, aço polido, guarda oval baixa e punho enfaixado",
    forms: ["Lua de nevoeiro", "Corte de bambu", "Sabre tumular", "Lâmina de escória", "Curva de maré", "Lua de gelo", "Corte de obsidiana", "Sabre de raio", "Lâmina de micélio", "Curva afogada", "Lua penitente", "Corte da raiz", "Sabre de vigília", "Lâmina sem bainha", "Curva do último duelo"],
    known: ["espada_curva_raiz", "sabre_osso_goblin"],
    questions: ["bater durante o ataque inimigo", "guardar o iai até ao compromisso", "perder valor se o contra-ataque não existir"],
    arts: ["iai", "corte duplo"], frames: [14, 5, 16], mv: 0.9,
  },
  haste: {
    nome: "Haste", hands: 1, range: 2.8, scale: "destreza", weight: "medio",
    silhouette: "haste rígida de 220 cm com ponta de 34 cm, talão metálico e pega central envolta em couro",
    forms: ["Lança de vigia", "Pique de copa", "Alabarda tumular", "Arpão de falésia", "Lança de gelo", "Pique de escória", "Alabarda de fulgor", "Lança de esporo", "Tridente afogado", "Pique penitente", "Alabarda da raiz", "Lança serrada", "Arpão de naufrágio", "Pique sem rosto", "Tridente de prata"],
    known: ["alabarda_raiz_petrificada", "arpao_submerso_costa", "gancho_orc_mar", "lanca_aco_frio", "lanca_bambu_kobold", "lanca_espinho_ventaneira", "lanca_orc_bruma", "tridente_prata_afogada"],
    questions: ["manter o alvo fora do alcance mínimo", "estocar atrás da guarda", "recuar antes de ficar colado"],
    arts: ["varrimento baixo", "carga de lança"], frames: [18, 6, 20], mv: 0.95,
  },
  cajado: {
    nome: "Cajado", hands: 2, range: 1.8, scale: "inteligencia", weight: "fraco",
    silhouette: "conduto de 180 cm, veio de madeira escura com aro mineral na ponta e empunhadura de couro gasto",
    forms: ["Cajado de bruma", "Fuso de seda", "Vara de ossário", "Diapasão de mina", "Bordão de maré", "Cajado de gelo", "Vara de cinza", "Diapasão de fulgor", "Fuso de esporo", "Bordão afogado", "Turíbulo branco", "Cajado da raiz", "Vara de peregrino", "Fuso de vidro", "Bordão de luto"],
    known: ["staff", "diapasao_penitente", "fuso_esporos_teciao", "fuso_teciao_selva", "turibulo_penitente"],
    questions: ["conjurar ou defender o espaço curto", "gastar mana na arte ou guardar para magia", "firmar a próxima conjuração"],
    arts: ["rajada de bruma", "conjuração firmada"], frames: [18, 5, 20], mv: 0.7,
  },
  arco: {
    nome: "Arco", hands: 2, range: 18, scale: "destreza", weight: "medio",
    silhouette: "arco recurvo de 145 cm, lâminas finas de madeira laminada, corda entrançada e punho de couro",
    forms: ["Arco de batedor", "Funda de copa", "Arco tumular", "Arco de mineiro", "Funda de maré", "Arco de gelo", "Arco de carvão", "Funda de fulgor", "Arco de esporo", "Arco afogado", "Funda penitente", "Arco da raiz", "Arco de vigília", "Funda de vidro", "Arco do horizonte"],
    known: ["arco_encharcado_campas", "funda_couro_fulgor", "funda_seda_selva"],
    questions: ["gastar munição para abrir combate", "marcar para o parceiro", "abandonar a mira quando o alvo fecha"],
    arts: ["disparo firmado", "chuva de flechas"], frames: [22, 4, 24], mv: 0.8,
  },
  besta: {
    nome: "Besta", hands: 1, range: 16, scale: "nenhuma", weight: "nenhuma",
    silhouette: "coronha curta de 78 cm, arco de aço transversal com 62 cm, estribo frontal e manivela lateral",
    forms: ["Besta de muralha", "Besta de copa", "Besta de cripta", "Besta de veio", "Besta de convés", "Besta de gelo", "Besta de fornalha", "Besta de fulgor", "Besta de esporo", "Besta afogada", "Besta penitente", "Besta da raiz", "Besta de peregrino", "Besta de cerco", "Besta sem brasão"],
    known: [],
    questions: ["disparar agora ou recarregar exposto", "combinar o tiro com a mão livre", "aceitar zero escala por acesso universal"],
    arts: ["tiro rápido", "mira ampliada"], frames: [20, 4, 26], mv: 1.0,
  },
};

const visualOverrides = {
  longsword: "espada de lâmina recta de dois gumes em ferro polido, 90 cm, guarda cruciforme curta, punho de couro castanho",
  dagger: "adaga de lâmina triangular em aço polido, 38 cm, guarda mínima e punho enfaixado em couro escuro",
  greataxe: "machadão de lâmina crescente em ferro martelado, cabeça de 42 cm e haste de freixo com 125 cm",
  staff: "cajado de freixo escurecido com 180 cm, aro de ferro fosco na ponta e empunhadura envolta em couro",
};
const specificWeaponSilhouette = (id, fallback) => {
  const rules = [
    [/clava_cogumelo/, "clava de madeira de cogumelo com 108 cm, cabeça bulbosa fibrosa de 34 cm e pega envolta em vime"],
    [/coluna_marmore/, "segmento de coluna de mármore molhado com 130 cm, base canelada usada como cabeça e pega de corda salgada"],
    [/enxada_lodo/, "enxada de ferro ferrugento com lâmina rectangular de 38 cm, haste de freixo com 120 cm e lodo seco nas juntas"],
    [/maca_fulgurite/, "maça de seis aletas de fulgurite e prata baça, cabeça de 32 cm e cabo de couro isolante com 95 cm"],
    [/maca_orc/, "maça orc de ferro rude com oito flanges rombas, cabeça de 36 cm e cabo grosso de carvalho com 105 cm"],
    [/machado_labirinto/, "machado de pedreira com lâmina trapezoidal de ferro bruto, contrapeso quadrado e haste de 118 cm"],
    [/martelo_aco_frio/, "martelo de guerra em aço frio, face quadrada de 24 cm, espigão traseiro curto e cabo branco de 110 cm"],
    [/martelo_lamina_obsidiana/, "martelo de forja com face de bronze fundido e lâmina traseira de obsidiana, cabo chamuscado de 112 cm"],
    [/picareta_kobold/, "picareta kobold de ferro bruto com ponta dupla de 54 cm, haste curta de 88 cm e pega marcada por corda"],
    [/tenaz_orc/, "tenaz de fundidor com braços de bronze de 125 cm, mandíbulas dentadas de 28 cm e anel de travamento"],
    [/alabarda/, "alabarda de raiz petrificada com haste de 225 cm, lâmina lateral de 42 cm, gancho traseiro e talão de osso"],
    [/arpao/, "arpão de bronze-do-mar com ponta farpada de 38 cm, haste salgada de 205 cm e argola de corda no talão"],
    [/gancho_orc/, "gancho naval orc de bronze curvo com abertura de 30 cm, haste de naufrágio de 190 cm e pega de corda"],
    [/lanca_aco_frio/, "lança de aço frio com ponta de folha de 36 cm, haste branca de 230 cm e talão de ferro escuro"],
    [/lanca_bambu/, "lança kobold de bambu negro com 215 cm, ponta triangular de ferro fino e três amarras de seda crua"],
    [/lanca_espinho/, "lança de espinho com ponta serrilhada de 40 cm, haste leve de 225 cm e penas brancas junto à pega"],
    [/lanca_orc/, "lança orc serrada de ferro rude com ponta de 34 cm, haste de carvalho negro de 220 cm e couro gasto"],
    [/tridente/, "tridente de prata afogada com três pontas desiguais de 46 cm, haste de 210 cm e vidro verde no encaixe"],
    [/diapasao/, "diapasão ritual de prata baça com 175 cm, duas hastes paralelas de 38 cm e empunhadura envolta em cera"],
    [/fuso_esporos/, "fuso de conjuração em madeira de cogumelo com 165 cm, espiral de esporo-lúmen e fios de seda tensos"],
    [/fuso_teciao/, "fuso tecelão de bambu negro com 170 cm, aro de quitina verde e quatro fios de seda crua"],
    [/turibulo/, "turíbulo de ouro baço e cera benta suspenso por três correntes de 70 cm, bojo perfurado e pega de mármore"],
    [/funda_couro/, "funda de couro isolante com bolsa oval de 18 cm, duas correias de 75 cm e pesos pequenos de fulgurite"],
    [/funda_seda/, "funda de seda crua trançada com bolsa de vime de 16 cm, correias de 80 cm e nós verdes visíveis"],
    [/arco_encharcado/, "arco recurvo de madeira encharcada com 145 cm, pontas de osso seco, corda de linho tumular e punho salgado"],
    [/dente_mimico/, "punhal feito de dente curvo de mímico com 35 cm, espinha serrada, guarda de ferro e punho de corda"],
    [/faca_goblin/, "faca goblin de ferro rude com lâmina assimétrica de 34 cm, ponta baixa e punho envolto em pano verde"],
    [/espada_curta/, "espada curta de ferro ferrugento com lâmina recta de 62 cm, guarda estreita e pomo de osso seco"],
    [/espada_prata/, "espada recta de prata baça com lâmina de dois gumes de 88 cm, guarda branca e pomo de ouro gasto"],
    [/espada_curva/, "lâmina curva de raiz petrificada com um gume de 84 cm, guarda baixa de quitina e punho de madeira negra"],
    [/sabre_osso/, "sabre de osso polido com lâmina curva de 78 cm, espinha escura, guarda de ferro e punho de linho"],
  ];
  return rules.find(([pattern]) => pattern.test(id))?.[1] ?? fallback;
};

const weaponCatalogue = {};
for (const [familyId, profile] of Object.entries(familyProfiles)) {
  const target = familyId === "espada_recta" ? 14 : 15;
  const ids = [...profile.known];
  let cursor = 0;
  while (ids.length < target) {
    const [biomeId, biomeName] = biomeRows[cursor % biomeRows.length];
    const form = profile.forms[cursor % profile.forms.length];
    const id = `${familyId}_${biomeId}_${slug(form)}`;
    if (!ids.includes(id)) ids.push(id);
    cursor += 1;
  }
  ids.forEach((id, index) => {
    const fallbackBiome = biomeRows[index % biomeRows.length];
    const biomeId = lootOrigin.arma[id] ?? fallbackBiome[0];
    const biome = biomeById[biomeId];
    const biomeName = biome.nome;
    const material = biome.material;
    const displayName = id === "longsword" ? "Espada longa" : id === "dagger" ? "Adaga" :
      id === "greataxe" ? "Machadão" : id === "staff" ? "Cajado" :
      lootByKind.arma.has(id) ? title(id) : profile.forms[index % profile.forms.length];
    const isFirstSlice = ["longsword", "dagger", "greataxe", "staff"].includes(id);
    weaponCatalogue[id] = {
      nome: displayName,
      familia: familyId,
      maos: profile.hands,
      alcance_m: profile.range,
      requisitos: profile.scale === "nenhuma" ? {} : { [profile.scale]: familyId === "pesada_corte" ? 14 : 10 },
      escala: profile.scale,
      peso_escala: profile.weight,
      origem: biomeId,
      material,
      pergunta: profile.questions[index % profile.questions.length],
      descricao_visual: visualOverrides[id] ?? `${specificWeaponSilhouette(id, profile.silhouette)}, construída em ${material}; marcas e ligaduras pertencem a ${biomeName}`,
      onde_se_encontra: lootByKind.arma.has(id) ? `baralho de espólio do inimigo que a usa em ${biomeName}` : `desvio explorável de ${biomeName}, atrás de uma leitura da família ${profile.nome.toLowerCase()}`,
      asset_path: isFirstSlice ? ({ longsword: "art/ui/icons/items/espada-longa.png", dagger: "art/ui/icons/items/adaga.png", greataxe: "art/ui/icons/items/machadao.png", staff: "art/ui/icons/items/cajado.png" })[id] : "",
      fatia_1: isFirstSlice,
    };
  });
}
weaponCatalogue.shield = {
  nome: "Escudo de madeira", familia_escudo: "escudo_medio", maos: 1, alcance_m: 1.2,
  requisitos: { forca: 8 }, escala: "forca", peso_escala: "fraco", origem: "brumal",
  material: "tábuas de carvalho negro e aro de ferro rude",
  pergunta: "bloquear com estabilidade média ou expor-se para aparar",
  descricao_visual: "escudo redondo de tábuas de carvalho negro com 72 cm, aro de ferro rude rebitado, umbo baixo e correias de couro",
  onde_se_encontra: "kit inicial do Guerreiro, Tanque e Paladino; réplica no arsenal de Brumal",
  asset_path: "art/ui/icons/items/escudo-madeira.png", fatia_1: true,
};

for (const lootId of lootByKind.arma) {
  if (!weaponCatalogue[lootId]) throw new Error(`arma de espólio sem família editorial: ${lootId}`);
}
if (Object.keys(weaponCatalogue).length !== 120) throw new Error("o catálogo de armas não fechou 120");

const familyMovesets = {};
for (const [familyId, profile] of Object.entries(familyProfiles)) {
  const [startup, active, recovery] = profile.frames;
  const q = profile.questions;
  familyMovesets[familyId] = {
    leve: { startup, active, recovery, mv: profile.mv, pergunta: q[0] },
    pesado: { startup: startup + 12, active: active + 2, recovery: recovery + 8, mv: Number((profile.mv * 1.6).toFixed(2)), pergunta: q[2] },
    cadeia: { max: familyId === "adaga" ? 4 : familyId === "pesada_corte" ? 2 : 3, pergunta: "parar a cadeia antes de perder a leitura" },
    leve_para_pesado: { startup_cut_percent: 25, pergunta: "confirmar o ritmo leve antes de comprometer o pesado" },
    em_corrida: { advance_m: familyId === "katana" ? 3 : 2.5, posture_multiplier: 1.5, pergunta: q[1] },
    a_rolar: { startup_delta_frames: -4, mv_multiplier: 0.85, pergunta: "converter a saída da esquiva em aproximação punível" },
    a_saltar: { hyper_armor: "apenas_frames_activos", pergunta: "saltar por cima da linha e aceitar a aterragem" },
    de_cima: { critical: "queda_sobre_alvo", pergunta: "trocar altura segura por um crítico que exige alinhamento" },
    empurrao: { startup: 12, active: 4, recovery: 14, stamina: 20, mv: 0.05, guard_break: true, pergunta: "quebrar a guarda sem causar dano relevante" },
    arte_1mao: { nome: profile.arts[0], mana_cost: 12, pergunta: `gastar mana para ${profile.arts[0]}` },
    arte_2maos: { nome: profile.arts[1], mana_cost: 18, pergunta: `abdicar da mão livre para ${profile.arts[1]}` },
  };
}

const armorSlot = (id) => {
  if (/mascara|veu/.test(id)) return "rosto";
  if (/elmo|capacete|capuz|chapeu|gola/.test(id)) return "cabeca";
  if (/ombreira|tirantes|tiras_bronze/.test(id)) return "ombros";
  if (/bracadeira|bracelete/.test(id)) return "maos";
  if (/cinto|cinta|cinturao|aljava|mochila/.test(id)) return "cintura";
  if (/perneira|greva|correias/.test(id)) return "pernas";
  if (/corda_pes/.test(id)) return "pes";
  if (/manto/.test(id)) return "capa";
  return "peito";
};
const armorBiome = (id) => {
  const tests = [
    [/bruma/, "brumal"], [/selva|vime|seda/, "selva_funda"], [/campas|tumid|linho|rachado/, "campas_cinzentas"],
    [/mineiro|ferro|mimico/, "fojo"], [/mar|naufragio|salgada/, "costa_quebrada"], [/gelo|ventaneira|cabra/, "cimeira"],
    [/fornalha|obsidiana|borralheiro|fundido/, "fornalha"], [/fulgor|fulgurite|tempestade/, "fulgor"],
    [/fungo|esporo|quitina|raizama|casca/, "raizama"], [/afogad|submerso|marmore/, "cidade_afogada"],
    [/penitente|cera|dourada|brancas/, "santuario_branco"], [/raiz|sem_rosto|osso/, "raiz"],
  ];
  return tests.find(([pattern]) => pattern.test(id))?.[1] ?? "brumal";
};
const armorShape = {
  cabeca: "cúpula baixa com abertura frontal legível e rebordo que não tapa os ombros",
  rosto: "placa ou tecido ajustado ao contorno do nariz e maxilar, preso por duas tiras posteriores",
  ombros: "duas placas assimétricas sobre correias cruzadas, deixando livre a elevação dos braços",
  peito: "painéis sobrepostos do esterno à cintura, fechados ao lado por correias largas",
  maos: "punhos articulados do pulso aos nós dos dedos, com palma de couro flexível",
  cintura: "faixa de 14 cm com fecho frontal e bolsas ou placas suspensas sem cobrir as pernas",
  pernas: "placas ou tiras do joelho ao tornozelo, articuladas atrás para permitir a esquiva",
  pes: "calçado de cano médio com sola espessa, biqueira reforçada e atacadores laterais",
  capa: "manto até à barriga da perna, preso num só ombro para deixar a arma legível",
};
const armorWeight = { cabeca: 4, rosto: 1, ombros: 3, peito: 9, maos: 2, cintura: 2, pernas: 4, pes: 2, capa: 2 };
const armorCatalogue = {};
for (const [id, piece] of Object.entries(starterArmor)) {
  armorCatalogue[id] = {
    nome: piece.nome, slot: piece.slot, peso: piece.peso, material: piece.material,
    resistencias: piece.resistencias, habilidade: "nenhuma — kit inicial não altera o combate medido",
    onde_ma: "não traz verbo próprio; troca-se quando a rota já ensinou resistências e peso",
    onde_se_encontra: "kit inicial de uma das seis origens em Brumal",
    descricao_visual: piece.descricao_visual,
    asset_path: `art/ui/icons/armor/${id.replaceAll("_", "-")}.png`, fatia_1: true,
  };
}
for (const id of [...lootByKind.armadura].sort()) {
  const slot = armorSlot(id);
  const biomeId = lootOrigin.armadura[id] ?? armorBiome(id);
  const biome = biomeById[biomeId];
  const ordinal = Object.keys(armorCatalogue).length;
  armorCatalogue[id] = {
    nome: title(id), slot, peso: armorWeight[slot] + (ordinal % 3) * 0.5,
    material: biome.material,
    resistencias: { [biomeId]: 6 + (ordinal % 3) * 2 },
    habilidade: `ao ler o perigo próprio de ${biome.nome}, permite escolher uma resposta de ${slot}; termina ao trocar esta peça`,
    onde_ma: `fora de ${biome.nome}, o peso permanece mas a resistência regional raramente responde à ameaça dominante`,
    onde_se_encontra: `carta sem reposição do inimigo que veste esta peça em ${biome.nome}`,
    descricao_visual: `${title(id)}, peça de ${slot} em ${biome.material}: ${armorShape[slot]}; desgaste e fixações pertencem a ${biome.nome}`,
    asset_path: "", fatia_1: false,
  };
}
if (Object.keys(armorCatalogue).length !== 68) throw new Error("o catálogo de armadura não fechou 68");

const ringRows = [];
const R = (id, nome, eixo, efeito, numeros, afinidade, soma, onde, visual) => ringRows.push({ id, nome, eixo, efeito, numeros, afinidade, soma_com_outro: soma, onde_se_encontra: onde, visual });

// Recursos (9)
R("gota_guardada", "Gota Guardada", "recursos", "uma cura interrompida conserva metade da carga em vez de a perder", { max_percent: 0, fraction: 0.5 }, "paladin", "não; altera a mesma interrupção", "Brumal, no fundo do poço seco atrás da capela", "ferro fosco com cavidade em forma de gota e uma lasca de vidro verde");
R("pulmao_de_ferro", "Pulmão de Ferro", "recursos", "o primeiro gasto de stamina depois de oito segundos parado não inicia a demora de regeneração", { max_percent: 0, wait_s: 8 }, "tank", "não; gatilho único", "Fojo, sobre a viga que cruza o veio abandonado", "aro largo de ferro bruto com três fendas paralelas cheias de fuligem");
R("eco_de_cinzas", "Eco de Cinzas", "recursos", "meditar junto de uma fogueira extinta reacende-a como ponto de meditação, não como descanso", { max_percent: 0, meditate_s: 40 }, "sorcerer", "não; verbo de mundo", "Campas Cinzentas, numa urna sem nome da cripta lateral", "prata escurecida com urna minúscula de cinza selada sob cristal fumado");
R("odre_inteiro", "Odre Inteiro", "recursos", "beber o último frasco deixa o recipiente marcar a fonte de água mais próxima", { max_percent: 0, last_use: 1 }, "warrior", "sim; só com efeitos de navegação", "Costa Quebrada, dentro do casco virado ao contrário", "bronze salgado moldado como pequeno odre, com rolha de cortiça presa por fio");
R("veio_de_mana", "Veio de Mana", "recursos", "parar uma magia antes do compromisso devolve a mana paga", { max_percent: 0, before_commitment: true }, "sorcerer", "não; reembolso não acumula", "Cidade Afogada, no balcão submerso do arquivo", "prata afogada com canal espiral de vidro azul leitoso no interior");
R("brasa_economa", "Brasa Económica", "recursos", "uma resina não consumida porque o golpe falhou volta ao inventário no descanso", { max_percent: 0, one_recovery: true }, "berserker", "não; restituição única", "Fornalha, atrás do fole partido da oficina baixa", "obsidiana rugosa com grão de brasa preso numa gaiola de cobre");
R("fome_do_musgo", "Fome do Musgo", "recursos", "usar um antídoto revela durante seis segundos todas as plantas iguais próximas", { max_percent: 0, reveal_s: 6 }, "batedor", "sim; não aumenta alcance", "Selva Funda, no ninho sob a ponte de cipós", "madeira verde encerada com folha dentada incrustada em resina translúcida");
R("dedo_do_ultimo_gole", "Dedo do Último Gole", "recursos", "curar o parceiro com o teu último frasco deixa-o escolher quem recebe a carga no próximo descanso", { max_percent: 0, choice_count: 1 }, "paladin", "não; uma escolha por descanso", "Santuário Branco, no cálice rachado da sacristia", "ouro baço com duas taças minúsculas ligadas por um sulco branco");
R("semente_de_favorito", "Semente de Favorito", "recursos", "ao descansar permite trocar um favorito de magia sem abrir o menu completo", { max_percent: 0, swaps: 1 }, "mago_do_mal", "não; interface única", "A Raiz, dentro de um caroço negro que só abre após meditar", "osso antigo polido em torno de uma semente vermelha sem brilho");

// Movimento e física (9)
R("passo_de_linho", "Passo de Linho", "movimento_e_fisica", "andar sem correr deixa de emitir o sinal visual de passos, mas a visão inimiga não muda", { max_percent: 0, walk_only: true }, "assassin", "não; mesma supressão", "Campas Cinzentas, nos pés da efígie do corredor estreito", "linho cinzento entrançado sobre aro de ferro fino, sem qualquer superfície solta");
R("salto_de_cabra", "Salto de Cabra", "movimento_e_fisica", "agarrar uma borda depois de cair converte a queda em balanço uma vez por travessia", { max_percent: 0, uses_per_crossing: 1 }, "batedor", "não; verbo único", "Cimeira, sob a cornija alcançada pelo caminho de dentro", "chifre branco curvado em torno de uma dobradiça de aço frio");
R("rolamento_de_mare", "Rolamento de Maré", "movimento_e_fisica", "a esquiva que termina dentro de água rasa continua em deslize, mas não pode encadear ataque", { max_percent: 0, attack_lock_frames: 18 }, "warrior", "não; substitui a saída", "Cidade Afogada, numa janela abaixo da linha de água", "prata verdeada com três ondas gravadas e borda lisa de vidro");
R("calcanhar_de_obsidiana", "Calcanhar de Obsidiana", "movimento_e_fisica", "uma aterragem pesada parte chão rachado sem exigir ataque de queda", { max_percent: 0, heavy_landing: true }, "berserker", "não; verbo de terreno", "Fornalha, na chaminé cujo piso soa oco", "obsidiana quadrada com fissura central e incrustação de bronze vermelho");
R("fio_de_vento", "Fio de Vento", "movimento_e_fisica", "saltar a favor de uma rajada prende o manto e mostra a próxima corrente ascendente", { max_percent: 0, reveal_s: 5 }, "batedor", "sim; sem somar duração", "Cimeira, pendurado no sino de gelo exterior", "aço frio quase sem espessura com pena branca presa no engaste");
R("joelho_de_pedra", "Joelho de Pedra", "movimento_e_fisica", "empurrado contra uma parede, podes gastar uma esquiva para cair de lado em vez de ressaltar", { max_percent: 0, stamina_cost: 25 }, "tank", "não; troca a reacção", "Fojo, atrás da prensa de minério bloqueada", "granito escuro octogonal com faixa articulada de ferro bruto");
R("corda_do_naufrago", "Corda do Náufrago", "movimento_e_fisica", "uma corda cortada por ti fica escalável do lado de baixo até ao descanso", { max_percent: 0, until_rest: true }, "assassin", "não; estado do atalho", "Costa Quebrada, no mastro que só se alcança pela falésia", "bronze-do-mar envolto em cabo salgado com nó de escota minúsculo");
R("passada_de_raiz", "Passada de Raiz", "movimento_e_fisica", "raízes móveis deixam de agarrar enquanto caminhas para trás de frente para elas", { max_percent: 0, backward_only: true }, "sorcerer", "não; condição espacial", "Raizama, sob o micélio que recua da luz", "quitina verde em forma de pegada com filamentos de raiz petrificada");
R("queda_contada", "Queda Contada", "movimento_e_fisica", "antes de saltar, o bordo mostra se a queda causa dano, quase morte ou morte", { max_percent: 0, categories: 3 }, "universal", "não; leitura única", "Brumal, atrás do telhado quebrado do tutorial de quedas", "ferro rude com três degraus gravados e fio de prumo em cobre");

// Combate defensivo (9)
R("guarda_tardia", "Guarda Tardia", "combate_defensivo", "bloquear depois do compromisso mostra quanto da stamina o golpe vai quebrar", { max_percent: 0, preview_frames: 8 }, "tank", "não; leitura sobreposta", "Fojo, no escudo abandonado junto ao elevador", "ferro bruto quadrado com barra móvel de fulgurite opaca");
R("eco_do_aparo", "Eco do Aparo", "combate_defensivo", "um parry falhado deixa uma imagem do frame correcto no chão até ao fim do combate", { max_percent: 0, ghosts: 1 }, "warrior", "não; conserva só o último", "Brumal, na arena de treino atrás da porta interior", "aço polido com dois chevrons desencontrados em esmalte branco");
R("muro_respirado", "Muro Respirado", "combate_defensivo", "baixar a guarda voluntariamente antes de quebrar converte a quebra em recuo sem atordoamento", { max_percent: 0, before_zero: true }, "tank", "não; substitui a quebra", "Santuário Branco, sob o banco dos penitentes armados", "mármore branco rachado preso por quatro grampos de ouro baço");
R("pele_de_sal", "Pele de Sal", "combate_defensivo", "o primeiro projéctil bloqueado marca no escudo a direcção do atirador", { max_percent: 0, first_projectile: true }, "paladin", "sim; não soma marcas", "Costa Quebrada, no ninho do atirador acima do cais", "bronze salgado com seta de madrepérola embutida no aro");
R("vigilia_dupla", "Vigília Dupla", "combate_defensivo", "ao fixar um alvo, um segundo atacante dentro do arco traseiro acende a borda do ecrã", { max_percent: 0, attackers: 1 }, "assassin", "não; canal de acessibilidade", "Selva Funda, na plataforma entre duas emboscadas", "seda negra sobre aro bifurcado de bambu, com dois olhos de resina");
R("osso_que_cede", "Osso que Cede", "combate_defensivo", "receber contusão durante uma esquiva falhada permite rolar ao levantar, sem alterar i-frames", { max_percent: 0, wakeup_option: true }, "berserker", "não; opção de levantar", "Campas Cinzentas, na pilha de fémures sob o sino", "osso cinzento segmentado por juntas de ferro ferrugento");
R("nevoa_no_escudo", "Névoa no Escudo", "combate_defensivo", "bloquear magia deixa no escudo a cor e o símbolo do elemento que passou", { max_percent: 0, until_next_hit: true }, "sorcerer", "sim; uma leitura por elemento", "Cidade Afogada, no laboratório de escudos inundado", "vidro verde leitoso montado em prata afogada com oito ranhuras");
R("brasa_recuada", "Brasa Recuada", "combate_defensivo", "rolar para fora de uma área ardente deixa uma marca no limite seguro por três segundos", { max_percent: 0, marker_s: 3 }, "batedor", "não; conserva a marca recente", "Fornalha, no anel exterior do lago de escória", "obsidiana circular com esmalte vermelho interrompido num único ponto");
R("raiz_que_ampara", "Raiz que Ampara", "combate_defensivo", "um parceiro em guarda quebrada pode usar a tua colisão como cobertura sem te empurrar", { max_percent: 0, partner_only: true }, "paladin", "não; regra de colisão", "A Raiz, atrás das duas estátuas encostadas", "madeira negra em dois arcos encaixados, presos por lágrima de bruma");

// Combate ofensivo (9)
R("primeiro_sulco", "Primeiro Sulco", "combate_ofensivo", "o primeiro golpe de uma cadeia grava a direcção de fuga usada pelo alvo", { max_percent: 0, one_vector: true }, "warrior", "não; substitui a gravação", "Brumal, na oficina do espadachim sem nome", "ferro polido com um sulco diagonal preenchido por cera escura");
R("agulha_de_costas", "Agulha de Costas", "combate_ofensivo", "um golpe nas costas deixa a segunda adaga pronta para o corte cruzado", { max_percent: 0, followup_window_s: 2 }, "assassin", "não; ramo único", "Selva Funda, no passadiço por trás do sentinela", "aço negro fino com duas pontas cruzadas sobre seda verde");
R("peso_do_vazio", "Peso do Vazio", "combate_ofensivo", "um pesado que falha por menos de meio metro mostra a zona real do próximo arco", { max_percent: 0, miss_distance_m: 0.5 }, "berserker", "não; treino do último golpe", "Fojo, ao lado do bloco de teste rachado", "ferro bruto espesso com arco de cobre gravado numa face");
R("linha_do_lanceiro", "Linha do Lanceiro", "combate_ofensivo", "uma estocada em contra-ataque prolonga no chão a linha que teria acertado", { max_percent: 0, line_s: 2 }, "paladin", "sim; não multiplica dano", "Santuário Branco, no corredor das lanças votivas", "ouro baço alongado com fio recto de prata branca no centro");
R("circulo_de_cinza", "Círculo de Cinza", "combate_ofensivo", "uma arte circular que acerta dois alvos marca o espaço ainda não coberto pelo arco", { max_percent: 0, targets: 2 }, "warrior", "não; leitura da arte", "Campas Cinzentas, no centro da rotunda funerária", "prata cinzenta com círculo incompleto de cinza sob cristal");
R("mira_partilhada", "Mira Partilhada", "combate_ofensivo", "uma flecha sinalizadora faz o parceiro ver também a queda prevista do próximo disparo", { max_percent: 0, next_shot: 1 }, "batedor", "não; partilha um traçado", "Cimeira, no poleiro acima da ponte de vento", "aço frio com pequeno arco de osso e fio azul esticado");
R("contracanto", "Contracanto", "combate_ofensivo", "conjurar durante o aviso sonoro inimigo mostra se a magia termina antes do compromisso", { max_percent: 0, timing_preview: true }, "sorcerer", "não; leitura temporal", "Cidade Afogada, no coro submerso do arquivo", "prata afogada com duas pautas curvas de vidro sem letras");
R("dente_de_fogo", "Dente de Fogo", "combate_ofensivo", "atingir óleo com dano de fogo transforma a poça numa área persistente legível", { max_percent: 0, area_s: 6 }, "mago_do_mal", "não; mesma área", "Fornalha, dentro da cuba de têmpera vazia", "obsidiana em forma de dente com gota de bronze solidificada");
R("raiz_do_empurrao", "Raiz do Empurrão", "combate_ofensivo", "empurrar um inimigo pesado revela a massa que faltou para o deslocar", { max_percent: 0, reveal_kg: true }, "tank", "não; informação, não força", "A Raiz, junto ao gigante que não pode ser movido", "madeira petrificada com escala de pesos gravada em osso antigo");

// Risco (8)
R("peito_aberto", "Peito Aberto", "risco", "sem peça de peito, um parry falhado permite um empurrão de emergência em vez de bloquear", { max_percent: 0, stamina_cost: 20 }, "berserker", "não; condição de equipamento", "Fornalha, sobre a armadura derretida do duelista", "bronze fundido aberto à frente, com dois espigões virados para dentro");
R("ultima_luz", "Última Luz", "risco", "abaixo de um quarto de vida, fontes de cura ainda não usadas deixam um rasto visível", { max_percent: 0, health_threshold_percent: 25 }, "paladin", "não; não altera cura", "Santuário Branco, atrás do vitral apagado", "ouro baço com cristal branco quase extinto no engaste");
R("mana_vermelha", "Mana Vermelha", "risco", "sem mana, uma magia vermelha mostra exactamente os PV que cobraria antes de confirmar", { max_percent: 0, preview_only: true }, "mago_do_mal", "não; informação única", "A Raiz, na mesa onde o sangue não seca", "osso negro com fio vermelho encerrado sob quartzo opaco");
R("passo_sem_regresso", "Passo sem Regresso", "risco", "entrar numa arena sem frascos mantém a porta aberta durante o primeiro aviso do chefe", { max_percent: 0, one_warning: true }, "assassin", "não; condição de arena", "Campas Cinzentas, na porta que fecha atrás do carrasco", "ferro ferrugento moldado como dobradiça quebrada com linho negro");
R("trovao_na_mao", "Trovão na Mão", "risco", "segurar um pesado durante uma tempestade atrai um raio para a arma e marca o impacto", { max_percent: 0, charge_required: true }, "warrior", "não; evento ambiental", "Fulgor, no pára-raios tombado da praça", "fulgurite bruta presa por quatro garras de prata baça");
R("fundo_do_poco", "Fundo do Poço", "risco", "depois de sobreviver a uma queda quase mortal, revela a saída mais baixa da sala", { max_percent: 0, near_death_fall: true }, "batedor", "não; uma saída por sala", "Fojo, no patamar inferior do poço de minério", "ferro bruto em espiral descendente com ponto de cobre no fundo");
R("vidro_sem_armadura", "Vidro sem Armadura", "risco", "com carga leve e nenhum escudo, feitiços persistentes mostram o intervalo exacto entre pulsos", { max_percent: 0, pulse_preview: true }, "sorcerer", "não; leitura de volume", "Cidade Afogada, na redoma partida da torre", "vidro verde transparente sem aro exterior, preso a uma única garra de prata");
R("companhia_vazia", "Companhia Vazia", "risco", "sozinho num mundo co-op, altares de ressurreição apontam para o próximo sinal de invocação", { max_percent: 0, solo_only: true }, "universal", "não; navegação condicional", "Brumal, no segundo assento vazio da mesa de descanso", "dois aros de ferro rude, um inteiro e outro interrompido");

// Almas (8)
R("ganancia_mineira", "Ganância Mineira", "almas", "um veio explorado mostra quantos inimigos recompensados restam na zona", { max_percent: 0, counter: true }, "berserker", "não; informação da zona", "Fojo, carta rara do kobold armadilheiro da mina", "ferro bruto com pequena pepita presa atrás de uma grade de quatro barras");
R("fio_da_mancha", "Fio da Mancha", "almas", "a tua mancha de almas liga-se por fio ao último atalho aberto", { max_percent: 0, one_anchor: true }, "assassin", "não; uma rota", "Campas Cinzentas, sob a ponte que volta à fogueira", "prata cinzenta com fio de linho vermelho enrolado três vezes");
R("peso_do_morto", "Peso do Morto", "almas", "junto da mancha, o chão mostra a direcção do golpe que te matou", { max_percent: 0, one_direction: true }, "tank", "não; memória da morte", "Brumal, no cadáver atrás do primeiro brutamontes", "ferro rude com seta funda e gota de vidro vermelho escuro");
R("dizimo_branco", "Dízimo Branco", "almas", "oferecer almas num altar deixa-as guardadas ali até ao próximo descanso", { max_percent: 0, one_altar: true }, "paladin", "não; depósito não acumula entre altares", "Santuário Branco, na caixa de esmolas selada por dentro", "mármore branco com fenda estreita e aro de ouro baço");
R("mapa_dos_caidos", "Mapa dos Caídos", "almas", "uma mancha recuperada revela outras manchas de jogadores na mesma travessia", { max_percent: 0, reveal_s: 12 }, "batedor", "não; só sobreposição social", "Cimeira, no memorial varrido pelo vento", "aço frio com pontos de prata ligados como um mapa sem nomes");
R("conta_afogada", "Conta Afogada", "almas", "almas perdidas dentro de água sobem à superfície como bolhas visíveis", { max_percent: 0, water_only: true }, "sorcerer", "não; muda apresentação", "Cidade Afogada, no pescoço da estátua submersa", "prata afogada com esfera oca de vidro verde cheia de uma bolha fixa");
R("cinza_de_dez", "Cinza de Dez", "almas", "ao esgotar as dez derrotas recompensadas de um inimigo, marca a sua carta final no bestiário", { max_percent: 0, rewarded_defeats: 10 }, "universal", "não; estado de catálogo", "Fornalha, na décima urna da galeria de cinza", "obsidiana com dez entalhes, o último preenchido por cinza branca");
R("eco_sem_face", "Eco sem Face", "almas", "derrotar um sem-rosto faz a mancha repetir a silhueta do equipamento que ele largaria", { max_percent: 0, preview_card: true }, "mago_do_mal", "não; pré-visualização única", "A Raiz, carta rara do alabardeiro sem rosto", "osso antigo liso sem símbolo, com reflexo escuro que não copia o portador");

// Elementos (9)
R("bruma_em_vidro", "Bruma em Vidro", "elementos", "bloquear bruma condensa gotas que assinalam chão escorregadio", { max_percent: 0, marker_s: 4 }, "tank", "não; marca ambiental", "Brumal, dentro da janela embaciada da torre", "vidro fosco azul-cinza num aro de ferro rude coberto de gotas");
R("seiva_inversa", "Seiva Inversa", "elementos", "veneno acumulado também enche um traço verde na arma que o aplicou", { max_percent: 0, mirrored_meter: true }, "assassin", "não; espelho visual", "Selva Funda, no tronco oco da árvore venenosa", "madeira verde com canal de seiva escura e espinho de quitina");
R("osso_sem_sangue", "Osso sem Sangue", "elementos", "atingir um alvo imune a sangramento troca o ícone da barra pelo material a usar", { max_percent: 0, hint_count: 1 }, "warrior", "não; pista de fraqueza", "Campas Cinzentas, na mão do esqueleto intacto", "osso branco seco com gota vazada e pequeno rebite de bronze");
R("ferro_aterrado", "Ferro Aterrado", "elementos", "um raio bloqueado desenha no chão o caminho para a superfície não metálica mais próxima", { max_percent: 0, path_s: 3 }, "paladin", "não; rota de fuga", "Fulgor, sob a grelha electrificada da oficina", "ferro negro ligado por fio de cobre a uma pedra de quartzo");
R("carvao_fendido", "Carvão Fendido", "elementos", "rolar apaga queimadura se a esquiva terminar em água ou cinza fria", { max_percent: 0, required_surfaces: 2 }, "berserker", "não; cura binária", "Fornalha, na vala de cinza junto ao forno", "carvão negro rachado com núcleo azul frio e aro de bronze");
R("sal_da_sombra", "Sal da Sombra", "elementos", "escuridão recebida deixa visível a fonte mesmo atrás de cobertura durante um segundo", { max_percent: 0, reveal_s: 1 }, "mago_do_mal", "não; sinal curto", "Costa Quebrada, numa tigela de sal dentro da gruta", "bronze-do-mar com cristais de sal negro presos em meia-lua");
R("prata_da_mare", "Prata da Maré", "elementos", "dano mágico que atravessa o escudo colore apenas a parcela não absorvida", { max_percent: 0, split_display: true }, "sorcerer", "não; apresentação de dano", "Cidade Afogada, no escudo cerimonial do salão", "prata afogada com duas faixas de vidro, uma clara e uma verde");
R("cera_do_relampago", "Cera do Relâmpago", "elementos", "uma conversão elemental activa deixa uma vela no HUD que acaba com o efeito", { max_percent: 0, hud_candle: true }, "paladin", "sim; não estende duração", "Santuário Branco, atrás do altar atingido por raio", "cera branca solidificada em ouro baço com pavio de fulgurite");
R("lagrima_vermelha", "Lágrima Vermelha", "elementos", "pagar PV por necromancia desenha a rota de regresso à última fonte de cura", { max_percent: 0, route_until_heal: true }, "mago_do_mal", "não; uma rota activa", "A Raiz, dentro do relicário que pulsa sem som", "osso negro com lágrima de vidro vermelho suspensa no centro");

// Co-op (9)
R("marujo_perdido", "Marujo Perdido", "coop", "separados por uma parede, ambos vêem a porta que volta a juntá-los", { max_percent: 0, both_players: true }, "batedor", "não; uma porta comum", "Costa Quebrada, carta rara do submerso do cais", "bronze-do-mar com dois barcos minúsculos separados por uma linha de prata");
R("pulso_gemeo", "Pulso Gémeo", "coop", "quando o parceiro inicia ressurreição, o teu HUD mostra o seu círculo e compromisso", { max_percent: 0, cue_equivalence: true }, "paladin", "não; canal partilhado", "Santuário Branco, entre as duas campas paralelas", "ouro baço em dois aros unidos por uma barra branca central");
R("guarda_revezada", "Guarda Revezada", "coop", "baixar a guarda junto do parceiro transfere para ele a marca do atacante fixado", { max_percent: 0, range_m: 2 }, "tank", "não; uma marca", "Brumal, na torre defendida por dois orcs", "ferro rude com dois escudos gravados em sentidos opostos");
R("passo_em_eco", "Passo em Eco", "coop", "atravessar um atalho faz o parceiro ver a tua última pegada do outro lado", { max_percent: 0, footsteps: 1 }, "assassin", "não; conserva uma pegada", "Selva Funda, na ponte dupla sob a copa", "seda verde em torno de duas pegadas de bambu sobrepostas");
R("mana_partida", "Mana Partida", "coop", "ao meditar lado a lado, cada jogador escolhe quem termina primeiro e quem mantém a vigília", { max_percent: 0, choices: 2 }, "sorcerer", "não; decisão conjunta", "Cidade Afogada, no banco duplo do observatório", "prata afogada com ampulheta de vidro dividida em dois reservatórios");
R("furia_avisada", "Fúria Avisada", "coop", "activar Fúria envia ao parceiro o símbolo das acções que deixaste de poder usar", { max_percent: 0, symbols: 2 }, "berserker", "não; acessibilidade", "Fornalha, no balcão acima da arena do ferreiro", "obsidiana com escudo e esquiva riscados em bronze vermelho");
R("alvo_de_neve", "Alvo de Neve", "coop", "um inimigo marcado por flecha mostra ao parceiro a tua linha de tiro bloqueada", { max_percent: 0, line_of_fire: true }, "batedor", "não; uma linha", "Cimeira, no posto dos dois vigias congelados", "aço frio com mira de osso branco e fio azul interrompido");
R("sangue_em_dueto", "Sangue em Dueto", "coop", "se ambos enchem sangramento no mesmo alvo, as duas contribuições aparecem em metades da barra", { max_percent: 0, split_meter: true }, "assassin", "não; apresentação partilhada", "Campas Cinzentas, no sarcófago aberto por duas alavancas", "ferro cinzento com duas veias de esmalte vermelho que nunca se tocam");
R("raiz_entre_dois", "Raiz entre Dois", "coop", "se o parceiro cai fora do ecrã, raízes no chão apontam para a rota navegável até ele", { max_percent: 0, route_until_revive: true }, "universal", "não; uma rota por queda", "A Raiz, entre os dois tronos vazios", "madeira negra em dois ramos que se unem numa lágrima de bruma");

if (ringRows.length !== 70) throw new Error(`o catálogo de anéis fechou ${ringRows.length}, não 70`);
const rings = {};
for (const row of ringRows) {
  if (rings[row.id]) throw new Error(`anel repetido: ${row.id}`);
  rings[row.id] = {
    nome: row.nome, eixo: row.eixo, efeito: row.efeito, numeros: row.numeros,
    afinidade: row.afinidade, soma_com_outro: row.soma_com_outro,
    onde_se_encontra: row.onde_se_encontra,
    descricao_visual: `anel ${row.visual}; objecto isolado com interior e perfil lateral legíveis`,
    asset_path: "", fatia_1: false,
  };
}
for (const lootId of lootByKind.anel) if (!rings[lootId]) throw new Error(`anel de espólio ausente: ${lootId}`);

const output = {
  _fonte: "spec/68-catalogo-de-armas-armaduras-e-aneis.md; gerado por tools/generate-equipment-catalogue.mjs",
  _rules: {
    any_class_can_equip_any_item: true,
    ring_slots_start: 2,
    ring_slots_max: 10,
    ring_same_effect_stack_limit: 2,
    first_slice_images: "só fatia_1=true; itens futuros mantêm descrição visual mas não geram agora",
  },
  family_movesets: familyMovesets,
  weapon_improvement: {
    rule: "cada nível abre uma decisão reversível no altar; nenhum aumenta dano base, defesa ou velocidade",
    materials: "Limalha abre +1…+3; Limalha Nobre abre +4…+6; exploração fixa, nunca farm repetível",
    levels: [
      { level: 0, axis: "base", choice: "arma sem voto", increases_base_damage: false },
      { level: 1, axis: "postura", choice: "postura avançada ou postura guardada; muda o golpe em corrida", increases_base_damage: false },
      { level: 2, axis: "arte_nova", choice: "troca uma das artes por uma arte da família encontrada no mundo", increases_base_damage: false },
      { level: 3, axis: "troca_escala", choice: "troca o atributo de escala; nunca soma dois atributos", increases_base_damage: false },
      { level: 4, axis: "conversao_elemental", choice: "converte parte física num elemento; o total base não cresce", increases_base_damage: false },
      { level: 5, axis: "postura", choice: "segunda postura incompatível com a primeira, incluindo uma fraqueza espacial", increases_base_damage: false },
      { level: 6, axis: "arte_nova", choice: "arte de mestre ocupa as duas artes e mantém custo de mana", increases_base_damage: false },
    ],
  },
  status_effects: {
    veneno: {
      meter_max: 100, decay: "2 s sem acumular, depois −10/s", trigger: "aos 100, barra esvazia e aplica 12 s",
      effect: "1% dos PV máximos a cada 2 s; mortos-vivos legíveis são imunes",
      escape: "antídoto limpa; esperar 12 s; descanso limpa", applies_to: "jogador_e_inimigo",
      sound_cue: "borbulhar húmido por pulso", visual_cue: "barra verde hachurada e gotas de baixo para cima",
      descricao_visual: "gotas verdes espessas sobre pele ou metal, com bolhas amarelas pequenas e contorno hachurado visível",
      origem: "selva_funda_e_raizama", fatia_1: false,
    },
    sangramento: {
      meter_max: 100, decay: "2 s sem acumular, depois −14/s", trigger: "aos 100, pulso único e barra esvazia",
      effect: "perde 4% dos PV máximos e 30 stamina; regeneração de stamina espera 1,2 s",
      escape: "faixa limpa 45 da barra; sair da pressão deixa a barra decair; morto-vivo sem sangue é imune", applies_to: "jogador_e_inimigo",
      sound_cue: "dois batimentos secos e rasgo curto", visual_cue: "barra carmesim dividida em duas veias que fecham ao centro",
      descricao_visual: "duas veias carmesim finas percorrem a silhueta até se unirem num rasgo branco curto sobre o ponto atingido",
      origem: "campas_cinzentas", fatia_1: true,
    },
    queimadura: {
      meter_max: 100, decay: "2 s sem acumular, depois −12/s", trigger: "aos 100, aplica 8 s",
      effect: "1,5% dos PV máximos a cada 2 s; IA com traço covarde recua 2 s após cada pulso",
      escape: "rolar terminando em água ou cinza fria limpa; esperar 8 s; descanso limpa", applies_to: "jogador_e_inimigo",
      sound_cue: "estalo grave seguido de quatro crepitações", visual_cue: "barra laranja hachurada e quatro pulsos numerados por brasas",
      descricao_visual: "brasas laranja agarradas às bordas da silhueta, quatro pulsos de chama baixa e fumo negro sem tapar o corpo",
      origem: "fornalha", fatia_1: false,
    },
  },
  assassin_proposal: {
    approval: "instrução do Rico; confirmação do Mateus pendente",
    stealth: "Passo Mudo: ao caminhar sem correr, suprime som e marca visual dos passos; visão, alcance e estados da IA não mudam; termina ao atacar, esquivar ou correr",
    speed: "Corte Alternado: cada leve com a adaga principal abre uma resposta da adaga esquerda durante a recuperação; é ramo novo, não velocidade percentual",
    bleeding: "Cruz Carmesim: acertar os dois lados soma 35+35 à barra visível de sangramento; usa o estado simétrico do catálogo",
    special: "Entre Sombras: durante 3 s, a próxima esquiva que atravesse o volume do inimigo abre por 2 s o Corte Cruzado; i-frames não mudam e falhar a travessia gasta a janela",
    cooldown_s: 25,
    no_new_ai: true,
    speed_is_new_branch: true,
    class_affinity_not_lock: true,
    availability: "o Assassino começa com as duas adagas e a técnica; qualquer origem pode aprendê-la como loot de marco",
    runtime_state: "por implementar no M2; os dados e guardas já são validados",
  },
  weapons: weaponCatalogue,
  armor: armorCatalogue,
  rings,
};

for (const [kind, catalogue] of [["arma", weaponCatalogue], ["armadura", armorCatalogue], ["anel", rings]]) {
  for (const [id, item] of Object.entries(catalogue)) {
    if (!item.fatia_1) continue;
    if (!item.asset_path || !fs.existsSync(path.join(root, item.asset_path))) {
      throw new Error(`${kind} Fatia 1 sem imagem canónica: ${id} (${item.asset_path || "sem caminho"})`);
    }
  }
}

fs.writeFileSync(path.join(root, "game/data/equipment.json"), `${JSON.stringify(output, null, 2)}\n`, "utf8");
const cell = (value) => String(value).replaceAll("|", "\\|").replaceAll("\n", " ");
const ringTable = Object.entries(rings).map(([id, ring]) =>
  `| \`${id}\` | ${cell(ring.nome)} | ${cell(ring.eixo)} | ${cell(ring.efeito)} | ${cell(JSON.stringify(ring.numeros))} | ${cell(ring.afinidade)} | ${cell(ring.soma_com_outro)} | ${cell(ring.onde_se_encontra)} | Não |`).join("\n");
const familyTable = Object.entries(familyMovesets).map(([id, moves]) =>
  `| \`${id}\` | ${cell(moves.em_corrida.pergunta)} | ${cell(moves.a_rolar.pergunta)} | ${cell(moves.a_saltar.pergunta)} | ${cell(moves.empurrao.pergunta)} | ${cell(moves.arte_1mao.nome)} / ${cell(moves.arte_2maos.nome)} |`).join("\n");
const improvementTable = output.weapon_improvement.levels.map((row) =>
  `| ${row.level} | ${cell(row.axis)} | ${cell(row.choice)} | não |`).join("\n");
const firstSliceArmor = Object.entries(armorCatalogue).filter(([, item]) => item.fatia_1)
  .map(([id, item]) => `| \`${id}\` | ${cell(item.nome)} | ${cell(item.slot)} | ${cell(item.material)} | ${cell(item.descricao_visual)} | Sim |`).join("\n");
const specification = `# 68 — Catálogo de armas, armaduras, estados e anéis

> **WP5 fechado em 01-08-2026.** Este documento substitui a melhoria numérica do [\`51\`](51-familias.md) §7 e entrega a camada 2: **120 armas**, **68 peças de armadura**, **70 anéis**, os oito movesets completos, três estados e a proposta do Assassino. A fonte executável é [\`equipment.json\`](../game/data/equipment.json); a fonte editorial que a regenera é [\`generate-equipment-catalogue.mjs\`](../tools/generate-equipment-catalogue.mjs).
>
> Etiquetas: o catálogo é \`[FABLE]\` onde não havia palavra de dono. O Assassino continua **⏳ a aguardar confirmação do Mateus**; os três guardas do [\`12\`](12-classes.md) são obrigatórios e testados. Nenhuma tensão de dono foi decidida aqui.

---

## 1. O tamanho que agora existe

| Catálogo | Total | Fatia 1? | Regra de produção |
|---|---:|---:|---|
| Armas | **120** (as oito famílias; o escudo de madeira ocupa a 120.ª ficha) | **5** | as cinco imagens aprovadas são reutilizadas; 115 esperam |
| Armaduras | **68** (11 kits + 57 peças já prometidas nos baralhos do WP6) | **11** | estes onze ícones geram agora; 57 esperam |
| Anéis | **70** | **0** | nenhum cresce a Fatia 1 |

Cada linha dos três catálogos declara \`descricao_visual\` e \`fatia_1\`. “Espada” ou “katana” não são prompts: as fichas dizem comprimento, construção, material, fixação e marca do bioma. Qualquer origem equipa qualquer item; requisitos e afinidades dizem **como rende**, nunca “não podes”.

Os 32 IDs de arma, 57 de armadura e três de anel prometidos pelos 330 cartões do [\`67\`](67-catalogo-do-bestiario.md) resolvem todos no arranque. Materiais e consumíveis continuam no WP9; não são escondidos por esta entrega.

## 2. Os onze golpes em cada família

Os onze são: leve · pesado · cadeia · leve→pesado · corrida · rolar · saltar · de cima · empurrão · arte a uma mão · arte a duas mãos. A antiga regra global deixou de ser uma promessa: \`family_movesets\` materializa **88 fichas**. Todos os golpes declaram a pergunta que fazem; as artes custam mana.

| Família | Corrida | A rolar | A saltar | Empurrão | Artes 1 mão / 2 mãos |
|---|---|---|---|---|---|
${familyTable}

Constantes universais que preservam a gramática: leve→pesado corta 25% do arranque · rolar corta 4 frames e usa MV ×0,85 · saltar só tem hiper-armadura nos activos · empurrão é 12+4+14 f, 20 stamina, MV 0,05 e quebra guarda. A diferença vem da pergunta e da geometria da família, nunca de “esta dá mais dano”.

⚠️ O protótipo da Fatia 1 ainda executa leve, pesado, cadeia e bash. Corrida, saída de rolamento, salto, queda, empurrão universal, troca uma/duas mãos e artes entram no M2. O catálogo deixou de ser ambíguo; a animação/runtime ainda é trabalho real e fica em [\`LACUNAS.md\`](../LACUNAS.md).

## 3. Melhoria — seis níveis sem comprar força

\`[FABLE]\` A melhoria é um **voto reversível no altar**. Limalha abre +1…+3; Limalha Nobre abre +4…+6; ambas vêm de exploração fixa, nunca de inimigo repetível. Não há +10%, dano base, defesa, velocidade ou janela melhor.

| Nível | Eixo | Decisão | Aumenta dano base? |
|---:|---|---|---|
${improvementTable}

“Postura” significa **posição/moveset**, não dano de postura. Conversão troca parte física por um dos oito tipos e conserva o total base; troca de escala substitui o atributo em vez de somar dois. A arma melhorada sabe fazer coisas novas e também escolhe fraquezas novas.

## 4. Estados alterados — barra, consequência e saída

| Estado | Enche / decai | Ao disparar | Como se escapa | Origem | Fatia 1? |
|---|---|---|---|---|---|
| Veneno | 100; espera 2 s, −10/s | 12 s, 1% PV máx. a cada 2 s | antídoto, duração ou descanso; mortos-vivos legíveis imunes | Selva Funda / Raizama | Não |
| Sangramento | 100; espera 2 s, −14/s | 4% PV máx. + 30 stamina; regen espera 1,2 s | faixa limpa 45; distância deixa decair; sem-sangue imune | Campas Cinzentas | **Sim** |
| Queimadura | 100; espera 2 s, −12/s | 8 s, 1,5% PV máx. a cada 2 s; covardes recuam 2 s/pulso | rolar para água/cinza fria, duração ou descanso | Fornalha | Não |

As regras base aplicam-se a **jogador e inimigo**. A barra é sempre visível e o som tem equivalente visual; imunidade só existe quando o corpo a explica. O comportamento “covarde recua” é um traço de IA já declarado pela ficha, não uma regra diferente para dano recebido.

## 5. Assassino — proposta sob os três guardas

⏳ **Instrução do Rico; confirmação do Mateus pendente.** Não se marca \`[DECIDIDO]\`.

| Pedido | Proposta | Guarda que passa |
|---|---|---|
| Furtividade | **Passo Mudo:** caminhar sem correr suprime o som e marca visual dos passos; termina ao atacar, esquivar ou correr | não muda visão, alcance, estados nem exige IA nova |
| Velocidade | **Corte Alternado:** cada leve abre na recuperação uma resposta da adaga esquerda | é um ramo novo, nunca “+X%” |
| Sangramento | **Cruz Carmesim:** os dois lados somam 35+35 à barra visível | usa o mesmo estado e as mesmas saídas dos dois lados |
| Habilidade | **Entre Sombras:** 3 s para atravessar o volume inimigo com a próxima esquiva; se conseguir, abre Corte Cruzado por 2 s | i-frames não mudam; falhar gasta a janela |

O Assassino começa com duas adagas e a técnica. Qualquer origem pode aprendê-la como loot de marco: afinidade, não tranca. O runtime continua marcado para M2, tal como os restantes golpes novos.

## 6. As onze armaduras que geram primeiro

| ID | Nome | Slot | Material | Descrição visual | Fatia 1? |
|---|---|---|---|---|---|
${firstSliceArmor}

As outras 57 fichas preservam o que o inimigo realmente veste, com peso, resistência regional, fraqueza fora da região, localização e descrição visual. Não se geram até a coluna mudar.

## 7. Os 70 anéis

Começam-se com **dois dedos** e ganham-se até dez. Todos são passivos ou condicionais, nenhum consome tecla, cada efeito é único e nenhum número percentual passa 10%. Afinidade dá sabor, não exclusividade. Efeitos iguais só poderiam somar dois — mas este catálogo não repete efeitos.

| ID | Nome | Eixo | Efeito | Números | Afinidade | Soma? | Onde se encontra | Fatia 1? |
|---|---|---|---|---|---|---|---|---|
${ringTable}

## 8. As quatro perguntas do fio solto

| Pergunta | Resposta |
|---|---|
| **Como se usa?** | armas herdam o moveset da família; melhoria escolhe-se no altar; armadura e anéis equipam-se no ecrã WP11; estados entram por ataque e mostram barra/saída; Assassino usa duas adagas e habilidade de classe |
| **Como se prova?** | \`GameData\` valida contagens, 88 golpes, seis níveis sem força, estados simétricos, oito eixos e todos os IDs WP6; \`self_test.gd\` repete a fronteira e os três guardas do Assassino |
| **De onde vem a arte?** | cada item/estado tem \`descricao_visual\`; cinco armas reutilizam imagens aprovadas, onze armaduras geram neste bloco e tudo o resto espera \`Fatia 1?\` |
| **Quanto custa?** | agora: 11 fontes 1254×1254 com import de UI a 512; futuro: 115 armas + 57 armaduras + 70 anéis, produzidos só quando entrarem numa fatia; runtime dos sete golpes e equipar ficam para M2/WP11 |

## 9. O que continua aberto

- ⏳ Mateus confirmar ou alterar a proposta do Assassino; este catálogo não transforma a instrução do Rico em consenso.
- 🔴 Implementar no M2 os sete golpes novos, troca uma/duas mãos, artes e estados; os dados já fixam o contrato.
- 🟠 O WP9 ainda resolve os 40 materiais e 17 consumíveis usados pelos baralhos do bestiário.
- 🟠 O ecrã de equipamento/anéis, ganho dos oito dedos adicionais e persistência dos votos pertencem ao WP11/save v2.
- 🟠 Contra-ataque universal vs só perfuração, piso de escudo e uma/duas mãos continuam nas perguntas já existentes; nenhuma tensão foi decidida.

## Ligações

[\`12-classes.md\`](12-classes.md) · [\`14-equipamento.md\`](14-equipamento.md) · [\`37-aneis-e-elementos.md\`](37-aneis-e-elementos.md) · [\`41-estudo-armas-e-golpes.md\`](41-estudo-armas-e-golpes.md) · [\`51-familias.md\`](51-familias.md) · [\`67-catalogo-do-bestiario.md\`](67-catalogo-do-bestiario.md) · [\`equipment.json\`](../game/data/equipment.json)
`;
fs.writeFileSync(path.join(root, "spec/68-catalogo-de-armas-armaduras-e-aneis.md"), specification, "utf8");
console.log(`equipment.json: ${Object.keys(weaponCatalogue).length} armas · ${Object.keys(armorCatalogue).length} armaduras · ${Object.keys(rings).length} anéis`);
