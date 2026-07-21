name = "mizchi/native_runtime_hooks"

version = "0.1.0"

warnings = "-6-29-53-68"

import {
  "mizchi/kagura_core@0.2.0",
  "mizchi/kagura_engine@0.2.0",
  "mizchi/gfx@0.1.0",
  "mizchi/text@0.2.0",
  "mizchi/atlas@0.2.0",
  "mizchi/renderer2d@0.2.0",
  "mizchi/kagura_platform@0.1.0",
  "mizchi/kagura_audio@0.1.0",
}

source = "src"

options(
  "--moonbit-unstable-prebuild": "../../../scripts/moon-prebuild-native-link-flags.cjs",
)
