name = "mizchi/native_vrt"

version = "0.1.0"

warnings = "-6-29-53-68"

import {
  "mizchi/native_runtime_hooks@0.1.0",
  "mizchi/pixelmatch@0.3.5",
  "mizchi/image@0.4.3",
  "mizchi/kagura_engine@0.2.0",
}

source = "src"

options(
  "--moonbit-unstable-prebuild": "../../../scripts/moon-prebuild-native-link-flags.cjs",
)
