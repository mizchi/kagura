import {test} from 'node:test';
import assert from 'node:assert/strict';
import {readFile} from 'node:fs/promises';
import {createHash} from 'node:crypto';
import {restoreMotionSource} from '../../../../scripts/motion/fbx.mjs';
import {emitMoonBitClip} from '../../../../scripts/motion/retarget.mjs';
import {bakeGameMotion} from './bake-game-motion.mjs';
const root=new URL('../motions/',import.meta.url);
const json=async path=>JSON.parse(await readFile(new URL(path,root),'utf8'));
const code=s=>s.replace(/\/\/[^\n]*/g,'').replace(/[\s,]/g,'');

test('checked-in HY motion sources reproduce the game clips offline',async()=>{
 const manifest=await json('manifest.json');
 const generated=code(await readFile(new URL('../app/enemy_motion_generated.mbt',root),'utf8'));
 assert.equal(manifest.clips.length,4);
 for(const entry of manifest.clips){
  const raw=await json(`source/${entry.name}/source-motion.json`);
  assert.equal(raw.fbxSha256,entry.sha256);
  assert.equal(createHash('sha256').update(JSON.stringify(raw)).digest('hex'),entry.sourceSha256);
  const source=restoreMotionSource(raw);
  const result=bakeGameMotion(source,source.animations[0],manifest.profile,entry.options);
  assert.deepEqual(result,await json(`${entry.name}.clip.json`));
  assert.ok(generated.includes(code(emitMoonBitClip(result))),`${entry.name}: rebuild MoonBit with just hunter-motions-build`);
  assert.ok(result.rootY.every(y=>Number.isFinite(y)&&Math.abs(y)<.35));
 }
});


test('bowstring draws back and the nocked arrow disappears on the gameplay release',async()=>{
 const clip=await json('bow_shot.clip.json');
 const [string,arrow]=clip.extraChannels;
 assert.equal(string.joint,14);
 assert.ok(string.values[23*3+2]<-.30,'string is pulled behind the grip');
 assert.equal(arrow.interpolation,'Step');
 assert.deepEqual(arrow.values.slice(23*3,24*3),[1,1,1]);
 assert.deepEqual(arrow.values.slice(24*3,25*3),[0,0,0]);
 assert.deepEqual(arrow.values.slice(-3),[0,0,0]);
});
