---
name: go-skill
description: "GoMasterOrchestrator - BEAM-style deterministic supervisor for BDCLI-first execution from top-priority bead to main. Includes pre-flight codebase exploration (STATE 2) to cache context before implementation, CI failure categorization (BANNED_ASSERTION / CLIPPY / COMPILE_ERROR / TEST_FAILURE / CONTRACT_PARITY / FORMAT) for targeted fix loops, and structured sub-agent task titles for auditability. Use this skill whenever starting work on a bead, implementing a feature end-to-end, or running the full TDD pipeline from contract to landing."
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
- `rust-contract` (State 3)
- `test-planner` (State 4)
- `test-reviewer` (State 5, State 11)
- `test-writer` (State 6)
- `functional-rust` (State 7, State 15)
- `qa-enforcer` (State 9)
- `red-queen` (State 12)
- `black-hat-reviewer` (State 13)

Artifact root:
- `.beads/<bead-id>/`

Required metadata header in canonical artifacts:
- `bead_id: <bead-id>`
- `bead_title: <title from bd show>`
- `phase: <phase-id>`
- `updated_at: <ISO-8601 UTC>`

---

## STATE 1: ISOLATION & CALIBRATION

1) Determine target bead:
```bash
bd show <bead-id>
```
If the caller supplied `<bead-id>`, use it. Only fall back to `bd ready --json` when no explicit bead ID was supplied.

2) Show and claim bead immediately:
```bash
bd show <bead-id> --json
bd update <bead-id> --claim --json
record-receipt <bead-id> p1 orchestrator "bead claimed" "bd update <bead-id> --claim --json" <exit> <stdout-file> <stderr-file> false
```
If `--claim` fails, abort instead of silently continuing on another bead.

3) Create isolated workspace:
```bash
jj workspace add "../<bead-id>"
jj workspace list
record-receipt <bead-id> p1 orchestrator "workspace isolated" "jj workspace add ../<bead-id>" <exit> <stdout-file> <stderr-file> false
```

Change your working directory by prefixing ALL subsequent `bash` commands with `cd ../<bead-id> &&`. ALL subsequent commands must operate in the new workspace.
Example: `cd ../<bead-id> && mkdir -p .beads/<bead-id> && echo "STATE 2" > .beads/<bead-id>/STATE.md`
Initialize `.beads/<bead-id>/STATE.md` with "STATE 2". Update this file at the start of every subsequent state to ensure durable crash recovery.

---

## STATE 2: CODEBASE EXPLORATION (PRE-FLIGHT)

**Purpose:** Cache codebase context before any sub-agent touches the implementation. Eliminates redundant bash/read exploration inside functional-rust and test-writer — reduces shell invocations by ~30%.

**Action:** Launch `explore` Sub-Agent via the `Task` tool.
**Title:** `[<bead-id>] p2-explore: codebase map`
**Prompt:** "You are an Explore agent. Map the codebase for Bead `<bead-id>`. Produce a structured snapshot covering: (1) directory tree (3 levels), (2) all public types and traits relevant to the bead's domain, (3) existing test files and their coverage areas, (4) any existing contract or plan artifacts in `.beads/<bead-id>/`. Write the map to `../<bead-id>/.beads/<bead-id>/codebase-map.md`. Do NOT edit any files — read only."

**Gate:** Orchestrator MUST verify `codebase-map.md` exists. If missing, proceed anyway (explore is best-effort) but log a warning. All subsequent sub-agent prompts MUST include: "Read `../<bead-id>/.beads/<bead-id>/codebase-map.md` first for codebase context."

---

## STATE 3: CONTRACT SYNTHESIS

If `contract.md` does not exist:
**Action:** Launch `rust-contract` Sub-Agent via the `Task` tool.
**Prompt:** "Load the `rust-contract` skill. Implement a strict Design-by-Contract specification for Bead: [ID]. Write the contract (types, invariants, preconditions, postconditions, error taxonomy) to `../<bead-id>/.beads/<bead-id>/contract.md`. Contract only — no test plan."
**Gate:** Orchestrator MUST verify `contract.md` exists (`ls ../<bead-id>/.beads/<bead-id>/contract.md`). If missing, fail-closed (Abort). Record contract receipt.

