param(
  [Parameter(Mandatory = $true, Position = 0)]
  [string]$Title,

  [Parameter(Position = 1)]
  [string]$Slug = "",

  [string]$Cover = "",

  [string[]]$Tags = @()
)

$ErrorActionPreference = "Stop"

function Convert-ToPostSlug {
  param([string]$Text)

  $slugText = $Text.Trim().ToLowerInvariant()
  $slugText = $slugText -replace '\s+', '-'
  $slugText = $slugText -replace '[\\/:*?"<>|#%&{}$!''@+`=]', '-'
  $slugText = $slugText -replace '-{2,}', '-'
  $slugText = $slugText.Trim('-')

  if ([string]::IsNullOrWhiteSpace($slugText)) {
    return (Get-Date -Format "yyyyMMdd-HHmmss")
  }

  return $slugText
}

function Format-YamlList {
  param([string[]]$Items)

  if (-not $Items -or $Items.Count -eq 0) {
    return "[]"
  }

  $quoted = $Items | ForEach-Object {
    '"' + ($_.Replace('\', '\\').Replace('"', '\"')) + '"'
  }
  return "[" + ($quoted -join ", ") + "]"
}

$postSlug = if ([string]::IsNullOrWhiteSpace($Slug)) { Convert-ToPostSlug $Title } else { Convert-ToPostSlug $Slug }
$postDir = Join-Path (Join-Path (Get-Location) "content\posts") $postSlug
$indexPath = Join-Path $postDir "index.md"

if (Test-Path -LiteralPath $postDir) {
  throw "Post folder already exists: $postDir"
}

New-Item -ItemType Directory -Path $postDir | Out-Null

$date = Get-Date -Format "yyyy-MM-ddTHH:mm:sszzz"
$tagList = Format-YamlList $Tags
$frontMatter = @"
---
title: "$Title"
date: $date
draft: true
tags: $tagList
categories: []
featured: false
cover: "$Cover"
---

在这里开始写正文。
"@

Set-Content -LiteralPath $indexPath -Value $frontMatter -Encoding UTF8

Write-Host "Created post bundle:"
Write-Host "  $indexPath"
Write-Host ""
Write-Host "Publish later by changing draft: true to draft: false."
