import test from 'node:test';
import assert from 'node:assert/strict';
import {createCameraInput,bindTouchCamera} from '../assets/hunter-camera.mjs';

test('slider coalescing preserves mode/reset order and camera input never becomes a gameplay intent',()=>{
  const camera=createCameraInput();
  camera.command(1,30);camera.command(1,40);camera.command(0,1);camera.command(1,12);camera.command(6,0);
  camera.command(1,NaN);camera.command(12,0);
  assert.deepEqual([camera.consumeCommand(),camera.consumeCommand(),camera.consumeCommand(),camera.consumeCommand(),camera.consumeCommand()],[[1,40],[0,1],[1,12],[6,0],[]]);
  camera.look(.2,.1);camera.look(.1,-.1);
  const look=camera.consumeLook();assert.ok(Math.abs(look[0]-.3)<1e-10);assert.equal(look[1],0);
  assert.deepEqual(camera.consumeLook(),[]);
  camera.command(2,5);camera.look(1,1);camera.clear();
  assert.deepEqual(camera.consumeCommand(),[]);assert.deepEqual(camera.consumeLook(),[]);
});

test('camera preferences debounce disk writes and flush the last setting before navigation',()=>{
  const writes=[],timers=new Map();let id=0;
  const camera=createCameraInput({save:value=>writes.push(value),schedule:fn=>{timers.set(++id,fn);return id;},cancel:id=>timers.delete(id)});
  camera.save('first');camera.save('latest');assert.equal(timers.size,1);assert.deepEqual(writes,[]);
  camera.flush();assert.deepEqual(writes,['latest']);assert.equal(timers.size,0);
  camera.flush();assert.deepEqual(writes,['latest']);
});

test('touch look belongs only to its initiating finger, stops when paused and cancels cleanly',()=>{
  const stage=new EventTarget();stage.ownerDocument={defaultView:new EventTarget()};stage.setPointerCapture=()=>{};
  const camera=createCameraInput();let enabled=true;
  bindTouchCamera(stage,camera,()=>enabled);
  const send=(type,id,x,y,pointerType='touch')=>stage.dispatchEvent(Object.assign(new Event(type),{pointerType,pointerId:id,clientX:x,clientY:y}));
  send('pointerdown',1,0,0);send('pointermove',2,30,40);assert.deepEqual(camera.consumeLook(),[]);
  send('pointerup',2,30,40);
  send('pointermove',1,20,10);assert.deepEqual(camera.consumeLook(),[.16,.06]);
  enabled=false;send('pointermove',1,50,50);assert.deepEqual(camera.consumeLook(),[]);
  send('pointercancel',1,50,50);enabled=true;send('pointermove',1,80,80);assert.deepEqual(camera.consumeLook(),[]);
  send('pointerdown',3,0,0);send('pointermove',3,10,20);send('pointerup',3,10,20);
  assert.deepEqual(camera.consumeLook(),[.08,.12]);
});
