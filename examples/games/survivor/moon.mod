name = "mizchi/survivor"

version = "0.1.0"

warnings = "-6-29-53-68"

import {
  "mizchi/signals@0.6.6",
  "mizchi/web_runtime_hooks@0.7.0",
  "mizchi/kagura_game@0.7.0",
  "mizchi/kagura_engine@0.7.0",
  "mizchi/kagura_core@0.7.0",
  "mizchi/geom@0.7.0",
}

options(
  "--moonbit-unstable-prebuild": "../../../scripts/moon-prebuild-native-link-flags.cjs",
)
