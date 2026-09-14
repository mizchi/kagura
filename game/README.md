# mizchi/kagura_game

`game` contains Kagura packages that are tied to gameplay, simulation,
scene orchestration, and game-specific helpers.

The root `mizchi/kagura` module remains the rendering/runtime infrastructure
layer (`core`, `engine`, `gltf`, and renderer-facing packages). This module
depends on that infrastructure and must not be imported by it.

This directory is the `mizchi/kagura_game` module root; imports keep that module
name. `machinations/` is an independent nested module, excluded
from this module's published package.

`scene_flow/` owns renderer-independent transition requests and portal triggers.
`scene_data/` holds portable authored scenes and collision bounds.
`scene_manager/` remains responsible for updating/drawing scenes and fades.
See [game project patterns](../docs/editor/game-projects.md).

Physics, IK, pathfinding and terrain calculations live in `core`. Display scenes,
HUD, tile rendering, sprite packing and inspection live in `engine`.
`inventory_web/` owns the MoonBit JS adapter for inventory previews and comparisons;
`just web-runtime-build` emits `assets/web/kagura-inventory.generated.js`.

`inpututil/` maps physical input states to game movement/confirmation commands.
Key, mouse, touch and gamepad edge detection is provided by `core/inputstate`.
The unused common AI prototype has been removed; games own their enemy behavior.
