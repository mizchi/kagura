import { expect, test } from "@playwright/test";

const EXPECTED_OUTPUT = "runtime_smoke(js): ok (hooked)";

const CASES = [
  {
    name: "runtime_smoke wasm target",
    path: "/e2e/fixtures/runtime_smoke_wasm.html",
  },
  {
    name: "runtime_smoke wasm-gc target",
    path: "/e2e/fixtures/runtime_smoke_wasm_gc.html",
  },
] as const;

for (const item of CASES) {
  test(item.name, async ({ page }) => {
    await page.goto(item.path);
    await page.waitForFunction(() => {
      return Boolean((window as { __wasmSmoke?: { status?: string } }).__wasmSmoke?.status);
    });
    const result = await page.evaluate(() => {
      return (window as { __wasmSmoke?: { status: string; output: string } }).__wasmSmoke;
    });
    expect(result?.status).toBe("ok");
    expect(result?.output).toContain(EXPECTED_OUTPUT);
  });
}
