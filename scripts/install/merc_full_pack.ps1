# install/merc_full_pack.ps1 - Mercedes Full Pack 2026
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 | Out-Null
$e = [char]27

#-- Helpers ------------------------------------------------------------------
function Write-Step($msg) { Write-Host "  ${e}[38;2;100;149;237m[..]${e}[0m  $msg" }
function Write-OK($msg)   { Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m  $msg" }
function Write-Err($msg)  { Write-Host "  ${e}[38;2;239;68;68m[X]${e}[0m   $msg" }
function Write-Warn($msg) { Write-Host "  ${e}[38;2;250;204;21m[!]${e}[0m   $msg" }

function Find-7Zip {
    $paths = @(
        "C:\Program Files\7-Zip\7z.exe",
        "C:\Program Files (x86)\7-Zip\7z.exe"
    )
    foreach ($p in $paths) {
        if (Test-Path $p) { return $p }
    }
    $found = Get-Command "7z.exe" -ErrorAction SilentlyContinue
    if ($found) { return $found.Source }
    return $null
}

function Resolve-Desktop {
    $candidates = [System.Collections.Generic.List[string]]::new()

    # 1. Utilizador com sessao activa (mesmo quando elevado como Admin)
    try {
        $loggedUser = (Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue).UserName
        if ($loggedUser -match '\\') {
            $uname = $loggedUser.Split('\')[-1]
            $uProfile = "C:\Users\$uname"
            $candidates.Add("$uProfile\OneDrive\Desktop")
            $candidates.Add("$uProfile\Desktop")
        }
    } catch {}

    # 2. Registo HKCU do processo actual (pode ser Admin, mas vale tentar)
    try {
        $reg = (Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" `
            -Name "Desktop" -ErrorAction Stop).Desktop
        $reg = [Environment]::ExpandEnvironmentVariables($reg)
        $candidates.Add($reg)
    } catch {}

    # 3. Todos os perfis em C:\Users (varredura)
    Get-ChildItem "C:\Users" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $candidates.Add("$($_.FullName)\OneDrive\Desktop")
        $candidates.Add("$($_.FullName)\Desktop")
    }

    foreach ($path in $candidates) {
        if ($path -and (Test-Path $path)) { return $path }
    }
    return $null
}

#-- Header -------------------------------------------------------------------
Write-Host ""
Write-Host "  ${e}[1;97mMercedes Full Pack 2026${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host "  ${e}[38;2;148;163;184m  Xentry + WIS + EPC + Vediamo${e}[0m"
Write-Host ""

#-- Menu loop ----------------------------------------------------------------
while ($true) {
    Write-Host "  ${e}[38;2;148;163;184m  -- EWA --${e}[0m"
    Write-Host "  ${e}[38;2;100;149;237m[A]${e}[0m  Extrair + Instalar EWA + Mover ficheiros"
    Write-Host "  ${e}[38;2;100;149;237m[B]${e}[0m  Mover atalhos para pasta Coding (Desktop)"
    Write-Host "  ${e}[38;2;100;149;237m[C]${e}[0m  Instalar Java (silent)"
    Write-Host ""
    Write-Host "  ${e}[38;2;148;163;184m  -- StarFinder --${e}[0m"
    Write-Host "  ${e}[38;2;100;149;237m[D]${e}[0m  Extrair StarFinder 2024"
    Write-Host ""
    Write-Host "  ${e}[38;2;80;100;140m[0]${e}[0m  Voltar"
    Write-Host ""
    Write-Host -NoNewline "  ${e}[38;2;29;155;255m>${e}[0m  Opcao: "
    $opcao = ($Host.UI.ReadLine()).Trim().ToUpper()
    Write-Host ""

    switch ($opcao) {

        "A" {
            #-- PASSO 1: Extrair ewa.7z ──────────────────────────────────
            $source  = "C:\M-auto\Temp\ewa.7z"
            $extract = "C:\M-auto\Temp\ewa"
            $pass    = "Fiesta77"
            $setup   = "C:\M-auto\Temp\ewa\EWA\EWA\SETUP.EXE"
            $srcDir  = "C:\M-auto\Temp\ewa\EWA\Files\ewa"
            $destDir = "C:\Program Files (x86)\ewa"

            Write-Host "  ${e}[38;2;100;149;237m-- Passo 1: Extrair EWA${e}[0m"
            Write-Host ""

            if (-not (Test-Path $source)) {
                Write-Err "Ficheiro nao encontrado: $source"
                Write-Host ""
                break
            }

            $szExe = Find-7Zip
            if (-not $szExe) {
                Write-Err "7-Zip nao encontrado. Instale primeiro via Start Engine."
                Write-Host ""
                break
            }

            if (-not (Test-Path $extract)) {
                New-Item -ItemType Directory -Path $extract -Force | Out-Null
            }

            Write-Step "A extrair $source ..."
            Write-Host "  ${e}[38;2;50;60;80m  ------------------------------------------------------${e}[0m"
            Write-Host ""

            & $szExe x $source -o"$extract" -p"$pass" -bsp1 -y

            Write-Host ""
            Write-Host "  ${e}[38;2;50;60;80m  ------------------------------------------------------${e}[0m"

            if ($LASTEXITCODE -ne 0) {
                Write-Err "Erro na extracao (codigo $LASTEXITCODE). Verifique a password ou o ficheiro."
                Write-Host ""
                break
            }

            Write-OK "Extracao concluida."
            try {
                Remove-Item $source -Force -ErrorAction Stop
                Write-OK "Ficheiro .7z apagado."
            } catch {
                Write-Warn "Nao foi possivel apagar o .7z: $_"
            }

            Write-Host ""

            #-- PASSO 2: Instalar EWA (SETUP.EXE) ────────────────────────
            Write-Host "  ${e}[38;2;100;149;237m-- Passo 2: Instalar EWA${e}[0m"
            Write-Host ""

            if (-not (Test-Path $setup)) {
                Write-Err "Ficheiro nao encontrado: $setup"
                Write-Host ""
                break
            }

            Write-Step "A lancar: $setup"
            Write-Host ""
            try {
                Start-Process -FilePath $setup -Wait -ErrorAction Stop
                Write-OK "Instalador fechado."
            } catch {
                Write-Err "Erro ao lancar o instalador: $_"
                Write-Host ""
                break
            }

            Write-Host ""
            Write-Host -NoNewline "  ${e}[38;2;29;155;255m>${e}[0m  Prima ENTER para mover os ficheiros EWA..."
            $null = $Host.UI.ReadLine()
            Write-Host ""

            #-- PASSO 3: Mover Files\ewa para Program Files (x86) ────────
            Write-Host "  ${e}[38;2;100;149;237m-- Passo 3: Mover ficheiros EWA${e}[0m"
            Write-Host ""

            if (-not (Test-Path $srcDir)) {
                Write-Err "Pasta nao encontrada: $srcDir"
                Write-Host ""
                break
            }

            Write-Step "De:   $srcDir"
            Write-Step "Para: $destDir"
            Write-Host ""

            robocopy $srcDir $destDir /E /MOVE /IS /IT /NP /NFL /NDL /NJH /NJS /NC /NS | Out-Null
            $rcExit = $LASTEXITCODE

            Write-Host ""
            if ($rcExit -le 7) {
                Write-OK "Ficheiros movidos para: $destDir"

                #-- PASSO 4: Apagar pasta temporaria completa ─────────────
                Write-Host ""
                Write-Host "  ${e}[38;2;100;149;237m-- Passo 4: Limpeza${e}[0m"
                Write-Host ""
                Write-Step "A apagar C:\M-auto\Temp\ewa ..."
                try {
                    Remove-Item "C:\M-auto\Temp\ewa" -Recurse -Force -ErrorAction Stop
                    Write-OK "Pasta temporaria apagada."
                } catch {
                    Write-Warn "Nao foi possivel apagar a pasta: $_"
                }
            } else {
                Write-Err "Robocopy terminou com erro (codigo $rcExit)."
            }

            Write-Host ""
        }

        "B" {
            #-- Mover atalhos para pasta Coding no Desktop ───────────────
            $desktop = Resolve-Desktop

            if (-not $desktop) {
                Write-Err "Nao foi possivel localizar o ambiente de trabalho."
                Write-Warn "Paths tentadas: HKCU Shell Folders | $env:USERPROFILE\OneDrive\Desktop | $env:USERPROFILE\Desktop"
                Write-Host ""
                break
            }

            $coding = Join-Path $desktop "Coding"

            Write-Step "Desktop: $desktop"
            Write-Step "Destino: $coding"
            Write-Host ""

            if (-not (Test-Path $coding)) {
                New-Item -ItemType Directory -Path $coding -Force | Out-Null
                Write-OK "Pasta Coding criada."
            }

            $allLinks = Get-ChildItem -Path $desktop -Filter "*.lnk" -ErrorAction SilentlyContinue
            Write-Step "$($allLinks.Count) atalho(s) encontrado(s) no Desktop."
            if ($allLinks.Count -gt 0) {
                $allLinks | ForEach-Object { Write-Host "    ${e}[38;2;80;100;140m- $($_.Name)${e}[0m" }
            }
            Write-Host ""

            $targets = @(
                "*Vediamo*Start*Center*",
                "*Vediamo*",
                "*DTS*Venice*",
                "*DTS*Monaco*",
                "*OTX*Studio*",
                "*XENTRY*Special*Functions*",
                "*DAS*FDOK*",
                "*Keygens*"
            )

            $moved   = @()
            $missed  = @()
            $matched = @()

            foreach ($pattern in $targets) {
                $hits = $allLinks | Where-Object { $_.Name -like $pattern -and $_.FullName -notin $matched }
                if ($hits) {
                    foreach ($lnk in $hits) {
                        $matched += $lnk.FullName
                        $destLnk = Join-Path $coding $lnk.Name
                        try {
                            Move-Item -Path $lnk.FullName -Destination $destLnk -Force -ErrorAction Stop
                            Write-OK "Movido: $($lnk.Name)"
                            $moved += $lnk.Name
                        } catch {
                            Write-Err "Erro ao mover: $($lnk.Name) — $_"
                        }
                    }
                } else {
                    $missed += ($pattern -replace '\*','').Trim()
                }
            }

            Write-Host ""
            if ($moved.Count -gt 0) {
                Write-OK "$($moved.Count) atalho(s) movido(s) para Coding."
            }
            if ($missed.Count -gt 0) {
                Write-Warn "Nao encontrados: $($missed -join ' | ')"
            }
            Write-Host ""
        }

        "C" {
            #-- Instalar Java em silent ───────────────────────────────────
            $jre = "C:\Program Files (x86)\EWA\clientapps\jre\JRE.EXE"

            if (-not (Test-Path $jre)) {
                Write-Err "Ficheiro nao encontrado: $jre"
                Write-Warn "Verifica se o EWA foi instalado (opcao A)."
                Write-Host ""
                break
            }

            Write-Step "A instalar Java (silent)..."
            Write-Step "$jre"
            Write-Host ""

            try {
                $proc = Start-Process -FilePath $jre -ArgumentList "/s" -Wait -PassThru -ErrorAction Stop
                Write-Host ""
                if ($proc.ExitCode -eq 0) {
                    Write-OK "Java instalado com sucesso."
                } else {
                    Write-Warn "Instalador terminou com codigo $($proc.ExitCode)."
                    Write-Warn "Verifica se o Java foi instalado corretamente."
                }
            } catch {
                Write-Err "Erro ao lancar o instalador: $_"
            }

            Write-Host ""
        }

        "D" {
            #-- Extrair StarFinder 2024 ──────────────────────────────────
            $source = "C:\M-auto\Temp\Startfifinder 2024.7z"
            $dest   = "C:\M-auto"

            if (-not (Test-Path $source)) {
                Write-Err "Ficheiro nao encontrado: $source"
                Write-Host ""
                break
            }

            $szExe = Find-7Zip
            if (-not $szExe) {
                Write-Err "7-Zip nao encontrado. Instale primeiro via Start Engine."
                Write-Host ""
                break
            }

            if (-not (Test-Path $dest)) {
                New-Item -ItemType Directory -Path $dest -Force | Out-Null
            }

            Write-Step "A extrair StarFinder 2024..."
            Write-Step "Para: $dest"
            Write-Host "  ${e}[38;2;50;60;80m  ------------------------------------------------------${e}[0m"
            Write-Host ""

            & $szExe x $source -o"$dest" -bsp1 -y

            Write-Host ""
            Write-Host "  ${e}[38;2;50;60;80m  ------------------------------------------------------${e}[0m"

            if ($LASTEXITCODE -eq 0) {
                Write-OK "StarFinder 2024 extraido para: $dest"
                try {
                    Remove-Item $source -Force -ErrorAction Stop
                    Write-OK "Ficheiro .7z apagado."
                } catch {
                    Write-Warn "Nao foi possivel apagar o .7z: $_"
                }
            } else {
                Write-Err "Erro na extracao (codigo $LASTEXITCODE)."
            }

            Write-Host ""
        }

        "0" { return }

        default {
            Write-Warn "Opcao invalida."
            Write-Host ""
        }
    }
}
