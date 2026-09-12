// Shared canvas presentation and capture contract. Game simulation/render resolution
// remains game-owned; this module only controls where the canvas is displayed.

/** @typedef {'embedded' | 'fullscreen'} PresentationMode */
/** @typedef {{x: number, y: number, width: number, height: number}} ViewportRect */
/**
 * @typedef {object} GameCaptureTarget
 * @property {1} version
 * @property {string} selector
 * @property {string} hideSelector DOM chrome to exclude, including overlapping help.
 * @property {ViewportRect} rect Current CSS pixels, relative to the viewport.
 * @property {{width: number, height: number}} pixels Current canvas backing size.
 * @property {number} renderedFrames Successfully submitted frames of this surface.
 */

/** Largest centered rectangle preserving the game's aspect ratio. */
export function fitGameViewport(width, height, aspectRatio) {
  if (![width, height, aspectRatio].every(value => Number.isFinite(value) && value > 0)) {
    throw new RangeError('Viewport dimensions and aspect ratio must be positive and finite');
  }
  const fittedWidth = Math.min(width, height * aspectRatio);
  const fittedHeight = fittedWidth / aspectRatio;
  return { x: (width - fittedWidth) / 2, y: (height - fittedHeight) / 2,
    width: fittedWidth, height: fittedHeight };
}

/**
 * Owns one game canvas per window; reinstallation disposes the previous surface.
 * @param {HTMLCanvasElement} canvas
 * @param {{mode?: PresentationMode, aspectRatio?: number, fit?: 'contain' | 'viewport'}} options
 */
export function installGamePresentation(canvas, {
  mode = canvas.getAttribute('data-kagura-presentation') ?? 'embedded',
  aspectRatio = canvas.width / canvas.height,
  fit = canvas.getAttribute('data-kagura-fit') ?? 'contain',
} = {}) {
  if (mode !== 'embedded' && mode !== 'fullscreen') throw new RangeError(`Unknown presentation mode: ${mode}`);
  if (fit !== 'contain' && fit !== 'viewport') throw new RangeError(`Unknown presentation fit: ${fit}`);
  fitGameViewport(1, 1, aspectRatio);
  const host = canvas.ownerDocument.defaultView;
  host.__kaguraPresentation?.dispose();
  const originalStyle = canvas.style.cssText;
  const surface = canvas.closest?.('[data-kagura-surface]') ?? canvas;
  const originalCapture = surface.getAttribute('data-kagura-capture');
  surface.setAttribute('data-kagura-capture', 'game');
  const resize = () => {
    if (mode !== 'fullscreen') return;
    const rect = fit === 'viewport' ? {x:0,y:0,width:host.innerWidth,height:host.innerHeight}
      : fitGameViewport(host.innerWidth, host.innerHeight, aspectRatio);
    Object.assign(canvas.style, {
      position: 'fixed', display: 'block', margin: '0', border: '0', padding: '0',
      boxSizing: 'border-box', maxWidth: 'none', maxHeight: 'none',
      left: `${rect.x}px`, top: `${rect.y}px`,
      width: `${rect.width}px`, height: `${rect.height}px`,
    });
  };
  resize();
  if (mode === 'fullscreen') host.addEventListener('resize', resize);
  let disposed = false;
  const presentation = Object.freeze({
    version: 1,
    mode,
    fit,
    aspectRatio,
    /** @returns {GameCaptureTarget} */
    captureTarget() {
      if (disposed) throw new Error('Game presentation has been disposed');
      const { x, y, width, height } = surface.getBoundingClientRect();
      const runtime = host.__kaguraWebRuntime;
      return {
        version: 1, selector: surface === canvas ? 'canvas[data-kagura-capture="game"]' : '[data-kagura-capture="game"]',
        hideSelector: '[data-kagura-overlay]', rect: { x, y, width, height },
        pixels: { width: canvas.width, height: canvas.height },
        renderedFrames: runtime?.canvas === canvas ? runtime.webgpu?._submittedFrameCount ?? 0 : 0,
      };
    },
    // Browser fullscreen needs a user gesture; viewport filling never needs one.
    async requestFullscreen() {
      if (disposed) throw new Error('Game presentation has been disposed');
      const document = canvas.ownerDocument;
      if (document.fullscreenElement) return true;
      if (!document.documentElement.requestFullscreen) return false;
      await document.documentElement.requestFullscreen();
      return true;
    },
    dispose() {
      if (disposed) return;
      disposed = true;
      if (mode === 'fullscreen') host.removeEventListener('resize', resize);
      canvas.style.cssText = originalStyle;
      if (originalCapture === null) surface.removeAttribute('data-kagura-capture');
      else surface.setAttribute('data-kagura-capture', originalCapture);
      if (host.__kaguraPresentation === presentation) delete host.__kaguraPresentation;
    },
  });
  host.__kaguraPresentation = presentation;
  return presentation;
}
