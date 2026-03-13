---
name: tdd15-phase-03-verify
description: PHASE 3 VERIFY - User approval checkpoint. Presents plan for review, handles clarification questions, confirms alignment before code starts.
allowed-tools: Read,Bash
model: sonnet
user-invocable: false
---

# Phase 3: VERIFY

## Phase Purpose

Confirm user alignment on the implementation plan before code work begins:
1. Present the plan from Phase 2 clearly
2. Ask clarifying questions if ambiguities exist
3. Get explicit user approval to proceed
4. Allow user to request adjustments
5. Lock in the plan for Phases 4-14

## Execution Steps

### Step 1: Present Phase 2 Plan

Display the plan in a readable format:
```
═══════════════════════════════════════════════════════════
IMPLEMENTATION PLAN: [Feature Title]
═══════════════════════════════════════════════════════════

Success Criteria:
  ✓ Criterion 1 (addressed by Steps A, B)
  ✓ Criterion 2 (addressed by Steps C, D)

Implementation Steps:
  1. [Step A] (~15 min)
     → What: [Description]
     → File: [Path]
     → Success Check: [Verification]

  2. [Step B] (~10 min)
     → ...

Files to Modify/Create:
  src/intent/feature.gleam (create)
  src/intent/checker.gleam (modify)
  test/feature_test.gleam (create)

Key Architectural Decisions:
  - Error handling: [Decision]
  - Module organization: [Decision]

Robot Insights:
  - Critical path: [Steps]
  - PageRank: [Key modules]
```

### Step 2: Check for Ambiguities

Identify potential questions:
- Are any success criteria unclear?
- Are implementation steps too vague?
- Are file modifications well-defined?
- Are architectural decisions justified?
- Any missing edge cases?

### Step 3: Ask User Questions

Use AskUserQuestion with primary question:

```
question: "Does this implementation plan address all success criteria and look good to proceed?"
header: "Plan Review"
options: [
  {label: "Yes, proceed", description: "Plan is clear and covers all requirements"},
  {label: "No, needs changes", description: "I want to adjust the approach"}
]
```

### Step 4: Handle "No" Response

If user selects "No, needs changes":

Ask follow-up:
```
question: "What needs to change?"
header: "Clarification"
options: [
  {label: "Success criteria not covered", description: "Plan misses some requirements"},
  {label: "Too many/few steps", description: "Steps are too granular or too large"},
  {label: "Wrong file modifications", description: "Architecture doesn't match my vision"},
  {label: "Missing architectural decision", description: "Need to discuss approach"},
  {label: "Other", description: "Something else not listed"}
]
```

**On clarification need**: Request user input and note as adjustment request for Phase 2 replan

### Step 5: Handle "Yes" Response

If user selects "Yes, proceed":

Confirm lock-in:
```
✓ Plan approved and locked
✓ Ready to enter TDD cycle (Phase 4)
✓ Further architectural changes require explicit request
```

Store plan in persistent context for Phases 4-14.

### Step 6: Prepare for Phase 4

Initialize for TDD cycle:
```bash
# Verify workspace is ready
jjz list  # Check workspace exists (created after this approval)

# Document approval
echo "Plan approved at $(date)" >> .phase-3-approval
```

## Gate: user_approval

**Pass Criteria**:
- [ ] Plan clearly presented to user
- [ ] User explicitly approved the plan
- [ ] All success criteria acknowledged
- [ ] User confirmed no major revisions needed
- [ ] Ready to proceed with RED phase

**Halt Criteria**:
- User rejects the plan
- Significant ambiguities in plan
- Success criteria conflicts not resolved
- Plan contradicts user requirements

**On Failure**:
```
Phase 3 VERIFY FAILED: User did not approve plan
Reason: [User feedback]
Action: Return to Phase 2 PLAN for revision
```

**On Success**: Advance to Phase 4 RED (TDD cycle begins)

## User Interaction Patterns

### Pattern 1: Approval
```
User: "Yes, proceed"
Response: "✓ Plan locked. Advancing to Phase 4 (RED - write failing tests)"
```

### Pattern 2: Clarification Request
```
User: "No, needs changes" → "Too many/few steps"
Response: "Understood. Let's adjust:
  Current plan has 8 steps.
  How many steps would be more appropriate?
  (or: which steps should be combined/split?)"
```

### Pattern 3: Architectural Concern
```
User: "No, needs changes" → "Wrong file modifications"
Response: "I see. Let me understand your preference:
  Should we create a new module or add to an existing one?
  Do you have a different architectural pattern in mind?"
```

## Output Format

Store approval status:
```
PHASE 3 VERIFICATION RESULT
─────────────────────────────
Status: APPROVED
User Response: "Yes, proceed"
Timestamp: 2026-01-18T13:25:00Z
Plan Hash: [Phase 2 plan identifier]
Lock Status: ✓ LOCKED
Next Phase: Phase 4 RED

[Full plan copy for reference]
```

## Integration Points

**Phase 2**: Consumes PLAN output
**Beads**: Records approval reason
**AskUserQuestion**: Gets user input
**Next Phase**: Locked plan feeds into Phase 4 RED

## Notes

- Phase 3 is a hard checkpoint: can't proceed without user approval
- If user says "no", return to Phase 2 for redesign
- Progressive disclosure: show plan first, ask follow-up questions if needed
- Lock the plan after approval (prevents mid-workflow scope creep)
- User can always request changes explicitly in later phases, but it will be documented as scope change

## Nu Backbone
- Start: `tdd15 phase-start <session> 3`
- Gate: `tdd15 gate-check <session> 3 '<result>'`
- Model/threshold may escalate on retry: `tdd15 model <session> 3`, `tdd15 threshold <session> 3`
