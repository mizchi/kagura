import './style.css';
import {createGameUI} from './ui.mjs';
import {initWebGPU, setupGlobalState} from '@kagura-web/kagura-init.js';
import {installGfxHelpers, setRenderTargetFormat, setRenderTargetSampleCount, setTextureOptions, setShaderRasterState, uploadTextureRGBA16F} from '@kagura-web/kagura-gfx.js';
import {installAudioHelpers} from '@kagura-web/kagura-audio.js';
import * as game from '../_build/js/release/build/mizchi/iron_yard/app/app.js';
import environmentURL from '../assets/source/room-pmrem.json?url';
import environmentDataURL from '../assets/source/room-pmrem.rgba16f?url';
import strixURL from '../assets/generated/strix.json?url';
import bastionURL from '../assets/generated/bastion.json?url';
import {PilotControls} from './controls.ts';
import {defaultSettings, validateSettings} from '../editor/contract.mjs';
import {validateSceneDocument} from '../editor/scene/contracts.ts';
import {runtimeRecipe} from '../editor/scene/runtime.mjs';

const authoring = new URLSearchParams(location.search).get('authoring') === '1';
if (authoring) document.documentElement.dataset.authoring = 'true';
const embedded = new URLSearchParams(location.search).get('editor') === '1';
if (embedded) document.documentElement.dataset.editor = 'true';
let authoringSettings;
let authoringScene;

const audioURLs = import.meta.glob('../assets/audio/*.wav', {eager: true, query: '?url', import: 'default'});
const canvas = document.getElementById('app');
const controls = new PilotControls();
function syncInput() {
  const i = controls.snapshot(), w = controls.weapons();
  game.set_input(i.forward, i.strafe, i.boost, i.jump, w.fire, w.lock, i.yaw, i.pitch);
}
const detach = authoring ? () => {} : controls.attach(canvas, active => {
  game.command(active ? 'start' : 'pause');
  syncInput();
});
for (const event of ['keydown', 'keyup', 'mousemove', 'mouseup']) window.addEventListener(event, syncInput);
canvas.addEventListener('mousedown', syncInput);
function reset(mode = 'reset') {
  controls.pause();
  controls.yaw = authoringSettings?.yaw ?? 0;
  controls.pitch = .25;
  if (authoringScene) {
    if (mode === 'training' || mode === 'combat') authoringSettings = {...authoringSettings, ai: mode === 'combat'};
    controls.yaw = 0;
    if (!game.load_scene(JSON.stringify(runtimeRecipe(authoringScene)), authoringSettings?.ai ?? true)) throw Error('シーンの読み込みに失敗しました');
  } else if (authoringSettings) {
    if (mode === 'training' || mode === 'combat') authoringSettings = {...authoringSettings, ai: mode === 'combat'};
    const s = authoringSettings;
    game.configure(s.ai, s.spawnX, s.spawnZ, s.yaw);
  } else game.command(mode);
  syncInput();
}
const ui = authoring ? {render(){},setReady(){},showError(error){document.body.textContent=error.message;}} : createGameUI({game, controls, reset});
globalThis.ironYardFrame = ui.render;

