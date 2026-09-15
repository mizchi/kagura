import {mkdirSync, writeFileSync} from 'node:fs';
import {dirname, resolve} from 'node:path';
import {createRequire} from 'node:module';
import {pathToFileURL} from 'node:url';
import {cpuPerFrame, mapCdpPerformanceMetrics, summarizeNumericSamples, summarizeCpuProfile} from './performance.mjs';

/** Resolve the optional tool from the caller's project, also for moon install. */
export async function loadChromium(dependencyRoot = process.cwd()) {
  const require = createRequire(resolve(dependencyRoot, 'package.json'));
  for (const name of ['@playwright/test', 'playwright']) {
    let entry;
    try { entry = require.resolve(name); }
    catch (error) { if (error.code === 'MODULE_NOT_FOUND') continue; throw error; }
    const module = await import(pathToFileURL(entry));
    const chromium = module.chromium ?? module.default?.chromium;
    if (chromium) return chromium;
    throw new Error(`${name} does not export chromium`);
  }
  throw new Error('Browser tools require Playwright in the calling project. Run: pnpm add -D @playwright/test; pnpm exec playwright install chromium');
}

export function validateBrowserOptions({url, viewport, samples = 240, profileMs = 4000, timeout = 30000, warmupMs = 1000}) {
  const target = new URL(url);
  if (!['http:', 'https:'].includes(target.protocol)) throw new Error('URL must use http:// or https://');
  for (const [name, value, min, max] of [
    ['width', viewport?.width, 1, 16384], ['height', viewport?.height, 1, 16384],
    ['samples', samples, 1, 3600], ['profileMs', profileMs, 1, 60000],
    ['timeout', timeout, 1, 300000], ['warmupMs', warmupMs, 0, 60000],
  ]) if (!Number.isInteger(value) || value < min || value > max) throw new RangeError(`${name} must be ${min}..${max}`);
  return target.toString();
}

async function launchBrowser({headed = false, dependencyRoot} = {}) {
  const chromium = await loadChromium(dependencyRoot);
  const metal = process.platform === 'darwin';
  const executablePath = process.env.KAGURA_PLAYWRIGHT_CHROMIUM_PATH;
  return chromium.launch({headless: !headed,
    ...(executablePath ? {executablePath} : metal ? {channel: 'chrome'} : {}),
    args: [...(metal ? ['--enable-unsafe-webgpu', '--enable-gpu', '--use-angle=metal']
      : ['--enable-unsafe-webgpu', '--use-angle=swiftshader', '--enable-unsafe-swiftshader']),
      ...(process.env.KAGURA_PLAYWRIGHT_CHROMIUM_ARGS ?? '').split(/\s+/).filter(Boolean)],
  });
}

export async function captureWeb({url = 'http://localhost:8080/', output = 'output/game.png',
  viewport = {width:1600,height:900}, headed = false, timeout = 30000, dependencyRoot = process.cwd()}) {
  const target = validateBrowserOptions({url, viewport, timeout});
  const browser = await launchBrowser({headed, dependencyRoot});
  try {
    const page = await browser.newPage({viewport, deviceScaleFactor:1});
    const errors = [];
    page.on('pageerror', error => errors.push(String(error)));
    page.setDefaultTimeout(timeout);
    page.setDefaultNavigationTimeout(timeout);
    await page.goto(target);
    const image = await captureGameFrame(page, {timeout});
    if (errors.length) throw new Error(`Page errors during capture: ${errors.join('; ')}`);
    const path = resolve(output);
    mkdirSync(dirname(path), {recursive:true});
    writeFileSync(path, image);
    console.log(path);
    return path;
  } finally { await browser.close(); }
}

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


