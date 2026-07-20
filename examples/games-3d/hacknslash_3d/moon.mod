name = "mizchi/hacknslash_3d"

version = "0.1.0"

warnings = "-6-29-53-68-deprecated"

import {
  "mizchi/font@0.7.0",
  "mizchi/kagura_effect_studio@0.1.0",
  "mizchi/web_runtime_hooks@0.1.0",
  "mizchi/terrain@0.1.1",
  "mizchi/differentiable_ecs@0.2.1",
  "mizchi/parquet@0.2.0",
  "moonbitlang/x@0.4.40",
  "mizchi/kagura_game@0.2.0",
  "mizchi/kagura_core@0.2.0",
  "mizchi/kagura_engine@0.2.0",
  "mizchi/gfx@0.1.0",
  "mizchi/text@0.2.0",
  "mizchi/mesh3d@0.2.0",
  "mizchi/geom@0.2.0",
  "mizchi/atlas@0.2.0",
  "mizchi/anim3d@0.2.0",
  "mizchi/physics@0.2.0",
  "mizchi/pathfind@0.2.0",
  "mizchi/kagura_ui@0.1.0",
}

source = "src"

options(
  "--moonbit-unstable-prebuild": "../../../scripts/moon-prebuild-native-link-flags.cjs",
)
