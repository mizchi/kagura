name = "mizchi/crater_paint"

version = "0.1.0"

supported_targets = "native"

preferred_target = "native"

warnings = "-6-29-53-68"

import {
  "mizchi/native_runtime_hooks@0.7.0",
  "mizchi/crater-renderer@0.19.2",
  "mizchi/crater-painter@0.19.2",
  "mizchi/crater-layout@0.19.2",
  "mizchi/crater-dom@0.19.2",
  "mizchi/font@0.7.4",
  "mizchi/image@0.5.0",
  "mizchi/kagura_engine@0.7.0",
  "mizchi/gfx@0.1.1",
  "mizchi/text@0.7.0",
  "mizchi/renderer2d@0.7.0",
  "mizchi/widget2d@0.7.0",
  "mizchi/atlas@0.7.0",
  "mizchi/crater-core@0.19.2",
  "mizchi/css@0.8.0",
}

options(
  "--moonbit-unstable-prebuild": "../../../scripts/moon-prebuild-native-link-flags.cjs",
)
