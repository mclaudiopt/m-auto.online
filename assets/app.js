/**
 * M-AUTO ONLINE — app.js
 * Arquitectura: dados em JSON, lógica aqui, HTML é apenas shell.
 */

/* ─────────────────────────────────────────────
   1. TRADUÇÕES UI (botões, nav, labels, wizard)
   Dados de produto ficam em catalog.json
───────────────────────────────────────────── */
const TRANS = {
  pt: {
    nav_soft: "Software", nav_all: "Tudo", nav_hard: "Hardware", nav_tools: "Downloads",
    nav_serv: "Serviços", nav_about: "Sobre",
    mob_soft: "Soft", mob_hard: "Hard", mob_tools: "DL", mob_serv: "Serv", mob_about: "Info",
    btn_order: "Encomendar", btn_download: "Download", btn_details: "Detalhes",
    btn_schedule: "Agendar", btn_close: "Fechar",
    price_consult: "Consulta", price_pack: "Pack Completo",
    badge_best: "Melhor Escolha", badge_top: "Mais Vendido",
    hero_sol: "Soluções Online", hero_desc: "Instalação remota profissional.",
    modal_order: "Encomendar", modal_no_details: "Detalhes não disponíveis.",
    search_placeholder: "🔍 Procurar...",
    meta_version: "Versão", meta_year: "Ano", meta_os: "Sistema",
    brand_multi: "Multimarca",
    hard_title: "Hardware", tools_title: "Downloads", serv_title: "Serviços",
    about_title: "Sobre",
    tools_meta: "Instalação remota assistida",
    about_text: "O que nos distingue é a qualidade do suporte e a experiência real em soluções que funcionam. Instalação remota assistida, aconselhamento gratuito e respostas rápidas — a confiança de quem já ajudou centenas de profissionais em toda a Europa.",
    about_wm: "SOBRE",
    serv_wm: "SERVIÇOS",
    popup_viewers: "visitantes online",
    popup_consult: "Outros softwares disponíveis — consulte-nos.",
    serv_contact: "Consultar",
    search_no_results: "Sem resultados para",
    wiz_os: "Que Windows tem?", wiz_ram: "Memória RAM?",
    wiz_disk: "Tipo de disco?", wiz_brand: "Marca do veículo?",
    wiz_result_title: "Resultado",
    wiz_restart: "Recomeçar 🔄",
    wiz_compatible_title: "✅ PC Compatível!",
    wiz_compatible_msg: "O seu PC pode instalar o Pack Completo.",
    wiz_limited_title: "⚠️ PC Limitado",
    wiz_limited_msg: "Recomendamos upgrade de hardware para melhor desempenho.",
    wiz_win_old: "Windows 7 / 8", wiz_win_new: "Windows 10 / 11",
    wiz_ram_low: "4 GB ou menos", wiz_ram_high: "8 GB ou mais",
    wiz_disk_hdd: "HDD", wiz_disk_ssd: "SSD",
    wiz_brand_merc: "Mercedes", wiz_brand_bmw: "BMW",
    wiz_sub_win_old: "Legado", wiz_sub_win_new: "Recomendado ✓",
    wiz_sub_ram_low: "Básico", wiz_sub_ram_high: "Ideal ✓",
    wiz_sub_disk_hdd: "Mecânico", wiz_sub_disk_ssd: "Rápido ✓",
    wiz_brand_other: "Outra marca",
    brand_hero_eyebrow: "Software de Diagnóstico",
    brand_hero_products: "produtos",
    brand_hero_meta: "Instalação remota profissional",
    about_cta: "Ver Software →",
    about_feat_install: "Instalação remota profissional",
    about_feat_brands: "Mercedes · BMW · VAG · PSA · Toyota e mais",
    about_feat_support: "Suporte rápido e garantido",
    wa_interest: "Olá! Tenho interesse em:",
    wa_general: "Olá! Gostaria de obter mais informações sobre os vossos softwares de diagnóstico."
  },
  en: {
    nav_soft: "Software", nav_all: "All", nav_hard: "Hardware", nav_tools: "Downloads",
    nav_serv: "Services", nav_about: "About",
    mob_soft: "Soft", mob_hard: "Hard", mob_tools: "DL", mob_serv: "Serv", mob_about: "Info",
    btn_order: "Order", btn_download: "Download", btn_details: "Details",
    btn_schedule: "Book", btn_close: "Close",
    price_consult: "On request", price_pack: "Full Pack",
    badge_best: "Best Choice", badge_top: "Best Seller",
    hero_sol: "Online Solutions", hero_desc: "Professional remote installation.",
    modal_order: "Order", modal_no_details: "Details not available.",
    search_placeholder: "🔍 Search...",
    meta_version: "Version", meta_year: "Year", meta_os: "OS",
    brand_multi: "Multi-brand",
    hard_title: "Hardware", tools_title: "Downloads", serv_title: "Services",
    about_title: "About",
    tools_meta: "Remote assisted installation",
    about_text: "What sets us apart is the quality of our support and real hands-on experience. We work with solutions that genuinely work — remote assisted installation, free advice and fast responses. Trusted by hundreds of professionals across Europe.",
    about_wm: "ABOUT",
    serv_wm: "SERVICES",
    popup_viewers: "visitors online",
    popup_consult: "More software available — ask us.",
    serv_contact: "Contact us",
    search_no_results: "No results for",
    wiz_os: "Which Windows?", wiz_ram: "RAM memory?",
    wiz_disk: "Disk type?", wiz_brand: "Vehicle brand?",
    wiz_result_title: "Result",
    wiz_restart: "Restart 🔄",
    wiz_compatible_title: "✅ Compatible PC!",
    wiz_compatible_msg: "Your PC can run the Full Pack.",
    wiz_limited_title: "⚠️ Limited PC",
    wiz_limited_msg: "We recommend a hardware upgrade for better performance.",
    wiz_win_old: "Windows 7 / 8", wiz_win_new: "Windows 10 / 11",
    wiz_ram_low: "4 GB or less", wiz_ram_high: "8 GB or more",
    wiz_disk_hdd: "HDD", wiz_disk_ssd: "SSD",
    wiz_brand_merc: "Mercedes", wiz_brand_bmw: "BMW",
    wiz_sub_win_old: "Legacy", wiz_sub_win_new: "Recommended ✓",
    wiz_sub_ram_low: "Basic", wiz_sub_ram_high: "Ideal ✓",
    wiz_sub_disk_hdd: "Mechanical", wiz_sub_disk_ssd: "Fast ✓",
    wiz_brand_other: "Other brand",
    brand_hero_eyebrow: "Diagnostic Software",
    brand_hero_products: "products",
    brand_hero_meta: "Professional remote installation",
    about_cta: "View Software →",
    about_feat_install: "Professional remote installation",
    about_feat_brands: "Mercedes · BMW · VAG · PSA · Toyota and more",
    about_feat_support: "Fast and guaranteed support",
    wa_interest: "Hello! I'm interested in:",
    wa_general: "Hello! I would like more information about your diagnostic software."
  },
  fr: {
    nav_soft: "Logiciel", nav_all: "Tout", nav_hard: "Matériel", nav_tools: "Téléchargements",
    nav_serv: "Services", nav_about: "À Propos",
    mob_soft: "Soft", mob_hard: "Hard", mob_tools: "DL", mob_serv: "Serv", mob_about: "Info",
    btn_order: "Commander", btn_download: "Télécharger", btn_details: "Détails",
    btn_schedule: "Planifier", btn_close: "Fermer",
    price_consult: "Sur demande", price_pack: "Pack Complet",
    badge_best: "Meilleur Choix", badge_top: "Best Seller",
    hero_sol: "Solutions En Ligne", hero_desc: "Installation à distance professionnelle.",
    modal_order: "Commander", modal_no_details: "Détails non disponibles.",
    search_placeholder: "🔍 Rechercher...",
    meta_version: "Version", meta_year: "Année", meta_os: "Système",
    brand_multi: "Multimarque",
    hard_title: "Matériel", tools_title: "Téléchargements", serv_title: "Services",
    about_title: "À Propos",
    tools_meta: "Installation à distance assistée",
    about_text: "Ce qui nous distingue, c'est la qualité du support et l'expérience réelle avec des solutions qui fonctionnent. Installation à distance assistée, conseils gratuits et réponses rapides — la confiance de centaines de professionnels à travers l'Europe.",
    about_wm: "À PROPOS",
    serv_wm: "SERVICES",
    popup_viewers: "personnes en ligne",
    popup_consult: "Plus de logiciels disponibles — contactez-nous.",
    serv_contact: "Nous contacter",
    search_no_results: "Aucun résultat pour",
    wiz_os: "Quel Windows ?", wiz_ram: "Mémoire RAM ?",
    wiz_disk: "Type de disque ?", wiz_brand: "Marque du véhicule ?",
    wiz_result_title: "Résultat",
    wiz_restart: "Recommencer 🔄",
    wiz_compatible_title: "✅ PC Compatible !",
    wiz_compatible_msg: "Votre PC peut installer le Pack Complet.",
    wiz_limited_title: "⚠️ PC Limité",
    wiz_limited_msg: "Nous recommandons une mise à niveau matérielle.",
    wiz_win_old: "Windows 7 / 8", wiz_win_new: "Windows 10 / 11",
    wiz_ram_low: "4 Go ou moins", wiz_ram_high: "8 Go ou plus",
    wiz_disk_hdd: "HDD", wiz_disk_ssd: "SSD",
    wiz_brand_merc: "Mercedes", wiz_brand_bmw: "BMW",
    wiz_sub_win_old: "Ancien", wiz_sub_win_new: "Recommandé ✓",
    wiz_sub_ram_low: "Basique", wiz_sub_ram_high: "Idéal ✓",
    wiz_sub_disk_hdd: "Mécanique", wiz_sub_disk_ssd: "Rapide ✓",
    wiz_brand_other: "Autre marque",
    brand_hero_eyebrow: "Logiciel de Diagnostic",
    brand_hero_products: "produits",
    brand_hero_meta: "Installation à distance professionnelle",
    about_cta: "Voir les Logiciels →",
    about_feat_install: "Installation à distance professionnelle",
    about_feat_brands: "Mercedes · BMW · VAG · PSA · Toyota et plus",
    about_feat_support: "Support rapide et garanti",
    wa_interest: "Bonjour ! Je suis intéressé par :",
    wa_general: "Bonjour ! Je souhaite obtenir plus d'informations sur vos logiciels de diagnostic."
  }
};

