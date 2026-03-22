# TDD-First Loop

Every code generation follows this cycle. Never write implementation without a failing test first.

---

## The Sacred Cycle

```
┌─────────────────────────────────────────────┐
│  1. DECLARE → Constraints & Invariants     │
│  2. RED     → Write Failing Test           │
│  3. PREDICT → How Will It Fail?            │
│  4. GREEN   → Minimal Implementation       │
│  5. VERIFY  → Skeptical Validation         │
│  6. REFACTOR→ Improve While Tests Pass     │
└─────────────────────────────────────────────┘
```

---

## Step 1: Declare Constraints and Invariants

**Before writing code or tests, articulate:**

### Constraints
- Input preconditions (what must be true about inputs)
- Output postconditions (what must be true about outputs)
- Performance requirements (time/space complexity)
- Environmental constraints (available resources, dependencies)

### Invariants
- What must ALWAYS be true (at start, during, and end)
- What must NEVER happen
- Relationships that must hold

### Example

```
Function: ParseJSON(data []byte) (Config, error)

Constraints:
- Input: data must be valid UTF-8 bytes
- Output: Config with all required fields populated, or error
- Performance: O(n) time where n is input size
- No external dependencies

Invariants:
- If error is nil, Config is valid and complete
- If error is non-nil, Config is zero value
- Never panic on malformed input
- Result deterministic (same input → same output)
```

---

## Step 2: RED - Write Failing Test

**Write the test FIRST. Do not write implementation yet.**

### Characteristics of a Good Test

1. **Focused** - One behavior only
2. **Clear** - Intent obvious from name and assertions
3. **Independent** - No shared state with other tests
4. **Repeatable** - Same result every time
5. **Fast** - Milliseconds, not seconds

### Test Structure (AAA Pattern)

```go
func TestBehavior(t *testing.T) {
    // ARRANGE - Set up test data
    input := TestInput{...}
    
    // ACT - Execute the behavior
    result := FunctionUnderTest(input)
    
    // ASSERT - Verify the outcome
    if result != expected {
        t.Errorf("got %v, want %v", result, expected)
    }
}
```

### Table-Driven Tests (Preferred for Go)

```go
func TestValidate(t *testing.T) {
    tests := []struct {
        name    string
        input   Contract
        wantErr bool
        errMsg  string
    }{
        {
            name:    "valid contract",
            input:   Contract{Name: "test", Version: "1.0"},
            wantErr: false,
        },
        {
            name:    "empty name",
            input:   Contract{Name: "", Version: "1.0"},
            wantErr: true,
            errMsg:  "name required",
        },
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            result := Validate(tt.input)
            
            if tt.wantErr {
                if result.IsOk() {
                    t.Errorf("expected error, got ok")
                }
                if result.Err().Error() != tt.errMsg {
                    t.Errorf("got %q, want %q", result.Err(), tt.errMsg)
                }
            } else {
                if result.IsErr() {
                    t.Errorf("unexpected error: %v", result.Err())
                }
            }
        })
    }
}
```

---

## Step 3: PREDICT - How Will It Fail?

**Before running the test, predict the failure.**

### Why Predict?

- Ensures you understand what the test is actually testing
- Catches tests that pass for wrong reasons
- Reveals assumptions about how code should work
- Makes you think about the implementation strategy

### Prediction Format

```
Test: TestAddReturnsSum
Input: Add(2, 3)
Expected: 5
Predicted Failure: "undefined: Add" (function doesn't exist yet)

After implementing stub:
Predicted Failure: "got 0, want 5" (zero value return)
```

### Common Failure Modes

1. **Compilation error** - Function/type doesn't exist
2. **Zero value return** - Function exists but returns default value
3. **Wrong calculation** - Logic error in implementation
4. **Panic/exception** - Unhandled edge case
5. **Wrong error** - Error returned but wrong message/type

---

## Step 4: GREEN - Minimal Implementation

**Write the LEAST code possible to make the test pass.**

