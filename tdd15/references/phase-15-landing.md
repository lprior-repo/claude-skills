---
name: tdd15-phase-15-landing
description: PHASE 15 LANDING - Final integration. JJ describe/push, bead close, workspace cleanup. Workflow completes and stops.
allowed-tools: Read,Bash
model: sonnet
user-invocable: false
---

# Phase 15: LANDING

## Phase Purpose

Complete the workflow: commit, push, close bead, cleanup:
1. Final JJ status check
2. Review changes
3. Create comprehensive change description
4. Push to remote via JJ
5. Close bead in Beads system
6. Cleanup ZJJ workspace
7. Report completion

**This is the final phase—after this, workflow stops.**

## Execution Steps

### Step 1: Verify Working Tree

```bash
jj status
```

Expected:
```
On branch main
Changes not staged for commit:
  modified:   src/intent/email_validator.gleam
  modified:   test/intent_email_validator_test.gleam

Untracked files:
  (none)

nothing added to commit but untracked changes exist
```

Document changes to be committed.

### Step 2: Review Changes

```bash
jj diff
```

Verify:
```bash
jj status
```

Expected:
```
On branch main
Changes to be committed:
  modified:   src/intent/email_validator.gleam
  modified:   test/intent_email_validator_test.gleam
```

### Step 3: Create Commit Message

Use comprehensive commit message format:

```
Implement Email Validation Feature

Complete 15-phase TDD workflow:
Research → Plan → Verify → RED → GREEN → REFACTOR → MF#1 →
Implement → Verify → Interrogate → QA → MF#2 → Consistency →
Code Liability → Landing

Phases completed:
✓ Phase 1-3: Discovery and planning
✓ Phase 4-6: TDD cycle (all tests pass)
✓ Phase 7: Martin Fowler #1 (8/8 checks pass)
✓ Phase 8: Feature implementation with CLI standards
✓ Phase 9: Success criteria verification
✓ Phase 10: Adversarial FP review (no critical issues)
✓ Phase 11: QA battle testing
✓ Phase 12: Martin Fowler #2 (13/13 checks pass)
✓ Phase 13: CLI consistency validation
✓ Phase 14: Code minimization (37% LOC reduction)
✓ Phase 15: Landing (this commit)

Changes:
- Add email_validator module with validation logic
- Add comprehensive test suite (15 tests, 95% coverage)
- Apply all CLI consistency standards
- Follow Gleam 7 Commandments throughout

Quality assurance:
- All tests passing
- No compiler warnings
- Code formatted with gleam format
- Performance baseline established
- FP principles verified with omarchy
- Manual QA passed all scenarios

Success criteria:
✓ Valid emails accepted
✓ Invalid emails rejected
✓ Plus addressing supported
✓ Error messages clear and helpful

Closes: <bead-id>
```

### Step 4: Describe Change

```bash
jj describe -m "feat: Implement feature via 15-phase TDD workflow

Completed all 15 phases of TDD workflow:
1-3: Research → Plan → Verify
4-6: RED → GREEN → REFACTOR
7: Martin Fowler Check #1 (8/8 ✓)
8: Implement with CLI standards
9: Verify success criteria
10: Interrogate (omarchy: 0 critical)
11: QA battle test
12: Martin Fowler Check #2 (13/13 ✓)
13: Consistency check
14: Code liability (minimized)
15: Landing

All quality gates passed.
All success criteria met.
All tests passing (exit code 0)."
jj new
```

Verify commit created:
```bash
jj log -r @ -n 1
```

Expected:
```
abc1234 feat: Implement feature via 15-phase TDD workflow
```

### Step 5: Push to Remote

```bash
jj git push --bookmark main
```

Expected:
```
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 8 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 1.23 KiB | 1.23 MiB/s, done.
Total 3 (delta 2), reused 0 (delta 0), pack-reused 0
remote: Resolving deltas: 100% (2/2), done.
To https://github.com/user/repo.git
   abc1234..def5678  main -> main
```

Verify:
- [ ] Push succeeded (exit code 0)
- [ ] Output shows "main -> main"
- [ ] No errors or warnings

### Step 6: Close Bead in Beads System

```bash
bd close <bead-id> --reason "Completed 15-phase TDD workflow

All 15 phases executed successfully:
✓ Phase 1: Research - codebase patterns understood
✓ Phase 2: Plan - implementation designed
✓ Phase 3: Verify - user approved plan
✓ Phase 4-6: TDD cycle - tests and implementation
✓ Phase 7: Martin Fowler #1 - quality gate (8/8 pass)
✓ Phase 8: Implementation - feature complete
✓ Phase 9: Verify - all criteria met
✓ Phase 10: Interrogate - FP review (0 critical)
✓ Phase 11: QA - battle testing passed
✓ Phase 12: Martin Fowler #2 - final gate (13/13 pass)
✓ Phase 13: Consistency - standards met
✓ Phase 14: Code Liability - minimized
✓ Phase 15: Landing - jj push successful

Commit: abc1234
Branch: main (pushed to remote)
Status: PRODUCTION_READY"
```

