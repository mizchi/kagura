import {test,expect} from '@playwright/test';
import {mkdirSync} from 'node:fs';
const output='output/dungeon_rpg';
const snapshot=page=>page.evaluate(()=>globalThis.fathom.read());
async function boot(page){
  const errors=[];page.on('pageerror',e=>errors.push(e.message));
  await page.goto('/');await page.waitForFunction(()=>typeof globalThis.fathom?.read==='function');await page.waitForFunction(()=>globalThis.__kaguraGfx?.lastRenderCpuMs?.()>0);
  mkdirSync(output,{recursive:true});return errors;
}
const command=(page,action,arg=-1)=>page.evaluate(([a,n])=>globalThis.fathom.command(a,n),[action,arg]);
async function click(page,action,arg){await page.locator(`[data-action="${action}"]${arg===undefined?'':`[data-arg="${arg}"]`}`).click();}
async function fight(page){
  for(let round=0;round<120;round++){
    const s=await snapshot(page);if(s.mode!=='battle')return;
    const b=s.battle;
    if(['report','won'].includes(b.phase)){await click(page,'continue');continue;}
    if(b.phase==='review'){await click(page,'resolve');continue;}
    const actor=s.party[b.active];
    const wounded=s.party.map((h,i)=>({...h,i})).filter(h=>h.hp>0&&h.maxHp-h.hp>=8).sort((a,b)=>a.hp-b.hp)[0];
    if(actor.jobCode===3&&actor.mp>=2&&wounded){await click(page,'pick-heal');await click(page,'target',wounded.i);}
    else if(actor.jobCode===4&&actor.mp>=3&&b.foes.filter(f=>f.hp>0).length>=2){await click(page,'flame');}
    else if(wounded&&wounded.hp<8&&s.potions>b.orders.filter(o=>o.action==='回復薬').length){await click(page,'pick-potion');await click(page,'target',wounded.i);}
    else await click(page,'attack');
  }
  throw Error('Battle did not finish');
}
const floors=[
['#########','#E..#...#','#.#.#.#T#','#.#...#.#','#.###.#.#','#...D...#','###.#.#.#','#T..#..>#','#########'],
['#########','#<..#..T#','#.#.#.#.#','#.#...#.#','#...#...#','###.###.#','#S..#...#','#...D.B.#','#########']
];
async function walk(page,tx,tz){
  let s=await snapshot(page);const maze=floors[s.floor],paths=[[[s.x,s.z]]],seen=new Set([`${s.x},${s.z}`]);let route;
  for(let i=0;i<paths.length;i++){
    const p=paths[i],[x,z]=p.at(-1);if(x===tx&&z===tz){route=p;break;}
    for(const [dx,dz]of [[1,0],[-1,0],[0,1],[0,-1]]){
      const nx=x+dx,nz=z+dz,key=`${nx},${nz}`;
      if(maze[nz]?.[nx]&&maze[nz][nx]!=='#'&&!seen.has(key)){seen.add(key);paths.push([...p,[nx,nz]]);}
    }
  }
  expect(route).toBeTruthy();
  for(const [x,z]of route.slice(1)){
    s=await snapshot(page);const facing=x>s.x?1:x<s.x?3:z>s.z?2:0;
    while((await snapshot(page)).facing!==facing)await command(page,'right');
    if(maze[z][x]==='D')await command(page,'interact');
    expect(await command(page,'forward')).toBe('');
    if((await snapshot(page)).mode==='battle')await fight(page);
    expect((await snapshot(page)).mode).not.toBe('town');
  }
}

test('the view renders, keyboard movement has no time cost, and a normal retreat banks safely',async({page})=>{
  const errors=await boot(page);await page.screenshot({path:`${output}/town.png`});
  await page.getByRole('button',{name:'迷宮へ入る →',exact:true}).click();
  await page.keyboard.press('w');const before=await snapshot(page);
  expect(before.x).toBe(2);expect(before.light).toBe(69);
  await page.waitForTimeout(600);expect(await snapshot(page)).toEqual(before);
  await page.keyboard.press('s');await click(page,'interact');
  expect((await snapshot(page)).mode).toBe('town');
  expect(errors).toEqual([]);
});

test('six heroes can clear both floors and return with the seal using actual command buttons',async({page})=>{
  const errors=await boot(page);await click(page,'enter');
  await walk(page,7,2);await click(page,'interact');await click(page,'loot',0);
  expect((await snapshot(page)).carriedGold).toBeGreaterThan(0);
  await walk(page,7,7);await click(page,'interact');expect((await snapshot(page)).floor).toBe(1);
  await walk(page,1,6);await click(page,'interact');
  await walk(page,6,7);await click(page,'challenge');
  await page.evaluate(()=>new Promise(resolve=>requestAnimationFrame(()=>requestAnimationFrame(resolve))));
  await page.locator('#fathom').evaluate(el=>el.scrollTop=0);
  await page.screenshot({path:`${output}/guardian.png`});
  const frozen=await snapshot(page);await page.waitForTimeout(350);expect(await snapshot(page)).toEqual(frozen);
  await fight(page);let s=await snapshot(page);expect(s.relic).toBe(true);expect(s.mode).toBe('explore');
  await click(page,'recall-check');await click(page,'recall');s=await snapshot(page);
  expect(s.mode).toBe('cleared');expect(s.clears).toBe(1);expect(s.gold).toBeGreaterThan(40);
  await page.screenshot({path:`${output}/clear.png`});
  await page.reload();await page.waitForFunction(()=>typeof globalThis.fathom?.read==='function');s=await snapshot(page);
  expect(s.clears).toBe(1);expect(s.mode).toBe('town');expect(s.carriedGold).toBe(0);
  expect(errors).toEqual([]);
});

