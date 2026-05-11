# install_r2_context.ps1 - Add "Generate R2 Link" to Explorer right-click menu
# Sem admin necessario — usa HKCU
# Uso:
#   install_r2_context.ps1            -> instala
#   install_r2_context.ps1 -Uninstall -> remove

param([switch]$Uninstall)

$VbsPath = "D:\Tutorials\m-auto.online\scripts\tools\r2_link.vbs"
$base    = "HKCU:\Software\Classes\*\shell\R2Link"

if ($Uninstall) {
    Remove-Item $base -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "[OK] Menu de contexto removido!" -ForegroundColor Green
    exit 0
}

if (-not (Test-Path $VbsPath)) {
    Write-Host "[X] Script nao encontrado: $VbsPath" -ForegroundColor Red
    exit 1
}

# Criar entrada principal
New-Item -Path $base -Force | Out-Null
Set-ItemProperty -Path $base -Name "(Default)" -Value "Generate R2 Link (m-auto)"
Set-ItemProperty -Path $base -Name "Icon" -Value "imageres.dll,165"

# Comando — usa VBS wrapper para correr PowerShell totalmente invisivel
$cmdPath = "$base\command"
New-Item -Path $cmdPath -Force | Out-Null
$cmd = "wscript.exe `"$VbsPath`" `"%1`""
Set-ItemProperty -Path $cmdPath -Name "(Default)" -Value $cmd

Write-Host "[OK] Menu de contexto instalado!" -ForegroundColor Green
Write-Host ""
Write-Host "  Botao direito num ficheiro -> 'Generate R2 Link (m-auto)'" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Nota Windows 11: pode estar em 'Show more options' (Shift+F10 abre logo o menu classico)" -ForegroundColor Yellow
Write-Host ""
Write-Host "  Para remover: install_r2_context.ps1 -Uninstall" -ForegroundColor Gray
