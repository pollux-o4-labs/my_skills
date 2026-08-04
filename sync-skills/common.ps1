<#
.SYNOPSIS
  common.ps1 — Shared constants and helper functions for PowerShell sync scripts.
#>
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot  = Split-Path -Parent $ScriptDir
$Home_     = $env:USERPROFILE
$ClaudeSkills = Join-Path $Home_ '.claude\skills'

$NotSkills = @('.git','.github','.claude','.playwright-mcp','.system','review','sync-skills','docs','node_modules','md-ebook','show-me')
$CopyOnlyIfMissing = @('md2ebook')

function Get-SkillMap([string]$root) {
  $map = @{}
  if (-not (Test-Path $root)) { return $map }
  foreach ($d in (Get-ChildItem -Path $root -Directory -Force -ErrorAction SilentlyContinue)) {
    if ($d.Name -in $NotSkills) { continue }
    $p = $d.FullName
    if (($d.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
      $p = $d.Target; if (-not $p) { $p = $d.LinkTarget }
    }
    if ($p -and (Test-Path (Join-Path $p 'SKILL.md'))) { $map[$d.Name] = $p }
  }
  return $map
}
