# setup_contextmenu.ps1 - Registers M-Auto context menu entries in Windows Explorer
$ps         = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
$scriptFile = "D:\Tutorials\m-auto.online\scripts\tools\gerar_link_contextmenu.ps1"
$scriptDir  = "D:\Tutorials\m-auto.online\scripts\tools\gerar_links_pasta.ps1"
$iconAria   = "shell32.dll,14"    # download arrow icon
$iconHTTP   = "shell32.dll,259"   # link/chain icon

# Helper: build PowerShell command string
function Build-Cmd($script, $mode) {
    return "`"$ps`" -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$script`" -Path `"%1`" -Mode $mode"
}

# Remove old single entry if present
foreach ($old in @(
    "HKCU:\Software\Classes\*\shell\GerarLinkMauto",
    "HKCU:\Software\Classes\Directory\shell\GerarLinkMauto"
)) {
    if (Test-Path $old) { Remove-Item $old -Recurse -Force }
}

# ── FILES ─────────────────────────────────────────────────────────────────────

# [1] Aria command (files)
$k = "HKCU:\Software\Classes\*\shell\MAutoLinkAria"
New-Item -Path "$k\command" -Force | Out-Null
Set-ItemProperty -Path $k -Name "(default)" -Value "Link Aria - M-Auto"
Set-ItemProperty -Path $k -Name "Icon"      -Value $iconAria
Set-ItemProperty -Path "$k\command" -Name "(default)" -Value (Build-Cmd $scriptFile "Aria")

# [2] HTTP link (files)
$k = "HKCU:\Software\Classes\*\shell\MAutoLinkHTTP"
New-Item -Path "$k\command" -Force | Out-Null
Set-ItemProperty -Path $k -Name "(default)" -Value "Link HTTP - M-Auto"
Set-ItemProperty -Path $k -Name "Icon"      -Value $iconHTTP
Set-ItemProperty -Path "$k\command" -Name "(default)" -Value (Build-Cmd $scriptFile "HTTP")

# ── FOLDERS ───────────────────────────────────────────────────────────────────

# [3] Aria commands for folder
$k = "HKCU:\Software\Classes\Directory\shell\MAutoLinksAria"
New-Item -Path "$k\command" -Force | Out-Null
Set-ItemProperty -Path $k -Name "(default)" -Value "Links Aria - M-Auto"
Set-ItemProperty -Path $k -Name "Icon"      -Value $iconAria
Set-ItemProperty -Path "$k\command" -Name "(default)" -Value (Build-Cmd $scriptDir "Aria")

# [4] HTTP links for folder
$k = "HKCU:\Software\Classes\Directory\shell\MAutoLinksHTTP"
New-Item -Path "$k\command" -Force | Out-Null
Set-ItemProperty -Path $k -Name "(default)" -Value "Links HTTP - M-Auto"
Set-ItemProperty -Path $k -Name "Icon"      -Value $iconHTTP
Set-ItemProperty -Path "$k\command" -Name "(default)" -Value (Build-Cmd $scriptDir "HTTP")

Write-Host "Menu de contexto registado:"
Write-Host "  Ficheiros : [Link Aria - M-Auto]  [Link HTTP - M-Auto]"
Write-Host "  Pastas    : [Links Aria - M-Auto] [Links HTTP - M-Auto]"
Write-Host ""
Write-Host "Corre o setup de novo se mudares os paths dos scripts."
