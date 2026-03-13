---
name: tdd15-phase-07-martin-fowler-1
description: PHASE 7 MARTIN FOWLER CHECK #1 - CRITICAL GATE. 8-question quality checklist. HALT on any NO. Guards entry into implementation phases.
allowed-tools: Read,Bash
model: sonnet
user-invocable: false
---

# Phase 7: MARTIN FOWLER CHECK #1 (CRITICAL GATE)

## Phase Purpose

Critical quality gate using Martin Fowler's principles:
1. Verify code is genuinely simple (not just "works")
2. Confirm all tests fully specify behavior
3. Ensure code is readable without comments
4. Validate user experience and edge cases
5. **HALT on any NO—this is non-negotiable**

This gate prevents entry into full implementation (Phase 8) with code that won't scale or maintain.

## 8-Question Checklist

### Question 1: Is this the simplest solution that works?

**Purpose**: Guard against over-engineering and premature optimization.

**Check**:
- No unnecessary abstraction layers
- No helper functions for one-time use
- No configurability that isn't used
- No "just in case" error handling
- No performance optimizations beyond obvious ones

**Example: FAIL**
```gleam
// Over-engineered for simple task
pub fn parse_input(input: String) -> Result(ParsedValue, ParseError) {
  input
  |> input_sanitizer.sanitize()  // Unnecessary wrapper
  |> input_validator.validate()  // Unnecessary wrapper
  |> input_transformer.transform()  // Unnecessary wrapper
  |> Ok()
}

// Should be:
pub fn parse_input(input: String) -> Result(ParsedValue, ParseError) {
  string.trim(input)
  |> Ok()
}
```

**Example: PASS**
```gleam
// Straightforward, no over-engineering
pub fn parse_input(input: String) -> Result(ParsedValue, ParseError) {
  case string.trim(input) {
    "" -> Error(EmptyInput)
    trimmed -> Ok(ParsedValue(trimmed))
  }
}
```

### Question 2: Has code been refactored for readability?

**Purpose**: Ensure Phase 6 refactoring actually improved readability.

**Check**:
- No duplication (DRY principle applied)
- Variable names are descriptive
- Function names explain intent
- Logic flow is obvious
- Helper functions appropriately extracted

**Example: FAIL**
```gleam
// Names don't clarify intent
pub fn proc(x: List(a)) -> List(a) {
  let y = list.filter(x, fn(z) { z != Nil })
  list.map(y, fn(z) { z })
}
```

**Example: PASS**
```gleam
// Clear names and intent
pub fn remove_nulls(items: List(a)) -> List(a) {
  items
  |> list.filter(fn(item) { item != Nil })
}
```

### Question 3: Do tests fully specify the behavior?

**Purpose**: Tests should be executable specification, not just verification.

**Check**:
- Each test represents one behavior/criterion
- Test name describes what's being tested
- Happy path, error paths, edge cases all covered
- Reading tests tells you what the function does
- No "magic" test data without explanation

**Example: FAIL**
```gleam
#[test]
pub fn test_1() {
  assert process("x") == "y"
}
```

**Example: PASS**
```gleam
#[test]
pub fn test_validate_email_accepts_valid_address() {
  let result = validate_email("user@example.com")
  result |> should.be_ok()
}

#[test]
pub fn test_validate_email_rejects_missing_at_sign() {
  let result = validate_email("userexample.com")
  result |> should.be_error()
}
```

### Question 4: Is the code readable without extensive comments?

**Purpose**: Code should be self-documenting through clarity and idiom, not comments.

**Check**:
- No comments explaining what code does (should be obvious)
- Only comments for "why" decisions, not "what"
- No commented-out code
- No TODO/FIXME comments left behind

**Example: FAIL**
```gleam
// Calculate the sum
pub fn total(nums: List(Int)) -> Int {
  // Loop through each number
  list.fold(nums, 0, fn(acc, n) {
    // Add it to accumulator
    acc + n
  })
}
// This is a sum function
```

**Example: PASS**
```gleam
pub fn total(nums: List(Int)) -> Int {
  list.fold(nums, 0, fn(acc, n) { acc + n })
}
```

### Question 5: Does a live demo of the feature work end-to-end?

**Purpose**: Verify the feature actually works, not just in tests.

**Check**:
- Manual testing shows feature works
- Happy path manual execution succeeds
- Error path manual execution shows proper handling
- UI/CLI feels right (if applicable)
- Integration with existing system works

**Execution**:
```bash
# If module is complete, manually test
gleam shell
# import intent/my_feature
# my_feature.process("test-data")
```

### Question 6: Have you manually verified all success criteria?

**Purpose**: Ensure every success criterion from the bead is actually met.

**Check** (for each criterion):
- [ ] Criterion 1: Verify with manual test
- [ ] Criterion 2: Verify with manual test
- [ ] ... etc ...

