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
`inventory/` owns typed item footprints, grid placement, exchange previews and stat comparisons.
Both the simulation and `inventory_web/` use these contracts. `inventory_web/` only converts JS objects;
`just web-runtime-build` emits `assets/web/kagura-inventory.generated.js`.

`inpututil/` maps physical input states to game movement/confirmation commands.
Key, mouse, touch and gamepad edge detection is provided by `core/inputstate`.
The unused common AI prototype has been removed; games own their enemy behavior.

`character3d/` provides a force-driven movement motor and spherical ground probes.
It controls acceleration toward a desired speed while keeping collision momentum
in `core/physics3d`. See [character3d](character3d/README.md).

`projectile3d/` provides renderer-independent telegraphed beam paths. Simulation,
rendering and HUD sample the same immutable timing/trajectory contract; games own
damage, hit history and encounter progression. See [projectile3d](projectile3d/README.md).
