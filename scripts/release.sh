#!/bin/bash
# Release script: bump version, commit, push ido4shape.
# Marketplace sync happens automatically via sync-marketplace.yml CI workflow.
# Usage: bash scripts/release.sh [patch|minor|major] "Release message"
# Default: patch

set -e

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"

BUMP_TYPE="${1:-patch}"
MESSAGE="${2:-Release}"

# ─── Pre-flight: Bundle Validation ─────────────────────────

BUNDLE="$PLUGIN_DIR/dist/spec-validator.js"
VERSION_FILE="$PLUGIN_DIR/dist/.spec-format-version"

if [ ! -f "$BUNDLE" ]; then
  echo "ERROR: $BUNDLE not found."
  echo "Run: scripts/update-validator.sh <version>"
  exit 1
fi

if ! head -3 "$BUNDLE" | grep -q "@ido4/spec-format v"; then
  echo "ERROR: $BUNDLE missing version header — not a valid bundle"
  exit 1
fi

BUNDLED_VERSION=$(cat "$VERSION_FILE" 2>/dev/null || echo "unknown")
LATEST_NPM=$(npm view @ido4/spec-format version 2>/dev/null || echo "unknown")

if [ "$BUNDLED_VERSION" != "$LATEST_NPM" ] && [ "$LATEST_NPM" != "unknown" ]; then
  echo "WARNING: Bundled spec-validator is v$BUNDLED_VERSION, latest on npm is v$LATEST_NPM"
  echo "Consider running: scripts/update-validator.sh $LATEST_NPM"
  read -p "Continue anyway? [y/N] " -n 1 -r
  echo
  [[ $REPLY =~ ^[Yy]$ ]] || exit 1
fi

echo "Pre-flight: spec-validator v$BUNDLED_VERSION ✓"
echo ""

# ─── Version Bump ──────────────────────────────────────────

# Read current version from plugin.json
CURRENT=$(python3 -c "
import json
d = json.load(open('$PLUGIN_DIR/.claude-plugin/plugin.json'))
print(d['version'])
")

# Bump version
NEW_VERSION=$(python3 -c "
parts = '$CURRENT'.split('.')
major, minor, patch = int(parts[0]), int(parts[1]), int(parts[2])
bump = '$BUMP_TYPE'
if bump == 'major':
    major += 1; minor = 0; patch = 0
elif bump == 'minor':
    minor += 1; patch = 0
else:
    patch += 1
print(f'{major}.{minor}.{patch}')
")

echo "Version: $CURRENT → $NEW_VERSION ($BUMP_TYPE)"
echo ""

# Update plugin.json
python3 -c "
import json
path = '$PLUGIN_DIR/.claude-plugin/plugin.json'
d = json.load(open(path))
d['version'] = '$NEW_VERSION'
json.dump(d, open(path, 'w'), indent=2)
print('  Updated: plugin.json')
"

# Commit and push
echo ""
echo "=== Pushing ido4shape ==="
cd "$PLUGIN_DIR"
git add -A
git commit -m "v${NEW_VERSION}: ${MESSAGE}

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
git push

echo ""
echo "==========================================="
echo "Released ido4shape v${NEW_VERSION}"
echo "==========================================="
echo ""
echo "CI will automatically:"
echo "  1. Run validation tests"
echo "  2. Sync to ido4-plugins marketplace (full directory)"
echo "  3. Create GitHub release"
echo ""
echo "To deploy to Cowork:"
echo "  1. In Cowork: Sync ido4-plugins marketplace"
echo "  2. In Cowork: Update ido4shape plugin"