/* ─────────────────────────────────────────────
   2. CONFIG DE MARCAS (ordem da sidebar)
───────────────────────────────────────────── */
const BRANDS = [
  { id:"mercedes", label:"Mercedes-Benz",  color:"#163354", colorLight:"#eef2f8", colorMid:"#4a6fa0", abbr:"MB",  watermark:"MERCEDES" },
  { id:"vag",      label:"VAG Group",      color:"#003fa5", colorLight:"#e8efff", colorMid:"#80a4e8", abbr:"VAG", watermark:"VAG" },
  { id:"bmw",      label:"BMW / Mini",     color:"#0053a0", colorLight:"#e8f2ff", colorMid:"#6aace0", abbr:"BMW", watermark:"BMW" },
  { id:"psa",      label:"PSA Group",      color:"#6d1fa0", colorLight:"#f3edff", colorMid:"#b47dd4", abbr:"PSA", watermark:"PSA" },
  { id:"renault",  label:"Renault / Dacia",color:"#c8a000", colorLight:"#fff9e0", colorMid:"#e8c850", abbr:"RNL", watermark:"RENAULT" },
  { id:"jlr",      label:"JLR",            color:"#1e5c3a", colorLight:"#eaf4ee", colorMid:"#72b08a", abbr:"JLR", watermark:"JAGUAR" },
  { id:"toyota",   label:"Toyota",         color:"#cc0000", colorLight:"#fff0f0", colorMid:"#f08080", abbr:"TYT", watermark:"TOYOTA" },
  { id:"nissan",   label:"Nissan",         color:"#b8002c", colorLight:"#fff0f3", colorMid:"#e87890", abbr:"NSN", watermark:"NISSAN" },
  { id:"ford",     label:"Ford",           color:"#003478", colorLight:"#e8eefb", colorMid:"#6080d0", abbr:"FRD", watermark:"FORD" },
  { id:"gm",       label:"General Motors",  color:"#1c4077", colorLight:"#e8eef8", colorMid:"#6080c0", abbr:"GM",  watermark:"GENERAL MOTORS" },
  { id:"multi",    label:"brand_multi",    color:"#374151", colorLight:"#f3f4f6", colorMid:"#9ca3af", abbr:"MUL", watermark:"MULTI" }
];

/* ─────────────────────────────────────────────
   2b. BRAND THEME
───────────────────────────────────────────── */
function setBrandTheme(brand) {
  const r = document.documentElement.style;
  r.setProperty('--brand-color', brand.color);
  r.setProperty('--brand-light', brand.colorLight);
  r.setProperty('--brand-mid',   brand.colorMid);
}

/* ─────────────────────────────────────────────
   3. ESTADO GLOBAL
───────────────────────────────────────────── */
let catalog   = [];
let services  = [];
let tools     = [];
let lang      = 'pt';
let activeSection = 'about';
let activeBrand   = 'mercedes';
let confirmedBrand = null; // null = utilizador ainda não escolheu marca
let dataLoaded    = false;
let swipeHintShown = false;

/* ─────────────────────────────────────────────
   4. UTILITÁRIOS
───────────────────────────────────────────── */
function t(key) {
  return (TRANS[lang] && TRANS[lang][key] !== undefined) ? TRANS[lang][key] : (TRANS.pt[key] || key);
}

function prodData(item) {
  return item[lang] || item.pt || {};
}

const ICON_ELLIPSIS = `<svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor" aria-hidden="true"><circle cx="5" cy="12" r="2"/><circle cx="12" cy="12" r="2"/><circle cx="19" cy="12" r="2"/></svg>`;
const ICON_DOWNLOAD = `<svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor" aria-hidden="true"><path d="M12 3v10.17l3.59-3.58L17 11l-5 5-5-5 1.41-1.41L11 13.17V3zM5 19h14v2H5z"/></svg>`;
const ICON_EYE = `<svg viewBox="0 0 24 24" width="14" height="14" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/></svg>`;

// Hover no dropdown de marcas — selecciona marca sem fechar dropdown
function hoverSelectBrand(brandId) {
  if (activeBrand === brandId) return;
  activeBrand = brandId;
  const brand = BRANDS.find(b => b.id === brandId) || BRANDS[0];
  setBrandTheme(brand);
  activeSection = 'soft';
  document.querySelectorAll('.section-view').forEach(p => p.classList.remove('active'));
  document.getElementById('sec-soft')?.classList.add('active');
  renderBrand(brandId);
  document.querySelectorAll('.nav-dd-item').forEach(b =>
    b.classList.toggle('active', b.dataset.brandId === brandId));
}

// Landing "Escolha Software" — mostrada quando dropdown abre antes de escolher marca
function renderSoftLanding() {
  const panel = document.getElementById('brand-active');
  if (!panel) return;
  const titles    = { pt: 'Software de Diagnóstico', en: 'Diagnostic Software', fr: 'Logiciel de Diagnostic' };
  const subtitles = { pt: 'Escolha a marca do veículo para ver os produtos disponíveis.', en: 'Select a vehicle brand to view available products.', fr: 'Sélectionnez une marque pour voir les produits disponibles.' };
  const brandBtns = BRANDS.map(b => {
    const lbl = b.label.startsWith('brand_') ? t(b.label) : b.label;
    return `<button class="soft-landing-brand-btn" onclick="selectBrandFromNav('${b.id}')"
      style="--b-color:${b.color};--b-light:${b.colorLight}">
      <span class="soft-landing-brand-icon" style="background:${b.color}">${b.abbr}</span>
      <span>${lbl}</span>
    </button>`;
  }).join('');
  panel.innerHTML = `
    <div class="soft-landing">
      <div class="soft-landing-wm">SOFTWARE</div>
      <div class="soft-landing-content">
        <p class="soft-landing-eyebrow">M-Auto Online</p>
        <h2 class="soft-landing-title">${titles[lang] || titles.pt}</h2>
        <p class="soft-landing-sub">${subtitles[lang] || subtitles.pt}</p>
        <div class="soft-landing-brands">${brandBtns}</div>
      </div>
    </div>
  `;
  applyWmOffset(panel);
}

// Swipe hint — aparece apenas 1× em mobile ao entrar na sec. Software
function showSwipeHint() {
  if (!window.matchMedia('(hover: none)').matches) return; // skip desktop
  swipeHintShown = true;
  const hint = document.createElement('div');
  hint.className = 'swipe-hint';
  const labels = { pt: '← deslize para mudar marca →', en: '← swipe to change brand →', fr: '← glissez pour changer de marque →' };
  hint.textContent = labels[lang] || labels.pt;
  document.body.appendChild(hint);
  setTimeout(() => hint.remove(), 3200);
}

// Hover-nav desktop: mudar secção ao passar o rato (com pequeno delay)
let _navHoverTimer = null;
function scheduleNavHover(id, btn) {
  if (window.matchMedia('(hover: none)').matches) return;
  clearTimeout(_navHoverTimer);
  _navHoverTimer = setTimeout(() => {
    if (activeSection !== id) switchSection(id, btn);
  }, 180);
}
function cancelNavHover() { clearTimeout(_navHoverTimer); }

// Offset aleatório no watermark para evitar sempre começar da posição inicial
function applyWmOffset(container) {
  const wm = container?.querySelector('.brand-hero-wm, .section-hero-wm');
  if (wm) wm.style.animationDelay = `-${(Math.random() * 22).toFixed(2)}s`;
}

