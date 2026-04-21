# Pass-2 translation: fix remaining Chinese sentences in generated pages
# Runs on all PT and EN HTML files

$base = "D:/Tutorials/m-auto.online/wiki"

# Extended translation maps (sentence level)
$mapPT = @{
  # Welcome/intro
  '欢迎使用傲世卡尔产品，此网站包含最新的设备使用和车辆诊断相关知识。我们致力于让原厂车辆诊断更简单！' = 'Bem-vindo aos produtos ALLScanner. Este site contém os conhecimentos mais recentes sobre utilização dos dispositivos e diagnóstico de veículos. O nosso objectivo é simplificar o diagnóstico veicular OEM!'
  # Home page em descriptions
  '首次使用时如何快速安装软件，连接设备，并立即Iniciar Diagnóstico。' = 'Como instalar rapidamente o software, ligar o dispositivo e iniciar o diagnóstico na primeira utilização.'
  '如何连接设备和配置 WiFi、USB、LAN 等不同连接方式。' = 'Como ligar o dispositivo e configurar WiFi, USB, LAN e outros modos de ligação.'
  '如何升级设备固件，设备固件异常时如何恢复。' = 'Como actualizar o firmware do dispositivo e como recuperar em caso de anomalia.'
  '如何查看、更新和添加设备授权。' = 'Como visualizar, actualizar e adicionar licenças do dispositivo.'
  '如何安装、更新和管理原厂诊断软件驱动程序。' = 'Como instalar, actualizar e gerir os drivers de software de diagnóstico OEM.'
  '总结产品使用过程中常见的疑问和解决方案。' = 'Resumo das dúvidas mais comuns durante a utilização do produto e respectivas soluções.'
  '使用 VCX 系列设备，基于云计算和 5G 通信技术的车辆远程实时诊断平台。' = 'Plataforma de diagnóstico remoto em tempo real para veículos, baseada em computação em nuvem e tecnologia 5G, usando dispositivos da série VCX.'
  '服务端(S)原厂软件直连客户端(C)设备实现远程车辆诊断。' = 'O software OEM do servidor (S) liga-se directamente ao dispositivo do cliente (C) para diagnóstico remoto.'
  '服务端(S)不限设备连接客户端(C)设备进行远程车辆诊断。' = 'O servidor (S) não necessita de dispositivo específico; liga-se ao dispositivo do cliente (C) para diagnóstico remoto.'
  '远程诊断时如 VCX 设备 IP 与路由器 IP 冲突时可修改设备 IP' = 'Se o IP do dispositivo VCX entrar em conflito com o IP do router durante o diagnóstico remoto, pode modificar o IP do dispositivo.'
  '远程诊断编程案例' = 'Casos de Programação por Diagnóstico Remoto'
  '各种远程诊断实车测试案例。' = 'Vários casos de teste em veículos reais com diagnóstico remoto.'
  'Passenger Vehicle' = 'Veículos Ligeiros'
  'Commercial Vehicle' = 'Veículos Comerciais'
  'Veículos Ligeiros原厂诊断指南，包含软件介绍和诊断案例' = 'Guia de diagnóstico OEM para ligeiros, com introdução ao software e casos de diagnóstico'
  # Firmware page
  '固件更新' = 'Actualização de Firmware'
  'VCX 设备通过更新固件来不断优化设备和新增功能，请保持设备固件始终为最新！' = 'Os dispositivos VCX são continuamente optimizados e recebem novas funcionalidades através de actualizações de firmware. Mantenha o firmware sempre actualizado!'
  '连接设备' = 'Ligar o Dispositivo'
  '固件升级时推荐使用有线连接方式：USB 或 LAN，请参照' = 'Para a actualização de firmware recomenda-se ligação com fio: USB ou LAN. Consulte'
  '连接设备和电脑。' = 'para ligar o dispositivo ao computador.'
  'USB 连接示意图：' = 'Diagrama de ligação USB:'
  '在无法连接车辆的情况下，设备可通过 USB 连接供电。' = 'Quando não for possível ligar ao veículo, o dispositivo pode ser alimentado via USB.'
  '部分电脑 USB 接口输出的电源功率可能不足，导致 VCX 设备无法稳定连接，此时必须通过 OBD 接口供电。' = 'Algumas portas USB de computadores podem não fornecer potência suficiente, causando instabilidade. Nesse caso, é necessário alimentar o dispositivo pela porta OBD.'
  '查看固件版本' = 'Verificar Versão de Firmware'
  '启动 VX Manager 管理软件，' = 'Inicie o VX Manager.'
  '中显示当前固件版本，如果服务器包含新固件，则' = 'mostra a versão actual do firmware. Se o servidor contiver novo firmware,'
  '按钮右侧会显示' = 'mostrará'
  '标记，并且自动弹出更新固件对话框。' = 'e aparecerá automaticamente a caixa de diálogo de actualização.'
  '更新固件过程' = 'Processo de Actualização de Firmware'
  '在更新固件对话框中勾选需要更新的固件，单击' = 'Na caixa de diálogo, seleccione o firmware a actualizar e clique em'
  '此过程将持续数分钟，更新过程中请不要中断设备与电脑的连接。' = 'O processo demora alguns minutos. Não interrompa a ligação entre o dispositivo e o computador durante a actualização.'
  '更新完成' = 'Actualização Concluída'
  '更新完成关闭更新对话框后，VX Manager' = 'Após fechar a caixa de diálogo de actualização, o VX Manager'
  '中会显示更新后的固件版本。' = 'mostrará a versão de firmware actualizada.'
  'DoIP 固件恢复' = 'Recuperação de Firmware DoIP'
  '对于因异常原因造成的 DoIP 系统启动失败，可以尝试恢复 DoIP 固件。' = 'Para falhas de arranque do sistema DoIP causadas por anomalias, pode tentar recuperar o firmware DoIP.'
  '此过程只适用 VCX-DoIP 和 VCX-SE 等包含 DoIP 系统的设备。' = 'Este processo aplica-se apenas a dispositivos com sistema DoIP, como VCX-DoIP e VCX-SE.'
  '判断 DOIP 系统异常的条件：' = 'Critérios para detectar anomalia no sistema DoIP:'
  '设备启动25秒后，没有听到第二次蜂鸣器 "哔哔" 声。' = 'Após 25 segundos do arranque, não se ouve o segundo sinal sonoro "bip-bip".'
  '设备启动25秒后，无线 LED 指示灯没有亮或闪烁。' = 'Após 25 segundos do arranque, o LED da rede sem fios não acende nem pisca.'
  '设备启动25秒后，搜索无线网络找不到设备:' = 'Após 25 segundos do arranque, a rede sem fios do dispositivo não é encontrada:'
  '设备启动25秒后，VX Manager 无法连接和读取到设备信息。' = 'Após 25 segundos do arranque, o VX Manager não consegue ligar nem ler as informações do dispositivo.'
  '进入固件恢复模式' = 'Entrar no Modo de Recuperação de Firmware'
  '设备断开所有连接（不通电），按照以下步骤进入固件恢复模式：' = 'Desconecte o dispositivo de todas as ligações (sem alimentação) e siga os passos abaixo para entrar no modo de recuperação:'
  # DoNet intro
  '远程诊断介绍' = 'Introdução ao Diagnóstico Remoto'
  'DoNet 远程诊断，是基于云计算和5G通信技术的车辆远程实时诊断平台。用户使用 VCX 诊断设备，通过 DoNet 微信公众号平台，即可实现故障车辆(客户端 C) 与维修企业或技术专家(服务端 S)的互联互通。' = 'O DoNet é uma plataforma de diagnóstico remoto em tempo real para veículos, baseada em computação em nuvem e tecnologia 5G. Usando dispositivos VCX e a plataforma WeChat DoNet, os veículos avariados (cliente C) ligam-se a empresas de manutenção ou especialistas técnicos (servidor S).'
  '通过此平台，汽修店等终端客户，在缺乏维修技术或诊断设备受限等情况下，可寻求远程技术专家的协助，解决汽修疑难问题。而维修企业和技术专家可发挥自身技术和诊断设备优势，跨越地域限制，向全行业客户提供诊断、编码和编程等服务，开拓新的创收平台。' = 'Através desta plataforma, oficinas e outros clientes finais podem pedir assistência remota a especialistas quando lhes faltam competências técnicas ou equipamentos de diagnóstico. As empresas de manutenção e especialistas podem, por sua vez, oferecer serviços de diagnóstico, codificação e programação a qualquer cliente, independentemente da localização geográfica.'
  '远程诊断组成' = 'Componentes do Diagnóstico Remoto'
  '客户端和服务端' = 'Cliente e Servidor'
  '客户端(C端)是需要对故障车辆寻求远程诊断服务的需求方。' = 'O cliente (C) é a parte que necessita de diagnóstico remoto para um veículo avariado.'
  '服务端(S端)是为客户故障车辆提供远程诊断服务的提供方。' = 'O servidor (S) é a parte que fornece o serviço de diagnóstico remoto para o veículo do cliente.'
  'VCX-SE 远程诊断设备' = 'Dispositivo VCX-SE para Diagnóstico Remoto'
  'VCX-SE 是傲世卡尔为远程诊断平台推出的最新一代诊断设备。' = 'O VCX-SE é o dispositivo de diagnóstico de última geração da ALLScanner para a plataforma de diagnóstico remoto.'
  '超高集成度的硬件设计，搭载多路 KWP / CAN / DoIP 等车辆总线协议，支持 WiFi / USB / LAN 等多种通信接口，成熟稳定的 J2534 / PDU 驱动可全面适配各种原厂诊断，不仅支持本地诊断，还可一键配网快速接入远程诊断平台。' = 'Design de hardware de alta integração com suporte para múltiplos protocolos de barramento veicular KWP/CAN/DoIP e interfaces de comunicação WiFi/USB/LAN. Drivers J2534/PDU maduros e estáveis, compatíveis com todos os diagnósticos OEM. Suporta diagnóstico local e ligação rápida à plataforma remota com um clique.'
  '服务端（S端）和客户端（C端）可使用相同的 VCX-SE 远程诊断设备，同时现有的 VCX-DoIP 等设备也可支持开通远程诊断功能。' = 'O servidor (S) e o cliente (C) podem utilizar o mesmo dispositivo VCX-SE. Os dispositivos VCX-DoIP existentes também podem ser activados para diagnóstico remoto.'
  'DoNet 远程诊断微信公众号' = 'Canal WeChat DoNet'
  'DoNet 微信公众号 (DiagnosisOnNet) 是傲世卡尔为广大汽修企业,专家及客户开设的远程诊断在线服务平台。用户关注公众号后，可绑定 VCX 设备并配置联网，查看设备在线状态，C端用户可发布车辆诊断需求，S端用户可发现远程服务需求，承接远程诊断服务等。' = 'O canal WeChat DoNet (DiagnosisOnNet) é uma plataforma de serviço de diagnóstico remoto online da ALLScanner para oficinas, especialistas e clientes. Após seguir o canal, pode associar o dispositivo VCX, configurar a rede, verificar o estado do dispositivo; os clientes (C) podem publicar necessidades de diagnóstico e os servidores (S) podem aceitar pedidos de diagnóstico remoto.'
  '双模式远程诊断' = 'Diagnóstico Remoto de Modo Duplo'
  'DoNet 开创性的支持双模式远程诊断功能：超级远程诊断和兼容远程诊断。' = 'O DoNet suporta de forma inovadora dois modos de diagnóstico remoto: Super Diagnóstico Remoto e Diagnóstico Remoto Compatível.'
  '超级远程诊断' = 'Super Diagnóstico Remoto'
  '超级模式只需要单客户端 VCX 设备即可实现多品牌原厂软件直连远程车辆诊断。' = 'O modo Super apenas requer um dispositivo VCX no cliente (C) para diagnóstico remoto multi-marca com software OEM directo.'
  '客户端 (C端) 连接 VCX 设备到故障车辆，并通过公众号平台配置联网。' = 'O cliente (C) liga o dispositivo VCX ao veículo avariado e configura a rede através do canal WeChat.'
  '服务端 (S端) 无需设备，使用原厂软件电脑，连接远程设备，加载远程 PDU/J2534 驱动即可直连远程车辆，向客户提供原厂诊断、编码及编程等服务。' = 'O servidor (S) não necessita de dispositivo. Com o PC com software OEM, conecta ao dispositivo remoto, carrega os drivers PDU/J2534 remotos e acede directamente ao veículo remoto para diagnóstico, codificação e programação OEM.'
  '超级远程诊断特性' = 'Características do Super Diagnóstico Remoto'
  '支持超级远程诊断的车型包括奔驰，宝马，保时捷，大众，奥迪，路虎，通用，福特，丰田，本田，斯巴鲁，沃尔沃等近20款。' = 'Suporta cerca de 20 marcas, incluindo Mercedes-Benz, BMW, Porsche, VW, Audi, Land Rover, GM, Ford, Toyota, Honda, Subaru, Volvo, entre outras.'
  '原厂诊断软件功能深度支持，远程诊断可实现功能与本地一致。' = 'Suporte profundo das funcionalidades do software OEM — o diagnóstico remoto oferece as mesmas capacidades que o diagnóstico local.'
  '支持 DoIP 协议远程诊断，车辆以太网直接映射到服务端。' = 'Suporta diagnóstico remoto via protocolo DoIP, com ethernet do veículo mapeada directamente para o servidor.'
  '只需服务端拥有账号、证书等资源，即可对任意客户端远程在线编码和编程。' = 'O servidor apenas necessita de conta e certificados para realizar codificação e programação remota em qualquer cliente.'
  '兼容远程诊断' = 'Diagnóstico Remoto Compatível'
  '兼容模式双端各使用 1 个 VCX 设备可实现任意品牌设备远程诊断。' = 'O modo Compatível utiliza 1 dispositivo VCX em cada lado (servidor e cliente) para diagnóstico remoto com qualquer marca.'
  '客户端&nbsp;(C端)&nbsp;连接 VCX&nbsp;设备到故障车辆，并通过公众号平台配置联网并发起诊断服务请求。' = 'O cliente (C) liga o dispositivo VCX ao veículo avariado, configura a rede e envia o pedido de diagnóstico através do canal WeChat.'
  '服务端 (S端) 连接 VCX 设备通过 OBD 公母转接头供电，并通过公众号平台配置联网。服务端使用原厂或第三方任意设备连接 OBD 即可提供远程诊断服务。' = 'O servidor (S) alimenta o dispositivo VCX via adaptador OBD macho-fêmea e configura a rede. O servidor pode usar qualquer dispositivo OEM ou de terceiros ligado ao OBD para fornecer o serviço de diagnóstico remoto.'
  '兼容远程诊断特性' = 'Características do Diagnóstico Remoto Compatível'
  '服务端可用诊断设备不限，包括原厂设备、通用型诊断仪、防盗专用工具、胎压专用工具、改装专用工具等。' = 'O servidor pode usar qualquer dispositivo de diagnóstico: equipamento OEM, scanner genérico, ferramentas anti-roubo, TPMS, tuning, etc.'
  '兼容远程诊断目前支持 CAN 和 DoIP 两种诊断协议。' = 'O diagnóstico remoto compatível suporta actualmente os protocolos CAN e DoIP.'
  '兼容远程诊断支持使用 CAN 和 DoIP 的所有车型。' = 'Suporta todos os modelos que usam CAN e DoIP.'
  '远程诊断使用指南' = 'Guia de Utilização do Diagnóstico Remoto'
  '如何使用超级远程诊断模式' = 'Como usar o modo de Super Diagnóstico Remoto'
  '如何使用兼容远程诊断模式' = 'Como usar o modo de Diagnóstico Remoto Compatível'
  '远程诊断案例' = 'Casos de Diagnóstico Remoto'
  '开放测试' = 'Testes Abertos'
  '目前 DoNet 超级远程诊断功能已经全面开放， 兼容远程诊断功能也已开放测试，欢迎使用！' = 'Actualmente o Super Diagnóstico Remoto DoNet está totalmente disponível e o Diagnóstico Remoto Compatível também está aberto a testes. Bem-vindo!'
  # Connection page content
  '设备连接' = 'Ligação do Dispositivo'
  'USB 连接' = 'Ligação USB'
  'WiFi 连接' = 'Ligação WiFi'
  'LAN 连接' = 'Ligação LAN'
  '连接方式' = 'Modo de Ligação'
  '无线连接' = 'Ligação sem fios'
  '有线连接' = 'Ligação com fio'
  # General
  '产品介绍' = 'Introdução ao Produto'
  '技术规格' = 'Especificações Técnicas'
  '主要特性' = 'Características Principais'
  '支持车型' = 'Modelos Suportados'
  '包装清单' = 'Lista de Embalagem'
  '注意事项' = 'Atenção'
  '下载' = 'Transferir'
  '安装' = 'Instalar'
  '完成' = 'Concluir'
  '取消' = 'Cancelar'
  '设置' = 'Configurar'
  '返回' = 'Voltar'
  '确认' = 'Confirmar'
  '更多' = 'Mais'
  '版本' = 'Versão'
  '日期' = 'Data'
  '更新内容' = 'Notas de Actualização'
  '修复' = 'Correcção'
  '新增' = 'Novo'
  '优化' = 'Optimização'
  '支持' = 'Suporte'
  '问题' = 'Problema'
  '解决' = 'Solução'
}

