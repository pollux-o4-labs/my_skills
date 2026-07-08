<#
  sync-skills.ps1 — one command to register/refresh skills for every CLI host.

  Replaces the old, hard-to-find C:\Users\orix4\.gemini\antigravity-cli\sync-skills.ps1.
  Now lives IN the repo (my_skills\sync-skills\) so it is version-controlled and easy to find.

  Hosts differ in registration mechanism (see CLAUDE.md "스킬 등록 경로" table):

    Claude Code : curated hub at ~\.claude\skills. A full run auto-registers AIL-*
                  skills (AI-Learned, always-on guidance) but NOT other repo skills
                  (some are deliberately kept out). Register a non-AIL repo skill with
                  `-Only <name>` — it junctions repo\<name> -> hub\<name> if absent.
    Codex       : junction  ~\.codex\skills\<name>   ->  personal skills activated in ~\.claude\skills
    Gemini/agy  : COPY (physical dir) from ~\.claude\skills, with junctions resolved

  Gemini roots are NOT pruned by default (we cannot tell a stale copy from a skill
  installed by another tool). Pass -PruneMirror to delete gemini entries absent from
  the union source.

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
    pwsh -File sync-skills.ps1 -Host gemini    # one host only (claude|codex|gemini)
    pwsh -File sync-skills.ps1 -Only foo-skill # register repo skill 'foo-skill' into hub, then all hosts
    pwsh -File sync-skills.ps1 -WhatIf         # dry run, no changes
    pwsh -File sync-skills.ps1 -SkipPull       # accepted for backward compatibility (no-op)

  Safe to run repeatedly (idempotent).
#>
[CmdletBinding(SupportsShouldProcess = $true)]
param(
  [ValidateSet('all','claude','codex','gemini')]
  [string]$Host_ = 'all',
  [switch]$SkipPull,
  [switch]$PruneMirror,          # allow pruning gemini copies absent from union source
  [string[]]$Only = @()          # restrict to these skill names (e.g. registering new skills)
)

$ErrorActionPreference = 'Stop'
# normalize -Only: `pwsh -File ... -Only a,b` arrives as one string "a,b" — split it
$Only = @($Only | ForEach-Object { $_ -split ',' } | ForEach-Object { $_.Trim() } | Where-Object { $_ })
$RepoRoot     = Split-Path -Parent $PSScriptRoot                  # ...\my_skills
$ClaudeSkills = Join-Path $env:USERPROFILE '.claude\skills'      # union root gemini mirrors
$Home_        = $env:USERPROFILE
$LegacyCodexSources = @(
  $RepoRoot,
  (Join-Path $env:USERPROFILE '.agents\my_skills')
)

# Skills whose gemini copy is refreshed ONLY when absent (submodule-backed; may hold unmerged WIP)
$CopyOnlyIfMissing = @('md2ebook')

# Directories in a source root that are NOT skills.
# md-ebook / show-me are git SUBMODULES deployed via `npx skills add pollux-o4/<repo>` —
# never junction/copy them from here (working tree may hold unmerged branches).
$NotSkills = @('.git','.claude','.playwright-mcp','.system','review','sync-skills','docs','node_modules',
               'md-ebook','show-me')

