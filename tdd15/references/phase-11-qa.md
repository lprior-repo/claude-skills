---
name: tdd15-phase-11-qa
description: PHASE 11 QA - Battle testing and comprehensive scenarios. Test happy path, error cases, edge cases, integration, and performance baseline.
allowed-tools: Read,Bash,Glob
model: sonnet
user-invocable: false
---

# Phase 11: QA BATTLE TEST

## Phase Purpose

Comprehensive quality assurance testing:
1. Full test suite execution
2. Happy path scenarios
3. Error path scenarios
4. Edge case scenarios
5. Integration scenarios
6. Performance baseline

## Execution Steps

### Step 1: Full Test Suite

```bash
gleam test
```

Record:
- [ ] All tests pass
- [ ] No test failures
- [ ] Test count and results

### Step 2: Happy Path Scenarios

Test normal operation:
```gleam
// Example scenarios for email validation

Scenario 1: Valid standard email
Input: "user@example.com"
Expected: Ok(Email(...))
Result: ✓ PASS

Scenario 2: Valid email with subdomain
Input: "user@mail.example.co.uk"
Expected: Ok(Email(...))
Result: ✓ PASS

Scenario 3: Plus addressing
Input: "user+tag@example.com"
Expected: Ok(Email(...))
Result: ✓ PASS
```

Document all happy path scenarios:
- [ ] Standard use case works
- [ ] Common variations work
- [ ] Expected defaults apply correctly

### Step 3: Error Path Scenarios

Test error handling:
```gleam
Scenario 1: Empty string
Input: ""
Expected: Error(EmptyInput)
Result: ✓ PASS - Error message clear

Scenario 2: Missing @ symbol
Input: "userexample.com"
Expected: Error(InvalidFormat)
Result: ✓ PASS - Error message helpful

Scenario 3: Multiple @ symbols
Input: "user@@example.com"
Expected: Error(InvalidFormat)
Result: ✓ PASS - Handled gracefully

Scenario 4: Invalid characters
Input: "user@exam<ple.com"
Expected: Error(InvalidCharacters)
Result: ✓ PASS - Clear error
```

Document error scenarios:
- [ ] Common errors caught
- [ ] Error messages are helpful
- [ ] No crashes on invalid input

### Step 4: Edge Cases

Test boundary conditions:
```gleam
Scenario 1: Minimum valid length
Input: "a@b"
Expected: Ok(Email(...)) or Error (depends on spec)
Result: ✓ [Expected behavior confirmed]

Scenario 2: Maximum length (common limit 254 chars)
Input: "x" * 240 + "@example.com"
Expected: Ok or Error depending on validation
Result: ✓ [Behavior confirmed]

Scenario 3: Unicode characters
Input: "ユーザー@example.com"
Expected: Depends on spec (accept or reject)
Result: ✓ [Behavior confirmed]

Scenario 4: Whitespace handling
Input: " user@example.com "
Expected: Trimmed and valid, or Error
Result: ✓ [Behavior confirmed]
```

Document edge cases:
- [ ] Boundary values handled
- [ ] Off-by-one errors avoided
- [ ] Unexpected input types rejected safely

### Step 5: Integration Scenarios

Test with rest of system (if applicable):
```bash
# If email validation integrates with user registration:
Integration Test 1:
- Create user with valid email
- Email stored correctly
- Validation triggered on retrieval
Result: ✓ PASS

Integration Test 2:
- Update user with invalid email
- Proper error returned to caller
- No partial state updates
Result: ✓ PASS
```

### Step 6: Performance Baseline

If applicable, test performance:
```bash
# Benchmark valid email validation
Time for 1000 validations: ~2ms
Memory impact: Negligible
Result: ✓ ACCEPTABLE BASELINE

# Benchmark error case
Time for 1000 invalid inputs: ~1.5ms
Result: ✓ ACCEPTABLE
```

Record baseline for future comparison.

### Step 7: QA Report

Create comprehensive QA report:
```
PHASE 11 QA BATTLE TEST REPORT
═════════════════════════════════════════

Feature: Email Validation
QA Date: 2026-01-18T14:00:00Z

Test Results:
────────────────────────
Full Suite: ✓ PASS (15 tests)
Test Coverage: 95%
Warnings: 0

Happy Path Scenarios: ✓ 3/3 PASS
- Standard email
- Subdomain email
- Plus addressing

Error Scenarios: ✓ 4/4 PASS
- Empty input → Clear error
- Missing @ → Clear error
- Multiple @ → Handled gracefully
- Invalid chars → Clear error

Edge Cases: ✓ 4/4 PASS
- Boundary length
- Maximum length
- Unicode handling
- Whitespace handling

Integration Scenarios: ✓ 2/2 PASS
- Creation flow
- Update flow

Performance:
- Valid validation: ~2μs per op
- Error case: ~1.5μs per op
- Baseline established ✓

Overall: ✓ QA PASSED - Ready for release
```

## Gate: qa_pass

**Pass Criteria**:
- [ ] All tests pass (gleam test = 0)
- [ ] Happy path scenarios verified
- [ ] Error paths handled gracefully
- [ ] Edge cases tested
- [ ] Integration scenarios pass (if applicable)
- [ ] No regressions vs baseline
- [ ] Performance acceptable

**Halt Criteria**:
- Tests fail
- Unhandled edge cases found
- Integration fails
- Performance regression

**On Failure**:
```
Phase 11 QA FAILED

Failed Scenarios:
- [Scenario]: [Issue]

Action: Fix the issue and re-run QA
```

**On Success**: Advance to Phase 12 MARTIN FOWLER CHECK #2

## QA Checklist

- [ ] Full test suite passes
- [ ] Happy path works end-to-end
- [ ] All error paths handled
- [ ] Edge cases don't crash
- [ ] Integration with existing code works
- [ ] Performance baseline established
- [ ] No unexpected side effects
- [ ] User-facing behavior verified

## Integration Points

**Phase 10**: Prerequisite (omarchy passed)
**Tests**: Uses all tests from Phases 4-6
**Manual Testing**: QA validates behaviors
**Next Phase**: Phase 12 Martin Fowler final check

## Notes

- Battle testing means thorough, not just basic testing
- Edge cases prevent production surprises
- Integration testing catches cross-module issues
- Performance baseline lets us detect regressions
- This phase is last comprehensive test before finals

## Nu Backbone
- Start: `tdd15 phase-start <session> 11`
- Gate: `tdd15 gate-check <session> 11 '<result>'`
- Model/threshold may escalate on retry: `tdd15 model <session> 11`, `tdd15 threshold <session> 11`
