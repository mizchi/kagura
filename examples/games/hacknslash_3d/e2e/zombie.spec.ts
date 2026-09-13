import {test,expect} from '@playwright/test';
import {PNG} from 'pngjs';
import {captureGameFrame} from '../../../../scripts/capture-web.mjs';

for (const width of [1280,390]) {
  test(`zombie shambles, raises both arms and leaps at ${width}px`,async({page},info)=>{
    await page.setViewportSize({width,height:900});
    const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
    const shots:PNG[]=[];
    for (const [motion,frame] of [['walk',0],['walk',18],['pounce',36],['pounce',43],['pounce',50]] as const) {
      await page.goto(`/?snapshot=zombie&motion=${motion}&frames=${frame}&seed=42&mute=1`);
      await page.waitForFunction(()=>globalThis.__ashenHunt?.bones===17);
      shots.push(PNG.sync.read(await captureGameFrame(page,{path:info.outputPath(`${motion}-${frame}.png`)})));
    }
    for (let n=1;n<shots.length;n++) {
      const a=shots[n-1],b=shots[n];
      let changed=0,skin=0;
      for(let y=Math.floor(b.height*.20);y<b.height*.72;y++)for(let x=Math.floor(b.width*.18);x<b.width*.82;x++) {
        const i=(y*b.width+x)*4,[r,g,blue]=b.data.subarray(i,i+3);
        if(Math.abs(a.data[i]-r)+Math.abs(a.data[i+1]-g)+Math.abs(a.data[i+2]-blue)>60)changed++;
        if(r>90&&g>=r&&g-blue>10&&g-r<50)skin++;
      }
      expect(changed,'feet / raised arms / airborne body visibly change pose').toBeGreaterThan(150);
      expect(skin,'pale skin is visible').toBeGreaterThan(300);
    }
    expect(errors).toEqual([]);
  });
}

test('zombie warns before pouncing and the player can counterattack after landing',async({page},info)=>{
  const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
  await page.goto('/?snapshot=zombies&seed=42&mute=1');
  await page.waitForFunction(()=>globalThis.__ashenHud?.combat);
  const hp=await page.evaluate(()=>globalThis.__ashenHud.hp);
  await expect.poll(()=>page.evaluate(()=>globalThis.__ashenHud.combat.warnings)).toBeGreaterThan(0);
  expect(await page.evaluate(()=>globalThis.__ashenHud.hp)).toBe(hp);
  await captureGameFrame(page,{path:info.outputPath('zombie-pounce-warning.png')});
  await expect.poll(()=>page.evaluate(()=>globalThis.__ashenHud.hp)).toBeLessThan(hp);
  await page.keyboard.down('KeyJ');
  await expect.poll(()=>page.evaluate(()=>globalThis.__ashenHud.combat.impacts)).toBeGreaterThan(0);
  await page.keyboard.up('KeyJ');
  expect(errors).toEqual([]);
});
