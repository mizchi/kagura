// Validation policy, independent of the publication catalog.
export const EXTRA_CHECK_MODULES = Object.freeze([
  { dir: "editor/studio", targets: ["js"], group: "standalone" },
  { dir: "editor/model-viewer", targets: ["js"], group: "standalone" },
  { dir: "editor/modeling3d", targets: ["js", "native"], group: "standalone" },
  {
    dir: "editor/effect-studio",
    targets: ["js", "native"],
    group: "standalone",
  },
  {
    dir: "examples/experimental/wasm_game/guest/moonbit",
    targets: ["wasm"],
    group: "standalone",
  },
  {
    dir: "examples/smoke/wasm_async_smoke",
    targets: ["wasm"],
    group: "standalone",
  },
  { dir: "assets/vendor/glfw", targets: ["native"], group: "standalone" },
  {
    dir: "examples/experimental/crater_paint",
    targets: ["native"],
    group: "external",
    externalCheckout: "../crater",
  },
  {
    dir: "examples/smoke/browser_headless",
    targets: ["native"],
    group: "external",
    externalCheckout: "../crater",
  },
]);
export const EXTERNAL_EXAMPLES = new Set(
  EXTRA_CHECK_MODULES.filter((entry) => entry.group === "external").map(
    (entry) => entry.dir,
  ),
);
