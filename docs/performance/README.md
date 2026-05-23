# Performance

このディレクトリは kagura のパフォーマンス計測と最適化に関するドキュメントをまとめています。

## ドキュメント

| ファイル | 内容 |
|---|---|
| [benchmark-kpi.md](benchmark-kpi.md) | 2D / 3D / ゲーム例 / WASM ABI の許容基準 (FPS, frame time, draw calls, bytes) |
| [perf.md](perf.md) | 直近のパフォーマンスレビュー結果 (改善値・残ボトルネック) |
| [hacknslash_3d-rendering-performance.md](hacknslash_3d-rendering-performance.md) | hacknslash_3d 描画パイプラインの計測と最適化記録 |
| [hacknslash_3d-balance-tuning.md](hacknslash_3d-balance-tuning.md) | autoplay 仮説検証によるゲームバランス調整 |

## ベンチマークの構成

各 bench テストは MoonBit の `@bench.T` フレームワークで定義されており、`moon bench` で実行されます。

| ファイル | テスト数 | 対象 |
|---|---:|---|
| `examples/games-3d/hacknslash_3d/src/view3d_bench.mbt` | 36 | render pass / update phase の細かい分解計測 |
| `modules/game/src/ecs/ecs_bench.mbt` | 11 | ECS spawn / system / component access |
| `modules/physics/src/physics3d/world_bench.mbt` | 8 | 物理ステップ (pairs / constraints / substeps / integration) |
| `modules/kagura_engine/src/text/contracts_bench.mbt` | 4 | テキスト glyph build / 描画コマンド構築 |
| `modules/kagura_engine/src/sprite2d/contracts_bench.mbt` | 3 | 2D 描画コマンド構築 (particle dispatch) |
| `examples/games-3d/arena3d/src/game_bench.mbt` | 3 | arena3d の update / scene graph / renderer3d facade |
| `modules/game/src/sprite_packer/packer_bench.mbt` | 2 | スプライトパッキング |
| `examples/games-2d/{action_rpg,flappy_bird,survivor}/src/game_bench.mbt` | 2 each | ゲーム例の update / view |

## 計測コマンド

```sh
# 全 bench を実行 (root + examples + modules)
just bench                # target=js (default)
just bench target=native  # native target

# 単一パッケージを実行
moon -C examples/games-3d/hacknslash_3d bench --target js
moon -C modules/physics bench --target js

# 回帰検知 (baseline と比較)
just bench-gate

# baseline 更新 (新規 / 意図的に変化させた場合)
just bench-update
```

## 回帰検知ゲート (`scripts/bench-gate.mjs`)

`moon bench` の出力をパースし、`scripts/bench-baseline.json` と比較して 1.5x 以上遅くなったベンチを `REGRESSION` として exit 1 します。

### baseline JSON 形式

```json
{
  "version": 1,
  "target": "js",
  "generatedAt": "2026-05-23T00:00:00.000Z",
  "benchmarks": {
    "ecs/spawn_10000": 433.36,
    "hacknslash_3d/draw_playing/default": 1240.5
  }
}
```

旧スキーマ (フラット `{name: meanUs}`) も読めます。値は全て `µs` 単位。

### 出力例

```
=== Benchmark Regression Check (threshold: 1.5x) ===
  OK: ecs/spawn_10000 = 433.36µs vs baseline 420µs (1.032x)
  REGRESSION: physics3d/world_step_substeps_dense_64 = 350µs vs baseline 200µs (1.750x slower)
  NEW: hacknslash_3d/new_phase = 42µs (no baseline)
  MISSING: ecs/legacy_path (baseline 10µs, not in output)
```

`bench-gate.mjs` のロジックは `scripts/bench-gate-utils.mjs` に分離されており、`node --test scripts/bench-gate-utils.test.mjs` でテスト可能です。

## 新しい bench を追加する

1. 対象パッケージに `<name>_bench.mbt` を置く (例: `examples/games-2d/my_game/src/game_bench.mbt`)。
2. `moon.pkg` の `import` に `"moonbitlang/core/bench" @bench` を追加する。
3. `test "bench <category>/<name>" (b : @bench.T) { ... }` パターンで定義する:

   ```moonbit
   ///|
   test "bench mygame/update" (b : @bench.T) {
     let state = GameState::new()
     b.bench(name="mygame/update", fn() {
       state.update()
       b.keep(state.frame_count)
     })
   }
   ```

4. 同種の bench を複数並べる場合は、`view3d_bench.mbt` の `run_*_bench(b, name, state)` パターンに倣ってヘルパーを抽出する。
5. baseline を更新: `just bench-update`。

## 既知のボトルネック (2026-03-30 時点)

[perf.md](perf.md) に詳細あり。要点:

| 領域 | 状況 |
|---|---|
| `physics3d` substep tangent / angular path | 世界 tick の ~80% を占める。未着手 |
| `scene3d` PBR / skinned uniform packing | 1024 object common case は改善済 (2.39ms → 0.93-1.02ms)、PBR は残課題 |
| `sprite2d` geometry merge | 同一 state vs 異なる state での CPU copy が重い |
| hacknslash_3d render path | minimap batch を直して描画はほぼ完了。次は `enemy_enemy_separation` などの update phase |

## GPU パフォーマンス計測 (hacknslash_3d)

`scripts/hacknslash_3d_gpu_perf.mjs` で Playwright + Chromium 環境で実 GPU の指標 (fps / frameTimeMs / updateMs / drawMs) を計測できます。

```sh
just hacknslash3d-gpu-perf samples=120 warmup=30
```

統計処理 (percentile / IQR outlier 除外) は `scripts/hacknslash_3d_gpu_perf_utils.mjs` にあり、unit test は `scripts/hacknslash_3d_gpu_perf_utils.test.mjs`。
