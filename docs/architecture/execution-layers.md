# Execution Layers

kagura の実行系は 3 層構造。重複ではなく意図的な設計分離。

## 層構造

| 層 | エントリ | タイムステップ | 対象 |
|---|---|---|---|
| **runtime** | `run_loop()` | 固定 (60 TPS, configurable) | 高精度ゲームループ |
| **engine** | `run()` | per-frame | Web/WASM 向け簡易ループ |
| **scene** | `run()` | engine に委譲 | 宣言的シーン API |

## 時間基準の統一

以下の時間管理は全層で同一パターン:

- **Audio ticking**: wall-clock accumulator (`audio_tick_ms = frames / 44100 * 1000`)
- **Resize tracking**: `platform.outside_size()` → `graphics.resize()` every frame
- **FPS 計測**: 500ms window average

## runtime vs engine の使い分け

- **runtime**: `Game` trait ベース、`layout()` で logical size を毎フレーム再計算、`step_fixed_timestep()` で物理更新頻度を安定化。Ebiten 互換の精密ゲームループ。
- **engine**: closure ベース (`update`, `draw`)、固定 width/height、per-frame 更新。Web/WASM guest 向けの軽量ループ。
- **scene**: engine の薄いラッパー。`view()` closure → `render_scene()` → draw commands。

## 設計判断

runtime と engine を無理に統合しない理由:
1. runtime の固定タイムステップは物理演算の安定性に必須
2. engine の per-frame モデルは WASM guest の update/render ABI に自然にマップされる
3. scene は engine の上に乗せることで宣言的 API を最小コストで提供
4. audio と resize は共通パターンなので、統合のメリットが薄い

## 変更時に共有すべき契約

固定 timestep と per-frame の違いは維持する。一方、`engine/run_js.mbt`、
`run_native.mbt`、`run_wasm.mbt` の初期化失敗・停止・リソース解放は別の問題であり、
実行モデルの違いを理由に挙動を分けない。三つの入口は現在 `RunSession` と
`run_session.mbt` の共通処理を使い、初期化失敗時は callback を開始せず停止する。
停止ハンドルと backend の容量は [runtime-sessions.md](./runtime-sessions.md) を参照する。

また、`run_wasm.mbt` の `kagura_frame` / `kagura_stop` はホスト駆動の
ライブラリ実行経路。`examples/experimental/wasm_game` の WIT に記載された
`kagura_guest_*` ABI とは別の入口。共通の寿命を持つ host adapter で扱い、
必要な imports と frame の結果は [guest-abi.md](./guest-abi.md) に区別して記載する。
