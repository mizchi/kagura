name = "mizchi/native_triangle"

version = "0.1.0"

warnings = "-6-29-53-68"

import {
  "mizchi/native_runtime_hooks@0.1.0",
}

source = "src"

options(
  "--moonbit-unstable-prebuild": "../../../scripts/moon-prebuild-native-link-flags.cjs",
)
