name = "mizchi/headless_screenshot"

version = "0.1.0"

warnings = "-6-29-53-68"

import {
  "mizchi/native_runtime_hooks@0.6.0",
  "mizchi/kagura_engine@0.6.0",
}

options(
  "--moonbit-unstable-prebuild": "../../../scripts/moon-prebuild-native-link-flags.cjs",
)
