import { defineConfig } from "@playwright/test";

const e2ePort = Number.parseInt(process.env.PORT ?? "4173", 10);
const e2eBaseURL = `http://127.0.0.1:${e2ePort}`;
const chromiumArgs = [
  "--enable-unsafe-webgpu",
  // Headless Linux CI has no GPU; without a software adapter the WebGPU
  // adapter is null and the runtime smoke harness reports status "failed".
  // SwiftShader provides a software WebGPU/GL backend so the adapter resolves.
  "--enable-unsafe-swiftshader",
  "--use-gl=angle",
  "--use-angle=swiftshader",
  ...(process.env.KAGURA_PLAYWRIGHT_CHROMIUM_ARGS ?? "").split(/\s+/).filter(Boolean),
];

export default defineConfig({
  testDir: "./e2e",
  timeout: 30_000,
  retries: process.env.CI ? 2 : 0,
  use: {
    baseURL: e2eBaseURL,
    browserName: "chromium",
    headless: true,
    launchOptions: {
      args: chromiumArgs,
    },
  },
  webServer: {
    command: `PORT=${e2ePort} node scripts/serve-wasm-smoke.mjs`,
    url: `${e2eBaseURL}/healthz`,
    timeout: 120_000,
    reuseExistingServer: process.env.PLAYWRIGHT_REUSE_SERVER === "1",
  },
});
