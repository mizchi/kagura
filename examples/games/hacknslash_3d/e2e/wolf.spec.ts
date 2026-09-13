import {test,expect} from '@playwright/test';
import {PNG} from 'pngjs';
import {captureGameFrame} from '../../../../scripts/capture-web.mjs';

for(const width of [1280,390]){
  test(`wolf walk, run and bite render articulated grey silhouettes at ${width}px`,async({page},info)=>{
    await page.setViewportSize({width,height:900});
    const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
    const shots:PNG[]=[];
    for(const [motion,frame] of [['walk',0],['walk',14],['run',8],['bite',24],['bite',34]] as const){
      await page.goto(`/?snapshot=wolf&motion=${motion}&frames=${frame}&seed=42&mute=1`);
      await page.waitForFunction(()=>globalThis.__ashenHunt?.bones===17);
      shots.push(PNG.sync.read(await captureGameFrame(page,{path:info.outputPath(`${motion}-${frame}.png`)})));
    }
    // Actor fills the centre; compare only its band so changing HUD text cannot pass.
    for(const [a,b] of [[shots[0],shots[1]],[shots[1],shots[2]],[shots[3],shots[4]]]){
      let changed=0,fur=0;
      for(let y=Math.floor(b.height*.30);y<b.height*.64;y++)for(let x=Math.floor(b.width*.18);x<b.width*.82;x++){
        const i=(y*b.width+x)*4,[r,g,blue]=b.data.subarray(i,i+3);
        if(Math.abs(a.data[i]-r)+Math.abs(a.data[i+1]-g)+Math.abs(a.data[i+2]-blue)>60)changed++;
        if(r>95&&blue>r&&Math.abs(g-blue)<30&&Math.abs(g-r)<30)fur++;
      }
      expect(changed,'legs / jaw visibly change pose').toBeGreaterThan(150);
      expect(fur,'grey fur remains visible').toBeGreaterThan(300);
    }
    expect(errors).toEqual([]);
  });
}

test('wolf pursues, warns before biting, and is vulnerable to player melee',async({page},info)=>{
  const errors:string[]=[];page.on('pageerror',e=>errors.push(e.message));
  await page.goto('/?snapshot=wolves&seed=42&mute=1');
  await page.waitForFunction(()=>globalThis.__ashenHud?.combat);
  const hp=await page.evaluate(()=>globalThis.__ashenHud.hp);
  await expect.poll(()=>page.evaluate(()=>globalThis.__ashenHud.combat.warnings)).toBeGreaterThan(0);
  expect(await page.evaluate(()=>globalThis.__ashenHud.hp)).toBe(hp);
  await captureGameFrame(page,{path:info.outputPath('wolf-bite-warning.png')});
  await expect.poll(()=>page.evaluate(()=>globalThis.__ashenHud.hp)).toBeLessThan(hp);
  await page.keyboard.down('KeyJ');
  await expect.poll(()=>page.evaluate(()=>globalThis.__ashenHud.combat.impacts)).toBeGreaterThan(0);
  await page.keyboard.up('KeyJ');
  expect(errors).toEqual([]);
});
