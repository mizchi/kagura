import { defineConfig } from '@playwright/test';
const metal = process.platform === 'darwin';
export default defineConfig({
  testDir: './e2e', timeout: 45_000, workers: 1,
  outputDir: '../../../test-results/ashen-hunt',
  use: { baseURL: 'http://127.0.0.1:8081', viewport: {width:1280,height:900},
    ...(metal ? {channel:'chrome'} : {}),
    launchOptions: {args:metal ? ['--enable-unsafe-webgpu','--enable-gpu','--use-angle=metal'] : ['--enable-unsafe-webgpu','--use-angle=swiftshader','--enable-unsafe-swiftshader']}, screenshot:'off', trace:{mode:'retain-on-failure',screenshots:false} },
  webServer: {command:'moon -C examples/games/hacknslash_3d build --target js && PORT=8081 just hunter-dev',
    cwd: new URL('../../../',import.meta.url).pathname, url:'http://127.0.0.1:8081', timeout:120_000},
});