function renderSkeletonCards(n = 6) {
  return Array(n).fill(0).map(() => `
    <div class="card card-skeleton">
      <div class="skel skel-bar"></div>
      <div class="card-body">
        <div class="skel skel-h3"></div>
        <div class="skel skel-p1"></div>
        <div class="skel skel-p2"></div>
      </div>
    </div>`).join('');
}

function initBrandSwipe() {
  const sec = document.getElementById('sec-soft');
  if (!sec) return;
  let startX = 0, startY = 0, startT = 0, moving = false;
  sec.addEventListener('touchstart', e => {
    startX = e.touches[0].clientX;
    startY = e.touches[0].clientY;
    startT = Date.now();
    moving = false;
  }, { passive: true });
  sec.addEventListener('touchmove', e => {
    if (!moving) {
      const dx = Math.abs(e.touches[0].clientX - startX);
      const dy = Math.abs(e.touches[0].clientY - startY);
      if (dx > dy && dx > 10) moving = true;
    }
  }, { passive: true });
  sec.addEventListener('touchend', e => {
    if (!moving) return;
    const dx = e.changedTouches[0].clientX - startX;
    if (Math.abs(dx) > 50 && Date.now() - startT < 500) {
      const ids = BRANDS.map(b => b.id);
      const i = ids.indexOf(activeBrand);
      if (dx < 0 && i < ids.length - 1) selectBrandFromNav(ids[i + 1]);
      else if (dx > 0 && i > 0)         selectBrandFromNav(ids[i - 1]);
    }
    moving = false;
  }, { passive: true });
}

/* ─────────────────────────────────────────────
   5. INICIALIZAÇÃO
───────────────────────────────────────────── */
window.addEventListener('DOMContentLoaded', async () => {
  // HERO DISABLED — código guardado para uso futuro (ver função loadHero + startTypewriter abaixo)
  // await loadHero();
  // startTypewriter();

  try {
    const [cat, srv, tls] = await Promise.all([
      fetch('data/catalog.json').then(r => r.json()),
      fetch('data/services.json').then(r => r.json()),
      fetch('data/tools.json').then(r => r.json())
    ]);
    catalog  = cat;
    services = srv;
    tools    = tls;
    dataLoaded = true;
  } catch(e) {
    console.error('Erro ao carregar dados:', e);
  }

  // Detectar língua: localStorage → browser → fallback pt
  let saved = null;
  try { saved = localStorage.getItem('mauto_lang'); } catch(e) {}
  const detected = (navigator.language || 'pt').split('-')[0].toLowerCase();
  lang = (saved && TRANS[saved]) ? saved : (TRANS[detected] ? detected : 'pt');

  buildNav();
  setBrandTheme(BRANDS[0]); // tema inicial: Mercedes
  renderSection('about');   // página inicial = SOBRE
  applyLang();
  initBrandSwipe();

  // Popup de visitantes — inicia após 8s, depois disparo aleatório periódico
  setTimeout(showViewersPopup, 8000);

  // Scroll top
  const scrollBtn = document.getElementById('scrollTopBtn');
  if (scrollBtn) {
    scrollBtn.classList.add('fab-scroll-top');
    window.addEventListener('scroll', () => {
      scrollBtn.classList.toggle('visible', window.scrollY > 200);
    });
  }

  // Fechar modal ao clicar fora
  document.getElementById('productModal')?.addEventListener('click', e => {
    if (e.target.id === 'productModal') closeProductModal();
  });
});

/* ─────────────────────────────────────────────
   6. HERO (partial externo)
───────────────────────────────────────────── */
function loadHero() {
  const mount = document.getElementById('heroMount');
  if (!mount) return Promise.resolve();
  return fetch('partials/hero.html', { cache: 'no-store' })
    .then(r => { if (!r.ok) throw new Error(); return r.text(); })
    .then(html => { mount.innerHTML = html; })
    .catch(() => {});
}

/* ─────────────────────────────────────────────
   7. NAV DINÂMICO
───────────────────────────────────────────── */
function buildNav() {
  const mainNav = document.querySelector('.main-nav');
  const mobNav  = document.querySelector('.mobile-nav');
  if (!mainNav || !mobNav) return;

  // Dropdown de marcas para SOFTWARE
  const isAllActive = activeSection === 'soft' && !confirmedBrand;
  const _softTotal = catalog.filter(p => p.section === 'soft').length;
  const allItem = `<button type="button" class="nav-dd-item nav-dd-all${isAllActive ? ' active' : ''}"
    onclick="selectAllBrands()" data-brand-id="all">
    <span class="nav-dd-icon nav-dd-icon-all">≡</span>
    <span class="nav-dd-label">${t('nav_all')}</span>
    ${_softTotal > 0 ? `<span class="nav-dd-count">${_softTotal}</span>` : ''}
  </button>`;
  const brandItems = allItem + BRANDS.map(b => {
    const label = b.label.startsWith('brand_') ? t(b.label) : b.label;
    const count = catalog.filter(p => p.section === 'soft' && p.brand === b.id).length;
    return `<button type="button" class="nav-dd-item${confirmedBrand === b.id ? ' active' : ''}"
      onclick="selectBrandFromNav('${b.id}')" data-brand-id="${b.id}"
      onmouseenter="hoverSelectBrand('${b.id}')">
      <span class="nav-dd-icon" style="background:${b.color}">${b.abbr}</span>
      <span class="nav-dd-label">${label}</span>
      ${count > 0 ? `<span class="nav-dd-count">${count}</span>` : ''}
    </button>`;
  }).join('');

  const softCount  = catalog.filter(p => p.section === 'soft').length;
  const hardCount  = catalog.filter(p => p.section === 'hard').length;
  const toolCount  = tools.length;
  const servCount  = services.length;
  const nb = n => n > 0 ? `<span class="nav-pill-count">${n}</span>` : '';

  mainNav.innerHTML = `
    <div class="nav-dropdown-wrap${activeSection === 'soft' ? ' nav-sec-active' : ''}" id="softDropdown"
      onmouseenter="openSoftDropdown()" onmouseleave="closeSoftDropdown()">
      <button type="button" class="nav-pill${activeSection === 'soft' ? ' active' : ''}"
        onclick="toggleSoftDropdown(event)" data-nav-key="nav_soft">
        <span class="nav-pill-label">${t('nav_soft')}</span>${nb(softCount)}
        <span class="nav-dd-arrow">▾</span>
      </button>
      <div class="nav-dropdown-menu" id="softDropdownMenu">${brandItems}</div>
    </div>
    <button type="button" class="nav-pill${activeSection === 'hard'  ? ' active' : ''}"
      onclick="switchSection('hard',  this)"
      onmouseenter="scheduleNavHover('hard', this)" onmouseleave="cancelNavHover()"
      data-nav-key="nav_hard">${t('nav_hard')}${nb(hardCount)}</button>
    <button type="button" class="nav-pill${activeSection === 'tools' ? ' active' : ''}"
      onclick="switchSection('tools', this)"
      onmouseenter="scheduleNavHover('tools', this)" onmouseleave="cancelNavHover()"
      data-nav-key="nav_tools">${t('nav_tools')}${nb(toolCount)}</button>
    <button type="button" class="nav-pill${activeSection === 'serv'  ? ' active' : ''}"
      onclick="switchSection('serv',  this)"
      onmouseenter="scheduleNavHover('serv', this)" onmouseleave="cancelNavHover()"
      data-nav-key="nav_serv">${t('nav_serv')}${nb(servCount)}</button>
    <button type="button" class="nav-pill${activeSection === 'about' ? ' active' : ''}"
      onclick="switchSection('about', this)"
      onmouseenter="scheduleNavHover('about', this)" onmouseleave="cancelNavHover()"
      data-nav-key="nav_about">${t('nav_about')}</button>
  `;

  mobNav.innerHTML = [
    { id: 'soft',  icon: 'fa-solid fa-car-side',           key: 'mob_soft',  fn: `toggleMobBrandPicker()` },
    { id: 'hard',  icon: 'fa-solid fa-microchip',          key: 'mob_hard',  fn: `switchSection('hard',  this)` },
    { id: 'tools', icon: 'fa-solid fa-download',           key: 'mob_tools', fn: `switchSection('tools', this)` },
    { id: 'serv',  icon: 'fa-solid fa-screwdriver-wrench', key: 'mob_serv',  fn: `switchSection('serv',  this)` },
    { id: 'about', icon: 'fa-solid fa-circle-info',        key: 'mob_about', fn: `switchSection('about', this)` },
  ].map(n => `<div class="mob-item${activeSection === n.id ? ' active' : ''}"
    onclick="${n.fn}" data-nav-key="${n.key}">
    <i class="${n.icon} mob-icon"></i>
    <span class="mob-label">${t(n.key)}</span>
  </div>`).join('');
}

