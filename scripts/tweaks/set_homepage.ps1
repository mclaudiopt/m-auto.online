# tweaks/set_homepage.ps1 - Configure Default Home Page
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27

Write-Host ""
Write-Host "  ${e}[1;97mConfigurar Home Page${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

$homePage = "https://www.m-auto.online/"

Write-Host "  ${e}[38;2;148;163;184m·${e}[0m  Home page: ${e}[38;2;100;149;237m$homePage${e}[0m"
Write-Host ""

try {
    # Configurar Edge
    Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A configurar Microsoft Edge..." -NoNewline
    $edgePath = "HKCU:\Software\Microsoft\Edge"
    if (-not (Test-Path $edgePath)) {
        New-Item -Path $edgePath -Force | Out-Null
    }
    Set-ItemProperty -Path $edgePath -Name "HomepageURL" -Value $homePage -ErrorAction Stop
    Set-ItemProperty -Path $edgePath -Name "HomepageIsNewTabPage" -Value 0 -ErrorAction Stop
    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"

    # Configurar Chrome se estiver instalado
    Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A configurar Google Chrome..." -NoNewline
    $chromePath = "HKCU:\Software\Google\Chrome\RestoreOnStartup"
    $chromeSettingsPath = "HKCU:\Software\Google\Chrome\RestoreOnStartupURLs"

    if (Test-Path "C:\Program Files\Google\Chrome\Application\chrome.exe") {
        if (-not (Test-Path $chromePath)) {
            New-Item -Path $chromePath -Force | Out-Null
        }
        if (-not (Test-Path $chromeSettingsPath)) {
            New-Item -Path $chromeSettingsPath -Force | Out-Null
        }

        Set-ItemProperty -Path $chromePath -Name "RestoreOnStartup" -Value 4 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $chromeSettingsPath -Name "1" -Value $homePage -ErrorAction SilentlyContinue
        Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
    } else {
        Write-Host "  ${e}[38;2;250;204;21m[N/A]${e}[0m"
    }

    # Configurar Firefox se estiver instalado
    Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A configurar Mozilla Firefox..." -NoNewline
    $firefoxPath = "HKCU:\Software\Mozilla\Firefox\Main"

    if (Test-Path "C:\Program Files\Mozilla Firefox\firefox.exe") {
        if (-not (Test-Path $firefoxPath)) {
            New-Item -Path $firefoxPath -Force | Out-Null
        }

        Set-ItemProperty -Path $firefoxPath -Name "StartPage" -Value 3 -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $firefoxPath -Name "homepage" -Value $homePage -ErrorAction SilentlyContinue
        Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
    } else {
        Write-Host "  ${e}[38;2;250;204;21m[N/A]${e}[0m"
    }

    Write-Host ""
    Write-Host "  ${e}[38;2;34;197;94m✔${e}[0m  Home page configurada com sucesso."
    Write-Host "  ${e}[38;2;148;163;184m  Feche e reabra os navegadores para aplicar.${e}[0m"

} catch {
    Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
    Write-Host "  ${e}[38;2;239;68;68m✖${e}[0m  Erro na configuracao: $($_.Exception.Message)"
}

Write-Host ""
Read-Host "  Pressione ENTER para voltar"
