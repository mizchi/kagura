// Repeatable terrain/streaming workloads; Kagura owns CPU and GPU measurement.
import {parseArgs} from 'node:util';
import {mkdirSync,writeFileSync} from 'node:fs';
import {resolve} from 'node:path';
import {chromium} from '@playwright/test';
import {measureWebPage} from './profile-web.mjs';
import {summarizeNumericSamples} from './web-performance-utils.mjs';
import {captureGameFrame} from './capture-web.mjs';
const {values}=parseArgs({options:{
  url:{type:'string',default:'http://localhost:8080/'},
  samples:{type:'string',default:'240'},
  scenario:{type:'string'},
  'out-dir':{type:'string',default:'output/expedition-profile'},
}});
const directory=resolve(values['out-dir']);mkdirSync(directory,{recursive:true});
const metal=process.platform==='darwin';
const browser=await chromium.launch({headless:true,...(metal?{channel:'chrome'}:{}),
  args:metal?['--enable-unsafe-webgpu','--enable-gpu','--use-angle=metal']:
    ['--enable-unsafe-webgpu','--use-angle=swiftshader','--enable-unsafe-swiftshader']});
const results=[];
try{
  for(const [name,params,moving] of [
    ['flat',{snapshot:'playing',terrain:'flat'},false],
    ['expedition',{snapshot:'playing',terrain:'expedition'},false],
    ['highland',{snapshot:'site',site:'chapel',terrain:'expedition'},false],
    ['streaming',{snapshot:'border',region:'0',terrain:'expedition'},true],
    ['panorama',{snapshot:'landscape',landmark:'coast',terrain:'expedition'},false],
    ['cave',{snapshot:'landscape',landmark:'inside',terrain:'expedition'},false],
    ['occlusion',{snapshot:'landscape',landmark:'occlusion',terrain:'expedition'},false],
    ['camp',{snapshot:'camp',terrain:'expedition'},false],
  ]){
    if(values.scenario&&values.scenario!==name)continue;
    const context=await browser.newContext({viewport:{width:1280,height:900}});
    const page=await context.newPage();const errors=[];
    page.on('pageerror',e=>errors.push(e.message));
    const url=new URL(values.url);
    for(const [key,value] of Object.entries({seed:'42',frames:'0',mute:'1',perf:'1',...params}))url.searchParams.set(key,value);
    await page.goto(url.toString());
    await page.waitForFunction(()=>globalThis.__kaguraProfiler?.snapshot()?.frame>30&&globalThis.__ashenHud?.mode==='playing');
    if(name==='highland')await page.waitForFunction(()=>globalThis.__ashenHud.atlas?.batches_built>=10);
    if(!moving){await page.keyboard.press('KeyP');await page.waitForFunction(()=>globalThis.__ashenHud.paused);}
    await page.waitForTimeout(500);
    const session=await context.newCDPSession(page);
    // Capture every simulation update during neighbor generation, including the
    // first request; steady-state sampling alone would miss a preload hitch.
    if(moving){
      await page.evaluate(()=>{
        globalThis.__mapStreamFrames=[];
        let last=-1;
        const sample=()=>{const s=globalThis.__kaguraProfiler.snapshot();
          if(s.frame!==last){last=s.frame;globalThis.__mapStreamFrames.push({...s});}
          if(globalThis.__mapStreamFrames.length<360)requestAnimationFrame(sample);
        };requestAnimationFrame(sample);
      });
      await page.keyboard.down('KeyD');await page.keyboard.down('KeyS');
    }
    const measured=await measureWebPage(page,session,{samples:Number(values.samples),profileMs:1000});
    await page.keyboard.up('KeyD');await page.keyboard.up('KeyS');
    const state=await page.evaluate(()=>({terrain:globalThis.__ashenHud.terrain,atlas:globalThis.__ashenHud.atlas,
      encounters:{resting:globalThis.__ashenHud.resting_enemies,waking:globalThis.__ashenHud.waking_enemies},
      preloadSamples:globalThis.__mapStreamFrames??[]}));
    const {profile,samples,...timing}=measured;
    const counters=Object.fromEntries(['drawCalls','indexCount','residentGeometryBuffers'].map(key=>[key,summarizeNumericSamples(samples.map(s=>s[key]))]));
    const result={name,url:url.toString(),...timing,counters,
      gpuTimingMethods:[...new Set(samples.map(s=>s.gpuTimingMethod))],
      terrain:state.terrain,streaming:state.atlas,encounters:state.encounters,
      preloadUpdateMs:state.preloadSamples.length?summarizeNumericSamples(state.preloadSamples.map(s=>s.updateMs)):null,errors};
    writeFileSync(resolve(directory,`${name}.samples.json`),JSON.stringify({samples,preloadSamples:state.preloadSamples}));
    writeFileSync(resolve(directory,`${name}.cpuprofile`),JSON.stringify(profile));
    if(!moving){await page.keyboard.press('KeyP');await page.waitForFunction(()=>!globalThis.__ashenHud.paused);}
    await captureGameFrame(page,{path:resolve(directory,`${name}.png`)});
    results.push(result);
    console.log(JSON.stringify({name,cpu:timing.cpuMsPerFrame.TaskDuration,gpuP95:timing.timings.gpuFrameMs?.p95,
      drawCalls:counters.drawCalls.p50,prepareMs:state.atlas?.prepare_max_ms,chunkMs:state.atlas?.chunk_max_ms,batchMs:state.atlas?.batch_max_ms}));
    await context.close();
    if(errors.length)throw new Error(errors.join('\n'));
  }
  writeFileSync(resolve(directory,'summary.json'),JSON.stringify({browser:await browser.version(),backend:metal?'Metal':'SwiftShader',viewport:{width:1280,height:900},results},null,2));
}finally{await browser.close();}
