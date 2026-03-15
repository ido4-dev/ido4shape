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
NOT_READY=$(grep -i "not started\|: thin" "$WORKSPACE/canvas.md" 2>/dev/null | head -3)

if [ -n "$NOT_READY" ]; then
  REASONS=$(echo "$NOT_READY" | sed 's/^- //' | tr '\n' '; ')
  echo "{\"decision\": \"block\", \"reason\": \"Understanding is insufficient for spec composition. Dimensions not ready: ${REASONS}\"}"
else
  echo '{"decision": "allow"}'
fi
