# Shared Functions for m-auto.online Download Scripts
# Used by: merc_download.ps1, merc_download_v3.ps1, renault_download.ps1, renault_download_v2.ps1, psa_download_v2.ps1
# Provides: Logging, Notifications, SHA256, Cache, Retry Logic, Progress Notifications

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
$e = [char]27

#-- LOGGING -------------------------------------------------------------------
function Write-Log {
    param(
        [string]$message,
        [string]$level = "INFO",
        [string]$logDir = "C:\M-auto\Logs"
    )

    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logFile = Join-Path $logDir "download_$(Get-Date -Format 'yyyyMMdd').log"

    "$timestamp [$level] $message" | Out-File -FilePath $logFile -Append -Encoding UTF8
}

#-- WINDOWS TOAST NOTIFICATIONS -----------------------------------------------
function Show-Notification {
    param(
        [string]$title,
        [string]$message,
        [bool]$sound = $true
    )

    try {
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] | Out-Null
        [Windows.Data.Xml.Dom.XmlDocument, Windows.Data.Xml.Dom.XmlDocument, ContentType = WindowsRuntime] | Out-Null

        $template = @"
<toast>
    <visual>
        <binding template="ToastGeneric">
            <text>$title</text>
            <text>$message</text>
        </binding>
    </visual>
    $(if ($sound) { '<audio src="ms-winsoundevent:Notification.Default"/>' } else { '<audio silent="true"/>' })
</toast>
"@

        $xml = New-Object Windows.Data.Xml.Dom.XmlDocument
        $xml.LoadXml($template)
        $toast = [Windows.UI.Notifications.ToastNotification]::new($xml)
        $notifier = [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier("M-Auto Downloader")
        $notifier.Show($toast)
    } catch {
        Write-Log "Notification failed: $_" "WARN"
    }
}

#-- FILE SIZE FORMATTING------------------------------------------------------
function Format-FileSize {
    param([int64]$bytes)

    if ($bytes -ge 1GB) { return "{0:N2} GB" -f ($bytes / 1GB) }
    elseif ($bytes -ge 1MB) { return "{0:N1} MB" -f ($bytes / 1MB) }
    elseif ($bytes -ge 1KB) { return "{0:N0} KB" -f ($bytes / 1KB) }
    else { return "$bytes B" }
}

#-- TIME FORMATTING (ETA) -----------------------------------------------------
function Format-ETA {
    param([int]$seconds)

    if ($seconds -lt 0) { return "--:--" }
    if ($seconds -ge 3600) {
        $h = [int]($seconds / 3600)
        $m = [int](($seconds % 3600) / 60)
        return "${h}h ${m}m"
    } elseif ($seconds -ge 60) {
        $m = [int]($seconds / 60)
        $s = [int]($seconds % 60)
        return "${m}m ${s}s"
    } else {
        return "${seconds}s"
    }
}

#-- SHA256 HASHING ------------------------------------------------------------
function Get-FileSHA256 {
    param([string]$filePath)

    try {
        $hash = Get-FileHash -Path $filePath -Algorithm SHA256 -ErrorAction Stop
        return $hash.Hash.ToLower()
    } catch {
        Write-Log "SHA256 calculation failed for $filePath : $_" "ERROR"
        return $null
    }
}

#-- FILE INTEGRITY CHECK------------------------------------------------------
function Test-FileIntegrity {
    param(
        [string]$filePath,
        [int64]$expectedSize
    )

    if (-not (Test-Path $filePath)) {
        Write-Log "File not found: $filePath" "WARN"
        return $false
    }

    $fileSize = (Get-Item $filePath).Length

    # Check size if expected
    if ($expectedSize -gt 0 -and $fileSize -ne $expectedSize) {
        Write-Log "Size mismatch: $filePath ($fileSize vs $expectedSize)" "WARN"
        return $false
    }

    return $true
}

#-- DOWNLOAD MANIFEST (SHA256 REGISTRY) ----------------------------------------
function Get-DownloadManifest {
    param([string]$logDir = "C:\M-auto\Logs")

    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }

    $manifestPath = Join-Path $logDir "download_manifest.json"

    if (Test-Path $manifestPath) {
        try {
            $manifest = Get-Content $manifestPath -Encoding UTF8 | ConvertFrom-Json
            return $manifest
        } catch {
            Write-Log "Failed to read manifest: $_" "WARN"
        }
    }

    return @{ downloads = @() }
}

