import { test } from 'node:test';
import assert from 'node:assert/strict';
import { fitGameViewport, installGamePresentation } from './kagura-presentation.js';

test('fullscreen contain uses the maximum viewport area without stretching or cropping', () => {
  assert.deepEqual(fitGameViewport(1600,900,4/3),{x:200,y:0,width:1200,height:900});
  assert.deepEqual(fitGameViewport(600,900,4/3),{x:0,y:225,width:600,height:450});
  assert.deepEqual(fitGameViewport(1280,720,16/9),{x:0,y:0,width:1280,height:720});
  assert.throws(()=>fitGameViewport(0,900,4/3),/positive/);
});

test('engine declares one capture canvas and keeps the contract current after resize', () => {
  const listeners = new Map();
  const host = {innerWidth:1600,innerHeight:900,addEventListener:(k,v)=>listeners.set(k,v),removeEventListener:k=>listeners.delete(k)};
  const attrs=new Map();
  const canvas={width:640,height:480,style:{cssText:''},getAttribute:k=>attrs.get(k)??null,
    setAttribute:(k,v)=>attrs.set(k,v),removeAttribute:k=>attrs.delete(k),
    getBoundingClientRect:()=>({x:200,y:0,width:1200,height:900}),ownerDocument:{defaultView:host}};
  const presentation=installGamePresentation(canvas,{mode:'fullscreen',aspectRatio:4/3});
  assert.equal(attrs.get('data-kagura-capture'),'game');
  assert.equal(canvas.style.width,'1200px');
  assert.equal(presentation.captureTarget().selector,'canvas[data-kagura-capture="game"]');
  assert.deepEqual(presentation.captureTarget().pixels,{width:640,height:480});
  host.innerWidth=600;
  listeners.get('resize')();
  assert.equal(canvas.style.width,'600px');
  assert.equal(canvas.style.top,'225px');
  presentation.dispose();
  assert.equal(listeners.size,0);
  assert.equal(attrs.has('data-kagura-capture'),false);
  assert.equal(canvas.style.cssText,'');
});

test('embedded layout is preserved, capture reads live backing pixels, and ownership transfers cleanly', () => {
  const host={};
  const makeCanvas=()=>{
    const attrs=new Map();
    return {width:640,height:480,style:{cssText:'width: 320px;'},
      getAttribute:k=>attrs.get(k)??null,setAttribute:(k,v)=>attrs.set(k,v),removeAttribute:k=>attrs.delete(k),
      getBoundingClientRect:()=>({x:10,y:20,width:320,height:240}),ownerDocument:{defaultView:host}};
  };
  const first=makeCanvas();
  const presentation=installGamePresentation(first);
  assert.equal(first.style.cssText,'width: 320px;');
  assert.equal(presentation.captureTarget().renderedFrames,0);
  first.width=1280;
  first.height=960;
  host.__kaguraWebRuntime={canvas:first,webgpu:{_submittedFrameCount:3}};
  assert.deepEqual(presentation.captureTarget().pixels,{width:1280,height:960});
  assert.equal(presentation.captureTarget().renderedFrames,3);
  const second=makeCanvas();
  const replacement=installGamePresentation(second);
  assert.equal(first.getAttribute('data-kagura-capture'),null);
  assert.equal(second.getAttribute('data-kagura-capture'),'game');
  assert.equal(replacement.captureTarget().renderedFrames,0);
  assert.throws(()=>presentation.captureTarget(),/disposed/);
  presentation.dispose();
  assert.equal(host.__kaguraPresentation,replacement);
  replacement.dispose();
  assert.equal(host.__kaguraPresentation,undefined);
});

test('responsive games fill a portrait viewport and capture their canvas plus DOM HUD as one surface', () => {
  const attrs=new Map();
  const host={innerWidth:390,innerHeight:844,addEventListener(){},removeEventListener(){}};
  const surface={getAttribute:k=>attrs.get(k)??null,setAttribute:(k,v)=>attrs.set(k,v),removeAttribute:k=>attrs.delete(k),
    getBoundingClientRect:()=>({x:0,y:0,width:390,height:844})};
  const canvas={width:640,height:480,style:{cssText:''},getAttribute:k=>k==='data-kagura-fit'?'viewport':null,
    closest:()=>surface,ownerDocument:{defaultView:host}};
  const p=installGamePresentation(canvas,{mode:'fullscreen'});
  assert.equal(canvas.style.width,'390px');
  assert.equal(canvas.style.height,'844px');
  assert.equal(p.captureTarget().selector,'[data-kagura-capture="game"]');
  assert.deepEqual(p.captureTarget().rect,{x:0,y:0,width:390,height:844});
  p.dispose();
  assert.equal(attrs.has('data-kagura-capture'),false);
});
