# r2_manager.ps1 - Local GUI to monitor & renew presigned R2 links
# - Lista todos os *_links.json no repo
# - Countdown live por cada um (cores: verde/amarelo/vermelho)
# - Botao "Renovar" por categoria + "Renovar tudo"
# - Aciona scripts renew_*.ps1 que fazem commit+push automaticamente

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

#-- Config -------------------------------------------------------------------
$REPO_DIR    = "D:\Tutorials\m-auto.online"
$TOOLS_DIR   = "$REPO_DIR\scripts\tools"

# Categorias: nome do JSON (sem _links.json) -> script de renovacao
$CATEGORIES = @{
    "merc"    = "renew_merc_links.ps1"
    "psa"     = "renew_psa_links.ps1"
    "renault" = "renew_renault_links.ps1"
}

#-- Helper: parse JSON e devolve estado --------------------------------------
function Get-LinkState {
    param([string]$JsonPath)

    $state = @{
        Files     = 0
        Expires   = $null
        Remaining = $null
        Status    = "missing"
        Color     = [System.Drawing.Color]::Gray
    }

    if (-not (Test-Path $JsonPath)) {
        $state.Status = "Sem JSON"
        return $state
    }

    try {
        $json = Get-Content $JsonPath -Raw | ConvertFrom-Json
        $state.Files = if ($json.files) { $json.files.Count } else { 0 }

        if ($json.expires) {
            $exp = [datetime]::Parse($json.expires,
                [System.Globalization.CultureInfo]::InvariantCulture,
                [System.Globalization.DateTimeStyles]::RoundtripKind)
            $state.Expires = $exp.ToLocalTime()
            $rem = $state.Expires - (Get-Date)
            $state.Remaining = $rem

            if ($rem.TotalSeconds -le 0) {
                $state.Status = "EXPIRADO"
                $state.Color  = [System.Drawing.Color]::FromArgb(150, 150, 150)
            } elseif ($rem.TotalMinutes -le 5) {
                $state.Status = "{0:hh\:mm\:ss}" -f $rem
                $state.Color  = [System.Drawing.Color]::FromArgb(220, 38, 38)   # vermelho
            } elseif ($rem.TotalMinutes -le 30) {
                $state.Status = "{0:hh\:mm\:ss}" -f $rem
                $state.Color  = [System.Drawing.Color]::FromArgb(245, 158, 11)  # amarelo
            } else {
                $state.Status = "{0:hh\:mm\:ss}" -f $rem
                $state.Color  = [System.Drawing.Color]::FromArgb(34, 197, 94)   # verde
            }
        }
    } catch {
        $state.Status = "ERRO: $_"
        $state.Color  = [System.Drawing.Color]::Red
    }

    return $state
}

#-- Form ---------------------------------------------------------------------
$form = New-Object System.Windows.Forms.Form
$form.Text          = "M-Auto R2 Manager"
$form.Size          = New-Object System.Drawing.Size(720, 420)
$form.StartPosition = "CenterScreen"
$form.BackColor     = [System.Drawing.Color]::FromArgb(24, 28, 38)
$form.ForeColor     = [System.Drawing.Color]::White
$form.Font          = New-Object System.Drawing.Font("Segoe UI", 10)

# Header
$header = New-Object System.Windows.Forms.Label
$header.Text      = "M-Auto  ::  R2 Presigned Links Manager"
$header.AutoSize  = $false
$header.Size      = New-Object System.Drawing.Size(700, 36)
$header.Location  = New-Object System.Drawing.Point(10, 8)
$header.Font      = New-Object System.Drawing.Font("Segoe UI Semibold", 14)
$header.ForeColor = [System.Drawing.Color]::FromArgb(100, 149, 237)
$form.Controls.Add($header)

