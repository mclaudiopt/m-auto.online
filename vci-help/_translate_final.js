// Final broad translation pass for release notes and remaining content
const fs = require('fs');
const path = require('path');
const base = 'D:/Tutorials/m-auto.online/wiki';

// Release notes patterns
const PT_FINAL2 = {
  // Release note verbs
  '更新: ': 'Actualização: ',
  '更新：': 'Actualização: ',
  '修正: ': 'Correcção: ',
  '修正：': 'Correcção: ',
  '新增: ': 'Novo: ',
  '新增：': 'Novo: ',
  '优化: ': 'Optimização: ',
  '优化：': 'Optimização: ',
  '修复: ': 'Correcção: ',
  '修复：': 'Correcção: ',
  '改进: ': 'Melhoria: ',
  '改进：': 'Melhoria: ',
  '支持: ': 'Suporte: ',
  '支持：': 'Suporte: ',
  '修复了': 'Corrigido: ',
  '新增了': 'Adicionado: ',
  '优化了': 'Optimizado: ',
  '增加了': 'Adicionado: ',
  '更新了': 'Actualizado: ',

  // Common release note phrases
  '更新支持': 'Actualizado suporte para',
  '支持新版本': 'Suporte para nova versão',
  '固件升级指南': 'Guia de Actualização de Firmware',
  '发布说明': 'Notas de Lançamento',
  '更新说明': 'Notas de Actualização',
  '版本说明': 'Notas da Versão',

  // Product spec patterns
  '接口协议': 'Protocolos de Interface',
  '车辆总线协议': 'Protocolos de Barramento Veicular',
  '通信速率': 'Taxa de Comunicação',
  '诊断协议': 'Protocolos de Diagnóstico',
  '供电电压': 'Tensão de Alimentação',
  '工作电流': 'Corrente de Trabalho',
  '工作温度范围': 'Gama de Temperatura de Trabalho',
  '存储温度范围': 'Gama de Temperatura de Armazenamento',
  '防护等级': 'Grau de Protecção',

  // Connection page
  '连接前请确认': 'Antes de ligar, confirme',
  '请参考以下步骤': 'Siga os passos abaixo',
  '如图所示': 'Conforme indicado na imagem',
  '注意事项': 'Notas Importantes',

  // Product image captions
  '正面': 'Vista frontal',
  '背面': 'Vista traseira',
  '侧面': 'Vista lateral',
  '俯视': 'Vista superior',
  '接口示意图': 'Diagrama de interfaces',
  '连接示意图': 'Diagrama de ligação',

  // License page
  '设备授权': 'Licença do Dispositivo',
  '授权信息': 'Informações de Licença',
  '授权到期': 'Licença expirada',
  '授权有效期': 'Validade da Licença',
  '在线激活': 'Activação online',
  '离线激活': 'Activação offline',
  '激活码': 'Código de activação',
  '序列号': 'Número de série',

  // Diagnosis driver page
  '诊断驱动': 'Driver de Diagnóstico',
  '驱动安装': 'Instalação do Driver',
  '驱动更新': 'Actualização do Driver',
  '驱动版本': 'Versão do Driver',
  '驱动下载': 'Transferência do Driver',
  '驱动管理': 'Gestão de Drivers',
  '已安装': 'Instalado',
  '未安装': 'Não instalado',
  '可用更新': 'Actualização disponível',
  '正在安装': 'A instalar...',
  '安装成功': 'Instalado com sucesso',
  '安装失败': 'Falha na instalação',

  // Steps
  '第一步': 'Passo 1',
  '第二步': 'Passo 2',
  '第三步': 'Passo 3',
  '第四步': 'Passo 4',
  '第五步': 'Passo 5',
  '步骤': 'Passo',

  // Generic UI
  '打开': 'Abra',
  '关闭': 'Feche',
  '点击': 'Clique em',
  '选择': 'Seleccione',
  '输入': 'Introduza',
  '确认': 'Confirme',
  '取消': 'Cancele',
  '保存': 'Guarde',
  '删除': 'Elimine',
  '添加': 'Adicione',
  '搜索': 'Pesquise',
  '刷新': 'Actualize',
  '完成': 'Concluído',
  '开始': 'Iniciar',
  '停止': 'Parar',
  '重启': 'Reiniciar',
  '返回': 'Voltar',
  '下一步': 'Seguinte',
  '上一步': 'Anterior',
  '完成安装': 'Concluir Instalação',

  // file source attribution for vs30
  '文章来源:': 'Fonte do artigo:',
  '来自 Sprinter-Forum 论坛用户 KrellyKryl 使用 ALLScanner VCX-SE 的产品深度体验和教程':
    'Experiência detalhada e tutorial do utilizador KrellyKryl do fórum Sprinter-Forum com o ALLScanner VCX-SE',
};

