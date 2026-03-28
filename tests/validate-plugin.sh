#!/bin/bash
# ido4shape V1 Plugin Validation Suite
# Tests: structure, format compliance, content quality, internal consistency

PLUGIN_DIR="$(cd "$(dirname "$0")/.." && pwd)"
PASS=0
FAIL=0
WARN=0

pass() { echo "  PASS: $1"; PASS=$((PASS + 1)); }
fail() { echo "  FAIL: $1"; FAIL=$((FAIL + 1)); }
warn() { echo "  WARN: $1"; WARN=$((WARN + 1)); }

echo "========================================="
echo "ido4shape V1 Plugin Validation"
echo "========================================="
echo ""

# ─── TEST 1: Plugin Manifest ───────────────────────────────

echo "--- Test 1: Plugin Manifest ---"

if [ -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ]; then
  pass "plugin.json exists"
else
  fail "plugin.json missing"
fi

# Check plugin.json has required 'name' field
if grep -q '"name"' "$PLUGIN_DIR/.claude-plugin/plugin.json" 2>/dev/null; then
  NAME=$(grep '"name"' "$PLUGIN_DIR/.claude-plugin/plugin.json" | head -1 | sed 's/.*: *"\([^"]*\)".*/\1/')
  if [ "$NAME" = "ido4shape" ]; then
    pass "plugin name is 'ido4shape'"
  else
    fail "plugin name is '$NAME', expected 'ido4shape'"
  fi
else
  fail "plugin.json missing 'name' field"
fi

# Check plugin.json is valid JSON
if python3 -m json.tool "$PLUGIN_DIR/.claude-plugin/plugin.json" > /dev/null 2>&1; then
  pass "plugin.json is valid JSON"
else
  fail "plugin.json is NOT valid JSON"
fi

echo ""

# ─── TEST 2: Directory Structure ───────────────────────────

echo "--- Test 2: Directory Structure ---"

REQUIRED_DIRS=("skills" "agents" "hooks" "references" ".claude-plugin")
for dir in "${REQUIRED_DIRS[@]}"; do
  if [ -d "$PLUGIN_DIR/$dir" ]; then
    pass "directory '$dir' exists"
  else
    fail "directory '$dir' missing"
  fi
done

echo ""

# ─── TEST 3: SKILL.md Files ───────────────────────────────

echo "--- Test 3: SKILL.md Files ---"

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

  # Check 'name' field in frontmatter
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

# ─── TEST 4: Auto-Triggered Skills ────────────────────────

echo "--- Test 4: Auto-Triggered vs User-Invocable ---"

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

# ─── TEST 5: Agent Files ──────────────────────────────────

echo "--- Test 5: Agent Files ---"

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
  if grep -q "^name:" "$agent_file"; then
    pass "$agent_name has name field"
  else
    fail "$agent_name missing name field"
  fi

  if grep -q "^description:" "$agent_file"; then
    pass "$agent_name has description"
  else
    fail "$agent_name missing description"
  fi

  if grep -q "^model:" "$agent_file"; then
    MODEL=$(grep "^model:" "$agent_file" | sed 's/model: *//')
    pass "$agent_name has model: $MODEL"
  else
    warn "$agent_name has no model specified (will inherit)"
  fi
done

echo ""

# ─── TEST 6: Hooks ────────────────────────────────────────

echo "--- Test 6: Hooks ---"

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
if grep -q "PreToolUse" "$HOOKS_FILE" 2>/dev/null; then
  pass "PreToolUse hook defined (phase gate — blocks premature spec writing)"
else
  warn "No PreToolUse hook for phase gate enforcement"
fi

if grep -q "UserPromptSubmit" "$HOOKS_FILE" 2>/dev/null; then
  pass "UserPromptSubmit hook defined (canvas state injection)"
else
  warn "No UserPromptSubmit hook for canvas context injection"
fi

if grep -q "Stop" "$HOOKS_FILE" 2>/dev/null; then
  pass "Stop hook defined (session capture)"
else
  warn "No Stop hook for session capture"
fi

echo ""

# ─── TEST 7: Reference Files ──────────────────────────────

echo "--- Test 7: Reference Files ---"

