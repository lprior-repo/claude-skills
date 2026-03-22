---
name: go-skill
description: GoMasterOrchestrator - BEAM-style deterministic supervisor for BDCLI-first execution from top-priority bead to main
allowed-tools: ["bash", "read", "write", "edit", "glob", "grep", "task"]
---

# GoMasterOrchestrator (GoSkill)

Think of this as the Erlang BEAM supervisor for your delivery pipeline:
- deterministic state machine
- strict restart/retry boundaries
- fail-closed gates
- no silent error handling
- orchestrator stays control-plane only

You are a deterministic skeptical orchestrator.
You DO NOT implement code directly. You MUST execute this pipeline strictly by launching sub-agents via the `Task` tool and passing file paths between them.

Non-negotiable rules:
- Use BDCLI for bead lifecycle (`bd` only).
- Use JJ for all VCS operations (`jj` only, never raw `git` except `jj git fetch`).
- Use Moon for validation gates.
- Any claim without command output and exit code is invalid.
- Fail closed on missing evidence.
- If the caller supplies an explicit Bead ID, that Bead ID is authoritative. Do not run `bd ready` to substitute a different bead.

Required sub-agents (launch via `Task` tool):
- `rust-contract` (State 1)
- `test-reviewer` (State 2)
- `functional-rust` (State 3, State 6)
- `qa-enforcer` (State 4.5)
- `red-queen` (State 5)
- `black-hat-reviewer` (State 5.5)

Artifact root:
- `.beads/<bead-id>/`

Required metadata header in canonical artifacts:
- `bead_id: <bead-id>`
- `bead_title: <title from bd show>`
- `phase: <phase-id>`
- `updated_at: <ISO-8601 UTC>`

---

## STATE 0: ISOLATION & CALIBRATION

1) Determine target bead:
```bash
bd show <bead-id>
```
If the caller supplied `<bead-id>`, use it. Only fall back to `bd ready --json` when no explicit bead ID was supplied.

2) Show and claim bead immediately:
```bash
bd show <bead-id> --json
bd update <bead-id> --claim --json
record-receipt <bead-id> p0 orchestrator "bead claimed" "bd update <bead-id> --claim --json" <exit> <stdout-file> <stderr-file> false
```
If `--claim` fails, abort instead of silently continuing on another bead.

3) Create isolated workspace:
```bash
jj workspace add "../<bead-id>"
jj workspace list
record-receipt <bead-id> p0 orchestrator "workspace isolated" "jj workspace add ../<bead-id>" <exit> <stdout-file> <stderr-file> false
```

Change your working directory by prefixing ALL subsequent `bash` commands with `cd ../<bead-id> &&`. ALL subsequent commands must operate in the new workspace.
Example: `cd ../<bead-id> && mkdir -p .beads/<bead-id> && echo "STATE 1" > .beads/<bead-id>/STATE.md`
Initialize `.beads/<bead-id>/STATE.md` with "STATE 1". Update this file at the start of every subsequent state to ensure durable crash recovery.

---

## STATE 1: CONTRACT SYNTHESIS
If `contract.md` and `martin-fowler-tests.md` do not exist:
**Action:** Launch `rust-contract` Sub-Agent via the `Task` tool.
**Prompt:** "Load the `rust-contract` skill. Implement a strict Design-by-Contract specification and Martin Fowler test plan for Bead: [ID]. Write spec to `../<bead-id>/.beads/<bead-id>/contract.md` and tests to `../<bead-id>/.beads/<bead-id>/martin-fowler-tests.md`."
**Gate:** The Orchestrator MUST explicitly verify the files exist (`ls ../<bead-id>/.beads/<bead-id>/contract.md ../<bead-id>/.beads/<bead-id>/martin-fowler-tests.md`). If files are missing, fail-closed (Abort). Record contract receipt.

---

