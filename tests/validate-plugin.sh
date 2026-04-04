#!/bin/bash
# ido4shape Plugin Validation Suite
# Tests: structure, format compliance, content quality, internal consistency, documentation
# Run: bash tests/validate-plugin.sh

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0
FAIL=0
WARN=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }
warn() { echo "  WARN: $1"; WARN=$((WARN + 1)); }

echo "========================================="
echo "ido4shape Plugin Validation"
echo "========================================="
echo ""

# ─── TEST 1: Plugin Manifest ───────────────────────────────

echo "--- Test 1: Plugin Manifest ---"

PLUGIN_JSON="$PLUGIN_DIR/.claude-plugin/plugin.json"

if [ -f "$PLUGIN_JSON" ]; then
  pass "plugin.json exists"
else
  fail "plugin.json missing"
fi

if python3 -m json.tool "$PLUGIN_JSON" > /dev/null 2>&1; then
  pass "plugin.json is valid JSON"
else
  fail "plugin.json is NOT valid JSON"
fi

# Required fields
for field in name description version repository license; do
  if python3 -c "import json; d=json.load(open('$PLUGIN_JSON')); assert '$field' in d" 2>/dev/null; then
    pass "plugin.json has '$field' field"
  else
    fail "plugin.json missing '$field' field"
  fi
done

# Name check
NAME=$(python3 -c "import json; print(json.load(open('$PLUGIN_JSON'))['name'])" 2>/dev/null)
if [ "$NAME" = "ido4shape" ]; then
  pass "plugin name is 'ido4shape'"
else
  fail "plugin name is '$NAME', expected 'ido4shape'"
fi

# Repository URL check (must point to ido4-dev org)
REPO_URL=$(python3 -c "import json; print(json.load(open('$PLUGIN_JSON'))['repository'])" 2>/dev/null)
if echo "$REPO_URL" | grep -q "ido4-dev/ido4shape"; then
  pass "repository URL points to ido4-dev org"
else
  fail "repository URL '$REPO_URL' should point to ido4-dev/ido4shape"
fi

# Optional but recommended fields
for field in category homepage keywords; do
  if python3 -c "import json; d=json.load(open('$PLUGIN_JSON')); assert '$field' in d" 2>/dev/null; then
    pass "plugin.json has '$field' field"
  else
    warn "plugin.json missing recommended '$field' field"
  fi
done

# Keywords should include searchable terms
if python3 -c "
import json
kw = json.load(open('$PLUGIN_JSON')).get('keywords', [])
assert any(k in kw for k in ['specification', 'spec-writing', 'product-requirements'])
" 2>/dev/null; then
  pass "keywords include searchable terms"
else
  warn "keywords may lack searchable terms (specification, spec-writing, product-requirements)"
fi

echo ""

# ─── TEST 2: Directory Structure ───────────────────────────

echo "--- Test 2: Directory Structure ---"

REQUIRED_DIRS=("skills" "agents" "hooks" "references" "dist" "scripts" ".claude-plugin")
for dir in "${REQUIRED_DIRS[@]}"; do
  if [ -d "$PLUGIN_DIR/$dir" ]; then
    pass "directory '$dir' exists"
  else
    fail "directory '$dir' missing"
  fi
done

echo ""

# ─── TEST 3: Documentation Files ─────────────────────────

echo "--- Test 3: Documentation Files ---"

for doc in README.md SECURITY.md CHANGELOG.md LICENSE; do
  if [ -f "$PLUGIN_DIR/$doc" ]; then
    pass "$doc exists"
  else
    fail "$doc missing"
  fi
done

# Documentation in docs/
for doc in DEVELOPER.md VISION.md; do
  if [ -f "$PLUGIN_DIR/docs/$doc" ]; then
    pass "docs/$doc exists"
  else
    fail "docs/$doc missing"
  fi
done

# README should mention Cowork
if grep -qi "cowork" "$PLUGIN_DIR/README.md" 2>/dev/null; then
  pass "README mentions Cowork"
