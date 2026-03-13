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
    nav_soft: "Software", nav_hard: "Hardware", nav_tools: "Downloads",
    nav_serv: "Serviços", nav_about: "Sobre",
    mob_soft: "Soft", mob_hard: "Hard", mob_tools: "DL", mob_serv: "Serv", mob_about: "Info",
    btn_order: "Encomendar", btn_download: "Download", btn_details: "Detalhes",
    btn_schedule: "Agendar", btn_close: "Fechar",
    price_consult: "Consulta", price_pack: "Pack Completo",
    badge_best: "Melhor Escolha",
    hero_sol: "Soluções Online", hero_desc: "Instalação remota profissional.",
    modal_order: "Encomendar", modal_no_details: "Detalhes não disponíveis.",
    search_placeholder: "🔍 Procurar...",
    meta_version: "Versão", meta_year: "Ano", meta_os: "Sistema",
    brand_multi: "Multimarca",
    hard_title: "Hardware", tools_title: "Downloads", serv_title: "Serviços",
    about_title: "Sobre",
    tools_meta: "Instalação remota assistida",
    about_text: "Somos especialistas em software de diagnóstico automóvel com anos de experiência. Oferecemos um serviço profissional, com resposta rápida e suporte assegurado.",
    popup_viewers: "visitantes online",
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
    brand_hero_eyebrow: "Software de Diagnóstico",
    brand_hero_products: "produtos",
    brand_hero_meta: "Instalação remota profissional",
    about_cta: "Ver Software →",
    about_feat_install: "Instalação remota profissional",
    about_feat_brands: "Mercedes · BMW · VAG · PSA · Toyota e mais",
    about_feat_support: "Suporte rápido e garantido"
  },
  en: {
    nav_soft: "Software", nav_hard: "Hardware", nav_tools: "Downloads",
    nav_serv: "Services", nav_about: "About",
    mob_soft: "Soft", mob_hard: "Hard", mob_tools: "DL", mob_serv: "Serv", mob_about: "Info",
    btn_order: "Order", btn_download: "Download", btn_details: "Details",
    btn_schedule: "Book", btn_close: "Close",
    price_consult: "On request", price_pack: "Full Pack",
    badge_best: "Best Choice",
    hero_sol: "Online Solutions", hero_desc: "Professional remote installation.",
    modal_order: "Order", modal_no_details: "Details not available.",
    search_placeholder: "🔍 Search...",
    meta_version: "Version", meta_year: "Year", meta_os: "OS",
    brand_multi: "Multi-brand",
    hard_title: "Hardware", tools_title: "Downloads", serv_title: "Services",
    about_title: "About",
    tools_meta: "Remote assisted installation",
    about_text: "We are specialists in automotive diagnostic software with years of experience. We offer a professional service, fast response and reliable support.",
    popup_viewers: "visitors online",
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
    brand_hero_eyebrow: "Diagnostic Software",
    brand_hero_products: "products",
    brand_hero_meta: "Professional remote installation",
    about_cta: "View Software →",
    about_feat_install: "Professional remote installation",
    about_feat_brands: "Mercedes · BMW · VAG · PSA · Toyota and more",
    about_feat_support: "Fast and guaranteed support"
  },
  fr: {
    nav_soft: "Logiciel", nav_hard: "Matériel", nav_tools: "Téléchargements",
    nav_serv: "Services", nav_about: "À Propos",
    mob_soft: "Soft", mob_hard: "Hard", mob_tools: "DL", mob_serv: "Serv", mob_about: "Info",
    btn_order: "Commander", btn_download: "Télécharger", btn_details: "Détails",
    btn_schedule: "Planifier", btn_close: "Fermer",
    price_consult: "Sur demande", price_pack: "Pack Complet",
    badge_best: "Meilleur Choix",
    hero_sol: "Solutions En Ligne", hero_desc: "Installation à distance professionnelle.",
    modal_order: "Commander", modal_no_details: "Détails non disponibles.",
    search_placeholder: "🔍 Rechercher...",
    meta_version: "Version", meta_year: "Année", meta_os: "Système",
    brand_multi: "Multimarque",
    hard_title: "Matériel", tools_title: "Téléchargements", serv_title: "Services",
    about_title: "À Propos",
    tools_meta: "Installation à distance assistée",
    about_text: "Nous sommes spécialistes des logiciels de diagnostic automobile avec des années d'expérience. Nous offrons un service professionnel, une réponse rapide et un support fiable.",
    popup_viewers: "personnes en ligne",
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
    brand_hero_eyebrow: "Logiciel de Diagnostic",
    brand_hero_products: "produits",
    brand_hero_meta: "Installation à distance professionnelle",
    about_cta: "Voir les Logiciels →",
    about_feat_install: "Installation à distance professionnelle",
    about_feat_brands: "Mercedes · BMW · VAG · PSA · Toyota et plus",
    about_feat_support: "Support rapide et garanti"
  }
};

