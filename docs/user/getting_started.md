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

Builds and starts a local server. Open `http://localhost:8080` in a WebGPU-capable browser.

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

## Native Run (macOS only)

> Native builds currently support macOS only. Windows and Linux support is planned.

```bash
bash scripts/setup-wgpu-native.sh
(cd examples/runtime_smoke_native && moon run src --target native)
```

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
    "mizchi/kagura": { "path": "../.." },
    "mizchi/signals": "0.6.3",
    "mizchi/web_runtime_hooks": { "path": "../web_runtime_hooks" },
    "mizchi/native_runtime_hooks": { "path": "../native_runtime_hooks" }
  }
}
```

### moon.pkg

```
import {
  "mizchi/signals" @signals,
  "mizchi/kagura/scene" @scene,
  "mizchi/kagura/core" @core,
  "mizchi/kagura/inpututil" @inpututil,
  "mizchi/web_runtime_hooks" @web_hooks,
  "mizchi/native_runtime_hooks" @native_hooks,
}

options(
  "is-main": true,
  link: {
    "native": {
      "cc-link-flags": "-L../../deps/wgpu-macos/lib -L/usr/local/lib -L/opt/homebrew/lib -lwgpu_native -lglfw -Wl,-rpath,../../deps/wgpu-macos/lib -Wl,-rpath,/usr/local/lib -Wl,-rpath,/opt/homebrew/lib -framework Metal -framework QuartzCore -framework IOKit -framework CoreFoundation -framework Cocoa -framework Foundation",
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