/* ── MOBILE BRAND PICKER (bottom sheet) ── */
function toggleMobBrandPicker() {
  let sheet = document.getElementById('mobBrandSheet');
  if (!sheet) {
    createMobBrandSheet();
    sheet = document.getElementById('mobBrandSheet');
  } else {
    // actualiza marca activa
    sheet.querySelectorAll('.mob-sheet-brand-btn').forEach(btn => {
      btn.classList.toggle('active', btn.dataset.brandId === activeBrand);
    });
  }
  const overlay = document.getElementById('mobSheetOverlay');
  const isOpen  = sheet.classList.contains('open');
  if (isOpen) {
    closeMobBrandPicker();
  } else {
    sheet.classList.add('open');
    overlay.classList.add('open');
  }
}

function closeMobBrandPicker() {
  document.getElementById('mobBrandSheet')?.classList.remove('open');
  document.getElementById('mobSheetOverlay')?.classList.remove('open');
}

function createMobBrandSheet() {
  // overlay
  const overlay = document.createElement('div');
  overlay.id = 'mobSheetOverlay';
  overlay.className = 'mob-sheet-overlay';
  overlay.addEventListener('click', closeMobBrandPicker);
  document.body.appendChild(overlay);

  // sheet
  const sheet = document.createElement('div');
  sheet.id    = 'mobBrandSheet';
  sheet.className = 'mob-brand-sheet';

  const brandBtns = BRANDS.map(b => {
    const label = b.label.startsWith('brand_') ? t(b.label) : b.label;
    const count = catalog.filter(p => p.section === 'soft' && p.brand === b.id).length;
    return `<button class="mob-sheet-brand-btn${b.id === activeBrand ? ' active' : ''}"
      data-brand-id="${b.id}"
      onclick="selectBrandFromNav('${b.id}'); closeMobBrandPicker();">
      <span class="mob-sheet-brand-swatch" style="background:${b.color}">${b.abbr}</span>
      <span class="mob-sheet-brand-name">${label}</span>
      ${count > 0 ? `<span class="mob-sheet-brand-count">${count}</span>` : ''}
    </button>`;
  }).join('');

  const title = { pt:'Software de Diagnóstico', en:'Diagnostic Software', fr:'Logiciel de Diagnostic' }[lang] || 'Software';
  sheet.innerHTML = `
    <div class="mob-sheet-handle"></div>
    <div class="mob-sheet-title">${title}</div>
    <div class="mob-sheet-brands">${brandBtns}</div>
  `;
  document.body.appendChild(sheet);
}

function openSoftDropdown() {
  document.getElementById('softDropdown')?.classList.add('open');
  // Mostrar landing ao abrir dropdown — switcha para sec-soft e mostra "Escolha marca"
  document.querySelectorAll('.section-view').forEach(p => p.classList.remove('active'));
  document.getElementById('sec-soft')?.classList.add('active');
  renderSoftLanding();
}

function toggleSoftDropdown(e) {
  e.stopPropagation();
  const wrap = document.getElementById('softDropdown');
  const isOpen = wrap.classList.toggle('open');
  if (isOpen) setTimeout(() => document.addEventListener('click', closeSoftDropdown, { once: true }), 0);
}

function closeSoftDropdown(skipRender = false) {
  document.getElementById('softDropdown')?.classList.remove('open');
  // Ao fechar, mostrar marca confirmada (se existir) — senão mantém landing
  if (!skipRender && confirmedBrand) {
    document.querySelectorAll('.section-view').forEach(p => p.classList.remove('active'));
    document.getElementById('sec-soft')?.classList.add('active');
    renderBrand(confirmedBrand);
  }
}

// Atualiza estado ativo no nav SEM recriar DOM — evita reabrir dropdown por hover implícito
function updateNavBrandActive(brandId) {
  document.querySelectorAll('.nav-pill').forEach(p => p.classList.remove('active'));
  document.querySelector('#softDropdown .nav-pill')?.classList.add('active');
  document.querySelectorAll('.nav-dd-item').forEach(b =>
    b.classList.toggle('active', b.dataset.brandId === brandId));
  document.querySelectorAll('.mob-item').forEach(m =>
    m.classList.toggle('active', m.dataset.navKey === 'mob_soft'));
}

function selectBrandFromNav(brandId) {
  confirmedBrand = brandId; // confirmar antes de fechar (closeSoftDropdown usa confirmedBrand)
  closeSoftDropdown(true);  // true = skipRender, renderBrand é chamado abaixo
  activeBrand = brandId;
  activeSection = 'soft';
  document.querySelectorAll('.section-view').forEach(p => p.classList.remove('active'));
  document.getElementById('sec-soft')?.classList.add('active');
  const brand = BRANDS.find(b => b.id === brandId) || BRANDS[0];
  setBrandTheme(brand);
  renderBrand(brandId);
  updateNavBrandActive(brandId); // sem rebuild DOM — dropdown fica fechado
  window.scrollTo({ top: 0, behavior: 'smooth' });
  showConsultPopup();
  const _bNav = BRANDS.find(b => b.id === brandId);
  if (_bNav) updateOGMeta(_bNav.label?.startsWith('brand_') ? t(_bNav.label) : _bNav.label, null, `https://m-auto.online/#soft/${brandId}`);
}

function selectAllBrands() {
  confirmedBrand = null;
  activeBrand = BRANDS[0].id;
  activeSection = 'soft';
  closeSoftDropdown(true);
  document.querySelectorAll('.section-view').forEach(p => p.classList.remove('active'));
  document.getElementById('sec-soft')?.classList.add('active');
  setBrandTheme(BRANDS[0]);
  renderSoftLanding();
  // Mark "Tudo" item as active
  document.querySelectorAll('.nav-dd-item').forEach(b => b.classList.remove('active'));
  document.querySelector('.nav-dd-item[data-brand-id="all"]')?.classList.add('active');
  document.querySelectorAll('.side-btn').forEach(b => b.classList.remove('active'));
  document.querySelector('.side-btn[data-brand-id="all"]')?.classList.add('active');
  window.scrollTo({ top: 0, behavior: 'smooth' });
}

/* ─────────────────────────────────────────────
   8. SIDEBAR DE MARCAS
───────────────────────────────────────────── */
function buildSidebar() {
  const sidebar = document.querySelector('.sidebar');
  if (!sidebar) return;
  const isTudo = !confirmedBrand;
  const allCount = catalog.filter(p => p.section === 'soft').length;
  const allBtn = `<button type="button" class="side-btn side-btn-all${isTudo ? ' active' : ''}"
    onclick="selectAllBrands()"
    data-brand-id="all">
    <span class="sb-color-strip sb-color-strip-all"></span>
    <span class="sb-inner-row">
      <span class="sb-brand-icon sb-brand-icon-all">≡</span>
      <span class="sb-label-text">${t('nav_all')}</span>
      ${allCount > 0 ? `<span class="sb-count">${allCount}</span>` : ''}
    </span>
  </button>`;
  sidebar.innerHTML = allBtn + BRANDS.map(b => {
    const label = b.label.startsWith('brand_') ? t(b.label) : b.label;
    const count = catalog.filter(p => p.section === 'soft' && p.brand === b.id).length;
    return `<button type="button" class="side-btn${confirmedBrand === b.id ? ' active' : ''}"
      onclick="switchBrand('${b.id}', this)"
      data-brand-id="${b.id}">
      <span class="sb-color-strip" style="background:${b.color}"></span>
      <span class="sb-inner-row">
        <span class="sb-brand-icon" style="background:${b.color}">${b.abbr}</span>
        <span class="sb-label-text">${label}</span>
        ${count > 0 ? `<span class="sb-count">${count}</span>` : ''}
      </span>
    </button>`;
  }).join('');
}

/* ─────────────────────────────────────────────
   9. SWITCH DE SECÇÃO / MARCA
───────────────────────────────────────────── */
function switchSection(id, btn) {
  activeSection = id;
  closeSoftDropdown();
  document.querySelectorAll('.section-view').forEach(p => p.classList.remove('active'));
  document.getElementById('sec-' + id)?.classList.add('active');
  document.querySelectorAll('.nav-pill, .mob-item').forEach(b => b.classList.remove('active'));
  if (btn) btn.classList.add('active');
  // Limpar pesquisa ao mudar de secção
  const srch = document.getElementById('searchInput');
  if (srch && srch.value) { srch.value = ''; filterProducts(); }
  window.scrollTo({ top: 0, behavior: 'smooth' });

  if (id === 'soft')  { confirmedBrand ? renderBrand(confirmedBrand) : renderSoftLanding(); }
  if (id === 'hard')  renderHard();
  if (id === 'tools') renderTools();
  if (id === 'serv')  renderServices();
  if (id === 'about') renderAbout();
  buildNav(); // mantém estado activo correcto no nav
  if (id === 'soft') showConsultPopup(); // só na tab Software
  const _secLabels = { soft: t('nav_soft'), hard: t('nav_hard'), tools: t('nav_tools'), serv: t('nav_serv'), about: 'Sobre' };
  updateOGMeta(_secLabels[id] || id, null, `https://m-auto.online/#${id}`);
}

