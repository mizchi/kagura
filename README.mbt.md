# kagura

A 2D-first (with future 3D) game engine for [MoonBit](https://www.moonbitlang.com/), inspired by [Ebiten](https://github.com/hajimehoshi/ebiten).

[日本語](README_ja.md)

[Playground](https://mizchi.github.io/kagura/) · [Play ASHEN REALMS](https://mizchi.github.io/kagura/hacknslash_3d/) — a low-poly action RPG with hunter, mage, archer and summoner builds.

## Features

- **Contract-first architecture** -- API contracts are defined before implementations, keeping the codebase modular and replaceable
- **Ebiten-inspired design** -- Fixed timestep updates, draw command batching, offscreen compositing, and backend abstraction
- **Cross-platform** -- Desktop via wgpu-native, browser via WebGPU
- **Pure MoonBit** -- No CGo, no FFI beyond the graphics backend boundary

## Architecture

```
moon.work
|-- core/                    Calculations: geometry, physics, terrain, input state
|-- platform/                Shared window/input/surface contracts
|-- platform_web/            Browser adapters and runtime_hooks/
|-- platform_native/         Native hooks, gfx_wgpu_native/, capture/
|-- engine/                  Rendering, assets, application/runtime, scene, HUD
|-- game/                    Rules, progression, ECS, inventory, input bindings
`-- editor/                  Authoring and inspection tools
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

### Development CLI

Install the CLI from this checkout, then scaffold a standalone Web game:

```sh
moon install ./cmd/kagura
kagura new my-game --web
cd my-game
pnpm install
kagura dev
kagura build
```

`kagura new --web` uses the current empty directory. The template includes the
browser runtime and Vite setup and depends on the published Kagura packages,
without local path dependencies.

The CLI shares the root `mizchi/kagura` module and release version. Starting with
the next release, install it with `moon install mizchi/kagura/cmd/kagura`.
The published 0.5.0 CLI is still `mizchi/kagura_cli/kagura@0.5.0`.

For examples and Studio in this checkout:

```sh
pnpm kagura dev hacknslash_3d --port 8080
pnpm kagura build hacknslash_3d --out-dir output/game
pnpm kagura studio
```

Run `just studio-install` once before launching Studio. `just kagura ...` also
works; inside a game directory the project argument can be omitted. Builds are
self-contained static sites. See [Kagura CLI](cmd/kagura/README.md) for options.

`kagura capture [url] --output game.png` captures the game surface, and
`kagura profile [url] --out-dir output/profile` writes frame statistics and a
Chrome CPU profile. Both work with external Kagura projects; install
`@playwright/test` in the calling project. See [browser tool setup](cmd/kagura/README.md#画面キャプチャと負荷計測).

### Publish the playground

`just pages` builds release bundles and relative assets into `_site/`. Pushing
`main` publishes them to GitHub Pages through `.github/workflows/deploy.yml`.
The repository's Pages source must be **GitHub Actions**.

After deployment, `just pages-test https://mizchi.github.io/kagura/` checks the
public gallery, save selection and summoner gameplay with Playwright. It also
accepts a locally served `_site/` URL, including a project subdirectory.

### Native

```bash
bash scripts/setup-wgpu-native.sh

# Run with just (recommended -- sets CPATH/LIBRARY_PATH automatically)
just run-native action_rpg

# Non-visual smoke test (window can appear black)
(cd examples/smoke/runtime_smoke_native && moon run src --target native)

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
- [Reusable Game Components](assets/web/README.md)
- [Rendering Performance and Profiling](docs/performance.md)

### For Contributors

- [Contributing Guide](CONTRIBUTING.md)
- [Architecture](docs/architecture/architecture.md)
- [Module Boundaries](docs/architecture/module_boundaries.md)
- [Roadmap](docs/roadmap/roadmap.md)

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

## Updating release versions

```bash
just version 0.5.0 --dry-run  # Preview affected modules and manifests
just version 0.5.0           # Update versions and regenerate Web runtime / CLI
just version 0.5.0 --check   # Fail if any manifest version/reference differs
just check-release
just publish-status         # Inspect packaged modules without uploading
```

The publication catalog in `scripts/release-policy.mjs` is shared with
`just publish`. It includes the reusable libraries, platform runtime hooks and
CLI. The updater changes their versions and internal dependency references in
source manifests, examples, editors and Web scaffolding, preserving external
dependencies and consumer project versions. Both `moon.mod` and `moon.mod.json`
are supported. Use a stable `X.Y.Z` version; downgrades are rejected.

Version updates regenerate the browser distribution before embedding it in the
CLI. If a build fails, fix the error and repeat the same command to finish
regeneration. The updater does not commit, tag, push or publish. Review the diff
and validation results before running `just publish`.

Publication stages every module outside the checkout, checks the staged
workspace and verifies each archive has its manifest, MoonBit sources and
prebuild support. Modules are published in dependency order; an upload failure
stops the release. `just publish-status` performs the same packaging checks.

## Dependencies

- [mizchi/image](https://mooncakes.io/docs/#/mizchi/image/) -- Image codec (PNG/BMP/JPEG)
- [mizchi/font](https://mooncakes.io/docs/#/mizchi/font/) -- Font rendering and shaping
- [mizchi/layout](https://mooncakes.io/docs/#/mizchi/layout/) -- Layout engine
- [mizchi/audio](https://mooncakes.io/docs/#/mizchi/audio/) -- Audio system
- [mizchi/svg](https://mooncakes.io/docs/#/mizchi/svg/) -- SVG rendering

## License

Apache-2.0
