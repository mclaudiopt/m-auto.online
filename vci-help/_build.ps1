# ALLScanner Wiki Builder
# Generates PT and EN translated pages from raw Chinese HTML

param([string]$lang = "both")

$base = "D:/Tutorials/m-auto.online/wiki"
$raw  = "$base/_raw"

# ──────────────────────────────────────────────────────────────────────
# HELPER: build page HTML
# ──────────────────────────────────────────────────────────────────────
function Build-Page {
  param(
    [string]$lang,
    [string]$title,
    [string]$breadcrumb,  # "Section > Subsection"
    [string]$content,     # inner HTML
    [string]$activePath,  # e.g. "guide/quickstart"
    [string]$depth        # "1" = pt/X.html, "2" = pt/X/Y.html, "3" = pt/X/Y/Z.html
  )

  $assetPath = switch ($depth) {
    "1" { "../assets" }
    "2" { "../../assets" }
    "3" { "../../../assets" }
    default { "../assets" }
  }
  $rootPath = switch ($depth) {
    "1" { "../" }
    "2" { "../../" }
    "3" { "../../../" }
    default { "../" }
  }

  $langLabel = if ($lang -eq "pt") { "PT" } else { "EN" }
  $otherLang = if ($lang -eq "pt") { "en" } else { "pt" }
  $otherLabel = if ($lang -eq "pt") { "EN" } else { "PT" }
  $htmlLang  = if ($lang -eq "pt") { "pt-PT" } else { "en" }

  # Build breadcrumb HTML
  $bcParts = $breadcrumb -split " > "
  $bcHtml = "<a href=`"${rootPath}index.html`">Wiki</a>"
  foreach ($part in $bcParts) {
    $bcHtml += " <span class=`"sep`">/</span> <span class=`"current`">$part</span>"
  }

  # Language switcher link (same page in other lang)
  $otherHref = $rootPath -replace "^\.\./$lang/", "../$otherLang/"
  # Simple approach: replace lang prefix in URL
  $curUrl = ""  # will be set per-page via JS

  return @"
<!DOCTYPE html>
<html lang="$htmlLang">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$title — ALLScanner Wiki</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Manrope:wght@400;500;600;700;800&family=Inter:wght@400;500;600&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${assetPath}/wiki.css">
</head>
<body>
  <!-- TOP BAR -->
  <header class="topbar">
    <button class="hamburger" id="hamburger" aria-label="Menu">
      <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
        <rect y="3" width="20" height="2" rx="1"/>
        <rect y="9" width="20" height="2" rx="1"/>
        <rect y="15" width="20" height="2" rx="1"/>
      </svg>
    </button>
    <a class="topbar-logo" href="${rootPath}index.html">ALLScanner <span>Wiki</span></a>
    <div class="topbar-sep"></div>
    <div class="lang-switcher" id="lang-switcher">
      <span class="lang-btn active">$langLabel</span>
      <a class="lang-btn" id="other-lang-btn" href="#">$otherLabel</a>
    </div>
  </header>

  <div class="overlay" id="overlay"></div>

  <div class="layout">
    <!-- SIDEBAR -->
    <nav class="sidebar" id="sidebar">
      $(Get-NavHTML $lang $rootPath $activePath)
    </nav>

    <!-- MAIN -->
    <main class="main">
      <nav class="breadcrumb">$bcHtml</nav>
      $content
      <div class="page-footer">
        ALLScanner Wiki &mdash; <a href="http://wiki.allscanner.com" target="_blank" rel="noopener">wiki.allscanner.com</a>
      </div>
    </main>
  </div>

  <script src="${assetPath}/nav.js"></script>
  <script>
    // Language switcher: swap /pt/ <-> /en/ in current URL
    (function() {
      var path = window.location.pathname;
      var other = path.replace('/$lang/', '/$otherLang/');
      document.getElementById('other-lang-btn').href = other;
    })();
  </script>
</body>
</html>
"@
}

