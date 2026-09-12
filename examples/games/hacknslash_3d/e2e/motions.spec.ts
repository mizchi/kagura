import {test,expect} from '@playwright/test';
import {PNG} from 'pngjs';
import {captureGameFrame} from '../../../../scripts/capture-web.mjs';

for(const viewport of [{width:1280,height:900},{width:390,height:844}]) {
 test(`HY attacks change all three enemy silhouettes and retain material colors at ${viewport.width}px`,async({page},info)=>{
  const errors:string[]=[];page.on('pageerror',error=>errors.push(error.message));
  await page.setViewportSize(viewport);
  const shots:PNG[]=[];
  for(const frame of [12,24]){
   await page.goto(`/?snapshot=motions&frames=${frame}&seed=42&mute=1`);
   await page.waitForFunction(()=>globalThis.__ashenHunt?.bones===14);
   shots.push(PNG.sync.read(await captureGameFrame(page,{path:info.outputPath(`motion-${frame}.png`)})));
  }
  const [a,b]=shots,changed=[0,0,0],colored=[0,0,0];
  // Fixed authoring camera: all three enemies occupy the middle upper band.
  // This inspects actual GPU pixels and catches white single-instance skins.
  const centers=viewport.width>600?[.32,.5,.68]:[.15,.5,.85];
  const radius=viewport.width>600?.075:.12;
  for(let actor=0;actor<3;actor++){
   for(let y=Math.floor(b.height*.31);y<b.height*.55;y++)for(let x=Math.floor(b.width*(centers[actor]-radius));x<b.width*(centers[actor]+radius);x++){
    const i=(y*b.width+x)*4,[r,g,blue]=b.data.subarray(i,i+3);
    if(Math.abs(a.data[i]-r)+Math.abs(a.data[i+1]-g)+Math.abs(a.data[i+2]-blue)>80)changed[actor]++;
    if(actor===0&&r>110&&g>r*1.03&&r>blue*1.02&&g<r*1.3)colored[actor]++;
    if(actor===1&&r>85&&r>g*1.15&&g>blue*1.15)colored[actor]++;
    if(actor===2&&r>145&&g>145&&blue>120&&Math.abs(r-g)<20&&r>=blue)colored[actor]++;
   }
  }
  for(let actor=0;actor<3;actor++){
   expect(changed[actor],`actor ${actor} articulates limbs`).toBeGreaterThan(viewport.width>600?250:70);
   expect(colored[actor],`actor ${actor} keeps its palette`).toBeGreaterThan(viewport.width>600?160:40);
  }
  expect(errors).toEqual([]);
 });
}

for(const viewport of [{width:1280,height:900},{width:390,height:844}]) {
 test(`skeleton archer draws the bowstring and releases at ${viewport.width}px`,async({page},info)=>{
  const errors:string[]=[];page.on('pageerror',error=>errors.push(error.message));
  await page.setViewportSize(viewport);
  const shots:PNG[]=[];
  for(const frame of [6,22,26]){
   await page.goto(`/?snapshot=bow&frames=${frame}&seed=42&mute=1`);
   await page.waitForFunction(()=>globalThis.__ashenHunt?.bones===14);
   shots.push(PNG.sync.read(await captureGameFrame(page,{path:info.outputPath(`bow-${frame}.png`)})));
  }
  for(const [a,b] of [[shots[0],shots[1]],[shots[1],shots[2]]]){
   let changed=0,bone=0;
   for(let y=Math.floor(b.height*.28);y<b.height*.58;y++)for(let x=Math.floor(b.width*.3);x<b.width*.8;x++){
    const i=(y*b.width+x)*4,[r,g,blue]=b.data.subarray(i,i+3);
    if(Math.abs(a.data[i]-r)+Math.abs(a.data[i+1]-g)+Math.abs(a.data[i+2]-blue)>80)changed++;
    if(r>145&&g>145&&blue>120&&Math.abs(r-g)<20&&r>=blue)bone++;
   }
   expect(changed,'draw / release change the bow and arm silhouette').toBeGreaterThan(viewport.width>600?180:70);
   expect(bone,'bone-colored archer remains visible').toBeGreaterThan(200);
  }
  expect(errors).toEqual([]);
 });
}