### Minimal Means Minimal

Don't think ahead. Don't handle cases you haven't tested for. Don't generalize.

**Bad (doing too much):**
```go
// Test only checks Add(2, 3) == 5
func Add(a, b int) int {
    // Handling cases not tested yet!
    if a < 0 || b < 0 {
        panic("negative numbers not supported")
    }
    if a > 1000000 || b > 1000000 {
        panic("numbers too large")
    }
    return a + b  // Only this line is needed!
}
```

**Good (minimal):**
```go
// Test only checks Add(2, 3) == 5
func Add(a, b int) int {
    return a + b  // Just enough to pass
}
```

### Halt If >40 Lines

If your implementation exceeds 40 lines, STOP:

1. You're doing too much in one function
2. Extract helper functions
3. Each helper gets its own test
4. Compose helpers in main function

**Example:**
```go
// Getting long (>40 lines)
func ProcessOrder(order Order) error {
    // 50 lines of validation, calculation, persistence...
}

// Split into testable units
func ProcessOrder(order Order) error {
    if err := ValidateOrder(order); err != nil {  // 1 line
        return err
    }
    total := CalculateTotal(order)               // 1 line
    if err := SaveOrder(order, total); err != nil {  // 1 line
        return err
    }
    return NotifyCustomer(order)                 // 1 line
}

// Each function ≤40 lines with own tests
func ValidateOrder(order Order) error { /* tested separately */ }
func CalculateTotal(order Order) float64 { /* tested separately */ }
func SaveOrder(order Order, total float64) error { /* tested separately */ }
func NotifyCustomer(order Order) error { /* tested separately */ }
```

### Run the Test

```bash
go test -v
# or
cargo test
```

**Verify:** Test should now PASS (GREEN).

If test still fails, fix implementation. Don't move forward until GREEN.

---

## Step 5: VERIFY - Skeptical Validation

**After every function, explicitly question it.**

### Four Critical Questions

1. **What assumptions did I make?**
   - About inputs (format, range, type)
   - About environment (files exist, network available)
   - About dependencies (other functions, libraries)
   - About state (global variables, singletons)

2. **What edge cases did I consider?**
   - Empty inputs (nil, "", [], {})
   - Boundary values (0, -1, MaxInt, "")
   - Invalid inputs (malformed, out of range)
   - Concurrent access
   - Resource exhaustion

3. **What might be wrong?**
   - Off-by-one errors
   - Race conditions
   - Memory leaks
   - Integer overflow
   - Incorrect error handling
   - Missing validation

4. **How do I know it actually works?**
   - What tests prove correctness?
   - What tests are missing?
   - Have I tested error paths?
   - Have I tested edge cases?

### Example Validation

```go
func Add(a, b int) int {
    return a + b
}

Validation:
- Assumptions:
  * Assumes int won't overflow (what if a = MaxInt, b = 1?)
  * Assumes addition is commutative (true for ints)
  
- Edge cases considered:
  * Negative numbers (works)
  * Zero (works)
  * MaxInt (OVERFLOW - not handled!)
  
- What might be wrong:
  * Integer overflow will wrap (silent failure)
  * No indication when overflow occurs
  
- How to know it works:
  * Current test passes for small numbers
  * Missing test for overflow behavior
  * Should either: panic on overflow, return error, or use wider type

Action: Add test for overflow, decide on behavior
```

---

## Step 6: REFACTOR - Improve While Tests Pass

**Improve code quality without changing behavior.**

### What to Refactor

1. **Extract functions** - Break down long functions
2. **Rename** - Make names more descriptive
3. **Remove duplication** - DRY principle
4. **Simplify conditionals** - Early returns, guard clauses
5. **Improve structure** - Better organize code

### Golden Rule

**Tests must stay GREEN throughout refactoring.**

Run tests after every refactor step. If tests fail, you changed behavior (bad). Revert and try different approach.

### Refactoring Techniques

