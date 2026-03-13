# Configuration Options

## Service/Handler Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `inactivity_timeout` | Duration | 1 min | Grace period before termination |
| `abort_timeout` | Duration | 10 min | Max wait for graceful shutdown |
| `retry_policy_max_attempts` | u64 | unlimited | Max retries before pause/kill |
| `idempotency_retention` | Duration | 24h | How long to keep idempotency keys |
| `journal_retention` | Duration | 24h | How long to keep execution journal |
| `workflow_retention` | Duration | 24h | Workflow state after run completes |
| `ingress_private` | bool | false | Prevent external HTTP/Kafka |
| `enable_lazy_state` | bool | false | Load state on demand |

## Rust SDK Configuration

```rust
use restate_sdk::prelude::*;
use std::time::Duration;

let options = ServiceOptions::new()
    .inactivity_timeout(Duration::from_secs(300))
    .abort_timeout(Duration::from_secs(600))
    .retry_policy_max_attempts(10);

let endpoint = Endpoint::builder()
    .bind_with_options(MyService.serve(), options)
    .build();
```

## Handler-Level Override

```rust
// Handler-specific options
let handler_opts = HandlerOptions::new()
    .inactivity_timeout(Duration::from_secs(600));

Endpoint::builder()
    .bind_with_options(MyService.serve(), ServiceOptions::new())
    .configure_handler("longRunningHandler", handler_opts)
    .build()
```

## Server Configuration

### Environment Variables
```bash
RESTATE_WORKER__INVOKER__INACTIVITY_TIMEOUT=5m
RESTATE_WORKER__INVOKER__ABORT_TIMEOUT=5m
RESTATE_DEFAULT_RETRY_POLICY__MAX_ATTEMPTS=100
RESTATE_DEFAULT_RETRY_POLICY__MAX_INTERVAL="10s"
```

### Config File (restate.toml)
```toml
[worker.invoker]
inactivity-timeout = "1m"
abort-timeout = "1m"

[invocation.default-retry-policy]
initial-interval = "50ms"
exponentiation-factor = 2.0
max-attempts = 70
max-interval = "60s"
on-max-attempts = "pause"  # or "kill"
```

## Timeout Tuning for CLI Operations

| Scenario | inactivity_timeout | Why |
|----------|-------------------|-----|
| git clone (small) | 2 min | Small repos fast |
| git clone (large) | 5-10 min | Large repos slow |
| npm install | 5 min | Network + resolution |
| cargo build | 10-15 min | Compile times vary |
| docker build | 10-30 min | Image layers |
| aws cloudformation deploy | 15-30 min | Stack ops slow |
| terraform apply | 15-30 min | Resource provisioning |

## Retry Policy

### Default Behavior
- **Infinite retries** with exponential backoff
- Initial interval: 50ms
- Factor: 2.0
- Max interval: 60s

### On Max Attempts
- `pause`: Invocation paused, can be resumed manually
- `kill`: Invocation failed immediately

### Run Block Retry
```rust
ctx.run(|| async { ... })
    .retry_policy(RunRetryPolicy::default()
        .max_attempts(3)
        .max_duration(Duration::from_secs(60)))
    .await
```

## Retention

### Idempotency Retention
- How long to deduplicate requests with same idempotency key
- Increase for financial/critical operations

### Journal Retention
- How long to keep execution history for debugging
- Capped by idempotency/workflow retention

### Workflow Retention
- How long workflow handlers callable after run completes
- Affects: state access, promise resolution, shared handlers

## State Access Mode

### Eager (Default)
- Full state snapshot sent on invocation
- Good for small state or AWS Lambda

### Lazy
- Load entries on demand via `ctx.get`
- Good for large state with sparse access
- Requires more suspend/replay cycles
