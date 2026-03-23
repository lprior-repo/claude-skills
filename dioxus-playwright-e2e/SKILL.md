---
name: dioxus-playwright-e2e
description: This skill provides guidance for writing reliable end-to-end tests for Dioxus web applications using Playwright.
---

# Skill: Dioxus + Playwright E2E Testing

This skill provides guidance for writing reliable end-to-end tests for Dioxus web applications using Playwright.

## Problem Statement

Dioxus web applications can display a "Your app is being rebuilt" overlay during development mode. This happens when:
- New variables/expressions are added that weren't in the last compilation
- Logic changes outside of RSX
- Component signatures change
- Import statements or module structure changes
- Complex Rust expressions in attributes involve function calls

This causes flaky tests if not handled properly.

## Key Principles

### 1. Always Wait for Rebuild Overlay

Before any interaction or assertion, ensure the rebuild overlay is NOT present:

```typescript
// BAD: Test might interact while app is rebuilding
await page.click('[data-testid="tool-text"]');
await expectNodeCount(page, 1);

// GOOD: Wait for rebuild to complete first
await waitForNoRebuildOverlay(page);
await page.click('[data-testid="tool-text"]');
await expectNodeCount(page, 1);
```

### 2. Use Auto-Retrying Assertions

Playwright's auto-retrying assertions handle timing issues gracefully:

```typescript
// BAD: Non-retrying assertion
expect(await nodeCount(page)).toBe(1);

// GOOD: Auto-retrying assertion
await expect.poll(() => nodeCount(page), { timeout: 5000 }).toBe(1);

// BETTER: Use helper function with retry
await expectNodeCount(page, 1);
```

### 3. Implement Robust Helper Functions

Create reusable helpers that handle the rebuild cycle:

```typescript
// helpers.ts
export async function waitForNoRebuildOverlay(page: Page) {
  const rebuilding = page.getByRole("heading", {
    name: "Your app is being rebuilt.",
  });
  await expect.poll(async () => rebuilding.count(), { timeout: 60_000 }).toBe(0);
}

export async function waitForUiReady(page: Page) {
  await ensureDeterministicUi(page);
  await expect(canvas(page)).toBeVisible();
  await expect(page.locator('[data-testid="counter-nodes"]').first()).toBeVisible({ timeout: 30_000 });
  await waitForNoRebuildOverlay(page);
}
```

### 4. Use freshStart Pattern

For test isolation, use a fresh start pattern:

```typescript
export async function freshStart(page: Page) {
  await runEffectsSequential([
    () => page.context().clearCookies(),
    () => page.evaluate(() => {
      try { localStorage.clear(); } catch (_) { /* noop */ }
      try { sessionStorage.clear(); } catch (_) { /* noop */ }
    }),
    () => page.goto("/", { waitUntil: "load" }),
    () => waitForUiReady(page),
    () => waitForE2eReady(page),  // Wait for app-specific hooks
    () => resetDocument(page),     // Reset app state
    () => waitForCleanState(page),
  ]);
}
```

### 5. Add Waiting Between Operations

When multiple state changes occur, add small waits or use polling:

```typescript
// Between creating nodes
await createTextNode(page, canvas, 360, 320);
await waitForNoRebuildOverlay(page);  // Wait for rebuild between operations
await createTextNode(page, canvas, 780, 320);
```

### 6. Handle WebServer Rebuilds

For Playwright webServer configuration:

```typescript
// playwright.config.ts
export default defineConfig({
  webServer: {
    command: "dx serve --platform web --port 8082 --watch false --hot-reload false --interactive false",
    url: "http://127.0.0.1:8082",
    reuseExistingServer: true,
    timeout: 300_000,  // Allow time for initial build
  },
  use: {
    // IMPORTANT: Disable hot-reload in e2e to prevent rebuilds during tests
    // Using --hot-reload false in the command
  },
});
```

### 7. Use Proper Tool Selection Pattern

When selecting tools, wait for the tool to be fully active:

```typescript
export async function createTextNode(
  page: Page,
  canvas: Locator,
  x: number,
  y: number,
) {
  await runEffectsSequential([
    () => waitForNoRebuildOverlay(page),
    () => page.locator('[data-testid="tool-text"]').first().click(),
    // Wait for tool mode switch deterministically
    () => page.locator('[data-testid="tool-text"]').first().waitFor({ state: "visible" }),
  ]);
  const box = await runEffect(() => canvas.boundingBox());
  if (!box) {
    throw new Error("canvas bounding box not available");
  }
  await runEffect(() => page.mouse.click(box.x + x, box.y + y));
}
```

