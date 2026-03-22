---
name: coding-rigor
description: Engineering discipline for code generation, review, and architecture. Enforces TDD-first development, tiny iterations, clean boundaries, functional core / imperative shell, and contracts. Use when writing code, generating functions/modules/services, reviewing code quality, designing architecture, refactoring, or any task involving software creation or evaluation. Applies Dave Farley's Modern Software Engineering principles. Triggers on any code generation, architectural design, code review, or refactoring request.
license: MIT
compatibility: opencode
metadata:
  author: Dave Farley Principles
  discipline: Modern Software Engineering
  methodology: TDD + ATDD + Functional Core
  references: /home/lewis/references/
---

# Coding Rigor

Engineering discipline based on Dave Farley's Modern Software Engineering. Optimize for learning through fast feedback. Manage complexity through clean boundaries.

---

## Core Principles

This skill enforces disciplined software engineering through:

1. **Hard Constraints** - Non-negotiable quality gates
2. **TDD-First Loop** - Test-driven development cycle  
3. **Tiny Iterations** - Smallest possible increments
4. **Skeptical Validation** - Continuous questioning
5. **Functional Architecture** - Pure core, impure shell
6. **ATDD Four-Layer** - Acceptance test driven development
7. **TCR Protocol** - Test-Commit-Revert enforcement
8. **Workflow Gates** - Six mandatory checkpoints
9. **Language Idioms** - Go and Rust best practices

---

## Quick Reference

### Hard Constraints (Non-Negotiable)

- **≤25 lines per function** (changed from 40 - see references/design-constraints.md)
- **≤5 parameters per function** (use objects/structs if exceeded)
- **Zero implementation without failing test first**
- **One behavior per test**
- **One concept per commit**

Violation requires immediate refactoring before continuing.

### Core TDD Loop

1. Declare constraints and invariants upfront
2. Write failing test that specifies desired behavior
3. Predict how the test will fail before running
4. Write minimal implementation to pass (halt if >25 lines)
5. Run skeptical validation
6. Refactor for clarity while tests stay green

**Never write implementation without corresponding test.**

### TCR Protocol (Test-Commit-Revert)

```
After every change:
- Tests GREEN → COMMIT immediately
- Tests RED → REVERT immediately
- Never persist broken code
```

See: `/home/lewis/references/tcr-protocol.md`

### Output Format for Each Function

```
## Behavior: [what this test specifies]

### Constraints
[invariants and preconditions]

### Test
[test code - written first]

### Predicted Failure
[how test will fail before implementation exists]

### Implementation
[production code - ≤25 lines]

### Validation
- Assumptions: [what I assumed]
- Edge cases: [what I considered]
- Uncertainty: [what might be wrong]

### Refactor Notes
[any cleanup applied]
```

---

## Workflow Gates

**Six mandatory checkpoints that MUST be verified before proceeding:**

### GATE-1: Acceptance Test Exists
- [ ] RED acceptance test defines WHAT (not HOW)
- [ ] Uses domain language only (see ATDD Four-Layer)
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

**Full gate specifications:** `/home/lewis/references/workflow-gates.md`

---

## ATDD Four-Layer Model

Dave Farley's architecture for acceptance tests ensures tests are stable, maintainable, and express domain intent.

```
┌─────────────────────────────────────────────┐
│  Layer 1: TEST CASES                        │
│  (Domain language - WHAT, not HOW)          │
└─────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  Layer 2: DOMAIN SPECIFIC LANGUAGE (DSL)    │
│  (Shared vocabulary, hides implementation)  │
└─────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  Layer 3: PROTOCOL DRIVERS                  │
│  (UI/API/CLI adapters - swappable)          │
└─────────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────┐
│  Layer 4: SYSTEM UNDER TEST                 │
│  (Production-like deployment)               │
└─────────────────────────────────────────────┘
```

**Change resilience:**
- Layer 1 (Test Cases): NEVER change (unless requirements change)
- Layer 2 (DSL): RARELY change (only if domain model changes)
- Layer 3 (Drivers): CHANGE HERE (absorbs implementation changes)
- Layer 4 (SUT): Changes trigger driver updates

**Full specification:** `/home/lewis/references/atdd-four-layer.md`

