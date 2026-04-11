#!/bin/bash
# SessionStart hook: create workspace if needed, detect new materials, output canvas state
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Find existing workspace
WORKSPACE=$("$SCRIPT_DIR/find-workspace.sh" 2>/dev/null)

if [ $? -ne 0 ]; then
  # No workspace — find the project directory and create one
  PROJECT_DIR=$("$SCRIPT_DIR/find-project-dir.sh" 2>/dev/null)

  if [ -z "$PROJECT_DIR" ]; then
    exit 0  # Can't determine project directory
  fi

  WORKSPACE="${PROJECT_DIR}.ido4shape"
  mkdir -p "$WORKSPACE/sessions" "$WORKSPACE/sources" 2>/dev/null

  cat > "$WORKSPACE/canvas.md" << 'CANVAS'
# Knowledge Canvas

## Understanding Assessment
- Problem Depth: not started
- Solution Shape: not started
- Boundary Clarity: not started
- Risk Landscape: not started
- Dependency Logic: not started
- Quality Bar: not started

## Problem Understanding

[To be developed through conversation]

## Solution Concepts

[To be developed through conversation]

## Stakeholders

[To be populated as stakeholders contribute — name, role, key perspective]

## Cross-Cutting Concerns

[NFRs, security, performance, accessibility, observability, compliance — captured as they emerge from stakeholder conversations. Not every project has every concern.]

## Constraints & Non-Goals

**Constraints:**
- [To be discovered]

**Non-goals:**
- [To be discovered]

## Open Questions

- [To be discovered]
CANVAS

  cat > "$WORKSPACE/decisions.md" << 'EOF'
# Decisions

_No decisions made yet._
EOF

  cat > "$WORKSPACE/tensions.md" << 'EOF'
# Tensions

_No active tensions._
EOF

  cat > "$WORKSPACE/stakeholders.md" << 'EOF'
# Stakeholders
EOF

  # Sentinel for the Stop hook: marks the moment this Claude session began.
  # Touched AFTER all workspace files so it is strictly newer than them at session start.
  touch "$WORKSPACE/.session-start"

  echo "ido4shape workspace created in project directory."
  echo "Canvas initialized with Understanding Assessment (all dimensions: not started)."
  exit 0
fi

# Existing workspace — refresh the session-start sentinel for the Stop hook.
touch "$WORKSPACE/.session-start"

# === EXISTING WORKSPACE — OUTPUT CONTEXT ===
echo "=== ido4shape session context ==="

if [ -f "$WORKSPACE/canvas.md" ]; then
  echo ""
  echo "Current canvas Understanding Assessment:"
  sed -n '/^## Understanding Assessment/,/^## /{ /^## Understanding Assessment/d; /^## [^U]/d; p; }' "$WORKSPACE/canvas.md" 2>/dev/null
fi

if [ -d "$WORKSPACE/sources" ]; then
  LATEST_SESSION=$(ls -t "$WORKSPACE/sessions/" 2>/dev/null | head -1)
  if [ -n "$LATEST_SESSION" ]; then
    NEW_FILES=$(find "$WORKSPACE/sources/" -type f -newer "$WORKSPACE/sessions/$LATEST_SESSION" 2>/dev/null)
    if [ -n "$NEW_FILES" ]; then
      echo ""
      echo "New source materials added since last session:"
      echo "$NEW_FILES" | while read f; do echo "  - $(basename "$f")"; done
    fi
  fi
fi

if [ -f "$WORKSPACE/stakeholders.md" ]; then
  STAKEHOLDER_COUNT=$(grep -c "^## " "$WORKSPACE/stakeholders.md" 2>/dev/null || true)
  STAKEHOLDER_COUNT=${STAKEHOLDER_COUNT:-0}
  if [ "$STAKEHOLDER_COUNT" -gt 0 ]; then
    echo ""
    echo "Stakeholders who have contributed: $STAKEHOLDER_COUNT"
  fi
fi

if [ -f "$WORKSPACE/tensions.md" ]; then
  TENSION_COUNT=$(grep -c "^- " "$WORKSPACE/tensions.md" 2>/dev/null || true)
  TENSION_COUNT=${TENSION_COUNT:-0}
  if [ "$TENSION_COUNT" -gt 0 ]; then
    echo ""
    echo "Active tensions: $TENSION_COUNT"
  fi
fi
