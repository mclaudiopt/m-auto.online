# tools/setup_r2_autostart.ps1 - Cria atalho de arranque automatico para Z:
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27

$SCRIPT  = "D:\Tutorials\m-auto.online\scripts\tools\mount_r2.ps1"
$STARTUP = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
$LNK     = "$STARTUP\MountR2.lnk"

Write-Host ""
Write-Host "  ${e}[1;97mAutostart — Montar R2 no arranque${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

if (Test-Path $LNK) {
    Write-Host "  ${e}[38;2;34;197;94m✔${e}[0m  Atalho ja existe: $LNK"
    Write-Host ""
    $r = Read-Host "  Recriar? [s/n]"
    if ($r -notmatch "^[sS]") {
        Write-Host ""
        Read-Host "  Pressione ENTER para sair"
        exit 0
    }
    Remove-Item $LNK -Force
}

try {
    $WshShell = New-Object -ComObject WScript.Shell
    $shortcut = $WshShell.CreateShortcut($LNK)
    $shortcut.TargetPath      = "powershell.exe"
    $shortcut.Arguments       = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$SCRIPT`""
    $shortcut.WorkingDirectory = Split-Path $SCRIPT
    $shortcut.Description     = "Montar R2 como Z:"
    $shortcut.WindowStyle     = 7   # minimizado
    $shortcut.Save()

    Write-Host "  ${e}[38;2;34;197;94m✔${e}[0m  Atalho criado em:"
    Write-Host "     $LNK"
    Write-Host ""
    Write-Host "  ${e}[38;2;148;163;184m  O disco Z: sera montado automaticamente no proximo inicio de sessao.${e}[0m"
} catch {
    Write-Host "  ${e}[38;2;239;68;68m✗${e}[0m  Erro ao criar atalho: $_"
}

Write-Host ""
Read-Host "  Pressione ENTER para sair"
