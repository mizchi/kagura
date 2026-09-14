import test from 'node:test';
import assert from 'node:assert/strict';
import {applyObjectPatch, createDependencyGate} from '../../assets/web/kagura-ui-sync.js';

test('patch replaces only changed fields and keeps null distinct from removal', () => {
  const original={hp:14, inventory:[1,2], menu:'inventory'};
  const next=applyObjectPatch(original,{full:false,set:{hp:13,menu:null},remove:['unused']});
  assert.equal(next.inventory,original.inventory);
  assert.equal(next.menu,null);
  assert.equal(original.hp,14);
  assert.deepEqual(applyObjectPatch(next,{full:true,set:{hp:1},remove:[]}),{hp:1});
  assert.deepEqual(applyObjectPatch(next,{full:false,set:{},remove:['inventory']}),{hp:13,menu:null});
});
test('patch treats prototype-like names as ordinary own keys', () => {
  const next=applyObjectPatch(null,JSON.parse('{"full":true,"set":{"__proto__":{"x":1}},"remove":[]}'));
  assert.equal(Object.getPrototypeOf(next),Object.prototype);
  assert.equal(Object.hasOwn(next,'__proto__'),true);
  assert.equal({}.x,undefined);
});
test('dependency gate updates immediately on changes including an external input mode', () => {
  const gate=createDependencyGate(); const list=[1];
  assert.equal(gate([list,1,false]),true);
  assert.equal(gate([list,1,false]),false);
  assert.equal(gate([list,1,true]),true);
  assert.equal(gate([list,2,true]),true);
  assert.equal(gate([[1],2,true]),true);
});
