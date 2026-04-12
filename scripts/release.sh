#!/bin/bash
# Release script: bump version, update changelog, commit, push ido4shape.
# Marketplace sync happens automatically via sync-marketplace.yml CI workflow.
# Usage: bash scripts/release.sh [--yes] [patch|minor|major] "Release message"
# Default: patch
#
# Flags:
#   --yes   Auto-confirm warnings (for agent/CI use). Errors still abort.

set -e

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"

YES_FLAG=false
while [[ "${1:-}" == --* ]]; do
  case "$1" in
    --yes) YES_FLAG=true; shift ;;
    *) echo "Unknown flag: $1"; exit 1 ;;
  esac
done

BUMP_TYPE="${1:-patch}"
MESSAGE="${2:-Release}"

# ─── Pre-flight: Claude CLI ────────────────────────────────

if ! command -v claude &>/dev/null; then
  echo "WARNING: 'claude' CLI not found — changelog will use deterministic generation"
elif ! echo "ok" | claude -p --no-session-persistence --max-turns 1 --output-format text &>/dev/null; then
  echo "WARNING: 'claude' CLI not logged in — changelog will use deterministic generation"
  echo "  Run 'claude /login' for LLM-powered changelog entries"
  echo ""
fi

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
  if [ "$YES_FLAG" = "true" ]; then
    echo "  --yes flag: proceeding despite validator drift"
  else
    read -p "Continue anyway? [y/N] " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]] || exit 1
  fi
fi

echo "Pre-flight: spec-validator v$BUNDLED_VERSION ✓"
echo ""

# ─── Pre-flight: Local vs Remote Sync ──────────────────────

echo "Pre-flight: checking local vs origin/main..."
git fetch --quiet origin main 2>/dev/null || {
  echo "WARNING: Could not fetch origin/main (offline?). Skipping sync check."
  echo ""
}

if git rev-parse --verify origin/main >/dev/null 2>&1; then
  LOCAL_SHA=$(git rev-parse @)
  REMOTE_SHA=$(git rev-parse origin/main)
  BASE_SHA=$(git merge-base @ origin/main)

  if [ "$LOCAL_SHA" = "$REMOTE_SHA" ]; then
    echo "Pre-flight: local in sync with remote ✓"
    echo ""
  elif [ "$LOCAL_SHA" = "$BASE_SHA" ]; then
    # Local is behind remote — most likely the auto-update pipeline
    AHEAD_COUNT=$(git rev-list --count @..origin/main)
    echo ""
    echo "ERROR: Your local main is behind origin/main by ${AHEAD_COUNT} commit(s)."
    echo ""
    echo "This usually means the cross-repo sync pipeline auto-merged a PR"
    echo "(e.g., a spec-format validator update from ido4) into the remote"
    echo "since you last pulled. The pipeline runs without your involvement,"
    echo "so your local clone doesn't know about it until you fetch."
    echo ""
    echo "Commits on remote that you don't have locally:"
    git log --oneline @..origin/main | sed 's/^/  /'
    echo ""
    echo "To resolve, pull the missing commits and re-run the release:"
    echo "  git pull --ff-only origin main"
    echo "  bash scripts/release.sh ${BUMP_TYPE} \"${MESSAGE}\""
    exit 1
  elif [ "$REMOTE_SHA" = "$BASE_SHA" ]; then
    # Local is ahead of remote — normal in-progress state
    BEHIND_COUNT=$(git rev-list --count origin/main..@)
    echo "Pre-flight: local has ${BEHIND_COUNT} unpushed commit(s) ahead of remote — ok, continuing"
    echo ""
  else
    # Diverged — local has commits remote doesn't, AND remote has commits local doesn't
    LOCAL_ONLY=$(git rev-list --count origin/main..@)
    REMOTE_ONLY=$(git rev-list --count @..origin/main)
    echo ""
    echo "ERROR: Local and remote main have diverged."
    echo ""
    echo "Your local has ${LOCAL_ONLY} commit(s) that aren't on remote AND"
    echo "remote has ${REMOTE_ONLY} commit(s) that aren't on local. This needs"
    echo "manual resolution — most likely you made a local commit while the"
    echo "auto-update pipeline merged a PR upstream."
    echo ""
    echo "Local-only commits:"
    git log --oneline origin/main..@ | sed 's/^/  /'
    echo ""
    echo "Remote-only commits:"
    git log --oneline @..origin/main | sed 's/^/  /'
    echo ""
    echo "To resolve:"
    echo "  1. Inspect the remote commits above to understand what landed"
    echo "  2. Rebase your local work on top of remote:"
    echo "       git pull --rebase origin main"
    echo "  3. Re-run the release once main is unified:"
    echo "       bash scripts/release.sh ${BUMP_TYPE} \"${MESSAGE}\""
    exit 1
  fi
fi

# ─── Pre-flight: Plugin Validation Suite ───────────────────

