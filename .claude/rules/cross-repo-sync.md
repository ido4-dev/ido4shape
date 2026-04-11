---
paths:
  - ".github/**"
  - "dist/**"
  - "scripts/update-validator*"
  - "scripts/release*"
---

# Cross-Repo Sync: ido4 → ido4shape

The bundled validator (`dist/spec-validator.js`) is built from `@ido4/spec-format` in ido4 and synced automatically.

## Automated Pipeline

```
ido4: scripts/release.sh 0.X.0
  → bumps version, commits, tags v0.X.0, pushes
  → publish.yml triggers (on tag v*)
    → npm run build + build:bundle + test
    → npm publish @ido4/spec-format (bundle included in dist/)
    → repository_dispatch to ido4-dev/ido4shape (event: spec-format-published)
      → ido4shape: update-validator.yml triggers
        → npm pack @ido4/spec-format@0.X.0, extract bundle
        → smoke test against references/example-strategic-notification-system.md
        → create PR (branch: automated/update-spec-validator)
        → CI runs on PR (validate-plugin.sh)
        → auto-merge (squash) if patch/minor, review if major
```

## Infrastructure

- `IDO4SHAPE_DISPATCH_TOKEN` secret in ido4 repo — PAT with `repo` scope for cross-repo dispatch
- `PAT` secret in ido4shape repo — same PAT, enables PR creation that triggers CI
- ido4shape org+repo: "Allow GitHub Actions to create and approve pull requests" enabled
- ido4shape branch protection: required status check = `validate`

## Manual Fallback

```bash
scripts/update-validator.sh 0.7.0                  # from npm
scripts/update-validator.sh ~/dev-projects/ido4 # from local build
```

## See also

- `~/dev-projects/ido4-suite/release-architecture.md` — the canonical 4-layer release pattern that all active ido4 repos follow (the abstract rule). This file is one specific instance of that pattern.
- `~/dev-projects/ido4-suite/cross-repo-connections.md` — the suite-wide connection map: every cross-repo dispatch, secret, PAT, and trust boundary across the ido4 ecosystem.
- `~/dev-projects/ido4-suite/scripts/audit-suite.sh` — runs the canonical-pattern audit against every active ido4 repo. Use it when you change anything in `.github/`, `scripts/release.sh`, `scripts/update-validator*`, or `dist/` to verify the change doesn't introduce a regression.
- `~/dev-projects/ido4/architecture/bundled-validator-architecture.md` — the original architectural spec for the bundled validator design (now implemented). Useful for understanding *why* the current approach was chosen over the previous npm-runtime-install approach.