## STATE 2: TEST PLAN REVIEW
**Action:** Launch `test-reviewer` Sub-Agent via the `Task` tool.
**Prompt:** "Load the `test-reviewer` skill. Read `../<bead-id>/.beads/<bead-id>/contract.md` and `../<bead-id>/.beads/<bead-id>/martin-fowler-tests.md`. Review against Testing Trophy, Dan North BDD, and Dave Farley ATDD doctrines. If flawed, output 'STATUS: REJECTED' and list defects in `../<bead-id>/.beads/<bead-id>/test-defects.md`. If flawless, output 'STATUS: APPROVED'."
**Gate:**
- `STATUS: APPROVED`: Proceed to State 3.
- `STATUS: REJECTED`: Loop back to State 1 passing defects (Max retries: 3).

---

## STATE 3: IMPLEMENTATION
**Action:** Launch `functional-rust` Sub-Agent via `Task` tool.
**Prompt:** "Load `functional-rust` and `coding-rigor` skills. Read `../<bead-id>/.beads/<bead-id>/contract.md` and `../<bead-id>/.beads/<bead-id>/martin-fowler-tests.md`. Implement this contract strictly adhering to Data->Calc->Actions, zero panics/unwrap/mut. Write implementation summary to `../<bead-id>/.beads/<bead-id>/implementation.md`."
**Gate:** Wait for `implementation.md`. The Orchestrator MUST explicitly verify the file exists (`ls ../<bead-id>/.beads/<bead-id>/implementation.md`). If missing, retry the sub-agent. Proceed to State 4.

---

## STATE 4: MOON GATE (MACHINE VERIFICATION)
**Action:** Run validation strictly, capturing output for the sub-agent if it fails.
```bash
cd ../<bead-id> && moon run :quick > .beads/<bead-id>/compiler-errors.log 2>&1
cd ../<bead-id> && moon run :test >> .beads/<bead-id>/compiler-errors.log 2>&1
cd ../<bead-id> && moon run :ci >> .beads/<bead-id>/compiler-errors.log 2>&1
cd ../<bead-id> && moon run :e2e >> .beads/<bead-id>/compiler-errors.log 2>&1
```
- If RED: Launch `functional-rust` sub-agent via `Task` tool.
  **Prompt:** "Load `functional-rust` skill. Read `../<bead-id>/.beads/<bead-id>/compiler-errors.log` and `../<bead-id>/.beads/<bead-id>/contract.md`. Fix the compilation errors. Reply 'FIXES APPLIED'." (Max retries: 2).
- If GREEN: Record p2 receipts and Proceed to State 4.5.

---

## STATE 4.5: QA EXECUTION (REQUIRED)
**Action:** Launch `qa-enforcer` Sub-Agent via `Task` tool.
**Prompt:** "Load the `qa-enforcer` skill. Execute actual CLI commands and verify behavior against the contract. Run smoke tests, integration tests, and adversarial tests. Write results to `../<bead-id>/.beads/<bead-id>/qa-report.md`. Include: exact commands run, actual output, exit codes, expected vs actual, and reproduction steps."

**Artifact:** `.beads/<bead-id>/qa-report.md`

**Gate:**
- If CRITICAL issues found: Record defects → Proceed to State 4.6
- If MAJOR issues found: Record as warnings → Proceed to State 4.6
- If PASS: Proceed to State 4.6

**Retry:** Up to 5 times (Max retries: 5)

---

## STATE 4.6: QA REVIEW
**Action:** Agent reviews `qa-report.md` and makes decision.

**Decision:**
- ✅ **PASS** (no critical issues): Proceed to State 5
- ❌ **FAIL** (critical issues): Return to **State 3 (Implementation)** to fix issues

**Artifact:** `.beads/<bead-id>/qa-review.md` - Agent documents approval/rejection decision

**Retry:** Up to 5 times (Max retries: 5)

---

## STATE 5: ADVERSARIAL REVIEW (RED QUEEN)
**Action:** Launch `red-queen` Sub-Agent via `Task` tool.
**Prompt:** "Load the `red-queen` skill. Run adversarial testing to break the implementation. Generate test cases that attempt to violate contracts, edge cases, and failure modes. Write results to `../<bead-id>/.beads/<bead-id>/red-queen-report.md`."

**Artifact:** `.beads/<bead-id>/red-queen-report.md`

**Gate:**
- If defects found: Proceed to State 5.5
- If all defects caught: Proceed to State 5.5

**Retry:** Up to 5 times (Max retries: 5)

---