async function fetchAsset(url) {
  const response = await fetch(url);
  if (!response.ok) throw Error(`アセットの読み込みに失敗しました (${response.status})`);
  return response;
}
try {
  const gpu = await initWebGPU('#app');
  if (!gpu) throw Error('WebGPU対応のブラウザが必要です。');
  const runtime = setupGlobalState(gpu.canvas, gpu.device, gpu.format, gpu.context);
  runtime.maxDevicePixelRatio = 1.5;
  installGfxHelpers();
  installAudioHelpers();
  setRenderTargetFormat(runtime.webgpu, 900, 'rgba16float');
  setRenderTargetSampleCount(runtime.webgpu, 900, 4);
  for (const id of [102,103,105,106,107,108,109]) setShaderRasterState(runtime.webgpu,id,{depthCompare:'less-equal', ...(id===105?{cullMode:'front'}:{})});
  const overrides = (authoring || embedded) ? await new Promise((resolve, reject) => {
    const timer = setTimeout(() => { window.removeEventListener('message', listener); reject(Error('Editor asset initialization timed out')); }, 30000);
    function listener(event) {
      if (event.source !== parent || event.origin !== location.origin || event.data?.type !== 'kagura:assets' || event.data.version !== 1) return;
      clearTimeout(timer); window.removeEventListener('message', listener); globalThis.__kaguraProject = event.data.project ? structuredClone(event.data.project) : null; resolve(event.data.assets ?? {});
    }
    window.addEventListener('message', listener);
    parent.postMessage({type:'kagura:request-assets',version:1},location.origin);
  }) : {};
  const [strix, bastion, environment] = await Promise.all(
    [overrides.strix ?? strixURL, overrides.bastion ?? bastionURL, overrides.environment ?? environmentURL].map(async url => (await fetchAsset(url)).json()),
  );
  for (const [index, image] of bastion.images.entries()) {
    const blob = await (await fetchAsset(`data:${image.mime};base64,${image.data}`)).blob();
    const bitmap = await createImageBitmap(blob, {premultiplyAlpha: 'none'});
    const surface = new OffscreenCanvas(bitmap.width, bitmap.height);
    const ctx = surface.getContext('2d');
    ctx.drawImage(bitmap, 0, 0);
    const sampler=image.sampler;
    const wrap=mode=>({10497:'repeat',33071:'clamp-to-edge',33648:'mirror-repeat'})[mode??10497];
    setTextureOptions(runtime.webgpu,1000+index,{format:'rgba8unorm-srgb',
      magFilter:sampler.magFilter===9728?'nearest':'linear',minFilter:sampler.minFilter===9728?'nearest':'linear',
      addressModeU:wrap(sampler.wrapS),addressModeV:wrap(sampler.wrapT)});
    game.register_image(1000 + index, bitmap.width, bitmap.height, Array.from(ctx.getImageData(0, 0, bitmap.width, bitmap.height).data));
    bitmap.close();
  }
  for (const [path, url] of Object.entries(audioURLs)) {
    const bytes = new Uint8Array(await (await fetchAsset(overrides['audio.' + path.split('/').at(-1).replace('.wav','')] ?? url)).arrayBuffer());
    const name = path.split('/').at(-1).replace('.wav', '');
    if (!game.register_audio(name, bytes)) throw Error('音声を読み込めませんでした');
  }
  const environmentData = new Uint16Array(await (await fetchAsset(overrides.environmentData ?? environmentDataURL)).arrayBuffer());
  uploadTextureRGBA16F(runtime.webgpu, 2000, environment.width, environment.height, environmentData);
  game.start(JSON.stringify(strix), JSON.stringify(bastion));
  ui.setReady();
  globalThis.ironYard = Object.freeze({
    snapshot: () => JSON.parse(game.snapshot()),
    rendererInfo: () => {
      const info = JSON.parse(game.renderer_info());
      return {...info, images: info.images + Number(runtime.webgpu.textures.has(2000)),
        lightingProfile: 'three-r185-standard', antialias: 'msaa-4x', pixelRatio: runtime.dpr, environment: {width: environment.width, height: environment.height, format: environment.format}};
    },
    pause: () => controls.pause(),
    play: () => ui.play(),
    configure: settings => {
      authoringScene = undefined;
      authoringSettings = validateSettings(settings);
      document.getElementById('mode').value = authoringSettings.ai ? 'combat' : 'training';
      reset();
    },
    loadScene: (source, ai = true) => {
      const next = validateSceneDocument(source);
      authoringScene = next; authoringSettings = {...defaultSettings, ai};
      document.getElementById('mode').value = ai ? 'combat' : 'training';
      reset();
    },
    sceneDocument: () => authoringScene ? structuredClone(authoringScene) : null,
    reset: () => reset(),
    renderer: 'kagura-webgpu',
  });
  if (authoring) {
    globalThis.kaguraAuthoring = Object.freeze({
      renderer: 'kagura-webgpu',
      scene(source,wave=0) { const doc=validateSceneDocument(source); if(!Number.isInteger(wave)||wave<0||wave>=doc.mission.waves.length) throw Error('Invalid wave'); if(!game.editor_scene(JSON.stringify(runtimeRecipe(doc)),wave)) throw Error('Invalid editor scene'); },
      camera(eye,target) { if([...eye,...target].length!==6 || ![...eye,...target].every(Number.isFinite)) throw Error('Invalid camera'); game.editor_camera(...eye,...target); },
      selection(box) { game.editor_selection(...(box?.center ?? [0,0,0]),...(box?.size ?? [0,0,0])); },
      active: game.editor_active,
      attack(source,time) { if(!Number.isFinite(time)||time<0||time>1.5) throw Error('Invalid attack time'); const doc=validateSceneDocument(source); doc.stage.solids=[];doc.stage.spawn=[0,0,0];doc.stage.targets=[{id:'preview',position:[0,0,16],yaw:Math.PI}];doc.mission.waves=[{id:'preview',targets:['preview']}]; if(!game.editor_attack(JSON.stringify(runtimeRecipe(doc)),time)) throw Error('Invalid attack'); },
      snapshot: () => JSON.parse(game.snapshot()),
    });
    parent.postMessage({type:'kagura:authoring-ready',version:1},location.origin);
  } else if (embedded) {
    globalThis.kaguraGame = globalThis.ironYard;
    globalThis.ironYard.configure(defaultSettings);
    parent.postMessage({type: 'kagura:game-ready', version: 1}, location.origin);
  }
} catch (error) {
  ui.showError(error);
  if (embedded || authoring) parent.postMessage({type: 'kagura:game-error', version: 1, message: error.message}, location.origin);
  console.error(error);
}
if (import.meta.hot) import.meta.hot.dispose(() => {
  detach();
  for (const event of ['keydown', 'keyup', 'mousemove', 'mouseup']) window.removeEventListener(event, syncInput);
  canvas.removeEventListener('mousedown', syncInput);
  delete globalThis.ironYardFrame;
  location.reload();
});
