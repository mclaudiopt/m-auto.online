#!/usr/bin/env node
/**
 * Mantem index.html e start.html sincronizados (start.html e o ficheiro ativo,
 * mas ambos devem ficar identicos — ver CLAUDE.md "Regras criticas").
 *
 * Uso:
 *   node scripts/sync-html.js         -> copia index.html -> start.html
 *   node scripts/sync-html.js --check -> so verifica, sai com erro se divergirem (util em CI)
 */
const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');
const src = path.join(root, 'index.html');
const dst = path.join(root, 'start.html');

const check = process.argv.includes('--check');

const srcContent = fs.readFileSync(src, 'utf8');
const dstExists = fs.existsSync(dst);
const dstContent = dstExists ? fs.readFileSync(dst, 'utf8') : null;

if (srcContent === dstContent) {
  console.log('[sync-html] index.html e start.html ja estao sincronizados.');
  process.exit(0);
}

if (check) {
  console.error('[sync-html] DIVERGENCIA: start.html esta desatualizado em relacao a index.html.');
  console.error('[sync-html] Corrige com: npm run sync-html');
  process.exit(1);
}

fs.writeFileSync(dst, srcContent, 'utf8');
console.log('[sync-html] start.html sincronizado a partir de index.html.');
