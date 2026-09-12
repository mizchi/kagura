import test from 'node:test';
import assert from 'node:assert/strict';
import { createHunterInput, stickVector, skillStatus } from '../assets/hunter-input.mjs';

test('stick has a dead zone, proportional movement and a circular speed limit', () => {
  assert.deepEqual(stickVector(2,3,50),{x:0,y:0});
  const slow=stickVector(25,0,50);
  assert.ok(slow.x>0 && slow.x<1);
  const fast=stickVector(100,-100,50);
  assert.ok(Math.abs(Math.hypot(fast.x,fast.y)-1)<1e-8);
  assert.ok(fast.x>0 && fast.y<0);
});
test('multitouch owns independent actions; cancellation releases every held input', () => {
  const input=createHunterInput();
  input.move(7,.5,-.5);
  input.hold(8,'attack');
  input.hold(9,'attack');
  input.release(8);
  assert.equal(input.snapshot().attack,true);
  assert.equal(input.snapshot().x,.5);
  input.release(7);
  assert.equal(input.snapshot().x,0);
  assert.equal(input.snapshot().attack,true);
  input.tap(49);
  assert.equal(input.consumeKey(),49);
  assert.equal(input.consumeKey(),0);
  input.clear();
  assert.equal(input.snapshot().attack,false);
  input.tap(13,2);
  input.tap(13,4);
  assert.equal(input.consumeKey(),13);
  assert.equal(input.selection(),2);
  assert.equal(input.consumeKey(),0);
  assert.equal(input.selection(),-1);
  assert.equal(input.consumeKey(),13);
  assert.equal(input.selection(),4);
});
test('skill availability distinguishes ready, cooling down and unlearned', () => {
  assert.deepEqual(skillStatus({level:1,remaining:0,total:180}),{disabled:false,label:'使用可能',progress:0});
  assert.deepEqual(skillStatus({level:1,remaining:90,total:180}),{disabled:true,label:'1.5s',progress:.5});
  assert.equal(skillStatus({level:0,remaining:0,total:180}).label,'未習得');
});
