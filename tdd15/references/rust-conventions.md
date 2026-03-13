# Rust Conventions (Functional Only)

## Zero Panics Rule

**NEVER use in non-test code**:
- `unwrap()`
- `expect()`
- `panic!()`
- `unreachable!()`
- `assert!()` (outside tests)

## Railway-Oriented Programming

```rust
// Good: Chain with ?
fn process(input: Input) -> Result<Output, Error> {
    let validated = validate(input)?;
    let transformed = transform(validated)?;
    let result = finalize(transformed)?;
    Ok(result)
}

// Bad: Manual matching
fn process(input: Input) -> Result<Output, Error> {
    match validate(input) {
        Ok(v) => match transform(v) { ... }
        Err(e) => Err(e)
    }
}
```

## Error Handling

```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum MyError {
    #[error("validation failed: {0}")]
    Validation(String),
    #[error("IO error: {0}")]
    Io(#[from] std::io::Error),
}
```

## Functional Patterns

- Prefer iterators over loops
- Use `map`, `and_then`, `or_else`, `unwrap_or_default`
- Exhaustive pattern matching
- No `let mut` in core logic
- No `RefCell`/`Cell` in core logic

## Commands

```bash
cargo build      # Build
cargo test       # Run tests
cargo fmt        # Format
cargo clippy     # Lint
```
