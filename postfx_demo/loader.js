import { initWebGPU, setupGlobalState, loadFonts, loadGameScript, showStartupError } from "../lib/kagura-init.js";
import { installAudioHelpers } from "../lib/kagura-audio.js";
import { installGfxHelpers } from "../lib/kagura-gfx.js";

async function init() {
  const result = await initWebGPU("#app");
  if (!result) {
    showStartupError(
      "#app",
      "WebGPU only demo",
      "Kagura browser demos currently require WebGPU.",
    );
    return;
  }
  setupGlobalState(result.canvas, result.device, result.format, result.context);
  installAudioHelpers();
  installGfxHelpers();
  try {
    await loadGameScript("./postfx_demo.js?v=69947a6");
  } catch (e) {
    showStartupError(
      "#app",
      "Failed to load game script",
      e && e.message ? e.message : String(e),
    );
  }
}

init().catch((e) => {
  showStartupError(
    "#app",
    "Unexpected runtime error",
    e && e.message ? e.message : String(e),
  );
});
