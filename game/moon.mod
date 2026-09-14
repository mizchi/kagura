name = "mizchi/kagura_game"

version = "0.5.0"

readme = "README.md"

description = "Gameplay rules, inventory, progression and scene transitions"

repository = "https://github.com/mizchi/kagura"

license = "Apache-2.0"

warnings = "-6-29-53-68-deprecated"

import {
  "mizchi/js@0.12.2",
  "mizchi/terrain@0.1.1",
  "mizchi/kagura_core@0.5.0",
  "mizchi/kagura_engine@0.5.0",
  "mizchi/gfx@0.1.0",
  "mizchi/geom@0.5.0",
  "mizchi/anim3d@0.5.0",
}

preferred_target = "js"

options(
  "--moonbit-unstable-prebuild": "../scripts/moon-prebuild-native-link-flags.cjs",
)
