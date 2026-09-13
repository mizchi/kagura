import {test} from 'node:test';
import assert from 'node:assert/strict';
import {createTerrainInput,renderTerrainPanel} from '../assets/hunter-terrain.mjs';

test('terrain transport keeps only the latest complete request and owns its values',()=>{
  const input=createTerrainInput();
  const values=[1,42,4,18,.5];
  input.generate(values);values[1]=99;
  assert.deepEqual(input.consume(),[1,42,4,18,.5]);
  input.generate([2,43,5,24,.6]);input.generate([3,43,5,24,.6]);
  input.generate([3,NaN,5,24,.6]);input.generate([1]);
  assert.deepEqual(input.consume(),[3,43,5,24,.6]);
  assert.deepEqual(input.consume(),[]);
});

test('terrain comparison exposes all patterns and marks parameters not used by pure cellular noise',()=>{
  const html=renderTerrainPanel({pattern:3,seed:42,amplitude:4,scale:18,roughness:.5,generation_ms:25,stats:{minimum:0,maximum:3,max_slope:.5,triangles:100}});
  for(const name of ['平坦','Perlin','Diamond Square','Voronoi','Voronoi + Perlin'])assert.ok(html.includes(name));
  assert.match(html,/data-terrain-field="4"[^>]*disabled/);
  assert.ok(html.includes('生成して比較'));
});
