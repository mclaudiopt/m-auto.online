# install/renault_download.ps1 - Renault CLIP Download
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null
$e = [char]27

$LINKS_URL = "https://raw.githubusercontent.com/mclaudiopt/m-auto.online/main/renault_links.json"
$DEST_DIR  = "C:\M-auto\Temp"

function Write-Header {
    Clear-Host
    Write-Host ""
    Write-Host "  ${e}[38;2;255;204;0m+------------------------------------------------------+${e}[0m"
    Write-Host "  ${e}[38;2;255;204;0m|${e}[0m  ${e}[1;97mRenault CLIP - Download${e}[0m"
    Write-Host "  ${e}[38;2;255;204;0m+------------------------------------------------------+${e}[0m"
    Write-Host ""
}

function Write-OK($msg)   { Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  $msg" }
function Write-Err($msg)  { Write-Host "  ${e}[38;2;239;68;68m[X]${e}[0m   $msg" }
function Write-Info($msg) { Write-Host "  ${e}[38;2;148;163;184m[.]${e}[0m   $msg" }

function Invoke-Download($Url, $Name, $Idx, $Total) {
    $dest = Join-Path $DEST_DIR $Name
    if (Test-Path $dest) {
        Write-OK "Ja existe: $Name"
        return $true
    }

    try {
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $Url -OutFile $dest -UseBasicParsing
        $sizeMB = [math]::Round((Get-Item $dest).Length / 1MB, 1)
        Write-OK "Transferido: $Name ($sizeMB MB)"
        return $true
    } catch {
        Write-Err "Falhou: $Name"
        Write-Info $_.Exception.Message
        return $false
    }
}

Write-Header

if (-not (Test-Path $DEST_DIR)) {
    Write-Info "A criar pasta: $DEST_DIR"
    New-Item -ItemType Directory -Path $DEST_DIR -Force | Out-Null
}

Write-Info "A obter lista de ficheiros..."
try {
    $data = Invoke-RestMethod -Uri $LINKS_URL -UseBasicParsing
    $links = $data.files
} catch {
    Write-Err "Erro ao obter links"
    Write-Info $_.Exception.Message
    Write-Host ""
    Read-Host "  Pressione ENTER para continuar"
    return
}

if (-not $links -or $links.Count -eq 0) {
    Write-Err "Nenhum ficheiro disponivel"
    Write-Host ""
    Read-Host "  Pressione ENTER para continuar"
    return
}

Write-Header
Write-OK "Links validos — $($links.Count) ficheiro(s) disponiveis."
Write-Host ""
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

$num = 0
foreach ($f in $links) {
    $num++
    $dest = Join-Path $DEST_DIR $f.name

    if (Test-Path $dest) {
        $sizeMB = [math]::Round((Get-Item $dest).Length / 1MB, 1)
        Write-Host "  ${e}[38;2;100;130;100m[$num]${e}[0m ${e}[38;2;34;197;94m[OK]${e}[0m  $($f.name) ${e}[38;2;100;130;100m($sizeMB MB — ja existe)${e}[0m"
    } else {
        Write-Host "  ${e}[38;2;148;163;184m[$num]${e}[0m ${e}[38;2;250;204;21m[--]${e}[0m  $($f.name) ${e}[38;2;148;163;184m(por transferir)${e}[0m"
    }
}
Write-Host ""
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""
Write-Host "  ${e}[38;2;148;163;184mEscolha:${e}[0m"
Write-Host "    ${e}[38;2;100;149;237m[A]${e}[0m Transferir todos os ficheiros em falta"
Write-Host "    ${e}[38;2;100;149;237m[1-$($links.Count)]${e}[0m Transferir ficheiro especifico"
Write-Host "    ${e}[38;2;239;68;68m[S]${e}[0m Sair"
Write-Host ""
$choice = Read-Host "  Opcao"

if ($choice -eq "S" -or $choice -eq "s") {
    return
}

$toDownload = @()
if ($choice -eq "A" -or $choice -eq "a") {
    for ($i = 0; $i -lt $links.Count; $i++) {
        $dest = Join-Path $DEST_DIR $links[$i].name
        if (-not (Test-Path $dest)) {
            $toDownload += $i
        }
    }
} elseif ($choice -match '^\d+$') {
    $idx = [int]$choice - 1
    if ($idx -ge 0 -and $idx -lt $links.Count) {
        $toDownload += $idx
    }
}

if ($toDownload.Count -eq 0) {
    Write-Info "Nenhum ficheiro para transferir"
    Start-Sleep -Seconds 2
    return
}

Write-Header
Write-Info "A transferir $($toDownload.Count) ficheiro(s)..."
Write-Host ""

$ok = 0; $fail = 0
foreach ($idx in $toDownload) {
    $f = $links[$idx]
    Write-Host "  ${e}[38;2;100;149;237m-- $($f.name) ($($ok+$fail+1)/$($toDownload.Count)) --${e}[0m"
    $res = Invoke-Download -Url $f.url -Name $f.name -Idx ($ok+$fail+1) -Total $toDownload.Count
    if ($res) { $ok++ } else { $fail++ }
    Write-Host ""
}

Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""
Write-OK "Concluido: $ok transferido(s), $fail falhou(ram)"
Write-Host ""
Read-Host "  Pressione ENTER para continuar"
