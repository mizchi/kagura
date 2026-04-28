# Getting Started

[日本語](getting_started_ja.md)

## Prerequisites

- [MoonBit](https://www.moonbitlang.com/)
- Node.js 24+
- pnpm
- [just](https://github.com/casey/just)

## Install

```bash
pnpm install
```

## Run in Browser

```bash
just dev flappy_bird
```

Builds and starts a local server. Open `http://localhost:8080` in a WebGPU-capable browser. Browser demos currently require WebGPU.

Other examples work the same way:

```bash
just dev survivor
just dev action_rpg
just dev scene_demo
```

## CLI Smoke Test

```bash
(cd examples/runtime_smoke && moon run src --target js)
```

Expected output:

```text
runtime_smoke(js): ok (hooked)
```

## Native Run

> Native builds support macOS and Linux. Windows is still experimental, but the repo includes a build workaround for the upstream `-lm` linker issue.

```bash
bash scripts/setup-wgpu-native.sh
(cd examples/runtime_smoke_native && moon run src --target native)

# Visual sanity check
just run-native native_triangle
```

`runtime_smoke_native` is for internal verification. A black window is expected; success is `runtime_smoke_native: ok (real)`.

## Creating a New Example

### Directory Structure

```
examples/my_game/
├── moon.mod.json
└── src/
    ├── moon.pkg
    ├── game.mbt          # Game logic (shared across targets)
    ├── main_js.mbt       # JS entry point
    ├── main_native.mbt   # Native entry point
    └── main_stub.mbt     # Stub for other targets
```

### moon.mod.json

```json
{
  "name": "mizchi/my_game",
  "version": "0.1.0",
  "source": "src",
  "deps": {
    "mizchi/kagura_core": { "path": "../../modules/kagura_core" },
    "mizchi/kagura_engine": { "path": "../../modules/kagura_engine" },
    "mizchi/kagura_game": { "path": "../../modules/game" },
    "mizchi/signals": "0.6.3",
    "mizchi/web_runtime_hooks": { "path": "../web_runtime_hooks" },
    "mizchi/native_runtime_hooks": { "path": "../native_runtime_hooks" }
  },
  "--moonbit-unstable-prebuild": "../../scripts/moon-prebuild-native-link-flags.cjs"
}
```

### moon.pkg

```
import {
  "mizchi/signals" @signals,
  "mizchi/kagura_game/scene" @scene,
  "mizchi/kagura_core" @core,
  "mizchi/kagura_core/inpututil" @inpututil,
  "mizchi/kagura_engine" @engine,
  "mizchi/kagura_engine/gfx" @gfx,
  "mizchi/web_runtime_hooks" @web_hooks,
  "mizchi/native_runtime_hooks" @native_hooks,
}

options(
  "is-main": true,
  link: {
    "native": {
      "cc-link-flags": "-L../../deps/wgpu-native/lib -lwgpu_native -lglfw -Wl,-rpath,../../deps/wgpu-native/lib ${build.KAGURA_NATIVE_PLATFORM_LIBS}",
    },
  },
  targets: {
    "main_js.mbt": ["js"],
    "main_native.mbt": ["native"],
    "main_stub.mbt": ["wasm", "wasm-gc", "llvm"],
  },
)
```

> **Note**: `cc-link-flags` are NOT propagated from dependency packages. For native builds, you must specify them directly in the `is-main: true` package. For web-only projects, the `link` section is not needed.

### main_js.mbt (minimal)

```moonbit
fn main {
  @web_hooks.install("#app")
  let game = Game::new()
  @scene.run(
    view=fn() { game.view() },
    update=fn(input) { game.update(input) },
    width=320, height=240,
    title="my_game", canvas="#app",
  )
}
```

### main_stub.mbt

```moonbit
fn main {
  ()
}
```

### Run

```bash
just dev my_game
```

## Ongoing Verification

```bash
just check target=js
just test target=js
pnpm e2e:smoke
```
