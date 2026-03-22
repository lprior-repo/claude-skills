# Development Flow: ATDD + TDD + TCR

Complete workflow combining Acceptance Test Driven Development, Test Driven Development, and Test-Commit-Revert.

---

## The Complete Picture

```
┌─────────────────────────────────────────────────────────────┐
│ OUTER LOOP: ATDD (Acceptance Test Driven Development)       │
│ - Executable Specification in domain language               │
│ - Defines WHAT, never HOW                                   │
│ - RED until feature complete                                │
├─────────────────────────────────────────────────────────────┤
│ INNER LOOP: TDD + TCR                                       │
│ ┌─────────────────────────────────────────────────────────┐ │
│ │ 1. RED   → Write failing unit test                      │ │
│ │ 2. GREEN → Minimal code to pass (<25 lines, pure)       │ │
│ │ 3. REFACTOR → Improve design, tests stay green          │ │
│ │ 4. COMMIT (or REVERT if stuck >10 min)                  │ │
│ └─────────────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────────────┤
│ ARCHITECTURE: Functional Core / Imperative Shell            │
│ - Pure functions in core (no I/O, no side effects)          │
│ - Side effects pushed to edges (shell)                      │
│ - Dependency inversion at boundaries                        │
├─────────────────────────────────────────────────────────────┤
│ VALIDATION: Scientific Method                               │
│ - Hypothesis → Experiment → Measure → Learn                 │
│ - Data-driven acceptance criteria                           │
└─────────────────────────────────────────────────────────────┘
```

---

## Workflow Gates

Six mandatory checkpoints that MUST be verified before proceeding:

### GATE-1: Acceptance Test Exists
- [ ] RED acceptance test defines WHAT (not HOW)
- [ ] Uses domain language only
- [ ] Expresses user-visible behavior
- [ ] Cannot proceed without this

### GATE-2: Unit Test RED
- [ ] Failing unit test for current step
- [ ] Single assertion
- [ ] Tests behavior, not implementation
- [ ] No production code without this

### GATE-3: Function Purity
- [ ] Core functions are pure (no I/O)
- [ ] Shell contains all side effects
- [ ] Same input → same output
- [ ] Deterministic and testable

### GATE-4: Function Size
- [ ] ≤25 lines per function
- [ ] Extract if exceeded
- [ ] Single responsibility
- [ ] Clear, descriptive name

### GATE-5: GREEN Before Refactor
- [ ] All tests passing
- [ ] No RED tests
- [ ] No skipped tests
- [ ] Safe to refactor

### GATE-6: TCR Enforcement
- [ ] GREEN → COMMIT
- [ ] RED → REVERT
- [ ] Never persist RED state
- [ ] Small, atomic commits

---

## Complete Workflow Example

### Scenario: Implement Order Validation

#### Phase 1: ATDD - Define Acceptance Criteria

```python
# GATE-1: Write acceptance test (RED)

def test_should_reject_order_when_cart_is_empty():
    # GIVEN
    customer = register_customer("John Doe")
    # Cart is empty (no items added)
    
    # WHEN
    result = checkout(customer, payment_method="credit_card")
    
    # THEN
    verify_order_rejected(result, reason="empty_cart")

# This test is RED - feature doesn't exist yet
# Commit: "test: should_reject_order_when_cart_is_empty"
```

**Gate Check:**
- ✅ GATE-1: Acceptance test exists and is RED
- Domain language used (checkout, customer, cart)
- No implementation details (no database, HTTP, UI)

---

#### Phase 2: TDD Inner Loop - First Behavior

**Iteration 1: Empty cart validation**

```go
// GATE-2: Write unit test (RED)

func TestRejectEmptyCart(t *testing.T) {
    cart := Cart{Items: []Item{}}
    
    result := ValidateCart(cart)
    
    if result.IsOk() {
        t.Error("expected error for empty cart")
    }
}

// Run test → RED (ValidateCart doesn't exist)
// Predicted failure: "undefined: ValidateCart"
```

```go
// GATE-3 & GATE-4: Minimal, pure implementation

func ValidateCart(cart Cart) Result[Cart] {
    if len(cart.Items) == 0 {
        return Err[Cart]("cart is empty")
    }
    return Ok(cart)
}

// Function is:
// ✅ Pure (no I/O, deterministic)
// ✅ Under 25 lines (2 lines)
// ✅ Single responsibility
```

