#!/bin/bash
# UserPromptSubmit hook: inject canvas Understanding Assessment into every prompt
# Outputs the current state so the agent always has it in recent context

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
  exit 0  # No workspace or canvas — do nothing
fi

# Extract and output Understanding Assessment
ASSESSMENT=$(sed -n '/^## Understanding Assessment/,/^## /{ /^## Understanding Assessment/d; /^## [^U]/d; p; }' "$WORKSPACE/canvas.md" 2>/dev/null)

if [ -n "$ASSESSMENT" ]; then
  echo "[ido4shape canvas state]"
  echo "$ASSESSMENT"
fi
