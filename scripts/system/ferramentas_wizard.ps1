# system/ferramentas_wizard.ps1 - Wizard de ferramentas adicionais
$e = [char]27

function Ask-YesNo($question) {
    Write-Host ""
    $response = Read-Host "  ${e}[38;2;100;149;237m·${e}[0m  $question [s/n]"
    return $response -match "^[sS]"
}

#-- FERRAMENTAS --------------------------------------------------------------
Write-Host ""
Write-Host "  ${e}[1;97mFerramentas Adicionais${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"

$actions = @()

if (Ask-YesNo "Instalar DeskIn (acesso remoto)?") {
    $actions += @{ name = "DeskIn"; action = "deskin" }
}

if (Ask-YesNo "Instalar Free Download Manager?") {
    $actions += @{ name = "FDM"; action = "fdm" }
}

if (Ask-YesNo "Criar ponto de restauro do sistema?") {
    $actions += @{ name = "Restore Point"; action = "restore" }
}

if (Ask-YesNo "Limpar ficheiros temporarios?") {
    $actions += @{ name = "Cleanup"; action = "cleanup" }
}

if (Ask-YesNo "Aplicar tweaks de otimizacao (Reserved Storage, WinSxS, etc)?") {
    $actions += @{ name = "Tweaks"; action = "tweaks" }
}

Write-Host ""

if ($actions.Count -eq 0) {
    Write-Host "  ${e}[38;2;148;163;184m(nenhuma acao selecionada)${e}[0m"
    Write-Host ""
    Read-Host "  Pressione ENTER para voltar"
    return
}

#-- EXECUTAR -------------------------------------------------------------------
Write-Host "  ${e}[38;2;100;149;237m>> Executando...${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

$completed = @()
$failed = @()

foreach ($action in $actions) {
    Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  $($action.name)..." -NoNewline

    try {
        switch ($action.action) {
            "deskin" {
                # Placeholder - seria irm de script deskin se existisse
                Write-Host "  ${e}[38;2;148;163;184m[MANUAL]${e}[0m"
                Write-Host "  ${e}[38;2;148;163;184m    (Script nao disponivel - contacte suporte)${e}[0m"
            }

            "fdm" {
                # Placeholder
                Write-Host "  ${e}[38;2;148;163;184m[MANUAL]${e}[0m"
                Write-Host "  ${e}[38;2;148;163;184m    (Script nao disponivel - contacte suporte)${e}[0m"
            }

            "restore" {
                $vss = Get-Service VSS -ErrorAction SilentlyContinue
                if ($vss) {
                    Checkpoint-Computer -Description "Backup by M-Auto" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
                    Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
                    $completed += $action.name
                } else {
                    Write-Host "  ${e}[38;2;239;68;68m[FALHOU]${e}[0m"
                    $failed += $action.name
                }
            }

            "cleanup" {
                Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A limpar TEMP..." -NoNewline
                Remove-Item "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
                $completed += $action.name
            }

            "tweaks" {
                Write-Host ""
                Write-Host "  ${e}[38;2;148;163;184mTweaks disponíveis em 'Opcoes Manuais':${e}[0m"
                Write-Host "  ${e}[38;2;148;163;184m· Reserved Storage OFF${e}[0m"
                Write-Host "  ${e}[38;2;148;163;184m· CompactOS${e}[0m"
                Write-Host "  ${e}[38;2;148;163;184m· WinSxS Cleanup${e}[0m"
                Write-Host "  ${e}[38;2;148;163;184m· Hibernacao OFF${e}[0m"
                Write-Host "  ${e}[38;2;148;163;184m· DriverStoreExplorer${e}[0m"
                Write-Host ""
                $completed += "Tweaks (menu manual)"
            }
        }
    } catch {
        Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
        Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
        $failed += $action.name
    }
}

#-- RESUMO -------------------------------------------------------------------
Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m>> Resumo${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""

if ($completed.Count -gt 0) {
    Write-Host "  ${e}[38;2;34;197;94m✓ Concluido:${e}[0m"
    $completed | ForEach-Object { Write-Host "    - $_" }
}

if ($failed.Count -gt 0) {
    Write-Host ""
    Write-Host "  ${e}[38;2;239;68;68m✗ Falhou:${e}[0m"
    $failed | ForEach-Object { Write-Host "    - $_" }
}

Write-Host ""
Read-Host "  Pressione ENTER para voltar"
