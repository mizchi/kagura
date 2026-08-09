# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

### Added

- Added high-level `@engine.run_game` and `@scene.run_game` helpers with `EngineGame` and `SceneGame` traits so simple examples can launch from state objects directly.
- Added `@ui.UISnapshot` and `@ui.publish_ui_snapshot`, publishing the laid-out UI tree (rects, clip rects, measured text extents, hit rects, focus order) to `globalThis.__kaguraUISnapshot`. A canvas UI has no DOM, so this is what lets external tooling name a UI node instead of seeing one opaque canvas.
- Added `@renderer2d.dot_text_size`, the dot-text measurement `append_dot_text` lays out with, so an overflow verdict measures with the same arithmetic that draws.
- Added `just ui-check`, a deterministic UI defect gate over a published snapshot (text overflow, clipping, off-screen HUD, safe-area intrusion, text collision, hit-box drift, collapsed and escaping nodes), plus `just ui-elements` to convert a snapshot into a vlmkit `--elements-json` payload and `just ui-asset-check` to vet a sprite before it enters a UI slot.
- Added `docs/tools/vlmkit-game-ui-verification.md` (what canvas game UI can and cannot verify with vlmkit) and `docs/tools/ui-verification-runbook.md` (how to run the gates).
- Added `mizchi/kagura_engine/capture`, the native frame-capture plumbing: config parsing, RGBA8-to-PNG encoding, silhouette binarisation, and (in its native sub-package) reading the staged config and writing the frame, context and summary. Native capture is the portable path — the web canvas capture is transparent headless and the Linux Dawn readback never completes. `just capture <example>` stages the config and runs the example on the native backend.

### Changed

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

- `aabb_from_mesh` panicked on a mesh with no vertices: it guarded `count > 0` and then read `data[0]`. It now returns the degenerate box at the origin, so a placeholder or not-yet-loaded mesh passes through broadphase.
- UI snapshot and authoring JSON generation escaped only five characters by hand, so a control character produced a document the consumer could not parse. Both now use the stdlib encoder.
- `model-authoring-vlm-daemon-utils.test.mjs` asserted a literal absolute path, so `just modeling3d-test` only passed on the machine it was recorded on.
- `native-windows` CI failed compiling MoonBit's own C runtime: clang 16+ made an implicit function declaration an error and the runtime calls `putchar` without including `<stdio.h>`. The Windows compiler wrapper now demotes that to a warning for the toolchain's files only, so our own C stays strict. The wrapper also stopped duplicating its argument filter — `setup-windows-native.sh` generated a second inline copy that MOON_CC used while the unit-tested one served only the link step.
- A capture that could not read its config or encode its frame panicked without saying which; it now names the missing key or the unwritable path.

### Internal

- Ignore `.DS_Store` in git.