echo "Pre-flight: running plugin validation suite..."
VALIDATE_LOG=$(mktemp)
if ! bash "$PLUGIN_DIR/tests/validate-plugin.sh" > "$VALIDATE_LOG" 2>&1; then
  echo "ERROR: Plugin validation failed. Aborting release."
  echo ""
  echo "--- Last 40 lines of validation output ---"
  tail -40 "$VALIDATE_LOG"
  echo ""
  echo "Full log: $VALIDATE_LOG"
  exit 1
fi
PASS_COUNT=$(grep -c "PASS:" "$VALIDATE_LOG" 2>/dev/null || echo "0")
rm -f "$VALIDATE_LOG"
echo "Pre-flight: plugin validation ✓ ($PASS_COUNT checks passed)"
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

# ─── Update CHANGELOG ─────────────────────────────────────

CHANGELOG="$PLUGIN_DIR/CHANGELOG.md"
TODAY=$(date +%Y-%m-%d)

# Get the last release tag
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [ -n "$LAST_TAG" ]; then
  RANGE="${LAST_TAG}..HEAD"
else
  RANGE="HEAD"
fi

# Collect raw commit messages and diff stats
COMMITS=$(git log "$RANGE" --pretty=format:"%s" | grep -v "^v[0-9]" | grep -v "^Merge")
DIFF_STAT=$(git diff "$RANGE" --stat 2>/dev/null || echo "")

# Try LLM-enhanced changelog first, fall back to deterministic
ENTRY=""
if command -v claude &>/dev/null; then
  echo "  Generating changelog with Claude (requires 'claude' CLI to be logged in)..."

  # Build prompt as a variable to avoid heredoc-in-substitution issues
  PROMPT="Write a CHANGELOG entry for a Cowork/Claude Code plugin release.

Version: $NEW_VERSION ($BUMP_TYPE bump)
Release message: $MESSAGE

Commits since last release:
$COMMITS

Files changed:
$DIFF_STAT

Rules:
- Use ### Added, ### Changed, ### Fixed sections (only sections that apply)
- Group related commits into single coherent items — don't list every commit separately
- Write from the USER's perspective, not the developer's
- One line per item, starting with \"- \"
- Be concise — each item should be one sentence
- No preamble, no explanation — output ONLY the markdown sections"

  RAW_ENTRY=$(echo "$PROMPT" | claude -p --no-session-persistence --model haiku --output-format text --max-turns 1 2>/dev/null) || true
  # Strip markdown code fences if present
  ENTRY=$(echo "$RAW_ENTRY" | sed '/^```/d')
fi

# Fall back to deterministic generation if claude unavailable or failed
if [ -z "$ENTRY" ]; then
  echo "  Generating changelog deterministically..."
  ENTRY=$(python3 -c "
import subprocess, re

range_arg = '$RANGE'
result = subprocess.run(
    ['git', 'log', range_arg, '--pretty=format:%s'],
    capture_output=True, text=True, cwd='$PLUGIN_DIR'
)
commits = [line.strip() for line in result.stdout.strip().split('\n') if line.strip()]
commits = [c for c in commits if not c.startswith('v') and not c.startswith('Merge')]

changed, added, fixed = [], [], []
for c in commits:
    c = c.split('\n')[0].strip()
    if not c: continue
    m = re.match(r'^(feat|fix|docs|enhance|refactor|chore|test)[\(:]?\s*(.+)', c, re.IGNORECASE)
    if m:
        prefix = m.group(1).lower()
        desc = m.group(2).lstrip(': ').rstrip('.')
        desc = re.sub(r'^\([^)]+\)\s*:?\s*', '', desc)
        desc = desc[0].upper() + desc[1:] if desc else desc
    else:
        prefix, desc = '', c[0].upper() + c[1:] if c else c
    if prefix == 'fix': fixed.append(desc)
    elif prefix in ('feat','enhance'): added.append(desc)
    else: changed.append(desc)

lines = []
if added: lines += ['### Added'] + [f'- {x}' for x in added] + ['']
if changed: lines += ['### Changed'] + [f'- {x}' for x in changed] + ['']
if fixed: lines += ['### Fixed'] + [f'- {x}' for x in fixed] + ['']
print('\n'.join(lines) if lines else '- $MESSAGE')
")
fi

# Prepend new entry to CHANGELOG
if [ -f "$CHANGELOG" ]; then
  python3 -c "
changelog = open('$CHANGELOG').read()
header = '# Changelog\n\n'
if changelog.startswith('# Changelog'):
    rest = changelog[len(header):]
else:
    rest = changelog

new_entry = '''## [$NEW_VERSION] — $TODAY

$MESSAGE

$ENTRY'''

open('$CHANGELOG', 'w').write(header + new_entry.rstrip() + '\n\n' + rest)
print('  Updated: CHANGELOG.md')
"
else
  echo "  WARNING: CHANGELOG.md not found — skipping"
fi

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
