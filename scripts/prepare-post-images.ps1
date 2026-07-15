[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$Path,

  [switch]$DeleteOriginalObsidianImages
)

$ErrorActionPreference = "Stop"
$Utf8NoBom = New-Object System.Text.UTF8Encoding($false)

function Read-Utf8Text {
  param([string]$FilePath)
  return [System.IO.File]::ReadAllText($FilePath, [System.Text.Encoding]::UTF8)
}

function Write-Utf8Text {
  param(
    [string]$FilePath,
    [string]$Text
  )
  [System.IO.File]::WriteAllText($FilePath, $Text, $script:Utf8NoBom)
}

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

  if ($slashPath -match '^(?i)(\.\./)?img-\d{3}\.[a-z0-9]+$') {
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

function Split-ObsidianImageTarget {
  param([string]$Target)

  $parts = $Target.Trim() -split '\|', 2
  $path = $parts[0].Trim()
  $alt = ""

  if ($parts.Count -gt 1) {
    $candidateAlt = $parts[1].Trim()
    if ($candidateAlt -notmatch '^\d+(x\d+)?$') {
      $alt = $candidateAlt
    }
  }

  return [pscustomobject]@{
    Path = $path
    Alt = $alt
  }
}

function Test-IsObsidianPastedImageName {
  param([string]$FileName)

  return $FileName -match '^(?i)Pasted image \d{14}\.(png|jpe?g|gif|webp|svg|bmp|avif)$'
}

function Get-FileSha256 {
  param([string]$FilePath)

  return (Get-FileHash -LiteralPath $FilePath -Algorithm SHA256).Hash
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

function Resolve-LocalImageSource {
  param(
    [string]$ArticleDirectory,
    [string]$PathText
  )

  if ([System.IO.Path]::IsPathRooted($PathText)) {
    return $PathText
  }

  $current = Get-Item -LiteralPath $ArticleDirectory
  while ($current) {
    $candidate = Join-Path $current.FullName $PathText
    if (Test-Path -LiteralPath $candidate -PathType Leaf) {
      return $candidate
    }

    $current = $current.Parent
  }

  return (Join-Path $ArticleDirectory $PathText)
}

function Get-MarkdownFiles {
  param([string]$InputPath)

  $resolved = Resolve-Path -LiteralPath $InputPath
  $item = Get-Item -LiteralPath $resolved

  if ($item.PSIsContainer) {
    $bundleIndex = Join-Path $item.FullName "index.md"
    if (Test-Path -LiteralPath $bundleIndex -PathType Leaf) {
      return @(Get-Item -LiteralPath $bundleIndex)
    }

    return @(Get-ChildItem -LiteralPath $item.FullName -File -Filter "*.md" | Sort-Object FullName)
  }

  if ($item.Extension -ine ".md") {
    throw "Input file must be a Markdown file: $($item.FullName)"
  }

  return @($item)
}

function Invoke-PrepareMarkdownImages {
  param([System.IO.FileInfo]$MarkdownFile)

  $articleDir = $MarkdownFile.Directory.FullName
  $content = Read-Utf8Text -FilePath $MarkdownFile.FullName
  $usesBundleRelativeImages = $MarkdownFile.BaseName -ieq "index" -or $MarkdownFile.BaseName -ieq "_index"
  $sourceToTarget = @{}
  $copied = New-Object System.Collections.Generic.List[string]
  $skippedMissing = New-Object System.Collections.Generic.List[string]
  $deleteCandidates = New-Object System.Collections.Generic.List[object]
  $deletedOriginals = New-Object System.Collections.Generic.List[string]
  $skippedDeletes = New-Object System.Collections.Generic.List[string]
  $imagePattern = '!\[(?<alt>[^\]]*)\]\((?<target>[^)\r\n]+)\)'
  $obsidianImagePattern = '!\[\[(?<target>[^\]\r\n]+)\]\]'

  function Add-OrphanObsidianDeleteCandidates {
    $articleImagesByHash = @{}
    Get-ChildItem -LiteralPath $articleDir -File -Filter "img-*.*" | ForEach-Object {
      if ($_.Extension -match '^(?i)\.(png|jpe?g|gif|webp|svg|bmp|avif)$') {
        $hash = Get-FileSha256 -FilePath $_.FullName
        if (-not $articleImagesByHash.ContainsKey($hash)) {
          $articleImagesByHash[$hash] = $_.FullName
        }
      }
    }

    if ($articleImagesByHash.Count -eq 0) {
      return
    }

    $current = Get-Item -LiteralPath $articleDir
    while ($current) {
      Get-ChildItem -LiteralPath $current.FullName -File -Filter "Pasted image *.*" | ForEach-Object {
        if (-not (Test-IsObsidianPastedImageName $_.Name)) {
          return
        }

        $source = $_.FullName
        $hash = Get-FileSha256 -FilePath $source
        if (-not $articleImagesByHash.ContainsKey($hash)) {
          return
        }

        $target = $articleImagesByHash[$hash]
        if ([System.IO.Path]::GetFullPath($source) -eq [System.IO.Path]::GetFullPath($target)) {
          return
        }

        $deleteCandidates.Add([pscustomobject]@{
          Source = $source
          Target = $target
        }) | Out-Null
      }

      $current = $current.Parent
    }
  }

  function Convert-LocalImageReference {
    param(
      [string]$PathText,
      [string]$Alt,
      [string]$Suffix,
      [string]$OriginalText,
      [bool]$IsObsidianReference = $false
    )

    $imagePath = $PathText.Trim()

    if (Test-IsSkippedImagePath $imagePath) {
      return $OriginalText
    }

    $sourcePath = Resolve-LocalImageSource -ArticleDirectory $articleDir -PathText $imagePath

    if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
      $skippedMissing.Add($imagePath) | Out-Null
      return $OriginalText
    }

    $sourceItem = Get-Item -LiteralPath $sourcePath
    $extension = $sourceItem.Extension
    if ($extension -notmatch '^(?i)\.(png|jpe?g|gif|webp|svg|bmp|avif)$') {
      return $OriginalText
    }

    $sourceKey = $sourceItem.FullName.ToLowerInvariant()
    if ($sourceToTarget.ContainsKey($sourceKey)) {
      $targetName = $sourceToTarget[$sourceKey]
    } else {
      $targetName = Get-NextImageName -Directory $articleDir -Extension $extension
      $destination = Join-Path $articleDir $targetName
      if (-not $WhatIfPreference) {
        Copy-Item -LiteralPath $sourceItem.FullName -Destination $destination
      }
      $sourceToTarget[$sourceKey] = $targetName
      $copied.Add($targetName) | Out-Null
    }

    if ($script:DeleteOriginalObsidianImages -and $IsObsidianReference -and (Test-IsObsidianPastedImageName $sourceItem.Name)) {
      $destinationPath = Join-Path $articleDir $targetName
      $deleteCandidates.Add([pscustomobject]@{
        Source = $sourceItem.FullName
        Target = $destinationPath
      }) | Out-Null
    }

    $targetReference = $targetName
    if (-not $usesBundleRelativeImages) {
      $targetReference = "../$targetName"
    }

    return "![{0}]({1}{2})" -f $Alt, $targetReference, $Suffix
  }

  $updated = [regex]::Replace($content, $imagePattern, {
    param($match)

    $target = Split-MarkdownImageTarget $match.Groups['target'].Value
    Convert-LocalImageReference `
      -PathText $target.Path `
      -Alt $match.Groups['alt'].Value `
      -Suffix $target.Suffix `
      -OriginalText $match.Value `
      -IsObsidianReference $false
  })

  $updated = [regex]::Replace($updated, $obsidianImagePattern, {
    param($match)

    $target = Split-ObsidianImageTarget $match.Groups['target'].Value
    Convert-LocalImageReference `
      -PathText $target.Path `
      -Alt $target.Alt `
      -Suffix "" `
      -OriginalText $match.Value `
      -IsObsidianReference $true
  })

  if ($updated -ne $content -and -not $WhatIfPreference) {
    Write-Utf8Text -FilePath $MarkdownFile.FullName -Text $updated
  }

  if ($DeleteOriginalObsidianImages) {
    Add-OrphanObsidianDeleteCandidates
  }

  if ($DeleteOriginalObsidianImages -and $deleteCandidates.Count -gt 0) {
    $deleteCandidates |
      Group-Object Source |
      ForEach-Object {
        $candidate = $_.Group[0]
        $source = $candidate.Source
        $target = $candidate.Target

        if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
          $skippedDeletes.Add("$source (source missing)") | Out-Null
          return
        }

        if (-not $WhatIfPreference -and -not (Test-Path -LiteralPath $target -PathType Leaf)) {
          $skippedDeletes.Add("$source (copied target missing)") | Out-Null
          return
        }

        if ([System.IO.Path]::GetFullPath($source) -eq [System.IO.Path]::GetFullPath($target)) {
          $skippedDeletes.Add("$source (source is target)") | Out-Null
          return
        }

        if ($PSCmdlet.ShouldProcess($source, "Delete original Obsidian pasted image")) {
          Remove-Item -LiteralPath $source -Force
          $deletedOriginals.Add($source) | Out-Null
        }
      }
  }

  [pscustomobject]@{
    File = $MarkdownFile.FullName
    Copied = @($copied)
    Missing = @($skippedMissing | Sort-Object -Unique)
    Deleted = @($deletedOriginals)
    DeleteSkipped = @($skippedDeletes)
  }
}