# ──────────────────────────────────────────────────────────────────────
# NAVIGATION HTML
# ──────────────────────────────────────────────────────────────────────
function Get-NavHTML {
  param([string]$lang, [string]$root, [string]$active)

  $p = $root  # base path (e.g. "../../")

  if ($lang -eq "pt") {
    $home     = "Início"
    $products = "Produtos"
    $releases = "Lançamentos"
    $guide    = "Guia de Utilização"
    $donet    = "DoNet Diagnóstico Remoto"
    $diagPass = "Diagnostico OEM - Ligeiros"
    $diagComm = "Diagnostico OEM - Comerciais"
    $devGuide = "Guia do Programador"
    $allHome  = "Início"

    $nav_home_lbl    = "Início"
    $nav_quickstart  = "Guia de Início Rápido"
    $nav_connection  = "Ligação do Dispositivo"
    $nav_firmware    = "Actualização de Firmware"
    $nav_license     = "Gestão de Licenças"
    $nav_diagnosis   = "Gestão de Drivers"
    $nav_faq         = "FAQ"
    $nav_device_ip   = "Alterar IP do Dispositivo"
    $nav_vcx_sel     = "Selecção de Produtos VCX"
    $nav_vcx_fd      = "VCX-FD"
    $nav_vcx_doip    = "VCX-DoIP"
    $nav_vcx_se      = "VCX-SE"
    $nav_vcx_nano    = "VCX-Nano"
    $nav_rel         = "Actualizações"
    $nav_upd_vci     = "Update VCI"
    $nav_upd_doip    = "Update DoIP"
    $nav_upd_vcxfd   = "Update VCX-FD"
    $nav_vxmgr       = "VX Manager"
    $nav_donet_intro = "Introdução à Plataforma"
    $nav_hyper       = "Super Diagnóstico Remoto"
    $nav_legacy      = "Diagnóstico Remoto Compatível"
    $nav_benz        = "Mercedes-Benz"
    $nav_bmw         = "BMW"
    $nav_ford        = "Ford"
    $nav_gm          = "GM / Chevrolet"
    $nav_honda       = "Honda"
    $nav_jlr         = "Jaguar Land Rover"
    $nav_porsche     = "Porsche"
    $nav_rmi         = "RMI"
    $nav_subaru      = "Subaru"
    $nav_toyota      = "Toyota"
    $nav_vag         = "VAG (VW/Audi/Seat/Skoda)"
    $nav_volvo       = "Volvo"
    $nav_vw          = "Volkswagen"
    $nav_drive_upd   = "DRIVE Update"
    $nav_deere       = "John Deere"
    $nav_developer   = "Guia do Programador"
  } else {
    $products = "Products"
    $releases = "Releases"
    $guide    = "User Guide"
    $donet    = "DoNet Remote Diagnosis"
    $diagPass = "OEM Diagnosis - Passenger"
    $diagComm = "OEM Diagnosis - Commercial"
    $devGuide = "Developer Guide"

    $nav_home_lbl    = "Home"
    $nav_quickstart  = "Quick Start Guide"
    $nav_connection  = "Device Connection"
    $nav_firmware    = "Firmware Update"
    $nav_license     = "License Management"
    $nav_diagnosis   = "Driver Management"
    $nav_faq         = "FAQ"
    $nav_device_ip   = "Change Device IP"
    $nav_vcx_sel     = "VCX Product Selection"
    $nav_vcx_fd      = "VCX-FD"
    $nav_vcx_doip    = "VCX-DoIP"
    $nav_vcx_se      = "VCX-SE"
    $nav_vcx_nano    = "VCX-Nano"
    $nav_rel         = "Updates"
    $nav_upd_vci     = "Update VCI"
    $nav_upd_doip    = "Update DoIP"
    $nav_upd_vcxfd   = "Update VCX-FD"
    $nav_vxmgr       = "VX Manager"
    $nav_donet_intro = "Platform Introduction"
    $nav_hyper       = "Hyper Remote Diagnosis"
    $nav_legacy      = "Legacy Remote Diagnosis"
    $nav_benz        = "Mercedes-Benz"
    $nav_bmw         = "BMW"
    $nav_ford        = "Ford"
    $nav_gm          = "GM / Chevrolet"
    $nav_honda       = "Honda"
    $nav_jlr         = "Jaguar Land Rover"
    $nav_porsche     = "Porsche"
    $nav_rmi         = "RMI"
    $nav_subaru      = "Subaru"
    $nav_toyota      = "Toyota"
    $nav_vag         = "VAG (VW/Audi/Seat/Skoda)"
    $nav_volvo       = "Volvo"
    $nav_vw          = "Volkswagen"
    $nav_drive_upd   = "DRIVE Update"
    $nav_deere       = "John Deere"
    $nav_developer   = "Developer Guide"
  }

  return @"
      <a class="nav-link-home" href="${p}${lang}/index.html">&#127968; $nav_home_lbl</a>

      <div class="nav-section">
        <div class="nav-section-header">$products <span class="chevron">&#9660;</span></div>
        <div class="nav-items">
          <a class="nav-link" href="${p}${lang}/product/index.html">$nav_vcx_sel</a>
          <a class="nav-link" href="${p}${lang}/product/vcx-fd.html">$nav_vcx_fd</a>
          <a class="nav-link" href="${p}${lang}/product/vcx-doip.html">$nav_vcx_doip</a>
          <a class="nav-link" href="${p}${lang}/product/vcx-se.html">$nav_vcx_se</a>
          <a class="nav-link" href="${p}${lang}/product/vcx-nano.html">$nav_vcx_nano</a>
        </div>
      </div>

      <div class="nav-section">
        <div class="nav-section-header">$guide <span class="chevron">&#9660;</span></div>
        <div class="nav-items">
          <a class="nav-link" href="${p}${lang}/guide/quickstart.html">$nav_quickstart</a>
          <a class="nav-link" href="${p}${lang}/guide/connection.html">$nav_connection</a>
          <a class="nav-link" href="${p}${lang}/guide/firmware.html">$nav_firmware</a>
          <a class="nav-link" href="${p}${lang}/guide/license.html">$nav_license</a>
          <a class="nav-link" href="${p}${lang}/guide/diagnosis.html">$nav_diagnosis</a>
          <a class="nav-link" href="${p}${lang}/guide/faq.html">$nav_faq</a>
          <a class="nav-link" href="${p}${lang}/guide/device-ip-change.html">$nav_device_ip</a>
        </div>
      </div>

      <div class="nav-section">
        <div class="nav-section-header">$donet <span class="chevron">&#9660;</span></div>
        <div class="nav-items">
          <a class="nav-link" href="${p}${lang}/donet/intro.html">$nav_donet_intro</a>
          <a class="nav-link" href="${p}${lang}/donet/hyper-remote.html">$nav_hyper</a>
          <a class="nav-link" href="${p}${lang}/donet/legacy-remote.html">$nav_legacy</a>
        </div>
      </div>

      <div class="nav-section">
        <div class="nav-section-header">$diagPass <span class="chevron">&#9660;</span></div>
        <div class="nav-items">
          <a class="nav-link" href="${p}${lang}/diagnosis/index.html">Overview</a>
          <a class="nav-link" href="${p}${lang}/diagnosis/benz/index.html">$nav_benz</a>
          <a class="nav-link" href="${p}${lang}/diagnosis/bmw/index.html">$nav_bmw</a>
          <a class="nav-link" href="${p}${lang}/diagnosis/ford.html">$nav_ford</a>
          <a class="nav-link" href="${p}${lang}/diagnosis/gm.html">$nav_gm</a>
          <a class="nav-link" href="${p}${lang}/diagnosis/honda/index.html">$nav_honda</a>
          <a class="nav-link" href="${p}${lang}/diagnosis/jlr.html">$nav_jlr</a>
          <a class="nav-link" href="${p}${lang}/diagnosis/porsche/index.html">$nav_porsche</a>
          <a class="nav-link" href="${p}${lang}/diagnosis/rmi.html">$nav_rmi</a>
          <a class="nav-link" href="${p}${lang}/diagnosis/subaru.html">$nav_subaru</a>
          <a class="nav-link" href="${p}${lang}/diagnosis/toyota/index.html">$nav_toyota</a>
          <a class="nav-link" href="${p}${lang}/diagnosis/vag.html">$nav_vag</a>
          <a class="nav-link" href="${p}${lang}/diagnosis/volvo.html">$nav_volvo</a>
          <a class="nav-link" href="${p}${lang}/diagnosis/vw.html">$nav_vw</a>
          <a class="nav-link" href="${p}${lang}/diagnosis/drive-update.html">$nav_drive_upd</a>
        </div>
      </div>

      <div class="nav-section">
        <div class="nav-section-header">$diagComm <span class="chevron">&#9660;</span></div>
        <div class="nav-items">
          <a class="nav-link" href="${p}${lang}/diagnosis-cv/index.html">Overview</a>
          <a class="nav-link" href="${p}${lang}/diagnosis-cv/deere/index.html">$nav_deere</a>
          <a class="nav-link" href="${p}${lang}/diagnosis-cv/deere/e240lc-diag.html">E240LC</a>
          <a class="nav-link" href="${p}${lang}/diagnosis-cv/deere/service-advisor-guide.html">Service ADVISOR</a>
        </div>
      </div>

      <div class="nav-section">
        <div class="nav-section-header">$releases <span class="chevron">&#9660;</span></div>
        <div class="nav-items">
          <a class="nav-link" href="${p}${lang}/release/index.html">$nav_rel</a>
          <a class="nav-link" href="${p}${lang}/release/update_vci.html">$nav_upd_vci</a>
          <a class="nav-link" href="${p}${lang}/release/update_doip.html">$nav_upd_doip</a>
          <a class="nav-link" href="${p}${lang}/release/update_vcxfd.html">$nav_upd_vcxfd</a>
          <a class="nav-link" href="${p}${lang}/release/vxmanager.html">$nav_vxmgr</a>
        </div>
      </div>

      <div class="nav-section">
        <div class="nav-section-header">$devGuide <span class="chevron">&#9660;</span></div>
        <div class="nav-items">
          <a class="nav-link" href="${p}${lang}/developer/index.html">$nav_developer</a>
        </div>
      </div>
"@
}

