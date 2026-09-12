// Shared audio backend for JS and WASM targets.

/** A bounded interleaved PCM queue. Consumed frames never become audible again. */
export class AudioFrameQueue {
  constructor(capacity, channels) {
    this.capacity = capacity;
    this.channels = channels;
    this.samples = new Float32Array(capacity * channels);
    this.reset();
  }

  reset() {
    this.readPos = 0;
    this.writePos = 0;
    this.available = 0;
  }

  push(data) {
    const frames = Math.floor(data.length / this.channels);
    const first = Math.max(0, frames - this.capacity);
    const count = frames - first;
    const dropped = Math.max(0, this.available + count - this.capacity);
    this.readPos = (this.readPos + dropped) % this.capacity;
    this.available -= dropped;
    for (let i = first; i < frames; i++) {
      for (let c = 0; c < this.channels; c++) {
        this.samples[this.writePos * this.channels + c] = data[i * this.channels + c];
      }
      this.writePos = (this.writePos + 1) % this.capacity;
    }
    this.available += count;
  }

  pull(output) {
    if (!output.length) return;
    const count = Math.min(output[0].length, this.available);
    for (let c = 0; c < output.length; c++) {
      output[c].fill(0);
      if (c >= this.channels) continue;
      for (let i = 0; i < count; i++) {
        output[c][i] = this.samples[((this.readPos + i) % this.capacity) * this.channels + c];
      }
    }
    this.readPos = (this.readPos + count) % this.capacity;
    this.available -= count;
  }
}

export function audioWorkletSource() {
  return `${AudioFrameQueue.toString()}
class KaguraProcessor extends AudioWorkletProcessor {
  constructor() {
    super();
    this.queue = null;
    this.port.onmessage = ({data: m}) => {
      if (m.t === "i") this.queue = new AudioFrameQueue(m.s, m.c);
      else if (m.t === "w") this.queue?.push(m.d);
      else if (m.t === "r") this.queue?.reset();
    };
  }
  process(inputs, outputs) {
    if (this.queue) this.queue.pull(outputs[0]);
    return true;
  }
}
registerProcessor("kagura-processor", KaguraProcessor);`;
}

/** ScriptProcessor fallback with an asynchronous AudioWorklet upgrade. */
export function createAudioBackend(sampleRate, channels) {
  const AC = globalThis.AudioContext || globalThis.webkitAudioContext;
  if (!AC) return null;
  const ctx = new AC({ sampleRate });
  const ch = Number(channels) || 2;
  const bufSize = 1024;
  const ringSize = bufSize * 8;
  // The engine writes here before advanceAudioWrite publishes complete frames.
  const ring = new Float32Array(ringSize * ch);
  const queue = new AudioFrameQueue(ringSize, ch);
  const node = ctx.createScriptProcessor(bufSize, 0, ch);
  node.onaudioprocess = ({outputBuffer}) => {
    const output = Array.from({length: ch}, (_, c) => outputBuffer.getChannelData(c));
    queue.pull(output);
  };
  node.connect(ctx.destination);
  const audio = {
    ctx, node, ring, ringSize, queue, writePos: 0,
    readPos: () => queue.readPos,
    channels: ch, workletNode: null, useWorklet: false,
  };
  ctx.addEventListener('statechange', () => {
    if (ctx.state !== 'running') {
      queue.reset();
      audio.workletNode?.port.postMessage({t: 'r'});
    }
  });
  if (ctx.audioWorklet) {
    const blob = new Blob([audioWorkletSource()], {type: 'application/javascript'});
    const url = URL.createObjectURL(blob);
    ctx.audioWorklet.addModule(url).then(() => {
      if (!audio.ctx || ctx.state === 'closed') return;
      const wn = new AudioWorkletNode(ctx, 'kagura-processor', {outputChannelCount: [ch]});
      wn.port.postMessage({t: 'i', s: ringSize, c: ch});
      wn.connect(ctx.destination);
      node.disconnect();
      queue.reset();
      audio.workletNode = wn;
      audio.useWorklet = true;
    }).catch(() => {}).finally(() => URL.revokeObjectURL(url));
  }
  return audio;
}

/** Publish completed PCM to the active consumer, preserving the JS/WASM ABI. */
export function advanceAudioWrite(audio, frames) {
  if (!audio) return;
  const f = Number(frames) | 0;
  if (f <= 0) return;
  if (audio.ctx?.state === 'running') {
    const first = Math.max(0, f - audio.ringSize);
    const count = (f - first) * audio.channels;
    const buf = new Float32Array(count);
    const start = ((audio.writePos + first) % audio.ringSize) * audio.channels;
    for (let i = 0; i < count; i++) buf[i] = audio.ring[(start + i) % audio.ring.length];
    if (audio.useWorklet && audio.workletNode) {
      audio.workletNode.port.postMessage({t: 'w', d: buf}, [buf.buffer]);
    } else {
      audio.queue.push(buf);
    }
  }
  audio.writePos = (audio.writePos + f) % audio.ringSize;
}

export function closeAudio(audio) {
  if (!audio) return;
  if (audio.workletNode) { audio.workletNode.disconnect(); audio.workletNode = null; }
  if (audio.node) { audio.node.disconnect(); audio.node = null; }
  if (audio.ctx) { audio.ctx.close(); audio.ctx = null; }
  audio.queue.reset();
}

export function installAudioHelpers() {
  globalThis.__kaguraAudio = {
    create: createAudioBackend,
    advance: advanceAudioWrite,
    close: closeAudio,
  };
}
