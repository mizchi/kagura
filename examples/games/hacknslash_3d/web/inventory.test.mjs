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


test('hover comparison uses the matching body slot and shows losses, gains and removed modifiers',async()=>{
  const {comparisonRows}=await import('../assets/hunter-item-comparison.mjs');
  const candidate={slot:0,stats:[['攻撃力',10],['防御力',0],['会心率 %',8]]};
  const view={equipment:[{id:1,item:{stats:[['攻撃力',999]]}},{id:0,item:{name:'古い槍',stats:[['防御力',3],['攻撃力',6],['会心率 %',0]]}}]};
  assert.deepEqual(comparisonRows(view,candidate),[
    {label:'攻撃力',value:10,before:6,delta:4},
    {label:'防御力',value:0,before:3,delta:-3},
    {label:'会心率 %',value:8,before:0,delta:8},
  ]);
  assert.equal(comparisonRows({equipment:[]},candidate)[0].before,0);
});

test('ground drop is only the visible margin outside the inventory dialog',async()=>{
  const {isInventoryGroundDrop}=await import('../assets/hunter-inventory-grid.mjs');
  const dialog={left:40,top:30,right:360,bottom:600};
  const surface={left:0,top:0,right:400,bottom:680};
  assert.equal(isInventoryGroundDrop(20,200,dialog,surface),true);
  assert.equal(isInventoryGroundDrop(200,640,dialog,surface),true);
  assert.equal(isInventoryGroundDrop(200,200,dialog,surface),false);
  assert.equal(isInventoryGroundDrop(40,30,dialog,surface),false);
  assert.equal(isInventoryGroundDrop(-1,200,dialog,surface),false);
  assert.equal(isInventoryGroundDrop(200,680,dialog,surface),false);
  assert.equal(isInventoryGroundDrop(20,200,null,surface),false);
});

test('comparison pages retain every modifier, while hover still shows the complete comparison',async()=>{
  const {comparisonMarkup}=await import('../assets/hunter-item-comparison.mjs');
  const item={slot:0,source:0,stats:Array.from({length:10},(_,i)=>['modifier-'+i,i+1])};
  const view={equipment:[]},escape=s=>s;
  for(const page of [0,1,2]){
    const html=comparisonMarkup(view,item,escape,{page,pageSize:4});
    for(let i=0;i<10;i++)assert.equal(html.includes('modifier-'+i),Math.floor(i/4)===page);
    assert.ok(html.includes(`補正 ${page+1} / 3`));
  }
  const hover=comparisonMarkup(view,item,escape);
  for(let i=0;i<10;i++)assert.ok(hover.includes('modifier-'+i));
  assert.ok(!hover.includes('data-inv-action'));
});
