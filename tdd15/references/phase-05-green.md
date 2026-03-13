---
name: tdd15-phase-05-green
description: PHASE 5 GREEN - Minimal implementation. Write the simplest code possible to make all tests pass. No optimization, no refactoring yet.
allowed-tools: Read,Write,Edit,Glob,Grep,Bash,Task
model: sonnet
user-invocable: false
---

# Phase 5: GREEN

## Phase Purpose

Write minimal implementation code to make all tests pass:
1. Simplest code possible to pass tests
2. No premature optimization
3. No refactoring
4. All tests should pass (GREEN state)
5. Minimal, focused implementations only

## Execution Steps

### Step 1: Analyze Test Failures

Review test output:
```bash
gleam test
```

For each failing test:
- Read the exact error message
- Understand what code is missing
- Note all failures

Example analysis:
```
Test: test_validate_email_accepts_valid_email
Error: Function not found: validate_email/1
Location: test/intent_email_validator_test.gleam:5

Fix Needed: Create validate_email function that returns Result(Email, Error)
```

### Step 2: Create Minimal Module Structure

Create the required module with simplest implementation:

```gleam
// src/intent/email_validator.gleam

pub type Email {
  Email(String)
}

pub type Error {
  InvalidEmail
}

pub fn validate_email(input: String) -> Result(Email, Error) {
  // Simplest implementation that might work
  case input {
    "" -> Error(InvalidEmail)
    s if string.contains(s, "@") -> Ok(Email(s))
    _ -> Error(InvalidEmail)
  }
}
```

**Principle**: Write the absolute minimum to pass the test.

### Step 3: Implement Function by Function

Go through each failing test:
1. Read what it expects
2. Write the minimal function
3. Run tests
4. Move to next failure

Don't:
- [ ] Optimize for performance
- [ ] Handle edge cases beyond what tests require
- [ ] Add extra error types
- [ ] Refactor or restructure
- [ ] Add comments

Do:
- [ ] Make tests pass
- [ ] Keep code simple
- [ ] Use obvious logic
- [ ] Follow Gleam basics (pattern matching, pipe operator)

### Step 4: Run Tests Frequently

After each implementation change:
```bash
gleam test
```

Track progress:
- X tests passing → continue
- All tests passing → Gate check
- New failures → understand why

### Step 5: Verify All Tests Pass

```bash
gleam test
# Expected: All tests pass (GREEN state)
```

Output should show:
```
Compiling intent v0.1.0
   Compiled successfully in X.XXs

Test results:
✓ test_validate_email_accepts_valid_email
✓ test_validate_email_rejects_invalid_email
✓ test_validate_email_handles_edge_case_plus_addressing

All tests passed!
```

### Step 6: Format Code

```bash
gleam format
```

Ensure code follows Gleam style guide (will be enforced in Phase 13).

### Step 7: Verify Build

```bash
gleam build
```

Ensure project builds cleanly:
- No unused imports
- No unused variables
- No warnings

## Gate: tests_pass

**Pass Criteria**:
- [ ] All tests pass (gleam test exit code 0)
- [ ] Code compiles cleanly (gleam build exit code 0)
- [ ] No compiler warnings
- [ ] Code formatted (gleam format passes)
- [ ] Minimal implementation (no over-engineering)
- [ ] Functions marked pub/priv correctly

**Halt Criteria**:
- Tests still failing
- Compilation errors
- Over-complicated implementation for what tests require
- Missing required type definitions

**On Failure**:
```
Phase 5 GREEN FAILED: Not all tests passing
Failing Tests:
- test_x (reason)
- test_y (reason)

Action: Fix implementations to pass tests
```

**On Success**: Advance to Phase 6 REFACTOR (clean up code)

## Implementation Checklist

- [ ] All public functions created and working
- [ ] All types defined (at least minimally)
- [ ] All error cases handled
- [ ] Tests run and pass
- [ ] Build succeeds
- [ ] No compiler warnings
- [ ] Code is readable (even if simple)

## Common Patterns

### Pattern 1: Simple Function
```gleam
pub fn add(a: Int, b: Int) -> Int {
  a + b
}
```

### Pattern 2: Result Type
```gleam
pub fn parse(input: String) -> Result(Value, Error) {
  case input {
    "" -> Error(EmptyInput)
    s -> Ok(Value(s))
  }
}
```

### Pattern 3: List Processing
```gleam
pub fn filter_valid(items: List(String)) -> List(String) {
  list.filter(items, fn(item) {
    string.length(item) > 0
  })
}
```

## Integration Points

**Phase 4**: Uses test specifications
**Files**: Creates src/intent/<feature>.gleam
**Tools**: gleam test, gleam build, gleam format
**Next Phase**: Phase 6 refactors this code while keeping tests green

## Notes

- Simplicity is the goal: YAGNI (You Ain't Gonna Need It)
- Tests pass → code is correct (for now)
- Refactoring happens in Phase 6, not here
- This phase is about making the spec executable
- Avoid premature optimization—Phase 6 is for cleanup

## Nu Backbone
- Start: `tdd15 phase-start <session> 5`
- Gate: `tdd15 gate-check <session> 5 '<result>'`
- Model/threshold may escalate on retry: `tdd15 model <session> 5`, `tdd15 threshold <session> 5`
