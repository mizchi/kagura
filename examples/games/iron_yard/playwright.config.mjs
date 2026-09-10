import {defineConfig} from '@playwright/test';
const metal = process.env.IRON_YARD_GPU === 'metal';
const port = metal ? 5195 : 5193;
export default defineConfig({
  // Software rasterization also compiles the full PBR/PCF shaders on the CPU.
  testDir:'./e2e', timeout:metal?45000:90000, expect:{timeout:metal?5000:15000}, workers:1,
  outputDir:`../../../test-results/iron-yard-${metal ? 'metal' : 'swiftshader'}`,
  use:{
    baseURL:`http://127.0.0.1:${port}`, viewport:{width:1280,height:800},
    ...(metal ? {channel:'chrome',headless:process.env.IRON_YARD_HEADED !== '1',deviceScaleFactor:2} : {}),
    launchOptions:{args:metal
      ? ['--enable-unsafe-webgpu','--enable-gpu','--use-angle=metal']
      : ['--enable-unsafe-webgpu','--use-angle=swiftshader','--enable-unsafe-swiftshader']},
    screenshot:'only-on-failure',
  },
  webServer:{
    command:`node ../../../node_modules/vite/bin/vite.js preview --config vite.config.mjs --port ${port}`,
    url:`http://127.0.0.1:${port}`,reuseExistingServer:false,
  },
});
