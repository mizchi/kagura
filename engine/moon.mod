name = "mizchi/kagura_engine"

version = "0.2.0"

readme = "README.md"

description = "Rendering, presentation, assets, audio and application runtime for Kagura"

repository = "https://github.com/mizchi/kagura"

license = "Apache-2.0"

warnings = "-6-29-53-68-deprecated"

import {
  "mizchi/kagura_ui@0.1.0",
  "mizchi/signals@0.6.5",
  "mizchi/kagura_core@0.2.0",
  "mizchi/kagura_platform@0.1.0",
  "mizchi/gfx@0.1.0",
  "mizchi/image@0.4.3",
  "mizchi/font@0.7.3",
  "mizchi/audio@0.1.1",
  "mizchi/text@0.2.0",
  "mizchi/mesh3d@0.2.0",
  "mizchi/renderer2d@0.2.0",
  "mizchi/geom@0.2.0",
  "mizchi/atlas@0.2.0",
  "mizchi/anim3d@0.2.0",
  "mizchi/kagura_audio@0.1.0",
}

preferred_target = "js"

options(
  "--moonbit-unstable-prebuild": "../scripts/moon-prebuild-native-link-flags.cjs",
)
