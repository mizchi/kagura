import test from 'node:test';
import assert from 'node:assert/strict';
import {renderWorldMap} from '../assets/hunter-world-map.mjs';

test('waypoint controls respect reachability, discovery and action locks',()=>{
  const regions=['灰の森','赤錆の荒野','霧の湿地','鐘楼の廃墟'].map((name,id)=>({
    id,name,subtitle:'',x:id%2,z:Math.floor(id/2),tier:1,unlocked:id<2,visited:id<2,
  }));
  const base={cursor:1,weapon_locked:false,atlas:{regions,current:0,near_waypoint:true,travel_target:null}};
  const button=hud=>renderWorldMap(hud,{icon:()=>'',escape:s=>s}).match(/<button class="atlas-travel"[^>]*>[^<]*/)[0];
  assert.doesNotMatch(button(base),/disabled/);
  for(const hud of [
    {...base,cursor:0},
    {...base,cursor:2},
    {...base,weapon_locked:true},
    {...base,atlas:{...base.atlas,near_waypoint:false}},
    {...base,atlas:{...base.atlas,travel_target:1}},
  ]) assert.match(button(hud),/disabled/);
  assert.match(button({...base,weapon_locked:true}),/動作終了後/);
});
