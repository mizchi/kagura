import test from 'node:test';
import assert from 'node:assert/strict';
import {createControlInput} from '../../../../assets/web/kagura-controls.js';
import {createHunterInput} from '../assets/hunter-input.mjs';
import {bindHunterAim} from '../assets/hunter-aim.mjs';

test('mouse aim survives WASD, switches on keyboard attack or touch, and ignores HUD hover',()=>{
  const document=new EventTarget(),window=new EventTarget(),stage=new EventTarget(),hud={contains:target=>target===hud};
  document.defaultView=window;stage.ownerDocument=document;
  stage.contains=target=>target===stage;
  stage.getBoundingClientRect=()=>({left:20,top:30,width:1000,height:800});
  const input=createHunterInput(createControlInput());
  const dispose=bindHunterAim({stage,hud,input,enabled:()=>true});
  function pointer(type,pointerType='mouse',target=stage,buttons=0){
    const event=new Event(type);Object.defineProperty(event,'target',{value:target});
    Object.assign(event,{pointerType,buttons,clientX:820,clientY:270});document.dispatchEvent(event);
  }
  function key(code){window.dispatchEvent(Object.assign(new Event('keydown'),{code}));}
  pointer('pointermove');assert.deepEqual(input.pointerAim(),{x:.8,y:.3});
  key('KeyW');assert.notEqual(input.pointerAim(),null);
  key('KeyJ');assert.equal(input.pointerAim(),null);
  pointer('pointerdown','mouse',stage,1);key('KeyJ');assert.notEqual(input.pointerAim(),null);
  pointer('pointerup');key('KeyJ');assert.equal(input.pointerAim(),null);
  pointer('pointermove');pointer('pointermove','mouse',hud);assert.equal(input.pointerAim(),null);
  pointer('pointermove');pointer('pointerdown','touch',hud);assert.equal(input.pointerAim(),null);
  pointer('pointermove');window.dispatchEvent(new Event('blur'));assert.equal(input.pointerAim(),null);
  dispose();assert.equal(input.pointerAim(),null);
});
