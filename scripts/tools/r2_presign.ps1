# r2_presign.ps1 - Generate AWS S3 / Cloudflare R2 presigned URLs
# Pure PowerShell SigV4 implementation - NO rclone, NO AWS SDK
# Dot-source this file:  . "$PSScriptRoot\r2_presign.ps1"
# Requires:               .r2_credentials.ps1 in same folder

# Carregar credenciais (ficheiro local, em .gitignore)
$credPath = Join-Path $PSScriptRoot ".r2_credentials.ps1"
if (-not (Test-Path $credPath)) {
    throw "Credenciais R2 nao encontradas: $credPath"
}
. $credPath

#-- HMAC-SHA256 helper -------------------------------------------------------
function Get-HmacSha256 {
    param([byte[]]$Key, [string]$Data)
    $hmac = New-Object System.Security.Cryptography.HMACSHA256
    $hmac.Key = $Key
    $result = $hmac.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Data))
    $hmac.Dispose()
    return $result
}

#-- SHA256 hex ---------------------------------------------------------------
function Get-Sha256Hex {
    param([string]$Data)
    $sha = [System.Security.Cryptography.SHA256]::Create()
    $hash = $sha.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($Data))
    $sha.Dispose()
    return -join ($hash | ForEach-Object { $_.ToString("x2") })
}

#-- Bytes to hex -------------------------------------------------------------
function ConvertTo-HexString {
    param([byte[]]$Bytes)
    return -join ($Bytes | ForEach-Object { $_.ToString("x2") })
}

#-- URI escape S3 style (preserva /) -----------------------------------------
function Get-S3UriEscape {
    param([string]$Path)
    $segments = $Path -split '/'
    $escaped  = $segments | ForEach-Object { [System.Uri]::EscapeDataString($_) }
    return $escaped -join '/'
}

#-- Get-S3PresignedUrl -------------------------------------------------------
function Get-S3PresignedUrl {
    param(
        [Parameter(Mandatory)] [string]$Key,            # caminho dentro do bucket (ex: "Daimler/foo.iso")
        [int]$ExpiresSeconds = 7200,                    # default: 2h
        [string]$Bucket    = $R2_CONFIG.Bucket,
        [string]$AccountId = $R2_CONFIG.AccountId,
        [string]$AccessKey = $R2_CONFIG.AccessKey,
        [string]$SecretKey = $R2_CONFIG.SecretKey,
        [string]$Region    = $R2_CONFIG.Region
    )

    $now       = [DateTime]::UtcNow
    $dateStamp = $now.ToString("yyyyMMdd")
    $amzDate   = $now.ToString("yyyyMMddTHHmmssZ")
    $service   = "s3"
    $hostName  = "$AccountId.r2.cloudflarestorage.com"
    $endpoint  = "https://$hostName"

    $credentialScope = "$dateStamp/$Region/$service/aws4_request"
    $credential      = "$AccessKey/$credentialScope"
    $encodedKey      = Get-S3UriEscape $Key
    $canonicalUri    = "/$Bucket/$encodedKey"

    # Query params (ordem alfabetica obrigatoria)
    $params = [System.Collections.Generic.SortedDictionary[string,string]]::new()
    $params["X-Amz-Algorithm"]     = "AWS4-HMAC-SHA256"
    $params["X-Amz-Credential"]    = $credential
    $params["X-Amz-Date"]          = $amzDate
    $params["X-Amz-Expires"]       = $ExpiresSeconds
    $params["X-Amz-SignedHeaders"] = "host"

    $canonicalQuery = ($params.GetEnumerator() | ForEach-Object {
        "$([System.Uri]::EscapeDataString($_.Key))=$([System.Uri]::EscapeDataString($_.Value))"
    }) -join '&'

    $canonicalHeaders = "host:$hostName`n"
    $signedHeaders    = "host"
    $payloadHash      = "UNSIGNED-PAYLOAD"

    $canonicalRequest = @(
        "GET",
        $canonicalUri,
        $canonicalQuery,
        $canonicalHeaders,
        $signedHeaders,
        $payloadHash
    ) -join "`n"

    $stringToSign = @(
        "AWS4-HMAC-SHA256",
        $amzDate,
        $credentialScope,
        (Get-Sha256Hex $canonicalRequest)
    ) -join "`n"

    # Derivacao da signing key (4 passos HMAC encadeados)
    $kDate    = Get-HmacSha256 ([System.Text.Encoding]::UTF8.GetBytes("AWS4$SecretKey")) $dateStamp
    $kRegion  = Get-HmacSha256 $kDate    $Region
    $kService = Get-HmacSha256 $kRegion  $service
    $kSigning = Get-HmacSha256 $kService "aws4_request"

    $signature = ConvertTo-HexString (Get-HmacSha256 $kSigning $stringToSign)

    return "$endpoint$canonicalUri`?$canonicalQuery&X-Amz-Signature=$signature"
}

