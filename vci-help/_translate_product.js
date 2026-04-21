// Translate product pages and FAQ
const fs = require('fs');
const path = require('path');
const base = 'D:/Tutorials/m-auto.online/wiki';

// Common terms used across product pages
const COMMON_PT = {
  '产品概述': 'Descrição do Produto',
  '产品特性': 'Características do Produto',
  '产品规格': 'Especificações do Produto',
  '技术规格': 'Especificações Técnicas',
  '主要特性': 'Características Principais',
  '支持的原厂诊断软件': 'Software de Diagnóstico OEM Suportado',
  '包装清单': 'Conteúdo da Embalagem',
  '产品照片': 'Fotografias do Produto',
  '极致性能的车辆诊断接口': 'Interface de Diagnóstico Veicular de Alto Desempenho',
  '双核架构协同工作，通信性能更强': 'Arquitectura Dual-Core, Comunicação Mais Potente',
  '550MHz ARM 协议处理器实现 CAN-FD 和所有传统车辆总线协议。': 'Processador ARM 550 MHz para CAN-FD e todos os protocolos de barramento veicular.',
  '560MHz MIPS 网络处理器实现 DoIP 超级诊断网关。': 'Processador de rede MIPS 560 MHz para gateway de super diagnóstico DoIP.',
  '双核处理器通过百兆以太网通信，高带宽、低延迟。': 'Os dois processadores comunicam via ethernet 100 Mbps — alta largura de banda, baixa latência.',
  '诊断通信速度比上一代产品提升数倍。': 'Velocidade de comunicação de diagnóstico várias vezes superior à geração anterior.',
  '双操作系统并发，软件运行更稳定': 'Dois Sistemas Operativos em Paralelo, Maior Estabilidade',
  'RTOS 实时操作系统保障车辆总线协议多任务高并发通信。': 'O RTOS garante comunicação multi-tarefa e alta concorrência nos protocolos de barramento.',
  'OpenWrt 网络操作系统灵活连接多种网络接口和车辆。': 'O OpenWrt permite ligação flexível a múltiplas interfaces de rede e veículos.',
  '支持更全的车辆总线协议': 'Suporte Completo de Protocolos de Barramento Veicular',
  '集成 OBD 智能协议多路器芯片，所有引脚能够智能切换任意协议。': 'Chip multiplexador de protocolo OBD inteligente — todos os pinos podem comutar para qualquer protocolo.',
  '支持 3 路 CAN-FD 多通道并发通信，最高支持 5M Bps 高速通信。': 'Suporta 3 canais CAN-FD simultâneos até 5 Mbps.',
  '支持 ISO-13400 标准双路 DoIP 接口 Option 1 和 Option 2。': 'Suporta interfaces DoIP duplas ISO-13400 Opção 1 e Opção 2.',
  '灵活易用的连接方式': 'Modos de Ligação Flexíveis',
  '主机通信接口支持 USB / RJ45 / WLAN 等多种连接, 灵活易用。': 'Interface de comunicação suporta USB/RJ45/WLAN e outros modos.',
  '内置无线路由模式，诊断电脑可无线直连设备。': 'Modo router sem fios integrado — o PC de diagnóstico pode ligar-se directamente ao dispositivo sem fios.',
  '支持无线工作站模式，设备可接入无线局域网，任意电脑都可连接设备。': 'Suporta modo estação wireless — o dispositivo pode ser acedido por qualquer PC na rede local.',
  '支持将车辆 DoIP 以太网映射到 WLAN 实现无线 DoIP 诊断。': 'Suporta mapeamento da ethernet DoIP do veículo para WLAN, permitindo diagnóstico DoIP sem fios.',
  '全新的外观设计': 'Design Exterior Renovado',
  '采用集成 OBD-II 接口的一体化设计，方便即插即用。': 'Design integrado com conector OBD-II para fácil ligação plug-and-play.',
  '加固设计的 Type-C 接口可防止晃动和脱落，连接更可靠。': 'Conector Type-C reforçado para evitar folgas, ligação mais fiável.',
  '更强大的车辆诊断设备': 'Dispositivo de Diagnóstico Veicular Mais Potente',
  '更全面的原厂车辆诊断': 'Diagnóstico OEM Mais Abrangente',
  'VCX-FD 现在适配的原厂诊断车型品牌已达 17 种。': 'O VCX-FD é compatível com 17 marcas de diagnóstico OEM.',
  '硬件更新后全面支持基于 CAN-FD 和 DoIP 的新车型和新原厂诊断软件。': 'O hardware actualizado suporta totalmente novos modelos e software OEM baseados em CAN-FD e DoIP.',
  '各种高级诊断和编程功能达到原厂级别，速度甚至超过原厂设备。': 'Funções avançadas de diagnóstico e programação ao nível OEM, com velocidade que supera os equipamentos originais.',
  '支持一键安装、卸载和升级原厂支持驱动，易于使用。': 'Suporta instalação, desinstalação e actualização de drivers OEM com um clique.',
  '更新的国际标准 API 接口': 'Interfaces API de Normas Internacionais Actualizadas',
  '可提共全平台 API 接口 (Windows / Linux / Android)': 'Fornece API multiplataforma (Windows / Linux / Android)',
  'J2534 原厂级 ECU 编程功能': 'Programação ECU de Nível OEM com J2534',
  'ECU 软件升级和标定。': 'Actualização e calibração de software ECU.',
  'ECU 更换刷写和编程。': 'Substituição, reprogramação e programação de ECU.',
  'J2534 可控编程电压 (5~20V) 输出。': 'Tensão de programação controlável J2534 (5~20V).',
  '双模式智能远程诊断': 'Diagnóstico Remoto Inteligente de Modo Duplo',
  '支持超级远程和兼容远程双模式远程诊断。': 'Suporta Super Diagnóstico Remoto e Diagnóstico Remoto Compatível.',
  '傲世卡尔 DoNet 远程诊断平台': 'Plataforma de Diagnóstico Remoto ALLScanner DoNet',
  'VCX-FD 是傲世卡尔设计的智能车辆诊断接口，代表着下一代的诊断技术。产品采用全新升级的双核高速处理器，全面支持多通道 CAN-FD / DoIP 和传统诊断协议，并且兼容更多原厂诊断软件。VCX-FD 还支持本地和超级远程双模式诊断，为用户提供卓越的诊断体验。':
    'O VCX-FD é a interface de diagnóstico veicular inteligente da ALLScanner, representando a tecnologia de diagnóstico de próxima geração. Equipado com um novo processador dual-core de alta velocidade, suporta totalmente CAN-FD/DoIP multi-canal e protocolos de diagnóstico tradicionais, com compatibilidade mais ampla com software OEM. O VCX-FD suporta diagnóstico local e super remoto de modo duplo.',
  // FAQ translations
  'VX Manager 启动报错 ErrorCode = 1450': 'Erro de Arranque do VX Manager — ErrorCode = 1450',
  '问题描述：': 'Descrição do problema:',
  '解决方案': 'Solução',
  '解决方案：': 'Solução:',
  'VX Mananger 安装完成后启动报错："ERROR: Loadlibrary(VCX.dll) ErrorCode = 1450"。': 'Após instalar o VX Manager, ocorre o erro: "ERROR: Loadlibrary(VCX.dll) ErrorCode = 1450".',
  '请卸载并重新安装 VX Manager 软件。': 'Desinstale e reinstale o VX Manager.',
  '设备连接电脑客户端提示没连上': 'O Dispositivo Está Ligado mas o VX Manager Não o Detecta',
  '设备USB连上电脑了 但是客户端VX MANAGER找不到设备，打开网络适配器页面发现有设备连接，而且设备IP正确（192.168.8.': 'O dispositivo USB está ligado ao PC mas o VX Manager não o detecta. Na página do adaptador de rede, o dispositivo está listado com IP correcto (192.168.8.',
  '首先从网络连接看，网卡已经连上设备': 'Passo 1: Verificar que o adaptador de rede detecta o dispositivo',
  '再看设备IP是正确的192.168.8.***（注：设备的网络IP地址选 自动获得IP地址）': 'Passo 2: Confirmar que o IP do dispositivo está correcto (192.168.8.*) — seleccionar "Obter IP automaticamente"',
  '①.把设备连接方式改成USBLAN连接即可。': 'Solução 1: Altere o modo de ligação para USBLAN.',
  '②.如果客户端设置为USBLAN还是没连上设备，请打开计算机设备管理，看看网络适配器里设备网卡驱动是否异常（如图），异常请卸载该网卡后在设备管理内刷新就可以了。':
    'Solução 2: Se ainda não ligar com USBLAN, abra o Gestor de Dispositivos e verifique se o driver da placa de rede tem anomalias (conforme imagem). Se sim, desinstale a placa de rede e actualize no Gestor de Dispositivos.',
  '③.如果网卡，客户端和设备管理都没找到设备，请看电脑的WIFI连接是否有设备的WIFI信号"DOIP-VCI-****",没有的话设备返修。':
    'Solução 3: Se a placa de rede, o cliente e o gestor de dispositivos não detectam o dispositivo, verifique se o WIFI mostra o sinal "DOIP-VCI-****". Se não, o dispositivo precisa de revisão.',
  '奔驰WIS注册不了': 'Mercedes-Benz WIS Não Regista',
  '问题描述：': 'Descrição:',
  'WIS想注册时没有硬件ID': 'Ao tentar registar o WIS, não há Hardware ID.',
  '解决方案：这是WIS已经在别的电脑注册过，或者拷贝硬盘不完整，重拷硬盘。':
    'Solução: O WIS já foi registado noutro PC, ou a cópia do disco está incompleta. Copie novamente o disco.',
  'GM GDS2软件安装后没有授权日期': 'GM GDS2 Sem Data de Licença Após Instalação',
  '问题描述：GM GDS2软件安装后没有授权日期；找不到设备；测不了车。':
    'Descrição: Após instalar o GM GDS2, não há data de licença; o dispositivo não é encontrado; não é possível testar o veículo.',
  '解决方案：请让客户查看他的系统，该软件的破解不支持家庭版本的WINDOWS！':
    'Solução: O software não suporta o Windows Home Edition!',
  '更换系统再安装，另外Tech2win只支持': 'Instale numa versão diferente. O Tech2win apenas suporta',
  '的系统安装使用。': 'para instalação e utilização.',
  'VX客户端OFFLINE': 'VX Manager Client OFFLINE',
  'VX MANAGER客户端OFFLINE连不上网，安装不了驱动刷新不了授权。':
    'O VX Manager está OFFLINE sem acesso à Internet, não consegue instalar drivers nem actualizar licenças.',
};

