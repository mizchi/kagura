import {test,expect} from '@playwright/test';
const snapshot = page => page.evaluate(() => globalThis.aftershift?.snapshot());
async function boot(page) {
  const errors=[];
  page.on('pageerror', e=>errors.push(e.message));
  await page.goto('/');
  await expect(page.locator('#shift-start')).toBeVisible();
  await expect.poll(async()=>(await snapshot(page))?.mode).toBe('title');
  return errors;
}

test('timing metadata separates the visual reference from game allowances',async({page})=>{
  await boot(page);
  const {timing}=await snapshot(page);
  expect(timing).toMatchObject({simulationHz:60,visualReactionMinMs:180,visualReactionMs:250,
    decisionAllowanceMs:150,deviceAllowanceMs:50,comfortAllowanceMs:50});
  expect(timing.responseBudgetMs).toBe(timing.visualReactionMs+timing.decisionAllowanceMs+
    timing.deviceAllowanceMs+timing.comfortAllowanceMs);
  expect(timing.responseBudgetFrames).toBe(Math.ceil(timing.responseBudgetMs*timing.simulationHz/1000));
  expect(timing.defaultWindupFrames).toBe(Math.ceil((timing.responseBudgetMs+timing.escapeExecutionMs+
    timing.telegraphMarginMs)*timing.simulationHz/1000));
});

test('start, movement, combo, pause and one-input retry work through real keys',async({page})=>{
  const errors=await boot(page);
  await page.screenshot({path:'output/belt_action/title.png'});
  await page.keyboard.press('Enter');
  await expect.poll(async()=>(await snapshot(page)).mode).toBe('playing');
  await page.keyboard.down('d');
  await expect.poll(async()=>(await snapshot(page)).player.x).toBeGreaterThan(275);
  await page.keyboard.up('d');await page.keyboard.down('j');
  await expect.poll(async()=>(await snapshot(page)).hits).toBeGreaterThan(0);
  await page.screenshot({path:'output/belt_action/combat.png'});
  await page.keyboard.up('j');await page.keyboard.press('Escape');
  await expect.poll(async()=>(await snapshot(page)).mode).toBe('paused');
  const frozen=await snapshot(page);
  await page.waitForTimeout(220);
  expect(await snapshot(page)).toEqual(frozen);
  await page.screenshot({path:'output/belt_action/pause.png'});
  await page.keyboard.press('Enter');
  await expect.poll(async()=>(await snapshot(page)).frameCount).toBeGreaterThan(frozen.frameCount);
  await page.keyboard.press('r');
  const retried=await snapshot(page);
  expect(retried.generation).toBeGreaterThan(frozen.generation);
  expect(retried.hp).toBe(6);expect(retried.stage).toBe(0);expect(retried.hits).toBe(0);
  expect(errors).toEqual([]);
});

test('defeat stays visible and a fresh Enter starts the next shift',async({page})=>{
  await boot(page);await page.locator('#shift-start').click();
  await expect.poll(async()=>(await snapshot(page)).mode,{timeout:28000}).toBe('lost');
  await expect(page.locator('#shift-start')).toHaveText('もう一度');
  await page.screenshot({path:'output/belt_action/defeat.png'});
  await page.waitForTimeout(200);expect((await snapshot(page)).mode).toBe('lost');
  await page.keyboard.press('Enter');
  await expect.poll(async()=>(await snapshot(page)).hp).toBe(6);
  expect((await snapshot(page)).mode).toBe('playing');
});

