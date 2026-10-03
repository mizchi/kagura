import { renderHunterPage } from "../examples/games/hacknslash_3d/web/page.mjs";
import { existsSync, readdirSync, statSync } from "node:fs";
import { join } from "node:path";
import {renderWebRuntimeImportMap} from './web-runtime-assets.mjs';
import {catalog} from './example-catalog.mjs';

const GITHUB_BLOB_ROOT = "https://github.com/mizchi/kagura/blob/main";
const HIDDEN_PAGE_NAMES = new Set([
  "model_authoring",
  "chair_authoring",
  "shelf_authoring",
  "frog_authoring",
  "dragon_authoring",
]);

const RAW_DEMO_PAGES = [
  {
    name: "card_game",
    title: "Ember Ascent",
    group: "Games",
    summary: "Build your deck across a branching adventure with events, gold, shops, relics and unique enemies.",
    start: "Choose a character and stage, then follow the branching map through 30 floors or challenge the Guardian boss. Drag cards or use a controller to play.",
    controls: ["Drag a card to play; release outside the battlefield to cancel", "Arrows / D-pad / left stick: choose a card; A / Enter: select, then confirm its target", "1–9: select a card; arrows: choose an enemy; Enter: play", "E / Y: end turn; D / X: deck; Q / LB: draw; R / RB: discard", "P / Start: settings; Esc / B: back; Tab: cycle popup controls", "Choose one card after each victory; rest to recover HP"],
    tags: ["2D", "Cards", "Roguelite"],
    sourcePath: "examples/games/card_game/main.mbt",
    width: 960,
    height: 640,
    pixelArt: true,
  },
  {
    name: "emberwing",
    title: "EMBERWING",
    group: "Games",
    summary: "A 3D rail shooter with multi-target homing fireballs, flame breath, enemy waves, obstacles and a giant kawaiko boss.",
    start: "Click Fly for nine escalating waves and a giant boss, or practice the boss from the title screen.",
    controls: ["Mouse: aim / fly", "Hold left: multi-lock; release: homing fireballs", "Hold right: flame breath", "WASD / arrows: dodge; Esc: pause"],
    tags: ["3D", "Rail shooter", "Instancing"],
    sourcePath: "examples/games/emberwing/main.mbt",
  },
  {
    name: "flappy_bird",
    title: "Flappy Bird",
    group: "Games",
    summary: "One-button 2D game loop demo.",
    start: "Tap the canvas or press Space to start.",
    controls: [
      "Tap / Space: flap",
      "Tap / Space after game over: restart",
    ],
    tags: ["2D", "Scene API"],
    sourcePath: "examples/games/flappy_bird/game.mbt",
  },
  {
    name: "survivor",
    title: "Survivor",
    group: "Games",
    summary: "Auto-attack survival prototype with leveling.",
    start: "Press Space to start, then keep moving.",
    controls: [
      "WASD / Arrow: move",
      "Space: start / confirm / continue",
    ],
    tags: ["2D", "Camera", "Leveling"],
    sourcePath: "examples/games/survivor/game.mbt",
  },
  {
    name: "hacknslash_3d",
    title: "ASHEN REALMS",
    group: "Games",
    summary: "A low-poly action RPG with loot, connected regions and customizable hunter, mage, archer or summoner builds.",
    start: "Choose a save slot and a starting build, then collect equipment and shape your skills.",
    controls: [
      "WASD / Arrow: move",
      "Left / right click: skill slots 1 / 2; 1–4: skills; Space / Shift: dodge",
      "Q / E: orbit; wheel: zoom; O: camera settings; Z: third-person view",
      "I: inventory; K: skill tree and slots; Esc: pause and save selection",
      "Gamepad and mobile touch controls supported",
    ],
    tags: ["3D", "Combat", "RPG"],
    sourcePath: "examples/games/hacknslash_3d/app/update.mbt",
    width: 640,
    height: 480,
  },
  {
    name: "scene_demo",
    title: "Scene Demo",
    group: "2D / UI",
    summary: "Minimal declarative Scene API example.",
    start: "Open the page and move the square.",
    controls: [
      "WASD / Arrow: move",
      "Space: add score",
    ],
    tags: ["2D", "Scene API"],
    sourcePath: "examples/demos-2d/scene_demo/game.mbt",
  },
  {
    name: "ui_demo",
    title: "UI Demo",
    group: "2D / UI",
    summary: "Focus handling and layout interactions.",
    start: "Use keyboard or mouse to move focus.",
    controls: [
      "Tab / Shift+Tab: move focus",
      "Click: focus / select",
    ],
    tags: ["UI", "Focus"],
    sourcePath: "examples/demos-2d/ui_demo/game.mbt",
    width: 640,
    height: 480,
  },
  {
    name: "fetch_image",
    title: "Fetch Image",
    group: "2D / UI",
    summary: "Asset loading demo that fetches and renders an image.",
    start: "Loads automatically on open.",
    controls: [
      "No input required",
      "Replace `assets/sample.png` to try another image",
    ],
    tags: ["Asset", "Image"],
    sourcePath: "examples/demos-2d/fetch_image/main.mbt",
  },
  {
    name: "arena3d",
    title: "Arena 3D",
    group: "Games",
    summary: "Collect items, shoot targets and experiment with stacked boxes and bouncing balls in first or third person.",
    start: "Opens directly into the scene.",
    controls: [
      "WASD / arrows: move; Space: jump",
      "Click / F: shoot; right drag: look",
      "V: first / third person; Q / E: turn; I / K: tilt; R: reset",
    ],
    tags: ["3D", "FPS / TPS", "Physics"],
    sourcePath: "examples/games/arena3d/game.mbt",
    width: 640,
    height: 480,
  },
  {
    name: "model_authoring",
    title: "Model Authoring",
    group: "3D Rendering",
    summary: "Code-first hard-surface + voxel sculpt modeling POC with baked surface preview for VLM review loops.",
    start: "Orbit the model, inspect the baked sculpt preview, click a hovered target to select it, drag the gizmo to move a primitive, then hold A or S while clicking to author sculpt stamps. Press G to export a GLB snapshot, I to build a round-trip diff and patch proposal from an imported GLB, P to apply the safe auto-patch subset in memory, U to apply opt-in primitive sync candidates, J to download the machine-readable VLM bundle, K to download the generated MoonBit patch snippet, and L to download the VLM review prompt.",
    controls: [
      "Left drag: orbit camera",
      "Wheel: zoom",
      "Click: select hovered primitive or sculpt layer",
      "Drag gizmo handle: move the selected primitive on one axis",
      "A + left click: add sculpt stamp",
      "S + left click: subtract sculpt stamp",
      "M: toggle x-axis symmetry for sculpt stamps",
      "Z: undo latest stamp in the active sculpt layer",
      "1 / 2 / 3 / 4: mute or unmute recent history slots",
      "G: download the current document as GLB",
      "I: import a GLB, diff it against the current document, and publish a patch proposal",
      "P: apply auto-safe patch actions from the latest imported GLB",
      "U: apply auto-safe patch actions plus opt-in primitive remove/append candidates",
      "J: download the machine-readable VLM bundle JSON for API handoff",
      "K: download the generated MoonBit patch snippet for model_doc-style updates",
      "L: download the generated VLM review prompt for manual diff resolution",
      "D / E: brush radius, O: reset document",
      "Inspect globalThis.__kaguraModelingContext in the browser console",
      "Inspect globalThis.__kaguraModelingExport after exporting",
      "Inspect globalThis.__kaguraModelingRoundTrip after importing",
      "Inspect globalThis.__kaguraModelingPatch for auto/manual patch actions, opt_in_append_source_ids, opt_in_remove_source_ids, manual_issue_details, moonbit_patch, and review_prompt",
      "J downloads current_document + roundtrip_report + patch_payload as one JSON bundle",
      "Use editor/modeling3d/scripts/model-authoring-vlm-review.mjs --provider openrouter with repeated --screenshot flags to send angled/front/side/top captures to google/gemini-3.1-flash-lite-preview by default, with free-model fallback if OpenRouter rejects the preview tier",
      "Use editor/modeling3d/scripts/model-authoring-vlm-handoff.mjs --serve --edit-profile roundtrip_diff_bundle --provider openrouter for an end-to-end local dry-run with four fixed review views",
      "After P or U, round-trip diff and patch payload are recomputed against the imported GLB",
      "Exported GLB keeps Kagura source ids in glTF extras and uses double-sided materials",
    ],
    tags: ["3D", "Modeling", "VLM"],
    sourcePath: "editor/modeling3d/examples/model_authoring/model_doc.mbt",
    width: 640,
    height: 480,
  },
  {
    name: "chair_authoring",
    title: "Chair Authoring",
    group: "3D Rendering",
    summary: "Primitive-first chair study with a small sculpted cushion, built to validate hard-surface VLM patch loops.",
    start: "Orbit the chair, click a part to select it, drag the gizmo to adjust proportions, and use the same GLB export/import round-trip loop as model_authoring.",
    controls: [
      "Left drag: orbit camera",
      "Wheel: zoom",
      "Click: select hovered primitive or the seat cushion sculpt layer",
      "Drag gizmo handle: move the selected primitive on one axis",
      "A + left click: add sculpt stamp to the seat cushion",
      "S + left click: subtract sculpt stamp from the seat cushion",
      "M: toggle x-axis symmetry for sculpt stamps",
      "G / I / P / U / J / K / L: same round-trip export, import, patch, and VLM bundle loop as model_authoring",
      "D / E: brush radius, O: reset document",
    ],
    tags: ["3D", "Modeling", "VLM", "Hard Surface"],
    sourcePath: "editor/modeling3d/examples/chair_authoring/model_doc.mbt",
    width: 640,
    height: 480,
  },
  {
    name: "shelf_authoring",
    title: "Shelf Authoring",
    group: "3D Rendering",
    summary: "Hard-surface shelf study with simple storage props, used to validate stacked-plane alignment in the VLM loop.",
    start: "Orbit the shelf, inspect the horizontal levels, uprights, and storage props, then use the same GLB export/import loop to see how well the VLM catches drifting shelves, missing braces, and clutter misalignment.",
    controls: [
      "Left drag: orbit camera",
      "Wheel: zoom",
      "Click: select hovered primitive",
      "Drag gizmo handle: move the selected primitive on one axis",
      "G / I / P / U / J / K / L: same round-trip export, import, patch, and VLM bundle loop as model_authoring",
      "O: reset document",
    ],
    tags: ["3D", "Modeling", "VLM", "Hard Surface"],
    sourcePath: "editor/modeling3d/examples/shelf_authoring/model_doc.mbt",
    width: 640,
    height: 480,
  },
  {
    name: "frog_authoring",
    title: "Frog Authoring",
    group: "3D Rendering",
    summary: "Stylized frog maquette using a voxel sculpt body and eye primitives, aimed at organic blockout workflows.",
    start: "Orbit the frog, inspect the sculpted body, then use sculpt stamps and GLB round-tripping to see where the current system handles organic forms well and where it falls back to manual review.",
    controls: [
      "Left drag: orbit camera",
      "Wheel: zoom",
      "Click: select hovered primitive or the frog_body sculpt layer",
      "A + left click: add sculpt stamp",
      "S + left click: subtract sculpt stamp",
      "M: toggle x-axis symmetry for sculpt stamps",
      "Drag gizmo handle: move the selected primitive on one axis",
      "G / I / P / U / J / K / L: same round-trip export, import, patch, and VLM bundle loop as model_authoring",
      "D / E: brush radius, O: reset document",
    ],
    tags: ["3D", "Modeling", "VLM", "Organic"],
    sourcePath: "editor/modeling3d/examples/frog_authoring/model_doc.mbt",
    width: 640,
    height: 480,
  },
  {
    name: "dragon_authoring",
    title: "Dragon Authoring",
    group: "3D Rendering",
    summary: "Stylized voxel dragon study focused on readable head, wings, and tail silhouettes in the VLM loop.",
    start: "Orbit the dragon, inspect the wing and tail silhouette, then use sculpt stamps and live-review to see whether the current voxel blockout still reads as a dragon from all four views.",
    controls: [
      "Left drag: orbit camera",
      "Wheel: zoom",
      "Click: select hovered primitive or the dragon_body sculpt layer",
      "A + left click: add sculpt stamp",
      "S + left click: subtract sculpt stamp",
      "M: toggle x-axis symmetry for sculpt stamps",
      "Drag gizmo handle: move the selected primitive on one axis",
      "G / I / P / U / J / K / L: same round-trip export, import, patch, and VLM bundle loop as model_authoring",
      "D / E: brush radius, O: reset document",
    ],
    tags: ["3D", "Modeling", "VLM", "Organic"],
    sourcePath: "editor/modeling3d/examples/dragon_authoring/model_doc.mbt",
    width: 640,
    height: 480,
  },
  {
    name: "effect_studio",
    title: "Effect Studio",
    group: "Tools",
    summary: "AI-first timeline effect editor with particle preview and timeline feedback.",
    start: "Orbit the preview, scrub the timeline, and inspect the published AI editing context in the browser console.",
    controls: [
      "Left drag: orbit camera",
      "Wheel: zoom",
      "Space: play / pause preview",
      "Left / Right: scrub timeline",
      "Shift + Left / Right: coarse scrub",
      "R: reset preview time",
      "J: download the machine-readable patch bundle JSON",
      "L: download the AI review prompt markdown",
      "Inspect globalThis.__kaguraEffectStudioContext in the browser console",
    ],
    tags: ["3D", "Particles", "Timeline", "AI"],
    sourcePath: "editor/effect-studio/examples/effect_studio/main.mbt",
    width: 640,
    height: 480,
  },
  {
    name: "particle_demo",
    title: "Particle System",
    group: "3D Rendering",
    summary: "Billboard particle rendering showcase.",
    start: "Orbit around the particles for a closer look.",
    controls: [
      "Left drag: orbit camera",
      "Wheel: zoom",
    ],
    tags: ["3D", "Particles"],
    sourcePath: "examples/demos-3d/particle_demo/game.mbt",
    width: 640,
    height: 480,
  },
  {
    name: "shadow3d_demo",
    title: "Shadow 3D",
    group: "3D Rendering",
    summary: "Depth-based shadow mapping demo.",
    start: "Loads directly into the scene.",
    controls: [
      "Automatic camera motion",
      "Open source for implementation details",
    ],
    tags: ["3D", "Shadow"],
    sourcePath: "examples/demos-3d/shadow3d_demo/game.mbt",
    width: 640,
    height: 480,
  },
  {
    name: "postfx_demo",
    title: "Post Effects",
    group: "3D Rendering",
    summary: "Bloom, tone mapping, and FXAA post-processing demo.",
    start: "Loads directly into the scene.",
    controls: [
      "Automatic camera motion",
      "Open source for post-processing setup",
    ],
    tags: ["3D", "PostFX"],
    sourcePath: "examples/demos-3d/postfx_demo/game.mbt",
    width: 640,
    height: 480,
  },
  {
    name: "skeletal_anim",
    title: "Skeletal Animation",
    group: "3D Rendering",
    summary: "GPU skinning and animated character demo.",
    start: "Loads directly into the scene.",
    controls: [
      "Automatic camera motion",
      "Open source for animation graph details",
    ],
    tags: ["3D", "Animation"],
    sourcePath: "examples/demos-3d/skeletal_anim/game.mbt",
    width: 640,
    height: 480,
  },
  {
    name: "physics3d_demo",
    title: "Physics 3D",
    group: "Physics",
    summary: "Rigid body and collision demo in 3D.",
    start: "Loads directly into the scene.",
    controls: [
      "Automatic camera motion",
      "Observe the rigid bodies and collisions",
    ],
    tags: ["Physics", "3D"],
    sourcePath: "examples/demos-3d/physics3d_demo/game.mbt",
    width: 640,
    height: 480,
  },
  {
    name: "physics2d_demo",
    title: "Physics 2D",
    group: "Physics",
    summary: "2D body spawning and collision sandbox.",
    start: "Click the stage to spawn bodies.",
    controls: [
      "Click: spawn a new body",
      "Bodies alternate between circles and boxes",
    ],
    tags: ["Physics", "2D"],
    sourcePath: "examples/demos-2d/physics2d_demo/game.mbt",
    width: 640,
    height: 480,
  },
  {
    name: "ragdoll_demo",
    title: "Ragdoll",
    group: "Physics",
    summary: "Drag-and-drop ragdoll interaction demo.",
    start: "Grab a body part with the mouse.",
    controls: [
      "Click and drag: pull the ragdoll",
      "Release: let the spring force settle",
    ],
    tags: ["Physics", "2D"],
    sourcePath: "examples/demos-3d/ragdoll_demo/game.mbt",
    width: 640,
    height: 480,
  },
  {
    name: "collision3d_demo",
    title: "Collision 3D",
    group: "Physics",
    summary: "Raycast and collision query viewer.",
    start: "Move through the scene and watch hits update.",
    controls: [
      "WASD: move",
      "Mouse: look",
    ],
    tags: ["Physics", "3D"],
    sourcePath: "examples/demos-3d/collision3d_demo/game.mbt",
    width: 640,
    height: 480,
  },
  {
    name: "crater_renderer",
    title: "Crater Renderer",
    group: "2D / UI",
    summary: "HTML/CSS rendered to WebGPU via crater layout engine.",
    start: "Loads automatically — renders an HTML dashboard.",
    controls: [
      "No input required",
      "Demonstrates crater HTML/CSS parsing + kagura WebGPU rendering",
    ],
    tags: ["2D", "HTML", "CSS", "Text"],
    sourcePath: "examples/experimental/crater_renderer/main.mbt",
    width: 800,
    height: 480,
  },
  {
    name: "machinations_demo",
    title: "Machinations",
    group: "Tools",
    summary:
      "Machinations-style game-economy simulator: a Cookie-Clicker loop with pools, sources, a converter, a gate and a feedback modifier, plus a live time-series chart.",
    start: "Click the gold CLICK / BUY nodes; press SPACE to run time.",
    controls: [
      "Click gold (interactive) nodes to fire them",
      "SPACE: play/pause   RIGHT: step   R: reset",
      "UP / DOWN: adjust speed",
      "Hover a node to inspect it",
    ],
    tags: ["Tool", "Simulation", "Economy", "Chart"],
    sourcePath: "examples/demos-2d/machinations_demo/sample.mbt",
    width: 720,
    height: 480,
  },
];

