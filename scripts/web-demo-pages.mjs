import { existsSync, readdirSync } from "node:fs";
import { join } from "node:path";

const GITHUB_BLOB_ROOT = "https://github.com/mizchi/kagura/blob/main";

const RAW_DEMO_PAGES = [
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
    sourcePath: "examples/flappy_bird/src/game.mbt",
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
    sourcePath: "examples/survivor/src/game.mbt",
  },
  {
    name: "action_rpg",
    title: "Action RPG",
    group: "Games",
    summary: "Tilemap, AI, audio, and UI showcase.",
    start: "Press Space to enter the dungeon.",
    controls: [
      "WASD / Arrow: move",
      "Space: start / attack / confirm",
      "Esc: pause menu",
    ],
    tags: ["2D", "AI", "UI"],
    sourcePath: "examples/action_rpg/src/game.mbt",
  },
  {
    name: "hacknslash",
    title: "Hack & Slash",
    group: "Games",
    summary: "Compact 2D action prototype.",
    start: "Press Space to start.",
    controls: [
      "WASD / Arrow: move",
      "Space: start / attack / restart",
    ],
    tags: ["2D", "Combat"],
    sourcePath: "examples/hacknslash/src/game.mbt",
  },
  {
    name: "hacknslash_3d",
    title: "Hack & Slash 3D",
    group: "Games",
    summary: "3D action prototype with RPG overlays.",
    start: "Press Space to begin, then move into combat.",
    controls: [
      "WASD / Arrow: move",
      "Space: confirm / use skill prompt",
      "I: inventory, K: skill tree, Esc: pause",
    ],
    tags: ["3D", "Combat", "RPG"],
    sourcePath: "examples/hacknslash_3d/src/update.mbt",
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
    sourcePath: "examples/scene_demo/src/game.mbt",
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
    sourcePath: "examples/ui_demo/src/game.mbt",
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
    sourcePath: "examples/fetch_image/src/main.mbt",
  },
  {
    name: "arena3d",
    title: "Arena 3D",
    group: "3D Rendering",
    summary: "3D arena prototype using the low-level renderer.",
    start: "Opens directly into the scene.",
    controls: [
      "Watch the scene render",
      "See source for camera / scene setup",
    ],
    tags: ["3D", "Renderer"],
    sourcePath: "examples/arena3d/src/game.mbt",
  },
  {
    name: "fps_demo",
    title: "FPS Demo",
    group: "3D Rendering",
    summary: "First-person movement and shooting demo.",
    start: "Move immediately after load.",
    controls: [
      "WASD: move",
      "Mouse: look",
      "Left click: shoot",
      "Space: jump",
    ],
    tags: ["3D", "FPS"],
    sourcePath: "examples/fps_demo/src/game.mbt",
  },
  {
    name: "obj_viewer",
    title: "OBJ Viewer",
    group: "3D Rendering",
    summary: "Interactive OBJ mesh viewer.",
    start: "Drag the model to inspect it.",
    controls: [
      "Left drag: orbit camera",
      "Wheel: zoom",
    ],
    tags: ["3D", "Asset"],
    sourcePath: "examples/obj_viewer/src/main_js.mbt",
  },
  {
    name: "gltf_viewer",
    title: "glTF Viewer",
    group: "3D Rendering",
    summary: "Interactive glTF / GLB viewer.",
    start: "Drag the scene or zoom in.",
    controls: [
      "Left drag: orbit camera",
      "Wheel: zoom",
    ],
    tags: ["3D", "Asset"],
    sourcePath: "examples/gltf_viewer/src/main_js.mbt",
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
    sourcePath: "examples/particle_demo/src/game.mbt",
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
    sourcePath: "examples/shadow3d_demo/src/game.mbt",
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
    sourcePath: "examples/postfx_demo/src/game.mbt",
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
    sourcePath: "examples/skeletal_anim/src/game.mbt",
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
    sourcePath: "examples/physics3d_demo/src/game.mbt",
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
    sourcePath: "examples/physics2d_demo/src/game.mbt",
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
    sourcePath: "examples/ragdoll_demo/src/game.mbt",
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
    sourcePath: "examples/collision3d_demo/src/game.mbt",
  },
];

