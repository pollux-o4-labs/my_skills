<#
  desync-skills.ps1 — disable this repo's skills on the local machine.

  Personal-hub/Claude/Codex junctions are removed only when their ownership can be proved.
  agy's official copy root is preserved unless -RemoveGemini is explicitly requested.
  Legacy Gemini copies are preserved unless -RemoveLegacyGemini is explicitly requested.
  The antigravity-cli directory is internal state and is never touched.
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [switch]$All,
  [string[]]$Only = @(),
  [switch]$RemoveGemini,
  [switch]$RemoveLegacyGemini
)

$ErrorActionPreference = 'Stop'
$RepoRoot = Split-Path -Parent $PSScriptRoot
$Home_ = $env:USERPROFILE
if (-not $Home_) { $Home_ = $env:HOME }
$CustomDir = Join-Path $Home_ '.agents\custom-skills'
$ClaudeDir = Join-Path $Home_ '.claude\skills'
$CodexDir = Join-Path $Home_ '.codex\skills'
$LegacyRepoRoot = Join-Path $Home_ '.agents\my_skills'
$ConfigBase = if ($env:APPDATA) { $env:APPDATA } else { Join-Path $Home_ '.config' }
$DisabledFile = if ($env:MY_SKILLS_DISABLED_FILE) { $env:MY_SKILLS_DISABLED_FILE } else { Join-Path (Join-Path $ConfigBase 'my_skills') 'disabled-skills.txt' }
$AgyDir = Join-Path $Home_ '.gemini\config\skills'
$LegacyGeminiDir = Join-Path $Home_ '.gemini\skills'
$NotSkills = @('.git','.github','.claude','.playwright-mcp','.system','review','sync-skills','docs','node_modules','md-ebook','show-me','_legacy','templates')

$Only = @($Only | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })
foreach ($name in $Only) {
  if ($name -notmatch '^[A-Za-z0-9._-]+$') { throw "invalid skill name: $name" }
}
if (-not $All -and $Only.Count -eq 0) { throw 'choose -All or -Only' }

function Test-IsReparse($item) {
  return ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0
}

