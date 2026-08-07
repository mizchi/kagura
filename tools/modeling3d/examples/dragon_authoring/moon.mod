name = "mizchi/dragon_authoring"

version = "0.1.0"

warnings = "-6-29-53-68-deprecated"

import {
  "mizchi/kagura_modeling3d@0.1.0",
  "mizchi/native_runtime_hooks@0.1.0",
  "mizchi/web_runtime_hooks@0.1.0",
  "mizchi/kagura_game@0.2.0",
  "mizchi/kagura_core@0.2.0",
  "mizchi/kagura_engine@0.2.0",
  "mizchi/gfx@0.1.0",
  "mizchi/mesh3d@0.2.0",
  "mizchi/renderer2d@0.2.0",
  "mizchi/geom@0.2.0",
  "mizchi/atlas@0.2.0",
  "mizchi/physics@0.2.0",
  "mizchi/kagura_platform@0.1.0",
}

source = "src"

options(
  "--moonbit-unstable-prebuild": "../../../../scripts/moon-prebuild-native-link-flags.cjs",
)