# ──────────────────────────────────────────────────────────────────────
# TRANSLATION FUNCTIONS
# ──────────────────────────────────────────────────────────────────────
function Translate-Links {
  param([string]$html, [string]$lang, [int]$depthLevel)

  # Convert internal /zh/path links to relative local links
  # depth 1 = one level deep (e.g. pt/index.html -> ../pt/guide/x.html)
  # depth 2 = two levels deep (e.g. pt/guide/x.html -> ../../pt/product/y.html)

  $prefix = switch ($depthLevel) {
    1 { "" }     # same level as pt/en
    2 { "../" }
    3 { "../../" }
    default { "" }
  }

  # Map Chinese paths to local filenames
  $html = $html -replace 'href="/zh/home"', "href=`"${prefix}index.html`""
  $html = $html -replace 'href="/zh/guide/quickstart"', "href=`"${prefix}guide/quickstart.html`""
  $html = $html -replace 'href="/zh/guide/connection"', "href=`"${prefix}guide/connection.html`""
  $html = $html -replace 'href="/zh/guide/firmware"', "href=`"${prefix}guide/firmware.html`""
  $html = $html -replace 'href="/zh/guide/license"', "href=`"${prefix}guide/license.html`""
  $html = $html -replace 'href="/zh/guide/diagnosis"', "href=`"${prefix}guide/diagnosis.html`""
  $html = $html -replace 'href="/zh/guide/faq"', "href=`"${prefix}guide/faq.html`""
  $html = $html -replace 'href="/zh/guide/device-ip-change"', "href=`"${prefix}guide/device-ip-change.html`""
  $html = $html -replace 'href="/zh/product"', "href=`"${prefix}product/index.html`""
  $html = $html -replace 'href="/zh/product/vcx-doip"', "href=`"${prefix}product/vcx-doip.html`""
  $html = $html -replace 'href="/zh/product/vcx-fd"', "href=`"${prefix}product/vcx-fd.html`""
  $html = $html -replace 'href="/zh/product/vcx-se"', "href=`"${prefix}product/vcx-se.html`""
  $html = $html -replace 'href="/zh/product/vcx-nano"', "href=`"${prefix}product/vcx-nano.html`""
  $html = $html -replace 'href="/zh/donet/intro"', "href=`"${prefix}donet/intro.html`""
  $html = $html -replace 'href="/zh/donet/hyper-remote"', "href=`"${prefix}donet/hyper-remote.html`""
  $html = $html -replace 'href="/zh/donet/legacy-remote"', "href=`"${prefix}donet/legacy-remote.html`""
  $html = $html -replace 'href="/zh/diagnosis"', "href=`"${prefix}diagnosis/index.html`""
  $html = $html -replace 'href="/zh/diagnosis/benz"', "href=`"${prefix}diagnosis/benz/index.html`""
  $html = $html -replace 'href="/zh/diagnosis/benz/xentry-das-guide"', "href=`"${prefix}diagnosis/benz/xentry-das-guide.html`""
  $html = $html -replace 'href="/zh/diagnosis/benz/dts-guide"', "href=`"${prefix}diagnosis/benz/dts-guide.html`""
  $html = $html -replace 'href="/zh/diagnosis/benz/model-list"', "href=`"${prefix}diagnosis/benz/model-list.html`""
  $html = $html -replace 'href="/zh/diagnosis/benz/me97-dts"', "href=`"${prefix}diagnosis/benz/me97-dts.html`""
  $html = $html -replace 'href="/zh/diagnosis/benz/205-doip-test"', "href=`"${prefix}diagnosis/benz/205-doip-test.html`""
  $html = $html -replace 'href="/zh/diagnosis/benz/211-zgw"', "href=`"${prefix}diagnosis/benz/211-zgw.html`""
  $html = $html -replace 'href="/zh/diagnosis/benz/om906-diag"', "href=`"${prefix}diagnosis/benz/om906-diag.html`""
  $html = $html -replace 'href="/zh/diagnosis/benz/vs30-xentry-dts"', "href=`"${prefix}diagnosis/benz/vs30-xentry-dts.html`""
  $html = $html -replace 'href="/zh/diagnosis/bmw"', "href=`"${prefix}diagnosis/bmw/index.html`""
  $html = $html -replace 'href="/zh/diagnosis/bmw/ista-guide"', "href=`"${prefix}diagnosis/bmw/ista-guide.html`""
  $html = $html -replace 'href="/zh/diagnosis/bmw/esys-guide"', "href=`"${prefix}diagnosis/bmw/esys-guide.html`""
  $html = $html -replace 'href="/zh/diagnosis/bmw/inpa-guide"', "href=`"${prefix}diagnosis/bmw/inpa-guide.html`""
  $html = $html -replace 'href="/zh/diagnosis/bmw/model-list"', "href=`"${prefix}diagnosis/bmw/model-list.html`""
  $html = $html -replace 'href="/zh/diagnosis/bmw/x5-e90-flash"', "href=`"${prefix}diagnosis/bmw/x5-e90-flash.html`""
  $html = $html -replace 'href="/zh/diagnosis/ford"', "href=`"${prefix}diagnosis/ford.html`""
  $html = $html -replace 'href="/zh/diagnosis/gm"', "href=`"${prefix}diagnosis/gm.html`""
  $html = $html -replace 'href="/zh/diagnosis/honda"', "href=`"${prefix}diagnosis/honda/index.html`""
  $html = $html -replace 'href="/zh/diagnosis/honda/hds-guide"', "href=`"${prefix}diagnosis/honda/hds-guide.html`""
  $html = $html -replace 'href="/zh/diagnosis/jlr"', "href=`"${prefix}diagnosis/jlr.html`""
  $html = $html -replace 'href="/zh/diagnosis/porsche"', "href=`"${prefix}diagnosis/porsche/index.html`""
  $html = $html -replace 'href="/zh/diagnosis/porsche/pt3g-guide"', "href=`"${prefix}diagnosis/porsche/pt3g-guide.html`""
  $html = $html -replace 'href="/zh/diagnosis/porsche/pt3g-engineer"', "href=`"${prefix}diagnosis/porsche/pt3g-engineer.html`""
  $html = $html -replace 'href="/zh/diagnosis/rmi"', "href=`"${prefix}diagnosis/rmi.html`""
  $html = $html -replace 'href="/zh/diagnosis/subaru"', "href=`"${prefix}diagnosis/subaru.html`""
  $html = $html -replace 'href="/zh/diagnosis/toyota"', "href=`"${prefix}diagnosis/toyota/index.html`""
  $html = $html -replace 'href="/zh/diagnosis/toyota/ista-guide"', "href=`"${prefix}diagnosis/toyota/ista-guide.html`""
  $html = $html -replace 'href="/zh/diagnosis/vag"', "href=`"${prefix}diagnosis/vag.html`""
  $html = $html -replace 'href="/zh/diagnosis/volvo"', "href=`"${prefix}diagnosis/volvo.html`""
  $html = $html -replace 'href="/zh/diagnosis/vw"', "href=`"${prefix}diagnosis/vw.html`""
  $html = $html -replace 'href="/zh/diagnosis/DRIVE/UPDATE"', "href=`"${prefix}diagnosis/drive-update.html`""
  $html = $html -replace 'href="/zh/diagnosis-cv"', "href=`"${prefix}diagnosis-cv/index.html`""
  $html = $html -replace 'href="/zh/diagnosis-cv/deere"', "href=`"${prefix}diagnosis-cv/deere/index.html`""
  $html = $html -replace 'href="/zh/diagnosis-cv/deere/e240lc-diag"', "href=`"${prefix}diagnosis-cv/deere/e240lc-diag.html`""
  $html = $html -replace 'href="/zh/diagnosis-cv/deere/service-advisor-guide"', "href=`"${prefix}diagnosis-cv/deere/service-advisor-guide.html`""
  $html = $html -replace 'href="/zh/release"', "href=`"${prefix}release/index.html`""
  $html = $html -replace 'href="/zh/release/update_doip"', "href=`"${prefix}release/update_doip.html`""
  $html = $html -replace 'href="/zh/release/update_vci"', "href=`"${prefix}release/update_vci.html`""
  $html = $html -replace 'href="/zh/release/update_vcxfd"', "href=`"${prefix}release/update_vcxfd.html`""
  $html = $html -replace 'href="/zh/release/vxmanager"', "href=`"${prefix}release/vxmanager.html`""
  $html = $html -replace 'href="/zh/developer"', "href=`"${prefix}developer/index.html`""

  # Fix image src: keep pointing to original wiki
  $html = $html -replace 'src="/', 'src="http://wiki.allscanner.com/'

  # Remove toc-anchor paragraph markers
  $html = $html -replace '<a href="#[^"]*" class="toc-anchor">[^<]*</a>\s*', ''

  return $html
}