Verify:
```bash
bd show <bead-id> --json | jq '.status'
```

Expected:
```
"closed"
```

### Step 7: Cleanup Workspace

If JJ workspace was created in Phase Init:

```bash
jj workspace forget <bead-id>
```

Verify:
```bash
jj workspace list | grep <bead-id>
# Should return: no results (workspace cleaned up)
```

### Step 8: Final Verification Report

Create landing report:

```
PHASE 15 LANDING REPORT
═════════════════════════════════════════

Bead ID: beads-<id>
Feature: Email Validation
Status: ✓ LANDED

Commit Details:
- Hash: abc1234def5678
- Branch: main
- Remote: origin/main
- Message: feat: Implement feature via 15-phase TDD

Push Verification:
- Exit code: 0 ✓
- Remote sync: ✓ CONFIRMED
- Branch tracking: main → main ✓

Bead Closure:
- Status: closed ✓
- Closed at: 2026-01-18T14:15:00Z
- Reason: Documented in bd show

Workspace Cleanup:
- ZJJ workspace: Removed ✓
- No orphaned workspaces ✓

Workflow Summary:
- Total phases: 15
- Failed phases: 0
- Rewound phases: 0
- Duration: [Total time from Phase 1 to Phase 15]
- Quality gates passed: 15/15 ✓

Final Metrics:
- Tests: 15 passing
- Coverage: 95%
- Code LOC: 95 (minimized from 150)
- Warnings: 0
- FP violations: 0

WORKFLOW COMPLETE ✓
Status: PRODUCTION_READY
Next: Code is live in main branch
```

## Gate: push_succeeded (CRITICAL)

**Pass Criteria**:
- [ ] All changes committed (`git commit` exit code 0)
- [ ] Commit pushed to remote (`git push` exit code 0)
- [ ] Bead closed in Beads system (status = "closed")
- [ ] Workspace cleaned up (if using ZJJ)
- [ ] No uncommitted changes remain
- [ ] Remote branch is synchronized

**Halt Criteria** (CRITICAL - FAILURE BLOCKS):
- Git push failed (exit code ≠ 0)
- Bead close failed
- Network error preventing push
- Authentication error

**On Failure**:
```
Phase 15 LANDING FAILED - MANUAL INTERVENTION REQUIRED

Failed Command: [git push|bd close|jjz remove]
Error: [Error message]
Exit Code: [Code]

Action Required:
1. Check network connectivity
2. Verify authentication
3. Check git remote configuration
4. Manually run failing command

WORKFLOW HALTED - DO NOT PROCEED
Contact git/beads administrator if needed
```

**On Success**: WORKFLOW COMPLETE ✓ STOPS

## Landing Checklist

- [ ] Git status clean (no uncommitted changes)
- [ ] All changes staged (`git add .`)
- [ ] Commit message meaningful and comprehensive
- [ ] Commit created successfully (`git commit` = 0)
- [ ] Push to remote successful (`git push` = 0)
- [ ] Bead closed with reason (`bd close` = 0)
- [ ] Workspace cleaned up (if applicable)
- [ ] Final report generated
- [ ] No errors or warnings

## Integration Points

**Phase 14**: Prerequisite (code minimized)
**Beads**: Integrates `bd close` to mark complete
**ZJJ**: Removes workspace if created
**Git**: Final commit and push to production branch

## Workflow Completion

After Phase 15 succeeds:
- ✓ Code is in main branch on remote
- ✓ Bead is closed in Beads system
- ✓ Workspace is cleaned up
- ✓ All 15 phases completed successfully
- ✓ **WORKFLOW STOPS** (no looping)
- ✓ Feature is production-ready

## Notes

- Phase 15 is the final phase—workflow terminates here
- Push failure is critical—blocks production release
- Always verify commit is on remote before considering done
- Bead closure documents completion in work tracking system
- Workspace cleanup prevents orphaned workspaces
- Success means feature is ready for production

## Nu Backbone
- Start: `tdd15 phase-start <session> 15`
- Gate: `tdd15 gate-check <session> 15 '<result>'`
- Model/threshold may escalate on retry: `tdd15 model <session> 15`, `tdd15 threshold <session> 15`
