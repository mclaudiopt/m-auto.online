param([string]$Path, [string]$Mode = "Aria")

Add-Type -AssemblyName System.Windows.Forms

$RCLONE  = "C:\Users\marce\AppData\Local\Microsoft\WinGet\Packages\Rclone.Rclone_Microsoft.Winget.Source_8wekyb3d8bbwe\rclone-v1.73.4-windows-amd64\rclone.exe"
$DRIVE   = "Z:"
$BUCKET  = "r2-mauto:m-auto-software"
$OUT_DIR = "D:\Tutorials\m-auto.online\scripts\clientes"

if (-not $Path.StartsWith($DRIVE, [System.StringComparison]::OrdinalIgnoreCase)) {
    [System.Windows.Forms.MessageBox]::Show(
        "Seleciona um ficheiro no drive R2 ($DRIVE\).",
        "M-Auto - Link",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Warning
    ) | Out-Null
    exit 1
}

$relativePath = $Path.Substring($DRIVE.Length).TrimStart('\').Replace('\', '/')
$remotePath   = "$BUCKET/$relativePath"
$fileName     = (Split-Path $Path -Leaf).Trim()

$EXPIRES = if ($Mode -eq "HTTP") { "168h" } else { "24h" }
$url = & $RCLONE link $remotePath --expire $EXPIRES 2>&1

if ($LASTEXITCODE -ne 0) {
    [System.Windows.Forms.MessageBox]::Show(
        "Erro ao gerar link:`n`n$url",
        "M-Auto - Erro",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    ) | Out-Null
    exit 1
}

# Gerar script cliente (HttpWebRequest streaming com progress bar)
$clientScript = @"
Clear-Host
`$host.UI.RawUI.WindowTitle = "M-Auto - Download"
`$URL  = "$url"
`$DEST = "C:\M-AUTO\Temp\$fileName"
if (-not (Test-Path "C:\M-AUTO\Temp")) { New-Item -ItemType Directory -Path "C:\M-AUTO\Temp" -Force | Out-Null }

# Ativar ANSI
try {
    Add-Type -Name VT -Namespace Win32 -MemberDefinition '[DllImport("kernel32.dll")] public static extern IntPtr GetStdHandle(int h); [DllImport("kernel32.dll")] public static extern bool GetConsoleMode(IntPtr h, out uint m); [DllImport("kernel32.dll")] public static extern bool SetConsoleMode(IntPtr h, uint m);' -EA SilentlyContinue
    `$hh = [Win32.VT]::GetStdHandle(-11); `$mm = 0
    [Win32.VT]::GetConsoleMode(`$hh, [ref]`$mm) | Out-Null
    [Win32.VT]::SetConsoleMode(`$hh, (`$mm -bor 4)) | Out-Null
} catch {}
`$e    = [char]27
`$ARIA = "`$env:TEMP\aria2c.exe"
`$RPC  = "http://localhost:6801/jsonrpc"
`$TOK  = "mauto2026"

Write-Host ""
Write-Host "  `${e}[38;2;29;155;255m+--------------------------------------------------+`${e}[0m"
Write-Host "  `${e}[38;2;29;155;255m|`${e}[0m  `${e}[1;97mM-Auto Online`${e}[0m  `${e}[38;2;100;149;237mDownload`${e}[0m"
Write-Host "  `${e}[38;2;29;155;255m+--------------------------------------------------+`${e}[0m"
Write-Host ""
Write-Host "  `${e}[38;2;148;163;184mFicheiro:`${e}[0m $fileName"
Write-Host "  `${e}[38;2;148;163;184mDestino: `${e}[0m `$DEST"
Write-Host ""

# Instalar aria2c se necessario
if (-not (Test-Path `$ARIA)) {
    Write-Host "  `${e}[38;2;250;204;21m[!]   A instalar motor de download (aria2c)...`${e}[0m"
    try {
        `$zip = "`$env:TEMP\aria2.zip"
        Invoke-WebRequest "https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip" -OutFile `$zip -UseBasicParsing
        Expand-Archive `$zip -DestinationPath "`$env:TEMP\aria2x" -Force
        Copy-Item "`$env:TEMP\aria2x\aria2-1.37.0-win-64bit-build1\aria2c.exe" `$ARIA -Force
        Remove-Item `$zip, "`$env:TEMP\aria2x" -Recurse -Force -EA SilentlyContinue
        Write-Host "  `${e}[38;2;34;197;94m[OK]  aria2c pronto`${e}[0m"
        Write-Host ""
    } catch { Write-Host "  `${e}[38;2;239;68;68m[X]   Erro: `$_`${e}[0m"; Read-Host "ENTER"; exit 1 }
}

# Detect system proxy
`$proxyArg = ""
try {
    `$rp = Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -EA SilentlyContinue
    if (`$rp.ProxyEnable -eq 1 -and `$rp.ProxyServer) {
        `$proxyArg = "--all-proxy=http://`$(`$rp.ProxyServer)"
        Write-Host "  `${e}[38;2;250;204;21m[i]   Proxy detetado: `$(`$rp.ProxyServer)`${e}[0m"
    }
} catch {}

# Iniciar daemon aria2c (se proxy detetado, forcar reinicio para aplicar proxy)
`$aria2Proc = `$null
if (`$proxyArg) {
    Get-Process -Name aria2c -EA SilentlyContinue | Stop-Process -Force -EA SilentlyContinue
    Start-Sleep -Milliseconds 400
    `$aria2Proc = Start-Process -FilePath `$ARIA -ArgumentList "--enable-rpc --rpc-listen-port=6801 --rpc-secret=`$TOK --rpc-allow-origin-all --file-allocation=none --quiet=true --disable-ipv6=true `$proxyArg" -PassThru -WindowStyle Hidden
    Start-Sleep -Milliseconds 1200
} else {
    try {
        `$test = Invoke-RestMethod -Uri `$RPC -Method Post -Body '{"jsonrpc":"2.0","id":"1","method":"aria2.getVersion","params":["token:mauto2026"]}' -ContentType "application/json" -TimeoutSec 2 -EA Stop
    } catch {
        `$aria2Proc = Start-Process -FilePath `$ARIA -ArgumentList "--enable-rpc --rpc-listen-port=6801 --rpc-secret=`$TOK --rpc-allow-origin-all --file-allocation=none --quiet=true --disable-ipv6=true" -PassThru -WindowStyle Hidden
        Start-Sleep -Milliseconds 1200
    }
}

try {
    # Adicionar download
    `$opts = @{ dir = "C:\M-AUTO\Temp"; out = "$fileName"; split = "32"; "max-connection-per-server" = "32"; "min-split-size" = "4M" }
    `$body = @{ jsonrpc="2.0"; id="1"; method="aria2.addUri"; params=@("token:`$TOK",@("`$URL"),`$opts) } | ConvertTo-Json -Depth 5 -Compress
    `$gid  = (Invoke-RestMethod -Uri `$RPC -Method Post -Body `$body -ContentType "application/json").result

    # Barra de progresso
    `$barW = 36; `$lastDown = 0; `$lastTick = [DateTime]::Now
    do {
        Start-Sleep -Milliseconds 800
        `$sb   = @{ jsonrpc="2.0"; id="1"; method="aria2.tellStatus"; params=@("token:`$TOK","`$gid") } | ConvertTo-Json -Depth 3 -Compress
        `$s    = (Invoke-RestMethod -Uri `$RPC -Method Post -Body `$sb -ContentType "application/json").result
        `$tot  = [long]`$s.totalLength
        `$down = [long]`$s.completedLength
        `$cn   = `$s.connections
        `$dt   = ([DateTime]::Now - `$lastTick).TotalSeconds
        `$spd  = if (`$dt -gt 0) { (`$down - `$lastDown) / `$dt } else { 0 }
        `$lastDown = `$down; `$lastTick = [DateTime]::Now
        `$pct    = if (`$tot -gt 0) { [int](`$down/`$tot*100) } else { 0 }
        `$mb     = "{0:N1}" -f (`$down/1MB)
        `$totMB  = "{0:N1}" -f (`$tot/1MB)
        `$spdStr = if (`$spd -gt 1MB) { "{0:N1} MB/s" -f (`$spd/1MB) } elseif (`$spd -gt 1KB) { "{0:N0} KB/s" -f (`$spd/1KB) } else { "-- KB/s" }
        `$etaStr = if (`$spd -gt 0 -and `$tot -gt `$down) {
            `$r = (`$tot-`$down)/`$spd
            if (`$r -gt 3600) { "{0}h{1:D2}m" -f [int](`$r/3600),[int]((`$r%3600)/60) }
            elseif (`$r -gt 60) { "{0}m{1:D2}s" -f [int](`$r/60),[int](`$r%60) }
            else { "{0}s" -f [int]`$r }
        } else { "--" }
        `$filled = [int](`$barW * `$pct / 100)
        `$bar    = ("`${e}[38;2;29;155;255m" + ([string][char]9608*`$filled)) + ("`${e}[38;2;40;50;70m" + ([string][char]9617*(`$barW-`$filled))) + "`${e}[0m"
        Write-Host -NoNewline ([char]13 + "  [`$bar] `${e}[1;97m`$pct%`${e}[0m  `${e}[38;2;148;163;184m`$mb/`$totMB MB`${e}[0m  `${e}[38;2;34;197;94m`$spdStr`${e}[0m  ETA `${e}[38;2;250;204;21m`$etaStr`${e}[0m  CN:`$cn   ")
    } while (`$s.status -eq "active" -or `$s.status -eq "waiting")

    Write-Host ""; Write-Host ""
    if (`$s.status -eq "complete") { Write-Host "  `${e}[38;2;34;197;94m[OK]  Concluido: C:\M-AUTO\Temp\$fileName`${e}[0m" }
    else { Write-Host "  `${e}[38;2;239;68;68m[X]   Erro: `$(`$s.errorMessage)`${e}[0m" }
} catch {
    Write-Host "  `${e}[38;2;239;68;68m[X]   Erro: `$_`${e}[0m"
} finally {
    if (`$aria2Proc) { `$aria2Proc | Stop-Process -Force -EA SilentlyContinue }
}

Write-Host ""
Read-Host "  Pressione ENTER para sair"
"@

if ($Mode -eq "HTTP") {
    # HTTP mode: copy just the URL to clipboard
    $url | Set-Clipboard

    [System.Windows.Forms.MessageBox]::Show(
        "Link HTTP copiado para clipboard.`n`nFicheiro: $fileName`nValidade: 7 dias`n`nCola o link no browser ou partilha diretamente.",
        "M-Auto - Link HTTP",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    ) | Out-Null
} else {
    # Aria mode: encode full download script and copy command to clipboard
    $encoded   = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($clientScript))
    $oneliner  = "powershell -NoProfile -ExecutionPolicy Bypass -EncodedCommand $encoded"
    $oneliner | Set-Clipboard

    [System.Windows.Forms.MessageBox]::Show(
        "Comando Aria copiado para clipboard.`n`nFicheiro: $fileName`nValidade: 24 horas`n`nO cliente abre PowerShell, cola a linha e prime Enter.",
        "M-Auto - Link Aria",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Information
    ) | Out-Null
}