REF_FILES=(
  "references/soul.md"
  "references/artifact-format-spec.md"
  "references/example-notification-system.md"
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

# ─── TEST 8: Soul.md Quality ──────────────────────────────

echo "--- Test 8: Soul Quality ---"

SOUL="$PLUGIN_DIR/references/soul.md"
if [ -f "$SOUL" ]; then
  SOUL_WORDS=$(wc -w < "$SOUL" | tr -d ' ')
  if [ "$SOUL_WORDS" -gt 500 ]; then
    pass "soul.md is substantive ($SOUL_WORDS words)"
  else
    fail "soul.md is too thin ($SOUL_WORDS words)"
  fi

  # Check for anti-patterns mentioned in VISION.md
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

  # Check for key character traits
  if grep -qi "curious" "$SOUL"; then
    pass "soul.md expresses curiosity"
  else
    warn "soul.md doesn't mention curiosity"
  fi

  if grep -qi "opinion" "$SOUL"; then
    pass "soul.md expresses having opinions"
  else
    warn "soul.md doesn't mention having opinions"
  fi

  if grep -qi "honest" "$SOUL"; then
    pass "soul.md expresses intellectual honesty"
  else
    warn "soul.md doesn't mention honesty"
  fi
fi

echo ""

# ─── TEST 9: Example Artifact Compliance ──────────────────

echo "--- Test 9: Example Artifact Format Compliance ---"

EXAMPLE="$PLUGIN_DIR/references/example-notification-system.md"
if [ -f "$EXAMPLE" ]; then
  # Check project heading
  if head -1 "$EXAMPLE" | grep -qE "^# "; then
    pass "example has project heading"
  else
    fail "example missing project heading"
  fi

  # Check group format
  GROUP_COUNT=$(grep -cE "^## Group:" "$EXAMPLE" || true)
  if [ "$GROUP_COUNT" -gt 0 ]; then
    pass "example has $GROUP_COUNT groups with correct format"
  else
    fail "example has no '## Group:' headings"
  fi

  # Check task format
  TASK_COUNT=$(grep -cE "^### [A-Z]{2,5}-[0-9]{2,3}:" "$EXAMPLE" || true)
  if [ "$TASK_COUNT" -gt 0 ]; then
    pass "example has $TASK_COUNT tasks with correct prefix format"
  else
    fail "example has no tasks matching PREFIX-NN pattern"
  fi

  # Check metadata presence
  META_COUNT=$(grep -cE "^> (effort|risk|type|ai|depends_on|size):" "$EXAMPLE" || true)
  if [ "$META_COUNT" -gt 0 ]; then
    pass "example has $META_COUNT metadata lines"
  else
    fail "example has no metadata lines"
  fi

  # Check success conditions
  SC_COUNT=$(grep -c '\*\*Success conditions:\*\*' "$EXAMPLE" || true)
  if [ "$SC_COUNT" -gt 0 ]; then
    pass "example has $SC_COUNT success conditions sections"
  else
    fail "example missing success conditions"
  fi

  # Check for bad group format (## without Group:)
  BAD_GROUPS=$(grep -cE "^## [^G]" "$EXAMPLE" || true)
  if [ "$BAD_GROUPS" -eq 0 ]; then
    pass "no incorrectly formatted group headings"
  else
    warn "$BAD_GROUPS headings use ## without 'Group:' prefix"
  fi
fi

echo ""

# ─── TEST 10: Cross-References ────────────────────────────

echo "--- Test 10: Internal Cross-References ---"

# Check that skills reference soul.md correctly
SOUL_REFS=$(grep -rl "soul.md" "$PLUGIN_DIR/skills/" 2>/dev/null | wc -l | tr -d ' ')
if [ "$SOUL_REFS" -gt 0 ]; then
  pass "$SOUL_REFS skills reference soul.md"
else
  warn "No skills reference soul.md"
fi

# Check that create-spec references canvas-format
if grep -q "canvas-format" "$PLUGIN_DIR/skills/create-spec/SKILL.md" 2>/dev/null; then
  pass "create-spec references canvas-format"
else
  warn "create-spec doesn't reference canvas-format"
fi

# Check that create-spec references conversation-patterns
if grep -q "conversation-patterns\|conversation-starters" "$PLUGIN_DIR/skills/create-spec/SKILL.md" 2>/dev/null || \
   grep -q "conversation-patterns\|conversation-starters" "$PLUGIN_DIR/skills/creative-decomposition/SKILL.md" 2>/dev/null; then
  pass "conversation patterns referenced from skills"
else
  warn "conversation patterns not referenced"
fi

# Check CLAUDE_SKILL_DIR usage
SKILLDIR_REFS=$(grep -rl 'CLAUDE_SKILL_DIR' "$PLUGIN_DIR/skills/" 2>/dev/null | wc -l | tr -d ' ')
if [ "$SKILLDIR_REFS" -gt 0 ]; then
  pass "$SKILLDIR_REFS skills use \${CLAUDE_SKILL_DIR} for references"
else
  warn "No skills use \${CLAUDE_SKILL_DIR}"
fi

echo ""

# ─── TEST 11: settings.json ───────────────────────────────

echo "--- Test 11: Settings ---"

if [ -f "$PLUGIN_DIR/settings.json" ]; then
  pass "settings.json exists"
  if python3 -m json.tool "$PLUGIN_DIR/settings.json" > /dev/null 2>&1; then
    pass "settings.json is valid JSON"
  else
    fail "settings.json is NOT valid JSON"
  fi
else
  warn "settings.json missing"
fi

echo ""

# ─── TEST 12: Bundled Validator ────────────────────────────

echo "--- Test 12: Bundled Validator ---"

if [ -f "$PLUGIN_DIR/dist/spec-validator.js" ]; then
  pass "Validator bundle exists"
else
  fail "Validator bundle missing (dist/spec-validator.js)"
fi

if [ -f "$PLUGIN_DIR/dist/.spec-format-version" ]; then
  BUNDLE_VERSION=$(cat "$PLUGIN_DIR/dist/.spec-format-version")
  pass "Version marker exists (v$BUNDLE_VERSION)"
else
  fail "Version marker missing (dist/.spec-format-version)"
fi

# Version header check
if [ -f "$PLUGIN_DIR/dist/spec-validator.js" ]; then
  if head -3 "$PLUGIN_DIR/dist/spec-validator.js" | grep -q "@ido4/spec-format v"; then
    pass "Bundle has version header"
  else
    fail "Bundle missing version header"
  fi
fi

# Smoke test (if node available)
if command -v node &>/dev/null && [ -f "$PLUGIN_DIR/dist/spec-validator.js" ]; then
  TEST_SPEC="$PLUGIN_DIR/references/example-strategic-notification-system.md"
  if [ -f "$TEST_SPEC" ]; then
    if node "$PLUGIN_DIR/dist/spec-validator.js" "$TEST_SPEC" >/dev/null 2>&1; then
      pass "Bundle executes successfully"
    else
      fail "Bundle execution failed"
    fi
    # Verify output structure
    RESULT=$(node "$PLUGIN_DIR/dist/spec-validator.js" "$TEST_SPEC" 2>/dev/null)
    if echo "$RESULT" | python3 -c "import sys,json; d=json.load(sys.stdin); assert d.get('valid') is not None" 2>/dev/null; then
      pass "Bundle produces valid JSON output"
    else
      fail "Bundle output is not valid parser JSON"
    fi
  else
    warn "Example spec fixture not found — skipping smoke test"
  fi
else
  warn "node not available — skipping bundle smoke test"
fi

echo ""

# ─── TEST 13: No Obvious Content Issues ───────────────────

echo "--- Test 13: Content Anti-Pattern Scan ---"

# Check for aggressive prompt language (research says it hurts newer Claude models)
AGGRESSIVE=$(grep -rli "CRITICAL!\|YOU MUST\|NEVER EVER\|IMPORTANT:" "$PLUGIN_DIR/skills/" "$PLUGIN_DIR/agents/" 2>/dev/null | wc -l | tr -d ' ')
if [ "$AGGRESSIVE" -eq 0 ]; then
  pass "No aggressive prompt language found"
else
  warn "$AGGRESSIVE files contain potentially aggressive prompt language"
fi

# Check for methodology-specific language in skills (should be agnostic)
METHODOLOGY=$(grep -rli "sprint\|scrum\|shape up\|wave\|kanban" "$PLUGIN_DIR/skills/" 2>/dev/null | wc -l | tr -d ' ')
if [ "$METHODOLOGY" -eq 0 ]; then
  pass "No methodology-specific language in skills"
else
  warn "$METHODOLOGY skills contain methodology-specific language (should be agnostic)"
fi

echo ""

# ─── SUMMARY ──────────────────────────────────────────────

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
