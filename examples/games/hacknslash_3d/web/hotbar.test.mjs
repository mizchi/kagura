import test from 'node:test';
import assert from 'node:assert/strict';
import {createControlInput} from '../../../../assets/web/kagura-controls.js';
import {createHunterInput} from '../assets/hunter-input.mjs';
import {pressHunterSlot} from '../assets/hunter-hotbar.mjs';

test('any slot can hold attack, guard or whirlwind; releases only its own source',()=>{
  const input=createHunterInput(createControlInput());
  const hud={skills:[{key:50,hold:'whirlwind'},{key:70,hold:'guard'},{key:74,hold:'attack'},{key:84,hold:''}]};
  pressHunterSlot(input,hud,0,101);pressHunterSlot(input,hud,1,102);pressHunterSlot(input,hud,2,103);
  assert.equal(input.snapshot().whirlwind,true);assert.equal(input.snapshot().guard,true);assert.equal(input.snapshot().attack,true);
  input.release(101);assert.equal(input.snapshot().whirlwind,false);assert.equal(input.snapshot().guard,true);
  assert.equal(input.consumeKey(),70);assert.equal(input.consumeKey(),0);assert.equal(input.consumeKey(),74);assert.equal(input.consumeKey(),0);
  pressHunterSlot(input,hud,3,104);assert.equal(input.consumeKey(),84);assert.equal(input.consumeKey(),0);
  input.clear();assert.equal(input.snapshot().guard,false);assert.equal(input.snapshot().attack,false);
});

test('a short basic attack click remains queued after releasing before the next game frame',()=>{
  const input=createHunterInput(createControlInput());
  pressHunterSlot(input,{skills:[{key:74,hold:'attack'}]},0,1);input.release(1);
  assert.equal(input.snapshot().attack,false);assert.equal(input.consumeKey(),74);assert.equal(input.consumeKey(),0);
});