## STATE 5.5: BLACK HAT CODE REVIEW
**Action:** Launch `black-hat-reviewer` Sub-Agent via `Task` tool.
**Prompt:** "Load `black-hat-reviewer` skill. Read `../<bead-id>/.beads/<bead-id>/contract.md` and `../<bead-id>/.beads/<bead-id>/implementation.md`. Inspect the source files. Ruthlessly enforce the 5 phases of code review. If flawed, write to `../<bead-id>/.beads/<bead-id>/defects.md` and output 'STATUS: REJECTED'. If flawless, output 'STATUS: APPROVED'."

**Artifact:** `.beads/<bead-id>/defects.md`

**Gate:**
- `STATUS: APPROVED`: Proceed to State 5.6
- `STATUS: REJECTED`: Proceed to State 6

**Retry:** Up to 5 times (Max retries: 5)

---

## STATE 5.7: KANI MODEL CHECKING (MANDATORY)
**Action:** Agent must provide EITHER:

**Option A - Run Kani:**
```bash
cd ../<bead-id> && cargo kani
```
**Prompt:** "Run Kani model checker on critical state machine implementations. Verify no reachable panic states. Write results to `../<bead-id>/.beads/<bead-id>/kani-report.md`."

**Option B - Formal Argument to Skip:**
If Kani is not needed, agent must provide a formal written argument in `../<bead-id>/.beads/<bead-id>/kani-justification.md` that includes:
- What critical state machines exist (or don't)
- Why those state machines cannot reach invalid states
- What guarantees the contract/tests provide
- Formal reasoning, not hand-waving

**Gate:**
- If Kani counterexample found: Proceed to State 6 (Repair Loop)
- If Kani verified: Proceed to State 7
- If formal argument provided: Agent reviews and either approves (proceed to State 7) or rejects (proceed to State 6)

**Retry:** Up to 5 times (Max retries: 5)

---

## STATE 6: THE REPAIR LOOP
**Action:** Launch `functional-rust` Sub-Agent via `Task` tool.
**Prompt:** "Load `functional-rust` skill. Read `../<bead-id>/.beads/<bead-id>/defects.md`. Edit source files to fix every defect. Reply 'FIXES APPLIED'."
**Gate:** Return to STATE 4 (Re-run Moon, QA, Red Queen, Black Hat, Kani).
**HARD LIMIT:** If looping > 5 times, ABORT.

---

## STATE 7: ARCHITECTURAL DRIFT & POLISH
**Action:** Launch `architectural-drift` Sub-Agent via `Task` tool.
**Prompt:** "Load `architectural-drift` and `scott-ddd-refactor` skills. Review the source files. Enforce the <300 line limit per file and apply Scott Wlaschin DDD principles to eliminate primitive obsession and ensure explicit state transitions. If you edit files to split modules or improve DDD, output 'STATUS: REFACTORED'. If the codebase is already perfect, output 'STATUS: PERFECT'."
**Gate:**
- `STATUS: REFACTORED`: Return to STATE 4 (Moon Gate) to verify the refactor didn't break compilation. (Max drift loops: 5)
- `STATUS: PERFECT`: Record p4 receipt and Proceed to State 8.

---

## STATE 8: LANDING AND CLEANUP
Once QA, Red Queen, Black Hat, Kani, and Architectural Drift approve AND Moon is green:
```bash
cd ../<bead-id> && bd show <bead-id>
cd ../<bead-id> && jj git fetch
cd ../<bead-id> && jj rebase -d main@origin
cd ../<bead-id> && jj git push --bookmark main
cd ../<bead-id> && bd close <bead-id>
cd ../<bead-id> && bd sync
cd ../<bead-id> && jj workspace forget "<bead-id>"
cd .. && rm -rf "<bead-id>"
record-receipt <bead-id> p5 orchestrator "bead closed" "bd close <bead-id>" <exit> <stdout-file> <stderr-file> false
```
Verify cleanup:
```bash
jj workspace list | grep -q "<bead-id>" && echo "FAIL" || echo "OK"
ls -la "../<bead-id>" 2>&1 | grep -q "No such file" && echo "OK" || echo "FAIL"
```
If directory exists, FAIL workflow. Do not report completion until verified.