function switchBrand(id, btn) {
  confirmedBrand = id;
  activeBrand = id;
  const brand = BRANDS.find(b => b.id === id) || BRANDS[0];
  setBrandTheme(brand);
  document.querySelectorAll('.side-btn').forEach(b => b.classList.remove('active'));
  if (btn) btn.classList.add('active');
  const appTop = document.querySelector('.app-container')?.offsetTop - 100 || 0;
  window.scrollTo({ top: appTop, behavior: 'smooth' });
  renderBrand(id);
  showConsultPopup();
  const _bl = BRANDS.find(b => b.id === id);
  if (_bl) updateOGMeta(_bl.label?.startsWith('brand_') ? t(_bl.label) : _bl.label, null, `https://m-auto.online/#soft/${id}`);
}

/* ─────────────────────────────────────────────
   10. RENDERIZAÇÃO DE PRODUTOS
───────────────────────────────────────────── */
function renderSection(id) {
  activeSection = id;
  if (id === 'soft')  { confirmedBrand ? renderBrand(confirmedBrand) : renderSoftLanding(); }
  if (id === 'hard')  renderHard();
  if (id === 'tools') renderTools();
  if (id === 'serv')  renderServices();
}

function renderBrand(brandId) {
  activeBrand = brandId;
  const panel = document.getElementById('brand-active');
  if (!panel) return;

  const brand    = BRANDS.find(b => b.id === brandId) || BRANDS[0];
  const label    = brand.label.startsWith('brand_') ? t(brand.label) : brand.label;
  const products = catalog.filter(p => p.section === 'soft' && p.brand === brandId);
  const brandIdx = BRANDS.findIndex(b => b.id === brandId);

  const dotsHtml = BRANDS.map((b, i) =>
    `<span class="brand-dot${i === brandIdx ? ' active' : ''}"
      onclick="selectBrandFromNav('${b.id}')"
      ${i === brandIdx ? `style="background:${brand.color}"` : ''}></span>`
  ).join('');

  const gridHtml = dataLoaded
    ? (products.length > 0 ? products.map(p => createCard(p)).join('') : '')
    : renderSkeletonCards(6);

  const existingHero = panel.querySelector('.brand-hero');
  if (existingHero) {
    // Partial update — preserva layout, apenas actualiza conteúdo → transição CSS suave
    const titleEl = existingHero.querySelector('.brand-hero-title');
    const metaEl  = existingHero.querySelector('.brand-hero-meta');
    const wmEl    = existingHero.querySelector('.brand-hero-wm');
    if (titleEl) titleEl.textContent = label;
    if (metaEl)  metaEl.innerHTML = `<span class="hero-count">0</span> ${t('brand_hero_products')} · ${t('brand_hero_meta')}`;
    if (wmEl)  { wmEl.textContent = brand.watermark; applyWmOffset(panel); }
    const dotsEl = panel.querySelector('.brand-dots');
    if (dotsEl) dotsEl.innerHTML = dotsHtml;
    const gridEl = panel.querySelector('.brand-grid');
    if (gridEl) gridEl.innerHTML = gridHtml;
  } else {
    // Primeiro render — full HTML
    panel.innerHTML = `
      <div class="brand-hero">
        <div class="brand-hero-wm">${brand.watermark}</div>
        <div class="brand-hero-eyebrow">${t('brand_hero_eyebrow')}</div>
        <h2 class="brand-hero-title">${label}</h2>
        <p class="brand-hero-meta"><span class="hero-count">0</span> ${t('brand_hero_products')} · ${t('brand_hero_meta')}</p>
      </div>
      <div class="brand-dots">${dotsHtml}</div>
      <div class="grid brand-grid">${gridHtml}</div>
    `;
    applyWmOffset(panel);
  }
  if (dataLoaded) {
    initSectionFx(panel, panel.querySelector('.hero-count'), products.length);
    if (!swipeHintShown) showSwipeHint();
  }
}

function renderHard() {
  const sec = document.getElementById('sec-hard');
  if (!sec) return;
  const products = catalog.filter(p => p.section === 'hard');
  let heroEl = sec.querySelector('.section-hero');
  if (!heroEl) {
    sec.innerHTML = `
      <div class="section-hero no-transition">
        <div class="section-hero-wm">HARDWARE</div>
        <div class="section-hero-eyebrow">M-Auto Online</div>
        <h2 class="section-hero-title">${t('hard_title')}</h2>
        <p class="section-hero-meta"><span class="hero-count">0</span> ${t('brand_hero_products')} · ${t('brand_hero_meta')}</p>
      </div>
      <div class="sec-body hard-body"></div>`;
    heroEl = sec.querySelector('.section-hero');
    applyWmOffset(sec);
    requestAnimationFrame(() => requestAnimationFrame(() => heroEl.classList.remove('no-transition')));
  } else {
    heroEl.querySelector('.section-hero-title').textContent = t('hard_title');
    heroEl.querySelector('.section-hero-meta').innerHTML = `<span class="hero-count">0</span> ${t('brand_hero_products')} · ${t('brand_hero_meta')}`;
  }
  sec.querySelector('.hard-body').innerHTML = `<div class="grid hard-grid">${dataLoaded ? products.map(p => createCard(p)).join('') : renderSkeletonCards(4)}</div>`;
  initSectionFx(sec, heroEl.querySelector('.hero-count'), products.length);
}

function renderTools() {
  const sec = document.getElementById('sec-tools');
  if (!sec) return;
  let heroEl = sec.querySelector('.section-hero');
  if (!heroEl) {
    sec.innerHTML = `
      <div class="section-hero no-transition">
        <div class="section-hero-wm">DOWNLOADS</div>
        <div class="section-hero-eyebrow">M-Auto Online</div>
        <h2 class="section-hero-title">${t('tools_title')}</h2>
        <p class="section-hero-meta"><span class="hero-count">0</span> apps · ${t('tools_meta')}</p>
      </div>
      <div class="sec-body tools-body"></div>`;
    heroEl = sec.querySelector('.section-hero');
    applyWmOffset(sec);
    requestAnimationFrame(() => requestAnimationFrame(() => heroEl.classList.remove('no-transition')));
  } else {
    heroEl.querySelector('.section-hero-title').textContent = t('tools_title');
    heroEl.querySelector('.section-hero-meta').innerHTML = `<span class="hero-count">0</span> apps · ${t('tools_meta')}`;
  }
  sec.querySelector('.tools-body').innerHTML = `<div class="tool-grid">${dataLoaded ? tools.map(tl => createToolCard(tl)).join('') : renderSkeletonToolCards(4)}</div>`;
  initSectionFx(sec, heroEl.querySelector('.hero-count'), tools.length);
}

function renderServices() {
  const sec = document.getElementById('sec-serv');
  if (!sec) return;
  const serviceCards = services.map(s => {
    const d = s[lang] || s.pt;
    // Cores por tipo de serviço
    const bgMap = { srv_remote_install:'#2563eb', srv_support:'#059669', srv_update:'#7c3aed', srv_config:'#d97706' };
    const svgMap = {
      srv_remote_install: `<svg viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" width="26" height="26"><rect x="2" y="3" width="20" height="14" rx="2"/><path d="M8 21h8M12 17v4"/><path d="M7 8l2 2-2 2M13 10h4"/></svg>`,
      srv_support: `<svg viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" width="26" height="26"><path d="M21 15a2 2 0 01-2 2H7l-4 4V5a2 2 0 012-2h14a2 2 0 012 2z"/><path d="M12 8v4M12 16h.01" stroke-width="2"/></svg>`,
      srv_update: `<svg viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" width="26" height="26"><polyline points="23 4 23 10 17 10"/><polyline points="1 20 1 14 7 14"/><path d="M3.51 9a9 9 0 0114.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0020.49 15"/></svg>`,
      srv_config: `<svg viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" width="26" height="26"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-4 0v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 010-4h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 012.83-2.83l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 014 0v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 010 4h-.09a1.65 1.65 0 00-1.51 1z"/></svg>`
    };
    const bg = bgMap[s.id] || '#2563eb';
    const svgIcon = svgMap[s.id] || `<svg viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="1.7" width="26" height="26"><circle cx="12" cy="12" r="10"/></svg>`;
    return `<div class="tool-card searchable-item">
      <div class="tool-card-icon" style="background:${bg}">${svgIcon}</div>
      <div class="tool-card-body">
        <div class="tool-card-name">${d.title}</div>
        <div class="tool-card-desc">${d.desc}</div>
      </div>
      <button type="button" class="tool-card-btn" onclick="orderProduct('${d.title.replace(/'/g,"\\'")}','${t('nav_serv')}')">
        ${t('serv_contact')}
      </button>
    </div>`;
  }).join('');
  let heroEl = sec.querySelector('.section-hero');
  if (!heroEl) {
    sec.innerHTML = `
      <div class="section-hero no-transition">
        <div class="section-hero-wm">${t('serv_wm')}</div>
        <div class="section-hero-eyebrow">M-Auto Online</div>
        <h2 class="section-hero-title">${t('serv_title')}</h2>
        <p class="section-hero-meta"><span class="hero-count">0</span> ${t('nav_serv').toLowerCase()} · ${t('brand_hero_meta')}</p>
      </div>
      <div class="sec-body serv-body"></div>`;
    heroEl = sec.querySelector('.section-hero');
    applyWmOffset(sec);
    requestAnimationFrame(() => requestAnimationFrame(() => heroEl.classList.remove('no-transition')));
  } else {
    heroEl.querySelector('.section-hero-title').textContent = t('serv_title');
    heroEl.querySelector('.section-hero-meta').innerHTML = `<span class="hero-count">0</span> ${t('nav_serv').toLowerCase()} · ${t('brand_hero_meta')}`;
  }
  sec.querySelector('.serv-body').innerHTML = `<div class="tool-grid">${serviceCards}</div>`;
  initSectionFx(sec, heroEl.querySelector('.hero-count'), services.length);
}

