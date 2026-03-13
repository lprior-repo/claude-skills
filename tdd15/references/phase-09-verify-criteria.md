---
name: tdd15-phase-09-verify-criteria
description: PHASE 9 VERIFY SUCCESS CRITERIA - Validate all success criteria are met. Run full test suite and format check. Prepare for deeper review phases.
allowed-tools: Read,Bash,Glob,Grep
model: sonnet
user-invocable: false
---

# Phase 9: VERIFY SUCCESS CRITERIA

## Phase Purpose

Confirm all success criteria from the original bead are actually met:
1. Check each success criterion explicitly
2. Verify with tests and manual verification
3. Run full test suite
4. Check code formatting
5. Create audit trail

## Execution Steps

### Step 1: Load Success Criteria

From bead definition:
```bash
bd show <bead-id> --json | jq '.success_criteria'
```

Example:
```json
[
  "Email validation accepts valid addresses",
  "Email validation rejects invalid addresses",
  "Edge case: Plus addressing supported",
  "Error messages are helpful"
]
```

### Step 2: Verify Each Criterion

For each criterion, execute:

**Criterion 1**: Email validation accepts valid addresses
- Test: `test_validate_email_accepts_valid_email` ✓ PASSES
- Manual: `validate_email("user@example.com")` → Ok(Email(...)) ✓
- Status: MET

**Criterion 2**: Email validation rejects invalid addresses
- Test: `test_validate_email_rejects_invalid_email` ✓ PASSES
- Manual: `validate_email("not-valid")` → Error(InvalidEmail) ✓
- Status: MET

**Criterion 3**: Edge case: Plus addressing supported
- Test: `test_validate_email_handles_plus_addressing` ✓ PASSES
- Manual: `validate_email("user+tag@example.com")` → Ok(Email(...)) ✓
- Status: MET

**Criterion 4**: Error messages are helpful
- Review: error_handler messages ✓ CLEAR
- Manual: invoke error scenario and check message
- Status: MET

Create verification matrix:
```
Criterion | Tests | Manual | Status
-----------|--------|---------|--------
1 | ✓ | ✓ | MET
2 | ✓ | ✓ | MET
3 | ✓ | ✓ | MET
4 | ✓ | ✓ | MET
```

### Step 3: Run Full Test Suite

```bash
gleam test
```

Expected output:
```
Compiling intent v0.1.0
   Compiled successfully

Test results:
✓ test_validate_email_accepts_valid_email
✓ test_validate_email_rejects_invalid_email
✓ test_validate_email_handles_plus_addressing
✓ ... (all tests)

All tests passed!
```

Record:
- [ ] All tests pass (exit code 0)
- [ ] No test failures
- [ ] Number of tests run: X

### Step 4: Check Code Formatting

```bash
gleam format --check
```

Expected: No output (no formatting issues)

If formatting issues found:
```bash
gleam format
```

Then verify again:
```bash
gleam format --check
```

### Step 5: Verify Build Quality

```bash
gleam build
```

Expected: Successful compilation with no warnings
```
   Compiling intent
   Compiled successfully in 1.23s
```

Check for:
- [ ] No compilation errors
- [ ] No warnings (unused imports, unreachable code, etc.)
- [ ] Build output shows "successfully"

### Step 6: Create Verification Report

Document verification:
```
PHASE 9 VERIFICATION REPORT
═════════════════════════════════════════

Success Criteria Verification:
┌─────────────────────────────────────────────┬────────────┐
│ Criterion                                   │ Status     │
├─────────────────────────────────────────────┼────────────┤
│ Email validation accepts valid addresses    │ ✓ MET      │
│ Email validation rejects invalid addresses  │ ✓ MET      │
│ Edge case: Plus addressing supported       │ ✓ MET      │
│ Error messages are helpful                 │ ✓ MET      │
└─────────────────────────────────────────────┴────────────┘

Test Results:
- Total tests run: 15
- Passed: 15
- Failed: 0
- Exit code: 0 ✓

Code Quality:
- Build: ✓ Success (no warnings)
- Formatting: ✓ Compliant
- Warnings: 0

Verification: ✓ ALL CRITERIA MET
```

## Gate: criteria_met

**Pass Criteria**:
- [ ] All success criteria verified (test or manual)
- [ ] All tests pass (`gleam test` exit code 0)
- [ ] Code builds with no warnings
- [ ] Code formatting passes (`gleam format --check`)
- [ ] Verification report complete and positive

**Halt Criteria**:
- Any success criterion not met
- Tests failing
- Build warnings
- Formatting issues
- Incomplete verification

**On Failure**:
```
Phase 9 VERIFY FAILED

Failed Criteria:
- [Criterion name]: [Why not met]

Action: Fix implementation to meet all criteria
```

**On Success**: Advance to Phase 10 INTERROGATE

## Verification Checklist

- [ ] All success criteria documented
- [ ] Each criterion has test AND/OR manual verification
- [ ] Verification matrix created
- [ ] All tests passing
- [ ] Build successful
- [ ] No compiler warnings
- [ ] Code formatted
- [ ] Report generated

## Integration Points

**Phase 8**: Validates completion of implementation
**Beads**: Uses bead success_criteria
**Tests**: Phase 4-6 tests verify criteria
**Next Phase**: Phase 10 does deeper adversarial review

## Notes

- Success criteria are the specification
- Verification is proof, not just testing
- Both automated tests and manual checks matter
- Formatting compliance is non-negotiable
- This phase is the last before deep review (Phase 10)

## Nu Backbone
- Start: `tdd15 phase-start <session> 9`
- Gate: `tdd15 gate-check <session> 9 '<result>'`
- Model/threshold may escalate on retry: `tdd15 model <session> 9`, `tdd15 threshold <session> 9`
