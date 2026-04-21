// Final cleanup pass for remaining Chinese text
const fs = require('fs');
const path = require('path');
const base = 'D:/Tutorials/m-auto.online/wiki';

const PT_FINAL = {
  'DoNet Diagnóstico Remoto组件需要使用 Internet Explorer 11 ou superior.':
    'O componente DoNet de Diagnóstico Remoto requer o Internet Explorer 11 ou superior.',
  'Neste passo pode seleccionar os drivers de diagnóstico OEM a instalar，或者Instalação Concluída后使用 VX Mananger 自由安装需要的原厂驱动。':
    'Pode seleccionar os drivers de diagnóstico OEM a instalar ou instalá-los posteriormente através do VX Manager.',
  'Instalação Concluída后将在桌面和开始菜单生成 VX Manager 快捷方式。':
    'Após a instalação, será criado um atalho do VX Manager no ambiente de trabalho e no menu Iniciar.',
  '【Libertar Ocupação】': '[Libertar Ocupação]',
  '【Reconectar】': '[Reconectar]',
  '【Teste do Dispositivo】': '[Teste do Dispositivo]',
  '【Reiniciar Dispositivo】': '[Reiniciar Dispositivo]',
  '【Actualizar Firmware】': '[Actualizar Firmware]',
  '【Actualizar Licença】': '[Actualizar Licença]',
  '【Activar/Desactivar DoIP】': '[Activar/Desactivar DoIP]',
  '【Relatório de Erros】': '[Relatório de Erros]',
  '【Verificar Actualizações】': '[Verificar Actualizações]',
  'Abra <strong>【车辆诊断】-&gt;【我的应用】</strong> clique na aplicação de diagnóstico a instalar <strong>[JLR DoIP]</strong>，在驱动信息界面中点击 <strong>【Instalar】</strong> 完成驱动安装。':
    'Abra <strong>[Diagnóstico do Veículo] → [As Minhas Aplicações]</strong>, clique na aplicação <strong>[JLR DoIP]</strong> e no ecrã do driver clique em <strong>[Instalar]</strong> para concluir.',
  // Fix bracket notation in button descriptions
  '【设备信息】': '[Informações do Dispositivo]',
  '【更新固件】': '[Actualizar Firmware]',
  '【开始更新】': '[Iniciar Actualização]',
  '【车辆诊断】': '[Diagnóstico do Veículo]',
  '【我的应用】': '[As Minhas Aplicações]',
  '【安装】': '[Instalar]',
  '【Next】': '[Seguinte]',
  '【Finish】': '[Concluir]',
  // System requirements items
  '1.6 GHz 或更快。': '1.6 GHz ou mais rápido.',
  'DDR 4GB 或以上。': 'DDR 4 GB ou superior.',
  '80GB 或以上。': '80 GB ou superior.',
  'LAN 100/1000M。': 'LAN 100/1000 Mbps.',
  'USB2.0 或 USB3.0。': 'USB 2.0 ou USB 3.0.',
  '802.11a/b/g/n WiFi。': '802.11a/b/g/n WiFi.',
  'Windows 10 / 8 / 7。': 'Windows 10 / 8 / 7.',
  'Internet Explorer 11 或更新版本。': 'Internet Explorer 11 ou superior.',
};

const EN_FINAL = {
  'DoNet Remote Diagnosis组件需要使用 Internet Explorer 11 or newer.':
    'The DoNet Remote Diagnosis component requires Internet Explorer 11 or newer.',
  'You can select OEM diagnostic drivers to install，或者Installation Complete后使用 VX Mananger 自由安装需要的原厂驱动。':
    'You can select OEM diagnostic drivers to install, or install them later using VX Manager.',
  'Installation Complete后将在桌面和开始菜单生成 VX Manager 快捷方式。':
    'After installation, a VX Manager shortcut is created on the desktop and Start menu.',
  '【Release Device】': '[Release Device]',
  '【Reconnect】': '[Reconnect]',
  '【Device Test】': '[Device Test]',
  '【Restart Device】': '[Restart Device]',
  '【Update Firmware】': '[Update Firmware]',
  '【Update License】': '[Update License]',
  '【DoIP Toggle】': '[DoIP Toggle]',
  '【Error Report】': '[Error Report]',
  '【Check for Updates】': '[Check for Updates]',
  'Open <strong>【车辆诊断】-&gt;【我的应用】</strong> click the diagnostic application to install <strong>[JLR DoIP]</strong>，在驱动信息界面中点击 <strong>【Install】</strong> 完成驱动安装。':
    'Open <strong>[Vehicle Diagnosis] → [My Applications]</strong>, click the <strong>[JLR DoIP]</strong> application, then click <strong>[Install]</strong> in the driver info screen.',
  '【Device Info】': '[Device Info]',
  '【Update Firmware】': '[Update Firmware]',
  '【Start Update】': '[Start Update]',
  '【Vehicle Diagnosis】': '[Vehicle Diagnosis]',
  '【My Applications】': '[My Applications]',
  '【Install】': '[Install]',
  '1.6 GHz 或更快。': '1.6 GHz or faster.',
  'DDR 4GB 或以上。': 'DDR 4 GB or more.',
  '80GB 或以上。': '80 GB or more.',
  'LAN 100/1000M。': 'LAN 100/1000 Mbps.',
  'USB2.0 或 USB3.0。': 'USB 2.0 or USB 3.0.',
  '802.11a/b/g/n WiFi。': '802.11a/b/g/n WiFi.',
  'Windows 10 / 8 / 7。': 'Windows 10 / 8 / 7.',
  'Internet Explorer 11 或更新版本。': 'Internet Explorer 11 or newer.',
};

// Also do a broad cleanup: strip Chinese from UI bracket notation 【...】
function cleanBrackets(content, lang) {
  // Replace 【Chinese text】 with [English/PT equivalent]
  // For now just convert to plain brackets
  content = content.replace(/【([^】]*[\u4e00-\u9fff][^】]*)】/g, (m, inner) => {
    return '[' + inner + ']';
  });
  return content;
}

function applyTranslations(content, map) {
  for (const [key, val] of Object.entries(map)) {
    if (content.includes(key)) {
      content = content.split(key).join(val);
    }
  }
  return content;
}

function processDir(dir, map, lang) {
  const items = fs.readdirSync(dir);
  for (const item of items) {
    const p = path.join(dir, item);
    const stat = fs.statSync(p);
    if (stat.isDirectory()) {
      processDir(p, map, lang);
    } else if (item.endsWith('.html')) {
      let content = fs.readFileSync(p, 'utf8');
      content = applyTranslations(content, map);
      content = cleanBrackets(content, lang);
      fs.writeFileSync(p, content, 'utf8');
    }
  }
}

console.log('Final fix PT...');
processDir(path.join(base, 'pt'), PT_FINAL, 'pt');
console.log('Final fix EN...');
processDir(path.join(base, 'en'), EN_FINAL, 'en');

// Count remaining Chinese
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

console.log('Remaining Chinese in PT:', countChinese(path.join(base, 'pt')));
console.log('Remaining Chinese in EN:', countChinese(path.join(base, 'en')));
console.log('Done.');