/** Measures submitted frames; duplicate RAF observations are skipped. */
export async function measureWebPage(page, session, {samples = 240, profileMs = 4000} = {}) {
  if (!Number.isInteger(samples) || samples < 1 || samples > 3600) throw new RangeError('samples must be 1..3600');
  if (!Number.isInteger(profileMs) || profileMs < 1 || profileMs > 60000) throw new RangeError('profileMs must be 1..60000');
  await session.send('Performance.enable');
  const metrics = async () => mapCdpPerformanceMetrics((await session.send('Performance.getMetrics')).metrics);
  const before = await metrics();
  const frames = await page.evaluate(({sampleCount}) => new Promise((resolve, reject) => {
    const profiler = globalThis.__kaguraProfiler;
    if (profiler?.version !== 1) return reject(new Error('Kagura profiler version 1 is required'));
    const startFrame = profiler.snapshot()?.frame;
    if (!Number.isInteger(startFrame)) return reject(new Error('No active Kagura GPU runtime'));
    const samples = [];
    let lastFrame = startFrame, lastTime = performance.now(), request;
    const timeout = setTimeout(() => {
      cancelAnimationFrame(request);
      reject(new Error(`Frame sampling timed out after ${samples.length} samples`));
    }, Math.max(30000, sampleCount * 100));
    function tick(now) {
      const frame = profiler.snapshot();
      if (!frame || frame.frame < lastFrame) {
        clearTimeout(timeout);
        reject(new Error('GPU runtime was replaced during measurement'));
        return;
      }
      if (frame.frame > lastFrame) {
        samples.push({...frame, rafMs:now - lastTime, frameDelta:frame.frame - lastFrame});
        lastFrame = frame.frame;
        lastTime = now;
        if (samples.length === sampleCount) {
          clearTimeout(timeout);
          resolve({samples, renderedFrames:lastFrame - startFrame});
          return;
        }
      }
      request = requestAnimationFrame(tick);
    }
    request = requestAnimationFrame(tick);
  }), {sampleCount:samples});
  const after = await metrics();
  // CPU sampling must start AFTER the frame-cost measurement.
  await session.send('Profiler.enable');
  await session.send('Profiler.setSamplingInterval', {interval:500});
  await session.send('Profiler.start');
  let profile;
  try {
    await page.waitForTimeout(profileMs);
  } finally {
    ({profile} = await session.send('Profiler.stop'));
  }
  const keys = [...new Set(frames.samples.flatMap(sample => Object.keys(sample).filter(key => key.endsWith('Ms'))))];
  const timings = Object.fromEntries(keys.map(key => {
    const values = frames.samples.map(sample => sample[key]).filter(Number.isFinite);
    return [key, values.length ? summarizeNumericSamples(values) : null];
  }));
  return {samples:frames.samples, renderedFrames:frames.renderedFrames,
    cpuMsPerFrame:cpuPerFrame(before, after, frames.renderedFrames), timings, profile,
    hot:summarizeCpuProfile(profile)};
}

/** Game adapters own only URL/scenario setup; all measurement stays here. */
export async function profileWeb({url, outDir = `output/cpu/${Date.now()}`,
  viewport = {width:1280,height:900}, samples = 240, profileMs = 4000,
  prepare = async () => {}, metadata = {}, headed = false, timeout = 30000, warmupMs = 1000, dependencyRoot = process.cwd()}) {
  const target = validateBrowserOptions({url, viewport, samples, profileMs, timeout, warmupMs});
  const directory = resolve(outDir);
  mkdirSync(directory, {recursive:true});
  const browser = await launchBrowser({headed, dependencyRoot});
  try {
    const page = await browser.newPage({viewport});
    const errors = [];
    page.on('pageerror', error => errors.push(String(error)));
    page.setDefaultTimeout(timeout);
    page.setDefaultNavigationTimeout(timeout);
    await page.goto(target);
    await page.waitForFunction(() => globalThis.__kaguraProfiler?.snapshot()?.frame > 20);
    await prepare(page);
    await page.waitForTimeout(warmupMs);
    const session = await page.context().newCDPSession(page);
    const measured = await measureWebPage(page, session, {samples, profileMs});
    const {profile, samples:frameSamples, ...stats} = measured;
    const summary = {version:1, url:target, browser:await browser.version(),
      gpuBackendRequest:process.platform === 'darwin' ? 'Metal' : 'SwiftShader', viewport, metadata,
      sampleCount:frameSamples.length, profileMs, ...stats, errors};
    writeFileSync(resolve(directory,'profile.cpuprofile'), JSON.stringify(profile));
    writeFileSync(resolve(directory,'samples.json'), JSON.stringify(frameSamples));
    writeFileSync(resolve(directory,'summary.json'), JSON.stringify(summary,null,2));
    console.log(JSON.stringify({outDir:directory, cpuMsPerFrame:summary.cpuMsPerFrame, errors},null,2));
    if (errors.length) throw new Error(`Page errors during profile: ${errors.join('; ')}`);
    return summary;
  } finally {
    await browser.close();
  }
}
