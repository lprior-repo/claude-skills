---
name: tdd15-phase-13-consistency
description: PHASE 13 CONSISTENCY - CLI consistency standards validation. Verify emoji constants, CLI flags, error handler, formatter utils, and Gleam 7 Commandments.
allowed-tools: Read,Write,Edit,Glob,Grep,Bash,Task
model: sonnet
user-invocable: false
---

# Phase 13: CONSISTENCY CHECK

## Phase Purpose

Verify CLI consistency standards from CLAUDE.md:
1. Emoji constants used (no hardcoding)
2. CLI flags builders used
3. Error handler module used
4. Formatter utils used
5. Gleam 7 Commandments followed

## Execution Steps

### Step 1: Run Code Review Agent

```bash
Task(
  subagent_type: "pr-review-toolkit:code-reviewer",
  description: "Review code for CLI consistency standards",
  prompt: "
    Review code for Intent CLI consistency standards:
    - emoji_constants.gleam usage (no hardcoded ✓✗⚠️)
    - cli_flags builders usage
    - error_handler module usage
    - formatter_utils usage
    - Gleam 7 Commandments adherence
  "
)
```

### Step 2: Standard 1: Emoji Constants

**Check**: All emojis from `emoji_constants.gleam`, none hardcoded

```gleam
// WRONG
let icon = "✓"
let error = "❌"
let warn = "⚠️"

// RIGHT
import intent/emoji_constants as emoji
let icon = emoji.success
let error = emoji.failure
let warn = emoji.warning
```

Verify:
```bash
grep -r "\"✓\"" src/
grep -r "\"✗\"" src/
grep -r "\"⚠️\"" src/
grep -r "\"❌\"" src/
# Should return: 0 results (none in src/, all in emoji_constants)
```

### Step 3: Standard 2: CLI Flags

**Check**: All flag definitions use `cli_flags` builders

```gleam
// WRONG
pub fn my_command() -> ... {
  let target = flags.string("--target", "http://localhost:8080")
  ...
}

// RIGHT
import intent/cli_flags
let target_flag = cli_flags.target_flag()
```

Verify:
- [ ] target_flag uses cli_flags.target_flag()
- [ ] json_flag uses cli_flags.json_flag()
- [ ] All flags use builders, not manual definitions

### Step 4: Standard 3: Error Handler

**Check**: All errors use `error_handler` module

```gleam
// WRONG
Error("Something went wrong")

// RIGHT
import intent/error_handler

let error = error_handler.generic_error(
  "Something went wrong",
  "Check your input",
  ["Verify the file exists", "Try again"]
)
error_handler.output_error(error, is_json)
```

Verify:
```bash
grep -r "Error(\"" src/ | wc -l
# Should be minimal (only error_handler uses this pattern)
```

### Step 5: Standard 4: Formatter Utils

**Check**: All output formatting uses `formatter_utils`

```gleam
// WRONG
let output = "╔═══════════════════════════════════╗\n"
  <> "║ Result\n"
  <> "╚═══════════════════════════════════╝"

// RIGHT
import intent/formatter_utils as fmt

let output = fmt.box_header("Result")
  <> fmt.score_with_status(85.5)
```

Verify:
- [ ] Box headers use fmt.box_header()
- [ ] Progress bars use fmt.progress_bar()
- [ ] Indentation uses fmt.indent_n()
- [ ] Sections use fmt.section_header()

### Step 6: Standard 5: Gleam 7 Commandments

#### Commandment 1: Immutability
No mutable state, no reassignments.

```gleam
// WRONG
let mut x = 0
x = x + 1

// RIGHT
let values = [0, 1, 2]
let doubled = list.map(values, fn(x) { x * 2 })
```

#### Commandment 2: No Nulls
Use Result/Option, never unwrap.

```gleam
// WRONG
let value = result.unwrap(parse_result)

// RIGHT
use value <- result.try(parse_result)
```

#### Commandment 3: Pipelines
Use `|>` operator idiomatically.

```gleam
// WRONG
let step1 = transform1(input)
let step2 = transform2(step1)
let result = transform3(step2)

// RIGHT
input
|> transform1()
|> transform2()
|> transform3()
```

#### Commandment 4: Exhaustive Matching
All pattern cases handled (Gleam enforces).

