#!/bin/bash
# Stop hook: emit a session-wrap reminder ONLY if real spec work happened
# in this session and no session summary has been written yet.
#
# Silent (allow stop) when:
#   - no workspace exists
#   - no sentinel (workspace pre-dates this fix) — fail open, allow stop
#   - no workspace files newer than the session-start sentinel
#   - a session summary has already been written this session
#
# Block (continue with reminder) when:
#   - canvas/decisions/tensions/stakeholders has been touched this session
#   - AND no session summary newer than sentinel exists yet

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

WORKSPACE=$("$SCRIPT_DIR/find-workspace.sh" 2>/dev/null) || exit 0
[ -d "$WORKSPACE" ] || exit 0

SENTINEL="$WORKSPACE/.session-start"
[ -f "$SENTINEL" ] || exit 0

# Has a session summary already been written this session?
SUMMARY_WRITTEN=$(find "$WORKSPACE/sessions" -type f -name "*.md" -newer "$SENTINEL" 2>/dev/null | head -1)
if [ -n "$SUMMARY_WRITTEN" ]; then
  exit 0
fi

# Has any tracked workspace file been touched this session?
WORK_DONE=""
for f in canvas.md decisions.md tensions.md stakeholders.md; do
  if [ -f "$WORKSPACE/$f" ] && [ "$WORKSPACE/$f" -nt "$SENTINEL" ]; then
    WORK_DONE="yes"
    break
  fi
done

if [ -z "$WORK_DONE" ]; then
  exit 0
fi

# Real work happened, no summary yet — ask Claude to wrap up.
cat <<'JSON'
{"decision": "block", "reason": "Specification work happened in this session but no session summary has been written yet. Update the canvas to reflect everything learned, then write a session summary to .ido4shape/sessions/session-NNN-[role].md (key insights, decisions, tensions, what to explore next), then stop."}
JSON
