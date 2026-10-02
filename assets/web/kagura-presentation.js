// Shared canvas presentation and capture contract. Game simulation/render resolution
// remains game-owned; this module only controls where the canvas is displayed.

/** @typedef {'embedded' | 'fullscreen'} PresentationMode */
/** @typedef {{x: number, y: number, width: number, height: number}} ViewportRect */
/** @typedef {{left?: number, top?: number, right?: number, bottom?: number}} ViewportInsets */
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
  aspectRatio,
  fit = canvas.getAttribute('data-kagura-fit') ?? 'contain',
} = {}) {
  if (mode !== 'embedded' && mode !== 'fullscreen') throw new RangeError(`Unknown presentation mode: ${mode}`);
  if (fit !== 'contain' && fit !== 'viewport') throw new RangeError(`Unknown presentation fit: ${fit}`);
  let gameAspectRatio;
  const currentAspectRatio = () => aspectRatio ?? gameAspectRatio ?? canvas.width / canvas.height;
  fitGameViewport(1, 1, currentAspectRatio());
  const toolbarInset = Number(canvas.getAttribute('data-kagura-inset-top') ?? 0);
  if (!Number.isFinite(toolbarInset) || toolbarInset < 0) throw new RangeError('Toolbar inset must be nonnegative and finite');
  const host = canvas.ownerDocument.defaultView;
  host.__kaguraPresentation?.dispose();
  const originalStyle = canvas.style.cssText;
  const surface = canvas.closest?.('[data-kagura-surface]') ?? canvas;
  const originalCapture = surface.getAttribute('data-kagura-capture');
  surface.setAttribute('data-kagura-capture', 'game');
  let insets={left:0,top:toolbarInset,right:0,bottom:0};
  const resize = () => {
    if (mode !== 'fullscreen') return;
    const width=Math.max(1,host.innerWidth-insets.left-insets.right);
    const height=Math.max(1,host.innerHeight-insets.top-insets.bottom);
    const rect = fit === 'viewport' ? {x:0,y:0,width,height}
      : fitGameViewport(width,height,currentAspectRatio());
    rect.x+=insets.left;rect.y+=insets.top;
    Object.assign(canvas.style, {
      position: 'fixed', display: 'block', margin: '0', border: '0', padding: '0',
      boxSizing: 'border-box', maxWidth: 'none', maxHeight: 'none',
      left: `${rect.x}px`, top: `${rect.y}px`,
      width: `${rect.width}px`, height: `${rect.height}px`,
    });
  };
  resize();
  if (mode === 'fullscreen') host.addEventListener('resize', resize);
  // Standalone canvases can change resolution after installation. The engine
  // supplies its logical ratio separately because backing pixels also track DPR.
  const observer = mode === 'fullscreen' && aspectRatio === undefined && host.MutationObserver
    ? new host.MutationObserver(resize) : null;
  observer?.observe(canvas, {attributes: true, attributeFilter: ['width', 'height']});
  let disposed = false;
  const presentation = Object.freeze({
    version: 1,
    mode,
    fit,
    get aspectRatio() { return currentAspectRatio(); },
    /** The engine's logical viewport, independent of CSS size and DPR. */
    setGameViewport(width, height) {
      if (disposed) throw new Error('Game presentation has been disposed');
      fitGameViewport(width, height, width / height);
      gameAspectRatio = width / height;
      resize();
    },
    /** Reserve space for editor panels; capture still includes the whole game surface.
     * @param {ViewportInsets} next Empty insets restore the normal fullscreen view.
     */
    setViewportInsets(next={}) {
      if(disposed)throw new Error('Game presentation has been disposed');
      const value={left:next.left??0,top:next.top??0,right:next.right??0,bottom:next.bottom??0};
      if(!Object.values(value).every(n=>Number.isFinite(n)&&n>=0))throw new RangeError('Viewport insets must be nonnegative and finite');
      insets=value;resize();
    },
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
      observer?.disconnect();
      canvas.style.cssText = originalStyle;
      if (originalCapture === null) surface.removeAttribute('data-kagura-capture');
      else surface.setAttribute('data-kagura-capture', originalCapture);
      if (host.__kaguraPresentation === presentation) delete host.__kaguraPresentation;
    },
  });
  host.__kaguraPresentation = presentation;
  return presentation;
}