function Translate-PT {
  param([string]$html)
  # Chinese -> Portuguese translations (key terms)
  $map = @{
    '欢迎使用' = 'Bem-vindo'
    '产品信息' = 'Informação do Produto'
    '产品使用指南' = 'Guia de Utilização do Produto'
    'DoNet 远程诊断' = 'DoNet Diagnóstico Remoto'
    'OEM 原厂车辆诊断' = 'Diagnóstico OEM de Veículos'
    '开发者指南' = 'Guia do Programador'
    '获取安装程序' = 'Obter o Instalador'
    '软件安装需求' = 'Requisitos de Instalação'
    '软件安装步骤' = 'Passos de Instalação'
    '连接设备和车辆' = 'Ligar Dispositivo e Veículo'
    'VCX 管理工具使用' = 'Utilização da Ferramenta VCX Manager'
    '安装原厂诊断驱动' = 'Instalar Driver de Diagnóstico OEM'
    '开始诊断' = 'Iniciar Diagnóstico'
    '处理器：' = 'Processador:'
    '内存：' = 'Memória RAM:'
    '硬盘：' = 'Disco rígido:'
    '网络接口：' = 'Interface de rede:'
    '通信接口：' = 'Interface de comunicação:'
    '无线网络：' = 'Rede sem fios:'
    '操作系统：' = 'Sistema operativo:'
    '浏览器：' = 'Browser:'
    '运行安装程序' = 'Executar o Instalador'
    '开始安装' = 'Iniciar a Instalação'
    '选择安装组件' = 'Seleccionar Componentes'
    '安装进行中' = 'Instalação em curso'
    '安装完成' = 'Instalação Concluída'
    '欢迎安装界面，点击【Next】继续。' = 'Ecrã de boas-vindas, clique em [Next] para continuar.'
    '双击运行 VX Manager 安装程序。' = 'Clique duas vezes para executar o instalador do VX Manager.'
    '安装过程可能持续数分钟，请耐心等待。' = 'O processo de instalação pode demorar alguns minutos. Aguarde.'
    '安装完成界面，点击【Finish】完成。' = 'Ecrã de conclusão, clique em [Finish] para terminar.'
    '安装完成后将在桌面和开始菜单生成 VX Manager 快捷方式。' = 'Após a instalação, será criado um atalho do VX Manager no ambiente de trabalho e no menu Iniciar.'
    '安装过程中请关闭 Windows Defender 或其他安全/杀毒软件！' = 'Durante a instalação, desactivar o Windows Defender ou outro software antivírus!'
    '注意：Windows XP 系统已经停止支持！' = 'Atenção: o Windows XP já não é suportado!'
    '重新连接' = 'Reconectar'
    '设备测试' = 'Teste do Dispositivo'
    '重启设备' = 'Reiniciar Dispositivo'
    '更新固件' = 'Actualizar Firmware'
    '更新授权' = 'Actualizar Licença'
    'DoIP开关' = 'Activar/Desactivar DoIP'
    '解除占用' = 'Libertar Ocupação'
    '错误报告' = 'Relatório de Erros'
    '检查更新' = 'Verificar Actualizações'
    '快速开始指南' = 'Guia de Início Rápido'
    '设备连接配置' = 'Configuração de Ligação do Dispositivo'
    '设备固件更新' = 'Actualização de Firmware do Dispositivo'
    '设备授权管理' = 'Gestão de Licenças do Dispositivo'
    '诊断驱动管理' = 'Gestão de Drivers de Diagnóstico'
    '常见问题解答' = 'Perguntas Frequentes (FAQ)'
    '远程诊断平台介绍' = 'Introdução à Plataforma de Diagnóstico Remoto'
    '超级远程诊断指南' = 'Guia de Super Diagnóstico Remoto'
    '兼容远程诊断指南' = 'Guia de Diagnóstico Remoto Compatível'
    '设备 IP 地址修改' = 'Modificar Endereço IP do Dispositivo'
    # Product descriptions
    'VCX 系列诊断产品选型一览' = 'Guia de Selecção de Produtos da Série VCX'
    'VCX - FD 新一代智能车辆诊断接口' = 'VCX-FD Interface de Diagnóstico Veicular Inteligente de Nova Geração'
    'VCX - DoIP 全功能 DoIP 车辆诊断设备' = 'VCX-DoIP Dispositivo de Diagnóstico Veicular DoIP Completo'
    'VCX - SE 远程车辆诊断接口' = 'VCX-SE Interface de Diagnóstico Remoto Veicular'
    'VCX - Nano 专用型车辆诊断接口' = 'VCX-Nano Interface de Diagnóstico Veicular Dedicada'
    # Misc
    '乘用车' = 'Veículos Ligeiros'
    '商用车' = 'Veículos Comerciais'
    '乘用车原厂诊断指南，包含软件介绍和诊断案例' = 'Guia de diagnóstico OEM para ligeiros, inclui introdução ao software e casos de diagnóstico'
    '商用车原厂诊断指南，包含软件介绍和诊断案例' = 'Guia de diagnóstico OEM para comerciais, inclui introdução ao software e casos de diagnóstico'
    '更多连接方式' = 'Mais modos de ligação'
    '详细了解 VCX 系列多种设备不同连接方式的使用' = 'Saiba mais sobre os diferentes modos de ligação dos dispositivos da série VCX'
    # Guide pages
    '基本功能' = 'Funções Básicas'
    '重新连接设备并刷新设备信息。' = 'Reconecta o dispositivo e actualiza as informações.'
    '设备自检和 LED 指示灯闪烁并且发出蜂鸣提示音。' = 'Auto-teste do dispositivo com piscar de LED e sinal sonoro.'
    '设备复位并重新启动运行。' = 'Repõe e reinicia o dispositivo.'
    '在线下载并更新设备固件程序。' = 'Transfere e actualiza o firmware do dispositivo online.'
    '在线下载并更新设备授权数据。' = 'Transfere e actualiza os dados de licença online.'
    '激活或关闭DoIP协议，测试车辆DoIP通信。' = 'Activa ou desactiva o protocolo DoIP para testar comunicação DoIP do veículo.'
    '设备被占用后手动解除占用释放设备。' = 'Liberta manualmente o dispositivo quando está ocupado.'
    '查看和获取设备错误日志。' = 'Visualiza e obtém o registo de erros do dispositivo.'
    '检查 VX Manager 软件是否有更新。' = 'Verifica se há actualizações disponíveis para o VX Manager.'
    '使用设备开始汽车诊断之前' = 'Antes de iniciar o diagnóstico automóvel com o dispositivo'
    '此安装程序包含在产品 CD-ROM 中' = 'Este instalador está incluído no CD-ROM do produto'
    '或者您可通过以下链接下载最新版本安装程序：' = 'ou pode transferir a versão mais recente através dos seguintes links:'
    '此过程中可以勾选要安装的原厂诊断驱动' = 'Neste passo pode seleccionar os drivers de diagnóstico OEM a instalar'
    '或者安装完成后使用 VX Mananger 自由安装需要的原厂驱动。' = 'ou instalá-los posteriormente através do VX Manager.'
    '启动 VX Manager，如果设备成功连接，将显示如下信息：' = 'Inicie o VX Manager. Se o dispositivo estiver ligado correctamente, será apresentada a seguinte informação:'
    '打开' = 'Abra'
    '页面，点击要安装的诊断应用' = 'clique na aplicação de diagnóstico a instalar'
    '在驱动信息界面中点击' = 'no ecrã de informação do driver, clique em'
    '完成驱动安装。' = 'para concluir a instalação do driver.'
    '打开 JLR Pathfinder 诊断软件，自动扫描车型信息，诊断结果如下：' = 'Abra o software JLR Pathfinder; este irá detectar automaticamente as informações do veículo. O resultado do diagnóstico é o seguinte:'
    '以 VCX-DoIP 设备通过USB连接为例，请确保设备连接正常：' = 'Exemplo com dispositivo VCX-DoIP ligado via USB. Certifique-se de que a ligação está correcta:'
    '使用 DB26-OBD 电缆连接设备至车辆。' = 'Ligue o cabo DB26-OBD do dispositivo ao veículo.'
    '使用 USB Type-B 电缆连接设备至 PC。' = 'Ligue o cabo USB Tipo-B do dispositivo ao PC.'
  }

  foreach ($key in $map.Keys) {
    $html = $html.Replace($key, $map[$key])
  }
  return $html
}