else
  warn "README doesn't mention Cowork (primary target platform)"
fi

# README should have example workflows
if grep -q "Example Workflow" "$PLUGIN_DIR/README.md" 2>/dev/null; then
  pass "README has example workflows"
else
  warn "README missing example workflows"
fi

# README should have Getting Started
if grep -q "Getting Started" "$PLUGIN_DIR/README.md" 2>/dev/null; then
  pass "README has Getting Started section"
else
  warn "README missing Getting Started section"
fi

# CHANGELOG should have current version
CURRENT_VERSION=$(python3 -c "import json; print(json.load(open('$PLUGIN_JSON'))['version'])" 2>/dev/null)
if grep -q "\[$CURRENT_VERSION\]" "$PLUGIN_DIR/CHANGELOG.md" 2>/dev/null; then
  pass "CHANGELOG includes current version ($CURRENT_VERSION)"
else
  warn "CHANGELOG missing entry for current version ($CURRENT_VERSION)"
fi

echo ""

# ─── TEST 4: SKILL.md Files ─────────────────────────────

echo "--- Test 4: SKILL.md Files ---"

SKILL_DIRS=(
  "skills/create-spec"
  "skills/refine-spec"
  "skills/validate-spec"
  "skills/synthesize-spec"
  "skills/artifact-format"
  "skills/creative-decomposition"
  "skills/dependency-analysis"
  "skills/quality-guidance"
  "skills/stakeholder-brief"
  "skills/review-spec"
)

for skill_dir in "${SKILL_DIRS[@]}"; do
  skill_name=$(basename "$skill_dir")
  skill_file="$PLUGIN_DIR/$skill_dir/SKILL.md"

  if [ -f "$skill_file" ]; then
    pass "$skill_name/SKILL.md exists"
  else
    fail "$skill_name/SKILL.md missing"
    continue
  fi

  # Check YAML frontmatter exists (starts with ---)
  if head -1 "$skill_file" | grep -q "^---$"; then
    pass "$skill_name has YAML frontmatter"
  else
    fail "$skill_name missing YAML frontmatter"
  fi

  # Check 'name' field in frontmatter matches directory
  if grep -q "^name:" "$skill_file"; then
    SNAME=$(grep "^name:" "$skill_file" | head -1 | sed 's/name: *//')
    if [ "$SNAME" = "$skill_name" ]; then
      pass "$skill_name: name field matches directory"
    else
      fail "$skill_name: name field '$SNAME' doesn't match directory name '$skill_name'"
    fi
  else
    fail "$skill_name missing 'name' field in frontmatter"
  fi

  # Check 'description' field
  if grep -q "^description:" "$skill_file"; then
    pass "$skill_name has description"
  else
    fail "$skill_name missing description"
  fi

  # Check word count (target 1500-2000, warn if outside)
  WORDS=$(wc -w < "$skill_file" | tr -d ' ')
  if [ "$WORDS" -lt 100 ]; then
    fail "$skill_name body too short ($WORDS words)"
  elif [ "$WORDS" -gt 3000 ]; then
    warn "$skill_name body may be too long ($WORDS words, target <2000)"
  else
    pass "$skill_name word count OK ($WORDS words)"
  fi
done

echo ""

# ─── TEST 5: Skill Reference Files ──────────────────────

echo "--- Test 5: Skill Reference Files ---"

# Check that skills referencing ${CLAUDE_SKILL_DIR}/references/ have those files
for skill_dir in "${SKILL_DIRS[@]}"; do
  skill_name=$(basename "$skill_dir")
  skill_file="$PLUGIN_DIR/$skill_dir/SKILL.md"
  [ -f "$skill_file" ] || continue

  # Extract referenced filenames from ${CLAUDE_SKILL_DIR}/references/
  REFS=$(grep -oE '\$\{CLAUDE_SKILL_DIR\}/references/[a-zA-Z0-9_-]+\.md' "$skill_file" 2>/dev/null | sed 's|.*references/||')
  for ref in $REFS; do
    if [ -f "$PLUGIN_DIR/$skill_dir/references/$ref" ]; then
      pass "$skill_name references/$ref exists"
    else
      fail "$skill_name references/$ref missing (referenced in SKILL.md)"
    fi
  done
