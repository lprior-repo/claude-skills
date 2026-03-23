---
name: code-quality-enforcer
description: A relentless code quality guardian that ensures perfect code hygiene across the entire project.
---

# Code Quality Enforcer Skill

A relentless code quality guardian that ensures perfect code hygiene across the entire project.

## Description

This skill enforces strict code quality standards by systematically checking and fixing:
- Compilation errors
- Linting violations
- Test failures
- Warnings and deprecated code
- Code formatting issues

The skill operates with zero tolerance for quality issues and will iteratively fix problems until the codebase is pristine.

## When to Use

Load this skill when:
- You need to ensure code passes all quality gates
- Preparing code for review or deployment
- Systematically improving codebase health
- Fixing technical debt and quality issues
- Running comprehensive code hygiene checks

## Core Principles

1. **Zero Tolerance**: No warnings, errors, or failures are acceptable
2. **Iterative Improvement**: Fix issues systematically until perfection
3. **Automated Detection**: Use project's existing tooling to detect issues
4. **Comprehensive Coverage**: Check compilation, linting, tests, and formatting
5. **Continuous Enhancement**: Each fix is an opportunity to improve the codebase

## Implementation Workflow

### Phase 1: Discovery
1. **Detect Available Tools**: Scan for common quality tools
   - Find compilation commands (`build`, `compile`, `typecheck`)
   - Identify linting tools (`lint`, `eslint`, `ruff`, `clippy`)
   - Locate test runners (`test`, `pytest`, `jest`, `cargo test`)
   - Check formatters (`format`, `prettier`, `rustfmt`)

2. **Baseline Assessment**: Run initial checks to identify all issues
   - Execute all quality tools in parallel
   - Catalog every error, warning, and failure
   - Prioritize critical issues (compilation errors first)

### Phase 2: Iterative Fixing
1. **Critical Path First**: Fix compilation errors immediately
   - Address syntax and type errors
   - Resolve dependency issues
   - Fix import/module problems

2. **Linting Cleanup**: Eliminate all linting violations
   - Style issues and formatting
   - Code complexity and maintainability
   - Security and best practices

3. **Test Resolution**: Ensure all tests pass
   - Fix failing test cases
   - Address integration issues
   - Resolve test environment problems

4. **Warning Elimination**: Remove all warnings
   - Deprecated code usage
   - Unused variables and imports
   - Performance and optimization warnings

### Phase 3: Validation
1. **Full Re-run**: Execute all quality checks again
2. **Zero Issues Verification**: Confirm no errors, warnings, or failures
3. **Final Sanity Check**: Ensure project builds and runs successfully

## Quality Gates

The skill enforces these strict criteria:
- ✅ All compilation succeeds with zero errors
- ✅ All linting passes with zero warnings
- ✅ All tests pass with zero failures
- ✅ Code is properly formatted
- ✅ No deprecated patterns or warnings
- ✅ Zero unused code or imports

## Available Commands

### Primary Commands
- `quality-check`: Run comprehensive quality assessment
- `fix-all`: Automatically fix all detected issues
- `validate`: Verify zero quality issues remain
- `improve`: Enhance code quality beyond minimum standards

### Diagnostic Commands
- `scan-tools`: Detect available quality tools
- `assess`: Generate detailed quality report
- `status`: Show current quality metrics
- `health`: Overall codebase health score

### Iterative Commands
- `fix-compile`: Focus on compilation issues
- `fix-lint`: Address linting violations
- `fix-tests`: Resolve test failures
- `fix-warnings`: Eliminate all warnings

## Tool Detection Logic

### Language-Specific Tools
- **JavaScript/TypeScript**: npm scripts (build, lint, test, format)
- **Python**: poetry/pip tools (pytest, ruff, black, mypy)
- **Rust**: cargo commands (check, clippy, test, fmt)
- **Go**: go commands (build, vet, test, fmt)
- **Java**: Maven/Gradle tasks (compile, checkstyle, test)
- **C#**: .NET CLI (build, lint, test, format)

### Configuration Files Detection
- `package.json`, `tsconfig.json`, `.eslintrc`
- `pyproject.toml`, `setup.py`, `.flake8`
- `Cargo.toml`, `.rustfmt.toml`
- `go.mod`, `Makefile`
- `pom.xml`, `build.gradle`

## Error Recovery Strategies

### Compilation Errors
- Fix syntax issues first
- Resolve type mismatches
- Address missing dependencies
- Correct import statements

### Linting Violations
- Auto-fix where possible
- Manual fix for complex issues
- Update configuration if rules are too restrictive
- Document intentional violations with comments

### Test Failures
- Fix assertion logic
- Update test expectations
- Address mocking/stubbing issues
- Fix test environment setup

### Warnings
- Remove unused code
- Update deprecated APIs
- Address performance warnings
- Fix type safety issues

## Integration with Workflows

This skill integrates seamlessly with:
- Pre-commit hooks
- CI/CD pipelines
- Code review processes
- Development workflows
- Deployment procedures

## Success Metrics

The skill measures success by:
- Zero compilation errors
- Zero linting violations
- Zero test failures
- Zero warnings
- Perfect formatting adherence
- Improved code maintainability scores
- Enhanced developer experience

## Continuous Improvement

Beyond fixing existing issues, the skill:
- Identifies patterns that cause quality issues
- Suggests preventive measures
- Recommends tooling improvements
- Encourages better coding practices
- Documents quality standards

## Exit Criteria

The skill completes when:
1. All quality gates pass
2. Zero errors, warnings, or failures remain
3. Code compiles successfully
4. All tests pass
5. Code is properly formatted
6. No deprecated patterns exist
7. The codebase meets all quality standards

Remember: Good enough isn't good enough. Perfect code quality is the only acceptable outcome.