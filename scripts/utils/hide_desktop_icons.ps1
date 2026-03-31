# utils/hide_desktop_icons.ps1 - Ocultar ícones do Desktop
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27

Write-Host ""
Write-Host "  ${e}[1;97mOcultar Ícones do Desktop${e}[0m"
Write-Host "  ${e}[38;2;50;60;80m------------------------------------------------------${e}[0m"
Write-Host ""
Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  Qual?" -NoNewline
Write-Host ""
Write-Host "  [1] This PC"
Write-Host "  [2] Recycle Bin"
Write-Host "  [3] Todos"

$choice = Read-Host "  Escolha"

try {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel"

    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }

    switch ($choice) {
        "1" {
            Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A ocultar This PC..." -NoNewline
            # This PC = CLSID: {20D04FE0-3AEA-1069-A2D8-08002B30309D}
            Set-ItemProperty -Path $regPath -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value 0 -ErrorAction Stop
            Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
        }
        "2" {
            Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A ocultar Recycle Bin..." -NoNewline
            # Recycle Bin = CLSID: {645FF040-5081-101B-9F08-00AA002F954E}
            Set-ItemProperty -Path $regPath -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Value 0 -ErrorAction Stop
            Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
        }
        "3" {
            Write-Host "  ${e}[38;2;100;149;237m·${e}[0m  A ocultar todos..." -NoNewline
            Set-ItemProperty -Path $regPath -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value 0 -ErrorAction Stop
            Set-ItemProperty -Path $regPath -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Value 0 -ErrorAction Stop
            Write-Host "  ${e}[38;2;34;197;94m[OK]${e}[0m"
        }
        default {
            Write-Host "  ${e}[38;2;250;204;21m[CANCELADO]${e}[0m"
        }
    }
} catch {
    Write-Host "  ${e}[38;2;239;68;68m[ERRO]${e}[0m"
    Write-Host "  ${e}[38;2;148;163;184m    $_${e}[0m"
}

Write-Host ""
Read-Host "  Pressione ENTER para voltar"