done

echo ""

# ─── TEST 6: Auto-Triggered vs User-Invocable ───────────

echo "--- Test 6: Auto-Triggered vs User-Invocable ---"

AUTO_TRIGGERED=("artifact-format" "creative-decomposition" "dependency-analysis" "quality-guidance")
USER_INVOCABLE=("create-spec" "refine-spec" "validate-spec" "synthesize-spec" "stakeholder-brief" "review-spec")

for skill in "${AUTO_TRIGGERED[@]}"; do
  skill_file="$PLUGIN_DIR/skills/$skill/SKILL.md"
  if grep -q "user-invocable: false" "$skill_file" 2>/dev/null; then
    pass "$skill is auto-triggered (user-invocable: false)"
  else
    fail "$skill should be auto-triggered but lacks 'user-invocable: false'"
  fi
done

for skill in "${USER_INVOCABLE[@]}"; do
  skill_file="$PLUGIN_DIR/skills/$skill/SKILL.md"
  if grep -q "user-invocable: false" "$skill_file" 2>/dev/null; then
    fail "$skill is marked auto-triggered but should be user-invocable"
  else
    pass "$skill is user-invocable (default)"
  fi
done

echo ""

# ─── TEST 7: Agent Files ────────────────────────────────

echo "--- Test 7: Agent Files ---"

AGENTS=("spec-reviewer.md" "canvas-synthesizer.md" "technical-reviewer.md" "scope-reviewer.md" "dependency-auditor.md")
for agent in "${AGENTS[@]}"; do
  agent_file="$PLUGIN_DIR/agents/$agent"
  agent_name=$(basename "$agent" .md)

  if [ -f "$agent_file" ]; then
    pass "$agent_name agent exists"
  else
    fail "$agent_name agent missing"
    continue
  fi

  # Check frontmatter
  if head -1 "$agent_file" | grep -q "^---$"; then
    pass "$agent_name has YAML frontmatter"
  else
    fail "$agent_name missing YAML frontmatter"
  fi

  # Check required fields
  for field in name description model tools; do
    if grep -q "^${field}:" "$agent_file"; then
      pass "$agent_name has $field field"
    else
      if [ "$field" = "tools" ]; then
        warn "$agent_name missing $field field"
      else
        fail "$agent_name missing $field field"
      fi
    fi
  done

  # Verify no agent has Bash access (security claim in SECURITY.md)
  if grep -q "^tools:.*Bash" "$agent_file" 2>/dev/null; then
    fail "$agent_name has Bash access (violates SECURITY.md claim)"
  else
    pass "$agent_name has no Bash access"
  fi
done

# Check review-spec references spec-reviewer
if grep -q "spec-reviewer" "$PLUGIN_DIR/skills/review-spec/SKILL.md" 2>/dev/null; then
  pass "review-spec references spec-reviewer agent"
else
  fail "review-spec doesn't reference spec-reviewer agent"
fi

echo ""

# ─── TEST 8: Hooks & Hook Scripts ────────────────────────

echo "--- Test 8: Hooks & Hook Scripts ---"

HOOKS_FILE="$PLUGIN_DIR/hooks/hooks.json"
if [ -f "$HOOKS_FILE" ]; then
  pass "hooks.json exists"
else
  fail "hooks.json missing"
fi

if python3 -m json.tool "$HOOKS_FILE" > /dev/null 2>&1; then
  pass "hooks.json is valid JSON"
else
  fail "hooks.json is NOT valid JSON"
fi

# Check for expected hook events
for event in PreToolUse UserPromptSubmit Stop PreCompact SessionStart; do
  if grep -q "$event" "$HOOKS_FILE" 2>/dev/null; then
    pass "$event hook defined"
  else
    warn "No $event hook defined"
  fi
