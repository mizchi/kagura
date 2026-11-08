name = "mizchi/emberwing"

version = "0.1.0"

preferred_target = "js"

warnings = "-6-29-53-68"

import {
  "mizchi/web_runtime_hooks@0.7.0",
  "mizchi/kagura_engine@0.7.0",
  "mizchi/kagura_game@0.7.0",
  "mizchi/gfx@0.1.1",
  "mizchi/mesh3d@0.7.0",
  "mizchi/geom@0.7.0",
}

options(
  "--moonbit-unstable-prebuild": "../../../scripts/moon-prebuild-native-link-flags.cjs",
)
