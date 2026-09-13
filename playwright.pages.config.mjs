import { defineConfig } from '@playwright/test';

const metal = process.platform === 'darwin';
export default defineConfig({
  testDir: './e2e',
  testMatch: 'pages.spec.ts',
  timeout: 60_000,
  workers: 1,
  outputDir: 'test-results/pages',
  use: {
    baseURL: process.env.KAGURA_PAGES_URL ?? 'http://127.0.0.1:8082/kagura/',
    viewport: {width: 1280, height: 900},
    ...(metal ? {channel: 'chrome'} : {}),
    launchOptions: {args: metal
      ? ['--enable-unsafe-webgpu', '--enable-gpu', '--use-angle=metal']
      : ['--enable-unsafe-webgpu', '--use-angle=swiftshader', '--enable-unsafe-swiftshader']},
    trace: {mode: 'retain-on-failure', screenshots: false},
  },
});
