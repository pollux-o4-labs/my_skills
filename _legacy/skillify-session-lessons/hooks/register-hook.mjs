#!/usr/bin/env node
// register-hook.mjs — idempotently register this skill's `Stop` hook (skillify-gate.mjs)
// into the host's ~/.claude/settings.json. Run once per machine by the sync-skills
// bootstrap (install.sh / install.ps1), which already branches per OS.
//
// Why a node registrar instead of per-OS shell mergers: settings.json is JSON, and a
// safe merge (preserve every other hook/key, never clobber, be idempotent) is materially
// harder and more divergent in bash+jq vs PowerShell. node is already a hard dependency
// (the hook itself runs `node`), so one JSON.parse/stringify merger serves both hosts.
// The per-OS differences — the gate path's separators (from import.meta.url) and the
// settings location (os.homedir()) — are derived here, so the same script serves both.
//
// Design goals: never corrupt settings.json (parse-fail => abort, not clobber), back up
// before writing, write only when something actually changes, touch nothing but this
// skill's own Stop entry.

import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const HOOK_TIMEOUT = 15; // seconds; matches auto-trigger.md
const MARKER = 'skillify-gate.mjs'; // identifies OUR Stop hook across path migrations

function log(msg) { process.stdout.write(`[register-hook] ${msg}\n`); }
function fail(msg) { process.stderr.write(`[register-hook] ${msg}\n`); process.exit(1); }

const home = os.homedir();

// Point the hook at the gate script INSIDE this repo (this file lives at
// <repo>/skillify-session-lessons/hooks/register-hook.mjs, so ../scripts/skillify-gate.mjs
// is the gate). Resolved per machine at install time — no clone-path hardcoding (the drift
// bug this fixes). Chosen over the ~/.claude/skills/<skill> synced link because the link is
// pruned when the skill leaves the sync manifest, which would leave a dead Stop-hook path;
// the repo folder persists. This also matches the proven-working Windows config shape.
const hooksDir = path.dirname(fileURLToPath(import.meta.url));
const gatePath = path.resolve(hooksDir, '..', 'scripts', 'skillify-gate.mjs');
if (!fs.existsSync(gatePath)) {
  fail(`gate script not found at ${gatePath}\n` +
       `  expected it next to this registrar — is the skill checkout intact?`);
}

const command = `node "${gatePath}"`;

const settingsPath = path.join(home, '.claude', 'settings.json');

let raw = '{}';
let existed = false;
if (fs.existsSync(settingsPath)) {
  existed = true;
  try { raw = fs.readFileSync(settingsPath, 'utf8'); }
  catch (e) { fail(`cannot read ${settingsPath}: ${e.message}`); }
}

let settings;
// Strip a leading UTF-8 BOM: Windows PowerShell 5.1 writes UTF-8-with-BOM by default,
// and JSON.parse throws on a leading ﻿. Without this the fix silently no-ops on Windows.
const rawNoBom = raw.replace(/^\uFEFF/, '');
try { settings = JSON.parse(rawNoBom || '{}'); }
catch (e) {
  // Never overwrite a file we cannot parse — the user may have hand edits/comments.
  fail(`${settingsPath} is not valid JSON (${e.message}). Aborting without changes.`);
}
if (settings === null || typeof settings !== 'object' || Array.isArray(settings)) {
  fail(`${settingsPath} top-level is not a JSON object. Aborting.`);
}

if (!settings.hooks || typeof settings.hooks !== 'object') settings.hooks = {};
if (!Array.isArray(settings.hooks.Stop)) settings.hooks.Stop = [];

// Find OUR entry: any Stop matcher containing a command that references the gate script.
let action = 'added';
let found = false;
for (const entry of settings.hooks.Stop) {
  if (!entry || !Array.isArray(entry.hooks)) continue;
  for (const h of entry.hooks) {
    if (h && typeof h.command === 'string' && h.command.includes(MARKER)) {
      found = true;
      if (h.command !== command) { h.command = command; action = 'updated'; }
      else { action = 'unchanged'; }
      if (h.timeout !== HOOK_TIMEOUT) { h.timeout = HOOK_TIMEOUT; if (action === 'unchanged') action = 'updated'; }
    }
  }
}

if (!found) {
  const gateHook = { type: 'command', command, timeout: HOOK_TIMEOUT };
  // Prefer merging into an existing always-on (empty-matcher) Stop entry's hooks[] — this is
  // the proven-working shape (the user's Windows config runs sound + gate as two hooks under
  // ONE matcher:"" entry). Appending a sibling entry would rely on Claude Code dispatching
  // multiple same-matcher Stop entries, which is unverified. Fall back to a new entry.
  const target = settings.hooks.Stop.find(
    (e) => e && Array.isArray(e.hooks) && (e.matcher === '' || e.matcher == null),
  );
  if (target) target.hooks.push(gateHook);
  else settings.hooks.Stop.push({ matcher: '', hooks: [gateHook] });
  action = 'added';
}

const next = JSON.stringify(settings, null, 2) + '\n';
if (existed && next === raw) {
  log(`already up to date — no change (${settingsPath}).`);
  process.exit(0);
}

// Back up the exact original bytes before writing (only when a file existed).
if (existed) {
  try { fs.writeFileSync(settingsPath + '.bak', raw); }
  catch (e) { fail(`cannot write backup ${settingsPath}.bak: ${e.message}`); }
}
try { fs.writeFileSync(settingsPath, next); }
catch (e) { fail(`cannot write ${settingsPath}: ${e.message}`); }

log(`${action} Stop hook -> ${command}`);
log(`settings: ${settingsPath}${existed ? ' (backup: settings.json.bak)' : ' (created)'}`);
