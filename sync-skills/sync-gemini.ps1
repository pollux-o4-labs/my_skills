<#
.SYNOPSIS
  sync-gemini.ps1 — Dedicated script to sync skills into Gemini / agy CLI paths on Windows.
#>
[CmdletBinding(SupportsShouldProcess=$true)]
param(
  [string[]]$Only = @(),
  [switch]$PruneMirror,
  [switch]$VerboseOutput,
  [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'common.ps1')

$srcMap = Get-SkillMap $ClaudeSkills
$repoMap = Get-SkillMap $RepoRoot
foreach ($k in $repoMap.Keys) {
  if (-not $srcMap.ContainsKey($k)) { $srcMap[$k] = $repoMap[$k] }
}

$wanted = @($srcMap.Keys)
if ($Only.Count -gt 0) { $wanted = @($wanted | Where-Object { $_ -in $Only }) }

$GeminiDests = @(
  (Join-Path $Home_ '.gemini\skills'),
  (Join-Path $Home_ '.gemini\antigravity-cli\skills'),
  (Join-Path $Home_ '.gemini\config\skills')
)

foreach ($dest in $GeminiDests) {
  if (-not (Test-Path $dest) -and $dest -ne (Join-Path $Home_ '.gemini\skills')) { continue }
  if (-not (Test-Path $dest)) {
    if ($PSCmdlet.ShouldProcess($dest, 'create gemini skills dir')) {
      New-Item -ItemType Directory -Path $dest -Force | Out-Null
    }
  }

  $updated = 0
  if ($PruneMirror) {
    Get-ChildItem -Path $dest -Directory -Force -ErrorAction SilentlyContinue | ForEach-Object {
      if ($_.Name -notin $wanted) {
        if ($VerboseOutput) { Write-Host "    prune (not in source): $($_.Name)" -ForegroundColor DarkYellow }
        if ($PSCmdlet.ShouldProcess($_.FullName, 'remove stale copy')) {
          Remove-Item $_.FullName -Force -Recurse -ErrorAction SilentlyContinue
        }
      }
    }
  }

  foreach ($name in $wanted) {
    $src = $srcMap[$name]
    if (-not $src) { continue }
    $dst = Join-Path $dest $name
    if (($name -in $CopyOnlyIfMissing) -and (Test-Path $dst)) { continue }
    if ($PSCmdlet.ShouldProcess($dst, "copy <- $src")) {
      if (Test-Path $dst) { Remove-Item $dst -Force -Recurse -ErrorAction SilentlyContinue }
      Copy-Item -Path $src -Destination $dst -Recurse -Force
      if ($VerboseOutput) { Write-Host "    + copy $name" -ForegroundColor Gray }
      $updated++
    }
  }
  Write-Host "==> [gemini] $dest ($($wanted.Count) skills synced, $updated updated)" -ForegroundColor Green
}

Write-Host "sync-gemini: done." -ForegroundColor Cyan
