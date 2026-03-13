---
name: orchestrate
description: Master supervisor for batch bead execution; delegates each bead to go-skill with strict context hygiene
allowed-tools: ["bash", "read", "glob", "grep", "task"]
---

# Orchestrate Skill

This is the master orchestrator. It supervises many beads while delegating per-bead execution to `go-skill`.

Key model:
- `orchestrate` = scheduler/supervisor (control plane)
- `go-skill` = deterministic per-bead worker pipeline (data plane)

Do not replace `go-skill`. Use it.

## Non-negotiables

- Use BDCLI for bead lifecycle (`bd`, never `bd`).
- Use JJ for VCS operations (`jj`, never raw `git`).
- Use Moon for validation gates.
- Delegate bead execution to `go-skill`.
- Keep orchestrator context minimal and stateless per bead.

## Context Hygiene (mandatory)

Track only this per bead:
- `bead_id`
- `state`: `pending|running|passed|failed`
- `attempt_count`
- `last_failure_code`

Never keep detailed implementation logs in orchestrator context.
Detailed evidence lives in `.beads/<bead-id>/` artifacts.

## Batch Execution Protocol

Input example: "do 10 beads"

1) Discover ready beads with BDCLI:
```bash
bd ready --json
```
Fallback:
```bash
bd ready
```

2) Select top N unblocked beads by priority (P0>P1>P2>P3>P4, then oldest).

3) For each selected bead, run this deterministic sequence:
   - invoke `go-skill` for that bead/task scope
   - wait for completion
   - verify status/evidence:
     - `bd show <bead-id>`
     - `verify-bead <bead-id> --phase all`
   - mark orchestrator state

4) If a bead fails:
   - record failure code from `.beads/<bead-id>/defects.md` when present
   - allow `go-skill` recovery path
   - retry same bead up to policy limit (default 3)
   - then continue to next bead (do not block entire batch forever)

5) Produce final batch report:
   - total beads requested
   - passed/failed counts
   - bead ids by status
   - failure codes summary

## Delegation Contract to go-skill

For each bead, delegate with this intent:
- execute mandatory BDCLI-first order
- enforce deterministic receipts and verifier checks
- close bead only after all gates pass
- clean workspace

## Success Condition

Orchestrate run is successful when:
- all targeted beads are either `passed` or explicitly `failed` with evidence
- no bead is left in ambiguous state
- each `passed` bead has `bd` closed status and full verifier pass
