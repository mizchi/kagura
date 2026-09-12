import {mkdirSync, writeFileSync} from 'node:fs';
import {resolve} from 'node:path';
import {pathToFileURL} from 'node:url';
import {parseArgs} from 'node:util';
import {chromium} from '@playwright/test';
import {mapCdpPerformanceMetrics, summarizeNumericSamples} from './web-performance-utils.mjs';

export function cpuPerFrame(before, after, frames) {
  if (!Number.isInteger(frames) || frames <= 0) throw new RangeError('No rendered frames');
  return Object.fromEntries(['TaskDuration','ScriptDuration','LayoutDuration','RecalcStyleDuration'].map(key => [key,
    Number.isFinite(before[key]) && Number.isFinite(after[key])
      ? Math.max(0, after[key] - before[key]) * 1000 / frames : null]));
}

export function summarizeCpuProfile(profile) {
  const times = new Map();
  (profile.samples ?? []).forEach((id, i) => times.set(id, (times.get(id) ?? 0) + (profile.timeDeltas[i] ?? 0)));
  const functions = new Map();
  for (const node of profile.nodes) {
    const {functionName, url, lineNumber} = node.callFrame;
    const key = JSON.stringify([url,lineNumber,functionName]);
    const entry = functions.get(key) ?? {name:functionName, url, line:lineNumber + 1, selfMs:0};
    entry.selfMs += (times.get(node.id) ?? 0) / 1000;
    functions.set(key, entry);
  }
  return [...functions.values()].sort((a,b) => b.selfMs - a.selfMs).slice(0,25);
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
  prepare = async () => {}, metadata = {}}) {
  const target = new URL(url).toString();
  const directory = resolve(outDir);
  mkdirSync(directory, {recursive:true});
  const metal = process.platform === 'darwin';
  const browser = await chromium.launch({headless:true,
    ...(metal ? {channel:'chrome'} : {}),
    args:metal ? ['--enable-unsafe-webgpu','--enable-gpu','--use-angle=metal']
      : ['--enable-unsafe-webgpu','--use-angle=swiftshader','--enable-unsafe-swiftshader'],
  });
  try {
    const page = await browser.newPage({viewport});
    const errors = [];
    page.on('pageerror', error => errors.push(String(error)));
    await page.goto(target);
    await page.waitForFunction(() => globalThis.__kaguraProfiler?.snapshot()?.frame > 20);
    await prepare(page);
    await page.waitForTimeout(1000);
    const session = await page.context().newCDPSession(page);
    const measured = await measureWebPage(page, session, {samples, profileMs});
    const {profile, samples:frameSamples, ...stats} = measured;
    const summary = {version:1, url:target, browser:await browser.version(),
      gpuBackendRequest:metal ? 'Metal' : 'SwiftShader', viewport, metadata,
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

if (process.argv[1] && import.meta.url === pathToFileURL(resolve(process.argv[1])).href) {
  const {values} = parseArgs({options:{
    url:{type:'string',default:'http://localhost:8080/'},
    'out-dir':{type:'string'}, samples:{type:'string',default:'240'},
    width:{type:'string',default:'1280'}, height:{type:'string',default:'900'},
  }});
  await profileWeb({url:values.url, outDir:values['out-dir'], samples:Number(values.samples),
    viewport:{width:Number(values.width),height:Number(values.height)}});
}
