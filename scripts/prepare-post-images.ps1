param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$MarkdownPath
)

$ErrorActionPreference = "Stop"

function Test-IsSkippedImagePath {
  param([string]$PathText)

  if ([string]::IsNullOrWhiteSpace($PathText)) {
    return $true
  }

  $normalized = $PathText.Trim()
  if ($normalized -match '^(?i)(https?:)?//' -or $normalized -match '^(?i)(data|mailto):' -or $normalized.StartsWith('#')) {
    return $true
  }

  $slashPath = $normalized -replace '\\', '/'
  if ($slashPath -match '^(?i)/?images/') {
    return $true
  }

  if ($slashPath -match '^(?i)img-\d{3}\.[a-z0-9]+$') {
    return $true
  }

  return $false
}

function Split-MarkdownImageTarget {
  param([string]$Target)

  $trimmed = $Target.Trim()
  $path = $trimmed
  $suffix = ""

  if ($trimmed.StartsWith('<') -and $trimmed.Contains('>')) {
    $end = $trimmed.IndexOf('>')
    $path = $trimmed.Substring(1, $end - 1)
    $suffix = $trimmed.Substring($end + 1)
  } elseif ($trimmed -match '^(?<path>\S+)(?<suffix>\s+["''][^"'']*["'']\s*)$') {
    $path = $Matches.path
    $suffix = $Matches.suffix
  }

  return [pscustomobject]@{
    Path = $path.Trim()
    Suffix = $suffix
  }
}

function Get-NextImageName {
  param(
    [string]$Directory,
    [string]$Extension
  )

  $max = 0
  Get-ChildItem -LiteralPath $Directory -File -Filter "img-*.*" | ForEach-Object {
    if ($_.BaseName -match '^img-(\d{3})$') {
      $number = [int]$Matches[1]
      if ($number -gt $max) {
        $max = $number
      }
    }
  }

  do {
    $max += 1
    $name = "img-{0:D3}{1}" -f $max, $Extension.ToLowerInvariant()
    $target = Join-Path $Directory $name
  } while (Test-Path -LiteralPath $target)

  return $name
}

$resolvedMarkdown = Resolve-Path -LiteralPath $MarkdownPath
$markdownFile = Get-Item -LiteralPath $resolvedMarkdown
$articleDir = $markdownFile.Directory.FullName
$content = Get-Content -LiteralPath $markdownFile.FullName -Raw
$sourceToTarget = @{}
$copied = New-Object System.Collections.Generic.List[string]
$skippedMissing = New-Object System.Collections.Generic.List[string]

$imagePattern = '!\[(?<alt>[^\]]*)\]\((?<target>[^)\r\n]+)\)'
$updated = [regex]::Replace($content, $imagePattern, {
  param($match)

  $alt = $match.Groups['alt'].Value
  $target = Split-MarkdownImageTarget $match.Groups['target'].Value
  $pathText = $target.Path

  if (Test-IsSkippedImagePath $pathText) {
    return $match.Value
  }

  if ([System.IO.Path]::IsPathRooted($pathText)) {
    $sourcePath = $pathText
  } else {
    $sourcePath = Join-Path $articleDir $pathText
  }

  if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
    $skippedMissing.Add($pathText) | Out-Null
    return $match.Value
  }

  $sourceItem = Get-Item -LiteralPath $sourcePath
  $extension = $sourceItem.Extension
  if ($extension -notmatch '^(?i)\.(png|jpe?g|gif|webp|svg|bmp|avif)$') {
    return $match.Value
  }

  $sourceKey = $sourceItem.FullName.ToLowerInvariant()
  if ($sourceToTarget.ContainsKey($sourceKey)) {
    $targetName = $sourceToTarget[$sourceKey]
  } else {
    $targetName = Get-NextImageName -Directory $articleDir -Extension $extension
    $destination = Join-Path $articleDir $targetName
    Copy-Item -LiteralPath $sourceItem.FullName -Destination $destination
    $sourceToTarget[$sourceKey] = $targetName
    $copied.Add($targetName) | Out-Null
  }

  return "![{0}]({1}{2})" -f $alt, $targetName, $target.Suffix
})

if ($updated -ne $content) {
  Set-Content -LiteralPath $markdownFile.FullName -Value $updated -NoNewline -Encoding UTF8
}

Write-Host "Processed: $($markdownFile.FullName)"
Write-Host "Copied images: $($copied.Count)"
if ($copied.Count -gt 0) {
  $copied | ForEach-Object { Write-Host "  $_" }
}
if ($skippedMissing.Count -gt 0) {
  Write-Warning "Skipped missing local images:"
  $skippedMissing | Sort-Object -Unique | ForEach-Object { Write-Warning "  $_" }
}