```gleam
// WRONG: Missing Error case
case parse(input) {
  Ok(value) -> value
}

// RIGHT: All cases handled
case parse(input) {
  Ok(value) -> value
  Error(e) -> handle_error(e)
}
```

#### Commandment 5: Labeled Arguments
Use labeled function arguments.

```gleam
// WRONG
pub fn validate(string, int, bool) { ... }
validate("email", 256, False)  // What's what?

// RIGHT
pub fn validate(value: String, max_length: Int, strict_mode: Bool) { ... }
validate(value: "email", max_length: 256, strict_mode: False)  // Clear!
```

#### Commandment 6: Type Safety
Leverage Gleam's type system.

```gleam
// WRONG: String instead of type
pub fn process(mode: String) -> String { ... }
process("email")  // Typo-prone

// RIGHT: Custom type
pub type Mode { Email EmailMode Sms SmsMode }
pub fn process(mode: Mode) -> Result(...) { ... }
process(Email(EmailMode(...)))  // Type-safe
```

#### Commandment 7: Formatting
`gleam format` passes.

```bash
gleam format --check
# Must pass with 0 issues
```

### Step 7: Create Compliance Report

```
PHASE 13 CONSISTENCY CHECK REPORT
═════════════════════════════════════════

Standard 1: Emoji Constants
- Status: ✓ COMPLIANT
- Hardcoded emojis: 0
- Using emoji_constants: 12
- Result: PASS

Standard 2: CLI Flags
- Status: ✓ COMPLIANT
- Flags defined: 5
- Using cli_flags builders: 5 (100%)
- Result: PASS

Standard 3: Error Handler
- Status: ✓ COMPLIANT
- Error returns: 8
- Using error_handler: 8 (100%)
- Result: PASS

Standard 4: Formatter Utils
- Status: ✓ COMPLIANT
- Output statements: 6
- Using formatter_utils: 6 (100%)
- Result: PASS

Standard 5: Gleam 7 Commandments
- Immutability: ✓ No mutable state
- No unwrap: ✓ Using Result.try
- Pipelines: ✓ Idiomatic usage
- Exhaustive matching: ✓ All cases handled
- Labeled arguments: ✓ Used throughout
- Type safety: ✓ Custom types used
- Formatting: ✓ gleam format passes

Overall: ✓ ALL STANDARDS MET
```

## Gate: standards_met

**Pass Criteria**:
- [ ] All emoji constants used (no hardcoding)
- [ ] All CLI flags use builders
- [ ] All errors use error_handler
- [ ] All output uses formatter_utils
- [ ] No mutable state
- [ ] No unwrap() calls without justification
- [ ] Pipelines used idiomatically
- [ ] All patterns exhaustively matched
- [ ] Labeled arguments used
- [ ] Type safety leveraged
- [ ] gleam format passes

**Halt Criteria**:
- Hardcoded emojis found
- Manual flag definitions found
- Non-standard error handling
- Missing formatter utilities
- Gleam 7 violations

**On Failure**:
```
Phase 13 CONSISTENCY FAILED

Standards Violations:
- [Standard]: [Count] violations
  Example: [Code snippet]

Action: Fix violations and resubmit
```

**On Success**: Advance to Phase 14 CODE LIABILITY

## Compliance Checklist

- [ ] emoji_constants used throughout
- [ ] cli_flags builders used for all flags
- [ ] error_handler used for all errors
- [ ] formatter_utils used for output
- [ ] No mutable state in code
- [ ] No unwrap() without Result.try equivalent
- [ ] Pipe operator used throughout
- [ ] All pattern matches exhaustive
- [ ] Labeled arguments on functions
- [ ] Custom types instead of strings
- [ ] gleam format passes

## Integration Points

**Phase 12**: Prerequisite (Martin Fowler #2 passed)
**CLAUDE.md**: References CLI Consistency Standards section
**Code Review**: Uses pr-review-toolkit:code-reviewer agent
**Next Phase**: Phase 14 CODE LIABILITY (minimize code)

## Notes

- Standards are non-optional—they're required
- Consistency enables team collaboration
- These standards are from CLAUDE.md, not new
- Phase 13 is last chance before landing
- Code that passes Phase 13 is production-ready

## Nu Backbone
- Start: `tdd15 phase-start <session> 13`
- Gate: `tdd15 gate-check <session> 13 '<result>'`
- Model/threshold may escalate on retry: `tdd15 model <session> 13`, `tdd15 threshold <session> 13`