const COMMON_EN = {
  '产品概述': 'Product Overview',
  '产品特性': 'Product Features',
  '产品规格': 'Product Specifications',
  '技术规格': 'Technical Specifications',
  '主要特性': 'Key Features',
  '支持的原厂诊断软件': 'Supported OEM Diagnostic Software',
  '包装清单': 'Package Contents',
  '产品照片': 'Product Photos',
  '极致性能的车辆诊断接口': 'Ultimate Performance Vehicle Diagnostic Interface',
  '双核架构协同工作，通信性能更强': 'Dual-Core Architecture, Enhanced Communication Performance',
  '550MHz ARM 协议处理器实现 CAN-FD 和所有传统车辆总线协议。': '550 MHz ARM protocol processor for CAN-FD and all traditional vehicle bus protocols.',
  '560MHz MIPS 网络处理器实现 DoIP 超级诊断网关。': '560 MHz MIPS network processor for DoIP hyper diagnostic gateway.',
  '双核处理器通过百兆以太网通信，高带宽、低延迟。': 'Dual-core processors communicate via 100 Mbps ethernet — high bandwidth, low latency.',
  '诊断通信速度比上一代产品提升数倍。': 'Diagnostic communication speed several times faster than the previous generation.',
  '双操作系统并发，软件运行更稳定': 'Dual OS Concurrency, More Stable Software Operation',
  'RTOS 实时操作系统保障车辆总线协议多任务高并发通信。': 'RTOS real-time OS ensures multi-task, high-concurrency vehicle bus communication.',
  'OpenWrt 网络操作系统灵活连接多种网络接口和车辆。': 'OpenWrt network OS enables flexible connection to multiple network interfaces and vehicles.',
  '支持更全的车辆总线协议': 'Comprehensive Vehicle Bus Protocol Support',
  '集成 OBD 智能协议多路器芯片，所有引脚能够智能切换任意协议。': 'Integrated OBD smart protocol multiplexer chip — all pins can intelligently switch to any protocol.',
  '支持 3 路 CAN-FD 多通道并发通信，最高支持 5M Bps 高速通信。': 'Supports 3-channel concurrent CAN-FD communication, up to 5 Mbps.',
  '支持 ISO-13400 标准双路 DoIP 接口 Option 1 和 Option 2。': 'Supports dual ISO-13400 DoIP interfaces Option 1 and Option 2.',
  '灵活易用的连接方式': 'Flexible and Easy Connection Modes',
  '主机通信接口支持 USB / RJ45 / WLAN 等多种连接, 灵活易用。': 'Host communication interface supports USB/RJ45/WLAN and more.',
  '内置无线路由模式，诊断电脑可无线直连设备。': 'Built-in wireless router mode — diagnostic PC connects directly to device wirelessly.',
  '支持无线工作站模式，设备可接入无线局域网，任意电脑都可连接设备。': 'Supports wireless station mode — device joins WLAN, any PC on the network can connect.',
  '支持将车辆 DoIP 以太网映射到 WLAN 实现无线 DoIP 诊断。': 'Supports mapping vehicle DoIP ethernet to WLAN for wireless DoIP diagnosis.',
  '全新的外观设计': 'New Exterior Design',
  '采用集成 OBD-II 接口的一体化设计，方便即插即用。': 'Integrated OBD-II connector design for easy plug-and-play.',
  '加固设计的 Type-C 接口可防止晃动和脱落，连接更可靠。': 'Reinforced Type-C connector prevents wobbling and disconnection.',
  '更强大的车辆诊断设备': 'More Powerful Vehicle Diagnostic Device',
  '更全面的原厂车辆诊断': 'More Comprehensive OEM Vehicle Diagnosis',
  'VCX-FD 现在适配的原厂诊断车型品牌已达 17 种。': 'VCX-FD is now compatible with 17 OEM diagnostic brands.',
  '硬件更新后全面支持基于 CAN-FD 和 DoIP 的新车型和新原厂诊断软件。': 'Updated hardware fully supports new CAN-FD and DoIP vehicle models and OEM software.',
  '各种高级诊断和编程功能达到原厂级别，速度甚至超过原厂设备。': 'Advanced diagnostic and programming functions at OEM level, often faster than OEM tools.',
  '支持一键安装、卸载和升级原厂支持驱动，易于使用。': 'Supports one-click install, uninstall and upgrade of OEM drivers.',
  '更新的国际标准 API 接口': 'Updated International Standard API Interfaces',
  '可提共全平台 API 接口 (Windows / Linux / Android)': 'Provides cross-platform API (Windows / Linux / Android)',
  'J2534 原厂级 ECU 编程功能': 'J2534 OEM-Level ECU Programming',
  'ECU 软件升级和标定。': 'ECU software upgrade and calibration.',
  'ECU 更换刷写和编程。': 'ECU replacement flashing and programming.',
  'J2534 可控编程电压 (5~20V) 输出。': 'J2534 controllable programming voltage (5~20V) output.',
  '双模式智能远程诊断': 'Dual-Mode Smart Remote Diagnosis',
  '支持超级远程和兼容远程双模式远程诊断。': 'Supports Hyper Remote and Legacy Remote dual-mode remote diagnosis.',
  '傲世卡尔 DoNet 远程诊断平台': 'ALLScanner DoNet Remote Diagnosis Platform',
  'VCX-FD 是傲世卡尔设计的智能车辆诊断接口，代表着下一代的诊断技术。产品采用全新升级的双核高速处理器，全面支持多通道 CAN-FD / DoIP 和传统诊断协议，并且兼容更多原厂诊断软件。VCX-FD 还支持本地和超级远程双模式诊断，为用户提供卓越的诊断体验。':
    'The VCX-FD is ALLScanner\'s intelligent vehicle diagnostic interface representing next-generation diagnostic technology. With a new dual-core high-speed processor, it fully supports multi-channel CAN-FD/DoIP and traditional diagnostic protocols with broader OEM software compatibility. The VCX-FD also supports local and hyper remote dual-mode diagnosis.',
  // FAQ
  'VX Manager 启动报错 ErrorCode = 1450': 'VX Manager Startup Error — ErrorCode = 1450',
  '问题描述：': 'Problem description:',
  '解决方案': 'Solution',
  '解决方案：': 'Solution:',
  'VX Mananger 安装完成后启动报错："ERROR: Loadlibrary(VCX.dll) ErrorCode = 1450"。': 'After installing VX Manager, an error occurs: "ERROR: Loadlibrary(VCX.dll) ErrorCode = 1450".',
  '请卸载并重新安装 VX Manager 软件。': 'Uninstall and reinstall VX Manager.',
  '设备连接电脑客户端提示没连上': 'Device Connected but VX Manager Does Not Detect It',
  '首先从网络连接看，网卡已经连上设备': 'Step 1: Check that the network adapter detects the device',
  '再看设备IP是正确的192.168.8.***（注：设备的网络IP地址选 自动获得IP地址）': 'Step 2: Confirm device IP is correct (192.168.8.*) — select "Obtain IP automatically"',
  '①.把设备连接方式改成USBLAN连接即可。': 'Fix 1: Change the connection mode to USBLAN.',
  '②.如果客户端设置为USBLAN还是没连上设备，请打开计算机设备管理，看看网络适配器里设备网卡驱动是否异常（如图），异常请卸载该网卡后在设备管理内刷新就可以了。':
    'Fix 2: If USBLAN still doesn\'t work, open Device Manager and check if the network adapter driver shows issues. If yes, uninstall the adapter and refresh in Device Manager.',
  '③.如果网卡，客户端和设备管理都没找到设备，请看电脑的WIFI连接是否有设备的WIFI信号"DOIP-VCI-****",没有的话设备返修。':
    'Fix 3: If network adapter, client and Device Manager all fail to find the device, check if WiFi shows the "DOIP-VCI-****" signal. If not, the device needs service.',
  '奔驰WIS注册不了': 'Mercedes-Benz WIS Registration Fails',
  'WIS想注册时没有硬件ID': 'When trying to register WIS, there is no Hardware ID.',
  '解决方案：这是WIS已经在别的电脑注册过，或者拷贝硬盘不完整，重拷硬盘。':
    'Solution: WIS was already registered on another PC, or the hard drive copy is incomplete. Re-copy the drive.',
  'GM GDS2软件安装后没有授权日期': 'GM GDS2 No License Date After Installation',
  '问题描述：GM GDS2软件安装后没有授权日期；找不到设备；测不了车。':
    'Problem: After installing GM GDS2, no license date; device not found; cannot test vehicle.',
  '解决方案：请让客户查看他的系统，该软件的破解不支持家庭版本的WINDOWS！':
    'Solution: The software does not support Windows Home Edition!',
  '更换系统再安装，另外Tech2win只支持': 'Install on a different edition. Tech2win only supports',
  '的系统安装使用。': 'for installation.',
  'VX客户端OFFLINE': 'VX Manager Client OFFLINE',
  'VX MANAGER客户端OFFLINE连不上网，安装不了驱动刷新不了授权。':
    'VX Manager client is OFFLINE with no internet access, cannot install drivers or update licenses.',
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
        console.log('  Updated: ' + path.relative(base, p));
      }
    }
  }
}

console.log('Translating product/FAQ content in PT...');
processDir(path.join(base, 'pt'), COMMON_PT);
console.log('Translating product/FAQ content in EN...');
processDir(path.join(base, 'en'), COMMON_EN);

// Count remaining
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

console.log('Remaining Chinese PT:', countChinese(path.join(base, 'pt')));
console.log('Remaining Chinese EN:', countChinese(path.join(base, 'en')));
