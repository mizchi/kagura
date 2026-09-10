// Isolated Chrome/Metal, headless by default for background profiling.
// CPU/allocation profiling is separate from FPS
// measurement so profiler overhead is not counted as application frame time.
import {chromium, expect} from '@playwright/test';
import {mkdir, writeFile} from 'node:fs/promises';
import {resolve} from 'node:path';

const args = process.argv.slice(2);
const option = (name, fallback) => args.find(a => a.startsWith(`--${name}=`))?.slice(name.length+3) ?? fallback;
const out = resolve(option('out', 'test-results/iron-yard-profile'));
const duration = Number(option('seconds', '10')) * 1000;
const repeats = Number(option('repeats', '3'));
const scenario = option('scenario', 'idle');
const profiles = option('profiles', 'true') === 'true';
const headless = option('headed', 'false') !== 'true';
if (!Number.isFinite(duration) || duration <= 0 || !Number.isSafeInteger(repeats) || repeats < 1) throw Error('Positive seconds and repeats required');
if (!['idle','strafe'].includes(scenario)) throw Error('Scenario must be idle or strafe');
const targets = args.filter(a => !a.startsWith('--')).map(a => {
  const i = a.indexOf('=');
  if (i < 1 || !/^[\w-]+$/.test(a.slice(0,i))) throw Error('Target must be name=http://...');
  return [a.slice(0,i), a.slice(i+1)];
});
if (!targets.length) throw Error('Specify kagura=URL and/or three=URL');
await mkdir(out, {recursive:true});
const browser = await chromium.launch({channel:'chrome', headless,
  args:['--enable-unsafe-webgpu','--enable-gpu','--use-angle=metal']});
