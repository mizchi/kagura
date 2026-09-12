import { test, expect } from '@playwright/test';
import { PNG } from 'pngjs';
import { captureGameFrame } from '../../../../scripts/capture-web.mjs';

test('goblin, kobold and skeleton silhouettes are rendered on desktop and portrait screens', async ({ page }, testInfo) => {
  for (const viewport of [{width:1280,height:900}, {width:390,height:844}]) {
    await page.setViewportSize(viewport);
    await page.goto('/?snapshot=playing&frames=0&mute=1&seed=42');
    await page.waitForFunction(() => globalThis.__ashenHunt?.bones === 14);
    const body = await captureGameFrame(page, {path:testInfo.outputPath(`enemies-${viewport.width}.png`)});
    const png = PNG.sync.read(body);
    // Actual lit materials, excluding HUD bars and buttons. All three species
    // must be visible; a runtime enemy count cannot catch missing GPU geometry.
    const pixels = {goblin:0, kobold:0, skeleton:0};
    for (let y=Math.floor(png.height*.16); y<png.height*.68; y++) {
      for (let x=Math.floor(png.width*.1); x<png.width*.9; x++) {
        const i=(y*png.width+x)*4;
        const [r,g,b]=png.data.subarray(i,i+3);
        if (r>110 && g>r*1.03 && r>b*1.02 && g<r*1.3) pixels.goblin++;
        if (r>85 && r>g*1.15 && g>b*1.15) pixels.kobold++;
        if (r>145 && g>145 && b>120 && Math.abs(r-g)<20 && r>=b && g-b<50) pixels.skeleton++;
      }
    }
    for (const [species, count] of Object.entries(pixels)) {
      expect(count, `${species} is visible at ${viewport.width}px`).toBeGreaterThan(viewport.width>600 ? 200 : 60);
    }
  }
});
