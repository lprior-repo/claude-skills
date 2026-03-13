# Red Queen Execution Protocol

## Phase 0: Probe

```bash
# Initialize state machine
L="$HOME/.claude/skills/red-queen/liza-advanced.nu"
nu $L init
nu $L task-add drq-session --spec_ref README.md

# AI discovers promises, registers each:
nu $L task-add-check drq-session "factory help" --expect_exit=0
nu $L task-add-check drq-session "factory version" --expect_exit=0

# Claim
nu $L claim drq-session red-queen
```

## Generation N: Evolve → Execute → Select

```bash
# Start generation
nu $L gen-start drq-session

# Execute challengers
factory bogus 2>/dev/null
if [ $? -eq 0 ]; then
  # BUG: should have failed
  nu $L gen-survivor drq-session "error-handling" "factory bogus 2>/dev/null; test \$? -ne 0" --severity CRITICAL
  bd create --title "[Red Queen] CRITICAL: bogus command exits 0" --type=bug --priority=0
else
  nu $L gen-discard drq-session "error-handling"
fi

# Show landscape
nu $L landscape drq-session

# Validate full lineage
nu $L coder-submit drq-session red-queen
nu $L validate drq-session
```

## Landscape Allocation

| Fitness | Challengers | Status |
|---------|-------------|--------|
| > 0.7 | 6+ | HEMORRHAGING |
| > 0.5 | 5 | HIGH PRESSURE |
| > 0.3 | 4 | CONTESTED |
| > 0.1 | 3 | PROBING |
| 0 | 2 | COOLING (double-tap) |
| exhausted 3+ gens | 0 | DORMANT (reawaken every 5) |

## Equilibrium

Requires 3 consecutive zero-survivor generations.

## Session Completion

```bash
# 1. Verify lineage
nu $L validate drq-session

# 2. Show final state
nu $L show --task=drq-session

# 3. Commit
jj describe -m "test(red-queen): gen N - <verdict>" && jj new
```
