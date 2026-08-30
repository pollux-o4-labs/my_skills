<#
  sync-skills.ps1 — one command to register/refresh skills for every CLI host.

  Replaces the old, hard-to-find C:\Users\orix4\.gemini\antigravity-cli\sync-skills.ps1.
  Now lives IN the repo (my_skills\sync-skills\) so it is version-controlled and easy to find.

  Hosts differ in registration mechanism (see CLAUDE.md "스킬 등록 경로" table):

    personal hub: curated links at ~\.agents\custom-skills. A full run auto-registers AIL-*
                  skills (AI-Learned, always-on guidance) but NOT other repo skills
                  (some are deliberately kept out). Register a non-AIL repo skill with
                  `-Only <name>` — it junctions repo\<name> -> hub\<name> if absent.
    Claude Code : junction  ~\.claude\skills\<name>  ->  personal hub
    Codex       : junction  ~\.codex\skills\<name>   ->  personal hub
    agy         : COPY (physical dir) to ~\.gemini\config\skills, with junctions resolved

  agy's official global discovery root is ~/.gemini/config/skills. The legacy
  ~/.gemini/skills root is not managed, and ~/.gemini/antigravity-cli is internal state.

  Why gemini MUST be physical copies: `agy` (Go) treats junctions as ReparsePoint files
  and skips them in ReadDir, so junction-linking gemini skills makes them invisible.

  SAFETY RULES (learned the hard way — do not "simplify" these away):
   - Claude/Codex hosts contain junctions from OTHER sources (~\.agents\skills\*) and
     plain local dirs (kcaveman, hatch-pet, .system). NEVER prune those. We only prune
     a junction when its recorded target is a DIRECT CHILD of this host's own source
     root (i.e. it was created by this script / this repo) and it is dangling or the
     skill left the source.
   - md2ebook is backed by the md-ebook git submodule. Its working tree may hold
     unmerged WIP, so we never re-copy it over an existing gemini copy (copy only if
     missing). Listed in $CopyOnlyIfMissing.

  Usage:
    pwsh -File sync-skills.ps1                 # sync all hosts
    pwsh -File sync-skills.ps1 -Host agy       # one host only (claude|codex|agy; gemini is an alias)
    pwsh -File sync-skills.ps1 -Only foo-skill # register repo skill 'foo-skill' into the personal hub, then all hosts
    pwsh -File sync-skills.ps1 -AllSkills      # register every repo skill into the personal hub
    pwsh -File sync-skills.ps1 -WhatIf         # dry run, no changes
    pwsh -File sync-skills.ps1 -SkipPull       # accepted for backward compatibility (no-op)
    %APPDATA%\my_skills\disabled-skills.txt   # local names excluded from sync

  Safe to run repeatedly (idempotent).
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [ValidateSet('all','claude','codex','agy','gemini')]
  [string]$Host_ = 'all',
  [switch]$SkipPull,
  [switch]$PruneMirror,          # allow pruning gemini copies absent from union source
  [switch]$AllSkills,
  [string[]]$Only = @()          # restrict to these skill names (e.g. registering new skills)
)

$ErrorActionPreference = 'Stop'
# normalize -Only: `pwsh -File ... -Only a,b` arrives as one string "a,b" — split it
$Only = @($Only | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })
$Host_ = if ($Host_ -eq 'gemini') { 'agy' } else { $Host_ }
$RepoRoot     = Split-Path -Parent $PSScriptRoot                  # ...\my_skills
$Home_        = $env:USERPROFILE
$CustomSkills = Join-Path $Home_ '.agents\custom-skills'
$ClaudeSkills = Join-Path $Home_ '.claude\skills'
$ConfigBase   = if ($env:APPDATA) { $env:APPDATA } else { Join-Path $env:USERPROFILE '.config' }
$DisabledFile = if ($env:MY_SKILLS_DISABLED_FILE) { $env:MY_SKILLS_DISABLED_FILE } else { Join-Path (Join-Path $ConfigBase 'my_skills') 'disabled-skills.txt' }
$LegacyClaudeSources = @(
  $RepoRoot,
  (Join-Path $env:USERPROFILE '.agents\my_skills')
)
$LegacyCodexSources = @($LegacyClaudeSources)

# Skills whose gemini copy is refreshed ONLY when absent (submodule-backed; may hold unmerged WIP)
$CopyOnlyIfMissing = @('md2ebook')