# --- host registration table -------------------------------------------------
# mode 'junction': dest\<name> -> source\<name> (source = physical root this host owns)
# mode 'mirror-copy': dest\<name> = physical copy of resolved source\<name>
$Hosts = @(
  # claude hub is CURATED: a full run never auto-adds repo skills (some are deliberately
  # kept out, e.g. git-workflow-select). Pass -Only <name> to register a repo skill here.
  @{ name='claude'; dest=(Join-Path $Home_ '.claude\skills');                 source=$RepoRoot;     mode='curated-junction' },
  @{ name='codex';  dest=(Join-Path $Home_ '.codex\skills');                  source=$ClaudeSkills; mode='personal-junction'; legacySources=$LegacyCodexSources },
  # agy reads three roots; all must be physical copies (union source resolved per skill)
  @{ name='gemini'; dest=(Join-Path $Home_ '.gemini\skills');                 source=$ClaudeSkills; mode='mirror-copy' },
  @{ name='gemini'; dest=(Join-Path $Home_ '.gemini\antigravity-cli\skills'); source=$ClaudeSkills; mode='mirror-copy' },
  @{ name='gemini'; dest=(Join-Path $Home_ '.gemini\config\skills');          source=$ClaudeSkills; mode='mirror-copy' }
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

function Select-PersonalSourceMap($map, [string]$repoRoot) {
  $personal = @{}
  $repoPrefix = $repoRoot.TrimEnd('\') + '\'
  foreach ($name in $map.Keys) {
    $src = $map[$name]
    if ($src -and $src.StartsWith($repoPrefix, [StringComparison]::OrdinalIgnoreCase)) {
      $personal[$name] = $src
    }
  }
  return $personal
}

function Get-SkillNames([string]$root) {
  Get-ChildItem -Path $root -Directory -Force |
    Where-Object { $_.Name -notin $NotSkills -and (Test-Path (Join-Path $_.FullName 'SKILL.md')) } |
    Select-Object -ExpandProperty Name
}

function Test-IsReparse($item) { return ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0 }

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

# Resolve a claude-skills entry (junction or plain dir) to its physical path.
function Resolve-SkillDir($item) {
  if (Test-IsReparse $item) {
    $t = $item.Target; if (-not $t) { $t = $item.LinkTarget }
    if ($t -and (Test-Path $t)) { return $t } else { return $null }
  }
  return $item.FullName
}

# --- sync each configured host root -----------------------------------------
foreach ($h in $Hosts) {
  if ($Host_ -ne 'all' -and $h.name -ne $Host_) { continue }

  $dest   = $h.dest
  $source = $h.source
  $mode   = $h.mode
  if ($mode -eq 'personal-junction') {
    $ownedSources = @($h.legacySources | Where-Object { $_ })
  } else {
    $ownedSources = @($source) + @($h.legacySources | Where-Object { $_ })
  }

  if (-not (Test-Path $source)) {
    Write-Warning "[$($h.name)] source missing: $source — skipped."
    continue
  }
  if (-not (Test-Path $dest)) {
    if ($PSCmdlet.ShouldProcess($dest, 'create host skills dir')) {
      New-Item -ItemType Directory -Path $dest -Force | Out-Null
    }
  }

  if ($mode -in @('junction','personal-junction','mirror-copy','curated-junction')) {
    $srcMap = Get-ResolvedSourceMap $source
    if ($mode -eq 'personal-junction') { $srcMap = Select-PersonalSourceMap $srcMap $RepoRoot }
    $wanted = @($srcMap.Keys)
  }
  else {
    $wanted = @(Get-SkillNames $source)
  }
  if ($Only.Count -gt 0) { $wanted = @($wanted | Where-Object { $_ -in $Only }) }
  Write-Host "==> [$($h.name)/$mode] $dest  (<= $source, $($wanted.Count) skills)" -ForegroundColor Green

  if ($mode -eq 'source-only') {
    Write-Host "    source-only: no changes; this root controls the active skill set." -ForegroundColor Gray
  }
  elseif ($mode -eq 'curated-junction') {
    # Full run auto-registers AIL-* skills (always-on AI-Learned guidance) so `git pull`
    # + this script connects newly pulled AIL skills. Non-AIL repo skills register only
    # when named via -Only; deliberate exclusions otherwise survive. (Mirrors sync-skills.sh.)
    $allNames = @($srcMap.Keys)
    $targets  = @($allNames | Where-Object { $_ -like 'AIL-*' })
    if ($Only.Count -gt 0) {
      $targets = @($targets + @($allNames | Where-Object { $_ -in $Only }) | Select-Object -Unique)
    }
    if ($targets.Count -eq 0) {
      Write-Host "    curated: nothing to register (no AIL-* skills, no -Only)." -ForegroundColor Gray
    }
    else {
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
  }
  elseif ($mode -in @('junction','personal-junction')) {
    # 1) prune ONLY junctions this source owns (dangling, or skill removed from source).
    #    Plain dirs and junctions pointing elsewhere are other installers' property — leave them.
    Get-ChildItem -Path $dest -Directory -Force -ErrorAction SilentlyContinue | ForEach-Object {
      $entry = $_
      if (-not (Test-OwnedJunction $entry $ownedSources)) { return }
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
        if (-not (Test-OwnedJunction $existing $ownedSources)) {
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
