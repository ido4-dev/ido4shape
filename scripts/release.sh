#!/bin/bash
# Release script: bump version, commit, push both repos
# Usage: bash scripts/release.sh [patch|minor|major] "Release message"
# Default: patch

set -e

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
MARKETPLACE_DIR="$(cd "$PLUGIN_DIR/../ido4-plugins" && pwd)"

BUMP_TYPE="${1:-patch}"
MESSAGE="${2:-Release}"

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

# Update marketplace.json
python3 -c "
import json
path = '$MARKETPLACE_DIR/.claude-plugin/marketplace.json'
d = json.load(open(path))
for p in d['plugins']:
    if p['name'] == 'ido4shape':
        p['version'] = '$NEW_VERSION'
json.dump(d, open(path, 'w'), indent=2)
print('  Updated: marketplace.json')
"

# Commit and push plugin repo
echo ""
echo "=== Pushing ido4shape ==="
cd "$PLUGIN_DIR"
git add -A
git commit -m "v${NEW_VERSION}: ${MESSAGE}

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
git push

# Commit and push marketplace repo
echo ""
echo "=== Pushing ido4-plugins ==="
cd "$MARKETPLACE_DIR"
git add -A
git commit -m "ido4shape v${NEW_VERSION}

Co-Authored-By: Claude Opus 4.6 (1M context) <noreply@anthropic.com>"
git push

echo ""
echo "==========================================="
echo "Released ido4shape v${NEW_VERSION}"
echo "==========================================="
echo ""
echo "Next steps:"
echo "  1. In Cowork: Sync ido4-plugins marketplace"
echo "  2. In Cowork: Update ido4shape plugin"
echo "  3. Start a new session to test"
