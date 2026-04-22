# mount_qnap.ps1 - Monta QNAP W: com retry
$NAS_LOCAL     = "192.168.1.61"
$NAS_TAILSCALE = "100.88.186.102"
$DRIVE         = "W:"
$MAXWAIT       = 120   # segundos maximos a aguardar rede
$elapsed       = 0

if (Test-Path "$DRIVE\") { exit 0 }   # ja montado

# Aguardar rede ficar disponivel (local ou Tailscale)
$ip = $null
while ($elapsed -lt $MAXWAIT) {
    if (Test-Connection -ComputerName $NAS_LOCAL -Count 1 -Quiet -ErrorAction SilentlyContinue) {
        $ip = $NAS_LOCAL; break
    }
    if (Test-Connection -ComputerName $NAS_TAILSCALE -Count 1 -Quiet -ErrorAction SilentlyContinue) {
        $ip = $NAS_TAILSCALE; break
    }
    Start-Sleep -Seconds 5
    $elapsed += 5
}

if (-not $ip) {
    "QNAP nao acessivel apos $MAXWAIT segundos" | Out-File "$env:TEMP\mount_qnap.log" -Encoding UTF8
    exit 1
}

# Tentar montar com retry
for ($i = 0; $i -lt 5; $i++) {
    $result = net use $DRIVE "\\$ip\M-Auto.online" /persistent:no 2>&1
    if ($LASTEXITCODE -eq 0) { exit 0 }
    Start-Sleep -Seconds 5
}

$result | Out-File "$env:TEMP\mount_qnap.log" -Encoding UTF8
exit 1
