#!/bin/bash
# Find the user's project directory (where .ido4shape should live)
# Works in both Cowork VM and Claude Code CLI

# In Cowork VM: find the mounted project folder
if [ "${CLAUDE_CODE_IS_COWORK}" = "1" ] && [ -d "/sessions" ]; then
  SESSION_NAME=$(basename "$HOME")
  for dir in "/sessions/$SESSION_NAME/mnt"/*/; do
    [ -d "$dir" ] || continue
    case "$dir" in
      */.local-plugins/*|*/.claude/*|*/.skills/*|*/.remote-plugins/*|*/uploads/*) continue ;;
    esac
    echo "$dir"
    exit 0
  done
fi

# Claude Code CLI: use current directory
echo "$(pwd)"
exit 0
