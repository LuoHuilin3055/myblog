[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [Parameter(Position = 0)]
  [string[]]$Path = @("content", "static"),

  [int]$MinBytes = 512KB,

  [ValidateRange(1, 100)]
  [int]$JpegQuality = 82,

  [switch]$Apply,

  [switch]$IncludeUntracked,

  [switch]$ReportLarge
)

$ErrorActionPreference = "Stop"

Add-Type -AssemblyName System.Drawing

function Get-RepoRoot {
  $root = git rev-parse --show-toplevel 2>$null
  if (-not $root) {
    throw "This script must be run inside a Git repository."
  }
  return [System.IO.Path]::GetFullPath(($root | Select-Object -First 1).Trim())
}

function Get-TrackedFileSet {
  param([string]$RepoRoot)

  $set = New-Object "System.Collections.Generic.HashSet[string]" ([System.StringComparer]::OrdinalIgnoreCase)
  git -C $RepoRoot -c core.quotepath=false ls-files | ForEach-Object {
    $fullPath = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot ($_ -replace '/', [System.IO.Path]::DirectorySeparatorChar)))
    [void]$set.Add($fullPath)
  }
  return $set
}

function Get-ImageCodec {
  param([string]$MimeType)

  return [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
    Where-Object { $_.MimeType -eq $MimeType } |
    Select-Object -First 1
}

function New-EncoderParameters {
  param([int]$Quality)

  $encoder = [System.Drawing.Imaging.Encoder]::Quality
  $parameters = New-Object System.Drawing.Imaging.EncoderParameters 1
  $parameters.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter $encoder, ([int64]$Quality)
  return $parameters
}

function Save-OptimizedImage {
  param(
    [System.IO.FileInfo]$Source,
    [string]$Destination,
    [int]$Quality
  )

  $extension = $Source.Extension.ToLowerInvariant()
  $image = [System.Drawing.Image]::FromFile($Source.FullName)
  try {
    if ($extension -in @(".jpg", ".jpeg")) {
      $codec = Get-ImageCodec -MimeType "image/jpeg"
      $encoderParameters = New-EncoderParameters -Quality $Quality
      try {
        $image.Save($Destination, $codec, $encoderParameters)
      } finally {
        $encoderParameters.Dispose()
      }
      return
    }

    if ($extension -eq ".png") {
      $image.Save($Destination, [System.Drawing.Imaging.ImageFormat]::Png)
      return
    }

    throw "Unsupported image extension: $extension"
  } finally {
    $image.Dispose()
  }
}

function Get-CandidateImages {
  param(
    [string[]]$InputPaths,
    [int]$MinimumBytes,
    [string]$RepoRoot,
    [System.Collections.Generic.HashSet[string]]$TrackedFiles,
    [bool]$AllowUntracked
  )

  $extensions = @(".jpg", ".jpeg", ".png")
  foreach ($inputPath in $InputPaths) {
    $resolvedPaths = Resolve-Path -LiteralPath $inputPath
    foreach ($resolvedPath in $resolvedPaths) {
      $item = Get-Item -LiteralPath $resolvedPath
      $files = if ($item.PSIsContainer) {
        Get-ChildItem -LiteralPath $item.FullName -Recurse -File
      } else {
        @($item)
      }

      foreach ($file in $files) {
        if ($file.Extension.ToLowerInvariant() -notin $extensions) {
          continue
        }

        if ($file.Length -lt $MinimumBytes) {
          continue
        }

        $fullPath = [System.IO.Path]::GetFullPath($file.FullName)
        if (-not $AllowUntracked -and -not $TrackedFiles.Contains($fullPath)) {
          continue
        }

        if (-not $fullPath.StartsWith($RepoRoot, [System.StringComparison]::OrdinalIgnoreCase)) {
          continue
        }

        $file
      }
    }
  }
}

$repoRoot = Get-RepoRoot
$trackedFiles = Get-TrackedFileSet -RepoRoot $repoRoot
$tempRoot = Join-Path $env:TEMP ("myblog-image-optimize-" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $tempRoot | Out-Null

$processed = 0
$optimized = 0
$skipped = 0
$savedBytes = 0L

try {
  $candidates = @(Get-CandidateImages `
    -InputPaths $Path `
    -MinimumBytes $MinBytes `
    -RepoRoot $repoRoot `
    -TrackedFiles $trackedFiles `
    -AllowUntracked:$IncludeUntracked)

  if ($ReportLarge) {
    $largeImages = $candidates | Sort-Object Length -Descending
    foreach ($image in $largeImages) {
      $relativePath = [System.IO.Path]::GetRelativePath($repoRoot, $image.FullName)
      Write-Host ("LARGE {0} ({1:N0} bytes)" -f $relativePath, $image.Length)
    }

    Write-Host ("Done (large-report). Checked: {0}, threshold: {1:N0} bytes." -f @($largeImages).Count, $MinBytes)
    return
  }

  foreach ($image in $candidates) {
    $processed += 1
    $tempFile = Join-Path $tempRoot ([guid]::NewGuid().ToString("N") + $image.Extension.ToLowerInvariant())

    try {
      Save-OptimizedImage -Source $image -Destination $tempFile -Quality $JpegQuality
      $newSize = (Get-Item -LiteralPath $tempFile).Length
      $oldSize = $image.Length
      $delta = $oldSize - $newSize
      $relativePath = [System.IO.Path]::GetRelativePath($repoRoot, $image.FullName)

      if ($delta -le 0) {
        $skipped += 1
        Write-Host ("SKIP {0} ({1:N0} bytes -> {2:N0} bytes)" -f $relativePath, $oldSize, $newSize)
        continue
      }

      $percent = [math]::Round(($delta / $oldSize) * 100, 1)
      if ($Apply) {
        if ($PSCmdlet.ShouldProcess($image.FullName, "Replace with optimized image")) {
          Copy-Item -LiteralPath $tempFile -Destination $image.FullName -Force
        }
        Write-Host ("OK   {0} ({1:N0} -> {2:N0}, -{3:N0} bytes, {4}%)" -f $relativePath, $oldSize, $newSize, $delta, $percent)
      } else {
        Write-Host ("PLAN {0} ({1:N0} -> {2:N0}, -{3:N0} bytes, {4}%)" -f $relativePath, $oldSize, $newSize, $delta, $percent)
      }

      $optimized += 1
      $savedBytes += $delta
    } catch {
      $skipped += 1
      Write-Warning ("FAILED {0}: {1}" -f $image.FullName, $_.Exception.Message)
    } finally {
      if (Test-Path -LiteralPath $tempFile) {
        Remove-Item -LiteralPath $tempFile -Force
      }
    }
  }
} finally {
  if (Test-Path -LiteralPath $tempRoot) {
    Remove-Item -LiteralPath $tempRoot -Recurse -Force
  }
}

$mode = if ($Apply) { "applied" } else { "dry-run" }
Write-Host ("Done ({0}). Checked: {1}, optimized: {2}, skipped: {3}, saved: {4:N0} bytes." -f $mode, $processed, $optimized, $skipped, $savedBytes)
