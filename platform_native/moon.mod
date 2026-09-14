name = "mizchi/native_runtime_hooks"

version = "0.5.0"

description = "Native platform integration for Kagura: windowing, WebGPU, audio, capture and host services"

repository = "https://github.com/mizchi/kagura"

license = "Apache-2.0"

warnings = "-6-29-53-68"

import {
  "mizchi/glfw@0.2.3",
  "mizchi/kagura_core@0.5.0",
  "mizchi/kagura_engine@0.5.0",
  "mizchi/gfx@0.1.0",
  "mizchi/text@0.5.0",
  "mizchi/atlas@0.5.0",
  "mizchi/renderer2d@0.5.0",
  "mizchi/kagura_platform@0.5.0",
  "mizchi/kagura_audio@0.5.0",
}

options(
  "--moonbit-unstable-prebuild": "../scripts/moon-prebuild-native-link-flags.cjs",
)
