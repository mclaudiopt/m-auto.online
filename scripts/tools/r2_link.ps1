# r2_link.ps1 - Generate presigned R2 link for a single file
# Usage: r2_link.ps1 "Z:\Daimler\SDMEDIA.zip"
# Called by Explorer right-click context menu

param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$FilePath
)

$RCLONE  = "C:\Users\marce\AppData\Local\Microsoft\WinGet\Packages\Rclone.Rclone_Microsoft.Winget.Source_8wekyb3d8bbwe\rclone-v1.73.4-windows-amd64\rclone.exe"
$BUCKET  = "r2-mauto:m-auto-software"
$EXPIRES = "2h"
$APP_ID  = "M-Auto.R2Link"

# Mapping local roots → R2 prefix
$ROOT_MAP = @{
    "Z:\Daimler"  = "Daimler"
    "Z:\Autodata" = "Autodata"
    "Z:\Delphi"   = "Delphi"
    "Z:\GM"       = "GM"
    "Z:\PSA"      = "PSA"
    "Z:\Renault"  = "Renault"
    "Z:\Tools"    = "Tools"
    "Z:\VW"       = "VW"
    "Z:\hermes"   = "hermes"
}

#-- Toast notification (Windows 10/11 native, no module needed) --------------
function Show-Toast {
    param(
        [string]$Title,
        [string]$Message,
        [string]$Sound = "ms-winsoundevent:Notification.Default"
    )
    try {
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType=WindowsRuntime] | Out-Null
        [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom, ContentType=WindowsRuntime] | Out-Null

        $xml = @"
<toast>
    <visual>
        <binding template="ToastGeneric">
            <text>$([System.Security.SecurityElement]::Escape($Title))</text>
            <text>$([System.Security.SecurityElement]::Escape($Message))</text>
        </binding>
    </visual>
    <audio src="$Sound"/>
</toast>
"@
        $doc = New-Object Windows.Data.Xml.Dom.XmlDocument
        $doc.LoadXml($xml)
        $toast = [Windows.UI.Notifications.ToastNotification]::new($doc)
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier($APP_ID).Show($toast)
    } catch {
        # Fallback para MessageBox se toast falhar (PowerShell <5 ou erro)
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show($Message, $Title) | Out-Null
    }
}

#-- Validacoes ---------------------------------------------------------------
if (-not (Test-Path $RCLONE)) {
    Show-Toast -Title "R2 Link - Erro" -Message "rclone nao encontrado." -Sound "ms-winsoundevent:Notification.Looping.Alarm"
    exit 1
}

if (-not (Test-Path $FilePath -PathType Leaf)) {
    Show-Toast -Title "R2 Link - Erro" -Message "Ficheiro nao encontrado: $FilePath" -Sound "ms-winsoundevent:Notification.Looping.Alarm"
    exit 1
}

# Resolver root + caminho relativo
$matchedRoot = $null
$r2Prefix    = $null
foreach ($k in $ROOT_MAP.Keys) {
    if ($FilePath -like "$k\*") {
        $matchedRoot = $k
        $r2Prefix    = $ROOT_MAP[$k]
        break
    }
}

if (-not $matchedRoot) {
    Show-Toast -Title "R2 Link - Erro" -Message "Ficheiro fora das pastas mapeadas (Z:\Daimler, Z:\PSA, etc.)" -Sound "ms-winsoundevent:Notification.Looping.Alarm"
    exit 1
}

$relPath = $FilePath.Substring($matchedRoot.Length).TrimStart('\').Replace('\', '/')
$r2Path  = "$BUCKET/$r2Prefix/$relPath"

#-- Gerar link ---------------------------------------------------------------
$url = & $RCLONE link $r2Path --expire $EXPIRES 2>&1
if ($LASTEXITCODE -ne 0) {
    Show-Toast -Title "R2 Link - Falhou" -Message "rclone erro: $url"
    exit 1
}

$url = "$url".Trim()

# Copiar para clipboard
Set-Clipboard -Value $url

# Toast de sucesso
$fileName = Split-Path $FilePath -Leaf
Show-Toast -Title "R2 Link copiado ($EXPIRES)" -Message "$fileName`nClipboard: $($url.Substring(0, [Math]::Min(60, $url.Length)))..."
