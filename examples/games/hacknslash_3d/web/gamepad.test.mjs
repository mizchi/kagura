import {test} from 'node:test';
import assert from 'node:assert/strict';
import {createControlInput} from '../../../../assets/web/kagura-controls.js';
import {createGamepadReader} from '../../../../assets/web/kagura-gamepad.js';
import {createHunterInput} from '../assets/hunter-input.mjs';
import {createHunterGamepad} from '../assets/hunter-gamepad.mjs';
const pad=(axes=[0,0,0,0],down=[])=>({index:0,id:'Test',mapping:'standard',connected:true,axes,buttons:Array.from({length:17},(_,i)=>({pressed:down.includes(i),value:down.includes(i)?1:0}))});
function fixture(inventory=()=>false){
  const input=createHunterInput(createControlInput());let pads=[pad()],hud={mode:'playing',paused:false,menu:'none',camera:{mode:0},arts:{targeting:false}},time=0;
  const navigation=[],look=[];let confirms=0;
  const gamepad=createHunterGamepad({inventory,reader:createGamepadReader(),input,camera:{look:(...v)=>look.push(v)},view:()=>hud,getPads:()=>pads,enabled:()=>true,now:()=>time+=16,navigate:d=>navigation.push(d),confirm:()=>confirms++});
  const set=(axes=[0,0,0,0],down=[])=>{pads=[pad(axes,down)];gamepad.poll();};set();
  return {input,hud,set,gamepad,navigation,look,confirms:()=>confirms,disconnect:()=>{pads=[];gamepad.poll();}};
}
test('square attacks, R1 guards, circle dodges and R2 channels independently of movement and aim',()=>{
  const f=fixture();f.set([.7,0,0,-.8],[2]);
  assert.ok(f.input.snapshot().x>.5);assert.ok(f.input.snapshot().attack);assert.ok(f.input.stickAim().y<0);
  f.set([0,0,0,0],[5]);assert.equal(f.input.snapshot().attack,false);assert.equal(f.input.snapshot().guard,true);assert.equal(f.input.stickAim(),null);
  f.set([0,0,0,0],[1]);assert.equal(f.input.consumeKey(),32);assert.equal(f.input.snapshot().whirlwind,false);
  f.set([0,0,0,0],[7]);assert.equal(f.input.snapshot().whirlwind,true);assert.equal(f.input.snapshot().attack,false);
  f.set();assert.equal(f.input.snapshot().whirlwind,false);
});
test('L2 plus dpad emits one spell and camera look is TPS only',()=>{
  const f=fixture();f.set([0,0,0,0],[6,12]);assert.equal(f.input.consumeKey(),53);assert.equal(f.input.consumeKey(),0);
  assert.equal(f.input.snapshot().guard,false);
  f.set([0,0,.7,0],[6,12]);assert.equal(f.input.consumeKey(),0);assert.equal(f.look.length,0);
  f.hud.camera.mode=1;f.set([0,0,.8,0]);assert.ok(f.look.at(-1)[0]>0);
});
test('menus suppress held combat until release, and disconnect only releases pad-owned input',()=>{
  const f=fixture();f.input.hold(9,'guard');f.set([1,0,0,0],[2]);
  f.hud.paused=true;f.set([1,0,0,0],[2]);assert.equal(f.input.snapshot().attack,false);
  f.hud.paused=false;f.set([1,0,0,0],[2]);assert.equal(f.input.snapshot().attack,false);
  f.set();f.set([1,0,0,0],[2]);assert.equal(f.input.snapshot().attack,true);
  f.disconnect();assert.equal(f.input.snapshot().x,0);assert.equal(f.input.snapshot().attack,false);assert.equal(f.input.snapshot().guard,true);
  assert.equal(f.input.consumeKey(),80);
});
test('gamepad menus navigate and confirm, while ground targeting has its own stick and cancel',()=>{
  const f=fixture();f.hud.paused=true;f.set();f.set([0,0,0,0],[13]);assert.equal(f.navigation.at(-1),'down');
  f.set();f.set([0,0,0,0],[0]);assert.equal(f.confirms(),1);
  f.hud.paused=false;f.hud.arts.targeting=true;f.set();f.set([0,0,1,0]);assert.ok(f.input.groundStick().x>0);
  f.set([0,0,0,0],[0]);assert.equal(f.input.consumeKey(),13);
  f.set();f.set([0,0,0,0],[1]);f.input.consumeKey();assert.equal(f.input.consumeKey(),84);
});

test('pad targeting starts from assisted aim without reusing an old mouse point',()=>{
  const f=fixture();f.input.aimAt(.1,.2);
  f.set([0,0,0,0],[13]);
  assert.equal(f.input.gamepadActive(),true);
  assert.deepEqual(f.input.groundStick(),{x:0,y:0});
  f.input.clear();assert.equal(f.input.gamepadActive(),true);
  f.input.aimPointer(.4,.3);f.set([.08,0,0,0]);
  assert.equal(f.input.gamepadActive(),true); // A button release is an intentional pad event.
  f.input.aimPointer(.4,.3);f.set([.1,0,0,0]);
  assert.equal(f.input.gamepadActive(),false);
  assert.deepEqual(f.input.pointerAim(),{x:.4,y:.3});
});

