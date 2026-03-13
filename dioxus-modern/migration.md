# Dioxus Migration Guide

```jsonl
{"kind":"meta","doc":"migration","skill":"dioxus-modern","version":"1.9.0"}
{"kind":"migration","id":"05_to_07","description":"Migration notes from Dioxus 0.5 to 0.7.","changes":[{"old":"dioxus-lib","new":"dioxus","description":"Package renamed"},{"old":"use_state","new":"use_signal","description":"State hook renamed"},{"old":"form submissions prevented","new":"form submissions allowed by default","description":"Form submission behavior changed, call prevent_default() to prevent"},{"old":"asset options separate","new":"AssetOptions unified","description":"Asset options unified to AssetOptions::image() etc."},{"old":"use_drop in prelude","new":"use_drop removed from prelude","description":"use_drop removed from prelude, use use_drop directly"}]}
{"kind":"migration","id":"06_to_07","description":"Migration notes from Dioxus 0.6 to 0.7.","changes":[{"old":"dioxus-ssr","new":"dioxus-ssr still available","description":"SSR still available but integrated into fullstack"},{"old":"server functions URL-encoded","new":"server functions JSON by default","description":"Default server function codec changed to JSON"}]}
{"kind":"reference","id":"migration_07","changes":["dioxus-lib -> dioxus","use_state -> use_signal","AssetOptions unified","Server codec is JSON"]}
```

## 0.5/0.6 → 0.7 Breaking Changes

### 1. dioxus-lib Removed
```rust
// 0.5/0.6
use dioxus_lib::prelude::*;

// 0.7
use dioxus::prelude::*;
```

### 2. Form Submission Behavior
```rust
// 0.6: Forms didn't submit by default
form { onsubmit: |e| {} }

// 0.7: Forms submit by default, call prevent_default() to prevent
form { onsubmit: |e| e.prevent_default() }
```

### 3. Asset Options API
```rust
// 0.6
asset!("/image.png", ImageAssetOptions::new().with_size(size))

// 0.7
asset!("/image.png", AssetOptions::image().with_size(size))
```

### 4. Server Function Codec
```rust
// 0.6: URL-encoded form data by default
#[server]
async fn my_function(arg: MyStruct) -> ServerFnResult<MyResponse> { ... }

// 0.7: JSON by default
#[server(protocol = Http<GetUrl, Json>)]  // Explicit if needed
async fn my_function(arg: MyStruct) -> ServerFnResult<MyResponse> { ... }
```

### 5. Removed from Prelude
```rust
// These are no longer in dioxus::prelude:
use_drop
Runtime
queue_effect
provide_root_context
```

### 6. Owned Event Listener Type
Custom renderers should accept `impl SuperInto<ListenerCallback<$data>, __Marker>` instead of `EventHandler`.

## Migration Checklist

- [ ] Replace `dioxus_lib` with `dioxus`
- [ ] Add `e.prevent_default()` to form submissions
- [ ] Update asset options to use `AssetOptions::image()`
- [ ] Update server functions to use JSON codec
- [ ] Import removed items explicitly if used
- [ ] Update event handler types in custom renderers

## Testing

After migration:
1. Run `cargo check` to catch compilation errors
2. Run `cargo clippy` to fix warnings
3. Test form submissions
4. Verify asset bundling
5. Check server function calls
