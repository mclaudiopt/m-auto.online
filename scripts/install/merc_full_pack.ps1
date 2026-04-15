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
    # fallback: search PATH
    $found = Get-Command "7z.exe" -ErrorAction SilentlyContinue
    if ($found) { return $found.Source }
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
    Write-Host "  ${e}[38;2;100;149;237m[A]${e}[0m  Extrair EWA (ewa.7z)"
    Write-Host "  ${e}[38;2;100;149;237m[B]${e}[0m  Mover atalhos para pasta Coding (Desktop)"
    Write-Host "  ${e}[38;2;100;149;237m[C]${e}[0m  Instalar EWA (SETUP.EXE)"
    Write-Host ""
    Write-Host "  ${e}[38;2;80;100;140m[0]${e}[0m  Voltar"
    Write-Host ""
    Write-Host -NoNewline "  ${e}[38;2;29;155;255m>${e}[0m  Opcao: "
    $opcao = ($Host.UI.ReadLine()).Trim().ToUpper()
    Write-Host ""

    switch ($opcao) {

        "A" {
            #-- Extrair ewa.7z ───────────────────────────────────────────
            $source = "C:\M-auto\Temp\ewa.7z"
            $dest   = "C:\M-auto\Temp\ewa"
            $pass   = "Fiesta77"

            # Verificar se o ficheiro existe
            if (-not (Test-Path $source)) {
                Write-Err "Ficheiro nao encontrado: $source"
                Write-Host ""
                break
            }

            # Verificar se 7-Zip esta instalado
            $szExe = Find-7Zip
            if (-not $szExe) {
                Write-Err "7-Zip nao encontrado. Instale primeiro via Start Engine."
                Write-Host ""
                break
            }

            # Criar pasta destino
            if (-not (Test-Path $dest)) {
                New-Item -ItemType Directory -Path $dest -Force | Out-Null
            }

            Write-Step "A extrair $source para $dest ..."
            Write-Host "  ${e}[38;2;50;60;80m  ------------------------------------------------------${e}[0m"
            Write-Host ""

            # Extrair com progresso visivel (-bsp1 = progress para stdout)
            & $szExe x $source -o"$dest" -p"$pass" -bsp1 -y

            Write-Host ""
            Write-Host "  ${e}[38;2;50;60;80m  ------------------------------------------------------${e}[0m"

            if ($LASTEXITCODE -eq 0) {
                Write-OK "Extracao concluida: $dest"

                # Apagar o .7z original
                Write-Step "A apagar $source ..."
                try {
                    Remove-Item $source -Force -ErrorAction Stop
                    Write-OK "Ficheiro .7z apagado."
                } catch {
                    Write-Warn "Nao foi possivel apagar o .7z: $_"
                }
            } else {
                Write-Err "Erro na extracao (codigo $LASTEXITCODE). Verifique a password ou o ficheiro."
            }

            Write-Host ""
        }

        "B" {
            #-- Mover atalhos para pasta Coding no Desktop ───────────────

            # Resolver path real do Desktop: registo > OneDrive > fallback
            $desktop = $null

            # 1. Registo HKCU (fonte de verdade, funciona com redirecionamento)
            try {
                $regDesktop = (Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders" `
                    -Name "Desktop" -ErrorAction Stop).Desktop
                # Expandir variaveis de ambiente (ex: %USERPROFILE%)
                $regDesktop = [Environment]::ExpandEnvironmentVariables($regDesktop)
                if (Test-Path $regDesktop) { $desktop = $regDesktop }
            } catch {}

            # 2. OneDrive Desktop (comum quando OneDrive redireciona)
            if (-not $desktop) {
                $odDesktop = "$env:USERPROFILE\OneDrive\Desktop"
                if (Test-Path $odDesktop) { $desktop = $odDesktop }
            }

            # 3. Fallback classico
            if (-not $desktop) {
                $fbDesktop = "$env:USERPROFILE\Desktop"
                if (Test-Path $fbDesktop) { $desktop = $fbDesktop }
            }

            if (-not $desktop) {
                Write-Err "Nao foi possivel localizar o ambiente de trabalho."
                Write-Warn "Paths tentadas:"
                Write-Host "    HKCU Shell Folders, $env:USERPROFILE\OneDrive\Desktop, $env:USERPROFILE\Desktop"
                Write-Host ""
                break
            }

            $coding = Join-Path $desktop "Coding"

            Write-Step "Desktop encontrado: $desktop"
            Write-Step "Destino:            $coding"
            Write-Host ""

            # Criar pasta Coding se nao existir
            if (-not (Test-Path $coding)) {
                New-Item -ItemType Directory -Path $coding -Force | Out-Null
                Write-OK "Pasta Coding criada."
            }

            # Listar todos os .lnk encontrados (ajuda a diagnosticar)
            $allLinks = Get-ChildItem -Path $desktop -Filter "*.lnk" -ErrorAction SilentlyContinue
            Write-Step "$($allLinks.Count) atalho(s) encontrado(s) no Desktop."
            Write-Host ""

            # Padroes de nome dos atalhos a mover
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
            $matched = @()  # evitar mover o mesmo ficheiro duas vezes

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
            #-- Correr EWA SETUP.EXE + mover Files\ewa ──────────────────
            $setup   = "C:\M-auto\Temp\ewa\EWA\EWA\SETUP.EXE"
            $srcDir  = "C:\M-auto\Temp\ewa\EWA\Files\ewa"
            $destDir = "C:\Program Files (x86)\ewa"

            if (-not (Test-Path $setup)) {
                Write-Err "Ficheiro nao encontrado: $setup"
                Write-Warn "Corre primeiro a opcao A para extrair o EWA."
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

            if (-not (Test-Path $srcDir)) {
                Write-Err "Pasta nao encontrada: $srcDir"
                Write-Host ""
                break
            }

            Write-Step "A mover: $srcDir"
            Write-Step "Para:    $destDir"
            Write-Host ""

            # robocopy: /E=subdirs, /MOVE=apaga origem apos copiar,
            #           /IS=sobrepoe ficheiros iguais, /IT=sobrepoe tweaked,
            #           /NP=sem % por ficheiro (mais limpo), /NFL=sem lista ficheiros
            #           exit codes 0-7 sao sucesso em robocopy
            $rc = robocopy $srcDir $destDir /E /MOVE /IS /IT /NP /NDL
            $exitCode = $LASTEXITCODE

            Write-Host ""
            if ($exitCode -le 7) {
                Write-OK "Ficheiros movidos para: $destDir"

                # Limpar pasta de origem vazia
                if (Test-Path $srcDir) {
                    Remove-Item $srcDir -Recurse -Force -ErrorAction SilentlyContinue
                }
            } else {
                Write-Err "Robocopy terminou com erro (codigo $exitCode)."
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
