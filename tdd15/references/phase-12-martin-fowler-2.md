---
name: tdd15-phase-12-martin-fowler-2
description: PHASE 12 MARTIN FOWLER CHECK #2 - FINAL GATE. 13-question comprehensive quality checklist. HALT on any NO. Allows rewind to Phase 6, 8, or 11.
allowed-tools: Read,Bash
model: sonnet
user-invocable: false
---

# Phase 12: MARTIN FOWLER CHECK #2 (FINAL GATE)

## Phase Purpose

Comprehensive final quality gate using Martin Fowler principles:
1. Verify all 8 questions from Phase 7 still hold
2. Verify 5 new advanced quality questions
3. **HALT on any NO—this is the final gate before production**
4. Allow rewind to earlier phases if needed

This is the last stop before Phases 13-15 (consistency, minimization, landing).

## 13-Question Checklist

### Questions 1-8: Repeat Phase 7 Checks

These must still be true after Phases 8-11:

1. **Is this the simplest solution that works?**
   - Still no over-engineering?
   - All added code in Phases 8-11 justified?

2. **Has code been refactored for readability?**
   - Code still clean after Phase 11 testing?
   - Any test code duplicating main code?

3. **Do tests fully specify the behavior?**
   - Test coverage still comprehensive?
   - New behaviors from Phase 8 tested?

4. **Is the code readable without extensive comments?**
   - Any confusion about Phase 8 implementation?
   - Comments added only for "why", not "what"?

5. **Does a live demo work end-to-end?**
   - Manual testing in Phase 11 confirmed this?
   - Happy path flows smoothly?

6. **Have all success criteria been verified?**
   - Phase 9 verified all criteria?
   - Nothing was missed?

7. **Is the user experience smooth and intuitive?**
   - API changes from Phase 8 still intuitive?
   - Error messages still helpful?

8. **Are edge cases handled gracefully?**
   - Phase 11 edge case testing passed?
   - No regressions?

### Question 9: Does this integrate cleanly with the existing codebase?

**Purpose**: Verify no breaking changes, clean architectural fit.

**Check**:
- No breaking changes to public APIs
- Follows existing module organization patterns
- Error types integrate with error_handler
- Functions compose naturally with existing utilities
- No conflicting names or duplicated functionality

**Example: FAIL**
```gleam
// Breaks existing API
// Old signature: pub fn validate(String) -> Result(Email, Error)
// New signature: pub fn validate(String, config: Config) -> Result(Email, Config) // Changed!
```

**Example: PASS**
```gleam
// Extends existing functionality cleanly
pub fn validate(input: String) -> Result(Email, Error)
pub fn validate_with_config(input: String, config: Config) -> Result(Email, Error)
// New function, old function unchanged
```

### Question 10: Is the code debuggable if issues arise?

**Purpose**: Production code will need debugging; make it feasible.

**Check**:
- Error messages are helpful and specific
- Error types/variants are meaningful
- No "swallowing" errors with generic handling
- Stack traces (if any panics) would be helpful
- Code flow is traceable

**Example: FAIL**
```gleam
// Unhelpful error handling
pub fn process(input: String) -> Result(String, Error) {
  case parse(input) {
    Ok(x) -> Ok(x)
    Error(_) -> Error(GenericError)  // Lost context!
  }
}
```

**Example: PASS**
```gleam
// Clear error propagation
pub fn process(input: String) -> Result(String, ProcessError) {
  input
  |> parse()
  |> result.map_error(fn(e) { ParseFailed(e) })
  |> result.try(fn(x) { validate(x) })
  |> result.map_error(fn(e) { ValidationFailed(e) })
}
```

### Question 11: Is performance acceptable for production?

**Purpose**: Performance baseline from Phase 11 should be acceptable.

**Check**:
- No obvious bottlenecks
- Response times reasonable for use case
- Memory usage acceptable
- No N² algorithms for common operations
- Baseline established and acceptable

**Example: FAIL**
```gleam
// List flattening inside loop = N²
pub fn process_list(items: List(Item)) -> List(Result(...)) {
  list.map(items, fn(item) {
    list.flatten(all_items)  // O(n) inside loop = O(n²) total!
  })
}
```

**Example: PASS**
```gleam
// Compute once, reuse = O(n)
pub fn process_list(items: List(Item)) -> List(Result(...)) {
  let flat = list.flatten(all_items)
  list.map(items, fn(item) {
    process(item, flat)
  })
}
```

### Question 12: Will this be maintainable 6 months from now?

**Purpose**: Can a different developer maintain this without the original author?

**Check**:
- Code structure is obvious
- Naming is clear and consistent
- Dependencies are documented
- Edge cases are handled (no mysterious bugs)
- Style is consistent with codebase

**Example: FAIL**
```gleam
// Mystery: why this check? What edge case?
pub fn validate(s: String) -> Result(Email, Error) {
  case string.length(s) {
    x if x < 3 || x > 250 -> Error(LengthError)  // Why these numbers?
    _ -> case string.contains(s, "@") {
      True -> Ok(Email(s))
      False -> Error(NoAtSign)
    }
  }
}
```

