# mizchi/kagura_game

`game` contains Kagura packages that are tied to gameplay, simulation,
scene orchestration, and game-specific helpers.

The root `mizchi/kagura` module remains the rendering/runtime infrastructure
layer (`core`, `engine`, `gltf`, and renderer-facing packages). This module
depends on that infrastructure and must not be imported by it.

This directory is the `mizchi/kagura_game` module root; imports keep that module
name. `pathfind/` and `machinations/` are independent nested modules, excluded
from this module's published package.

`scene_flow/` owns renderer-independent transition requests and portal triggers.
`scene_data/` holds portable authored scenes and collision bounds.
`scene_manager/` remains responsible for updating/drawing scenes and fades.
See [game project patterns](../docs/editor/game-projects.md).
