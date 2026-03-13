---
name: tdd15-phase-01-research
description: PHASE 1 RESEARCH - Codebase exploration and pattern discovery. Understands existing patterns, dependencies, test structure, and CLI conventions related to the feature.
allowed-tools: Read,Write,Edit,Glob,Grep,Bash,Task
model: sonnet
user-invocable: false
---

# Phase 1: RESEARCH

## Phase Purpose

Explore and understand the codebase to identify:
1. Existing patterns related to the feature
2. Files and modules that depend on or relate to this work
3. Current implementation conventions (modules, types, error handling)
4. Test structure and testing patterns
5. CLI consistency patterns (emoji_constants, cli_flags, error_handler, formatter_utils)

## Execution Steps

### Step 1: Load Bead Context
```bash
bd show <bead-id> --json
```
Extract and understand:
- Feature title and description
- Success criteria (what defines "done")
- EARS patterns (ubiquitous, event, state, unwanted)
- Database contracts (DbC) if applicable

### Step 2: Research Related Code

**Find related files by pattern**:
```
Glob("src/**/*.gleam")
Grep("pattern from bead.title")
```

Identify:
- Similar features already implemented
- Existing modules this will depend on
- Types and data structures used in similar contexts
- Error handling patterns

### Step 3: Analyze Test Conventions

**Examine test structure**:
```bash
ls -la test/
grep -r "pub fn test" src/
```

Document:
- Test naming conventions
- Test utilities and helpers
- Mock/fixture patterns
- Test organization (unit/integration/e2e)

### Step 4: CLI Consistency Patterns

**Check for existing usage**:
```gleam
// Verify these modules exist and understand their patterns:
import intent/emoji_constants as emoji
import intent/cli_flags
import intent/error_handler
import intent/formatter_utils
```

Document:
- How emoji constants are used
- Flag builder patterns
- Error formatting conventions
- Output formatting patterns

### Step 5: Module Dependencies

**Analyze module topology**:
```
Grep("pub type", "src/**/*.gleam")
Grep("pub fn", "src/**/*.gleam")
```

Map:
- Public types and their fields
- Public functions and their signatures
- Module dependencies
- Potential circular dependencies

## Gate: sufficient_context

**Pass Criteria**:
- [ ] Codebase patterns understood and documented
- [ ] Related code identified and reviewed
- [ ] Test structure understood
- [ ] CLI consistency patterns verified
- [ ] Module topology mapped
- [ ] At least 3 related existing implementations found

**Halt Criteria**:
- Insufficient related code found
- Unable to understand existing patterns
- Core modules missing or inaccessible
- Contradictory conventions discovered

**On Failure**: Output diagnostic report showing what context was insufficient

**On Success**: Store research findings in TodoWrite context for Phase 2

## Output Format

Return research findings as structured context:
```
# RESEARCH FINDINGS

## Related Implementations
- [File] - [Purpose] - [Key Types]
- ...

## Test Patterns
- [Convention] - [Example]
- ...

## CLI Consistency Usage
- emoji_constants: [Used in X modules]
- cli_flags: [Patterns observed]
- error_handler: [Error format]
- formatter_utils: [Output format]

## Module Dependencies
- [Module] depends on [Module]
- ...

## Success Criteria
- [From bead]
```

## Integration Points

**Beads**: Reads bead definition, understands EARS/DbC
**ZJJ**: No workspace yet (created after approval in Phase 3)
**Next Phase**: Output feeds into Phase 2 PLAN

## Notes

- Non-blocking research: any incomplete findings don't halt
- Progressive discovery: Phase 2 can request more details
- Focus on breadth first: understand the landscape before diving deep
- Document conventions, not just code snippets

## Nu Backbone
- Start: `tdd15 phase-start <session> 1`
- Gate: `tdd15 gate-check <session> 1 '<result>'`
- Model/threshold may escalate on retry: `tdd15 model <session> 1`, `tdd15 threshold <session> 1`
