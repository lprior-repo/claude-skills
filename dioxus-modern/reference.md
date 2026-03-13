# Dioxus 0.7 Modern Reference

```jsonl
{"kind":"meta","doc":"reference","skill":"dioxus-modern","version":"1.9.0"}
{"kind":"intent","text":"Provide a technical deep-dive into Dioxus 0.7 architecture, state management, and fullstack patterns."}
{"kind":"api","id":"use_signal","signature":"fn use_signal<T: 'static>(initializer: impl FnOnce() -> T) -> Signal<T>","description":"Creates a new Signal. Signals are a Copy state management solution with automatic dependency tracking."}
{"kind":"api","id":"use_signal_sync","signature":"fn use_signal_sync<T: 'static + Send + Sync>(initializer: impl FnOnce() -> T) -> Signal<T>","description":"Creates a new Signal with SyncStorage. Use when sharing state across threads."}
{"kind":"api","id":"use_store","signature":"fn use_store<T: 'static + Default>(initializer: impl FnOnce() -> T) -> Store<T>","description":"Create a new Store. Stores are reactive types built for nested data structures."}
{"kind":"api","id":"use_memo","signature":"fn use_memo<T: PartialEq + 'static>(initializer: impl FnOnce() -> T) -> Memo<T>","description":"Creates a new Memo. Re-computes only when dependencies change."}
{"kind":"api","id":"use_resource","signature":"fn use_resource<T, E>(initializer: impl FnOnce() -> impl Future<Output = Result<T, E>> + 'static) -> Resource<T>","description":"Reactive async state. Auto-restarts when signals read inside are updated."}
{"kind":"api","id":"use_loader","signature":"fn use_loader<T, E>(initializer: impl FnOnce() -> impl Future<Output = Result<T, E>> + 'static) -> Result<Loader<T>, Loading>","description":"Hybrid SSR/client loader with suspense integration."}
{"kind":"api","id":"use_effect","signature":"fn use_effect(initializer: impl FnOnce() + 'static)","description":"Runs side-effects after render. Tracks signals read inside."}
{"kind":"api","id":"use_context","signature":"fn use_context<T: 'static + Clone>() -> T","description":"Consume context from the tree."}
{"kind":"api","id":"use_context_provider","signature":"fn use_context_provider<T: 'static + Clone>(initializer: impl FnOnce() -> T) -> T","description":"Provide context to subtree."}
{"kind":"api","id":"use_drop","signature":"fn use_drop(initializer: impl FnOnce() + 'static)","description":"Cleanup logic when component unmounts."}
{"kind":"api","id":"use_callback","signature":"fn use_callback<T: 'static, Args>(callback: impl Fn(Args) -> T + 'static) -> Callback<Args, T>","description":"Creates a memoized callback. Stabilizes function identity across renders."}
{"kind":"api","id":"use_effect_with","signature":"fn use_effect_with<T: PartialEq + 'static>(initializer: impl FnOnce() -> T, observer: impl Fn(&T))","description":"Effect that runs when the observed value changes. Combines use_effect + dependency tracking."}
{"kind":"api","id":"use_on_destroy","signature":"fn use_on_destroy(callback: impl FnOnce() + 'static)","description":"Alias for use_drop. Cleanup logic when component unmounts."}
{"kind":"api","id":"use_id","signature":"fn use_id() -> String","description":"Generates a unique ID for accessibility and element referencing."}
{"kind":"api","id":"use_shared_state","signature":"fn use_shared_state<T: 'static + Clone>() -> Option<&'static T>","description":"Access shared global state. Prefer use_signal with wrapper for most cases."}
{"kind":"api","id":"use_shared_state_provider","signature":"fn use_shared_state_provider<T: 'static + Clone>(initializer: impl FnOnce() -> T)","description":"Provide shared global state accessible via use_shared_state."}
{"kind":"api","id":"use_provide_root_id","signature":"fn use_provide_root_id(id: impl Into<String>) -> ()","description":"Provide a root-level ID scope for nested use_id calls."}
{"kind":"api","id":"use_ref","signature":"fn use_ref<T: 'static>(initializer: impl FnOnce() -> T) -> &Ref<T>","description":"Legacy. Use use_signal instead. Creates a mutable reference with interior mutability."}
{"kind":"api","id":"use_suspense","signature":"fn use_suspense<T>(init: impl FnOnce() -> impl Future<Output = T> + 'static, fallback: impl Fn() -> V) -> T","description":"Suspend rendering until async resource is ready. Shows fallback during load."}
{"kind":"api","id":"use_timeout","signature":"fn use_timeout(duration: Duration) -> &TimeoutHandle","description":"Schedule a callback to run after a delay. Returns handle to cancel."}
{"kind":"api","id":"use_future","signature":"fn use_future<T, E>(initializer: impl FnOnce() -> impl Future<Output = Result<T, E>> + 'static) -> Future<T>","description":"Static async future. Runs once on mount, does NOT react to signal changes unlike use_resource."}
{"kind":"api","id":"use_callback_ref","signature":"fn use_callback_ref<T, Args>(initializer: impl FnOnce() -> T, callback: impl Fn(Args) -> T + 'static) -> impl Fn(Args) -> T","description":"Callback with ref capture. Combines effect dependencies with callback stability."}
{"kind":"api","id":"use_provide_state","signature":"fn use_provide_state<T: 'static + Clone>(cx: Scope, initializer: impl FnOnce() -> T) -> Signal<T>","description":"Provide app-level state. Use in root component for global reactive state."}
{"kind":"api","id":"use_suspense_boundary","signature":"fn use_suspense_boundary() -> SuspenseBoundary","description":"Creates boundary to catch suspended components and display fallback."}
{"kind":"api","id":"use_error_boundary","signature":"fn use_error_boundary() -> ErrorBoundary","description":"Catches errors from child components. Shows error UI instead of crashing app."}
{"kind":"api","id":"use_on_click","signature":"fn use_on_click<F: FnMut(MouseEvent) + 'static>(cx: Scope, handler: F) -> EventHandler<MouseEvent>","description":"Creates memoized click handler. Convenience wrapper with stable identity."}
{"kind":"api","id":"use_on_mount","signature":"fn use_on_mount(cx: Scope, callback: impl FnOnce() + 'static)","description":"Runs callback once when component first mounts. Alias for use_effect with empty deps."}
{"kind":"api","id":"use_arc_signal","signature":"fn use_arc_signal<T: 'static>(initializer: impl FnOnce() -> T) -> ArcSignal<T>","description":"Creates Signal with Arc storage. For expensive-to-clone types requiring interior mutability."}
{"kind":"warning","id":"use_state","text":"Legacy hook. use_signal is preferred in Dioxus 0.7+ for better performance and fine-grained reactivity.","description":"Deprecated. Use use_signal instead for Copy types, use_store for nested data."}
{"kind":"type","id":"Signal","description":"Primary reactive unit. Copy + Send + Sync."}
{"kind":"type","id":"ReadSignal","description":"Read-only signal view. Standard for reactive props."}
{"kind":"type","id":"Store","description":"Nested reactive state. Use #[derive(Store)] on structs."}
{"kind":"trait","id":"Readable","description":"Trait for states that can be read from like Signal or ReadSignal."}
{"kind":"trait","id":"Writable","description":"Trait for states that can be written to like Signal."}
{"kind":"event","id":"onclick","handler":"EventHandler<MouseEvent>","description":"Click event."}
{"kind":"event","id":"oninput","handler":"EventHandler<InputEvent>","description":"Text/field input event."}
{"kind":"event","id":"onchange","handler":"EventHandler<InputEvent>","description":"Input/select change event. Fires on blur after value modification."}
{"kind":"event","id":"onsubmit","handler":"EventHandler<SubmitEvent>","description":"Form submission. Automatic prevent_default in 0.7."}
{"kind":"event","id":"onblur","handler":"EventHandler<FocusEvent>","description":"Element loses focus."}
{"kind":"event","id":"onfocus","handler":"EventHandler<FocusEvent>","description":"Element gains focus."}
{"kind":"event","id":"onkeydown","handler":"EventHandler<KeyboardEvent>","description":"Key pressed down."}
{"kind":"event","id":"onkeyup","handler":"EventHandler<KeyboardEvent>","description":"Key released."}
{"kind":"event","id":"onkeypress","handler":"EventHandler<KeyboardEvent>","description":"Key pressed (deprecated, use onkeydown)."}
{"kind":"event","id":"onmouseenter","handler":"EventHandler<MouseEvent>","description":"Mouse enters element. Does not bubble."}
{"kind":"event","id":"onmouseleave","handler":"EventHandler<MouseEvent>","description":"Mouse leaves element. Does not bubble."}
{"kind":"event","id":"onload","handler":"EventHandler<LoadEvent>","description":"Resource loaded."}
{"kind":"event","id":"onerror","handler":"EventHandler<LoadEvent>","description":"Resource failed to load."}
{"kind":"event","id":"onscroll","handler":"EventHandler<WheelEvent>","description":"Container scrolled."}
{"kind":"event","id":"ondrag","handler":"EventHandler<DragEvent>","description":"Element is being dragged."}
{"kind":"event","id":"ondrop","handler":"EventHandler<DragEvent>","description":"Element dropped."}
{"kind":"macro","id":"rsx!","description":"Main templating macro for Dioxus. Defines UI components with Rust-like syntax. Supports expressions, attributes, children, and custom elements."}
{"kind":"macro","id":"#[component]","description":"Component decorator macro. Generates props struct, implements Component trait, adds memoization via PartialEq on props."}
{"kind":"macro","id":"html!","description":"HTML macro for static HTML content. Alias for rsx! in most contexts."}
{"kind":"macro","id":"template!","description":"Template macro for reusable UI templates with slots."}
{"kind":"type","id":"EventHandler","description":"Callback type for event handlers. Generic over event type (e.g., EventHandler<MouseEvent>). Stored as field in components."}
{"kind":"type","id":"Scope","description":"Dioxus component scope. Provides access to hooks, context, and rendering. Alias for dioxus::core::Scope."}
{"kind":"type","id":"VNode","description":"Virtual Node. Internal representation of a rendered element or component."}
{"kind":"rule","id":"component_purity","text":"Component bodies must be pure. Mutations belong in event handlers, effects, or resources."}
{"kind":"rule","id":"hook_order","text":"Hooks must be called in the same order every render. No conditionals or loops."}
{"kind":"pattern","id":"signal_atomic","text":"Use use_signal for atomic/copy values (numbers, strings, bools, simple enums). Signals are Copy and implement automatic dependency tracking.","example":"let count = use_signal(|| 0); rsx! { \"{count}\" }"}
{"kind":"pattern","id":"store_nested","text":"Use use_store with #[derive(Store)] for nested/complex state (structs, vecs, maps). Provides fine-grained reactivity at field level.","example":"#[derive(Store)] struct AppState { user: User, items: Vec<Item> }"}
{"kind":"pattern","id":"memo_computed","text":"Use use_memo for expensive computations. Memo only re-evaluates when dependencies change.","example":"let sorted = use_memo(move || items.iter().sorted().collect::<Vec<_>>())"}
{"kind":"pattern","id":"resource_async","text":"Use use_resource for async state that needs reactivity. Automatically restarts when signals inside are updated.","example":"let data = use_resource(move || async fetch_user(user_id()))"}
{"kind":"pattern","id":"context_di","text":"Use use_context/use_context_provider for dependency injection. Avoids prop drilling for global state.","example":"let theme = use_context::<Theme>(); cx.provider(Theme::dark(), || child())"}
{"kind":"pattern","id":"callback_events","text":"Use use_callback for event handlers that need stable identity across renders.","example":"let handler = use_callback(move |_| set_count(*count + 1))"}
{"kind":"pattern","id":"effect_side_effects","text":"Use use_effect for side effects (DOM manipulation, subscriptions, logging). Runs after render.","example":"use_effect(move || { console_log(\"mounted\"); || console_log(\"cleanup\") })"}
{"kind":"pattern","id":"store_lenses","text":"Use store lenses (my_store.field().title()) for fine-grained access. Only re-renders component using that specific field.","example":"let title = my_store.items()[idx].title(); my_store.items()[idx].title.set(\"new\")"}
{"kind":"pattern","id":"readsignal_props","text":"Use ReadSignal<T> for component props to ensure reactivity. Accepts Signal, Memo, Resource, or primitives.","example":"#[component] fn Child(value: ReadSignal<i32>) -> Element { rsx! { \"{value}\" } }"}
{"kind":"pattern","id":"suspense_async","text":"Use SuspenseBoundary with suspend() for async components. Shows fallback during load, enables streaming.","example":"SuspenseBoundary { fallback: |_| \"loading\", async_component {} }"}
{"kind":"antipattern","id":"manual_clone","text":"Shall not manually clone signals. Use .read() for reading or .write() for writing instead of .clone().","rationale":"Signals are Copy. Cloning creates redundant handles and breaks reactivity tracking.","example_bad":"let clone = signal.clone(); // creates new handle","example_good":"let value = *signal.read(); // read current value"}
{"kind":"antipattern","id":"use_state_legacy","text":"Shall not use use_state in Dioxus 0.7+. Use use_signal instead for atomic values or use_store for nested data.","rationale":"use_state is legacy API from 0.5/0.6. Signals provide Copy semantics and better performance.","example_bad":"let mut count = use_state(|| 0);","example_good":"let count = use_signal(|| 0);"}
{"kind":"antipattern","id":"direct_mutation","text":"Shall not mutate state directly without signals. All state must flow through reactive primitives.","rationale":"Direct mutation bypasses reactivity system, UI won't update.","example_bad":"let mut items = Vec::new(); items.push(new_item);","example_good":"let mut items = use_signal(Vec::new); items.write().push(new_item);"}
{"kind":"antipattern","id":"prop_drill","text":"Shall not pass props through deep component trees. Use context for global state or compose components differently.","rationale":"Prop drilling creates tight coupling and makes refactoring difficult.","example_bad":"fn A(p) { B(p) } fn B(p) { C(p) } fn C(p) { p.value }","example_good":"fn A(cx) { cx.provider(value, || B {}) } fn B(cx) { use_context::<Value>() }"}
{"kind":"antipattern","id":"large_monolith","text":"Shall not create large monolithic components. Split into smaller, focused components with single responsibility.","rationale":"Large components are hard to test, reason about, and maintain.","example_bad":"fn Dashboard(cx) { render_header(); render_sidebar(); render_content(); render_footer(); }","example_good":"fn Dashboard(cx) { rsx! { Header {} Sidebar {} Content {} Footer {} } }"}
{"kind":"antipattern","id":"missing_effect_cleanup","text":"Shall not forget cleanup in effects. Always return cleanup function to prevent memory leaks and ghost state.","rationale":"Effects without cleanup leak resources and cause stale state on remount.","example_bad":"use_effect(|| { let sub = subscribe(handler); })","example_good":"use_effect(|| { let sub = subscribe(handler); || sub.unsubscribe() })"}
{"kind":"antipattern","id":"mutable_props","text":"Shall not use mut or Signal for component props. Use ReadSignal<T> for reactive input, callbacks for output.","rationale":"Props should be immutable input. Mutable props break one-way data flow.","example_bad":"#[component] fn Child(mut value: Signal<i32>) -> Element","example_good":"#[component] fn Child(value: ReadSignal<i32>, on_increment: Callback<i32>) -> Element"}
{"kind":"antipattern","id":"blocking_async","text":"Shall not block async rendering with synchronous operations. Use use_resource or use_future for async work.","rationale":"Blocking operations freeze the UI. Async primitives integrate with Suspense.","example_bad":"let data = blocking_fetch_sync();","example_good":"let data = use_resource(|| async { fetch().await });"}
{"kind":"antipattern","id":"index_as_key","text":"Shall not use array index as key when items can reorder. Use stable unique IDs for proper diffing.","rationale":"Index keys cause incorrect DOM updates when list order changes.","example_bad":"for (idx, item) in items.iter().enumerate() { rsx! { li { key: \"{idx}\" } } }","example_bad":"for item in items { rsx! { li { key: \"{item.id}\" } } }"}
{"kind":"antipattern","id":"effect_dependencies","text":"Shall not read signals in use_effect without tracking. Signals read inside effect create implicit dependencies.","rationale":"Untracked signal reads miss updates. Either use the signal directly or use_effect_with for explicit tracking.","example_bad":"use_effect(|| { some_signal(); }) // signal not tracked","example_good":"use_effect_with(some_signal, |v| { /* use v */ })"}
{"kind":"principle","id":"single_responsibility","text":"Each component should have one clear purpose. Extract UI, logic, and data fetching into separate concerns.","rationale":"Single-responsibility components are reusable, testable, and compose better."}
{"kind":"principle","id":"props_drill_prevention","text":"Prefer composition over prop drilling. Use context for shared state, extract intermediate components for specific props.","rationale":"Shallow component trees with clear data flow are easier to maintain and debug."}
{"kind":"principle","id":"effect_cleanup","text":"Always return cleanup function from effects. Handle subscriptions, timers, and DOM mutations with proper teardown.","rationale":"Cleanup prevents memory leaks, stale callbacks, and double-rendering issues."}
{"kind":"principle","id":"one_way_data_flow","text":"Data flows down via props/context, actions flow up via callbacks. Never mutate props in child components.","rationale":"One-way flow makes state changes predictable and debugging straightforward."}
{"kind":"principle","id":"atomic_updates","text":"Keep state atomic. Use Signal for values, Store for collections. Avoid nested mutability patterns.","rationale":"Atomic state enables fine-grained reactivity and simpler mental model for updates."}
{"kind":"principle","id":"composition_over_inheritance","text":"Compose components with children and slots. Extract reusable patterns as wrapper components.","rationale":"Composition provides flexibility without coupling components to implementation details."}
{"kind":"principle","id":"explicit_dependencies","text":"Make dependencies explicit. Pass signals explicitly to effects, use callbacks for parent communication.","rationale":"Explicit dependencies make data flow visible and refactoring safer."}
{"kind":"principle","id":"error_boundaries","text":"Use error boundaries to catch and handle runtime errors gracefully. Never let crashes propagate unchecked.","rationale":"Error boundaries provide fallback UI and prevent full app crashes from component errors."}
```