# Directories in a source root that are NOT skills.
# md-ebook / show-me are git SUBMODULES deployed via `npx skills add pollux-o4/<repo>` —
# never junction/copy them from here (working tree may hold unmerged branches).
$NotSkills = @('.git','.github','.claude','.playwright-mcp','.system','review','sync-skills','docs','node_modules',
               'md-ebook','show-me','_legacy','templates')

# Declarative manifest: non-AIL repo skills to link into the personal hub.
# (AIL-* are auto by provenance and need not be listed.) One name per line; '#' comments.
$ManifestFile = Join-Path $PSScriptRoot 'custom-skills.txt'
$Manifest = @()
if (Test-Path $ManifestFile) {
  $Manifest = @(Get-Content $ManifestFile | ForEach-Object { ($_ -replace '#.*$','').Trim() } | Where-Object { $_ })
}
$DisabledNames = @()
if (Test-Path $DisabledFile) {
  $DisabledNames = @(Get-Content $DisabledFile | ForEach-Object { ($_ -replace '#.*$','').Trim() } | Where-Object { $_ })
}

# --- host registration table -------------------------------------------------
# mode 'junction': dest\<name> -> source\<name> (source = physical root this host owns)
# mode 'mirror-copy': dest\<name> = physical copy of resolved source\<name>
$Hosts = @(
  @{ name='custom'; dest=$CustomSkills;                                        source=$RepoRoot;      mode='curated-junction' },
  @{ name='claude'; dest=$ClaudeSkills;                                        source=$CustomSkills;  mode='junction'; legacySources=$LegacyClaudeSources },
  @{ name='codex';  dest=(Join-Path $Home_ '.codex\skills');                  source=$CustomSkills;  mode='junction'; legacySources=$LegacyCodexSources },
  # agy's official global discovery root. Legacy ~/.gemini/skills is not managed;
  # ~/.gemini/antigravity-cli contains internal runtime state and is not a skill root.
  @{ name='agy';    dest=(Join-Path $Home_ '.gemini\config\skills');          source=$CustomSkills;  mode='mirror-copy' }
)

function Get-ResolvedSourceMap([string]$root) {
  $map = @{}
  foreach ($d in (Get-ChildItem -Path $root -Directory -Force -ErrorAction SilentlyContinue)) {
    if ($d.Name -in $NotSkills) { continue }
    $p = Resolve-SkillDir $d
    if ($p -and (Test-Path (Join-Path $p 'SKILL.md'))) { $map[$d.Name] = $p }
  }
  return $map
}

function Get-EntrySourceMap([string]$root) {
  $map = @{}
  foreach ($d in (Get-ChildItem -Path $root -Directory -Force -ErrorAction SilentlyContinue)) {
    if ($d.Name -in $NotSkills) { continue }
    $p = Resolve-SkillDir $d
    if ($p -and (Test-Path (Join-Path $p 'SKILL.md'))) { $map[$d.Name] = $d.FullName }
  }
  return $map
}

function Get-SkillNames([string]$root) {
  Get-ChildItem -Path $root -Directory -Force |
    Where-Object { $_.Name -notin $NotSkills -and (Test-Path (Join-Path $_.FullName 'SKILL.md')) } |
    Select-Object -ExpandProperty Name
}

function Test-IsReparse($item) { return ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0 }

function Test-IsDisabled([string]$name) { return $DisabledNames -contains $name }

