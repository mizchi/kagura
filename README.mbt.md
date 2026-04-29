# kagura

A 2D-first (with future 3D) game engine for [MoonBit](https://www.moonbitlang.com/), inspired by [Ebiten](https://github.com/hajimehoshi/ebiten).

[日本語](README_ja.md)

## Features

- **Contract-first architecture** -- API contracts are defined before implementations, keeping the codebase modular and replaceable
- **Ebiten-inspired design** -- Fixed timestep updates, draw command batching, offscreen compositing, and backend abstraction
- **Cross-platform** -- Desktop via wgpu-native, browser via WebGPU
- **Pure MoonBit** -- No CGo, no FFI beyond the graphics backend boundary

## Architecture

```
moon.work
|-- mizchi/kagura             Thin public facade over core/engine contracts
|-- mizchi/kagura_core        Core contracts, math, camera, mesh, input utilities
|-- mizchi/kagura_engine      Rendering/runtime infrastructure
|   |-- platform/, gfx/        Platform, graphics, native/web backends
|   |-- runtime/, asset/       Runtime loop, assets, audio, text, UI
|   `-- gltf/, renderer*/      glTF loading and 2D/3D renderer facades
|-- mizchi/kagura_game        Gameplay-oriented packages
|   |-- scene/                 Declarative 2D Scene API
|   |-- physics2d/, physics3d/ Simulation and collision integration
|   `-- ai/, ecs/, tilemap2d/  Game systems and helpers
`-- mizchi/kagura_js_runtime  JS-only WebGPU runtime helpers
```

### Platform Support

| Target | Backend | Status |
|--------|---------|--------|
| Web (all OS) | WebGPU | Supported |
| Native macOS | wgpu-native + Metal + GLFW | Supported |
| Native Linux | wgpu-native + Vulkan + GLFW | Supported (CI: check + test + build) |
| Native Windows | wgpu-native + D3D12/Vulkan + GLFW | Partial (CI: check + build workaround; runtime validation pending) |
| WASM Guest | Shared-memory binary protocol | Supported (MoonBit / Rust / Zig) |

> JS builds (browser) work on any OS. Native builds support macOS and Linux. Windows native build uses a repo-side workaround for the upstream `-lm` issue, but runtime validation is still limited.

## Quick Start

### Prerequisites

- [MoonBit](https://www.moonbitlang.com/)
- Node.js 24+
- pnpm
- [just](https://github.com/casey/just)

### Run in Browser

```bash
pnpm install
just dev flappy_bird
```

Builds and serves at `http://localhost:8080`. Browser demos currently require WebGPU (Chrome 113+, Edge 113+).

### Native

```bash
bash scripts/setup-wgpu-native.sh

# Run with just (recommended -- sets CPATH/LIBRARY_PATH automatically)
just run-native action_rpg

# Non-visual smoke test (window can appear black)
(cd examples/runtime_smoke_native && moon run src --target native)

# Visual sanity check
just run-native native_triangle
```

`runtime_smoke_native` is intended for internal verification. A black window is expected; success is `runtime_smoke_native: ok (real)`.

## Examples

| Example              | Description                        |
|----------------------|------------------------------------|
| `runtime_smoke`      | Minimal JS smoke test              |
| `runtime_smoke_native` | Minimal native smoke test (non-visual) |
| `native_triangle`    | Native backend triangle demo       |
| `flappy_bird`        | 2D game loop with input handling   |
| `survivor`           | Multi-entity game with weapons/UI  |
| `action_rpg`         | Action RPG prototype               |
| `arena3d`            | 3D arena prototype (experimental)  |

Each example is an independent MoonBit module. Run with:

```bash
(cd examples/<name> && moon run src --target <js|native>)
```

## Documentation

### For Users

- [Getting Started](docs/user/getting_started.md)
- [Tutorials](docs/user/tutorials.md)
- [API Guide](docs/user/api_guide.md)

### For Contributors

- [Contributing Guide](CONTRIBUTING.md)
- [Architecture](docs/architecture.md)
- [Module Boundaries](docs/module_boundaries.md)
- [Roadmap](docs/roadmap.md)

## Verification

```bash
just fmt
just check target=js
just test target=js
just check target=native
just test target=native
just check-release
pnpm e2e:smoke
```

## Dependencies

- [mizchi/image](https://mooncakes.io/docs/#/mizchi/image/) -- Image codec (PNG/BMP/JPEG)
- [mizchi/font](https://mooncakes.io/docs/#/mizchi/font/) -- Font rendering and shaping
- [mizchi/layout](https://mooncakes.io/docs/#/mizchi/layout/) -- Layout engine
- [mizchi/audio](https://mooncakes.io/docs/#/mizchi/audio/) -- Audio system
- [mizchi/svg](https://mooncakes.io/docs/#/mizchi/svg/) -- SVG rendering

## License

Apache-2.0