## 1. The Reactive Store Paradigm

### Stores vs. Signals
- **Signals**: Best for atomic values. Updates trigger a re-render of the entire component that reads them.
- **Stores**: Best for nested structs and collections. Provides "Lenses" to zoom into data. 
- **Fine-grained Reactivity**: Iterating over a `Store<Vec<T>>` with `.iter()` provides `ReadSignal<T>` handles. Modifying one item **only** re-renders the component using that specific handle, not the parent list.

### Store Lenses
Lenses are zero-cost abstractions generated by `#[derive(Store)]`.
```rust
let title = my_store.header().title(); // Creates a Lens
```
Lenses implement `Readable` and `Writable`. On component boundaries, they automatically decay into `ReadSignal<T>` or `ReadStore<T>`.

## 2. Asynchronous Patterns & Suspense

### SuspenseBoundary
Groups multiple async tasks.
```rust
SuspenseBoundary {
    fallback: |_| rsx! { "Loading..." },
    AsyncChild {}
}
```

### Suspending Components
Call `.suspend()?` on a `Resource`. This returns early with a `RenderError::Suspended` variant.
```rust
let data = use_resource(move || fetch()).suspend()?;
```

### use_resource vs use_future
- `use_resource`: Reactive. Automatically restarts when signals read inside its closure change.
- `use_future`: Static. Only runs once on mount.

