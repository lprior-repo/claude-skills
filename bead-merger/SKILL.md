---
name: kim-aki-land-the-plane
description: Audit all open bead worktrees, merge clean ones into main, delete branches, and archive Discord threads. Use when user asks to "cleanup", "merge", "audit" or "rundown" of open threads.
argument-hint: <none required>
allowed-tools: ["bash", "read", "glob", "grep", "edit", "write", "kimaki_archive_thread", "question"]
model: sonnet
user-invocable: true
context: []
agent: []
hooks: []
---

# Skill: KIM Aki land the plane

This skill audits all open bead worktrees, identifies which ones merge cleanly into main, performs the merge, deletes the branches, and archives the associated Discord threads.

## Activation

Triggered when user says:
- "cleanup" or "clean up"
- "merge" or "merge in"
- "audit" or "rundown"
- "what's open" or "list open threads"
- Any variation combining these terms with "bead", "worktree", "thread", or "branch"

## Workflow

### 1. List All Sessions

Run `kimaki session list --json` to get all open sessions with their thread IDs and directories.

### 2. Identify Branches Ahead of Main

For each worktree branch:
1. Check commits ahead of main: `git log main..<branch> --oneline`
2. If commits exist, test merge: `git merge --no-commit --no-ff main <branch>`
3. If merge succeeds without conflicts, mark as "ready to merge"
4. Abort any test merges: `git merge --abort`

### 3. Merge Clean Branches

For each branch marked "ready to merge":
1. `git fetch origin main`
2. `git merge origin/main <branch> --no-edit`
3. `git push origin main`

### 4. Delete Merged Branches

Delete each successfully merged branch:
`git branch -D <branch>`

### 5. Archive Discord Threads

For each merged bead's thread:
1. Get thread ID from session list
2. Use `kimaki_archive_thread` tool to archive

### 6. Report Results

Present a summary:
- Which beads were merged
- Which had conflicts/weren't ready
- Which threads were archived

## Notes

- Only merge branches that have a clean (conflict-free) merge with main
- Skip branches that are behind main or have conflicts
- Skip branches with uncommitted changes in worktree
- The current session thread should be archived last
