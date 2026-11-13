import {defineConfig} from '@playwright/test';
const port = Number(process.env.DUNGEON_RPG_PORT || 5198);
export default defineConfig({
  testDir: './e2e', workers: 1, timeout: 90000,
  outputDir: '../../../test-results/dungeon_rpg',
  use: {
    baseURL: `http://localhost:${port}`, viewport: {width:1280,height:800},
    launchOptions: {args:['--enable-unsafe-webgpu','--use-angle=swiftshader','--enable-unsafe-swiftshader']},
    screenshot: 'only-on-failure',
  },
  webServer: {
    command: `PORT=${port} node ../../../scripts/dev-server.mjs .`,
    url: `http://localhost:${port}`,reuseExistingServer: !process.env.CI,
  },
});
