// content.js - Base de dados de textos para M-Auto Online V17.10
// Atualizado com descrições detalhadas para EPC e WIS

const translations = {
    pt: { 
        hero_sol: "Soluções Online", 
        hero_desc: "Instalação remota profissional.", 
        nav_soft: "Software", nav_hard: "Hardware", nav_tools: "Ferramentas", nav_serv: "Serviços", nav_about: "Sobre", 
        badge_best: "Melhor Escolha",
        
        // --- PRODUTOS & DESCRIÇÕES LONGAS (MODAIS) ---
        
        // Mercedes
        prod_merc_full: "Mercedes Full Pack 2025", 
        desc_merc_full: "A Solução Completa.", 
        price_pack: "Pack Completo",
        desc_merc_full_detail: "A solução definitiva para profissionais Mercedes. Inclui:<br>• Xentry (Diagnóstico PassThru/OpenShell)<br>• WIS/ASRA (Manuais de Reparação e Esquemas)<br>• EPC (Catálogo de Peças)<br>• Starfinder (Localizador de componentes)<br>• Vediamo & DTS Monaco (Engenharia e Flash)<br>• MbTools & Certificados ZenZefi para acesso offline.",
        
        desc_xentry_detail: "Software de diagnóstico oficial da Mercedes-Benz. Permite leitura e eliminação de falhas, visualização de dados em tempo real, testes de atuação e procedimentos de serviço completos para veículos ligeiros ou pesados (consoante a versão).",
        
        // ATUALIZADO: WIS (PT)
        desc_wis_detail: "Mercedes-Benz WIS/ASRA: Documentação de reparação e serviço, Esquemas elétricos, Diagnóstico, Reparação de carroçaria, Resolução de problemas e outros.<br>Abrange: Carros, Camiões, Veículos Todo-o-Terreno, Autocarros, Carrinhas, Unimog, Smart & Maybach.<br><br>O objetivo do WIS net é melhorar a disponibilidade eletrónica e a utilidade da documentação da oficina (reparação, manutenção, dados básicos, esquemas elétricos) dos produtos Mercedes-Benz e Smart.<br><br>Funcionalidades:<br>• Documentação de oficina/serviço<br>• Identificação e descodificação de veículos<br>• Catálogo de unidades de trabalho e taxas fixas<br>• Códigos de danos e Resolução de problemas<br>• Esquemas elétricos e Ilustrações<br>• Pesquisa e filtros avançados",

        // ATUALIZADO: EPC (PT)
        desc_epc_detail: "Mercedes-Benz EPC net: Catálogo eletrónico de peças sobresselentes originais para todos os modelos de carros, camiões e autocarros Mercedes-Benz de todos os mercados (incluindo Smart & Maybach).<br><br>Ao introduzir o seu Número de Identificação do Veículo (VIN), pode visualizar as peças específicas que se adequam ao seu carro, o que é extremamente útil quando existem variações de peças ao longo da vida do modelo.<br><br>Também é possível visualizar o Cartão de Dados do veículo que mostra o número original do motor, número da caixa de velocidades, códigos de pintura, acabamentos e lista de opcionais. Isto é muito útil ao avaliar um carro usado para determinar se mantém os componentes originais.<br>O EPC mostra também uma vista explodida de cada área do carro.",

        desc_vgs_detail: "Ferramenta específica para reiniciar (Renew) e Virginizar unidades de controlo de transmissão 722.9 (7G-Tronic). Essencial para substituição de placas TCU usadas.",
        desc_dts_detail: "DTS Monaco é a ferramenta de engenharia universal para diagnóstico e controlo de unidades ECUs da Daimler. Permite codificação SCN offline, alteração de variantes e flashagem.",
        desc_vediamo_detail: "Software de engenharia de fábrica. Utilizado para diagnóstico, codificação, flash e diagnósticos especiais não acessíveis via Xentry.",
        desc_hht_detail: "Emulador HHT-WIN para diagnóstico de modelos Mercedes clássicos (anos 90 e inícios de 2000) que não são cobertos nativamente pelo Xentry moderno.",
        desc_7g_detail: "Ferramenta especializada para reset e calibração de transmissões 7G-Tronic. Permite procedimentos rápidos de adaptação.",
        desc_zenzefi_detail: "Certificados digitais que permitem o diagnóstico de veículos mais recentes (W206, W223) em modo offline, contornando a necessidade de login online oficial.",
        desc_mbtools_detail: "Suite de utilitários para facilitar a instalação, ativação e manutenção dos softwares Mercedes. Inclui geradores de chaves e fixadores de erros comuns.",
        desc_pl_detail: "Lista de preços oficial das peças Mercedes-Benz para o ano 2025. Formato Excel/Database para consulta rápida de valores.",
        desc_tut_detail: "Coleção de guias em vídeo e PDF ensinando procedimentos comuns de codificação, instalação e uso das ferramentas de engenharia.",
        desc_sdm_detail: "Star Diagnosis Media. Biblioteca de vídeos e guias multimédia oficiais para resolução de problemas complexos.",
        desc_vin_detail: "Base de dados FBS completa e inferências baseadas no VIN.<br>• Sistema completo de deteção de tipo de carroçaria<br>• Visualização fixa de plataforma e transmissão<br>• Binário restaurado e características notáveis do motor<br>• Formatação melhorada para relatórios detalhados<br>• A lógica exata do 'modelo completo' (E220D, C200, etc.)<br>• Sem janelas de consola durante a verificação<br>• Descodificação manual de VIN completamente offline.",

        // Outras Marcas
        desc_odis_s: "ODIS Service (Offboard Diagnostic Information System). Software de diagnóstico de concessionário para todas as marcas do grupo VAG (VW, Audi, Seat, Skoda, Bentley, Lamborghini). Inclui funções de diagnóstico guiado, esquemas elétricos e boletins técnicos.",
        desc_odis_e: "ODIS Engineering. Software de desenvolvimento VAG para flashagem offline de unidades de controlo. Permite alterar parâmetros, atualizar firmware e realizar codificações avançadas não acessíveis no ODIS Service.",
        desc_ista_d: "ISTA+ (Rheingold). Sistema de diagnóstico oficial para BMW, Mini e Rolls-Royce. Suporta diagnóstico completo, plano de teste calculado, esquemas elétricos e manuais de reparação integrados.",
        desc_ista_p: "Software dedicado para programação e codificação de módulos (ECU) em chassis da série E. Essencial para atualizações de software e substituição de módulos.",
        desc_diagbox9: "Diagbox v9. Versão mais recente para veículos PSA (Peugeot, Citroën, DS, Opel). Suporta os modelos mais recentes até 2024. Funciona com interfaces Lexia 3 originais ou de alta qualidade.",
        desc_clip: "Renault Can Clip. Ferramenta de diagnóstico oficial para Renault e Dacia. Permite diagnóstico completo de todos os sistemas, reprogramação, codificação de chaves e testes de atuadores.",
        desc_pathfinder: "JLR Pathfinder. Nova arquitetura de diagnóstico para veículos Jaguar e Land Rover com comunicação DoIP (geralmente modelos 2017 em diante).",
        desc_sdd: "JLR SDD. Symptom Driven Diagnostics para veículos JLR de 2005 a 2016. Suporta funções de serviço, diagnósticos de avarias e programação de módulos.",
        desc_jlr_seed_detail: "Gerador de chaves de acesso de segurança (Seed-Key). Essencial para desbloquear funções especiais e de engenharia no SDD e Pathfinder (ex: codificação de chaves, alteração de VIN).",
        desc_techstream: "Toyota Techstream. Software de diagnóstico de fábrica para Toyota, Lexus e Scion. Permite verificação de saúde do veículo, personalização de configurações (C-Best) e reprogramação.",
        desc_toyota_epc: "Catálogo de peças eletrónico global para Toyota. Identificação precisa de peças através do VIN, com diagramas detalhados de montagem.",
        desc_toylex: "Ferramenta poderosa para desativar sistemas como EGR, DPF, Adblue e IMMO em ECUs Denso da Toyota e Lexus. Edição direta de ficheiros binários.",
        desc_consult: "Nissan Consult III Plus. Software de diagnóstico profissional para Nissan e Infiniti. Suporta diagnóstico de todos os sistemas, CAN, programação de ECU e configuração de chaves.",
        desc_fdrs: "Ford FDRS. Sistema de diagnóstico e reparação Ford de próxima geração. Baseado na nuvem, para todos os veículos novos da Ford.",
        desc_ids: "Ford IDS. Padrão de diagnóstico para a frota Ford legacy. Cobre diagnósticos de concessionário, programação de módulos, PATS (imobilizador) e regeneração de DPF.",
        desc_gds2: "GM GDS2. Software de diagnóstico global para plataformas GM Global A. Suporta Buick, Cadillac, Chevrolet, GMC e Opel/Vauxhall (modelos 2010+).",

        // Descrições Curtas (Cartões)
        desc_cars: "Ligeiros", desc_trucks: "Pesados", desc_manuals: "Manuais", desc_parts: "Peças",
        desc_gearbox: "Caixa 722.9", desc_eng: "Engenharia", desc_classic: "Clássicos", desc_offline: "Acesso Offline",
        desc_util: "Utilitário", desc_guides: "Guias", desc_ident: "Identificação", desc_media: "Multimédia",
        desc_diag: "Diagnóstico", desc_prog: "Programação", desc_new: "Recentes", desc_old: "Antigos",
        desc_interface: "Interface J2534", desc_mux: "Multiplexer MB", desc_hardware: "Hardware",

        // Hardware & Tools Detalhado
        desc_openport_full: "Interface J2534 PassThru de alta qualidade. Compatível com Xentry, ODIS, Techstream, Forscan e muito mais. Essencial para diagnóstico multimarca.",
        desc_c4_full: "Multiplexer SD Connect C4 de grau A+. Suporta comunicação DoIP, WiFi estável e firmware atualizável. A melhor escolha para diagnóstico Mercedes.",
        desc_scanmatik_detail: "Scanmatik SM2 Pro. A interface J2534 mais estável do mercado. Suporta tensão de programação auxiliar (FEPS) e é a recomendada para Xentry Passthru, ODIS e GDS2.",
        desc_vcx_detail: "VCX SE. Interface de diagnóstico compacta e versátil. Suporta DoIP e múltiplas licenças de fabricantes (pode ser usada como JLR, Ford, VW, etc).",
        desc_mbpro_detail: "Super MB Pro M6. Evolução do C4 com melhor dissipação de calor e design mais robusto. Suporte total a protocolos wireless e DoIP.",
        desc_enet_detail: "Cabo E-NET (Ethernet to OBD). Essencial para codificação e programação rápida em veículos BMW das séries F, G e I. Funciona com E-Sys e ISTA.",
        desc_clip_hw_detail: "Sonda VCI Can Clip (Chip Ouro/Gold). Interface de alta qualidade para garantir estabilidade na programação de módulos Renault/Dacia.",
        desc_lexia_detail: "Interface Lexia 3 Full Chip (NEC Relays). Indispensável para PSA. A versão Full Chip garante comunicação com todos os módulos, inclusive em modelos mais antigos que as versões 'Lite' não leem.",
        desc_laptop_detail: "Computador portátil recondicionado (Grau A, i5/i7, 8GB RAM, SSD). Fornecido pronto a usar, com sistema operativo limpo e otimizado para oficina.",

        desc_remote_full: "Software de acesso remoto de alta performance, baixa latência e seguro. Alternativa superior ao TeamViewer para suporte técnico.",
        desc_iso_full: "Ferramenta oficial da Microsoft para criar pen drives de arranque com a versão mais recente do Windows 10/11.",
        desc_extract_full: "Gestor de arquivos open-source. Essencial para extrair os nossos pacotes de software com máxima compatibilidade.",
        desc_defender_full: "Utilitário portátil para desativar completamente o Windows Defender, evitando falsos positivos durante instalações.",

        // Serviços
        serv_fmt: "Formatação", desc_fmt: "Instalação limpa de Windows 10/11 Pro com drivers e otimização.",
        serv_av: "Anti-vírus", desc_av: "Instalação e configuração de proteção leve e eficaz.",
        serv_inst: "Instalação", desc_inst: "Instalação remota completa de qualquer software de diagnóstico.",
        serv_opt: "Otimização", desc_opt: "Limpeza de sistema, registo e aceleração do arranque.",
        serv_upg: "Upgrade HW", desc_upg: "Consultoria para upgrade de memória RAM e disco SSD.",
        
        btn_schedule: "Agendar",
        about_text_full: "Somos especialistas em software de diagnóstico automóvel com anos de experiência. Oferecemos um serviço profissional, com resposta rápida e suporte assegurado. As nossas instalações são limpas, otimizadas e garantidas. Trabalhamos com as melhores ferramentas do mercado para garantir que a sua oficina nunca para.", 
        wiz_os: "Qual é o seu Windows?", wiz_ram: "Memória RAM?", wiz_result: "Resultado",
        popup_text: "pessoas a ver este site."
    },
    en: { 
        hero_sol: "Online Solutions", hero_desc: "Professional remote installation.", 
        nav_soft: "Software", nav_hard: "Hardware", nav_tools: "Tools", nav_serv: "Services", nav_about: "About", 
        badge_best: "Best Choice",

        prod_merc_full: "Mercedes Full Pack 2025", desc_merc_full: "The Complete Solution.", price_pack: "Full Pack",
        desc_merc_full_detail: "The ultimate solution for Mercedes pros. Includes:<br>• Xentry (PassThru/OpenShell)<br>• WIS/ASRA (Repair Manuals)<br>• EPC (Parts Catalog)<br>• Starfinder<br>• Vediamo & DTS Monaco (Engineering)<br>• MbTools & ZenZefi Certificates.",
        
        desc_cars: "Cars", desc_trucks: "Trucks", desc_manuals: "Manuals", desc_parts: "Parts",
        desc_gearbox: "Gearbox 722.9", desc_eng: "Engineering", desc_classic: "Classics", desc_offline: "Offline Access",
        desc_util: "Utility", desc_guides: "Guides", desc_ident: "Identification", desc_media: "Multimedia",
        desc_diag: "Diagnostic", desc_prog: "Programming", desc_new: "Recent", desc_old: "Legacy",
        desc_interface: "J2534 Interface", desc_mux: "MB Multiplexer", desc_hardware: "Hardware",

        desc_xentry_detail: "Official Mercedes-Benz diagnostic software. Allows fault reading/clearing, live data, actuation tests, and full service procedures.",
        
        // UPDATED: WIS (EN)
        desc_wis_detail: "Mercedes-Benz WIS/ASRA: Repair and service documentation, Electric diagrams, Diagnosis, Body repair, Troubleshooting and more.<br>Covers: Cars, Trucks, Cross-Country vehicles, Buses, Vans, Unimog, Smart & Maybach.<br><br>The WIS net aim is to improve the electronic availability and usefulness of the workshop documentation (e.g. repair, maintenance, basic data, wiring diagrams) of Mercedes-Benz products.<br><br>Features:<br>• Workshop/service documentation<br>• Vehicle identification, decoding<br>• Work units catalog & Flat rates<br>• Damage codes & Troubleshooting<br>• Wiring diagrams & Illustrations<br>• Search/filters",

        // UPDATED: EPC (EN)
        desc_epc_detail: "Mercedes-Benz EPC net: Electronic spare parts catalogue consisting of original parts for all models of Mercedes-Benz cars, trucks, and buses (including Smart & Maybach).<br><br>By entering your Vehicle Identification Number (VIN), you can view the specific parts that fit your car. This is extremely helpful when variations on a part were fitted over the model’s lifetime.<br><br>Also, the vehicle’s Data Card is viewable, showing the original engine number, gearbox number, paint/trim codes, and option codes. Very handy for verifying if a second-hand car still has original components.<br>The EPC also shows an exploded view of each area.",

        desc_vgs_detail: "Specific tool to Renew and Virginize 722.9 (7G-Tronic) transmission control units.",
        desc_dts_detail: "DTS Monaco is the universal engineering tool for Daimler ECUs. Allows offline SCN coding, variant coding, and flashing.",
        desc_vediamo_detail: "Factory engineering software. Used for diagnostics, coding, flashing, and special functions not in Xentry.",
        desc_hht_detail: "HHT-WIN emulator for diagnosing classic Mercedes models (90s/early 00s).",
        desc_7g_detail: "Specialized tool for resetting and calibrating 7G-Tronic transmissions.",
        desc_zenzefi_detail: "Digital certificates allowing offline diagnosis of newer vehicles (W206, W223).",
        desc_mbtools_detail: "Utility suite for Mercedes software installation, activation, and fixes.",
        desc_pl_detail: "Official 2025 Mercedes-Benz parts price list in database format.",
        desc_tut_detail: "Collection of video guides and PDFs teaching coding and installation procedures.",
        desc_sdm_detail: "Star Diagnosis Media. Official video and multimedia guide library.",
        desc_vin_detail: "Full FBS database and VIN-based inferences<br>• Complete body type detection system<br>• Fixed display of platform and transmission<br>• Restored torque and noticeable engine features<br>• Improved formatting for detailed reports<br>• The exact logic of the 'full model'<br>• No console windows during scanning<br>• Manual VIN decoding completely offline",
        
        desc_odis_s: "Dealer diagnostic software for all VAG group brands (VW, Audi, Seat, Skoda). Includes guided fault finding and wiring diagrams.",
        desc_odis_e: "VAG engineering software for offline ECU flashing. Allows changing parameters and advanced coding.",
        desc_ista_d: "Official Rheingold diagnostic system for BMW, Mini and Rolls-Royce. Supports full diagnostics and repair manuals.",
        desc_ista_p: "Dedicated software for module programming and coding on E-series chassis.",
        desc_diagbox9: "Latest diagnostic software for PSA vehicles (Peugeot, Citroën, DS, Opel). Supports latest models up to 2024.",
        desc_clip: "Official diagnostic tool for Renault and Dacia. Allows full system diagnostics and reprogramming.",
        desc_jlr_seed_detail: "Security access seed-key generator for SDD and Pathfinder. Allows key coding and engineering access.",
        desc_pathfinder: "New diagnostic architecture for JLR vehicles (2017+ models). Requires DoIP interface.",
        desc_sdd: "Symptom Driven Diagnostics for JLR vehicles (2005-2016).",
        desc_techstream: "Factory diagnostic software for Toyota, Lexus and Scion.",
        desc_toyota_epc: "Global electronic parts catalog for Toyota.",
        desc_toylex: "Powerful tool to disable EGR, DPF, Adblue and IMMO on Toyota/Lexus Denso ECUs.",
        desc_consult: "Professional diagnostic software for Nissan and Infiniti.",
        desc_fdrs: "Next-generation Ford Diagnostic and Repair System (Cloud-based).",
        desc_ids: "Diagnostic standard for legacy Ford fleet.",
        desc_gds2: "Global Diagnostic System 2 for GM Global A platforms.",

        // Hardware & Tools Detailed EN
        desc_openport_full: "High quality J2534 PassThru interface. Compatible with Xentry, ODIS, Techstream, Forscan and more.",
        desc_c4_full: "Grade A+ SD Connect C4 Multiplexer. Supports DoIP communication and stable WiFi.",
        desc_scanmatik_detail: "High-end J2534 interface (SM2 Pro), known for stability. Best for Xentry Passthru and ODIS.",
        desc_vcx_detail: "All-in-one diagnostic interface (VCX SE). Supports multiple protocols and brands.",
        desc_mbpro_detail: "Improved version of the C4 multiplexer (M6). Better heat dissipation and full DoIP support.",
        desc_enet_detail: "Ethernet to OBD cable. Essential for BMW F/G/I series coding.",
        desc_clip_hw_detail: "Alliance VCI probe for Renault/Dacia (Gold PCB).",
        desc_lexia_detail: "Full Chip interface for PSA. Ensures full compatibility with older vehicles.",
        desc_laptop_detail: "Refurbished laptop (i5/i7, 8GB RAM, SSD) ready to use.",

        desc_remote_full: "High performance secure remote access software.",
        desc_iso_full: "Official Microsoft tool to create bootable USB drives.",
        desc_extract_full: "Open-source file manager for extracting software packages.",
        desc_defender_full: "Portable utility to completely disable Windows Defender.",

        // Services
        serv_fmt: "Formatting", desc_fmt: "Clean Windows 10/11 Pro install with drivers and optimization.",
        serv_av: "Anti-virus", desc_av: "Installation and configuration of light and effective protection.",
        serv_inst: "Installation", desc_inst: "Full remote software installation.",
        serv_opt: "Optimization", desc_opt: "System cleaning, registry fix and boot acceleration.",
        serv_upg: "HW Upgrade", desc_upg: "Consulting for RAM memory and SSD upgrade.",

        btn_schedule: "Schedule",
        about_text_full: "We are automotive diagnostic software specialists. We offer professional service, fast response and guaranteed support. Our installations are clean, optimized and guaranteed. We work with the best tools on the market to ensure your workshop never stops.", 
        wiz_os: "Which Windows?", wiz_ram: "RAM Memory?", wiz_result: "Result",
        popup_text: "people viewing this site."
    },
    fr: { 
        hero_sol: "Solutions En Ligne", hero_desc: "Installation à distance pro.", 
        nav_soft: "Logiciels", nav_hard: "Matériel", nav_tools: "Outils", nav_serv: "Services", nav_about: "À propos", 
        badge_best: "Meilleur Choix",

        prod_merc_full: "Mercedes Full Pack 2025", desc_merc_full: "La Solution Complète.", price_pack: "Pack Complet",
        desc_merc_full_detail: "La solution ultime pour les pros Mercedes. Comprend:<br>• Xentry (PassThru/OpenShell)<br>• WIS/ASRA (Manuels)<br>• EPC (Pièces)<br>• Starfinder<br>• Vediamo & DTS Monaco (Ingénierie)<br>• MbTools & Certificats ZenZefi.",
        
        desc_cars: "Voitures", desc_trucks: "Camions", desc_manuals: "Manuels", desc_parts: "Pièces",
        desc_gearbox: "Boîte 722.9", desc_eng: "Ingénierie", desc_classic: "Classiques", desc_offline: "Accès Hors Ligne",
        desc_util: "Utilitaire", desc_guides: "Guides", desc_ident: "Identification", desc_media: "Multimédia",
        desc_diag: "Diagnostic", desc_prog: "Programmation", desc_new: "Récents", desc_old: "Anciens",
        desc_interface: "Interface J2534", desc_mux: "Multiplexeur MB", desc_hardware: "Matériel",

        desc_xentry_detail: "Logiciel de diagnostic officiel Mercedes-Benz. Lecture/effacement de défauts, données en temps réel et tests.",
        
        // MIS À JOUR : WIS (FR)
        desc_wis_detail: "Mercedes-Benz WIS/ASRA : Documentation de réparation et d'entretien, Schémas électriques, Diagnostic, Carrosserie et Dépannage.<br>Couvre : Voitures, Camions, Bus, Utilitaires, Unimog, Smart & Maybach.<br><br>L'objectif de WIS net est d'améliorer la disponibilité électronique de la documentation d'atelier pour les produits Mercedes-Benz et Smart.<br><br>Fonctionnalités :<br>• Documentation d'atelier<br>• Identification et décodage VIN<br>• Catalogue d'unités de travail et forfaits<br>• Codes de défauts et Dépannage<br>• Schémas de câblage et Illustrations<br>• Recherche et filtres avancés",

        // MIS À JOUR : EPC (FR)
        desc_epc_detail: "Mercedes-Benz EPC net : Catalogue électronique de pièces détachées d'origine pour tous les modèles Mercedes-Benz (y compris Smart & Maybach).<br><br>En entrant votre numéro de châssis (VIN), vous pouvez voir les pièces spécifiques qui correspondent à votre voiture. Extrêmement utile pour les variations de pièces au fil du temps.<br><br>La carte de données du véhicule est également visible (moteur d'origine, boîte, codes peinture et options). Idéal pour vérifier l'authenticité des composants d'un véhicule d'occasion.<br>L'EPC offre aussi une vue éclatée de chaque zone.",

        desc_vgs_detail: "Outil spécifique pour réinitialiser les unités de commande de transmission 722.9.",
        desc_dts_detail: "Outil d'ingénierie universel pour calculateurs Daimler. Codage SCN hors ligne et flashage.",
        desc_vediamo_detail: "Logiciel d'ingénierie d'usine. Utilisé pour le codage et les fonctions spéciales.",
        desc_hht_detail: "Émulateur pour le diagnostic des modèles Mercedes classiques.",
        desc_7g_detail: "Outil pour la réinitialisation et le calibrage des transmissions 7G-Tronic.",
        desc_zenzefi_detail: "Certificats numériques permettant le diagnostic hors ligne des véhicules récents.",
        desc_mbtools_detail: "Suite d'utilitaires pour l'installation et l'activation des logiciels Mercedes.",
        desc_pl_detail: "Liste de prix officielle des pièces Mercedes-Benz 2025.",
        desc_tut_detail: "Collection de guides vidéo pour le codage et l'installation.",
        desc_sdm_detail: "Bibliothèque multimédia officielle Star Diagnosis.",
        desc_vin_detail: "Base de données FBS complète et inférences basées sur VIN<br>• Système complet de détection de type de carrosserie<br>• Affichage fixe de la plateforme et de la transmission<br>• Couple restauré et caractéristiques moteur notables<br>• Formatage amélioré pour les rapports détaillés<br>• La logique exacte du 'modèle complet'<br>• Pas de fenêtres de console pendant le scan<br>• Décodage manuel VIN complètement hors ligne",
        
        desc_odis_s: "Logiciel de diagnostic concessionnaire pour toutes les marques du groupe VAG.",
        desc_odis_e: "Logiciel d'ingénierie VAG pour le flashage hors ligne des calculateurs.",
        desc_ista_d: "Système de diagnostic officiel Rheingold pour BMW, Mini et Rolls-Royce.",
        desc_ista_p: "Logiciel dédié à la programmation et au codage des modules sur châssis série E.",
        desc_diagbox9: "Dernier logiciel de diagnostic pour véhicules PSA. Supporte les modèles jusqu'à 2024.",
        desc_clip: "Outil de diagnostic officiel pour Renault et Dacia.",
        desc_jlr_seed_detail: "Générateur de clés d'accès de sécurité (Seed-Key) pour SDD et Pathfinder.",
        desc_pathfinder: "Nouvelle architecture de diagnostic pour Jaguar et Land Rover (DoIP, 2017+).",
        desc_sdd: "Symptom Driven Diagnostics pour véhicules JLR (2005-2016).",
        desc_techstream: "Logiciel de diagnostic d'usine pour Toyota, Lexus et Scion.",
        desc_toyota_epc: "Catalogue de pièces électronique mondial pour Toyota.",
        desc_toylex: "Outil pour désactiver EGR, DPF, Adblue et IMMO sur Toyota/Lexus.",
        desc_consult: "Logiciel de diagnostic professionnel pour Nissan et Infiniti.",
        desc_fdrs: "Système de diagnostic Ford nouvelle génération (Cloud).",
        desc_ids: "Standard de diagnostic pour la flotte Ford existante.",
        desc_gds2: "Système de diagnostic mondial pour plateformes GM Global A.",

        // Hard/Tools Detailed FR
        desc_openport_full: "Interface J2534 PassThru de haute qualité. Compatible multimarque.",
        desc_c4_full: "Multiplexeur SD Connect C4 grade A+. Supporte DoIP et WiFi stable.",
        desc_scanmatik_detail: "Interface J2534 haut de gamme (SM2 Pro), très stable.",
        desc_vcx_detail: "Interface de diagnostic tout-en-un (VCX SE).",
        desc_mbpro_detail: "Version améliorée du multiplexeur C4 (M6).",
        desc_enet_detail: "Câble Ethernet vers OBD pour BMW.",
        desc_clip_hw_detail: "Sonde VCI Alliance pour Renault/Dacia (Gold PCB).",
        desc_lexia_detail: "Interface Full Chip pour PSA.",
        desc_laptop_detail: "Ordinateur portable reconditionné (i5/i7, 8GB RAM, SSD) prêt à l'emploi.",

        desc_remote_full: "Logiciel d'accès à distance performant et sécurisé.",
        desc_iso_full: "Outil officiel Microsoft pour créer des clés USB de démarrage.",
        desc_extract_full: "Gestionnaire de fichiers open-source pour extraire les archives.",
        desc_defender_full: "Utilitaire pour désactiver Windows Defender.",

        // Services
        serv_fmt: "Formatage", desc_fmt: "Installation propre de Windows 10/11 Pro avec pilotes.",
        serv_av: "Anti-virus", desc_av: "Installation et configuration d'une protection légère et efficace.",
        serv_inst: "Installation", desc_inst: "Installation complète de logiciels à distance.",
        serv_opt: "Optimisation", desc_opt: "Nettoyage du système, registre et accélération du démarrage.",
        serv_upg: "Mise à niveau", desc_upg: "Conseil pour la mise à niveau de la RAM et du SSD.",

        btn_schedule: "Planifier",
        about_text_full: "Spécialistes en logiciels de diagnostic automobile. Service professionnel, réponse rapide et support garanti. Installations propres et optimisées.", 
        wiz_os: "Quel Windows?", wiz_ram: "Mémoire RAM?", wiz_result: "Résultat",
        popup_text: "personnes consultent ce site."
    }
};
