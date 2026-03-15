#!/bin/bash
# SessionStart hook: detect new source materials and output canvas state
# Outputs context text that gets injected into the session

WORKSPACE=""
# Find .ido4shape in any mounted directory
for dir in /sessions/*/mnt/*/; do
  if [ -d "${dir}.ido4shape" ]; then
    WORKSPACE="${dir}.ido4shape"
    break
  fi
done

# Also check cwd-relative paths
if [ -z "$WORKSPACE" ] && [ -d ".ido4shape" ]; then
  WORKSPACE=".ido4shape"
fi

if [ -z "$WORKSPACE" ]; then
  exit 0  # No workspace — not a spec project, do nothing
fi

echo "=== ido4shape session context ==="

# Output current Understanding Assessment
if [ -f "$WORKSPACE/canvas.md" ]; then
  echo ""
  echo "Current canvas Understanding Assessment:"
  # Extract the Understanding Assessment section
  sed -n '/^## Understanding Assessment/,/^## /{ /^## Understanding Assessment/d; /^## [^U]/d; p; }' "$WORKSPACE/canvas.md" 2>/dev/null
fi

# Check for new source materials
if [ -d "$WORKSPACE/sources" ]; then
  LATEST_SESSION=$(ls -t "$WORKSPACE/sessions/" 2>/dev/null | head -1)
  if [ -n "$LATEST_SESSION" ]; then
    # Find files in sources/ newer than the latest session summary
    NEW_FILES=$(find "$WORKSPACE/sources/" -type f -newer "$WORKSPACE/sessions/$LATEST_SESSION" 2>/dev/null)
    if [ -n "$NEW_FILES" ]; then
      echo ""
      echo "New source materials added since last session:"
      echo "$NEW_FILES" | while read f; do echo "  - $(basename "$f")"; done
    fi
  fi
fi

# Output stakeholder summary if exists
if [ -f "$WORKSPACE/stakeholders.md" ]; then
  STAKEHOLDER_COUNT=$(grep -c "^## " "$WORKSPACE/stakeholders.md" 2>/dev/null || echo "0")
  if [ "$STAKEHOLDER_COUNT" -gt 0 ]; then
    echo ""
    echo "Stakeholders who have contributed: $STAKEHOLDER_COUNT"
  fi
fi

# Output active tensions count
if [ -f "$WORKSPACE/tensions.md" ]; then
  TENSION_COUNT=$(grep -ci "active\|unresolved" "$WORKSPACE/tensions.md" 2>/dev/null || echo "0")
  if [ "$TENSION_COUNT" -gt 0 ]; then
    echo ""
    echo "Active tensions: $TENSION_COUNT"
  fi
fi