test('formation and town progress restore; a malformed save leaves a usable new party',async({page})=>{
  await boot(page);await click(page,'swap',0);await click(page,'swap',4);await click(page,'buy');
  await page.reload();await page.waitForFunction(()=>typeof globalThis.fathom?.read==='function');
  let s=await snapshot(page);expect(s.party[0].jobCode).toBe(4);expect(s.potions).toBe(4);expect(s.gold).toBe(34);
  await page.evaluate(()=>localStorage.setItem('kagura.fathom.town.v1','{"schema":999}'));
  await page.reload();await page.waitForFunction(()=>typeof globalThis.fathom?.read==='function');
  await expect(page.locator('#notice')).toContainText('保存記録を読み込めませんでした');
  s=await snapshot(page);expect(s.party).toHaveLength(6);expect(s.gold).toBe(40);await click(page,'enter');
  expect((await snapshot(page)).mode).toBe('explore');
});

test('runtime inspection pauses all commands without advancing the expedition',async({page})=>{
  await boot(page);await click(page,'enter');
  const before=await snapshot(page);
  await page.evaluate(()=>globalThis.kaguraSceneRuntime.pause(true));
  await expect(page.locator('#pause-notice')).toBeVisible();
  expect(await command(page,'forward')).toContain('Studio');
  await expect(page.locator('[data-action="forward"]')).toBeDisabled();
  expect(await snapshot(page)).toEqual(before);
  const inspection=await page.evaluate(()=>globalThis.kaguraSceneRuntime.fieldEditor.read());
  expect(JSON.stringify(inspection)).toContain('ROWAN');
  await page.evaluate(()=>globalThis.kaguraSceneRuntime.pause(false));await expect(page.locator('[data-action="forward"]')).toBeEnabled();
  await page.keyboard.press('w');expect((await snapshot(page)).x).toBe(2);
});

test.describe('phone',()=>{
  test.use({viewport:{width:390,height:844},hasTouch:true,isMobile:true});
  test('touch exploration, formation and scroll remain reachable without horizontal overflow',async({page})=>{
    const errors=await boot(page);await page.screenshot({path:`${output}/phone-town.png`});
    await page.locator('[data-action="enter"]').tap();await page.locator('[data-action="forward"]').tap();
    expect((await snapshot(page)).x).toBe(2);
    await page.locator('#fathom').evaluate(el=>el.scrollTop=0);await page.screenshot({path:`${output}/phone-dungeon.png`});
    await page.locator('.hero').last().scrollIntoViewIfNeeded();await page.screenshot({path:`${output}/phone-party.png`});
    const bounds=await page.evaluate(()=>{const el=document.querySelector('#fathom');return {scroll:el.scrollWidth,width:el.clientWidth}});
    expect(bounds.scroll).toBe(bounds.width);
    await page.setViewportSize({width:844,height:390});await expect(page.locator('[data-action="interact"]')).toBeVisible();
    expect(errors).toEqual([]);
  });
});

test('the HUD, party and commands share the render area without page scrolling',async({page})=>{
  await boot(page);await page.setViewportSize({width:1280,height:800});
  await expect(page.locator('#game-screen')).toBeVisible();
  const geometry=await page.evaluate(()=>{
    const screen=document.querySelector('#game-screen'),canvas=document.querySelector('#app'),r=canvas.getBoundingClientRect();
    return {screen:screen.getBoundingClientRect().toJSON(),canvas:r.toJSON(),overflow:screen.scrollHeight-screen.clientHeight,
      controls:[...screen.querySelectorAll('button:not(:disabled)')].filter(e=>e.checkVisibility()).map(e=>e.getBoundingClientRect().toJSON())};
  });
  const capture=await page.evaluate(()=>globalThis.__kaguraPresentation.captureTarget());
  await expect(page.locator(capture.selector)).toHaveAttribute('id','game-screen');
  expect(geometry.screen).toEqual(geometry.canvas);expect(geometry.overflow).toBe(0);
  for(const r of geometry.controls){expect(r.left).toBeGreaterThanOrEqual(geometry.canvas.left);expect(r.right).toBeLessThanOrEqual(geometry.canvas.right+1);expect(r.top).toBeGreaterThanOrEqual(geometry.canvas.top);expect(r.bottom).toBeLessThanOrEqual(geometry.canvas.bottom+1);}
});

