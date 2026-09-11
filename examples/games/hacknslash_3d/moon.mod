name = "mizchi/hacknslash_3d"

version = "0.1.0"

warnings = "-6-29-53-68-deprecated"

import {
  // font is held at 0.7.3: 0.7.4 pulls moonbitlang/x 0.4.50, which dropped
  // `@x/fs.IOError::to_string`, and mizchi/parquet still calls it on native.
  "mizchi/font@0.7.3",
  "mizchi/kagura_effect_studio@0.1.0",
  "mizchi/web_runtime_hooks@0.1.0",
  "mizchi/terrain@0.1.1",
  "mizchi/differentiable_ecs@0.2.1",
  "mizchi/parquet@0.2.1",
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
  "mizchi/kagura_audio@0.1.0",
}

options(
  "--moonbit-unstable-prebuild": "../../../scripts/moon-prebuild-native-link-flags.cjs",
)
