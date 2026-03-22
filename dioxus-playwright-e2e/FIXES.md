# Dioxus + Playwright E2E Test Fixes

This document captures the specific fixes needed for the seshat project to make E2E tests reliable.

## Root Cause Analysis

The "Your app is being rebuilt" overlay in Dioxus appears when:
1. The dev server performs a hot reload due to code changes
2. WASM compilation completes
3. The app needs to re-hydrate

When tests interact with the app while this overlay is present, interactions fail silently.

## Immediate Fixes Needed

### 1. Update waitForNoRebuildOverlay in helpers.ts

Current code is insufficient. Add proper polling:

```typescript
export async function waitForNoRebuildOverlay(page: Page) {
  const rebuilding = page.getByRole("heading", {
    name: "Your app is being rebuilt.",
  });
  // Poll with longer timeout - Dioxus rebuilds can take time
  await expect.poll(
    async () => {
      const count = await rebuilding.count();
      return count === 0;
    }, 
    { timeout: 60_000 }
  ).toBe(true);
}
```

### 2. Add waitBetweenOperations helper

```typescript
export async function waitBetweenOperations(page: Page) {
  await waitForNoRebuildOverlay(page);
  await page.waitForTimeout(100);  // Small buffer for signal propagation
}
```

### 3. Update createTextNode to wait properly

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
    () => page.locator('[data-testid="tool-text"]').first().waitFor({ state: "visible" }),
  ]);
  
  const box = await runEffect(() => canvas.boundingBox());
  if (!box) {
    throw new Error("canvas bounding box not available");
  }
  
  await runEffect(() => page.mouse.click(box.x + x, box.y + y));
  
  // Wait for the node to be created and app to stabilize
  await waitForNoRebuildOverlay(page);
}
```

### 4. Update rq-fixtures.ts importScene

```typescript
async function importScene(page: Page, sceneName: SceneName): Promise<void> {
  await recoverFromRebuildOverlay(page);

  const cwdPath = resolve(process.cwd(), "diagram_tool", "e2e", "scenes", `${sceneName}.json`);
  const fixtureRelativePath = resolve(__dirname, "..", "scenes", `${sceneName}.json`);
  const filePath = existsSync(cwdPath) ? cwdPath : fixtureRelativePath;
  const payload = readFileSync(filePath, "utf8");
  parseAndValidateScenePayload(sceneName, payload);
  const contract = sceneContracts[sceneName];
  
  await runEffectsSequential([
    () => waitForUiReady(page),
    () => page.waitForTimeout(1000),
    () => page.evaluate((jsonPayload) => {
      (window as { __SESHAT_E2E_IMPORT_JSON?: string }).__SESHAT_E2E_IMPORT_JSON = jsonPayload;
    }, payload),
    () => expect(page.getByTestId("toolbar-open")).toBeEnabled({ timeout: 15_000 }),
    () => page.getByTestId("toolbar-open").click(),
    // CRITICAL: Wait for import to process
    () => page.waitForTimeout(3000),  // Increase from 2000
    () => waitForNoRebuildOverlay(page),  // Add this
    () => page.waitForTimeout(1000),  // Additional buffer
  ]);

  await expect.poll(() => nodeCount(page), { timeout: 15_000 }).toBe(contract.nodeCount);
  await expect.poll(() => edgeCount(page), { timeout: 15_000 }).toBe(contract.edgeCount);
}
```

### 5. Add recoverFromRebuildOverlay helper

```typescript
async function recoverFromRebuildOverlay(page: Page): Promise<void> {
  const rebuilding = page.getByRole("heading", { name: "Your app is being rebuilt." });
  const visible = await runEffect(() => rebuilding.isVisible().catch(() => false));
  if (!visible) {
    return;
  }
  // Wait for rebuild to complete
  await expect.poll(
    async () => {
      const isVisible = await rebuilding.isVisible().catch(() => false);
      return !isVisible;
    },
    { timeout: 120_000 }  // Allow up to 2 minutes for rebuild
  ).toBe(true);
}
```

### 6. Update all test files to use proper waiting

Each test should start with:

```typescript
test("my test @baseline", async ({ page }) => {
  await runEffectsSequential([
    () => page.goto("/"),
    () => waitForUiReady(page),
  ]);
  
  // Now safe to interact
  const canvas = page.getByTestId("canvas-root");
  // ...
});
```

## Moon Configuration

Ensure e2e tests use non-hot-reload mode:

```yaml
# moon.yml
serve-e2e:
  script: |
    dx serve --platform web --port 8082 --open false --watch false --hot-reload false --interactive false
  options:
    cache: false
```

## Test Patterns to Avoid

1. **Don't use page.waitForTimeout exclusively** - Use polling instead
2. **Don't assume node creation is instant** - Wait for rebuild
3. **Don't skip waitForNoRebuildOverlay** - Always call it before interactions
4. **Don't use expect without polling for dynamic content** - Use expect.poll

## Recommended Test Structure

```typescript
import { test } from "./fixtures/rq-fixtures";
import { 
  waitForNoRebuildOverlay, 
  waitForUiReady,
  expectNodeCount,
  // ...
} from "./helpers";

test.describe("feature name", () => {
  test("test description @baseline", async ({ page }) => {
    // 1. Start with clean state
    await runEffectsSequential([
      () => page.goto("/"),
      () => waitForUiReady(page),
    ]);
    
    // 2. Perform actions with proper waiting
    const canvas = page.getByTestId("canvas-root");
    
    await createTextNode(page, canvas, 100, 100);
    await waitForNoRebuildOverlay(page);  // Wait between operations
    
    await createTextNode(page, canvas, 200, 200);
    await waitForNoRebuildOverlay(page);
    
    // 3. Use auto-retrying assertions
    await expectNodeCount(page, 2);
    
    // 4. Verify other state
    // ...
  });
});
```
