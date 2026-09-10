import { defineConfig } from '@playwright/test';
export default defineConfig({
  testDir: './e2e', fullyParallel: true,
  use: { baseURL: 'http://127.0.0.1:5191', viewport: { width: 1440, height: 1000 },
    launchOptions: { args: ['--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'] } },
  webServer: { command: `pnpm exec vite ${process.env.STUDIO_PREVIEW === '1' ? 'preview ' : ''}--host 127.0.0.1 --port 5191 --strictPort`, url: 'http://127.0.0.1:5191' },
});