done

# Verify all referenced scripts exist
SCRIPTS=$(grep -oE '\$\{CLAUDE_PLUGIN_ROOT\}/scripts/[a-zA-Z0-9_-]+\.sh' "$HOOKS_FILE" 2>/dev/null | sed 's|.*scripts/||' | sort -u)
for script in $SCRIPTS; do
  if [ -f "$PLUGIN_DIR/scripts/$script" ]; then
    pass "hook script scripts/$script exists"
  else
    fail "hook script scripts/$script missing (referenced in hooks.json)"
  fi
done

# Verify no hook script makes network requests
for script in $SCRIPTS; do
  script_path="$PLUGIN_DIR/scripts/$script"
  [ -f "$script_path" ] || continue
  if grep -qE "curl |wget |fetch |https?://" "$script_path" 2>/dev/null; then
    fail "scripts/$script contains network calls (violates SECURITY.md)"
  else
    pass "scripts/$script makes no network requests"
  fi
done

echo ""

# ─── TEST 9: Reference Files ────────────────────────────

echo "--- Test 9: Reference Files ---"

REF_FILES=(
  "references/soul.md"
  "references/artifact-format-spec.md"
  "references/strategic-spec-format.md"
  "references/stakeholder-profiles.md"
  "references/example-notification-system.md"
  "references/example-strategic-notification-system.md"
  "references/methodology-mapping.md"
  "references/project-templates/api-service.md"
  "references/project-templates/mobile-app.md"
  "references/project-templates/platform-feature.md"
  "references/project-templates/data-pipeline.md"
)

for ref in "${REF_FILES[@]}"; do
  if [ -f "$PLUGIN_DIR/$ref" ]; then
    pass "$(basename $ref) exists"
  else
    fail "$(basename $ref) missing"
  fi
done

echo ""

# ─── TEST 10: Soul.md Quality ───────────────────────────

echo "--- Test 10: Soul Quality ---"

SOUL="$PLUGIN_DIR/references/soul.md"
if [ -f "$SOUL" ]; then
  SOUL_WORDS=$(wc -w < "$SOUL" | tr -d ' ')
  if [ "$SOUL_WORDS" -gt 500 ]; then
    pass "soul.md is substantive ($SOUL_WORDS words)"
  else
    fail "soul.md is too thin ($SOUL_WORDS words)"
  fi

  # Anti-patterns
  if grep -qi "great question" "$SOUL"; then
    fail "soul.md contains 'great question' (anti-pattern)"
  else
    pass "soul.md avoids 'great question' anti-pattern"
  fi

  if grep -qi "let me help you" "$SOUL"; then
    fail "soul.md contains 'let me help you' (anti-pattern)"
  else
    pass "soul.md avoids 'let me help you' anti-pattern"
  fi

  # Key character traits
  for trait in curious opinion honest; do
    if grep -qi "$trait" "$SOUL"; then
      pass "soul.md expresses $trait"
    else
      warn "soul.md doesn't mention $trait"
    fi
  done
fi

echo ""

# ─── TEST 11: Strategic Spec Example Compliance ─────────

echo "--- Test 11: Strategic Spec Example Compliance ---"

