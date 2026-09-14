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

test('expedition map shows elevation, risks and durable local return points',()=>{
  const regions=[{id:0,name:'灰の森',subtitle:'',x:0,z:0,tier:1,unlocked:true,visited:true}];
  const atlas={regions,current:0,near_waypoint:true,at_region_waypoint:true,travel_target:null,
    expedition:{name:'尾根の回廊',road_path:'M20 49L40 26',contours:''},
    anchors:[{id:0,name:'宿場跡',x:40,z:26,height:4,unlocked:true,reward:'レア装備'},
      {id:1,name:'野営地',x:29,z:32,height:1.5,unlocked:false,reward:'装備と回復'}]};
  const html=renderWorldMap({atlas,cursor:4,weapon_locked:false},{icon:()=>'',escape:s=>s});
  assert.match(html,/尾根の回廊/);
  assert.match(html,/解放 1 \/ 2/);
  assert.match(html,/data-expedition-site="0"[^>]*aria-pressed="true"/);
  assert.match(html,/data-expedition-site="1"[^>]*disabled/);
  assert.match(html,/レア装備/);
  const remote=renderWorldMap({atlas:{...atlas,near_waypoint:false},cursor:4},{icon:()=>'',escape:s=>s});
  assert.match(remote,/data-expedition-site="0"[^>]*disabled/);
});
