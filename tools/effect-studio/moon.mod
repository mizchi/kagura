name = "mizchi/kagura_effect_studio"

version = "0.1.0"

description = "AI-oriented effect studio workspace for Kagura timeline-driven particle effects"

repository = "https://github.com/mizchi/kagura"

license = "Apache-2.0"

warnings = "-6-29-53-68"

import {
  "mizchi/kagura_core@0.2.0",
  "mizchi/kagura_engine@0.2.0",
  "mizchi/geom@0.2.0",
}

source = "src"

options(
  exclude: [ "examples", "docs", "output" ],
)
