# system/sysinfo.ps1
$e = [char]27

function Write-Row($label, $value) {
    Write-Host "  ${e}[38;2;100;149;237m$($label.PadRight(24))${e}[0m  ${e}[97m$value${e}[0m"
}

Write-Host ""
Write-Host "  ${e}[1;97mInformacao do Sistema${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
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
Write-Row "Nucleos / Threads"  "$($cpu.NumberOfCores) cores / $($cpu.NumberOfLogicalProcessors) threads"
Write-Row "RAM Total"          "${ram} GB  (livre: ${free} GB)"
Write-Row "Disco C:"           "Usado: ${diskUsed} GB  |  Livre: ${diskFree} GB"
Write-Row "Hostname"           $env:COMPUTERNAME
Write-Row "Utilizador"         $env:USERNAME

Write-Host ""
Wait-Key
