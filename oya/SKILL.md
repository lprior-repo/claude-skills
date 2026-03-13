---
name: oya
description: Oya is a durable workflow orchestrator built on Restate that automates bead-based task execution. Use when implementing beads end-to-end: picks ready beads, creates isolated workspaces, runs opencode, executes QA, runs CI, rebases onto main, opens PRs, and cleans up. Triggers on ANY request mentioning "oya".
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - AskUserQuestion
user-invocable: true
argument-hint: [lifecycle, init, status, cancel, or bead-id]
version: 1.0.0
---

# Oya: Durable Workflow Orchestrator

> *"Automates bead-based task execution with durable workflows that survive process restarts."*

```jsonl
{"kind":"meta","skill":"oya","version":"1.0.0","format":"markdown-with-embedded-jsonl","philosophy":"Pick → Isolate → Implement → Verify → CI → Rebase → PR → Cleanup"}
{"kind":"principle","id":"end_to_end","text":"Full lifecycle automation from bead to PR with zero manual intervention.","bans":["manual jj commands","manual gh commands","hand-crafted rebase"],"enforcement":"Every implementation goes through oya lifecycle."}
{"kind":"principle","id":"isolated_workspaces","text":"Each bead gets its own jj workspace for complete isolation.","bans":["shared workspaces","mutation of shared state"],"enforcement":"jj workspace add for each lifecycle."}
{"kind":"principle","id":"durable_execution","text":"Workflows survive process restarts via Restate durability.","bans":["in-memory state","process-dependent execution"],"enforcement":"All state in Restate ObjectContext/WorkflowContext."}
{"kind":"principle","id":"adversarial_qa","text":"QA verification runs BEFORE CI to catch issues early.","bans":["skip qa","qa after ci"],"enforcement":"qa-enforcer runs as second step."}
```

## Quick Reference

```bash
# Start the runtime (REQUIRED before any oya commands)
oya init

# Run a bead through the full lifecycle
oya lifecycle --bead <id> --repo <owner/repo>

# Check lifecycle status
curl http://localhost:909/OyaService/get_lifecycle -d '{"key": "Oya/<id>/run"}'

# Cancel a running lifecycle
curl http://localhost:909/OyaService/cancel -d '{"key": "Oya/<id>/run"}'
```

## 1. Fresh Repo Setup

```bash
# Install/build oya
cargo build --release

# Start the Restate runtime (REQUIRED before any oya commands)
oya init

# Verify runtime is running
curl http://localhost:909/restate/health
# Should return: {"status":"OK"}

# Register handlers with Restate
oya init
# This registers OyaMemory and OyaService handlers
```

## 2. The Full Lifecycle Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                        OYA LIFECYCLE                                    │
├─────────────────────────────────────────────────────────────────────────┤
│  1. bd ready --json        ← Pick next ready bead from tracker        │
│  2. jj workspace add        ← Create isolated workspace                │
│  3. opencode run            ← AI implements the bead                   │
│  4. qa-enforcer verify      ← Adversarial QA check                     │
│  5. moon run :ci           ← Run CI checks                            │
│  6. jj rebase -d main@origin← Rebase onto latest                     │
│  7. jj git push            ← Push bookmark                            │
│  8. gh pr create           ← Open PR                                   │
│  9. jj workspace forget    ← Cleanup workspace                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## 3. Running a Lifecycle

```bash
# Basic run - picks any ready bead
oya lifecycle --repo lprior-repo/oya

# Run specific bead
oya lifecycle --bead intent-cli-abc123 --repo lprior-repo/oya

# With custom model
oya lifecycle --bead intent-cli-abc123 --repo lprior-repo/oya --model zai-coding-plan/glm-5
```

## 4. Checking Status

### Via REST API (JSON)
```bash
curl -s http://localhost:909/OyaService/get_lifecycle \
  -H 'Content-Type: application/json' \
  -d '{"key": "Oya/intent-cli-abc123/run"}'
```

### Response Structure
```json
{
  "bead_id": "intent-cli-abc123",
  "steps": [
    {"step": "workspace", "status": "succeeded", "message": "..."},
    {"step": "opencode", "status": "running", "message": "..."},
    {"step": "qa", "status": "pending", "message": null}
  ],
  "done": true,
  "success": true,
  "pr_url": "https://github.com/owner/repo/pull/123",
  "message": "bead completed successfully"
}
```

### Polling for Completion
```bash
while true; do
  STATUS=$(curl -s http://localhost:909/OyaService/get_lifecycle \
    -H 'Content-Type: application/json' \
    -d '{"key": "Oya/intent-cli-abc123/run"}' | jq -r '.done')
  if [ "$STATUS" = "true" ]; then
    curl -s http://localhost:909/OyaService/get_lifecycle \
      -H 'Content-Type: application/json' \
      -d '{"key": "Oya/intent-cli-abc123/run"}' | jq '.success, .pr_url'
    break
  fi
  echo "Still running..."
  sleep 5
done
```

## 5. Multiple Concurrent Runs