export const DEMO_PAGES = RAW_DEMO_PAGES.map((demo) => ({
  ...demo,
  githubHref: `${GITHUB_BLOB_ROOT}/${demo.sourcePath}`,
}));

const DEMO_PAGE_MAP = new Map(DEMO_PAGES.map((demo) => [demo.name, demo]));

export const DEMO_GROUPS = [
  "Games",
  "2D / UI",
  "3D Rendering",
  "Physics",
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
  const title = humanizeName(name);
  return {
    name,
    title,
    group: "Local Example",
    summary: "Local example build for development.",
    start: "Open the stage and use the controls implemented in source.",
    controls: [
      "Browser demos currently require WebGPU",
      "Open the example source for control details",
    ],
    tags: ["Local"],
    sourcePath: `examples/${name}/src`,
    githubHref: `${GITHUB_BLOB_ROOT}/examples/${name}/src`,
  };
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
}) {
  const tagHtml = demo.tags.map((tag) => `<li>${escapeHtml(tag)}</li>`).join("");
  const controlsHtml = demo.controls
    .map((control) => `<li>${escapeHtml(control)}</li>`)
    .join("");
  return `<!doctype html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover" />
    <title>${escapeHtml(demo.title)} - Kagura</title>
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
          radial-gradient(circle at top, rgba(73, 122, 183, 0.24), transparent 34rem),
          linear-gradient(180deg, #0d1524 0%, var(--bg) 100%);
      }
      a {
        color: inherit;
      }
      .page {
        width: min(100%, 72rem);
        margin: 0 auto;
        padding: 1rem;
        display: flex;
        flex-direction: column;
        gap: 1rem;
      }
      .hero,
      .stage-panel,
      .card {
        background: var(--panel);
        border: 1px solid var(--panel-border);
        border-radius: 1.25rem;
        box-shadow: 0 1rem 3rem rgba(0, 0, 0, 0.25);
      }
      .hero {
        padding: 1rem;
        display: flex;
        flex-direction: column;
        gap: 0.75rem;
      }
      .hero-top {
        display: flex;
        justify-content: space-between;
        gap: 0.75rem;
        align-items: center;
        flex-wrap: wrap;
      }
      .hero-links {
        display: flex;
        gap: 0.75rem;
        flex-wrap: wrap;
      }
      .hero-link,
      .hero-link:visited {
        text-decoration: none;
        color: var(--accent);
        font-weight: 600;
      }
      .hero-link:hover {
        text-decoration: underline;
      }
      .badge {
        display: inline-flex;
        align-items: center;
        gap: 0.4rem;
        width: fit-content;
        padding: 0.35rem 0.7rem;
        border-radius: 999px;
        font-size: 0.85rem;
        font-weight: 700;
        color: #06111d;
        background: linear-gradient(135deg, var(--accent) 0%, #c9fbff 100%);
      }
      h1,
      h2,
      p {
        margin: 0;
      }
      .hero p,
      .card p,
      .support-copy {
        color: var(--muted);
        line-height: 1.55;
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
      .content {
        display: grid;
        grid-template-columns: minmax(0, 1.2fr) minmax(18rem, 0.8fr);
        gap: 1rem;
        align-items: start;
      }
      .stage-panel {
        padding: 1rem;
        display: flex;
        flex-direction: column;
        gap: 0.75rem;
      }
      .stage-shell {
        border-radius: 1rem;
        background: #02060d;
        border: 1px solid rgba(255, 255, 255, 0.08);
        padding: 0.75rem;
        display: flex;
        justify-content: center;
      }
      .stage-canvas {
        display: block;
        width: min(100%, 28rem);
        height: auto;
        aspect-ratio: 4 / 3;
        max-height: 62svh;
        border: 1px solid rgba(255, 255, 255, 0.12);
        background: #000;
        image-rendering: pixelated;
      }
      .side {
        display: grid;
        gap: 1rem;
      }
      .card {
        padding: 1rem;
        display: flex;
        flex-direction: column;
        gap: 0.6rem;
      }
      .card ul {
        margin: 0;
        padding-left: 1.1rem;
        color: var(--text);
      }
      .card li + li {
        margin-top: 0.35rem;
      }
      .card strong {
        color: var(--accent-strong);
      }
      @media (max-width: 860px) {
        .content {
          grid-template-columns: 1fr;
        }
      }
      @media (max-width: 520px) {
        .page {
          padding: 0.75rem;
        }
        .hero,
        .stage-panel,
        .card {
          border-radius: 1rem;
        }
        .stage-panel {
          padding: 0.75rem;
        }
        .stage-shell {
          padding: 0.5rem;
        }
        .stage-canvas {
          width: 100%;
        }
      }
    </style>
  </head>
  <body>
    <div class="page">
      <header class="hero">
        <div class="hero-top">
          <div class="hero-links">
            <a class="hero-link" href="${escapeAttr(homeHref)}">${escapeHtml(homeLabel)}</a>
            <a class="hero-link" href="${escapeAttr(demo.githubHref)}">Source</a>
          </div>
          <span class="badge">WebGPU only</span>
        </div>
        <h1>${escapeHtml(demo.title)}</h1>
        <p>${escapeHtml(demo.summary)}</p>
        <ul class="tag-list">${tagHtml}</ul>
      </header>

      <main class="content">
        <section class="stage-panel">
          <div class="stage-shell">
            <canvas id="app" class="stage-canvas" width="320" height="240"></canvas>
          </div>
          <p class="support-copy">
            <strong>Start:</strong> ${escapeHtml(demo.start)}
          </p>
          <p class="support-copy">
            Browser demos currently target WebGPU only. Recent desktop Chrome or Edge is the safest path.
          </p>
        </section>

        <aside class="side">
          <section class="card">
            <h2>Controls</h2>
            <ul>${controlsHtml}</ul>
          </section>
          <section class="card">
            <h2>Source</h2>
            <p>${escapeHtml(demo.sourcePath)}</p>
            <p>
              Open the source if you want to map the controls directly to the implementation.
            </p>
          </section>
        </aside>
      </main>
    </div>
    ${scriptTag}
  </body>
</html>
`;
}