# DataGridView
$grid = New-Object System.Windows.Forms.DataGridView
$grid.Location          = New-Object System.Drawing.Point(10, 50)
$grid.Size              = New-Object System.Drawing.Size(685, 260)
$grid.BackgroundColor   = [System.Drawing.Color]::FromArgb(30, 35, 48)
$grid.ForeColor         = [System.Drawing.Color]::White
$grid.GridColor         = [System.Drawing.Color]::FromArgb(50, 60, 80)
$grid.BorderStyle       = "None"
$grid.RowHeadersVisible = $false
$grid.AllowUserToAddRows = $false
$grid.AllowUserToDeleteRows = $false
$grid.AllowUserToResizeRows = $false
$grid.SelectionMode     = "FullRowSelect"
$grid.MultiSelect       = $false
$grid.ReadOnly          = $true
$grid.RowTemplate.Height = 36
$grid.EnableHeadersVisualStyles = $false
$grid.ColumnHeadersDefaultCellStyle.BackColor = [System.Drawing.Color]::FromArgb(40, 50, 70)
$grid.ColumnHeadersDefaultCellStyle.ForeColor = [System.Drawing.Color]::White
$grid.ColumnHeadersDefaultCellStyle.Font      = New-Object System.Drawing.Font("Segoe UI Semibold", 10)
$grid.ColumnHeadersHeight = 32
$grid.DefaultCellStyle.SelectionBackColor = [System.Drawing.Color]::FromArgb(50, 80, 130)
$grid.DefaultCellStyle.SelectionForeColor = [System.Drawing.Color]::White

[void]$grid.Columns.Add("cat",     "Categoria")
[void]$grid.Columns.Add("files",   "Ficheiros")
[void]$grid.Columns.Add("expires", "Expira as")
[void]$grid.Columns.Add("status",  "Restante")
$grid.Columns["cat"].Width     = 180
$grid.Columns["files"].Width   = 100
$grid.Columns["expires"].Width = 180
$grid.Columns["status"].Width  = 220
$grid.Columns["files"].DefaultCellStyle.Alignment   = "MiddleCenter"
$grid.Columns["expires"].DefaultCellStyle.Alignment = "MiddleCenter"
$grid.Columns["status"].DefaultCellStyle.Alignment  = "MiddleCenter"
$grid.Columns["status"].DefaultCellStyle.Font       = New-Object System.Drawing.Font("Consolas", 11, [System.Drawing.FontStyle]::Bold)
$form.Controls.Add($grid)

# Botoes
$btnRenewSel = New-Object System.Windows.Forms.Button
$btnRenewSel.Text     = "Renovar Selecionado"
$btnRenewSel.Location = New-Object System.Drawing.Point(10, 320)
$btnRenewSel.Size     = New-Object System.Drawing.Size(170, 36)
$btnRenewSel.BackColor = [System.Drawing.Color]::FromArgb(34, 197, 94)
$btnRenewSel.ForeColor = [System.Drawing.Color]::White
$btnRenewSel.FlatStyle = "Flat"
$btnRenewSel.FlatAppearance.BorderSize = 0
$form.Controls.Add($btnRenewSel)

$btnRenewAll = New-Object System.Windows.Forms.Button
$btnRenewAll.Text      = "Renovar TUDO"
$btnRenewAll.Location  = New-Object System.Drawing.Point(190, 320)
$btnRenewAll.Size      = New-Object System.Drawing.Size(140, 36)
$btnRenewAll.BackColor = [System.Drawing.Color]::FromArgb(100, 149, 237)
$btnRenewAll.ForeColor = [System.Drawing.Color]::White
$btnRenewAll.FlatStyle = "Flat"
$btnRenewAll.FlatAppearance.BorderSize = 0
$form.Controls.Add($btnRenewAll)

$btnRefresh = New-Object System.Windows.Forms.Button
$btnRefresh.Text       = "Recarregar"
$btnRefresh.Location   = New-Object System.Drawing.Point(340, 320)
$btnRefresh.Size       = New-Object System.Drawing.Size(110, 36)
$btnRefresh.BackColor  = [System.Drawing.Color]::FromArgb(60, 70, 90)
$btnRefresh.ForeColor  = [System.Drawing.Color]::White
$btnRefresh.FlatStyle  = "Flat"
$btnRefresh.FlatAppearance.BorderSize = 0
$form.Controls.Add($btnRefresh)

