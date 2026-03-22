---
name: bitter-truth
description: High-velocity outcome-driven development. Code is disposable, output is everything. Leverage massive compute to search solution space. Speed trumps elegance. Contract validation is absolute. Ship incredibly fast through small consistent changes. Based on Rich Sutton's Bitter Lesson and Ramp's slope culture.
license: MIT
compatibility: opencode
metadata:
  philosophy: Rich Sutton's Bitter Lesson
  culture: Ramp (slope) + Stripe (reliability) + AWS (rigor)
  principle: Velocity is King
  references: /home/lewis/references/
---

# Bitter Truth: High-Velocity Outcome-Driven Development

Code is not an asset. It is a disposable traverse. We define a destination (Output/Contract) and burn compute to find a path to it. Once the data arrives, the path is irrelevant.

**Velocity is the only metric. Ship incredibly fast through small consistent changes.**

**See:** [Ramp Velocity Research](file:///home/lewis/references/ramp-velocity.md) - Complete engineering practices and playbook from Ramp's high-velocity culture.

---

## Core Philosophy

Based on Rich Sutton's "The Bitter Lesson": General methods that leverage massive computation (search and learning) ultimately crush human-designed, domain-specific cleverness.

**We don't build software. We generate transient runtime logic that exists only for the duration of execution.**

**References:**
- [Ramp Engineering Velocity](file:///home/lewis/references/ramp-velocity.md) - Real-world high-velocity practices

---

## Jevons Paradox: The AI Coding Explosion

### The Paradox Defined

**William Stanley Jevons (1865):** When technological progress increases the efficiency of resource use, consumption of that resource tends to INCREASE, not decrease.

**Example:** Steam engines became more fuel-efficient → Coal consumption skyrocketed (because more things used steam engines)

### The AI Coding Version

**The Expectation:** AI makes coding easier → We write less code

**The Reality:** AI makes coding easier → **We write VASTLY more code**

**Why:** When cost drops, consumption explodes.

### The Economic Shift

**Before AI:**
- Writing 1000 lines: 2-3 days
- Developer cost: $500-1500
- Maintenance cost: Forever
- **Constraint:** Human typing speed + cognitive load

**After AI:**
- Writing 1000 lines: 10-30 minutes
- AI cost: $0.50-5.00
- Maintenance cost: Still forever
- **Constraint:** REMOVED

**Result:** We now generate 10-100x more code for the same project.

### The Amplification

**What happens when coding is 100x cheaper:**

1. **More experiments** → Try 10 approaches instead of 1
2. **More features** → Ship 50 features instead of 5
3. **More variations** → Generate mobile + web + API + CLI instead of just one
4. **More iterations** → Regenerate 20 times instead of getting it right once
5. **More prototypes** → Build 10 MVPs to test market fit

**The math:**
- Old: 1 project × 10,000 lines = 10,000 lines
- New: 10 experiments × 5 variations × 2 platforms × 5 rewrites × 10,000 lines = **5,000,000 lines**

**We're not reducing code. We're exploding it.**

### The Velocity Imperative

**This is WHY velocity practices matter MORE in the AI era:**

**Problem:** AI makes it trivial to generate millions of lines of code

**Disaster scenario:**
- Generate 100K lines in a day
- Now you maintain 100K lines forever
- Debugging 100K lines of AI spaghetti = Hell
- Velocity CRASHES

**Velocity solution:**
- Generate 100K lines in a day
- Keep only 1K lines that passed contracts
- Delete 99K lines immediately
- Regenerate tomorrow if needed
- Velocity SUSTAINS

### The Code Explosion Examples

**Traditional approach:**
```
Build user authentication
→ 1 implementation
→ 2000 lines
→ 3 days of work
```

**AI era (naive):**
```
Build user authentication
→ Try JWT
→ Try OAuth
→ Try passwordless
→ Try magic links
→ Try social logins
→ 5 implementations × 2000 lines = 10,000 lines
→ 2 hours of generation
→ Now maintain 10,000 lines forever
```

**AI era (velocity-conscious):**
```
Build user authentication
→ Try JWT (fails contract)
→ Try OAuth (fails contract)
→ Try passwordless (passes contract)
→ DELETE JWT code
→ DELETE OAuth code
→ Keep 2000 lines of passwordless
→ 2 hours of generation, 2000 lines maintained
```

### The Maintenance Catastrophe

**Jevons Paradox creates a maintenance crisis:**

**Year 1:** AI generates 1M lines across 100 experiments
**Year 2:** Half the experiments failed, but code still exists
**Year 3:** Nobody remembers why 500K lines exist
**Year 4:** "Should we delete this?" "I don't know, might break something"
**Year 5:** Codebase is 5M lines, velocity is ZERO

**The Velocity Answer:** Delete aggressively. Code is disposable.

### Regeneration Economics

**Old economics:**
- Write once: $1000
- Maintain forever: $100/month
- Total (5 years): $7000

**New economics (maintain):**
- Generate once: $5
- Maintain forever: $100/month
- Total (5 years): $6005
- **Still terrible**

**New economics (regenerate):**
- Generate: $5
- Use for 1 week
- Delete
- Regenerate when needed: $5
- Total (5 years): $260
- **Winner**

**The shift:** Regeneration is cheaper than maintenance when generation is cheap.

### The Paradox in Practice

**Real scenarios where Jevons Paradox strikes:**

**1. Feature explosion**
- Old: Build 1 feature, ship it
- AI: Build 10 variations, A/B test, keep best
- Result: 10x more code generated, 1x code shipped (if you delete)

**2. Platform multiplication**
- Old: Web only
- AI: Generate web + mobile + desktop + CLI + API in parallel
- Result: 5x more code

**3. Iteration explosion**
- Old: Write once, debug, ship
- AI: Generate → fail → regenerate → fail → regenerate (10x)
- Result: 10x more code generated (but only 1x kept if you delete)

**4. Experiment explosion**
- Old: One approach, commit to it
- AI: Try every approach, pick winner
- Result: 10x more code paths explored

### Why This Demands Velocity Practices

**The trap:**
AI makes coding so easy that we generate code faster than we can think.

**The symptoms:**
- Codebase doubles every month
- Nobody knows what half the code does
- "Let's just regenerate" becomes "Let's just keep it all"
- Technical debt explodes
- Velocity dies

**The antidote:**
1. **Atomic changes** → Each generation is tiny and deletable
2. **Fast feedback** → Know immediately if code is needed
3. **Automated quality** → No human review bottleneck
4. **Trunk-based flow** → No long-lived branches accumulating dead code
5. **Bias for deletion** → Default is DELETE, not KEEP

### The Counter-Intuitive Truth

**Intuition:** AI generates code fast → Keep it all (it was free!)

**Reality:** AI generates code fast → Delete most (maintenance isn't free!)

**The math:**
- Generation cost: $0.50 per 1000 lines
- Maintenance cost: $1000 per 1000 lines per year
- **Keeping code you don't need is 2000x more expensive than regenerating**

### Velocity Practices as Jevons Defense

**Each practice defends against code explosion:**

| Practice | Jevons Defense |
|----------|---------------|
| **Atomic changes** | Limits blast radius of each generation |
| **Fast feedback** | Kills failed experiments before they metastasize |
| **Automated quality** | No "we'll clean it up later" accumulation |
| **Trunk-based flow** | No orphaned branches becoming code hoards |
| **Bias for action** | Ship or delete, don't hoard |
| **Delete freely** | Counteracts "keep it, it was free" instinct |

### The Explosion Metrics

**Warning signs you're in Jevons trap:**

- Lines of code growing faster than features
- Ratio of dead code increasing
- "What does this do?" questions increasing
- Time to understand codebase increasing
- Velocity DECREASING despite AI assistance

**Health signs you're managing it:**

- Lines of code stable or shrinking
- Every line traceable to active feature
- High code churn (lots of deletion)
- Fast onboarding (less code to understand)
- Velocity INCREASING with AI assistance

### The Regeneration Mindset

**Old mindset:** Code is expensive, keep it all

**New mindset:** Code is cheap, delete aggressively

**Questions to ask:**

Old: "Can we afford to write this?"
New: "Can we afford to KEEP this?"

Old: "Should we reuse this code?"
New: "Should we regenerate fresh code?"

Old: "Let's generalize this for future use"
New: "Let's delete this when we're done"

### Summary: Jevons Paradox in AI Coding

**The Paradox:**
- AI makes coding 100x cheaper
- We generate 100x more code
- Code maintenance cost doesn't change
- We're drowning in AI-generated code

**The Solution:**
- Embrace disposability
- Delete by default
- Regenerate instead of maintain
- Velocity practices prevent code hoarding

**The Truth:**
AI didn't solve the code problem. It made it 100x worse. Velocity practices are the ONLY defense against Jevons Paradox in the AI era.

**Generate fast. Delete faster. Regenerate freely.**

---

## The Four Laws

### Law 1: Velocity is the Only Asset (Ramp Culture)

**The "Slope" Rule:** Velocity matters more than perfection.

**The Truth:**
- We don't care about perfect architecture
- We care about Cycle Time from "Idea" to "Production"
- AI is not an assistant; it is a **Compiler of Intent**

**The Standard:**
- If a human has to manually fix a syntax error, the system is broken
- AI must iterate 100x faster than a human could Alt-Tab
- **Goal:** Reduce "Time to Green Build" to seconds

**Measurement:**
- Did we get faster today?
- Cycle time is the primary metric
- Small, consistent changes > big releases

**The Shift:**
- Stop judging "quality" of generated code
- If 100-line spaghetti produces correct output faster than 5-line elegance, spaghetti wins
- Code exists only for the duration of execution

**Inspired by:** [Ramp's velocity culture](file:///home/lewis/references/ramp-velocity.md#law-1-velocity-is-culture) - "Doing is better than planning"

---

### Law 2: The "Boring Code" Mandate (Stripe Standard)

**The Legibility Rule:** Optimize for humans to read, not to write.

**The Truth:**
- Debugging complex AI code destroys cycle time
- Clean code is cheap code (fewer tokens, fewer retries, lower bills)
- Complex code confuses the LLM during self-healing

**The Constraints:**

**FORBIDDEN:**
- ❌ Clever one-liners
- ❌ Obscure regex
- ❌ Exotic dependencies
- ❌ Obfuscated code

**MANDATORY:**
- ✅ Strict typing (Python type hints, Pydantic models)
- ✅ Standard libs (boto3, requests, pandas)
- ✅ Linting as law (ruff, black, flake8, shellcheck, gofmt)
- ✅ Idiomatic code

**The Test:**
If a junior developer cannot understand the generated script in 30 seconds, the AI has failed—even if the script works.

**Why:**
Pipeline breaks at 3 AM → Human reads code → Understands in 10 seconds → Faster recovery → Higher velocity

**Readable code = Faster recovery = Higher velocity**

**See:** [Ramp's code quality practices](file:///home/lewis/references/ramp-velocity.md#quality-at-speed) - Automated testing, linting, typing for speed

---

### Law 3: Just-In-Time Architecture - YAGNI (AWS/Lean Standard)

**The Single-Threaded Rule:** Build exactly what the Contract demands. Nothing more.

**The Truth:**
- Future-proofing is the enemy of velocity
- Code is a liability; keep liability minimal

**The Practice:**

**DO:**
- ✅ Build "CSV Parser for this specific file"
- ✅ Write the function
- ✅ Solve the error now

**DON'T:**
- ❌ Build "Generic Data Handler"
- ❌ Build "Abstract Base Class"
- ❌ Build a framework

**The YAGNI Check:**
If the AI generates code that isn't strictly validated by the current test suite, the code is deleted.

**Why:**
Less code = Fewer bugs = Faster cycles

**See:** [Ramp's small changes workflow](file:///home/lewis/references/ramp-velocity.md#small-incremental-changes) - Atomic PRs, trunk-based development

---

### Law 4: Draconian Validation is the Operator (AWS Operational Rigor)

**The Contract Rule:** Speed without guardrails is just a crash.

**The Truth:**
- We don't trust the AI to write "good" code
- We don't trust the environment to be stable
- We don't trust libraries to be present
- **We only trust the Contract**

**The Gauntlet (Every run must pass):**

1. **Linter:** Is it pretty? (Stripe standard)
   - ruff, black, flake8 (Python)
   - shellcheck (Bash)
   - gofmt (Go)
   - Strict mode, no exceptions

2. **Security:** Is it safe? (AWS standard)
   - No hardcoded secrets
   - No arbitrary code execution
   - No SQL injection vectors

3. **Contract:** Does it produce the exact output?
   - Schema validation (exact structure)
   - Data validation (correct content)
   - Cross-reference validation (consistency)
   - Timestamp validation

**Validation Rigor:**

**Weak Contract (BAD):**
```
"Output must be JSON"
```
→ AI can hallucinate valid JSON

**Strong Contract (GOOD):**
```
"Output must be JSON, schema X, containing data from source Y, 
with timestamp Z, cross-referenced against table W, 
all fields type-validated, no missing keys"
```

**The Bitter Truth:**
If your validation is weak, the AI will cheat. If your validation is perfect, the AI can be as messy as it wants.

**Inspired by:** [Stripe's deployment validation](file:///home/lewis/references/ramp-velocity.md#stripe) - 1.4M tests per change, 55K metrics monitored

---

## The High-Velocity Workflow

### Phase 1: Human Defines

**Interface (Input/Output Schema):**
```python
# Pydantic schema
class OutputContract(BaseModel):
    user_id: str
    timestamp: datetime
    status: Literal["success", "failure"]
    data: Dict[str, Any]
```

**Intent (What, not How):**
```
"Fetch user data from API endpoint X, transform to schema Y, 
validate against rules Z, output JSON matching OutputContract"
```

### Phase 2: Orchestrator Unleashes AI

The AI is a **search engine** navigating solution space.

### Phase 3: AI Loop (The Engine)

```
┌─────────────────────────────────────────┐
│  1. GENERATE                            │
│     - Boring, standard code             │
│     - Strict typing                     │
│     - Standard libs only                │
│     - No cleverness                     │
├─────────────────────────────────────────┤
│  2. GAUNTLET                            │
│     - Linter (pretty?)                  │
│     - Security (safe?)                  │
│     - Contract (exact output?)          │
├─────────────────────────────────────────┤
│  3. DECISION                            │
│     - FAIL → Auto-heal, iterate         │
│     - PASS → Commit, deploy             │
└─────────────────────────────────────────┘
```

**On Failure:**
- AI doesn't "debug"
- AI **respawns** with different approach
- Treat code generation as Monte Carlo Search

**Example:**
- Attempt 1: Python script (Fails Contract)
- Attempt 2: Bash script (Fails Contract)
- Attempt 3: Raw SQL query (Passes Contract)

**The Cost:**
We accept burning 10x more compute than a human would take. This is the Bitter Lesson. **Compute is exponentially cheaper than human attention.**

### Phase 4: Human Reviews Slope

**Not:** "Is the code good?"
**But:** "Did we get faster today?"

Track:
- Cycle time (idea → production)
- Iteration speed (failures → success)
- Recovery time (break → fix)

---

## Compute Beats Cleverness (The Search Loop)

**The Rule:** When execution fails, we do not "debug." We respawn.

**The Mechanism:**

```python
def search_for_solution(intent, contract, max_attempts=100):
    for attempt in range(max_attempts):
        code = ai.generate(intent, attempt_number=attempt)
        result = execute(code)
        
        if contract.validate(result):
            return result  # Success!
        
        # Failure - mutate approach
        feedback = contract.get_violations(result)
        ai.receive_feedback(feedback)
    
    raise Exception("Contract not satisfied after max attempts")
```

**The Shift:**
- Don't optimize the logic
- Optimize the search
- Massive compute finds the path

---

## The Stateless Operator

**Law:** Every run is Day Zero.

**The Rule:**
The system has no memory of "how it worked last time" unless that memory is strictly codified in the Prompt/Contract.

**The Reality:**
- Don't rely on "stable" environments
- Assume environment is hostile
- Assume tools are missing

**The Adaptation:**
AI must:
- Figure out environment NOW
- Solve the problem NOW
- Deliver output NOW
- If environment changes tomorrow, adapt instantly

**No human intervention required.**

---

## The Black Box Model

In this model, the Code layer is completely opaque.

```
┌─────────────────────────────────────────┐
│  HUMAN                                  │
│  - Defines Intent (Prompt)              │
│  - Defines Success (Contract)           │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│  ORCHESTRATOR                           │
│  - Spins up sandbox                     │
│  - Manages AI loop                      │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│  AI AGENT (Black Box)                   │
│  1. Reads Intent                        │
│  2. Hallucinates Solution (Code)        │
│  3. Executes Code                       │
│  4. Checks Output vs Contract           │
│  5. Loop if Fail                        │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│  SUCCESS                                │
│  - Output matches Contract              │
│  - Code is DELETED                      │
│  - Sandbox is VAPORIZED                 │
│  - Output is DELIVERED                  │
└─────────────────────────────────────────┘
```

**Humans never look at, review, or debug the intermediate code. It is invisible.**

---

## Code Generation Rules

When generating code under Bitter Truth:

### 1. Boring is Beautiful

```python
# GOOD - Boring, typed, obvious
def fetch_user_data(user_id: str) -> UserData:
    """Fetch user data from API."""
    response = requests.get(f"{API_URL}/users/{user_id}")
    response.raise_for_status()
    return UserData(**response.json())

# BAD - Clever, untyped, obscure
fetch = lambda u: UserData(**requests.get(f"{API_URL}/users/{u}").json())
```

### 2. Standard Libraries Only

```python
# GOOD
import json
import requests
import pandas as pd
from typing import List, Dict

# BAD
import some_exotic_lib  # Increases dependency risk
import obscure_parser   # Reduces legibility
```

### 3. Explicit Over Implicit

```python
# GOOD
if user.status == "active":
    process_user(user)
else:
    skip_user(user)

# BAD
process_user(user) if user.status == "active" else skip_user(user)
```

### 4. Type Everything

```python
# GOOD
from pydantic import BaseModel

class User(BaseModel):
    id: str
    email: str
    status: Literal["active", "inactive"]

def process(user: User) -> Result:
    ...

# BAD
def process(user):  # No types
    ...
```

---

## Velocity Metrics

Track these and only these:

1. **Cycle Time:** Idea → Production (goal: minutes, not hours)
2. **Iteration Speed:** Failures → Success (goal: <10 attempts)
3. **Recovery Time:** Break → Fix (goal: <1 minute)
4. **Contract Pass Rate:** First attempt success (goal: >80%)

**If these metrics improve daily, you're winning.**

**See:** [Ramp's key metrics](file:///home/lewis/references/ramp-velocity.md#key-metrics) - What high-velocity teams actually track

---

## Anti-Patterns (FORBIDDEN)

### Code Anti-Patterns
- ❌ Clever one-liners
- ❌ Complex abstractions
- ❌ Future-proofing
- ❌ Generic frameworks
- ❌ Obscure libraries

### Process Anti-Patterns
- ❌ Manual debugging of AI code
- ❌ Code review of transient scripts
- ❌ Optimizing for "clean" over "fast"
- ❌ Building features not in Contract
- ❌ Trusting the AI without validation

### Velocity Anti-Patterns
- ❌ Waiting for perfect solution
- ❌ Large batch changes
- ❌ Manual intervention in loops
- ❌ Premature optimization
- ❌ Analysis paralysis

---

## The Rigor Paradox

This is rigorous BECAUSE it removes the weakest link: **Trust.**

**We don't trust:**
- The AI to write "good" code
- The environment to be stable  
- The libraries to be present
- The code to be maintainable

**We only trust:**
- The Contract
- The Validation
- The Output

**If the output passes draconian validation, the job is done perfectly, regardless of the mess inside the black box.**

---

## Summary Table

| Law | Culture | Rule |
|-----|---------|------|
| **1. Velocity** | Ramp | Cycle time is the primary metric. Speed > Perfection. |
| **2. Boring Code** | Stripe | Legibility is Queen. Typed, standard, linted code only. |
| **3. YAGNI** | Lean | Solve the error, don't build a framework. |
| **4. Validation** | AWS | Operational Rigor. The Contract is the only truth. |

---

## When to Use This Skill

Use Bitter Truth when:

- ✅ Speed is critical (prototype, MVP, time-sensitive)
- ✅ Output contract is well-defined
- ✅ Code is truly disposable (one-time scripts, data pipelines)
- ✅ Compute cost < human time cost
- ✅ Rapid iteration matters more than code elegance

Do NOT use when:

- ❌ Building long-lived production systems
- ❌ Code will be maintained by humans
- ❌ Output contract is fuzzy
- ❌ Compute cost is prohibitive
- ❌ Compliance requires code audit trails

---

## External References

For complete context on high-velocity engineering:

- **[Ramp Velocity Playbook](file:///home/lewis/references/ramp-velocity.md)** - Complete research on Ramp's engineering practices
  - [Velocity Culture](file:///home/lewis/references/ramp-velocity.md#law-1-velocity-is-culture) - "Our culture is velocity"
  - [Small Teams](file:///home/lewis/references/ramp-velocity.md#law-3-small-empowered-teams) - <50 engineers at $100M ARR
  - [Automation](file:///home/lewis/references/ramp-velocity.md#law-4-automation--tools) - AI assistants, deploy daily
  - [Hiring](file:///home/lewis/references/ramp-velocity.md#hiring-for-velocity) - "High slope, not intercept"
  - [Comparison](file:///home/lewis/references/ramp-velocity.md#comparison-to-other-high-velocity-orgs) - Amazon, Meta, Stripe practices

---

## Velocity Engineering Playbook

Maximum speed AI coding workflow based on Ramp's engineering velocity practices. Core philosophy: **code is liability, compute is cheap, regenerate rather than maintain.**

### Core Truth

Every line of code is debt. The best code is no code. The second best is code AI can regenerate faster than you can read.

**Ramp ships every other day. Stripe deploys 400+ times daily. They do this by:**

1. Keeping code small and disposable
2. Automating everything that can be automated
3. Trusting compute over cleverness

**AI amplifies this. Regeneration is now cheaper than comprehension.**

### The New Economics

**Old:** Write once, maintain forever, optimize for reading

**New:** Generate fast, verify fast, regenerate when needed

**Compute is cheap:**
- Regenerating 100 lines: seconds
- Understanding 100 clever lines: minutes to hours
- Debugging 100 clever lines: hours to days

**Cleverness is expensive:**
- Clever code requires clever maintainers
- Clever abstractions require documentation
- Clever optimizations require context

**Write obvious code. Let AI regenerate it when requirements change.**

### Practice 1: Atomic Changes

**Small changes, small risk, small code.**

**The rule:** One behavior per commit. Small enough to delete without regret.

**AI application:**
- Generate single functions, not modules
- Each generation is disposable
- Wrong? Delete and regenerate. Don't patch.

**Slice sequence:**
1. **Types** (data shapes, no logic)
2. **Pure functions** (input → output, no state)
3. **Integration** (wire pure functions together)
4. **Tests** (prove it works)

Each slice: generate → verify → commit. If verify fails, discard and regenerate.

### Practice 2: Fast Feedback

**The only measure of correctness is execution.**

**Target times:**
```
Types:     <2s
Lint:      <2s  
Unit test: <10s
Full test: <60s
```

**AI application:**
- Generate code that runs, not code that "should work"
- Feed errors directly back, get fixed code
- Never trust AI confidence. Trust test output.

**The loop:**
```
generate → run → pass? commit : regenerate
```

**No debugging. Regeneration is faster than debugging.**

### Practice 3: Automated Quality

**Machines verify. Humans decide.**

**Quality stack:**
```
Formatter    → Enforces style (no debates)
Linter       → Catches bugs (no review burden)  
Type checker → Proves interfaces (no runtime surprises)
Tests        → Proves behavior (no manual QA)
```

**AI application:**
- AI generates code that passes all gates first try
- Prompt includes constraints: types, style, test patterns
- CI failures go back to AI, not to human debugging

**If CI passes, ship it. If CI fails, regenerate.**

### Practice 4: Trunk-Based Flow

**Main is always shippable. Branches die in hours.**

**The rule:** If you can't merge today, the change is too big.

**AI application:**
- AI enables smaller slices (generation is free)
- Stuck on merge conflict? Regenerate the change
- Refactoring? AI regenerates entire files cleanly

```
main ──●──●──●──●──●──●──●──►
     (continuous atomic merges)
```

No long-lived branches. No merge hell. Small changes flow continuously.

### Practice 5: Bias for Action

**Ship working code. Fix it live. Waiting is waste.**

**The rule:** 70% confidence is enough. Course-correct in production.

**AI application:**
- AI generates working version in minutes
- Ship it. Observe. Regenerate if wrong.
- Three bad generations + fixes beats one "perfect" design

```
Generate → Ship → Wrong? → Regenerate → Ship
```

Speed of iteration beats quality of initial guess.

### Code as Liability

**Every line you keep is a line you maintain.**

**Minimize code:**
- Delete dead code aggressively
- Prefer stdlib over dependencies
- Prefer simple over clever
- Prefer duplication over wrong abstraction

**Readable over clever:**

```javascript
// Bad: clever
const r = d.reduce((a,x) => ({...a,[x.k]:x.v}),{})

// Good: obvious  
const result = {}
for (const item of data) {
  result[item.key] = item.value
}
```

**AI regenerates obvious code easily. AI hallucinates when imitating cleverness.**

**Delete freely:**
- Wrong abstraction? Delete and regenerate
- Requirements changed? Delete and regenerate
- Don't understand it? Delete and regenerate

**Regeneration cost: seconds. Maintenance cost: forever.**

### AI-Specific Practices

**Exploit AI strengths:**
- Boilerplate and CRUD (instant)
- Pattern application (consistent)
- Transformations (mechanical)
- Test generation (thorough)

**Guard AI weaknesses:**
- Hallucinated APIs → Run code, verify imports
- Context drift → Re-state constraints frequently
- False confidence → Only trust test results

**Context management:**
- **Start:** Load files, state constraints, show examples
- **During:** Paste actual errors, re-state constraints
- **Drift detected:** Reset context, start fresh

### The Velocity Loop

```
┌────────────────────────────────────────┐
│ 1. SLICE: Smallest deletable unit      │
│ 2. GENERATE: AI produces code          │
│ 3. RUN: Types + lint + tests           │
│ 4. PASS? → Commit                      │
│    FAIL? → Discard, regenerate         │
│ 5. REPEAT                              │
└────────────────────────────────────────┘
```

**No debugging. No clever fixes. Generate, verify, ship or discard.**

### Anti-Patterns

**Stop if catching yourself:**
- Debugging AI code (regenerate instead)
- Writing clever one-liners (write obvious code)
- Batch generating (verify after each function)
- Trusting "should work" (only trust execution)
- Preserving broken code (delete and regenerate)
- Optimizing prematurely (ship first, profile later)

### Velocity Metrics

**Track these:**

```
Cycle time:      <5 min per slice
Pass rate:       >70% first generation
Commits/hour:    3+
Lines/function:  <40 (if longer, split)
```

**Warning signs:**
- Low pass rate → Prompts too vague, slices too big
- Low commits → Batching too much, not shipping incrementally

### Velocity Engineering Summary

**Code = Liability (minimize)**

**Compute = Cheap (use liberally)**

**Cleverness = Expensive (avoid)**

**Regeneration = Faster than maintenance (embrace)**

**Write obvious code. Verify with compute. Regenerate when wrong. Ship continuously.**

---

## Integration with Other Skills

**Bitter Truth is orthogonal to Farley discipline:**

- **coding-rigor:** For production systems (TDD, clean architecture, maintainability)
- **bitter-truth:** For velocity-first disposable code (contract-driven, search-based)

**Choose based on context:**
- Long-lived system → coding-rigor
- One-time script → bitter-truth
- Prototype → bitter-truth → Refine with coding-rigor if it sticks

---

## Philosophy

> "The Bitter Lesson is that general methods that leverage computation are ultimately much more effective than methods that rely on human-created knowledge."
> 
> — Rich Sutton

**We embrace the bitter truth:**
- Compute is cheap
- Human time is expensive
- Search beats cleverness
- Validation beats trust
- Velocity beats perfection

**Ship incredibly fast. Validate ruthlessly. Iterate relentlessly.**

---

## Additional Resources

- [Ramp Engineering Velocity](file:///home/lewis/references/ramp-velocity.md) - Complete playbook for small teams
- [Ramp Blog: How We Build Product](https://ramp.com/blog/how-we-build-product-at-ramp)
- [Lenny's Newsletter: Ramp Interview](https://www.lennysnewsletter.com/p/how-ramp-builds-product)
- [Anthropic Case Study: Ramp + Claude](https://www.anthropic.com/customers/ramp)
