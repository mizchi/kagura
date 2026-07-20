name = "mizchi/kagura_native_runtime"

version = "0.1.0"

description = "Native-only WGPU + audio runtime backend for Kagura (extracted from kagura_engine; counterpart to kagura_js_runtime)"

repository = "https://github.com/mizchi/kagura"

license = "Apache-2.0"

warnings = "-6-29-53-68"

preferred_target = "native"

import {
  "mizchi/kagura_engine@0.2.0",
  "mizchi/glfw@0.2.2",
  "mizchi/kagura_audio@0.1.0",
}

options(
  "--moonbit-unstable-prebuild": "../../scripts/moon-prebuild-native-link-flags.cjs",
)