function Translate-EN {
  param([string]$html)
  $map = @{
    '欢迎使用' = 'Welcome'
    '产品信息' = 'Product Information'
    '产品使用指南' = 'Product User Guide'
    'DoNet 远程诊断' = 'DoNet Remote Diagnosis'
    'OEM 原厂车辆诊断' = 'OEM Vehicle Diagnosis'
    '开发者指南' = 'Developer Guide'
    '获取安装程序' = 'Get the Installer'
    '软件安装需求' = 'Software Requirements'
    '软件安装步骤' = 'Installation Steps'
    '连接设备和车辆' = 'Connect Device and Vehicle'
    'VCX 管理工具使用' = 'Using the VCX Manager Tool'
    '安装原厂诊断驱动' = 'Install OEM Diagnostic Driver'
    '开始诊断' = 'Start Diagnosis'
    '处理器：' = 'CPU:'
    '内存：' = 'RAM:'
    '硬盘：' = 'HDD:'
    '网络接口：' = 'Network interface:'
    '通信接口：' = 'Communication interface:'
    '无线网络：' = 'Wireless:'
    '操作系统：' = 'OS:'
    '浏览器：' = 'Browser:'
    '运行安装程序' = 'Run the Installer'
    '开始安装' = 'Begin Installation'
    '选择安装组件' = 'Select Components'
    '安装进行中' = 'Installation in Progress'
    '安装完成' = 'Installation Complete'
    '欢迎安装界面，点击【Next】继续。' = 'Welcome screen — click [Next] to continue.'
    '双击运行 VX Manager 安装程序。' = 'Double-click to run the VX Manager installer.'
    '安装过程可能持续数分钟，请耐心等待。' = 'The installation may take several minutes. Please wait.'
    '安装完成界面，点击【Finish】完成。' = 'Completion screen — click [Finish] to close.'
    '安装完成后将在桌面和开始菜单生成 VX Manager 快捷方式。' = 'After installation, a VX Manager shortcut is created on the desktop and Start menu.'
    '安装过程中请关闭 Windows Defender 或其他安全/杀毒软件！' = 'Disable Windows Defender or other antivirus software during installation!'
    '注意：Windows XP 系统已经停止支持！' = 'Note: Windows XP is no longer supported!'
    '重新连接' = 'Reconnect'
    '设备测试' = 'Device Test'
    '重启设备' = 'Restart Device'
    '更新固件' = 'Update Firmware'
    '更新授权' = 'Update License'
    'DoIP开关' = 'DoIP Toggle'
    '解除占用' = 'Release Device'
    '错误报告' = 'Error Report'
    '检查更新' = 'Check for Updates'
    '快速开始指南' = 'Quick Start Guide'
    '设备连接配置' = 'Device Connection Setup'
    '设备固件更新' = 'Device Firmware Update'
    '设备授权管理' = 'Device License Management'
    '诊断驱动管理' = 'Diagnostic Driver Management'
    '常见问题解答' = 'Frequently Asked Questions (FAQ)'
    '远程诊断平台介绍' = 'Remote Diagnosis Platform Introduction'
    '超级远程诊断指南' = 'Hyper Remote Diagnosis Guide'
    '兼容远程诊断指南' = 'Legacy Remote Diagnosis Guide'
    '设备 IP 地址修改' = 'Change Device IP Address'
    'VCX 系列诊断产品选型一览' = 'VCX Series Product Selection Guide'
    'VCX - FD 新一代智能车辆诊断接口' = 'VCX-FD Next-Gen Smart Vehicle Diagnostic Interface'
    'VCX - DoIP 全功能 DoIP 车辆诊断设备' = 'VCX-DoIP Full-Featured DoIP Vehicle Diagnostic Device'
    'VCX - SE 远程车辆诊断接口' = 'VCX-SE Remote Vehicle Diagnostic Interface'
    'VCX - Nano 专用型车辆诊断接口' = 'VCX-Nano Dedicated Vehicle Diagnostic Interface'
    '乘用车' = 'Passenger Vehicle'
    '商用车' = 'Commercial Vehicle'
    '乘用车原厂诊断指南，包含软件介绍和诊断案例' = 'OEM diagnostic guide for passenger vehicles, including software overview and diagnosis cases'
    '商用车原厂诊断指南，包含软件介绍和诊断案例' = 'OEM diagnostic guide for commercial vehicles, including software overview and diagnosis cases'
    '更多连接方式' = 'More connection methods'
    '详细了解 VCX 系列多种设备不同连接方式的使用' = 'Learn about different connection methods for VCX series devices'
    '基本功能' = 'Basic Functions'
    '重新连接设备并刷新设备信息。' = 'Reconnect device and refresh device information.'
    '设备自检和 LED 指示灯闪烁并且发出蜂鸣提示音。' = 'Device self-test with LED flash and beep.'
    '设备复位并重新启动运行。' = 'Reset and restart the device.'
    '在线下载并更新设备固件程序。' = 'Download and update device firmware online.'
    '在线下载并更新设备授权数据。' = 'Download and update device license data online.'
    '激活或关闭DoIP协议，测试车辆DoIP通信。' = 'Activate or deactivate DoIP protocol to test vehicle DoIP communication.'
    '设备被占用后手动解除占用释放设备。' = 'Manually release the device when it is occupied.'
    '查看和获取设备错误日志。' = 'View and retrieve device error log.'
    '检查 VX Manager 软件是否有更新。' = 'Check if VX Manager has updates available.'
    '使用设备开始汽车诊断之前' = 'Before starting vehicle diagnosis with the device'
    '此安装程序包含在产品 CD-ROM 中' = 'This installer is included in the product CD-ROM'
    '或者您可通过以下链接下载最新版本安装程序：' = 'or download the latest version from these links:'
    '此过程中可以勾选要安装的原厂诊断驱动' = 'You can select which OEM diagnostic drivers to install'
    '或者安装完成后使用 VX Mananger 自由安装需要的原厂驱动。' = 'or install them later using VX Manager.'
    '启动 VX Manager，如果设备成功连接，将显示如下信息：' = 'Launch VX Manager. If the device is connected successfully, the following information will be displayed:'
    '打开' = 'Open'
    '页面，点击要安装的诊断应用' = 'click the diagnostic application to install'
    '在驱动信息界面中点击' = 'in the driver info screen, click'
    '完成驱动安装。' = 'to complete driver installation.'
    '打开 JLR Pathfinder 诊断软件，自动扫描车型信息，诊断结果如下：' = 'Open JLR Pathfinder software; it will automatically scan vehicle information. The diagnosis result is as follows:'
    '以 VCX-DoIP 设备通过USB连接为例，请确保设备连接正常：' = 'Using VCX-DoIP connected via USB as an example, ensure the connection is correct:'
    '使用 DB26-OBD 电缆连接设备至车辆。' = 'Connect the DB26-OBD cable from the device to the vehicle.'
    '使用 USB Type-B 电缆连接设备至 PC。' = 'Connect the USB Type-B cable from the device to the PC.'
  }

  foreach ($key in $map.Keys) {
    $html = $html.Replace($key, $map[$key])
  }
  return $html
}

function Get-RawContent {
  param([string]$path)
  $file = "$raw/$path.html"
  if (Test-Path $file) {
    return (Get-Content $file -Raw -Encoding UTF8)
  }
  return "<p><em>Content not available.</em></p>"
}

function Write-Page {
  param(
    [string]$lang,
    [string]$outPath,     # relative to wiki/
    [string]$rawPath,     # relative to _raw/
    [string]$title_pt,
    [string]$title_en,
    [string]$breadcrumb_pt,
    [string]$breadcrumb_en,
    [string]$activePath,
    [int]$depth
  )

  $raw = Get-RawContent $rawPath
  $raw = Translate-Links $raw $lang $depth

  foreach ($l in @("pt","en")) {
    if ($lang -ne "both" -and $lang -ne $l) { continue }

    if ($l -eq "pt") {
      $content = Translate-PT $raw
      $title = $title_pt
      $bc = $breadcrumb_pt
    } else {
      $content = Translate-EN $raw
      $title = $title_en
      $bc = $breadcrumb_en
    }

    $page = Build-Page $l $title $bc $content $activePath $depth.ToString()
    $out = "$base/$l/$outPath"
    $dir = Split-Path $out
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    Set-Content -Path $out -Value $page -Encoding UTF8
    Write-Host "  [$l] $out"
  }
}

Write-Host "Building wiki pages..."

# ── HOME ─────────────────────────────────────────────────────────────────────
Write-Page -lang "both" -outPath "index.html" -rawPath "home" `
  -title_pt "Início" -title_en "Home" `
  -breadcrumb_pt "Início" -breadcrumb_en "Home" `
  -activePath "home" -depth 1

# ── GUIDE ────────────────────────────────────────────────────────────────────
Write-Page -lang "both" -outPath "guide/quickstart.html" -rawPath "guide/quickstart" `
  -title_pt "Guia de Início Rápido" -title_en "Quick Start Guide" `
  -breadcrumb_pt "Guia de Utilização > Início Rápido" -breadcrumb_en "User Guide > Quick Start" `
  -activePath "guide/quickstart" -depth 2

