---
name: tdd15-phase-14-code-liability
description: PHASE 14 CODE LIABILITY - Minimize code by deleting unused code, over-engineering, premature abstractions, and dead code. Reduce to essentials.
allowed-tools: Read,Write,Edit,Glob,Grep,Bash
model: sonnet
user-invocable: false
---

# Phase 14: CODE LIABILITY

## Phase Purpose

Minimize code to essentials, reducing maintenance burden:
1. Delete unused functions and variables
2. Remove over-engineered abstractions
3. Eliminate dead code paths
4. Simplify redundant logic
5. Reduce overall complexity

**Principle**: Less code = less to maintain, test, and debug.

## Execution Steps

### Step 1: Identify Unused Code

Scan for unused exports:

```bash
# Find potentially unused functions
grep -rn "pub fn" src/intent/my_feature.gleam
grep -rn "pub type" src/intent/my_feature.gleam
```

For each public item, verify it's used:
- [ ] Referenced in other modules?
- [ ] Tested in test file?
- [ ] Part of public API (should be)?
- [ ] Can be marked private?

Example analysis:
```gleam
// src/intent/email_validator.gleam

pub fn validate(s: String) -> Result(Email, Error) { ... }
// ✓ Used in tests: YES
// ✓ Used in other modules: YES
// ✓ Part of public API: YES
// Decision: KEEP

pub fn internal_parse(s: String) -> Result(String, Error) { ... }
// ✓ Used in tests: NO
// ✓ Used in other modules: NO
// ✓ Part of public API: NO
// Decision: MAKE PRIVATE or DELETE

pub type ValidationOptions {
  ValidationOptions(max_length: Int, allow_unicode: Bool)
}
// ✓ Used in tests: NO
// ✓ Used in other modules: NO
// ✓ Part of public API: NO (never passed to public functions)
// Decision: DELETE (unused over-engineering)
```

### Step 2: Remove Dead Code

Delete unused code:

```gleam
// BEFORE: Dead code
pub fn validate(s: String) -> Result(Email, Error) {
  case parse(s) {
    Ok(parsed) -> {
      // Never executed (always returns above)
      unreachable_helper(parsed)
      Ok(Email(parsed))
    }
    Error(e) -> Error(e)
  }
}

fn unreachable_helper(s: String) -> String {
  s  // Never called
}

// AFTER: Dead code removed
pub fn validate(s: String) -> Result(Email, Error) {
  case parse(s) {
    Ok(parsed) -> Ok(Email(parsed))
    Error(e) -> Error(e)
  }
}
```

### Step 3: Delete Over-Engineered Abstractions

Look for single-use helpers:

```gleam
// BEFORE: Over-engineered for one use
fn create_email_validator_config(s: String) -> Config {
  Config(max_length: 254, allow_unicode: True)
}

pub fn validate(s: String) -> Result(Email, Error) {
  let config = create_email_validator_config(s)  // Only used here!
  do_validate(s, config)
}

// AFTER: Simplify
pub fn validate(s: String) -> Result(Email, Error) {
  do_validate(s, Config(max_length: 254, allow_unicode: True))
}
```

### Step 4: Remove Redundant Logic

Consolidate duplicate patterns:

```gleam
// BEFORE: Redundant error handling
pub fn validate_email(s: String) -> Result(Email, Error) {
  case parse_email(s) {
    Ok(e) -> Ok(e)
    Error(e) -> Error(ParseFailed(e))
  }
}

pub fn validate_phone(s: String) -> Result(Phone, Error) {
  case parse_phone(s) {
    Ok(p) -> Ok(p)
    Error(e) -> Error(ParseFailed(e))
  }
}

// AFTER: Use generic pattern (Result.map_error)
pub fn validate_email(s: String) -> Result(Email, Error) {
  parse_email(s)
  |> result.map_error(ParseFailed)
}

pub fn validate_phone(s: String) -> Result(Phone, Error) {
  parse_phone(s)
  |> result.map_error(ParseFailed)
}
```

### Step 5: Make Private What Should Be Private

Change public to private:

