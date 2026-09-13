import {test} from 'node:test';
import assert from 'node:assert/strict';
import {createGamepadReader} from './kagura-gamepad.js';
const pad=(index=0,axes=[0,0,0,0],down=[])=>({index,id:`Pad ${index}`,connected:true,mapping:'standard',axes,buttons:Array.from({length:17},(_,i)=>({pressed:down.includes(i),value:down.includes(i)?1:0}))});
const victrix=(axes=[-.04,0,0,-1,-1,0,0,0,0,9/7],down=[])=>({...pad(0,axes,down),id:'Victrix Pro BFG Wired Controller for PS5 (Vendor: 0e6f Product: 0218)',mapping:''});

test('Victrix PS5 HID idle arms despite trigger and hat neutral values; right Y is axis 5',()=>{
  const r=createGamepadReader();const idle=victrix();const original=structuredClone(idle);
  const initial=r.step([idle]);
  assert.equal(initial.ready,true);assert.equal(initial.profile,'victrix-pro-bfg-ps5-mac');
  assert.deepEqual(initial.move,{x:0,y:0});assert.deepEqual(initial.look,{x:0,y:0});assert.deepEqual(initial.down,[]);
  const moved=r.step([victrix([.7,0,-.8,-1,-1,.5,0,0,0,9/7])]);
  assert.ok(moved.move.x>.5);assert.ok(moved.look.x<-.5);assert.ok(moved.look.y>0);
  assert.deepEqual(moved.down,[]);assert.deepEqual(idle,original);
});

test('Victrix face buttons, shoulders, menu and stick clicks map to their physical standard positions',()=>{
  for(const [raw,standard] of [[0,2],[1,0],[2,1],[3,3],[4,4],[5,5],[6,6],[7,7],[8,8],[9,9],[10,10],[11,11],[12,16],[13,17]]){
    const r=createGamepadReader();r.step([victrix()]);
    assert.deepEqual(r.step([victrix(undefined,[raw])]).pressed,[standard],`raw ${raw}`);
  }
  const r=createGamepadReader();r.step([victrix()]);
  assert.deepEqual(r.step([victrix([0,0,0,1,1,0,0,0,0,9/7])]).down,[6,7]);
  assert.deepEqual(r.step([victrix()]).released,[6,7]);
});

test('Victrix hat decodes all eight directions, and neutral never navigates',()=>{
  const directions=[[12],[12,15],[15],[13,15],[13],[13,14],[14],[12,14]];
  for(const [i,down] of directions.entries()){
    const r=createGamepadReader();r.step([victrix()]);
    const axes=[0,0,0,-1,-1,0,0,0,0,-1+i*2/7];
    assert.deepEqual(r.step([victrix(axes)]).down,down);
    assert.equal(r.step([victrix()]).navigation,null);
  }
});

test('Victrix fallback is device and layout specific; browser standard mapping wins',()=>{
  const raw=victrix();
  for(const id of [raw.id.replace('0218','021a'),raw.id.replace('0e6f','054c'),'Unknown pad']){
    assert.equal(createGamepadReader().step([{...raw,id}]).supported,false);
  }
  assert.equal(createGamepadReader().step([{...raw,axes:[0,0,0,0]}]).supported,false);
  const r=createGamepadReader();r.step([{...pad(),id:raw.id}]);
  assert.deepEqual(r.step([{...pad(0,[0,0,0,0],[0]),id:raw.id}]).pressed,[0]);
});

test('gamepad dead zones are radial, analog speed is retained, and buttons have edges',()=>{
  const r=createGamepadReader();r.step([null,pad(2)]);
  let s=r.step([null,pad(2,[.1,-.1,0,0],[7])]);
  assert.equal(s.index,2);assert.deepEqual(s.move,{x:0,y:0});assert.deepEqual(s.pressed,[7]);
  s=r.step([pad(2,[.5,0,1,1],[7])]);
  assert.ok(s.move.x>0&&s.move.x<.5);assert.ok(Math.hypot(s.look.x,s.look.y)<=1.000001);assert.deepEqual(s.pressed,[]);
  assert.deepEqual(r.step([pad(2)]).released,[7]);
});

test('connection, focus return and replacement require neutral controls, and never merge pads',()=>{
  const r=createGamepadReader();
  assert.equal(r.step([pad(3,[1,0,0,0],[7])]).ready,false);
  r.step([pad(3)]);
  assert.deepEqual(r.step([pad(3,[1,0,0,0],[7]),pad(4,[0,1,0,0],[0])]).down,[7]);
  assert.deepEqual(r.step([pad(4,[1,0,0,0],[7])]).down,[]);
  r.step([pad(4)]);
  assert.deepEqual(r.step([pad(4,[0,0,0,0],[7])]).pressed,[7]);
  assert.equal(r.step([pad(4)],{enabled:false}).ready,false);
  assert.deepEqual(r.step([pad(4,[0,0,0,0],[7])]).down,[]);
  assert.equal(r.step([pad(4)]).ready,true);
  assert.equal(r.step([]).connected,false);
});

test('unmapped controllers do not trigger standard actions and menu directions repeat at a controlled rate',()=>{
  const r=createGamepadReader();
  assert.equal(r.step([{...pad(),mapping:''}]).supported,false);
  r.step([pad()],{now:0});
  assert.equal(r.step([pad(0,[0,0,0,0],[13])],{now:10}).navigation,'down');
  assert.equal(r.step([pad(0,[0,0,0,0],[13])],{now:200}).navigation,null);
  assert.equal(r.step([pad(0,[0,0,0,0],[13])],{now:430}).navigation,'down');
  assert.equal(r.step([pad(0,[0,0,0,0],[13])],{now:440}).navigation,null);
});

test('disconnect, replacement and focus loss emit release edges exactly once',()=>{
  for(const next of [[],[pad(1)], [pad(0)]]){
    const r=createGamepadReader();r.step([pad()]);r.step([pad(0,[0,0,0,0],[6,7])]);
    const options={enabled:next[0]?.index!==0};
    assert.deepEqual(r.step(next,options).released,[6,7]);
    assert.deepEqual(r.step(next,options).released,[]);
  }
});

test('deadzoned jitter never reports device activity',()=>{
  const r=createGamepadReader();r.step([pad()]);
  assert.equal(r.step([pad(0,[.1,.08,-.1,.07])]).activity,false);
  assert.equal(r.step([pad(0,[.7,0,0,0])]).activity,true);
});

test('slow intentional stick motion still activates the pad after leaving the dead zone',()=>{
  const r=createGamepadReader();r.step([pad()]);
  let active=false;
  for(let i=1;i<=50;i++)active=r.step([pad(0,[i/100,0,0,0])]).activity||active;
  assert.equal(active,true);
  assert.equal(r.step([pad(0,[.5,0,0,0])]).activity,false);
});
