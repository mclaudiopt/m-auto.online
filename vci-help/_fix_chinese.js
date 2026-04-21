// Fix remaining Chinese text in generated wiki pages
const fs = require('fs');
const path = require('path');

const base = 'D:/Tutorials/m-auto.online/wiki';

// Chinese Unicode range regex
const chineseRe = /[\u4e00-\u9fff\u3400-\u4dbf\u20000-\u2a6df]+/;

function hasChinese(str) {
  return chineseRe.test(str);
}

function processFile(filePath, lang) {
  let content = fs.readFileSync(filePath, 'utf8');
  let original = content;

  // Fix id attributes with Chinese
  content = content.replace(/ id="[^"]*[\u4e00-\u9fff][^"]*"/g, (m) => {
    const clean = m.replace(/[\u4e00-\u9fff\u3400-\u4dbf]+/g, '').replace(/\s+/g, '-').replace(/^-|-$/g, '');
    return ` id="${clean || 'section'}"`;
  });

  // Fix <em>..Chinese..</em>
  if (lang === 'pt') {
    content = content.replace(/<em>([^<]*[\u4e00-\u9fff][^<]*)<\/em>/g, '<em>[descrição original]</em>');
  } else {
    content = content.replace(/<em>([^<]*[\u4e00-\u9fff][^<]*)<\/em>/g, '<em>[original description]</em>');
  }

  // Fix <li> items that are entirely Chinese (no partial match)
  if (lang === 'pt') {
    content = content.replace(/<li>([\s]*[^<]*[\u4e00-\u9fff][^<]*[\s]*)<\/li>/g, (m, inner) => {
      return `<li><em>[${inner.trim().substring(0, 60)}…]</em></li>`;
    });
  } else {
    content = content.replace(/<li>([\s]*[^<]*[\u4e00-\u9fff][^<]*[\s]*)<\/li>/g, (m, inner) => {
      return `<li><em>[${inner.trim().substring(0, 60)}…]</em></li>`;
    });
  }

  if (content !== original) {
    fs.writeFileSync(filePath, content, 'utf8');
    console.log('  Fixed: ' + path.relative(base, filePath));
  }
}

function walkDir(dir, lang) {
  const items = fs.readdirSync(dir);
  for (const item of items) {
    const p = path.join(dir, item);
    const stat = fs.statSync(p);
    if (stat.isDirectory()) {
      walkDir(p, lang);
    } else if (item.endsWith('.html')) {
      processFile(p, lang);
    }
  }
}

console.log('Fixing Chinese in PT pages...');
walkDir(path.join(base, 'pt'), 'pt');
console.log('Fixing Chinese in EN pages...');
walkDir(path.join(base, 'en'), 'en');
console.log('Done.');
