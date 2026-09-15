import { defineConfig } from "@playwright/test";
const metal = process.env.EMBERWING_GPU === "metal";
const port = Number(process.env.EMBERWING_PORT || 5194);
export default defineConfig({
  testDir: "./e2e", workers: 1, timeout: 45000,
  outputDir: "../../../test-results/emberwing",
  use: {
    baseURL: `http://localhost:${port}`, viewport: { width: 1440, height: 900 },
    ...(metal ? { channel: "chrome" } : {}),
    launchOptions: { args: metal
      ? ["--enable-unsafe-webgpu", "--enable-gpu", "--use-angle=metal"]
      : ["--enable-unsafe-webgpu", "--use-angle=swiftshader", "--enable-unsafe-swiftshader"] },
    screenshot: "only-on-failure",
  },
  webServer: {
    command: `node ../../../cmd/kagura/main.mjs dev emberwing --port ${port}`,
    url: `http://localhost:${port}`, reuseExistingServer: !process.env.CI,
  },
});