const results = [];
try {
  for (const [name, url] of targets) {
    const context = await browser.newContext({viewport:{width:1280,height:800},deviceScaleFactor:2});
    const page = await context.newPage();
    const errors=[];
    page.on('pageerror', e=>errors.push(e.message));
    await page.addInitScript(()=>{Element.prototype.requestPointerLock=async()=>{throw Error('Benchmark RMB fallback');};});
    const cdp = await context.newCDPSession(page);
    await cdp.send('Performance.enable');
    await cdp.send('HeapProfiler.enable');
    await page.goto(url);
    // Selecting a mode before MoonBit finishes loading silently drops reset().
    // Wait for readiness, then verify the simulation, not only the select value.
    await expect(page.getByRole('button',{name:'出撃する'})).toBeEnabled({timeout:60000});
    await page.getByRole('combobox').selectOption('training');
    await page.getByRole('button',{name:'出撃する'}).click({timeout:60000});
    await page.waitForTimeout(5000);
    const verifyScenario=async()=>{
      const state=await page.evaluate(()=>{
        const s=globalThis.ironYard?.snapshot();
        return s ? {training:s.ai===false,active:s.phase==='playing',targets:s.units.filter(u=>u.hp>0).length}
          // Three's deployment select is unmounted after starting; its game
          // telemetry reports 3 targets in training and 9 in combat instead.
          : {training:Number(document.querySelector('#mission-telemetry')?.dataset.total)===3,active:document.querySelector('.arena')?.dataset.active==='true',
            targets:Number(document.querySelector('#mission-telemetry')?.dataset.total)};
      });
      if (!state.training || !state.active || state.targets!==3) throw Error(`${name}: invalid scenario ${JSON.stringify(state)}`);
      return state;
    };
    const verifiedScenario=await verifyScenario();
    const metadata = await page.evaluate(async()=>{
      const canvas=document.querySelector('canvas');
      const adapter=await navigator.gpu?.requestAdapter();
      const gl=canvas.getContext('webgl2');
      const debug=gl?.getExtension('WEBGL_debug_renderer_info');
      return {viewport:[innerWidth,innerHeight],canvas:[canvas.width,canvas.height],dpr:devicePixelRatio,
        renderer:globalThis.ironYard?.rendererInfo(),samples:gl?.getParameter(gl.SAMPLES),
        webglRenderer:debug?gl.getParameter(debug.UNMASKED_RENDERER_WEBGL):null,
        gpu:adapter ? {vendor:adapter.info.vendor,architecture:adapter.info.architecture,device:adapter.info.device} : null};
    });
    metadata.chrome = browser.version();
    metadata.headless = headless;
    metadata.scenario = scenario;
    metadata.verifiedScenario = verifiedScenario;
    if (scenario === 'strafe') await page.evaluate(()=>{
      // Same alternating controls in both ports. Keep all three targets alive.
      let direction='KeyA';
      window.dispatchEvent(new KeyboardEvent('keydown',{code:direction,bubbles:true}));
      globalThis.__benchmarkInput=setInterval(()=>{
        window.dispatchEvent(new KeyboardEvent('keyup',{code:direction,bubbles:true}));
        direction=direction==='KeyA'?'KeyD':'KeyA';
        window.dispatchEvent(new KeyboardEvent('keydown',{code:direction,bubbles:true}));
      },1000);
    });
    const memory=async()=>{
      await cdp.send('HeapProfiler.collectGarbage');
      return {heap:await cdp.send('Runtime.getHeapUsage'),dom:await cdp.send('Memory.getDOMCounters')};
    };
    const before=await memory();
    const frames=[];
    for(let i=0;i<repeats;i++) {
      const metricsBefore=Object.fromEntries((await cdp.send('Performance.getMetrics')).metrics.map(m=>[m.name,m.value]));
      const sample=await page.evaluate(duration=>new Promise(resolve=>{
        const deltas=[],renderCpu=[],gpuMs=[];let start,previous;
        function frame(now){
          start??=now;
          if(previous!==undefined) deltas.push(now-previous);
          previous=now;
          const gpu=globalThis.__kaguraWebRuntime?.webgpu;
          if(gpu) {renderCpu.push(gpu._lastRenderCpuMs);gpuMs.push(gpu._lastTimestampFrameMs);}
          if(now-start<duration) requestAnimationFrame(frame);
          else resolve({elapsed:now-start,deltas,renderCpu,gpuMs});
        }
        requestAnimationFrame(frame);
      }),duration);
      const metricsAfter=Object.fromEntries((await cdp.send('Performance.getMetrics')).metrics.map(m=>[m.name,m.value]));
      sample.metrics=Object.fromEntries(['TaskDuration','ScriptDuration','LayoutDuration','RecalcStyleDuration'].map(k=>[k,(metricsAfter[k]-metricsBefore[k])*1000]));
      frames.push(sample);
      console.log(name,'run',i+1, JSON.stringify({fps:sample.deltas.length*1000/sample.elapsed,cpuMs:sample.metrics.TaskDuration}));
    }
    const after=await memory();
    await verifyScenario();
    let profileSummary;
    if (profiles) {
      await cdp.send('Profiler.enable');
      await cdp.send('Profiler.setSamplingInterval',{interval:1000});
      await cdp.send('Profiler.start');
      await page.waitForTimeout(duration);
      const {profile:cpu}=await cdp.send('Profiler.stop');
      await writeFile(`${out}/${name}.cpuprofile`,JSON.stringify(cpu));
      await cdp.send('HeapProfiler.startSampling',{samplingInterval:32768,includeObjectsCollectedByMajorGC:true,includeObjectsCollectedByMinorGC:true});
      await page.waitForTimeout(duration);
      const {profile:allocation}=await cdp.send('HeapProfiler.stopSampling');
      await writeFile(`${out}/${name}.heapprofile`,JSON.stringify(allocation));
      const selfTimes = new Map();
      cpu.samples.forEach((id,i)=>selfTimes.set(id,(selfTimes.get(id)??0)+cpu.timeDeltas[i]));
      const cpuGroups = new Map();
      for(const n of cpu.nodes) {
        const key=`${n.callFrame.functionName || '(anonymous)'} @ ${n.callFrame.url}:${n.callFrame.lineNumber+1}`;
        cpuGroups.set(key,(cpuGroups.get(key)??0)+(selfTimes.get(n.id)??0)/1000);
      }
      const allocationGroups=[];
      function visit(node, parents=[]) {
        allocationGroups.push({function:node.callFrame.functionName,bytes:node.selfSize,callers:parents.slice(-3)});
        for(const child of node.children) visit(child,[...parents,node.callFrame.functionName]);
      }
      visit(allocation.head);
      profileSummary={cpuSelfMs:[...cpuGroups].sort((a,b)=>b[1]-a[1]).slice(0,20),
        sampledAllocationBytes:allocationGroups.reduce((s,n)=>s+n.bytes,0),
        allocations:allocationGroups.sort((a,b)=>b.bytes-a.bytes).slice(0,20)};
    }
    const final=await memory();
    await verifyScenario();
    const diagnostics=await page.evaluate(()=>{
      const gpu=globalThis.__kaguraWebRuntime?.webgpu;
      const snapshot=globalThis.ironYard?.snapshot();
      const cache=gpu?._drawResourceCache;
      const slotBytes=names=>names.reduce((total,name)=>total+(cache?.[name]??[]).reduce((n,e)=>n+(e?.size??0),0),0);
      const sharedBytes=[...(gpu?._sharedGeometryBuffers?.resident??[])].reduce((n,e)=>n+(e.buffer?.size??0),0);
      return {phase:snapshot?.phase ?? document.querySelector('.arena')?.getAttribute('data-active'),
        draws:gpu?._lastSubmittedDrawCount ?? gpu?.commands?.length,
        instances:gpu?._lastSubmittedInstanceCount,
        geometryBuffers:gpu?._sharedGeometryBuffers?.resident.size,
        geometryBufferBytes:gpu ? sharedBytes+slotBytes(['vertexBuffers','indexBuffers','customVertexBuffers','customIndexBuffers']) : undefined,
        uniformBufferBytes:gpu ? slotBytes(['uniformBuffers','customUniformBuffers']) : undefined,
        geometryResources:gpu?._geometryRegistry?.size,
        commandSlots:gpu?._commandPool?.length,renderError:gpu?.lastError,
        timingMethod:gpu?._gpuTimingMethod,
        position:snapshot?.pilot.position ?? {...document.querySelector('#pilot-telemetry')?.dataset}};
    });
    if (!['playing','true'].includes(diagnostics.phase)) throw Error(`${name}: game became inactive during profiling`);
    if (errors.length || diagnostics.renderError) throw Error(`${name}: rendering failed: ${[...errors,diagnostics.renderError].join('; ')}`);
    if (option('heap-snapshot','false') === 'true') {
      const chunks=[];
      const chunk=event=>chunks.push(event.chunk);
      cdp.on('HeapProfiler.addHeapSnapshotChunk',chunk);
      await cdp.send('HeapProfiler.takeHeapSnapshot');
      cdp.off('HeapProfiler.addHeapSnapshotChunk',chunk);
      await writeFile(`${out}/${name}.heapsnapshot`,chunks.join(''));
    }
    await page.screenshot({path:`${out}/${name}.png`});
    const quantile=(a,q)=>{const v=a.filter(Number.isFinite).sort((a,b)=>a-b);return v[Math.floor((v.length-1)*q)]??null;};
    const summary=frames.map(f=>({fps:f.deltas.length*1000/f.elapsed,p50:quantile(f.deltas,.5),p95:quantile(f.deltas,.95),p99:quantile(f.deltas,.99),over25ms:f.deltas.filter(x=>x>25).length,
      renderCpuP50:quantile(f.renderCpu,.5),gpuP50:quantile(f.gpuMs,.5),...f.metrics}));
    const result={name,url,metadata,duration,repeats,summary,profileSummary,diagnostics,memory:{before,after,final},errors,frames};
    results.push(result);
    await writeFile(`${out}/results.json`,JSON.stringify(results,null,2));
    console.log(name,JSON.stringify({metadata,summary,memory:result.memory,diagnostics,errors},null,2));
    await context.close();
  }
} finally {await browser.close();}