#### Extract Function
```go
// Before
func Process(data Data) error {
    if data.Name == "" || data.Email == "" {
        return errors.New("invalid")
    }
    // ... more code
}

// After refactor
func Process(data Data) error {
    if err := Validate(data); err != nil {
        return err
    }
    // ... more code
}

func Validate(data Data) error {
    if data.Name == "" || data.Email == "" {
        return errors.New("invalid")
    }
    return nil
}
```

#### Rename for Clarity
```go
// Before
func calc(o Order) float64 {
    t := 0.0
    for _, i := range o.Items {
        t += i.P * float64(i.Q)
    }
    return t
}

// After
func CalculateTotal(order Order) float64 {
    total := 0.0
    for _, item := range order.Items {
        total += item.Price * float64(item.Quantity)
    }
    return total
}
```

#### Simplify Conditionals
```go
// Before
func IsValid(user User) bool {
    if user.Email != "" {
        if user.Age >= 18 {
            return true
        } else {
            return false
        }
    } else {
        return false
    }
}

// After
func IsValid(user User) bool {
    return user.Email != "" && user.Age >= 18
}
```

---

## Incremental Revelation Protocol

**Do not dump large blocks. Present one function cycle at a time.**

### Process

1. Present ONE function cycle (test → impl → validation)
2. Wait for feedback or confirmation
3. Proceed to NEXT function only after confirmation

### Why?

- Surface decisions rather than make them silently
- Give user chance to redirect before too much work done
- Make thinking visible
- Enable collaboration

### Format

```markdown
## Behavior: [what this test specifies]

### Constraints
- Input: [preconditions]
- Output: [postconditions]
- Invariants: [what must always hold]

### Test
```go
[test code - written first]
```

### Predicted Failure
[how test will fail before implementation exists]

### Implementation
```go
[production code - ≤40 lines]
```

### Validation
- **Assumptions:** [what I assumed]
- **Edge cases:** [what I considered]
- **Uncertainty:** [what might be wrong]
- **Verification:** [how to know it works]

### Refactor Notes
[any cleanup applied]

---

**Ready to proceed to next function?**
```

---

## Anti-Patterns to Avoid

### ❌ Writing Implementation First

```go
// WRONG - Implementation before test
func Add(a, b int) int {
    return a + b  // How do you know this is right?
}

// Test written after
func TestAdd(t *testing.T) {
    // This test will obviously pass - you wrote code to match test
}
```

### ❌ Testing Implementation Details

```go
// WRONG - Testing internal structure
func TestUserInternals(t *testing.T) {
    user := User{name: "John"}  // Accessing private field
    if user.name != "John" {     // Testing internal state
        t.Error("wrong internal state")
    }
}

// RIGHT - Testing behavior
func TestUserName(t *testing.T) {
    user := NewUser("John")
    if user.Name() != "John" {   // Testing public API
        t.Error("wrong name")
    }
}
```

### ❌ Skipping Prediction

```go
// WRONG
"I'll just run the test and see what happens"

// RIGHT
"I predict this will fail with 'undefined: Add' because the function doesn't exist yet"
```

### ❌ Over-implementing

```go
// Test only verifies Add(2, 3) == 5

// WRONG - Gold plating
func Add(a, b int) int {
    // Premature optimization!
    if a == 0 { return b }
    if b == 0 { return a }
    
    // Handling untested cases!
    if a < 0 && b < 0 {
        panic("both negative")
    }
    
    return a + b
}

// RIGHT - Minimal
func Add(a, b int) int {
    return a + b  // Just enough
}
```

---

## Philosophy

**The test is the specification.**

By writing tests first, you:
- Clarify requirements before coding
- Design from the user's perspective
- Create executable documentation
- Enable fearless refactoring
- Prevent regression

**Red → Green → Refactor** is not just a process. It's a discipline that produces:
- Testable code (forced by TDD)
- Modular design (forced by testability)
- Clear interfaces (forced by user perspective)
- Living documentation (the tests themselves)

**Every line of code is guilty until proven innocent by a test.**
