---
description: "Use for any family_kitchen development. Enforces the three-phase git workflow: local development → local verification → remote sync. Ensures local and remote git are always in sync."
applyTo: "**"
---

# Git Workflow for family_kitchen

## Three-Phase Git Workflow

All development work follows this strict three-phase process to keep local and remote repositories synchronized.

### Phase 1: Local Development

**Focus**: Make changes locally, commit early and often.

- Create a feature branch: `git checkout -b feature/your-feature-name`
- Make your code changes in the appropriate directory (`api/`, `mobile_app/`, `infra/`, or docs)
- Commit changes frequently with clear messages:
  ```
  git add .
  git commit -m "API-001: Add inventory CRUD endpoints"
  ```
- Use descriptive commit messages that reference the issue (e.g., `API-001`, `MOB-002`, `INFRA-003`)

### Phase 2: Local Verification

**Focus**: Verify all work is complete and committed before remote sync.

- Check working directory status before ANY remote operation:
  ```
  git status
  ```
- Ensure output shows: `nothing to commit, working tree clean`
- If uncommitted changes exist, commit them first
- Review your commits:
  ```
  git log --oneline -n 5
  ```
- Verify branch is up-to-date with main (if needed):
  ```
  git fetch origin
  git rebase origin/main  # or merge if preferred
  ```

### Phase 3: Remote Sync

**Focus**: Push to remote and create PR only after local verification passes.

- Push your local branch to remote:
  ```
  git push origin feature/your-feature-name
  ```
- Create a Pull Request on GitHub with:
  - Title referencing the issue (e.g., `API-001: Implement inventory CRUD`)
  - Description summarizing changes
  - Link to related issues
  - Any testing instructions or deployment notes

## Critical Sync Rule

**Local and remote git MUST be in sync at all times.**

- ❌ **NEVER** push uncommitted local changes
- ❌ **NEVER** bypass local verification before remote sync
- ❌ **NEVER** force-push without discussion
- ✅ **ALWAYS** commit locally first, verify clean state, then push
- ✅ **ALWAYS** keep main branch updated across team

## Common Commands

```bash
# Check status and verify clean working tree
git status

# Commit changes with reference to issue
git commit -m "API-001: Description of changes"

# Push branch to remote
git push origin feature/your-feature-name

# View recent commits
git log --oneline -n 5

# Update branch with latest main
git fetch origin
git rebase origin/main

# Undo uncommitted changes
git checkout -- path/to/file
```

## Issue Prefix Convention

Use these prefixes in commit messages and issue titles:

- **`API-`**: Backend API and FastAPI development (`api/`)
- **`MOB-`**: Mobile Flutter app development (`mobile_app/`)
- **`INFRA-`**: Cloud infrastructure and Terraform (`infra/`)
- **`TL-`**: Technical lead coordination and planning (cross-team)
- **`DOC-`**: Documentation updates

Example: `API-001: Add inventory CRUD endpoints`

## Team Collaboration

- Always push your work to avoid losing local commits
- Communicate in PR descriptions about blocked or dependent work
- Request reviews from relevant team members before merging
- Address review comments by committing new changes locally, then pushing
- Merge PR only after approval and all CI checks pass

## Emergency Procedures

If you accidentally pushed uncommitted work or need to revert:

1. **Uncommitted changes on feature branch**: Use `git stash` to save, switch branches, then restore
2. **Wrong commit pushed**: Revert with `git revert` (creates new commit), or discuss force-push in PR
3. **Merge conflict**: Resolve locally, commit, and push resolved version

**Always communicate with the team when undoing or rewinding commits.**
