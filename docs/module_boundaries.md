# Module Boundaries

実装前に固定する境界面の整理。

## Workspace Modules

- `mizchi/kagura`: thin public facade。`src/*` を持ち、`mizchi/kagura_core` と `mizchi/kagura_engine` の契約を束ねる。
- `mizchi/kagura_core`: core contracts / math / camera / mesh / input utilities。`modules/kagura_core/src/*` を持つ。
- `mizchi/kagura_engine`: rendering/runtime infrastructure。`modules/kagura_engine/src/*` を持ち、`mizchi/kagura_core` に依存する。
- `mizchi/kagura_game`: gameplay/simulation/application layer。`modules/game/src/*` を持ち、`mizchi/kagura_core` と `mizchi/kagura_engine` に依存する。
- `mizchi/kagura_js_runtime`: JS 専用 WebGPU runtime helper。`modules/js_runtime/src/*` を持つ。

`mizchi/kagura` は compatibility facade とし、gameplay 層を含めない。`mizchi/kagura_game` から root facade へ戻す依存も作らない。

## Release Units

MoonBit registry へ出す単位は次の 5 つに固定する。

- `mizchi/kagura`
- `mizchi/kagura_core`
- `mizchi/kagura_engine`
- `mizchi/kagura_game`
- `mizchi/kagura_js_runtime`

source manifest では `moon.work` 用の local `path` 依存を許可する。publish 用 staging は `just release-stage` で生成し、workspace 内の `path` 依存を対象 module の `version` 文字列へ変換する。release 前の検証は `just check-release` を通す。

## Dependency Direction

- `mizchi/kagura_core` <- `mizchi/kagura_engine`
- `mizchi/kagura_core`, `mizchi/kagura_engine` <- `mizchi/kagura_game`
- `mizchi/kagura_core`, `mizchi/kagura_engine` <- `mizchi/kagura`
- `core` <- `platform`, `gfx`, `runtime`, `ui`
- `platform` <- `gfx`（surface token のみ参照）
- `gfx` <- `asset`, `text`, `ui`
- `asset` <- `text`, `ui`
- `draw2d` <- `renderer2d`（2D draw command builder の上に frame/queue API を置く）
- `draw3d`, `scene3d`, `render_pipeline3d` <- `renderer3d`（3D scene/pipeline の facade）
- 禁止:
  - `core` -> `platform/gfx`
  - `mizchi/kagura` -> `mizchi/kagura_game`
  - `mizchi/kagura_game` -> `mizchi/kagura`
  - `renderer2d` -> `mizchi/kagura_game/scene`（game scene 側から renderer2d を使う）
  - `ai` -> `gfx`（描画依存を持たない）
  - `ui` -> `platform`（入力は `core.InputSnapshot` 経由）

## Boundary Matrix

| module | own state | input | output | contract file |
|---|---|---|---|---|
| `core` | tick/update 計画 | outside size, input snapshot | frame budget, termination | `modules/kagura_core/src/contracts.mbt` |
| `platform` | window/event buffer | window options | input snapshot, surface token | `modules/kagura_engine/src/platform/contracts.mbt`, `modules/kagura_engine/src/platform/surface_contracts.mbt` |
| `gfx` | GPU resources, command queue | draw commands, shader source, surface token | present, image/shader handle | `modules/kagura_engine/src/gfx/contracts.mbt`, `modules/kagura_engine/src/gfx/shader_contracts.mbt`, `modules/kagura_engine/src/gfx/backend_contracts.mbt` |
| `runtime` | loop state | core/platform/gfx contracts | frame execution | `modules/kagura_engine/src/runtime/contracts.mbt` |
| `asset` | asset index, atlas allocation | image/shader specs | image/shader/material handle | `modules/kagura_engine/src/asset/contracts.mbt` |
| `renderer2d` | frame draw context | atlas draw sources, 2D frame target | draw command queue | `modules/kagura_engine/src/renderer2d/renderer2d.mbt` |
| `renderer3d` | frame draw context | `scene3d` graph/scene, optional postfx pipeline | scene + postfx draw command queue | `modules/kagura_engine/src/renderer3d/renderer3d.mbt` |
| `text` | font cache, glyph cache | text runs | glyph quads, draw commands | `modules/kagura_engine/src/text/contracts.mbt` |
| `ui` | ui tree, layout cache | input snapshot, frame budget | ui events, draw commands | `modules/kagura_engine/src/ui/contracts.mbt` |
| `ai` | blackboard, scheduler state | sensor snapshot, frame budget | action intents | `modules/game/src/ai/contracts.mbt` |

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
