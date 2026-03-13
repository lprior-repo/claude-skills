---
name: tdd15-phase-06-refactor
description: PHASE 6 REFACTOR - Clean and optimize code while keeping tests green. Improve readability, reduce duplication, apply Gleam idioms.
allowed-tools: Read,Write,Edit,Glob,Grep,Bash,Task
model: sonnet
user-invocable: false
---

# Phase 6: REFACTOR

## Phase Purpose

Improve code quality while keeping all tests green:
1. Simplify logic without changing behavior
2. Extract duplicated code
3. Apply Gleam idioms (pipelines, pattern matching, etc.)
4. Improve readability
5. Rename for clarity
6. Organize code logically

**Key Principle**: Refactor in small steps, running tests after each change.

## Execution Steps

### Step 1: Run Tests (Baseline)

```bash
gleam test
```

Ensure all tests pass before refactoring.

### Step 2: Identify Refactoring Opportunities

Scan the code for:
- **Duplication**: Same logic in multiple places
- **Complex logic**: Conditionals that could be simpler
- **Poor names**: Variables/functions unclear
- **Type opportunities**: Missing abstractions that would clarify intent
- **Gleam idioms**: Code that could use pipes, patterns, or utilities better

Example refactoring needs:
```gleam
// Before: Imperative-style error handling
pub fn process(input: String) -> Result(String, Error) {
  case parse(input) {
    Ok(value) -> {
      case transform(value) {
        Ok(result) -> Ok(result)
        Error(e) -> Error(e)
      }
    }
    Error(e) -> Error(e)
  }
}

// After: Pipeline style (more idiomatic)
pub fn process(input: String) -> Result(String, Error) {
  input
  |> parse()
  |> result.try(transform)
}
```

### Step 3: Refactor in Small Steps

For each refactoring:
1. Make one small change
2. Run `gleam test`
3. Verify tests pass
4. Commit or note the change
5. Move to next refactoring

Never refactor multiple things at once.

### Step 4: Common Refactorings

#### Extract Helper Functions
```gleam
// Before: Long function with repeated patterns
pub fn process_items(items: List(String)) -> List(String) {
  list.map(items, fn(item) {
    string.trim(item)
    |> string.lowercase()
    |> string.split_once(on: ":")
  })
}

// After: Extracted helper
fn parse_item(item: String) -> Result(Key, Value) {
  item
  |> string.trim()
  |> string.lowercase()
  |> string.split_once(on: ":")
}

pub fn process_items(items: List(String)) -> List(Result(Key, Value)) {
  list.map(items, parse_item)
}
```

#### Apply Pipelines
```gleam
// Before: Nested function calls
pub fn validate(input: String) -> Result(Validated, Error) {
  case string.trim(input) {
    trimmed -> {
      case string.length(trimmed) > 0 {
        True -> Ok(Validated(trimmed))
        False -> Error(EmptyInput)
      }
    }
  }
}

// After: Pipeline
pub fn validate(input: String) -> Result(Validated, Error) {
  input
  |> string.trim()
  |> fn(trimmed) {
    case string.length(trimmed) > 0 {
      True -> Ok(Validated(trimmed))
      False -> Error(EmptyInput)
    }
  }
}
```

#### Better Type Names
```gleam
// Before: Generic names
pub type T1 {
  V1(String)
  V2(Int)
}

// After: Descriptive names
pub type EmailValidation {
  Valid(EmailAddress)
  Invalid(ValidationError)
}
```

#### Use Result.try
```gleam
// Before: Nested case
case parse(a) {
  Ok(val1) -> {
    case parse(b) {
      Ok(val2) -> Ok([val1, val2])
      Error(e) -> Error(e)
    }
  }
  Error(e) -> Error(e)
}

// After: Result.try
use val1 <- result.try(parse(a))
use val2 <- result.try(parse(b))
Ok([val1, val2])
```

### Step 5: Verify Tests After Each Change

```bash
gleam test
```

After every refactoring, confirm:
- [ ] All tests pass
- [ ] Same number of tests passing
- [ ] No new warnings

### Step 6: Format Final Code

```bash
gleam format
```

### Step 7: Build and Test One More Time

```bash
gleam build && gleam test
```

Final confirmation everything works.

## Gate: tests_green

**Pass Criteria**:
- [ ] All tests still pass (same tests, same results)
- [ ] Code is more readable than before
- [ ] No duplication remains (DRY principle)
- [ ] Gleam idioms applied (pipelines, pattern matching, Result.try)
- [ ] Type names are clear and descriptive
- [ ] Functions are focused (single responsibility)
- [ ] Build succeeds with no warnings
- [ ] Code formatted with gleam format

**Halt Criteria**:
- Tests fail after refactoring
- Over-engineered new abstractions
- Code became more complex instead of simpler
- Introduced new errors or edge cases

**On Failure**:
```
Phase 6 REFACTOR FAILED: Tests broken or code not improved
Issue: [What went wrong]
Action: Revert change or fix the test failure
```

**On Success**: Advance to Phase 7 MARTIN FOWLER CHECK #1

## Refactoring Checklist

- [ ] Code is simpler than before
- [ ] No duplicated logic remains
- [ ] Variable names are clear
- [ ] Function names describe purpose
- [ ] Gleam idioms used appropriately
- [ ] All tests passing
- [ ] No compiler warnings
- [ ] Code follows Gleam style

## Gleam Idioms Reference

| Idiom | Before | After |
|-------|--------|-------|
| Pipeline | `f(g(h(x)))` | `x \| h() \| g() \| f()` |
| Result.try | Nested case | `use result <- result.try(...)` |
| List map | case/recursion | `list.map(items, fn)` |
| Pattern match | if/else | `case x { A -> ... B -> ... }` |

## Integration Points

**Phase 5**: Refactors GREEN code
**Files**: Modifies src/intent/<feature>.gleam
**Tests**: Uses Phase 4 tests as specification
**Next Phase**: Phase 7 checks quality with Martin Fowler checklist

## Notes

- Refactor in tiny steps—makes it easy to find what broke
- Tests are your safety net: they prove refactoring didn't break behavior
- Don't add new features during refactoring
- Don't optimize for edge cases not covered by tests
- Gleam's type system helps catch many refactoring mistakes

## Nu Backbone
- Start: `tdd15 phase-start <session> 6`
- Gate: `tdd15 gate-check <session> 6 '<result>'`
- Model/threshold may escalate on retry: `tdd15 model <session> 6`, `tdd15 threshold <session> 6`
