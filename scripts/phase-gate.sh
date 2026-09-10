#!/bin/bash
# PreToolUse hook on Write: block premature spec artifact writing
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INPUT=$(cat)

# Extract file path from tool input
FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.loads(sys.stdin.read())
    path = d.get('file_path', d.get('input', {}).get('file_path', ''))
    print(path)
except:
    print('')
" 2>/dev/null)

# Only gate *-spec.md files
case "$FILE_PATH" in
  *-spec.md) ;;
  *) echo '{"decision": "allow"}'; exit 0 ;;
esac

# Find workspace
WORKSPACE=$("$SCRIPT_DIR/find-workspace.sh" 2>/dev/null)
if [ $? -ne 0 ] || [ ! -f "$WORKSPACE/canvas.md" ]; then
  echo '{"decision": "allow"}'
  exit 0
fi

# Check for insufficient understanding
# Only the Understanding Assessment block decides readiness. Scanning the whole
# canvas would let the words "not started" in ordinary project prose block a write.
ASSESSMENT=$(sed -n '/^## Understanding Assessment/,/^## [^U]/p' "$WORKSPACE/canvas.md" 2>/dev/null)
NOT_READY=$(printf '%s\n' "$ASSESSMENT" | grep -i "not started\|: thin" | head -3)

if [ -n "$NOT_READY" ]; then
  REASONS=$(echo "$NOT_READY" | sed 's/^- //' | tr '\n' '; ')
  echo "{\"decision\": \"block\", \"reason\": \"Understanding is insufficient for spec composition. Dimensions not ready: ${REASONS}\"}"
else
  echo '{"decision": "allow"}'
fi
