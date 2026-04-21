// Fix mixed Chinese-translated sentences and remaining Chinese in li items
const fs = require('fs');
const path = require('path');
const base = 'D:/Tutorials/m-auto.online/wiki';

// These are the actual mixed-language strings found in the output
const PT_MIXED = {
  // Quickstart page mixed
  'Antes de iniciar o diagnóstico automóvel com o dispositivo，PC 上必须安装 VX Manager 管理工具和驱动程序，Este instalador está incluído no CD-ROM do produto，ou pode transferir a versão mais recente através dos seguintes links:':
    'Antes de iniciar o diagnóstico com o dispositivo, o PC deverá ter o VX Manager e os drivers instalados. O instalador está incluído no CD-ROM do produto ou pode ser transferido nos seguintes links:',
  '1.6 GHz 或更快。': '1.6 GHz ou mais rápido.',
  'DDR 4GB 或以上。': 'DDR 4 GB ou superior.',
  '80GB 或以上。': '80 GB ou superior.',
  'LAN 100/1000M。': 'LAN 100/1000 Mbps.',
  'USB2.0 或 USB3.0。': 'USB 2.0 ou USB 3.0.',
  '802.11a/b/g/n WiFi。': '802.11a/b/g/n WiFi.',
  'Windows 10 / 8 / 7。': 'Windows 10 / 8 / 7.',
  'Internet Explorer 11 或更新版本。': 'Internet Explorer 11 ou superior.',
  'DoNet 远程诊断组件需要使用 Internet Explorer 11 或更新版本。':
    'O componente de Diagnóstico Remoto DoNet requer o Internet Explorer 11 ou superior.',
  'Windows 7 系统需要升级 IE 浏览器为最新版本。':
    'O Windows 7 necessita de atualizar o IE para a versão mais recente.',
  '下载 Internet Explorer 11（32 位）': 'Transferir Internet Explorer 11 (32 bits)',
  '下载 Internet Explorer 11（64 位）': 'Transferir Internet Explorer 11 (64 bits)',
  // Step names from quickstart
  '1. 运行安装程序': '1. Executar o Instalador',
  '2. 开始安装': '2. Iniciar a Instalação',
  '3. 选择安装组件': '3. Seleccionar Componentes',
  '4. 安装进行中': '4. Instalação em Curso',
  '5. 安装完成': '5. Instalação Concluída',
  // Quickstart steps
  '此过程中可以勾选要安装的原厂诊断驱动，或者安装完成后使用 VX Mananger 自由安装需要的原厂驱动。':
    'Pode seleccionar os drivers de diagnóstico OEM a instalar, ou instalá-los posteriormente através do VX Manager.',
  '安装完成后将在桌面和开始菜单生成 VX Manager 快捷方式。':
    'Após a instalação, será criado um atalho do VX Manager no ambiente de trabalho e no menu Iniciar.',
  '启动 VX Manager，如果设备成功连接，将显示如下信息：':
    'Inicie o VX Manager. Se o dispositivo estiver ligado correctamente, será apresentada a seguinte informação:',
  '打开 <strong>【车辆诊断】-&gt;【我的应用】</strong> 页面，点击要安装的诊断应用 <strong>[JLR DoIP]</strong>，在驱动信息界面中点击 <strong>【安装】</strong> 完成驱动安装。':
    'Abra a página <strong>[Diagnóstico do Veículo] → [As Minhas Aplicações]</strong>, clique na aplicação <strong>[JLR DoIP]</strong> e no ecrã de informação do driver clique em <strong>[Instalar]</strong> para concluir.',
  '打开 JLR Pathfinder 诊断软件，自动扫描车型信息，诊断结果如下：':
    'Abra o software JLR Pathfinder. Este irá detectar automaticamente as informações do veículo. O resultado do diagnóstico é o seguinte:',
  // VX Manager button descriptions
  '重新连接设备并刷新设备信息。': 'Reconecta o dispositivo e actualiza as informações.',
  '设备自检和 LED 指示灯闪烁并且发出蜂鸣提示音。': 'Auto-teste do dispositivo com LED a piscar e sinal sonoro.',
  '设备复位并重新启动运行。': 'Repõe e reinicia o dispositivo.',
  '在线下载并更新设备固件程序。': 'Transfere e actualiza o firmware do dispositivo online.',
  '在线下载并更新设备授权数据。': 'Transfere e actualiza os dados de licença online.',
  '激活或关闭DoIP协议，测试车辆DoIP通信。': 'Activa ou desactiva o protocolo DoIP para testar a comunicação DoIP.',
  '设备被占用后手动解除占用释放设备。': 'Liberta manualmente o dispositivo quando está ocupado.',
  '查看和获取设备错误日志。': 'Visualiza e obtém o registo de erros do dispositivo.',
  '检查 VX Manager 软件是否有更新。': 'Verifica se há actualizações disponíveis para o VX Manager.',
  // Connection page
  '以 VCX-DoIP 设备通过USB连接为例，请确保设备连接正常：':
    'Exemplo com dispositivo VCX-DoIP via USB. Certifique-se de que a ligação está correcta:',
  '使用 DB26-OBD 电缆连接设备至车辆。': 'Ligue o cabo DB26-OBD do dispositivo ao veículo.',
  '使用 USB Type-B 电缆连接设备至 PC。': 'Ligue o cabo USB Tipo-B do dispositivo ao PC.',
  // Generic Chinese phrases commonly left over
  '更多连接方式': 'Mais modos de ligação',
  '详细了解 VCX 系列多种设备不同连接方式的使用':
    'Saiba mais sobre os diferentes modos de ligação dos dispositivos da série VCX',
};