async function playShift(page, {readTelegraphs, mashAll=false, budget=100000}) {
  const held=new Set(), phases=new Set();let lastStage=-1;
  async function keys(next) {
    for(const key of held) if(!next.has(key)){await page.keyboard.up(key);held.delete(key);}
    for(const key of next) if(!held.has(key)){await page.keyboard.down(key);held.add(key);}
  }
  const deadline=Date.now()+budget;
  let s=await snapshot(page);
  while(s.mode==='playing'&&Date.now()<deadline) {
    if(readTelegraphs&&s.stage!==lastStage){lastStage=s.stage;await page.screenshot({path:`output/belt_action/sector-${s.stage+1}.png`});}
    const next=new Set(),p=s.player;
    const responseFrames=s.timing.responseBudgetFrames;
    const alive=s.enemies.filter(e=>e.hp>0);
    const recognizedOpen=e=>e.open&&e.phaseTotal-e.timer>=responseFrames;
    const priority=e=>Math.abs(e.x-p.x)+(readTelegraphs?Math.abs(e.z-p.z)*.5-(recognizedOpen(e)?100:0)-(e.kind!==1&&e.kind!==3?30:0):0);
    alive.sort((a,b)=>priority(a)-priority(b));
    if(!readTelegraphs&&(!mashAll||s.frameCount%24<2)){
      next.add('j');if(mashAll){next.add('k');next.add('Space');}
    }
    if(readTelegraphs)for(const e of alive){if(e.braced)phases.add('braced');if(e.open)phases.add('open');}
    const threat=readTelegraphs&&alive.find(e=>((e.action==='windup'&&e.phaseTotal-e.timer>=responseFrames)||e.action==='active')&&Math.abs(e.x-p.x)<145);
    if(threat&&Math.abs(threat.aimZ-p.z)<55){
      next.add(threat.aimZ<372?'s':'w');
      if(threat.action==='windup'&&p.evadeCooldown===0)next.add('Space');
    } else if(!alive.length)next.add('d');
    else {
      const e=alive[0],dx=e.x-p.x,dz=e.z-p.z,dir=Math.sign(dx)||1;
      if(Math.abs(dx)>68||p.facing!==dir)next.add(dx<0?'a':'d');
      if(Math.abs(dz)>10&&(!threat||Math.abs(p.z+Math.sign(dz)*2.3-threat.aimZ)>=55))next.add(dz<0?'w':'s');
      if(readTelegraphs&&Math.abs(dx)<95&&Math.abs(dz)<27){
        if(e.kind!==1&&e.kind!==3)next.add('j');
        else if(recognizedOpen(e)&&e.timer>=20)next.add('k');
      }
    }
    await keys(next);await page.waitForTimeout(mashAll?15:60);s=await snapshot(page);
  }
  await keys(new Set());
  return {state:s,phases};
}

test('holding combo while chasing enemies loses without reading any telegraphs',async({page})=>{
  test.setTimeout(120000);
  const errors=await boot(page);await page.keyboard.press('Enter');
  const {state:s}=await playShift(page,{readTelegraphs:false});
  expect(s.mode,JSON.stringify(s)).toBe('lost');
  expect(s.stage).toBe(2);expect(s.dodges).toBe(0);expect(s.hp).toBe(0);
  expect(s.damage).toBe(1);expect(s.windup).toBe(s.timing.defaultWindupFrames);
  await page.screenshot({path:'output/belt_action/mash-defeat.png'});
  expect(errors).toEqual([]);
});

test('blind evasion carries a damage cost without requiring every pattern to lose',async({page})=>{
  test.setTimeout(90000);
  const errors=await boot(page);await page.keyboard.press('Enter');
  const {state:s}=await playShift(page,{readTelegraphs:false,mashAll:true,budget:75000});
  expect(['lost','cleared'],JSON.stringify(s)).toContain(s.mode);
  expect(s.taken).toBeGreaterThan(0);expect(s.dodges).toBeGreaterThan(0);expect(s.attacks).toBeGreaterThan(0);
  expect(s.damage).toBe(1);expect(s.windup).toBe(s.timing.defaultWindupFrames);
  expect(errors).toEqual([]);
});

