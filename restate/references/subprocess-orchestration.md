# Subprocess/CLI Orchestration

## Core Principle

**ALL CLI/subprocess calls MUST be wrapped in `ctx.run`** for journaling.

Without `ctx.run`, a CLI command will re-execute on every retry, causing:
- Duplicate operations
- Inconsistent state
- Wasted resources

## Basic Pattern

```rust
ctx.run(|| async {
    let output = tokio::process::Command::new("git")
        .args(&["clone", &repo])
        .output()
        .await
        .map_err(|e| HandlerError::from(e.to_string()))?;

    if !output.status.success() {
        return Err(HandlerError::from(
            String::from_utf8_lossy(&output.stderr).to_string()
        ));
    }

    Ok::<_, HandlerError>(String::from_utf8_lossy(&output.stdout).to_string())
}).await?
```

## Capturing Output

Always capture stdout/stderr for subsequent logic:

```rust
let output = ctx.run(|| async {
    tokio::process::Command::new("aws")
        .args(&["s3", "ls", &bucket])
        .output()
        .await
        .map_err(|e| HandlerError::from(e.to_string()))
}).await?;

// Check exit code
if !output.status.success() {
    return Err(HandlerError::from(
        String::from_utf8_lossy(&output.stderr).to_string()
    ));
}

// Parse output
let files = String::from_utf8_lossy(&output.stdout)
    .lines()
    .collect::<Vec<_>>();
```

## Timeout Pattern

Always timeout long-running commands:

```rust
use tokio::time::{timeout, Duration};

let result = ctx.run(|| async {
    timeout(
        Duration::from_secs(60),
        tokio::process::Command::new("npm")
            .args(&["install"])
            .current_dir(&project_dir)
            .status()
    ).await
        .map_err(|_| HandlerError::from("npm install timed out"))?
        .map_err(|e| HandlerError::from(e.to_string()))
}).await?;
```

## Atomicity Principle

**Each `ctx.run` should contain ONE CLI command** for finest recovery granularity:

```rust
// GOOD: Each command in separate run
ctx.run(|| git_clone(&repo)).await?;
ctx.run(|| npm_install(&dir)).await?;
ctx.run(|| npm_build(&dir)).await?;

// BAD: Multiple commands in one run
// If npm_build fails, npm_install won't retry
ctx.run(|| async {
    git_clone(&repo).await?;
    npm_install(&dir).await?;
    npm_build(&dir).await?;
    Ok(())
}).await?;
```

## Timeout Recommendations

| Operation | Recommended inactivity_timeout |
|-----------|-------------------------------|
| git clone (small) | 2 min |
| git clone (large) | 5-10 min |
| npm install | 5 min |
| cargo build | 10-15 min |
| docker build | 10-30 min |
| aws cloudformation deploy | 15-30 min |
| terraform apply | 15-30 min |

## Error Classification

```rust
// Transient - will retry
let result = ctx.run(|| async {
    let output = Command::new("aws").args(&["s3", "sync", ...]).output().await?;
    if !output.status.success() {
        // Network/timeout errors should be transient
        return Err(HandlerError::from("S3 sync failed"));
    }
    Ok(())
}).await;

// Terminal - won't retry
let result = ctx.run(|| async {
    let output = Command::new("git").args(&["checkout", &branch]).output().await?;
    if !output.status.success() {
        let stderr = String::from_utf8_lossy(&output.stderr);
        if stderr.contains("did not match any file") {
            // Branch doesn't exist - won't fix with retry
            return Err(TerminalError::new(&format!("Branch {} not found", branch)).into());
        }
        return Err(HandlerError::from(stderr.to_string()));
    }
    Ok(())
}).await;
```

## Working Directory

```rust
ctx.run(|| async {
    Command::new("cargo")
        .args(&["build", "--release"])
        .current_dir(&project_dir)  // Set working directory
        .output()
        .await
}).await?
```

## Environment Variables

```rust
ctx.run(|| async {
    Command::new("aws")
        .args(&["cloudformation", "deploy", ...])
        .env("AWS_REGION", "us-west-2")
        .env("AWS_PROFILE", "production")
        .output()
        .await
}).await?
```

## Detached Processes

For terminal multiplexers (zellij, tmux, screen):

```rust
ctx.run(|| async {
    let mut cmd = Command::new("zellij");
    cmd.args(&["attach", &session_name])
        .env("ZELLIJ_SOCKET_DIR", &socket_dir);

    // Don't wait for detached process
    cmd.spawn()?;
    Ok::<_, HandlerError>(())
}).await?
```

Note: Detached processes can exceed inactivity timeout if not handled carefully.

## File System State

Service restarts lose local file system state. For persistent working directories:

1. **Use persistent volumes** (not /tmp)
2. **Sync state to cloud storage** between major steps
3. **Check for existing state** before re-creating

```rust
let repo_dir = format!("/var/lib/myapp/repos/{}", ctx.invocation_id());

// Check if already cloned (from previous attempt)
if !std::path::Path::new(&repo_dir).exists() {
    ctx.run(|| git_clone(&repo_url, &repo_dir)).await?;
}
```