Write-Page -lang "both" -outPath "guide/connection.html" -rawPath "guide/connection" `
  -title_pt "Ligação do Dispositivo" -title_en "Device Connection" `
  -breadcrumb_pt "Guia de Utilização > Ligação do Dispositivo" -breadcrumb_en "User Guide > Device Connection" `
  -activePath "guide/connection" -depth 2

Write-Page -lang "both" -outPath "guide/firmware.html" -rawPath "guide/firmware" `
  -title_pt "Actualização de Firmware" -title_en "Firmware Update" `
  -breadcrumb_pt "Guia de Utilização > Actualização de Firmware" -breadcrumb_en "User Guide > Firmware Update" `
  -activePath "guide/firmware" -depth 2

Write-Page -lang "both" -outPath "guide/license.html" -rawPath "guide/license" `
  -title_pt "Gestão de Licenças" -title_en "License Management" `
  -breadcrumb_pt "Guia de Utilização > Gestão de Licenças" -breadcrumb_en "User Guide > License Management" `
  -activePath "guide/license" -depth 2

Write-Page -lang "both" -outPath "guide/diagnosis.html" -rawPath "guide/diagnosis" `
  -title_pt "Gestão de Drivers de Diagnóstico" -title_en "Diagnostic Driver Management" `
  -breadcrumb_pt "Guia de Utilização > Gestão de Drivers" -breadcrumb_en "User Guide > Driver Management" `
  -activePath "guide/diagnosis" -depth 2

Write-Page -lang "both" -outPath "guide/faq.html" -rawPath "guide/faq" `
  -title_pt "FAQ — Perguntas Frequentes" -title_en "FAQ — Frequently Asked Questions" `
  -breadcrumb_pt "Guia de Utilização > FAQ" -breadcrumb_en "User Guide > FAQ" `
  -activePath "guide/faq" -depth 2

Write-Page -lang "both" -outPath "guide/device-ip-change.html" -rawPath "guide/device-ip-change" `
  -title_pt "Alterar IP do Dispositivo" -title_en "Change Device IP" `
  -breadcrumb_pt "Guia de Utilização > Alterar IP" -breadcrumb_en "User Guide > Change Device IP" `
  -activePath "guide/device-ip-change" -depth 2

# ── PRODUCT ──────────────────────────────────────────────────────────────────
Write-Page -lang "both" -outPath "product/index.html" -rawPath "product" `
  -title_pt "Selecção de Produtos VCX" -title_en "VCX Product Selection" `
  -breadcrumb_pt "Produtos" -breadcrumb_en "Products" `
  -activePath "product" -depth 2

Write-Page -lang "both" -outPath "product/vcx-fd.html" -rawPath "product/vcx-fd" `
  -title_pt "VCX-FD" -title_en "VCX-FD" `
  -breadcrumb_pt "Produtos > VCX-FD" -breadcrumb_en "Products > VCX-FD" `
  -activePath "product/vcx-fd" -depth 2

Write-Page -lang "both" -outPath "product/vcx-doip.html" -rawPath "product/vcx-doip" `
  -title_pt "VCX-DoIP" -title_en "VCX-DoIP" `
  -breadcrumb_pt "Produtos > VCX-DoIP" -breadcrumb_en "Products > VCX-DoIP" `
  -activePath "product/vcx-doip" -depth 2

Write-Page -lang "both" -outPath "product/vcx-se.html" -rawPath "product/vcx-se" `
  -title_pt "VCX-SE" -title_en "VCX-SE" `
  -breadcrumb_pt "Produtos > VCX-SE" -breadcrumb_en "Products > VCX-SE" `
  -activePath "product/vcx-se" -depth 2

Write-Page -lang "both" -outPath "product/vcx-nano.html" -rawPath "product/vcx-nano" `
  -title_pt "VCX-Nano" -title_en "VCX-Nano" `
  -breadcrumb_pt "Produtos > VCX-Nano" -breadcrumb_en "Products > VCX-Nano" `
  -activePath "product/vcx-nano" -depth 2

# ── DONET ────────────────────────────────────────────────────────────────────
Write-Page -lang "both" -outPath "donet/intro.html" -rawPath "donet/intro" `
  -title_pt "Introdução ao DoNet" -title_en "DoNet Introduction" `
  -breadcrumb_pt "DoNet > Introdução" -breadcrumb_en "DoNet > Introduction" `
  -activePath "donet/intro" -depth 2

Write-Page -lang "both" -outPath "donet/hyper-remote.html" -rawPath "donet/hyper-remote" `
  -title_pt "Super Diagnóstico Remoto" -title_en "Hyper Remote Diagnosis" `
  -breadcrumb_pt "DoNet > Super Remoto" -breadcrumb_en "DoNet > Hyper Remote" `
  -activePath "donet/hyper-remote" -depth 2

Write-Page -lang "both" -outPath "donet/legacy-remote.html" -rawPath "donet/legacy-remote" `
  -title_pt "Diagnóstico Remoto Compatível" -title_en "Legacy Remote Diagnosis" `
  -breadcrumb_pt "DoNet > Remoto Compatível" -breadcrumb_en "DoNet > Legacy Remote" `
  -activePath "donet/legacy-remote" -depth 2

# ── DIAGNOSIS ────────────────────────────────────────────────────────────────
Write-Page -lang "both" -outPath "diagnosis/index.html" -rawPath "diagnosis" `
  -title_pt "Diagnóstico OEM — Veículos Ligeiros" -title_en "OEM Diagnosis - Passenger Vehicles" `
  -breadcrumb_pt "Diagnostico OEM - Ligeiros" -breadcrumb_en "OEM Diagnosis - Passenger" `
  -activePath "diagnosis" -depth 2

# Benz
Write-Page -lang "both" -outPath "diagnosis/benz/index.html" -rawPath "diagnosis/benz" `
  -title_pt "Mercedes-Benz" -title_en "Mercedes-Benz" `
  -breadcrumb_pt "Diagnóstico OEM > Mercedes-Benz" -breadcrumb_en "OEM Diagnosis > Mercedes-Benz" `
  -activePath "diagnosis/benz" -depth 3

Write-Page -lang "both" -outPath "diagnosis/benz/xentry-das-guide.html" -rawPath "diagnosis/benz/xentry-das-guide" `
  -title_pt "Guia XENTRY/DAS — Benz" -title_en "XENTRY/DAS Guide — Benz" `
  -breadcrumb_pt "Diagnóstico OEM > Benz > Guia XENTRY/DAS" -breadcrumb_en "OEM Diagnosis > Benz > XENTRY/DAS Guide" `
  -activePath "diagnosis/benz/xentry-das-guide" -depth 3

Write-Page -lang "both" -outPath "diagnosis/benz/dts-guide.html" -rawPath "diagnosis/benz/dts-guide" `
  -title_pt "Guia DTS — Benz" -title_en "DTS Guide — Benz" `
  -breadcrumb_pt "Diagnóstico OEM > Benz > Guia DTS" -breadcrumb_en "OEM Diagnosis > Benz > DTS Guide" `
  -activePath "diagnosis/benz/dts-guide" -depth 3

Write-Page -lang "both" -outPath "diagnosis/benz/model-list.html" -rawPath "diagnosis/benz/model-list" `
  -title_pt "Lista de Modelos — Benz" -title_en "Model List — Benz" `
  -breadcrumb_pt "Diagnóstico OEM > Benz > Lista de Modelos" -breadcrumb_en "OEM Diagnosis > Benz > Model List" `
  -activePath "diagnosis/benz/model-list" -depth 3

Write-Page -lang "both" -outPath "diagnosis/benz/me97-dts.html" -rawPath "diagnosis/benz/me97-dts" `
  -title_pt "ME97 DTS — Benz" -title_en "ME97 DTS — Benz" `
  -breadcrumb_pt "Diagnóstico OEM > Benz > ME97 DTS" -breadcrumb_en "OEM Diagnosis > Benz > ME97 DTS" `
  -activePath "diagnosis/benz/me97-dts" -depth 3