export const DEMO_PAGES = RAW_DEMO_PAGES
  .filter((demo) => !HIDDEN_PAGE_NAMES.has(demo.name))
  .map((demo) => ({
    ...demo,
    group: catalog.find(item => item.id === demo.name)?.kind === 'game'
      ? 'Games' : demo.group === 'Games' ? 'Gameplay' : demo.group,
    githubHref: `${GITHUB_BLOB_ROOT}/${demo.sourcePath}`,
  }));

const DEMO_PAGE_MAP = new Map(DEMO_PAGES.map((demo) => [demo.name, demo]));

export const DEMO_GROUPS = [
  "Gameplay",
  "2D / UI",
  "3D Rendering",
  "Physics",
  "Tools",
];

export function getDemoPage(name) {
  const demo = DEMO_PAGE_MAP.get(name);
  if (!demo) {
    throw new Error(`Unknown demo: ${name}`);
  }
  return demo;
}

export function resolveDemoPage(name) {
  if (DEMO_PAGE_MAP.has(name)) {
    return getDemoPage(name);
  }
  const sourcePath = resolveExampleSourcePath(name);
  const title = humanizeName(name);
  return {
    name,
    title,
    group: "Local Example",
    summary: "Local example build for development.",
    start: "Open the stage and use the controls implemented in source.",
    controls: [
      "Open the example source for control details",
    ],
    tags: ["Local"],
    sourcePath,
    githubHref: `${GITHUB_BLOB_ROOT}/${sourcePath}`,
  };
}

