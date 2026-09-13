import test from 'node:test';
import assert from 'node:assert/strict';
import {previewPlacement,rotatedCells} from '../assets/hunter-inventory.mjs';
const cleaver={source:0,slot:0,x:0,y:0,width:2,height:3,rotated:false,cells:[[0,0],[1,0],[0,1],[0,2]]};
const ring={source:1,slot:2,x:1,y:1,width:1,height:1,rotated:false,cells:[[0,0]]};
test('preview preserves L-shaped holes, bounds and own-cell movement',()=>{
  const view={width:4,height:4,items:[cleaver]};
  assert.equal(previewPlacement(view,ring,1,1,false).valid,true);
  assert.equal(previewPlacement(view,ring,0,1,false).swap,true);
  assert.equal(previewPlacement(view,cleaver,0,1,false).valid,true);
  assert.equal(previewPlacement(view,cleaver,3,0,false).valid,false);
  assert.deepEqual(rotatedCells(cleaver,true),[[2,0],[2,1],[1,0],[0,0]]);
});
test('preview rejects multiple overlaps and wrong-slot swaps when unequipping',()=>{
  const view={width:4,height:4,items:[ring,{...ring,source:2,x:2}]};
  assert.equal(previewPlacement(view,{...cleaver,source:3},1,1,false).valid,false);
  view.items.pop();
  assert.equal(previewPlacement(view,{...cleaver,source:3},1,1,false).valid,true);
  assert.equal(previewPlacement(view,{...cleaver,source:-1},1,1,false).valid,false);
});
