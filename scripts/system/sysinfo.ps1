# system/sysinfo.ps1 — informação do sistema
$ESC = [char]27

function Write-Row($label, $value) {
    Write-Host "  $ESC[38;2;100;149;237m$($label.PadRight(20))$ESC[0m  $ESC[97m$value$ESC[0m"
}

Write-Host ""
Write-Host "  $ESC[1;97mInformação do Sistema$ESC[0m"
Write-Host "  $ESC[38;2;50;60;80m" + ("─" * 54) + "$ESC[0m"
Write-Host ""

$os   = Get-CimInstance Win32_OperatingSystem
$cpu  = Get-CimInstance Win32_Processor | Select-Object -First 1
$ram  = [math]::Round($os.TotalVisibleMemorySize / 1MB, 1)
$free = [math]::Round($os.FreePhysicalMemory / 1MB, 1)
$disk = Get-PSDrive C | Select-Object Used, Free
$diskUsed = [math]::Round($disk.Used / 1GB, 1)
$diskFree = [math]::Round($disk.Free / 1GB, 1)

Write-Row "Sistema Operativo"  "$($os.Caption) ($($os.OSArchitecture))"
Write-Row "Build"              $os.BuildNumber
Write-Row "Processador"        $cpu.Name.Trim()
Write-Row "Núcleos / Threads"  "$($cpu.NumberOfCores) cores / $($cpu.NumberOfLogicalProcessors) threads"
Write-Row "RAM Total"          "${ram} GB  (livre: ${free} GB)"
Write-Row "Disco C:"           "Usado: ${diskUsed} GB  |  Livre: ${diskFree} GB"
Write-Row "Hostname"           $env:COMPUTERNAME
Write-Row "Utilizador"         $env:USERNAME

Write-Host ""
Invoke-Pause