function resolveExampleSourcePath(name) {
  if (name.endsWith("_studio")) {
    return `editor/effect-studio/examples/${name}/src`;
  }
  if (name.endsWith("_authoring")) {
    return `editor/modeling3d/examples/${name}/src`;
  }
  const examplesRoot = "examples";
  if (existsSync(examplesRoot)) {
    for (const category of readdirSync(examplesRoot)) {
      const categoryPath = join(examplesRoot, category);
      if (!statSync(categoryPath).isDirectory()) continue;
      if (
        existsSync(join(categoryPath, name, "moon.mod.json")) ||
        existsSync(join(categoryPath, name, "moon.mod"))
      ) {
        return `examples/${category}/${name}/src`;
      }
    }
  }
  return `examples/${name}/src`;
}

export function detectFontEntries(exampleDir) {
  const assetsDir = join(exampleDir, "assets");
  if (!existsSync(assetsDir)) {
    return [];
  }
  return readdirSync(assetsDir)
    .filter((file) => file.endsWith(".ttf") || file.endsWith(".otf"))
    .sort()
    .map((file) => [`assets/${file}`, `./assets/${file}`]);
}

export function renderLoaderModule({ fontEntries, scriptPath, libPrefix }) {
  const fontSnippet = fontEntries.length > 0
    ? `  await loadFonts(${JSON.stringify(fontEntries)});\n`
    : "";
  return `import { initWebGPU, setupGlobalState, loadFonts, loadGameScript, showStartupError } from "${libPrefix}/kagura-init.js";
import { installAudioHelpers } from "${libPrefix}/kagura-audio.js";
import { installGfxHelpers } from "${libPrefix}/kagura-gfx.js";

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
${fontSnippet}  try {
    await loadGameScript(${JSON.stringify(scriptPath)});
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
`;
}

