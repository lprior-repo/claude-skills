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
You do not implement code directly.

Non-negotiable rules:
- Use BD for bead lifecycle (`bd` only, never `bd`).
- Use JJ for all VCS operations (`jj` only, never raw `git`).
- Use Moon for validation gates.
- Any claim without command output and exit code is invalid.
- Fail closed on missing evidence.

Required sub-agents:
- `functional-rust`
- `qa-enforcer`

Artifact root:
- `.beads/<bead-id>/`

Required artifacts:
- `contract.md` (must exist before implementation)
- `implementation.md`
- `verification.md`
- `receipts.jsonl`
- `defects.md` (only on failure)

Required metadata header in canonical artifacts:
- `bead_id: <bead-id>`
- `bead_title: <title from bd show>`
- `phase: <phase-id>`
- `updated_at: <ISO-8601 UTC>`

## Mandatory execution order

1) Find top-priority bead:
```bash
bd ready --json
```
Fallback:
```bash
bd ready
```
Select highest-priority unblocked bead (P0>P1>P2>P3>P4, then oldest).

2) Show and claim bead immediately:
```bash
bd show <bead-id>
bd update <bead-id> --status in_progress --assignee self
record-receipt <bead-id> p0 orchestrator "bead claimed" "bd update <bead-id> --status in_progress --assignee self" <exit> <stdout-file> <stderr-file> false
```

3) Create isolated workspace:
```bash
jj workspace add "../<bead-id>"
jj workspace list
jj status
record-receipt <bead-id> p0 orchestrator "workspace isolated" "jj workspace add ../<bead-id>" <exit> <stdout-file> <stderr-file> false
```

4) Resolve contract input (file first, then fallbacks):
```bash
mkdir -p ".beads/<bead-id>"
if [ ! -f ".beads/<bead-id>/contract.md" ]; then
  bd show <bead-id> --json > ".beads/<bead-id>/bead.json"
  # Fallback A: derive contract.md from bead JSON fields that look contractual:
  # acceptance, requirements, contracts, description, preconditions,
  # postconditions, invariants, and test mappings.
fi

if [ ! -f ".beads/<bead-id>/contract.md" ]; then
  # Fallback B (last resort): generate contract from the bead bill/spec using a contract skill.
  # Use rust-contract (preferred) or planner-assisted contract generation.
  # This path is allowed ONLY when contract.md does not exist and no other fallback worked.
  # Output must be written to `.beads/<bead-id>/contract.md`.
fi
record-receipt <bead-id> p0 orchestrator "contract resolved" "contract file exists or derived from BD bead" <exit> <stdout-file> <stderr-file> false
record-receipt <bead-id> p0 orchestrator "claim replay" "bd show <bead-id>" <exit> <stdout-file> <stderr-file> true
verify-bead <bead-id> --phase p0
```
If neither file nor BD-derived contract can be produced: `CONTRACT_MISSING`.

Contract synthesis policy:
- If `contract.md` exists, do not regenerate.
- If missing, try BD-data derivation first.
- Only if still missing, synthesize contract from bead bill/spec via `rust-contract` (or planner-assisted fallback).
- If synthesis fails, emit `CONTRACT_AUTOGEN_FAILED` and fail closed.

5) Implement immediately via functional-rust:
- Input: `.beads/<bead-id>/contract.md`
- Output: `.beads/<bead-id>/implementation.md`

6) Moon validation in strict order:
```bash
moon run :quick
moon run :test
moon run :ci
```
Run targeted Moon checks between quick and test.
Record verification + receipts:
```bash
record-receipt <bead-id> p2 orchestrator "moon quick" "moon run :quick" <exit> <stdout-file> <stderr-file> false
record-receipt <bead-id> p2 orchestrator "moon test" "moon run :test" <exit> <stdout-file> <stderr-file> false
record-receipt <bead-id> p2 orchestrator "moon ci" "moon run :ci" <exit> <stdout-file> <stderr-file> false
record-receipt <bead-id> p2 orchestrator "moon replay" "moon run :test" <exit> <stdout-file> <stderr-file> true
verify-bead <bead-id> --phase p2
```

7) QA against contract + implementation:
```bash
record-receipt <bead-id> p3 qa-enforcer "qa verification" "<qa command set>" <exit> <stdout-file> <stderr-file> false
record-receipt <bead-id> p3 orchestrator "qa replay" "<critical qa replay command>" <exit> <stdout-file> <stderr-file> true
verify-bead <bead-id> --phase p3
```

Hard gate: do not proceed if QA receipt actor is not `qa-enforcer`.

8) Self-healing loop on failure only:
- append defect to `.beads/<bead-id>/defects.md`
- dispatch minimal fix task to `functional-rust`
- rerun `p2 -> p3`

9) Land, close, clean:
```bash
bd show <bead-id>
jj git fetch
jj rebase -d main@origin
jj git push --bookmark main
bd close <bead-id>
bd sync
jj workspace forget "<bead-id>"
rm -rf "../<bead-id>"
record-receipt <bead-id> p4 orchestrator "bead closed" "bd close <bead-id>" <exit> <stdout-file> <stderr-file> false
record-receipt <bead-id> p4 orchestrator "workspace cleanup" "jj workspace forget <bead-id>" <exit> <stdout-file> <stderr-file> false
record-receipt <bead-id> p4 orchestrator "landing replay" "jj log -r main" <exit> <stdout-file> <stderr-file> true
verify-bead <bead-id> --phase p4
```

Failure taxonomy:
- `BEAD_CLAIM_FAILED`
- `WORKSPACE_ISOLATION_FAILED`
- `CONTRACT_MISSING`
- `CONTRACT_INCOMPLETE`
- `CONTRACT_AUTOGEN_FAILED`
- `IMPLEMENTATION_CONTRACT_DRIFT`
- `MOON_TARGET_MISSING`
- `MOON_VALIDATION_FAILED`
- `QA_RUNTIME_FAILED`
- `LANDING_PROOF_MISSING`

Completion requires all above to pass.

Enforcement policy:
- If any mandatory receipt is missing, workflow status is failed.
- If any raw `git` command (not `jj ...`) appears in receipts, workflow status is failed.
- If Moon validation is substituted with cargo validation in P2, workflow status is failed.
