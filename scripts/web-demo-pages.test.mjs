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

  assert.doesNotMatch(html, /gltf_viewer|obj_viewer/);
  assert.match(html, /fetch_image/);
  assert.doesNotMatch(html, /model_authoring/);
  assert.doesNotMatch(html, /chair_authoring/);
  assert.doesNotMatch(html, /shelf_authoring/);
  assert.doesNotMatch(html, /frog_authoring/);
  assert.doesNotMatch(html, /dragon_authoring/);
  assert.doesNotMatch(html, /WebGPU only|require WebGPU|Chrome or Edge/i);
  assert.doesNotMatch(html, /undefined/);
  const games = html.match(/<section class="group" id="games"[\s\S]*?<\/section>/)?.[0] ?? '';
  assert.match(games, /EMBERWING/);
  assert.match(games, /ASHEN REALMS/);
  assert.match(games, /href="\.\/studio\/games\/iron-yard\/"/);
  assert.doesNotMatch(games, /Arena 3D|Flappy Bird|Survivor|Card Game/);
  assert.match(html, /id="technical-demos"/);
});

test("landing page links to Studio and the shareable kawaiko preset under its hosting path", () => {
  const html = renderLandingHtml({ demos: DEMO_PAGES });
  assert.match(html, /href="\.\/studio\/"/);
  assert.match(html, /href="\.\/studio\/\?mode=modeling&amp;model=kawaiko"/);
});

test("demo page includes responsive layout and control guidance", () => {
  const html = renderDemoHtml({
    demo: getDemoPage("particle_demo"),
    scriptTag: '<script type="module" src="./loader.js?v=test"></script>',
  });

  assert.match(html, /name="viewport"/i);
  assert.match(html, /Controls/i);
  assert.match(html, /Gallery/i);
  assert.match(html, /stage-canvas/);
  assert.doesNotMatch(html, /WebGPU only|require WebGPU|Chrome or Edge/i);
});

test("loader tells users that browser demos are WebGPU only", () => {
  const moduleCode = renderLoaderModule({
    fontEntries: [],
    scriptPath: "./survivor.js?v=test",
    libPrefix: "../lib",
  });

  assert.match(moduleCode, /WebGPU only/i);
});
