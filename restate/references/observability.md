# Observability

## Tracing (OpenTelemetry)

### Setup

```bash
# Start Jaeger (OTLP receiver)
docker run -d --name jaeger \
    -p 4317:4317 -p 4318:4318 -p 16686:16686 \
    jaegertracing/jaeger:2.4.0

# Start Restate with tracing endpoint
restate-server --tracing-endpoint http://localhost:4317
```

### Endpoints
| Format | URL |
|--------|-----|
| OTLP/gRPC | `http://localhost:4317` |
| OTLP/HTTP | `otlp+http://localhost:4318/v1/traces` |

### Features
- **W3C TraceContext**: Correlates parent traces from incoming HTTP
- **Span tags**: `restate.invocation.id`, `rpc.service`, `rpc.method`
- **One-way calls**: Separate traces, link by invocation ID

### Jaeger UI
http://localhost:16686

Search by invocation ID:
```
restate.invocation.id="inv_19maBIcE9uRD0gIu30mu6eqhZ4pQT"
```

---

## Metrics (Prometheus)

### Endpoint
```
localhost:5122/metrics
```

### Prometheus Config
```yaml
scrape_configs:
  - job_name: restate_server
    metrics_path: "/metrics"
    static_configs:
      - targets: ["10.10.10.1:5122"]
```

### Key Metrics

| Metric | Description |
|--------|-------------|
| `restate_ingress_requests_total` | Request count by state |
| `restate_ingress_request_duration_seconds` | Request latency |
| `restate_invoker_invocation_task_total` | Invocation task count |
| `restate_rocksdb_estimate_live_data_size_bytes` | Storage size |

### Example Queries

```promql
# Throughput (ops/s)
rate(restate_ingress_requests_total[$__rate_interval])

# P99 latency
restate_ingress_request_duration_seconds{quantile="0.99"}
```

### Grafana Dashboards

| Dashboard | ID | Purpose |
|-----------|-----|---------|
| Restate: Overview | [24747](https://grafana.com/grafana/dashboards/24747) | Cluster health, throughput |
| Restate: Internals | [24748](https://grafana.com/grafana/dashboards/24748) | Bifrost, Invoker, RocksDB |

---

## Logging

### Server Logging

```bash
# Default: INFO in pretty format
restate-server

# With filter
restate-server --log-filter=info,restate=debug

# JSON format for production
restate-server --log-format=json
```

### Log Filter Patterns
```bash
# Network issues
info,restate_ingress_http=trace,restate_invoker=trace,hyper=debug

# State machine effects
info,restate_worker::partition::effects=debug

# Service discovery
info,restate_admin=trace
```

### Log Components
- `restate_ingress_http` - HTTP request handling
- `restate_admin` - Metadata, service discovery
- `restate_invoker` - Service invocation
- `restate_worker::partition::state_machine` - State machine
- `restate_bifrost` - Durable log layer

### Log Context Fields
- `rpc.service` - Service name
- `rpc.method` - Handler name
- `restate.invocation.id` - Invocation identifier

---

## Service-Level Logging (Rust)

### Setup
```rust
fn main() {
    tracing_subscriber::fmt::init();
    // ... create endpoint
}
```

### Structured Logging in Handlers
```rust
use tracing::{info, info_span, Instrument};

async fn my_handler(&self, ctx: ObjectContext<'_>, req: Request) -> Result<Response, HandlerError> {
    // Create span with context
    let span = info_span!(
        "my_handler",
        key = %ctx.key(),
        invocation_id = %ctx.invocation_id()
    );

    async move {
        info!("Processing request");
        // ... handler logic
        info!(result = ?response, "Completed");
        Ok(response)
    }.instrument(span).await
}
```

### Log Levels
```rust
use tracing::{trace, debug, info, warn, error};

trace!("Very detailed");
debug!("Debug info");
info!("General info");
warn!("Warning");
error!("Error occurred");
```

---

## Configuration

### Tracing Headers
```toml
# restate.toml
[tracing-headers]
authorization = "Bearer some-auth-token"
```

### Tracing Filter
```toml
tracing-filter = "info,restate=debug"
```

### JSON Log Export
```bash
restate-server --tracing-json-path /var/log/restate/traces.json
```