$mapEN = @{
  # Welcome/intro
  '欢迎使用傲世卡尔产品，此网站包含最新的设备使用和车辆诊断相关知识。我们致力于让原厂车辆诊断更简单！' = 'Welcome to ALLScanner products. This site contains the latest knowledge on device usage and vehicle diagnostics. Our goal is to make OEM vehicle diagnosis simpler!'
  # Home em descriptions
  '首次使用时如何快速安装软件，连接设备，并立即Iniciar Diagnóstico。' = 'How to quickly install software, connect the device and start diagnosing on first use.'
  '如何连接设备和配置 WiFi、USB、LAN 等不同连接方式。' = 'How to connect the device and configure WiFi, USB, LAN and other connection modes.'
  '如何升级设备固件，设备固件异常时如何恢复。' = 'How to upgrade device firmware and how to recover from firmware issues.'
  '如何查看、更新和添加设备授权。' = 'How to view, update and add device licenses.'
  '如何安装、更新和管理原厂诊断软件驱动程序。' = 'How to install, update and manage OEM diagnostic software drivers.'
  '总结产品使用过程中常见的疑问和解决方案。' = 'Summary of common questions and solutions during product use.'
  '使用 VCX 系列设备，基于云计算和 5G 通信技术的车辆远程实时诊断平台。' = 'Real-time remote vehicle diagnosis platform based on cloud computing and 5G, using VCX series devices.'
  '服务端(S)原厂软件直连客户端(C)设备实现远程车辆诊断。' = 'Server (S) OEM software connects directly to client (C) device for remote vehicle diagnosis.'
  '服务端(S)不限设备连接客户端(C)设备进行远程车辆诊断。' = 'Server (S) can use any device to connect to client (C) device for remote vehicle diagnosis.'
  '远程诊断时如 VCX 设备 IP 与路由器 IP 冲突时可修改设备 IP' = 'If the VCX device IP conflicts with the router IP during remote diagnosis, the device IP can be changed.'
  '远程诊断编程案例' = 'Remote Diagnosis Programming Cases'
  '各种远程诊断实车测试案例。' = 'Various real vehicle remote diagnosis test cases.'
  # DoNet
  '远程诊断介绍' = 'Remote Diagnosis Introduction'
  'DoNet 远程诊断，是基于云计算和5G通信技术的车辆远程实时诊断平台。用户使用 VCX 诊断设备，通过 DoNet 微信公众号平台，即可实现故障车辆(客户端 C) 与维修企业或技术专家(服务端 S)的互联互通。' = 'DoNet is a real-time remote vehicle diagnosis platform based on cloud computing and 5G technology. Using VCX diagnostic devices and the DoNet WeChat platform, faulty vehicles (client C) connect with repair companies or technical experts (server S).'
  '通过此平台，汽修店等终端客户，在缺乏维修技术或诊断设备受限等情况下，可寻求远程技术专家的协助，解决汽修疑难问题。而维修企业和技术专家可发挥自身技术和诊断设备优势，跨越地域限制，向全行业客户提供诊断、编码和编程等服务，开拓新的创收平台。' = 'Through this platform, workshops and end-customers lacking technical expertise or diagnostic equipment can seek remote expert assistance. Repair companies and experts can leverage their skills and equipment to offer diagnosis, coding and programming services to customers anywhere, creating new revenue opportunities.'
  '远程诊断组成' = 'Remote Diagnosis Components'
  '客户端和服务端' = 'Client and Server'
  '客户端(C端)是需要对故障车辆寻求远程诊断服务的需求方。' = 'The client (C) is the party seeking remote diagnosis service for a faulty vehicle.'
  '服务端(S端)是为客户故障车辆提供远程诊断服务的提供方。' = 'The server (S) is the party providing remote diagnosis service for the client vehicle.'
  'VCX-SE 远程诊断设备' = 'VCX-SE Remote Diagnosis Device'
  'VCX-SE 是傲世卡尔为远程诊断平台推出的最新一代诊断设备。' = 'The VCX-SE is ALLScanner''s latest generation diagnostic device for the remote diagnosis platform.'
  '超高集成度的硬件设计，搭载多路 KWP / CAN / DoIP 等车辆总线协议，支持 WiFi / USB / LAN 等多种通信接口，成熟稳定的 J2534 / PDU 驱动可全面适配各种原厂诊断，不仅支持本地诊断，还可一键配网快速接入远程诊断平台。' = 'Highly integrated hardware design supporting multiple vehicle bus protocols (KWP/CAN/DoIP) and communication interfaces (WiFi/USB/LAN). Mature J2534/PDU drivers fully compatible with all OEM diagnostics. Supports local diagnosis and one-click quick access to the remote platform.'
  '服务端（S端）和客户端（C端）可使用相同的 VCX-SE 远程诊断设备，同时现有的 VCX-DoIP 等设备也可支持开通远程诊断功能。' = 'Both server (S) and client (C) can use the same VCX-SE device. Existing VCX-DoIP devices can also be activated for remote diagnosis.'
  'DoNet 远程诊断微信公众号' = 'DoNet WeChat Channel'
  'DoNet 微信公众号 (DiagnosisOnNet) 是傲世卡尔为广大汽修企业,专家及客户开设的远程诊断在线服务平台。用户关注公众号后，可绑定 VCX 设备并配置联网，查看设备在线状态，C端用户可发布车辆诊断需求，S端用户可发现远程服务需求，承接远程诊断服务等。' = 'The DoNet WeChat channel (DiagnosisOnNet) is an online remote diagnosis service platform by ALLScanner for workshops, experts and customers. After following the channel, users can bind VCX devices, configure networking, check device status; client (C) users can post diagnosis requests and server (S) users can find and accept remote service requests.'
  '双模式远程诊断' = 'Dual-Mode Remote Diagnosis'
  'DoNet 开创性的支持双模式远程诊断功能：超级远程诊断和兼容远程诊断。' = 'DoNet innovatively supports two remote diagnosis modes: Hyper Remote Diagnosis and Legacy Remote Diagnosis.'
  '超级远程诊断' = 'Hyper Remote Diagnosis'
  '超级模式只需要单客户端 VCX 设备即可实现多品牌原厂软件直连远程车辆诊断。' = 'Hyper mode only requires a single client VCX device to achieve multi-brand OEM software direct-connect remote vehicle diagnosis.'
  '客户端 (C端) 连接 VCX 设备到故障车辆，并通过公众号平台配置联网。' = 'The client (C) connects the VCX device to the faulty vehicle and configures networking via the WeChat channel.'
  '服务端 (S端) 无需设备，使用原厂软件电脑，连接远程设备，加载远程 PDU/J2534 驱动即可直连远程车辆，向客户提供原厂诊断、编码及编程等服务。' = 'The server (S) needs no device. Using a PC with OEM software, connect to the remote device, load remote PDU/J2534 drivers to directly access the remote vehicle for OEM diagnosis, coding and programming.'
  '超级远程诊断特性' = 'Hyper Remote Diagnosis Features'
  '支持超级远程诊断的车型包括奔驰，宝马，保时捷，大众，奥迪，路虎，通用，福特，丰田，本田，斯巴鲁，沃尔沃等近20款。' = 'Supports approximately 20 brands including Mercedes-Benz, BMW, Porsche, VW, Audi, Land Rover, GM, Ford, Toyota, Honda, Subaru, Volvo and more.'
  '原厂诊断软件功能深度支持，远程诊断可实现功能与本地一致。' = 'Deep OEM software feature support — remote diagnosis capabilities match local diagnosis.'
  '支持 DoIP 协议远程诊断，车辆以太网直接映射到服务端。' = 'Supports DoIP protocol remote diagnosis with vehicle ethernet directly mapped to the server.'
  '只需服务端拥有账号、证书等资源，即可对任意客户端远程在线编码和编程。' = 'Server only needs account and certificate resources to remotely perform online coding and programming for any client.'
  '兼容远程诊断' = 'Legacy Remote Diagnosis'
  '兼容模式双端各使用 1 个 VCX 设备可实现任意品牌设备远程诊断。' = 'Legacy mode uses 1 VCX device on each side (server and client) to enable remote diagnosis with any brand device.'
  '客户端&nbsp;(C端)&nbsp;连接 VCX&nbsp;设备到故障车辆，并通过公众号平台配置联网并发起诊断服务请求。' = 'The client (C) connects the VCX device to the faulty vehicle, configures networking and initiates a diagnosis service request via the WeChat channel.'
  '服务端 (S端) 连接 VCX 设备通过 OBD 公母转接头供电，并通过公众号平台配置联网。服务端使用原厂或第三方任意设备连接 OBD 即可提供远程诊断服务。' = 'The server (S) powers the VCX device via an OBD male-female adapter and configures networking via WeChat. The server can use any OEM or third-party device connected via OBD to provide remote diagnosis.'
  '兼容远程诊断特性' = 'Legacy Remote Diagnosis Features'
  '服务端可用诊断设备不限，包括原厂设备、通用型诊断仪、防盗专用工具、胎压专用工具、改装专用工具等。' = 'Server can use any diagnostic device: OEM tools, generic scanners, immobiliser tools, TPMS tools, tuning tools, etc.'
  '兼容远程诊断目前支持 CAN 和 DoIP 两种诊断协议。' = 'Legacy remote diagnosis currently supports CAN and DoIP protocols.'
  '兼容远程诊断支持使用 CAN 和 DoIP 的所有车型。' = 'Supports all vehicles using CAN and DoIP.'
  '远程诊断使用指南' = 'Remote Diagnosis User Guide'
  '如何使用超级远程诊断模式' = 'How to use Hyper Remote Diagnosis mode'
  '如何使用兼容远程诊断模式' = 'How to use Legacy Remote Diagnosis mode'
  '远程诊断案例' = 'Remote Diagnosis Cases'
  '开放测试' = 'Open Beta'
  '目前 DoNet 超级远程诊断功能已经全面开放， 兼容远程诊断功能也已开放测试，欢迎使用！' = 'DoNet Hyper Remote Diagnosis is now fully available, and Legacy Remote Diagnosis is open for beta testing. Welcome to try it!'
  # Firmware
  '固件更新' = 'Firmware Update'
  'VCX 设备通过更新固件来不断优化设备和新增功能，请保持设备固件始终为最新！' = 'VCX devices are continuously optimised and receive new features through firmware updates. Always keep firmware up to date!'
  '连接设备' = 'Connect Device'
  '固件升级时推荐使用有线连接方式：USB 或 LAN，请参照' = 'For firmware updates, wired connection (USB or LAN) is recommended. See'
  '连接设备和电脑。' = 'to connect the device to the PC.'
  'USB 连接示意图：' = 'USB connection diagram:'
  '在无法连接车辆的情况下，设备可通过 USB 连接供电。' = 'When unable to connect to a vehicle, the device can be powered via USB.'
  '部分电脑 USB 接口输出的电源功率可能不足，导致 VCX 设备无法稳定连接，此时必须通过 OBD 接口供电。' = 'Some PC USB ports may not provide sufficient power, causing unstable VCX connection. In that case, power must be supplied via the OBD port.'
  '查看固件版本' = 'Check Firmware Version'
  '启动 VX Manager 管理软件，' = 'Launch VX Manager.'
  '中显示当前固件版本，如果服务器包含新固件，则' = 'shows the current firmware version. If the server has new firmware available,'
  '按钮右侧会显示' = 'will show'
  '标记，并且自动弹出更新固件对话框。' = 'and the firmware update dialog will automatically appear.'
  '更新固件过程' = 'Firmware Update Process'
  '在更新固件对话框中勾选需要更新的固件，单击' = 'In the update dialog, select the firmware to update and click'
  '此过程将持续数分钟，更新过程中请不要中断设备与电脑的连接。' = 'This process takes a few minutes. Do not disconnect the device from the PC during the update.'
  '更新完成' = 'Update Complete'
  '更新完成关闭更新对话框后，VX Manager' = 'After closing the update dialog, VX Manager'
  '中会显示更新后的固件版本。' = 'will show the updated firmware version.'
  'DoIP 固件恢复' = 'DoIP Firmware Recovery'
  '对于因异常原因造成的 DoIP 系统启动失败，可以尝试恢复 DoIP 固件。' = 'For DoIP system boot failures caused by abnormal conditions, try recovering the DoIP firmware.'
  '此过程只适用 VCX-DoIP 和 VCX-SE 等包含 DoIP 系统的设备。' = 'This procedure only applies to devices with a DoIP system, such as VCX-DoIP and VCX-SE.'
  '判断 DOIP 系统异常的条件：' = 'Criteria for detecting DoIP system abnormality:'
  '设备启动25秒后，没有听到第二次蜂鸣器 "哔哔" 声。' = 'After 25 seconds from startup, no second "beep-beep" sound is heard.'
  '设备启动25秒后，无线 LED 指示灯没有亮或闪烁。' = 'After 25 seconds from startup, the wireless LED does not light or flash.'
  '设备启动25秒后，搜索无线网络找不到设备:' = 'After 25 seconds from startup, the device wireless network is not found:'
  '设备启动25秒后，VX Manager 无法连接和读取到设备信息。' = 'After 25 seconds from startup, VX Manager cannot connect or read device information.'
  '进入固件恢复模式' = 'Enter Firmware Recovery Mode'
  '设备断开所有连接（不通电），按照以下步骤进入固件恢复模式：' = 'Disconnect all connections from the device (no power) and follow these steps to enter firmware recovery mode:'
  # General terms
  '产品介绍' = 'Product Introduction'
  '技术规格' = 'Technical Specifications'
  '主要特性' = 'Key Features'
  '支持车型' = 'Supported Vehicles'
  '包装清单' = 'Package Contents'
  '注意事项' = 'Notes'
  '下载' = 'Download'
  '安装' = 'Install'
  '完成' = 'Complete'
  '取消' = 'Cancel'
  '设置' = 'Settings'
  '返回' = 'Back'
  '确认' = 'Confirm'
  '更多' = 'More'
  '版本' = 'Version'
  '日期' = 'Date'
  '更新内容' = 'Update Notes'
  '修复' = 'Fix'
  '新增' = 'New'
  '优化' = 'Optimization'
  '支持' = 'Support'
  '问题' = 'Issue'
  '解决' = 'Solution'
}

Write-Host "Running pass-2 translations..."

# Process PT files
Get-ChildItem "$base/pt" -Recurse -Filter "*.html" | ForEach-Object {
  $file = $_.FullName
  $content = Get-Content $file -Raw -Encoding UTF8
  $changed = $false
  foreach ($key in $mapPT.Keys) {
    if ($content.Contains($key)) {
      $content = $content.Replace($key, $mapPT[$key])
      $changed = $true
    }
  }
  if ($changed) {
    Set-Content $file $content -Encoding UTF8
    Write-Host "  Updated PT: $($_.Name)"
  }
}

# Process EN files
Get-ChildItem "$base/en" -Recurse -Filter "*.html" | ForEach-Object {
  $file = $_.FullName
  $content = Get-Content $file -Raw -Encoding UTF8
  $changed = $false
  foreach ($key in $mapEN.Keys) {
    if ($content.Contains($key)) {
      $content = $content.Replace($key, $mapEN[$key])
      $changed = $true
    }
  }
  if ($changed) {
    Set-Content $file $content -Encoding UTF8
    Write-Host "  Updated EN: $($_.Name)"
  }
}

Write-Host "Pass-2 complete."
