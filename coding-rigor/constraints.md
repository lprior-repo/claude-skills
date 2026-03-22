# Hard Constraints

Non-negotiable gates that halt progress. Violation of any constraint requires immediate refactoring before continuing.

---

## The Five Commandments

### 1. ≤40 Lines Per Function

**Rule:** No function exceeds 40 lines of code.

**Why:** Functions beyond 40 lines are doing too much. They're hard to test, hard to understand, and hard to change.

**Action:** Extract helper functions. Break complex operations into smaller, composable pieces.

**Example violation:**
```go
// BAD - 60 lines
func ProcessOrder(order Order) error {
    // 60 lines of validation, calculation, DB calls, notifications...
}
```

**Fixed:**
```go
// GOOD - Composed from smaller functions
func ProcessOrder(order Order) error {
    if err := ValidateOrder(order); err != nil {
        return err
    }
    total := CalculateTotal(order)
    if err := SaveOrder(order, total); err != nil {
        return err
    }
    return NotifyCustomer(order)
}

func ValidateOrder(order Order) error { /* ≤40 lines */ }
func CalculateTotal(order Order) float64 { /* ≤40 lines */ }
func SaveOrder(order Order, total float64) error { /* ≤40 lines */ }
func NotifyCustomer(order Order) error { /* ≤40 lines */ }
```

---

### 2. ≤5 Parameters Per Function

**Rule:** No function accepts more than 5 parameters.

**Why:** Many parameters signal poor cohesion. The function is likely doing too much or the data belongs together in a struct/object.

**Action:** Group related parameters into structs, objects, or configuration types.

**Example violation:**
```go
// BAD
func CreateUser(firstName, lastName, email, phone, address, city, state, zip string, age int) error {
    // ...
}
```

**Fixed:**
```go
// GOOD
type UserDetails struct {
    FirstName string
    LastName  string
    Email     string
    Phone     string
    Address   Address
    Age       int
}

type Address struct {
    Street string
    City   string
    State  string
    Zip    string
}

func CreateUser(details UserDetails) error {
    // ...
}
```

---

### 3. Zero Implementation Without Failing Test First

**Rule:** Every line of production code must be written in response to a failing test.

**Why:** Tests are specifications. Writing code without tests means building without knowing what "done" looks like.

**Action:** Write the test first. Run it. Watch it fail. Then write minimal code to pass.

**Process:**
```
1. Write test
2. Run test → RED (fails)
3. Write minimal implementation
4. Run test → GREEN (passes)
5. Refactor while keeping tests green
```

**Example:**
```go
// STEP 1: Write test first
func TestAddition(t *testing.T) {
    result := Add(2, 3)
    if result != 5 {
        t.Errorf("got %d, want 5", result)
    }
}

// STEP 2: Run test → Compilation error (Add doesn't exist)

// STEP 3: Minimal implementation
func Add(a, b int) int {
    return a + b
}

// STEP 4: Run test → GREEN
```

---

### 4. One Behavior Per Test

**Rule:** Each test validates exactly one behavior or invariant.

**Why:** Multiple behaviors in one test make failures ambiguous. Which behavior failed? Tests become brittle and hard to maintain.

**Action:** Split multi-assertion tests into focused, single-behavior tests.

**Example violation:**
```go
// BAD - Tests multiple behaviors
func TestUserCreation(t *testing.T) {
    user := CreateUser("John", "Doe")
    if user.FullName() != "John Doe" {
        t.Error("full name wrong")
    }
    if user.IsValid() != true {
        t.Error("should be valid")
    }
    if user.CreatedAt.IsZero() {
        t.Error("timestamp not set")
    }
}
```

**Fixed:**
```go
// GOOD - One behavior per test
func TestUserFullName(t *testing.T) {
    user := CreateUser("John", "Doe")
    if user.FullName() != "John Doe" {
        t.Errorf("got %q, want 'John Doe'", user.FullName())
    }
}

func TestUserIsValidWhenCreated(t *testing.T) {
    user := CreateUser("John", "Doe")
    if !user.IsValid() {
        t.Error("newly created user should be valid")
    }
}

func TestUserCreatedAtIsSet(t *testing.T) {
    user := CreateUser("John", "Doe")
    if user.CreatedAt.IsZero() {
        t.Error("CreatedAt should be set on creation")
    }
}
```

