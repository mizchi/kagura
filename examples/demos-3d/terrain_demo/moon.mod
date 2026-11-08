name = "mizchi/terrain_demo"

version = "0.1.0"

warnings = "-6-29-53-68"

import {
  "mizchi/terrain@0.1.1",
  "mizchi/web_runtime_hooks@0.7.1",
  "mizchi/native_runtime_hooks@0.7.1",
  "mizchi/kagura_game@0.7.1",
  "mizchi/kagura_core@0.7.1",
  "mizchi/kagura_engine@0.7.1",
  "mizchi/gfx@0.1.1",
  "mizchi/mesh3d@0.7.1",
  "mizchi/geom@0.7.1",
  "mizchi/anim3d@0.7.1",
  "mizchi/pathfind@0.7.1",
}

options(
  "--moonbit-unstable-prebuild": "../../../scripts/moon-prebuild-native-link-flags.cjs",
)