# A junction "belongs to" a source root iff its recorded target is a direct child of it.
function Test-OwnedJunction($item, [string[]]$sourceRoots) {
  if (-not (Test-IsReparse $item)) { return $false }
  $t = $item.Target
  if (-not $t) { return $false }
  $parent = (Split-Path -Parent $t).TrimEnd('\')
  foreach ($sourceRoot in $sourceRoots) {
    if ($parent -ieq $sourceRoot.TrimEnd('\')) { return $true }
  }
  return $false
}

# The previous Codex topology used Claude as an intermediate hub. It is owned
# only when that Claude entry can itself be proved repo-owned; arbitrary Claude
# links must remain foreign.
function Test-OwnedLegacyCodexJunction($item) {
  if (-not (Test-IsReparse $item)) { return $false }
  $target = $item.Target
  if (-not $target) { return $false }
  if ((Split-Path -Parent $target).TrimEnd('\') -ine $ClaudeSkills.TrimEnd('\')) { return $false }
  $claudeEntry = Get-Item -LiteralPath $target -Force -ErrorAction SilentlyContinue
  return $claudeEntry -and (Test-OwnedJunction $claudeEntry $LegacyClaudeSources)
}

# Resolve a personal-hub entry (junction or plain dir) to its physical path.
function Resolve-SkillDir($item) {
  if (Test-IsReparse $item) {
    $t = $item.Target; if (-not $t) { $t = $item.LinkTarget }
    if ($t -and (Test-Path $t)) { return $t } else { return $null }
  }
  return $item.FullName
}

# --- sync each configured host root -----------------------------------------
foreach ($h in $Hosts) {
  if ($Host_ -ne 'all' -and $h.name -ne $Host_ -and $h.name -ne 'custom') { continue }

  $dest   = $h.dest
  $source = $h.source
  $mode   = $h.mode
  $ownedSources = @($source) + @($h.legacySources | Where-Object { $_ })

  if (-not (Test-Path $source)) {
    Write-Warning "[$($h.name)] source missing: $source — skipped."
    continue
  }
  if (-not (Test-Path $dest)) {
    if ($PSCmdlet.ShouldProcess($dest, 'create host skills dir')) {
      New-Item -ItemType Directory -Path $dest -Force | Out-Null
    }
  }

  if ($mode -eq 'junction') {
    $srcMap = Get-EntrySourceMap $source
  } else {
    $srcMap = Get-ResolvedSourceMap $source
  }
  $wanted = @($srcMap.Keys | Where-Object { -not (Test-IsDisabled $_) })
  Write-Host "==> [$($h.name)/$mode] $dest  (<= $source, $($wanted.Count) skills)" -ForegroundColor Green

  if ($mode -eq 'source-only') {
    Write-Host "    source-only: no changes; this root controls the active skill set." -ForegroundColor Gray
  }
  elseif ($mode -eq 'curated-junction') {
    # Full run registers AIL-* (auto by provenance) + custom-skills.txt manifest entries.
    # -Only adds ad-hoc names; -AllSkills registers every repo skill.
    $allNames = @($srcMap.Keys | Where-Object { -not (Test-IsDisabled $_) })
    $targets  = @($allNames | Where-Object { $AllSkills -or ($_ -like 'AIL-*') -or ($_ -in $Manifest) })
    if ($Only.Count -gt 0) {
      $targets = @($targets + @($allNames | Where-Object { $_ -in $Only }) | Select-Object -Unique)
    }
    if ($targets.Count -eq 0) {
      Write-Host "    curated: nothing to register (no AIL-* skills, empty manifest, no -Only/-AllSkills)." -ForegroundColor Gray
    }
    # Prune even when the curated target set is empty. This keeps migrations from
    # leaving repo-owned dangling junctions behind after the last skill is removed.
    # Foreign junctions / plain dirs are never touched. -Only limits pruning to named skills.
    Get-ChildItem -Path $dest -Directory -Force -ErrorAction SilentlyContinue | ForEach-Object {
      $entry = $_
      if (-not (Test-OwnedJunction $entry @($RepoRoot))) { return }
      if ($Only.Count -gt 0 -and $entry.Name -notin $Only) { return }
      $targetGone = -not (Test-Path $entry.Target)
      $notWanted  = $entry.Name -notin $targets
      if ($targetGone -or $notWanted) {
        $why = if ($targetGone) { 'dangling' } else { 'dropped from manifest' }
        Write-Host "    prune ($why): $($entry.Name)" -ForegroundColor DarkYellow
        if ($PSCmdlet.ShouldProcess($entry.FullName, "remove ($why)")) { [IO.Directory]::Delete($entry.FullName) }
      }
    }
    foreach ($name in $targets) {
      $src = $srcMap[$name]
      $dst = Join-Path $dest $name
      $existing = Get-Item $dst -ErrorAction SilentlyContinue
      if ($existing) {
        if ((Test-IsReparse $existing) -and ($existing.Target -ieq $src)) {
          Write-Host "    = already registered: $name" -ForegroundColor Gray; continue
        }
        if (-not (Test-OwnedJunction $existing @($RepoRoot))) {
          Write-Warning "    skip ${name}: hub slot occupied by foreign entry ($($existing.Target ?? 'plain dir')) — resolve manually."; continue
        }
        if ($PSCmdlet.ShouldProcess($dst, 'replace stale owned junction')) { [IO.Directory]::Delete($dst) }
      }
      if ($PSCmdlet.ShouldProcess($dst, "junction -> $src")) {
        New-Item -ItemType Junction -Path $dst -Target $src | Out-Null
        Write-Host "    + junction $name" -ForegroundColor Gray
      }
    }
    foreach ($n in $Only) {
      if ($n -notin $allNames) { Write-Warning "    ${n}: not a repo skill (no $RepoRoot\$n\SKILL.md) — nothing to register." }
    }
  }
  elseif ($mode -eq 'junction') {
    # 1) prune ONLY junctions this source owns (dangling, or skill removed from source).
    #    Plain dirs and junctions pointing elsewhere are other installers' property — leave them.
    Get-ChildItem -Path $dest -Directory -Force -ErrorAction SilentlyContinue | ForEach-Object {
      $entry = $_
      $owned = (Test-OwnedJunction $entry $ownedSources) -or ($h.name -eq 'codex' -and (Test-OwnedLegacyCodexJunction $entry))
      if (-not $owned) { return }
      if ($Only.Count -gt 0 -and $entry.Name -notin $Only) { return }
      $targetGone = -not (Test-Path $entry.Target)
      $notWanted  = $entry.Name -notin $wanted
      if ($targetGone -or $notWanted) {
        $why = if ($targetGone) { 'dangling junction' } else { 'removed from source' }
        Write-Host "    prune ($why): $($entry.Name)" -ForegroundColor DarkYellow
        if ($PSCmdlet.ShouldProcess($entry.FullName, "remove ($why)")) {
          # junction: remove the link itself, never recurse into the target
          [IO.Directory]::Delete($entry.FullName)
        }
      }
    }
    # 2) (re)create each wanted junction
    foreach ($name in $wanted) {
      $src = $srcMap[$name]
      if (-not $src) { Write-Warning "    skip ${name}: source unresolved."; continue }
      $dst = Join-Path $dest   $name
      $existing = Get-Item $dst -ErrorAction SilentlyContinue
      if ($existing) {
        if ((Test-IsReparse $existing) -and ($existing.Target -ieq $src)) { continue }  # already correct
        $existingOwned = (Test-OwnedJunction $existing $ownedSources) -or ($h.name -eq 'codex' -and (Test-OwnedLegacyCodexJunction $existing))
        if (-not $existingOwned) {
          Write-Warning "    skip ${name}: dest occupied by foreign entry ($($existing.Target ?? 'plain dir')) — resolve manually."
          continue
        }
        if ($PSCmdlet.ShouldProcess($dst, 'replace stale owned junction')) {
          [IO.Directory]::Delete($dst)
        }
      }
      if ($PSCmdlet.ShouldProcess($dst, "junction -> $src")) {
        New-Item -ItemType Junction -Path $dst -Target $src | Out-Null
        Write-Host "    + junction $name" -ForegroundColor Gray
      }
    }
  }
  elseif ($mode -eq 'mirror-copy') {
    if ($PruneMirror) {
      Get-ChildItem -Path $dest -Directory -Force -ErrorAction SilentlyContinue | ForEach-Object {
        if ($_.Name -notin $wanted) {
          Write-Host "    prune (not in union source): $($_.Name)" -ForegroundColor DarkYellow
          if ($PSCmdlet.ShouldProcess($_.FullName, 'remove stale copy')) {
            Remove-Item $_.FullName -Force -Recurse -ErrorAction SilentlyContinue
          }
        }
      }
    }
    foreach ($name in $wanted) {
      $src = $srcMap[$name]
      if (-not $src) { Write-Warning "    skip ${name}: source unresolved."; continue }
      $dst = Join-Path $dest $name
      if (($name -in $CopyOnlyIfMissing) -and (Test-Path $dst)) { continue }  # submodule-backed; don't overwrite
      if ($PSCmdlet.ShouldProcess($dst, "copy <- $src")) {
        if (Test-Path $dst) { Remove-Item $dst -Force -Recurse -ErrorAction SilentlyContinue }
        Copy-Item -Path $src -Destination $dst -Recurse -Force
        Write-Host "    + copy $name" -ForegroundColor Gray
      }
    }
  }
}

Write-Host "sync-skills: done." -ForegroundColor Cyan
