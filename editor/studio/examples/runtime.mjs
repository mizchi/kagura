import { initWebGPU, setupGlobalState, loadFonts, loadGameScript } from './lib/kagura-init.js';
import { installAudioHelpers } from './lib/kagura-audio.js';
import { installGfxHelpers } from './lib/kagura-gfx.js';
import { assetURL } from './assets.mjs';

const send = (type, extra = {}) =>
  parent.postMessage({ type, version: 1, ...extra }, location.origin);
let initialized = false;
function fail(error) {
  const message = error?.message ?? String(error);
  const box = document.querySelector('#error');
  box.hidden = false;
  box.textContent = message;
  send('kagura:example-error', { message });
}
addEventListener('error', (event) => fail(event.error ?? event.message));
addEventListener('unhandledrejection', (event) => fail(event.reason));
addEventListener('message', async (event) => {
  if (
    event.source !== parent ||
    event.origin !== location.origin ||
    event.data?.version !== 1 ||
    event.data.type !== 'kagura:example-init' ||
    initialized
  )
    return;
  initialized = true;
  try {
    const { script, assets, project, scene } = event.data;
    if (scene && project.game && scene.game !== project.game)
      throw Error('Project game does not match runtime scene');
    globalThis.__kaguraProject = structuredClone(project);
    const { width, height } = project.display;
    // A game adapter compiles the shared scene before this runtime starts. No live editor objects cross the boundary.
    globalThis.__kaguraSceneProject = event.data.sceneProject
      ? structuredClone(event.data.sceneProject)
      : null;
    globalThis.__kaguraScene = scene ? structuredClone(scene) : null;
    const canvas = document.querySelector('#app');
    canvas.width = width;
    canvas.height = height;
    const originalFetch = globalThis.fetch.bind(globalThis);
    globalThis.fetch = (input, options) => {
      const url = assetURL(
        input instanceof Request ? input.url : String(input),
        location.href,
        assets,
      );
      return originalFetch(
        url ? (input instanceof Request ? new Request(url, input) : url) : input,
        options,
      );
    };
    const gpu = await initWebGPU('#app');
    if (!gpu) throw Error('WebGPUを初期化できませんでした');
    setupGlobalState(gpu.canvas, gpu.device, gpu.format, gpu.context);
    installAudioHelpers();
    installGfxHelpers();
    await loadFonts(
      Object.keys(assets)
        .filter((path) => /\.(ttf|otf)$/i.test(path))
        .map((path) => [path, assets[path]]),
    );
    await loadGameScript(script);
    if (
      scene &&
      (globalThis.kaguraSceneRuntime?.apiVersion !== 1 ||
        globalThis.kaguraSceneRuntime?.game !== scene.game)
    )
      throw Error('This runtime did not accept the game scene');
    await new Promise((resolve) => requestAnimationFrame(() => requestAnimationFrame(resolve)));
    globalThis.kaguraExample = Object.freeze({
      renderer: 'kagura-webgpu',
      project: structuredClone(project),
    });
    send('kagura:example-ready');
    canvas.focus();
  } catch (error) {
    fail(error);
  }
});
send('kagura:example-request');