**Example: PASS**
```gleam
// Clear intent and edge case reasoning
pub fn validate(s: String) -> Result(Email, Error) {
  // Email max length is 254 chars (RFC 5321)
  // Minimum reasonable length is 3 chars (a@b)
  case string.length(s) {
    x if x < 3 || x > 254 -> Error(InvalidLength)
    _ -> case string.contains(s, "@") {
      True -> Ok(Email(s))
      False -> Error(MissingAtSign)
    }
  }
}
```

### Question 13: Is each line of code necessary?

**Purpose**: Minimize complexity, maximize signal-to-noise ratio.

**Check**:
- No dead code (unused functions, variables)
- No redundant checks
- No unnecessary intermediate variables
- No over-engineering ("just in case" features)
- No commented-out code

**Example: FAIL**
```gleam
// Dead code and redundancy
pub fn validate(s: String) -> Result(Email, Error) {
  let trimmed = string.trim(s)  // Dead variable
  let len = string.length(trimmed)  // Unnecessary intermediate
  let result = case len > 0 {  // Redundant intermediate
    True -> case string.contains(trimmed, "@") {
      True -> Ok(Email(trimmed))
      False -> Error(NoAtSign)
    }
    False -> Error(Empty)
  }
  result
}
```

**Example: PASS**
```gleam
// Necessary code only
pub fn validate(s: String) -> Result(Email, Error) {
  s
  |> string.trim()
  |> fn(trimmed) {
    case string.contains(trimmed, "@") && string.length(trimmed) > 0 {
      True -> Ok(Email(trimmed))
      False -> Error(InvalidEmail)
    }
  }
}
```

## Gate: martin_fowler_2 (FINAL)

**Pass Criteria** (ALL must be YES):
- [ ] Question 1: Simplest solution? **YES**
- [ ] Question 2: Refactored for readability? **YES**
- [ ] Question 3: Tests specify behavior? **YES**
- [ ] Question 4: Readable without comments? **YES**
- [ ] Question 5: Live demo works? **YES**
- [ ] Question 6: Success criteria verified? **YES**
- [ ] Question 7: User experience smooth? **YES**
- [ ] Question 8: Edge cases handled? **YES**
- [ ] Question 9: Integrates cleanly? **YES**
- [ ] Question 10: Debuggable? **YES**
- [ ] Question 11: Performance acceptable? **YES**
- [ ] Question 12: Maintainable 6mo? **YES**
- [ ] Question 13: All lines necessary? **YES**

**Halt Criteria** (ANY failure halts):
- Any question answered NO
- Regression in Phase 7 questions

**On Failure**: HALT and request phase to rewind to
```
Phase 12 MARTIN FOWLER CHECK #2 FAILED

Failed Question(s):
- Question 10: Not debuggable enough
  Issue: Error messages are too generic

Which phase to return to?
- Phase 6 (REFACTOR) - Clean up code structure
- Phase 8 (IMPLEMENT) - Improve error handling
- Phase 11 (QA) - Additional testing

Selected: Phase 8
```

**On Success**: Advance to Phase 13 CONSISTENCY

## User Interaction

Present final checklist:
```
╔═══════════════════════════════════════════════════════════╗
║  MARTIN FOWLER CODE QUALITY CHECK #2 (FINAL GATE)       ║
╚═══════════════════════════════════════════════════════════╝

Before proceeding to production (Phase 13+), verify:

REPEAT FROM PHASE 7:
1. ✓ Simplest solution that works?
2. ✓ Refactored for readability?
3. ✓ Tests fully specify behavior?
4. ✓ Readable without extensive comments?
5. ✓ Live demo works end-to-end?
6. ✓ All success criteria verified?
7. ✓ User experience smooth and intuitive?
8. ✓ Edge cases handled gracefully?

NEW QUESTIONS:
9. ✓ Integrates cleanly with existing codebase?
10. ✓ Is the code debuggable if issues arise?
11. ✓ Is performance acceptable for production?
12. ✓ Will this be maintainable 6 months from now?
13. ✓ Is each line of code necessary?

───────────────────────────────────────────────────────────
Confirm: Do ALL 13 checks pass? [Yes / No]
```

If No:
```
Which phase to return to?
- Phase 6 (REFACTOR) - Code structure and clarity
- Phase 8 (IMPLEMENT) - Feature completeness
- Phase 11 (QA) - Testing and verification
```

## Integration Points

**Phase 11**: Prerequisites (QA passed)
**Phase 13**: Only entered if ALL 13 questions pass
**Manual verification**: User/developer confirms each

## Notes

- This is the **absolute final gate** before production
- If ANY question is NO, the answer is NO
- Allow rewind to appropriate phase
- Better to go back now than have production issues later
- All 8 Phase 7 questions still matter—code can regress

## Nu Backbone
- Start: `tdd15 phase-start <session> 12`
- Gate: `tdd15 gate-check <session> 12 '<result>'`
- Model/threshold may escalate on retry: `tdd15 model <session> 12`, `tdd15 threshold <session> 12`
