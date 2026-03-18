#!/bin/bash
# Generate skill inventory table for README.md
# Reads SKILL.md frontmatter from all skills and produces a markdown table

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

python3 << 'PYSCRIPT'
import os, re, glob

plugin_dir = os.environ.get("PLUGIN_DIR", "PLUGIN_DIR_PLACEHOLDER")
skills_dir = os.path.join(plugin_dir, "skills")
readme_path = os.path.join(plugin_dir, "README.md")

rows = []
for skill_file in sorted(glob.glob(os.path.join(skills_dir, "*/SKILL.md"))):
    content = open(skill_file).read()
    name = os.path.basename(os.path.dirname(skill_file))

    # Extract user-invocable
    m = re.search(r'^user-invocable:\s*(true|false)', content, re.MULTILINE)
    if m and m.group(1) == "false":
        skill_type = "auto-triggered"
    else:
        skill_type = "user-invocable"

    # Extract first sentence of description
    m = re.search(r'^description:\s*>?\s*\n?\s*(.+?)(?:\n[a-zA-Z]|\n---)', content, re.MULTILINE | re.DOTALL)
    if m:
        desc = re.sub(r'\s+', ' ', m.group(1).strip())
        desc = re.split(r'(?<=[.!?])\s', desc)[0]
        # Remove "This skill" prefix for cleaner table
        desc = re.sub(r'^This skill\s+', '', desc)
        desc = desc[0].upper() + desc[1:] if desc else desc
        if len(desc) > 120:
            desc = desc[:117] + "..."
    else:
        desc = ""

    rows.append(f"| `{name}` | {skill_type} | {desc} |")

table = "| Skill | Type | Description |\n|-------|------|-------------|\n" + "\n".join(rows)

# Update README
if os.path.exists(readme_path):
    readme = open(readme_path).read()
    if "BEGIN SKILL INVENTORY" in readme:
        replacement = f"<!-- BEGIN SKILL INVENTORY -->\n## Skills\n\n{table}\n<!-- END SKILL INVENTORY -->"
        result = re.sub(
            r'<!-- BEGIN SKILL INVENTORY -->.*?<!-- END SKILL INVENTORY -->',
            replacement, readme, flags=re.DOTALL
        )
        open(readme_path, 'w').write(result)
        print("README.md skill inventory updated")
    else:
        print("No markers found")
        print(table)
else:
    print(table)
PYSCRIPT
