# Skeptical Validation

After every function, explicitly question and validate. Do not proceed until uncertainties are surfaced.

---

## Core Principle

**Hidden assumptions become production bugs.**

Every function implementation must be interrogated from multiple angles before moving forward.

---

## Four Critical Questions

After implementing each function, you MUST answer these four questions:

### 1. What assumptions did I make?

Articulate every assumption about:

**Inputs:**
- Format (JSON? CSV? Binary?)
- Range (positive? bounded? normalized?)
- Type (always string? could be nil?)
- Encoding (UTF-8? ASCII?)
- Size (small enough for memory? could be GB?)

**Environment:**
- Files exist at expected paths
- Network is available
- Database is accessible
- Configuration is loaded
- Dependencies are initialized

**Dependencies:**
- Other functions work as expected
- Libraries behave as documented
- External services are available
- Data sources are consistent

**State:**
- Global variables are initialized
- Singleton is constructed
- Cache is populated
- Connection pool is ready

**Example:**
```
Function: ParseConfig(data []byte) (Config, error)

Assumptions made:
- data is valid UTF-8 (what if it's not?)
- data fits in memory (what if config is 10GB?)
- data is well-formed JSON (what if it's malformed?)
- all required fields are present (what if they're missing?)
- values are in expected format (what if "port" is a string?)
```

---

### 2. What edge cases did I consider?

Identify and test boundary conditions:

**Empty Inputs:**
- `nil` pointers/references
- Empty strings `""`
- Empty collections `[]`, `{}`
- Zero values `0`, `0.0`, `false`

**Boundary Values:**
- Minimum: `0`, `-1`, `MinInt`
- Maximum: `MaxInt`, `MaxUint`, infinity
- Off-by-one: `n-1`, `n`, `n+1`

**Invalid Inputs:**
- Malformed data
- Out of range values
- Incorrect types
- Negative where positive expected
- NULL/undefined where value expected

**Concurrency:**
- Multiple threads accessing same data
- Race conditions
- Deadlock scenarios
- Starvation

**Resource Exhaustion:**
- Out of memory
- Out of disk space
- File descriptor limits
- Connection pool exhausted

**Example:**
```
Function: Calculate(a, b int) int

Edge cases considered:
✅ a = 0, b = 0 (both zero)
✅ a = MaxInt, b = 1 (overflow)
✅ a = -1, b = -1 (both negative)
✅ a = MinInt, b = -1 (underflow)
❌ NOT TESTED: concurrent calls (is it thread-safe?)
❌ NOT TESTED: very large inputs causing slow execution
```

---

### 3. What might be wrong?

Proactively identify potential bugs:

**Common Errors:**
- Off-by-one errors
  - Loop conditions: `<` vs `<=`
  - Array access: `arr[len]` vs `arr[len-1]`
  
- Integer overflow/underflow
  - `MaxInt + 1` wraps to `MinInt`
  - Multiplication before division
  
- Floating point precision
  - `0.1 + 0.2 != 0.3` (binary representation)
  - Comparing floats with `==`
  
- Race conditions
  - Shared mutable state
  - Check-then-act patterns
  - Non-atomic operations
  
- Memory leaks
  - Unreleased resources
  - Circular references
  - Forgotten cleanup

- Incorrect error handling
  - Errors silently ignored
  - Panic instead of error return
  - Wrong error messages

**Logic Errors:**
- Conditional logic reversed
- Wrong operator (`&&` vs `||`)
- Missing validation
- Incorrect calculation
- Wrong data structure choice

**Example:**
```
Function: Divide(a, b float64) float64

What might be wrong:
- Division by zero (b == 0) → Panic or Infinity?
- Precision loss with very small numbers
- No handling of NaN inputs
- No handling of Infinity inputs
- Assuming float64 precision is sufficient
```

---

### 4. How do I know it actually works?

Define verification strategy:

**Current Tests:**
- What tests exist?
- What do they prove?
- What scenarios are covered?

**Missing Tests:**
- What edge cases aren't tested?
- What error paths aren't tested?
- What integration scenarios aren't tested?

**Confidence Level:**
- High: Comprehensive test coverage, all edges tested
- Medium: Main paths tested, some edges missing
- Low: Minimal tests, many gaps

**Verification Plan:**
- What additional tests are needed?
- What manual testing is required?
- What monitoring/logging should be added?

**Example:**
```
Function: ValidateEmail(email string) bool

How I know it works:
✅ Test passes for valid email: "user@example.com"
✅ Test rejects empty string
✅ Test rejects missing '@'
✅ Test rejects missing domain

Missing verification:
❌ No test for international characters (IDN)
❌ No test for quoted local part ("name@host")
❌ No test for IP address domain [user@192.168.1.1]
❌ No test for very long emails (>254 chars)
❌ No test for subdomain edge cases

Confidence: MEDIUM
Action needed: Add tests for RFC 5322 edge cases
```

---

## Validation Output Format

After each function implementation, provide this structured validation:

