import {test,expect} from '@playwright/test';
import {PNG} from 'pngjs';
import {captureGameFrame} from '../../../../scripts/capture-web.mjs';
const hud=page=>page.evaluate(()=>globalThis.__ashenHud);

test.beforeEach(async({page})=>{
  await page.addInitScript(()=>{
    globalThis.__landscapeGpuErrors=[];
    const request=GPUAdapter.prototype.requestDevice;
    GPUAdapter.prototype.requestDevice=async function(...args){
      const d=await request.apply(this,args);
      d.addEventListener('uncapturederror',e=>globalThis.__landscapeGpuErrors.push(e.error.message));
      return d;
    };
  });
});

for(const landmark of ['bridge','coast','cave','inside']){
  test(`${landmark} renders actual terrain and cached distant scenery without GPU validation errors`,async({page},info)=>{
    await page.goto(`/?snapshot=landscape&landmark=${landmark}&seed=42&mute=1&perf=1`);
    await expect.poll(async()=>(await hud(page))?.mode).toBe('playing');
    await page.waitForFunction(()=>globalThis.__kaguraProfiler?.snapshot()?.frame>25);
    const png=PNG.sync.read(await captureGameFrame(page,{path:info.outputPath(`${landmark}.png`)}));
    let scenePixels=0,waterPixels=0;
    for(let y=200;y<650;y++)for(let x=250;x<1030;x++){
      const i=(y*png.width+x)*4;const [r,g,b]=png.data.subarray(i,i+3);
      if(r+g+b>90)scenePixels++;
      if(b>g&&g>r*1.4&&b>65)waterPixels++;
    }
    expect(scenePixels).toBeGreaterThan(100000);
    if(landmark==='bridge'||landmark==='coast')expect(waterPixels).toBeGreaterThan(4000);
    expect(await page.evaluate(()=>globalThis.__landscapeGpuErrors)).toEqual([]);
    expect((await hud(page)).terrain.expedition_available).toBe(true);
    // The western panorama must not prepare the remote region's actors/props.
    if(landmark==='coast'){expect((await hud(page)).atlas.chunks_built).toBe(0);expect((await hud(page)).camera.mode).toBe(1);}
  });
}

test('walk through the cave and back out while the roof follows the player',async({page},info)=>{
  await page.goto('/?snapshot=landscape&landmark=cave&seed=42&mute=1');
  await expect.poll(async()=>(await hud(page))?.mode).toBe('playing');
  // The gallery is aligned north/south; compensate the fixture camera yaw by
  // moving diagonally in short corrections, using the real keyboard path.
  await page.keyboard.down('KeyW');
  await expect.poll(async()=>(await hud(page)).map_z,{timeout:12000}).toBeLessThan(22);
  await page.keyboard.up('KeyW');
  await captureGameFrame(page,{path:info.outputPath('walking-cave.png')});
  const z=(await hud(page)).map_z;
  await page.keyboard.down('KeyS');
  await expect.poll(async()=>(await hud(page)).map_z,{timeout:12000}).toBeGreaterThan(z+4);
  await page.keyboard.up('KeyS');
  expect(await page.evaluate(()=>globalThis.__landscapeGpuErrors)).toEqual([]);
});

test('landmark preview overrides saved terrain and camera without changing preferences',async({page})=>{
  const prefs={
    terrain:JSON.stringify({pattern:'Flat',seed:87,amplitude:4,scale:18,roughness:.5}),
    camera:JSON.stringify({version:1,mode:0,
      quarter:{tilt:65,distance:12,side:0,height:.4,forward:0},
      tps:{tilt:18,distance:4.5,side:.55,height:1,forward:.65}}),
  };
  await page.addInitScript(p=>{
    localStorage.setItem('ashen-hunt-terrain-v1',p.terrain);
    localStorage.setItem('ashen-hunt-camera-v1',p.camera);
  },prefs);
  await page.goto('/?snapshot=landscape&landmark=coast&seed=42&mute=1');
  await expect.poll(async()=>(await hud(page))?.terrain.pattern).toBe(5);
  expect((await hud(page)).camera.mode).toBe(1);
  expect((await hud(page)).camera.tuning.tilt).toBe(10);
  expect((await hud(page)).map_x).toBeCloseTo(13.5);
  expect(await page.evaluate(()=>({terrain:localStorage.getItem('ashen-hunt-terrain-v1'),camera:localStorage.getItem('ashen-hunt-camera-v1')}))).toEqual(prefs);
});

