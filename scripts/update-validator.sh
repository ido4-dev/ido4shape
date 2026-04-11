#!/bin/bash
# Update the bundled spec-format validator from npm or a local ido4 build.
#
# Usage:
#   ./scripts/update-validator.sh 0.7.0              # Fetch from npm
#   ./scripts/update-validator.sh ~/dev/ido4          # Copy from local build
#
# The bundle is a single self-contained .js file (~8KB) with zero npm dependencies.
# See: architecture/bundled-validator-architecture.md (in ido4 repo)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(dirname "$SCRIPT_DIR")"
DIST_DIR="$PLUGIN_DIR/dist"
BUNDLE_FILE="$DIST_DIR/spec-validator.js"
VERSION_FILE="$DIST_DIR/.spec-format-version"

usage() {
  echo "Usage: $0 <version|path-to-ido4>"
  echo ""
  echo "Examples:"
  echo "  $0 0.7.0              # Fetch from npm, extract bundle"
  echo "  $0 ~/dev/ido4         # Copy from local build"
  exit 1
}

[ $# -eq 1 ] || usage

SOURCE="$1"
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

mkdir -p "$DIST_DIR"

if [ -d "$SOURCE" ]; then
  # Local path: copy pre-built bundle
  LOCAL_BUNDLE="$SOURCE/packages/spec-format/dist/spec-validator.bundle.js"
  if [ ! -f "$LOCAL_BUNDLE" ]; then
    echo "ERROR: Bundle not found at $LOCAL_BUNDLE"
    echo "Run 'npm run build:bundle -w @ido4/spec-format' in $SOURCE first"
    exit 1
  fi
  cp "$LOCAL_BUNDLE" "$BUNDLE_FILE"
  # Extract version from header comment: // @ido4/spec-format v0.6.0 | ...
  VERSION=$(head -3 "$BUNDLE_FILE" | grep -o 'v[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*' | head -1 | sed 's/^v//' || echo "unknown")
  echo "Copied bundle from local build (v$VERSION)"
else
  # npm version: fetch package, extract bundle
  VERSION="$SOURCE"
  echo "Fetching @ido4/spec-format@$VERSION from npm..."
  cd "$TMPDIR"
  npm pack "@ido4/spec-format@$VERSION" --silent 2>&1
  tar xzf ido4-spec-format-*.tgz

  if [ -f "package/dist/spec-validator.bundle.js" ]; then
    cp "package/dist/spec-validator.bundle.js" "$BUNDLE_FILE"
    echo "Extracted bundle from npm package"
  else
    # Bundle not in npm package — build it locally
    echo "Bundle not in npm package. Building from extracted source..."
    if ! command -v npx &>/dev/null; then
      echo "ERROR: npx not found. Install Node.js or use a local ido4 build instead."
      exit 1
    fi
    cd package
    npx esbuild src/cli.ts --bundle --platform=node --target=node18 \
      --format=cjs --outfile="$BUNDLE_FILE" --minify \
      --banner:js="// @ido4/spec-format v$VERSION | bundled $(date +%Y-%m-%d)"
    echo "Built bundle from source"
  fi
fi

# Smoke test: run against the example strategic spec
TEST_SPEC="$PLUGIN_DIR/references/example-strategic-notification-system.md"
if [ -f "$TEST_SPEC" ]; then
  echo "Smoke testing bundle..."
  RESULT=$(node "$BUNDLE_FILE" "$TEST_SPEC" 2>&1) || {
    echo "ERROR: Bundle smoke test failed"
    echo "$RESULT"
    rm -f "$BUNDLE_FILE"
    exit 1
  }
  # Verify output is JSON with expected structure
  echo "$RESULT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    assert 'valid' in d, 'missing valid field'
    assert 'meta' in d, 'missing meta field'
    assert 'metrics' in d, 'missing metrics field'
    print(f'  Result: valid={d[\"valid\"]}, groups={d[\"metrics\"][\"groupCount\"]}, caps={d[\"metrics\"][\"capabilityCount\"]}')
except Exception as e:
    print(f'ERROR: Invalid parser output — {e}', file=sys.stderr)
    sys.exit(1)
" || {
    echo "ERROR: Bundle output is not valid parser JSON"
    rm -f "$BUNDLE_FILE"
    exit 1
  }
  echo "Smoke test passed."
else
  echo "WARNING: No test fixture found at $TEST_SPEC — skipping smoke test"
fi

# Write version marker
echo "$VERSION" > "$VERSION_FILE"

# Write checksum
CHECKSUM_FILE="$DIST_DIR/.spec-format-checksum"
shasum -a 256 "$BUNDLE_FILE" | sed "s|$DIST_DIR/||" > "$CHECKSUM_FILE"
echo "Wrote checksum to $CHECKSUM_FILE"

SIZE=$(wc -c < "$BUNDLE_FILE" | tr -d ' ')
echo ""
echo "Updated spec-validator.js to v$VERSION"
echo "  Bundle: $BUNDLE_FILE ($SIZE bytes)"
echo "  Version: $VERSION_FILE"
echo "  Checksum: $CHECKSUM_FILE"
