param(
  [int]$LargeImageMB = 2,
  [switch]$SkipBuild
)

$ErrorActionPreference = "Stop"
$repoRoot = (Get-Location).Path
$issueCount = 0

function Add-Issue {
  param(
    [string]$Type,
    [string]$Message
  )

  $script:issueCount += 1
  Write-Warning "[$Type] $Message"
}

function Get-RelativePathText {
  param([string]$Path)
  return [System.IO.Path]::GetRelativePath($repoRoot, $Path)
}

function Split-MarkdownImageTarget {
  param([string]$Target)

  $trimmed = $Target.Trim()
  $path = $trimmed
  if ($trimmed.StartsWith('<') -and $trimmed.Contains('>')) {
    $end = $trimmed.IndexOf('>')
    $path = $trimmed.Substring(1, $end - 1)
  } elseif ($trimmed -match '^(?<path>\S+)(?<suffix>\s+["''][^"'']*["'']\s*)$') {
    $path = $Matches.path
  }

  return $path.Trim()
}

function Test-IsExternalOrAnchor {
  param([string]$PathText)
  return $PathText -match '^(?i)(https?:)?//' -or $PathText -match '^(?i)(data|mailto):' -or $PathText.StartsWith('#')
}

function Resolve-MarkdownImagePath {
  param(
    [System.IO.FileInfo]$MarkdownFile,
    [string]$ImagePath
  )

  if ([System.IO.Path]::IsPathRooted($ImagePath)) {
    return $ImagePath
  }

  $slashPath = $ImagePath -replace '\\', '/'
  if ($slashPath -match '^(?i)/?images/') {
    return Join-Path (Join-Path $repoRoot "static") $slashPath.TrimStart('/')
  }

  return Join-Path $MarkdownFile.Directory.FullName $ImagePath
}

Write-Host "Checking blog source..."

if (-not $SkipBuild) {
  $buildDir = Join-Path $env:TEMP "myblog-check-build"
  if (Test-Path -LiteralPath $buildDir) {
    Remove-Item -LiteralPath $buildDir -Recurse -Force
  }

  Write-Host "Running Hugo build..."
  hugo -t theme2 --cleanDestinationDir --printPathWarnings -d $buildDir
}

$markdownFiles = Get-ChildItem -LiteralPath (Join-Path $repoRoot "content") -Recurse -File -Filter "*.md"

foreach ($file in $markdownFiles) {
  $relative = Get-RelativePathText $file.FullName
  $content = Get-Content -LiteralPath $file.FullName -Raw

  if ($content -match '(?m)^draft:\s*$') {
    Add-Issue "draft" "$relative has empty draft value. Use draft: true or draft: false."
  }

  if ($content -match '/myblog/' -or $content -match 'github\.io') {
    Add-Issue "hardcoded-url" "$relative contains /myblog/ or github.io. Prefer relative paths."
  }

  $matches = [regex]::Matches($content, '!\[(?<alt>[^\]]*)\]\((?<target>[^)\r\n]+)\)')
  foreach ($match in $matches) {
    $imagePath = Split-MarkdownImageTarget $match.Groups['target'].Value
    if ([string]::IsNullOrWhiteSpace($imagePath) -or (Test-IsExternalOrAnchor $imagePath)) {
      continue
    }

    $resolvedImage = Resolve-MarkdownImagePath -MarkdownFile $file -ImagePath $imagePath
    if (-not (Test-Path -LiteralPath $resolvedImage -PathType Leaf)) {
      Add-Issue "missing-image" "$relative references missing image: $imagePath"
    }
  }
}

$imageExtensions = @("*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.bmp", "*.avif")
$largeImageBytes = $LargeImageMB * 1MB
$imageRoots = @(
  Join-Path $repoRoot "content",
  Join-Path $repoRoot "static"
)

foreach ($root in $imageRoots) {
  foreach ($extension in $imageExtensions) {
    Get-ChildItem -LiteralPath $root -Recurse -File -Filter $extension -ErrorAction SilentlyContinue | Where-Object {
      $_.Length -gt $largeImageBytes
    } | ForEach-Object {
      $size = "{0:N1}MB" -f ($_.Length / 1MB)
      Add-Issue "large-image" "$(Get-RelativePathText $_.FullName) is $size. Consider compressing it."
    }
  }
}

if ($issueCount -gt 0) {
  Write-Host "Check finished with $issueCount issue(s)."
  exit 1
}

Write-Host "Check passed. No issues found."
