name = "mizchi/native_vrt"

version = "0.1.0"

warnings = "-6-29-53-68"

import {
  "mizchi/native_runtime_hooks@0.7.1",
  "mizchi/pixelmatch@0.6.1",
  "mizchi/image@0.5.0",
  "mizchi/kagura_engine@0.7.1",
}

options(
  "--moonbit-unstable-prebuild": "../../../scripts/moon-prebuild-native-link-flags.cjs",
)
