---
name: tdd15-phase-02-plan
description: PHASE 2 PLAN - Design implementation approach covering all success criteria. Produces step-by-step plan, files to modify, component designs, and architectural decisions.
allowed-tools: Read,Write,Edit,Glob,Grep,Bash,Task
model: sonnet
user-invocable: false
---

# Phase 2: PLAN

## Phase Purpose

Design the implementation approach for the feature, covering:
1. Step-by-step implementation plan
2. Files to create/modify with rationale
3. Component designs and data flows
4. Build sequence and dependencies
5. Key architectural decisions
6. Risk mitigation strategies
7. Robot insights (PageRank, Betweenness Centrality)

## Execution Steps

### Step 1: Parse Phase 1 Research Output

Read research context from Phase 1:
- Related implementations and patterns
- Test structure and conventions
- CLI consistency patterns
- Module dependencies
- Success criteria

### Step 2: Design Implementation Steps

For each success criterion, create:
- **Atomic step**: Smallest unit of work
- **Success check**: How to verify this step is done
- **Dependencies**: What must be done first
- **Estimated scope**: 5-30 min per step
- **Risks**: What could go wrong

Map dependencies:
```
Success Criterion 1 → Step A → Step B → Step C
Success Criterion 2 → Step D → depends on Step A
...
```

### Step 3: Identify Files to Modify/Create

For each step, specify:
- **File path**: Exact location
- **Action**: create/modify/delete
- **Scope**: What changes (new functions, types, tests)
- **Rationale**: Why this file
- **Example**: Pseudocode or structure

Example:
```
src/intent/my_feature.gleam
- Action: Create
- Scope: New module with public types and functions
- Rationale: Core feature logic
- Structure:
  pub type MyType { ... }
  pub fn do_thing(input: String) -> Result(String, Error)
```

### Step 4: Design Data Flows

Create flow diagrams showing:
- Input data and types
- Transformation steps
- Output data and types
- Error paths

Example:
```
Request (String)
  → Parse (Result)
  → Validate (Result)
  → Process (Result)
  → Format (String)
  → Response
```

### Step 5: Document Architectural Decisions

For each decision, record:
- **Decision**: What is being decided
- **Options considered**: At least 2 alternatives
- **Choice**: Which option and why
- **Tradeoffs**: What we're giving up
- **Reversibility**: Can this be changed later?

Example:
```
Decision: Error handling for network timeouts
Options:
  1. Retry with exponential backoff
  2. Fail immediately
  3. Async retry in background
Chosen: Option 1 (recoverable, matches existing patterns)
Tradeoff: Increased latency in error cases
Reversibility: Yes, error handling can be changed
```

### Step 6: Get Robot Insights

```bash
bv --robot-insights --json-out phase2-insights.json
```

Parse and incorporate:
- PageRank analysis (which modules are central)
- Betweenness Centrality (which modules bridge others)
- Critical path analysis
- Parallelizable work

### Step 7: Validate Against Success Criteria

Verify each success criterion is addressed:
```
✓ Success Criterion 1 - addressed by Steps A, B, C
✓ Success Criterion 2 - addressed by Steps D, depends on A
...
```

If any criterion is missing, go back and add steps.

## Gate: plan_verified

**Pass Criteria**:
- [ ] All success criteria are addressed
- [ ] Implementation steps are atomic (5-30 min each)
- [ ] Files and changes are clearly specified
- [ ] Data flows documented with examples
- [ ] Architectural decisions recorded with rationale
- [ ] Dependencies form a DAG (no cycles)
- [ ] Robot insights incorporated
- [ ] Plan is understandable and executable

**Halt Criteria**:
- Success criteria not fully covered
- Circular dependencies detected
- Ambiguous steps that can't be clearly executed
- Missing critical architectural decisions
- No clear file modifications specified

**On Failure**: Output missing criteria and request clarification

**On Success**: Plan ready for Phase 3 user approval

## Output Format

Return implementation plan as structured document:
```
# IMPLEMENTATION PLAN: <Feature Title>

## Success Criteria Coverage
- [ ] Criterion 1 → Steps A, B
- [ ] Criterion 2 → Steps C, D
...

## Implementation Steps (Ordered)
1. **Step A**: [Description] (~15 min)
   - What: [Specific change]
   - File: src/...
   - Success Check: [How to verify]
   - Dependencies: [Steps it depends on]

2. **Step B**: [Description] (~10 min)
   - ...

## Files to Modify
| File | Action | Scope |
|------|--------|-------|
| src/... | create | New module |
| src/... | modify | Add function |

## Data Flows
[ASCII diagram showing transformations]

## Architectural Decisions
1. Error handling: [Decision with rationale]
2. Module organization: [Decision with rationale]

## Robot Insights
- PageRank: [Key modules]
- Critical Path: [Longest dependency chain]

## Risks & Mitigation
- Risk 1: [Mitigation]
- Risk 2: [Mitigation]
```

## Integration Points

**Beads**: Reads bead success_criteria
**Phase 1**: Consumes RESEARCH output
**Robot Mode**: Runs `bv --robot-insights`
**Next Phase**: Output feeds into Phase 3 VERIFY

## Notes

- Plan should be detailed enough to hand to another developer
- Err on the side of more steps (easier to combine) than fewer
- Document assumptions and decisions clearly
- Robot insights provide prioritization guidance
- Plan is proposal, not gospel—Phase 3 user can request changes

## Nu Backbone
- Start: `tdd15 phase-start <session> 2`
- Gate: `tdd15 gate-check <session> 2 '<result>'`
- Model/threshold may escalate on retry: `tdd15 model <session> 2`, `tdd15 threshold <session> 2`
