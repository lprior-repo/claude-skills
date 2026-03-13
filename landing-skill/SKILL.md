---
name: landing-skill
description: "Session completion enforcer for JJ workflows - validates quality, syncs main, closes bead, and cleans workspace."
allowed-tools: ["bash", "glob", "grep", "read", "write", "edit", "task"]
---

# Landing the Plane Skill (JJ-Only)

This workflow is mandatory before ending a session.

Core rules:
- Use `jj` and `bd` only for workflow lifecycle.
- Use `jj` commands only for VCS operations; do not run raw `git` commands.
- Keep `main` clean: tests/lint/build must pass.
- Every unresolved issue must be filed as a bead.
- No local-only work.
- No orphan workspaces, bookmarks, or stale bead directories for closed beads.

## Step 1: Audit Current State

```bash
# JJ and repository state
jj status
jj log -r 'mine()'
jj workspace list
jj bookmark list

# Bead state
bd ready
bd list --status in_progress

# JJ-level safety checks
jj op log -n 5
```

Decide for each open line of work:
- Complete now and land
- Keep in progress with bead notes updated
- Abandon with explicit bead context

## Step 2: File Beads for Unfinished/Failing Work

For any unresolved failure or deferred work, create/update bead records:

```bash
bd create "[smell-type] brief description" --type task --priority 2
bd update <bead-id> --description "<context>" --acceptance "<criteria>"
bd lint <bead-id>
```

## Step 3: Quality Gates (Repo Tooling)

Use repo-standard gates (prefer Moon when configured):

```bash
# Primary (Moon projects)
moon run :quick
moon run :test
moon run :ci

# If repo does not use Moon, run project-native equivalents
# (npm test/lint/build, pytest/ruff/mypy, etc.)
```

Rules:
- New failures introduced in this session must be fixed now.
- Pre-existing failures may proceed only if tracked by bead with evidence.

## Step 4: Rebase and Land on Main

```bash
jj git fetch
jj rebase -d main@origin

# Ensure current changes are intentional
jj diff
jj log -r 'main..@'
```

If you use bookmarks for push:

```bash
jj bookmark list
jj bookmark set <bookmark-name> -r @
jj git push --bookmark <bookmark-name> --allow-new
```

If pushing main directly in your repo convention:

```bash
jj git push --bookmark main
```

## Step 5: Verify Main + Remote

```bash
jj git fetch
jj log -r main
jj git push --dry-run
jj status
```

Pass criteria:
- Main includes the landed change.
- Remote is up to date.
- Working copy is clean or intentionally in-progress with bead notes.

## Step 6: Close or Update Beads

```bash
# Completed
bd close <bead-id> --reason "Completed and landed on main"

# In progress
bd update <bead-id> --status in_progress --notes "<current state>"

# Sync bead view
bd sync
bd ready
```

## Step 7: Cleanup JJ Workspace and Directories

For bead-linked workspaces named with bead id (e.g., `bd-354`):

```bash
# 1) Confirm bead closed and landed
bd show <bead-id>
jj log -r main

# 2) Remove JJ workspace entry if present
jj workspace list | grep "<bead-id>"
jj workspace forget "<bead-id>"

# 3) Remove bead bookmark if used
jj bookmark list | grep "<bead-id>"
jj bookmark delete "<bead-id>" 2>/dev/null

# 4) Remove physical workspace directory
rm -rf "../<bead-id>"

# 5) Optional local artifact cleanup
rm -rf ".beads/<bead-id>"
```

Required cleanup proof:
- bead_closed_via_br
- change_in_main
- remote_up_to_date
- jj_workspace_removed
- workspace_directory_removed

## Step 8: Final Handoff Report

Provide a concise handoff with:
- completed work and bead ids
- quality gate outcomes
- remaining beads and blockers
- confirmation of push and cleanup

---

Anti-patterns (forbidden):
- Ending session without push
- Closing bead before validation/landing
- Leaving closed-bead workspace directories
- Claiming pass without command evidence

**Landing Skill Version**: 3.0.0
**Last Updated**: February 2026
**Status**: JJ-only production baseline
