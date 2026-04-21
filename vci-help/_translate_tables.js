// Translate table content and remaining product page Chinese
const fs = require('fs');
const path = require('path');
const base = 'D:/Tutorials/m-auto.online/wiki';

const COMMON = {
  // Table headers
  '品牌': { pt: 'Marca', en: 'Brand' },
  '车型': { pt: 'Modelos', en: 'Models' },
  '原厂诊断软件': { pt: 'Software OEM', en: 'OEM Software' },
  '支持': { pt: 'Suporte', en: 'Support' },
  '版本': { pt: 'Versão', en: 'Version' },
  '日期': { pt: 'Data', en: 'Date' },
  '更新内容': { pt: 'Notas de Actualização', en: 'Update Notes' },
  '固件版本': { pt: 'Versão de Firmware', en: 'Firmware Version' },
  '发布日期': { pt: 'Data de Lançamento', en: 'Release Date' },
  '下载': { pt: 'Transferir', en: 'Download' },
  '功能': { pt: 'Funções', en: 'Features' },
  '备注': { pt: 'Notas', en: 'Notes' },
  '接口': { pt: 'Interface', en: 'Interface' },
  '参数': { pt: 'Parâmetros', en: 'Parameters' },
  '规格': { pt: 'Especificações', en: 'Specifications' },
  '连接': { pt: 'Ligação', en: 'Connection' },
  '通信': { pt: 'Comunicação', en: 'Communication' },
  '供电': { pt: 'Alimentação', en: 'Power Supply' },
  '尺寸': { pt: 'Dimensões', en: 'Dimensions' },
  '重量': { pt: 'Peso', en: 'Weight' },
  '温度': { pt: 'Temperatura', en: 'Temperature' },
  '工作温度': { pt: 'Temperatura de funcionamento', en: 'Operating Temperature' },
  '存储温度': { pt: 'Temperatura de armazenamento', en: 'Storage Temperature' },
  '电源': { pt: 'Alimentação', en: 'Power' },
  '处理器': { pt: 'Processador', en: 'CPU' },
  '内存': { pt: 'Memória', en: 'Memory' },
  '闪存': { pt: 'Flash', en: 'Flash' },
  '主机': { pt: 'Host', en: 'Host' },
  '无线': { pt: 'Sem fios', en: 'Wireless' },
  '蓝牙': { pt: 'Bluetooth', en: 'Bluetooth' },
  '以太网': { pt: 'Ethernet', en: 'Ethernet' },

  // Vehicle brands (Chinese names)
  '奔驰、迈巴赫、Smart、FUSO': 'Mercedes-Benz, Maybach, Smart, FUSO',
  '宝马、劳斯莱斯、MINI': 'BMW, Rolls-Royce, MINI',
  '大众、西亚特、斯柯达、宾利、兰博基尼': 'VW, SEAT, Skoda, Bentley, Lamborghini',
  '奥迪': 'Audi',
  '保时捷': 'Porsche',
  '捷豹、路虎': 'Jaguar, Land Rover',
  '沃尔沃': 'Volvo',
  '雪佛兰、别克、凯迪拉克、欧宝、霍顿': 'Chevrolet, Buick, Cadillac, Opel, Holden',
  '福特、林肯': 'Ford, Lincoln',
  '本田、讴歌': 'Honda, Acura',
  '丰田、雷克萨斯、大发': 'Toyota, Lexus, Daihatsu',
  '斯巴鲁': 'Subaru',
  '马自达': 'Mazda',
  '日产、英菲尼迪': 'Nissan, Infiniti',
  '克莱斯勒': 'Chrysler',
  '吉普、道奇': 'Jeep, Dodge',
  '菲亚特、阿尔法·罗密欧': 'Fiat, Alfa Romeo',
  '现代、起亚': 'Hyundai, Kia',
  '雷诺': 'Renault',
  '标致、雪铁龙、DS': 'Peugeot, Citroën, DS',

  // Product specs (generic)
  '超级远程诊断只需设备联网即可实现原厂在线诊断。': {
    pt: 'O Super Diagnóstico Remoto apenas requer ligação à Internet para diagnóstico OEM online.',
    en: 'Hyper remote diagnosis only requires internet connection for online OEM diagnosis.'
  },
  '兼容远程诊断可支持多种特殊功能设备远程诊断。': {
    pt: 'O Diagnóstico Remoto Compatível suporta diagnóstico remoto com vários dispositivos especiais.',
    en: 'Legacy remote diagnosis supports remote diagnosis with various special function devices.'
  },
  '设备支持一键配网功能，快速接入远程诊断平台。': {
    pt: 'O dispositivo suporta configuração de rede com um clique para acesso rápido à plataforma remota.',
    en: 'Device supports one-click network configuration for quick remote platform access.'
  },
  '支持的原厂车辆诊断功能': {
    pt: 'Funções de Diagnóstico OEM Suportadas',
    en: 'Supported OEM Vehicle Diagnostic Functions'
  },

  // Guide / Connection page
  '设备连接配置': { pt: 'Configuração de Ligação do Dispositivo', en: 'Device Connection Setup' },
  '通过 USB 连接': { pt: 'Ligação via USB', en: 'USB Connection' },
  '通过 WiFi 连接': { pt: 'Ligação via WiFi', en: 'WiFi Connection' },
  '通过 LAN 连接': { pt: 'Ligação via LAN', en: 'LAN Connection' },

  // Release notes common patterns
  '更新日志': { pt: 'Registo de Alterações', en: 'Changelog' },
  '新增功能': { pt: 'Novas Funcionalidades', en: 'New Features' },
  '修复问题': { pt: 'Correcções', en: 'Bug Fixes' },
  '优化改进': { pt: 'Melhorias', en: 'Improvements' },
  '已知问题': { pt: 'Problemas Conhecidos', en: 'Known Issues' },
};

function applyTranslations(content, lang) {
  for (const [key, val] of Object.entries(COMMON)) {
    if (!content.includes(key)) continue;
    if (typeof val === 'string') {
      content = content.split(key).join(val);
    } else if (val && val[lang]) {
      content = content.split(key).join(val[lang]);
    }
  }
  return content;
}

function processDir(dir, lang) {
  const items = fs.readdirSync(dir);
  for (const item of items) {
    const p = path.join(dir, item);
    const stat = fs.statSync(p);
    if (stat.isDirectory()) {
      processDir(p, lang);
    } else if (item.endsWith('.html')) {
      let content = fs.readFileSync(p, 'utf8');
      const updated = applyTranslations(content, lang);
      if (updated !== content) {
        fs.writeFileSync(p, updated, 'utf8');
        console.log('  ' + path.relative(base, p));
      }
    }
  }
}

console.log('Translating tables/specs PT...');
processDir(path.join(base, 'pt'), 'pt');
console.log('Translating tables/specs EN...');
processDir(path.join(base, 'en'), 'en');

function countChinese(dir) {
  let total = 0;
  const items = fs.readdirSync(dir);
  for (const item of items) {
    const p = path.join(dir, item);
    const stat = fs.statSync(p);
    if (stat.isDirectory()) total += countChinese(p);
    else if (item.endsWith('.html')) {
      const c = fs.readFileSync(p, 'utf8');
      const m = c.match(/[\u4e00-\u9fff]/g);
      if (m) total += m.length;
    }
  }
  return total;
}

console.log('\nRemaining Chinese PT:', countChinese(path.join(base, 'pt')));
console.log('Remaining Chinese EN:', countChinese(path.join(base, 'en')));
