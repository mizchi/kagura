# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

### Added

- Kagura Studio's scene editor is a slot shell (`hierarchy`, `resources`, `viewport`, `timeline`, `inspector`, `tools`). The Luna 3D UI is the default view; 2D and runtime overlays `adopt()` a slot instead of occupying CSS classes.
- Kagura Studio Agent/Terminal hide the generic New pane / Close pane chrome. Each agent turn is prefixed with live revision, selection, scene, subjects and node IDs. sprite_anim's project manifest lists the same js+native targets as its `moon.pkg`.
- Kagura Studio's Ghostty pane speaks the gespenst.v1 binary PTY protocol (`hello` / `resize` as JSON, shell bytes as binary). Sending node-pty strings as text frames left a blank cursor.
- Kagura Studio hierarchy is a state-based scene graph (project scenes, logical subjects, observed view). Inspector and Debugger are named parts; Agent chat and a Ghostty terminal (gespenst) sit on the command pane. The in-editor agent talks to `pi-coding-agent` over a Vite sidecar and uses the same snapshot/dispatch/runtime tools as WebMCP.
- `@scene.run` publishes a UI snapshot from scene labels (same `dot_text_size` arithmetic as `append_dot_text`). Keyed groups become path prefixes; unlabeled world rects are omitted. `just render flappy_bird` / `survivor` / `card_game` / `action_rpg` / `hacknslash` now write `.snapshot.json`.
- `@scene.run` honors `capture_viewport` and an optional `snapshot_state` callback so a matrix cell's PNG size and `expectedState` match the request.
- `just ui-matrix --all` runs ui_demo plus flappy_bird, survivor, action_rpg, hacknslash, and card_game across the four default viewports. Scene games apply `capture_viewport` to HUD layout via `apply_viewport`. `--all --backend native` skips js-only examples. `just ui-matrix-gates` runs each example's `editor/theme.json` and i18n stress on standard cells (i18n gates ui_demo; scene games are advisory because label rects equal glyph boxes).
- Flappy Bird's native `load_editor_scene` no longer re-applies the baked layout. That path called `reset()` and wiped the `gameover` capture fixture, so native matrix cells came back as title.
- Scene UI snapshots publish keyed `rect` / `rect_outline` nodes with the drawn box as the hit rect. Unlabeled world rects stay omitted. card_game HUD chrome (HP bar, End Turn, card frames, enemy bodies) now has keys.
- `just ui-matrix hacknslash_3d --backend gpu` captures title and playing HUD through native wgpu. Playing 3D geometry is still black (PostFX targets are not on the capture device); HUD is composited onto `ctx.dst` in a second pass. JS CI does not run this. Game code lives in `examples/games/hacknslash_3d/app/` so the native GPU entry does not import the main package.
- hacknslash_3d publishes a named HUD snapshot (title, playing HP/floor/gold, game over, inventory) through `@hud.HudContext` measure, not the scene walker.
- `just ui-check --image` scores WCAG AA contrast from the frame PNG. vlmkit's image-only integrity skips `low-contrast-text` (no computed colors); the gate crops each text node, splits ink from backdrop, and uses 4.5:1 (3:1 at 24px+).
- `just ui-i18n-stress` is the canvas counterpart of `vlmkit stress i18n`: inflate snapshot strings, re-measure with `dot_text_size`, re-run integrity, and report glyphs the 3x5 HUD atlas cannot draw.
- `just ui-theme-check` diffs a frame palette against a declared token table (`editor/theme.json`). Colors farther than `maxDistance` from every token are hard-coded literals. `just ui-assets` runs `vlmkit check asset` over `editor/assets.json`.
- `just vlm-ui-review --matrix` walks every state x viewport in `editor/verification.json`. `just vlm-ui-daemon-start` keeps the example bundle warm and accepts `POST /review` (dry-run by default, `--execute` to call the VLM).
- Native capture can drive the real wgpu pipeline (`backend=gpu`). CPU remains the portable 2D path; GPU is what 3D uses, because the CPU rasterizer skips those commands. `just capture pbr_demo output/capture "--backend gpu"` writes PNG + context through `@engine.run`.
- Added high-level `@engine.run_game` and `@scene.run_game` helpers with `EngineGame` and `SceneGame` traits so simple examples can launch from state objects directly.
- Added `@ui.UISnapshot` and `@ui.publish_ui_snapshot`, publishing the laid-out UI tree (rects, clip rects, measured text extents, hit rects, focus order) to `globalThis.__kaguraUISnapshot`. A canvas UI has no DOM, so this is what lets external tooling name a UI node instead of seeing one opaque canvas.
- Added `@renderer2d.dot_text_size`, the dot-text measurement `append_dot_text` lays out with, so an overflow verdict measures with the same arithmetic that draws.
- Added `just ui-check`, a deterministic UI defect gate over a published snapshot (text overflow, clipping, off-screen HUD, safe-area intrusion, text collision, hit-box drift, collapsed and escaping nodes), plus `just ui-elements` to convert a snapshot into a vlmkit `--elements-json` payload and `just ui-asset-check` to vet a sprite before it enters a UI slot.
- Added `docs/tools/vlmkit-game-ui-verification.md` (what canvas game UI can and cannot verify with vlmkit) and `docs/tools/ui-verification-runbook.md` (how to run the gates).
- Added `mizchi/kagura_engine/capture`, the native frame-capture plumbing: config parsing, RGBA8-to-PNG encoding, silhouette binarisation, and (in its native sub-package) reading the staged config and writing the frame, context and summary. Native capture is the portable path — the web canvas capture is transparent headless and the Linux Dawn readback never completes. `just capture <example>` stages the config and runs the example on the native backend.

