import { test, expect } from '@playwright/test';
import { PNG } from 'pngjs';
import { captureGameFrame } from '../../../../scripts/capture-web.mjs';

test('opening monsters are visibly rendered in desktop and portrait playfields', async ({ page }, testInfo) => {
  for (const viewport of [{width:1280,height:900}, {width:390,height:844}]) {
    await page.setViewportSize(viewport);
    await page.goto('/?snapshot=playing&frames=0&mute=1&seed=42');
    await page.waitForFunction(() => globalThis.__ashenHunt?.bones === 14);
    const body = await captureGameFrame(page, {path:testInfo.outputPath(`enemies-${viewport.width}.png`)});
    const png = PNG.sync.read(body);
    // Check the actual monster-colored geometry, excluding the HUD/health bar.
    let monsterPixels = 0;
    for (let y=Math.floor(png.height*.16); y<png.height*.68; y++) {
      for (let x=Math.floor(png.width*.1); x<png.width*.9; x++) {
        const i=(y*png.width+x)*4;
        const [r,g,b]=png.data.subarray(i,i+3);
        if (r>70 && r>g*1.3 && r>b*1.15) monsterPixels++;
      }
    }
    expect(monsterPixels, `visible monster silhouettes at ${viewport.width}px`).toBeGreaterThan(viewport.width>600 ? 700 : 200);
  }
});
