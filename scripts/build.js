#!/usr/bin/env node
/**
 * Build de producao: minifica assets/app.js e assets/style.css,
 * e sincroniza start.html a partir de index.html.
 * Corre ANTES de cada commit/deploy (ver CLAUDE.md "Regras criticas").
 *
 * Uso:
 *   node scripts/build.js         -> gera app.min.js / style.min.css + sync start.html
 *   node scripts/build.js --check -> so verifica se os .min estao desatualizados (sai com erro se sim)
 */
const fs = require('fs');
const path = require('path');
const { execFileSync } = require('child_process');

const root = path.resolve(__dirname, '..');
const check = process.argv.includes('--check');

function run(pkg, binFile, args) {
  const script = path.join(root, 'node_modules', pkg, 'bin', binFile);
  return execFileSync(process.execPath, [script, ...args], {
    cwd: root,
    encoding: 'utf8',
    maxBuffer: 20 * 1024 * 1024
  });
}

function buildJs() {
  const src = path.join(root, 'assets/app.js');
  const dst = path.join(root, 'assets/app.min.js');
  const before = fs.existsSync(dst) ? fs.readFileSync(dst, 'utf8') : null;
  const out = run('terser', 'terser', [src, '-c', '-m', '--comments', 'false']);
  if (check) return out !== before;
  fs.writeFileSync(dst, out, 'utf8');
  console.log(`[build] app.min.js gerado (${fs.statSync(src).size} -> ${fs.statSync(dst).size} bytes)`);
  return false;
}

function buildCss() {
  const src = path.join(root, 'assets/style.css');
  const dst = path.join(root, 'assets/style.min.css');
  const before = fs.existsSync(dst) ? fs.readFileSync(dst, 'utf8') : null;
  const out = run('clean-css-cli', 'cleancss', [src]); // sem -o -> imprime para stdout
  if (check) return out !== before;
  fs.writeFileSync(dst, out, 'utf8');
  console.log(`[build] style.min.css gerado (${fs.statSync(src).size} -> ${fs.statSync(dst).size} bytes)`);
  return false;
}

function syncHtml() {
  const src = path.join(root, 'index.html');
  const dst = path.join(root, 'start.html');
  const srcContent = fs.readFileSync(src, 'utf8');
  const dstContent = fs.existsSync(dst) ? fs.readFileSync(dst, 'utf8') : null;
  if (srcContent === dstContent) return false;
  if (check) return true;
  fs.writeFileSync(dst, srcContent, 'utf8');
  console.log('[build] start.html sincronizado a partir de index.html.');
  return false;
}

if (check) {
  const jsStale = buildJs();
  const cssStale = buildCss();
  const htmlStale = syncHtml();
  if (jsStale || cssStale || htmlStale) {
    console.error('[build] DESATUALIZADO — corre: npm run build');
    process.exit(1);
  }
  console.log('[build] tudo atualizado.');
} else {
  buildJs();
  buildCss();
  syncHtml();
}