test('configured response delays still permit a complete shift',async({page})=>{
  test.setTimeout(120000);
  const errors=await boot(page);await page.keyboard.press('Enter');
  const {state:s,phases}=await playShift(page,{readTelegraphs:true});
  expect(s.mode,JSON.stringify(s)).toBe('cleared');
  expect(s.damage).toBe(1);expect(s.windup).toBe(s.timing.defaultWindupFrames);expect(s.hp).toBeGreaterThan(0);
  expect(s.dodges).toBeGreaterThan(0);expect([...phases].sort()).toEqual(['braced','open']);
  await page.screenshot({path:'output/belt_action/clear.png'});
  expect(errors).toEqual([]);
});

test('a visible windup and OPEN each allow the configured response budget',async({page})=>{
  await boot(page);await page.locator('#shift-start').click();
  const reactionMs=(await snapshot(page)).timing.responseBudgetMs;
  await page.keyboard.down('d');
  await expect.poll(async()=>(await snapshot(page)).player.x).toBeGreaterThan(270);
  await page.keyboard.up('d');
  await page.waitForFunction(()=>aftershift.snapshot().enemies[0].action==='windup');
  await page.waitForTimeout(reactionMs);
  const noticed=await snapshot(page);
  expect(noticed.hp).toBe(6);expect(noticed.enemies[0].action).toBe('windup');
  await page.screenshot({path:'output/belt_action/recognition-window.png'});
  await page.keyboard.down('w');await page.keyboard.down('Space');
  await expect.poll(async()=>{
    const s=await snapshot(page);return s.enemies[0].aimZ-s.player.z;
  }).toBeGreaterThan(48);
  await page.keyboard.up('w');await page.keyboard.up('Space');
  await page.waitForFunction(()=>aftershift.snapshot().enemies[0].action==='recover');
  await page.waitForTimeout(reactionMs);
  await page.keyboard.down('s');
  await expect.poll(async()=>{
    const s=await snapshot(page);return Math.abs(s.enemies[0].z-s.player.z);
  },{intervals:[20]}).toBeLessThan(24);
  await page.keyboard.up('s');await page.keyboard.down('j');
  await expect.poll(async()=>(await snapshot(page)).hits).toBeGreaterThan(0);
  await page.keyboard.up('j');expect((await snapshot(page)).hp).toBe(6);
});

test.describe('touch',()=>{
test.use({hasTouch:true,isMobile:true});
test('directions and independent action holds work on a phone',async({page})=>{
  await page.setViewportSize({width:390,height:844});
  await boot(page);await page.locator('#shift-start').click();
  const right=page.locator('[data-action=right]');
  const strike=page.locator('[data-action=strike]');
  const point=async locator=>{const b=await locator.boundingBox();return{x:b.x+b.width/2,y:b.y+b.height/2};};
  const direction={...await point(right),id:1},attack={...await point(strike),id:2};
  const touch=await page.context().newCDPSession(page);
  await touch.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[direction]});
  await expect.poll(async()=>(await snapshot(page)).player.x).toBeGreaterThan(180);
  await touch.send('Input.dispatchTouchEvent',{type:'touchStart',touchPoints:[direction,attack]});
  await expect.poll(async()=>(await snapshot(page)).attacks).toBeGreaterThan(0);
  await touch.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[attack]});
  await touch.send('Input.dispatchTouchEvent',{type:'touchEnd',touchPoints:[]});
  await page.locator('[data-action=evade]').tap();
  await expect.poll(async()=>(await snapshot(page)).dodges).toBeGreaterThan(0);
  const bounds=await page.evaluate(()=>({scroll:document.documentElement.scrollWidth,width:innerWidth}));
  expect(bounds.scroll).toBe(bounds.width);
  await page.screenshot({path:'output/belt_action/phone.png'});
  await page.setViewportSize({width:844,height:390});
  await expect(strike).toBeVisible();
  await page.screenshot({path:'output/belt_action/phone-landscape.png'});
});
});