### Avoiding Waterfalls
Initialize multiple resources early to fetch in parallel:
```rust
let res_a = use_resource(fetch_a);
let res_b = use_resource(fetch_b);
let data_a = res_a.suspend()?;
let data_b = res_b.suspend()?;
```

## 3. Component Architecture

### #[component] macro
Always use the macro. It handles:
- Props struct generation
- Automatic memoization (only re-renders if props change via `PartialEq`)
- Clean function signatures

### ReadSignal Props
Standardize on `ReadSignal<T>` for reactive props. It accepts `Signal`, `Memo`, `Resource`, or even raw primitives with auto-conversion in `rsx!`.

## 4. Reconciliation & Performance

### The Render Loop
1. **Render**: Call component function.
2. **Display**: Renderer draws the tree.
3. **Listen**: User interacts (event).
4. **Mutate**: Event handler updates Signal/Store.
5. **Reconcile**: Dioxus diffs old vs new tree and issues minimal draw calls.

### Purity Rules
Component bodies **must** be pure. Side effects belong in:
- **Event Handlers**: For user actions.
- **Effects (`use_effect`)**: For DOM sync or external logging.
- **Resources (`use_resource`)**: For async data.

## 5. Advanced RSX & DOM Access

### Custom Attributes
Use quotes for non-standard attributes:
```rust
div { "data-id": "123", "aria-label": "Close" }
```

### Dangerous Inner HTML
```rust
div { dangerous_inner_html: "<h1>Raw HTML</h1>" }
```

### Direct DOM Access
Use `onmounted` to get a handle to the live element.
```rust
onmounted: move |e| async move {
    let _ = e.set_focus(true).await;
}
```

## 6. JavaScript Interop (eval)
Send and receive data between Rust and JS.
```rust
let mut eval = document::eval("dioxus.send(window.location.href)");
let href = eval.recv::<String>().await?;
```
- JS -> Rust: `dioxus.send(data)`
- Rust -> JS: `eval.send(data)`
- Rust recv: `eval.recv().await`
- JS recv: `await dioxus.recv()`
