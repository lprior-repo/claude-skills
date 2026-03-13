# LTC - Little Test Command

A comprehensive code quality enforcer that ensures zero compilation errors, linting violations, test failures, or warnings exist.

## Usage

```bash
# Run full quality check and fix
node ~/.claude/skills/code-quality-enforcer/ltc.js

# Or create an alias in your shell
alias ltc="node ~/.claude/skills/code-quality-enforcer/ltc.js"
ltc
```

## What LTC Does

### 1. **Detects Tools Automatically**
- **Node.js**: npm scripts (build, lint, test, format, typecheck)
- **Python**: ruff, black, mypy, pytest
- **Rust**: cargo check, clippy, test, fmt
- **Go**: go build, vet, test, fmt

### 2. **Runs Comprehensive Quality Checks**
- Compilation/Type checking (highest priority)
- Linting violations
- Test failures
- Formatting issues

### 3. **Fixes Issues Iteratively**
- Fixes compilation errors first
- Addresses linting violations
- Resolves test failures
- Eliminates formatting problems

### 4. **Validates Zero Tolerance Policy**
- Re-runs all checks after fixes
- Ensures no issues remain
- Reports on fixes applied

## Quality Enforcement Philosophy

- **Zero Tolerance**: No warnings, errors, or failures acceptable
- **Iterative Improvement**: Fix systematically until perfect
- **Comprehensive Coverage**: All quality gates must pass
- **Automated Detection**: Uses project's existing tooling

## Exit Criteria

LTC completes successfully when:
- ✅ All compilation succeeds
- ✅ All linting passes
- ✅ All tests pass
- ✅ Code is properly formatted
- ✅ Zero warnings exist
- ✅ Perfect code quality achieved

## Integration

Add to your shell configuration for easy access:

```bash
# In ~/.bashrc or ~/.zshrc
alias ltc="node ~/.claude/skills/code-quality-enforcer/ltc.js"

# Then run from any project directory
ltc
```

Perfect for:
- Pre-commit validation
- CI/CD pipelines
- Code review preparation
- Development workflow enforcement
- Technical debt elimination

Remember: Good enough isn't good enough. LTC enforces perfect code quality, every time.