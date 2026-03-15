#!/bin/bash
# UserPromptSubmit hook: inject canvas Understanding Assessment into every prompt
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKSPACE=$("$SCRIPT_DIR/find-workspace.sh" 2>/dev/null) || exit 0

[ -f "$WORKSPACE/canvas.md" ] || exit 0

ASSESSMENT=$(sed -n '/^## Understanding Assessment/,/^## /{ /^## Understanding Assessment/d; /^## [^U]/d; p; }' "$WORKSPACE/canvas.md" 2>/dev/null)

if [ -n "$ASSESSMENT" ]; then
  echo "[ido4shape canvas state]"
  echo "$ASSESSMENT"
fi
