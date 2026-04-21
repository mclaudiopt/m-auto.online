#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Bulk fix script for vci-help HTML files:
1. Text branding replacements (VCX -> M-Auto VCI, ALLScanner -> M-Auto, etc.)
2. Chinese text translation (PT and EN files)
3. Image src paths: http://wiki.allscanner.com/ -> local assets/images/
4. Footer replacement
5. Title / h1 branding
"""

import os, re, sys, urllib.request, urllib.error
from pathlib import Path

BASE = Path('D:/Tutorials/m-auto.online/vci-help')
ASSETS_IMG = BASE / 'assets' / 'images'
ASSETS_IMG.mkdir(parents=True, exist_ok=True)

# ─── Chinese translation maps ─────────────────────────────────────────────────
# Maps Chinese string -> (PT translation, EN translation)
ZH = {
    # Product / UI navigation
    '欢迎使用':         ('Bem-vindo',                          'Welcome'),
    '产品信息':         ('Informações do Produto',             'Product Information'),
    '产品使用指南':     ('Guia de Utilização',                 'User Guide'),
    '设备连接配置':     ('Configuração de Ligação',            'Connection Setup'),
    '设备固件更新':     ('Atualização de Firmware',            'Firmware Update'),
    '设备授权管理':     ('Gestão de Licenças',                 'License Management'),
    '诊断驱动管理':     ('Gestão de Drivers de Diagnóstico',   'Diagnostic Driver Management'),
    '常见问题解答':     ('Perguntas Frequentes',               'FAQ'),
    '快速开始指南':     ('Guia de Início Rápido',              'Quick Start Guide'),
    '首页':             ('Início',                             'Home'),
    '产品总览':         ('Visão Geral dos Produtos',           'Product Overview'),
    '产品更新发布':     ('Notas de Versão',                    'Release Notes'),
    '远程诊断':         ('Diagnóstico Remoto',                 'Remote Diagnosis'),
    '乘用车原厂诊断':   ('Diagnóstico OEM Veículos Ligeiros',  'OEM Passenger Vehicle Diagnosis'),
    '商用车原厂诊断':   ('Diagnóstico OEM Veículos Comerciais','OEM Commercial Vehicle Diagnosis'),
    '开发者指南':       ('Guia do Programador',                'Developer Guide'),
    # Company name
    '傲世卡尔科技':     ('M-Auto',                            'M-Auto'),
    '傲世卡尔':         ('M-Auto',                            'M-Auto'),
    # Common terms
    '优化':             ('Otimização',                        'Optimization'),
    '更新':             ('Atualização',                       'Update'),
    '修正':             ('Correção',                          'Fix'),
    '修复':             ('Correção',                          'Fix'),
    '设备':             ('Dispositivo',                       'Device'),
    '新增':             ('Adicionado',                        'Added'),
    '和':               ('e',                                 'and'),
    '网络':             ('Rede',                              'Network'),
    '协议':             ('Protocolo',                         'Protocol'),
    '车辆':             ('Veículo',                           'Vehicle'),
    '的':               ('',                                  ''),
    '米':               ('m',                                 'm'),
    '软件':             ('Software',                          'Software'),
    '诊断':             ('Diagnóstico',                       'Diagnosis'),
    '转':               ('Converter',                         'Convert'),
    '在':               ('em',                                'in'),
    '描述':             ('Descrição',                         'Description'),
    '更新时间':         ('Data de Atualização',               'Update Date'),
    '解决了小问题':     ('Correcção de pequenos problemas',   'Fixed minor issues'),
    '说明':             ('Nota',                              'Note'),
    '硬件':             ('Hardware',                          'Hardware'),
    '修改':             ('Modificação',                       'Modification'),
    '固件更新':         ('Atualização de Firmware',           'Firmware Update'),
    '固件':             ('Firmware',                          'Firmware'),
    '驱动':             ('Driver',                            'Driver'),
    '适配器':           ('Adaptador',                         'Adapter'),
    '增加':             ('Adicionado',                        'Added'),
    '状态':             ('Estado',                            'Status'),
    '示意':             ('Diagrama',                          'Diagram'),
    '指示灯':           ('LED de Estado',                     'Status LED'),
    '新':               ('Novo',                              'New'),
    '车辆诊断案例':     ('Casos de Diagnóstico',              'Diagnostic Cases'),
    '电缆':             ('Cabo',                              'Cable'),
    '集成更新':         ('Atualização Integrada',             'Integrated Update'),
    '通过':             ('através de',                        'via'),
    '安装':             ('Instalação',                        'Install'),
    '奔驰':             ('Mercedes-Benz',                     'Mercedes-Benz'),
    '宝马':             ('BMW',                               'BMW'),
    '大众':             ('Volkswagen',                        'Volkswagen'),
    '诊断软件介绍和使用指南': ('Guia de Software de Diagnóstico', 'Diagnostic Software Guide'),
    '原厂诊断':         ('Diagnóstico OEM',                   'OEM Diagnosis'),
    '使用':             ('Utilização',                        'Usage'),
    '编程':             ('Programação',                       'Programming'),
    '不':               ('não',                               'not'),
    '双色':             ('Bicolor',                           'Dual-color'),
    '卡车':             ('Camião',                            'Truck'),
    '等':               ('etc.',                              'etc.'),
    '福特':             ('Ford',                              'Ford'),
    '丰田':             ('Toyota',                            'Toyota'),
    '进入':             ('Entrar',                            'Enter'),
    '发动机':           ('Motor',                             'Engine'),
    '例如':             ('Por exemplo',                       'For example'),
    '项目':             ('Projeto',                           'Project'),
    '工作':             ('Funcionamento',                     'Operation'),
    '年':               ('ano',                               'year'),
    '选项':             ('Opção',                             'Option'),
    '后':               ('após',                              'after'),
    '配置设备联网':     ('Configurar Ligação à Internet',     'Configure Device Network'),
    '个':               ('',                                  ''),
    '产品':             ('Produto',                           'Product'),
    '请购买授权正版软件': ('Adquira software licenciado original', 'Please purchase licensed software'),
    '有线':             ('Com fio',                           'Wired'),
    '路':               ('linha',                             'line'),
    '的原厂车辆诊断':   ('Diagnóstico OEM de Veículos',       'OEM Vehicle Diagnosis'),
    '标准':             ('Padrão',                            'Standard'),
    '兼容':             ('Compatível',                        'Compatible'),
    '引脚总线协议覆盖': ('Cobertura de Protocolos de Bus',    'Bus Protocol Coverage'),
    '产品附件':         ('Acessórios',                        'Accessories'),
    '产品图集':         ('Galeria de Imagens',                'Image Gallery'),
    '可选':             ('Opcional',                          'Optional'),
    '部分':             ('Parcial',                           'Partial'),
    '设备型号':         ('Modelo do Dispositivo',             'Device Model'),
    '工程师软件介绍和使用指南': ('Guia do Software de Engenharia', 'Engineering Software Guide'),
    '位':               ('bit',                               'bit'),
    '或':               ('ou',                                'or'),
    '该':               ('Este',                              'This'),
    '菜单':             ('Menu',                              'Menu'),
    '客户端':           ('Cliente',                           'Client'),
    '脚':               ('pino',                              'pin'),
    '特性':             ('Características',                   'Features'),
    '时':               ('quando',                            'when'),
    '系列':             ('Série',                             'Series'),
    '车辆诊断':         ('Diagnóstico de Veículos',           'Vehicle Diagnosis'),
    '授权':             ('Licença',                           'License'),
    '如图':             ('Como mostrado',                     'As shown'),
    '错误':             ('Erro',                              'Error'),
    '推荐使用网线':     ('Recomenda-se cabo de rede',         'Ethernet cable recommended'),
    '宽带路由器':       ('Router de Banda Larga',             'Broadband Router'),
    '首次':             ('Primeira vez',                      'First time'),
    '为':               ('para',                              'for'),
    '了解更多':         ('Saber mais',                        'Learn more'),
    '雷克萨斯':         ('Lexus',                             'Lexus'),
    '塞恩':             ('Scion',                             'Scion'),
    '原厂软件版权属于其所有者': ('Software OEM é propriedade dos respectivos detentores', 'OEM software copyright belongs to respective owners'),
    '功耗':             ('Consumo de Energia',                'Power Consumption'),
    '包装':             ('Embalagem',                         'Packaging'),
    '外壳':             ('Carcaça',                           'Housing'),
    '储存':             ('Armazenamento',                     'Storage'),
    '标准认证':         ('Certificações',                     'Certifications'),
    '红色':             ('Vermelho',                          'Red'),
    '蓝色':             ('Azul',                              'Blue'),
    '包装盒':           ('Caixa',                             'Box'),
    '母转':             ('Fêmea para',                        'Female to'),
    '公':               ('Macho',                             'Male'),
    '带':               ('com',                               'with'),
    '当前':             ('Atual',                             'Current'),
    '稳定性':           ('Estabilidade',                      'Stability'),
    '底层':             ('Nível base',                        'Base layer'),
    '云诊断':           ('Diagnóstico na Nuvem',              'Cloud Diagnosis'),
    '并':               ('e',                                 'and'),
    '诊断案例':         ('Casos de Diagnóstico',              'Diagnostic Cases'),
    '如果':             ('Se',                                 'If'),
    '注意':             ('Atenção',                           'Note'),
    '音响':             ('Sistema de Som',                    'Audio System'),
    '网络测试':         ('Teste de Rede',                     'Network Test'),
    '通讯':             ('Comunicação',                       'Communication'),
    '注':               ('Nota',                              'Note'),
    '方式':             ('Modo',                              'Mode'),
    '刷写':             ('Flash',                             'Flash'),
    '底盘号':           ('Número de Chassi',                  'Chassis Number'),
    '从':               ('de',                                'from'),
    '与':               ('com',                               'with'),
    '信息':             ('Informação',                        'Information'),
    '程序':             ('Programa',                          'Program'),
    '软件介绍':         ('Introdução ao Software',            'Software Introduction'),
    '模式':             ('Modo',                              'Mode'),
    '离线':             ('Offline',                           'Offline'),
    '作业':             ('Operação',                          'Operation'),
    '控制单元':         ('Unidade de Controlo',               'Control Unit'),
    '服务端':           ('Servidor',                          'Server'),
    '设备有稳定快速的联网条件': ('Dispositivo com ligação estável e rápida à internet', 'Device with stable fast internet connection'),
    '设备远程诊断':     ('Diagnóstico Remoto do Dispositivo', 'Device Remote Diagnosis'),
    '设备通过':         ('O dispositivo através de',          'The device via'),
    '网线':             ('Cabo de rede',                      'Network cable'),
    '方式适用产品':     ('Modo aplicável ao produto',         'Mode applicable to product'),
    '设备管理':         ('Gestão de Dispositivos',            'Device Management'),
    '页面':             ('Página',                            'Page'),
    '卸载':             ('Desinstalar',                       'Uninstall'),
    '双':               ('Duplo',                             'Dual'),
    '可多选':           ('Seleção múltipla possível',         'Multiple selection possible'),
    '一个设备':         ('Um dispositivo',                    'One device'),
    '众多原厂车辆诊断': ('Numerosos diagnósticos OEM',        'Numerous OEM vehicle diagnostics'),
    '基于':             ('baseado em',                        'based on'),
    '的原厂级诊断':     ('diagnóstico ao nível OEM',          'OEM-level diagnosis'),
    '与原厂完全一致':   ('totalmente compatível com OEM',     'fully compatible with OEM'),
    '性能甚至超出原厂': ('desempenho que supera o OEM',       'performance exceeding OEM'),
    '一键安装原厂':     ('instalação OEM com um clique',      'one-click OEM installation'),
    '驱动和在线升级':   ('drivers e atualização online',      'drivers and online upgrade'),
    '易于使用':         ('Fácil de usar',                     'Easy to use'),
    '原厂级':           ('Nível OEM',                         'OEM level'),
    '达契亚':           ('Dacia',                             'Dacia'),
    '标志':             ('Peugeot',                           'Peugeot'),
    '雪铁龙':           ('Citroën',                           'Citroën'),
    '工具箱':           ('Caixa de ferramentas',              'Toolbox'),
    '加固型塑胶外壳':   ('Carcaça de plástico reforçado',     'Reinforced plastic housing'),
    '符合欧盟':         ('em conformidade com a UE',          'compliant with EU'),
    '和美国':           ('e EUA',                             'and US'),
    '颜色':             ('Cor',                               'Color'),
    '含义':             ('Significado',                       'Meaning'),
    '设备工作状态':     ('Estado de Funcionamento',           'Operating Status'),
    '网络状态':         ('Estado da Rede',                    'Network Status'),
    '时快速闪烁':       ('piscando rapidamente',              'flashing rapidly'),
    '配网时慢速闪烁':   ('piscando lentamente ao configurar', 'slow flash during setup'),
    '时蓝色闪烁':       ('piscando azul',                     'flashing blue'),
    '用户手册':         ('Manual do Utilizador',              'User Manual'),
    '保修卡':           ('Cartão de Garantia',                'Warranty Card'),
    '远程诊断服务端配件': ('Acessórios do Servidor de Diagnóstico Remoto', 'Remote Diagnosis Server Accessories'),
    '软件包':           ('Pacote de Software',                'Software Package'),
    '优化远程诊断':     ('Diagnóstico Remoto Otimizado',      'Optimized Remote Diagnosis'),
    '系统':             ('Sistema',                           'System'),
    '或者':             ('ou',                                'or'),
    '我的应用':         ('As Minhas Aplicações',              'My Applications'),
    '项目示例':         ('Exemplos de Projeto',               'Project Examples'),
    '命令行测试程序':   ('Programa de Teste de Linha de Comandos', 'Command Line Test Program'),
    '图形测试工具':     ('Ferramenta de Teste Gráfico',       'Graphical Test Tool'),
    '开发示例代码':     ('Código de Exemplo para Desenvolvimento', 'Development Sample Code'),
    '路虎':             ('Land Rover',                        'Land Rover'),
    '解决':             ('Solução',                           'Solution'),
    '介绍和使用指南':   ('Guia de Introdução e Utilização',   'Introduction and Usage Guide'),
    '转向角传感器零位设定方法': ('Método de calibração do sensor de ângulo de direção', 'Steering angle sensor zero calibration method'),
    '圈':               ('volta',                             'turn'),
    '不要':             ('Não',                               'Do not'),
    '点火开关':         ('Interruptor de ignição',            'Ignition switch'),
    '对':               ('para',                              'for'),
    '执行':             ('Executar',                          'Execute'),
    '本文介绍奔驰':     ('Este artigo apresenta o Mercedes-Benz', 'This article introduces Mercedes-Benz'),
    '诊断软件':         ('Software de Diagnóstico',           'Diagnostic Software'),
    '离线编程':         ('Programação Offline',               'Offline Programming'),
    '文件':             ('Ficheiro',                          'File'),
    '用了离线补丁':     ('utilizando patch offline',          'using offline patch'),
    '软件就只能做离线编程': ('o software apenas faz programação offline', 'software can only do offline programming'),
    '原厂诊断资源':     ('Recursos de Diagnóstico OEM',       'OEM Diagnosis Resources'),
    '和底盘列表':       ('e lista de chassis',                'and chassis list'),
    '插头':             ('Conector',                          'Connector'),
    '级别':             ('Nível',                             'Level'),
    '本文介绍傲世卡尔科技': ('Este artigo apresenta a M-Auto', 'This article introduces M-Auto'),
    '诊断设备使用':     ('utilização do dispositivo de diagnóstico', 'diagnostic device usage'),
    '梅赛德斯':         ('Mercedes',                          'Mercedes'),
    '到':               ('para',                              'to'),
    '将':               ('converter',                        'convert'),
    '入门':             ('Introdução',                        'Introduction'),
    '中的':             ('em',                                'in'),
    '信息来源':         ('Fonte de Informação',               'Information Source'),
    '迈巴赫':           ('Maybach',                           'Maybach'),
    '同时':             ('ao mesmo tempo',                    'simultaneously'),
    '且':               ('e',                                 'and'),
    '一致':             ('consistente',                       'consistent'),
    '软件截图':         ('Captura de ecrã do software',       'Software screenshot'),
    '设备已经':         ('O dispositivo já',                  'The device already'),
    '管理工具':         ('Ferramenta de Gestão',              'Management Tool'),
    '不可用':           ('indisponível',                      'unavailable'),
    '是':               ('é',                                 'is'),
    '用于':             ('para',                              'for'),
    '禁用安全带状态显示': ('Desativar exibição do estado do cinto de segurança', 'Disable seatbelt status display'),
    '乘客座椅':         ('Assento do passageiro',             'Passenger seat'),
    '禁用安全带提醒':   ('Desativar aviso de cinto de segurança', 'Disable seatbelt reminder'),
    '本文以':           ('Este artigo usa',                   'This article uses'),
    '方法':             ('Método',                            'Method'),
    '然后':             ('de seguida',                        'then'),
    '数据':             ('Dados',                             'Data'),
    '工程师软件':       ('Software de Engenharia',            'Engineering Software'),
    '根据':             ('com base em',                       'based on'),
    '如':               ('como',                              'as'),
    '测试':             ('Teste',                             'Test'),
    '解决办法':         ('Solução',                           'Solution'),
    '指南':             ('Guia',                              'Guide'),
    '新款':             ('Novo modelo',                       'New model'),
    '只能使用':         ('apenas pode usar',                  'can only use'),
    '软件进行诊断':     ('software para diagnóstico',         'software for diagnosis'),
    '或更新':           ('ou atualizar',                      'or update'),
    '标定':             ('Calibração',                        'Calibration'),
    '强排名第':         ('classificado em',                   'ranked'),
    '必要需求':         ('Requisitos necessários',            'Necessary requirements'),
    '车辆使用稳定的':   ('O veículo utiliza uma rede estável', 'Vehicle uses stable network'),
    '关注公众号':       ('Siga no WeChat',                    'Follow on WeChat'),
    '扫描二维码或微信': ('Digitalize o código QR ou WeChat',  'Scan QR code or WeChat'),
    '平台':             ('Plataforma',                        'Platform'),
    '并关注':           ('e siga',                            'and follow'),
    '远程诊断平台':     ('Plataforma de Diagnóstico Remoto',  'Remote Diagnosis Platform'),
    '公众号菜单中':     ('no menu do WeChat',                 'in WeChat menu'),
    '智能诊断':         ('Diagnóstico Inteligente',           'Smart Diagnosis'),
    '进入远程诊断平台': ('Aceder à plataforma de diagnóstico remoto', 'Enter remote diagnosis platform'),
    '配置用户信息':     ('Configurar informações do utilizador', 'Configure user information'),
    '首次使用需要配置用户信息': ('Na primeira utilização, configure as informações do utilizador', 'First use requires configuring user information'),
    '请填写手机号便于双方联系': ('Indique o número de telemóvel para contacto', 'Please enter phone number for contact'),
    '配置设备信息':     ('Configurar informações do dispositivo', 'Configure device information'),
    '首次使用需要绑定': ('Na primeira utilização, é necessário vincular', 'First use requires binding'),
    '远程诊断需要将设备接入互联网': ('O diagnóstico remoto requer ligação à internet', 'Remote diagnosis requires internet connection'),
    '联网方式':         ('Modo de ligação à internet',        'Internet connection method'),
    '设备联网方式':     ('Modo de ligação do dispositivo',    'Device connection method'),
    '按照向导':         ('seguindo o assistente',             'following the wizard'),
    '配网':             ('configurar rede',                   'configure network'),
    '请确保互联网':     ('Certifique-se de que a internet',   'Ensure the internet'),
    '稳定快速':         ('estável e rápida',                  'stable and fast'),
    '设备网速延迟小于': ('latência do dispositivo inferior a', 'device network latency less than'),
    '建议优先':         ('Recomenda-se prioritariamente',     'Recommended first'),
    '有线网络':         ('rede com fio',                      'wired network'),
    '有线网络联网':     ('ligação por rede com fio',          'wired network connection'),
    '网络联网':         ('ligação à rede',                    'network connection'),
    '手机热点联网':     ('ligação por hotspot móvel',         'mobile hotspot connection'),
    '超级远程诊断':     ('Super Diagnóstico Remoto',          'Hyper Remote Diagnosis'),
    '兼容远程诊断':     ('Diagnóstico Remoto Compatível',     'Compatible Remote Diagnosis'),
    '类型':             ('Tipo',                              'Type'),
    '电脑搜寻':         ('Pesquisa do computador',            'Computer search'),
    '自动':             ('Automático',                        'Automatic'),
    '成功后':           ('após sucesso',                      'after success'),
    '会自动安装驱动':   ('os drivers são instalados automaticamente', 'drivers installed automatically'),
    '密码':             ('Palavra-passe',                     'Password'),
    '默认':             ('padrão',                            'default'),
    '设备配置':         ('Configuração do Dispositivo',       'Device Configuration'),
    '本文介绍':         ('Este artigo apresenta',             'This article introduces'),
    '关于':             ('Sobre',                             'About'),
    '检测不到设备的问题': ('Problema: dispositivo não detectado', 'Device not detected issue'),
    '原厂诊断指南':     ('Guia de Diagnóstico OEM',           'OEM Diagnosis Guide'),
    '安装报错的问题':   ('Problema de erro de instalação',    'Installation error issue'),
    '工程师软件介绍和使用指南': ('Guia do Software de Engenharia', 'Engineering Software Guide'),
    '车辆诊断案例':     ('Casos de Diagnóstico de Veículos',  'Vehicle Diagnostic Cases'),
    '警报灯间歇性报警': ('alerta intermitente da luz de aviso', 'intermittent warning light alert'),
    '正常行驶时':       ('durante a condução normal',         'during normal driving'),
    '文件比较大':       ('O ficheiro é grande',               'The file is large'),
    '缓存要点时间':     ('o cache demora algum tempo',        'caching takes some time'),
    '请耐心等候':       ('por favor aguarde',                 'please wait patiently'),
    '教材':             ('material de aprendizagem',          'learning material'),
    '紧凑型厢式货车':   ('Furgoneta compacta',                'Compact van'),
    '敞篷车':           ('Descapotável',                      'Convertible'),
    '轿跑车':           ('Coupé',                             'Coupe'),
    '紧凑型车':         ('Compacto',                          'Compact'),
    '轿车':             ('Berlina',                           'Sedan'),
    '造成的原因和解决办法': ('Causas e soluções',             'Causes and solutions'),
    '问题':             ('Problema',                          'Problem'),
    '部分家庭版':       ('Algumas versões Home',              'Some Home editions'),
    '权限不够':         ('permissões insuficientes',          'insufficient permissions'),
    '本田诊断系统软件套件': ('Suite de software Honda Diagnostic System', 'Honda Diagnostic System software suite'),
    '用于本田':         ('para Honda',                        'for Honda'),
    '和讴歌':           ('e Acura',                           'and Acura'),
    '汽车上的电子系统的诊断和维修': ('diagnóstico e reparação de sistemas electrónicos', 'diagnosis and repair of electronic systems'),
    '原厂软件':         ('Software OEM',                      'OEM Software'),
    '后端电子编程':     ('Programação electrónica de backend', 'Backend electronics programming'),
    '工程师模式的转换操作': ('Operação de conversão para modo de engenharia', 'Engineer mode conversion operation'),
    '工程师模式转换操作方法': ('Método de conversão para modo de engenharia', 'Engineer mode conversion method'),
    '内系统设置':       ('configurações do sistema interno',  'internal system settings'),
    '软件每个发行版都用': ('Cada versão do software usa',     'Each software release uses'),
    '作为':             ('como',                              'as'),
    '号':               ('número',                           'number'),
    '按照软件设定':     ('de acordo com as definições do software', 'according to software settings'),
    '安装的时候系统的': ('durante a instalação do sistema',   'during system installation'),
    '超级远程诊断模式只需要单客户端': ('O modo Super Diagnóstico Remoto requer apenas um cliente', 'Hyper remote mode requires only a single client'),
    '设备即可实现多':   ('dispositivo para múltiplos',        'device to achieve multiple'),
    '原厂软件直连远程车辆诊断': ('diagnóstico remoto directo com software OEM', 'direct OEM software remote vehicle diagnosis'),
    '本文档介绍超级远程诊断使用': ('Este documento descreve a utilização do Super Diagnóstico Remoto', 'This document describes Hyper Remote Diagnosis usage'),
    '远程诊断介绍':     ('Introdução ao Diagnóstico Remoto',  'Remote Diagnosis Introduction'),
    '是基于云计算和':   ('é baseado em computação em nuvem e', 'is based on cloud computing and'),
    '技术的车辆远程实时诊断平台': ('plataforma de diagnóstico remoto em tempo real', 'real-time remote vehicle diagnosis platform'),
    '用户使用':         ('Os utilizadores usam',              'Users use'),
    '诊断设备':         ('dispositivo de diagnóstico',        'diagnostic device'),
    '兼容远程诊断模式需要服务端和客户端各使用': ('O modo de Diagnóstico Remoto Compatível requer servidor e cliente cada um usando', 'Compatible remote mode requires server and client each using'),
    '个':               ('',                                  ''),
    '可实现任意':       ('pode realizar qualquer',            'can achieve any'),
    '系列设备与':       ('dispositivos da série com',         'series devices with'),
    '多种':             ('múltiplos',                         'multiple'),
    '设备被占用后手动': ('após ocupação manual do dispositivo', 'manually after device is occupied'),
    '释放设备':         ('libertar o dispositivo',            'release the device'),
    '后启动报错':       ('Erro ao iniciar após',              'Error on startup after'),
    '问题描述':         ('Descrição do problema',             'Problem description'),
    '连上电脑了':       ('ligado ao computador',              'connected to computer'),
    '但是客户端':       ('mas o cliente',                     'but the client'),
    '需求':             ('Requisitos',                        'Requirements'),
    '适配':             ('adaptação',                         'adaptation'),
    '安装驱动后':       ('após instalar o driver',            'after installing driver'),
    '即可被软件识别并实现原厂诊断': ('pode ser reconhecido pelo software para diagnóstico OEM', 'can be recognized by software for OEM diagnosis'),
    '请保持设备固件始终为最新': ('mantenha sempre o firmware do dispositivo actualizado', 'keep device firmware always updated'),
    '来不断优化设备和新增': ('para optimizar continuamente o dispositivo e adicionar', 'to continuously optimize and add features'),
    '设备通过授权':     ('O dispositivo através de licença',  'The device via license'),
    '来管理设备':       ('para gerir o dispositivo',          'to manage the device'),
    '用户购买的产品根据型号和配置可能包含多种授权': ('O produto adquirido pode incluir várias licenças conforme o modelo', 'Product may include multiple licenses depending on model'),
    '系列产品可':       ('Produtos da série podem',           'Series products can'),
    '或更新':           ('ou atualizar',                      'or update'),
    '系列车辆诊断产品总览': ('Visão geral dos produtos de diagnóstico da série', 'Series vehicle diagnostic products overview'),
    '新一代智能车辆诊断': ('Diagnóstico inteligente de veículos de nova geração', 'Next-generation smart vehicle diagnosis'),
    '全':               ('Total',                             'Full'),
    '车辆诊断设备':     ('Dispositivo de diagnóstico de veículos', 'Vehicle diagnostic device'),
    '远程车辆诊断':     ('Diagnóstico remoto de veículos',    'Remote vehicle diagnosis'),
    '是搭载了':         ('é equipado com',                    'is equipped with'),
    '诊断技术的最新一代车辆网络': ('a mais recente rede de diagnóstico veicular', 'the latest generation vehicle network with diagnosis technology'),
    '集成四大汽车工业标准于一个设备': ('integra quatro padrões da indústria automóvel num dispositivo', 'integrates four automotive industry standards in one device'),
    '不仅':             ('não apenas',                        'not only'),
    '所有传统':         ('todos os tradicionais',             'all traditional'),
    '是一款标准化的':   ('é um dispositivo padronizado de',   'is a standardized'),
    '国际标准设计':     ('design baseado em padrões internacionais', 'design based on international standards'),
    '超高集成度的硬件设计': ('Hardware de alta integração',   'High integration hardware design'),
    '可全面适配多种':   ('compatível com múltiplos',          'compatible with multiple'),
    '本地诊断':         ('diagnóstico local',                 'local diagnosis'),
    '还可实现超级远程诊断': ('e permite Super Diagnóstico Remoto', 'and enables Hyper Remote Diagnosis'),
    '软件更新':         ('Atualização de Software',           'Software Update'),
    '当前':             ('Atual',                             'Current'),
    '请优先使用最新的': ('Use preferencialmente a versão mais recente de', 'Prefer to use the latest'),
    '进行':             ('para',                              'to perform'),
    '如果无法在线更新时': ('Se não conseguir atualizar online', 'If unable to update online'),
    '请使用':           ('utilize',                           'please use'),
    '累积更新':         ('atualização acumulativa',           'cumulative update'),
    '优化':             ('Otimização',                        'Optimization'),
    '引起的':           ('causado por',                       'caused by'),
    '失效':             ('falha',                             'failure'),
    '链接':             ('Link',                              'Link'),
    '修复':             ('Correção',                          'Fix'),
    '兼容性更新':       ('Atualização de compatibilidade',    'Compatibility update'),
    '环境闪退':         ('crash no ambiente',                 'environment crash'),
    '软件':             ('Software',                          'Software'),
    '简介':             ('Introdução',                        'Introduction'),
    '约翰迪尔':         ('John Deere',                        'John Deere'),
    '公司':             ('empresa',                           'company'),
    '年由铁匠约翰':     ('fundada pelo ferreiro John',        'founded by blacksmith John'),
    '对约翰迪尔':       ('para o John Deere',                 'for John Deere'),
    '挖掘机进行诊断':   ('realizar diagnóstico na escavadeira', 'perform excavator diagnosis'),
    '是较旧的诊断软件': ('é software de diagnóstico mais antigo', 'is older diagnostic software'),
    '它是':             ('É o',                               'It is'),
    '车辆最简单的工具': ('ferramenta mais simples para veículos', 'simplest tool for vehicles'),
    '宝马售后在线系统': ('Sistema de pós-venda BMW online',   'BMW after-sales online system'),
    '工程师软件的简介和设备': ('introdução ao software de engenharia e dispositivo', 'introduction to engineering software and device'),
    '离线编程':         ('Programação Offline',               'Offline Programming'),
    '说明':             ('Nota',                              'Note'),
    '本文介绍奔驰':     ('Este artigo apresenta o Mercedes-Benz', 'This article introduces Mercedes-Benz'),
    '网关':             ('Gateway',                           'Gateway'),
    '本文简单介绍':     ('Este artigo descreve brevemente',   'This article briefly introduces'),
    '设备如何操作':     ('como operar o dispositivo',         'how to operate the device'),
    '级车':             ('classe',                            'class'),
    '免责声明':         ('Aviso Legal',                       'Disclaimer'),
    '这是梅赛德斯':     ('Este é o Mercedes',                 'This is Mercedes'),
    '奔驰用于车辆保养': ('Mercedes-Benz para manutenção de veículos', 'Mercedes-Benz for vehicle maintenance'),
    '维护和维修的整套诊断和编程系统': ('sistema completo de diagnóstico e programação para manutenção e reparação', 'complete diagnosis and programming system for maintenance and repair'),
    '是其中规模最大的一个': ('é o maior do sistema',          'is the largest of the system'),
    '是诊断系统':       ('é o sistema de diagnóstico',        'is the diagnosis system'),
    '的下一代产品':     ('a próxima geração de',              'the next generation of'),
    '工程师软件简介和': ('Introdução ao Software de Engenharia e', 'Engineering Software Introduction and'),
    '操作介绍':         ('Introdução à Operação',             'Operation Introduction'),
    '是':               ('é',                                 'is'),
    '软件更新':         ('Atualização de Software',           'Software Update'),
    '固件':             ('Firmware',                          'Firmware'),
    '自动':             ('Automático',                        'Automatic'),
    '诊断软件':         ('Software de Diagnóstico',           'Diagnostic Software'),
    # Release notes patterns
    '更新时间':         ('Data de Atualização',               'Update Date'),
    '解决了小问题':     ('Correcção de problemas menores',    'Fixed minor issues'),
}

# ─── Build translation tables sorted by length (longest first to avoid partial matches) ─
ZH_PT = sorted(ZH.items(), key=lambda x: -len(x[0]))
ZH_EN = [(k, v[1]) for k, v in sorted(ZH.items(), key=lambda x: -len(x[0]))]
ZH_PT = [(k, v[0]) for k, v in ZH_PT]

def translate_chinese(text, translations):
    """Replace all Chinese strings using provided translation list."""
    for zh, target in translations:
        text = text.replace(zh, target)
    return text

# ─── Image downloading ─────────────────────────────────────────────────────────
WIKI_BASE = 'http://wiki.allscanner.com'

def download_image(url, dest_path):
    dest_path = Path(dest_path)
    dest_path.parent.mkdir(parents=True, exist_ok=True)
    if dest_path.exists():
        return True
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        with urllib.request.urlopen(req, timeout=10) as resp:
            dest_path.write_bytes(resp.read())
        print(f'  Downloaded: {url}')
        return True
    except Exception as e:
        print(f'  FAILED: {url} -> {e}')
        return False

def fix_image_src(content, file_path):
    """
    Replace http://wiki.allscanner.com/path/to/img.ext with relative path to assets/images/
    Also download the image.
    """
    pattern = re.compile(r'(src|href)="http://wiki\.allscanner\.com(/[^"]*\.(png|jpg|jpeg|gif|svg|webp|ico))"', re.IGNORECASE)

    # Determine depth of this file relative to vci-help/
    file_path = Path(file_path)
    try:
        rel = file_path.relative_to(BASE)
        depth = len(rel.parts) - 1  # number of directories above the file
    except ValueError:
        depth = 0

    prefix = '../' * depth  # e.g. for pt/product/file.html -> ../../

    def replace_img(m):
        attr = m.group(1)
        img_path = m.group(2)  # e.g. /home/vcx-fd.png
        img_path_clean = img_path.lstrip('/')
        dest = ASSETS_IMG / img_path_clean
        download_image(f'{WIKI_BASE}{img_path}', dest)
        relative_to_assets = f'{prefix}assets/images/{img_path_clean}'
        return f'{attr}="{relative_to_assets}"'

    return pattern.sub(replace_img, content)

# ─── Main processing ───────────────────────────────────────────────────────────

# Branding replacements - careful ordering matters (longest match first)
def apply_branding(content, filepath):
    fp = str(filepath)

    # 1. Title tags: always full replacement
    content = re.sub(r'<title>([^<]*?)ALLScanner Wiki([^<]*?)</title>',
                     lambda m: f'<title>{m.group(1)}M-Auto VCI Help{m.group(2)}</title>', content)
    content = re.sub(r'<title>([^<]*?)VCX Wiki([^<]*?)</title>',
                     lambda m: f'<title>{m.group(1)}M-Auto VCI Help{m.group(2)}</title>', content)

    # 2. Topbar logo text
    content = re.sub(r'ALLScanner\s*<span>Wiki</span>', 'M-Auto VCI <span>Help</span>', content)
    content = re.sub(r'VCX\s*<span>Wiki</span>', 'M-Auto VCI <span>Help</span>', content)

    # 3. landing page logo
    content = content.replace('class="landing-logo">ALLScanner Wiki', 'class="landing-logo">M-Auto VCI Help')
    content = content.replace('class="landing-logo">VCX Wiki', 'class="landing-logo">M-Auto VCI Help')

    # 4. Breadcrumbs "Wiki" links
    content = re.sub(r'(<a href="[^"]*index\.html">)Wiki(</a>)', r'\1M-Auto VCI Help\2', content)

    # 5. VX Manager / VX manager -> VCI Manager
    content = content.replace('VX Manager', 'VCI Manager')
    content = content.replace('VX manager', 'VCI Manager')

    # 6. vxmanager in display text (not in URLs/hrefs)
    # Only in visible text, not in href attributes
    content = re.sub(r'(?<!href=")(?<!src=")(?<!/)(vxmanager)(?!/)', 'vci-manager', content)

    # 7. ALLScanner -> M-Auto (in text, not in image src paths)
    # In image src we should NOT change allscanner -> m-auto (it's part of domain)
    # But allscanner.com domain references in text should be removed
    content = content.replace('ALLScanner', 'M-Auto')

    # 8. allscanner in visible text but NOT in URLs
    # Replace allscanner only outside of href/src attributes
    # Strategy: split by attributes and only replace outside quotes
    content = re.sub(r'(?<!")allscanner(?!")', 'm-auto', content)

    # 9. VCX Wiki -> M-Auto VCI Help (general text)
    content = content.replace('VCX Wiki', 'M-Auto VCI Help')

    # 10. VCX -> M-Auto VCI (in text, keeping product names like VCX-FD intact as product refs)
    # But "VCX" standalone should become "M-Auto VCI"
    # In CSS classes/IDs: vcx -> m-auto-vci
    content = re.sub(r'\bVCX\b(?!-)', 'M-Auto VCI', content)  # VCX not followed by hyphen
    # vcx in CSS classes/IDs only (class="...vcx..." or id="...vcx...")
    content = re.sub(r'(class|id)="([^"]*?)vcx([^"]*?)"',
                     lambda m: f'{m.group(1)}="{m.group(2)}m-auto-vci{m.group(3)}"', content)

    # 11. 傲世卡尔 -> M-Auto
    content = content.replace('傲世卡尔科技', 'M-Auto')
    content = content.replace('傲世卡尔', 'M-Auto')

    # 12. Footer removal
    # Remove footer paragraphs mentioning allscanner/VCX Wiki/ALLScanner
    content = re.sub(
        r'<p[^>]*>[^<]*(?:ALLScanner|M-Auto VCI Help|wiki\.allscanner\.com|VCX Wiki|allscanner)[^<]*(?:allscanner|ALLScanner|VXDIAG)[^<]*</p>',
        '', content, flags=re.IGNORECASE
    )
    # Replace specific source line
    content = re.sub(
        r'Source:\s*<a[^>]*>wiki\.allscanner\.com</a>[^<]*ALLScanner[^<]*/VXDIAG[^<]*',
        '&copy; M-Auto Online &mdash; <a href="https://m-auto.online">m-auto.online</a>',
        content
    )
    # Remove any remaining wiki.allscanner.com references in text/footer
    content = re.sub(
        r'<p[^>]*>[^<]*wiki\.allscanner\.com[^<]*</p>',
        '', content
    )

    # 13. wiki.allscanner.com domain in non-image hrefs (text links)
    content = re.sub(r'<a[^>]+href="http://wiki\.allscanner\.com"[^>]*>[^<]*</a>', '', content)

    return content

def process_file(fp):
    fp = Path(fp)
    is_pt = '\\pt\\' in str(fp) or '/pt/' in str(fp)
    is_en = '\\en\\' in str(fp) or '/en/' in str(fp)

    try:
        content = fp.read_text(encoding='utf-8-sig')
    except Exception as e:
        print(f'READ ERROR: {fp}: {e}')
        return False

    original = content

    # Apply branding
    content = apply_branding(content, fp)

    # Apply Chinese translations
    if is_pt:
        content = translate_chinese(content, ZH_PT)
    elif is_en:
        content = translate_chinese(content, ZH_EN)
    else:
        # Root index.html - apply EN translations
        content = translate_chinese(content, ZH_EN)

    # Fix image paths
    content = fix_image_src(content, fp)

    if content != original:
        fp.write_text(content, encoding='utf-8')
        return True
    return False

# Process all files
files = []
for root, dirs, fnames in os.walk(BASE):
    dirs[:] = [d for d in dirs if d not in ['_raw', 'assets']]
    for f in fnames:
        if f.endswith('.html'):
            files.append(os.path.join(root, f))

print(f'Processing {len(files)} HTML files...')
changed = 0
for fp in files:
    if process_file(fp):
        changed += 1
        print(f'  Updated: {fp.replace(str(BASE), "")}')

print(f'\nDone. {changed}/{len(files)} files updated.')

# Final scan for remaining Chinese
remaining = []
zh_pattern = re.compile(r'[\u4e00-\u9fff]+')
for fp in files:
    try:
        content = Path(fp).read_text(encoding='utf-8-sig')
        matches = zh_pattern.findall(content)
        if matches:
            uniq = list(dict.fromkeys(matches))
            remaining.append((fp.replace(str(BASE), ''), uniq))
    except: pass

print(f'\nFiles still containing Chinese: {len(remaining)}')
for fp, chars in remaining[:20]:
    print(f'  {fp}: {chars[:5]}')
if len(remaining) > 20:
    print(f'  ... and {len(remaining)-20} more')
