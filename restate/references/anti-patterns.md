# Anti-Patterns

## Critical Anti-Patterns

### 1. Non-Awaited `ctx.run`

**Problem**: Journal interleaving causes non-determinism
```rust
// BAD
let fut1 = ctx.run(|| async { op1() });
let fut2 = ctx.run(|| async { op2() });
let (r1, r2) = futures::join!(fut1, fut2);  // Non-deterministic order!
```

**Fix**: Always await immediately
```rust
// GOOD
let r1 = ctx.run(|| async { op1() }).await?;
let r2 = ctx.run(|| async { op2() }).await?;
```

---

### 2. Context in `ctx.run` Closure

**Problem**: Cannot access Restate context inside run closure
```rust
// BAD - won't compile
ctx.run(|| async {
    let key = ctx.key();  // ctx not accessible
}).await
```

**Fix**: Capture data before closure
```rust
// GOOD
let key = ctx.key().to_string();
ctx.run(move || async {
    use_key(&key)
}).await
```

---

### 3. Object Deadlock

**Problem**: Circular calls with same key
```rust
// A calls B with key X, B calls A with key X
// Both wait forever for exclusive access
```

**Fix**: Avoid circular calls on same key
- Design call graph to be acyclic
- Use different keys for different services
- Use shared handlers where possible

---

### 4. Long Sleep in Exclusive Handler

**Problem**: Blocks all other handlers for that key
```rust
// BAD
async fn wait_for_event(&self, ctx: ObjectContext<'_>) {
    ctx.sleep(Duration::from_secs(3600)).await?;  // Blocks everything!
}
```

**Fix**: Use Workflow for long waits
```rust
// GOOD - use Workflow instead
async fn run(&self, ctx: WorkflowContext<'_>) {
    ctx.sleep(Duration::from_secs(3600)).await?;  // OK in workflow
}
```

---

### 5. Mutable State Pattern

**Problem**: Mutating state breaks replay consistency
```rust
// BAD
let mut state = ctx.get("data").await?.unwrap_or_default();
state.push(item);  // Mutation lost on replay
```

**Fix**: Return new state, set explicitly
```rust
// GOOD
let state = ctx.get("data").await?.unwrap_or_default();
let new_state = update_state(state, item);
ctx.set("data", new_state);
```

---

### 6. Non-Deterministic in Handler

**Problem**: Random/IO varies across replays
```rust
// BAD
let id = uuid::Uuid::new_v4();  // Different each replay
let time = std::time::SystemTime::now();  // Different each replay
```

**Fix**: Wrap in `ctx.run`
```rust
// GOOD
let id = ctx.run(|| async { uuid::Uuid::new_v4() }).await?;
// Or use Restate's stable UUID
let id = ctx.rand_uuid();
```

---

## CLI/Subprocess Anti-Patterns

### 7. Unwrapped CLI Command

**Problem**: Re-executes on every retry
```rust
// BAD
let output = Command::new("git").args(&["clone", &repo]).output().await?;
```

**Fix**: Wrap in `ctx.run`
```rust
// GOOD
ctx.run(|| async {
    Command::new("git").args(&["clone", &repo]).output().await
}).await?
```

---

### 8. No CLI Timeout

**Problem**: Hanging command blocks invocation indefinitely
```rust
// BAD
ctx.run(|| async {
    Command::new("npm").args(&["install"]).output().await
}).await
```

**Fix**: Add internal timeout
```rust
// GOOD
ctx.run(|| async {
    tokio::time::timeout(
        Duration::from_secs(60),
        Command::new("npm").args(&["install"]).output()
    ).await
}).await
```

---

### 9. Double Execute Pattern

**Problem**: git clone succeeds, next step fails, clone runs again
```rust
// BAD - multiple commands in one run
ctx.run(|| async {
    git_clone(&repo).await?;
    make_changes().await?;  // Fails here
    git_push().await?;
    Ok(())
}).await  // Retry re-runs clone!
```

**Fix**: Separate `ctx.run` per command
```rust
// GOOD
ctx.run(|| git_clone(&repo)).await?;
ctx.run(|| make_changes()).await?;  // Only this retries
ctx.run(|| git_push()).await?;
```

---

### 10. Orphan Cloud Resources

**Problem**: Resource created, workflow killed, orphan remains
```rust
// BAD
let bucket = ctx.run(|| create_s3_bucket()).await?;
// ... workflow killed here ...
// Bucket orphaned!
```

**Fix**: Implement saga with compensations
```rust
// GOOD
let result = async {
    let bucket = ctx.run(|| create_s3_bucket()).await?;
    // ... more work ...
    Ok(bucket)
}.await;

if let Err(e) = result {
    if e.is_terminal() {
        ctx.run(|| delete_s3_bucket(&bucket)).await?;
    }
    return Err(e);
}
```

---

## Quick Reference

| Anti-Pattern | Symptom | Fix |
|--------------|---------|-----|
| Non-awaited run | Non-determinism | Await immediately |
| ctx in run | Won't compile | Capture before |
| Object deadlock | Timeout | Avoid circular calls |
| Long sleep in object | Blocked handlers | Use Workflow |
| Mutable state | Lost updates | Set explicitly |
| Non-deterministic | Replay fails | Use ctx.run |
| Unwrapped CLI | Double execute | Wrap in ctx.run |
| No CLI timeout | Hangs | Add timeout |
| Double execute | Wasted work | One cmd per run |
| Orphan resources | Leaked infra | Use saga pattern |
