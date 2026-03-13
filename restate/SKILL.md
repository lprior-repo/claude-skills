---
name: restate
description: Use when implementing Restate services, Virtual Objects, Workflows, durable execution patterns, or when encountering Restate-specific errors. Covers Rust SDK v0.8.0 service definitions, state management, error handling, service communication, and deployment. Triggers on restate_sdk, ObjectContext, WorkflowContext, TerminalError, HandlerError, durable execution, or orchestration patterns.
---

```jsonl
{"kind":"meta","version":"2.0.0","sdk":"0.8.0","updated":"2026-02"}
{"kind":"type","name":"Service","macro":"#[restate_sdk::service]","ctx":"Context<'_>","use":"Stateless request-response"}
{"kind":"type","name":"VirtualObject","macro":"#[restate_sdk::object]","ctx":"ObjectContext<'_>","use":"Stateful keyed, exclusive"}
{"kind":"type","name":"Workflow","macro":"#[restate_sdk::workflow]","ctx":"WorkflowContext<'_>","use":"Long-running with promises"}
{"kind":"ctx","type":"Context<'_>","state":false,"promises":false,"key":false,"sleep":true,"run":true,"calls":true}
{"kind":"ctx","type":"ObjectContext<'_>","state":"rw","promises":false,"key":true,"sleep":true,"run":true,"calls":true,"exclusive":true}
{"kind":"ctx","type":"SharedObjectContext<'_>","state":"r","promises":false,"key":true,"sleep":true,"run":true,"calls":true}
{"kind":"ctx","type":"WorkflowContext<'_>","state":"rw","promises":true,"key":true,"sleep":true,"run":true,"calls":true,"exclusive":true}
{"kind":"ctx","type":"SharedWorkflowContext<'_>","state":"r","promises":true,"key":true,"sleep":true,"run":true,"calls":true}
{"kind":"handler","pattern":"async fn name(&self, ctx: Ctx, arg: T) -> Result<R, HandlerError>","use":"Default exclusive"}
{"kind":"handler","pattern":"#[shared] async fn name(&self, ctx: Shared*Context, arg: T)","use":"Concurrent read-only"}
{"kind":"error","type":"TerminalError","pattern":"TerminalError::new(\"msg\").into()","retry":false,"use":"Business logic, validation, not found"}
{"kind":"error","type":"TerminalError+code","pattern":"TerminalError::new_with_code(404, \"msg\").into()","retry":false,"use":"HTTP-style errors"}
{"kind":"error","type":"HandlerError","pattern":"HandlerError::from(\"msg\")","retry":true,"use":"Network, timeout, transient"}
{"kind":"state","op":"get","pattern":"ctx.get::<T>(\"key\").await?","returns":"Option<T>"}
{"kind":"state","op":"set","pattern":"ctx.set(\"key\", value)","note":"Overwrites"}
{"kind":"state","op":"clear","pattern":"ctx.clear(\"key\")"}
{"kind":"state","op":"get_keys","pattern":"ctx.get_keys().await?","returns":"Vec<String>"}
{"kind":"effect","op":"sleep","pattern":"ctx.sleep(Duration::from_secs(10)).await?","note":"Survives crashes"}
{"kind":"effect","op":"run","pattern":"ctx.run(|| async { non_deterministic() }).await?","note":"Journals result"}
{"kind":"effect","op":"uuid","pattern":"ctx.rand_uuid()","note":"Stable across retries"}
{"kind":"call","type":"service","pattern":"ctx.service_client::<S>().handler(arg).call().await?"}
{"kind":"call","type":"object","pattern":"ctx.object_client::<O>(\"key\").handler(arg).call().await?"}
{"kind":"call","type":"workflow","pattern":"ctx.workflow_client::<W>(\"id\").run(arg).call().await?"}
{"kind":"call","type":"send","pattern":"client.handler(arg).send()","note":"Fire-and-forget"}
{"kind":"call","type":"delayed","pattern":"client.handler(arg).send_after(Duration::from_secs(60))"}
{"kind":"call","type":"idempotent","pattern":"client.handler(arg).with_idempotency_key(\"key\").call()","note":"Deduplicates"}
{"kind":"awakeable","op":"create","pattern":"let (id, promise) = ctx.awakeable::<T>()","note":"id sent externally"}
{"kind":"awakeable","op":"resolve","pattern":"ctx.resolve_awakeable(&id, payload)"}
{"kind":"promise","op":"wait","pattern":"ctx.promise::<T>(\"name\").await?","note":"Workflow only, blocks"}
{"kind":"promise","op":"peek","pattern":"ctx.peek_promise::<T>(\"name\").await?","returns":"Option<T>"}
{"kind":"promise","op":"resolve","pattern":"ctx.resolve_promise(\"name\", value)"}
{"kind":"inspect","op":"key","pattern":"ctx.key()","returns":"&str"}
{"kind":"inspect","op":"invocation_id","pattern":"ctx.invocation_id()","returns":"&str"}
{"kind":"best","id":"wrap_run","text":"ALL non-deterministic ops (IO, CLI, random) in ctx.run"}
{"kind":"best","id":"terminal_business","text":"TerminalError for business logic - won't fix with retries"}
{"kind":"best","id":"handler_transient","text":"HandlerError for transient - Restate auto-retries"}
{"kind":"best","id":"shared_reads","text":"#[shared] for read-only - allows concurrency"}
{"kind":"best","id":"timeout_cli","text":"inactivity_timeout >= longest CLI command"}
{"kind":"best","id":"atomic_run","text":"One CLI command per ctx.run for recovery granularity"}
{"kind":"best","id":"saga_compensate","text":"Track compensations for rollback on TerminalError"}
{"kind":"anti","id":"non_awaited_run","issue":"Journal interleaving","fix":"Await ctx.run immediately"}
{"kind":"anti","id":"ctx_in_run","issue":"Cannot access ctx in closure","fix":"Capture before closure"}
{"kind":"anti","id":"unwrapped_cli","issue":"Re-executes on retry","fix":"Wrap in ctx.run"}
{"kind":"anti","id":"no_cli_timeout","issue":"Hangs indefinitely","fix":"Add internal timeout"}
{"kind":"anti","id":"double_execute","issue":"Prev cmd runs again","fix":"Separate ctx.run per command"}
{"kind":"anti","id":"object_deadlock","issue":"A->B->A same key","fix":"Avoid circular calls same key"}
{"kind":"anti","id":"long_sleep_object","issue":"Blocks all handlers","fix":"Use Workflow for long waits"}
{"kind":"cli","cmd":"restate services list","desc":"List services"}
{"kind":"cli","cmd":"restate invocations list --status backing-off","desc":"See retries"}
{"kind":"cli","cmd":"restate invocations describe <id>","desc":"Details + journal"}
{"kind":"cli","cmd":"restate invocations cancel <id>","desc":"Graceful, runs compensation"}
{"kind":"cli","cmd":"restate invocations kill <id>","desc":"Immediate, no compensation"}
{"kind":"cli","cmd":"restate sql \"select * from sys_invocation where retry_count > 1\"","desc":"Find stuck"}
{"kind":"cli","cmd":"restate kv get <service> <key>","desc":"Read state"}
{"kind":"config","opt":"inactivity_timeout","default":"1m","use":"Grace period before termination"}
{"kind":"config","opt":"abort_timeout","default":"10m","use":"Max wait for graceful shutdown"}
{"kind":"config","opt":"retry_policy_max_attempts","default":"unlimited","use":"Max retries before pause/kill"}
{"kind":"config","opt":"idempotency_retention","default":"24h","use":"Idempotency key TTL"}
{"kind":"config","opt":"journal_retention","default":"24h","use":"Journal TTL"}
{"kind":"config","opt":"workflow_retention","default":"24h","use":"Workflow state after run"}
{"kind":"timeout","op":"git clone","val":"5m","why":"Large repos"}
{"kind":"timeout","op":"aws deploy","val":"15m","why":"Stack ops slow"}
{"kind":"timeout","op":"docker build","val":"30m","why":"Build times vary"}
{"kind":"timeout","op":"npm install","val":"5m","why":"Network + resolution"}
{"kind":"decision","q":"Need state?","a":"VirtualObject or Workflow"}
{"kind":"decision","q":"Long-running with waits?","a":"Workflow (promises + timers)"}
{"kind":"decision","q":"Just request-response?","a":"Service"}
{"kind":"decision","q":"Read-only operation?","a":"#[shared] for concurrency"}
{"kind":"decision","q":"Error is business logic?","a":"TerminalError"}
{"kind":"decision","q":"Error might fix itself?","a":"HandlerError (auto-retry)"}
{"kind":"decision","q":"Running CLI commands?","a":"ctx.run + inactivity_timeout"}
{"kind":"decision","q":"Multi-step with rollback?","a":"Saga pattern (see patterns.md)"}
{"kind":"ref","file":"templates.md","use":"Full code templates"}
{"kind":"ref","file":"patterns.md","use":"Saga, Fan-out, RateLimit, HumanLoop"}
{"kind":"ref","file":"subprocess.md","use":"CLI patterns, timeout guidance"}
{"kind":"ref","file":"observability.md","use":"Tracing, metrics, logging"}
{"kind":"ref","file":"introspection.md","use":"SQL queries, debugging"}
{"kind":"ref","file":"config.md","use":"All config options"}
{"kind":"ref","file":"anti-patterns.md","use":"Common mistakes + fixes"}
{"kind":"server","op":"bind","pattern":"Endpoint::builder().bind(svc.serve()).build()"}
{"kind":"server","op":"http","pattern":"HttpServer::new(endpoint).listen_and_serve(addr).await"}
{"kind":"server","op":"options","pattern":"Endpoint::builder().bind_with_options(svc.serve(), opts).build()"}
```

## Quick Pattern

```rust
ctx.run(|| async {
    tokio::process::Command::new("git")
        .args(&["clone", &repo]).output().await
}).await?
```

```rust
let opts = ServiceOptions::new().inactivity_timeout(Duration::from_secs(300));
Endpoint::builder().bind_with_opts(Svc.serve(), opts).build()
```

**Refs**: `references/{templates,patterns,subprocess,observability,introspection,config,anti-patterns}.md`