---

## Functional Core / Imperative Shell

**Mandatory architecture pattern.** All systems MUST separate pure logic from side effects.

```
┌─────────────────────────────────────┐
│      IMPERATIVE SHELL               │
│      (I/O, side effects)            │
│                                     │
│  ┌───────────────────────────────┐  │
│  │   FUNCTIONAL CORE             │  │
│  │   (Pure logic, no I/O)        │  │
│  │                               │  │
│  │   - Business rules            │  │
│  │   - Transformations           │  │
│  │   - Validations               │  │
│  │   - Calculations              │  │
│  └───────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

**Data flow:**
1. Shell reads data (impure I/O)
2. Core transforms data (pure logic)
3. Shell writes result (impure I/O)

**Full constraints:** `/home/lewis/references/design-constraints.md`

---

## Detailed References

For comprehensive guidance on each aspect, see:

### Internal Documentation (This Skill)

- **[constraints.md](constraints.md)** - Hard constraints and red flags (5 commandments)
- **[tdd-loop.md](tdd-loop.md)** - Test-driven development cycle (Red→Green→Refactor)
- **[architecture.md](architecture.md)** - Functional core / imperative shell patterns
- **[go-idioms.md](go-idioms.md)** - Go language patterns
- **[rust-idioms.md](rust-idioms.md)** - Rust language patterns
- **[validation.md](validation.md)** - Skeptical validation protocol (4 questions)
- **[flow.md](flow.md)** - ATDD + TDD + TCR development flow

### External References (Farley Discipline)

**CRITICAL: Read these files for complete understanding:**

- **`/home/lewis/references/atdd-four-layer.md`** - Complete ATDD specification
  - Layer 1: Test Cases (domain language)
  - Layer 2: DSL (abstraction)
  - Layer 3: Protocol Drivers (adapters)
  - Layer 4: System Under Test

- **`/home/lewis/references/design-constraints.md`** - Mandatory architectural rules
  - Functional Core / Imperative Shell (complete specification)
  - Function Purity Rules (checklist)
  - Function Size Limits (25 lines - ENFORCED)
  - Modularity Requirements
  - Coupling Constraints
  - Cohesion Requirements
  - Dependency Rules

- **`/home/lewis/references/tcr-protocol.md`** - Test-Commit-Revert enforcement
  - Core Principle: Never persist broken code
  - The TCR Loop (Code → Test → GREEN/RED → Commit/Revert)
  - Commit Rules
  - Revert Triggers
  - Step Size Calibration
  - Recovery Procedures

- **`/home/lewis/references/workflow-gates.md`** - Six mandatory checkpoints
  - GATE-1: Acceptance Test Exists
  - GATE-2: Unit Test RED
  - GATE-3: Function Purity
  - GATE-4: Function Size (≤25 lines)
  - GATE-5: GREEN Before Refactor
  - GATE-6: TCR Enforcement

---

## When to Use This Skill

Invoke Coding Rigor when:

- ✅ Writing new functions, modules, or services
- ✅ Refactoring existing code
- ✅ Designing system architecture
- ✅ Reviewing code quality
- ✅ Making technical design decisions
- ✅ Implementing features (after Skeptical Implementer planning)
- ✅ Any code generation, architectural design, code review, or refactoring request

---

## Integration with Skeptical Implementer

**Two-phase approach:**

1. **Skeptical Implementer** (Planning Phase)
   - Uses Six Thinking Hats to interrogate requirements
   - Explores all perspectives (facts, emotions, risks, benefits, creativity, process)
   - Produces complete specification with risks/mitigations
   - Gets user buy-in before implementation

2. **Coding Rigor** (Implementation Phase)
   - Takes specification from Skeptical Implementer
   - Enforces ATDD + TDD + TCR workflow
   - Maintains functional core / imperative shell architecture
   - Applies all gates and constraints
   - Delivers production-ready code

**Handoff:** Once Skeptical Implementer completes planning and all six hats are satisfied, Coding Rigor takes over for disciplined implementation.

---

## Complete Development Flow

```
┌─────────────────────────────────────────────────────┐
│ OUTER LOOP: ATDD                                    │
│ - Write RED acceptance test (Layer 1: domain lang)  │
│ - Build DSL (Layer 2: abstraction)                  │
│ - Create Protocol Drivers (Layer 3: adapters)       │
│ - Deploy SUT (Layer 4: production-like)             │
│ - RED until feature complete                        │
├─────────────────────────────────────────────────────┤
│ INNER LOOP: TDD + TCR                               │
│ ┌─────────────────────────────────────────────────┐ │
│ │ GATE-1: Acceptance test exists ✓                │ │
│ │ GATE-2: Write RED unit test                     │ │
│ │ GATE-3: Write pure core function (no I/O)       │ │
│ │ GATE-4: Keep function ≤25 lines                 │ │
│ │ Run test:                                       │ │
│ │   → GREEN: Validate, COMMIT (GATE-6)            │ │
│ │   → RED: REVERT immediately (GATE-6)            │ │
│ │ GATE-5: Tests GREEN? Refactor safely            │ │
│ └─────────────────────────────────────────────────┘ │
├─────────────────────────────────────────────────────┤
│ ARCHITECTURE: Functional Core / Imperative Shell    │
│ - Pure functions in core (deterministic)            │
│ - Side effects in shell (I/O at edges)              │
│ - Dependency inversion at boundaries                │
├─────────────────────────────────────────────────────┤
│ VALIDATION: Scientific Method                       │
│ - Hypothesis (test) → Experiment (code)             │
│ - Measure (run) → Learn (validate)                  │
│ - Four questions: assumptions, edges, issues, proof │
└─────────────────────────────────────────────────────┘
```

---

## Anti-Patterns (FORBIDDEN)

### Code Anti-Patterns
- ❌ Functions >25 lines
- ❌ Functions with >5 parameters
- ❌ Implementation before test
- ❌ Core functions with I/O
- ❌ Global mutable state
- ❌ Persisting RED state

### Test Anti-Patterns
- ❌ Tests with multiple assertions
- ❌ Tests sharing state
- ❌ Tests requiring specific order
- ❌ Acceptance tests with implementation details (SQL, HTTP, selectors)
- ❌ Tests that sleep/wait for arbitrary times

### Workflow Anti-Patterns
- ❌ "I'll write tests later"
- ❌ Debugging instead of reverting
- ❌ Refactoring on RED
- ❌ Skipping gates
- ❌ Large commits with multiple concepts

---

## Philosophy

This skill embodies Dave Farley's Modern Software Engineering:

1. **Optimize for learning** - Fast feedback loops reveal truth (TDD + TCR)
2. **Work iteratively** - Tiny steps, constant verification (TCR)
3. **Manage complexity** - Clean boundaries, pure functions (Functional Core)
4. **Measure progress** - Acceptance criteria, fitness functions (ATDD)
5. **Experiment scientifically** - Hypothesis → Test → Measure → Learn

**The goal:** Flow through the system, not optimization of the system itself.

Every gate is a quality checkpoint. Every commit is a proven step forward. Every revert is learning.

---

## Enforcement Protocol

The AI MUST:

1. **Verify gates before proceeding** - Check all six gates at appropriate times
2. **Read reference files** - Consult `/home/lewis/references/` for complete specifications
3. **Enforce constraints** - 25 lines, 5 parameters, purity, TCR
4. **Follow ATDD layers** - Write tests in domain language, build DSL, create drivers
5. **Apply TCR** - Commit on GREEN, revert on RED, never persist broken code
6. **Validate skeptically** - Answer four questions after every function

Violation response:

```
GATE-[N] VIOLATION DETECTED

Cannot proceed.
Reason: <specific violation>
Reference: /home/lewis/references/<file>.md

Required action:
1. <specific fix>
2. <verification step>
3. Resume workflow
```

---

## Success Metrics

You know you're doing it right when:

- ✅ Every commit is GREEN
- ✅ Functions are ≤25 lines
- ✅ Core is pure (no I/O)
- ✅ Tests express WHAT, not HOW
- ✅ Reverts are quick and painless
- ✅ Architecture is clean (core/shell separation)
- ✅ Acceptance tests in domain language
- ✅ Fast feedback (seconds to minutes per cycle)

**Flow through the system, not optimization of the system itself.**
