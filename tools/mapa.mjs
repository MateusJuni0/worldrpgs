#!/usr/bin/env node
// Gera o MAPA.md — estrutura do projecto e quem depende de quem.
// Determinístico e grátis: lê os links reais entre documentos, não inventa nada.
// Correr: node tools/mapa.mjs

import fs from 'node:fs';
import path from 'node:path';

const raiz = process.cwd();
const ignorar = /^(\.git|\.godot|node_modules|graphify-out|art\/models|art\/audio|art\/textures|medicoes|game\/captures)/;

function listar(dir, acc = []) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    const rel = path.relative(raiz, p).replace(/\\/g, '/');
    if (ignorar.test(rel)) continue;
    if (e.isDirectory()) listar(p, acc);
    else if (e.name.endsWith('.md')) acc.push(rel);
  }
  return acc;
}

const docs = listar(raiz).sort();
const titulo = {}, liga = {}, ligado = {}, linhas = {};

for (const d of docs) {
  const t = fs.readFileSync(path.join(raiz, d), 'utf8');
  linhas[d] = t.split('\n').length;
  titulo[d] = (t.match(/^#\s+(.+)$/m) || [, path.basename(d)])[1].trim();
  liga[d] = new Set();
  for (const m of t.matchAll(/\]\(([^)#\s]+\.md)[^)]*\)/g)) {
    const alvo = path.relative(raiz, path.resolve(path.dirname(path.join(raiz, d)), m[1])).replace(/\\/g, '/');
    if (docs.includes(alvo) && alvo !== d) liga[d].add(alvo);
  }
}
for (const d of docs) for (const a of liga[d]) (ligado[a] = ligado[a] || new Set()).add(d);

const grau = d => (liga[d]?.size || 0) + (ligado[d]?.size || 0);
const maisCitados = [...docs].sort((a, b) => (ligado[b]?.size || 0) - (ligado[a]?.size || 0)).slice(0, 12);
const orfaos = docs.filter(d => !ligado[d]?.size && !/^(README|SPEC|ESTADO|LACUNAS|CLAUDE|MAPA|DECISOES|COORDENACAO)/.test(path.basename(d)));

const grupo = d =>
  d.startsWith('spec/') ? 'spec' :
  d.startsWith('prompts/') ? 'prompts' :
  d.startsWith('docs/') ? 'docs' :
  d.startsWith('game/') ? 'game' :
  d.startsWith('art/') ? 'art' :
  d.startsWith('memory/') ? 'memory' : 'raiz';

const grupos = {};
for (const d of docs) (grupos[grupo(d)] = grupos[grupo(d)] || []).push(d);

const total = docs.reduce((s, d) => s + linhas[d], 0);

let out = `# MAPA — a estrutura do projecto

> **Gerado por \`node tools/mapa.mjs\`.** Não se edita à mão — se estiver desactualizado, corre-se outra vez.
>
> Mostra **os links reais entre documentos**. Um documento muito citado é uma fundação: mexer nele mexe em tudo o que aponta para lá.

**${docs.length} documentos · ${total.toLocaleString('pt-PT')} linhas**

## ⭐ As fundações — o que mais se cita

Mexer num destes obriga a rever o que aponta para lá.

| Documento | Citado por | Cita | Linhas |
|---|---|---|---|
`;
for (const d of maisCitados) {
  out += `| [\`${d}\`](${d}) — ${titulo[d].replace(/^\d+\s*—\s*/, '')} | **${ligado[d]?.size || 0}** | ${liga[d]?.size || 0} | ${linhas[d]} |\n`;
}

out += `\n## Por pasta\n`;
const nomes = { raiz: 'Raiz — leem-se primeiro', spec: 'spec/ — a especificação', prompts: 'prompts/ — instruções para agentes', docs: 'docs/ — auditorias', game: 'game/ — o jogo', art: 'art/ — a arte', memory: 'memory/ — registo' };
for (const g of ['raiz', 'spec', 'prompts', 'docs', 'game', 'art', 'memory']) {
  if (!grupos[g]?.length) continue;
  out += `\n### ${nomes[g]} — ${grupos[g].length} ficheiros\n\n| Documento | Linhas | Citado por |\n|---|---|---|\n`;
  for (const d of grupos[g].sort()) {
    out += `| [\`${path.basename(d)}\`](${d}) — ${titulo[d].replace(/^\d+\s*—\s*/, '').slice(0, 70)} | ${linhas[d]} | ${ligado[d]?.size || 0} |\n`;
  }
}

if (orfaos.length) {
  out += `\n## ⚠️ Documentos que ninguém cita\n\nExistem, mas nada aponta para eles. Ou estão a ser esquecidos, ou deviam estar ligados a algum lado.\n\n`;
  for (const d of orfaos) out += `- [\`${d}\`](${d}) — ${titulo[d]}\n`;
}

fs.writeFileSync(path.join(raiz, 'MAPA.md'), out);
console.log(`MAPA.md: ${docs.length} documentos, ${total.toLocaleString('pt-PT')} linhas, ${orfaos.length} sem citação`);
