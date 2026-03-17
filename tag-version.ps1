# tag-version.ps1
# Uso: .\tag-version.ps1 "v8.2a - nova feature X"
# Cria tag anotada com mensagem descritiva

param(
    [Parameter(Mandatory=$true)]
    [string]$Message,
    [string]$ProjectDir = (Get-Location).Path
)

if (-not (Test-Path "$ProjectDir\.git")) {
    Write-Host "ERRO: Não é uma pasta git" -ForegroundColor Red
    exit 1
}

Push-Location $ProjectDir

# Formato da tag: data + sequência
$today = Get-Date -Format "yyyyMMdd"
$todayCount = (git tag -l "$today-*" 2>&1 | Measure-Object).Count
$versionNum = $todayCount + 1
$tagName = "${today}-v${versionNum}"

# Adicionar e commitar se há mudanças
$status = git status --porcelain 2>&1
if ($status) {
    git add -A 2>&1 | Out-Null
    git commit -m "feat: $Message" 2>&1 | Out-Null
}

# Tag anotada (com mensagem)
git tag -a $tagName -m $Message 2>&1 | Out-Null

Write-Host ""
Write-Host "✅ Versão criada: $tagName" -ForegroundColor Green
Write-Host "   Mensagem: $Message"
Write-Host ""
Write-Host "Para fazer push das tags:"
Write-Host "   git push && git push --tags"

Pop-Location