### Changed

- Kagura Studio now uses `mizchi/luna@0.25.0` (`mizchi/js` / `mizchi/js_browser` 0.12.2). `luna_components` stays at the latest published 0.23.2.
- Renamed progression APIs to make intent explicit around XP accrual, level thresholds, weighted selection, loot rarity sampling, and loot stat scaling.
- Renamed `gameplay2d` pickup APIs to separate effect resolution from applying the resulting actor state changes.
- Renamed `interactable2d` APIs to use consistent parsing, blocking, interaction-frame, and anchor-selection terminology.
- Renamed `scene_manager` transition getters to describe transition progress and overlay alpha explicitly.
- Updated `examples/hacknslash_3d` and simple example entrypoints to follow the renamed APIs and high-level launch helpers.
- Extracted the shared 3D authoring code into `mizchi/kagura_modeling3d`. The five authoring examples had byte-identical copies of eleven files, so a one-line fix meant editing five of them; each example now carries only its model data, its review profile and three-line entry points.
- **Behaviour change:** the round-trip importer now compares primitive colours at the hex precision the document stores, not with `approx_eq(1e-5)`. `chair`, `model` and `shelf` previously emitted a no-op `set_color` patch for float noise below 1/255, which the document cannot represent. `dragon` and `frog` already behaved this way.
- Replaced deprecated `to_repr` with `Repr` across every `Show` impl, restoring `moon check --deny-warn` (the gate `just check-release` and CI use) on the current MoonBit toolchain.
- Bumped `@playwright/test` to satisfy `@mizchi/vlmkit`'s `>=1.61` peer requirement, and added `@mizchi/vlmkit` plus a `.mcp.json` entry for it.
- `examples/smoke/native_vrt` now writes its baselines as PNG rather than BMP, so they are directly consumable by the image tooling instead of needing a conversion first.

### Removed

- Removed the 18 VRT baselines that were pure black. A black baseline fails a legitimate render, and keeping them implied visual coverage that did not exist. Portable frame capture is tracked in #9, re-gating VRT in #8.

### Fixed

- `just check-release` allows `mizchi/kagura_game` to depend on `mizchi/kagura_ui`. Scene UI snapshots import the engine UI module; the import boundary already allowed it, the release dep policy did not.
- `aabb_from_mesh` panicked on a mesh with no vertices: it guarded `count > 0` and then read `data[0]`. It now returns the degenerate box at the origin, so a placeholder or not-yet-loaded mesh passes through broadphase.
- UI snapshot and authoring JSON generation escaped only five characters by hand, so a control character produced a document the consumer could not parse. Both now use the stdlib encoder.
- `model-authoring-vlm-daemon-utils.test.mjs` asserted a literal absolute path, so `just modeling3d-test` only passed on the machine it was recorded on.
- `native-windows` CI failed compiling MoonBit's own C runtime: clang 16+ made an implicit function declaration an error and the runtime calls `putchar` without including `<stdio.h>`. The Windows compiler wrapper now demotes that to a warning for the toolchain's files only, so our own C stays strict. The wrapper also stopped duplicating its argument filter — `setup-windows-native.sh` generated a second inline copy that MOON_CC used while the unit-tested one served only the link step.
- A capture that could not read its config or encode its frame panicked without saying which; it now names the missing key or the unwritable path.

### Internal

- Ignore `.DS_Store` in git.
