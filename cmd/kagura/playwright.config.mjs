import {defineConfig} from '@playwright/test';
const metal = process.platform === 'darwin';
export default defineConfig({
  testDir: './e2e', workers: 1, timeout: 240_000,
  outputDir: '../../test-results/kagura-cli',
  use: {
    ...(metal ? {channel: 'chrome'} : {}),
    launchOptions: {args: metal ? ['--enable-unsafe-webgpu', '--enable-gpu', '--use-angle=metal']
      : ['--enable-unsafe-webgpu', '--use-angle=swiftshader', '--enable-unsafe-swiftshader']},
  },
});
