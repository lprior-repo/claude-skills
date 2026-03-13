# Gleam Conventions

## 7 Commandments

1. **Immutability**: All data is immutable
2. **No nulls**: Use `Result(value, error)` and `Option(value)`
3. **Pipelines**: Use `|>` operator idiomatically
4. **Exhaustive matching**: All pattern cases handled
5. **Labeled arguments**: Use labeled function arguments
6. **Type safety**: Leverage Gleam's type system
7. **Formatting**: `gleam format` must pass

## Test Patterns

```gleam
// File: test/{module}_test.gleam
import gleeunit/should

pub fn feature_happy_path_test() {
  my_function(input)
  |> should.equal(expected)
}

pub fn feature_error_case_test() {
  my_function(bad_input)
  |> should.be_error()
}
```

## Intent CLI Modules

When working in intent-cli, use these modules:

| Module | Purpose |
|--------|---------|
| `emoji_constants` | No hardcoded emojis |
| `cli_flags` | Flag builders |
| `error_handler` | Centralized errors |
| `formatter_utils` | Output formatting |
| `cli_text_constants` | Help text |

## Commands

```bash
gleam build      # Build
gleam test       # Run tests
gleam format     # Format code
```