export function renderLandingHtml({ demos = DEMO_PAGES }) {
  const sections = DEMO_GROUPS.map((group) => {
    const cards = demos
      .filter((demo) => demo.group === group)
      .map((demo) => renderLandingCard(demo))
      .join("\n");
    return `      <section class="group">
        <div class="group-head">
          <h2>${escapeHtml(group)}</h2>
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
      .card,
      .notice {
        background: var(--panel);
        border: 1px solid var(--panel-border);
        border-radius: 1.25rem;
        box-shadow: 0 1rem 3rem rgba(0, 0, 0, 0.25);
      }
      .hero,
      .notice {
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
      p {
        margin: 0;
      }
      .muted {
        color: var(--muted);
        line-height: 1.6;
      }
      .badge {
        display: inline-flex;
        align-items: center;
        gap: 0.4rem;
        width: fit-content;
        padding: 0.35rem 0.7rem;
        border-radius: 999px;
        font-size: 0.85rem;
        font-weight: 700;
        color: #06111d;
        background: linear-gradient(135deg, var(--accent) 0%, #c9fbff 100%);
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
      .card a:hover h3 {
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
        .card,
        .notice {
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
          <span class="badge">WebGPU only</span>
        </div>
        <p class="muted">
          Interactive examples for Kagura, a MoonBit game engine. Open any card below to launch the demo, review controls, and jump to source.
        </p>
      </header>

      <section class="notice">
        <p class="muted">
          Browser demos currently require WebGPU. Recent desktop Chrome or Edge is recommended. On phones, open the page in portrait and use the built-in control notes before interacting.
        </p>
      </section>

${sections}
    </div>
  </body>
</html>
`;
}

function renderLandingCard(demo) {
  const firstControl = demo.controls[0] ?? "Open the source for controls.";
  const tagHtml = demo.tags.map((tag) => `<li>${escapeHtml(tag)}</li>`).join("");
  return `          <article class="card">
            <a href="./${escapeAttr(demo.name)}/">
              <h3>${escapeHtml(demo.title)}</h3>
            </a>
            <p class="muted">${escapeHtml(demo.summary)}</p>
            <p class="muted"><strong>Start:</strong> ${escapeHtml(demo.start)}</p>
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
