import test from "node:test";
import assert from "node:assert/strict";

import {
  DEMO_PAGES,
  getDemoPage,
  renderDemoHtml,
  renderLandingHtml,
  renderLoaderModule,
} from "./web-demo-pages.mjs";

test("landing page exposes additional public demos", () => {
  const html = renderLandingHtml({ demos: DEMO_PAGES });

  assert.match(html, /gltf_viewer/);
  assert.match(html, /fetch_image/);
  assert.match(html, /WebGPU only/i);
});

test("demo page includes responsive layout and control guidance", () => {
  const html = renderDemoHtml({
    demo: getDemoPage("survivor"),
    scriptTag: '<script type="module" src="./loader.js?v=test"></script>',
  });

  assert.match(html, /name="viewport"/i);
  assert.match(html, /Controls/i);
  assert.match(html, /Gallery/i);
  assert.match(html, /WASD/i);
  assert.match(html, /stage-canvas/);
});

test("loader tells users that browser demos are WebGPU only", () => {
  const moduleCode = renderLoaderModule({
    fontEntries: [],
    scriptPath: "./survivor.js?v=test",
    libPrefix: "../lib",
  });

  assert.match(moduleCode, /WebGPU only/i);
});
