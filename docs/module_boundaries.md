# Module Boundaries

実装前に固定する境界面の整理。

## Dependency Direction

- `core` <- `platform`, `gfx`, `runtime`, `ui`, `ai`
- `platform` <- `gfx`（surface token のみ参照）
- `gfx` <- `asset`, `text`, `ui`
- `runtime` <- `ai`（tick 統合）
- `asset` <- `text`, `ui`
- 禁止:
  - `core` -> `platform/gfx`
  - `ai` -> `gfx`（描画依存を持たない）
  - `ui` -> `platform`（入力は `core.InputSnapshot` 経由）

## Boundary Matrix

| module | own state | input | output | contract file |
|---|---|---|---|---|
| `core` | tick/update 計画 | outside size, input snapshot | frame budget, termination | `src/core/contracts.mbt` |
| `platform` | window/event buffer | window options | input snapshot, surface token | `src/platform/contracts.mbt`, `src/platform/surface_contracts.mbt` |
| `gfx` | GPU resources, command queue | draw commands, shader source, surface token | present, image/shader handle | `src/gfx/contracts.mbt`, `src/gfx/shader_contracts.mbt`, `src/gfx/backend_contracts.mbt` |
| `runtime` | loop state | core/platform/gfx contracts | frame execution | `src/runtime/contracts.mbt` |
| `asset` | asset index, atlas allocation | image/shader specs | image/shader/material handle | `src/asset/contracts.mbt` |
| `text` | font cache, glyph cache | text runs | glyph quads, draw commands | `src/text/contracts.mbt` |
| `ui` | ui tree, layout cache | input snapshot, frame budget | ui events, draw commands | `src/ui/contracts.mbt` |
| `ai` | blackboard, scheduler state | sensor snapshot, frame budget | action intents | `src/ai/contracts.mbt` |

## Backend Implementations

| target | platform impl | gfx impl | key contract |
|---|---|---|---|
| desktop | `DesktopGlfwPlatform` | `WgpuNative` | `platform.SurfaceToken(kind=MetalLayer)` |
| browser(webgpu) | `WebCanvasPlatform` | `WebGpu` | `platform.SurfaceToken(kind=WebGpuCanvasContext)` |
| browser(webgl2) | `WebCanvasPlatform` | `WebGl2` | `platform.SurfaceToken(kind=WebGlCanvasContext)` |
| tests/headless | offscreen surface | `Null` | `create_offscreen_surface_token` |

- 補足:
  - `platform` / `gfx` は標準では stub hook を使う
  - real native 初期化は `examples/native_runtime_hooks` から hook 注入して有効化する
  - browser 側は `examples/web_runtime_hooks` から web hook 注入して有効化する
  - `native_triangle` も `examples/native_runtime_hooks` の共通初期化 API を利用する
  - `runtime_smoke(js)` は `examples/web_runtime_hooks` 経由で browser 導線を通す

## AI Boundary

- sensing:
  - `ai.SensorBridge` が world state を `SensorSnapshot` に射影
- decision:
  - `ai.AIPolicy` が `DecisionContext -> DecisionResult`
- actuation:
  - `ai.ActuatorBridge` が action intent を game world に適用
- runtime integration:
  - `runtime` が fixed tick ごとに `run_ai_tick` を呼ぶ