EXAMPLE="$PLUGIN_DIR/references/example-strategic-notification-system.md"
if [ -f "$EXAMPLE" ]; then
  # Format identifier
  if grep -q "format: strategic-spec" "$EXAMPLE"; then
    pass "example has strategic-spec format identifier"
  else
    fail "example missing 'format: strategic-spec' identifier"
  fi

  # Project heading
  if head -1 "$EXAMPLE" | grep -qE "^# "; then
    pass "example has project heading"
  else
    fail "example missing project heading"
  fi

  # Group format
  GROUP_COUNT=$(grep -cE "^## Group:" "$EXAMPLE" || true)
  if [ "$GROUP_COUNT" -gt 0 ]; then
    pass "example has $GROUP_COUNT groups with correct format"
  else
    fail "example has no '## Group:' headings"
  fi

  # Capability format (PREFIX-NN with 2-5 char prefix)
  CAP_COUNT=$(grep -cE "^### [A-Z]{2,5}-[0-9]{2,3}:" "$EXAMPLE" || true)
  if [ "$CAP_COUNT" -gt 0 ]; then
    pass "example has $CAP_COUNT capabilities with correct prefix format"
  else
    fail "example has no capabilities matching PREFIX-NN pattern"
  fi

  # Strategic metadata (priority, risk, depends_on)
  for key in priority risk depends_on; do
    if grep -qE "^> .*${key}:" "$EXAMPLE"; then
      pass "example has '$key' metadata"
    else
      fail "example missing '$key' metadata"
    fi
  done

  # Must NOT have implementation-level metadata
  for key in effort type "^> .*ai:" size; do
    if grep -qE "$key" "$EXAMPLE" 2>/dev/null | grep -qE "^> " 2>/dev/null; then
      # More precise: check metadata lines only
      :
    fi
  done
  IMPL_META=$(grep -cE "^> .*(effort:|type:|ai:|size:)" "$EXAMPLE" 2>/dev/null || true)
  if [ "$IMPL_META" -eq 0 ]; then
    pass "example has no implementation-level metadata (correct for strategic spec)"
  else
    fail "example contains implementation-level metadata ($IMPL_META lines) — should be strategic only"
  fi

  # Success conditions
  SC_COUNT=$(grep -c '\*\*Success conditions:\*\*' "$EXAMPLE" || true)
  if [ "$SC_COUNT" -gt 0 ]; then
    pass "example has $SC_COUNT success conditions sections"
  else
    fail "example missing success conditions"
  fi

  # Stakeholders section
  if grep -qi "stakeholder" "$EXAMPLE"; then
    pass "example has stakeholder content"
  else
    warn "example may lack stakeholder attribution"
  fi

  # Cross-cutting concerns
  if grep -q "Cross-Cutting Concerns" "$EXAMPLE"; then
    pass "example has Cross-Cutting Concerns section"
  else
    warn "example missing Cross-Cutting Concerns section"
  fi
fi

echo ""

# ─── TEST 12: Technical Spec Example (Reference) ────────

echo "--- Test 12: Technical Spec Example (Reference) ---"

TECH_EXAMPLE="$PLUGIN_DIR/references/example-notification-system.md"
if [ -f "$TECH_EXAMPLE" ]; then
  pass "technical spec example exists (reference only)"

  # This IS the technical spec — it SHOULD have implementation metadata
  if grep -qE "^> .*effort:" "$TECH_EXAMPLE"; then
    pass "technical example has effort metadata (correct for technical spec)"
  else
    warn "technical example missing effort metadata"
  fi
else
  warn "technical spec example not found"
fi

echo ""

# ─── TEST 13: Internal Cross-References ─────────────────

echo "--- Test 13: Internal Cross-References ---"

# Skills referencing soul.md
SOUL_REFS=$(grep -rl "soul.md" "$PLUGIN_DIR/skills/" 2>/dev/null | wc -l | tr -d ' ')
if [ "$SOUL_REFS" -gt 0 ]; then
  pass "$SOUL_REFS skills reference soul.md"
else
  warn "No skills reference soul.md"
fi

# create-spec references canvas-format
if grep -q "canvas-format" "$PLUGIN_DIR/skills/create-spec/SKILL.md" 2>/dev/null; then
  pass "create-spec references canvas-format"
else
  warn "create-spec doesn't reference canvas-format"
fi

# Conversation patterns referenced
if grep -q "conversation-patterns\|conversation-starters" "$PLUGIN_DIR/skills/create-spec/SKILL.md" 2>/dev/null || \
   grep -q "conversation-patterns\|conversation-starters" "$PLUGIN_DIR/skills/creative-decomposition/SKILL.md" 2>/dev/null; then
  pass "conversation patterns referenced from skills"
