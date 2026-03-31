# bump-version.ps1 - Incrementa versao e timestamp antes de push

$scriptPath = "scripts/m-auto.ps1"

# Ler conteudo
$content = Get-Content $scriptPath -Raw

# Extrair versao atual
if ($content -match '\$VERSION\s*=\s*"([^"]+)"') {
    $currentVersion = $matches[1]
    Write-Host "Versao atual: $currentVersion"
} else {
    $currentVersion = "1.0"
    Write-Host "Primeira versao: $currentVersion"
}

# Incrementar versao
$parts = $currentVersion.Split('.')
$major = [int]$parts[0]
$minor = [int]$parts[1]
$newMinor = $minor + 1
$newVersion = "$major.$newMinor"

# Timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Nova versao com timestamp
$newVersionString = "$newVersion [$timestamp]"

Write-Host "Nova versao: $newVersionString"

# Atualizar ficheiro
$content = $content -replace '\$VERSION\s*=\s*"[^"]*"', "`$VERSION  = `"$newVersionString`""

Set-Content $scriptPath $content -Encoding UTF8

# Commit
git add $scriptPath
git commit -m "version: bump to $newVersion [$timestamp]"

Write-Host "`n✓ Versao atualizada. Pronto para 'git push'" -ForegroundColor Green
