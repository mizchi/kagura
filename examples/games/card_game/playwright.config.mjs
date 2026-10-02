import { defineConfig } from '@playwright/test';
const port = Number(process.env.CARD_GAME_PORT ?? 5196);
export default defineConfig({
  testDir: './e2e', workers: 1, timeout: 45000,
  outputDir: '../../../test-results/card-game',
  use: {
    baseURL: `http://127.0.0.1:${port}`, headless: true,
    viewport: { width: 1280, height: 900 },
    launchOptions: { args: ['--enable-unsafe-webgpu', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'] },
    screenshot: 'only-on-failure',
  },
  webServer: {
    command: `PORT=${port} node ../../../scripts/dev-server.mjs card_game`,
    url: `http://127.0.0.1:${port}`, reuseExistingServer: !process.env.CI,
    timeout: 120000,
  },
});
