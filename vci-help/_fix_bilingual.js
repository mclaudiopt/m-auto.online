// Fix the vs30-xentry-dts page: it's bilingual (EN+ZH)
// For EN version: remove Chinese-only paragraphs (keep English)
// For PT version: replace Chinese paragraphs with note
const fs = require('fs');
const path = require('path');
const base = 'D:/Tutorials/m-auto.online/wiki';

function isChineseParagraph(text) {
  // Count Chinese vs non-Chinese printable chars
  const chinese = (text.match(/[\u4e00-\u9fff]/g) || []).length;
  const total = text.replace(/\s+/g, '').replace(/<[^>]+>/g, '').length;
  return total > 0 && chinese / total > 0.4;
}

function processVs30(filePath, lang) {
  let content = fs.readFileSync(filePath, 'utf8');

  // Strategy: the Chinese duplicate paragraphs appear as:
  // <p>English text...<br>Chinese text...</p>
  // Split these: keep English, remove Chinese after <br>

  // For paragraphs containing mixed EN+ZH after a <br>
  content = content.replace(/<p>([\s\S]*?)<\/p>/g, (m, inner) => {
    // Check if there's a mix of English and Chinese separated by <br>
    const parts = inner.split(/<br\s*\/?>/i);
    if (parts.length > 1) {
      const cleanParts = parts.filter(p => {
        const chinese = (p.match(/[\u4e00-\u9fff]/g) || []).length;
        const total = p.replace(/\s+/g, '').replace(/<[^>]+>/g, '').length;
        // Keep if less than 50% Chinese OR if it has important links
        return total === 0 || chinese / total < 0.5 || p.includes('<a ');
      });
      if (cleanParts.length < parts.length) {
        return '<p>' + cleanParts.join('<br>\n') + '</p>';
      }
    }
    return m;
  });

  // Also remove purely Chinese headings (h1/h2/h3 that are Chinese only)
  content = content.replace(/<h([1-3])[^>]*>([\s\S]*?)<\/h\1>/g, (m, level, inner) => {
    const chinese = (inner.match(/[\u4e00-\u9fff]/g) || []).length;
    const total = inner.replace(/<[^>]+>/g, '').trim().length;
    if (total > 0 && chinese / total > 0.7) {
      return ''; // Remove Chinese-only headings
    }
    return m;
  });

  // Remove Chinese-only list items in <ol>/<ul>
  content = content.replace(/<li>([\s\S]*?)<\/li>/g, (m, inner) => {
    const parts = inner.split(/<br\s*\/?>/i);
    if (parts.length > 1) {
      const cleanParts = parts.filter(p => {
        const chinese = (p.match(/[\u4e00-\u9fff]/g) || []).length;
        const total = p.replace(/<[^>]+>/g, '').replace(/\s+/g, '').length;
        return total === 0 || chinese / total < 0.5;
      });
      if (cleanParts.length < parts.length) {
        return '<li>' + cleanParts.join('<br>\n') + '</li>';
      }
    }
    return m;
  });

  fs.writeFileSync(filePath, content, 'utf8');
}

// Process vs30 files
const vs30_pt = path.join(base, 'pt/diagnosis/benz/vs30-xentry-dts.html');
const vs30_en = path.join(base, 'en/diagnosis/benz/vs30-xentry-dts.html');

console.log('Processing vs30 PT...');
processVs30(vs30_pt, 'pt');
console.log('Processing vs30 EN...');
processVs30(vs30_en, 'en');

// Count remaining Chinese
function countChinese(filePath) {
  const c = fs.readFileSync(filePath, 'utf8');
  const m = c.match(/[\u4e00-\u9fff]/g);
  return m ? m.length : 0;
}

console.log('vs30 PT remaining Chinese:', countChinese(vs30_pt));
console.log('vs30 EN remaining Chinese:', countChinese(vs30_en));