**Run test → GREEN**

**Skeptical Validation:**
```
Assumptions:
- Cart.Items is always initialized (never nil)
- Empty cart is 0 items (what about nil slice?)

Edge cases:
✅ Empty slice
❌ Nil slice - NOT HANDLED

Potential issues:
- len(nil) == 0 in Go, so works accidentally
- Should explicitly check for nil? Or document assumption?

Verification:
- Current test: empty slice
- Missing test: nil slice

Confidence: MEDIUM
Action: Add test for nil, or document that Cart.Items is never nil
```

**GATE-6: TCR Decision**
- Tests: GREEN ✅
- Action: **COMMIT**
- Message: "green: validate cart rejects empty items"

---

**Iteration 2: Add nil check**

```go
// GATE-2: Write test for nil case (RED)

func TestRejectNilItems(t *testing.T) {
    cart := Cart{Items: nil}
    
    result := ValidateCart(cart)
    
    if result.IsOk() {
        t.Error("expected error for nil items")
    }
}

// Run test → GREEN (already passes because len(nil) == 0)
// Interesting! Nil case already handled.
```

**GATE-6: TCR Decision**
- Tests: GREEN ✅
- Action: **COMMIT**
- Message: "test: verify nil items handled (already passing)"

---

**Iteration 3: Validate item quantities**

```go
// GATE-2: Write test (RED)

func TestRejectInvalidQuantity(t *testing.T) {
    cart := Cart{
        Items: []Item{
            {SKU: "widget", Quantity: 0},  // Invalid!
        },
    }
    
    result := ValidateCart(cart)
    
    if result.IsOk() {
        t.Error("expected error for zero quantity")
    }
}

// Run test → RED (test fails, zero quantity not rejected)
```

```go
// GATE-3 & GATE-4: Extend implementation (PURE, <25 lines)

func ValidateCart(cart Cart) Result[Cart] {
    if len(cart.Items) == 0 {
        return Err[Cart]("cart is empty")
    }
    
    for _, item := range cart.Items {
        if item.Quantity <= 0 {
            return Err[Cart](fmt.Sprintf(
                "invalid quantity for %s", item.SKU))
        }
    }
    
    return Ok(cart)
}

// Still pure, still under 25 lines (9 lines)
```

**Run test → GREEN**

**Skeptical Validation:**
```
Assumptions:
- Quantity <= 0 is invalid (no negative orders)
- SKU exists in error message

Edge cases:
✅ Zero quantity
✅ Negative quantity
❌ MaxInt quantity - NOT HANDLED
❌ Empty SKU - NOT HANDLED

Potential issues:
- Very large quantities could indicate error/attack
- Error message exposes internal SKU

Verification:
Confidence: MEDIUM
Action: Consider max quantity limit, sanitize error messages
```

**GATE-6: TCR Decision**
- Tests: GREEN ✅
- Action: **COMMIT**
- Message: "green: validate item quantities are positive"

---

#### Phase 3: Refactoring

**GATE-5: Check before refactoring**
- All tests GREEN? ✅
- Safe to refactor

```go
// Extract for clarity

func ValidateCart(cart Cart) Result[Cart] {
    if err := checkCartNotEmpty(cart); err != nil {
        return Err[Cart](err.Error())
    }
    
    if err := validateItemQuantities(cart.Items); err != nil {
        return Err[Cart](err.Error())
    }
    
    return Ok(cart)
}

func checkCartNotEmpty(cart Cart) error {
    if len(cart.Items) == 0 {
        return errors.New("cart is empty")
    }
    return nil
}

func validateItemQuantities(items []Item) error {
    for _, item := range items {
        if item.Quantity <= 0 {
            return fmt.Errorf("invalid quantity for %s", item.SKU)
        }
    }
    return nil
}

// Each function:
// ✅ Pure
// ✅ Under 25 lines
// ✅ Single responsibility
```

**Run tests → GREEN**

**GATE-6: TCR Decision**
- Tests: GREEN ✅
- Action: **COMMIT**
- Message: "refactor: extract cart validation helpers"

---

#### Phase 4: ATDD - Check Acceptance Test

```python
# Run acceptance test
# Status: Still RED (need to wire validation to checkout handler)
```

