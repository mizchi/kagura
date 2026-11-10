name = "mizchi/belt_action"

version = "0.1.0"

preferred_target = "js"

warnings = "-6-29-53-68"

import {
  "mizchi/renderer2d@0.7.1",
  "mizchi/kagura_engine@0.7.1",
  "mizchi/kagura_game@0.7.1",
  "mizchi/kagura_core@0.7.1",
  "mizchi/web_runtime_hooks@0.7.1",
}

options(
  "--moonbit-unstable-prebuild": "../../../scripts/moon-prebuild-native-link-flags.cjs",
)