#-- List objects in bucket prefix (S3 ListObjectsV2) -------------------------
function Get-S3Objects {
    param(
        [string]$Prefix    = "",
        [int]$MaxKeys      = 1000,
        [string]$Bucket    = $R2_CONFIG.Bucket,
        [string]$AccountId = $R2_CONFIG.AccountId,
        [string]$AccessKey = $R2_CONFIG.AccessKey,
        [string]$SecretKey = $R2_CONFIG.SecretKey,
        [string]$Region    = $R2_CONFIG.Region
    )

    $now       = [DateTime]::UtcNow
    $dateStamp = $now.ToString("yyyyMMdd")
    $amzDate   = $now.ToString("yyyyMMddTHHmmssZ")
    $service   = "s3"
    $hostName  = "$AccountId.r2.cloudflarestorage.com"
    $endpoint  = "https://$hostName"

    $credentialScope = "$dateStamp/$Region/$service/aws4_request"
    $credential      = "$AccessKey/$credentialScope"
    $canonicalUri    = "/$Bucket"

    $allItems = @()
    $continuationToken = $null

    do {
        $params = [System.Collections.Generic.SortedDictionary[string,string]]::new()
        $params["list-type"]  = "2"
        $params["max-keys"]   = $MaxKeys
        if ($Prefix) { $params["prefix"] = $Prefix }
        if ($continuationToken) { $params["continuation-token"] = $continuationToken }

        $canonicalQuery = ($params.GetEnumerator() | ForEach-Object {
            "$([System.Uri]::EscapeDataString($_.Key))=$([System.Uri]::EscapeDataString($_.Value))"
        }) -join '&'

        $payloadHashEmpty = Get-Sha256Hex ""
        $canonicalHeaders = "host:$hostName`nx-amz-content-sha256:$payloadHashEmpty`nx-amz-date:$amzDate`n"
        $signedHeaders    = "host;x-amz-content-sha256;x-amz-date"

        $canonicalRequest = @(
            "GET", $canonicalUri, $canonicalQuery,
            $canonicalHeaders, $signedHeaders, $payloadHashEmpty
        ) -join "`n"

        $stringToSign = @(
            "AWS4-HMAC-SHA256", $amzDate, $credentialScope,
            (Get-Sha256Hex $canonicalRequest)
        ) -join "`n"

        $kDate    = Get-HmacSha256 ([System.Text.Encoding]::UTF8.GetBytes("AWS4$SecretKey")) $dateStamp
        $kRegion  = Get-HmacSha256 $kDate    $Region
        $kService = Get-HmacSha256 $kRegion  $service
        $kSigning = Get-HmacSha256 $kService "aws4_request"
        $signature = ConvertTo-HexString (Get-HmacSha256 $kSigning $stringToSign)

        $authHeader = "AWS4-HMAC-SHA256 Credential=$credential, SignedHeaders=$signedHeaders, Signature=$signature"

        $url = "$endpoint$canonicalUri`?$canonicalQuery"
        $headers = @{
            "Host"                 = $hostName
            "x-amz-date"           = $amzDate
            "x-amz-content-sha256" = $payloadHashEmpty
            "Authorization"        = $authHeader
        }

        $resp = Invoke-RestMethod -Uri $url -Method GET -Headers $headers
        $allItems += $resp.ListBucketResult.Contents | Where-Object { $_ }

        $continuationToken = if ($resp.ListBucketResult.IsTruncated -eq "true") {
            $resp.ListBucketResult.NextContinuationToken
        } else { $null }
    } while ($continuationToken)

    return $allItems | ForEach-Object {
        [PSCustomObject]@{
            Key          = $_.Key
            Size         = [long]$_.Size
            LastModified = [datetime]$_.LastModified
        }
    }
}
