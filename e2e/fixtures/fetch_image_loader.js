// fetch_image loader for JS target E2E test
import { loadGameScript } from "../../lib/web/kagura-init.js";

async function init() {
  // Do NOT call initWebGPU/setupGlobalState here.
  // The game's @web_hooks.install() handles WebGPU initialization.
  // Pre-initializing conflicts because install() calls js_release_webgpu_resources()
  // which unconfigures the context, and the re-init path skips reconfiguration
  // when it sees an existing device.

  // Hook fetch to capture image loading details
  const imageFetches = [];
  const origFetch = window.fetch.bind(window);
  window.fetch = async (...args) => {
    const url = typeof args[0] === "string" ? args[0] : args[0]?.url ?? "";
    const resp = await origFetch(...args);
    if (/\.(png|jpe?g|gif|webp|bmp)$/i.test(url)) {
      imageFetches.push({
        url,
        status: resp.status,
        ok: resp.ok,
        contentType: resp.headers.get("content-type"),
      });
    }
    return resp;
  };

  // Hook requestAnimationFrame to count frames
  let frames = 0;
  const hasWebGPU = !!(navigator.gpu);
  const origRAF = window.requestAnimationFrame.bind(window);
  window.requestAnimationFrame = (cb) => {
    return origRAF((ts) => {
      frames++;
      if (frames === 1) {
        window.__fetchImageResult = { status: "ok", frames, hasWebGPU, imageFetches };
      }
      cb(ts);
      window.__fetchImageResult = { ...window.__fetchImageResult, frames };
    });
  };

  await loadGameScript("/examples/fetch_image/_build/js/debug/build/fetch_image.js");

  // Fallback: if no frame rendered within 5s, report timeout
  setTimeout(() => {
    if (!window.__fetchImageResult) {
      window.__fetchImageResult = { status: "timeout", frames: 0, hasWebGPU, imageFetches };
    }
  }, 5000);
}

init().catch((err) => {
  console.error("fetch_image loader error:", err);
  window.__fetchImageResult = { status: "error", frames: 0, hasWebGPU: false, imageFetches: [], error: String(err) };
});
