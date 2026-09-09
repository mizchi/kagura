name = "mizchi/crater_renderer"

version = "0.1.0"

warnings = "-6-29-53-68"

import {
  "mizchi/web_runtime_hooks@0.1.0",
  "mizchi/native_runtime_hooks@0.1.0",
  "mizchi/crater-renderer@0.19.0",
  "mizchi/crater-painter@0.19.0",
  "mizchi/css@0.7.3",
  "mizchi/font@0.7.3",
  "mizchi/kagura_core@0.2.0",
  "mizchi/kagura_engine@0.2.0",
  "mizchi/gfx@0.1.0",
  "mizchi/text@0.2.0",
  "mizchi/renderer2d@0.2.0",
  "mizchi/widget2d@0.2.0",
  "mizchi/atlas@0.2.0",
}

source = "src"

options(
  "--moonbit-unstable-prebuild": "../../../scripts/moon-prebuild-native-link-flags.cjs",
)
