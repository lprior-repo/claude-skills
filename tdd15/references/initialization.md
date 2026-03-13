# Initialization

## Steps

1. **Initialize session** (creates blackboard + zjj workspace):
   ```bash
   tdd15 init <session-id> --language <gleam|rust>
   ```

2. **Start Phase 0** (triage determines complexity and route):
   ```bash
   tdd15 phase-start <session-id> 0
   ```

3. **Execute Phase 0**: Assess complexity (inline, no subagent)

4. **Pass Phase 0 gate** with complexity and route:
   ```bash
   tdd15 gate-check <session-id> 0 '{"passed": true, "complexity": "simple", "route": [0,4,5,6,14,15]}'
   ```

5. **Advance to first real phase**:
   ```bash
   tdd15 advance <session-id>
   ```

## What `tdd15 init` Does

- Creates `~/.local/share/tdd15/<session>/blackboard.yml`
- Initializes all 16 phases as pending
- Sets default route to complex (Phase 0 refines this)
- Creates zjj workspace `tdd15-<session-id>` (non-fatal if zjj unavailable)

## Pre-set Complexity

To skip Phase 0 triage:
```bash
tdd15 init <session-id> --language gleam --complexity simple
```

This sets the route immediately. Phase 0 gate still needs to pass but can be a quick confirmation.

## Verifying Initialization

```bash
tdd15 status <session-id>   # Shows session state
tdd15 show <session-id>     # Raw YAML
```
