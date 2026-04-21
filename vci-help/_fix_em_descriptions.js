// Fix em link descriptions and the welcome text partial translations
const fs = require('fs');
const path = require('path');
const base = 'D:/Tutorials/m-auto.online/wiki';

// The home page em descriptions for PT
const HOME_PT_FIXES = {
  '<p>Bem-vindo傲世卡尔产品，此网站包含最新的设备使用和车辆诊断相关知识。我们致力于让原厂车辆诊断更简单！</p>':
    '<p>Bem-vindo aos produtos ALLScanner. Este site contém os conhecimentos mais recentes sobre utilização dos dispositivos e diagnóstico de veículos. O nosso objectivo é simplificar o diagnóstico OEM!</p>',
  // Link descriptions that got [descrição original] - fix with proper text
  'Quick Start Guide <em>[descrição original]</em>': 'Guia de Início Rápido <em>Como instalar o software, ligar o dispositivo e iniciar o diagnóstico na primeira utilização.</em>',
  'Configuração de Ligação do Dispositivo <em>[descrição original]</em>': 'Ligação do Dispositivo <em>Como ligar e configurar WiFi, USB, LAN e outros modos de ligação.</em>',
  'Actualização de Firmware do Dispositivo <em>[descrição original]</em>': 'Actualização de Firmware <em>Como actualizar o firmware e recuperar em caso de anomalia.</em>',
  'Gestão de Licenças do Dispositivo <em>[descrição original]</em>': 'Gestão de Licenças <em>Como visualizar, actualizar e adicionar licenças do dispositivo.</em>',
  'Gestão de Drivers de Diagnóstico <em>[descrição original]</em>': 'Gestão de Drivers <em>Como instalar, actualizar e gerir os drivers de diagnóstico OEM.</em>',
  'Perguntas Frequentes (FAQ) <em>[descrição original]</em>': 'FAQ <em>Dúvidas comuns durante a utilização do produto e respectivas soluções.</em>',
  'Introdução à Plataforma de Diagnóstico Remoto <em>[descrição original]</em>': 'Introdução à Plataforma DoNet <em>Plataforma de diagnóstico remoto em tempo real baseada em nuvem e 5G.</em>',
  'Guia de Super Diagnóstico Remoto <em>[descrição original]</em>': 'Super Diagnóstico Remoto <em>Software OEM do servidor liga-se directamente ao dispositivo do cliente para diagnóstico remoto.</em>',
  'Guia de Diagnóstico Remoto Compatível <em>[descrição original]</em>': 'Diagnóstico Remoto Compatível <em>O servidor pode usar qualquer dispositivo para diagnóstico remoto.</em>',
  'Modificar Endereço IP do Dispositivo <em>[descrição original]</em>': 'Alterar IP do Dispositivo <em>Se o IP do dispositivo conflituar com o router durante o diagnóstico remoto.</em>',
  'Casos de Programação por Diagnóstico Remoto <em>[descrição original]</em>': 'Casos de Diagnóstico Remoto <em>Casos de teste em veículos reais com diagnóstico remoto.</em>',
  'Veículos Ligeiros <em>[descrição original]</em>': 'Veículos Ligeiros <em>Guia de diagnóstico OEM para ligeiros, com introdução ao software e casos de diagnóstico.</em>',
  'Veículos Comerciais <em>[descrição original]</em>': 'Veículos Comerciais <em>Guia de diagnóstico OEM para comerciais, com introdução ao software e casos de diagnóstico.</em>',
};