---

### 5. One Concept Per Commit

**Rule:** Each commit contains changes for exactly one concept or behavior.

**Why:** Mixed commits are impossible to review, revert, or understand in history. Atomic commits enable precise rollbacks and clear history.

**Action:** Commit after each test passes. Keep commits small and focused.

**Example violations:**
- ❌ "Fix bug, add feature, refactor tests, update docs"
- ❌ "WIP various changes"
- ❌ "Update multiple components"

**Good commits:**
- ✅ "Add validation for empty email addresses"
- ✅ "Extract CalculateTotal helper function"
- ✅ "Handle nil pointer in ParseConfig"

---

## Red Flags That Demand Refactoring

Stop and refactor immediately when encountering:

### Code Smells

- ❌ **Function doing multiple things** - Extract separate functions
- ❌ **Change requires modifications in many places** - Violates DRY, poor cohesion
- ❌ **Circular dependencies** - Restructure module boundaries
- ❌ **God objects or modules** - Split responsibilities
- ❌ **Implementation details leaking through interfaces** - Tighten abstractions
- ❌ **Functions >40 lines** - Extract helpers
- ❌ **Functions with >5 parameters** - Group into structs

### Test Smells

- ❌ **Mock explosion (>3 mocks per test)** - Core logic not pure enough
- ❌ **Extensive fixture setup** - Tests depend on too much context
- ❌ **Testing implementation details** - Tests coupled to internals, not behavior
- ❌ **Order-dependent tests** - Hidden shared state, poor isolation
- ❌ **Hard-to-write tests** - Design feedback: simplify the code

### Design Smells

- ❌ **Tight coupling** - Components depend on too many others
- ❌ **Long dependency chains** - A → B → C → D... simplify
- ❌ **Unclear naming** - If you can't name it clearly, you don't understand it
- ❌ **Mixed abstraction levels** - High-level logic mixed with low-level details

---

## Enforcement Protocol

When you encounter a constraint violation:

1. **STOP** - Do not proceed with current approach
2. **Identify** - Which constraint is violated and why
3. **Refactor** - Fix the violation (extract, split, simplify)
4. **Validate** - Ensure tests still pass
5. **Proceed** - Continue with clean code

### Example Enforcement

```
Situation: Function reaches 45 lines

1. STOP - "This function exceeds 40 lines"
2. IDENTIFY - "Too many responsibilities: validation, calculation, persistence"
3. REFACTOR - Extract ValidateInput(), CalculateResult(), SaveResult()
4. VALIDATE - Run tests → all green
5. PROCEED - Continue with extracted functions
```

---

## Fitness Functions

Before starting any work, define:

- **What does "done" look like?** - Clear acceptance criteria
- **What are the acceptance criteria?** - Measurable outcomes
- **How will correctness be verified?** - Test strategy

Without a fitness function, progress cannot be measured.

---

## Exceptions

There are NO exceptions to these constraints. If you think you need an exception, you don't understand the problem well enough.

**Common false justifications:**
- "It's just a simple script" → Scripts have bugs too
- "This is just a prototype" → Prototypes become production
- "We'll clean it up later" → Later never comes
- "This is legacy code" → Perfect time to start doing it right

**Real exception:** Generated code (protobuf, etc.) - but you shouldn't be writing that by hand anyway.

---

## Philosophy

Constraints enable creativity. By limiting degrees of freedom, we force ourselves to find elegant solutions.

- 40-line limit → Forces modular, composable design
- 5-parameter limit → Forces proper data structures
- Test-first → Forces clarity about requirements
- One behavior/test → Forces focused, maintainable tests
- One concept/commit → Forces disciplined, reviewable changes

These aren't arbitrary rules. They're distilled wisdom from decades of software engineering pain.
