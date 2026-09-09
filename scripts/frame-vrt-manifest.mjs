/**
 * What the browser-free visual regression gate renders and compares.
 *
 * Every entry here is rendered by the engine's headless path through the CPU
 * rasterizer (`engine/kagura_engine/raster`), so the frame is pure arithmetic:
 * no GPU, no driver, no compositor, and therefore byte-identical run to run.
 * That is what makes a real gate possible where the Playwright VRT could only
 * ever run with `--update-snapshots`.
 *
 * To be in this list an example must render **something legible**. A frame that
 * is one flat color proves nothing -- the repository already carried 18 pure
 * black baselines that passed forever while verifying nothing -- so the gate
 * refuses to pin a uniform frame unless the entry says `allowUniform` and gives
 * a reason.
 *
 * Deliberately absent:
 *
 * - 3D examples. The CPU rasterizer draws 2D commands only and counts the rest
 *   in `skipped_commands`; a baseline missing the whole scene is worse than no
 *   baseline. Those stay with `just capture` (native) or a real browser.
 * - `sprite_anim`. Its frame is a single sprite quad, and an atlas texture the
 *   rasterizer has not been handed samples as white -- the frame comes out
 *   100% `#fcfcfc`. Exactly the baseline this gate exists to reject.
 * - `fetch_image`. It loads its image before starting the engine, so a headless
 *   render publishes no frame at all.
 */

/**
 * `frames` is how many update ticks run before the captured draw. Pick the
 * smallest number that reaches the state worth pinning: a title screen needs
 * almost none, a simulation needs enough to settle.
 */
export const FRAME_VRT_ENTRIES = [
  // The UI demo carries a published UI snapshot, so a diff here can name the
  // node that changed instead of a bare rectangle. Three states, because a UI
  // breaks in its states rather than at rest.
  { example: "ui_demo", frames: 3 },
  { example: "ui_demo", state: "hover", frames: 3, cursor: [100, 74] },
  { example: "ui_demo", state: "focus", frames: 3, keys: [9] },

  { example: "draw2d_ui_demo", frames: 30 },
  { example: "machinations_demo", frames: 30 },
  { example: "physics2d_demo", frames: 30 },
  { example: "scene_demo", frames: 30 },
  { example: "ecs_demo", frames: 30 },

  { example: "card_game", frames: 30 },
  { example: "flappy_bird", frames: 30 },
  { example: "action_rpg", frames: 30 },
  { example: "hacknslash", frames: 30 },
  { example: "survivor", frames: 30 },
];
