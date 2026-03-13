# Phase 0: COMPLEXITY TRIAGE

## Purpose

Assess bead complexity to route to appropriate workflow depth. This phase prevents wasting tokens on simple tasks that don't need full 15-phase rigor.

## Token Savings

| Complexity | Phases | Approx Token Savings |
|------------|--------|---------------------|
| SIMPLE | 6 | ~60% |
| MEDIUM | 10 | ~35% |
| COMPLEX | 16 | 0% (full workflow) |

## Assessment Criteria

### Criteria Count
- **1-2 criteria**: SIMPLE
- **3-4 criteria**: MEDIUM
- **5+ criteria**: COMPLEX

### File Estimate
- **Single file**: SIMPLE
- **2-3 files**: MEDIUM
- **4+ files**: COMPLEX

### Dependency Depth
- **None**: SIMPLE
- **Light (1-2 deps)**: MEDIUM
- **Deep (3+ deps)**: COMPLEX

### Integration Surface
- **Narrow (internal only)**: SIMPLE
- **Moderate (touches 1-2 systems)**: MEDIUM
- **Wide (touches 3+ systems)**: COMPLEX

## Execution

```bash
# Read bead context
bd show <bead-id> --json

# Assess and classify
# Write result to cache
mkdir -p .tdd15-cache/<bead-id>
```

## Output Format

Write to `.tdd15-cache/<bead-id>/phase-0-triage.md`:

```markdown
## Complexity Assessment
- Criteria count: N
- File estimate: N
- Dependency depth: low/medium/high
- Integration surface: narrow/moderate/wide

## Classification: SIMPLE|MEDIUM|COMPLEX

## Route
Phases: [list]
Skip: [list]
```

## Routing Tables

### SIMPLE (6 phases)
```
0 → 4 → 5 → 6 → 14 → 15
```
- Triage → RED → GREEN → REFACTOR → Code Liability → Landing

### MEDIUM (10 phases)
```
0 → 1 → 2 → 4 → 5 → 6 → 7 → 9 → 11 → 15
```
- Triage → Research → Plan → RED → GREEN → REFACTOR → MF#1 → Verify Criteria → QA → Landing

### COMPLEX (16 phases)
```
0 → 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10 → 11 → 12 → 13 → 14 → 15
```
- Full workflow with all quality gates

## Gate

**Name**: `complexity_assessed`

**Pass criteria**: Valid classification (SIMPLE, MEDIUM, or COMPLEX) with explicit routing

**Self-heal**: If classification unclear, default to MEDIUM

## Examples

### SIMPLE Example
```
Bead: "Add status icon to success message"
- Criteria: 1 (add icon)
- Files: 1 (output.gleam)
- Dependencies: None
- Integration: Narrow

Classification: SIMPLE
Route: 0 → 4 → 5 → 6 → 14 → 15
```

### MEDIUM Example
```
Bead: "Add JSON output flag to check command"
- Criteria: 3 (parse flag, format output, handle errors)
- Files: 2 (intent.gleam, output.gleam)
- Dependencies: Light (glint)
- Integration: Moderate

Classification: MEDIUM
Route: 0 → 1 → 2 → 4 → 5 → 6 → 7 → 9 → 11 → 15
```

### COMPLEX Example
```
Bead: "Implement interview command with state persistence"
- Criteria: 8 (5 rounds, state management, export, resume)
- Files: 6 (interview.gleam, interview_storage.gleam, spec_builder.gleam, ...)
- Dependencies: Deep (sqlite, json, file I/O)
- Integration: Wide (CLI, storage, spec generation)

Classification: COMPLEX
Route: 0 → 1 → 2 → 3 → 4 → 5 → 6 → 7 → 8 → 9 → 10 → 11 → 12 → 13 → 14 → 15
```

## Notes

- When in doubt, classify higher (MEDIUM over SIMPLE, COMPLEX over MEDIUM)
- Simple classification errors waste tokens; complex classification errors waste time
- Triage happens inline (no subagent needed) to minimize overhead

## Nu Backbone
- Start: `tdd15 phase-start <session> 0`
- Gate: `tdd15 gate-check <session> 0 '<result>'`
- Model/threshold may escalate on retry: `tdd15 model <session> 0`, `tdd15 threshold <session> 0`
