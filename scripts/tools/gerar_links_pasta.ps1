param([string]$Path, [string]$Mode = "Both")

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$RCLONE  = "C:\Users\marce\AppData\Local\Microsoft\WinGet\Packages\Rclone.Rclone_Microsoft.Winget.Source_8wekyb3d8bbwe\rclone-v1.73.4-windows-amd64\rclone.exe"
$DRIVE   = "Z:"
$BUCKET  = "r2-mauto:m-auto-software"
$EXPIRES = "168h"

if (-not $Path.StartsWith($DRIVE, [System.StringComparison]::OrdinalIgnoreCase)) {
    [System.Windows.Forms.MessageBox]::Show("Seleciona uma pasta no drive R2 ($DRIVE\).", "M-Auto", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning) | Out-Null
    exit 1
}

$files = Get-ChildItem -Path $Path -File | Sort-Object Name
if ($files.Count -eq 0) {
    [System.Windows.Forms.MessageBox]::Show("Pasta vazia ou sem ficheiros diretos.", "M-Auto", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning) | Out-Null
    exit 0
}

# Build encoded aria2c download command for a file
function New-DownloadCommand($url, $fileName) {
    $fileName = $fileName.Trim()
    $script = @"
Clear-Host
`$host.UI.RawUI.WindowTitle = "M-Auto - Download"
`$URL  = "$url"
`$DEST = "C:\M-AUTO\Temp\$fileName"
if (-not (Test-Path "C:\M-AUTO\Temp")) { New-Item -ItemType Directory -Path "C:\M-AUTO\Temp" -Force | Out-Null }
try { Add-Type -Name VT -Namespace Win32 -MemberDefinition '[DllImport("kernel32.dll")] public static extern IntPtr GetStdHandle(int h); [DllImport("kernel32.dll")] public static extern bool GetConsoleMode(IntPtr h, out uint m); [DllImport("kernel32.dll")] public static extern bool SetConsoleMode(IntPtr h, uint m);' -EA SilentlyContinue; `$hh=[Win32.VT]::GetStdHandle(-11); `$mm=0; [Win32.VT]::GetConsoleMode(`$hh,[ref]`$mm)|Out-Null; [Win32.VT]::SetConsoleMode(`$hh,(`$mm -bor 4))|Out-Null } catch {}
`$e=[char]27; `$ARIA="`$env:TEMP\aria2c.exe"; `$RPC="http://localhost:6801/jsonrpc"; `$TOK="mauto2026"
Write-Host ""; Write-Host "  `${e}[38;2;29;155;255m+--------------------------------------------------+`${e}[0m"
Write-Host "  `${e}[38;2;29;155;255m|`${e}[0m  `${e}[1;97mM-Auto Online`${e}[0m  `${e}[38;2;100;149;237mDownload`${e}[0m"
Write-Host "  `${e}[38;2;29;155;255m+--------------------------------------------------+`${e}[0m"
Write-Host ""; Write-Host "  `${e}[38;2;148;163;184mFicheiro:`${e}[0m $fileName"; Write-Host "  `${e}[38;2;148;163;184mDestino: `${e}[0m `$DEST"; Write-Host ""
if (-not (Test-Path `$ARIA)) {
    Write-Host "  `${e}[38;2;250;204;21m[!]   A instalar aria2c...`${e}[0m"
    try { `$zip="`$env:TEMP\aria2.zip"; Invoke-WebRequest "https://github.com/aria2/aria2/releases/download/release-1.37.0/aria2-1.37.0-win-64bit-build1.zip" -OutFile `$zip -UseBasicParsing; Expand-Archive `$zip -DestinationPath "`$env:TEMP\aria2x" -Force; Copy-Item "`$env:TEMP\aria2x\aria2-1.37.0-win-64bit-build1\aria2c.exe" `$ARIA -Force; Remove-Item `$zip,"`$env:TEMP\aria2x" -Recurse -Force -EA SilentlyContinue; Write-Host "  `${e}[38;2;34;197;94m[OK]  aria2c pronto`${e}[0m"; Write-Host "" } catch { Write-Host "  `${e}[38;2;239;68;68m[X]   Erro: `$_`${e}[0m"; Read-Host "ENTER"; exit 1 }
}
`$proxyArg=""; try { `$rp=Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings" -EA SilentlyContinue; if(`$rp.ProxyEnable -eq 1 -and `$rp.ProxyServer){`$proxyArg="--all-proxy=http://`$(`$rp.ProxyServer)"; Write-Host "  `${e}[38;2;250;204;21m[i]   Proxy: `$(`$rp.ProxyServer)`${e}[0m"} } catch {}
`$aria2Proc=`$null
if (`$proxyArg) {
    Get-Process -Name aria2c -EA SilentlyContinue | Stop-Process -Force -EA SilentlyContinue; Start-Sleep -Milliseconds 400
    `$aria2Proc=Start-Process -FilePath `$ARIA -ArgumentList "--enable-rpc --rpc-listen-port=6801 --rpc-secret=`$TOK --rpc-allow-origin-all --file-allocation=none --quiet=true --disable-ipv6=true `$proxyArg" -PassThru -WindowStyle Hidden; Start-Sleep -Milliseconds 1200
} else {
    try { Invoke-RestMethod -Uri `$RPC -Method Post -Body '{"jsonrpc":"2.0","id":"1","method":"aria2.getVersion","params":["token:mauto2026"]}' -ContentType "application/json" -TimeoutSec 2 -EA Stop } catch { `$aria2Proc=Start-Process -FilePath `$ARIA -ArgumentList "--enable-rpc --rpc-listen-port=6801 --rpc-secret=`$TOK --rpc-allow-origin-all --file-allocation=none --quiet=true --disable-ipv6=true" -PassThru -WindowStyle Hidden; Start-Sleep -Milliseconds 1200 }
}
try {
    `$opts=@{dir="C:\M-AUTO\Temp";out="$fileName";split="32";"max-connection-per-server"="32";"min-split-size"="4M"}
    `$body=@{jsonrpc="2.0";id="1";method="aria2.addUri";params=@("token:`$TOK",@("`$URL"),`$opts)}|ConvertTo-Json -Depth 5 -Compress
    `$gid=(Invoke-RestMethod -Uri `$RPC -Method Post -Body `$body -ContentType "application/json").result
    `$barW=36;`$lastDown=0;`$lastTick=[DateTime]::Now
    do {
        Start-Sleep -Milliseconds 800
        `$sb=@{jsonrpc="2.0";id="1";method="aria2.tellStatus";params=@("token:`$TOK","`$gid")}|ConvertTo-Json -Depth 3 -Compress
        `$s=(Invoke-RestMethod -Uri `$RPC -Method Post -Body `$sb -ContentType "application/json").result
        `$tot=[long]`$s.totalLength;`$down=[long]`$s.completedLength;`$cn=`$s.connections
        `$dt=([DateTime]::Now-`$lastTick).TotalSeconds;`$spd=if(`$dt -gt 0){(`$down-`$lastDown)/`$dt}else{0};`$lastDown=`$down;`$lastTick=[DateTime]::Now
        `$pct=if(`$tot -gt 0){[int](`$down/`$tot*100)}else{0};`$mb="{0:N1}"-f(`$down/1MB);`$totMB="{0:N1}"-f(`$tot/1MB)
        `$spdStr=if(`$spd -gt 1MB){"{0:N1} MB/s"-f(`$spd/1MB)}elseif(`$spd -gt 1KB){"{0:N0} KB/s"-f(`$spd/1KB)}else{"-- KB/s"}
        `$etaStr=if(`$spd -gt 0 -and `$tot -gt `$down){`$r=(`$tot-`$down)/`$spd;if(`$r -gt 3600){"{0}h{1:D2}m"-f[int](`$r/3600),[int]((`$r%3600)/60)}elseif(`$r -gt 60){"{0}m{1:D2}s"-f[int](`$r/60),[int](`$r%60)}else{"{0}s"-f[int]`$r}}else{"--"}
        `$filled=[int](`$barW*`$pct/100);`$bar=("`${e}[38;2;29;155;255m"+([string][char]9608*`$filled))+("`${e}[38;2;40;50;70m"+([string][char]9617*(`$barW-`$filled)))+"`${e}[0m"
        Write-Host -NoNewline ([char]13+"  [`$bar] `${e}[1;97m`$pct%`${e}[0m  `${e}[38;2;148;163;184m`$mb/`$totMB MB`${e}[0m  `${e}[38;2;34;197;94m`$spdStr`${e}[0m  ETA `${e}[38;2;250;204;21m`$etaStr`${e}[0m  CN:`$cn   ")
    } while (`$s.status -eq "active" -or `$s.status -eq "waiting")
    Write-Host "";Write-Host ""
    if (`$s.status -eq "complete"){Write-Host "  `${e}[38;2;34;197;94m[OK]  Concluido: C:\M-AUTO\Temp\$fileName`${e}[0m"}else{Write-Host "  `${e}[38;2;239;68;68m[X]   Erro: `$(`$s.errorMessage)`${e}[0m"}
} catch { Write-Host "  `${e}[38;2;239;68;68m[X]   Erro: `$_`${e}[0m" } finally { if(`$aria2Proc){`$aria2Proc|Stop-Process -Force -EA SilentlyContinue} }
Write-Host ""; Read-Host "  Pressione ENTER para sair"
"@
    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($script))
    return "powershell -NoProfile -ExecutionPolicy Bypass -EncodedCommand $encoded"
}

# ── Parallel URL generation via runspaces ──────────────────────────────────────
$pool = [System.Management.Automation.Runspaces.RunspaceFactory]::CreateRunspacePool(1, [Math]::Min($files.Count, 8))
$pool.Open()

$jobs = foreach ($f in $files) {
    $ps = [PowerShell]::Create()
    $ps.RunspacePool = $pool
    [void]$ps.AddScript({
        param($rclone, $bucket, $drive, $fullPath, $expires)
        $rel  = $fullPath.Substring($drive.Length).TrimStart('\').Replace('\','/')
        $url  = & $rclone link "$bucket/$rel" --expire $expires 2>&1
        [PSCustomObject]@{ FullName=$fullPath; Name=(Split-Path $fullPath -Leaf).Trim(); URL=if($LASTEXITCODE -eq 0){[string]$url}else{''}; OK=($LASTEXITCODE -eq 0) }
    })
    [void]$ps.AddParameters(@{ rclone=$RCLONE; bucket=$BUCKET; drive=$DRIVE; fullPath=$f.FullName; expires=$EXPIRES })
    [PSCustomObject]@{ PS=$ps; Handle=$ps.BeginInvoke() }
}

# Collect results in original order
$results = foreach ($j in $jobs) {
    $j.PS.EndInvoke($j.Handle)[0]
    $j.PS.Dispose()
}
$pool.Close(); $pool.Dispose()

# Sort back by name
$results = $results | Sort-Object Name

# ── Build output strings ───────────────────────────────────────────────────────
$ts = Get-Date -Format 'yyyy-MM-dd HH:mm'
$folderName = Split-Path $Path -Leaf

$allURLs  = @()
$allCMDs  = @()
foreach ($r in $results) {
    if ($r.OK) {
        $allURLs += $r.URL
        $allCMDs += New-DownloadCommand $r.URL $r.Name
    } else {
        $allURLs += "ERRO"
        $allCMDs += "ERRO"
    }
}

# ── WinForms result dialog ─────────────────────────────────────────────────────
$showURL = ($Mode -eq "Both" -or $Mode -eq "HTTP")
$showCMD = ($Mode -eq "Both" -or $Mode -eq "Aria")

$form = New-Object System.Windows.Forms.Form
$form.Text = "M-Auto  —  $folderName  ($($results.Count) ficheiros)"
$form.Size = New-Object System.Drawing.Size(780, 480)
$form.StartPosition = "CenterScreen"
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$form.BackColor = [System.Drawing.Color]::FromArgb(15, 23, 42)
$form.ForeColor = [System.Drawing.Color]::FromArgb(203, 213, 225)
$form.MinimumSize = New-Object System.Drawing.Size(600, 350)

# Top bar
$top = New-Object System.Windows.Forms.Panel
$top.Dock = "Top"; $top.Height = 44; $top.BackColor = [System.Drawing.Color]::FromArgb(22, 33, 56)
$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "M-Auto Online  —  Links gerados  ($ts  ·  Validade: 7 dias)"; $lblTitle.ForeColor = [System.Drawing.Color]::FromArgb(148,163,184)
$lblTitle.AutoSize = $true; $lblTitle.Location = New-Object System.Drawing.Point(12,13)
$top.Controls.Add($lblTitle); $form.Controls.Add($top)

# Grid
$grid = New-Object System.Windows.Forms.DataGridView
$grid.Dock = "Fill"; $grid.AllowUserToAddRows = $false; $grid.AllowUserToDeleteRows = $false
$grid.ReadOnly = $true; $grid.SelectionMode = "FullRowSelect"; $grid.MultiSelect = $false
$grid.RowHeadersVisible = $false; $grid.AutoSizeColumnsMode = "Fill"
$grid.BackgroundColor = [System.Drawing.Color]::FromArgb(15,23,42)
$grid.GridColor = [System.Drawing.Color]::FromArgb(30,41,59)
$grid.DefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(15,23,42)
$grid.DefaultCellStyle.ForeColor = [System.Drawing.Color]::FromArgb(226,232,240)
$grid.DefaultCellStyle.SelectionBackColor = [System.Drawing.Color]::FromArgb(29,155,255)
$grid.DefaultCellStyle.SelectionForeColor = [System.Drawing.Color]::White
$grid.ColumnHeadersDefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(22,33,56)
$grid.ColumnHeadersDefaultCellStyle.ForeColor = [System.Drawing.Color]::FromArgb(148,163,184)
$grid.EnableHeadersVisualStyles = $false
$grid.ColumnHeadersHeight = 28

$colN    = New-Object System.Windows.Forms.DataGridViewTextBoxColumn; $colN.HeaderText="#"; $colN.FillWeight=4; $colN.DefaultCellStyle.Alignment="MiddleCenter"
$colName = New-Object System.Windows.Forms.DataGridViewTextBoxColumn; $colName.HeaderText="Ficheiro"; $colName.FillWeight=40
$colStat = New-Object System.Windows.Forms.DataGridViewTextBoxColumn; $colStat.HeaderText="Estado"; $colStat.FillWeight=10; $colStat.DefaultCellStyle.Alignment="MiddleCenter"
$grid.Columns.AddRange($colN, $colName, $colStat)

for ($i = 0; $i -lt $results.Count; $i++) {
    $r = $results[$i]
    $row = $grid.Rows.Add(($i+1), $r.Name, $(if($r.OK){"✓"}else{"✗"}))
    if (-not $r.OK) { $grid.Rows[$row].DefaultCellStyle.ForeColor = [System.Drawing.Color]::FromArgb(239,68,68) }
}

# Bottom bar
$bot = New-Object System.Windows.Forms.Panel
$bot.Dock = "Bottom"; $bot.Height = 50; $bot.BackColor = [System.Drawing.Color]::FromArgb(22,33,56)
$bot.Padding = New-Object System.Windows.Forms.Padding(8,8,8,8)

function New-Btn($txt, $x) {
    $b = New-Object System.Windows.Forms.Button
    $b.Text = $txt; $b.Width = 170; $b.Height = 32; $b.Location = New-Object System.Drawing.Point($x, 8)
    $b.FlatStyle = "Flat"; $b.BackColor = [System.Drawing.Color]::FromArgb(29,155,255)
    $b.ForeColor = [System.Drawing.Color]::White; $b.Font = New-Object System.Drawing.Font("Segoe UI",9,[System.Drawing.FontStyle]::Bold)
    $b.FlatAppearance.BorderSize = 0; return $b
}

$xPos = 8
if ($showCMD) {
    $btnCopyAllAria = New-Btn "Copiar Tudo  [Aria]" $xPos; $xPos += 180
    $btnCopyAllAria.Add_Click({
        $all = ($allCMDs | Where-Object {$_ -ne "ERRO"}) -join "`r`n"
        [System.Windows.Forms.Clipboard]::SetText($all)
        $btnCopyAllAria.Text = "Copiado ✓"; Start-Sleep -Milliseconds 1200; $btnCopyAllAria.Text = "Copiar Tudo  [Aria]"
    }.GetNewClosure())
    $bot.Controls.Add($btnCopyAllAria)

    $btnCopySel = New-Btn "Copiar Selecionado" $xPos; $xPos += 180
    $btnCopySel.Add_Click({
        if ($grid.SelectedRows.Count -gt 0) {
            $idx = $grid.SelectedRows[0].Index
            if ($allCMDs[$idx] -ne "ERRO") {
                [System.Windows.Forms.Clipboard]::SetText($allCMDs[$idx])
                $btnCopySel.Text = "Copiado ✓"; Start-Sleep -Milliseconds 1200; $btnCopySel.Text = "Copiar Selecionado"
            }
        }
    }.GetNewClosure())
    $bot.Controls.Add($btnCopySel)
}

if ($showURL) {
    $btnCopyHTTP = New-Btn "Copiar Tudo  [HTTP]" $xPos; $xPos += 180
    $btnCopyHTTP.BackColor = [System.Drawing.Color]::FromArgb(30,80,140)
    $btnCopyHTTP.Add_Click({
        $all = ($allURLs | Where-Object {$_ -ne "ERRO"}) -join "`r`n"
        [System.Windows.Forms.Clipboard]::SetText($all)
        $btnCopyHTTP.Text = "Copiado ✓"; Start-Sleep -Milliseconds 1200; $btnCopyHTTP.Text = "Copiar Tudo  [HTTP]"
    }.GetNewClosure())
    $bot.Controls.Add($btnCopyHTTP)
}

$btnClose = New-Btn "Fechar" ($form.ClientSize.Width - 120)
$btnClose.BackColor = [System.Drawing.Color]::FromArgb(51,65,85); $btnClose.Width = 90
$btnClose.Add_Click({ $form.Close() })
$btnClose.Anchor = [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Bottom
$bot.Controls.Add($btnClose)

$form.Controls.Add($grid)
$form.Controls.Add($bot)

[void]$form.ShowDialog()
