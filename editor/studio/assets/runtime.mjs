import { initWebGPU, setupGlobalState, loadGameScript } from './lib/kagura-init.js';
import { installGfxHelpers } from './lib/kagura-gfx.js';
const send = (type, extra = {}) =>
  parent.postMessage({ type, version: 1, ...extra }, location.origin);
let started = false,
  device;
globalThis.kaguraModelDispose = () => device?.destroy();
addEventListener('pagehide', globalThis.kaguraModelDispose);
const fail = (error) => send('kagura:model-error', { message: error?.message ?? String(error) });
addEventListener('error', (e) => fail(e.error ?? e.message));
addEventListener('unhandledrejection', (e) => fail(e.reason));
addEventListener('message', async (event) => {
  if (
    event.source !== parent ||
    event.origin !== location.origin ||
    event.data?.version !== 1 ||
    event.data.type !== 'kagura:model-init' ||
    started
  )
    return;
  started = true;
  try {
    const gpu = await initWebGPU('#app');
    if (!gpu) throw Error('WebGPUを初期化できませんでした');
    device = gpu.device;
    setupGlobalState(gpu.canvas, gpu.device, gpu.format, gpu.context);
    installGfxHelpers();
    await loadGameScript('./model-viewer.js');
    const { format, json, buffers, text } = event.data.model;
    const stats = kaguraModel.load(format, json, buffers, text);
    if (!stats.ok) throw Error(stats.message);
    await new Promise((resolve) => requestAnimationFrame(() => requestAnimationFrame(resolve)));
    send('kagura:model-ready', { stats });
  } catch (error) {
    fail(error);
  }
});
document.querySelector('#app').addEventListener('contextmenu', (e) => e.preventDefault());
send('kagura:model-request');