test('keyboard-only menus, targeting, formation and the journal need no pointer',async({page})=>{
  await boot(page);
  await page.keyboard.press('g');await page.keyboard.press('Enter');await page.keyboard.press('ArrowRight');await page.keyboard.press('Enter');
  expect((await snapshot(page)).party[0].id).toBe(1);
  await page.keyboard.press('Escape');await page.keyboard.press('Enter');
  expect((await snapshot(page)).mode).toBe('explore');
  await page.keyboard.press('m');await expect(page.getByRole('dialog',{name:'探索手帳'})).toBeVisible();
  const frozen=await snapshot(page);await page.keyboard.press('w');expect(await snapshot(page)).toEqual(frozen);
  await page.keyboard.press('Escape');await expect(page.getByRole('dialog')).not.toBeVisible();
  await expect(page.locator('.adventurer-art')).toHaveCount(6);
});

async function firstEncounter(page){
  await page.keyboard.press('Enter');
  for(const key of ['d','w','w','w','w','a','w','w','Enter','w','w','w','w'])await page.keyboard.press(key);
  expect((await snapshot(page)).mode).toBe('battle');
}

test('keyboard combat plans targets and spells, plays every receipt, and skips effects on the next input',async({page})=>{
  const errors=await boot(page);await firstEncounter(page);
  await page.keyboard.press('1');await page.keyboard.press('ArrowRight');await page.keyboard.press('Enter');
  expect((await snapshot(page)).battle.orders[0].target).toBe(1);
  await page.keyboard.press('2');await page.keyboard.press('2');
  const mp=(await snapshot(page)).party[3].mp;
  await page.keyboard.press('3');await page.keyboard.press('Escape');
  expect((await snapshot(page)).party[3].mp).toBe(mp);expect((await snapshot(page)).battle.orders).toHaveLength(3);
  await page.keyboard.press('2');await page.keyboard.press('4');await page.keyboard.press('1');await page.keyboard.press('Enter');
  expect((await snapshot(page)).battle.phase).toBe('review');
  expect((await snapshot(page)).party[4].mp).toBe(10);
  await page.keyboard.press('Enter');
  const resolved=await snapshot(page);
  expect(resolved.party[4].mp).toBe(7);
  expect(resolved.effects.some(e=>e.kind==='fire')).toBe(true);
  await expect(page.locator('.damage-number')).toHaveCount(resolved.effects.length);
  await expect(page.locator('.hit-mark').first()).toBeVisible();
  await page.screenshot({path:`${output}/keyboard-hit-effects.png`});
  await page.keyboard.press('Enter');
  expect((await snapshot(page)).battle.phase).toBe('planning');
  await expect(page.locator('.damage-number')).toHaveCount(0);await expect(page.locator('.scene-hold')).toHaveCount(0);
  expect(errors).toEqual([]);
});

test('studio pause freezes presentation time and read-only combat state',async({page})=>{
  await boot(page);await firstEncounter(page);await page.keyboard.press('f');
  await page.evaluate(()=>kaguraSceneRuntime.pause(true));await expect(page.locator('#pause-notice')).toBeVisible();
  const time=await page.locator('#effects').evaluate(el=>el.getAnimations({subtree:true}).map(a=>a.currentTime));
  expect(time.length).toBeGreaterThan(0);const frozen=await snapshot(page);await page.waitForTimeout(220);
  expect(await page.locator('#effects').evaluate(el=>el.getAnimations({subtree:true}).map(a=>a.currentTime))).toEqual(time);
  expect(await snapshot(page)).toEqual(frozen);
  await page.evaluate(()=>kaguraSceneRuntime.pause(false));
  await expect.poll(()=>page.evaluate(()=>fathom.presentation().active)).toBe(0);
});

test.describe('reduced motion',()=>{
  test.use({reducedMotion:'reduce'});
  test('numeric feedback remains visible while movement, shake and slash effects are disabled',async({page})=>{
    await boot(page);await firstEncounter(page);await page.keyboard.press('f');
    expect(await page.evaluate(()=>fathom.presentation().reducedMotion)).toBe(true);
    expect(await page.locator('.damage-number').count()).toBeGreaterThan(0);
    await expect(page.locator('.hit-mark')).toHaveCount(0);await expect(page.locator('.scene-hold')).toHaveCount(0);
    expect(await page.locator('#world').evaluate(el=>el.getAnimations().length)).toBe(0);
    const frozen=await snapshot(page);await page.waitForTimeout(250);expect(await snapshot(page)).toEqual(frozen);
    await expect(page.locator('.damage-number')).toHaveCount(0);
  });
});

test('Enter activates a focused party member without starting an expedition',async({page})=>{
  await boot(page);await page.locator('[data-action="swap"][data-arg="0"]').focus();await page.keyboard.press('Enter');
  const selected=await snapshot(page);expect(selected.mode).toBe('town');expect(selected.selected).toBe(0);
  await page.keyboard.press('Escape');expect((await snapshot(page)).selected).toBe(-1);
});