## Required Test Helper Functions

Every Dioxus E2E test suite should include:

1. `waitForNoRebuildOverlay(page)` - Waits for Dioxus rebuild to complete
2. `waitForUiReady(page)` - Waits for UI to be fully hydrated
3. `waitForE2eReady(page)` - Waits for app-specific E2E hooks
4. `resetDocument(page)` - Resets app state without page reload
5. `waitForCleanState(page)` - Verifies clean initial state
6. `freshStart(page)` - Full fresh-start sequence

## Test Configuration

```typescript
// playwright.config.ts
export default defineConfig({
  testDir: "diagram_tool/e2e",
  timeout: 45_000,
  use: {
    baseURL: "http://127.0.0.1:8082",
    headless: true,
    trace: "retain-on-failure",
    video: "retain-on-failure",
  },
  projects: [
    {
      name: "e2e-smoke",
      retries: 2,  // Allow retries for flaky rebuild-related issues
      workers: 12,
      grep: /@baseline/,
    },
  ],
});
```

## Common Issues and Solutions

### Issue: "Expected 2, Received 1" - Node creation failing intermittently

**Cause**: Test is not waiting for rebuild after node creation

**Solution**:
```typescript
await createTextNode(page, canvas, 560, 210);
await createTextNode(page, canvas, 820, 330);
await expectNodeCount(page, 2);  // This will retry automatically
```

### Issue: Test times out waiting for element

**Cause**: Rebuild overlay is blocking interaction

**Solution**:
```typescript
await waitForNoRebuildOverlay(page);  // Add this before interaction
await page.click('[data-testid="tool-text"]');
```

### Issue: Scene loading fails

**Cause**: Not waiting for rebuild after scene import

**Solution**:
```typescript
await page.getByTestId("toolbar-open").click();
await page.waitForTimeout(2000);  // Allow time for import processing
await waitForNoRebuildOverlay(page);  // Wait for any rebuild
await expect.poll(() => nodeCount(page), { timeout: 15000 }).toBe(contract.nodeCount);
```

## CI Considerations

For CI runs, consider:

1. **Disable hot-reload**: Use `--watch false --hot-reload false` in the serve command
2. **Increase timeouts**: Allow 5+ minutes for initial build
3. **Retry flaky tests**: Configure retries for rebuild-related flakes
4. **Use fresh browser contexts**: Each test gets a fresh context

## References

- [Dioxus Hot-Reload Documentation](https://dioxuslabs.com/learn/0.7/essentials/ui/hotreload)
- [Playwright Assertions](https://playwright.dev/docs/test-assertions)
- [Playwright Navigations](https://playwright.dev/docs/navigations)

# Bug Discovery Through E2E Tests

E2E tests are excellent at finding real bugs in the application code. When a test fails consistently, investigate the Rust code to find the root cause.

## Example: No-Op Marquee Bug

A failing test "no-op marquee does not clear existing selection" led to discovering a bug in `apply_rubber_band_release`:

### Buggy Code
```rust
fn apply_rubber_band_release(
    doc: &mut DiagramDocument,
    start: (f64, f64),
    current: (f64, f64),
    additive: bool,
) {
    if !has_drag_threshold(start, current) {
        doc.editor_state.selected_items.clear();  // BUG: Clears selection!
        return;
    }
    // ...
}
```

### Fixed Code
```rust
fn apply_rubber_band_release(
    doc: &mut DiagramDocument,
    start: (f64, f64),
    current: (f64, f64),
    additive: bool,
) {
    if !has_drag_threshold(start, current) {
        return;  // FIX: Preserve selection (do nothing)
    }
    // ...
}
```

### Fixing the Unit Test
The corresponding unit test also had to be fixed:

```rust
// Before (testing buggy behavior)
#[test]
fn given_noop_rubber_band_when_released_then_selection_is_cleared() {
    // ...
    assert!(doc.editor_state.selected_items.is_empty());
}

// After (testing correct behavior)
#[test]
fn given_noop_rubber_band_when_released_then_selection_is_preserved() {
    // ...
    assert!(doc.editor_state.selected_items.contains(&node_id.to_string()));
}
```

## Investigation Steps

When a test fails consistently:

1. **Check the error context** - Look at the Playwright error-context.md for page state
2. **Find the relevant Rust code** - Search for the functionality being tested
3. **Analyze the logic** - Look for bugs in state management, event handling, etc.
4. **Fix both code and tests** - Update unit tests to match correct behavior
5. **Verify all tests pass** - Run both Rust tests and E2E tests
