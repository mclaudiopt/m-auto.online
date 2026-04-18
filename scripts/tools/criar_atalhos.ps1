# tools/criar_atalhos.ps1 - Criar atalhos no Ambiente de Trabalho
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null
$e = [char]27

# Resolve Desktop real (funciona mesmo quando elevado como Admin)
function Resolve-Desktop {
    try {
        $loggedUser = (Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue).UserName
        if ($loggedUser -match '\\') {
            $uProfile = "C:\Users\$($loggedUser.Split('\')[-1])"
            foreach ($p in @("$uProfile\OneDrive\Desktop", "$uProfile\Desktop")) {
                if (Test-Path $p) { return $p }
            }
        }
    } catch {}
    try {
        $reg = [Environment]::ExpandEnvironmentVariables(
            (Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" -Name "Desktop" -ErrorAction Stop).Desktop
        )
        if (Test-Path $reg) { return $reg }
    } catch {}
    Get-ChildItem "C:\Users" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        foreach ($p in @("$($_.FullName)\OneDrive\Desktop", "$($_.FullName)\Desktop")) {
            if (Test-Path $p) { return $p }
        }
    }
    return $null
}

$desktop = Resolve-Desktop
if (-not $desktop) {
    Write-Host "  ${e}[38;2;239;68;68m[X]${e}[0m   Nao foi possivel localizar o ambiente de trabalho."
    Read-Host "  Pressione ENTER para voltar"
    return
}

function New-LnkShortcut {
    param(
        [string]$Name,
        [string]$Target,
        [string]$Icon = $null
    )
    $lnkPath = "$desktop\$Name.lnk"
    $shell = New-Object -ComObject WScript.Shell
    $sc = $shell.CreateShortcut($lnkPath)
    $sc.TargetPath = $Target
    if ($Icon) { $sc.IconLocation = $Icon }
    $sc.Save()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($shell) | Out-Null
    return $lnkPath
}

$atalhos = @(
    @{
        Num   = "1"
        Nome  = "StarFinder WebETM"
        Label = "StarFinder WebETM"
        Alvo  = "C:\M-Auto\Startfifinder 2024\StarFinder_webETM\WebETM-SDmedia.exe"
        Icon  = $null
        Desc  = "Usa icon do executavel"
    },
    @{
        Num   = "2"
        Nome  = "Coding Tutorials"
        Label = "Coding Tutorials"
        Alvo  = "C:\M-Auto\Coding tutorials full"
        Icon  = $null
        Desc  = "Abre pasta no Explorer"
    }
)

while ($true) {
    Clear-Host
    Write-Host ""
    Write-Host "  ${e}[1;97mCriar Atalhos no Ambiente de Trabalho${e}[0m"
    Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
    Write-Host ""

    foreach ($a in $atalhos) {
        $exists = Test-Path $a.Alvo
        $status = if ($exists) { "${e}[38;2;34;197;94m OK${e}[0m " } else { "${e}[38;2;239;68;68mFALTA${e}[0m" }
        Write-Host "  ${e}[38;2;100;149;237m[$($a.Num)]${e}[0m  $($a.Label)"
        Write-Host "       ${e}[38;2;148;163;184m$($a.Alvo)${e}[0m  [$status ]"
        if ($a.Icon) {
            Write-Host "       ${e}[38;2;100;130;100mIcon: $($a.Icon)${e}[0m  ${e}[38;2;100;130;100m| $($a.Desc)${e}[0m"
        } else {
            Write-Host "       ${e}[38;2;100;130;100m$($a.Desc)${e}[0m"
        }
        Write-Host ""
    }

    Write-Host "  ${e}[38;2;100;149;237m[T]${e}[0m  Criar TODOS os atalhos"
    Write-Host "  ${e}[38;2;148;163;184m[0]${e}[0m  Voltar"
    Write-Host ""
    $opt = Read-Host "  Opcao"

    $escolha = $null
    if ($opt -eq "T" -or $opt -eq "t") {
        $escolha = $atalhos
    } elseif ($opt -eq "0") {
        return
    } else {
        $escolha = $atalhos | Where-Object { $_.Num -eq $opt }
        if (-not $escolha) {
            Write-Host "  ${e}[38;2;239;68;68m[!]${e}[0m  Opcao invalida."
            Start-Sleep -Milliseconds 800
            continue
        }
        $escolha = @($escolha)
    }

    Write-Host ""
    foreach ($a in $escolha) {
        Write-Host -NoNewline "  ${e}[38;2;100;149;237m·${e}[0m  $($a.Label) ... "
        if (-not (Test-Path $a.Alvo)) {
            Write-Host "${e}[38;2;239;68;68m[ERRO] Nao encontrado:${e}[0m"
            Write-Host "     ${e}[38;2;148;163;184m$($a.Alvo)${e}[0m"
        } else {
            try {
                New-LnkShortcut -Name $a.Nome -Target $a.Alvo -Icon $a.Icon | Out-Null
                Write-Host "${e}[38;2;34;197;94m[OK]${e}[0m"
            } catch {
                Write-Host "${e}[38;2;239;68;68m[ERRO] $($_.Exception.Message)${e}[0m"
            }
        }
    }

    Write-Host ""
    Read-Host "  Pressione ENTER para continuar"
}
