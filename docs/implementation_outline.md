# Implementation Outline (Ebiten-first)

実装時に迷わないための、Ebiten準拠の着手順アウトライン。

## Package Layout

- `src/core`
  - `contracts.mbt`: `Game`, `RunOptions`, `EngineTermination`
  - `fixed_timestep.mbt`: TPS 固定ステップ計画
- `src/platform`
  - `contracts.mbt`: window/event/input 抽象
  - `surface_contracts.mbt`: platform->gfx surface token 境界
  - `desktop_glfw.mbt` (planned): native 実装
  - `web_canvas.mbt` (planned): web 実装
- `src/gfx`
  - `contracts.mbt`: `GraphicsDriver`, `CommandQueue`
  - `shader_contracts.mbt`: `ShaderFrontend`, `UniformCanonicalizer`, `BuiltinShaderSourceRepo`
  - `backend_contracts.mbt`: backend factory (`wgpu-native/webgpu/webgl/null`)
- `src/gfx_wgpu_native` (planned)
  - `backend.mbt`: `~/Downloads/wgpu` 由来の backend 実装
- `src/gfx_webgpu` / `src/gfx_webgl` (planned)
  - ブラウザ backend 実装
- `src/asset` (planned)
  - `contracts.mbt`: image/shader/material/atlas 管理契約
- `src/text` (planned)
  - `contracts.mbt`: font shaping と text batch 契約
- `src/ui` (planned)
  - `contracts.mbt`: layout/input/render adapter 契約
- `src/ai` (planned)
  - `contracts.mbt`: sensor/policy/actuator/scheduler 契約
- `src/runtime`
  - `contracts.mbt`: ループ統合契約
  - `run_loop.mbt` (planned): 実行本体

## Ebiten Mapping (implementation viewpoint)

- `run.go` -> `core/contracts.mbt`, `runtime/run_loop.mbt`
- `gameforui.go` -> `runtime/run_loop.mbt`（offscreen/final pass）
- `internal/ui/context.go` -> `runtime/run_loop.mbt`, `core/fixed_timestep.mbt`
- `internal/ui/input*.go` -> `platform/*`（capture_input）
- `internal/ui/ui_glfw.go` + `internal/ui/ui_js.go` -> `platform.SurfaceProvider`
- `internal/graphicsdriver/graphics.go` -> `gfx/contracts.mbt` + backend packages
- `internal/graphics/shader.go` + `internal/shader*` -> `gfx.ShaderFrontend`
- `internal/ui/shader.go` + `internal/shaderir/program.go` + `internal/graphicscommand/commandqueue.go` -> `gfx.UniformCanonicalizer`
- `internal/builtinshader/shader.go` + `shader.go` + `internal/atlas/shader.go` -> `gfx.BuiltinShaderSourceRepo`
- `internal/graphicscommand/commandqueue.go` -> `gfx/command_queue.mbt` (planned)
- `internal/atlas/image.go` -> `asset/contracts.mbt` の atlas/image repository

## Implementation Order (TDD)

1. Core clock
   - Red: `fixed_timestep_test.mbt` を復活
   - Green: `step_fixed_timestep` 実装
2. Desktop render minimum
   - Red: `runtime` で 1 フレーム進む統合テスト
   - Green: `platform_desktop + gfx_wgpu_native`
3. Shader pipeline
   - Red: `compile + uniform canonicalize` の black-box 契約テスト
   - Green: `gfx_wgpu_native` 向け `ShaderFrontend`/`UniformCanonicalizer` 最小実装
4. Command queue
   - Red: merge 条件テスト
   - Green: enqueue/flush 実装
5. Asset + Text + UI
   - Red: sprite draw/readback
   - Green: atlas 実装 + text batch + ui layout bridge
6. Web backend
   - Red: desktop と同一ロジック比較
   - Green: `gfx_webgpu`、必要なら `gfx_webgl`
7. AI runtime
   - Red: 同入力 seed で deterministic な decision テスト
   - Green: `ai.run_ai_tick` と runtime integration

## Rules While Implementing

- 契約は `core/platform/gfx/runtime` で先に固定
- backend 差分は adapter 層に閉じ込める
- `moon check --target js` と `moon check --target native` を継続通過
- 変更ごとに `moon info` で API 差分確認