export function renderDemoHtml({
  demo,
  scriptTag,
  homeHref = "../",
  homeLabel = "Gallery",
  libPrefix = "../lib",
}) {
  if (demo.name === "hacknslash_3d") return renderHunterPage({ scriptTag, homeHref, homeLabel, libPrefix });
  const controlsHtml = demo.controls.map(control => `<li>${escapeHtml(control)}</li>`).join('');
  return `<!doctype html>
<html lang="ja">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
  <title>${escapeHtml(demo.title)} - Kagura</title>
  <style>
    :root { color-scheme: dark; font: 14px system-ui, sans-serif; color: #eef4ff; background: #08101a; }
    * { box-sizing: border-box; }
    html, body { width: 100%; height: 100%; }
    body { margin: 0; min-height: 100dvh; overflow: hidden; }
    .stage-canvas { display: block; background: #000; touch-action: none; ${demo.pixelArt ? 'image-rendering: pixelated;' : ''} }
    .presentation-tools { position: fixed; inset: 0 0 auto; height: 48px; z-index: 10;
      display: flex; align-items: center; justify-content: space-between; gap: 8px;
      padding: 4px max(8px, env(safe-area-inset-right)) 4px max(8px, env(safe-area-inset-left));
      background: #101b2a; border-bottom: 1px solid #304357; }
    .game-title { margin: 0; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; font-size: 15px; }
    .tool-actions { display: flex; align-items: center; gap: 8px; flex-shrink: 0; }
    button, summary { min-height: 36px; border: 1px solid #536c83; border-radius: 6px;
      background: #203246; padding: 8px 12px; color: #eef4ff; font: inherit; cursor: pointer; }
    :focus-visible { outline: 2px solid #ffe082; outline-offset: 2px; }
    details > summary { list-style: none; }
    details > summary::-webkit-details-marker { display: none; }
    details:not([open]) .guide { display: none; }
    .guide { position: absolute; right: 8px; top: 48px; width: min(400px, calc(100vw - 16px));
      max-height: calc(100dvh - 64px); overflow: auto; padding: 20px; border: 1px solid #536c83;
      border-radius: 8px; background: #101b2a; box-shadow: 0 12px 32px #0008; line-height: 1.6; }
    .guide h2 { margin: 0; font-size: 17px; }
    .guide p { color: #b7c8da; }
    .guide ul { padding-left: 20px; }
    .guide a { color: #a2e2ff; }
    .guide-links { display: flex; gap: 20px; }
    #display-status { margin: 0; color: #ffe082; }
  </style>
</head>
<body>
  <canvas id="app" class="stage-canvas" width="${demo.width || 320}" height="${demo.height || 240}"
    data-kagura-presentation="fullscreen" data-kagura-inset-top="48" tabindex="0"
    aria-label="${escapeAttr(demo.title)} ゲーム画面"></canvas>
  <nav class="presentation-tools" data-kagura-overlay aria-label="表示と操作">
    <h1 class="game-title">${escapeHtml(demo.title)}</h1>
    <div class="tool-actions">
      <button id="fullscreen" type="button" aria-pressed="false">全画面</button>
      <details id="game-guide"><summary>操作ガイド</summary><section class="guide">
        <h2>Controls</h2>
        <p>${escapeHtml(demo.summary)}</p>
        <p>${escapeHtml(demo.start)}</p>
        <ul>${controlsHtml}</ul>
        <p class="guide-links"><a href="${escapeAttr(homeHref)}">${escapeHtml(homeLabel)}</a>
          <a href="${escapeAttr(demo.githubHref)}">Source</a></p>
        <p id="display-status" role="status"></p>
      </section></details>
    </div>
  </nav>
  <script>
    const canvas = document.querySelector('#app');
    const tools = document.querySelector('.presentation-tools');
    const fullscreen = document.querySelector('#fullscreen');
    const guide = document.querySelector('#game-guide');
    const status = document.querySelector('#display-status');
    canvas.addEventListener('contextmenu', event => event.preventDefault());
    for (const type of ['mousedown', 'mouseup', 'pointerdown', 'pointerup', 'touchstart', 'touchend', 'keydown', 'keyup']) {
      tools.addEventListener(type, event => event.stopPropagation());
    }
    fullscreen.addEventListener('click', async () => {
      try {
        const entered = document.fullscreenElement ? (await document.exitFullscreen(), true)
          : await globalThis.__kaguraPresentation?.requestFullscreen();
        status.textContent = entered ? '' : 'このブラウザでは全画面表示を使用できません。';
        if (!entered) guide.open = true;
      } catch {
        status.textContent = '全画面表示を開始できませんでした。';
        guide.open = true;
      }
      canvas.focus({preventScroll: true});
    });
    document.addEventListener('fullscreenchange', () => {
      fullscreen.textContent = document.fullscreenElement ? '全画面を終了' : '全画面';
      fullscreen.setAttribute('aria-pressed', String(Boolean(document.fullscreenElement)));
    });
    document.addEventListener('pointerdown', event => {
      if (guide.open && !tools.contains(event.target)) guide.open = false;
    });
    guide.addEventListener('keydown', event => {
      if (event.key === 'Escape') { guide.open = false; canvas.focus({preventScroll: true}); }
    });
  </script>
  ${renderWebRuntimeImportMap(libPrefix)}
  ${scriptTag}
</body>
</html>
`;
}

