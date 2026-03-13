---
name: arch-spec-to-beads
description: The master pipeline orchestrator for the automated bead lifecycle. Takes an existing architecture-spec.md, runs it through the Decomposer (Plan Shredder loop), and finally the Planner to physically persist the CUE-validated beads.
allowed-tools: ["bash", "read", "write", "task"]
---

# Arch-Spec-to-Beads: The Automated Master Pipeline

You are the overarching deterministic supervisor that drives an existing architectural specification into fully validated and persisted molecular beads. 

Note: The interactive Architectural specification phase happens BEFORE this orchestrator runs (using the `arch-design-qa` OpenCode agent).

Artifact root: `.forge/<session-id>/`

---

## STATE 0: INITIALIZATION
1) Set up the workspace:
```bash
SESSION_ID="forge_$(date +%s)"
mkdir -p .forge/$SESSION_ID
# Verify architecture-spec.md exists in the current directory
cp architecture-spec.md .forge/$SESSION_ID/architecture-spec.md
```
2) Initialize `.forge/$SESSION_ID/STATE.md` with "STATE 1". Update this file at the start of every subsequent state.

---

## STATE 1: THE DECOMPOSER (Molecular Shredding)
**Action:** Launch `decomposer` Sub-Agent via the `Task` tool.
**Prompt:** "Load the `decomposer` skill. Read `.forge/<session-id>/architecture-spec.md`. Run your deterministic pipeline (Draft -> Iron Shredder review -> Repair). Output the final JSON task array to `.forge/<session-id>/final-tasks.json`. Note that for large Epics, this may result in dozens or even hundreds of tasks."
**Gate:** The Orchestrator MUST verify the file exists (`ls .forge/<session-id>/final-tasks.json`). If missing, fail-closed.

---

## STATE 2: THE PLANNER (Bead Persistence)
**Action:** Execute the Planner deterministic script directly via `Bash`.
```bash
P="$HOME/.claude/skills/planner/planner.nu"
# Pass the architecture spec in as the description using a HEREDOC
nu $P init --session-id $SESSION_ID --description "$(cat .forge/$SESSION_ID/architecture-spec.md)"

# Load the tasks directly from jq iteration to add-task
cat .forge/$SESSION_ID/final-tasks.json | jq -c '.[]' | while read task; do
  echo "$task" | nu $P add-task $SESSION_ID -
done

# Process, validate, and create the beads
nu $P process $SESSION_ID
nu $P report $SESSION_ID
```
**Gate:** Verify the Planner script executed successfully and beads were persisted to the database.

---

## STATE 3: SUCCESS
Output to the user:
```
Spec-to-Beads complete. The architecture spec has been shredded into molecular tasks, validated by the Iron Shredder, and persisted by the Planner. 
Run `bd ready` to see the work.
```

Base directory for this skill: file:///home/lewis/.claude/skills/spec-to-beads
