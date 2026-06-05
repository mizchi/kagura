name = "mizchi/text"

version = "0.2.0"

description = "Text rendering helpers (glyph cache, batch builder, font engine) on top of mizchi/gfx and mizchi/font, extracted from kagura"

repository = "https://github.com/mizchi/text-mbt"

license = "Apache-2.0"

warnings = "-6-29-53-68"

import {
  "mizchi/gfx@0.1.0",
  "mizchi/font@0.7.0",
}

options(
  source: "src",
)
