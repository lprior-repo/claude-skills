---
name: tdd15-phase-10-interrogate
description: PHASE 10 INTERROGATE - Adversarial FP review with omarchy. Detects immutability violations, side effects, panic risks, and FP principle breaches. Creates discovered-from beads.
allowed-tools: Read,Bash,Task
model: sonnet
user-invocable: false
---

# Phase 10: INTERROGATE

## Phase Purpose

Adversarial review for functional programming violations:
1. Run omarchy for hostile FP review
2. Identify immutability violations
3. Detect side effects and panic risks
4. Find Railway-Oriented Programming failures
5. Create beads for discovered issues

## Execution Steps

### Step 1: Run Omarchy Review

```bash
Skill(skill: "omarchy", args: "<feature-module>")
```

Omarchy analyzes:
- **Immutability**: Mutable state, reassignments
- **Pure functions**: Side effects, I/O in business logic
- **Error handling**: Unwrap() calls, panic risks
- **Railway-Oriented**: Error propagation patterns
- **Type-driven**: Type safety and guarantees

### Step 2: Parse Omarchy Output

Expected findings (examples):
```
OMARCHY REVIEW: intent_email_validator

SEVERITY CRITICAL (0):
  None found ✓

SEVERITY HIGH (2):
  1. File: src/intent/email_validator.gleam:15
     Issue: Potential unwrap on Result
     Code: let value = result.unwrap(parse_result)
     Fix: Use result.try() or result.map() instead

  2. File: src/intent/email_validator.gleam:42
     Issue: Side effect (I/O) in validation function
     Code: io.println("Validating...")
     Fix: Move logging outside of validation logic

SEVERITY MEDIUM (3):
  1. Exhaustive match not verified for Error type
  ...

SEVERITY LOW (1):
  1. Redundant error conversion
  ...
```

### Step 3: Categorize Findings

By severity:
- **CRITICAL**: Blocks Phase 10 gate
- **HIGH**: Should fix, creates discovered beads
- **MEDIUM**: Should fix, creates discovered beads
- **LOW**: Optional improvements, creates beads

### Step 4: Fix Critical Issues (if any)

If CRITICAL issues found:
1. Stop interrogation
2. Fix the issue
3. Re-run omarchy verification
4. Continue

### Step 5: Create Discovered Beads

For HIGH, MEDIUM, and LOW findings, create beads:

```bash
# For each finding:
bd create \
  --title "Fix: [Issue description]" \
  --type task \
  --priority 2 \
  --deps "discovered-from:beads-<original-bead-id>"
```

Example:
```bash
bd create \
  --title "Fix: Remove unwrap() in email validation" \
  --type task \
  --priority 2 \
  --deps "discovered-from:beads-abc123"

bd create \
  --title "Fix: Remove I/O side effect from validate_email" \
  --type task \
  --priority 2 \
  --deps "discovered-from:beads-abc123"
```

### Step 6: Document Findings

Create omarchy report:
```
PHASE 10 INTERROGATE REPORT
═════════════════════════════════════════

Original Bead: beads-abc123 (Email validation feature)
Review Tool: omarchy (FP principle verification)
Review Date: 2026-01-18T13:45:00Z

Findings Summary:
- Critical: 0 (PASS)
- High: 2 (created beads for fixes)
- Medium: 1 (created bead for improvement)
- Low: 0 (acceptable)

Issues Found:
1. [HIGH] Unwrap in email_validator.gleam:15
   → Created beads-discovered-001
   → "Fix: Remove unwrap() in email validation"

2. [HIGH] I/O side effect in validate_email
   → Created beads-discovered-002
   → "Fix: Remove I/O logging from validate_email"

3. [MEDIUM] Non-exhaustive Error handling
   → Created beads-discovered-003
   → "Improve: Add comprehensive error matching"

Discovered Beads:
- beads-discovered-001: discovered-from:beads-abc123
- beads-discovered-002: discovered-from:beads-abc123
- beads-discovered-003: discovered-from:beads-abc123

Next Steps:
- These beads are non-blocking for current bead closure
- Prioritize High-severity beads
- Schedule for future work cycles
```

## Gate: no_critical_issues

**Pass Criteria**:
- [ ] Omarchy review completed
- [ ] No CRITICAL severity issues found
- [ ] HIGH and MEDIUM issues documented
- [ ] Beads created for discovered issues
- [ ] FP principles mostly adhered to

**Halt Criteria**:
- CRITICAL severity issue found
- Panic risk or major FP violation
- Unrecoverable error handling issue

**On Failure**:
```
Phase 10 INTERROGATE FAILED

Critical FP Violations:
- [Issue]: [Why it's critical]

Action: Fix critical issue and re-run omarchy
```

**On Success**: Advance to Phase 11 QA

## Discovered Beads Semantics

The `discovered-from:<id>` dependency:
- Indicates genealogy (where the work came from)
- Doesn't block original bead from closing
- Lets team see full context of related work
- Non-blocking: original bead completes, discovered work queued

Example workflow:
```
beads-abc123 (original): CLOSE
└─→ Discovered during Phase 10:
    ├─ beads-discovered-001 (blocked by nothing)
    ├─ beads-discovered-002 (blocked by nothing)
    └─ beads-discovered-003 (blocked by nothing)

All discovered beads enter backlog for future cycles
```

## Integration Points

**Phase 9**: Prerequisite: success criteria met
**Skill**: Invokes omarchy for FP review
**Beads**: Creates discovered-from dependencies
**Next Phase**: Phase 11 QA (behavior testing)

## Notes

- Omarchy is adversarial: it's looking for problems
- FP principles enable maintainability
- High issues should be fixed; Medium/Low are backlog-worthy
- Discovered beads don't block current bead closure
- This phase reveals technical debt for future work

## Nu Backbone
- Start: `tdd15 phase-start <session> 10`
- Gate: `tdd15 gate-check <session> 10 '<result>'`
- Model/threshold may escalate on retry: `tdd15 model <session> 10`, `tdd15 threshold <session> 10`
