name = "mizchi/flappy_bird"

version = "0.1.0"

warnings = "-6-29-53-68"

import {
  "mizchi/signals@0.6.5",
  "mizchi/web_runtime_hooks@0.1.0",
  "mizchi/kagura_game@0.2.0",
  "mizchi/kagura_engine@0.2.0",
  "mizchi/kagura_ui@0.1.0",
  "mizchi/kagura_core@0.2.0",
}

options(
  "--moonbit-unstable-prebuild": "../../../scripts/moon-prebuild-native-link-flags.cjs",
)
