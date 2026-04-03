# Java Exception Site List - Adicionar localhost:81
# M-Auto Online

$e = [char]27
$url = "http://localhost:81"
$sitesFile = "$env:USERPROFILE\AppData\LocalLow\Sun\Java\Deployment\security\exception.sites"

function Write-OK($m)   { Write-Host "  ${e}[38;2;34;197;94m[OK]  $m${e}[0m" }
function Write-Warn($m) { Write-Host "  ${e}[38;2;250;204;21m[!]   $m${e}[0m" }
function Write-Err($m)  { Write-Host "  ${e}[38;2;239;68;68m[X]   $m${e}[0m" }
function Write-Info($m) { Write-Host "  ${e}[38;2;148;163;184m[.]   $m${e}[0m" }

Write-Host ""
Write-Info "A configurar Java Exception Site List..."
Write-Host ""

# Criar directorio se necessario
$dir = Split-Path $sitesFile
if (-not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    Write-Info "Directorio criado: $dir"
}

# Verificar se ja existe
$exists = $false
if (Test-Path $sitesFile) {
    $content = Get-Content $sitesFile -ErrorAction SilentlyContinue
    if ($content -contains $url) {
        $exists = $true
    }
}

if ($exists) {
    Write-Warn "$url ja esta na lista de excecoes Java"
} else {
    # Adicionar entrada
    $existing = if (Test-Path $sitesFile) { (Get-Content $sitesFile) } else { @() }
    $lines = @($existing) + $url | Where-Object { $_ -ne "" }
    $enc = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllLines($sitesFile, $lines, $enc)
    Write-OK "$url adicionado a lista de excecoes Java"
}

Write-Host ""
Write-Info "Ficheiro: $sitesFile"
Write-Host ""

# Verificar instalacao Java
$javaPath = @(
    "$env:ProgramFiles\Java",
    "${env:ProgramFiles(x86)}\Java",
    "$env:ProgramW6432\Java"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($javaPath) {
    Write-OK "Java detectado em: $javaPath"
} else {
    Write-Warn "Java nao detectado no sistema"
}

Write-Host ""
Write-Host -NoNewline "  ${e}[38;2;80;100;140mPressione ENTER para continuar...${e}[0m"
$null = $Host.UI.ReadLine()
