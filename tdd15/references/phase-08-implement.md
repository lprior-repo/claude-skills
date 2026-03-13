---
name: tdd15-phase-08-implement
description: PHASE 8 IMPLEMENT - Complete feature with all behaviors. Apply CLI consistency standards (emoji_constants, cli_flags, error_handler, formatter_utils). Follow Gleam 7 Commandments.
allowed-tools: Read,Write,Edit,Glob,Grep,Bash,Task
model: sonnet
user-invocable: false
---

# Phase 8: IMPLEMENT

## Phase Purpose

Complete the full feature implementation with all behaviors and standards:
1. Implement all remaining feature behaviors
2. Apply CLI consistency standards from CLAUDE.md
3. Follow Gleam 7 Commandments
4. Ensure integration with existing codebase
5. Prepare for verification in Phase 9

## Execution Steps

### Step 1: Review Locked Plan

Revisit Phase 3 approved plan:
- All steps to be completed
- File modifications and creation
- Architectural decisions

### Step 2: Implement All Behaviors

For each behavior in the feature:
```gleam
// Ensure implemented and tested
pub fn behavior_1(...) -> Result(...) { ... }
pub fn behavior_2(...) -> Result(...) { ... }
```

Verify:
- All public functions implemented
- All types complete and well-formed
- All error cases handled with Result types
- No panics, no unwrap() without reason

### Step 3: Apply CLI Consistency Standards

Check each module for CLAUDE.md compliance:

#### Standard 1: Emoji Constants
```gleam
// WRONG: Hardcoded emoji
let icon = "✓"

// RIGHT: From emoji_constants
import intent/emoji_constants as emoji
let icon = emoji.success
```

#### Standard 2: CLI Flags
```gleam
// Use cli_flags builders for all flag definitions
import intent/cli_flags
let target_flag = cli_flags.target_flag()
let json_flag = cli_flags.json_flag()
```

#### Standard 3: Error Handling
```gleam
// Use error_handler for all errors
import intent/error_handler

case result {
  Ok(value) -> Ok(value)
  Error(msg) -> {
    let error = error_handler.generic_error(
      msg,
      "Check spec file",
      ["Run validate", "Review error above"]
    )
    Error(error_handler.output_error(error, is_json))
  }
}
```

#### Standard 4: Output Formatting
```gleam
// Use formatter_utils for consistent output
import intent/formatter_utils as fmt

let header = fmt.box_header("Analysis Results")
let score = fmt.score_with_status(85.5)
let indent = fmt.indent_n(1)
```

### Step 4: Follow Gleam 7 Commandments

#### 1. Immutability
- No mutable state
- No refs or variables that change
- Use Result/List for transformations

#### 2. No Nulls
- Use Result(T, Error) for fallible operations
- Use Option(T) for optional values
- Never unwrap without justification

#### 3. Pipelines
- Use `|>` operator idiomatically
- Chain operations clearly
- Avoid nested function calls

#### 4. Exhaustive Matching
- Pattern match all cases
- Gleam compiler enforces this
- No catch-all patterns unless intentional

#### 5. Labeled Arguments
- Use labeled function arguments
- Makes call sites readable
- Gleam style

```gleam
// RIGHT: Labeled args
pub fn validate(value: String, max_length: Int, allow_unicode: Bool) -> Result(...) {
  ...
}

validate(value:, max_length: 256, allow_unicode: False)
```

#### 6. Type Safety
- Leverage Gleam's type system
- Create custom types instead of strings
- Use Result over Error codes

```gleam
// Custom type instead of String
pub type Email {
  Email(String)
}

pub fn validate_email(input: String) -> Result(Email, ValidationError) {
  case parse(input) {
    Ok(email) -> Ok(Email(email))
    Error(e) -> Error(InvalidEmail(e))
  }
}
```

#### 7. Formatting
- Run `gleam format` before completion
- Follows Gleam style guide
- Non-negotiable for production code

```bash
gleam format
```

### Step 5: Integration with Existing Codebase

- [ ] Module follows existing patterns
- [ ] Types align with project conventions
- [ ] Error types integrate with error_handler
- [ ] Functions compose with existing utilities
- [ ] No breaking changes to public APIs

### Step 6: Complete All Implementation Steps

Verify each step from locked plan is done:
```
Step 1: [Description] ✓ DONE
Step 2: [Description] ✓ DONE
Step 3: [Description] ✓ DONE
...
```

### Step 7: Run Full Test Suite

```bash
gleam test
# All tests pass
gleam build
# No warnings
gleam format --check
# No formatting issues
```

## Gate: implementation_complete

**Pass Criteria**:
- [ ] All feature behaviors implemented
- [ ] All CLI consistency standards applied
- [ ] All Gleam 7 Commandments followed
- [ ] All tests passing
- [ ] Build succeeds with no warnings
- [ ] Code formatted
- [ ] Integration with existing code verified
- [ ] No over-engineering or scope creep

**Halt Criteria**:
- Incomplete behaviors
- Standards not applied
- Tests failing
- Build warnings
- Over-complicated implementation

**On Failure**:
```
Phase 8 IMPLEMENT FAILED

Issues:
- [List of incomplete items]

Action: Complete remaining items
```

**On Success**: Advance to Phase 9 VERIFY SUCCESS CRITERIA

## Standards Checklist

- [ ] emoji_constants used (no hardcoded emojis)
- [ ] cli_flags builders used (no manual flag creation)
- [ ] error_handler used (all errors formatted)
- [ ] formatter_utils used (output formatting)
- [ ] No mutable state
- [ ] No null values (all Result/Option)
- [ ] Pipelines used idiomatically
- [ ] All patterns exhaustively matched
- [ ] Labeled arguments on functions
- [ ] Type safety leveraged
- [ ] Code formatted with gleam format

## Integration Points

**Phase 7**: Prerequisite completed
**CLAUDE.md**: Standards from CLI Consistency Standards section
**Files**: Modifies src/intent/<feature>.gleam and related modules
**Tests**: All Phase 4-6 tests must still pass
**Next Phase**: Phase 9 validates success criteria

## Notes

- This phase is comprehensive: implement everything needed
- Standards are non-optional—they're required for consistency
- After Phase 8, code is production-grade
- Don't skip formatting—Phase 13 will check anyway
- Integration matters: code should fit naturally in the project

## Nu Backbone
- Start: `tdd15 phase-start <session> 8`
- Gate: `tdd15 gate-check <session> 8 '<result>'`
- Model/threshold may escalate on retry: `tdd15 model <session> 8`, `tdd15 threshold <session> 8`
