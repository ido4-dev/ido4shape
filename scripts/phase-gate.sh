#!/bin/bash
# PreToolUse hook on Write: block premature spec artifact writing
# Reads the tool input from stdin (JSON with file_path)
# Returns JSON decision: {"decision": "allow"} or {"decision": "block", "reason": "..."}

INPUT=$(cat)

# Extract the file path being written
FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.loads(sys.stdin.read())
    # The input structure varies — try common paths
    path = d.get('file_path', d.get('input', {}).get('file_path', ''))
    print(path)
except:
    print('')
" 2>/dev/null)

# Only gate *-spec.md files
case "$FILE_PATH" in
  *-spec.md)
    ;;
  *)
    echo '{"decision": "allow"}'
    exit 0
    ;;
esac

# Find the workspace
WORKSPACE=""
for dir in /sessions/*/mnt/*/; do
  if [ -d "${dir}.ido4shape" ]; then
    WORKSPACE="${dir}.ido4shape"
    break
  fi
done

if [ -z "$WORKSPACE" ] && [ -d ".ido4shape" ]; then
  WORKSPACE=".ido4shape"
fi

if [ -z "$WORKSPACE" ] || [ ! -f "$WORKSPACE/canvas.md" ]; then
  # No workspace — allow the write (probably not using ido4shape workflow)
  echo '{"decision": "allow"}'
  exit 0
fi

# Check Understanding Assessment for "not started" or "thin"
CANVAS="$WORKSPACE/canvas.md"
NOT_READY=$(grep -i "not started\|: thin" "$CANVAS" 2>/dev/null | head -3)

if [ -n "$NOT_READY" ]; then
  # Found dimensions that aren't ready
  REASONS=$(echo "$NOT_READY" | sed 's/^- //' | tr '\n' '; ')
  echo "{\"decision\": \"block\", \"reason\": \"Understanding is insufficient for spec composition. Dimensions not ready: ${REASONS}\"}"
else
  echo '{"decision": "allow"}'
fi
