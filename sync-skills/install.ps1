<#
  install.ps1 — one-time per-clone bootstrap on Windows. Mirror of install.sh.

  Git does NOT ship hook activation with a clone (security). So core.hooksPath must
  be set once per clone. This sets it, then runs an initial sync so skills are linked
  immediately. After this, every `git pull` auto-links newly pulled AIL skills via the
  OS-dispatching post-merge hook.

    pwsh -File sync-skills\install.ps1
#>
$ErrorActionPreference = 'Stop'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot  = Split-Path -Parent $ScriptDir
Push-Location $RepoRoot
try {
  git config --local core.hooksPath sync-skills/git-hooks
  Write-Host "[install] core.hooksPath -> sync-skills/git-hooks"
  $sync = Join-Path $ScriptDir 'sync-skills.ps1'
  if (Test-Path $sync) {
    Write-Host "[install] initial sync:"
    & $sync
  }

  # register skill-owned Stop hook (idempotent; runs after sync so the skill is linked)
  $gateRegistrar = Join-Path $RepoRoot 'skillify-session-lessons\hooks\register-hook.mjs'
  if (Test-Path $gateRegistrar) {
    if (Get-Command node -ErrorAction SilentlyContinue) {
      Write-Host "[install] registering skillify Stop hook:"
      & node $gateRegistrar
      if ($LASTEXITCODE -ne 0) { Write-Host "[install] WARN: hook registration failed (skills still linked)" }
    } else {
      Write-Host "[install] WARN: node not found — skipping skillify Stop hook registration"
    }
  }

  Write-Host "[install] done — future 'git pull' will auto-link skills."
}
finally { Pop-Location }