function Update-DownloadManifest {
    param(
        [string]$filename,
        [int64]$size,
        [string]$sha256,
        [string]$status = "success",
        [string]$logDir = "C:\M-auto\Logs"
    )

    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }

    $manifestPath = Join-Path $logDir "download_manifest.json"
    $manifest = Get-DownloadManifest -logDir $logDir

    $entry = @{
        filename = $filename
        size = $size
        sha256 = $sha256
        timestamp = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
        status = $status
    }

    # Check if file already exists in manifest
    $existing = $manifest.downloads | Where-Object { $_.filename -eq $filename }
    if ($existing) {
        $manifest.downloads = $manifest.downloads | Where-Object { $_.filename -ne $filename }
    }

    $manifest.downloads += $entry

    try {
        $manifest | ConvertTo-Json -Depth 3 | Out-File -FilePath $manifestPath -Encoding UTF8 -Force
        Write-Log "Manifest updated: $filename ($sha256)" "INFO"
    } catch {
        Write-Log "Failed to update manifest: $_" "ERROR"
    }
}

#-- METADATA CACHE (24H AUTO-REFRESH) ------------------------------------------
function Get-CacheFile {
    param([string]$cacheDir = $null)

    if ([string]::IsNullOrWhiteSpace($cacheDir)) {
        $cacheDir = Join-Path $env:APPDATA "M-Auto"
    }

    if (-not (Test-Path $cacheDir)) {
        New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null
    }

    $cachePath = Join-Path $cacheDir "cache.json"

    if (Test-Path $cachePath) {
        try {
            $cache = Get-Content $cachePath -Encoding UTF8 | ConvertFrom-Json

            # Check if cache is still valid (< 24 hours)
            $cachedAt = [datetime]::Parse($cache.cached_at)
            $age = (Get-Date) - $cachedAt

            if ($age.TotalHours -lt 24) {
                return $cache
            }
        } catch {
            Write-Log "Failed to read cache: $_" "WARN"
        }
    }

    return @{
        cached_at = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
        files = @()
    }
}

function Update-CacheFile {
    param(
        [array]$files,
        [datetime]$linksExpires = $null,
        [string]$cacheDir = $null
    )

    if ([string]::IsNullOrWhiteSpace($cacheDir)) {
        $cacheDir = Join-Path $env:APPDATA "M-Auto"
    }

    if (-not (Test-Path $cacheDir)) {
        New-Item -ItemType Directory -Path $cacheDir -Force | Out-Null
    }

    $cachePath = Join-Path $cacheDir "cache.json"

    $cache = @{
        cached_at = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssZ")
        files = $files
    }

    if ($linksExpires) {
        $cache["links_expires"] = $linksExpires.ToString("yyyy-MM-ddTHH:mm:ssZ")
    }

    try {
        $cache | ConvertTo-Json -Depth 3 | Out-File -FilePath $cachePath -Encoding UTF8 -Force
        Write-Log "Cache updated with $($files.Count) files" "INFO"
    } catch {
        Write-Log "Failed to update cache: $_" "ERROR"
    }
}

#-- SMART RETRY WITH EXPONENTIAL BACKOFF --------------------------------------
function Invoke-SmartRetry {
    param(
        [scriptblock]$scriptBlock,
        [int]$maxRetries = 3,
        [array]$backoffSeconds = @(2, 5, 10)
    )

    for ($attempt = 1; $attempt -le $maxRetries; $attempt++) {
        try {
            return & $scriptBlock
        } catch {
            if ($attempt -eq $maxRetries) {
                throw $_
            }

            $delay = $backoffSeconds[$attempt - 1]
            Write-Log "Retry $attempt/$maxRetries (waiting ${delay}s) - Error: $_" "WARN"
            Start-Sleep -Seconds $delay
        }
    }
}

#-- PROGRESS NOTIFICATIONS (25%, 50%, 75%, 100%) -----------------------------------------------
function Show-ProgressNotification {
    param(
        [int]$percent,
        [string]$downloadName,
        [int]$etaSeconds = 0,
        [array]$firedThresholds = @()
    )

    $thresholds = @(25, 50, 75, 100)

    foreach ($threshold in $thresholds) {
        if ($percent -ge $threshold -and $threshold -notin $firedThresholds) {
            $message = "$downloadName [$percent%]"
            if ($etaSeconds -gt 0 -and $percent -lt 100) {
                $message += " - $(Format-ETA $etaSeconds) remaining"
            }

            Show-Notification "M-Auto Download" $message $false
            $firedThresholds += $threshold
            Write-Log "Progress notification: $message" "INFO"
        }
    }

    return $firedThresholds
}

#-- EXPORT FUNCTIONS (explicit exports for scripts) ---------------------------
Export-ModuleMember -Function @(
    'Write-Log',
    'Show-Notification',
    'Format-FileSize',
    'Format-ETA',
    'Get-FileSHA256',
    'Test-FileIntegrity',
    'Get-DownloadManifest',
    'Update-DownloadManifest',
    'Get-CacheFile',
    'Update-CacheFile',
    'Invoke-SmartRetry',
    'Show-ProgressNotification'
) -ErrorAction SilentlyContinue
