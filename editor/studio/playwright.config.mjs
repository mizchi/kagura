import { defineConfig } from '@playwright/test';
const metal = process.env.STUDIO_GPU === 'metal';
export default defineConfig({
  testDir: './e2e', fullyParallel: true,
  use: { baseURL: 'http://127.0.0.1:5191', viewport: { width: 1440, height: 1000 },
    ...(metal ? { channel: 'chrome', headless: true } : {}),
    launchOptions: { args: metal ? ['--enable-unsafe-webgpu', '--enable-gpu', '--use-angle=metal'] : ['--enable-unsafe-webgpu', '--use-gl=angle', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'] } },
  webServer: { command: `pnpm exec vite ${process.env.STUDIO_PREVIEW === '1' ? 'preview ' : ''}--host 127.0.0.1 --port 5191 --strictPort`, url: 'http://127.0.0.1:5191' },
});
