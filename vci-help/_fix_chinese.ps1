param([string]$file, [string]$lang)
$content = Get-Content $file -Raw -Encoding UTF8

# Clean up Chinese id attributes
$content = [regex]::Replace($content, ' id=[^]*[\u4e00-\u9fff]+[^]*', ' id=section')

# Replace Chinese in em tags
if ($lang -eq 'pt') {
  $content = [regex]::Replace($content, '<em>([^<]*[\u4e00-\u9fff][^<]*)</em>', '<em>[descricao original]</em>')
} else {
  $content = [regex]::Replace($content, '<em>([^<]*[\u4e00-\u9fff][^<]*)</em>', '<em>[original description]</em>')
}

Set-Content $file $content -Encoding UTF8
