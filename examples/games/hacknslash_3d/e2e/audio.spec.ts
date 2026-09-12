import {test, expect} from '@playwright/test';

test('new sound bank plays through the mixer and worklet, mutes and resumes', async ({page}) => {
  const errors: string[]=[];
  page.on('pageerror', error=>errors.push(error.message));
  await page.goto('/?snapshot=playing&frames=0&seed=42');
  await page.waitForFunction(()=>globalThis.__hacknslash3dAudioDebug?.loadedCount === 11);
  await page.locator('canvas').focus();
  await page.keyboard.press('KeyF'); // A physical gesture unlocks browser audio.
  await page.waitForFunction(()=>globalThis.__kaguraWebRuntime.audio?.useWorklet &&
    globalThis.__kaguraWebRuntime.audio.ctx.state === 'running');
  await page.evaluate(()=>{
    const audio=globalThis.__kaguraWebRuntime.audio;
    const analyser=audio.ctx.createAnalyser();
    analyser.fftSize=1024;
    audio.workletNode.connect(analyser);
    const samples=new Float32Array(analyser.fftSize);
    globalThis.__audioProbe={peak:0,history:[]};
    function measure(){
      analyser.getFloatTimeDomainData(samples);
      const peak=samples.reduce((max,x)=>Math.max(max,Math.abs(x)),0);
      const probe=globalThis.__audioProbe;
      probe.peak=Math.max(probe.peak,peak);
      probe.history.push(peak);
      if(probe.history.length>12)probe.history.shift();
      requestAnimationFrame(measure);
    }
    measure();
  });
  await page.keyboard.down('KeyJ');
  await expect.poll(()=>page.evaluate(()=>globalThis.__audioProbe.peak)).toBeGreaterThan(.015);
  await page.keyboard.up('KeyJ');
  await page.keyboard.down('KeyM');
  await expect.poll(()=>page.evaluate(()=>globalThis.__hacknslash3dAudioDebug.muted)).toBe(true);
  await page.keyboard.up('KeyM');
  await expect.poll(()=>page.evaluate(()=>Math.max(...globalThis.__audioProbe.history))).toBeLessThan(.00001);
  expect(await page.evaluate(()=>globalThis.__hacknslash3dAudioDebug.playingCount)).toBe(0);
  await page.evaluate(()=>{globalThis.__audioProbe.peak=0;});
  await page.keyboard.down('KeyM');
  await expect.poll(()=>page.evaluate(()=>globalThis.__hacknslash3dAudioDebug.muted)).toBe(false);
  await page.keyboard.up('KeyM');
  await page.keyboard.down('KeyJ');
  await expect.poll(()=>page.evaluate(()=>globalThis.__audioProbe.peak)).toBeGreaterThan(.015);
  await page.keyboard.up('KeyJ');
  expect(await page.evaluate(()=>globalThis.__audioProbe.peak)).toBeLessThan(.98);
  expect(await page.evaluate(()=>globalThis.__hacknslash3dAudioDebug.failedCount)).toBe(0);
  expect(errors).toEqual([]);
});
