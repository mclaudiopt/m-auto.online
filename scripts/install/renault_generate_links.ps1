# install/renault_generate_links.ps1 - Renault Links Generator
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null
$e = [char]27

$SOURCE_DIR = "Z:\Renault"
$OUTPUT_FILE = "D:\Tutorials\m-auto.online\renault_links.json"
$R2_BASE_URL = "https://8d2cf9429e3c19524a14a659e5a07183.r2.cloudflarestorage.com/m-auto-software/Renault"

function Write-Header {
    Clear-Host
    Write-Host ""
    Write-Host "  ${e}[38;2;255;204;0m+------------------------------------------------------+${e}[0m"
    Write-Host "  ${e}[38;2;255;204;0m|${e}[0m  ${e}[1;97mRenault Links Generator${e}[0m"
    Write-Host "  ${e}[38;2;255;204;0m+------------------------------------------------------+${e}[0m"
    Write-Host ""
}

function Write-OK($msg)   { Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  $msg" }
function Write-Err($msg)  { Write-Host "  ${e}[38;2;239;68;68m[X]${e}[0m   $msg" }
function Write-Info($msg) { Write-Host "  ${e}[38;2;148;163;184m[.]${e}[0m   $msg" }

Write-Header

if (-not (Test-Path $SOURCE_DIR)) {
    Write-Err "Pasta nao encontrada: $SOURCE_DIR"
    exit 1
}

Write-Info "A procurar ficheiros em: $SOURCE_DIR"
$files = Get-ChildItem -Path $SOURCE_DIR -File -Recurse | Sort-Object FullName

if ($files.Count -eq 0) {
    Write-Err "Nenhum ficheiro encontrado."
    exit 1
}

Write-OK "Encontrados $($files.Count) ficheiro(s)."
Write-Host ""
Write-Info "A processar ficheiros..."
Write-Host ""

$links = @()
$num = 0
foreach ($file in $files) {
    $num++
    $relativePath = $file.FullName.Substring($SOURCE_DIR.Length + 1).Replace('\', '/')
    $encodedPath = [uri]::EscapeDataString($relativePath).Replace('%2F', '/')
    $url = "$R2_BASE_URL/$encodedPath"

    $links += @{
        name = $file.Name
        url = $url
    }

    $sizeMB = [math]::Round($file.Length / 1MB, 1)
    Write-OK "[$num/$($files.Count)] $($file.Name) ($sizeMB MB)"
}

$json = @{
    generated = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    files = $links
} | ConvertTo-Json -Depth 10

Write-Host ""
Write-Info "A guardar em: $OUTPUT_FILE"
$json | Out-File -FilePath $OUTPUT_FILE -Encoding UTF8 -Force

Write-OK "Links gerados com sucesso!"
Write-Host ""