export function renderLandingHtml({ demos = DEMO_PAGES }) {
  const gameCards = catalog.filter(item => item.kind === 'game')
    .sort((a, b) => a.gallery.order - b.gallery.order)
    .map(item => renderLandingCard({
      title: item.title,
      playHref: `./${item.gallery.playPath ?? `${item.id}/`}`,
      summary: item.gallery.description,
      controls: item.controls,
      tags: [item.gallery.dimension, item.gallery.genre],
    })).join('\n');
  const sections = DEMO_GROUPS.map((group) => {
    const cards = demos
      .filter((demo) => demo.group === group)
      .map((demo) => renderLandingCard(demo, 4))
      .join("\n");
    return `      <section class="group">
        <div class="group-head">
          <h3>${escapeHtml(group)}</h3>
        </div>
        <div class="grid">
${cards}
        </div>
      </section>`;
  }).join("\n");

  return `<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />
    <title>Kagura Examples</title>
    <style>
      :root {
        color-scheme: dark;
        --bg: #08101a;
        --panel: rgba(10, 16, 28, 0.88);
        --panel-border: rgba(128, 156, 196, 0.22);
        --muted: #9fb0c7;
        --text: #eef4ff;
        --accent: #79d4ff;
        --accent-strong: #ffe082;
      }
      * {
        box-sizing: border-box;
      }
      body {
        margin: 0;
        min-height: 100svh;
        font-family: system-ui, sans-serif;
        color: var(--text);
        background:
          radial-gradient(circle at top, rgba(73, 122, 183, 0.26), transparent 34rem),
          linear-gradient(180deg, #0d1524 0%, var(--bg) 100%);
      }
      .page {
        width: min(100%, 80rem);
        margin: 0 auto;
        padding: 1rem;
        display: flex;
        flex-direction: column;
        gap: 1rem;
      }
      .hero,
      .card {
        background: var(--panel);
        border: 1px solid var(--panel-border);
        border-radius: 1.25rem;
        box-shadow: 0 1rem 3rem rgba(0, 0, 0, 0.25);
      }
      .hero {
        padding: 1rem;
      }
      .hero {
        display: flex;
        flex-direction: column;
        gap: 0.75rem;
      }
      .hero-top {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 0.75rem;
        flex-wrap: wrap;
      }
      h1,
      h2,
      h3,
      h4,
      p {
        margin: 0;
      }
      .muted {
        color: var(--muted);
        line-height: 1.6;
      }
      .group {
        display: flex;
        flex-direction: column;
        gap: 0.75rem;
      }
      .grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(15rem, 1fr));
        gap: 1rem;
      }
      .card {
        padding: 1rem;
        display: flex;
        flex-direction: column;
        gap: 0.6rem;
      }
      .card a {
        color: inherit;
        text-decoration: none;
      }
      .card a:hover h3,
      .card a:hover h4 {
        text-decoration: underline;
      }
      .tag-list {
        list-style: none;
        margin: 0;
        padding: 0;
        display: flex;
        flex-wrap: wrap;
        gap: 0.5rem;
      }
      .tag-list li {
        padding: 0.25rem 0.6rem;
        border-radius: 999px;
        background: rgba(121, 212, 255, 0.12);
        border: 1px solid rgba(121, 212, 255, 0.24);
        color: #d7f5ff;
        font-size: 0.82rem;
      }
      .card strong {
        color: var(--accent-strong);
      }
      .group-head {
        display: flex;
        justify-content: space-between;
        align-items: center;
        gap: 0.75rem;
        flex-wrap: wrap;
      }
      @media (max-width: 520px) {
        .page {
          padding: 0.75rem;
        }
        .hero,
        .card {
          border-radius: 1rem;
        }
      }
    </style>
  </head>
  <body>
    <div class="page">
      <header class="hero">
        <div class="hero-top">
          <h1>Kagura Examples</h1>
        </div>
        <p class="muted">
          Interactive examples for Kagura, a MoonBit game engine. Open any card below to launch the demo, review controls, and jump to source.
        </p>
        <p><a href="./examples/" style="color: var(--accent)">Browse games and technical demos with screenshots →</a></p>
      </header>

      <section class="group" id="games">
        <div class="group-head"><h2>Games</h2></div>
        <div class="grid">${gameCards}</div>
      </section>

      <section class="group" id="technical-demos">
        <div class="group-head"><h2>Technical Demos</h2></div>
${sections}
      </section>

      <section class="group">
        <div class="group-head"><h2>Studio</h2></div>
        <div class="grid">
          <article class="card">
            <a href="./studio/"><h3>Kagura Studio</h3></a>
            <p class="muted">Edit scenes, preview motions, and create 3D models in the browser.</p>
          </article>
          <article class="card">
            <a href="./studio/?mode=modeling&amp;model=kawaiko"><h3>Model kawaiko</h3></a>
            <p class="muted">Open the editable kawaiko model with Blender-style modeling controls.</p>
            <p class="muted"><strong>Controls:</strong> G / R / S: transform · Tab: edit mesh · Middle mouse: orbit</p>
          </article>
        </div>
      </section>

    </div>
  </body>
</html>
`;
}

function renderLandingCard(demo, headingLevel = 3) {
  const firstControl = demo.controls[0] ?? "Open the source for controls.";
  const tagHtml = demo.tags.map((tag) => `<li>${escapeHtml(tag)}</li>`).join("");
  return `          <article class="card">
            <a href="${escapeAttr(demo.playHref ?? `./${demo.name}/`)}">
              <h${headingLevel}>${escapeHtml(demo.title)}</h${headingLevel}>
            </a>
            <p class="muted">${escapeHtml(demo.summary)}</p>
            ${demo.start ? `<p class="muted"><strong>Start:</strong> ${escapeHtml(demo.start)}</p>` : ''}
            <p class="muted"><strong>Controls:</strong> ${escapeHtml(firstControl)}</p>
            <ul class="tag-list">${tagHtml}</ul>
          </article>`;
}

function humanizeName(name) {
  return name
    .split("_")
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(" ");
}

function escapeHtml(value) {
  return String(value)
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function escapeAttr(value) {
  return escapeHtml(value);
}
