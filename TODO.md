# TODO (kagura roadmap)

このファイルは未完了タスクのみを管理する。
完了済みは `docs/mvp.md` の `DONE` セクションへ退避する。

3D modeling / VLM authoring 関連の未完了は `tools/modeling3d/TODO.md` で管理する。

## ゴール

- `wgpu` renderer を持つ host 上で、wasm guest として 2D/3D アプリケーションコードを動かす
- preview/HMR を強くした code-first 開発体験を作り、MoonBit を基準にしつつ同じ WIT を満たす guest を Rust / Zig にも開く
- WebGL/WebGL2 フォールバックは非目標
- Unity / Godot 風の重い統合 editor を先に作ることは非目標
- 複雑な編集 UI をそのまま利用者に露出することは非目標

## 現在のオープンタスク

### P0: Toolchain / Platform

- [x] Windows native build workaround を GitHub Actions / 実機で確定する
  CI で check + test + build が通る状態になった。`moon test --target native` を追加済み。
  実際の描画実行テストはヘッドレス GPU 不在のため CI では非対応（build 確認のみ）。

### P1: Engine Architecture

- [x] 頂点フォーマットのハードコード stride を定数化する
  `* 8` / `/ 8` リテラルを `vertex3d_stride` 定数に置換済み（gltf, mesh3d, particle3d）。
- [ ] 頂点フォーマットを柔軟化する（次ステップ）
  定数化は完了。スキンメッシュや将来の拡張頂点属性を動的に扱うには、vertex layout descriptor の導入が必要。

### P2: Package Boundary / Deferred

- [ ] glTF/OBJ ローダーを別パッケージへ切り出す
  **依存分析結果:**
  - `gltf` → `scene3d` 依存は `scene_builder.mbt` の1ファイルのみ（`SceneGraph`, `Material`, `scene_node`）
  - `gltf` → `skeleton3d` / `animation3d` 依存は `skin_builder.mbt` の1ファイルのみ
  - `gltf` → `mesh3d` / `math3d` / `transform3d` はコア依存（切り離し不要）
  **切り出し方針:**
  1. `gltf` パッケージを `gltf_core`（パーサ + メッシュビルダ）と `gltf_scene`（シーンビルダ）に分離
  2. `gltf_core` は `mesh3d` / `math3d` / `transform3d` のみに依存（`scene3d` 非依存）
  3. `gltf_scene` は `gltf_core` + `scene3d` + `skeleton3d` + `animation3d` に依存
  4. OBJ ローダーは既に `mesh3d` 内にあり独立している（切り出し不要）
  テクスチャパイプライン安定後に着手する。

## ベンチマーク方針

- ベンチマークゲームは Isometric Hack & Slash ARPG を継続する
- 既存の Phase 進行、レビュー修正、周辺機能の完了分は `docs/mvp.md` を参照する
- 新規の ARPG 固有タスクは、完了済み checklist を増やさず、このファイルの open task として再整理して追加する

## 参照

- 完了済み一覧: `docs/mvp.md`
- 詳細な実装ログ: Git 履歴
