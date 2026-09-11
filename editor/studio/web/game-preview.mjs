/** A game owns its Window, input, audio and GPU lifetime. Unloading releases the entire runtime. */
export function createGamePreview(container, { url, title, onActive, onStatus, projectSettings, resourceAssets = async () => ({}) }) {
  let frame,
    runtime,
    pending,
    settle,
    timer,
    settings,
    scene,
    detach,
    commandVersion = 0;
  function close() {
    commandVersion++;
    runtime?.pause();
    runtime = undefined;
    clearTimeout(timer);
    settle?.(false);
    settle = undefined;
    pending = undefined;
    detach?.();
    detach = undefined;
    if (frame) {
      frame.remove();
      frame = undefined;
    }
    container.classList.remove('game-active');
    onActive(false);
  }
  function open() {
    if (pending) return pending;
    container.classList.add('game-active');
    onActive(true);
    frame = document.createElement('iframe');
    frame.title = title;
    frame.className = 'game-frame';
    frame.allow = 'autoplay';
    const current = frame;
    pending = new Promise((resolve) => {
      settle = resolve;
    });
    function fail(message) {
      if (frame !== current) return;
      close();
      onStatus(message);
    }
    function ready() {
      if (frame !== current || !settle) return;
      try {
        runtime = frame.contentWindow.kaguraGame;
        if (
          !runtime ||
          !['configure', 'play', 'pause', 'reset', 'snapshot'].every(
            (key) => typeof runtime[key] === 'function',
          )
        )
          throw Error('Game runtime unavailable. WebGPUとゲームのビルドを確認してください。');
        runtime.configure(settings);
        if (scene) runtime.loadScene(scene, settings.ai);
        clearTimeout(timer);
        settle(true);
        settle = undefined;
        onStatus('IRON YARD · Ready');
      } catch (error) {
        fail(error.message);
      }
    }
    // Module top-level await can finish after iframe.load. The game explicitly announces readiness.
    const message = async (event) => {
      if (
        event.source !== current.contentWindow ||
        event.origin !== location.origin ||
        event.data?.version !== 1
      )
        return;
      if (event.data.type === 'kagura:request-assets') {
        try { const assets = await resourceAssets(); if (frame === current) current.contentWindow.postMessage({type:'kagura:assets',version:1,assets,project:projectSettings},location.origin); }
        catch (error) { fail(error.message); }
      }
      if (event.data.type === 'kagura:game-ready') ready();
      if (event.data.type === 'kagura:game-error') fail(String(event.data.message));
      if (event.data.type === 'kagura:game-exit') close();
    };
    window.addEventListener('message', message);
    detach = () => window.removeEventListener('message', message);
    frame.addEventListener('load', () => {
      if (frame === current && current.contentWindow.kaguraGame) ready();
    });
    frame.addEventListener('error', () => fail('Game could not be loaded'));
    timer = setTimeout(() => fail('Game loading timed out'), 30000);
    frame.src = url;
    container.append(frame);
    return pending;
  }
  return Object.freeze({
    open,
    close,
    configure(value) {
      commandVersion++;
      settings = structuredClone(value);
      runtime?.configure(settings);
    },
    loadScene(value) {
      commandVersion++;
      scene = structuredClone(value);
      if (runtime && scene) runtime.loadScene(scene, settings.ai);
    },
    async command(action) {
      if (!['play', 'pause', 'reset'].includes(action)) throw Error('Unknown preview action');
      const version = ++commandVersion;
      if (action === 'pause') {
        runtime?.pause();
        return;
      }
      if ((await open()) && version === commandVersion) runtime?.[action]();
    },
    snapshot: () => runtime?.snapshot() ?? null,
    dispose: close,
  });
}
