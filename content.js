/**
 * M-AUTO ONLINE - content.js 
 * Versão Otimizada (V17.11 Base)
 */

// 1. DICIONÁRIO DE TRADUÇÃO (Centralizado)
const UI = {
    pt: {
        version: "Versão",
        os: "Sistema",
        space: "Espaço",
        details: "Detalhes",
        buy: "Adquirir Software",
        more: "Ver Mais",
        loading: "A carregar...",
        search: "Procurar software..."
    },
    en: {
        version: "Version",
        os: "OS",
        space: "Space",
        details: "Details",
        buy: "Get Software",
        more: "See More",
        loading: "Loading...",
        search: "Search software..."
    },
    fr: {
        version: "Version",
        os: "Système",
        space: "Espace",
        details: "Détails",
        buy: "Obtenir",
        more: "Voir Plus",
        loading: "Chargement...",
        search: "Rechercher..."
    }
};

// Ícone de reticências para o botão "Ver"
const ICON_ELLIPSIS = '<svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor"><path d="M6 10c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm12 0c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2zm-6 0c-1.1 0-2 .9-2 2s.9 2 2 2 2-.9 2-2-.9-2-2-2z"/></svg>';

// 2. ESTADO GLOBAL
let allProducts = [];
let currentLang = localStorage.getItem('selectedLang') || 'pt';

// 3. INICIALIZAÇÃO
document.addEventListener('DOMContentLoaded', () => {
    initApp();
});

async function initApp() {
    // Carregar produtos (Exemplo de caminhos baseados no teu repo)
    const files = [
        'data/products/bmw_ista_plus.json',
        'data/products/renault_clip.json'
        // Adiciona aqui os outros ficheiros JSON
    ];

    try {
        const responses = await Promise.all(files.map(f => fetch(f).then(r => r.json())));
        allProducts = responses;
        renderByCategory('all');
    } catch (err) {
        console.error("Erro ao carregar produtos:", err);
    }
}

// 4. MOTOR DE RENDERIZAÇÃO DE CARDS
function createProductCard(item) {
    const lang = UI[currentLang] || UI.pt;
    const isGold = item.premium ? 'gold' : '';
    
    // Texto de descrição baseado na língua
    const description = item['desc_' + currentLang] || item.desc_pt || "";

    return `
        <div class="card ${isGold}" data-id="${item.id}">
            ${item.premium ? '<span class="badge">PREMIUM</span>' : ''}
            <img src="${item.img}" alt="${item.name}" onerror="this.src='assets/img/placeholder.png'">
            <div class="card-body">
                <h3>${item.brand} ${item.name}</h3>
                <p class="sub-desc">${description}</p>
                
                <div class="tech-details">
                    <div class="tech-row">
                        <span class="tech-label">${lang.version}:</span>
                        <span>${item.version}</span>
                    </div>
                    <div class="tech-row">
                        <span class="tech-label">${lang.os}:</span>
                        <span>${item.os}</span>
                    </div>
                    <div class="tech-row">
                        <span class="tech-label">${lang.space}:</span>
                        <span>${item.space}</span>
                    </div>
                </div>

                <div class="card-footer">
                    <span class="price">${item.price || '---'}</span>
                    <button class="btn-view btn-view-icon" onclick="openModal('${item.id}')" title="${lang.details}">
                        ${ICON_ELLIPSIS}
                    </button>
                </div>
            </div>
        </div>
    `;
}

// 5. FILTRAGEM E PESQUISA
function renderByCategory(catId) {
    const container = document.getElementById('grid-content');
    if (!container) return;

    const filtered = catId === 'all' 
        ? allProducts 
        : allProducts.filter(p => p.category === catId);

    container.innerHTML = filtered.map(item => createProductCard(item)).join('');
}

function handleSearch(query) {
    const q = query.toLowerCase();
    const filtered = allProducts.filter(p => 
        p.name.toLowerCase().includes(q) || 
        p.brand.toLowerCase().includes(q)
    );
    document.getElementById('grid-content').innerHTML = filtered.map(item => createProductCard(item)).join('');
}

// 6. MODAL DE DETALHES
function openModal(id) {
    const item = allProducts.find(p => p.id === id);
    if (!item) return;

    const lang = UI[currentLang] || UI.pt;
    const modal = document.getElementById('prodModal');
    const body = modal.querySelector('.prod-body');
    const footer = modal.querySelector('.prod-footer');

    const desc = item['desc_' + currentLang] || item.desc_pt;

    body.innerHTML = `
        <img src="${item.img}" style="width:100%; border-radius:12px; margin-bottom:15px;">
        <h2 class="prod-title">${item.brand} ${item.name}</h2>
        <p class="prod-text">${desc}</p>
    `;

    footer.innerHTML = `
        <span class="prod-price">${item.price || ''}</span>
        <button class="prod-btn" onclick="window.open('${item.link || '#'}')">${lang.buy}</button>
    `;

    modal.style.display = 'flex';
}

function closeModal() {
    document.getElementById('prodModal').style.display = 'none';
}

// 7. TROCA DE LÍNGUA
function setLanguage(langCode) {
    currentLang = langCode;
    localStorage.setItem('selectedLang', langCode);
    
    // Atualiza botões ativos na UI
    document.querySelectorAll('.lang-btn').forEach(btn => {
        btn.classList.toggle('active', btn.dataset.lang === langCode);
    });

    // Re-renderiza tudo com a nova língua
    const activeCat = document.querySelector('.side-btn.active')?.dataset.cat || 'all';
    renderByCategory(activeCat);
}
