# Red Queen Automated Weapons

## `mutate` — Rust Mutation Testing

Runs `cargo-mutants` and records uncaught mutants as gen-survivors.

```bash
nu $L mutate drq-session /path/to/rust/project --file src/lib.rs --function parse --timeout 300
```

- **Requires**: `cargo-mutants` installed, active generation
- **MissedMutant** → gen-survivor (dimension: `mutation`), auto-escalates to CRITICAL for pub API
- **CaughtMutant** → gen-discard

## `spec-mine` — Promise Extraction

Mines any project for testable promises.

```bash
nu $L spec-mine drq-session /path/to/project --bin myapp --readme /path/to/README.md
```

| Source | Method | Dimension |
|--------|--------|-----------|
| README.md | Extract fenced bash blocks | `spec-readme` |
| CLI --help | Parse subcommands | `spec-help` |
| Rust doctests | `cargo test --doc` | `spec-doctest` |
| Python doctests | `python -m doctest` | `spec-doctest` |
| Debt markers | Grep TODO/FIXME/HACK | `spec-debt` |
| Rust type safety | `cargo clippy -- -D clippy::unwrap_used` | `spec-type-safety` |

## `quality-gate` — Code Quality Checks

```bash
nu $L quality-gate drq-session /path/to/project
```

| Gate | Command | Dimension |
|------|---------|-----------|
| No Panic | `cargo clippy -- -D clippy::unwrap_used -D clippy::expect_used -D clippy::panic` | `fp-gate-no-panic` |
| Exhaustive Match | `cargo clippy -- -D clippy::wildcard_enum_match_arm` | `fp-gate-exhaustive` |
| Format | `cargo fmt --check` | `fp-gate-format` |
| Lint | `cargo clippy -- -D warnings` | `fp-gate-lint` |
| Tests | `cargo test` | `fp-gate-tests` |
| Coverage | `cargo tarpaulin` (< 80% → survivor) | `fp-gate-coverage` |

## `fowler-review` — Martin Fowler Code Review

```bash
nu $L fowler-review drq-session /path/to/project --complexity-threshold 15
```

| Metric | Threshold | Dimension |
|--------|-----------|-----------|
| Cyclomatic complexity | > 15 | `fowler-complexity` |
| Function length (SLOC) | > 50 | `fowler-large-fn` |
| Nesting depth | > 4 | `fowler-deep-nesting` |
| `.unwrap()` | AST pattern | `fowler-unwrap` |
| `todo!()` | AST pattern | `fowler-todo` |

**Required tools**: `rust-code-analysis-cli`, `ast-grep`/`sg`, `cargo-llvm-cov`, `cargo-geiger`, `cargo-audit`, `tokei`