```gleam
// BEFORE: Public but not part of API
pub fn validate(s: String) -> Result(Email, Error) { ... }
pub fn internal_helper(e: Email) -> Bool { ... }  // Not for external use

// AFTER: Explicit about public API
pub fn validate(s: String) -> Result(Email, Error) { ... }
fn internal_helper(e: Email) -> Bool { ... }  // Private helper
```

### Step 6: Simplify Type Definitions

Remove unused type variants:

```gleam
// BEFORE: Unused variant
pub type ValidationError {
  TooShort
  TooLong
  InvalidCharacters
  UnknownError  // Never used
}

// AFTER: Only what's needed
pub type ValidationError {
  TooShort
  TooLong
  InvalidCharacters
}
```

### Step 7: Verify Tests Still Pass

```bash
gleam test
# All tests should still pass
```

Record:
- [ ] No test failures
- [ ] Same test count passing
- [ ] No new warnings

### Step 8: Final Code Review

```bash
gleam build
gleam format
```

Verify:
- [ ] Builds cleanly
- [ ] No warnings
- [ ] Code formatted
- [ ] Reduced complexity

### Step 9: Create Minimization Report

```
PHASE 14 CODE LIABILITY REPORT
═════════════════════════════════════════

Minimization Actions:

Deleted Functions: 3
- internal_parse() - unused
- create_config() - single use
- unused_helper() - dead code

Deleted Types: 1
- ValidationOptions - never used

Simplified Logic: 2
- validate_email() - removed duplicate pattern
- validate_phone() - consolidated error handling

Made Private: 4
- internal_helper() - internal only
- parse_stage_1() - internal step
- parse_stage_2() - internal step
- validate_impl() - internal helper

Code Reduction:
- Before: 150 LOC
- After: 95 LOC
- Reduction: 37% ✓

Complexity:
- Cyclomatic complexity: 8 → 5
- Max function depth: 4 → 3

Verification:
- Tests: 15/15 PASS ✓
- Build: Clean ✓
- Warnings: 0 ✓

Status: ✓ CODE MINIMIZED
```

## Gate: minimized

**Pass Criteria**:
- [ ] Unused code removed
- [ ] Dead code deleted
- [ ] Over-engineering removed
- [ ] Single-use helpers consolidated
- [ ] All tests still passing
- [ ] Build succeeds with no warnings
- [ ] Code still readable (not over-minified)
- [ ] Complexity reduced

**Halt Criteria**:
- Tests fail after minimization
- Code becomes unreadable
- Core functionality removed

**On Failure**:
```
Phase 14 CODE LIABILITY FAILED

Issue: [What went wrong]
Tests failing: [Which tests]

Action: Restore deleted code and reanalyze
```

**On Success**: Advance to Phase 15 LANDING

## Minimization Checklist

- [ ] Identified all unused functions
- [ ] Deleted unused public functions (or made private)
- [ ] Removed dead code paths
- [ ] Consolidated single-use helpers
- [ ] Simplified redundant patterns
- [ ] Removed unused type variants
- [ ] Made internal functions private
- [ ] Tests all pass
- [ ] Build succeeds
- [ ] Code still maintainable

## Common Patterns to Remove

| Anti-Pattern | Example | Fix |
|--------------|---------|-----|
| Single-use helper | `create_config()` called once | Inline the logic |
| Wrapper function | `pub fn f(x) { helper(x) }` | Remove wrapper |
| Unused variant | Error type with never-used case | Delete variant |
| Dead code | Code after return | Remove code |
| Unused type | Custom type never used | Delete type |
| Over-abstraction | Helper for simple operation | Simplify |

## Integration Points

**Phase 13**: Prerequisite (consistency passed)
**Tests**: All Phase 4-6 tests must pass
**Files**: Modifies src/intent/<feature>.gleam
**Next Phase**: Phase 15 LANDING (git commit and push)

## Notes

- Minimization = remove waste, not necessary features
- Less code is easier to maintain
- Every line should earn its place
- Tests prove minimization didn't break anything
- This is last code change before landing

## Nu Backbone
- Start: `tdd15 phase-start <session> 14`
- Gate: `tdd15 gate-check <session> 14 '<result>'`
- Model/threshold may escalate on retry: `tdd15 model <session> 14`, `tdd15 threshold <session> 14`
