name = "mizchi/renderer2d"

version = "0.2.0"

description = "Comprehensive 2D rendering toolkit: batched-quad RenderFrame, atlas quad geometry, color helpers, debug overlay/profiler, color-matrix transforms."

repository = "https://github.com/mizchi/kagura"

license = "Apache-2.0"

warnings = "-6-29-53-68-deprecated"

import {
  "mizchi/gfx@0.1.0",
  "mizchi/atlas@0.2.0",
  "mizchi/kagura_core@0.2.0",
  "mizchi/geom@0.2.0",
  "mizchi/svg@0.2.0",
}

options(
  source: "src",
)
