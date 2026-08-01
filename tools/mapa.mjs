#!/usr/bin/env node
// Gera o MAPA.md — estrutura do projecto e quem depende de quem.
// Determinístico e grátis: lê os links reais entre documentos, não inventa nada.
// Correr: node tools/mapa.mjs

import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';

const raiz = process.cwd();

// ⚠️ CORRIGIDO 01-08-2026. O mapa listava ficheiros do DISCO; passa a listar
// os que estão MESMO no repositório (`git ls-files`).
//
// Porque é que isto importa, e não é arrumação:
//   1. Havia uma lista de exclusões à mão que não batia com o `.gitignore`.
//      Quem corresse isto numa máquina com as transcrições locais escrevia-as
//      no MAPA.md; como nunca são commitadas, o link nascia partido para toda
//      a gente e o guarda da spec falhava para sempre.
//   2. ⭐ E pior: `design/transcripts/` e `design/ideas/` estão gitignored
//      POR PRIVACIDADE — são uma conversa privada num repositório público.
//      O mapa publicava os NOMES e as DATAS desses ficheiros. Era fuga de
//      metadados exactamente daquilo que o `.gitignore` protege.
//
// Perguntar ao git em vez de manter uma lista fecha as duas de uma vez, e não
// volta a partir quando alguém acrescentar outra pasta ignorada.
function listar() {
  try {
    const saida = execFileSync('git', ['ls-files', '-z', '*.md'], {
      cwd: raiz, encoding: 'utf8', maxBuffer: 64 * 1024 * 1024,
    });
    const docs = saida.split('\0').filter(Boolean).map(d => d.replace(/\\/g, '/'));
    if (docs.length) return docs;
    throw new Error('git ls-files não devolveu nada');
  } catch (e) {
    // Sem git (tarball, CI mínimo) o mapa continua a gerar-se — mas diz que
    // pode conter ficheiros que não estão no repositório. Falhar em silêncio
    // era como isto começou.
    console.warn(`AVISO: ${e.message}. A varrer o disco; o mapa pode listar ficheiros não versionados.`);
    const ignorar = /^(\.git|\.godot|node_modules|graphify-out|art\/models|art\/audio|art\/textures|medicoes|game\/captures|design\/(transcripts|ideas|raw))/;
    const acc = [];
    (function varre(dir) {
      for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
        const p = path.join(dir, e.name);
        const rel = path.relative(raiz, p).replace(/\\/g, '/');
        if (ignorar.test(rel)) continue;
        if (e.isDirectory()) varre(p);
        else if (e.name.endsWith('.md')) acc.push(rel);
      }
    })(raiz);
    return acc;
  }
}

const docs = listar().sort();
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