function renderAbout() {
  const sec = document.getElementById('sec-about');
  if (!sec) return;
  const wmDelay = -(Math.random() * 22).toFixed(2);
  sec.innerHTML = `
    <div class="section-hero about-hero">
      <div class="section-hero-wm" style="animation-delay:${wmDelay}s">${t('about_wm')}</div>
      <div class="section-hero-eyebrow">M-Auto Online</div>
      <h2 class="section-hero-title">${t('about_title')}</h2>
      <p class="section-hero-meta">Simply Digital · Diagnóstico Profissional</p>
    </div>
    <div class="about-landing">
      <p class="about-body">${t('about_text')}</p>
      <button class="about-cta" onclick="selectBrandFromNav('mercedes')">${t('about_cta')}</button>
    </div>
  `;
}

/* ─────────────────────────────────────────────
   11. CRIAÇÃO DE CARDS
───────────────────────────────────────────── */
function createCard(item) {
  const d = prodData(item);
  const isPremium = !!item.premium;
  const priceKey = item.price_key || 'price_consult';
  const spanClass = item.span_full ? ' style="grid-column:1/-1;position:relative"' : '';

  let badgeHtml = '';
  if (item.badge) badgeHtml = `<span class="badge${item.badge === 'badge_top' ? ' badge-top' : ''}">${t(item.badge)}</span>`;

  const priceColor = isPremium ? ' style="color:var(--gold)"' : '';
  const eyeColor   = isPremium ? ' card-eye-gold' : '';

  return `<div class="card${isPremium ? ' gold' : ''} searchable-item card-clickable"${spanClass}
    onclick="openProductModal('${item.id}')" role="button" tabindex="0"
    onkeydown="if(event.key==='Enter'||event.key===' ')openProductModal('${item.id}')">
    ${badgeHtml}
    ${item.img ? `<img src="${item.img}" loading="lazy" alt="${d.name || ''}">` : `<div class="img-placeholder"><span>${d.name || item.id}</span></div>`}
    <div class="card-body">
      <div class="card-title-row">
        <h3>${d.name || ''}</h3>
        <span class="card-eye${eyeColor}" aria-hidden="true">${ICON_EYE}</span>
      </div>
      <p class="sub-desc">${d.short || ''}</p>
      <div class="card-footer">
        <span class="price"${priceColor}>${t(priceKey)}</span>
      </div>
    </div>
  </div>`;
}

function createToolRow(tl) {
  const d = tl[lang] || tl.pt;
  return `<div class="tool-row searchable-item">
    <div class="tool-info">
      <div class="tool-icon-box" style="background:${tl.iconBg}">${tl.icon}</div>
      <div class="tool-meta">
        <h4>${d.name}</h4>
        <p>${d.desc}</p>
      </div>
    </div>
    <a href="${tl.url}" target="_blank" rel="noopener" class="tool-btn icon-btn"
      aria-label="${t('btn_download')}" title="${t('btn_download')}">${ICON_DOWNLOAD}</a>
  </div>`;
}

function createToolCard(tl) {
  const d = tl[lang] || tl.pt;
  const iconHTML = tl.faIcon
    ? `<i class="${tl.faIcon}"></i>`
    : `<span style="font-weight:800;font-size:1rem;letter-spacing:-0.03em">${tl.icon}</span>`;
  return `<div class="tool-card searchable-item">
    <div class="tool-card-icon" style="background:${tl.iconBg}">${iconHTML}</div>
    <div class="tool-card-body">
      <div class="tool-card-name">${d.name}</div>
      <div class="tool-card-desc">${d.desc}</div>
    </div>
    <a href="${tl.url}" target="_blank" rel="noopener" class="tool-card-btn">
      <i class="fa-solid fa-download"></i> ${t('btn_download')}
    </a>
  </div>`;
}

function getBrandLabel(brandId) {
  const b = BRANDS.find(x => x.id === brandId);
  if (!b) return brandId;
  return b.label.startsWith('brand_') ? t(b.label) : b.label;
}

/* ─────────────────────────────────────────────
   12. MODAL DE PRODUTO
───────────────────────────────────────────── */
let activeModalId = null;

function openProductModal(id) {
  activeModalId = id;
  const item = catalog.find(p => p.id === id);
  if (!item) return;
  const modal = document.getElementById('productModal');
  renderModalContent(item);
  modal.style.display = 'flex';
  requestAnimationFrame(() => requestAnimationFrame(() => modal.classList.add('open')));
  showConsultPopup();
}

function renderModalContent(item) {
  const d = prodData(item);
  const priceKey = item.price_key || 'price_consult';

  const titleEl = document.getElementById('modalTitle');
  const descEl  = document.getElementById('modalDesc');
  const priceEl = document.getElementById('modalPrice');
  const imgEl   = document.getElementById('modalImg');

  if (titleEl) titleEl.textContent = d.name || '';
  const featHtml = (item.features?.length)
    ? `<ul class="modal-features">${item.features.map(f => `<li>✓ ${f}</li>`).join('')}</ul>`
    : '';
  if (descEl)  descEl.innerHTML = (d.details || `<em>${t('modal_no_details')}</em>`) + featHtml;
  if (priceEl) priceEl.style.display = priceKey === 'price_consult' ? 'none' : '';
  if (priceEl && priceKey !== 'price_consult') priceEl.textContent = t(priceKey);
  if (imgEl)   { imgEl.removeAttribute('src'); imgEl.style.display = 'none'; }

  // Botão encomendar
  const orderBtn = document.querySelector('#productModal .prod-btn');
  if (orderBtn) orderBtn.textContent = t('modal_order');
}

function closeProductModal() {
  const modal = document.getElementById('productModal');
  modal.classList.remove('open');
  setTimeout(() => {
    modal.style.display = 'none';
    activeModalId = null;
  }, 380);
}

function orderFromModal() {
  const item = catalog.find(p => p.id === activeModalId);
  if (!item) {
    orderProduct(t('wa_general'), '');
    return;
  }
  const d = prodData(item);
  const name = d.name || item.id;
  // Contexto: secção › marca (se soft)
  const sectionLabels = { soft: t('nav_soft'), hard: t('nav_hard'), tools: t('nav_tools'), serv: t('nav_serv') };
  const parts = [];
  if (item.section) parts.push(sectionLabels[item.section] || item.section);
  if (item.brand && item.section === 'soft') parts.push(getBrandLabel(item.brand));
  if (d.short) parts.push(d.short.replace(/\.$/, ''));
  orderProduct(name, parts.join(' › '));
}

function orderProduct(nameOrMsg, context = '') {
  const phone = "351911157459";
  let text;
  // Se nameOrMsg já é a mensagem completa (wa_general)
  if (!context && nameOrMsg === t('wa_general')) {
    text = nameOrMsg;
  } else {
    text = `${t('wa_interest')} *${nameOrMsg}*`;
    if (context) text += `\n📂 ${context}`;
    text += `\n🌐 m-auto.online`;
  }
  window.open(`https://wa.me/${phone}?text=${encodeURIComponent(text)}`, '_blank');
}

function orderGeneral() {
  const phone = "351911157459";
  const text = t('wa_general');
  window.open(`https://wa.me/${phone}?text=${encodeURIComponent(text)}`, '_blank');
}

/* ─────────────────────────────────────────────
   13b. EFEITOS VISUAIS — tilt · reveal · count-up · skeleton
───────────────────────────────────────────── */

