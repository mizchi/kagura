# TODO (Ebiten 同等機能ロードマップ)

このファイルは未完了タスクのみを管理する。
完了済みは `docs/mvp.md` の `DONE` セクションへ退避。

## ゴール再確認

- 目標: 2D/3D 両対応のゲームエンジンを MoonBit で提供する
- 優先: WebGPU (browser) と native wgpu (macOS) で同一ゲームロジックを早期に動かす
- 非目標: WebGL/WebGL2 フォールバック

## 現在の優先タスク (優先順位順)

### Windows / Linux Native 対応

現在 Native ビルドは macOS のみ対応。wgpu-native と GLFW 自体は Windows/Linux をサポートしているため、以下の対応で拡張可能:

- [ ] `scripts/setup-wgpu-native.sh` を Windows (MSYS2/MinGW) / Linux に対応
- [ ] `moon.pkg` の `cc-link-flags` をプラットフォーム別に分岐（macOS: Metal frameworks、Linux: Vulkan + X11/Wayland、Windows: D3D12/Vulkan）
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

- CPU ラスタライザ → GPU パイプライン移行: scene3d は CPU で頂点変換して 2D コマンドに変換している。`src/gfx_webgpu/` で GPU Z-buffer レンダラーを実装済み、段階的に移行
- 頂点フォーマットの柔軟化: 現在 stride=8 固定。スキンメッシュではボーンウェイトが必要

## テスト・CI

- [x] Playwright VRT（Visual Regression Testing）— 17 examples の描画スナップショット自動検証
- [x] moon test: 1150 テスト（js target）
- [x] CI: js / native-linux / native-windows / native-macos 4 ジョブ

## 参照

- 完了済み一覧: `docs/mvp.md`
