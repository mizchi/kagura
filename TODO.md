# TODO (Ebiten 同等機能ロードマップ)

このファイルは未完了タスクのみを管理する。
完了済みは `docs/mvp.md` の `DONE` セクションへ退避。

## ゴール再確認

- 目標: 2D/3D 両対応のゲームエンジンを MoonBit で提供する
- 優先: WebGPU (browser) と native wgpu (macOS/Linux/Windows) で同一ゲームロジックを早期に動かす
- 非目標: WebGL/WebGL2 フォールバック

## 現在の優先タスク (優先順位順)

### コードレビュー起因の修正項目 (performance / API)

- [ ] `runtime.run_loop` を実時間 delta で駆動し、`step_fixed_timestep` へ固定値 `16.6667ms` を渡す実装を廃止する
- [ ] 低レベル API 契約の no-op を解消する — `Game.layout` の `LogicalSize`、`RunOptions.init_unfocused`、`RunOptions.screen_cleared_every_frame` を実行系に反映する
- [ ] `AssetStreamer.request` の重複要求を callback fan-out 対応する — 同一 asset を待つ全 caller が `on_complete` を受け取れるようにする
- [ ] `@scene` の宣言的 API の内部表現を見直す — 毎フレームの `view()` 再構築・文字列属性化・再パースを減らし、利用者向け API と内部契約の型ズレを縮小する
- [ ] `scene3d` のフラスタムカリングを最適化する — mesh ごとの AABB をキャッシュし、毎フレーム・毎オブジェクトの全頂点走査を避ける
- [ ] `scene3d.sort_bias` の扱いを確定する — renderer で意味を持たせるか、公開 API から整理する

### Windows / Linux Native 対応

Surface 作成のクロスプラットフォーム化と CI 整備は完了。残タスク:

- [x] Surface 作成を macOS/Linux(X11)/Windows(Win32) に分岐 — `wgpu_native_stub.c` + `_macos.m` 分離
- [x] CI: native-linux に wgpu-native + GLFW + X11 セットアップ追加、テスト・ビルド通過
- [x] CI: native-windows に wgpu-native セットアップ追加、`moon check` 通過
- [ ] Windows `moon build`: MoonBit ランタイムが `-lm` を無条件付加する問題の上流修正待ち
- [ ] Audio バックエンドの抽象化（現在 AudioToolbox に依存 → Linux: PulseAudio/ALSA、Windows: WASAPI）

### 残タスク (3D エンジン)

- [ ] glTF/OBJ ローダーを別パッケージに切り出し — 後回し: 現状 mesh3d/scene3d/skeleton3d/animation3d 等 6 パッケージに依存しており、基盤パッケージの独立とテクスチャパイプライン安定後に着手

## ベンチマークゲーム: Isometric Hack & Slash ARPG

Path of Exile スタイルの斜め見下ろしアクション RPG をターゲットに開発を進める。

- **視点**: 固定カメラ斜め見下ろし（クォータービュー）
- **ビルド**: 近接ビルド / 魔法ビルド / 召喚ビルド
- **システム**: スキルツリー、装備、ルート、マップ生成
- **地形**: `mizchi/terrain` を使用 or 参考にした procedural 地形生成

### ARPG 残タスク (優先順位順)

#### Phase 1: 最小プレイアブル

- [x] 非同期アセットストリーミング（第2段階）— `AssetStreamer` 高レベル API（距離ベース優先度、LOD、LRU eviction、`on_frame` エンジン統合）

#### Phase 2: ゲームシステム

- [ ] スプライトシート自動生成 — UI アイコン、スキルアイコン用テクスチャアトラス
- [ ] UI フレームワーク — インベントリ、スキルツリー画面（インタラクティブ UI は `src/ui/` を拡張）
- [ ] セーブ / ロード — キャラクターデータ、進行状況の永続化

#### Phase 3: 品質・スケール

- [ ] オクルージョンカリング — 大規模マップでの描画負荷軽減
- [ ] PBR 拡張 (IBL, SSR, SSAO) — 環境マッピング、スクリーンスペース反射
- [ ] ネットワーク同期 — マルチプレイヤー対応（WebSocket / WebRTC）
- [ ] プロファイラ — フレーム時間、ドローコール、メモリ使用量の可視化
- [x] ホットリロード — Vite ベース dev サーバー + .mbt 変更検知 full-reload
- [ ] ビジュアルエディタ — シーン配置、パラメータ調整 GUI

## アーキテクチャ課題

- [x] CPU ラスタライザ → GPU パイプライン移行: CPU painter's algorithm 削除済み、全 example が GPU Z-buffer レンダラーに統一
- 頂点フォーマットの柔軟化: 現在 stride=8 固定。スキンメッシュではボーンウェイトが必要

## テスト・CI

- [x] Playwright VRT（Visual Regression Testing）— 17 examples の描画スナップショット自動検証
- [x] moon test: 1150 テスト（js target）
- [x] CI: js / native-linux / native-windows / native-macos 4 ジョブ

## 参照

- 完了済み一覧: `docs/mvp.md`