const EN_MIXED = {
  'Before starting vehicle diagnosis with the device，PC 上必须安装 VX Manager 管理工具和驱动程序，This installer is included in the product CD-ROM，or download the latest version from these links:':
    'Before starting vehicle diagnosis, the PC must have VX Manager and drivers installed. The installer is included in the product CD-ROM or can be downloaded from these links:',
  'Antes de iniciar o diagnóstico automóvel com o dispositivo，PC 上必须安装 VX Manager 管理工具和驱动程序，Este instalador está incluído no CD-ROM do produto，ou pode transferir a versão mais recente através dos seguintes links:':
    'Before starting vehicle diagnosis with the device, the PC must have VX Manager and drivers installed. The installer is included in the product CD-ROM or can be downloaded from these links:',
  '1.6 GHz 或更快。': '1.6 GHz or faster.',
  'DDR 4GB 或以上。': 'DDR 4 GB or more.',
  '80GB 或以上。': '80 GB or more.',
  'LAN 100/1000M。': 'LAN 100/1000 Mbps.',
  'USB2.0 或 USB3.0。': 'USB 2.0 or USB 3.0.',
  '802.11a/b/g/n WiFi。': '802.11a/b/g/n WiFi.',
  'Windows 10 / 8 / 7。': 'Windows 10 / 8 / 7.',
  'Internet Explorer 11 或更新版本。': 'Internet Explorer 11 or newer.',
  'DoNet 远程诊断组件需要使用 Internet Explorer 11 或更新版本。':
    'The DoNet Remote Diagnosis component requires Internet Explorer 11 or newer.',
  'Windows 7 系统需要升级 IE 浏览器为最新版本。':
    'Windows 7 requires upgrading IE to the latest version.',
  '下载 Internet Explorer 11（32 位）': 'Download Internet Explorer 11 (32-bit)',
  '下载 Internet Explorer 11（64 位）': 'Download Internet Explorer 11 (64-bit)',
  '1. 运行安装程序': '1. Run the Installer',
  '2. 开始安装': '2. Begin Installation',
  '3. 选择安装组件': '3. Select Components',
  '4. 安装进行中': '4. Installation in Progress',
  '5. 安装完成': '5. Installation Complete',
  '此过程中可以勾选要安装的原厂诊断驱动，或者安装完成后使用 VX Mananger 自由安装需要的原厂驱动。':
    'You can select OEM diagnostic drivers to install, or install them later using VX Manager.',
  '安装完成后将在桌面和开始菜单生成 VX Manager 快捷方式。':
    'After installation, a VX Manager shortcut is created on the desktop and Start menu.',
  '启动 VX Manager，如果设备成功连接，将显示如下信息：':
    'Launch VX Manager. If the device is connected successfully, the following information will be displayed:',
  '打开 <strong>【车辆诊断】-&gt;【我的应用】</strong> 页面，点击要安装的诊断应用 <strong>[JLR DoIP]</strong>，在驱动信息界面中点击 <strong>【安装】</strong> 完成驱动安装。':
    'Open the <strong>[Vehicle Diagnosis] → [My Applications]</strong> page, click the <strong>[JLR DoIP]</strong> application, then click <strong>[Install]</strong> in the driver info screen to complete installation.',
  '打开 JLR Pathfinder 诊断软件，自动扫描车型信息，诊断结果如下：':
    'Open JLR Pathfinder software; it automatically scans vehicle information. The diagnosis result is shown below:',
  '重新连接设备并刷新设备信息。': 'Reconnect device and refresh device information.',
  '设备自检和 LED 指示灯闪烁并且发出蜂鸣提示音。': 'Device self-test with LED flash and beep.',
  '设备复位并重新启动运行。': 'Reset and restart the device.',
  '在线下载并更新设备固件程序。': 'Download and update device firmware online.',
  '在线下载并更新设备授权数据。': 'Download and update device license data online.',
  '激活或关闭DoIP协议，测试车辆DoIP通信。': 'Toggle DoIP protocol to test vehicle DoIP communication.',
  '设备被占用后手动解除占用释放设备。': 'Manually release the device when it is occupied.',
  '查看和获取设备错误日志。': 'View and retrieve device error logs.',
  '检查 VX Manager 软件是否有更新。': 'Check if VX Manager has updates available.',
  '以 VCX-DoIP 设备通过USB连接为例，请确保设备连接正常：':
    'Using VCX-DoIP connected via USB as an example, ensure the connection is correct:',
  '使用 DB26-OBD 电缆连接设备至车辆。': 'Connect the DB26-OBD cable from the device to the vehicle.',
  '使用 USB Type-B 电缆连接设备至 PC。': 'Connect the USB Type-B cable from the device to the PC.',
  '更多连接方式': 'More connection methods',
  '详细了解 VCX 系列多种设备不同连接方式的使用':
    'Learn about different connection methods for VCX series devices',
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
    if (stat.isDirectory()) {
      processDir(p, map);
    } else if (item.endsWith('.html')) {
      let content = fs.readFileSync(p, 'utf8');
      const updated = applyTranslations(content, map);
      if (updated !== content) {
        fs.writeFileSync(p, updated, 'utf8');
        console.log('  Fixed: ' + path.relative(base, p));
      }
    }
  }
}

console.log('Fixing mixed-language sentences in PT...');
processDir(path.join(base, 'pt'), PT_MIXED);
console.log('Fixing mixed-language sentences in EN...');
processDir(path.join(base, 'en'), EN_MIXED);
console.log('Done.');