$markdownFiles = Get-MarkdownFiles -InputPath $Path
if ($markdownFiles.Count -eq 0) {
  Write-Warning "No Markdown files found."
  return
}

$totalCopied = 0
$totalDeleted = 0
foreach ($markdownFile in $markdownFiles) {
  $result = Invoke-PrepareMarkdownImages -MarkdownFile $markdownFile
  $totalCopied += $result.Copied.Count
  $totalDeleted += $result.Deleted.Count

  Write-Host "Processed: $($result.File)"
  if ($WhatIfPreference) {
    Write-Host "Images to copy: $($result.Copied.Count)"
  } else {
    Write-Host "Copied images: $($result.Copied.Count)"
  }
  if ($result.Copied.Count -gt 0) {
    $result.Copied | ForEach-Object { Write-Host "  $_" }
  }
  if ($result.Missing.Count -gt 0) {
    Write-Warning "Skipped missing local images:"
    $result.Missing | ForEach-Object { Write-Warning "  $_" }
  }
  if ($DeleteOriginalObsidianImages) {
    if ($WhatIfPreference) {
      Write-Host "Obsidian originals to delete: see WhatIf messages above"
    } else {
      Write-Host "Deleted Obsidian originals: $($result.Deleted.Count)"
    }
    if ($result.Deleted.Count -gt 0) {
      $result.Deleted | ForEach-Object { Write-Host "  $_" }
    }
    if ($result.DeleteSkipped.Count -gt 0) {
      Write-Warning "Skipped deleting Obsidian originals:"
      $result.DeleteSkipped | ForEach-Object { Write-Warning "  $_" }
    }
  }
}

if ($WhatIfPreference) {
  Write-Host "Done. Markdown files: $($markdownFiles.Count), images to copy: $totalCopied. No files were changed because -WhatIf was used."
} else {
  Write-Host "Done. Markdown files: $($markdownFiles.Count), copied images: $totalCopied, deleted Obsidian originals: $totalDeleted"
}