else
  warn "conversation patterns not referenced"
fi

# CLAUDE_SKILL_DIR usage
SKILLDIR_REFS=$(grep -rl 'CLAUDE_SKILL_DIR' "$PLUGIN_DIR/skills/" 2>/dev/null | wc -l | tr -d ' ')
if [ "$SKILLDIR_REFS" -gt 0 ]; then
  pass "$SKILLDIR_REFS skills use \${CLAUDE_SKILL_DIR} for references"
else
  warn "No skills use \${CLAUDE_SKILL_DIR}"
fi

echo ""

# ─── TEST 14: Settings ──────────────────────────────────

echo "--- Test 14: Settings ---"

if [ -f "$PLUGIN_DIR/settings.json" ]; then
  pass "settings.json exists"
  if python3 -m json.tool "$PLUGIN_DIR/settings.json" > /dev/null 2>&1; then
    pass "settings.json is valid JSON"
  else
    fail "settings.json is NOT valid JSON"
  fi

  # Check required permissions
  for perm in Read Write Edit Glob Grep Bash Agent; do
    if grep -q "\"$perm\"" "$PLUGIN_DIR/settings.json" 2>/dev/null; then
      pass "permission '$perm' declared"
    else
      fail "permission '$perm' missing from settings.json"
    fi
  done
else
  fail "settings.json missing"
fi

echo ""

# ─── TEST 15: Bundled Validator ─────────────────────────

echo "--- Test 15: Bundled Validator ---"

BUNDLE="$PLUGIN_DIR/dist/spec-validator.js"
VERSION_MARKER="$PLUGIN_DIR/dist/.spec-format-version"
CHECKSUM_FILE="$PLUGIN_DIR/dist/.spec-format-checksum"

if [ -f "$BUNDLE" ]; then
  pass "validator bundle exists"
else
  fail "validator bundle missing (dist/spec-validator.js)"
fi

if [ -f "$VERSION_MARKER" ]; then
  BUNDLE_VERSION=$(cat "$VERSION_MARKER")
  pass "version marker exists (v$BUNDLE_VERSION)"
else
  fail "version marker missing (dist/.spec-format-version)"
fi

# Version header
if [ -f "$BUNDLE" ]; then
  if head -3 "$BUNDLE" | grep -q "@ido4/spec-format v"; then
    pass "bundle has version header"
  else
    fail "bundle missing version header"
  fi
fi

# Checksum file
if [ -f "$CHECKSUM_FILE" ]; then
  pass "checksum file exists"
  # Verify checksum matches actual bundle
  if [ -f "$BUNDLE" ]; then
    EXPECTED=$(cat "$CHECKSUM_FILE" | awk '{print $1}')
    ACTUAL=$(shasum -a 256 "$BUNDLE" | awk '{print $1}')
    if [ "$EXPECTED" = "$ACTUAL" ]; then
      pass "checksum matches bundle (SHA-256 verified)"
    else
      fail "checksum MISMATCH — expected $EXPECTED, got $ACTUAL"
    fi
  fi
else
  warn "checksum file missing (dist/.spec-format-checksum)"
fi

# Smoke test (if node available)
if command -v node &>/dev/null && [ -f "$BUNDLE" ]; then
  TEST_SPEC="$PLUGIN_DIR/references/example-strategic-notification-system.md"
  if [ -f "$TEST_SPEC" ]; then
    if node "$BUNDLE" "$TEST_SPEC" >/dev/null 2>&1; then
      pass "bundle executes successfully"
    else
      fail "bundle execution failed"
    fi
    # Verify output structure
    RESULT=$(node "$BUNDLE" "$TEST_SPEC" 2>/dev/null)
    if echo "$RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); assert d.get('valid') is not None" 2>/dev/null; then
      pass "bundle produces valid JSON output"
    else
      fail "bundle output is not valid parser JSON"
    fi
    # Verify example passes validation
    if echo "$RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); assert d['valid'] == True" 2>/dev/null; then
      pass "strategic spec example passes validation"
    else
      warn "strategic spec example does not pass validation"
    fi
  else
    warn "strategic spec example not found — skipping smoke test"
  fi
