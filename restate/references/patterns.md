# Design Patterns

## Saga Pattern (Compensating Transactions)

Use for multi-step workflows that need rollback on failure.

### Structure
1. Track completed steps with their compensating actions
2. Execute steps sequentially
3. On TerminalError, run compensations in reverse order

### When to Use
- Booking workflows (flight + hotel + car)
- Payment processing (reserve → charge → confirm)
- Cloud resource provisioning
- Any multi-step that modifies external state

### Key Points
- Register compensation BEFORE executing step
- Compensations should be idempotent
- Use `ctx.run` for each compensation
- Only compensate on TerminalError (transient errors retry automatically)

```rust
// Pattern: register compensation before step
match ctx.run(|| reserve_flight(&req)).await {
    Ok(booking_id) => {
        // Register compensation only after success
        compensations.push(Box::new(move || cancel_flight(&booking_id)));
    }
    Err(e) => {
        // Step failed - no compensation needed
        return Err(e);
    }
}
```

---

## Fan-out/Fan-in (Parallel Work)

Execute multiple subtasks in parallel, aggregate results.

### Pattern
1. Fan out: Schedule parallel calls via `send()` or futures
2. Fan in: Await all results with `futures::join!` or similar

### When to Use
- Batch processing
- Parallel API calls
- Distributed computations

```rust
// Fan out - schedule parallel calls
let fut1 = ctx.service_client::<Worker>().task(subtask1).send();
let fut2 = ctx.service_client::<Worker>().task(subtask2).send();
let fut3 = ctx.service_client::<Worker>().task(subtask3).send();

// Fan in - await all (Restate makes futures durable)
let (r1, r2, r3) = futures::join!(fut1, fut2, r3);
```

### Important
- Restate makes futures durable - they survive crashes
- Each parallel call gets its own invocation ID
- One-way calls (`send()`) are scheduled immediately

---

## Rate Limiting

Control request rates per key using Virtual Objects.

### Pattern
1. Virtual Object with token bucket state
2. `acquire()` handler with durable sleep
3. `try_acquire()` for non-blocking check

### When to Use
- API rate limiting
- Resource throttling
- Preventing abuse

### Key Points
- Each limiter key is isolated (Virtual Object)
- State persists across invocations
- Durable sleep survives crashes

See templates.md for RateLimiter implementation.

---

## Human-in-the-Loop

Wait for external approval or event.

### Option 1: Workflow with Promises

```rust
// In run handler
ctx.set("status", "pending_approval");
ctx.promise::<Approval>("approval").await?;  // Blocks
ctx.set("status", "approved");

// In signal handler (called by external system)
async fn approve(&self, ctx: WorkflowContext<'_>, approval: Approval) -> Result<(), HandlerError> {
    ctx.resolve_promise("approval", approval);
    Ok(())
}
```

### Option 2: Awakeables

```rust
// Create awakeable
let (id, promise) = ctx.awakeable::<Approval>();

// Send id to external system (webhook, email, etc.)
send_approval_request(&id);

// Wait for external resolution
let approval = promise.await?;
```

### When to Use
- Approval workflows
- Manual review steps
- External webhook integration

---

## Delayed Actions

Schedule work for future execution.

### Option 1: send_after (Recommended)

```rust
// Schedule message for later (fire-and-forget)
ctx.service_client::<Reminder>()
    .send_reminder(notification)
    .send_after(Duration::from_secs(3600))  // 1 hour
```

### Option 2: Sleep then act

```rust
// Sleep is durable - survives crashes
ctx.sleep(Duration::from_secs(3600)).await?;
// Then do the work
do_scheduled_work().await?;
```

### Comparison
| Method | Pros | Cons |
|--------|------|------|
| `send_after` | No handler blocked, scales | Can't cancel easily |
| `sleep` | Can check conditions | Handler blocked |

---

## Request-Response with Timeout

```rust
use tokio::time::{timeout, Duration};

let result = timeout(
    Duration::from_secs(30),
    ctx.service_client::<ExternalApi>().call(data)
).await;

match result {
    Ok(Ok(response)) => Ok(response),
    Ok(Err(e)) => Err(HandlerError::from(e.to_string())),
    Err(_) => Err(HandlerError::from("Request timed out")),
}
```

---

## Idempotent External Calls

When calling external APIs, use idempotency keys:

```rust
let idempotency_key = ctx.rand_uuid().to_string();

ctx.run(|| async {
    external_api.charge(
        payment_info,
        idempotency_key,  // Prevents double-charge on retry
    ).await
}).await?
```

The `ctx.rand_uuid()` produces the same UUID across retries.
