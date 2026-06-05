name = "mizchi/kagura"

version = "0.4.0"

import {
  "mizchi/kagura_core@0.2.0",
  "mizchi/kagura_engine@0.2.0",
  "mizchi/image@0.1.1",
  "mizchi/font@0.7.0",
  "mizchi/audio@0.1.0",
  "mizchi/svg@0.2.0",
  "mizchi/glfw@0.2.2",
  "mizchi/gfx@0.1.0",
}

readme = "README.mbt.md"

repository = "https://github.com/mizchi/kagura"

license = "Apache-2.0"

keywords = [ "game-engine", "wgpu", "webgl", "moonbit" ]

description = "2D-first game engine for MoonBit inspired by Ebiten"

warnings = "-6-29-53-68"

preferred_target = "js"

options(
  source: "src",
  exclude: [
    "examples",
    "e2e",
    "docs",
    "deps",
    "fixtures",
    ".github",
    ".claude",
    ".tornado",
    "node_modules",
    "_build",
    "_site",
    "target",
    "test-results",
    "CLAUDE.md",
    "CONTRIBUTING.md",
    "CONTRIBUTING_ja.md",
    "TODO.md",
    "justfile",
    "package.json",
    "pnpm-lock.yaml",
    "playwright.config.ts",
  ],
  "--moonbit-unstable-prebuild": "scripts/moon-prebuild-native-link-flags.cjs",
)
