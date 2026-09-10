import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { convertGLB } from '../scripts/convert-assets.mjs';

test('actual STRIX preserves every rigid skinned vertex, bone and animation', async () => {
  const asset = convertGLB(await readFile(new URL('../assets/source/strix.glb', import.meta.url)));
  assert.equal(asset.stats.sourceMeshes, 205);
  assert.equal(asset.batches.reduce((n,b) => n + b.vertices.length / 8, 0), 11572);
  assert.equal(asset.bones.length, 28);
  assert.ok(asset.bones.some(b => b.name === 'RightHand'));
  assert.deepEqual(asset.clips.map(c => c.name), ['Idle','Walk','Advance','Boost']);
  assert.ok(asset.batches.every(b => b.bone >= 0 && b.bone < 28));
  assert.ok(asset.batches.length < 205, 'batch compatible parts without dropping geometry');
  for (const b of asset.batches) assert.ok(b.indices.every(i => i >= 0 && i < b.vertices.length / 8));
});

test('actual BASTION preserves embedded textures, material and hierarchy transforms', async () => {
  const asset = convertGLB(await readFile(new URL('../assets/source/bastion.glb', import.meta.url)));
  assert.equal(asset.stats.sourceMeshes, 168);
  assert.equal(asset.stats.meshInstances, 296);
  assert.equal(asset.batches.reduce((n,b) => n + b.vertices.length / 8, 0), 35028);
  assert.equal(asset.images.length, 18);
  assert.ok(asset.batches.some(b => b.material.texture >= 0));
  assert.ok(asset.batches.some(b => b.material.alpha === 'BLEND'));
  assert.ok(asset.batches.some(b => b.material.metallic > 0));
  assert.ok(asset.batches.every(b => b.bone === -1));
  const ys = asset.batches.flatMap(b => b.vertices.filter((_,i) => i % 8 === 1));
  assert.ok(Math.min(...ys) > -.2 && Math.max(...ys) > 4 && Math.max(...ys) < 10);
});

test('native PMREM preserves finite HDR half-floats and the full CubeUV layout', async () => {
  const env=JSON.parse(await readFile(new URL('../assets/source/room-pmrem.json',import.meta.url)));
  const bytes=await readFile(new URL('../assets/source/room-pmrem.rgba16f',import.meta.url));
  assert.deepEqual([env.width,env.height,env.format,env.layout],[768,1024,'rgba16float','cube-uv']);
  assert.equal(bytes.length,env.width*env.height*8);
  let hdr=0,lit=0;
  for(let i=0;i<bytes.length;i+=2){const bits=bytes.readUInt16LE(i);assert.notEqual(bits&0x7c00,0x7c00);if(i%8!==6){if(bits>0x3c00)hdr++;if(bits>0)lit++;}}
  assert.ok(hdr>1000);assert.ok(lit>env.width*env.height);
});

test('BASTION keeps the GLB sampler contract for all 18 images', async()=>{
 const bytes=await readFile(new URL('../assets/source/bastion.glb',import.meta.url));
 const doc=JSON.parse(bytes.subarray(20,20+bytes.readUInt32LE(12))),asset=convertGLB(bytes);
 for(const t of doc.textures)assert.deepEqual(asset.images[t.source].sampler,doc.samplers[t.sampler]);
});