---

## STATE 4: TEST PLANNING

**Action:** Launch `test-planner` Sub-Agent via the `Task` tool.
**Prompt:** "Load the `test-planner` skill. Read `../<bead-id>/.beads/<bead-id>/contract.md`. Produce an exhaustive `test-plan.md` covering: Testing Trophy allocation, BDD Given-When-Then scenarios for every public function, proptest invariants, cargo-fuzz targets, Kani harness specs, and mutation testing checkpoints. Write to `../<bead-id>/.beads/<bead-id>/test-plan.md`."
**Gate:** Orchestrator MUST verify `test-plan.md` exists. If missing, fail-closed (Abort). Record receipt.

---

## STATE 5: TEST PLAN REVIEW

**Action:** Launch `test-reviewer` Sub-Agent via the `Task` tool — **Mode 1: Plan Inquisition**.
**Prompt:** "Load the `test-reviewer` skill. Run Mode 1 (Plan Inquisition). Read `../<bead-id>/.beads/<bead-id>/contract.md` and `../<bead-id>/.beads/<bead-id>/test-plan.md`. Audit the plan against all six axes: contract parity, assertion sharpness, trophy allocation, boundary completeness, mutation survivability, and Holzmann rules. Write findings to `../<bead-id>/.beads/<bead-id>/test-plan-review.md`. Output STATUS: APPROVED or STATUS: REJECTED."

**Gate:**
- `STATUS: APPROVED`: Proceed to State 6.
- `STATUS: REJECTED`: Loop back to State 4 passing defects from `test-plan-review.md` (Max retries: 7). If still failing after 7 loops, ABORT.

---

## STATE 6: TDD RED PHASE

**Action:** Launch `test-writer` Sub-Agent via the `Task` tool — **Red Phase only**.
**Prompt:** "Load the `test-writer` skill. Read `../<bead-id>/.beads/<bead-id>/contract.md` and `../<bead-id>/.beads/<bead-id>/test-plan.md`. Write ALL tests specified in the plan: unit tests, integration tests, proptest invariants, fuzz targets, Kani harnesses. The implementation does NOT exist yet — tests must be written to compile but FAIL (red phase). After writing, run `cargo nextest run 2>&1 | tail -10` and confirm tests are RED. Do NOT write any implementation code. Reply 'RED PHASE COMPLETE: N tests failing' with the nextest output."

**Gate:**
- Tests compile AND fail (red) → Proceed to State 7.
- Tests pass (somehow green without implementation) → **ABORT**. Something is wrong — either the implementation already exists or the tests are hollow.
- Tests fail to compile → Loop back with compile errors (Max retries: 7).

---

## STATE 7: IMPLEMENTATION

**Action:** Launch `functional-rust` Sub-Agent via `Task` tool.
**Prompt:** "Load `functional-rust` skill. Read `../<bead-id>/.beads/<bead-id>/contract.md`, `../<bead-id>/.beads/<bead-id>/test-plan.md`, and the failing tests already written in the codebase. The failing tests are your authoritative specification — make them pass. Implement strictly adhering to Data->Calc->Actions, zero panics/unwrap/mut. Write implementation summary to `../<bead-id>/.beads/<bead-id>/implementation.md`."
**Gate:** Wait for `implementation.md`. Orchestrator MUST verify file exists. If missing, retry. Proceed to State 8.

---

## STATE 8: MOON GATE (MACHINE VERIFICATION)

**Action:** Run validation strictly, capturing output:
```bash
cd ../<bead-id> && moon run :quick > .beads/<bead-id>/compiler-errors.log 2>&1
cd ../<bead-id> && moon run :test >> .beads/<bead-id>/compiler-errors.log 2>&1
cd ../<bead-id> && moon run :ci >> .beads/<bead-id>/compiler-errors.log 2>&1
cd ../<bead-id> && moon run :e2e >> .beads/<bead-id>/compiler-errors.log 2>&1
```

