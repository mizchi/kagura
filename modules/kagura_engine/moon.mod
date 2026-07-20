name = "mizchi/kagura_engine"

version = "0.2.0"

description = "Rendering, runtime, platform, asset, audio, and glTF infrastructure for Kagura"

repository = "https://github.com/mizchi/kagura"

license = "Apache-2.0"

warnings = "-6-29-53-68-deprecated"

import {
  "mizchi/kagura_core@0.2.0",
  "mizchi/gfx@0.1.0",
  "mizchi/image@0.4.3",
  "mizchi/font@0.7.0",
  "mizchi/audio@0.1.0",
  "mizchi/glfw@0.2.2",
  "mizchi/text@0.2.0",
  "mizchi/mesh3d@0.2.0",
  "mizchi/renderer2d@0.2.0",
  "mizchi/geom@0.2.0",
  "mizchi/atlas@0.2.0",
  "mizchi/anim3d@0.2.0",
}

preferred_target = "js"

source = "src"

options(
  "--moonbit-unstable-prebuild": "../../scripts/moon-prebuild-native-link-flags.cjs",
)
