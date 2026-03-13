---
name: tdd15-phase-04-red
description: PHASE 4 RED - Test-first development. Write failing tests that define expected behavior. Tests are executable specifications of the feature.
allowed-tools: Read,Write,Edit,Glob,Grep,Bash,Task
model: sonnet
user-invocable: false
---

# Phase 4: RED

## Phase Purpose

Write failing tests that define the expected behavior:
1. Tests are executable specifications (EARS patterns as tests)
2. Each test represents one success criterion or behavior
3. Tests fail initially (RED phase of TDD)
4. Tests guide implementation in Phase 5

## Execution Steps

### Step 1: Parse Locked Plan from Phase 3

Understand:
- Success criteria and how they map to behaviors
- Implementation steps and their test checkpoints
- File modifications and new modules
- Data flows and transformations

### Step 2: Design Test Structure

For each success criterion, create:
```gleam
#[test]
pub fn test_success_criterion_1() {
  // Arrange: set up test data
  let input = ...

  // Act: call the function
  let result = my_function(input)

  // Assert: verify expected behavior
  assert result == expected
}
```

Test naming convention:
- `test_<feature>_<scenario>`
- `test_<behavior>_<condition>`
- Clear intent from name alone

### Step 3: Write Failing Tests

Create test files following pattern:
```
test/intent_<feature>_test.gleam
```

For each step in the plan:
1. Write test that exercises that step
2. Test should initially fail (RED)
3. Failure message should be clear about what's missing
4. No implementation code yet

Example:
```gleam
import gleeunit/should

#[test]
pub fn test_validate_email_accepts_valid_email() {
  let valid = "user@example.com"
  let result = validate_email(valid)
  result |> should.be_ok()
}

#[test]
pub fn test_validate_email_rejects_invalid_email() {
  let invalid = "not-an-email"
  let result = validate_email(invalid)
  result |> should.be_error()
}

#[test]
pub fn test_validate_email_handles_edge_case_plus_addressing() {
  let edge_case = "user+tag@example.com"
  let result = validate_email(edge_case)
  result |> should.be_ok()
}
```

### Step 4: Organize Test File

Structure test file clearly:
```gleam
// Imports
import gleeunit/should
import intent/my_feature

// Test suite organization
// [HAPPY PATH TESTS]
#[test]
pub fn test_...() { ... }

// [EDGE CASES]
#[test]
pub fn test_...() { ... }

// [ERROR CASES]
#[test]
pub fn test_...() { ... }
```

### Step 5: Verify Tests Fail

```bash
cd <workspace>  # If using jjz
gleam test
# Expected: Tests fail (modules don't exist, functions not implemented)
```

Verify:
- [ ] Tests compile (syntax correct)
- [ ] Tests fail as expected
- [ ] Failure messages are clear
- [ ] Each test is independent

### Step 6: Document Test Coverage

Record what each test covers:
```
Test Coverage Map:
- test_validate_email_accepts_valid_email
  ✗ Success Criterion 1: Valid emails accepted
  ✗ Module: intent_email_validator
  ✗ Function: validate_email(String) → Result(Email, Error)

- test_validate_email_rejects_invalid_email
  ✗ Success Criterion 1: Invalid emails rejected
  ✗ Error Path: EmailError

- test_validate_email_handles_edge_case_plus_addressing
  ✗ Edge Case: Plus addressing (RFC 5321)
```

## Gate: tests_fail

**Pass Criteria**:
- [ ] Test file(s) created and syntactically correct
- [ ] All tests fail initially (RED state)
- [ ] Failure messages are clear and meaningful
- [ ] At least one test per success criterion
- [ ] Tests are independent (no hidden order dependencies)
- [ ] `gleam test` command works and shows failures
- [ ] Test organization is clear and logical

**Halt Criteria**:
- Tests don't compile (syntax errors)
- Tests pass (should fail in RED phase)
- Insufficient test coverage (missing success criteria)
- Unclear test names or assertions
- Test file in wrong location

**On Failure**:
```
Phase 4 RED FAILED: Tests not in expected RED state
Reason: [Details of failure]
Fix: [Specific action to correct]
```

**On Success**: Advance to Phase 5 GREEN (write minimal implementation)

## Test Quality Checklist

- [ ] Each test has a single assertion (or clear grouped assertions)
- [ ] Test names describe what they're testing
- [ ] Arrange-Act-Assert pattern used consistently
- [ ] No test setup side effects affecting other tests
- [ ] Error cases explicitly tested
- [ ] Edge cases covered
- [ ] Happy path tested
- [ ] Failure messages would help debug

## Integration Points

**Phase 3**: Uses locked plan
**Files**: Creates test/intent_<feature>_test.gleam
**Tools**: gleam test for verification
**Next Phase**: Phase 5 uses these tests as specification

## Notes

- Tests are the specification: write them to describe desired behavior
- RED phase is not about implementation—resist the urge to code features
- Use clear names and assertions—tests are documentation
- One test per behavior/criterion ideally
- Tests should fail for the right reason (missing implementation, not bugs)
- Gleam exhaustive matching helps: tests catch incomplete implementations early

## Nu Backbone
- Start: `tdd15 phase-start <session> 4`
- Gate: `tdd15 gate-check <session> 4 '<result>'`
- Model/threshold may escalate on retry: `tdd15 model <session> 4`, `tdd15 threshold <session> 4`
