import test from 'node:test';
import assert from 'node:assert/strict';
import {createControlInput, stickVector, bindVirtualStick} from './kagura-controls.js';

test('stick normalizes diagonal movement, has a configurable dead zone and validates dimensions', () => {
  assert.deepEqual(stickVector(2, 3, 50), {x:0, y:0});
  const slow=stickVector(25, 0, 50);
  assert.ok(slow.x>0 && slow.x<1);
  assert.ok(Math.abs(Math.hypot(...Object.values(stickVector(100, -100, 50)))-1)<1e-8);
  assert.deepEqual(stickVector(25, 0, 50, {deadZone:0}), {x:.5,y:0});
  assert.throws(()=>stickVector(0,0,0), RangeError);
});

test('pointer ownership and arbitrary held actions are independent of a game', () => {
  const input=createControlInput();
  assert.equal(input.move(1,.5,-.5),true);
  assert.equal(input.move(2,1,1),false);
  input.hold(3,'fire'); input.hold(4,'fire'); input.hold(5,'guard');
  input.release(3); input.release(2);
  assert.deepEqual(input.snapshot(), {x:.5,y:-.5,actions:['fire','guard']});
  input.release(1);
  assert.equal(input.snapshot().x,0);
  input.clear();
  assert.deepEqual(input.snapshot(), {x:0,y:0,actions:[]});
});

test('bounded commands retain payloads and insert a release tick between repeated presses', () => {
  const input=createControlInput({capacity:2});
  assert.equal(input.tap(13,{slot:2}),true);
  assert.equal(input.tap(13,{slot:4}),true);
  assert.equal(input.tap(32),false);
  assert.deepEqual(input.consumeCommand(),{key:13,payload:{slot:2}});
  assert.equal(input.consumeCommand(),null);
  assert.deepEqual(input.consumeCommand(),{key:13,payload:{slot:4}});
  input.clear();
  assert.equal(input.consumeCommand(),null);
});

test('virtual stick releases on cancellation, blur and disposal without releasing another action', () => {
  const host=new EventTarget();
  const document=new EventTarget(); document.defaultView=host;
  const element=new EventTarget(); element.ownerDocument=document;
  element.getBoundingClientRect=()=>({x:0,y:0,width:100,height:100});
  const captured=new Set();
  element.setPointerCapture=id=>captured.add(id);
  element.hasPointerCapture=id=>captured.has(id);
  element.releasePointerCapture=id=>captured.delete(id);
  const input=createControlInput(); input.hold(99,'guard');
  const positions=[];
  const controller=bindVirtualStick(element,{input,radius:50,onChange:p=>positions.push(p)});
  const send=(type,id=1)=>element.dispatchEvent(Object.assign(new Event(type,{cancelable:true}),{pointerId:id,clientX:100,clientY:50}));
  send('pointerdown'); assert.equal(input.snapshot().x,1);
  send('pointerdown',2); send('pointercancel',2); assert.equal(input.snapshot().x,1);
  host.dispatchEvent(new Event('blur')); assert.equal(input.snapshot().x,0);
  send('pointerdown'); send('lostpointercapture'); assert.equal(input.snapshot().x,0);
  send('pointerdown'); controller.dispose(); send('pointerdown');
  assert.deepEqual(input.snapshot(),{x:0,y:0,actions:['guard']});
  assert.deepEqual(positions.at(-1),{x:0,y:0});
});
