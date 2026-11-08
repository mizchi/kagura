name = "mizchi/kagura_game"

version = "0.7.1"

readme = "README.md"

description = "Gameplay rules, inventory, progression and scene transitions"

repository = "https://github.com/mizchi/kagura"

license = "Apache-2.0"

warnings = "-6-29-53-68-deprecated"

import {
  "mizchi/js_core@0.13.0",
  "mizchi/terrain@0.1.1",
  "mizchi/kagura_core@0.7.1",
  "mizchi/kagura_engine@0.7.1",
  "mizchi/gfx@0.1.1",
  "mizchi/geom@0.7.1",
  "mizchi/anim3d@0.7.1",
}

preferred_target = "js"

options(
  "--moonbit-unstable-prebuild": "../scripts/moon-prebuild-native-link-flags.cjs",
)
