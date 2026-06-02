# M-Auto Renew Links Master Script
# Usage: iex (irm https://raw.githubusercontent.com/mclaudiopt/m-auto.online/main/scripts/m-auto.ps1)

param([string]$brand = "merc")

$brands = @{
    'merc'     = 'renew_merc_links.ps1'
    'mercedes' = 'renew_merc_links.ps1'
    'renault'  = 'renew_renault_links.ps1'
    'psa'      = 'renew_psa_links.ps1'
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $scriptDir) { $scriptDir = "D:\Tutorials\m-auto.online\scripts\tools" }

$script = $brands[$brand]
if (-not $script) {
    Write-Host "Disponível: merc, renault, psa"
    exit 1
}

$scriptPath = "$scriptDir\tools\$script"
if (-not (Test-Path $scriptPath)) {
    Write-Host "Script não encontrado: $scriptPath"
    exit 1
}

& $scriptPath
