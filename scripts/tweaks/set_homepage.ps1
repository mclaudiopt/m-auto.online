# tweaks/set_homepage.ps1 - Configure Default Home Page
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27

$homePage = "https://www.m-auto.online/"

Write-Host ""
Write-Host "  ${e}[1;97mConfigurar Home Page${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""
Write-Host "  ${e}[38;2;148;163;184m·${e}[0m  Home page: ${e}[38;2;100;149;237m$homePage${e}[0m"
Write-Host ""

# --- Microsoft Edge ---
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A configurar Microsoft Edge..." -NoNewline
try {
    # Edge usa Group Policy registry (nao HKCU\Software\Microsoft\Edge)
    $edgePolicy = "HKCU:\Software\Policies\Microsoft\Edge"
    if (-not (Test-Path $edgePolicy)) {
        New-Item -Path $edgePolicy -Force | Out-Null
    }
    Set-ItemProperty -Path $edgePolicy -Name "HomepageLocation"      -Value $homePage -ErrorAction Stop
    Set-ItemProperty -Path $edgePolicy -Name "HomepageIsNewTabPage"   -Value 0        -Type DWord -ErrorAction Stop
    Set-ItemProperty -Path $edgePolicy -Name "RestoreOnStartup"       -Value 4        -Type DWord -ErrorAction Stop

    # URL de startup
    $edgeStartup = "$edgePolicy\RestoreOnStartupURLs"
    if (-not (Test-Path $edgeStartup)) {
        New-Item -Path $edgeStartup -Force | Out-Null
    }
    Set-ItemProperty -Path $edgeStartup -Name "1" -Value $homePage -ErrorAction Stop

    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
} catch {
    Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m  $($_.Exception.Message)"
}

# --- Google Chrome ---
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A configurar Google Chrome..." -NoNewline
$chromeExe = @(
    "C:\Program Files\Google\Chrome\Application\chrome.exe",
    "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($chromeExe) {
    try {
        $chromePolicy = "HKCU:\Software\Policies\Google\Chrome"
        if (-not (Test-Path $chromePolicy)) {
            New-Item -Path $chromePolicy -Force | Out-Null
        }
        Set-ItemProperty -Path $chromePolicy -Name "HomepageLocation"    -Value $homePage -ErrorAction Stop
        Set-ItemProperty -Path $chromePolicy -Name "HomepageIsNewTabPage" -Value 0        -Type DWord -ErrorAction Stop
        Set-ItemProperty -Path $chromePolicy -Name "RestoreOnStartup"     -Value 4        -Type DWord -ErrorAction Stop

        $chromeStartup = "$chromePolicy\RestoreOnStartupURLs"
        if (-not (Test-Path $chromeStartup)) {
            New-Item -Path $chromeStartup -Force | Out-Null
        }
        Set-ItemProperty -Path $chromeStartup -Name "1" -Value $homePage -ErrorAction Stop

        Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m  $($_.Exception.Message)"
    }
} else {
    Write-Host "  ${e}[38;2;250;204;21m[N/A]${e}[0m"
}

# --- Mozilla Firefox ---
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A configurar Mozilla Firefox..." -NoNewline
$firefoxExe = @(
    "C:\Program Files\Mozilla Firefox\firefox.exe",
    "C:\Program Files (x86)\Mozilla Firefox\firefox.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if ($firefoxExe) {
    try {
        $ffPolicies = "C:\Program Files\Mozilla Firefox\distribution"
        if (-not (Test-Path $ffPolicies)) {
            New-Item -ItemType Directory -Path $ffPolicies -Force | Out-Null
        }
        $ffPolicy = @{
            policies = @{
                Homepage = @{
                    URL    = $homePage
                    Locked = $false
                    StartPage = "homepage"
                }
            }
        } | ConvertTo-Json -Depth 5
        Set-Content -Path "$ffPolicies\policies.json" -Value $ffPolicy -Encoding UTF8 -Force
        Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m  $($_.Exception.Message)"
    }
} else {
    Write-Host "  ${e}[38;2;250;204;21m[N/A]${e}[0m"
}

Write-Host ""
Write-Host "  ${e}[38;2;34;197;94m✔${e}[0m  Home page configurada. Feche e reabra os navegadores."
Write-Host ""
Read-Host "  Pressione ENTER para voltar"