**CI Failure Categorization (required before any fix loop):**
If RED, classify the first failure in `compiler-errors.log` into exactly one category and write to `.beads/<bead-id>/ci-failure-category.txt`:
- `BANNED_ASSERTION` — `result.is_ok()`, `result.is_err()`, bare `unwrap`, `let _`
- `CLIPPY` — clippy lint violation
- `COMPILE_ERROR` — rustc compile failure
- `TEST_FAILURE` — test panicked or assertion failed
- `CONTRACT_PARITY` — type/signature mismatch with contract.md
- `FORMAT` — rustfmt violation

```bash
# Classify and record:
cd ../<bead-id> && grep -m1 -E "(is_ok\(\)|is_err\(\)|unwrap\(\)|let _|clippy::|error\[E|FAILED|contract)" .beads/<bead-id>/compiler-errors.log \
  | awk '{print "CATEGORY: "$0}' > .beads/<bead-id>/ci-failure-category.txt
```

- If RED: Launch `functional-rust` sub-agent.
  **Title:** `[<bead-id>] p8-fix: <CATEGORY from ci-failure-category.txt>`
  **Prompt:** "Load `functional-rust` skill. Read `../<bead-id>/.beads/<bead-id>/compiler-errors.log`, `../<bead-id>/.beads/<bead-id>/ci-failure-category.txt`, and `../<bead-id>/.beads/<bead-id>/contract.md`. The failure category is in `ci-failure-category.txt` — target that category specifically. Fix the errors. Do NOT modify tests to make them pass — fix the implementation. Reply 'FIXES APPLIED: <category>'." (Max retries: 7).
- If GREEN: Record p8 receipts and proceed to State 9.

---

## STATE 9: QA EXECUTION (REQUIRED)

**Action:** Launch `qa-enforcer` Sub-Agent via `Task` tool.
**Prompt:** "Load the `qa-enforcer` skill. Execute actual CLI commands and verify behavior against the contract. Run smoke tests, integration tests, and adversarial tests. Write results to `../<bead-id>/.beads/<bead-id>/qa-report.md`. Include: exact commands run, actual output, exit codes, expected vs actual, and reproduction steps."

**Artifact:** `.beads/<bead-id>/qa-report.md`

**Gate:**
- If CRITICAL issues found: Record defects → Proceed to State 10
- If MAJOR issues found: Record as warnings → Proceed to State 10
- If PASS: Proceed to State 10

**Retry:** Up to 7 times (Max retries: 7)

---

## STATE 10: QA REVIEW

**Action:** Agent reviews `qa-report.md` and makes decision.

**Decision:**
- ✅ **PASS** (no critical issues): Proceed to State 11
- ❌ **FAIL** (critical issues): Return to **State 7 (Implementation)** to fix issues

**Artifact:** `.beads/<bead-id>/qa-review.md`

**Retry:** Up to 7 times (Max retries: 7)

---

## STATE 11: TEST SUITE REVIEW

**Action:** Launch `test-reviewer` Sub-Agent via the `Task` tool — **Mode 2: Suite Inquisition**.
**Prompt:** "Load the `test-reviewer` skill. Run Mode 2 (Suite Inquisition). Run all four tiers: Tier 0 static analysis, Tier 1 execution gates, Tier 2 coverage, Tier 3 mutation. The project root is `../<bead-id>`. Write findings to `../<bead-id>/.beads/<bead-id>/test-suite-review.md`. Output STATUS: APPROVED or STATUS: REJECTED with full evidence."

**Gate:**
- `STATUS: APPROVED`: Proceed to State 12.
- `STATUS: REJECTED`: Launch `test-writer` sub-agent.
  **Prompt:** "Load `test-writer` skill. Read `../<bead-id>/.beads/<bead-id>/test-suite-review.md`. Fix every finding in the MANDATE section. Write additional tests for every surviving mutant. Reply 'SUITE FIXED'."
  Then return to State 11 for full re-review. (Max retries: 7)

---

## STATE 12: ADVERSARIAL REVIEW (RED QUEEN)

**Action:** Launch `red-queen` Sub-Agent via `Task` tool.
**Prompt:** "Load the `red-queen` skill. Run adversarial testing to break the implementation. Generate test cases that attempt to violate contracts, edge cases, and failure modes. Write results to `../<bead-id>/.beads/<bead-id>/red-queen-report.md`."