// EN home page fixes
const HOME_EN_FIXES = {
  '<p>Welcome傲世卡尔产品，此网站包含最新的设备使用和车辆诊断相关知识。我们致力于让原厂车辆诊断更简单！</p>':
    '<p>Welcome to ALLScanner products. This site contains the latest knowledge on device usage and vehicle diagnostics. Our goal is to make OEM vehicle diagnosis simpler!</p>',
  'Quick Start Guide <em>[original description]</em>': 'Quick Start Guide <em>How to install software, connect the device and start diagnosing on first use.</em>',
  'Device Connection Setup <em>[original description]</em>': 'Device Connection <em>How to connect and configure WiFi, USB, LAN and other connection modes.</em>',
  'Device Firmware Update <em>[original description]</em>': 'Firmware Update <em>How to upgrade device firmware and recover from firmware issues.</em>',
  'Device License Management <em>[original description]</em>': 'License Management <em>How to view, update and add device licenses.</em>',
  'Diagnostic Driver Management <em>[original description]</em>': 'Driver Management <em>How to install, update and manage OEM diagnostic drivers.</em>',
  'Frequently Asked Questions (FAQ) <em>[original description]</em>': 'FAQ <em>Common questions and solutions during product use.</em>',
  'Remote Diagnosis Platform Introduction <em>[original description]</em>': 'DoNet Platform Introduction <em>Real-time remote vehicle diagnosis platform based on cloud and 5G.</em>',
  'Hyper Remote Diagnosis Guide <em>[original description]</em>': 'Hyper Remote Diagnosis <em>Server OEM software connects directly to client device for remote diagnosis.</em>',
  'Legacy Remote Diagnosis Guide <em>[original description]</em>': 'Legacy Remote Diagnosis <em>Server can use any device to connect to client for remote diagnosis.</em>',
  'Change Device IP Address <em>[original description]</em>': 'Change Device IP <em>If device IP conflicts with router IP during remote diagnosis.</em>',
  'Remote Diagnosis Programming Cases <em>[original description]</em>': 'Remote Diagnosis Cases <em>Real vehicle remote diagnosis test cases.</em>',
  'Passenger Vehicle <em>[original description]</em>': 'Passenger Vehicle <em>OEM diagnostic guide for passenger vehicles, with software overview and diagnostic cases.</em>',
  'Commercial Vehicle <em>[original description]</em>': 'Commercial Vehicle <em>OEM diagnostic guide for commercial vehicles, with software overview and diagnostic cases.</em>',
};

function applyFixes(content, map) {
  for (const [key, val] of Object.entries(map)) {
    if (content.includes(key)) {
      content = content.split(key).join(val);
    }
  }
  return content;
}

// Apply to all PT index pages
function fixIndexPages(dir, map) {
  const indexFiles = [];
  function find(d) {
    const items = fs.readdirSync(d);
    for (const item of items) {
      const p = path.join(d, item);
      const stat = fs.statSync(p);
      if (stat.isDirectory()) find(p);
      else if (item === 'index.html') indexFiles.push(p);
    }
  }
  find(dir);
  for (const f of indexFiles) {
    let c = fs.readFileSync(f, 'utf8');
    const u = applyFixes(c, map);
    if (u !== c) {
      fs.writeFileSync(f, u, 'utf8');
      console.log('  Fixed: ' + path.relative(base, f));
    }
  }
}

console.log('Fixing PT index pages...');
fixIndexPages(path.join(base, 'pt'), HOME_PT_FIXES);
console.log('Fixing EN index pages...');
fixIndexPages(path.join(base, 'en'), HOME_EN_FIXES);

// Also fix the [original description] / [descrição original] labels across all pages
// Replace generic ones with proper context
function fixGenericEm(dir, lang) {
  const items = fs.readdirSync(dir);
  for (const item of items) {
    const p = path.join(dir, item);
    const stat = fs.statSync(p);
    if (stat.isDirectory()) fixGenericEm(p, lang);
    else if (item.endsWith('.html')) {
      let c = fs.readFileSync(p, 'utf8');
      const orig = c;
      // Remove [descrição original] / [original description] from em tags that have link text
      if (lang === 'pt') {
        c = c.replace(/ <em>\[descrição original\]<\/em>/g, '');
      } else {
        c = c.replace(/ <em>\[original description\]<\/em>/g, '');
      }
      if (c !== orig) {
        fs.writeFileSync(p, c, 'utf8');
      }
    }
  }
}

console.log('Removing generic [original description] labels...');
fixGenericEm(path.join(base, 'pt'), 'pt');
fixGenericEm(path.join(base, 'en'), 'en');

console.log('Done.');