Write-Page -lang "both" -outPath "diagnosis/benz/205-doip-test.html" -rawPath "diagnosis/benz/205-doip-test" `
  -title_pt "Teste DoIP — W205 — Benz" -title_en "DoIP Test — W205 — Benz" `
  -breadcrumb_pt "Diagnóstico OEM > Benz > Teste DoIP W205" -breadcrumb_en "OEM Diagnosis > Benz > DoIP Test W205" `
  -activePath "diagnosis/benz/205-doip-test" -depth 3

Write-Page -lang "both" -outPath "diagnosis/benz/211-zgw.html" -rawPath "diagnosis/benz/211-zgw" `
  -title_pt "W211 ZGW — Benz" -title_en "W211 ZGW — Benz" `
  -breadcrumb_pt "Diagnóstico OEM > Benz > W211 ZGW" -breadcrumb_en "OEM Diagnosis > Benz > W211 ZGW" `
  -activePath "diagnosis/benz/211-zgw" -depth 3

Write-Page -lang "both" -outPath "diagnosis/benz/om906-diag.html" -rawPath "diagnosis/benz/om906-diag" `
  -title_pt "Diagnóstico OM906 — Benz" -title_en "OM906 Diagnosis — Benz" `
  -breadcrumb_pt "Diagnóstico OEM > Benz > OM906" -breadcrumb_en "OEM Diagnosis > Benz > OM906" `
  -activePath "diagnosis/benz/om906-diag" -depth 3

Write-Page -lang "both" -outPath "diagnosis/benz/vs30-xentry-dts.html" -rawPath "diagnosis/benz/vs30-xentry-dts" `
  -title_pt "VS30 XENTRY DTS — Benz" -title_en "VS30 XENTRY DTS — Benz" `
  -breadcrumb_pt "Diagnóstico OEM > Benz > VS30 XENTRY DTS" -breadcrumb_en "OEM Diagnosis > Benz > VS30 XENTRY DTS" `
  -activePath "diagnosis/benz/vs30-xentry-dts" -depth 3

# BMW
Write-Page -lang "both" -outPath "diagnosis/bmw/index.html" -rawPath "diagnosis/bmw" `
  -title_pt "BMW" -title_en "BMW" `
  -breadcrumb_pt "Diagnóstico OEM > BMW" -breadcrumb_en "OEM Diagnosis > BMW" `
  -activePath "diagnosis/bmw" -depth 3

Write-Page -lang "both" -outPath "diagnosis/bmw/ista-guide.html" -rawPath "diagnosis/bmw/ista-guide" `
  -title_pt "Guia ISTA — BMW" -title_en "ISTA Guide — BMW" `
  -breadcrumb_pt "Diagnóstico OEM > BMW > Guia ISTA" -breadcrumb_en "OEM Diagnosis > BMW > ISTA Guide" `
  -activePath "diagnosis/bmw/ista-guide" -depth 3

Write-Page -lang "both" -outPath "diagnosis/bmw/esys-guide.html" -rawPath "diagnosis/bmw/esys-guide" `
  -title_pt "Guia E-SYS — BMW" -title_en "E-SYS Guide — BMW" `
  -breadcrumb_pt "Diagnóstico OEM > BMW > Guia E-SYS" -breadcrumb_en "OEM Diagnosis > BMW > E-SYS Guide" `
  -activePath "diagnosis/bmw/esys-guide" -depth 3

Write-Page -lang "both" -outPath "diagnosis/bmw/inpa-guide.html" -rawPath "diagnosis/bmw/inpa-guide" `
  -title_pt "Guia INPA — BMW" -title_en "INPA Guide — BMW" `
  -breadcrumb_pt "Diagnóstico OEM > BMW > Guia INPA" -breadcrumb_en "OEM Diagnosis > BMW > INPA Guide" `
  -activePath "diagnosis/bmw/inpa-guide" -depth 3

Write-Page -lang "both" -outPath "diagnosis/bmw/model-list.html" -rawPath "diagnosis/bmw/model-list" `
  -title_pt "Lista de Modelos — BMW" -title_en "Model List — BMW" `
  -breadcrumb_pt "Diagnóstico OEM > BMW > Lista de Modelos" -breadcrumb_en "OEM Diagnosis > BMW > Model List" `
  -activePath "diagnosis/bmw/model-list" -depth 3

Write-Page -lang "both" -outPath "diagnosis/bmw/x5-e90-flash.html" -rawPath "diagnosis/bmw/x5-e90-flash" `
  -title_pt "Flash X5/E90 — BMW" -title_en "X5/E90 Flash — BMW" `
  -breadcrumb_pt "Diagnóstico OEM > BMW > Flash X5/E90" -breadcrumb_en "OEM Diagnosis > BMW > X5/E90 Flash" `
  -activePath "diagnosis/bmw/x5-e90-flash" -depth 3

# Others
Write-Page -lang "both" -outPath "diagnosis/ford.html" -rawPath "diagnosis/ford" `
  -title_pt "Ford" -title_en "Ford" `
  -breadcrumb_pt "Diagnóstico OEM > Ford" -breadcrumb_en "OEM Diagnosis > Ford" `
  -activePath "diagnosis/ford" -depth 2

Write-Page -lang "both" -outPath "diagnosis/gm.html" -rawPath "diagnosis/gm" `
  -title_pt "GM / Chevrolet" -title_en "GM / Chevrolet" `
  -breadcrumb_pt "Diagnóstico OEM > GM" -breadcrumb_en "OEM Diagnosis > GM" `
  -activePath "diagnosis/gm" -depth 2

Write-Page -lang "both" -outPath "diagnosis/honda/index.html" -rawPath "diagnosis/honda" `
  -title_pt "Honda" -title_en "Honda" `
  -breadcrumb_pt "Diagnóstico OEM > Honda" -breadcrumb_en "OEM Diagnosis > Honda" `
  -activePath "diagnosis/honda" -depth 3

Write-Page -lang "both" -outPath "diagnosis/honda/hds-guide.html" -rawPath "diagnosis/honda/hds-guide" `
  -title_pt "Guia HDS — Honda" -title_en "HDS Guide — Honda" `
  -breadcrumb_pt "Diagnóstico OEM > Honda > Guia HDS" -breadcrumb_en "OEM Diagnosis > Honda > HDS Guide" `
  -activePath "diagnosis/honda/hds-guide" -depth 3

Write-Page -lang "both" -outPath "diagnosis/jlr.html" -rawPath "diagnosis/jlr" `
  -title_pt "Jaguar Land Rover" -title_en "Jaguar Land Rover" `
  -breadcrumb_pt "Diagnóstico OEM > JLR" -breadcrumb_en "OEM Diagnosis > JLR" `
  -activePath "diagnosis/jlr" -depth 2

Write-Page -lang "both" -outPath "diagnosis/porsche/index.html" -rawPath "diagnosis/porsche" `
  -title_pt "Porsche" -title_en "Porsche" `
  -breadcrumb_pt "Diagnóstico OEM > Porsche" -breadcrumb_en "OEM Diagnosis > Porsche" `
  -activePath "diagnosis/porsche" -depth 3

Write-Page -lang "both" -outPath "diagnosis/porsche/pt3g-guide.html" -rawPath "diagnosis/porsche/pt3g-guide" `
  -title_pt "Guia PT3G — Porsche" -title_en "PT3G Guide — Porsche" `
  -breadcrumb_pt "Diagnóstico OEM > Porsche > Guia PT3G" -breadcrumb_en "OEM Diagnosis > Porsche > PT3G Guide" `
  -activePath "diagnosis/porsche/pt3g-guide" -depth 3

Write-Page -lang "both" -outPath "diagnosis/porsche/pt3g-engineer.html" -rawPath "diagnosis/porsche/pt3g-engineer" `
  -title_pt "PT3G Engineer — Porsche" -title_en "PT3G Engineer — Porsche" `
  -breadcrumb_pt "Diagnóstico OEM > Porsche > PT3G Engineer" -breadcrumb_en "OEM Diagnosis > Porsche > PT3G Engineer" `
  -activePath "diagnosis/porsche/pt3g-engineer" -depth 3