/* ─────────────────────────────────────────────
   2. CONFIG DE MARCAS (ordem da sidebar)
───────────────────────────────────────────── */
const BRANDS = [
  { id:"mercedes", label:"Mercedes-Benz",  color:"#1c1c1c", colorLight:"#f5f5f5", colorMid:"#8a8a8a", abbr:"MB",  watermark:"MERCEDES" },
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
let dataLoaded    = false;

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

  // Viewers popup
  setTimeout(() => updateViewers(false), 5000);

  // Scroll top
  const scrollBtn = document.getElementById('scrollTopBtn');
  if (scrollBtn) {
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
  const brandItems = BRANDS.map(b => {
    const label = b.label.startsWith('brand_') ? t(b.label) : b.label;
    const count = catalog.filter(p => p.section === 'soft' && p.brand === b.id).length;
    return `<button type="button" class="nav-dd-item${b.id === activeBrand ? ' active' : ''}"
      onclick="selectBrandFromNav('${b.id}')" data-brand-id="${b.id}">
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
    <div class="nav-dropdown-wrap${activeSection === 'soft' ? ' nav-sec-active' : ''}" id="softDropdown">
      <button type="button" class="nav-pill${activeSection === 'soft' ? ' active' : ''}"
        onclick="toggleSoftDropdown(event)" data-nav-key="nav_soft">
        <span class="nav-pill-label">${t('nav_soft')}</span>${nb(softCount)}
        <span class="nav-dd-arrow">▾</span>
      </button>
      <div class="nav-dropdown-menu" id="softDropdownMenu">${brandItems}</div>
    </div>
    <button type="button" class="nav-pill${activeSection === 'hard'  ? ' active' : ''}"
      onclick="switchSection('hard',  this)" data-nav-key="nav_hard">${t('nav_hard')}${nb(hardCount)}</button>
    <button type="button" class="nav-pill${activeSection === 'tools' ? ' active' : ''}"
      onclick="switchSection('tools', this)" data-nav-key="nav_tools">${t('nav_tools')}${nb(toolCount)}</button>
    <button type="button" class="nav-pill${activeSection === 'serv'  ? ' active' : ''}"
      onclick="switchSection('serv',  this)" data-nav-key="nav_serv">${t('nav_serv')}${nb(servCount)}</button>
    <button type="button" class="nav-pill${activeSection === 'about' ? ' active' : ''}"
      onclick="switchSection('about', this)" data-nav-key="nav_about">${t('nav_about')}</button>
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

function toggleSoftDropdown(e) {
  e.stopPropagation();
  const wrap = document.getElementById('softDropdown');
  const isOpen = wrap.classList.toggle('open');
  if (isOpen) setTimeout(() => document.addEventListener('click', closeSoftDropdown, { once: true }), 0);
}

function closeSoftDropdown() {
  document.getElementById('softDropdown')?.classList.remove('open');
}

function selectBrandFromNav(brandId) {
  closeSoftDropdown();
  activeBrand = brandId;
  activeSection = 'soft';
  document.querySelectorAll('.section-view').forEach(p => p.classList.remove('active'));
  document.getElementById('sec-soft')?.classList.add('active');
  const brand = BRANDS.find(b => b.id === brandId) || BRANDS[0];
  setBrandTheme(brand);
  document.querySelectorAll('.brand-panel').forEach(p => p.classList.remove('active'));
  document.getElementById('brand-' + brandId)?.classList.add('active');
  renderBrand(brandId);
  buildNav(); // actualiza estado activo no dropdown
  window.scrollTo({ top: 0, behavior: 'smooth' });
}

/* ─────────────────────────────────────────────
   8. SIDEBAR DE MARCAS
───────────────────────────────────────────── */
function buildSidebar() {
  const sidebar = document.querySelector('.sidebar');
  if (!sidebar) return;
  sidebar.innerHTML = BRANDS.map((b, i) => {
    const label = b.label.startsWith('brand_') ? t(b.label) : b.label;
    const count = catalog.filter(p => p.section === 'soft' && p.brand === b.id).length;
    return `<button type="button" class="side-btn${i === 0 ? ' active' : ''}"
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

  if (id === 'soft')  renderBrand(activeBrand);
  if (id === 'hard')  renderHard();
  if (id === 'tools') renderTools();
  if (id === 'serv')  renderServices();
  if (id === 'about') renderAbout();
  buildNav(); // mantém estado activo correcto no nav
}

function switchBrand(id, btn) {
  activeBrand = id;
  const brand = BRANDS.find(b => b.id === id) || BRANDS[0];
  setBrandTheme(brand);
  const container = btn.closest('.layout-flex');
  container?.querySelectorAll('.brand-panel').forEach(c => c.classList.remove('active'));
  container?.querySelector('#brand-' + id)?.classList.add('active');
  container?.querySelectorAll('.side-btn').forEach(b => b.classList.remove('active'));
  if (btn) btn.classList.add('active');
  const appTop = document.querySelector('.app-container')?.offsetTop - 100 || 0;
  window.scrollTo({ top: appTop, behavior: 'smooth' });
  renderBrand(id);
}

/* ─────────────────────────────────────────────
   10. RENDERIZAÇÃO DE PRODUTOS
───────────────────────────────────────────── */
function renderSection(id) {
  activeSection = id;
  if (id === 'soft')  renderBrand(activeBrand);
  if (id === 'hard')  renderHard();
  if (id === 'tools') renderTools();
  if (id === 'serv')  renderServices();
}

function renderBrand(brandId) {
  activeBrand = brandId;
  const panel = document.getElementById('brand-' + brandId);
  if (!panel) return;

  const brand    = BRANDS.find(b => b.id === brandId) || BRANDS[0];
  const label    = brand.label.startsWith('brand_') ? t(brand.label) : brand.label;
  const products = catalog.filter(p => p.section === 'soft' && p.brand === brandId);

  // Brand dots (indicador swipe — visível só em mobile via CSS)
  const brandIdx = BRANDS.findIndex(b => b.id === brandId);
  const dotsHtml = `<div class="brand-dots">${BRANDS.map((b, i) =>
    `<span class="brand-dot${i === brandIdx ? ' active' : ''}"
      onclick="selectBrandFromNav('${b.id}')"
      ${i === brandIdx ? `style="background:${brand.color}"` : ''}></span>`
  ).join('')}</div>`;

  // Grid: skeleton se dados ainda não carregaram, cards se já tem dados
  const gridHtml = dataLoaded
    ? (products.length > 0 ? products.map(p => createCard(p)).join('') : '')
    : renderSkeletonCards(6);

  panel.innerHTML = `
    <div class="brand-hero">
      <div class="brand-hero-wm">${brand.watermark}</div>
      <div class="brand-hero-eyebrow">${t('brand_hero_eyebrow')}</div>
      <h2 class="brand-hero-title">${label}</h2>
      <p class="brand-hero-meta">${dataLoaded ? products.length : '—'} ${t('brand_hero_products')} · ${t('brand_hero_meta')}</p>
    </div>
    ${dotsHtml}
    <div class="grid brand-grid">${gridHtml}</div>
  `;
}

function renderHard() {
  const sec = document.getElementById('sec-hard');
  if (!sec) return;
  const products = catalog.filter(p => p.section === 'hard');
  sec.innerHTML = `
    <div class="section-hero">
      <div class="section-hero-wm">HARDWARE</div>
      <div class="section-hero-eyebrow">M-Auto Online</div>
      <h2 class="section-hero-title">${t('hard_title')}</h2>
      <p class="section-hero-meta">${products.length} ${t('brand_hero_products')} · ${t('brand_hero_meta')}</p>
    </div>
    <div class="grid hard-grid">${products.map(p => createCard(p)).join('')}</div>`;
}

function renderTools() {
  const sec = document.getElementById('sec-tools');
  if (!sec) return;
  sec.innerHTML = `
    <div class="section-hero">
      <div class="section-hero-wm">DOWNLOADS</div>
      <div class="section-hero-eyebrow">M-Auto Online</div>
      <h2 class="section-hero-title">${t('tools_title')}</h2>
      <p class="section-hero-meta">${tools.length} apps · ${t('tools_meta')}</p>
    </div>
    <div class="tool-grid">${tools.map(tl => createToolCard(tl)).join('')}</div>`;
}

function renderServices() {
  const sec = document.getElementById('sec-serv');
  if (!sec) return;
  sec.innerHTML = `
    <div class="section-hero">
      <div class="section-hero-wm">SERVICES</div>
      <div class="section-hero-eyebrow">M-Auto Online</div>
      <h2 class="section-hero-title">${t('serv_title')}</h2>
    </div>
    <section class="services-section">
      <ul class="services-list">${services.map(s => {
        const d = s[lang] || s.pt;
        return `<li class="service-item">
          <span class="service-icon">${s.icon}</span>
          <div><strong>${d.title}</strong><span>${d.desc}</span></div>
        </li>`;
      }).join('')}</ul>
    </section>`;
}

function renderAbout() {
  const sec = document.getElementById('sec-about');
  if (!sec) return;
  sec.innerHTML = `
    <div class="about-landing">
      <div class="about-logo-block">
        <div class="about-logo-text">
          <span class="brand-m">M-Auto</span>&nbsp;<span class="brand-online">Online</span>
        </div>
        <div class="about-tagline">Simply Digital</div>
      </div>
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
  if (item.badge) badgeHtml = `<span class="badge">${t(item.badge)}</span>`;

  const priceColor = isPremium ? ' style="color:var(--gold)"' : '';
  const btnColor   = isPremium ? ' style="color:var(--gold)"' : '';

  return `<div class="card${isPremium ? ' gold' : ''} searchable-item"${spanClass}>
    <div class="card-top-bar"></div>
    ${badgeHtml}
    ${item.img ? `<img src="${item.img}" loading="lazy" alt="${d.name || ''}">` : ''}
    <div class="card-body">
      <h3>${d.name || ''}</h3>
      <p class="sub-desc">${d.short || ''}</p>
      <div class="card-footer">
        <span class="price"${priceColor}>${t(priceKey)}</span>
        <button type="button" class="btn-view btn-view-icon"${btnColor}
          onclick="openProductModal('${item.id}')"
          aria-label="${t('btn_details')}" title="${t('btn_details')}">
          ${ICON_ELLIPSIS}
        </button>
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
  renderModalContent(item);
  document.getElementById('productModal').style.display = 'flex';
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
  if (priceEl) priceEl.textContent = t(priceKey);
  if (imgEl)   { imgEl.removeAttribute('src'); imgEl.style.display = 'none'; }

  // Botão encomendar
  const orderBtn = document.querySelector('#productModal .prod-btn');
  if (orderBtn) orderBtn.textContent = t('modal_order');
}

function closeProductModal() {
  document.getElementById('productModal').style.display = 'none';
  activeModalId = null;
}

function orderFromModal() {
  const item = catalog.find(p => p.id === activeModalId);
  const name = item ? (prodData(item).name || activeModalId) : 'Produto';
  orderProduct(name);
}

function orderProduct(name) {
  const phone = "351911157459";
  window.open(`https://wa.me/${phone}?text=${encodeURIComponent('Tenho interesse em: ' + name)}`, '_blank');
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
  document.querySelectorAll('.searchable-item').forEach(el => {
    el.hidden = val ? !el.textContent.toLowerCase().includes(val) : false;
  });
}

/* ─────────────────────────────────────────────
   15. WIZARD DE COMPATIBILIDADE
───────────────────────────────────────────── */
let userSpecs = {};

function openWizard() {
  userSpecs = {};
  document.querySelectorAll('#wizContent .step').forEach(s => s.classList.remove('active'));
  document.getElementById('wiz-step-1')?.classList.add('active');
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
  } else {
    showWizResult();
  }
}

function showWizResult() {
  const { win, ram, disk, brand } = userSpecs;
  const resultEl = document.getElementById('finalResultContent');
  if (!resultEl) return;

  const limited  = win === 'old' || ram === 'low';
  const optimal  = !limited && disk === 'ssd';
  const msgs = { pt: {}, en: {}, fr: {} };

  let color, title, lines = [];

  if (limited) {
    color = '#f59e0b';
    title = t('wiz_limited_title');
    lines.push(t('wiz_limited_msg'));
    if (win === 'old') lines.push({ pt: '⚠️ Windows 7/8 não suporta software recente.', en: '⚠️ Windows 7/8 does not support recent software.', fr: '⚠️ Windows 7/8 ne supporte pas les logiciels récents.' }[lang]);
    if (ram === 'low') lines.push({ pt: '💾 4 GB RAM é insuficiente — mínimo recomendado: 8 GB.', en: '💾 4 GB RAM is insufficient — recommended minimum: 8 GB.', fr: '💾 4 Go de RAM insuffisant — minimum recommandé : 8 Go.' }[lang]);
  } else if (optimal) {
    color = '#10b981';
    title = { pt: '🚀 PC Óptimo!', en: '🚀 Optimal PC!', fr: '🚀 PC Optimal !' }[lang];
    lines.push({ pt: 'SSD + RAM 8 GB+ — instalação rápida e estável.', en: 'SSD + 8 GB+ RAM — fast and stable installation.', fr: 'SSD + 8 Go+ RAM — installation rapide et stable.' }[lang]);
  } else {
    color = '#2563eb';
    title = t('wiz_compatible_title');
    lines.push(t('wiz_compatible_msg'));
    if (disk === 'hdd') lines.push({ pt: '💡 SSD recomendado para melhor desempenho.', en: '💡 SSD recommended for better performance.', fr: '💡 SSD recommandé pour de meilleures performances.' }[lang]);
  }

  if (brand) lines.push({ pt: `🔧 Marca seleccionada: <strong>${brand}</strong>`, en: `🔧 Selected brand: <strong>${brand}</strong>`, fr: `🔧 Marque sélectionnée : <strong>${brand}</strong>` }[lang]);

  resultEl.innerHTML = `<div class="wiz-result-box" style="border:2px solid ${color};border-radius:12px;padding:20px">
    <h4 style="color:${color};margin-bottom:12px">${title}</h4>
    ${lines.map(l => `<p style="margin:6px 0;font-size:0.9rem">${l}</p>`).join('')}
  </div>`;

  document.getElementById('wiz-result')?.classList.add('active');
}

function applyWizardTranslations() {
  const map = {
    'wiz_title_1': 'wiz_os', 'wiz_title_2': 'wiz_ram',
    'wiz_title_3': 'wiz_disk', 'wiz_title_4': 'wiz_brand',
    'wiz_title_result': 'wiz_result_title', 'wiz_restart_btn': 'wiz_restart',
    'wiz_btn_win_old': 'wiz_win_old', 'wiz_btn_win_new': 'wiz_win_new',
    'wiz_btn_ram_low': 'wiz_ram_low', 'wiz_btn_ram_high': 'wiz_ram_high',
    'wiz_btn_disk_hdd': 'wiz_disk_hdd', 'wiz_btn_disk_ssd': 'wiz_disk_ssd',
    'wiz_btn_brand_merc': 'wiz_brand_merc', 'wiz_btn_brand_bmw': 'wiz_brand_bmw'
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

function updateViewers(textOnly = false) {
  if (!textOnly) {
    viewers = Math.max(2, Math.min(15, viewers + Math.floor(Math.random() * 5) - 2));
  }
  const el = document.getElementById('viewerText');
  if (el) el.innerHTML = `<strong>${viewers}</strong> ${t('popup_viewers')}`;

  if (!textOnly) {
    const popup = document.getElementById('salesPopup');
    popup?.classList.add('active');
    setTimeout(() => popup?.classList.remove('active'), 5000);
    setTimeout(() => updateViewers(false), Math.random() * 25000 + 20000);
  }
}

/* ─────────────────────────────────────────────
   18. TEMA
───────────────────────────────────────────── */
function toggleTheme() {
  const current = document.documentElement.getAttribute('data-theme');
  document.documentElement.setAttribute('data-theme', current === 'dark' ? '' : 'dark');
}
