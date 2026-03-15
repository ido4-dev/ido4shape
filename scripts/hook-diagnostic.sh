#!/bin/bash
# Diagnostic: captures execution environment for hooks in Cowork
# Output goes into the session context so we can read it in the logs

echo "=== ido4shape hook diagnostic ==="
echo "Date: $(date)"
echo "Hostname: $(hostname)"
echo "User: $(whoami)"
echo "CWD: $(pwd)"
echo "Shell: $SHELL"
echo "OS: $(uname -s) $(uname -m)"
echo ""

echo "=== Key paths ==="
echo "HOME: $HOME"
echo "CLAUDE_PLUGIN_ROOT: ${CLAUDE_PLUGIN_ROOT:-NOT SET}"
echo "CLAUDE_SKILL_DIR: ${CLAUDE_SKILL_DIR:-NOT SET}"
echo "CLAUDE_SESSION_ID: ${CLAUDE_SESSION_ID:-NOT SET}"
echo ""

echo "=== /sessions/ check ==="
if [ -d "/sessions" ]; then
  echo "/sessions EXISTS"
  ls -la /sessions/ 2>/dev/null | head -5
  echo ""
  echo "Mounted dirs:"
  find /sessions/*/mnt/ -maxdepth 1 -type d 2>/dev/null | head -20
else
  echo "/sessions DOES NOT EXIST (running on host, not in VM)"
fi
echo ""

echo "=== CWD contents ==="
ls -la 2>/dev/null | head -10
echo ""

echo "=== .ido4shape check ==="
if [ -d ".ido4shape" ]; then
  echo ".ido4shape EXISTS in CWD"
  find .ido4shape -type f 2>/dev/null
else
  echo ".ido4shape NOT in CWD"
fi
echo ""

echo "=== Environment variables ==="
env | grep -i "claude\|session\|plugin\|cowork\|workspace\|project" 2>/dev/null | sort
echo ""

echo "=== Script location ==="
echo "Script: $0"
echo "Script dir: $(cd "$(dirname "$0")" && pwd)"
echo "=== end diagnostic ==="