**Artifact:** `.beads/<bead-id>/red-queen-report.md`

**Gate:**
- If defects found: Proceed to State 13
- If all defects caught: Proceed to State 13

**Retry:** Up to 7 times (Max retries: 7)

---

## STATE 13: BLACK HAT CODE REVIEW

**Action:** Launch `black-hat-reviewer` Sub-Agent via `Task` tool.
**Prompt:** "Load `black-hat-reviewer` skill. Read `../<bead-id>/.beads/<bead-id>/contract.md` and `../<bead-id>/.beads/<bead-id>/implementation.md`. Inspect the source files. Ruthlessly enforce the 5 phases of code review. If flawed, write to `../<bead-id>/.beads/<bead-id>/defects.md` and output 'STATUS: REJECTED'. If flawless, output 'STATUS: APPROVED'."

**Artifact:** `.beads/<bead-id>/defects.md`

**Gate:**
- `STATUS: APPROVED`: Proceed to State 14
- `STATUS: REJECTED`: Proceed to State 15

**Retry:** Up to 7 times (Max retries: 7)

---

## STATE 14: KANI MODEL CHECKING (MANDATORY)

Kani harnesses were written by `test-writer` in State 6. This state executes them.

**Action:**
```bash
cd ../<bead-id> && cargo kani 2>&1 | tee .beads/<bead-id>/kani-report.md
```

**Gate:**
- If Kani counterexample found: Proceed to State 15 (Repair Loop)
- If Kani verified: Proceed to State 16
- If no harnesses exist (test-writer skipped Kani layer): Require written justification
  in `../<bead-id>/.beads/<bead-id>/kani-justification.md` — formal argument why Kani
  is not needed for this bead's critical invariants.

**Retry:** Up to 7 times (Max retries: 7)

---

## STATE 15: THE REPAIR LOOP

**Action:** Launch `functional-rust` Sub-Agent via `Task` tool.
**Prompt:** "Load `functional-rust` skill. Read `../<bead-id>/.beads/<bead-id>/defects.md`. Edit source files to fix every defect. Do NOT modify tests to make them pass — fix the implementation. Reply 'FIXES APPLIED'."
**Gate:** Return to STATE 8 (Re-run Moon, QA, Test Suite Review, Red Queen, Black Hat, Kani).
**HARD LIMIT:** if looping > 7 times, ABORT.

---

## STATE 16: ARCHITECTURAL DRIFT & POLISH

**Action:** Launch `architectural-drift` Sub-Agent via `Task` tool.
**Prompt:** "Load `architectural-drift` and `scott-ddd-refactor` skills. Review the source files. Enforce the <300 line limit per file and apply Scott Wlaschin DDD principles to eliminate primitive obsession and ensure explicit state transitions. If you edit files to split modules or improve DDD, output 'STATUS: REFACTORED'. If the codebase is already perfect, output 'STATUS: PERFECT'."
**Gate:**
- `STATUS: REFACTORED`: Return to STATE 8 (Moon Gate) to verify the refactor didn't break compilation. (Max drift loops: 7)
- `STATUS: PERFECT`: Record p16 receipt and Proceed to State 17.

---

## STATE 17: LANDING AND CLEANUP

Once QA, Test Suite Review, Red Queen, Black Hat, Kani, and Architectural Drift approve AND Moon is green:
```bash
cd ../<bead-id> && bd show <bead-id>
cd ../<bead-id> && jj git fetch
cd ../<bead-id> && jj rebase -d main@origin
cd ../<bead-id> && jj git push --bookmark main
cd ../<bead-id> && bd close <bead-id>
cd ../<bead-id> && bd sync
cd ../<bead-id> && jj workspace forget "<bead-id>"
cd .. && rm -rf "<bead-id>"
record-receipt <bead-id> p17 orchestrator "bead closed" "bd close <bead-id>" <exit> <stdout-file> <stderr-file> false
```
Verify cleanup:
```bash
jj workspace list | grep -q "<bead-id>" && echo "FAIL" || echo "OK"
ls -la "../<bead-id>" 2>&1 | grep -q "No such file" && echo "OK" || echo "FAIL"
```
If directory exists, FAIL workflow. Do not report completion until verified.
