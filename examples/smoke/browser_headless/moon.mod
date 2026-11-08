name = "mizchi/browser_headless"

version = "0.1.0"

supported_targets = "native"

preferred_target = "native"

warnings = "-6-29-53-68"

import {
  "mizchi/native_runtime_hooks@0.7.0",
  "mizchi/crater-renderer@0.19.0",
  "mizchi/crater-painter@0.19.0",
  "mizchi/crater-layout@0.19.1",
  "mizchi/crater-browser@0.19.0",
  "mizchi/crater-browser-native@0.19.0",
  "mizchi/v8@0.3.0",
  "mizchi/kagura_engine@0.7.0",
  "mizchi/gfx@0.1.1",
  "mizchi/renderer2d@0.7.0",
  "mizchi/widget2d@0.7.0",
  "mizchi/crater-core@0.19.0",
  "mizchi/css@0.8.0",
}

options(
  "--moonbit-unstable-prebuild": "scripts/prebuild.mjs",
)
