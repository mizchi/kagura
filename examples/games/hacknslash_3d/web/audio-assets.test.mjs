import test from 'node:test';
import assert from 'node:assert/strict';
import {createHash} from 'node:crypto';
import {createSoundBank, encodeWav} from '../scripts/design-audio.mjs';

test('hunter sounds are distinct, reproducible PCM with headroom and smooth silent edges', () => {
  const bank=createSoundBank();
  assert.equal(bank.length,11);
  const hashes=new Set();
  for(const sound of bank){
    const {samples,sampleRate,channels}=sound;
    assert.equal(sampleRate,44100);
    assert.equal(channels,2);
    assert.equal(samples.length % channels,0);
    const seconds=samples.length/channels/sampleRate;
    assert.ok(seconds>=.12 && seconds<=2.5,sound.id);
    let peak=0,energy=0,mean=0;
    for(const x of samples){assert.ok(Number.isFinite(x));peak=Math.max(peak,Math.abs(x));energy+=x*x;mean+=x;}
    assert.ok(peak>.15 && peak<=.66,`${sound.id}: peak ${peak}`);
    assert.ok(Math.sqrt(energy/samples.length)>.025,`${sound.id}: audible body`);
    assert.ok(Math.abs(mean/samples.length)<.003,`${sound.id}: no DC offset`);
    assert.ok(Math.abs(samples[0])<.0001 && Math.abs(samples.at(-1))<.0001,`${sound.id}: no edge clicks`);
    assert.ok(Math.max(...samples.slice(-440).map(Math.abs))<.015,`${sound.id}: quiet tail`);
    const wav=encodeWav(sound);
    assert.equal(wav.toString('ascii',0,4),'RIFF');
    assert.equal(wav.readUInt32LE(24),44100);
    assert.equal(wav.readUInt16LE(22),2);
    const hash=createHash('sha256').update(wav).digest('hex');
    assert.ok(!hashes.has(hash),'every action has its own sound');hashes.add(hash);
  }
  const again=createSoundBank();
  assert.deepEqual(encodeWav(bank[0]),encodeWav(again[0]));
});