**Next TDD cycles:**
1. Implement checkout handler (shell)
2. Wire validation to handler
3. Handle validation errors
4. Return appropriate response
5. Check acceptance test → GREEN

---

## TCR Protocol in Practice

### Success Case (GREEN)

```
1. Write failing test
2. Write minimal implementation
3. Run tests → GREEN
4. Commit immediately
5. Next iteration
```

### Failure Case (RED)

```
1. Write failing test
2. Write implementation
3. Run tests → RED (unexpected failure)
4. REVERT (don't debug, don't fix)
5. Return to last GREEN
6. Reassess: Was step too large?
7. Take smaller step
```

### Stuck Case (No Progress)

```
1. Write failing test
2. Attempt implementation
3. Not sure how to make it pass
4. REVERT
5. Step back: Do I understand the problem?
6. Options:
   a. Research/read docs
   b. Write exploratory spike (throwaway)
   c. Ask for help
   d. Break into smaller steps
7. Return with clarity
```

---

## ATDD Four-Layer Model

### Layer 1: Test Cases (Domain Language)

```python
def test_should_complete_purchase_when_payment_succeeds():
    customer = register_customer("Alice")
    add_item_to_cart(customer, "widget", quantity=2)
    
    order = checkout(customer, payment_method="credit_card")
    
    verify_order_confirmed(order)
    verify_inventory_reduced("widget", by=2)
```

**Rules:**
- No technical terms (no HTTP, SQL, DOM)
- Business vocabulary only
- Expresses WHAT, not HOW

### Layer 2: DSL (Abstraction)

```python
def checkout(customer, payment_method):
    # Delegates to protocol driver
    return protocol_driver.submit_checkout(customer.id, payment_method)

def verify_order_confirmed(order):
    # Verifies via protocol driver
    status = protocol_driver.get_order_status(order.id)
    assert status == "confirmed"
```

**Rules:**
- Hides HOW system is accessed
- Same DSL works for UI, API, CLI
- Provides test data builders

### Layer 3: Protocol Drivers (Adapters)

```python
class APIDriver:
    def submit_checkout(self, customer_id, payment_method):
        response = http.post(
            f"{base_url}/checkout",
            json={"customer_id": customer_id, "payment": payment_method}
        )
        return Order(response.json())

class UIDriver:
    def submit_checkout(self, customer_id, payment_method):
        browser.click("#checkout-button")
        browser.fill("#payment-method", payment_method)
        browser.click("#confirm")
        # ... wait for confirmation
```

**Rules:**
- One driver per interface (UI, API, CLI)
- Swappable without changing tests
- Absorbs all implementation changes

### Layer 4: System Under Test

```
Application (deployed)
  ├── Database (real)
  ├── Payment Gateway (stubbed)
  └── Email Service (stubbed)
```

**Rules:**
- Production-like deployment
- Real dependencies where possible
- Stub external services
- Fast startup (<10 seconds)

---

## Workflow Summary

**Starting a feature:**
1. ✅ GATE-1: Write RED acceptance test
2. Commit RED acceptance test
3. Begin TDD inner loop

**TDD inner loop (repeat):**
1. ✅ GATE-2: Write RED unit test
2. ✅ GATE-3: Write pure core function
3. ✅ GATE-4: Keep function <25 lines
4. Run test → GREEN
5. Skeptical validation
6. ✅ GATE-6: COMMIT (or REVERT if RED)

**Refactoring:**
1. ✅ GATE-5: Verify all tests GREEN
2. Make small refactoring change
3. Run tests
4. GREEN → COMMIT
5. RED → REVERT immediately

**Completing feature:**
1. Run acceptance test
2. RED → Continue TDD loop
3. GREEN → Feature complete!

---

## Philosophy

This workflow embodies Modern Software Engineering principles:

1. **Optimize for Learning** - Fast feedback via TDD
2. **Work Iteratively** - Tiny steps via TCR
3. **Manage Complexity** - Pure core, thin shell
4. **Measure Progress** - Acceptance tests define "done"
5. **Experiment Scientifically** - Hypothesis (test) → Experiment (code) → Measure (run) → Learn (validate)

**The goal:** Flow through the system, not optimization of the system itself.

Every gate is a quality checkpoint. Every commit is a proven step forward. Every revert is learning.