else
  warn "node not available — skipping bundle smoke test"
fi

echo ""

# ─── TEST 16: .gitignore ────────────────────────────────

echo "--- Test 16: Git Configuration ---"

if [ -f "$PLUGIN_DIR/.gitignore" ]; then
  pass ".gitignore exists"
  if grep -q "\.ido4shape/" "$PLUGIN_DIR/.gitignore"; then
    pass ".gitignore excludes .ido4shape/"
  else
    fail ".gitignore missing .ido4shape/ (workspace should not be committed)"
  fi
else
  warn ".gitignore missing"
fi

echo ""

# ─── TEST 17: Content Anti-Pattern Scan ─────────────────

echo "--- Test 17: Content Anti-Pattern Scan ---"

# Aggressive prompt language
AGGRESSIVE=$(grep -rli "CRITICAL!\|YOU MUST\|NEVER EVER\|IMPORTANT:" "$PLUGIN_DIR/skills/" "$PLUGIN_DIR/agents/" 2>/dev/null | wc -l | tr -d ' ')
if [ "$AGGRESSIVE" -eq 0 ]; then
  pass "No aggressive prompt language found"
else
  warn "$AGGRESSIVE files contain potentially aggressive prompt language"
fi

# Methodology-specific language in skills
METHODOLOGY=$(grep -rli "sprint\|scrum\|shape up\|wave\|kanban" "$PLUGIN_DIR/skills/" 2>/dev/null | wc -l | tr -d ' ')
if [ "$METHODOLOGY" -eq 0 ]; then
  pass "No methodology-specific language in skills"
else
  warn "$METHODOLOGY skills contain methodology-specific language (should be agnostic)"
fi

# Implementation-level metadata in skills (should reference strategic spec only)
IMPL_IN_SKILLS=$(grep -rlE "effort: [SMLX]|type: feature|ai: full|ai: assisted" "$PLUGIN_DIR/skills/" 2>/dev/null | wc -l | tr -d ' ')
if [ "$IMPL_IN_SKILLS" -eq 0 ]; then
  pass "No implementation-level metadata examples in skills"
else
  warn "$IMPL_IN_SKILLS skills contain implementation-level metadata references"
fi

echo ""

# ─── TEST 18: Security Claims Verification ──────────────

echo "--- Test 18: Security Claims ---"

# Verify SECURITY.md sub-agent tools match actual agent files
if [ -f "$PLUGIN_DIR/SECURITY.md" ]; then
  # canvas-synthesizer should have Read, Write, Glob (no Bash, no Edit)
  CS_TOOLS=$(grep "^tools:" "$PLUGIN_DIR/agents/canvas-synthesizer.md" 2>/dev/null | head -1)
  if echo "$CS_TOOLS" | grep -q "Bash"; then
    fail "canvas-synthesizer has Bash access (security violation)"
  else
    pass "canvas-synthesizer has no Bash access"
  fi

  # No agent should have network-capable tools
  for agent_file in "$PLUGIN_DIR/agents/"*.md; do
    agent_name=$(basename "$agent_file" .md)
    if grep -q "^tools:.*WebFetch\|^tools:.*WebSearch" "$agent_file" 2>/dev/null; then
      fail "$agent_name has network-capable tools"
    fi
  done
  pass "no agents have network-capable tools"
fi

echo ""

# ─── SUMMARY ────────────────────────────────────────────

echo "========================================="
echo "RESULTS: $PASS passed, $FAIL failed, $WARN warnings"
echo "========================================="

if [ "$FAIL" -gt 0 ]; then
  echo "STATUS: FAIL — $FAIL issues must be fixed"
  exit 1
else
  echo "STATUS: PASS"
  exit 0
fi
