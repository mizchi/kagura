# TDD Roadmap

## Current Progress

- Milestone 0: `fixed_timestep` のテスト/実装を復活済み
- Milestone 2: `src/examples/native_triangle --target native` の build/run を確認済み
- Module Boundary: `asset/text/ui/ai` と `platform<->gfx` の契約 stub を追加済み
- Runtime Smoke: `src/examples/runtime_smoke`(js) / `src/examples/runtime_smoke_native`(native) 実行確認済み
- Hook Bridge: `examples/native_runtime_hooks` + `examples/web_runtime_hooks` で実行境界を共通化済み
- E2E Smoke: Playwright で `wasm` / `wasm-gc` の browser 実行確認を追加済み
- Milestone 3 以降: 契約先行で着手待ち

## Phase 0: Contract Outline (current)

- `#declaration_only` で API 契約だけ先に確定
- Ebiten の参照元を各契約コメントと `docs/ebiten_reference.md` に明記
- 実装は「必要最小限を残してよい」。ただし契約を先に固定してから TDD で段階実装する

## Milestone 0: Core Clock (first implementation)

- 探索:
  - Ebiten の `clock` / `ui/context.updateFrameImpl` を確認
- Red:
  - 固定 timestep の単体テスト作成
- Green:
  - 純粋関数 `step_fixed_timestep` を実装
- Refactor:
  - 設定値/状態/結果を構造体に分離

## Milestone 1: Contract Layer

- 探索:
  - `internal/graphicsdriver/graphics.go` と `inputstate` を分析
- Red:
  - `Game`, `Platform`, `RenderBackend` の契約テスト
- Green:
  - mock 実装で 1 フレーム駆動
- Refactor:
  - API を minimal surface に縮小

## Milestone 2: Desktop Minimal Render

- 探索:
  - `~/Downloads/wgpu` 既存 FFI を再利用
- Red:
  - 「window 作成」「clear」「triangle」E2E テスト
- Green:
  - `platform_desktop + gfx_wgpu` 実装
- Refactor:
  - リソース解放とエラー経路を統一

## Milestone 3: DrawCommand Queue

- 探索:
  - Ebiten `graphicscommand` の merge 条件を抽出
- Red:
  - 同一 pipeline/texture の merge テスト
- Green:
  - command queue 実装
- Refactor:
  - バッファ再利用・アロケーション削減

## Milestone 4: Image/Atlas

- 探索:
  - Ebiten `atlas` と `mipmap` の役割を整理
- Red:
  - sprite 描画、partial update、readback のテスト
- Green:
  - 最小 atlas 実装
- Refactor:
  - managed/unmanaged の切り分け

## Milestone 5: Input Snapshot

- 探索:
  - Ebiten `inputstate` tick 一貫性を参照
- Red:
  - 同 tick で結果不変のテスト
- Green:
  - snapshot 実装
- Refactor:
  - device 共通 API に統合

## Milestone 6: Web Backend

- 探索:
  - `crater` browser/js/wasm 層を再利用可能単位に分解
- Red:
  - 同一 game logic が desktop/web で一致するテスト
- Green:
  - `platform_web + gfx_webgpu|webgl`
- Refactor:
  - 差分を adapter 層に押し込む

## Milestone 7: Text/UI Integration

- `mizchi/font` と `mizchi/layout` を統合
- text rendering と layout の API を分離したまま接続

## Milestone 8: AI Tick Integration

- 探索:
  - sensor/policy/actuator/scheduler 分離で deterministic にする
- Red:
  - 同 seed + 同 input で action が一致するテスト
- Green:
  - `ai.run_ai_tick` を runtime update に統合
- Refactor:
  - budget 制御と trace 出力を整理

## Definition of Done (phase gate)

- `moon check --target js`
- `moon test --target js`
- desktop マイルストーンは `--target native` も通過
- `moon info` で契約面の差分をレビュー
