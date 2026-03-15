#!/bin/bash
# Deploy ido4shape plugin to both CLI cache and Cowork
# Run this after pushing changes instead of claude plugin install/uninstall

set -e

PLUGIN_NAME="ido4shape"
MARKETPLACE="ido4-plugins"

echo "=== Updating CLI plugin ==="
claude plugin uninstall "${PLUGIN_NAME}@${MARKETPLACE}" 2>/dev/null || true
claude plugin install "${PLUGIN_NAME}@${MARKETPLACE}"

echo ""
echo "=== Syncing to Cowork ==="
CACHE="$HOME/.claude/plugins/cache/${MARKETPLACE}/${PLUGIN_NAME}/1.0.0"
COWORK_BASE="$HOME/Library/Application Support/Claude/local-agent-mode-sessions"

if [ ! -d "$CACHE" ]; then
  echo "ERROR: CLI cache not found at $CACHE"
  exit 1
fi

# Find the cowork_plugins directory (there's one per account/org)
SYNCED=0
find "$COWORK_BASE" -type d -name "cowork_plugins" 2>/dev/null | while read COWORK_DIR; do
  TARGET="$COWORK_DIR/marketplaces/local-desktop-app-uploads/$PLUGIN_NAME"
  if [ -d "$TARGET" ] || [ -d "$(dirname "$TARGET")" ]; then
    rm -rf "$TARGET"
    cp -R "$CACHE" "$TARGET"
    echo "  Synced to: $TARGET"
    SYNCED=1
  fi
done

if [ "$SYNCED" -eq 0 ] 2>/dev/null; then
  echo "  No existing Cowork plugin directory found — Cowork will pick up from CLI cache on next install"
fi

echo ""
echo "=== Done. Restart Cowork to pick up changes. ==="
