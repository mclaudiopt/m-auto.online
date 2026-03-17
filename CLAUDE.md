# m-auto.online — Contexto do projeto

## Stack
- HTML/CSS/JS vanilla — sem frameworks
- Ficheiro principal: start.html (index.html e start.html sao identicos — start.html e o ativo)
- Assets: assets/app.js + assets/style.css
- Dados: data/*.json
- Partials: partials/ (componentes HTML incluidos via JS)
- Deploy: GitHub Pages (CNAME: m-auto.online)
- Servidor local: porta 3000

## Versao atual
- v8 (design "Brand Identity" — Syne + Manrope + Inter)
- Proxima: v8.1 (11 itens pendentes na TodoList da ultima sessao)
- hero/typewriter desativado mas codigo preservado

## Regras criticas
- NUNCA usar CDNs — tudo local ou inline
- Paths de imagens: sempre relativos, sensiveis ao MAX_PATH Windows (260 chars)
- Backups: ficheiros *_backup_*.html sao versoes antigas — nao editar
- node_modules existe mas nao e usado no runtime — so para ferramentas dev

## Ficheiros ignorar
- content.js1, index1.html, start_backup_*, index_backup_* — versoes antigas
- preview-a.html, preview-b.html, preview-c.html — mockups de design

## Git
- Remote: GitHub (GitHub Pages)
- Branch principal: main
- Auto-commit ativo via hook