Write-Page -lang "both" -outPath "diagnosis/rmi.html" -rawPath "diagnosis/rmi" `
  -title_pt "RMI" -title_en "RMI" `
  -breadcrumb_pt "Diagnóstico OEM > RMI" -breadcrumb_en "OEM Diagnosis > RMI" `
  -activePath "diagnosis/rmi" -depth 2

Write-Page -lang "both" -outPath "diagnosis/subaru.html" -rawPath "diagnosis/subaru" `
  -title_pt "Subaru" -title_en "Subaru" `
  -breadcrumb_pt "Diagnóstico OEM > Subaru" -breadcrumb_en "OEM Diagnosis > Subaru" `
  -activePath "diagnosis/subaru" -depth 2

Write-Page -lang "both" -outPath "diagnosis/toyota/index.html" -rawPath "diagnosis/toyota" `
  -title_pt "Toyota" -title_en "Toyota" `
  -breadcrumb_pt "Diagnóstico OEM > Toyota" -breadcrumb_en "OEM Diagnosis > Toyota" `
  -activePath "diagnosis/toyota" -depth 3

Write-Page -lang "both" -outPath "diagnosis/toyota/ista-guide.html" -rawPath "diagnosis/toyota/ista-guide" `
  -title_pt "Guia ISTA — Toyota" -title_en "ISTA Guide — Toyota" `
  -breadcrumb_pt "Diagnóstico OEM > Toyota > Guia ISTA" -breadcrumb_en "OEM Diagnosis > Toyota > ISTA Guide" `
  -activePath "diagnosis/toyota/ista-guide" -depth 3

Write-Page -lang "both" -outPath "diagnosis/vag.html" -rawPath "diagnosis/vag" `
  -title_pt "VAG (VW/Audi/Seat/Skoda)" -title_en "VAG (VW/Audi/Seat/Skoda)" `
  -breadcrumb_pt "Diagnóstico OEM > VAG" -breadcrumb_en "OEM Diagnosis > VAG" `
  -activePath "diagnosis/vag" -depth 2

Write-Page -lang "both" -outPath "diagnosis/volvo.html" -rawPath "diagnosis/volvo" `
  -title_pt "Volvo" -title_en "Volvo" `
  -breadcrumb_pt "Diagnóstico OEM > Volvo" -breadcrumb_en "OEM Diagnosis > Volvo" `
  -activePath "diagnosis/volvo" -depth 2

Write-Page -lang "both" -outPath "diagnosis/vw.html" -rawPath "diagnosis/vw" `
  -title_pt "Volkswagen" -title_en "Volkswagen" `
  -breadcrumb_pt "Diagnóstico OEM > VW" -breadcrumb_en "OEM Diagnosis > VW" `
  -activePath "diagnosis/vw" -depth 2

Write-Page -lang "both" -outPath "diagnosis/drive-update.html" -rawPath "diagnosis/DRIVE/UPDATE" `
  -title_pt "DRIVE Update" -title_en "DRIVE Update" `
  -breadcrumb_pt "Diagnóstico OEM > DRIVE Update" -breadcrumb_en "OEM Diagnosis > DRIVE Update" `
  -activePath "diagnosis/DRIVE/UPDATE" -depth 2

# GDS2
Write-Page -lang "both" -outPath "diagnosis/gm/gds2-device-not-detected.html" -rawPath "diagnosis/gm/gds2-device-not-detected" `
  -title_pt "GDS2 — Dispositivo Não Detectado" -title_en "GDS2 — Device Not Detected" `
  -breadcrumb_pt "Diagnóstico OEM > GM > GDS2 Dispositivo Não Detectado" -breadcrumb_en "OEM Diagnosis > GM > GDS2 Device Not Detected" `
  -activePath "diagnosis/gm/gds2" -depth 3

# Subaru SSM
Write-Page -lang "both" -outPath "diagnosis/subaru/ssm-install-error.html" -rawPath "diagnosis/subaru/ssm-install-error" `
  -title_pt "SSM — Erro de Instalação — Subaru" -title_en "SSM Install Error — Subaru" `
  -breadcrumb_pt "Diagnóstico OEM > Subaru > Erro SSM" -breadcrumb_en "OEM Diagnosis > Subaru > SSM Error" `
  -activePath "diagnosis/subaru" -depth 3

# ── DIAGNOSIS-CV ─────────────────────────────────────────────────────────────
Write-Page -lang "both" -outPath "diagnosis-cv/index.html" -rawPath "diagnosis-cv" `
  -title_pt "Diagnóstico OEM — Veículos Comerciais" -title_en "OEM Diagnosis - Commercial Vehicles" `
  -breadcrumb_pt "Diagnostico OEM - Comerciais" -breadcrumb_en "OEM Diagnosis - Commercial" `
  -activePath "diagnosis-cv" -depth 2

Write-Page -lang "both" -outPath "diagnosis-cv/deere/index.html" -rawPath "diagnosis-cv/deere" `
  -title_pt "John Deere" -title_en "John Deere" `
  -breadcrumb_pt "Diagnóstico OEM > John Deere" -breadcrumb_en "OEM Diagnosis > John Deere" `
  -activePath "diagnosis-cv/deere" -depth 3

Write-Page -lang "both" -outPath "diagnosis-cv/deere/e240lc-diag.html" -rawPath "diagnosis-cv/deere/e240lc-diag" `
  -title_pt "Diagnóstico E240LC — John Deere" -title_en "E240LC Diagnosis — John Deere" `
  -breadcrumb_pt "Diagnóstico OEM > John Deere > E240LC" -breadcrumb_en "OEM Diagnosis > John Deere > E240LC" `
  -activePath "diagnosis-cv/deere/e240lc-diag" -depth 3

Write-Page -lang "both" -outPath "diagnosis-cv/deere/service-advisor-guide.html" -rawPath "diagnosis-cv/deere/service-advisor-guide" `
  -title_pt "Guia Service ADVISOR" -title_en "Service ADVISOR Guide" `
  -breadcrumb_pt "Diagnóstico OEM > John Deere > Service ADVISOR" -breadcrumb_en "OEM Diagnosis > John Deere > Service ADVISOR" `
  -activePath "diagnosis-cv/deere/service-advisor-guide" -depth 3

# ── RELEASE ──────────────────────────────────────────────────────────────────
Write-Page -lang "both" -outPath "release/index.html" -rawPath "release" `
  -title_pt "Lançamentos e Actualizações" -title_en "Releases and Updates" `
  -breadcrumb_pt "Lançamentos" -breadcrumb_en "Releases" `
  -activePath "release" -depth 2

Write-Page -lang "both" -outPath "release/update_vci.html" -rawPath "release/update_vci" `
  -title_pt "Actualizações VCI" -title_en "VCI Updates" `
  -breadcrumb_pt "Lançamentos > Actualizações VCI" -breadcrumb_en "Releases > VCI Updates" `
  -activePath "release/update_vci" -depth 2

Write-Page -lang "both" -outPath "release/update_doip.html" -rawPath "release/update_doip" `
  -title_pt "Actualizações DoIP" -title_en "DoIP Updates" `
  -breadcrumb_pt "Lançamentos > Actualizações DoIP" -breadcrumb_en "Releases > DoIP Updates" `
  -activePath "release/update_doip" -depth 2

Write-Page -lang "both" -outPath "release/update_vcxfd.html" -rawPath "release/update_vcxfd" `
  -title_pt "Actualizações VCX-FD" -title_en "VCX-FD Updates" `
  -breadcrumb_pt "Lançamentos > Actualizações VCX-FD" -breadcrumb_en "Releases > VCX-FD Updates" `
  -activePath "release/update_vcxfd" -depth 2

Write-Page -lang "both" -outPath "release/vxmanager.html" -rawPath "release/vxmanager" `
  -title_pt "Actualizações VX Manager" -title_en "VX Manager Updates" `
  -breadcrumb_pt "Lançamentos > VX Manager" -breadcrumb_en "Releases > VX Manager" `
  -activePath "release/vxmanager" -depth 2

# ── DEVELOPER ────────────────────────────────────────────────────────────────
Write-Page -lang "both" -outPath "developer/index.html" -rawPath "developer" `
  -title_pt "Guia do Programador" -title_en "Developer Guide" `
  -breadcrumb_pt "Guia do Programador" -breadcrumb_en "Developer Guide" `
  -activePath "developer" -depth 2

Write-Host ""
Write-Host "Done! All pages written."

