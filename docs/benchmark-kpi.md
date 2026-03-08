# Benchmark KPI

各カテゴリのパフォーマンス許容基準。CI の `just bench-gate` で回帰検知に使う。

## 2D

| シーン | FPS | Frame Time | Draw Calls | Vertices |
|--------|-----|------------|------------|----------|
| sprite 1000 体 | >= 60 | <= 16ms | <= 50 | <= 6000 |
| text 100 行 | >= 60 | <= 16ms | <= 200 | <= 2400 |
| tilemap 100x100 | >= 60 | <= 16ms | <= 100 | <= 40000 |

## 3D

| シーン | FPS | Frame Time | Draw Calls | Vertices |
|--------|-----|------------|------------|----------|
| scene3d 50 objects | >= 30 | <= 33ms | <= 100 | <= 50000 |
| shadow 10 lights | >= 30 | <= 33ms | <= 200 | <= 100000 |
| postfx (bloom+tonemap+FXAA) | >= 30 | <= 33ms | <= 10 | N/A |

## ゲーム例

| Example | FPS | Frame Time |
|---------|-----|------------|
| flappy_bird | >= 60 | <= 8ms |
| survivor | >= 60 | <= 12ms |
| action_rpg | >= 60 | <= 14ms |
| arena3d | >= 30 | <= 20ms |
| hacknslash_3d | >= 30 | <= 25ms |

## WASM ABI

| 指標 | 許容値 |
|------|--------|
| update call | <= 0.5ms |
| render call | <= 0.3ms |
| input serialization | <= 0.05ms |
| draw deserialization | <= 0.1ms |
| input bytes/frame | <= 200B |
| draw bytes/frame | <= 10KB |

## クロスバックエンド基準シーン

- `examples/runtime_smoke/` — JS/native 両ターゲットで同一描画ロジックを実行。VRT + native build smoke test で描画結果を比較可能。
- `examples/runtime_smoke_native/` — native 専用 smoke test。

CI で js / native-linux / native-macos の 3 環境で同一シーンをビルド・テストし、パフォーマンス差を検知する基盤が整備済み。

## 計測ツール

- `just bench` — MoonBit microbenchmarks (ecs, sprite2d, text, sprite_packer)
- `just bench-gate` — 基準値との回帰比較
- preview-shell の ABI stats パネル — wasm host-guest 境界コスト
- `@debugutil.build_profiler_hud()` — ゲーム内 stats overlay
