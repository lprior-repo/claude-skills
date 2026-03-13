# Dioxus 0.7 Fullstack Reference

```jsonl
{"kind":"meta","doc":"fullstack","skill":"dioxus-modern","version":"1.9.0"}
{"kind":"intent","text":"Deep-dive into Dioxus Fullstack features including server functions, streaming, and SSR patterns."}
{"kind":"api","id":"server_fn","signature":"#[server]","description":"Defines a server-side function with automatic client RPC generation. JSON by default."}
{"kind":"api","id":"use_server_future","signature":"fn use_server_future<T>(init: impl FnOnce() -> impl Future<Output = T>) -> Result<Resource<T>, RenderError>","description":"SSR-aware async fetching with automatic hydration."}
{"kind":"api","id":"use_websocket","signature":"fn use_websocket<In, Out, E>(init: impl FnOnce() -> ...) -> UseWebsocket<In, Out, E>","description":"Reactive websocket handle for bi-directional communication."}
{"kind":"api","id":"use_server_cached","signature":"fn use_server_cached<T: serde::Serialize>(key: &str, init: impl FnOnce() -> T) -> T","description":"Transfers data from server to client during hydration."}
{"kind":"api","id":"TextStream","description":"Unidirectional server-to-client text chunks. Perfect for LLM token streaming."}
{"kind":"rule","id":"streaming_control","text":"Enable out-of-order streaming via ServeConfig. Sent resolved components as they complete."}
{"kind":"rule","id":"native_origin","text":"Native apps must call set_server_url(\"https://api.com\") at launch to use server functions."}
{"kind":"rule","id":"middleware_order","text":"Global middleware via .layer() in dioxus::serve. Specific route middleware via #[middleware(Layer)]."}
{"kind":"workflow","id":"ssg_setup","steps":["Enable incremental rendering","Implement static_routes server fn","Run dx bundle --ssg"]}
```

## 1. Server Functions

### Basic Usage
```rust
#[server]
async fn get_data(id: u32) -> Result<Data, ServerFnError> {
    Ok(database::fetch(id).await?)
}
```

### Protocol and Codec
Dioxus 0.7 defaults to JSON. You can customize:
```rust
#[server(protocol = Http<GetUrl, Json>)]
async fn search(query: String) -> Result<Vec<Result>, ServerFnError> { ... }
```

## 2. Real-time Communication

### Websockets
Strongly typed messaging:
```rust
#[get("/api/ws")]
async fn chat_ws(options: WebSocketOptions) -> Result<Websocket<ClientMsg, ServerMsg>> {
    Ok(options.on_upgrade(|mut socket| async move {
        while let Ok(msg) = socket.recv().await {
            socket.send(process(msg)).await.ok();
        }
    }))
}
```

### SSE & Unidirectional Streams
- `TextStream`: Perfect for LLM token streaming.
- `ByteStream`: For raw file/binary data.
- `FileStream`: Optimized for large transfers.

## 3. Streaming & Hydration

### Out-of-Order Streaming
Send the HTML skeleton instantly, then push components as they resolve on the server.
```rust
ServeConfig::builder().enable_out_of_order_streaming()
```

### use_server_cached
Store a value on the server during SSR and retrieve it on the client without re-executing logic.
```rust
let data = use_server_cached("my-key", || compute());
```

## 4. Middleware & Security

### Axum Layers
Dioxus fullstack is built on Axum. Add global layers in `dioxus::serve`:
```rust
dioxus::serve(|| async move {
    Ok(dioxus::server::router(app).layer(TraceLayer::new_for_http()))
});
```

### Route Middleware
Use the `#[middleware]` attribute on server functions for endpoint-specific logic like auth or rate limiting.

## 5. Static Site Generation (SSG)

### Setup
1. Enable `incremental` rendering in `ServeConfig`.
2. Define a server function at endpoint `"static_routes"`.
3. Return `Route::static_routes()`.
4. Build with `dx bundle --ssg`.

### Hybrid Mode
Dioxus SSG generates static HTML but hydrates into a full SPA, allowing static SEO pages to have dynamic sub-regions.
