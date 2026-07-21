name = "mizchi/shadow3d_demo"

version = "0.1.0"

warnings = "-6-29-53-68"

import {
  "mizchi/web_runtime_hooks@0.1.0",
  "mizchi/kagura_core@0.2.0",
  "mizchi/kagura_engine@0.2.0",
  "mizchi/gfx@0.1.0",
  "mizchi/mesh3d@0.2.0",
  "mizchi/geom@0.2.0",
  "mizchi/anim3d@0.2.0",
}

source = "src"

options(
  "--moonbit-unstable-prebuild": "../../../scripts/moon-prebuild-native-link-flags.cjs",
)