// 3D Tilt hover nos cards
function initCardTilt() {
  document.querySelectorAll('.card:not([data-tilt]), .tool-card:not([data-tilt])').forEach(card => {
    card.dataset.tilt = '1';
    card.addEventListener('mousemove', e => {
      const rect = card.getBoundingClientRect();
      const x = (e.clientX - rect.left) / rect.width - 0.5;
      const y = (e.clientY - rect.top) / rect.height - 0.5;
      card.style.transform = `perspective(700px) rotateY(${x * 9}deg) rotateX(${-y * 9}deg) scale3d(1.03,1.03,1.03)`;
      card.style.boxShadow = `${-x * 12}px ${-y * 12}px 28px rgba(0,0,0,0.13)`;
    });
    card.addEventListener('mouseleave', () => {
      card.style.transform = '';
      card.style.boxShadow = '';
    });
  });
}

// Scroll-triggered reveal
let _scrollObserver = null;
function initScrollReveal() {
  if (!_scrollObserver) {
    _scrollObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          entry.target.classList.add('reveal-in');
          _scrollObserver.unobserve(entry.target);
        }
      });
    }, { threshold: 0.07, rootMargin: '0px 0px -20px 0px' });
  }
  document.querySelectorAll('.card:not(.reveal-obs), .tool-card:not(.reveal-obs)').forEach((el, i) => {
    el.classList.add('reveal-obs');
    el.style.setProperty('--reveal-delay', `${Math.min(i * 55, 400)}ms`);
    _scrollObserver.observe(el);
  });
}

// Count-up animation nos números do hero
function animateCount(el, target) {
  if (!el || !target) return;
  const dur = 750;
  const start = performance.now();
  const update = (now) => {
    const p = Math.min((now - start) / dur, 1);
    const eased = 1 - Math.pow(1 - p, 3);
    el.textContent = Math.round(eased * target);
    if (p < 1) requestAnimationFrame(update);
  };
  requestAnimationFrame(update);
}

// Skeleton para tool-cards
function renderSkeletonToolCards(n = 4) {
  return Array(n).fill(0).map(() => `
    <div class="tool-card card-skeleton">
      <div class="skel" style="width:44px;height:44px;border-radius:12px;flex-shrink:0"></div>
      <div class="tool-card-body" style="flex:1">
        <div class="skel skel-h3" style="width:60%"></div>
        <div class="skel skel-p1" style="width:90%"></div>
      </div>
    </div>`).join('');
}

// Inicializa efeitos depois de render
function initSectionFx(sec, countEl, countVal) {
  requestAnimationFrame(() => {
    initScrollReveal();
    initCardTilt();
    if (countEl && countVal) animateCount(countEl, countVal);
  });
}

/* ─────────────────────────────────────────────
   13. SISTEMA DE LÍNGUA
───────────────────────────────────────────── */
function setLanguage(newLang) {
  if (!TRANS[newLang]) return;
  lang = newLang;
  try { localStorage.setItem('mauto_lang', lang); } catch(e) {}
  applyLang();
}

function applyLang() {
  document.documentElement.lang = lang;

  // SEO: título e meta description dinâmicos
  const titles = { pt: 'M-Auto Online | Software de Diagnóstico Automóvel', en: 'M-Auto Online | Automotive Diagnostic Software', fr: 'M-Auto Online | Logiciels de Diagnostic Automobile' };
  const descs  = { pt: 'Software de diagnóstico automóvel profissional. Instalação remota, suporte técnico.', en: 'Professional automotive diagnostic software. Remote installation, technical support.', fr: 'Logiciels de diagnostic automobile professionnels. Installation à distance, support technique.' };
  document.title = titles[lang] || titles.pt;
  document.querySelector('meta[name="description"]')?.setAttribute('content', descs[lang] || descs.pt);

  // Botões de língua
  document.querySelectorAll('.lang-btn').forEach(b => b.classList.remove('active'));
  document.getElementById('btn-' + lang)?.classList.add('active');

  // Nav — rebuild completo (inclui dropdown com labels traduzidos)
  buildNav();

  // Hero e outros elementos com data-trans (novo) e data-translate (legado hero.html)
  document.querySelectorAll('[data-trans], [data-translate]').forEach(el => {
    const key = el.dataset.trans || el.dataset.translate;
    if (key) el.textContent = t(key);
  });

  // Search placeholder
  const search = document.getElementById('searchInput');
  if (search) search.placeholder = t('search_placeholder');

  // About
  renderAbout();

  // Re-renderizar secção activa
  renderSection(activeSection);

  // Atualizar popup viewers
  updateViewers(true);

  // Se modal aberto, re-renderizar
  if (activeModalId) {
    const item = catalog.find(p => p.id === activeModalId);
    if (item) renderModalContent(item);
  }
}

/* ─────────────────────────────────────────────
   14. PESQUISA
───────────────────────────────────────────── */
function filterProducts() {
  const val = (document.getElementById('searchInput')?.value || '').toLowerCase().trim();
  const panel = document.getElementById('searchResultsPanel');
  if (!panel) return;

  if (!val) {
    panel.classList.remove('active');
    return;
  }

  // Pesquisar em catalog + tools (dados, não DOM)
  const catMatches = catalog.filter(p => {
    const d = prodData(p);
    return (d.name || '').toLowerCase().includes(val)
        || (d.short || '').toLowerCase().includes(val)
        || (p.brand || '').toLowerCase().includes(val);
  });
  const toolMatches = tools.filter(tl => {
    const d = tl[lang] || tl.pt;
    return (d.name || '').toLowerCase().includes(val)
        || (d.desc || '').toLowerCase().includes(val);
  });

  if (catMatches.length === 0 && toolMatches.length === 0) {
    panel.innerHTML = `<p class="search-empty">${t('search_no_results')} "<strong>${val}</strong>"</p>`;
  } else {
    const catHtml = catMatches.length
      ? `<div class="grid search-grid">${catMatches.map(p => createCard(p)).join('')}</div>`
      : '';
    const toolHtml = toolMatches.length
      ? `<div class="tool-grid search-tool-grid">${toolMatches.map(tl => createToolCard(tl)).join('')}</div>`
      : '';
    panel.innerHTML = catHtml + toolHtml;
  }
  panel.classList.add('active');
}

/* ─────────────────────────────────────────────
   15. WIZARD DE COMPATIBILIDADE
───────────────────────────────────────────── */
let userSpecs = {};

function openWizard() {
  userSpecs = {};
  document.querySelectorAll('#wizContent .step').forEach(s => s.classList.remove('active'));
  document.getElementById('wiz-step-1')?.classList.add('active');
  // Reiniciar stepper visual
  document.querySelectorAll('.wiz-step-dot').forEach((dot, i) => {
    dot.classList.remove('wiz-dot-done', 'wiz-dot-active');
    if (i === 0) dot.classList.add('wiz-dot-active');
  });
  document.querySelectorAll('.wiz-step-line').forEach(line => line.classList.remove('wiz-line-done'));
  applyWizardTranslations();
  document.getElementById('wizardModal').style.display = 'flex';
}

function closeWizard() {
  document.getElementById('wizardModal').style.display = 'none';
}

function setSpec(key, val) {
  userSpecs[key] = val;
  const steps = ['win', 'ram', 'disk', 'brand'];
  const idx = steps.indexOf(key);
  document.querySelectorAll('#wizContent .step').forEach(s => s.classList.remove('active'));
  if (idx < steps.length - 1) {
    document.getElementById('wiz-step-' + (idx + 2))?.classList.add('active');
    updateWizStepper(idx + 2);
  } else {
    showWizResult();
    updateWizStepper(5);
  }
}

function updateWizStepper(currentStep) {
  document.querySelectorAll('.wiz-step-dot').forEach(dot => {
    const n = parseInt(dot.dataset.step);
    dot.classList.toggle('wiz-dot-done',   n < currentStep);
    dot.classList.toggle('wiz-dot-active', n === currentStep);
    dot.classList.remove('wiz-dot-done');
    if (n < currentStep) dot.classList.add('wiz-dot-done');
    if (n === currentStep) dot.classList.add('wiz-dot-active');
    else dot.classList.remove('wiz-dot-active');
  });
  document.querySelectorAll('.wiz-step-line').forEach((line, i) => {
    line.classList.toggle('wiz-line-done', i + 2 < currentStep);
  });
}

