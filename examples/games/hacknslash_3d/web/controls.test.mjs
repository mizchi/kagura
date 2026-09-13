import test from 'node:test';
import assert from 'node:assert/strict';
import { createHunterInput, skillStatus } from '../assets/hunter-input.mjs';

import {createControlInput} from '../../../../assets/web/kagura-controls.js';

test('selecting a tree node carries an index without a confirmation key', () => {
  const input=createHunterInput(createControlInput());
  input.select(5);
  input.tap(13,5);
  assert.equal(input.consumeKey(),0);
  assert.equal(input.selection(),5);
  assert.equal(input.consumeKey(),0);
  assert.equal(input.selection(),-1);
  assert.equal(input.consumeKey(),13);
  assert.equal(input.selection(),5);
});

test('multitouch owns independent actions; cancellation releases every held input', () => {
  const input=createHunterInput(createControlInput());
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

test('inventory moves carry an immutable intent without synthetic game keys', () => {
  const input=createHunterInput(createControlInput());
  const move={source:2,target:-1,x:5,y:1,rotated:true};
  input.moveItem(move);
  move.x=99;
  assert.equal(input.consumeKey(),0);
  assert.deepEqual(input.inventoryMove(),{source:2,target:-1,x:5,y:1,rotated:true});
  assert.equal(input.selection(),-1);
  input.consumeKey();
  assert.equal(input.inventoryMove(),null);
  input.moveItem(move);input.clear();input.consumeKey();
  assert.equal(input.inventoryMove(),null);
});
