$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$TestHome = Join-Path ([IO.Path]::GetTempPath()) ('my-skills-sync-' + [guid]::NewGuid().ToString())
$OriginalUserProfile = $env:USERPROFILE
$OriginalAppData = $env:APPDATA

function Assert-True([bool]$condition, [string]$message) {
  if (-not $condition) { throw $message }
}

function Assert-JunctionTarget([string]$path, [string]$target) {
  $item = Get-Item -LiteralPath $path -Force -ErrorAction Stop
  Assert-True (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) "expected junction: $path"
  Assert-True ($item.Target -ieq $target) "unexpected target for ${path}: $($item.Target)"
}

try {
  $env:USERPROFILE = $TestHome
  $env:APPDATA = Join-Path $TestHome 'AppData'
  $custom = Join-Path $TestHome '.agents\custom-skills'
  $claude = Join-Path $TestHome '.claude\skills'
  $codex = Join-Path $TestHome '.codex\skills'
  $agy = Join-Path $TestHome '.gemini\config\skills'
  $skill = 'engineering-principles'
  $repoSkill = Join-Path $RepoRoot $skill
  $defaultSkills = @(
    'agent-orchestration-principles',
    'business--growth--growth-and-revenue',
    'business--operations--business-operations-and-governance',
    'computer-science--application--application-engineering',
    'computer-science--communication--technical-ecosystem',
    'computer-science--foundations--computing-data-and-intelligence',
    'computer-science--platform--systems-and-delivery',
    'computer-science--product--product-experience',
    'computer-science--quality--quality-and-security',
    'documentation-principles',
    'engineering-principles',
    'git-workflow-principles',
    'research-principles',
    'resource-principles',
    'skill-authoring-principles',
    'verification-principles'
  )

  New-Item -ItemType Directory -Path $claude, $codex, $agy -Force | Out-Null
  & (Join-Path $ScriptDir 'sync-skills.ps1') 6>$null

  Assert-True (@(Get-ChildItem -LiteralPath $custom -Directory).Count -eq $defaultSkills.Count) 'default profile did not register every canonical skill'
  foreach ($defaultSkill in $defaultSkills) {
    $repoDefaultSkill = Join-Path $RepoRoot $defaultSkill
    Assert-JunctionTarget (Join-Path $custom $defaultSkill) $repoDefaultSkill
    Assert-JunctionTarget (Join-Path $claude $defaultSkill) (Join-Path $custom $defaultSkill)
    Assert-JunctionTarget (Join-Path $codex $defaultSkill) (Join-Path $custom $defaultSkill)
  }
  Assert-True (Test-Path (Join-Path $agy "$skill\SKILL.md")) 'agy copy missing'

  & (Join-Path $ScriptDir 'desync-skills.ps1') -Only $skill -RemoveGemini 6>$null
  Assert-True (-not (Get-Item -LiteralPath (Join-Path $custom $skill) -Force -ErrorAction SilentlyContinue)) 'personal hub link was not removed by desync'
  Assert-True (-not (Get-Item -LiteralPath (Join-Path $claude $skill) -Force -ErrorAction SilentlyContinue)) 'Claude link was not removed by desync'
  Assert-True (-not (Get-Item -LiteralPath (Join-Path $codex $skill) -Force -ErrorAction SilentlyContinue)) 'Codex link was not removed by desync'
  Assert-True (-not (Test-Path (Join-Path $agy $skill))) 'agy copy was not removed by desync'
  Remove-Item -LiteralPath (Join-Path $env:APPDATA 'my_skills') -Recurse -Force
  & (Join-Path $ScriptDir 'sync-skills.ps1') 6>$null

  New-Item -ItemType Directory -Path (Join-Path $TestHome 'foreign\skill') -Force | Out-Null
  New-Item -ItemType Junction -Path (Join-Path $claude 'foreign-skill') -Target (Join-Path $TestHome 'foreign\skill') | Out-Null
  New-Item -ItemType Junction -Path (Join-Path $codex 'foreign-skill') -Target (Join-Path $claude 'foreign-skill') | Out-Null
  $disabled = Join-Path $env:APPDATA 'my_skills\disabled-skills.txt'
  New-Item -ItemType Directory -Path (Split-Path -Parent $disabled) -Force | Out-Null
  Set-Content -LiteralPath $disabled -Value $skill
  & (Join-Path $ScriptDir 'sync-skills.ps1') 6>$null

  Assert-True (-not (Get-Item -LiteralPath (Join-Path $custom $skill) -Force -ErrorAction SilentlyContinue)) 'personal hub link was not pruned'
  Assert-True (-not (Get-Item -LiteralPath (Join-Path $claude $skill) -Force -ErrorAction SilentlyContinue)) 'Claude link was not pruned'
  Assert-True (-not (Get-Item -LiteralPath (Join-Path $codex $skill) -Force -ErrorAction SilentlyContinue)) 'Codex link was not pruned'
  Assert-True ($null -ne (Get-Item -LiteralPath (Join-Path $claude 'foreign-skill') -Force -ErrorAction SilentlyContinue)) 'foreign link was pruned'
  Assert-True ($null -ne (Get-Item -LiteralPath (Join-Path $codex 'foreign-skill') -Force -ErrorAction SilentlyContinue)) 'foreign Codex link was pruned'

  Write-Output 'test-sync-skills.ps1: PASS'
}
finally {
  $env:USERPROFILE = $OriginalUserProfile
  $env:APPDATA = $OriginalAppData
  if (Test-Path -LiteralPath $TestHome) { Remove-Item -LiteralPath $TestHome -Recurse -Force }
}
