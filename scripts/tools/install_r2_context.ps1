# install_r2_context.ps1 - Add R2 Link entries to Explorer right-click menu
# Sem admin necessario — usa HKCU
# Uso:
#   install_r2_context.ps1            -> instala
#   install_r2_context.ps1 -Uninstall -> remove

param([switch]$Uninstall)

$VbsFile   = "D:\Tutorials\m-auto.online\scripts\tools\r2_link.vbs"
$VbsFolder = "D:\Tutorials\m-auto.online\scripts\tools\r2_links_folder.vbs"
$APP_ID    = "M-Auto.R2Link"

$keys = @(
    "HKCU:\Software\Classes\*\shell\R2Link",                                # File right-click
    "HKCU:\Software\Classes\Directory\shell\R2LinksFolder",                 # Folder right-click
    "HKCU:\Software\Classes\Directory\Background\shell\R2LinksFolder",      # Inside-folder right-click
    "HKCU:\Software\Classes\AppUserModelId\$APP_ID"                         # Toast AppID
)

if ($Uninstall) {
    foreach ($k in $keys) { Remove-Item $k -Recurse -Force -ErrorAction SilentlyContinue }
    Write-Host "[OK] Menu de contexto e AppID removidos!" -ForegroundColor Green
    exit 0
}

if (-not (Test-Path $VbsFile))   { Write-Host "[X] $VbsFile nao encontrado"   -ForegroundColor Red; exit 1 }
if (-not (Test-Path $VbsFolder)) { Write-Host "[X] $VbsFolder nao encontrado" -ForegroundColor Red; exit 1 }

# 1) Registar AppID para toasts
$appKey = "HKCU:\Software\Classes\AppUserModelId\$APP_ID"
New-Item -Path $appKey -Force | Out-Null
Set-ItemProperty -Path $appKey -Name "DisplayName"    -Value "M-Auto R2 Link"
Set-ItemProperty -Path $appKey -Name "IconUri"        -Value "$env:SystemRoot\System32\imageres.dll,165"
Set-ItemProperty -Path $appKey -Name "ShowInSettings" -Value 1 -Type DWord

# 2) Right-click num ficheiro
$base = "HKCU:\Software\Classes\*\shell\R2Link"
New-Item -Path $base -Force | Out-Null
Set-ItemProperty -Path $base -Name "(Default)" -Value "Generate R2 Link (m-auto)"
Set-ItemProperty -Path $base -Name "Icon" -Value "imageres.dll,165"
New-Item -Path "$base\command" -Force | Out-Null
Set-ItemProperty -Path "$base\command" -Name "(Default)" -Value "wscript.exe `"$VbsFile`" `"%1`""

# 3) Right-click numa pasta
foreach ($p in @("HKCU:\Software\Classes\Directory\shell\R2LinksFolder",
                 "HKCU:\Software\Classes\Directory\Background\shell\R2LinksFolder")) {
    New-Item -Path $p -Force | Out-Null
    Set-ItemProperty -Path $p -Name "(Default)" -Value "Generate R2 Links (todos os ficheiros)"
    Set-ItemProperty -Path $p -Name "Icon" -Value "imageres.dll,165"
    New-Item -Path "$p\command" -Force | Out-Null
}
# %1 para clicar SOBRE pasta, %V para clicar DENTRO de pasta vazia
Set-ItemProperty -Path "HKCU:\Software\Classes\Directory\shell\R2LinksFolder\command"            -Name "(Default)" -Value "wscript.exe `"$VbsFolder`" `"%1`""
Set-ItemProperty -Path "HKCU:\Software\Classes\Directory\Background\shell\R2LinksFolder\command" -Name "(Default)" -Value "wscript.exe `"$VbsFolder`" `"%V`""

Write-Host "[OK] Menu de contexto instalado!" -ForegroundColor Green
Write-Host ""
Write-Host "  Botao direito num FICHEIRO -> 'Generate R2 Link (m-auto)'"          -ForegroundColor Cyan
Write-Host "  Botao direito numa PASTA   -> 'Generate R2 Links (todos os ...)'"   -ForegroundColor Cyan
Write-Host ""
Write-Host "  AppID '$APP_ID' registado para toasts."                              -ForegroundColor Gray
Write-Host "  Para remover: install_r2_context.ps1 -Uninstall"                     -ForegroundColor Gray
