import { mkdir } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { parseArgs } from 'node:util';

/**
 * Capture only the surface declared by Kagura's presentation contract, including
 * the in-game HUD but excluding page chrome and letterboxing. Never falls back to
 * a full-page screenshot when the engine has not initialized.
 * @param {import('@playwright/test').Page} page
 * @param {{path?: string, timeout?: number}} options
 * @returns {Promise<Buffer>}
 */
export async function captureGameFrame(page, { path, timeout = 30_000 } = {}) {
  await page.waitForFunction(() => {
    const presentation = globalThis.__kaguraPresentation;
    return presentation?.version === 1 && presentation.captureTarget().renderedFrames > 0;
  }, null, { timeout });
  await page.evaluate(async () => {
    await globalThis.__kaguraWebRuntime.webgpu.device.queue.onSubmittedWorkDone();
  });
  const target = await page.evaluate(() => globalThis.__kaguraPresentation.captureTarget());
  const surface = page.locator(target.selector);
  if (await surface.count() !== 1) throw new Error('Kagura capture requires exactly one game surface');
  return surface.screenshot({ path, timeout, scale: 'css',
    style: `${target.hideSelector} { visibility: hidden !important; }` });
}

async function main() {
  const { values } = parseArgs({ options: {
    url: { type: 'string', default: 'http://localhost:8080/' },
    output: { type: 'string', default: 'output/game.png' },
    width: { type: 'string', default: '1600' },
    height: { type: 'string', default: '900' },
    headed: { type: 'boolean', default: false },
  } });
  const viewport = { width: Number(values.width), height: Number(values.height) };
  if (!Object.values(viewport).every(value => Number.isSafeInteger(value) && value > 0)) {
    throw new RangeError('Capture width and height must be positive integers');
  }
  const { chromium } = await import('@playwright/test');
  const metal = process.platform === 'darwin';
  const browser = await chromium.launch({ headless: !values.headed,
    ...(metal ? { channel: 'chrome' } : {}),
    args: metal ? ['--enable-unsafe-webgpu', '--enable-gpu', '--use-angle=metal']
      : ['--enable-unsafe-webgpu', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'],
  });
  try {
    const page = await browser.newPage({ viewport, deviceScaleFactor: 1 });
    await page.goto(values.url);
    const path = resolve(values.output);
    await mkdir(dirname(path), { recursive: true });
    await captureGameFrame(page, { path });
    console.log(path);
  } finally {
    await browser.close();
  }
}

if (process.argv[1] && resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  main().catch(error => { console.error(error); process.exitCode = 1; });
}