function Test-OwnedJunction($item, [string[]]$sourceRoots) {
  if (-not (Test-IsReparse $item)) { return $false }
  $target = $item.Target
  if (-not $target) { return $false }
  $parent = (Split-Path -Parent $target).TrimEnd('\')
  foreach ($sourceRoot in $sourceRoots) {
    if ($parent -ieq $sourceRoot.TrimEnd('\')) { return $true }
  }
  return $false
}

function Test-OwnedCustomEntry($item) {
  return Test-OwnedJunction $item @($RepoRoot)
}

function Test-OwnedHostEntry($item, [string[]]$legacyRoots) {
  if (-not (Test-IsReparse $item)) { return $false }
  $target = $item.Target
  if (-not $target) { return $false }
  $parent = (Split-Path -Parent $target).TrimEnd('\')
  if ($parent -ieq $CustomDir.TrimEnd('\')) { return $true }
  foreach ($root in $legacyRoots) {
    if ($parent -ieq $root.TrimEnd('\')) { return $true }
  }
  return $false
}

function Test-OwnedLegacyCodexEntry($item) {
  if (-not (Test-IsReparse $item)) { return $false }
  $target = $item.Target
  if (-not $target) { return $false }
  if ((Split-Path -Parent $target).TrimEnd('\') -ine $ClaudeDir.TrimEnd('\')) { return $false }
  $claudeEntry = Get-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue
  return $claudeEntry -and (Test-OwnedHostEntry $claudeEntry @($RepoRoot, $LegacyRepoRoot))
}

function Get-RepoSkillNames {
  Get-ChildItem -Path $RepoRoot -Directory -Force |
    Where-Object { $_.Name -notin $NotSkills -and (Test-Path (Join-Path $_.FullName 'SKILL.md')) } |
    Select-Object -ExpandProperty Name
}

function Get-TargetNames {
  $names = @()
  $names += @(Get-RepoSkillNames)
  if (Test-Path $CustomDir) {
    $names += @(Get-ChildItem -Path $CustomDir -Force -ErrorAction SilentlyContinue |
      Where-Object { Test-OwnedCustomEntry $_ } | Select-Object -ExpandProperty Name)
  }
  if (Test-Path $ClaudeDir) {
    $names += @(Get-ChildItem -Path $ClaudeDir -Force -ErrorAction SilentlyContinue |
      Where-Object { Test-OwnedHostEntry $_ @($RepoRoot) } | Select-Object -ExpandProperty Name)
  }
  if (Test-Path $CodexDir) {
    $names += @(Get-ChildItem -Path $CodexDir -Force -ErrorAction SilentlyContinue |
      Where-Object { (Test-OwnedHostEntry $_ @($RepoRoot, $LegacyRepoRoot)) -or (Test-OwnedLegacyCodexEntry $_) } | Select-Object -ExpandProperty Name)
  }
  return @($names | Sort-Object -Unique)
}

$DisabledNames = @()
if (Test-Path $DisabledFile) {
  $DisabledNames = @(Get-Content $DisabledFile | ForEach-Object { ($_ -replace '#.*$','').Trim() } | Where-Object { $_ })
}

$names = @(Get-TargetNames)
if ($Only.Count -gt 0) { $names = @($names | Where-Object { $_ -in $Only }) }
if ($names.Count -eq 0) { throw 'no matching repo-owned skills' }

foreach ($name in $names) {
  if ($name -notin $DisabledNames) {
    Write-Host "    disable: $name"
    if ($PSCmdlet.ShouldProcess($DisabledFile, "add disabled skill $name")) {
      New-Item -ItemType Directory -Path (Split-Path -Parent $DisabledFile) -Force | Out-Null
      Add-Content -LiteralPath $DisabledFile -Value $name
      $DisabledNames += $name
    }
  }

  $codexLink = Join-Path $CodexDir $name
  $codexEntry = Get-Item -LiteralPath $codexLink -Force -ErrorAction SilentlyContinue
  if ($codexEntry -and ((Test-OwnedHostEntry $codexEntry @($RepoRoot, $LegacyRepoRoot)) -or (Test-OwnedLegacyCodexEntry $codexEntry))) {
    Write-Host "    remove codex: $name"
    if ($PSCmdlet.ShouldProcess($codexLink, 'remove owned junction')) { [IO.Directory]::Delete($codexLink) }
  }

  $claudeLink = Join-Path $ClaudeDir $name
  $claudeEntry = Get-Item -LiteralPath $claudeLink -Force -ErrorAction SilentlyContinue
  if ($claudeEntry -and (Test-OwnedHostEntry $claudeEntry @($RepoRoot, $LegacyRepoRoot))) {
    Write-Host "    remove claude: $name"
    if ($PSCmdlet.ShouldProcess($claudeLink, 'remove owned junction')) { [IO.Directory]::Delete($claudeLink) }
  }

  $customLink = Join-Path $CustomDir $name
  $customEntry = Get-Item -LiteralPath $customLink -Force -ErrorAction SilentlyContinue
  if ($customEntry -and (Test-OwnedCustomEntry $customEntry)) {
    Write-Host "    remove personal hub: $name"
    if ($PSCmdlet.ShouldProcess($customLink, 'remove owned junction')) { [IO.Directory]::Delete($customLink) }
  }

  $agyCopy = Join-Path $AgyDir $name
  $agyEntry = Get-Item -LiteralPath $agyCopy -Force -ErrorAction SilentlyContinue
  if ($agyEntry -and -not (Test-IsReparse $agyEntry)) {
    if ($RemoveGemini) {
      Write-Host "    remove agy copy: $agyCopy"
      if ($PSCmdlet.ShouldProcess($agyCopy, 'remove physical copy')) { Remove-Item -LiteralPath $agyCopy -Recurse -Force }
    }
    else { Write-Host "    keep agy copy (use -RemoveGemini): $agyCopy" }
  }

  $legacyCopy = Join-Path $LegacyGeminiDir $name
  $legacyEntry = Get-Item -LiteralPath $legacyCopy -Force -ErrorAction SilentlyContinue
  if ($legacyEntry -and -not (Test-IsReparse $legacyEntry)) {
    if ($RemoveLegacyGemini) {
      Write-Host "    remove legacy Gemini copy: $legacyCopy"
      if ($PSCmdlet.ShouldProcess($legacyCopy, 'remove legacy physical copy')) { Remove-Item -LiteralPath $legacyCopy -Recurse -Force }
    }
    else { Write-Host "    keep legacy Gemini copy (use -RemoveLegacyGemini): $legacyCopy" }
  }
}

Write-Host "desync-skills: done. disabled list: $DisabledFile"
