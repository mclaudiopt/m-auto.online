# prep/tamper_off.ps1 - Desativar Tamper Protection
$e = [char]27

Write-Host ""
Write-Host "  ${e}[1;97mTamper Protection OFF${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

$defSvc = Get-Service -Name WinDefend -ErrorAction SilentlyContinue
$defRunning = $defSvc -and ($defSvc.Status -eq 'Running')

Write-Host "  ${e}[38;2;148;163;184m·${e}[0m  A desativar Tamper Protection..." -NoNewline

if (-not $defRunning) {
    Write-Host "  ${e}[38;2;250;204;21m[JA FEITO]${e}[0m"
} else {
    try {
        $regPath = "HKLM:\SOFTWARE\Microsoft\Windows Defender\Features"
        $acl = Get-Acl $regPath -ErrorAction Stop
        $adminSid = New-Object System.Security.Principal.SecurityIdentifier("S-1-5-32-544")
        $acl.SetOwner($adminSid)
        $rule = New-Object System.Security.AccessControl.RegistryAccessRule(
            $adminSid, "FullControl",
            [System.Security.AccessControl.InheritanceFlags]"ContainerInherit,ObjectInherit",
            [System.Security.AccessControl.PropagationFlags]::None,
            [System.Security.AccessControl.AccessControlType]::Allow
        )
        $acl.AddAccessRule($rule)
        Set-Acl -Path $regPath -AclObject $acl -ErrorAction Stop
        Set-ItemProperty -Path $regPath -Name "TamperProtection" -Value 4 -ErrorAction Stop
        Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
    } catch {
        $tp = (Get-MpComputerStatus -ErrorAction SilentlyContinue).IsTamperProtected
        if ($tp -eq $false) {
            Write-Host "  ${e}[38;2;250;204;21m[JA FEITO]${e}[0m"
        } elseif ($tp -eq $true) {
            Write-Host "  ${e}[38;2;250;204;21m[MANUAL]${e}[0m"
            Write-Host "  ${e}[38;2;148;163;184m    -> Seguranca do Windows > Protecao virus > desativar${e}[0m"
        } else {
            Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
        }
    }
}

Write-Host ""
Read-Host "  Pressione ENTER para voltar"