test('cross requests loot without casting a combat skill and the spell modifier preserves basic combat buttons',()=>{
  const f=fixture();f.set([0,0,0,0],[0]);assert.equal(f.input.consumeKey(),204);assert.equal(f.input.consumeKey(),0);
  f.set();f.set([0,0,0,0],[6,2,5]);
  assert.equal(f.input.snapshot().attack,true);assert.equal(f.input.snapshot().guard,true);assert.equal(f.input.consumeKey(),0);
  f.set([0,0,0,0],[6,1]);assert.equal(f.input.consumeKey(),32);assert.equal(f.input.snapshot().whirlwind,false);
  f.input.clear();f.hud.arts.targeting=true;f.set();f.set([0,0,0,0],[7]);
  assert.equal(f.input.consumeKey(),0);assert.equal(f.input.snapshot().whirlwind,false);
});

test('relocated skills and L2 spell directions do not also fire the unmodified action',()=>{
  for(const [buttons,key] of [[[4],86],[[6,12],53],[[6,14],54],[[6,15],56]]){
    const f=fixture();f.set([0,0,0,0],buttons);
    assert.equal(f.input.consumeKey(),key);assert.equal(f.input.consumeKey(),0);
    assert.equal(f.input.snapshot().guard,false);assert.equal(f.input.snapshot().attack,false);
  }
});

test('mage primary pad slots cast lightning and target an explosion without channeling whirlwind',()=>{
  const f=fixture();
  f.hud.skills=[{key:53,hold:''},{key:84,hold:''},{key:51,hold:''},{key:52,hold:''}];
  f.set([0,0,0,0],[3]);assert.equal(f.input.consumeKey(),53);assert.equal(f.input.consumeKey(),0);
  f.set();f.set([0,0,0,0],[7]);
  assert.equal(f.input.consumeKey(),84);assert.equal(f.input.snapshot().whirlwind,false);
  f.set([0,0,0,0],[7]);assert.equal(f.input.consumeKey(),0);
});

test('all customized pad slots support independent holds and release on context changes',()=>{
  const f=fixture();f.hud.skills=[{key:50,hold:'whirlwind'},{key:70,hold:'guard'},{key:74,hold:'attack'},{key:50,hold:'whirlwind'}];
  for(const [buttons,action] of [[[3],'whirlwind'],[[7],'guard'],[[4],'attack'],[[6,13],'whirlwind']]){
    f.set();f.set([0,0,0,0],buttons);assert.equal(f.input.snapshot()[action],true);
    f.hud.paused=true;f.set([0,0,0,0],buttons);assert.equal(f.input.snapshot()[action],false);
    f.hud.paused=false;f.set([0,0,0,0],buttons);assert.equal(f.input.snapshot()[action],false);
  }
});


test('inventory routes navigation, equip, rotation and discard without leaking combat buttons',()=>{
  const events=[];
  const f=fixture(action=>{if(!['open','sync'].includes(action))events.push(action);return action!=='cancel';});
  f.hud.menu='inventory';f.set();
  for(const [button,action] of [[15,'right'],[0,'confirm'],[2,'equip'],[3,'rotate'],[4,'previous'],[5,'next'],[11,'drop']]){
    f.set();f.set([0,0,0,0],[button]);assert.equal(events.at(-1),action);
    assert.equal(f.input.snapshot().attack,false);assert.equal(f.input.snapshot().guard,false);
    assert.equal(f.input.consumeKey(),0);
  }
  assert.equal(f.confirms(),0);assert.deepEqual(f.navigation,[]);
  f.set();f.set([0,0,0,0],[1]);assert.equal(events.at(-1),'cancel');assert.equal(f.input.consumeKey(),27);
});

test('inventory right stick requests comparison navigation without moving the player or camera',()=>{
  const events=[];const f=fixture((action,value)=>{events.push([action,value]);return true;});
  f.hud.menu='inventory';f.set();f.set([0,0,0,1]);
  const scroll=events.find(([action])=>action==='scroll');
  assert.ok(scroll?.[1]>0);
  assert.equal(f.input.snapshot().y,0);assert.deepEqual(f.look,[]);
});

test('cross picks one nearby drop only in play and is suppressed across confirmation contexts',()=>{
  const f=fixture();f.hud.loot=[{id:17,nearest:true,reachable:true}];
  f.set([0,0,0,0],[0]);assert.equal(f.input.consumeKey(),204);assert.equal(f.input.selection(),0);
  f.set([0,0,0,0],[0]);assert.equal(f.input.consumeKey(),0);
  assert.equal(f.input.snapshot().attack,false);
  f.hud.arts.targeting=true;f.set();f.set([0,0,0,0],[0]);assert.equal(f.input.consumeKey(),13);
  f.hud.arts.targeting=false;f.set([0,0,0,0],[0]);assert.equal(f.input.consumeKey(),0);
  f.set();f.set([0,0,0,0],[0]);assert.equal(f.input.consumeKey(),204);
});
