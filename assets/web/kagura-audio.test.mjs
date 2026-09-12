import test from 'node:test';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import {AudioFrameQueue, audioWorkletSource, createAudioBackend, advanceAudioWrite, closeAudio} from './kagura-audio.js';

test('audio underruns produce silence instead of looping previously played effects', () => {
  const q=new AudioFrameQueue(4,2);
  q.push(new Float32Array([.1,.2,.3,.4]));
  const out=[new Float32Array(4),new Float32Array(4)];
  q.pull(out);
  assert.deepEqual([...out[0]],[Math.fround(.1),Math.fround(.3),0,0]);
  assert.deepEqual([...out[1]],[Math.fround(.2),Math.fround(.4),0,0]);
  q.pull(out);q.pull(out);
  assert.deepEqual([...out[0]],[0,0,0,0]);
  q.push(new Float32Array([.5,.6]));q.pull(out);
  assert.deepEqual([...out[0]],[.5,0,0,0]);
});

test('audio overflow drops oldest frames in order and reset clears pending effects', () => {
  const q=new AudioFrameQueue(3,1);
  q.push(new Float32Array([1,2]));q.push(new Float32Array([3,4,5,6]));
  const out=[new Float32Array(4)];q.pull(out);
  assert.deepEqual([...out[0]],[4,5,6,0]);
  q.push(new Float32Array([7]));q.reset();q.pull(out);
  assert.deepEqual([...out[0]],[0,0,0,0]);
});

test('actual AudioWorklet uses the same queue and never replays stale PCM', () => {
  let Processor;
  vm.runInNewContext(audioWorkletSource(),{
    AudioWorkletProcessor:class {port={onmessage:null};},
    registerProcessor:(_name,klass)=>{Processor=klass;},
  });
  const p=new Processor();
  p.port.onmessage({data:{t:'i',s:4,c:1}});
  p.port.onmessage({data:{t:'w',d:new Float32Array([.5])}});
  const output=[[new Float32Array(4)]];
  p.process([],output);assert.deepEqual([...output[0][0]],[.5,0,0,0]);
  p.process([],output);assert.deepEqual([...output[0][0]],[0,0,0,0]);
});

test('fallback publishes engine PCM once and discards writes while suspended', t => {
  const descriptor = Object.getOwnPropertyDescriptor(globalThis, 'AudioContext');
  t.after(() => {
    if (descriptor) Object.defineProperty(globalThis, 'AudioContext', descriptor);
    else delete globalThis.AudioContext;
  });
  globalThis.AudioContext = class {
    state = 'running';
    destination = {};
    createScriptProcessor() { return {connect() {}, disconnect() {}}; }
    addEventListener(_name, callback) { this.stateChanged = callback; }
    close() { this.state = 'closed'; }
  };
  const audio = createAudioBackend(44100, 2);
  const output = [new Float32Array(4), new Float32Array(4)];
  const render = () => audio.node.onaudioprocess({outputBuffer: {getChannelData: c => output[c]}});
  audio.ring.set([.5, .25]); advanceAudioWrite(audio, 1);
  render(); assert.deepEqual([...output[0]], [.5, 0, 0, 0]);
  render(); assert.deepEqual([...output[0]], [0, 0, 0, 0]);
  audio.ctx.state = 'suspended'; audio.ctx.stateChanged();
  audio.ring.set([.75, .5], audio.writePos * 2); advanceAudioWrite(audio, 1);
  audio.ctx.state = 'running'; render();
  assert.deepEqual([...output[0]], [0, 0, 0, 0]);
  closeAudio(audio);
});