$btnClose = New-Object System.Windows.Forms.Button
$btnClose.Text       = "Fechar"
$btnClose.Location   = New-Object System.Drawing.Point(605, 320)
$btnClose.Size       = New-Object System.Drawing.Size(90, 36)
$btnClose.BackColor  = [System.Drawing.Color]::FromArgb(80, 80, 80)
$btnClose.ForeColor  = [System.Drawing.Color]::White
$btnClose.FlatStyle  = "Flat"
$btnClose.FlatAppearance.BorderSize = 0
$form.Controls.Add($btnClose)

# Status bar
$status = New-Object System.Windows.Forms.Label
$status.AutoSize  = $false
$status.Size      = New-Object System.Drawing.Size(700, 22)
$status.Location  = New-Object System.Drawing.Point(10, 365)
$status.ForeColor = [System.Drawing.Color]::FromArgb(148, 163, 184)
$status.Text      = "Pronto."
$form.Controls.Add($status)

#-- Refresh do grid ----------------------------------------------------------
function Update-Grid {
    foreach ($row in $grid.Rows) {
        $catName = $row.Cells["cat"].Value -replace ' .*', ''
        $jsonPath = "$REPO_DIR\${catName}_links.json"
        $st = Get-LinkState -JsonPath $jsonPath

        $row.Cells["files"].Value   = $st.Files
        $row.Cells["expires"].Value = if ($st.Expires) { $st.Expires.ToString("yyyy-MM-dd HH:mm") } else { "-" }
        $row.Cells["status"].Value  = $st.Status
        $row.Cells["status"].Style.ForeColor = $st.Color
    }
}

function Build-Grid {
    $grid.Rows.Clear()
    foreach ($cat in ($CATEGORIES.Keys | Sort-Object)) {
        $script   = $CATEGORIES[$cat]
        $hasScript = Test-Path "$TOOLS_DIR\$script"
        $catLabel = $cat.ToUpper() + $(if (-not $hasScript) { "  (sem script)" })
        [void]$grid.Rows.Add($catLabel, "-", "-", "-")
    }
    Update-Grid
}

#-- Renovar (corre script numa nova janela powershell) -----------------------
function Invoke-Renew {
    param([string]$Category)
    $script = $CATEGORIES[$Category]
    if (-not $script) { return }
    $path = "$TOOLS_DIR\$script"
    if (-not (Test-Path $path)) {
        $status.Text = "[X] Script nao encontrado: $script"
        return
    }
    $status.Text = "A renovar $Category..."
    Start-Process powershell.exe -ArgumentList @(
        "-NoProfile",
        "-ExecutionPolicy", "Bypass",
        "-File", "`"$path`""
    ) -Wait
    Update-Grid
    $status.Text = "Renovacao de $Category concluida."
}

#-- Eventos ------------------------------------------------------------------
$btnRenewSel.Add_Click({
    if ($grid.SelectedRows.Count -eq 0) {
        $status.Text = "Seleciona uma linha primeiro."
        return
    }
    $cat = ($grid.SelectedRows[0].Cells["cat"].Value -replace ' .*', '').ToLower()
    Invoke-Renew -Category $cat
})

$btnRenewAll.Add_Click({
    foreach ($cat in $CATEGORIES.Keys) {
        if (Test-Path "$TOOLS_DIR\$($CATEGORIES[$cat])") {
            Invoke-Renew -Category $cat
        }
    }
    $status.Text = "Todas as categorias renovadas."
})

$btnRefresh.Add_Click({ Build-Grid; $status.Text = "Recarregado." })
$btnClose.Add_Click({ $form.Close() })

# Esc fecha
$form.KeyPreview = $true
$form.Add_KeyDown({ if ($_.KeyCode -eq "Escape") { $form.Close() } })

# Timer 1s para countdown live
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000
$timer.Add_Tick({ Update-Grid })
$timer.Start()

# Build inicial
Build-Grid

#-- Run ----------------------------------------------------------------------
[void]$form.ShowDialog()
$timer.Stop()
$timer.Dispose()