```bash
# Run multiple beads concurrently - each gets own workspace
oya lifecycle --bead intent-cli-001 --repo lprior-repo/oya &
oya lifecycle --bead intent-cli-002 --repo lprior-repo/oya &
oya lifecycle --bead intent-cli-003 --repo lprior-repo/oya &

# Each runs in isolated workspace: oya-intent-cli-001, oya-intent-cli-002, etc.

# Check all concurrently
curl -s http://localhost:909/OyaService/get_lifecycle \
  -H 'Content-Type: application/json' \
  -d '{"key": "Oya/intent-cli-001/run"}' &
curl -s http://localhost:909/OyaService/get_lifecycle \
  -H 'Content-Type: application/json' \
  -d '{"key": "Oya/intent-cli-002/run"}' &
curl -s http://localhost:909/OyaService/get_lifecycle \
  -H 'Content-Type: application/json' \
  -d '{"key": "Oya/intent-cli-003/run"}' &
```

## 6. Cancellation

```bash
# Cancel a running lifecycle
curl -s http://localhost:909/OyaService/cancel \
  -H 'Content-Type: application/json' \
  -d '{"key": "Oya/intent-cli-abc123/run"}'

# Response:
{"cancelled": true, "message": "memory cancelled; workflow cancelled; workspace cleanup attempted"}
```

## 7. Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         OYA ARCHITECTURE                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  ┌──────────┐    ┌──────────────┐    ┌──────────────────────┐ │
│  │  bd CLI  │───▶│  Oya Service │───▶│  Lifecycle Workflow  │ │
│  │ (beads)  │    │  (Restate)   │    │  (Rust State Machine)│ │
│  └──────────┘    └──────────────┘    └──────────────────────┘ │
│       │                  │                      │              │
│       │                  │                      ▼              │
│       │                  │           ┌──────────────────────┐ │
│       │                  │           │  TokioCommandExecutor│ │
│       │                  │           │  - jj workspace      │ │
│       │                  │           │  - opencode run      │ │
│       │                  │           │  - moon run :ci     │ │
│       │                  │           │  - gh pr create     │ │
│       │                  │           └──────────────────────┘ │
│       │                  │                                    │
│       ▼                  ▼                                    │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │              RESTATE RUNTIME                             │ │
│  │  - Durable execution (surives process restart)          │ │
│  │  - Shared state via ObjectContext/WorkflowContext        │ │
│  │  - Automatic retry on transient failures                 │ │
│  └─────────────────────────────────────────────────────────┘ │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Key Files

| Path | Purpose |
|------|---------|
| `src/lifecycle/workflow/execution.rs` | Main lifecycle runner |
| `src/lifecycle/workflow/execution/steps.rs` | Step definitions |
| `src/restate_oya/handlers.rs` | REST endpoints for status/cancel |
| `src/cli/restate.rs` | CLI helpers for bd ready parsing |

## 8. API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `http://localhost:909/OyaService/get_lifecycle` | POST | Get workflow status |
| `http://localhost:909/OyaService/cancel` | POST | Cancel running workflow |
| `http://localhost:909/OyaMemory/<id>/start` | POST | Run opencode prompt |
| `http://localhost:909/OyaMemory/<id>/run_pipeline` | POST | Run bead pipeline |
| `http://localhost:9180/discover` | GET | List available services |
| `http://localhost:9070` | GET | Admin UI |

### Runtime Ports

- **Ingress:** http://localhost:909
- **Discovery:** http://localhost:9180/discover
- **UI:** http://localhost:9070

## 9. For AI Agents - Prompt Template

Include this in your prompts:

```
## OYA WORKFLOW - MANDATORY

You MUST use oya for all implementation work:

1. START: Run `oya lifecycle --bead <bead-id> --repo <owner/repo>`

2. MONITOR: Poll status via:
   curl http://localhost:909/OyaService/get_lifecycle \
     -H 'Content-Type: application/json' \
     -d '{"key": "Oya/<bead-id>/run"}'

3. WAIT: For "done": true in response

4. ON SUCCESS: PR URL is in "pr_url" field

5. ON FAILURE: Check "message" field for error, "compensation_diagnostics" for rollback info

NEVER run jj/gh commands manually - let oya handle:
- Workspace creation/deletion
- Rebasing onto main
- Pushing and PR creation

If oya is not running, start with: oya init
```

## 10. Key Configuration

```bash
# Timeouts (in src/lifecycle/effects.rs)
MOON_CI_TIMEOUT_SECS = 900     # 15 min
OPENCODE_TIMEOUT_SECS = 1200  # 20 min
DEFAULT_CLI_TIMEOUT_SECS = 120 # 2 min
JJ_WORKSPACE_TIMEOUT_SECS = 20

# Output limits
MAX_OUTPUT_BYTES = 1_048_576  # 1MB per stdout/stderr
CLI_ERROR_LIMIT = 512         # Max error message chars
```

## 11. Debugging

```bash
# View runtime logs
~/.local/share/observability/observability.sh logs restate

# Check workspace state
jj workspace list
jj log --graph -r '::@'

# Manual bead status
bd show <bead-id>
bd update <bead-id> --status in_progress

# Force cleanup stuck workspace
jj workspace forget oya-<bead-id>
```

## Step Status Values

| Status | Meaning |
|--------|---------|
| `pending` | Not yet started |
| `running` | Currently executing |
| `succeeded` | Step completed successfully |
| `failed` | Step failed (lifecycle may continue for compensation) |
| `skipped` | Step was skipped |

## Exit Codes

| Code | Meaning |
|------|---------|
| 0 | Lifecycle completed successfully |
| 1 | Lifecycle failed |
| 2 | Invalid arguments |
| 3 | Oya runtime not initialized |

---

**Version:** 1.0.0  
**Last Updated:** February 2026  
**Status:** Production Ready  
**Philosophy:** Pick → Isolate → Implement → Verify → CI → Rebase → PR → Cleanup
