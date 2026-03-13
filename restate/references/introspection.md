# Introspection & Debugging

## SQL Introspection Tables

| Table | Description |
|-------|-------------|
| `sys_invocation` | Active and recent invocations |
| `sys_inbox` | Queue of pending invocations |
| `sys_keyed_service_status` | Virtual Object status (what's blocking) |
| `sys_journal` | Journal entries for invocations |
| `sys_service` | Registered services |
| `sys_deployment` | Service deployments |
| `sys_idempotency` | Idempotency keys |
| `state` | Application K/V state |

## CLI Queries

```bash
# List invocations
restate invocations list
restate invocations list --all
restate invocations list --status backing-off
restate invocations list --service MyService --key myKey

# Describe invocation
restate invocations describe <id>

# SQL queries
restate sql "select * from sys_invocation"
restate sql "select * from sys_journal where id='inv_...'"
restate sql "select * from state where service_name='Counter'"
```

## Common Queries

### Invocations in Retry Loop
```sql
select * from sys_invocation where retry_count > 1
```

### Blocking Virtual Object
```sql
select invocation_id from sys_keyed_service_status
where service_name = 'MyObject' and service_key = 'myKey'
```

### Invocation Status
```sql
select status, modified_at, retry_count from sys_invocation
where id = 'inv_...'
```

### View Journal
```sql
select * from sys_journal where id = 'inv_...' order by seq
```

### Read Service State
```sql
select key, value_utf8 from state
where service_name = 'MyObject' and service_key = 'myKey'
```

### Old Stuck Invocations
```sql
select * from sys_invocation
where to_timestamp(modified_at) <= now() - interval '1' hour
```

### Invocation Source
```sql
select invoked_by, invoked_by_service_name, invoked_by_id
from sys_invocation where id = 'inv_...'
```

### Get Trace ID
```sql
select trace_id from sys_invocation where id = 'inv_...'
```

## Invocation Status Values

| Status | Description |
|--------|-------------|
| `pending` | Enqueued, waiting for turn |
| `ready` | Ready to process, not running |
| `running` | Actively processing |
| `backing-off` | Retrying due to failure |
| `suspended` | Waiting on external input |
| `completed` | Finished (idempotent/workflow only) |

## State Management

### Read State
```bash
restate kv get <service> <key>
restate kv get Counter bob
```

### Edit State
```bash
restate kv edit <service> <key>
restate kv edit Counter bob --force  # Overwrite concurrent changes
```

### Plain JSON Output
```bash
restate kv get Counter bob --plain | jq '.count'
```

## HTTP Queries

```bash
# Query via HTTP
curl localhost:9070/query --json '{"query": "select * from sys_invocation"}'

# With filter
curl localhost:9070/query --json '{"query": "select * from state where service_name=\"X\""}'
```

## Debugging Workflows

### Check if workflow is running
```sql
select status from sys_invocation
where target_service_name = 'MyWorkflow' and target_service_key = 'wf-123'
```

### Check workflow state
```sql
select key, value_utf8 from state
where service_name = 'MyWorkflow' and service_key = 'wf-123'
```

### Find promises waiting
Look for `suspended` status - workflow is likely waiting on a promise.

## Handling Stuck Invocations

### 1. Identify
```bash
restate invocations list --status suspended
restate sql "select * from sys_invocation where status='suspended' and modified_at < ..."
```

### 2. Investigate
```bash
restate invocations describe <id>
restate sql "select * from sys_journal where id='<id>'"
```

### 3. Resolve
```bash
# Cancel gracefully (runs compensation)
restate invocations cancel <id>

# Kill immediately (no compensation)
restate invocations kill <id>

# Resume a paused invocation
restate invocations resume <id>
```
