import {test,expect} from '@playwright/test';
import {captureGameFrame} from '../../../../scripts/capture-web.mjs';
async function start(page){
  await page.goto('/?snapshot=melee&seed=42');
  await page.waitForFunction(()=>globalThis.__ashenHud?.combat&&globalThis.__ashenHunt);
  await page.evaluate(()=>{
    globalThis.__meleeSamples=[];
    const sample=()=>{
      const h=globalThis.__ashenHud,c=h?.combat,p=globalThis.__ashenHunt;
      if(c&&p){globalThis.__meleeSamples.push({frame:globalThis.__hacknslash3dRuntime.frame,stop:c.hitstop,impacts:c.impacts,damage:c.damage.length,amounts:c.damage.filter(d=>!d.player).map(d=>d.amount),combo:c.combo_step,active:c.combo_active,attacks:p.attacks,x:p.x,y:p.y,warnings:c.warnings,hp:h.hp,attack:p.attackFrame,cue:globalThis.__hacknslash3dAudioDebug?.lastPlayedCue});}
      if(globalThis.__meleeSamples.length<600)requestAnimationFrame(sample);
    };requestAnimationFrame(sample);
  });
}

for(const [index,name,cue] of [[0,'cleaver','melee_cleaver'],[1,'spear','melee_pierce'],[2,'punch','melee_punch']] as const){
  test(`${name}: assisted contact, visible damage, hitstop and a distinct impact sound`,async({page},info)=>{
    const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
    await start(page);
    await page.locator('#player-weapon').selectOption(String(index));
    await expect.poll(()=>page.evaluate(()=>globalThis.__ashenHud.weapon_index)).toBe(index);
    await page.keyboard.down('KeyJ');
    // Multiple sounds can play in one tick; lastPlayedCue may be a later enemy warning.
    await page.waitForFunction(cue=>globalThis.__meleeSamples.some(s=>s.impacts>0&&s.cue===cue),cue);
    await page.keyboard.up('KeyJ');
    const numbers=page.locator('.damage-number:not([hidden])');
    await expect(numbers.first()).toBeVisible();
    expect(Number(await numbers.first().textContent())).toBeGreaterThan(0);
    await captureGameFrame(page,{path:info.outputPath(`${name}-impact.png`)});
    const samples=await page.evaluate(()=>globalThis.__meleeSamples);
    expect(samples.some(s=>s.damage>0)).toBe(true);
    expect(samples.some(s=>s.cue===cue)).toBe(true);
    expect(samples.some((s,i)=>i>0&&s.stop>0&&s.frame===samples[i-1].frame&&s.attack===samples[i-1].attack)).toBe(true);
    await page.keyboard.press('Escape');
    await expect(page.getByRole('dialog',{name:'一時停止メニュー'})).toBeVisible();
    const frame=await page.evaluate(()=>globalThis.__hacknslash3dRuntime.frame);
    await page.evaluate(async()=>{for(let i=0;i<8;i++)await new Promise(requestAnimationFrame)});
    expect(await page.evaluate(()=>globalThis.__hacknslash3dRuntime.frame)).toBe(frame);
    expect(errors).toEqual([]);
  });
}

test('enemy melee paints its warning before contact and a sideways dodge avoids it',async({page},info)=>{
  await start(page);
  await expect.poll(()=>page.evaluate(()=>globalThis.__ashenHud.combat.warnings)).toBeGreaterThan(0);
  await captureGameFrame(page,{path:info.outputPath('enemy-melee-warning.png')});
  const hp=await page.evaluate(()=>globalThis.__ashenHud.hp);
  await page.keyboard.down('KeyA');
  await page.keyboard.press('Space');
  await page.waitForFunction(()=>globalThis.__ashenHunt.dodges>0);
  await page.keyboard.up('KeyA');
  await expect.poll(()=>page.evaluate(()=>globalThis.__ashenHunt.animation)).not.toBe('dodging');
  expect(await page.evaluate(()=>globalThis.__ashenHud.hp)).toBe(hp);
});

test.describe('portrait melee',()=>{
  test.use({viewport:{width:390,height:844},isMobile:true,hasTouch:true});
  test('touch attack locks nearby targets and damage numbers remain legible',async({page,context},info)=>{
    await start(page);
    const box=(await page.locator('#attack-button').boundingBox())!;
    const cdp=await context.newCDPSession(page);
    await cdp.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[{x:box.x+box.width/2,y:box.y+box.height/2,id:1}]});
    await expect.poll(()=>page.evaluate(()=>globalThis.__ashenHud.combat.impacts)).toBeGreaterThan(0);
    await cdp.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});
    const text=page.locator('.damage-number:not([hidden])').first();
    await expect(text).toBeVisible();
    expect(await text.evaluate(el=>parseFloat(getComputedStyle(el).fontSize))).toBeGreaterThanOrEqual(21);
    const rect=(await text.boundingBox())!;
    expect(rect.x).toBeGreaterThanOrEqual(0);expect(rect.x+rect.width).toBeLessThanOrEqual(390);
    await captureGameFrame(page,{path:info.outputPath('melee-mobile.png')});
  });
});


test('holding slash cycles three separate cuts with a longer third recovery',async({page},info)=>{
  await start(page);
  await page.keyboard.down('KeyJ');
  await page.waitForFunction(()=>globalThis.__ashenHunt.attacks>=4);
  await page.keyboard.up('KeyJ');
  const samples=await page.evaluate(()=>globalThis.__meleeSamples);
  const starts=samples.filter((s,i)=>s.attacks>0&&(i===0||s.attacks!==samples[i-1].attacks));
  expect(starts.slice(0,4).map(s=>s.combo)).toEqual([1,2,3,1]);
  const intervals=starts.slice(1,4).map((s,i)=>s.frame-starts[i].frame);
  expect(intervals[2]).toBeGreaterThan(intervals[0]+20);
  expect(intervals[2]).toBeGreaterThan(intervals[1]+20);
  for(const step of [1,2]){
    const strike=samples.filter(s=>s.active&&s.combo===step&&s.attacks===step);
    expect(Math.hypot(strike.at(-1).x-strike[0].x,strike.at(-1).y-strike[0].y)).toBeGreaterThan(.05);
  }
  expect(samples.some(s=>s.combo===3&&s.stop===6)).toBe(true);
  await expect(page.locator('#combo-chain')).toBeVisible();
  await captureGameFrame(page,{path:info.outputPath('cleaver-combo.png')});
});

test('each cleaver cut can be inspected independently in the authoring view',async({page},info)=>{
  for(const [step,frame] of [[1,6],[2,7],[3,12]]){
    await page.goto(`/?snapshot=hunter&weapon=cleaver_flintlock&combo=${step}&frames=${frame}&seed=42`);
    await page.waitForFunction(({step,frame})=>globalThis.__ashenHud?.combat.combo_step===step&&globalThis.__ashenHunt?.attackFrame===frame,{step,frame});
    await captureGameFrame(page,{path:info.outputPath(`cleaver-cut-${step}.png`)});
  }
});
