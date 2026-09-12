import {mkdirSync, writeFileSync} from 'node:fs';
import {resolve} from 'node:path';
import {parseArgs} from 'node:util';
import {chromium} from '@playwright/test';
import {mapCdpPerformanceMetrics, summarizeNumericSamples} from './hacknslash_3d_gpu_perf_utils.mjs';

const {values} = parseArgs({options:{
  url:{type:'string', default:'http://localhost:8080/'},
  'out-dir':{type:'string', default:`output/cpu/${Date.now()}`},
  moving:{type:'boolean', default:false},
}});
const url = new URL(values.url);
for (const [key, value] of Object.entries({snapshot:'playing', frames:'0', mute:'1', perf:'1', seed:'42'})) {
  url.searchParams.set(key, value);
}
const outDir = resolve(values['out-dir']);
mkdirSync(outDir, {recursive:true});
const metal = process.platform === 'darwin';
const browser = await chromium.launch({
  headless:true,
  ...(metal ? {channel:'chrome'} : {}),
  args:metal
    ? ['--enable-unsafe-webgpu', '--enable-gpu', '--use-angle=metal']
    : ['--enable-unsafe-webgpu', '--use-angle=swiftshader', '--enable-unsafe-swiftshader'],
});
try {
  const page = await browser.newPage({viewport:{width:1280, height:900}});
  const session = await page.context().newCDPSession(page);
  const errors = [];
  page.on('pageerror', error => errors.push(String(error)));
  await session.send('Performance.enable');
  const metrics = async () => mapCdpPerformanceMetrics((await session.send('Performance.getMetrics')).metrics);
  await page.goto(url.toString());
  await page.waitForFunction(() => globalThis.__hacknslash3dProfile?.worldFrame > 20);
  if (values.moving) await page.keyboard.down('KeyD');
  else await page.keyboard.press('KeyP');
  await page.waitForTimeout(1000);

  // Measure frame costs WITHOUT the CPU sampler. Pausing preserves the scene
  // while rendering still runs; --moving includes simulation and chunk changes.
  const before = await metrics();
  const samples = await page.evaluate(() => new Promise((resolve, reject) => {
    const samples = [];
    const timeout = setTimeout(() => reject(new Error('Frame sampling timed out')), 30000);
    let last = performance.now();
    function tick(now) {
      samples.push({...globalThis.__hacknslash3dProfile, rafMs:now - last});
      last = now;
      if (samples.length === 240) {
        clearTimeout(timeout);
        resolve(samples);
      } else requestAnimationFrame(tick);
    }
    requestAnimationFrame(tick);
  }));
  const after = await metrics();
  const runtime = await page.evaluate(() => globalThis.__hacknslash3dRuntime);

  // A separate sample identifies hot call stacks. Chrome DevTools can open it.
  await session.send('Profiler.enable');
  await session.send('Profiler.setSamplingInterval', {interval:500});
  await session.send('Profiler.start');
  await page.waitForTimeout(4000);
  const {profile} = await session.send('Profiler.stop');
  const times = new Map();
  profile.samples.forEach((id, i) => times.set(id, (times.get(id) ?? 0) + profile.timeDeltas[i]));
  const functions = new Map();
  for (const node of profile.nodes) {
    const {functionName, url, lineNumber} = node.callFrame;
    const key = `${url}:${lineNumber}:${functionName}`;
    const entry = functions.get(key) ?? {name:functionName, url, line:lineNumber + 1, selfMs:0};
    entry.selfMs += (times.get(node.id) ?? 0) / 1000;
    functions.set(key, entry);
  }
  const summary = {
    url:url.toString(),
    mode:values.moving ? 'physical KeyD held' : 'paused scene; rendering active',
    browser:await browser.version(), viewport:{width:1280, height:900},
    samples:samples.length,
    cpuMsPerFrame:Object.fromEntries(['TaskDuration', 'ScriptDuration', 'LayoutDuration', 'RecalcStyleDuration']
      .map(key => [key, (after[key] - before[key]) * 1000 / samples.length])),
    timings:Object.fromEntries(['rafMs', 'updateMs', 'drawCallbackMs', 'renderCommandsMs', 'gpuFrameMs']
      .map(key => [key, summarizeNumericSamples(samples.map(sample => sample[key]))])),
    runtime, errors,
    hot:[...functions.values()].sort((a,b) => b.selfMs - a.selfMs).slice(0,25),
  };
  writeFileSync(resolve(outDir, 'profile.cpuprofile'), JSON.stringify(profile));
  writeFileSync(resolve(outDir, 'samples.json'), JSON.stringify(samples));
  writeFileSync(resolve(outDir, 'summary.json'), JSON.stringify(summary, null, 2));
  console.log(JSON.stringify({outDir, mode:summary.mode, cpuMsPerFrame:summary.cpuMsPerFrame, errors}, null, 2));
  if (errors.length) process.exitCode = 1;
} finally {
  await browser.close();
}
