import { defineConfig } from "@playwright/test";

export default defineConfig({
  testDir: ".",
  testMatch: "session.spec.ts",
  workers: 1,
  use: {
    baseURL: "http://127.0.0.1:15475",
    headless: true,
    launchOptions: { args: ["--enable-unsafe-webgpu"] },
  },
  webServer: {
    command: "node scripts/dev-server.mjs ui_demo",
    cwd: "../..",
    env: { PORT: "15475" },
    url: "http://127.0.0.1:15475",
    timeout: 120000,
  },
});
