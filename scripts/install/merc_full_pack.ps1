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
            $desktop = [Environment]::GetFolderPath("Desktop")
            $coding  = Join-Path $desktop "Coding"

            # Padroes de nome dos atalhos a mover (sem extensao, com wildcards)
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

            Write-Step "Desktop: $desktop"
            Write-Step "Destino: $coding"
            Write-Host ""

            # Criar pasta Coding se nao existir
            if (-not (Test-Path $coding)) {
                New-Item -ItemType Directory -Path $coding -Force | Out-Null
                Write-OK "Pasta Coding criada."
            }

            # Encontrar todos os .lnk no Desktop
            $allLinks = Get-ChildItem -Path $desktop -Filter "*.lnk" -ErrorAction SilentlyContinue

            $moved  = @()
            $missed = @()

            foreach ($pattern in $targets) {
                $matches = $allLinks | Where-Object { $_.Name -like $pattern }
                if ($matches) {
                    foreach ($lnk in $matches) {
                        $dest = Join-Path $coding $lnk.Name
                        try {
                            Move-Item -Path $lnk.FullName -Destination $dest -Force -ErrorAction Stop
                            Write-OK "Movido: $($lnk.Name)"
                            $moved += $lnk.Name
                        } catch {
                            Write-Err "Erro ao mover: $($lnk.Name) — $_"
                        }
                    }
                } else {
                    # Guarda o padrao limpo para o relatorio
                    $missed += ($pattern -replace '\*','').Trim()
                }
            }

            Write-Host ""
            if ($moved.Count -gt 0) {
                Write-OK "$($moved.Count) atalho(s) movido(s) para Coding."
            }
            if ($missed.Count -gt 0) {
                Write-Warn "Nao encontrados no Desktop: $($missed -join ', ')"
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
