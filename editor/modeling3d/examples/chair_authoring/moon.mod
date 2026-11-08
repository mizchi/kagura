name = "mizchi/chair_authoring"

version = "0.1.0"

warnings = "-6-29-53-68-deprecated"

import {
  "mizchi/kagura_modeling3d@0.1.0",
  "mizchi/native_runtime_hooks@0.7.1",
  "mizchi/web_runtime_hooks@0.7.1",
  "mizchi/kagura_game@0.7.1",
  "mizchi/kagura_core@0.7.1",
  "mizchi/kagura_engine@0.7.1",
  "mizchi/gfx@0.1.1",
  "mizchi/mesh3d@0.7.1",
  "mizchi/renderer2d@0.7.1",
  "mizchi/geom@0.7.1",
  "mizchi/atlas@0.7.1",
  "mizchi/kagura_platform@0.7.1",
}

options(
  "--moonbit-unstable-prebuild": "../../../../scripts/moon-prebuild-native-link-flags.cjs",
)