```markdown
## Validation: [FunctionName]

### Assumptions
- **Input:** [assumption about inputs]
- **Environment:** [assumption about environment]
- **Dependencies:** [assumption about dependencies]
- **State:** [assumption about state]

### Edge Cases Considered
✅ [edge case tested]
✅ [edge case tested]
❌ [edge case NOT tested - needs test]

### Potential Issues
- **[Issue category]:** [specific concern]
  - **Impact:** [what breaks if this occurs]
  - **Mitigation:** [how to prevent/handle]

### Verification Status
**Current tests:**
- [test 1 - what it proves]
- [test 2 - what it proves]

**Missing tests:**
- [missing test scenario]
- [missing test scenario]

**Confidence level:** [HIGH/MEDIUM/LOW]

**Action required:**
- [action to increase confidence]
```

---

## Example: Complete Validation

```go
func ParseJSON(data []byte) (Config, error) {
    var config Config
    if err := json.Unmarshal(data, &config); err != nil {
        return Config{}, fmt.Errorf("parse JSON: %w", err)
    }
    return config, nil
}
```

### Validation: ParseJSON

**Assumptions:**
- **Input:** 
  - data is valid UTF-8 bytes
  - data size is reasonable (< 100MB)
  - data contains JSON, not YAML/TOML
- **Environment:** 
  - json library is available (standard library)
  - sufficient memory to unmarshal
- **Dependencies:** 
  - Config struct matches JSON structure
  - json.Unmarshal works correctly
- **State:** 
  - No state dependencies

**Edge Cases Considered:**
✅ Empty data `[]byte{}`
✅ Invalid JSON syntax
✅ JSON with missing fields
❌ Very large JSON (10GB+) - could exhaust memory
❌ Malicious JSON (deeply nested) - stack overflow?
❌ JSON with unexpected extra fields - ignored or error?

**Potential Issues:**
- **Memory exhaustion:** Large JSON could crash program
  - **Impact:** OOM kill in production
  - **Mitigation:** Add size limit check before unmarshal

- **Panic on malformed input:** json.Unmarshal could panic in edge cases
  - **Impact:** Program crash
  - **Mitigation:** Add defer recover or validate before unmarshal

- **Silent field mismatch:** Extra fields in JSON are ignored
  - **Impact:** Configuration drift, missing validation
  - **Mitigation:** Use json.Decoder with DisallowUnknownFields

**Verification Status:**

**Current tests:**
- TestParseValidJSON - proves basic parsing works
- TestParseInvalidJSON - proves error on syntax error

**Missing tests:**
- Empty input test
- Very large input test
- Deeply nested input test (DoS vector)
- Unknown field test
- Type mismatch test (string where int expected)

**Confidence level:** MEDIUM

**Action required:**
1. Add size limit check (1MB max)
2. Add test for large input rejection
3. Add test for malicious deep nesting
4. Consider strict mode for unknown fields

---

## Red Flags

Stop and re-evaluate when you encounter:

### Testing Red Flags

- ❌ **"I can't think of a way to test this"**
  - Problem: Code is not testable
  - Solution: Refactor to make it pure/injectable

- ❌ **"This test is really complicated"**
  - Problem: Code has too many dependencies
  - Solution: Simplify, extract, apply dependency injection

- ❌ **"I need to mock 5 things"**
  - Problem: Function is not pure enough
  - Solution: Extract core logic to pure function

### Implementation Red Flags

- ❌ **"This will probably work"**
  - Problem: Uncertainty about correctness
  - Solution: Add test to verify, or reduce scope

- ❌ **"I'll handle that edge case later"**
  - Problem: Incomplete implementation
  - Solution: Handle it now or add TODO test

- ❌ **"This is getting complicated"**
  - Problem: Function too complex
  - Solution: Break down into smaller functions

### Design Red Flags

- ❌ **"I'm not sure what this should return on error"**
  - Problem: Contract unclear
  - Solution: Define error behavior first, add test

- ❌ **"The test setup is really long"**
  - Problem: Too many dependencies
  - Solution: Refactor to reduce coupling

- ❌ **"I need to read the documentation"**
  - Problem: Missing understanding
  - Solution: Good! Read docs, then implement

---

## Uncertainty Budget

Track your confidence for each function:

| Confidence | Meaning | Action |
|------------|---------|--------|
| **HIGH** | All edges tested, no known issues | Proceed |
| **MEDIUM** | Main paths tested, some edges missing | Add tests or document limitations |
| **LOW** | Minimal testing, many unknowns | STOP - add tests before proceeding |
| **UNKNOWN** | Can't articulate what could go wrong | STOP - don't understand problem |

**Never proceed with UNKNOWN confidence.**

---

## Validation Checklist

Before marking a function as complete:

```
[ ] All four questions answered
[ ] Assumptions documented
[ ] Edge cases identified and tested
[ ] Potential bugs listed
[ ] Verification strategy defined
[ ] Confidence level assessed
[ ] Action items created for gaps
[ ] Red flags addressed
```

---

## Philosophy

**Skepticism is not pessimism. It's engineering rigor.**

By questioning every assumption, we:
- Surface hidden dependencies
- Identify edge cases before production
- Build confidence through explicit verification
- Create a paper trail for future maintainers
- Prevent "works on my machine" bugs

**If you can't articulate what might go wrong, you don't understand the code well enough to ship it.**