const EN_FINAL2 = {
  '更新: ': 'Update: ',
  '更新：': 'Update: ',
  '修正: ': 'Fix: ',
  '修正：': 'Fix: ',
  '新增: ': 'New: ',
  '新增：': 'New: ',
  '优化: ': 'Improvement: ',
  '优化：': 'Improvement: ',
  '修复: ': 'Fix: ',
  '修复：': 'Fix: ',
  '改进: ': 'Improvement: ',
  '改进：': 'Improvement: ',
  '支持: ': 'Support: ',
  '支持：': 'Support: ',
  '修复了': 'Fixed: ',
  '新增了': 'Added: ',
  '优化了': 'Improved: ',
  '增加了': 'Added: ',
  '更新了': 'Updated: ',
  '更新支持': 'Updated support for',
  '支持新版本': 'Support for new version',
  '固件升级指南': 'Firmware Upgrade Guide',
  '发布说明': 'Release Notes',
  '更新说明': 'Update Notes',
  '版本说明': 'Version Notes',
  '接口协议': 'Interface Protocols',
  '车辆总线协议': 'Vehicle Bus Protocols',
  '通信速率': 'Communication Rate',
  '诊断协议': 'Diagnostic Protocols',
  '供电电压': 'Supply Voltage',
  '工作电流': 'Operating Current',
  '工作温度范围': 'Operating Temperature Range',
  '存储温度范围': 'Storage Temperature Range',
  '防护等级': 'Protection Rating',
  '连接前请确认': 'Before connecting, confirm',
  '请参考以下步骤': 'Follow the steps below',
  '如图所示': 'As shown in the image',
  '正面': 'Front view',
  '背面': 'Rear view',
  '侧面': 'Side view',
  '俯视': 'Top view',
  '接口示意图': 'Interface diagram',
  '连接示意图': 'Connection diagram',
  '设备授权': 'Device License',
  '授权信息': 'License Information',
  '授权到期': 'License expired',
  '授权有效期': 'License validity',
  '在线激活': 'Online activation',
  '离线激活': 'Offline activation',
  '激活码': 'Activation code',
  '序列号': 'Serial number',
  '诊断驱动': 'Diagnostic Driver',
  '驱动安装': 'Driver Installation',
  '驱动更新': 'Driver Update',
  '驱动版本': 'Driver Version',
  '驱动下载': 'Driver Download',
  '驱动管理': 'Driver Management',
  '已安装': 'Installed',
  '未安装': 'Not installed',
  '可用更新': 'Update available',
  '正在安装': 'Installing...',
  '安装成功': 'Installation successful',
  '安装失败': 'Installation failed',
  '第一步': 'Step 1',
  '第二步': 'Step 2',
  '第三步': 'Step 3',
  '第四步': 'Step 4',
  '第五步': 'Step 5',
  '步骤': 'Step',
  '打开': 'Open',
  '关闭': 'Close',
  '点击': 'Click',
  '选择': 'Select',
  '输入': 'Enter',
  '确认': 'Confirm',
  '取消': 'Cancel',
  '保存': 'Save',
  '删除': 'Delete',
  '添加': 'Add',
  '搜索': 'Search',
  '刷新': 'Refresh',
  '完成': 'Done',
  '开始': 'Start',
  '停止': 'Stop',
  '重启': 'Restart',
  '返回': 'Back',
  '下一步': 'Next',
  '上一步': 'Previous',
  '完成安装': 'Complete Installation',
  '文章来源:': 'Article source:',
  '来自 Sprinter-Forum 论坛用户 KrellyKryl 使用 ALLScanner VCX-SE 的产品深度体验和教程':
    'In-depth user experience and tutorial from Sprinter-Forum user KrellyKryl using the ALLScanner VCX-SE',
};

function applyTranslations(content, map) {
  for (const [key, val] of Object.entries(map)) {
    if (content.includes(key)) {
      content = content.split(key).join(val);
    }
  }
  return content;
}

function processDir(dir, map) {
  const items = fs.readdirSync(dir);
  for (const item of items) {
    const p = path.join(dir, item);
    const stat = fs.statSync(p);
    if (stat.isDirectory()) processDir(p, map);
    else if (item.endsWith('.html')) {
      let content = fs.readFileSync(p, 'utf8');
      const updated = applyTranslations(content, map);
      if (updated !== content) {
        fs.writeFileSync(p, updated, 'utf8');
      }
    }
  }
}

console.log('Final translation pass PT...');
processDir(path.join(base, 'pt'), PT_FINAL2);
console.log('Final translation pass EN...');
processDir(path.join(base, 'en'), EN_FINAL2);

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

console.log('Final Chinese count PT:', countChinese(path.join(base, 'pt')));
console.log('Final Chinese count EN:', countChinese(path.join(base, 'en')));
