# Phase 10: FP Micro-Gates (Parallel)

## Overview

Run 5 functional programming checks **in parallel** using haiku agents.

Per Anthropic: "Launch multiple agents concurrently whenever possible."

## The 5 Gates

### 10a: IMMUTABILITY
```
Task(subagent_type="general-purpose", model="haiku")

Check for mutable state:
- Gleam: Any `let assert`? (should be exhaustive match)
- Rust: Any `let mut`? `RefCell`? `Cell`? `&mut` in core?

Output: {"violations": [...], "pass": true}
```

### 10b: PURITY
```
Task(subagent_type="general-purpose", model="haiku")

Check for uncontrolled side effects:
- Are IO/network/file at boundaries only?
- Is core logic pure (input → output)?

Output: {"violations": [...], "pass": true}
```

### 10c: NO PANIC
```
Task(subagent_type="general-purpose", model="haiku")

Check for panic risks:
- Gleam: Any `panic` or `todo`?
- Rust: Any `unwrap()`, `expect()`, `panic!()`, `unreachable!()`?

Output: {"violations": [...], "count": 0, "pass": true}
```

### 10d: EXHAUSTIVE MATCHING
```
Task(subagent_type="general-purpose", model="haiku")

Check pattern matching:
- Any `_` catchall that hides cases?
- Any non-exhaustive matches?

Output: {"violations": [...], "pass": true}
```

### 10e: RAILWAY
```
Task(subagent_type="general-purpose", model="haiku")

Check error handling:
- Gleam: Using Result properly? No nested case?
- Rust: Using `?` operator? No manual match on Result?

Output: {"violations": [...], "pass": true}
```

## Aggregated Output

Write to `.tdd15-cache/$ARGUMENTS/omarchy.json`:

```json
{
  "immutability": {"pass": true, "violations": []},
  "purity": {"pass": true, "violations": []},
  "no_panic": {"pass": true, "count": 0},
  "exhaustive": {"pass": true, "violations": []},
  "railway": {"pass": true, "violations": []},
  "overall_pass": true,
  "critical_count": 0
}
```

## Gate

`no_critical_issues` - overall_pass=true, critical_count=0

## Nu Backbone
- Start: `tdd15 phase-start <session> 10`
- Gate: `tdd15 gate-check <session> 10 '<result>'`
- Model/threshold may escalate on retry: `tdd15 model <session> 10`, `tdd15 threshold <session> 10`
