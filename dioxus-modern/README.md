# Dioxus Modern Skill

```jsonl
{"kind":"meta","doc":"readme","skill":"dioxus-modern","version":"1.9.0"}
{"kind":"onboarding","intent":"Provide a human-readable entry point for developers using the dioxus-modern skill."}
```

A comprehensive guide for modern Dioxus 0.7 + Tailwind CSS development.

## When to Use This Skill

Invoke this skill when asking about:
- Dioxus 0.7 best practices and patterns
- Signals (`use_signal`) and Stores (`use_store`) for state management
- `ReadSignal<T>` props for reactive component interfaces
- Async patterns with `use_resource` and `use_loader`
- Tailwind CSS integration in Dioxus 0.7
- Component architecture and custom hooks
- State hoisting and context patterns

## Quick Start

### State Management
```rust
// Atomic values
let mut count = use_signal(|| 0);

// Collections/nested state
#[derive(Store, Default)]
struct AppState { items: Vec<Item> }
let state = use_store(AppState::default);
```

### Tailwind Setup
1. Create `tailwind.css` with `@import "tailwindcss"`
2. Reference via `asset!("/assets/tailwind.css")`
3. Run `dx serve` (automatic integration)

## Support Files

- **[reference.md](reference.md)**: Detailed guidance on each pattern
- **[fullstack.md](fullstack.md)**: Server functions and streaming
- **[templates.md](templates.md)**: Reusable code templates
- **[examples.md](examples.md)**: Before/after examples
- **[migration.md](migration.md)**: Upgrading from 0.5/0.6

## Key Patterns

| Pattern | Use For |
|---------|---------|
| `use_signal` | Atomic values (i32, String, bool) |
| `use_store` | Collections, nested state |
| `ReadSignal<T>` | Component props (reactive) |
| `#[component]` | Memoized components |
| `use_resource` | Async data fetching |
| `use_memo` | Derived state |
| `use_effect` | Side-effects |
