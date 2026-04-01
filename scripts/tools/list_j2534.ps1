# tools/list_j2534.ps1 - Listar interfaces J2534 instalados
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27

Write-Host ""
Write-Host "  ${e}[1;97mInterfaces J2534 Instalados${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

$found = @()

# Caminhos registry J2534 (32-bit e 64-bit)
$regPaths = @(
    "HKLM:\SOFTWARE\PassThruSupport.04.04",
    "HKLM:\SOFTWARE\WOW6432Node\PassThruSupport.04.04"
)

foreach ($regPath in $regPaths) {
    if (Test-Path $regPath) {
        $devices = Get-ChildItem -Path $regPath -ErrorAction SilentlyContinue
        foreach ($device in $devices) {
            $props = Get-ItemProperty -Path $device.PSPath -ErrorAction SilentlyContinue
            $entry = [PSCustomObject]@{
                Name        = $props.Name
                Vendor      = $props.Vendor
                Version     = $props.ProtocolsSupported
                DLL         = $props.FunctionLibrary
                DLLExists   = if ($props.FunctionLibrary) { Test-Path $props.FunctionLibrary } else { $false }
            }
            $found += $entry
        }
    }
}

if ($found.Count -eq 0) {
    Write-Host "  ${e}[38;2;239;68;68m✖${e}[0m  Nenhum interface J2534 encontrado no registry."
    Write-Host ""
    Write-Host "  ${e}[38;2;148;163;184m  Interfaces comuns: OpenPort 2.0, Drew Tech, Mongoose,${e}[0m"
    Write-Host "  ${e}[38;2;148;163;184m  Tactrix, AVDI, SDConnect, DAS, XENTRY.${e}[0m"
} else {
    Write-Host "  ${e}[38;2;34;197;94m✔${e}[0m  Encontrados: $($found.Count) interface(s)"
    Write-Host ""

    foreach ($dev in $found) {
        $dllStatus = if ($dev.DLLExists) {
            "${e}[38;2;34;197;94m[OK]${e}[0m"
        } else {
            "${e}[38;2;239;68;68m[DLL NAO ENCONTRADA]${e}[0m"
        }

        Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  $($dev.Name)"
        if ($dev.Vendor)  { Write-Host "      Vendor  : $($dev.Vendor)" }
        if ($dev.DLL)     { Write-Host "      DLL     : $($dev.DLL)  $dllStatus" }
        Write-Host ""
    }
}

Read-Host "  Pressione ENTER para voltar"