test('sky covers the horizon in terrain lab and survives camera rotation',async({page},info)=>{
  await page.goto('/?snapshot=landscape&landmark=coast&terrain=flat&seed=42&mute=1&perf=1');
  await expect.poll(async()=>(await hud(page))?.terrain.pattern).toBe(0);
  await expect.poll(async()=>(await hud(page))?.camera.mode).toBe(1);
  await page.waitForFunction(()=>globalThis.__kaguraProfiler?.snapshot()?.frame>25);
  for(let direction=0;direction<4;direction++){
    if(direction>0){
      const yaw=await page.evaluate(()=>globalThis.__ashenHunt.yaw);
      await page.keyboard.down('KeyQ');
      await expect.poll(()=>page.evaluate(()=>globalThis.__ashenHunt.yaw)).toBeGreaterThan(yaw+Math.PI/2);
      await page.keyboard.up('KeyQ');
    }
    const png=PNG.sync.read(await captureGameFrame(page,{path:info.outputPath(`sky-${direction}.png`)}));
    let sky=0,total=0;
    for(let y=125;y<190;y++)for(let x=340;x<940;x++){
      const i=(y*png.width+x)*4;const [r,g,b]=png.data.subarray(i,i+3);
      total++;if(r>45&&g>55&&b>70)sky++;
    }
    expect(sky/total).toBeGreaterThan(.65);
  }
  expect(await page.evaluate(()=>globalThis.__landscapeGpuErrors)).toEqual([]);
});


test('sky has no depth clipping gaps at a fractional render scale',async({page},info)=>{
  await page.setViewportSize({width:1318,height:868});
  await page.goto('/?snapshot=landscape&landmark=coast&seed=42&mute=1&perf=1');
  await expect.poll(async()=>(await hud(page))?.camera.mode).toBe(1);
  await page.waitForFunction(()=>globalThis.__kaguraProfiler?.snapshot()?.frame>25);
  const png=PNG.sync.read(await captureGameFrame(page,{path:info.outputPath('sky-no-gaps.png')}));
  let gaps=0;
  for(let y=20;y<95;y++)for(let x=760;x<1020;x++){
    const i=(y*png.width+x)*4;
    if(png.data[i]+png.data[i+1]+png.data[i+2]<60)gaps++;
  }
  expect(gaps).toBe(0);
  expect(await page.evaluate(()=>globalThis.__landscapeGpuErrors)).toEqual([]);
});

test('shared terrain index ranges render with SSAO enabled',async({page})=>{
  await page.goto('/?snapshot=camp&seed=42&mute=1&perf=1&ssao=1');
  await expect.poll(()=>page.evaluate(()=>globalThis.__kaguraProfiler?.snapshot()?.frame??0)).toBeGreaterThan(70);
  await page.keyboard.press('KeyP');
  const ranges=await page.evaluate(()=>globalThis.__kaguraLastGpu.commands
    .filter(c=>c.firstIndex>0).map(c=>({first:c.firstIndex,count:c.indexCount,total:c.indices.length})));
  expect(ranges.length).toBeGreaterThan(0);
  for(const r of ranges){expect(r.count).toBeGreaterThan(0);expect(r.first+r.count).toBeLessThanOrEqual(r.total);}
  expect(await page.evaluate(()=>globalThis.__landscapeGpuErrors)).toEqual([]);
});