Example:
```
Success Criteria:
✓ Email validation accepts valid addresses
  → Manual test: validate_email("user@example.com") returns Ok()

✓ Email validation rejects invalid addresses
  → Manual test: validate_email("not-valid") returns Error()

✓ Edge case: Plus addressing supported
  → Manual test: validate_email("user+tag@example.com") returns Ok()
```

### Question 7: Is the user experience smooth and intuitive?

**Purpose**: Feature should feel natural to use, not awkward.

**Check**:
- Function signatures are intuitive
- Error messages are helpful (if applicable)
- Return types make sense
- No surprising behavior
- API feels Gleam-idiomatic

**Example: Poor UX**
```gleam
// Confusing parameter order
pub fn validate(input: String, options: Options, config: Config, strict: Bool) -> Result(...) {...}

// Unclear return type
pub fn process(data: String) -> String  // Could be result or error?
```

**Example: Good UX**
```gleam
pub fn validate(input: String) -> Result(Email, ValidationError)

// Clear: returns Result (explicit error handling)
// Parameters are obvious
// Signature tells the story
```

### Question 8: Are edge cases handled gracefully?

**Purpose**: Code shouldn't break on unexpected inputs, should handle them.

**Check** (via tests and manual verification):
- Empty input handled
- Boundary values handled
- Invalid input rejected with clear error
- Off-by-one errors considered
- Null/None values handled (or explicitly impossible via types)

**Example: FAIL**
```gleam
pub fn parse_age(input: String) -> Int {
  string.to_int(input) |> unwrap()  // Panics on error
}
```

**Example: PASS**
```gleam
pub fn parse_age(input: String) -> Result(Age, ParseError) {
  case string.to_int(input) {
    Ok(age) if age >= 0 && age <= 150 -> Ok(Age(age))
    Ok(_) -> Error(AgeOutOfRange)
    Error(_) -> Error(InvalidNumber)
  }
}
```

## Gate: martin_fowler_1 (CRITICAL)

**Pass Criteria** (ALL must be YES):
- [ ] Question 1: Simplest solution? **YES**
- [ ] Question 2: Refactored for readability? **YES**
- [ ] Question 3: Tests specify behavior? **YES**
- [ ] Question 4: Readable without comments? **YES**
- [ ] Question 5: Live demo works? **YES**
- [ ] Question 6: Success criteria verified? **YES**
- [ ] Question 7: User experience smooth? **YES**
- [ ] Question 8: Edge cases handled? **YES**

**Halt Criteria** (ANY failure halts):
- Any question answered NO
- Cannot demonstrate live working feature
- Success criteria not actually met

**On Failure**: HALT and return to Phase 6 REFACTOR
```
Phase 7 MARTIN FOWLER CHECK #1 FAILED

Failed Question(s):
- Question 3: Tests do not fully specify behavior

Action: Return to Phase 6 REFACTOR
- Improve test coverage
- Ensure tests document all behaviors
- Re-submit Phase 7 when ready
```

**On Success**: Advance to Phase 8 IMPLEMENT

## User Interaction

When presenting the checklist:
```
╔═══════════════════════════════════════════════════════════╗
║  MARTIN FOWLER CODE QUALITY CHECK #1 (CRITICAL GATE)     ║
╚═══════════════════════════════════════════════════════════╝

Before proceeding to full implementation (Phase 8), verify:

1. ✓ Is this the simplest solution that works?
   No over-engineering, premature optimization, or unnecessary abstractions?

2. ✓ Has code been refactored for readability?
   No duplication, clear names, obvious logic flow?

3. ✓ Do tests fully specify the behavior?
   Each test represents one behavior? Names describe intent?

4. ✓ Is the code readable without extensive comments?
   Code is self-documenting? No "what" comments, only "why"?

5. ✓ Does a live demo work end-to-end?
   Manual testing confirms feature works?

6. ✓ Have all success criteria been verified?
   Each criterion manually tested and confirmed?

7. ✓ Is the user experience smooth and intuitive?
   API feels natural? Signatures are clear?

8. ✓ Are edge cases handled gracefully?
   Empty input, boundary values, errors all handled?

───────────────────────────────────────────────────────────
Confirm: Do ALL 8 checks pass? [Yes / No]
```

## Integration Points

**Phase 6**: Reviews refactored code
**Phase 8**: Only entered if ALL 8 questions pass
**Manual verification**: User/developer must confirm each item

## Notes

- This is a **hard gate**: No partial passes, no "close enough"
- If ANY question is NO, the answer is NO
- Return to Phase 6 if needed—better now than later
- Martin Fowler's principles are about sustainability, not just functionality
- This gate prevents "works but unmaintainable" code

## Nu Backbone
- Start: `tdd15 phase-start <session> 7`
- Gate: `tdd15 gate-check <session> 7 '<result>'`
- Model/threshold may escalate on retry: `tdd15 model <session> 7`, `tdd15 threshold <session> 7`
