# mizchi/kagura_game

`modules/game` contains Kagura packages that are tied to gameplay, simulation,
scene orchestration, and game-specific helpers.

The root `mizchi/kagura` module remains the rendering/runtime infrastructure
layer (`core`, `engine`, `gltf`, and renderer-facing packages). This module
depends on that infrastructure and must not be imported by it.
