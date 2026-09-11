/** One isolated Kagura renderer per mounted model. All listeners/GPU resources are scoped to it. */
export function createModelFrame(element, model) {
  const frame = document.createElement('iframe');
  frame.className = 'model-frame';
  frame.title = 'Model preview';
  frame.src = new URL('./model-runtime/index.html', location.href).href;
  let settled = false,
    resolve,
    reject;
  const ready = new Promise((yes, no) => {
    resolve = yes;
    reject = no;
  });
  const timeout = setTimeout(() => finish(Error('Model preview timed out')), 30000);
  function finish(error, stats) {
    if (settled) return;
    settled = true;
    clearTimeout(timeout);
    if (error) reject(error);
    else {
      frame.dataset.ready = 'true';
      resolve(stats);
    }
  }
  function message(event) {
    if (
      event.source !== frame.contentWindow ||
      event.origin !== location.origin ||
      event.data?.version !== 1
    )
      return;
    if (event.data.type === 'kagura:model-request' && model) {
      frame.contentWindow.postMessage(
        { type: 'kagura:model-init', version: 1, model },
        location.origin,
        [...new Set(model.buffers.map((buffer) => buffer.buffer))],
      );
      model = undefined;
    }
    if (event.data.type === 'kagura:model-ready') finish(null, event.data.stats);
    if (event.data.type === 'kagura:model-error') finish(Error(event.data.message));
  }
  addEventListener('message', message);
  element.append(frame);
  return {
    ready,
    reset: () => frame.contentWindow?.kaguraModel?.reset(),
    dispose() {
      finish(new DOMException('Model preview closed', 'AbortError'));
      removeEventListener('message', message);
      try {
        frame.contentWindow?.kaguraModelDispose?.();
      } finally {
        frame.remove();
      }
    },
  };
}
