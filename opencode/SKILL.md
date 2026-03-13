---
name: opencode
description: "OpenCode CLI + API expert. Use for run/serve/web/attach, sessions, agents, MCP, providers, automation, and orchestration with SSE/polling."
argument-hint: [subcommand, workflow question, or automation task]
allowed-tools: Read,Write,Edit,Glob,Grep,Bash,Task,AskUserQuestion
model: sonnet
user-invocable: true
---

# Skill: opencode (token-efficient edition)

OpenCode is an AI coding runtime with:

- CLI/TUI (`opencode`, `opencode run`)
- server mode (`opencode serve`, HTTP API)
- multi-provider model routing
- custom agents, MCP servers, skills, tools

This skill is optimized for low token use while preserving operational coverage.

## 1) Fast mental model

- **Control plane owns policy/state** (your orchestrator).
- **OpenCode owns execution** (model/tool/session runtime).
- **Session = execution unit** (messages, parts, tokens, diffs).
- **Use fresh sessions per stage attempt** for deterministic costs/audit.

## 2) Essential CLI (only high-value commands)

```bash
# Interactive
opencode

# One-shot automation
opencode run --format json "task"

# Server mode (for orchestrators)
OPENCODE_SERVER_PASSWORD=secret opencode serve --port 4096

# Attach client
opencode attach http://localhost:4096

# Health/debug
opencode debug config
opencode debug paths
opencode models --verbose
opencode stats --models --tools --days 7
```

## 3) API automation essentials

### Auth

- Server uses Basic Auth.
- Set `OPENCODE_SERVER_PASSWORD` when starting server.
- Requests use `-u opencode:$PASSWORD` unless username changed.

### Critical request-shape rule (validated)

For `POST /session/{id}/message` and `POST /session/{id}/prompt_async`, pass model under `model`:

```json
{
  "model": { "providerID": "openai", "modelID": "gpt-5.3-codex" },
  "agent": "build",
  "parts": [{ "type": "text", "text": "..." }]
}
```

Do not rely on top-level `providerID`/`modelID` in API bodies.

### Minimal sync flow (recommended prototype mode)

```bash
# 1) create session
curl -u opencode:$PASSWORD -X POST "$BASE/session" \
  -H 'Content-Type: application/json' \
  -d '{"title":"run-123-qa-a1"}'

# 2) execute stage (sync)
curl -u opencode:$PASSWORD -X POST "$BASE/session/$SID/message" \
  -H 'Content-Type: application/json' \
  -d '{"model":{"providerID":"openai","modelID":"gpt-5.3-codex"},"agent":"build","parts":[{"type":"text","text":"<stage prompt>"}]}'
```

### Async flow (use with durable state)

```bash
# queue
curl -u opencode:$PASSWORD -X POST "$BASE/session/$SID/prompt_async" \
  -H 'Content-Type: application/json' \
  -d '{"model":{"providerID":"openai","modelID":"gpt-5.3-codex"},"agent":"build","parts":[{"type":"text","text":"<stage prompt>"}]}'

# timeout recovery
curl -u opencode:$PASSWORD -X POST "$BASE/session/$SID/abort"
```

## 4) Polling + SSE behavior (validated)

### `GET /session/status` is sparse

- Busy sessions appear as keys.
- Idle sessions are absent.

```json
{ "ses_abc": { "type": "busy" } }
```

or

```json
{}
```

Treat missing key as idle.

### Completion gate (advance only if all true)

1. Session not busy (`/session/status`)
2. Latest assistant message exists (`/session/{id}/message?limit=1`)
3. `latest.info.time.completed` set
4. Assistant text part parses to expected JSON contract

### SSE routes

- `GET /event` (instance)
- `GET /global/event` (global)

Useful events:

- `session.status`, `session.idle`
- `message.updated`, `message.part.updated`
- `session.diff`
- `permission.updated`, `question.updated`

## 5) Interruption handling

Always check queues:

```bash
curl -u opencode:$PASSWORD "$BASE/permission"
curl -u opencode:$PASSWORD "$BASE/question"
```

- Reply permission: `POST /permission/{requestID}/reply`
- Reply question: `POST /question/{requestID}/reply`

Treat interruptions as workflow states, not errors.

## 6) Failure taxonomy (recommended)

- `pending_permission`
- `pending_question`
- `rate_limited`
- `provider_unavailable`
- `auth_failed`
- `context_overflow`
- `assistant_output_not_json`
- `assistant_output_missing_text_part`
- `timeout`

Use taxonomy for deterministic retries/escalation.

## 7) Context/token policy for orchestrators

- New session per `run_id + stage + attempt`
- Carry artifact summaries, not full transcript history
- Parse/store `info.tokens` for budget controls
- Prefer sync `/message` while prototyping
- Use async only with durable resume/reconcile

## 8) Must-know API groups

- Health/events: `/global/health`, `/event`, `/global/event`
- Session: `/session`, `/session/{id}`, `/session/{id}/message`, `/session/{id}/prompt_async`, `/session/{id}/abort`
- Interrupts: `/permission`, `/question`
- Providers: `/provider`, `/config/providers`
- MCP: `/mcp*`
- PTY/WebSocket: `/pty*`, `/pty/{id}/connect`
- OpenAPI: `/doc`

## 9) Quick reliability playbook

1. `assistant_output_not_json` -> retry once with stricter JSON contract
2. `assistant_output_missing_text_part` -> retry once, then escalate
3. `timeout` -> abort session, retry in new session
4. `rate_limited/provider_unavailable` -> backoff + fallback model/provider
5. repeated same stage+failure -> stuck detection -> escalate/human

## 10) Config essentials (minimal)

Use env references for secrets:

```jsonc
{
  "model": "openai/gpt-5.3-codex",
  "small_model": "openai/gpt-4.1-mini",
  "default_agent": "build",
  "provider": {
    "openai": { "options": { "apiKey": "{env:OPENAI_API_KEY}" } }
  },
  "compaction": { "auto": true, "prune": true }
}
```

## 11) References

- Full HTTP API: `references/http-api.md`
- Runtime OpenAPI: `GET /doc`
- Deeper CLI help: `opencode <cmd> --help`

---

**Skill Version**: 1.2.0
**Last Updated**: February 2026
**OpenCode Version Support**: 1.1.59+
**Status**: Production-Ready