function showWizResult() {
  const { win, ram, disk, brand } = userSpecs;
  const resultEl = document.getElementById('finalResultContent');
  if (!resultEl) return;

  const limited = win === 'old' || ram === 'low';
  const optimal = !limited && disk === 'ssd';

  let statusColor, statusIcon, statusTitle, statusMsg, tips = [];

  if (limited) {
    statusColor = '#f59e0b';
    statusIcon  = '⚠️';
    statusTitle = t('wiz_limited_title');
    statusMsg   = t('wiz_limited_msg');
    if (win === 'old') tips.push({ pt: 'Actualizar para Windows 10/11 para suporte total.', en: 'Upgrade to Windows 10/11 for full software support.', fr: 'Mettre à jour vers Windows 10/11 pour un support complet.' }[lang]);
    if (ram === 'low') tips.push({ pt: 'Aumentar RAM para mínimo 8 GB.', en: 'Upgrade RAM to a minimum of 8 GB.', fr: 'Augmenter la RAM à 8 Go minimum.' }[lang]);
  } else if (optimal) {
    statusColor = '#10b981';
    statusIcon  = '🚀';
    statusTitle = { pt: 'PC Óptimo!', en: 'Optimal PC!', fr: 'PC Optimal !' }[lang];
    statusMsg   = { pt: 'SSD + 8 GB+ RAM — instalação rápida e estável garantida.', en: 'SSD + 8 GB+ RAM — fast and stable installation guaranteed.', fr: 'SSD + 8 Go+ RAM — installation rapide et stable garantie.' }[lang];
  } else {
    statusColor = '#2563eb';
    statusIcon  = '✅';
    statusTitle = t('wiz_compatible_title');
    statusMsg   = t('wiz_compatible_msg');
    if (disk === 'hdd') tips.push({ pt: 'SSD recomendado para melhor desempenho.', en: 'SSD recommended for better performance.', fr: 'SSD recommandé pour de meilleures performances.' }[lang]);
  }

  // Recomendação por marca
  const brandMap = {
    mercedes: { prod: 'Mercedes Full Pack 2026', id: 'merc_full_pack', bg: '#0a1628', abbr: 'MB' },
    bmw:      { prod: 'ISTA+',                  id: 'bmw_ista_plus',  bg: '#0066b2', abbr: 'BMW' },
    vag:      { prod: 'ODIS Service',            id: 'vag_odis_service', bg: '#001f6e', abbr: 'VAG' },
    psa:      { prod: 'Diagbox 9.208',           id: 'psa_diagbox_9208', bg: '#001f5c', abbr: 'PSA' },
    other:    { prod: 'Delphi / Autocom',        id: 'multi_delphi',   bg: '#374151', abbr: '🔧' },
  };
  const rec = brand ? brandMap[brand] : null;
  const recHtml = rec ? `
    <div class="wiz-rec-card" onclick="closeWizard(); openProductModal('${rec.id}')">
      <div class="wiz-rec-abbr" style="background:${rec.bg}">${rec.abbr}</div>
      <div class="wiz-rec-info">
        <div class="wiz-rec-label">${{ pt: 'Recomendado:', en: 'Recommended:', fr: 'Recommandé :' }[lang]}</div>
        <div class="wiz-rec-prod">${rec.prod}</div>
      </div>
      <div class="wiz-rec-arrow">→</div>
    </div>` : '';

  document.getElementById('wiz-result')?.classList.add('active');
  resultEl.innerHTML = `
    <div class="wiz-status-card" style="border-left:4px solid ${statusColor}">
      <span class="wiz-status-icon">${statusIcon}</span>
      <div>
        <div class="wiz-status-title" style="color:${statusColor}">${statusTitle}</div>
        <div class="wiz-status-msg">${statusMsg}</div>
      </div>
    </div>
    ${tips.length ? `<ul class="wiz-tips">${tips.map(tip => `<li>${tip}</li>`).join('')}</ul>` : ''}
    ${recHtml}
  `;
}

function applyWizardTranslations() {
  // Step dot labels (stepper)
  const stepLabels = [
    { pt: 'Sistema', en: 'System',  fr: 'Système' },
    { pt: 'RAM',     en: 'RAM',     fr: 'RAM' },
    { pt: 'Disco',   en: 'Drive',   fr: 'Disque' },
    { pt: 'Marca',   en: 'Brand',   fr: 'Marque' },
  ];
  document.querySelectorAll('.wiz-dot-label').forEach((el, i) => {
    if (stepLabels[i]) el.textContent = stepLabels[i][lang] || stepLabels[i].pt;
  });
  // Botão resultado reiniciar
  const restartEl = document.getElementById('wiz_restart_btn');
  if (restartEl) restartEl.textContent = t('wiz_restart');
  // Títulos dos steps, opções e sub-labels
  const map = {
    'wiz_title_1': 'wiz_os', 'wiz_title_2': 'wiz_ram',
    'wiz_title_3': 'wiz_disk', 'wiz_title_4': 'wiz_brand',
    'wiz_title_result': 'wiz_result_title',
    'wiz_btn_win_old': 'wiz_win_old', 'wiz_btn_win_new': 'wiz_win_new',
    'wiz_btn_ram_low': 'wiz_ram_low', 'wiz_btn_ram_high': 'wiz_ram_high',
    'wiz_btn_disk_hdd': 'wiz_disk_hdd', 'wiz_btn_disk_ssd': 'wiz_disk_ssd',
    // sub-labels
    'wiz_sub_win_old': 'wiz_sub_win_old', 'wiz_sub_win_new': 'wiz_sub_win_new',
    'wiz_sub_ram_low': 'wiz_sub_ram_low', 'wiz_sub_ram_high': 'wiz_sub_ram_high',
    'wiz_sub_disk_hdd': 'wiz_sub_disk_hdd', 'wiz_sub_disk_ssd': 'wiz_sub_disk_ssd',
    // brand step
    'wiz_btn_brand_other': 'wiz_brand_other',
  };
  Object.entries(map).forEach(([id, key]) => {
    const el = document.getElementById(id);
    if (el) el.textContent = t(key);
  });
}

/* ─────────────────────────────────────────────
   16. TYPEWRITER
───────────────────────────────────────────── */
function startTypewriter() {
  const el = document.querySelector('.typewriter-text');
  if (!el) return;
  const texts = ["Mercedes-Benz","Volkswagen","BMW","Audi","PSA","Renault","JLR","Toyota","Nissan","Ford","GM"];
  let ci = 0, ci2 = 0;
  (function type() {
    if (ci >= texts.length) ci = 0;
    const cur = texts[ci];
    el.textContent = cur.slice(0, ++ci2);
    if (ci2 === cur.length) { ci++; ci2 = 0; setTimeout(type, 2000); }
    else setTimeout(type, 100);
  })();
}

/* ─────────────────────────────────────────────
   17. POPUP DE VISITANTES
───────────────────────────────────────────── */
let viewers = 5;
let _popupTimer = null;

// Popup de visitantes — só contagem, espaçado, opaco, 7s
function showViewersPopup() {
  viewers = Math.max(2, Math.min(15, viewers + Math.floor(Math.random() * 3) - 1));
  const el = document.getElementById('viewerText');
  if (el) el.innerHTML = `<span class="popup-viewers-line"><strong>${viewers}</strong> ${t('popup_viewers')}</span>`;
  const popup = document.getElementById('salesPopup');
  if (!popup) return;
  popup.classList.remove('consult-mode', 'active');
  clearTimeout(_popupTimer);
  void popup.offsetWidth;
  popup.classList.add('active');
  _popupTimer = setTimeout(() => popup.classList.remove('active'), 7000);
  setTimeout(showViewersPopup, Math.random() * 20000 + 20000);
}

// Popup de consulta — só mensagem, transparente, 2.5s (trigger: mudar marca/secção)
function showConsultPopup() {
  const el = document.getElementById('viewerText');
  if (el) el.innerHTML = `<span class="popup-consult-line">${t('popup_consult')}</span>`;
  const popup = document.getElementById('salesPopup');
  if (!popup) return;
  popup.classList.remove('active');
  clearTimeout(_popupTimer);
  void popup.offsetWidth;
  popup.classList.add('consult-mode', 'active');
  _popupTimer = setTimeout(() => {
    popup.classList.remove('active');
    setTimeout(() => popup.classList.remove('consult-mode'), 500);
  }, 2500);
}

// Alias para applyLang não quebrar
function updateViewers(textOnly = false) {
  if (!textOnly) showViewersPopup();
}

/* ─────────────────────────────────────────────
   18. TEMA
───────────────────────────────────────────── */
function toggleTheme() {
  const current = document.documentElement.getAttribute('data-theme');
  document.documentElement.setAttribute('data-theme', current === 'dark' ? '' : 'dark');
}

/* ─────────────────────────────────────────────
   19. PWA — SERVICE WORKER
───────────────────────────────────────────── */
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('/sw.js').catch(() => {});
  });
}

/* ─────────────────────────────────────────────
   20. OG META DINÂMICOS
───────────────────────────────────────────── */
function updateOGMeta(titleSuffix, desc, url) {
  const base = 'M-Auto Online';
  const fullTitle = titleSuffix ? `${base} · ${titleSuffix}` : base;
  document.title = fullTitle;
  const set = (prop, val) => {
    const el = document.querySelector(`meta[property="${prop}"]`);
    if (el) el.setAttribute('content', val);
  };
  set('og:title', fullTitle);
  set('og:description', desc || 'Software de diagnóstico automóvel — instalação remota profissional.');
  set('og:url', url || 'https://m-auto.online/');
}

/* cursor personalizado removido */
