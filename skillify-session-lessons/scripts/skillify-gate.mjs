#!/usr/bin/env node
// skillify-gate.mjs — Claude Code `Stop` hook. Heuristic gate that decides whether the
// just-finished session is a candidate for `skillify-session-lessons` (the manual
// self-improvement loop), and if so injects a one-line nudge back to Claude.
//
// Contract (Claude Code Stop hook):
//  - stdin: JSON { session_id, transcript_path, stop_hook_active, ... }
//  - to nudge: print JSON { hookSpecificOutput: { hookEventName:"Stop", additionalContext } }
//    and exit 0. Non-blocking — context is injected into the model's next turn without
//    forcing it to continue (unlike decision:"block").
//  - to stay silent: exit 0 with NO stdout.
//
// Design goals: BOARDING-PASS conservative (few false positives), fire AT MOST ONCE per
// session, never loop (respect stop_hook_active), never throw (any error => silent exit 0).
//
// Not applied automatically — registered in ~/.claude/settings.json by the user/coordinator.

import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';

// ---- never let this hook break the session: any failure => silent pass ----
function silent() { process.exit(0); }
process.on('uncaughtException', silent);

// ---- tunables (conservative on purpose) ----
const MIN_USER_TURNS      = 8;   // short sessions rarely yield reusable skills
const MIN_CORRECTIONS     = 2;   // repeated user corrections = strong signal
const MIN_FAILURE_RECOVER = 1;   // at least one error-then-progress arc
const SCORE_TO_FIRE       = 2;   // need >=2 of the 3 signal families

// user-correction cues (KO + EN), matched case-insensitively on user turns
const CORRECTION_RE = /(아니(?!요\s*됐)|그게\s*아니|다시\b|틀렸|잘못|왜\s*안|여전히|아직도|되돌려|원래대로|not what|that's wrong|no,? that|revert|undo this|still (broken|failing|not))/i;
// failure cues on tool-result / assistant turns
const FAILURE_RE = /(error|exception|failed|traceback|not found|cannot|denied|npm err|fatal:|✘|❌)/i;

function readStdin() {
  try { return fs.readFileSync(0, 'utf8'); } catch { return ''; }
}

function main() {
  let input = {};
  try { input = JSON.parse(readStdin() || '{}'); } catch { return silent(); }

  // infinite-loop guard: if we already blocked once this stop cycle, do nothing
  if (input.stop_hook_active) return silent();

  const tp = input.transcript_path;
  if (!tp || !fs.existsSync(tp)) return silent();

  // once-per-session guard via a marker file keyed by session_id
  // state lives under ~/.claude (stable, user-visible) — NOT os.tmpdir (may be purged/session-scoped)
  const sid = input.session_id || path.basename(tp);
  const stateDir = path.join(os.homedir(), '.claude', 'skillify-gate-state');
  try { fs.mkdirSync(stateDir, { recursive: true }); } catch {}
  const marker = path.join(stateDir, `${sanitize(sid)}.done`);
  if (fs.existsSync(marker)) return silent();

  let userTurns = 0, corrections = 0, failures = 0, recoveredAfterFailure = 0;
  let sawFailure = false;

  let lines;
  try { lines = fs.readFileSync(tp, 'utf8').split('\n'); } catch { return silent(); }

  for (const ln of lines) {
    const s = ln.trim();
    if (!s) continue;
    let o; try { o = JSON.parse(s); } catch { continue; }

    const role = o.role || o.type || o.message?.role;
    const text = extractText(o);
    if (!text) continue;

    if (role === 'user' || role === 'human') {
      // skip synthetic tool-result envelopes that Claude Code tags as user role
      const isToolResult = /tool_result|tool_use_id/.test(s);
      if (!isToolResult) {
        userTurns++;
        if (CORRECTION_RE.test(text)) corrections++;
      }
    }
    if (FAILURE_RE.test(text)) { failures++; sawFailure = true; }
    // any substantive assistant turn AFTER a failure = a recovery arc
    if ((role === 'assistant') && sawFailure && text.length > 40) {
      recoveredAfterFailure++;
      sawFailure = false;
    }
  }

  if (userTurns < MIN_USER_TURNS) return silent();

  let score = 0;
  if (corrections >= MIN_CORRECTIONS) score++;
  if (recoveredAfterFailure >= MIN_FAILURE_RECOVER) score++;
  if (userTurns >= 15 && failures >= 3) score++;  // long+bumpy workflow

  if (score < SCORE_TO_FIRE) return silent();

  // fire once
  try { fs.writeFileSync(marker, new Date().toISOString()); } catch {}

  const note = [
    '[skillify-gate] 이 세션은 스킬화 후보 조건을 충족했다',
    `(사용자 정정 ${corrections}회, 실패→복구 ${recoveredAfterFailure}회, 유저 턴 ${userTurns}).`,
    '마무리 전에 skillify-session-lessons 실행 여부를 사용자에게 제안하라 —',
    '재사용 가능한 일반 원리면 스킬로 승격, 아니면 넘어가면 된다.',
  ].join(' ');

  process.stdout.write(JSON.stringify({
    hookSpecificOutput: { hookEventName: 'Stop', additionalContext: note },
  }));
  process.exit(0);
}

function extractText(o) {
  if (typeof o.content === 'string') return o.content;
  if (typeof o.text === 'string') return o.text;
  const c = o.message?.content ?? o.content;
  if (Array.isArray(c)) {
    return c.map(b => (typeof b === 'string' ? b : b?.text || '')).join(' ');
  }
  if (typeof c === 'string') return c;
  return '';
}

function sanitize(s) { return String(s).replace(/[^a-zA-Z0-9_-]/g, '_').slice(0, 80); }

main();
