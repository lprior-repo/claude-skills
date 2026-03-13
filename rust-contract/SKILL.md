---
name: rust-contract
description: >
  Design-by-contract specification and Martin Fowler Given-When-Then test
  planning for Rust. Use when asked to: specify a feature, write contracts,
  plan tests, define preconditions or postconditions, design error types,
  create an error taxonomy, plan a Rust function or struct, or write a
  test plan. Does NOT implement code -- produces contract-spec.md and
  martin-fowler-tests.md only. Handles Result types, ownership contracts,
  type-encoded preconditions, and violation examples.
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
model: opus
user-invocable: true
argument-hint: [bead id or feature description]
version: 2.0.0
---

# Rust Contract (Design by Contract + Martin Fowler Tests)

This skill generates **contract-first specifications** and **Martin Fowler style test plans** for Rust work. It does **not** implement code.

```jsonl
{"kind":"meta","skill":"rust-contract","version":"2.0.0","updated":"2026-02","format":"markdown-with-embedded-jsonl"}
{"kind":"principle","id":"contract_first","text":"Define preconditions, postconditions, invariants, and error taxonomy before any implementation."}
{"kind":"principle","id":"fowler_tests","text":"Tests are executable specifications: expressive names, Given-When-Then, happy/error/edge coverage."}
{"kind":"principle","id":"no_implementation","text":"Do not write production code. Output only contracts and test plans."}
{"kind":"principle","id":"railway_oriented","text":"All fallible operations must be expressed as Result<T, Error> in the contract signatures."}
{"kind":"principle","id":"violation_examples","text":"Every precondition and postcondition must have a concrete violation example with the exact input and expected Err variant. Required output, not optional."}
{"kind":"principle","id":"type_first","text":"Every precondition must specify enforcement level: compile-time type (strongest), debug_assert, or Result error variant (weakest). Compile-time is always preferred."}
{"kind":"principle","id":"violation_test_parity","text":"Every violation example in contract-spec.md must have a corresponding named test in martin-fowler-tests.md. Parity is a hard exit criterion."}
{"kind":"principle","id":"ownership_contracts","text":"Every &mut parameter must list mutated fields as postconditions. Ownership transfer and clone decisions are first-class contract concerns."}
```

## Inputs

- Bead ID or feature description
- Any existing constraints, APIs, or domain language

If information is missing, list **open questions** and **assumptions** explicitly.

## Outputs

Produce two artifacts:

1) `contract-spec.md` - Design by contract specification
2) `martin-fowler-tests.md` - Test plan with Given-When-Then scenarios

For bead pipeline workflows, also emit a normalized `contract.md` bundle containing:
- scope map (what/where)
- contract clauses (pre/post/invariants)
- error taxonomy
- traceability mapping
- evaluation protocol

### Artifact Path Resolution (Bead Work)

When a bead id is available, store artifacts under:
- Primary: `.beads/<bead-id>/`

Write and read artifacts only in `.beads/<bead-id>/`.

Canonical resolver snippet:
```bash
BEAD_ID="<bead-id>"
PRIMARY_DIR=".beads/$BEAD_ID"
mkdir -p "$PRIMARY_DIR"
READ_ROOT="$PRIMARY_DIR"
```

## Workflow

### Step 1: Gather Context

- Read relevant docs or bead description
- Identify domain terms and constraints
- List open questions (if any)

### Step 2: Design by Contract

Define the contract **before** tests:

- Preconditions (what must be true before)
- Postconditions (what must be true after)
- Invariants (what is always true)
- Error taxonomy (exhaustive, semantic error variants)
- Function signatures (Result<T, Error> for all fallible ops)

### Step 3: Martin Fowler Test Plan

Create test cases that fully specify behavior:

- Happy path tests (expressive names)
- Error path tests (each failure mode)
- Edge case tests (boundaries, empty, extremes)
- Contract verification tests (pre/post/invariants)
- At least one end-to-end scenario (if applicable)

### Step 4: Exit Criteria

Only finalize if:

- [ ] Every precondition has a type encoding specified (compile-time preferred)
- [ ] Every precondition and postcondition has a concrete violation example
- [ ] Every violation example has a matching named test
- [ ] Every `&mut` parameter has mutation postconditions listed
- [ ] Every failure mode has a corresponding error variant
- [ ] Test names describe behavior unambiguously

## Output Templates

### contract-spec.md

```markdown
# Contract Specification

## Context
- Feature:
- Domain terms:
- Assumptions:
- Open questions:

## Preconditions
- [ ]

## Postconditions
- [ ]

## Invariants
- [ ]

## Error Taxonomy
- Error::InvalidInput - when ...
- Error::NotFound - when ...
- Error::PreconditionViolation - when ...

## Contract Signatures
- fn ... -> Result<..., Error>

## Type Encoding
For each precondition, specify the strongest possible type enforcement:
| Precondition | Enforcement Level | Type / Pattern |
|---|---|---|
| amount > 0 | Compile-time (strongest) | `NonZeroU64` |
| state is valid | Compile-time | `enum ValidState { ... }` |
| string non-empty | Runtime-checked constructor | `NonEmptyString::new() -> Result` |
| invariant X | Debug-only | `debug_assert!()` |
| fallback | Error variant | `Result<T, Error::PreconditionViolated>` |

IMPORTANT: Prefer compile-time enforcement over runtime. Only fall through to
Result if the type system cannot enforce the constraint.

## Violation Examples (REQUIRED -- one per precondition and postcondition)
- VIOLATES <P1>: `<concrete_call>` -- should produce `Err(<ErrorVariant>)`
- VIOLATES <P2>: `<concrete_call>` -- should produce `Err(<ErrorVariant>)`
- VIOLATES <Q1>: `<concrete_state>` after call -- should produce `Err(<ErrorVariant>)`

## Ownership Contracts (Rust-specific)
- Ownership transfer: `fn foo(val: MyType)` -- caller gives up ownership, document why
- Shared borrow: `fn foo(val: &MyType)` -- read-only, no mutation, document lifetime expectations
- Exclusive borrow: `fn foo(val: &mut MyType)` -- mutation contract: what fields change?
- Clone policy: Does this type/function clone? If so, is that intentional or a smell?

IMPORTANT: If a function takes `&mut`, list every field that will be mutated
as a postcondition. "Mutates account.balance" is a postcondition.

## Non-goals
- [ ]
```

### martin-fowler-tests.md

```markdown
# Martin Fowler Test Plan

## Happy Path Tests
- test_returns_success_when_valid_input_provided
- test_creates_resource_when_preconditions_met

## Error Path Tests
- test_returns_error_when_invalid_input
- test_returns_error_when_resource_not_found

## Edge Case Tests
- test_handles_empty_input_gracefully
- test_handles_boundary_values_correctly

## Contract Verification Tests
- test_precondition_<name>
- test_postcondition_<name>
- test_invariant_<name>

## Contract Violation Tests
(One test per violation example in contract-spec.md -- paste example, assert Err variant)
- `test_<precondition_name>_violation_returns_<error_variant>`
  Given: <paste violation example from contract>
  When: function is called with violating input
  Then: returns `Err(<ErrorVariant>)` -- NOT a panic, NOT an unwrap failure

## Given-When-Then Scenarios
### Scenario 1: <name>
Given: ...
When: ...
Then:
- ...
```

## Notes

- Do not implement code in this skill.
- Use ASCII only unless the repo already uses non-ASCII.
- Keep outputs precise, testable, and unambiguous.

> Model note: Use `opus` for contract design on complex ownership hierarchies
> or state machines. Use `sonnet` for simple CRUD-style contracts.
